--------------------------------------------------------
--  DDL for Package Body PA_AUTOALLOC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AUTOALLOC_WF_PKG" AS
/*  $Header: PAXWFALB.pls 120.4 2006/05/31 23:01:06 skannoji noship $  */
----------------------------------------------------------------------------
-- This procedure is called from GL workflow activity to launch PA workflow

PROCEDURE Launch_PA_WF ( p_item_type	IN 	VARCHAR2,
                         p_item_key	IN 	VARCHAR2,
                         p_actid	IN 	NUMBER,
                         p_funcmode	IN 	VARCHAR2,
                         p_result	OUT NOCOPY 	VARCHAR2)
IS
v_err_stack	varchar2(2000);
v_debug_file_dir varchar2(255);
v_user_id                       Number;
v_org_id                        Number;
v_resp_id                       Number;
v_resp_appl_id                  Number;
v_lang           varchar2(30);
v_debug_mode     varchar2(1);
Begin
If ( p_funcmode = 'RUN' ) THEN
	v_Err_Stack := 'PA_AUTOALLOC_WF_PKG.Launch_PA_WF';
        G_Err_Stage := 'Starting Launch_PA_WF';
/* 	dbms_output.put_line(G_Err_Stage); */

        -- generate PA workflow item key
	select pa_workflow_itemkey_s.nextval
	into PA_AUTOALLOC_WF_PKG.PA_item_key
	from dual;

/*         dbms_output.put_line('Item Key is '||PA_item_key); */
       	wf_engine.CreateProcess( itemtype => PA_item_type,
                                 itemkey  => PA_item_key,
                                 process  => 'PA_AUTO_ALLOC_PROCESS');
/*         dbms_output.put_line('Created Process'); */
	Init_PA_WF_Stack (PA_Item_Type,PA_Item_Key,v_Err_Stack);

/*Bug:920470. set user_id, resp_id etc. before calling fnd_profile.get()*/
        v_user_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'USER_ID');

        v_org_id     := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'ORG_ID');

        v_resp_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'RESP_ID');

        v_resp_appl_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'RESP_APPL_ID');

        v_lang   := WF_ENGINE.GetItemAttrText
                        (PA_item_type,
                         PA_item_key,
                         'LANG');

        FND_PROFILE.put('LANG', v_lang);

     -- Fix for bug : 4640479
     -- FND_PROFILE.put('ORG_ID', v_org_id);
        MO_GLOBAL.set_policy_context('S',v_org_id);
        FND_PROFILE.put('USER_ID', v_user_id );
        FND_PROFILE.put('RESP_ID', v_resp_id);
        FND_PROFILE.put('RESP_APPL_ID', v_resp_appl_id);
/*end bug920470*/

/*Bug 931037.set workflow attribute DEBUG_MODE,then get the attribute value from
 function DebugFlag         */
        FND_PROFILE.GET('PA_DEBUG_MODE',v_debug_mode);
        Wf_Engine.SetItemAttrText(      itemtype => PA_item_type,
                                        itemkey => PA_item_key,
                                        aname => 'DEBUG_MODE',
                                        avalue => v_debug_mode);
/*End bug 931037*/

	/* Set attribute DEBUG_FILE_DIR and initialize debug  only if
	   Debug Flag is on */
	if DebugFlag then
    	   v_debug_file_dir := GetDebugLogDir; -- Added for bug 5218394
    	   -- Commented out for bug 5218394 v_debug_file_dir :=  NVL(FND_PROFILE.VALUE('PA_DEBUG_LOG_DIRECTORY'),'/sqlcom/log');

	   wf_engine.SetItemAttrText( 	itemtype        => PA_item_type,
                               		itemkey         => PA_item_key,
                               		aname           => 'DEBUG_FILE_DIR',
                               		avalue          => v_debug_file_dir);
/*            dbms_output.put_line('Debug File Dir is '||v_debug_file_dir); */

	   /** Initialize PA debug File **/
	   G_Err_Stage := 'Call Initialize Debug';
/*            dbms_output.put_line(G_Err_Stage); */
           initialize_debug;
	   G_Err_Stage := 'After Initialize Debug';
/*            dbms_output.put_line(G_Err_Stage); */
	end if;

	/* Write to GL debug file */
       	If(GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg_flag) then
           GL_AUTO_ALLOC_WF_PKG.initialize_debug;

       	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('*****************************************');
       	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('Launching PA Autoallocation Workflow');
   	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('PA Workflow Launch Date and Time: '||to_char(sysdate,'DD-MON-YYYY,HH24:MI:SS'));
       	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('Generated PA item Key is: '||PA_item_Key);
       	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('PA debug directory is: '||v_debug_file_dir);
       	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('PA debug file is: '||G_FILE);
       	   GL_AUTO_ALLOC_WF_PKG.diagn_debug_msg('*****************************************');
        End If;

        /** Set GL itemtype and itemkey as PA attributes  **/
      	Wf_Engine.SetItemAttrText(	itemtype => PA_item_type,
				  	itemkey => PA_item_key,
					aname => 'GL_ITEM_TYPE',
					avalue => p_item_type);

      	Wf_Engine.SetItemAttrText(	itemtype => PA_item_type,
				  	itemkey => PA_item_key,
					aname => 'GL_ITEM_KEY',
					avalue => p_item_key);

      	Wf_Engine.SetItemAttrText(	itemtype => PA_item_type,
				  	itemkey => PA_item_key,
					aname => 'WF_LAUNCHED_FROM',
					avalue => 'GL');

       	WriteDebugMsg('*****************************************');
       	WriteDebugMsg('Launching PA Auto Allocation Workflow');
       	WriteDebugMsg('*****************************************');
   	WriteDebugMsg('PA Workflow Launch Date and Time: '||
			to_char(sysdate,'DD-MON-YYYY,HH24:MI:SS'));
	WriteDebugMsg(v_Err_Stack);
       	WriteDebugMsg('Generated PA Item Key = ' ||PA_item_key);
    	WriteDebugMsg('Attribute DEBUG_FILE_DIR = '||v_debug_file_dir);
	WriteDebugMsg('Attribute GL_ITEM_TYPE = '||p_item_type);
	WriteDebugMsg('Attribute GL_ITEM_KEY = '||p_item_key);

	G_Err_Stage:= 'Creating Process PA_AUTO_ALLOC_PROCESS';
	WriteDebugMsg(G_ERR_STAGE);
	Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);

	G_Err_Stage:= 'Initialize PA WorkFlow Item Attributes ';
	Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
	WriteDebugMsg(G_ERR_STAGE);

       	--initialize pl/sql and pa wf item attributes
       	initialize_pa_wf;

       	G_Err_Stage := 'Process PA_AUTO_ALLOC_PROCESS starting';
	WriteDebugMsg(G_ERR_STAGE);
	Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);

       	Wf_engine.StartProcess( itemtype => PA_item_type,
                                itemkey  => PA_item_key );

       	wf_engine.SetItemAttrText( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'PA_WF_STATUS',
                                   avalue       => NULL );
	p_result := 'COMPLETE:PASS';

	G_Err_Stage:= 'End of the API: Launch_PA_WF ';
	Set_PA_WF_Stage(PA_Item_Type,PA_Item_key,G_Err_Stage);
	WriteDebugMsg(G_ERR_STAGE);

 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

 EXCEPTION
    WHEN NO_DATA_FOUND then
       Wf_Core.Context('PA_AUTOALLOC_WF_PKG',
                      'Launch_PA_WF', PA_item_type, PA_item_key,
			'Item Type could not be set: sequence does not exist');
       Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
       WriteDebugMsg('*************** Error Encountered **************');
       WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
       wf_engine.SetItemAttrText( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'PA_WF_STATUS',
                                   avalue       => 'FAIL' );
       p_result := 'COMPLETE:FAIL';

       Raise;
    WHEN OTHERS THEN
       Wf_Core.Context( 'PA_AUTOALLOC_WF_PKG','Launch_PA_WF', G_Err_Stage,
				PA_item_type, PA_item_key);
       Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
       WriteDebugMsg('*************** Error Encountered **************');
       WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
       wf_engine.SetItemAttrText( itemtype     => p_item_type,
                                  itemkey      => p_item_key,
                                  aname        => 'PA_WF_STATUS',
                                 avalue       => 'FAIL' );
       p_result := 'COMPLETE:FAIL';
       Raise;

End Launch_PA_WF;
--------------------------------------------------------------------------------------
PROCEDURE initialize_pa_wf
IS

--      Local variables
	v_err_stack			   Varchar2(2000);
        v_gl_item_type 			   Varchar2(10);
	v_gl_item_key			   Varchar2(40);
        v_ALLOCATION_SET_NAME              Varchar2(40);
	v_SET_REQ_ID		   	   Number;
        v_OWNER                            Varchar2(100);
        v_SET_OF_BOOKS_ID                  Number;
        v_GL_PERIOD_NAME		   Varchar2(15);
        v_PA_PERIOD_NAME		   Varchar2(15);
	v_EXPENDITURE_ITEM_DATE		   Date;
        v_LAST_UPDATE_LOGIN                Number;
        v_CREATED_BY  	                   Number;
        v_LAST_UPDATED_BY                  Number;
        v_FUNC_CURR                        Varchar2(15);
        v_monitor_url                      VARCHAR2(500);
        v_rollback_allowed                 VARCHAR2(1);
        v_resp_id                          NUMBER;
        v_user_id                          NUMBER;
        v_org_id                           NUMBER;
        v_resp_appl_id                     NUMBER;
	v_operating_mode		   Varchar2(2);
	v_batch_id			   Number;
/* Changing the length of v_batch_name from varchar2(40) to varchar2(60)
   for bug# 1721283 since PA_ALLOC_RULES_ALL.RULE_NAME
   is now length 60 */
	v_batch_name			   Varchar2(60);
	v_batch_type_code		   Varchar2(1);
	v_allocation_method_code	   Varchar2(1);
	v_step_number 			   Number;
        v_lang        fnd_profile_option_values.profile_option_value%TYPE;
        v_value       fnd_profile_option_values.profile_option_value%TYPE;
	v_launched_from		   	   VARCHAR2(10);

 Begin

    G_Err_Stage := 'Entering initialize_pa_wf';
