--------------------------------------------------------
--  DDL for Package Body AS_LEAD_ASSIGN_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEAD_ASSIGN_WF" AS
/* $Header: asxlasnb.pls 115.7 2002/11/06 00:43:01 appldev ship $ */
--Declarations


PROCEDURE StartProcess(
    p_sales_lead_id             in  INTEGER,
    p_assigned_resource_id      in  INTEGER,
    x_return_status     in      out VARCHAR2,
    x_item_type                 out VARCHAR2,
    x_item_key                  out VARCHAR2 )
IS
    Item_Type	VARCHAR2(8) := 'ASXLDASW' ;
    Item_Key VARCHAR2(30);
    l_status VARCHAR2(80);
    l_result VARCHAR2(80);
    l_sequence VARCHAR2(240);
    l_seqnum NUMBER(38);
    workflowprocess VARCHAR2(30) := 'LEAD_ASSIGNMENT_PROCESS';
    l_resource_id NUMBER;
BEGIN
    -- Start Process :
    --  If workflowprocess is passed, it will be run.
    --  If workflowprocess is NOT passed, the selector FUNCTION
    --  defined in the item type will determine which process to run.

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: Startprocess Begin'||item_key);

    SELECT TO_CHAR(AS_WORKFLOW_KEYS_S.nextval) INTO Item_Key FROM dual;

    -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
    --                              'Startprocess: '||item_key);

    wf_engine.CreateProcess(
        ItemType => Item_Type,
        ItemKey  => Item_Key,
        process  => Workflowprocess);

    -- Initialize workflow item attributes
    --
    wf_engine.SetItemAttrNumber (
        itemtype => Item_Type,
        itemkey  => Item_Key,
        aname    => 'SALES_LEAD_ID',
        avalue   => p_sales_lead_id);

    wf_engine.SetItemAttrNumber (
        itemtype => Item_Type,
        itemkey  => Item_Key,
        aname    => 'ASSIGN_ID',
        avalue   => p_assigned_resource_id);

    l_resource_id := wf_engine.GetItemAttrNumber(
                                   itemtype => Item_Type,
                                   itemkey  => Item_Key,
                                   aname    => 'ASSIGN_ID' );
--     dbms_output.put_line('l_resource_id' || l_resource_id);

    wf_engine.SetItemAttrNumber (
        itemtype => Item_Type,
        itemkey  =>Item_key,
        aname    => 'DAYS_TO_ACCEPT',
        avalue   =>  0);

    wf_engine.AddItemAttr(
        itemtype => Item_Type,
        itemkey  => Item_Key,
        aname    => 'RESOURCE_ID',
        number_value => 0);

    wf_engine.AddItemAttr(
        itemtype => Item_Type,
        itemkey  => Item_Key,
        aname    => 'ORIG_RESOURCE_ID',
        number_value => p_assigned_resource_id);

    wf_engine.AddItemAttr(
        itemtype => Item_Type,
        itemkey  => Item_Key,
        aname    => 'BUSINESS_GROUP_ID',
        number_value => 0);

    wf_engine.StartProcess(
        itemtype => Item_Type,
        itemkey  => Item_Key);

    wf_engine.ItemStatus(
        itemtype => Item_Type,
        itemkey  => Item_Key,
        status   => l_status,
        result   => l_result);

    x_item_type := Item_Type;
    x_item_key := Item_Key;
    x_return_status := l_status;

--     dbms_output.put_line('AS_LEAD_ASSIGN_WF: Startprocess End');
    EXCEPTION
       when others then
          wf_core.context(Item_type, 'StartProcess', p_sales_lead_id,
                          Workflowprocess);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
								 'error in StartProcess');
    -- dbms_output.put_line('Error in AS_LEAD_ASSIGN_WF: Startprocess ');
          raise;
END StartProcess;


PROCEDURE CheckAssignID(
    itemtype                   in VARCHAR2,
    itemkey                    in VARCHAR2,
    actid                      in NUMBER,
    funcmode                   in VARCHAR2,
    result                     out VARCHAR2)
