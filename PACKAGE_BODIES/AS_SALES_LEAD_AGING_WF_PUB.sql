--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_AGING_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_AGING_WF_PUB" AS
/* $Header: asxslagb.pls 115.2 2002/11/06 00:49:47 appldev ship $ */

------------------------
-- Constants Definition
------------------------

-- Workflow status flags
C_WORKFLOW_APPROVED_SAVED      CONSTANT VARCHAR2(1) := 'S';
C_WORKFLOW_APPROVED_REJECTED   CONSTANT VARCHAR2(1) := 'R';

-- Start from process from abandon, reassign
C_START_FROM_REASSIGN          CONSTANT VARCHAR2(40) := 'AS_REASSIGN';
C_START_FROM_ABANDON           CONSTANT VARCHAR2(40) := 'AS_ABANDON';
C_START_FROM_PASS              CONSTANT VARCHAR2(40) := 'AS_PASS';
C_START_FROM_ERROR             CONSTANT VARCHAR2(40) := 'ERROR';


PROCEDURE StartSalesLeadAgingProcess(
    p_request_id            IN NUMBER,
    p_sales_lead_id         IN NUMBER,
    p_assigned_resource_id  IN NUMBER,
    p_aging_days_noact      IN NUMBER,
    p_aging_days_abandon    IN NUMBER,
    p_aging_abandon_actions IN VARCHAR2,
    p_aging_noact_actions   IN VARCHAR2,
    x_item_type             OUT VARCHAR2,
    x_item_key              OUT VARCHAR2,
    x_return_status	        OUT VARCHAR2 )
IS
    l_item_type        VARCHAR2(100) := 'ASXSLAG';
    l_item_key         VARCHAR2(100) := to_char(p_request_id);
    l_status           VARCHAR2(80);
    l_result           VARCHAR2(80);
    l_debug_info       VARCHAR2(200);
    workflowprocess VARCHAR2(30)     := 'AS_SALES_LEAD_AGING_PROCESS';

BEGIN

    -- dbms_output.put_line ('Startprocess ');

    WF_ENGINE.CreateProcess(
        itemtype => l_item_type,
        itemkey => l_item_key,
        process => workflowprocess);


    WF_ENGINE.SetItemAttrNumber(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname => 'SALES_LEAD_ID',
        avalue	=> p_sales_lead_id);

    WF_ENGINE.SetItemAttrNumber(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname =>'DAYS_TO_ACCEPT',
        avalue	=> p_aging_days_noact);

    WF_ENGINE.SetItemAttrNumber(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname =>'DAYS_TO_ABANDON',
        avalue	=> p_aging_days_abandon);

    WF_ENGINE.SetItemAttrText(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname =>'AGING_ABANDON_ACTIONS',
        avalue => p_aging_abandon_actions);

    WF_ENGINE.SetItemAttrText  (
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname =>'AGING_NOACT_ACTIONS',
        avalue	=> p_aging_noact_actions);

    wf_engine.SetItemAttrNumber (
        itemtype => l_item_type,
        itemkey  => l_item_key,
        aname => 'ASSIGN_ID',
        avalue => p_assigned_resource_id);

    wf_engine.AddItemAttr(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname  => 'ORIG_RESOURCE_ID',
        number_value => p_assigned_resource_id);

    wf_engine.AddItemAttr(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname  => 'RESOURCE_ID',
        number_value => p_assigned_resource_id);

    wf_engine.AddItemAttr(
        itemtype => l_item_type,
        itemkey => l_item_key,
        aname  => 'BUSINESS_GROUP_ID',
        number_value => 0);

    WF_ENGINE.StartProcess (
        itemtype => l_item_type,
        itemkey => l_item_key	 );

    -- Remove the Background() call when finished testing...
    /*
    wf_engine.Background (
        itemtype => l_item_type,
        minthreshold =>  null,
        maxthreshold =>  null,
        process_deferred => TRUE,
        process_timeout => TRUE);

    wf_engine.Background    (
        itemtype => 'ASXLABDW',
        minthreshold =>  null,
        maxthreshold => null,
        process_deferred => TRUE,
        process_timeout => TRUE);
    */

    WF_ENGINE.ItemStatus(
        itemtype => l_item_type,
        itemkey => l_item_key,
        status  => l_status,
        result  => l_result);

    x_item_type := l_item_type;
    x_item_key := l_item_key;
    x_return_status := l_result ;

    EXCEPTION
  	    when others then
		  wf_core.context('AS_SALES_LEAD_AGING_WF_PUB',
                            'StartSalesLeadAgingProcess',
                            workflowprocess, l_item_key );
		  raise;

END StartSalesLeadAgingProcess;


PROCEDURE DetermineStartFromProcess(
    itemtype       in VARCHAR2,
    itemkey        in VARCHAR2,
    actid          in NUMBER,
    funcmode       in VARCHAR2,
    result         out VARCHAR2 )