/*     dbms_output.put_line (G_Err_Stage); */
    Set_PA_WF_Stack(PA_item_type,PA_item_key,'Initialize_PA_WF');
    v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
    WriteDebugMsg(v_err_stack);
    G_Err_Stage := 'Get GL Item Attributes';
    WriteDebugMsg(G_Err_Stage);
    Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);

    -- Get all the GL item attributes
    v_gl_item_type := wf_engine.GetItemAttrText(itemtype =>PA_item_type,
						itemkey => PA_item_key,
						aname => 'GL_ITEM_TYPE');

    v_gl_item_key := wf_engine.GetItemAttrText(itemtype =>PA_item_type,
						itemkey =>PA_item_key,
						aname => 'GL_ITEM_KEY');

    v_ALLOCATION_SET_NAME := wf_engine.GetItemAttrText
					( itemtype => v_gl_item_type,
				  	  itemkey => v_gl_item_key,
					  aname => 'SET_NAME');

    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					  	itemkey => v_gl_item_key,
						aname => 'SET_REQ_ID');

    v_USER_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					     itemkey => v_gl_item_key,
					     aname => 'USER_ID');

    v_ORG_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					    itemkey => v_gl_item_key,
					    aname => 'ORG_ID');

    v_RESP_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					     itemkey => v_gl_item_key,
					     aname => 'RESP_ID');

    v_RESP_APPL_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					  	 itemkey => v_gl_item_key,
						 aname => 'RESP_APPL_ID');

    v_LANG := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
					itemkey => v_gl_item_key,
				 	aname => 'LANG');

    v_ROLLBACK_ALLOWED := WF_ENGINE.GetItemAttrText
					(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'ROLLBACK_ALLOWED');

    v_OWNER := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'STEP_CONTACT');

    v_EXPENDITURE_ITEM_DATE := WF_ENGINE.GetItemAttrDate
					(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'EXPENDITURE_ITEM_DATE');

    v_GL_PERIOD_NAME := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'GL_PERIOD_NAME');

    v_PA_PERIOD_NAME := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'PA_PERIOD_NAME');

    v_CREATED_BY := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					  	 itemkey => v_gl_item_key,
						 aname => 'CREATED_BY');

    v_LAST_UPDATED_BY := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
					  	 itemkey => v_gl_item_key,
						 aname => 'LAST_UPDATED_BY');

    v_LAST_UPDATE_LOGIN := WF_ENGINE.GetItemAttrNumber
						(itemtype => v_gl_item_type,
					  	 itemkey => v_gl_item_key,
						 aname => 'LAST_UPDATE_LOGIN');

    v_OPERATING_MODE := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'OPERATING_MODE');

    v_STEP_NUMBER := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
                                         	 itemkey => v_gl_item_key,
                                         	 aname => 'STEP_NUMBER');

    v_BATCH_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
                                         	 itemkey => v_gl_item_key,
                                         	 aname => 'BATCH_ID');

    v_BATCH_NAME := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
                                         	 itemkey => v_gl_item_key,
                                         	 aname => 'BATCH_NAME');

    v_BATCH_TYPE_CODE := WF_ENGINE.GetItemAttrText(itemtype => v_gl_item_type,
                                         	 itemkey => v_gl_item_key,
                                         	 aname => 'BATCH_TYPE_CODE');

    v_ALLOCATION_METHOD_CODE := WF_ENGINE.GetItemAttrText
					(itemtype => v_gl_item_type,
                                         itemkey => v_gl_item_key,
                                         aname => 'ALLOCATION_METHOD_CODE');

    v_SET_OF_BOOKS_ID := WF_ENGINE.GetItemAttrNumber(itemtype => v_gl_item_type,
                                         	 itemkey => v_gl_item_key,
                                         	 aname => 'SET_OF_BOOKS_ID');

    -- Set PA item attributes based on GL item attributes
    G_Err_Stage:= 'Set PA Item Attributes';
    Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
    WriteDebugMsg(G_Err_Stage);

    -- Set item user key
    wf_engine.SetItemUserKey( itemtype => PA_item_type,
                                  itemkey  => PA_item_key,
                                  userkey  => v_allocation_set_name );

    wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'SET_NAME',
                                  avalue    => v_allocation_set_name );
    WriteDebugMsg('Attribute Allocation Set_Name = '||v_allocation_set_name);

    begin
    v_monitor_url :=
                  wf_monitor.GetDiagramUrl(wf_core.translate('WF_WEB_AGENT'),
                                     PA_item_type, PA_item_key,'YES');
    exception
	when others then
	   v_monitor_url := 'Invalid URL';
    end;

     wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'MONITOR_URL',
                                   avalue          => v_monitor_url);

    WriteDebugMsg('Attribute MONITOR_URL = '||v_monitor_url);

    wf_engine.SetItemAttrNumber( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'SET_REQ_ID',
                                   avalue       => v_set_req_id );
    WriteDebugMsg('Attribute Set_Req_ID is = '||to_char(v_set_req_id));

    wf_engine.SetItemAttrNumber(   itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'PA_ITEM_KEY',
                                   avalue       => PA_item_key );
    WriteDebugMsg('Attribute PA_Item_Key is = '||PA_ITEM_KEY);

    wf_engine.SetItemAttrNumber( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'USER_ID',
                                   avalue       => v_user_id );
    WriteDebugMsg('Attribute User_ID is = '||to_char(v_user_id));

    wf_engine.SetItemAttrNumber( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'ORG_ID',
                                   avalue       => v_org_id );
    WriteDebugMsg('Attribute Org_ID is = '||to_char(v_org_id));

    wf_engine.SetItemAttrNumber( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'RESP_ID',
                                   avalue       => v_resp_id );
    WriteDebugMsg('Attribute Resp_ID is = '||to_char(v_resp_id));

    wf_engine.SetItemAttrNumber( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'RESP_APPL_ID',
                                   avalue       => v_resp_appl_id );
    WriteDebugMsg('Attribute Resp_Appl_ID is = '||to_char(v_resp_appl_id));

    wf_engine.SetItemAttrText( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'LANG',
                                   avalue       => v_lang );

    WriteDebugMsg('Lang  =' ||v_lang);

    wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'ROLLBACK_ALLOWED',
                                   avalue          => v_rollback_allowed);
    WriteDebugMsg('Attribute Roolback_Allowed = ' ||v_rollback_allowed);

    wf_engine.SetItemAttrText( itemtype     => PA_item_type,
                                   itemkey      => PA_item_key,
                                   aname        => 'MONITOR_URL',
                                   avalue       => v_monitor_url );
    WriteDebugMsg('Attribute Monitor_URL = ' ||v_monitor_url);

    wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'STEP_CONTACT',
                                   avalue          => v_OWNER);
    WriteDebugMsg('Attribute Step_Contact = ' ||v_owner);

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'SET_OF_BOOKS_ID',
                                   avalue          => v_SET_OF_BOOKS_ID);
    WriteDebugMsg('Attribute SET_OF_BOOKS_ID = ' ||to_char(v_SET_OF_BOOKS_ID));

    wf_engine.SetItemAttrDate( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'EXPENDITURE_ITEM_DATE',
                                   avalue          => v_EXPENDITURE_ITEM_DATE);
    WriteDebugMsg('Attribute EXPENDITURE_ITEM_DATE = ' ||
                           to_char(v_EXPENDITURE_ITEM_DATE));

    wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'GL_PERIOD_NAME',
                                   avalue          => v_GL_PERIOD_NAME);
    WriteDebugMsg('Attribute GL_PERIOD_NAME = ' ||v_GL_PERIOD_NAME);

    wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'PA_PERIOD_NAME',
                                   avalue          => v_PA_PERIOD_NAME);
    WriteDebugMsg('Attribute PA_PERIOD_NAME =  ' ||v_PA_PERIOD_NAME);

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'CREATED_BY',
                                   avalue          => v_CREATED_BY);
    WriteDebugMsg('Attribute CREATED_BY =  ' ||to_char(v_CREATED_BY));

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'LAST_UPDATED_BY',
                                   avalue          => v_LAST_UPDATED_BY);
    WriteDebugMsg('Attribute LAST_UPDATED_BY = ' ||to_char(v_LAST_UPDATED_BY));

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'LAST_UPDATE_LOGIN',
                                   avalue          => v_LAST_UPDATE_LOGIN);
    WriteDebugMsg('Attribute LAST_UPDATE_LOGIN = '
				||to_char(v_LAST_UPDATE_LOGIN));
    wf_engine.SetItemAttrText( 	   itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'OPERATING_MODE',
                                   avalue          => v_operating_mode);
    WriteDebugMsg('Attribute Operating Mode = ' ||v_operating_mode);

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'STEP_NUMBER',
                                   avalue          => v_step_number);
    WriteDebugMsg('Attribute Step Number = ' ||to_char(v_step_number));

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'BATCH_ID',
                                   avalue          => v_batch_id);
    WriteDebugMsg('Attribute Batch ID = ' ||to_char(v_batch_id));

    wf_engine.SetItemAttrText( 	   itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'BATCH_NAME',
                                   avalue          => v_batch_name);
    WriteDebugMsg('Attribute Batch Name  = ' ||v_batch_name);

    wf_engine.SetItemAttrText( 	   itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'BATCH_TYPE_CODE',
                                   avalue          => v_batch_type_code);
    WriteDebugMsg('Attribute Batch Type Code  = ' ||v_batch_type_code);

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                   itemkey         => PA_item_key,
                                   aname           => 'SET_OF_BOOKS_ID',
                                   avalue          => v_set_of_books_id);
    WriteDebugMsg('Attribute Set Of Books ID = ' ||to_char(v_set_of_books_id));

    WF_Engine.SetItemAttrText(itemtype => PA_item_type,
			      itemkey  => PA_item_key,
			      aname    => 'DEFINITION_FORM',
			      avalue   => NULL);

    G_Err_Stage := 'Set PA specific Item Attributes';
    WriteDebugMsg(G_Err_Stage);
    Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);

-- Set PA specific item attributes
    wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                               itemkey         => PA_item_key,
                               aname           => 'PARENT_PROCESS',
                               avalue          => 'GL');
    WriteDebugMsg('Attribute PARENT_PROCESS = GL');

    wf_engine.SetItemAttrNumber( itemtype        => PA_item_type,
                                 itemkey         => PA_item_key,
                                 aname           => 'REVERSED_STEP_NUMBER',
                                 avalue          => 0);
    WriteDebugMsg('Attribute Reversed_Step_Number = 0 ');

    wf_engine.SetItemAttrText( itemtype        => PA_item_type,
                               itemkey         => PA_item_key,
                               aname           => 'EXPENDITURE_GROUP',
                               avalue          => 'NONE');
    WriteDebugMsg('Attribute EXPENDITURE_GROUP =  NONE ');

    v_launched_from := WF_ENGINE.GetItemAttrText(itemtype =>PA_item_type,
					  	 itemkey => PA_item_key,
						 aname => 'WF_LAUNCHED_FROM');
    IF v_launched_from = 'GL' THEN
       wf_engine.SetItemAttrText( 	itemtype        => PA_item_type,
                               		itemkey         => PA_item_key,
                               		aname           => 'GL_BLOCK_ACTIVITY',
                               		avalue          => 'PA_CHECK_WF');
       WriteDebugMsg('Attribute GL Block Activity  =  '||'PA_CHECK_WF');
    END IF;

    Reset_PA_WF_Stack(PA_item_type,PA_item_key);
  EXCEPTION
    WHEN OTHERS THEN
     Reset_PA_WF_Stack(PA_item_type,PA_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG',
                      'initialize_pa_wf', PA_item_type, PA_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg ('************ Error Encountered **************');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     Raise;
End initialize_pa_wf;
--------------------------------------------------------------------------------------
/** This function submits Concurrent Process to generate Project Allocation Transactions.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Alloc_Process(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT  NOCOPY	VARCHAR2) Is

v_request_id            NUMBER;
v_parent_process	VARCHAR2(30);
v_allocation_run_id	NUMBER;
v_rule_id		NUMBER;
v_pa_period_name	VARCHAR2(20);
v_gl_period_name	VARCHAR2(20);
v_expnd_item_date	DATE;
v_step_number		NUMBER;
l_allocation_method_code Varchar2(1);
v_set_req_id		Number;
v_err_stack		Varchar2(2000);
vc_expnd_item_date	Varchar2(20);

Begin
If ( p_funcmode = 'RUN' ) THEN

   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;

   Set_PA_WF_Stack(p_item_type,p_item_key,'Submit_Alloc_Process');
   v_err_stack := WF_ENGINE.GetItemAttrText(	p_item_type,
						p_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);
   WriteDebugMsg('Activity ID is'||to_char(p_actid));


   v_parent_process := WF_ENGINE.GetItemAttrText (	p_item_type
                         				,p_item_key
                         				,'PARENT_PROCESS');
   WriteDebugMsg('Attribute Parent Process = '||v_parent_process);

/* Set attributes Concurrent Program Code and Name */

  WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'CONC_PRG_CODE',
				'PAXALGAT');
   WriteDebugMsg('Attribute CONC_PRG_CODE = '||'PAXALGAT');

