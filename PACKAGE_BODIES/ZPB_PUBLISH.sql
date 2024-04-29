--------------------------------------------------------
--  DDL for Package Body ZPB_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_PUBLISH" AS
/* $Header: ZPBPUBB.pls 120.0.12010.2 2005/12/23 06:02:52 appldev noship $ */


/*+=========================================================================+
  | startPublishTaskCP
  |
  | Starts the Publish WorkFlow process which runs independent of BP Tasks.
  |
  | Notes:
  |  1. Manages context for WF.
  |  2. Starts the WF process.
  |
  +========================================================================+
*/

    PROCEDURE startPublishTaskCP(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT nocopy VARCHAR2
 )
   IS
        -- Enter the procedure variables here. As shown below
        CurrtaskSeq         NUMBER;
        ACID                NUMBER;
        ownerID             NUMBER;
        respID              NUMBER;
        respAppID           NUMBER;
        InstanceID          NUMBER;
        TaskID              NUMBER;
        REQID               NUMBER;

        owner               VARCHAR2(30);
        ACNAME              VARCHAR2(300);
        charDate            VARCHAR2(30);
        newItemKey          VARCHAR2(240);
        workflowprocess     VARCHAR2(30);
        TaskName            VARCHAR2(256);

    	issue_msg           fnd_new_messages.message_text%TYPE;
        textVarNameArray    Wf_Engine.NameTabTyp; -- Array of Text Attribute Names
        textVarValArray     Wf_Engine.TextTabTyp; -- Text Array of Item Attribute Values
        numVarNameArray     Wf_Engine.NameTabTyp;  -- Array of Numeric Attribute Names
        numVarValArray      Wf_Engine.NumTabTyp;   -- Number Array of Item Attribute Values


        CURSOR c_tasks is
            select *
            from zpb_analysis_cycle_tasks
            where ANALYSIS_CYCLE_ID = InstanceID
            and Sequence = CurrtaskSeq;
        v_tasks c_Tasks%ROWTYPE;

   BEGIN
  	    resultout :='COMPLETE:N';
        -- Get current global attributes to run next WF task!
        CurrtaskSeq := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKSEQ');
        ACID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACID');
        ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACNAME');
        ownerID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'OWNERID');
        respID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPID');
        respAppID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'RESPAPPID');
        owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'FNDUSERNAM');
        InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'INSTANCEID');
        TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'TASKID');

        WorkflowProcess := 'PUBLISH_WORKFLOW';
        -- Set item key and date
        charDate := to_char(sysdate, 'MM/DD/YYYY-HH24-MI-SS');
        newItemKey := rtrim(substr(ACName, 1, 50), ' ') || '-' || to_char(ACID) || '-' || to_char(CurrtaskSeq+1) || '-' || workflowprocess || '-' || charDate;
-- +============================================================+
        -- Create WF start process instance
        wf_engine.CreateProcess(ItemType => ItemType,
                        itemKey => newItemKey,
                        process => WorkflowProcess);

	   -- Get the short text from fnd messages
        FND_MESSAGE.SET_NAME('ZPB', 'ZPB_PUBLISH_TASK_ISSUE_MSG');
        issue_msg := FND_MESSAGE.GET;

        textVarNameArray(1) := 'EPBPERFORMER';
        textVarValArray(1) := owner;

        textVarNameArray(2) := 'ACNAME';
        textVarValArray(2) := ACNAME;

        textVarNameArray(3) := 'ISSUEMSG';
        textVarValArray(3) := issue_msg;

        textVarNameArray(4) := 'FNDUSERNAM';
        textVarValArray(4) := owner;

        Wf_Engine.SetItemAttrTextArray(Itemtype => ItemType,
                        Itemkey => newItemKey,
                        aname => textVarNameArray,
                        avalue => textVarValArray);

        numVarNameArray(1) := 'OWNERID';
        numVarValArray(1) := ownerID;

        numVarNameArray(2) := 'RESPID';
        numVarValArray(2) := respID;

        numVarNameArray(3) := 'RESPAPPID';
        numVarValArray(3) := respAppID;

        numVarNameArray(4) := 'INSTANCEID';
        numVarValArray(4) := InstanceID;

        numVarNameArray(5) := 'TASKID';
        numVarValArray(5) := TaskID;

        Wf_Engine.SetItemAttrNumberArray(Itemtype => ItemType,
                  Itemkey => newItemKey,
                  aname => numVarNameArray,
                  avalue => numVarValArray);

        --If the session has been interrupted, reset the Context.