IS
    CURSOR c_sales_lead (x_sales_lead_id NUMBER) IS
      SELECT sales_lead_id
             ,creation_date
             ,assign_date
             ,accept_flag
             ,status_code
      FROM as_sales_leads
      WHERE sales_lead_id = x_sales_lead_id;

    l_start_from_process       VARCHAR2(40);
    l_debug_info               VARCHAR2(200);
    l_sales_lead_rec           Sales_Lead_Rec_Type;

    l_sales_lead_id            NUMBER;
    l_aging_days_noact         NUMBER;
    l_aging_days_abandon       NUMBER;
    l_aging_abandon_actions    VARCHAR2(240);
    l_aging_noact_actions      VARCHAR2(240);

    -- delete later
    l_datediff                 NUMBER;
    l_datedifftest             BOOLEAN;
BEGIN
    -- dbms_output.put_line('DetermineStartFromProcess: '|| funcmode);

    IF (funcmode = 'RUN') THEN

        l_sales_lead_id := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey,
                                                       'SALES_LEAD_ID');

        l_aging_days_noact := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey,
                                                          'DAYS_TO_ACCEPT');

        l_aging_days_abandon := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey,
                                                            'DAYS_TO_ABANDON');
        l_aging_abandon_actions := WF_ENGINE.GetItemAttrText(itemtype, itemkey,
                                                      'AGING_ABANDON_ACTIONS');

        l_aging_noact_actions := WF_ENGINE.GetItemAttrText(itemtype, itemkey,
                                                        'AGING_NOACT_ACTIONS');

        OPEN c_sales_lead(l_sales_lead_id);
        FETCH c_sales_lead INTO
            l_sales_lead_rec.sales_lead_id,
            l_sales_lead_rec.creation_date,
            l_sales_lead_rec.assign_date,
            l_sales_lead_rec.accept_flag,
            l_sales_lead_rec.status_code;

        result := 'COMPLETE:'||C_START_FROM_PASS;

        IF c_sales_lead%FOUND
        THEN
            l_datediff := sysdate - l_sales_lead_rec.assign_date ;
            IF  l_datediff > l_aging_days_noact
            THEN
                IF upper(l_aging_noact_actions) = 'ABANDON'
                THEN
                    result := 'COMPLETE:' || C_START_FROM_ABANDON;
                ELSIF upper(l_aging_noact_actions) = 'REASSIGN'
                      OR upper(l_aging_noact_actions) = 'RECYCLE'
                THEN
                    result := 'COMPLETE:' || C_START_FROM_REASSIGN;
                END IF;
            END IF;

            IF l_sales_lead_rec.assign_date IS NOT NULL AND result IS NULL
            THEN
                IF (l_datediff > l_aging_days_abandon)
                   AND (nvl(l_sales_lead_rec.accept_flag,'NULL') <> 'Y')
                THEN
                    IF upper(l_aging_noact_actions) = 'ABANDON'
                    THEN
                        result := 'COMPLETE:' || C_START_FROM_ABANDON;
                    ELSIF upper(l_aging_noact_actions) = 'REASSIGN'
                          OR upper(l_aging_noact_actions) = 'RECYCLE'
                    THEN
                        result := 'COMPLETE:' || C_START_FROM_REASSIGN;
                    END IF;
                END IF;
            ELSE -- assign date IS null
        	      l_datediff := sysdate - l_sales_lead_rec.creation_date ;
        	      IF (l_datediff > l_aging_days_abandon)
                   AND (nvl(l_sales_lead_rec.accept_flag,'NULL') <> 'Y')
                THEN
                    IF upper(l_aging_noact_actions) = 'ABANDON'
                    THEN
                        result := 'COMPLETE:' || C_START_FROM_ABANDON;
                    ELSIF upper(l_aging_noact_actions) = 'REASSIGN'
                          OR upper(l_aging_noact_actions) = 'RECYCLE'
                    THEN
                        result := 'COMPLETE:' || C_START_FROM_REASSIGN;
                    END IF;
                END IF;
            END IF;
        ELSE
            result := 'COMPLETE:'||C_START_FROM_ERROR;
        END IF;
        CLOSE c_sales_lead;

    ELSIF (funcmode = 'CANCEL')
    THEN
        result := 'COMPLETE';
    END IF;

    -- dbms_output.put_line('Result: '||result);

    EXCEPTION
   	  when others then
           result := 'COMPLETE:'||C_START_FROM_ERROR;
           wf_core.context('AS_SALES_LEAD_AGING_WF_PUB',
                           'DetermineStartFromProcess',
                           itemtype, itemkey, to_char(actid), funcmode);
           raise;

END DetermineStartFromProcess;

END AS_SALES_LEAD_AGING_WF_PUB;


/