/* Get Parameters needed to submit Allocation Generation Process */

   v_rule_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'BATCH_ID');
   WriteDebugMsg('Attribute Batch ID  = '||to_char(v_rule_id));

   v_expnd_item_date := WF_ENGINE.GetItemAttrDate(p_item_type,
				  	 		p_item_key,
					 		'EXPENDITURE_ITEM_DATE');
   WriteDebugMsg('Attribute EXPENDITURE_ITEM_DATE  = '
					||to_char(v_expnd_item_date));

   v_pa_period_name := WF_ENGINE.GetItemAttrText(	p_item_type,
                         				p_item_key,
                         				'PA_PERIOD_NAME');
   WriteDebugMsg('Attribute PA_PERIOD_NAME  = '||v_pa_period_name);

   v_gl_period_name := WF_ENGINE.GetItemAttrText(	p_item_type,
                         				p_item_key,
                         				'GL_PERIOD_NAME');
   WriteDebugMsg('Attribute GL_PERIOD_NAME  = '||v_gl_period_name);

   G_Err_Stage := 'Submit Generate Allocation Transactions Concurrent Process';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);

  IF  v_parent_process in ( 'GL','Concurrent Process Error') THEN

      /** First time submission and restart after concurrent process
	  errors out as no draft is generated **/

      vc_expnd_item_date :=fnd_date.date_to_canonical(v_expnd_item_date);
      WriteDebugMsg('Expenditure Item Date in char format:='||
					vc_expnd_item_date);

    v_request_id := Submit_Conc_Process('PAXALGAT'
				   	,p_arg1 => v_rule_id
		    		   	,p_arg2 => vc_expnd_item_date
					,p_arg3 => v_pa_period_name
					,p_arg4 => v_gl_period_name
		 		   	);
  ELSIF v_parent_process = 'Concurrent Process Exception' THEN

     /** Generate Allocation process has generated draft having status
	 'DF' or 'IP'  so Delete Draft before restart**/

    v_allocation_run_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                         				p_item_key,
                         				'ALLOCATION_RUN_ID');
    G_Err_Stage:='Delete Draft before submitting Allocation Concurrent Process';
    Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
    WriteDebugMsg(G_Err_Stage);

    PA_ALLOC_RUN.Delete_ALLOC_TXNS (v_rule_id,
				     v_allocation_run_id);

    vc_expnd_item_date :=fnd_date.date_to_canonical(v_expnd_item_date);
    WriteDebugMsg('Expenditure Item Date in char format:='
						||vc_expnd_item_date);

     v_request_id := Submit_Conc_Process('PAXALGAT'
				   	,p_arg1 => v_rule_id
		    		   	,p_arg2 => vc_expnd_item_date
					,p_arg3 => v_pa_period_name
					,p_arg4 => v_gl_period_name
		 		   	);
  END IF;

  WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'PARENT_PROCESS',
				'Generate Allocation');

  G_Err_Stage:='End Of API: Submit_Alloc_Process';
  Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
  WriteDebugMsg(G_Err_Stage);

  Reset_PA_WF_Stack(p_item_type,p_item_key);
  p_result := 'COMPLETE';
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  WHEN OTHERS THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'SUBMIT_ALLOC_PROCESS',
						p_item_type, p_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('*********** Error Encountered ***********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error

     v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
     Raise;

END Submit_Alloc_Process;
--------------------------------------------------------------------------------

/** This function submits Concurrent Process to Update Project Summary Amounts.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_Sum(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT  NOCOPY	VARCHAR2) Is

v_request_id            NUMBER;
v_parent_process	VARCHAR2(30);
v_allocation_run_id	NUMBER;
v_rule_id		NUMBER;
v_pa_period_name	VARCHAR2(20);
v_gl_period_name	VARCHAR2(20);
v_expenditure_item_date	DATE;
v_step_number		NUMBER;
l_allocation_method_code Varchar2(1);
v_batch_id		Number;
v_set_req_id		Number;
v_debug_mode		Varchar2(30);
v_err_stack		Varchar2(2000);
v_operating_mode	Varchar2(2);

Begin
If ( p_funcmode = 'RUN' ) THEN
   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;

   Set_PA_WF_Stack(p_item_type,p_item_key,'Submit_Conc_Sum');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_parent_process := WF_ENGINE.GetItemAttrText (	p_item_type
                         				,p_item_key
                         				,'PARENT_PROCESS');

   v_set_req_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'SET_REQ_ID');

   v_step_number := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'STEP_NUMBER');

   v_allocation_run_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'ALLOCATION_RUN_ID');

   v_operating_mode := WF_ENGINE.GetItemAttrText(p_item_type,
                         			p_item_key,
                         			'OPERATING_MODE');

/* Set attributes Concurrent Program Code and Name */

   WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'CONC_PRG_CODE',
				'PAXACMPT');
   WriteDebugMsg('Attribute CONC_PRG_CODE = PAXACMPT');

/* Get Parameters needed to submit the concurrent Process */
    FND_PROFILE.GET('PA_DEBUG_MODE',v_debug_mode);
   WriteDebugMsg('Debug Mode value = '||v_debug_mode);

/** Set default values to all required parameters **/
   v_request_id := Submit_Conc_Process(p_prog_code => 'PAXACMPT'
					,p_arg4  => 'Y'
					,p_arg6  => 'Y'
					,p_arg7  => 'Y'
					,p_arg9  => 'Y'
				   	,p_arg10 => v_debug_mode
					,p_arg11 => 'AUTO_ALLOCATION'
					,p_arg12 => v_allocation_run_id
					,p_arg13 => 'Y'
					,p_arg15  => 'I'
		 		   	);

   G_Err_Stage := 'End of API: Submit_Conc_Sum';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(p_item_type,p_item_key);

   p_result := 'COMPLETE';

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  WHEN OTHERS THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'SUBMIT_CONC_SUM',
					PA_item_type, PA_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('********** Error Encountered *********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error
     v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
     Raise;

END Submit_Conc_Sum;

--------------------------------------------------------------------------------

/** This function calls an API for Allocation Run Reversal.This is part of Rollback Process. This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_AllocRev(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT  NOCOPY	VARCHAR2) Is

v_request_id            NUMBER;
v_parent_process	VARCHAR2(30);
v_allocation_run_id	NUMBER;
v_rule_id		NUMBER;
v_pa_period_name	VARCHAR2(20);
v_gl_period_name	VARCHAR2(20);
v_expenditure_item_date	DATE;
v_step_number		NUMBER;
l_allocation_method_code Varchar2(1);
v_batch_id		Number;
v_set_req_id		Number;
v_rev_tgt_exp_group  	Varchar2(50);
v_rev_off_exp_group  	Varchar2(50);
v_target_exp_group	Varchar2(50);
v_offset_exp_group	Varchar2(50);
v_run_status		Varchar2(2);
v_org_id		Number;
v_operating_mode	Varchar2(2);
v_status_code		Varchar2(15);
v_message_name		Varchar2(150);
v_retcode	 	Number;
v_errbuf		Varchar2(30);
v_prog_code		Varchar2(30);
v_rollback_allowed	Varchar2(2);

Begin
If ( p_funcmode = 'RUN' ) THEN

   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
   WriteDebugMsg('Started Submit_Conc_AllocRev');

   v_parent_process := WF_ENGINE.GetItemAttrText (	p_item_type
                         				,p_item_key
                         				,'PARENT_PROCESS');

   v_set_req_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'SET_REQ_ID');

   v_step_number := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'STEP_NUMBER');

   v_operating_mode := WF_ENGINE.GetItemAttrText(p_item_type,
                         			 p_item_key,
                         			'OPERATING_MODE');

   v_allocation_run_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'ALLOCATION_RUN_ID');

   v_rule_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'BATCH_ID');

/* Set attributes Program Code and Name */

   WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'CONC_PRG_CODE',
				'PAXALGAT');

   select run_status,target_exp_group,offset_exp_group
   into v_run_status,v_target_exp_group,v_offset_exp_group
   from pa_alloc_runs_all
   where run_id = v_allocation_run_id;

   if v_run_status in ('DF','DS','RF','IP') then
      PA_ALLOC_RUN.Delete_ALLOC_TXNS (v_rule_id,
				      v_allocation_run_id);
   elsif  v_run_status = 'RV' then
      p_result := 'COMPLETE:PASS';
   else
      /* Set the reversed exp group values */
      v_rev_tgt_exp_group := Substr(v_target_exp_group,1,30)||'!'||
					substr(p_item_key,1,19);
      v_rev_off_exp_group := Substr(v_offset_exp_group,1,30)||'!'||
					substr(p_item_key,1,19);
      G_Err_Stage:= 'Calling Reverse_alloc_txns';
      WriteDebugMsg(G_Err_Stage);

      PA_ALLOC_RUN.Reverse_alloc_txns( 	v_rule_id
                             		,v_allocation_run_id
                             		,v_rev_tgt_exp_group
                             		,v_rev_off_exp_group
                             		,v_retcode
                             		,v_errbuf
                            		);
      if v_retcode = -1 then
/** ??? what will be the v_prog_code **/
         Get_Status_and_Message(v_Prog_Code
                          ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);

          -- Program Error
         GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
                    );

         wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
				  avalue    => v_message_name);

	 WriteDebugMsg('Attribute Message Name = '||v_message_name);
         p_result := 'COMPLETE:FAIL';
       Else
         p_result := 'COMPLETE:PASS';
       End If;

   end if;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'SUBMIT_CONC_ALLOCREV', PA_item_type, PA_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('************* Error Encountered ************');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error
    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;

END Submit_Conc_AllocRev;
--------------------------------------------------------------------------------

PROCEDURE Check_Exp_Groups(		p_item_type	IN	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                         		p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2)
IS

v_allocation_run_id	NUMBER;
v_batch_id		NUMBER;
v_org_id		NUMBER;
v_parent_process	VARCHAR2(30);
v_err_stack		VARCHAR2(2000);
v_target_exp_group	VARCHAR2(50);
v_offset_exp_group	VARCHAR2(50);
v_operating_mode	VARCHAR2(2);
v_expenditure_group	Varchar2(50);
v_step_number 		Number;
v_set_req_id		Number;

BEGIN

If ( p_funcmode = 'RUN' ) THEN

   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
   Set_PA_WF_Stack(PA_item_type,PA_item_key,'Check_Exp_Groups');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

   v_org_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');

   v_batch_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BATCH_ID');
   v_allocation_run_id := WF_ENGINE.GetItemAttrNumber
                        	(p_item_type,
                         	 p_item_key,
                         	'ALLOCATION_RUN_ID');

   v_parent_process := WF_ENGINE.GetItemAttrText
                        	(p_item_type,
                         	 p_item_key,
                         	'PARENT_PROCESS');

   v_operating_mode := WF_ENGINE.GetItemAttrText
                        	(p_item_type,
                         	 p_item_key,
                         	'OPERATING_MODE');

   v_expenditure_group := WF_ENGINE.GetItemAttrText
                        	(p_item_type,
                         	 p_item_key,
                         	'EXPENDITURE_GROUP');
   WriteDebugMsg('The attribute Expenditure Group is: '||v_expenditure_group);

   /** Select target_exp_group and offset_exp_group in NORMAL mode and
	rev_target_exp_group and rev_offset_exp_group in ROLLBACK mode **/

   select decode (v_operating_mode,'N',target_exp_group,
						rev_target_exp_group),
	  decode (v_operating_mode, 'N',offset_exp_group,
						rev_offset_exp_group)
   into v_target_exp_group,v_offset_exp_group
   from pa_alloc_runs_all
   where run_id = v_allocation_run_id;

   WriteDebugMsg('Target Expenditure Group : '||v_target_exp_group);
   WriteDebugMsg('Offset Expenditure Group : '||v_offset_exp_group);

   /** Initial value of expenditure group is NONE. To check if all the
	expenditure group has been costed or not first time item attribute
	EXPENDITURE_GROUP value is set to target_exp_group. Once that is
	processed the attribute value is set to offset_exp_group **/

   IF v_expenditure_group = 'NONE' THEN
      wf_engine.SetItemAttrText(
      		itemtype  => p_item_type,
      		itemkey   => p_item_key,
      		aname     => 'EXPENDITURE_GROUP',
		avalue	  => v_target_exp_group);
      WriteDebugMsg('Setting the attribute Expenditure_Group : '||v_target_exp_group);
      p_result := 'COMPLETE:Y';
   ELSIF (v_expenditure_group = v_target_exp_group) AND
	 (v_expenditure_group <> v_offset_exp_group) THEN
      wf_engine.SetItemAttrText(
      		itemtype  => p_item_type,
      		itemkey   => p_item_key,
      		aname     => 'EXPENDITURE_GROUP',
		avalue	  => v_offset_exp_group);
      WriteDebugMsg('Setting the attribute Expenditure Group : '||v_offset_exp_group);
      p_result := 'COMPLETE:Y';
   ELSE
      p_result := 'COMPLETE:N';
   END IF;
   Reset_PA_WF_Stack(p_item_type,p_item_key);

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Exp_Groups', PA_item_type, PA_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('**************** Error Encountered ***************');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error
     v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;

  WHEN OTHERS THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Exp_Groups', PA_item_type, PA_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('**************** Error Encountered ***************');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error
     v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;

