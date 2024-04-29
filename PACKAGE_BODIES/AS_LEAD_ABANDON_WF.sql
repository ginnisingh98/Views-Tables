--------------------------------------------------------
--  DDL for Package Body AS_LEAD_ABANDON_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_LEAD_ABANDON_WF" AS
/* $Header: asxslabb.pls 115.3 2002/11/06 00:49:18 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_LEAD_ABANDON_WF';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxslabb.pls';


PROCEDURE StartProcess(
    p_sales_lead_id	in INTEGER,
    p_assigned_resource_id in INTEGER,
    x_return_status   in out VARCHAR2,
    x_item_type out VARCHAR2,
    x_item_key out VARCHAR2 )
IS
    Item_Type	VARCHAR2(8) := 'ASXLABDW' ;
    Item_Key   VARCHAR2(30);
    l_status   VARCHAR2(80);
    l_result   VARCHAR2(80);
    l_sequence VARCHAR2(240);
    l_seqnum   NUMBER(38);
    workflowprocess VARCHAR2(30) := 'LEAD_ABANDON_PROCESS';

BEGIN
    -- dbms_output.put_line('AS_LEAD_ABANDON_WF: Startprocess begin'||Item_Key);

    -- Start Process :
    --  If workflowprocess is passed, it will be run.
    --  If workflowprocess is NOT passed, the selector FUNCTION
    --  defined in the item type will determine which process to run.

    SELECT TO_CHAR(AS_WORKFLOW_KEYS_S.nextval)
    INTO Item_Key
    FROM dual;

    -- dbms_output.put_line('Startprocess: '||Item_Key);

    wf_engine.CreateProcess(
            ItemType => Item_Type,
            ItemKey  => Item_Key,
            process  => Workflowprocess);

    -- Initialize workflow item attributes
    --
    wf_engine.SetItemAttrNumber (
            itemtype => Item_Type,
            itemkey  => Item_Key,
            aname 	 => 'SALES_LEAD_ID',
            avalue	 => p_sales_lead_id);

    wf_engine.SetItemAttrNumber (
            itemtype => Item_Type,
            itemkey  => Item_Key,
            aname 	 => 'ASSIGN_ID',
            avalue	 => p_assigned_resource_id);

    wf_engine.AddItemAttr (
            itemtype => Item_Type,
            itemkey => Item_Key,
            aname  => 'ORIG_RESOURCE_ID',
            number_value => p_assigned_resource_id);

    wf_engine.AddItemAttr (
            itemtype => Item_Type,
            itemkey => Item_Key,
            aname  => 'RESOURCE_ID',
            number_value => p_assigned_resource_id);

    wf_engine.AddItemAttr (
            itemtype => Item_Type,
           itemkey => Item_Key,
           aname  => 'BUSINESS_GROUP_ID',
           number_value => 0);

    wf_engine.StartProcess (
            itemtype => Item_Type,
            itemkey	 => Item_Key );

    wf_engine.ItemStatus (
            itemtype => Item_Type,
            itemkey	 => Item_Key,
            status  => l_status,
            result  => l_result);

    x_item_type := Item_Type;
    x_item_key := Item_Key;
    x_return_status := l_result ;

    -- dbms_output.put_line('AS_LEAD_ABANDON_WF: Startprocess end');

    EXCEPTION
	   when others then
		  wf_core.context(Item_type, 'StartProcess', p_sales_lead_id,
                            Workflowprocess);
		  x_return_status := 'ERROR';
		  raise;
END StartProcess;


PROCEDURE GetAbandonTime (
    itemtype       in VARCHAR2,
    itemkey        in VARCHAR2,
    actid          in NUMBER,
    funcmode       in VARCHAR2,
    result         out VARCHAR2 )
IS
    l_abandondays Number := 0 ;
    wait_mode varchar2(100);
    wakeup number;

BEGIN

    -- dbms_output.put_line ('GetAcceptTime '||itemkey);
    IF funcmode = 'RUN'
    THEN
        l_abandondays := fnd_profile.value('AS_AGING_DAYS_ABANDON');

        -- dbms_output.put_line ('Time to Wait: '||l_abandondays);

        wf_engine.SetItemAttrNumber (
                itemtype ,
                itemkey ,
                aname  => 'DAYS_TO_ABANDON',
                avalue => l_abandondays);

        result := 'COMPLETE:';
    END IF;

    EXCEPTION
   	   when others then
		  wf_core.context(Itemtype, 'GetAcceptTime', itemtype, itemkey,
                            to_char(actid),funcmode);
		  raise;

END GetAbandonTime;


PROCEDURE GetAbandonAction (
    itemtype      in VARCHAR2,
    itemkey       in VARCHAR2,
    actid	        in NUMBER,
    funcmode      in VARCHAR2,
    result        out VARCHAR2 )
IS
    l_action VARCHAR2(240);

BEGIN
    -- dbms_output.put_line ('GetAbandonAction '||itemkey);
    IF funcmode = 'RUN' THEN
        l_action := fnd_profile.value('AS_AGING_ABANDON_ACTIONS');
        -- dbms_output.put_line ('Decision: '||l_action);
        IF UPPER(l_action) = 'ABANDON' THEN
            result := 'COMPLETE:ABANDON';
        ELSE
	       result := 'COMPLETE:';
	   END IF;
    END IF ;

  EXCEPTION
   	when others then
		wf_core.context(Itemtype, 'GetAbandonAction', itemtype, itemkey,
                          to_char(actid),funcmode);
		raise;
END GetAbandonAction;


PROCEDURE GetResourceGroup (
    itemtype      in VARCHAR2,
    itemkey       in VARCHAR2,
    actid         in NUMBER,
    funcmode      in VARCHAR2,
    result        out VARCHAR2 )
IS
    CURSOR c_resourcegroup (resource_id_in number) IS
        SELECT b.business_group_id
        FROM jtf_rs_emp_dtls_vl a,
             per_assignments_x b
        WHERE a.source_id = b.person_id
              and b.primary_flag = 'Y'
              and b.assignment_type = 'E'
              and a.resource_id = resource_id_in
        ORDER BY resource_id;

    l_resource_id NUMBER;
    l_business_group_id NUMBER;

BEGIN
    -- dbms_output.put_line('GetResourceGroup: '||itemkey);

    IF funcmode = 'RUN' THEN
        l_resource_id := wf_engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname  	=> 'RESOURCE_ID' );

        -- dbms_output.put_line ('Resource ID: ' || to_char(l_resource_id));

        OPEN c_resourcegroup (l_resource_id);
        FETCH c_resourcegroup
        INTO l_business_group_id;
        CLOSE c_resourcegroup;

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname  => 'BUSINESS_GROUP_ID',
                                    avalue => l_business_group_id);

        -- dbms_output.put_line('Group ID: '||to_char(l_business_group_id));
        -- dbms_output.put_line('Resource: '||to_char(l_resource_id));

        result := 'COMPLETE:';

    END IF;

    EXCEPTION
	  when others then
		 wf_core.context(itemtype, 'GetResourceGroup', itemtype, itemkey,
                           to_char(actid),funcmode);
		 result := 'COMPLETE:ERROR';
		 raise;
END GetResourceGroup;

END AS_LEAD_ABANDON_WF;


/