IS
   l_resource_id NUMBER;

BEGIN

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: CheckAssignID begin');
    l_resource_id := wf_engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ASSIGN_ID' );

    -- dbms_output.put_line('l_resource_id: '||l_resource_id);
    if (l_resource_id is not null) then
        result := 'COMPLETE:Y';
    else
	   result := 'COMPLETE:N';
    end if ;

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: CheckAssignID end - '||result);
    EXCEPTION
        when others then
            wf_core.context(Itemtype, 'CheckAssignID', itemtype, itemkey,
                            to_char(actid), funcmode);
            raise;

END CheckAssignID;


PROCEDURE AssignLead (
    itemtype                  in VARCHAR2,
    itemkey                   in VARCHAR2,
    actid                     in NUMBER,
    funcmode                  in VARCHAR2,
    result                    out VARCHAR2 )
IS
    CURSOR c_sales_lead(x_sales_lead_id NUMBER) IS
        SELECT last_update_date,
             customer_id,
             address_id,
             assign_sales_group_id,
             sales_lead_id
        FROM as_sales_leads
        WHERE sales_lead_id = x_sales_lead_id;

    l_sales_lead_id        NUMBER;
    l_resource_id          NUMBER;
    l_sales_lead_rec       AS_SALES_LEADS_PUB.sales_lead_rec_type ;
    l_sales_lead_profile_tbl   AS_UTILITY_PUB.Profile_Tbl_Type;
    l_api_version_number   NUMBER := 2.0;
    l_cnt                  NUMBER := 0;
    l_tt                   NUMBER := 0;
    l_status_code          VARCHAR2(30);
    l_last_update_date     DATE  := SYSDATE;
    l_return_status        VARCHAR2(15);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_msg_index_out        NUMBER;

BEGIN
    -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
    --                              'AssignLead '||itemkey);
    IF funcmode = 'RUN' then
    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: AssignLead begin '||itemkey);
        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                          itemtype => itemtype,
                                          itemkey => itemkey,
                                          aname => 'SALES_LEAD_ID' );

        l_resource_id := wf_engine.GetItemAttrNumber(
                                          itemtype => itemtype,
                                          itemkey => itemkey,
                                          aname => 'ASSIGN_ID' );

        OPEN c_sales_lead(l_sales_lead_id);
        FETCH c_sales_lead INTO
            l_sales_lead_rec.last_update_date,
            l_sales_lead_rec.customer_id,
            l_sales_lead_rec.address_id,
            l_sales_lead_rec.assign_sales_group_id,
            l_sales_lead_rec.sales_lead_id;
        CLOSE c_sales_lead;

        l_sales_lead_rec.assign_to_salesforce_id := l_resource_id;

        AS_SALES_LEADS_PUB.update_sales_lead(
           p_api_version_number     => l_api_version_number
          ,p_init_msg_list          => fnd_api.g_false
          ,p_commit                 => fnd_api.g_false
          ,p_validation_level       => 0 -- fnd_api.g_valid_level_full
          ,p_check_access_flag      => 'N' -- fnd_api.g_miss_char
          ,p_admin_flag             => fnd_api.g_miss_char
          ,p_admin_group_id         => fnd_api.g_miss_num
          ,p_identity_salesforce_id => fnd_api.g_miss_num
          ,p_sales_lead_profile_tbl => l_sales_lead_profile_tbl
          ,p_sales_lead_rec         => l_sales_lead_rec
          ,x_return_status          => l_return_status
          ,x_msg_count              => l_msg_count
          ,x_msg_data               => l_msg_data );

        -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        --                              'return status: ' || l_return_status );

        FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
            FND_MSG_PUB.Get(p_msg_index=>j,
                            p_encoded=>'F',
                            p_data=>l_msg_data,
                            p_msg_index_out=>l_msg_index_out);
        END LOOP;

        if l_return_status = fnd_api.g_ret_sts_success then
            result := 'COMPLETE:S';
        else
            result := 'COMPLETE:ERROR';
        end if;
    end if;

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: AssignLead end');
    EXCEPTION
   	  when others then
           wf_core.context(Itemtype, 'AssignLead', itemtype, itemkey,
                           to_char(actid), funcmode);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
								 'error in AssignLead');
           raise;