END Check_Exp_Groups;
-------------------------------------------------------------------------------
/** This function submits Concurrent Process to Distribute Cost.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_Process_Dist(	p_item_type	IN	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                         		p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT  NOCOPY	VARCHAR2)
IS

v_err_stack		VARCHAR2(2000);
v_request_id            NUMBER;
v_parent_process	VARCHAR2(30);
v_allocation_run_id	NUMBER;
v_rule_id		NUMBER;
v_pa_period_name	VARCHAR2(20);
v_gl_period_name	VARCHAR2(20);
v_expenditure_item_date	DATE;
v_allocation_run_id	NUMBER;
v_step_number		NUMBER;
l_allocation_method_code Varchar2(1);
v_batch_id		Number;
v_set_req_id		Number;
v_expenditure_group	Varchar2(50);
v_debug_mode		Varchar2(30);
v_operating_mode	Varchar2(2);

Begin
If ( p_funcmode = 'RUN' ) THEN

    PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
    Set_PA_WF_Stack(PA_item_type,PA_item_key,'Submit_Conc_Process_Dist');
    v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
    WriteDebugMsg(v_err_stack);

   v_step_number := WF_ENGINE.GetItemAttrNumber(p_item_type,
                         			p_item_key,
                         			'STEP_NUMBER');

   /** Get Attribute values to be passed as parameters **/

   v_parent_process := WF_ENGINE.GetItemAttrText (	p_item_type
                         				,p_item_key
                         				,'PARENT_PROCESS');

   v_set_req_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'SET_REQ_ID');

   v_operating_mode := WF_ENGINE.GetItemAttrText(	p_item_type,
                         				p_item_key,
                         				'OPERATING_MODE');

/* Set attributes Concurrent Program Code and Name */

   WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'CONC_PRG_CODE',
				'PASDUC');
   WriteDebugMsg('The Attribute CONC_PRG_CODE value is: PASDUC ');

/* Get Parameters needed to submit Distribute Usage and Misc Costs*/
   v_expenditure_group := WF_ENGINE.GetItemAttrText(	p_item_type,
							p_item_key,
							'EXPENDITURE_GROUP');
   WriteDebugMsg('The attribute EXPENDITURE_GROUP is '||v_expenditure_group);

   FND_PROFILE.GET('PA_DEBUG_MODE',v_debug_mode);
   Writedebugmsg('Debug Mode = '||v_debug_mode);

/* Bug  2497324 change p_arg9 to p_arg11 as two parameters added in the process */
   v_request_id := Submit_Conc_Process(
				p_prog_code => 'PASDUC'
				,p_arg1 => v_expenditure_group
				,p_arg11 => v_debug_mode
		 		   	);

   G_Err_Stage := 'End of API: Submit_Conc_Process_Dist';

   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(p_item_type,p_item_key);

   p_result := 'COMPLETE';

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  WHEN OTHERS THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Submit_Conc_Process_Dist', PA_item_type, PA_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('*********** Error Encountered ***********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error
     v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;
END Submit_Conc_Process_Dist;

--------------------------------------------------------------------------------
/** This function submits a concurrent request and returns the request id **/

Function  Submit_Conc_Process(
         p_prog_code	IN 	VARCHAR2
         ,p_arg1	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg2	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg3	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg4	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg5	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg6	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg7	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg8	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg9	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg10	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg11	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg12	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg13	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg14	IN 	VARCHAR2 DEFAULT NULL
         ,p_arg15	IN 	VARCHAR2 DEFAULT NULL)

Return Number Is

v_userenv_lang                	Varchar2(10);
v_conc_prg_name               	Varchar2(240);
v_user_id                     	Number;
v_org_id                      	Number;
v_resp_id                     	Number;
v_resp_appl_id                	Number;
v_created_by			Number;
v_last_updated_by		Number;
v_last_update_login		Number;
v_lang                        	Varchar2(30);
v_rollback_allowed            	Varchar2(1);
v_request_id 			NUMBER;
v_err_stack		      	Varchar2(2000);
v_step_number			NUMBER;
v_set_req_id			Number;
v_operating_mode		Varchar2(2);

v_status_code                 	Varchar2(15);
v_message_Name                	Varchar2(150);
x_org_id                        NUMBER := mo_global.get_current_org_id ;

-- Needs Modification
Cursor conc_prog_name_C  IS
Select tl.USER_CONCURRENT_PROGRAM_NAME
From fnd_concurrent_programs_tl tl,
     fnd_concurrent_programs cp
Where cp.APPLICATION_ID = 275
AND cp.CONCURRENT_PROGRAM_NAME = p_prog_code
AND tl.CONCURRENT_PROGRAM_ID = cp.concurrent_program_id
AND tl.APPLICATION_ID = 275
AND tl.LANGUAGE = NVL(v_userenv_lang,'US');

Begin
    Set_PA_WF_Stack(PA_item_type,PA_item_key,'Submit_Conc_Process');
    v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   WriteDebugMsg('p_arg1='||p_arg1);
   WriteDebugMsg('p_arg2='||p_arg2);
   WriteDebugMsg('p_arg3='||p_arg3);
   WriteDebugMsg('p_arg4='||p_arg4);
   WriteDebugMsg('p_arg5='||p_arg5);
   WriteDebugMsg('p_arg6='||p_arg6);
   WriteDebugMsg('p_arg7='||p_arg7);
   WriteDebugMsg('p_arg8='||p_arg8);
   WriteDebugMsg('p_arg9='||p_arg9);
   WriteDebugMsg('p_arg10='||p_arg10);
   WriteDebugMsg('p_arg11='||p_arg11);
   WriteDebugMsg('p_arg12='||p_arg12);
   WriteDebugMsg('p_arg13='||p_arg13);
   WriteDebugMsg('p_arg14='||p_arg14);
   WriteDebugMsg('p_arg15='||p_arg15);
   WriteDebugMsg('Prog_Code='||p_prog_code);

   v_user_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'USER_ID');

   v_org_id     := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'ORG_ID');

   v_resp_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'RESP_ID');

   v_resp_appl_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'RESP_APPL_ID');

   v_lang   := WF_ENGINE.GetItemAttrText
                        (PA_item_type,
                         PA_item_key,
                         'LANG');

   v_set_req_id := WF_ENGINE.GetItemAttrNumber(	PA_item_type,
                         			PA_item_key,
                         			'SET_REQ_ID');

   v_step_number := WF_ENGINE.GetItemAttrNumber(	PA_item_type,
                         				PA_item_key,
                         				'STEP_NUMBER');

   v_operating_mode := WF_ENGINE.GetItemAttrText(PA_item_type,
                         			PA_item_key,
                         			'OPERATING_MODE');
   v_created_by   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'CREATED_BY');

   v_last_updated_by := WF_ENGINE.GetItemAttrNumber
                       		(PA_item_type,
                         	 PA_item_key,
                         	 'LAST_UPDATED_BY');

   v_last_update_login := WF_ENGINE.GetItemAttrNumber
                       		(PA_item_type,
                         	 PA_item_key,
                         	 'LAST_UPDATE_LOGIN');

    FND_PROFILE.put('LANG', v_lang);
    -- Fix for bug : 4640479
    -- FND_PROFILE.put('ORG_ID', v_org_id);
    MO_GLOBAL.set_policy_context('S',v_org_id);
    FND_PROFILE.put('USER_ID', v_user_id );
    FND_PROFILE.put('RESP_ID', v_resp_id);
    FND_PROFILE.put('RESP_APPL_ID', v_resp_appl_id);

    FND_PROFILE.GET('LANG', v_userenv_lang);
    WriteDebugMsg('User Env. Lang = '||v_userenv_lang);

    Open conc_prog_name_C;
    Fetch conc_prog_name_C into v_conc_prg_name;
    Close conc_prog_name_C;

    wf_engine.SetItemAttrText(
                itemtype  => PA_item_type,
                itemkey   => PA_item_key,
                aname     => 'CONC_PRG_NAME',
                avalue    => v_conc_prg_name );
    WriteDebugMsg('Attribute CONC_PRG_NAME = '||v_conc_prg_name);

    IF p_prog_code = 'PAXALGAT' THEN
       G_Err_Stage := 'Calling PA_GL_AUTOALLOC_PKG.Submit_Alloc_Request';
	WriteDebugMsg(G_Err_Stage);
       Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);

       v_request_id := PA_GL_AUTOALLOC_PKG.Submit_Alloc_Request(
				p_rule_id => p_arg1,
				p_expnd_item_date =>
					fnd_date.canonical_to_date(p_arg2),
				p_pa_period => p_arg3,
				p_gl_period => p_arg4);
    ELSIF p_prog_code = 'PASDUC' then
       G_Err_Stage := 'Submit Request for Concurrent Program'||'PASDUC';
       Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
       WriteDebugMsg(G_Err_Stage);

       fnd_global.apps_initialize(v_user_id, v_resp_id, v_resp_appl_id); /* Bug#3485255 */

/* Bug  2497324 added parameters  p_arg10,p_arg11 as two parameters added in the process */
  -- MOAC changes
        fnd_request.set_org_id (x_org_id);
	  v_request_id :=
             FND_REQUEST.SUBMIT_REQUEST(
                'PA',
                'PASDUC',
                '',
                '',
                FALSE,
                p_arg1,
                p_arg2,
                p_arg3,
                p_arg4,
                p_arg5,
                p_arg6,
		p_arg7,
		p_arg8,
		p_arg9,
		p_arg10,
		p_arg11);

    ELSE
       G_Err_Stage := 'Submit Request for Concurrent Program'||p_prog_code;
       Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
       WriteDebugMsg(G_Err_Stage);

	/** testing
       IF p_prog_code = 'PAXALRAT' then
		DBMS_LOCK.sleep(180);
       End If; **/

  -- MOAC changes
        fnd_request.set_org_id (x_org_id);
       v_request_id :=
             FND_REQUEST.SUBMIT_REQUEST(
                'PA',
                p_prog_code,
                '',
                '',
                FALSE,
                p_arg1,
                p_arg2,
                p_arg3,
                p_arg4,
                p_arg5,
                p_arg6,
                p_arg7,
                p_arg8,
                p_arg9,
		p_arg10,
		p_arg11,
		p_arg12,
		p_arg13,
		p_arg14,
		p_arg15,
                '','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','');
    END IF;

    IF v_request_id <> 0 THEN
       WriteDebugMsg('Inserting req id = '||to_char(v_request_id)||
                            ' into histroy detail');

          GL_AUTO_ALLOC_WF_PKG.INSERT_BATCH_HIST_DET(
                p_REQUEST_ID        => v_request_id
               ,p_PARENT_REQUEST_ID => v_set_req_id
               ,p_STEP_NUMBER       => v_step_number
               ,p_PROGRAM_NAME_CODE => p_prog_code
               ,p_RUN_MODE          => v_operating_mode
	       ,p_allocation_type   => 'PA'
	       ,p_created_by        => 	v_created_by
	       ,p_last_updated_by   => v_last_updated_by
	       ,p_last_update_login => v_last_update_login);

      /* Get Appropriate Status Code */
         Get_Status_and_Message(p_prog_Code
                          ,'PENDING'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);
      --Generation pending status
         GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
                    );
    End If;

    wf_engine.SetItemAttrNumber(
                itemtype  => PA_item_type,
                itemkey   => PA_item_key,
                aname     => 'CONC_REQUEST_ID',
                avalue    => v_Request_ID );
    WriteDebugMsg('Attribute CONC_REQUEST_ID = '||v_request_id);

    G_Err_Stage := 'End Of API Submit_Conc_Process';
    Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
    WriteDebugMsg(G_Err_Stage);
    Reset_PA_WF_Stack(PA_item_type,PA_item_key);

    Return v_request_id;