-- +============================================================+
        -- Now that all is created and set START the PROCESS!
        wf_engine.StartProcess(ItemType => ItemType,
                        ItemKey => newItemKey);

        resultout := 'COMPLETE:Y';
        EXCEPTION
            WHEN others THEN
              raise;
    END startPublishTaskCP;

/*+=========================================================================+
  | getApprovalFlag
  |
  | 1. Checks whether "Approval Flag" is set by the User or not.
  | 2. Also checks whether the "Send Status Report" flag is set or not.
  |
  +========================================================================+
*/

    PROCEDURE getApprovalFlag(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT nocopy VARCHAR2
 )
   IS
        call_status         BOOLEAN;

    	l_respapp_id        NUMBER;
        l_user_id           NUMBER;
    	l_resp_id           NUMBER;
        l_start_pos         NUMBER;
        l_pre_PathLoc       NUMBER;
        l_post_PathLoc      NUMBER;
        l_pre_RepNameLoc    NUMBER;
        l_post_RepNameLoc   NUMBER;
        request_id          NUMBER;
        InstanceID          NUMBER;
        TaskID              NUMBER;

        l_owner             VARCHAR2(30);
        l_ACNAME            VARCHAR2(300);
        rphase              VARCHAR2(30);
        rstatus             VARCHAR2(30);
        dphase              VARCHAR2(30);
        dstatus             VARCHAR2(30);
        message             VARCHAR2(240);
        appr_flag           VARCHAR2(1);
        send_status_flag    VARCHAR2(1);
        template_name       VARCHAR2(4000);
        read_access         VARCHAR2(4000);
        recipients_list     VARCHAR2(4000);
        datasources_list    VARCHAR2(4000);
        l_char_delim        VARCHAR2(8);


    	issue_msg       fnd_new_messages.message_text%TYPE;
    	no_issue_msg    fnd_new_messages.message_text%TYPE;

        textVarNameArray Wf_Engine.NameTabTyp; -- Array of Text Attribute Names
        textVarValArray  Wf_Engine.TextTabTyp; -- Text Array of Item Attribute Values

        CURSOR c_recipient is
          select NAME, value
          from ZPB_TASK_PARAMETERS
          where TASK_ID = TaskID and name = 'SPECIFIED_NOTIFICATION_RECIPIENT';

        v_recipient c_recipient%ROWTYPE;

        CURSOR c_datasources is
          select NAME, value
          from ZPB_TASK_PARAMETERS
          where TASK_ID = TaskID and name = 'TEMPLATE_DATASOURCE';

        v_datasources c_datasources%ROWTYPE;

   BEGIN
        l_owner := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'FNDUSERNAM');
 	    l_resp_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
        		       Itemkey => ItemKey,
 	  	               aname => 'RESPID');
        l_user_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
        		       Itemkey => ItemKey,
	  	               aname => 'OWNERID');
        l_respapp_id := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
        		       Itemkey => ItemKey,
 	  	               aname => 'RESPAPPID');
        l_ACNAME := wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ACNAME');
        InstanceID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'INSTANCEID');
        TaskID := wf_engine.GetItemAttrNumber(Itemtype => ItemType,
                         Itemkey => ItemKey,
                         aname => 'TASKID');

        l_start_pos          := 1;
        l_pre_PathLoc        := 3;
        l_post_PathLoc       := 4;
        l_pre_RepNameLoc     := 2;
        l_post_RepNameLoc    := 3;
        l_char_delim         := fnd_global.newline;

        --Getting the List of Document Recipients
        for  v_recipient in c_recipient loop
           recipients_list := recipients_list || v_recipient.value || l_char_delim;
        end loop;
        recipients_list := SUBSTR(
                            recipients_list,
                            l_start_pos,
                            length(recipients_list) - length(l_char_delim));

        --Getting the Lits of Datasources used to create the Document
        for  v_datasources in c_datasources loop
           datasources_list := datasources_list ||
           SUBSTR(
             v_datasources.value,
             INSTR(v_datasources.value, l_char_delim, l_start_pos, l_pre_PathLoc)+1,
             INSTR(v_datasources.value, l_char_delim, l_start_pos, l_post_PathLoc)-
                 INSTR(v_datasources.value, l_char_delim, l_start_pos, l_pre_PathLoc)-1
                  ) || '/' ||
           SUBSTR(
             v_datasources.value,
             INSTR(v_datasources.value, l_char_delim, l_start_pos, l_pre_RepNameLoc)+1,
             INSTR(v_datasources.value, l_char_delim, l_start_pos, l_post_RepNameLoc)-
                 INSTR(v_datasources.value, l_char_delim, l_start_pos, l_pre_RepNameLoc)-1
                  )
           || l_char_delim;
        end loop;

        datasources_list := SUBSTR(
                            datasources_list,
                            l_start_pos,
                            length(datasources_list) - length(l_char_delim));

        --Getting the Template Name used to create the Document
        SELECT value INTO template_name
        FROM zpb_task_parameters
        WHERE task_ID = taskID and NAME = 'DOCUMENT_TEMPLATE_NAME';

        --Getting the Document Security used
        SELECT value INTO read_access
        FROM zpb_task_parameters
        WHERE task_ID = taskID and NAME = 'DOCUMENT_SECURITY';
        IF read_access = 'USER_READSCOPE' THEN
            read_access := fnd_message.get_string('ZPB', 'ZPB_RECIPIENT_READ_SCOPE');
        ELSE
            read_access := fnd_message.get_string('ZPB', 'ZPB_BPO_READ_SCOPE');
        END IF;

        --To find whether the Approval required CheckBox is selected
        SELECT value INTO appr_flag
        FROM zpb_task_parameters
        WHERE task_ID = taskID and NAME = 'DOCUMENT_WAIT_FOR_APPROVAL';

        --To find whether Send Status Report CheckBox is selected
        SELECT value INTO send_status_flag
        FROM zpb_task_parameters
        WHERE task_ID = taskID and NAME = 'DOCUMENT_SEND_STATUS_BPO';

	    -- Get the short text from fnd messages
        FND_MESSAGE.SET_NAME('ZPB', 'ZPB_CAL_JAVA_XML_GEN_ISSUE_MSG');
        issue_msg := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('ZPB', 'ZPB_NO_ISSUE_MSG');
        no_issue_msg := FND_MESSAGE.GET;

        textVarNameArray(1) := 'ISSUEMSG';
        textVarValArray(1) := issue_msg;

        textVarNameArray(2) := 'NOISSUEMSG';
        textVarValArray(2) := no_issue_msg;

        textVarNameArray(3) := 'ACNAME';
        textVarValArray(3) := l_ACNAME;

        textVarNameArray(4) := 'TEMPLATE_NAME';
        textVarValArray(4) := template_name;

        textVarNameArray(5) := 'READ_ACCESS';
        textVarValArray(5) := read_access;

        textVarNameArray(6) := 'DOC_RECEP_LIST';
        textVarValArray(6) := recipients_list;

        textVarNameArray(7) := 'DATASOURCE_LIST';
        textVarValArray(7) := datasources_list;

        IF (send_status_flag = 'Y') THEN
            textVarNameArray(8) := 'EPBPERFORMER';
            textVarValArray(8) := l_owner;
            call_status := FND_REQUEST.add_notification(l_owner);
        END IF;

        Wf_Engine.SetItemAttrTextArray(Itemtype => ItemType,
                        Itemkey => ItemKey,
                        aname => textVarNameArray,
                        avalue => textVarValArray);

        --If the session has been interrupted due to notification, reset the Context.
     	fnd_global.apps_initialize(l_user_id,l_resp_id,l_respapp_id);

        -- WF BACKGROUND ENGINE TO RUN deferred activities like WAIT.
        call_status := FND_CONCURRENT.GET_REQUEST_STATUS(request_id, 'ZPB', 'ZPB_WF_START', rphase,rstatus,dphase,dstatus, message);

        IF (appr_flag = 'Y') THEN
            resultout := 'COMPLETE:Y';
        ELSE
            resultout := 'COMPLETE:N';
        END IF;

   EXCEPTION

        WHEN NO_DATA_FOUND then
            resultout := 'COMPLETE:N';
        WHEN others THEN
            raise;
   END getApprovalFlag;
END ZPB_PUBLISH;

/