END AssignLead;


PROCEDURE GetAcceptTime (
    itemtype                  in VARCHAR2,
    itemkey                   in VARCHAR2,
    actid                     in NUMBER,
    funcmode                  in VARCHAR2,
    result                    out VARCHAR2 )
IS
    l_acceptdays Number := 0 ;
    wait_mode varchar2(100);
    wakeup number;

BEGIN
    -- dbms_output.put_line ('GetAcceptTime '||itemkey);
    IF funcmode = 'RUN' THEN
    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: GetAcceptTime begin'||itemkey);
        l_acceptdays := fnd_profile.value('AS_AGING_DAYS_NOACT');

        -- dbms_output.put_line ('Time to Wait: '||l_acceptdays);

        wf_engine.SetItemAttrNumber ( itemtype ,
                                      itemkey ,
                                      aname => 'DAYS_TO_ACCEPT',
                                      avalue => l_acceptdays);
        result := 'COMPLETE:';
    END IF;

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: GetAcceptTime end');
    EXCEPTION
   	   when others then
            wf_core.context(Itemtype, 'GetAcceptTime', itemtype, itemkey,
                            to_char(actid), funcmode);
            raise;

END GetAcceptTime;


PROCEDURE CheckAccepted (
    itemtype                  in VARCHAR2,
    itemkey                   in VARCHAR2,
    actid                     in NUMBER,
    funcmode                  in VARCHAR2,
    result                    out VARCHAR2 )
IS
    CURSOR c_lead_status (lead_id_in in number) IS
        SELECT accept_flag
        FROM as_sales_leads
        WHERE sales_lead_id = lead_id_in;

    l_accept_flag VARCHAR2(50);
    l_sales_lead_id NUMBER;

BEGIN
    -- dbms_output.put_line ('CheckAccepted '||itemkey);
    IF funcmode = 'RUN' then
    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: CheckAccepted begin'||itemkey);
        l_sales_lead_id :=  wf_engine.GetItemAttrNumber(
                                     itemtype => itemtype,
    					            itemkey => itemkey,
                                     aname => 'SALES_LEAD_ID' );

        OPEN c_lead_status (l_sales_lead_id);
        FETCH c_lead_status INTO l_accept_flag;
        CLOSE c_lead_status;

        IF upper(l_accept_flag) = 'Y' THEN
  	       result := 'COMPLETE:Y';
        ELSE
    	       result := 'COMPLETE:N';
        END IF;
    END IF;

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: CheckAccepted end');
    EXCEPTION
   	   when others then
            wf_core.context(Itemtype, 'CheckAccepted', itemtype, itemkey,
                            to_char(actid), funcmode);
            raise;

END CheckAccepted;


PROCEDURE CheckforAbandon (
    itemtype                  in VARCHAR2,
    itemkey                   in VARCHAR2,
    actid                     in NUMBER,
    funcmode                  in VARCHAR2,
    result                    out VARCHAR2 )
IS

l_action VARCHAR2(50);

BEGIN
    -- dbms_output.put_line ('CheckforAbandon '||itemkey);
    IF funcmode = 'RUN' THEN
    --dbms_output.put_line('AS_LEAD_ASSIGN_WF: CheckforAbandon begin'||itemkey);
        l_action := fnd_profile.value('AS_AGING_NOACT_ACTIONS');
        IF UPPER(l_action) = 'ABANDON' THEN
            result := 'COMPLETE:Y';
        ELSE
            result := 'COMPLETE:N';
        END IF;
    END IF ;

    -- dbms_output.put_line('AS_LEAD_ASSIGN_WF: CheckforAbandon end');
    EXCEPTION
   	   when others then
            wf_core.context(Itemtype, 'CheckforAbandon', itemtype, itemkey,
                              to_char(actid), funcmode);
            raise;

END CheckforAbandon;


END AS_LEAD_ASSIGN_WF ;



/