END Submit_Conc_Process;
--------------------------------------------------------------------------------
/** This procedure deletes an allocation run given a rule_id and a run_id**/

Procedure Delete_Alloc_Run(	p_item_type 	IN 	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                       		p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2) IS

v_rule_id		Number;
v_allocation_run_id	Number;
v_step_number		Number;
v_err_stack		Varchar2(2000);
v_set_req_id		Number;

Begin

IF p_funcmode = 'RUN' THEN

   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
   Set_PA_WF_Stack(p_item_type,p_item_key,'Delete_Alloc_Run');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);


/** Get rule_id, run_id from WF Attributes **/

   v_allocation_run_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'ALLOCATION_RUN_ID');

   v_rule_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'BATCH_ID');

   PA_ALLOC_RUN.Delete_ALLOC_TXNS (v_rule_id,
				   v_allocation_run_id);

   Reset_PA_WF_Stack(p_item_type,p_item_key);
   p_result := 'COMPLETE';

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

Exception

  WHEN OTHERS THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'DELETE_ALLOC_RUN', p_item_type, p_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('*********** Error Encountered ***********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     -- set status code to unexpected fatal error
     v_step_number := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'STEP_NUMBER');
    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;

End Delete_Alloc_Run;
------------------------------------------------------------------------------
/** This is the function for checking the completion status of the concurrent process **/
Procedure Check_Process_Status(	p_item_type	IN 	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                       		p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2) Is

v_request_id             Number;
p_phase                  Varchar2(30);
p_status                 Varchar2(30);
p_dev_phase              Varchar2(30);
p_dev_status             Varchar2(30);
p_message                Varchar2(240) ;
v_call_status            Boolean;
v_step_number            Number;
v_conc_prg_code          Varchar2(15);
v_status_code            Varchar2(15);
v_message_Name           Varchar2(150);
v_err_stack		 VARCHAR2(2000);
v_rollback_allowed	 Varchar2(1);
v_set_req_id		 Number;
v_user_id                Number;
v_org_id                  Number;
v_resp_id                 Number;
v_resp_appl_id            Number;
v_lang           varchar2(30);

Begin
If ( p_funcmode = 'RUN' ) THEN
   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;

   Set_PA_WF_Stack(PA_item_type,PA_item_key,'Check_Process_Status');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_step_number := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'STEP_NUMBER');
   WriteDebugMsg('Attribute STEP_NUMBER  = '||to_char(v_step_number));

   v_conc_prg_code := WF_ENGINE.GetItemAttrText
                        (PA_item_type,
                         PA_item_key,
                         'CONC_PRG_CODE');
   WriteDebugMsg('Attribute CONC_PRG_CODE = '||v_conc_prg_code);

   v_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           PA_item_type,
                           PA_item_key,
                           'ROLLBACK_ALLOWED');
   WriteDebugMsg('Attribute ROLLBACK_ALLOWED = '||v_rollback_allowed);

   v_request_id :=  WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'CONC_REQUEST_ID');

   WriteDebugMsg('Attribute CONC_REQUEST_ID = '||to_char(v_request_id));

    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');

   IF v_request_id = 0 THEN /* Concurrent Program could not be submitted */
      WF_ENGINE.SetItemAttrText(p_item_type,
				p_item_key,
				'PARENT_PROCESS',
				'Concurrent Process Error');

      WriteDebugMsg('Sending Notification.Fatal Error: Conc program not submitted');
      Get_Status_and_Message(v_conc_prg_Code
                          ,'ZEROERROR'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);

      wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => v_message_name );
      WriteDebugMsg('Message_name = '||v_message_Name);

          -- Program Error
      GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
                    );

      Reset_PA_WF_Stack(p_item_type,p_item_key);
      p_result := 'COMPLETE:FAIL';
      return;

  END IF;/* Request ID =0 */

   v_user_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'USER_ID');

   v_org_id     := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'ORG_ID');

   v_resp_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'RESP_ID');

   v_resp_appl_id   := WF_ENGINE.GetItemAttrNumber
                        (PA_item_type,
                         PA_item_key,
                         'RESP_APPL_ID');
   v_lang   := WF_ENGINE.GetItemAttrText
                        (PA_item_type,
                         PA_item_key,
                         'LANG');

        FND_PROFILE.put('LANG', v_lang);
        -- Fix for bug : 4640479
       -- FND_PROFILE.put('ORG_ID', v_org_id);
        MO_GLOBAL.set_policy_context('S',v_org_id);
        FND_PROFILE.put('USER_ID', v_user_id );
        FND_PROFILE.put('RESP_ID', v_resp_id);
        FND_PROFILE.put('RESP_APPL_ID', v_resp_appl_id);

      v_call_status :=
              Fnd_Concurrent.Wait_For_Request(
                  request_id   => v_request_id
                 ,Interval     => 30
                 ,Max_wait     => 360000
                 ,phase        => p_phase
                 ,status       => p_status
                 ,dev_phase    => p_dev_phase
                 ,dev_status   => p_dev_status
                 ,message      => p_message );

       WriteDebugMsg('Phase = '||p_dev_phase);
       WriteDebugMsg('Status = '||p_dev_status);

       if not (v_call_status) THEN
          WriteDebugMsg('Wait for request return message = '||p_message);
       end if;

       If p_dev_phase = 'COMPLETE' AND
           p_dev_status In ('NORMAL') Then
           WriteDebugMsg('Completed concurrent program = '||
						to_char(v_request_id) );

           -- set status code program completed
           Get_Status_and_Message(v_conc_prg_code
                           ,'COMPLETE'
                           ,v_rollback_allowed
                           ,v_status_code
        	           ,v_message_name);
	   WriteDebugMsg('Status Code Value = '||v_status_code);

           GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
                    );

	   WriteDebugMsg('Updated Status Code Value = '||v_status_code);

           p_result := 'COMPLETE:PASS';
           Reset_PA_WF_Stack(p_item_type,p_item_key);
           return;
      Else
         WriteDebugMsg('Sending Notification. Concurrent program not completed'
			||'Request ID is = '|| to_char(v_request_id) );
         WriteDebugMsg('Phase = '||p_dev_phase||' Status ='||p_dev_status);
	 WF_Engine.SetItemAttrText (p_item_type,
			  p_item_key,
			  'PARENT_PROCESS',
			  'Concurrent Process Error');
          Get_Status_and_Message(v_conc_prg_code
                           ,'ERROR'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);

          -- Program Error
          GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
                    );

	WriteDebugMsg('Updated Status Code Value = '||v_status_code);

        wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => v_message_name );

         WriteDebugMsg('Message_name = '||v_message_Name);

         Reset_PA_WF_Stack(p_item_type,p_item_key);
         p_result := 'COMPLETE:FAIL';
         return;
     End If;
 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  When Others Then
    Reset_PA_WF_Stack(p_item_type,p_item_key);
    Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Process_Status',
						p_item_type, p_item_key);
    Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
    WriteDebugMsg('*********** Error Encountered **********');
    WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
    GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;

End Check_Process_Status ;
--------------------------------------------------------------------------------
/** This is the function for checking the exceptions in the allocation run process **/

Procedure Check_Alloc_Run_Status(	p_item_type	IN 	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                       			p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2) Is

v_conc_request_id        Number;
p_phase                  Varchar2(30);
p_status                 Varchar2(30);
p_dev_phase              Varchar2(30);
p_dev_status             Varchar2(30);
p_message                Varchar2(240) ;
v_call_status            Boolean;
v_step_number            Number;
v_conc_prg_code          Varchar2(15);
v_rollback_allowed       Varchar2(1);
v_parent_process	 Varchar2(30);
v_result		 Varchar2(10);
v_run_id		 Number;
v_org_id		 Number;
v_batch_id		 Number;
v_err_stack		 Varchar2(2000);
v_run_status		 Varchar2(2);
v_set_req_id		 Number;
v_message_Name           Varchar2(150);
v_status_code            Varchar2(15);
v_return_code		 Number;

Begin
If ( p_funcmode = 'RUN' ) THEN
   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;

   Set_PA_WF_Stack(p_item_type,p_item_key,'Check_Alloc_Run_Status');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           PA_item_type,
                           PA_item_key,
                           'ROLLBACK_ALLOWED');
   v_parent_process :=  WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'PARENT_PROCESS');
   WriteDebugMsg('Attribute Parent_Process = '||v_parent_process);

   v_batch_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BATCH_ID');
   v_org_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');
   v_conc_request_id :=  WF_ENGINE.GetItemAttrNumber
                        		(p_item_type,
                         		 p_item_key,
                         		'CONC_REQUEST_ID');
   v_step_number :=  WF_ENGINE.GetItemAttrNumber
                        		(p_item_type,
                         		 p_item_key,
                         		'STEP_NUMBER');
   v_conc_prg_code :=  WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'CONC_PRG_CODE');

   v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');

   IF v_parent_process = 'Generate Allocation' THEN
   begin
      select run_status,run_id
      into v_run_status,v_run_id
      from PA_ALLOC_RUNS_ALL
      where rule_id = v_batch_id
      and draft_request_id = v_conc_request_id;

      WriteDebugMsg('Run Status = '||v_run_status);
      WriteDebugMsg('Run ID = '||to_char(v_run_id));

      WF_Engine.SetItemAttrNumber (p_item_type,
			 p_item_key,
			 'ALLOCATION_RUN_ID',
			 v_run_id);

      WriteDebugMsg('Calling GL API to update PA_ALLOCATION_RUN_ID');
      GL_PA_AUTOALLOC_PKG.upd_gl_autoalloc_batch_hist
			(p_request_id => v_set_req_id,
			 p_step_number => v_step_number,
			 p_pa_allocation_run_id => v_run_id,
			 p_return_code => v_return_code);

      IF v_return_code = -1 THEN
         WriteDebugMsg('Run ID could not be updated for request ID: '
		||to_char(v_conc_request_id)||' and step number: '||
					to_char(v_step_number));
      ELSE

         WriteDebugMsg('GL_AUTO_ALLOC_BAT_HIST_DET updated with RUN_ID');

      END IF;

      IF v_run_status in ('DF','IP') THEN
	 WF_Engine.SetItemAttrText(p_item_type,
			 p_item_key,
			 'PARENT_PROCESS',
			 'Concurrent Process Exception');
         WriteDebugMsg('Setting attribute PARENT_PROCESS value  = '||
						'Concurrent Process Exception');

         Get_Status_and_Message(v_conc_prg_code
                           ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);
          -- Program Error
         GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
	   		);
         wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => v_message_name );

         WriteDebugMsg('Message_name = '||v_message_Name);

         p_result := 'COMPLETE:FAIL';
      ELSE
	 p_result := 'COMPLETE:PASS';
      END IF;

   exception
       when no_data_found then
	  WF_Engine.SetItemAttrText(p_item_type,
			 p_item_key,
			 'PARENT_PROCESS',
			 'Concurrent Process Exception');
         WriteDebugMsg('Setting attribute PARENT_PROCESS value  = '||
						'Concurrent Process Exception');
          Get_Status_and_Message(v_conc_prg_code
                           ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);
          -- Program Error
          GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
	   		);
         wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => v_message_name );

	 p_result := 'COMPLETE:FAIL';
   end;/* Generate Allocation*/

   ELSE /* Release Allocation Process */
      begin
      v_run_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
				    p_item_key,
				    'ALLOCATION_RUN_ID');
      WriteDebugMsg('Checking Release Status');
      select run_status
      into v_run_status
      from PA_ALLOC_RUNS_ALL
      where rule_id = v_batch_id
      and release_request_id = v_conc_request_id;

      WriteDebugMsg('Run Status = '||v_run_status);

      IF (v_run_status = 'RF' or v_run_status = 'IP') THEN
	 WF_Engine.SetItemAttrText(p_item_type,
			 p_item_key,
			 'PARENT_PROCESS',
			 'Concurrent Process Exception');
         Get_Status_and_Message(v_conc_prg_code
                           ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);
          -- Program Error
         GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
	   		);
         wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => v_message_name );

         WriteDebugMsg('Message_name = '||v_message_Name);
   	 p_result := 'COMPLETE:FAIL';
      ELSE
	 p_result := 'COMPLETE:PASS';
      END IF;
      exception
	 when no_data_found then
	    WF_ENGINE.SetItemAttrText(p_item_type,
			 	p_item_key,
			 	'PARENT_PROCESS',
			 	'Concurrent Process Exception');
            WriteDebugMsg('Setting attribute PARENT_PROCESS value  = '||
						'Concurrent Process Exception');
            Get_Status_and_Message(v_conc_prg_code
                           ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);
          -- Program Error
            GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
	   		);
            wf_engine.SetItemAttrText(itemtype => PA_item_type,
                                  itemkey   => PA_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => v_message_name );
	    p_result := 'COMPLETE:FAIL';
      end;/* Release Allocation */
   END IF; /* Parent Process */
   G_Err_Stage := 'End Of API: Check_Alloc_Run_Status';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(p_item_type,p_item_key);
 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
 END IF;/* funcmode = run */

EXCEPTION
  When Others Then
    Reset_PA_WF_Stack(p_item_type,p_item_key);
    Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Alloc_Run_Status', p_item_type, p_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('************Error Encountered***********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
  Raise;
END Check_Alloc_Run_Status;

-----------------------------------------------------------------------------------
/** This procedure checks if allocation run is released or not.**/

PROCEDURE Check_Alloc_Release(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2) Is

v_org_id	NUMBER;
v_batch_id	NUMBER;
v_allocation_run_id	NUMBER;
v_result	VARCHAR2(10);
v_err_stack     Varchar2(2000);
v_step_number	Number;
v_definition_form Varchar2(500);
v_set_req_id	Number;

BEGIN
If ( p_funcmode = 'RUN' ) THEN

   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
   Set_PA_WF_Stack(p_item_type,p_item_key,'Check_Alloc_Release');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_org_id := WF_Engine.GetItemAttrNumber (p_item_type,
				  p_item_key,
				  'ORG_ID');
   v_batch_id := WF_Engine.GetItemAttrNumber (p_item_type,
				    p_item_key,
				    'BATCH_ID');
   v_allocation_run_id := WF_Engine.GetItemAttrNumber (	p_item_type,
				  		p_item_key,
				  		'ALLOCATION_RUN_ID');
   v_step_number := WF_Engine.GetItemAttrNumber (p_item_type,
				  		 p_item_key,
				  		 'STEP_NUMBER');
   select 'RELEASED'
   into v_result
   from PA_ALLOC_RUNS_ALL
   where run_id = v_allocation_run_id
   and run_status = 'RS';

   p_result := 'COMPLETE:'||v_result;

   G_Err_Stage := 'End of API: Check_Alloc_Release';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(p_item_type,p_item_key);

 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
 End If;

EXCEPTION
  when no_data_found then
       Reset_PA_WF_Stack(p_item_type,p_item_key);
       v_result := 'DRAFT';
	/** Set The definition form to Review Allocation Run Form */
       v_definition_form := 'PA_PAXALRAR: CHAR_RUN_ID='||
		to_char(V_ALLOCATION_RUN_ID);


       WF_Engine.SetItemAttrText(itemtype => p_item_type,
			      itemkey  => p_item_key,
			      aname    => 'DEFINITION_FORM',
			      avalue   => v_definition_form);

       p_result := 'COMPLETE:'||v_result;
  When Others Then
    Reset_PA_WF_Stack(p_item_type,p_item_key);
    Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Alloc_Release', p_item_type, p_item_key);
    Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
    WriteDebugMsg('************Error Encountered***********');
    WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
    GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;

END Check_Alloc_Release;
--------------------------------------------------------------------------------
/** This is the function for checking the exceptions in the distribute cost process **/

Procedure Check_Costing_Process(	p_item_type	IN 	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                       			p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2) Is

p_message                Varchar2(240) ;
v_status_code            Varchar2(15);
v_message_Name           Varchar2(150);
v_result		 Varchar2(10);
v_run_id		 Number;
v_org_id		 Number;
v_conc_prg_code 	 Varchar2(15);
v_rollback_allowed 	 Varchar2(1);
v_err_stack		 VARCHAR2(2000);
v_expenditure_group	 Varchar2(50);
v_step_number		 Number;
v_set_req_id		 Number;

Begin
If ( p_funcmode = 'RUN' ) THEN

   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
   Set_PA_WF_Stack(p_item_type,p_item_key,'Check_Costing_Process');
   v_err_stack := WF_ENGINE.GetItemAttrText(	p_item_type,
						p_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_set_req_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'SET_REQ_ID');

   v_step_number :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

   v_org_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');
   v_expenditure_group :=  WF_ENGINE.GetItemAttrText
                        	(p_item_type,
                         	 p_item_key,
                         	'EXPENDITURE_GROUP');
   v_conc_prg_code :=  WF_ENGINE.GetItemAttrText
                        	(p_item_type,
                         	 p_item_key,
                         	'CONC_PRG_CODE');
   v_rollback_allowed:=  WF_ENGINE.GetItemAttrText
                        	(p_item_type,
                         	 p_item_key,
                         	'ROLLBACK_ALLOWED');

   select 'FAIL'
   into v_result
   From dual
   where exists (select 'Y'
		 from PA_Expenditure_Items_All EI,
		      PA_Expenditures_All ES
		 where ES.expenditure_group = v_expenditure_group
		 and EI.expenditure_item_id = ES.expenditure_id
   		 and EI.cost_distributed_flag||'' = 'N'
   		 );

   Get_Status_and_Message(v_conc_prg_Code
                          ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);
   -- Program Error
   GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
	   		);
   wf_engine.SetItemAttrText(itemtype => PA_item_type,
                             itemkey   => PA_item_key,
                             aname     => 'MESSAGE_NAME',
                             avalue    => v_message_name );

   G_Err_Stage := 'The expenditure Group '||v_expenditure_group||
						'is yet to be fully costed';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);

   G_Err_Stage := 'End of API: Check_Costing_Process';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(p_item_type,p_item_key);

   p_result := 'COMPLETE:FAIL';

 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
 End If;

Exception
   When no_data_found then
      Reset_PA_WF_Stack(p_item_type,p_item_key);
      p_result := 'COMPLETE:PASS';

   When Others Then
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Costing_Process', p_item_type, p_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('********** Encountered Errors ***********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );

END Check_Costing_Process;
--------------------------------------------------------------------------------
/** This is the function for checking the exceptions in the Summarization process **/

Procedure Check_Summary_Process(	p_item_type	IN 	VARCHAR2,
                         		p_item_key	IN 	VARCHAR2,
                         		p_actid		IN 	NUMBER,
                       			p_funcmode	IN 	VARCHAR2,
                         		p_result	OUT NOCOPY 	VARCHAR2) Is

p_message                Varchar2(240) ;
v_status_code            Varchar2(15);
v_rollback_allowed       Varchar2(1);
v_message_Name           Varchar2(150);
v_result		 Varchar2(5);
v_run_id		 Number;
v_org_id		 Number;
v_err_stack		 VARCHAR2(2000);
v_request_id		 Number;
v_step_number		 Number;
v_set_req_id		 Number;

Begin
If ( p_funcmode = 'RUN' ) THEN
   PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;

   Set_PA_WF_Stack(p_item_type,p_item_key,'Check_Summary_Process');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_org_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');
   v_set_req_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'SET_REQ_ID');
   v_step_number :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');
   v_request_id :=  WF_ENGINE.GetItemAttrNumber
                        	(p_item_type,
                         	 p_item_key,
                         	'CONC_REQUEST_ID');

   v_result := Check_Summarization_status (v_request_id);
   IF v_result = 'FAIL' THEN
      /* set parent process */
      WF_Engine.SetItemAttrText(itemtype => p_item_type,
		      itemkey  => p_item_key,
		      aname     => 'PARENT_PROCESS',
		      avalue    => 'Concurrent Process Exception');

      Get_Status_and_Message('PAXACMPT'
                          ,'EXCEPTION'
                           ,v_rollback_allowed
                           ,v_status_code
                           ,v_message_name);

      wf_engine.SetItemAttrText(itemtype => PA_item_type,
                             itemkey   => PA_item_key,
                             aname     => 'MESSAGE_NAME',
                             avalue    => v_message_name );
          -- Program Error
            GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,v_status_code
	   		);

      G_Err_Stage := 'Summarization Process has exceptions';
      Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
      WriteDebugMsg(G_Err_Stage);

      p_result := 'COMPLETE:FAIL';
   ELSE
      G_Err_Stage := 'Summarization Process is successful';
      Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
      WriteDebugMsg(G_Err_Stage);
      p_result := 'COMPLETE:PASS';
   END IF;

      G_Err_Stage := 'End of API: Check_Summary_Process';
      Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
      WriteDebugMsg(G_Err_Stage);
      Reset_PA_WF_Stack(p_item_type,p_item_key);

 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
 End If;

EXCEPTION
  When Others Then
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Check_Summary_Process',
						p_item_type, p_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg('************* Error Encountered **********');
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );

END Check_Summary_Process;
--------------------------------------------------------------------------------
/*** This function checks if the request submitted for summarization
     has any exceptions. Returns 'FAIL' if an exception occured,
     'PASS' otherwise ***/

Function Check_Summarization_Status( p_request_id	IN	Number)
Return Varchar2
IS
   v_summarization_status VARCHAR2(5);
   v_err_stack		  Varchar2(2000);

BEGIN

    Set_PA_WF_Stack(PA_item_type,PA_item_key,'Check_Summarization_Status');
    v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
    WriteDebugMsg(v_err_stack);

   select 'FAIL'
   into v_summarization_status
   from dual
   where exists
	 (select 'Exception'
         from pa_projects_for_accum
	 where request_id = p_request_id
	 and exception_flag = 'Y');

   return v_summarization_status;

   G_Err_Stage := 'End of API: Check_Summarization_Status';
   Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(PA_item_type,PA_item_key);

Exception
   when no_data_found then
      G_Err_Stage := 'End of API: Check_Summarization_Status';
      Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
      WriteDebugMsg(G_Err_Stage);
      Reset_PA_WF_Stack(PA_item_type,PA_item_key);
      return 'PASS';


END Check_Summarization_Status;
-------------------------------------------------------------------------------
/** This function submits Concurrent Process to release Project Allocation Transactions.This is called from PA Step down Allocation Work Flow **/

PROCEDURE Submit_Conc_AllocRls(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2) Is

v_request_id            NUMBER;
v_parent_process	VARCHAR2(30);
v_allocation_run_id	NUMBER;
v_rule_id		NUMBER;
v_run_period		VARCHAR2(20);
v_expenditure_item_date	DATE;
v_allocation_run_id		NUMBER;

v_step_number                 NUMBER;
l_allocation_method_code      Varchar2(1);
l_usage_code                  Varchar2(1);
l_sob_id                      Number;
l_period_name                 Varchar2(15);
l_journal_effective_date      Date;
l_calc_effective_date         Date;
l_batch_id                    Number;
v_set_req_id              Number;
v_err_stack		      Varchar2(2000);
v_operating_mode	 VARCHAR2(2);

Begin
If ( p_funcmode = 'RUN' ) THEN
    PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
    Set_PA_WF_Stack(p_item_type,p_item_key,'Submit_Conc_AllocRls');
    v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
    WriteDebugMsg(v_err_stack);

    v_parent_process := WF_ENGINE.GetItemAttrText (	p_item_type
                         				,p_item_key
                         				,'PARENT_PROCESS');

    v_set_req_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         				p_item_key,
                         				'SET_REQ_ID');

    v_operating_mode := WF_ENGINE.GetItemAttrText(	p_item_type,
                         				p_item_key,
                         				'OPERATING_MODE');

/* Set attributes Concurrent Program Code and Name */

   WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'CONC_PRG_CODE',
				'PAXALRAT');
   WriteDebugMsg('Attribute CONC_PRG_CODE = PAXALRAT');

/* Get Parameters needed to submit Allocation Release Process */

   v_rule_id := WF_ENGINE.GetItemAttrNumber(	p_item_type,
                         			p_item_key,
                         			'BATCH_ID');

   v_request_id := Submit_Conc_Process
				('PAXALRAT',
				 p_arg1 => to_char(v_rule_id),
				 p_arg2 => 'R'
		 		   	);

   WF_ENGINE.SetItemAttrText(	p_item_type,
			   	p_item_key,
				'PARENT_PROCESS',
				'Release Allocation');

   G_Err_Stage := 'End of API: Submit_Conc_AllocRls';
   Set_PA_WF_Stage(p_item_type,p_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(p_item_type,p_item_key);

   p_result := 'COMPLETE';
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  WHEN OTHERS THEN
     Reset_PA_WF_Stack(p_item_type,p_item_key);
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG', 'Submit_Conc_AllocRls', p_item_type, p_item_key);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     WriteDebugMsg(G_err_msg ||'*'||G_err_stack);
     WriteDebugMsg('************ Error Encountered *************');
     -- set status code to unexpected fatal error
    v_SET_REQ_ID := WF_ENGINE.GetItemAttrNumber(itemtype => p_item_type,
					  	itemkey => p_item_key,
						aname => 'SET_REQ_ID');
     GL_AUTO_ALLOC_WF_PKG.Update_Status(v_set_req_id
                    ,v_step_number
                    ,'UFE'
                    );
    Raise;
END Submit_Conc_AllocRls;
--------------------------------------------------------------------------------
/**This procedure sets a GL attribute value based on the result of PA Step Down
   Allocation Process and issues a complete activity for the block. **/

PROCEDURE Set_PA_WF_Status(	p_item_type	IN	VARCHAR2,
                         	p_item_key	IN 	VARCHAR2,
                         	p_actid		IN 	NUMBER,
                         	p_funcmode	IN 	VARCHAR2,
                         	p_result	OUT NOCOPY 	VARCHAR2)
IS
v_gl_item_type		Varchar2(10);
v_gl_item_key		Varchar2(40);
v_gl_block_activity	VARCHAR2(15);
v_result		VARCHAR2(30);
v_rollback_allowed	VARCHAR2(1);
v_err_stack		VARCHAR2(2000);

BEGIN
If ( p_funcmode = 'RUN' ) THEN
    PA_AUTOALLOC_WF_PKG.PA_item_key := p_item_key;
    Set_PA_WF_Stack(p_item_type,p_item_key,'Set_PA_WF_STATUS');
    v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
    WriteDebugMsg(v_err_stack);

   v_gl_item_type := WF_ENGINE.GetItemAttrText(	p_item_type,
				  	p_item_key,
				  	'GL_ITEM_TYPE');
   v_gl_item_key := WF_ENGINE.GetItemAttrText(	p_item_type,
				  	p_item_key,
				  	'GL_ITEM_KEY');
   v_rollback_allowed := WF_ENGINE.GetItemAttrText(p_item_type,
				  	 p_item_key,
				  	 'ROLLBACK_ALLOWED');

    v_result := WF_ENGINE.GetActivityAttrText(	p_item_type,
						p_item_key,
					        p_actid,
						'RESULT_CODE');
    G_Err_Stage := 'PA Workflow Result Code is = '||v_result;
    WriteDebugMsg(G_Err_Stage);

   /** if rollback is not allowed then PA Process result cannot be ROLLBACK -

   /** if rollback is not allowed then PA Process result cannot be ROLLBACK -
	ROLLBACK is overwritten with FAIL. **/

   if v_rollback_allowed = 'N' then
      if v_result = 'ROLLBACK' then
	 v_result := 'FAIL';
      end if;
   end if;

   WF_ENGINE.SetItemAttrText(	v_gl_item_type,
			   	v_gl_item_key,
				'PA_WF_STATUS',
				v_result);
   WriteDebugMsg('GL Attribute PA_WF_STATUS  = '||v_result);

   v_gl_block_activity := WF_ENGINE.GetItemAttrText(p_item_type,
					  p_item_key,
					  'GL_BLOCK_ACTIVITY');
   WF_ENGINE.CompleteActivity(  v_gl_item_type,
				v_gl_item_key,
				v_gl_block_activity,
				v_result);
   p_result := 'COMPLETE';

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

END SET_PA_WF_Status;
--------------------------------------------------------------------------------

Procedure Get_Status_and_Message(
          p_conc_prg_code    IN  Varchar2
         ,p_ptype            IN  Varchar2
         ,p_rollback_allowed IN Varchar2
         ,x_status_code      OUT NOCOPY Varchar2
         ,x_message_name     OUT  NOCOPY Varchar2 ) Is

v_operating_mode   Varchar2(2);
v_err_stack	   Varchar2(2000);
v_conc_Request_id  Number;
v_definition_form VARCHAR2(500);
v_rule_id	  Number;

Begin
   Set_PA_WF_Stack(PA_item_type,PA_item_key,'Get_Status_And_Message');
   v_err_stack := WF_ENGINE.GetItemAttrText(	PA_item_type,
						PA_item_key,
						'WF_STACK');
   WriteDebugMsg(v_err_stack);

   v_operating_mode := WF_ENGINE.GetItemAttrText
                        (PA_item_type,
                         PA_item_key,
   			 'OPERATING_MODE');
   WriteDebugMsg('Attribute Operating_Mode = '||v_operating_mode);

   WriteDebugMsg('Get_Status_and_Message: Prg_Code = '||p_Conc_Prg_Code);

   If p_ptype = 'COMPLETE' Then
      If v_operating_mode = 'R' Then  --Rollback mode
         If p_conc_prg_code = 'PAXALGAT' Then
	 /** ?????Reversal is not a Concurrent Request. Which program Code to use ? Status Code could be set at the place where complete activity is processed  ????**/
           --Rollback:Allocation Reversal Completed
            x_status_code := 'RALPC';
         Elsif p_conc_prg_code = 'PASDUC' Then
          --Rollback: Distribute Usage and Miscellaneous Cost Process Completed
            x_status_code := 'RDCPC';
         Elsif p_conc_prg_code = 'PAXACMPT' Then
          --Rollback: Update Project Summary Amounts Completed
           x_status_code := 'RUPPC';
         End If;
      Else -- Normal mode
         If p_conc_prg_code = 'PAXALGAT' Then
          --Generate Allocation Transactions Process Completed
          x_status_code := 'ALPC';
         Elsif p_conc_prg_code = 'PAXALRAT' Then
           --Release Allocation Transaction Process Completed
           x_status_code := 'RLALPC';
         Elsif p_conc_prg_code = 'PASDUC' Then
           --Distribute Usage and Miscellaneous Cost Process Completed
           x_status_code := 'DCPC';
         Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Update Project Summary Amounts Process Completed
           x_status_code := 'UPPC';
         End If;
      End If;
   ElsIf p_ptype = 'PENDING' Then
      If v_operating_mode = 'R' Then  --Rollback mode
         If p_conc_prg_code = 'PASDUC' Then
          --Rollback: Distribute Usage and Miscellaneous Cost Process Pending
            x_status_code := 'RDCPP';
         Elsif p_conc_prg_code = 'PAXACMPT' Then
          --Rollback: Update Project Summary Amounts Pending
           x_status_code := 'RUPPP';
         End If;
      Else -- Normal mode
         If p_conc_prg_code = 'PAXALGAT' Then
          --Generate Allocation Transactions Process Pending
          x_status_code := 'ALPP';
         Elsif p_conc_prg_code = 'PAXALRAT' Then
           --Release Allocation Transaction Process Pending
           x_status_code := 'RLALPP';
         Elsif p_conc_prg_code = 'PASDUC' Then
           --Distribute Usage and Miscellaneous Cost Process Pending
           x_status_code := 'DCPP';
         Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Update Project Summary Amounts Process Pending
           x_status_code := 'UPPP';
         End If;
      End If;
 ElsIf p_ptype = 'ZEROERROR' Then
    /** Concurrent Process returned Request ID = 0 **/

    /** Set the Message **/
    If p_conc_prg_code = 'PAXALGAT' Then
       x_message_name := 'PASDALOC:REQUEST_NOT_SUBMITTED_NRB';
    else
       if p_rollback_allowed = 'Y' then
          x_message_name := 'PASDALOC:REQUEST_NOT_SUBMITTED';
       else
          x_message_name := 'PASDALOC:REQUEST_NOT_SUBMITTED_NRB';
       end if;
    end if;

    If v_operating_mode = 'R' Then  --Rollback mode
       If p_conc_prg_code = 'PASDUC' Then
          --Rollback: Distribute Usage and Miscellaneous Cost Process Failed
           x_status_code := 'RDCPF';
       Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Rollback: Update Project Summary Amounts Process Failed
           x_status_code := 'RUPPF';
       End If;
    Else -- Normal mode
       If p_conc_prg_code = 'PAXALGAT' Then
          --Generate Allocation Transactions Process Failed
          x_status_code := 'ALPF';
       Elsif p_conc_prg_code = 'PAXALRAT' Then
           --Release Allocation Transactions Process Failed
          x_status_code := 'RLALPF';
       Elsif p_conc_prg_code = 'PASDUC' Then
           --Distribute Usage and Miscellaneous Cost Process Failed
          x_status_code := 'DCPF';
       Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Update Project Summary Amounts Process Completed
          x_status_code := 'UPPF';
       END IF;
    End If;

 ElsIf p_ptype = 'ERROR' Then

    v_conc_request_id := wf_engine.GetItemAttrNumber
						(itemtype => PA_item_type,
				             	 itemkey => PA_item_key,
						 aname => 'CONC_REQUEST_ID');
    /** Set the definition form attribute **/

    v_definition_form := 'PAREQVIEW: DODT_REQ_ID='|| to_char(v_conc_request_id);


    WF_Engine.SetItemAttrText(itemtype => PA_item_type,
			      itemkey  => PA_item_key,
			      aname    => 'DEFINITION_FORM',
			      avalue   => v_definition_form);

    If v_operating_mode = 'R' Then  --Rollback mode
       If p_conc_prg_code = 'PASDUC' Then
          --Rollback: Distribute Usage and Miscellaneous Cost Process Failed
           x_status_code := 'RDCPF';
           x_message_name := 'PASDALOC:DIST_COST_PRG_FAILED';
       Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Rollback: Update Project Summary Amounts Process Failed
           x_status_code := 'RUPPF';
           x_message_name := 'PASDALOC:UPDT_PROJ_SUM_PRG_FAILED';
       End If;
    Else -- Normal mode
       If p_conc_prg_code = 'PAXALGAT' Then
          --Generate Allocation Transactions Process Failed
          x_status_code := 'ALPF';
          x_message_name := 'PASDALOC:GEN_ALLOC_PRG_FAILED';
       Elsif p_conc_prg_code = 'PAXALRAT' Then
           --Release Allocation Transactions Process Failed
          x_status_code := 'RLALPF';
	  If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:RLS_ALLOC_PRG_FAILED';
	  else
             x_message_name := 'PASDALOC:RLS_ALLOC_PRG_FAILED_NRB';
	  End If;
       Elsif p_conc_prg_code = 'PASDUC' Then
           --Distribute Usage and Miscellaneous Cost Process Failed
          x_status_code := 'DCPF';
	  If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:DIST_COST_PRG_FAILED';
	  Else
             x_message_name := 'PASDALOC:DIST_COST_PRG_FAILED_NRB';
	  End If;
       Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Update Project Summary Amounts Process Completed
          x_status_code := 'UPPF';
	  If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:UPDT_PROJ_SUM_PRG_FAILED';
	  Else
             x_message_name := 'PASDALOC:UPDT_PROJ_SUM_PRG_FAILED_NRB';
	  End If;
       END IF;
    End If;
 ElsIf p_ptype = 'EXCEPTION' Then
    v_conc_request_id := wf_engine.GetItemAttrNumber
						(itemtype => PA_item_type,
				             	 itemkey => PA_item_key,
						 aname => 'CONC_REQUEST_ID');

    /* Set the view definition form sent with notification */

    v_definition_form := 'PAREQVIEW: DODT_REQ_ID='|| to_char(v_conc_request_id);

    WF_Engine.SetItemAttrText(itemtype => PA_item_type,
			      itemkey  => PA_item_key,
			      aname    => 'DEFINITION_FORM',
			      avalue   => v_definition_form);

    If v_operating_mode = 'R' Then  --Rollback mode
       If p_conc_prg_code = 'PASDUC' Then
          --Rollback: Distribute Usage and Miscellaneous Cost Process raised exceptions
           x_status_code := 'RDCPE';
           x_message_name := 'PASDALOC:DIST_COST_PRG_EXCEPT';
       Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Rollback: Update Project Summary Amounts Process Completed
           x_status_code := 'RUPPE';
           x_message_name := 'PASDALOC:UPDT_PROJ_SUM_EXCEPT';
       End If;
    Else -- Normal mode
       If p_conc_prg_code = 'PAXALGAT' Then
          --Generate Allocation Transactions Process raised exceptions
          x_status_code := 'ALPE';
          If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:GEN_ALLOC_PRG_EXCEPT';
	  Else
             x_message_name := 'PASDALOC:GEN_ALLOC_PRG_EXCEPT_NRB';
	  End If;

       Elsif p_conc_prg_code = 'PAXALRAT' Then
           --Release Allocation Transactions Process raised exceptions
          x_status_code := 'RLALPE';
          If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:RLS_ALLOC_PRG_EXCEPT';
	  Else
             x_message_name := 'PASDALOC:RLS_ALLOC_PRG_EXCEPT_NRB';
	  End If;
       Elsif p_conc_prg_code = 'PASDUC' Then
           --Distribute Usage and Miscellaneous Cost Process raised exceptions
          x_status_code := 'DCPE';
          If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:DIST_COST_PRG_EXCEPT';
	  Else
             x_message_name := 'PASDALOC:DIST_COST_PRG_EXCEPT_NRB';
	  End If;
       Elsif p_conc_prg_code = 'PAXACMPT' Then
           --Update Project Summary Amounts Process raised exceptions
          x_status_code := 'UPPE';
          If p_rollback_allowed = 'Y' Then
             x_message_name := 'PASDALOC:UPDT_PROJ_SUM_PRG_EXCEPT';
	  Else
             x_message_name := 'PASDALOC:UPDT_PROJ_SUM_PRG_EXCEPT_NRB';
	  End If;
       END IF;
 End If;
End If;

  WriteDebugMsg('Message_name = '||x_message_name||' Status_Code = '||x_status_code);
   G_Err_Stage := 'End of API: Get_Status_And_Message';
   Set_PA_WF_Stage(PA_item_type,PA_item_key,G_Err_Stage);
   WriteDebugMsg(G_Err_Stage);
   Reset_PA_WF_Stack(PA_item_type,PA_item_key);
   return;

End Get_Status_and_Message;
--------------------------------------------------------------------------------
-- ****************************************************************************
-- This procedure opens debug file for appending
-- ****************************************************************************

Procedure initialize_debug IS

v_err_stack	VARCHAR2(2000);
 Begin
	  v_err_stack := 'Initialize_Debug';
	  Set_PA_WF_Stack(PA_Item_Type,PA_Item_Key,v_err_stack);
          G_FILE := 'PA'||PA_item_key ||'.dbg';
	  G_Err_Stage := 'Debug File IS '||G_FILE;
          If utl_file.Is_Open(G_FILE_PTR) Then
            utl_file.fclose(G_FILE_PTR);
          End If;
    	  G_DIR := wf_engine.GetItemAttrText(   itemtype => PA_item_type,
				        	itemkey => PA_item_key,
						aname => 'DEBUG_FILE_DIR');
          G_FILE_PTR := utl_file.fopen(G_DIR,G_FILE,'a');
	  Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);
	  G_Err_Stage := 'Exitting Initialize_Debug';
	  --WriteDebugMsg(G_Err_Stage);

  Exception

   WHEN UTL_FILE.INVALID_PATH THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');

        raise_application_error(-20020,'INVALID PATH exception from UTL_FILE !!'
                                || v_err_stack||'-'||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INVALID_MODE THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'INVALID MODE exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'INVALID FILEHANDLE exception from UTL_FIL
E !!'
                                || G_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INVALID_OPERATION THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'INVALID OPERATION exception from UTL_FILE
 !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.READ_ERROR THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'READ ERROR exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.WRITE_ERROR THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'WRITE ERROR exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'INTERNAL ERROR exception from UTL_FILE !!
'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

    When Others Then
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
/*        dbms_output.put_line('In when-others of initialize_debug'); */
/*        dbms_output.put_line(SQLERRM); */
       Wf_Core.Context('PA_AUTOALLOC_WF_PKG',
                      'initialize_debug', 'PASDALOC', PA_item_key);
       Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);
       Raise;
 End initialize_debug;
-------------------------------------------------------------------------------------
-- This procedure writes debug messages to a file

Procedure WriteDebugMsg(debug_message in Varchar2) Is
v_err_stack	Varchar2(2000);

 Begin
 v_err_stack := 'WriteDebugMsg';
 Set_PA_WF_Stack (PA_Item_Type,PA_Item_Key,v_err_stack);

 If (DebugFlag) then
   If debug_message is not null then
     If  NOT utl_file.Is_Open(G_FILE_PTR) OR
         G_FILE <> 'PA'||PA_item_key ||'.dbg' OR
         G_FILE  IS NULL   Then
      G_Err_Stage := 'Calling Initialize Debug from WriteDebugMsg';
/*       dbms_output.put_line(G_Err_Stage); */
      initialize_debug;
     End If;
     utl_file.put_line(G_FILE_PTR, debug_message);
     utl_file.fflush(G_FILE_PTR);
   End if;
 End If;
 Reset_PA_WF_Stack (PA_Item_Type,PA_Item_Key);

Exception

   WHEN UTL_FILE.INVALID_PATH THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');

        raise_application_error(-20020,'INVALID PATH exception from UTL_FILE !!'
                                || v_err_stack||'-'||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INVALID_MODE THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'INVALID MODE exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INVALID_FILEHANDLE THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,
		'INVALID FILEHANDLE exception from UTL_FIL E !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INVALID_OPERATION THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,
			'INVALID OPERATION exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.READ_ERROR THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'READ ERROR exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.WRITE_ERROR THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,'WRITE ERROR exception from UTL_FILE !!'
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

   WHEN UTL_FILE.INTERNAL_ERROR THEN
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
        raise_application_error(-20020,
		'INTERNAL ERROR exception from UTL_FILE !! '
                                || v_Err_Stack ||' - '||G_Err_Stage);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);

    When Others Then
    	v_err_stack := wf_engine.GetItemAttrText
					(       itemtype => PA_item_type,
				       		itemkey => PA_item_key,
						aname => 'WF_STACK');
       /*        dbms_output.put_line(SQLERRM); */
       Wf_Core.Context('PA_AUTOALLOC_WF_PKG',
                      'WriteDebugMsg', 'PASDALOC', PA_item_key,v_err_stack);
       Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
	Reset_PA_WF_Stack(PA_Item_Type,PA_Item_Key);
       Raise;

End WriteDebugMsg;
--------------------------------------------------------------------------------
/* This procedure initializes WF_STACK with the argument passed
   to it */
Procedure 	Init_PA_WF_STACK (p_item_type	In 	Varchar2,
				  p_item_key	In	Varchar2,
				  p_err_stack	In	Varchar2)
IS
Begin

   G_Err_Stage := 'Inside Init_PA_WF_STACK';

   /* Append the stack with the new string */
   WF_Engine.SetItemAttrText(itemtype => p_item_type,
			     itemkey  => p_item_key,
			     aname     => 'WF_STACK',
			     avalue    => p_err_stack);
Exception

WHEN OTHERS THEN
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG',
                      'Init_PA_WF_Stack', 'PASDALOC', PA_item_key,G_Err_Stage);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     Raise;


End Init_PA_WF_Stack;
--------------------------------------------------------------------------------
/* This procedure sets WF_STACK attribute with an argument */

Procedure 	Set_PA_WF_STACK (p_item_type	In 	Varchar2,
				 p_item_key	In	Varchar2,
				 p_err_stack	In	Varchar2)
IS
v_err_stack	Varchar2(2000);
Begin
   /* Get the previous value of the attribute */
   v_err_stack := WF_Engine.GetItemAttrText(p_item_type,
					    p_item_key,
					    'WF_STACK');

   /* Append the stack with the new string */
   WF_Engine.SetItemAttrText(itemtype => p_item_type,
			     itemkey  => p_item_key,
			     aname     => 'WF_STACK',
			     avalue    => v_err_stack||'=>'||p_err_stack);

Exception

WHEN OTHERS THEN
     Wf_Core.Context('PA_AUTOALLOC_WF_PKG',
                      'Set_PA_WF_Stack', 'PASDALOC', PA_item_key,G_Err_Stage);
     Wf_Core.Get_Error(G_err_name,G_err_msg,G_err_stack);
     Raise;

End Set_PA_WF_Stack;
--------------------------------------------------------------------------------
/* This procedure resets WF_STACK attribute.It just removes last string from the   stack  */

Procedure 	Reset_PA_WF_STACK (p_item_type	In 	Varchar2,
				   p_item_key	In	Varchar2)
IS
v_err_stack	Varchar2(2000);
v_reset_stack	Varchar2(2000);
Begin
   /* Get the previous value of the attribute */
   v_err_stack := WF_Engine.GetItemAttrText(p_item_type,
					    p_item_key,
					    'WF_STACK');
   v_reset_stack := Substr(v_err_stack,1,
				instr(v_err_stack,'=>',-1,1)-1);

   /* Remove the most recently entered string from the stack  */
   WF_Engine.SetItemAttrText(itemtype => p_item_type,
			     itemkey  => p_item_key,
			     aname     => 'WF_STACK',
			     avalue    => v_reset_stack);

End Reset_PA_WF_Stack;
--------------------------------------------------------------------------------
/* Set the WF_STAGE attribute with an argument */
Procedure 	Set_PA_WF_Stage (p_item_type	In 	Varchar2,
				 p_item_key	In	Varchar2,
				 p_err_stage	In	Varchar2)
IS
v_err_stage	Varchar2(2000);
Begin

   WF_Engine.SetItemAttrText(itemtype => p_item_type,
			     itemkey  => p_item_key,
			     aname     => 'WF_STAGE',
			     avalue    => p_err_stage);

End Set_PA_WF_Stage;
--------------------------------------------------------------------------------
Function DebugFlag
Return BOOLEAN
IS
v_debug_mode 	Varchar2(2);
BEGIN
 v_debug_mode := wf_engine.GetItemAttrText
                                        (       itemtype => PA_item_type,
                                                itemkey => PA_item_key,
                                                aname => 'DEBUG_MODE');

   IF v_debug_mode = 'Y' THEN
      Return TRUE;
   ELSE
      Return FALSE;
   END IF;

End DebugFlag;
-------------------------------------------------------------------------------

-- Created this function for bug 5218394. This function will reterieve the debug
-- directory location using utl_log_dir
--------------------------------------------------------------------------------
Function GetDebugLogDir
Return VARCHAR2
IS

TEMP_UTL        VARCHAR2(512);
TEMP_DIR        VARCHAR2(255);

BEGIN
      -- use first entry of utl_file_dir as the TEMP_DIR
      -- if there is no entry then do not even construct file names
      SELECT TRANSLATE(LTRIM(value),',',' ')
      INTO TEMP_UTL
      FROM v$parameter
      WHERE name = 'utl_file_dir';

      IF (INSTR(TEMP_UTL,' ') > 0 AND TEMP_UTL IS NOT NULL) THEN
        SELECT SUBSTRB(TEMP_UTL, 1, INSTR(TEMP_UTL,' ') - 1)
        INTO TEMP_DIR
        FROM dual ;
      ELSIF (TEMP_UTL IS NOT NULL) THEN
        TEMP_DIR := TEMP_UTL;
      END IF;

      IF (TEMP_UTL IS NULL or TEMP_DIR IS NULL ) THEN
         TEMP_DIR := '/sqlcom/log';
      END IF;

      RETURN TEMP_DIR;
End GetDebugLogDir;
-------------------------------------------------------------------------------
End PA_AUTOALLOC_WF_PKG;


/
