--------------------------------------------------------
--  DDL for Package Body CS_WF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WF_EVENT_PKG" AS
/* $Header: cswfevtb.pls 120.11.12010000.8 2010/01/06 12:45:36 vpremach ship $ */

  /****************************************************************************************

  CS_Custom_Rule_Func

    This custom rule function corresponds to the subscriptions for workflow
    business events oracle.apps.cs.sr.ServiceRequest.created and
    oracle.apps.cs.sr.ServiceRequest.updated .
    These subscriptions executes the old BES converted seeded workflow CALL
    SUPPORT, as well as any client custom BES workflows. Also, these subscriptions
    are executed Synchronously, the same as the old seeded workflows. This is
    important since the calling wrapper API needs to update the workflow_process_id
    if the workflow was launched.

    If this custom rule function is not able to launch the workflow process
    because the proces is not BES compatible, then the CS event wrapper API
    Raise_ServiceRequest_Event() will try to launch the workflow process using
    the old non-BES workflow API calls, i.e., CreateProcess(), StartProcess() .
    This provides backward compatibility for those clients who has custom
    workflow processes but has not converted to BES.

  ***************************************************************************************/

  FUNCTION CS_Custom_Rule_Func (p_subscription_guid in raw,
                                     p_event in out nocopy WF_EVENT_T) return varchar2 is

    l_event_name 	VARCHAR2(240) := p_event.getEventName( );
    l_request_number	VARCHAR2(64);
    l_event_key		VARCHAR2(240);
    l_wf_process_id	NUMBER;
    l_item_key		VARCHAR2(100);
    l_user_id		NUMBER;
    l_manual_launch	VARCHAR2(1);
    l_raise_old_wf_flag	VARCHAR2(1);


    CURSOR sel_workflow_csr IS
      SELECT nvl(status.close_flag,'N') close_flag,
                inc.workflow_process_id,
                cit.AUTOLAUNCH_WORKFLOW_FLAG,
                cit.WORKFLOW,
                inc.resource_type,
                inc.incident_owner_id,
                inc.incident_id,
                inc.object_version_number
      FROM   cs_incident_statuses status,
             cs_incidents_all_b inc,
             cs_incident_types cit
      WHERE  inc.incident_number = l_request_number
             AND inc.incident_status_id = status.incident_status_id
             and cit.incident_type_id = inc.incident_type_id;

    l_sel_workflow_rec   sel_workflow_csr%ROWTYPE;

    CURSOR l_servereq_csr IS
      SELECT end_date
      FROM   wf_items
      WHERE  item_type = 'SERVEREQ'
      AND    item_key  like l_request_number||'-%'
      AND    item_key NOT like l_request_number||'%EVT'
      AND end_date IS NULL;

    l_end_date  DATE;


    l_process_name VARCHAR2(30);

    l_wf_proc_activity_name	wf_process_activities.ACTIVITY_NAME%TYPE;
    l_wf_activity_name	WF_ACTIVITIES.name%TYPE;

    CURSOR sel_workflow_act_csr IS
      select wfa.name
      from WF_ACTIVITIES wfa
      where wfa.item_type = 'SERVEREQ'
            and  wfa.type ='EVENT'
            and wfa.name = l_wf_proc_activity_name;


    -- get the Name of the Start activity for the latest workflow process version
    CURSOR sel_workflow_proc_act_csr IS
      select wfpa.ACTIVITY_NAME
      from wf_process_activities wfpa
      where wfpa.PROCESS_ITEM_TYPE = 'SERVEREQ'
            and wfpa.PROCESS_NAME = l_process_name
            and wfpa.START_END = 'START'
      ORDER BY wfpa.process_version DESC;



  begin
  --         <your executable statements>


    -- Obtain values initialized from the parameter list.
    l_request_number := p_event.GetValueForParameter('REQUEST_NUMBER');
    l_user_id := p_event.GetValueForParameter('USER_ID');

    -- rmanabat 01/06/03
    l_manual_launch := p_event.GetValueForParameter('MANUAL_LAUNCH');

    l_event_key := p_event.getEventKey();
    l_item_key := SUBSTR(l_event_key, 1, INSTR(l_event_key, '-EVT') - 1);

   --Changing the INSTR construct for bug#4007083- shdeshpa 12/02/2004
   --l_wf_process_id := TO_NUMBER( SUBSTR(l_item_key, INSTR(l_item_key,'-')+1, length(l_item_key)) );

    l_wf_process_id := TO_NUMBER( SUBSTR(l_item_key, INSTR(l_item_key,'-',-1,1)+1, length(l_item_key)) );


 --INSERT INTO rm_tmp values (l_request_number, 'In Custom rule,l_manual_launch='||l_manual_launch,rm_tmp_seq.nextval);


    OPEN sel_workflow_csr;
    FETCH sel_workflow_csr INTO l_sel_workflow_rec;
    IF (sel_workflow_csr%FOUND AND l_sel_workflow_rec.workflow IS NOT NULL) THEN


      -- Before attempting to raise an event workflow,we check if the workflow process
      -- is BES enabled, If not we will not call wf_engine.event().
      -- This is important since calling event() api on a non BES workflow causes
      -- it to raise an exception, which is handled in this custom rule function's
      -- exception handler with a return status of 'ERROR'. A return status of ERROR
      -- causes workflow to rollback any raised event performed, and since this is a
      -- synchorous subsciption, the succeeding subscriptions(auto-notification)
      -- will not be triggered since the event itself was rolled back.

      l_process_name := l_sel_workflow_rec.workflow;

      OPEN sel_workflow_proc_act_csr;
      FETCH sel_workflow_proc_act_csr
      INTO l_wf_proc_activity_name;
      CLOSE sel_workflow_proc_act_csr;


      OPEN sel_workflow_act_csr;
      FETCH sel_workflow_act_csr
      INTO l_wf_activity_name;

      IF (sel_workflow_act_csr%FOUND) THEN
        -- Workflow has a receive event as Start activity, so we can call
        -- the wf_engine.event() api.


        IF (l_sel_workflow_rec.AUTOLAUNCH_WORKFLOW_FLAG = 'Y') AND
           (( l_sel_workflow_rec.resource_type = 'RS_EMPLOYEE' AND
            -- Also need to check the owner_id being passed by CIC in order to launch
            -- their workflow.
            l_sel_workflow_rec.incident_owner_id IS NOT NULL) OR
	    l_sel_workflow_rec.workflow = 'CSEADUP')   THEN --changed for bug 7484364
	 --   l_sel_workflow_rec.workflow <> 'CSEADUP') THEN       --Added this for bug 6974942

            IF(l_event_name = 'oracle.apps.cs.sr.ServiceRequest.created') THEN

              l_raise_old_wf_flag := 'Y';

            ELSIF(l_sel_workflow_rec.close_flag <> 'Y') THEN
              OPEN l_servereq_csr;
	      FETCH l_servereq_csr INTO l_end_date;
              IF (l_servereq_csr%NOTFOUND) THEN
                l_raise_old_wf_flag := 'Y';
              END IF;

            END IF;


        -- rmanabat 01/06/03
        ELSIF (l_manual_launch = 'Y' AND
	       l_sel_workflow_rec.resource_type = 'RS_EMPLOYEE' AND
	       l_sel_workflow_rec.incident_owner_id IS NOT NULL AND
	       CS_Workflow_PKG.Is_Servereq_Item_Active
                 (p_request_number  => l_request_number,
                  p_wf_process_id   => l_sel_workflow_rec.workflow_process_id )  = 'N' AND
               l_sel_workflow_rec.close_flag <> 'Y') THEN


          l_raise_old_wf_flag := 'Y';

        END IF;

      END IF;	/** IF (sel_workflow_act_csr%FOUND) **/

      CLOSE sel_workflow_act_csr;

      IF (l_raise_old_wf_flag = 'Y') THEN


 --INSERT INTO rm_tmp values (l_request_number, 'Calling raise() from custom rule function ',rm_tmp_seq.nextval);

        -- This will have a Synchronous subscription.
        -- This will raise an exception when the workflow does not have a receive event
        -- activity,i.e., the workflow is not BES enabled.
        --BEGIN

          WF_ENGINE.Event(
	  	  itemtype	=> 'SERVEREQ',
  	  	  itemkey	=> l_item_key,
  	  	  process_name 	=> l_sel_workflow_rec.workflow,
  	  	  event_message	=> p_event);
        --EXCEPTION
          -- Still return success because we don't want ither subscriptions to fail
         -- --WHEN OTHERS THEN
         --   null;
        --END;


      END IF;



    END IF;	/** IF (sel_workflow_csr%FOUND AND ... **/

    CLOSE sel_workflow_csr;


    return 'SUCCESS';


  --         <optional code for WARNING>
  --         WF_CORE.CONTEXT('<package name>', '<function name>',
  --                         p_event.getEventName( ), p_subscription_guid);
  --         WF_EVENT.setErrorInfo(p_event, 'WARNING');
  --         return 'WARNING';

  EXCEPTION

    /*************
    WHEN l_UPDATE_FAILED THEN
      IF sel_workflow_csr%ISOPEN THEN
	CLOSE sel_workflow_csr;
      END IF;
      WF_CORE.CONTEXT('CS_WF_EVENT_PKG', 'CS_Custom_Rule_Func',
                      l_event_name , p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'WARNING');
      return 'WARNING';
     ******/

    WHEN others THEN

 --INSERT INTO rm_tmp values (l_request_number, 'In custom rule function,WHEN others exception ',rm_tmp_seq.nextval);

      IF sel_workflow_csr%ISOPEN THEN
	CLOSE sel_workflow_csr;
      END IF;
      WF_CORE.CONTEXT('CS_WF_EVENT_PKG', 'CS_Custom_Rule_Func',
                      l_event_name , p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      return 'WARNING';

  END CS_Custom_Rule_Func;



  /*************************************************************************
  --
  --   Raise_ServiceRequest_Event()
  --
  --     This is the wrapper API to be called by the Create/Update
  --     Service Request API for validating event parameters and raising
  --     the Workflow business events . Subscriptions to these business events
  --     will in turn launch the old seeded workflows, client custom workflows,
  --     as well as the new auto-notification and update workflows.
  --     We are also able to execute Non BES client workflows , to maintain
  --     backward compatibility.
  --
   --  Modification History:
  --
  --  Date        Name       Desc
  --  ----------  ---------  ---------------------------------------------
  --  04/29/04    RMANABAT   Fix for bug 3628552. Replaced contact name
  --			     separator with ';' .
  --  06/09/04    RMANABAT   Fix for bug 3663881. Changed #FROM_ROLE to SENDER_ROLE
  --			     obtained from profile default resource.
  --  20-Jul-2005 aneemuch   Release 12.0 changes. Following change made
  --                         1. Changed Raise_ServiceRequest_Event to
  --                            raise contacts BES only when party role
  --                            code is 'CONTACT'
  --                         2. To raise associated party added BES
  --                            when associated party contact added
  -- 31-Oct-2005 aneemuch    Fixed FP bug 4007088.
  -- 06-Mar-2006 spusegao    Modified to use value from l_administrator variable to set the an item attribute.
  --                         WF_ADMINISTRATOR. Earlier the value from l_initiator_role was used. (Bug # 5080255)
  -- 12-Mar-2007 PadmanabhaRao Modified the Cursor l_sel_party_name_csr as per perf bug 5730498.
  -- 12-Jun-2007 BKANIMOZ    Bug fix for 6069111.Added a Cursor get_status_id_csr.
  -- 29-APR-2009 VPREMACH    Bug 7580964. Notification rules should not be checked when raising the status changed event.
  *************************************************************************/

  PROCEDURE Raise_ServiceRequest_Event(
        p_api_version            IN    NUMBER,
        p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
        p_validation_level       IN    NUMBER   DEFAULT fnd_api.g_valid_level_full,
        p_Event_Code            IN VARCHAR2,
        p_Incident_Number       IN VARCHAR2,
        p_USER_ID               IN NUMBER  DEFAULT FND_GLOBAL.USER_ID, -- p_last_updated_by from Update_ServiceREquest()
        p_RESP_ID               IN NUMBER,      -- p_resp_id from Update_ServiceREquest()
        p_RESP_APPL_ID          IN NUMBER,      -- p_resp_appl_id from Update_ServiceREquest()
        p_Old_SR_Rec            IN CS_ServiceRequest_PVT.service_request_rec_type,
        p_New_SR_Rec            IN CS_ServiceRequest_PVT.service_request_rec_type,
        p_Contacts_Table        IN CS_ServiceRequest_PVT.contacts_table,
        p_Link_Rec              IN CS_INCIDENTLINKS_PVT.CS_INCIDENT_LINK_REC_TYPE,
        p_wf_process_id         IN NUMBER, -- from Update_ServiceRequest() parameter list, important
					   -- to pass this to prevent unwanted recursive calls
	p_owner_id		IN NUMBER, -- passed by CIC
	p_wf_manual_launch	IN VARCHAR2 , -- flag for event raised from UI launch_wf().
					      -- p_Event_Code for manually launched workflow
					      -- should always be UPDATE_SERVICE_REQUEST
        x_wf_process_id         OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2) IS

    l_dummy             	VARCHAR2(240);
    l_initiator_role    	VARCHAR2(100);

    l_param_list		wf_parameter_list_t;
    l_event_key			VARCHAR2(240);
    l_event_id     		NUMBER;
    --l_request_status		VARCHAR2(30);
    l_linked_incident_number	VARCHAR2(64);
    l_old_request_status	VARCHAR2(64);
    l_business_event		VARCHAR2(240);
    l_contact_index		BINARY_INTEGER;
    l_new_contact_point_name	VARCHAR2(2000);
    l_new_contact_point_id	VARCHAR2(2000);

    l_new_associated_party_name	VARCHAR2(2000);
    l_new_associated_party_id	VARCHAR2(2000);

    l_contact_name		VARCHAR2(360);
    l_contact_party_id		NUMBER;
    l_administrator		VARCHAR2(100);
    --l_close_flag		VARCHAR2(1);
    l_raise_old_wf_flag		VARCHAR2(1);
    --l_msg_index_OUT		NUMBER;


    --l_service_request_rec  CS_ServiceRequest_PVT.service_request_rec_type;
    l_notes		CS_SERVICEREQUEST_PVT.notes_table;
    l_contacts		CS_SERVICEREQUEST_PVT.contacts_table;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_interaction_id    number;
    out_wf_process_id   NUMBER;

    l_link_type_name	VARCHAR2(240);

    l_itemkey           VARCHAR2(240);
    l_pos               NUMBER;

    l_resource_id       NUMBER;
    l_role_display_name VARCHAR2(360);
    l_role_name         VARCHAR2(320);

    l_INVALID_EVENT_ARGS		EXCEPTION;
    l_INVALID_EVENT_CODE		EXCEPTION;
    l_API_ERROR				EXCEPTION;


    /* Roopa - begin
       Fix for bug 2788761
       A SR contact can also be an employee which means
       that we will have to check on per_people_f table also.
       Formed a union because of this reason.
    */
	--Padmanabha Rao  Modified the cursor for bug 5730498.
    CURSOR l_sel_party_name_csr IS
	 SELECT P.PARTY_NAME
	 FROM HZ_PARTIES P,
	 CS_HZ_SR_CONTACT_POINTS C
	 WHERE P.PARTY_ID = l_contact_party_id AND C.CONTACT_TYPE <> 'EMPLOYEE' AND C.PARTY_ID= P.PARTY_ID
	 UNION
	 SELECT P.FULL_NAME
	 FROM PER_ALL_PEOPLE_F P
	 WHERE P.PERSON_ID = l_contact_party_id AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(P.EFFECTIVE_START_DATE, SYSDATE))
	 AND TRUNC(NVL(P.EFFECTIVE_END_DATE, SYSDATE))
	 AND EXISTS (SELECT 1
	 FROM CS_HZ_SR_CONTACT_POINTS C
	 WHERE C.CONTACT_TYPE = 'EMPLOYEE'
	 AND C.PARTY_ID = P.PERSON_ID) ;

	--Padmanabha Rao  commented below cursor for bug 5730498.
	/*
	CURSOR l_sel_party_name_csr IS
       SELECT p.PARTY_NAME
       FROM HZ_PARTIES p, cs_hz_sr_contact_points c
       WHERE p.PARTY_ID = c.party_id and
             c.contact_type <> 'EMPLOYEE' and c.party_id=l_contact_party_id
       UNION
       select p.full_name
       from per_all_people_f p, cs_hz_sr_contact_points c
       where p.person_id = c.party_id
       and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(p.effective_start_date, SYSDATE))
       and TRUNC(NVL(p.effective_end_date, SYSDATE))
       and c.contact_type = 'EMPLOYEE' and c.party_id=l_contact_party_id;
	 */

    /*
      Roopa - end
      Fix for bug 2788761
    */

    CURSOR l_sel_request_csr IS
        SELECT nvl(status.close_flag,'N') close_flag,
		inc.workflow_process_id,
		cit.AUTOLAUNCH_WORKFLOW_FLAG,
		cit.WORKFLOW,
		inc.resource_type,
		inc.incident_owner_id,
		inc.incident_id,
		inc.object_version_number
        FROM   cs_incident_statuses status,
		cs_incidents_all_b inc,
		cs_incident_types cit
        WHERE  inc.incident_number = p_Incident_Number
               AND inc.incident_status_id = status.incident_status_id
	       and cit.incident_type_id = inc.incident_type_id;

    l_sel_request_rec	l_sel_request_csr%ROWTYPE;


    /*
        02/07/2003
        Roopa - fix for bug # 2788610
        The PREV_OWNER_ID wf attribute value should be
        the source_id from jtf_rs_resource_extns table
        and NOT incident_owner_id.
        CS_WORKFLOW_PUB.Get_Employee_Role() procedure was failing because of this discripency
    */

    CURSOR l_cs_sr_get_empid_csr(p_resource_id IN NUMBER) IS
      select emp.source_id , emp.resource_name
      from jtf_rs_resource_extns_vl emp
      where emp.resource_id = p_resource_id;
    l_cs_sr_get_empid_rec       l_cs_sr_get_empid_csr%ROWTYPE;
    l_prev_employee_id NUMBER;

    /**
     This fixes the scenario :
     An Auto-launch workflow was executed, and later aborted.
     When the workflow is launched again using the UI
     tools menu, the UI does a commit which makes another call
     to the update_servicerequest() api. This prevents another
     seeded workflow from launching by looking if one is already
     running.
    **/

    CURSOR l_servereq_csr IS
      SELECT end_date,item_key
      FROM   wf_items
      WHERE  item_type = 'SERVEREQ'
      AND    item_key  like p_Incident_Number||'-%'
      AND    item_key NOT like p_Incident_Number||'%EVT'
      AND end_date IS NULL;

    l_end_date  DATE;

    CURSOR l_sel_adhocrole_csr(c_role_name IN VARCHAR2) IS
      SELECT display_name,expiration_date
      FROM wf_local_roles
      WHERE name = c_role_name;
    l_sel_adhocrole_rec l_sel_adhocrole_csr%ROWTYPE;


   -- 5238921
   CURSOR c_party_role_csr (p_party_role_code in VARCHAR2) IS
      SELECT name
        FROM cs_party_roles_vl
       WHERE party_role_code = p_party_role_code;

    l_new_party_role_name	VARCHAR2(2000);
    l_temp_new_party_role_name	VARCHAR2(100);
   -- 5238921_eof

 --Bug Fix for 6069111.Added by bkanimoz on 12-Jun-2007
     l_status_id NUMBER; --Bug 5948714

   CURSOR  get_status_id_csr IS
   SELECT  csat.INCIDENT_STATUS_ID
	--INTO    l_status_id
	FROM    CS_SR_ACTION_TRIGGERS csat,
		CS_SR_ACTION_DETAILS csad,
		CS_SR_EVENT_CODES_B cec
        WHERE
		  cec.WF_BUSINESS_EVENT_ID = 'oracle.apps.cs.sr.ServiceRequest.statuschanged'
		  and csat.EVENT_CODE = cec.EVENT_CODE
		  and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
		  and TRUNC(NVL(csat.end_date_active, SYSDATE))
		  and csad.event_condition_id = csat.event_condition_id
		  and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
		  and TRUNC(NVL(csad.end_date_active, SYSDATE))
	          and csat.from_to_status_code IS not NULL
	          and csad.resolution_code IS  NULL
		  and csat.incident_status_id IS NOT NULL
		  and csat.incident_status_id = (select incident_status_id from cs_incidents_all_b
						   where incident_number = p_incident_number)
		  and csad.action_code like 'NOTIFY%';




  BEGIN


    --dbms_output.put_line('Start of  Raise_ServiceRequest_Event');

    -- Initialize return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 --INSERT INTO rm_tmp values (p_Incident_Number, 'In Start of BES wrapper ',rm_tmp_seq.nextval);

    IF ( p_Incident_Number IS NULL) THEN

      RAISE l_INVALID_EVENT_ARGS;

    ELSIF (p_wf_process_id IS NOT NULL) THEN
      --Do NOTHING. WE DON't HAVE TO RAISE a business event since this
      --is just a recursive call to Update_ServiceRequest() API to update
      --the workflow process id when a workflow is launched.
	null;
 --INSERT INTO rm_tmp values (p_Incident_Number, 'In BES wrapper,p_wf_process_id IS NOT NULL ',rm_tmp_seq.nextval);

    ELSE

 --INSERT INTO rm_tmp values (p_Incident_Number, 'In BES wrapper,p_wf_process_id IS NULL ',rm_tmp_seq.nextval);

      --  Derive Role from User ID
      IF (p_USER_ID IS NOT NULL) THEN
        CS_WF_AUTO_NTFY_UPDATE_PKG.get_fnd_user_role
             ( p_fnd_user_id        => p_USER_ID,
               x_role_name          => l_initiator_role,
               x_role_display_name  => l_dummy );
      END IF;


      /******************************************************************
        This section sets the Event Parameter List. These parameters are
        converted to workflow item attributes.
      *******************************************************************/

      wf_event.AddParameterToList(p_name => 'REQUEST_NUMBER',
    			      p_value => p_Incident_Number,
    			      p_parameterlist => l_param_list);

/* Roopa - Begin - Fix for bug 3360069 */
/* Initializing the  vars with FND_GLOBAL values if the input vars are null in value */
      IF(p_USER_ID is NULL or p_USER_ID = -1) THEN
      wf_event.AddParameterToList(p_name => 'USER_ID',
    			      p_value => FND_GLOBAL.USER_ID,
    			      p_parameterlist => l_param_list);
      ELSE
      wf_event.AddParameterToList(p_name => 'USER_ID',
    			      p_value => p_USER_ID,
    			      p_parameterlist => l_param_list);

      END IF;

      IF(p_RESP_ID is NULL or p_RESP_ID = -1) THEN
      wf_event.AddParameterToList(p_name => 'RESP_ID',
    			      p_value => FND_GLOBAL.RESP_ID,
    			      p_parameterlist => l_param_list);
      ELSE
      wf_event.AddParameterToList(p_name => 'RESP_ID',
			      p_value => p_RESP_ID,
			      p_parameterlist => l_param_list);
      END IF;

      IF(p_RESP_APPL_ID is NULL or p_RESP_APPL_ID = -1) THEN
      wf_event.AddParameterToList(p_name => 'RESP_APPL_ID',
    			      p_value => FND_GLOBAL.RESP_APPL_ID,
    			      p_parameterlist => l_param_list);
      ELSE
      wf_event.AddParameterToList(p_name => 'RESP_APPL_ID',
			      p_value => p_RESP_APPL_ID,
			      p_parameterlist => l_param_list);
      END IF;
/* Roopa - End - Fix for bug 3360069 */

      wf_event.AddParameterToList(p_name => 'INITIATOR_ROLE',
			      p_value => l_initiator_role,
			      p_parameterlist => l_param_list);

      -- We need this parameter since manual launch will also unnecessarily launch the
      -- auto-notify workflow. Validation not to process will have to be done in the
      -- activity of the workflow itself.
      wf_event.AddParameterToList(p_name => 'MANUAL_LAUNCH',
			      p_value => p_wf_manual_launch,
			      p_parameterlist => l_param_list);


      l_resource_id :=  NVL(FND_PROFILE.VALUE('CS_SR_DEFAULT_SYSTEM_RESOURCE'), -1);
      OPEN l_cs_sr_get_empid_csr(l_resource_id);
      FETCH l_cs_sr_get_empid_csr INTO l_cs_sr_get_empid_rec;

      l_role_name := 'CS_WF_ROLE_DUMMY';
      OPEN l_sel_adhocrole_csr(l_role_name);
      FETCH l_sel_adhocrole_csr INTO l_sel_adhocrole_rec;

      IF (l_sel_adhocrole_csr%FOUND) THEN

	-- expired adhoc role, renew expiration date.
        IF (nvl(l_sel_adhocrole_rec.EXPIRATION_DATE, SYSDATE) < sysdate) THEN
          wf_directory.SetAdHocRoleExpiration(role_name         => l_role_name,
                                              expiration_date   => sysdate + 365);
        END IF;

	-- chnage display name if needed.
        IF (l_sel_adhocrole_rec.display_name <> l_cs_sr_get_empid_rec.resource_name) THEN
          l_role_display_name := l_cs_sr_get_empid_rec.resource_name;
          wf_directory.SetAdHocRoleAttr(role_name       => l_role_name,
                                        display_name    => l_role_display_name);
        END IF;

      ELSE

        wf_directory.CreateAdHocRole(role_name          => l_role_name,
                                     role_display_name  => l_role_display_name,
                                     expiration_date    => sysdate + 365);

        l_role_display_name := l_cs_sr_get_empid_rec.resource_name;

        wf_directory.SetAdHocRoleAttr(role_name         => l_role_name,
                                      display_name      => l_role_display_name);
      END IF;

      IF l_sel_adhocrole_csr%ISOPEN THEN
        CLOSE l_sel_adhocrole_csr;
      END IF;
      IF l_cs_sr_get_empid_csr%ISOPEN THEN
        CLOSE l_cs_sr_get_empid_csr;
      END IF;

      wf_event.AddParameterToList(p_name        => 'SENDER_ROLE',
                                  p_value       => l_role_name,
                                  p_parameterlist=> l_param_list);


      --dbms_output.put_line('Setting CS_WF_ADMINISTRATOR');

      BEGIN
        l_administrator := FND_PROFILE.VALUE('CS_WF_ADMINISTRATOR');

        wf_event.AddParameterToList(p_name => 'WF_ADMINISTRATOR',
			        p_value => l_administrator,
			        p_parameterlist => l_param_list);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END;

      -- Setting SR Status Changed attribute
      IF (p_Old_SR_Rec.STATUS_ID <> p_New_SR_Rec.STATUS_ID) THEN

        SELECT name
	INTO l_old_request_status
	FROM cs_incident_statuses_vl
	WHERE INCIDENT_STATUS_ID = p_Old_SR_Rec.STATUS_ID;

        wf_event.AddParameterToList(p_name => 'REQUEST_STATUS_OLD',
    			      p_value => l_old_request_status,
    			      p_parameterlist => l_param_list);
      END IF;


      -- Setting SR Reassigned attribute

      /* Roopa - begin
          Fix for bug 2799545 - Changed the IF condition to include
          null owner to not null owner
          not null owner to null owner
      */

      IF (p_Old_SR_Rec.OWNER_ID <> p_New_SR_Rec.OWNER_ID OR
         (p_Old_SR_Rec.OWNER_ID is null and p_New_SR_Rec.OWNER_ID is not null) OR
         (p_New_SR_Rec.OWNER_ID is null and p_Old_SR_Rec.OWNER_ID is not null)) THEN

      /* Roopa - end
          Fix for bug 2799545
      */

        /* Roopa - begin
           Fix for bug # 2788610
        */
        OPEN l_cs_sr_get_empid_csr(p_Old_SR_Rec.OWNER_ID);
    	FETCH l_cs_sr_get_empid_csr INTO l_cs_sr_get_empid_rec;
        IF (l_cs_sr_get_empid_csr%FOUND) THEN
          wf_event.AddParameterToList(p_name => 'PREV_OWNER_ID',
				      p_value => l_cs_sr_get_empid_rec.source_id,
				      p_parameterlist => l_param_list);
        ELSE
          wf_event.AddParameterToList(p_name => 'PREV_OWNER_ID',
			      	      p_value => p_Old_SR_Rec.OWNER_ID,
				      p_parameterlist => l_param_list);
        END IF;
        CLOSE   l_cs_sr_get_empid_csr;
      /* Roopa - end
           Fix for bug # 2788610
      */

      END IF;

      --dbms_output.put_line('Setting NTFY_LINK_TYPE ');

      -- Setting Link Created/Deleted attribute
      IF (p_Link_Rec.LINK_TYPE_ID IS NOT NULL) THEN

        SELECT name
	INTO l_link_type_name
        FROM CS_SR_LINK_TYPES_VL
        WHERE link_type_id = p_Link_Rec.LINK_TYPE_ID;

        wf_event.AddParameterToList(p_name => 'NTFY_LINK_TYPE',
			      p_value => l_link_type_name,
			      p_parameterlist => l_param_list);
      END IF;


      /*******************************************************
       Important Note:
         Links treats the queried SR in the UI as the SUBJECT and
         the linked SR as the object. In our workflow logic, it is
         the opposite. So we have to reverse this assignment. In
         this case, p_Incident_Number is the subject number.
      ********************************************************/

      IF (p_Link_Rec.OBJECT_NUMBER IS NOT NULL) THEN

        wf_event.AddParameterToList(p_name => 'NTFY_LINKED_INCIDENT_NUMBER',
			      p_value => p_Link_Rec.OBJECT_NUMBER,
			      p_parameterlist => l_param_list);
      END IF;


      /******************************************************
       Setting New Contacts Added attributes.
       We build a list of new contact names to be used for the
       notification message, and a list of new contact point
       IDs to be used for recipients of the ntfxn. In the future,
       the contact point names might be queried in the PL/SQL
       document attribute of the message, instead of putting it
       in a single line of text.
      *****************************************************/

      l_contact_index := p_Contacts_Table.FIRST;

      WHILE l_contact_index IS NOT NULL LOOP

        IF (p_Contacts_Table(l_contact_index).SR_CONTACT_POINT_ID IS NULL OR
            p_Contacts_Table(l_contact_index).SR_CONTACT_POINT_ID = FND_API.G_MISS_NUM ) THEN -- new contact

	  l_contact_party_id := p_Contacts_Table(l_contact_index).PARTY_ID;
	  OPEN l_sel_party_name_csr;
	  FETCH l_sel_party_name_csr INTO l_contact_name;

	  IF (l_sel_party_name_csr%FOUND AND l_contact_name IS NOT NULL )THEN

            IF (p_Contacts_table(l_contact_index).party_role_code = 'CONTACT' OR
                p_Contacts_table(l_contact_index).party_role_code = FND_API.G_MISS_CHAR OR
		p_Contacts_table(l_contact_index).party_role_code IS NULL  ) THEN

            -- Check for l_new_contact_point_name list length not to exceed 2000 .
              IF (nvl(LENGTH(l_new_contact_point_name),0) + nvl(LENGTH(l_contact_name),0) + 1) <= 2000 THEN
	         IF (l_new_contact_point_name IS NULL) THEN

                    l_new_contact_point_name := l_contact_name;

                    /************************************
		     Roopa - begin
        	     Fix for bug 2788761
                     contact_point_id will be hz_contact point id for contact type != employee
                     contact_point_id will be per_all_people_f person id for contact type = employee
                     since contact point id will be null for this contact type
		    *************************************/

                    IF(p_Contacts_Table(l_contact_index).CONTACT_TYPE <> 'EMPLOYEE') THEN
        	       l_new_contact_point_id := TO_CHAR(p_Contacts_Table(l_contact_index).contact_point_id);
                    ELSE
                       l_new_contact_point_id := TO_CHAR(l_contact_party_id);
                    END IF;

	         ELSE

	            l_new_contact_point_name := l_new_contact_point_name || ';' || l_contact_name;
                    IF(p_Contacts_Table(l_contact_index).CONTACT_TYPE <> 'EMPLOYEE') THEN
            	       l_new_contact_point_id := l_new_contact_point_id || ' '
                                         || TO_CHAR(p_Contacts_Table(l_contact_index).contact_point_id);
                    ELSE
                       l_new_contact_point_id := l_new_contact_point_id || ' ' || TO_CHAR(l_contact_party_id);
                    END IF;

	         END IF;
              ELSE
	         EXIT;
	      END IF;
            ELSE
               IF (nvl(LENGTH(l_new_associated_party_name),0) + nvl(LENGTH(l_contact_name),0) + 1) <= 2000 THEN
                   IF (l_new_associated_party_name IS NULL) THEN
                      l_new_associated_party_name := l_contact_name;
                      l_new_associated_party_id := TO_CHAR(p_Contacts_Table(l_contact_index).contact_point_id);
                   ELSE
                      l_new_associated_party_name := l_new_associated_party_name || ';' || l_contact_name;
                      l_new_associated_party_id := l_new_associated_party_id || ' ' ||
                                          TO_CHAR(p_Contacts_Table(l_contact_index).contact_point_id);
                   END IF;

                   -- 5238921
                   Open c_party_role_csr(p_Contacts_Table(l_contact_index).party_role_code);
                   Fetch c_party_role_csr Into l_temp_new_party_role_name;
                   Close c_party_role_csr;

                   IF l_new_party_role_name is null Then
                      l_new_party_role_name := l_temp_new_party_role_name;
                   ELSE
                     l_new_party_role_name := l_new_party_role_name ||';'||l_temp_new_party_role_name;
                   END IF;
                   -- 5238921_eof

                ELSE
                   EXIT;
                END IF;
            END IF; -- party_role_code = 'CONTACTS'

	  END IF; -- (l_sel_party_name_csr%FOUND AND l_contact_name IS NOT NULL )
	  CLOSE l_sel_party_name_csr;

        END IF;		-- IF (p_Contacts_Table(l_contact_index).SR ...
        l_contact_index := p_Contacts_Table.NEXT(l_contact_index);

      END LOOP;

      IF (l_new_contact_point_name IS NOT NULL) THEN
        wf_event.AddParameterToList(p_name => 'NEW_CONTACT_POINT_NAME',
                              p_value => l_new_contact_point_name,
                              p_parameterlist => l_param_list);
        wf_event.AddParameterToList(p_name => 'NEW_CONTACT_POINT_ID_LIST',
                              p_value => l_new_contact_point_id,
                              p_parameterlist => l_param_list);
      END IF;

      IF (l_new_associated_party_name IS NOT NULL) THEN
        wf_event.AddParameterToList(p_name => 'NEW_ASSOCIATED_PARTY_NAME',
                              p_value => l_new_associated_party_name,
                              p_parameterlist => l_param_list);
        wf_event.AddParameterToList(p_name => 'NEW_ASSOCIATED_PARTY_ID_LIST',
                              p_value => l_new_associated_party_id,
                              p_parameterlist => l_param_list);

        -- 523892
         wf_event.AddParameterToList(p_name => 'NEW_PARTY_ROLE_NAME',
                              p_value => l_new_party_role_name,
                              p_parameterlist => l_param_list);

        -- 5238921_eof
      END IF;



      /**********************************************************
        This section establishes the WF business events to raise.
      ***********************************************************/

      IF (p_Event_Code = 'UPDATE_SERVICE_REQUEST') THEN

        /* Roopa - begin
          Fix for bug # 2809232
        */
        wf_event.AddParameterToList(p_name => 'PREV_TYPE_ID',
			      p_value => p_Old_SR_Rec.type_id,
			      p_parameterlist => l_param_list);

        wf_event.AddParameterToList(p_name => 'PREV_SEVERITY_ID',
			      p_value => p_Old_SR_Rec.severity_id,
			      p_parameterlist => l_param_list);

        wf_event.AddParameterToList(p_name => 'PREV_STATUS_ID',
			      p_value => p_Old_SR_Rec.status_id,
			      p_parameterlist => l_param_list);

        wf_event.AddParameterToList(p_name => 'PREV_URGENCY_ID',
			      p_value => p_Old_SR_Rec.urgency_id,
			      p_parameterlist => l_param_list);

        wf_event.AddParameterToList(p_name => 'PREV_SUMMARY',
			      p_value => p_Old_SR_Rec.summary,
			      p_parameterlist => l_param_list);

        /* Roopa - end
          Fix for bug # 2809232
        */

        -- Aside from raising the Update business event, we may have to raise
        -- other business events, i.e., Reassign, StatusUpdate. etc. This
        -- depends on what Service Request attributes was updated.

        -- Check for Status Update event.
        IF (p_Old_SR_Rec.STATUS_ID <> p_New_SR_Rec.STATUS_ID) THEN

          SELECT cs_wf_process_id_s.nextval
          INTO l_event_id
          FROM dual;
          -- Construct the unique event key
          l_event_key := p_Incident_Number ||'-'||to_char(l_event_id) || '-EVT';
--Commented the below code for bug 7580964
--  Bug fix for 6069111.Added by bkanimoz on 12-Jun-2007

	/*  OPEN get_status_id_csr;
	  LOOP
	    FETCH get_status_id_csr INTO l_status_id;
	    EXIT WHEN get_status_id_csr%NOTFOUND;
               IF ( p_New_SR_Rec.STATUS_ID =l_status_id ) THEN*/
               BEGIN
               --RAISE the WF Business event.
		 wf_event.raise(p_event_name => 'oracle.apps.cs.sr.ServiceRequest.statuschanged',
				p_event_key  => l_event_key,
				p_parameters => l_param_list);
               EXCEPTION  -- Added the exception for bug 8849523
	          WHEN OTHERS THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END;

		  /* Roopa - begin
		      Fix for bug 2798269
		  */
		  -- Standard check of p_commit
			  IF FND_API.To_Boolean(p_commit) THEN
			    COMMIT WORK;
			  END IF;
/*               END IF;
         END LOOP;
         CLOSE get_status_id_csr;*/
	  --  commit;

        END IF;

        /************************************
         Roopa - begin
           Fix for bug 2799545 - Changed the IF condition to include
           null owner to not null owner
           not null owner to null owner
        **************************************/

        -- Check for SR reassigned event.
        IF (p_Old_SR_Rec.OWNER_ID <> p_New_SR_Rec.OWNER_ID OR
            (p_Old_SR_Rec.OWNER_ID is null and p_New_SR_Rec.OWNER_ID is not null) OR
            (p_New_SR_Rec.OWNER_ID is null and p_Old_SR_Rec.OWNER_ID is not null)) THEN

        /* Roopa - end
           Fix for bug 2799545
        */

          SELECT cs_wf_process_id_s.nextval
          INTO l_event_id
          FROM dual;
          -- Construct the unique event key
          l_event_key := p_Incident_Number ||'-'||to_char(l_event_id) || '-EVT';

          --RAISE the WF Business event.
          wf_event.raise(p_event_name => 'oracle.apps.cs.sr.ServiceRequest.reassigned',
                         p_event_key  => l_event_key,
                         p_parameters => l_param_list);

          /* Roopa - begin
              Fix for bug 2798269
          */
          -- Standard check of p_commit
          IF FND_API.To_Boolean(p_commit) THEN
            COMMIT WORK;
          END IF;
          --  commit;

        END IF;

        /***********************************************
         Roopa - begin
           Fix for bug 2793681 - ADD_NEW_CONTACT_TO_SR is never passed as an event
           from the SR api we need to interpret the update condition and raise this
           event accordingly. inserting the following if .
           Roopa - end
        ***********************************************/

   	IF (l_new_contact_point_name IS NOT NULL) THEN

          SELECT cs_wf_process_id_s.nextval
          INTO l_event_id
          FROM dual;
          -- Construct the unique event key
          l_event_key := p_Incident_Number ||'-'||to_char(l_event_id) || '-EVT';

          --RAISE the WF Business event.
          wf_event.raise(p_event_name => 'oracle.apps.cs.sr.ServiceRequest.newcontactadded',
                         p_event_key  => l_event_key,
                         p_parameters => l_param_list);

        END IF;

-- To raise Associated Party Contact added business event
--
        IF (l_new_associated_party_name IS NOT NULL) THEN

          SELECT cs_wf_process_id_s.nextval
          INTO l_event_id
          FROM dual;
          -- Construct the unique event key
          l_event_key := p_Incident_Number ||'-'||to_char(l_event_id) || '-EVT';

          --RAISE the WF Business event.
          wf_event.raise(p_event_name => 'oracle.apps.cs.sr.ServiceRequest.associatedpartyadded',
                         p_event_key  => l_event_key,
                         p_parameters => l_param_list);

        END IF;


        l_business_event := 'oracle.apps.cs.sr.ServiceRequest.updated';


      ELSIF (p_Event_Code = 'RELATIONSHIP_CREATE_FOR_SR' ) THEN

        IF(p_Link_Rec.LINK_TYPE_ID IS NOT NULL) THEN
/* Roopa - Fix for bug 3528510 */
/* The following 2 parameters are added to the payload so that
   the business event wf will catch the non-SR -> SR link scenario
*/
        wf_event.AddParameterToList(p_name => 'LINK_SUBJECT_TYPE',
                              p_value => p_link_rec.subject_type,
                              p_parameterlist => l_param_list);
        wf_event.AddParameterToList(p_name => 'LINK_OBJECT_TYPE',
                              p_value => p_link_rec.object_type,
                              p_parameterlist => l_param_list);
          l_business_event :=  'oracle.apps.cs.sr.ServiceRequest.relationshipcreated';
    	ELSE
	     RAISE l_INVALID_EVENT_ARGS;
	END IF;

      ELSIF (p_Event_Code = 'RELATIONSHIP_DELETE_FOR_SR') THEN

    	IF (p_Link_Rec.LINK_TYPE_ID IS NOT NULL) THEN
/* Roopa - Fix for bug 3528510 */
/* The following 2 parameters are added to the payload so that
   the business event wf will catch the non-SR -> SR link scenario
*/
        wf_event.AddParameterToList(p_name => 'LINK_SUBJECT_TYPE',
                              p_value => p_link_rec.subject_type,
                              p_parameterlist => l_param_list);
        wf_event.AddParameterToList(p_name => 'LINK_OBJECT_TYPE',
                              p_value => p_link_rec.object_type,
                              p_parameterlist => l_param_list);
              l_business_event := 'oracle.apps.cs.sr.ServiceRequest.relationshipdeleted';
    	ELSE
	     RAISE l_INVALID_EVENT_ARGS;
    	END IF;

      /* Roopa - begin
         Fix for bug 2793681 - ADD_NEW_CONTACT_TO_SR is never passed as an event from the SR api
                          we need to interpret the update condition and raise this
                          event accordingly. Commenting out the following elsif
      Roopa - end*/

      --  ELSIF (p_Event_Code = 'ADD_NEW_CONTACT_TO_SR') THEN
      --    IF (l_new_contact_point_name IS NOT NULL) THEN
      --              l_business_event :=  'oracle.apps.cs.sr.ServiceRequest.newcontactadded';
      --	  ELSE
      --	     RAISE l_INVALID_EVENT_ARGS;
      --	  END IF;

      ELSIF (p_Event_Code = 'CREATE_SERVICE_REQUEST') THEN

        l_business_event :=  'oracle.apps.cs.sr.ServiceRequest.created';

      ELSE

        RAISE l_INVALID_EVENT_CODE;

      END IF;

      SELECT cs_wf_process_id_s.nextval
      INTO l_event_id
      FROM dual;

      -- Construct the unique event key
      l_event_key := p_Incident_Number ||'-'||to_char(l_event_id) || '-EVT';


      --dbms_output.put_line('Raising the Workflow business : ' || l_business_event);

 --INSERT INTO rm_tmp values (p_Incident_Number, 'Raising WF from event code ',rm_tmp_seq.nextval);
 --INSERT INTO rm_tmp values (p_Incident_Number, 'l_business_event='||l_business_event||' ,l_event_key= '|| l_event_key ,rm_tmp_seq.nextval);


      wf_event.raise(p_event_name => l_business_event,
                     p_event_key  => l_event_key,
                     p_parameters => l_param_list);

      l_param_list.DELETE;


      /* Roopa - begin
          Fix for bug 2798269
      */
      -- Standard check of p_commit
      IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
      END IF;
      --      commit;


      /***************************************************************
        This section is for backward compatibility. This will enable
        client custom workflows which are not BES compatible, to be
	executed by using the old Workflow APIs to launch the workflow
	processes, i.e., CreateProcess() , StartProcess().
        All the old seeded workflows will be converted to BES and
        will be shipped out with release 11.5.9  .
      **************************************************************/


      IF (p_Event_Code = 'CREATE_SERVICE_REQUEST' OR p_Event_Code = 'UPDATE_SERVICE_REQUEST') THEN

	OPEN l_sel_request_csr;
	FETCH l_sel_request_csr INTO l_sel_request_rec;

        IF (l_sel_request_csr%FOUND) THEN

          -- Check if the seeded workflow or client custom workflow process was
	  -- launched via WF business event. It the process was launched, then
	  -- update SR table with the workflow process ID used in the event.
          -- If not (workflow process may not be BES converted), try to launch
	  -- the workflow using the old workflow APIs.



          OPEN l_servereq_csr;
          FETCH l_servereq_csr
          INTO l_end_date,l_itemkey;

          IF (l_servereq_csr%FOUND) THEN

          /*********
          IF (CS_Workflow_PKG.Is_Servereq_Item_Active
                         (p_request_number  => p_Incident_Number,
                          p_wf_process_id   => l_event_id)  = 'Y') THEN
          ********/

            /* Roopa - 01/24/03
              It was decided that Update_ServiceRequest API need not be called
              just to update the workflow process id of the SR that too with full validation on.
              An explicit update should suffice. Hence commenting out the following code and
              replacing it with an explicit update statement
            */
            l_pos := INSTR(l_itemkey, '-',-1,1); -- Bug#4007088
            x_wf_process_id := SUBSTR(l_itemkey, l_pos+1);

 --INSERT INTO rm_tmp values (p_Incident_Number, 'Update event raised successfuly,updating table.x_wf_process_id= '||x_wf_process_id||' l_itemkey='||l_itemkey,rm_tmp_seq.nextval);

            --UPDATE CS_INCIDENTS_ALL_B set WORKFLOW_PROCESS_ID = l_event_id
            UPDATE CS_INCIDENTS_ALL_B set WORKFLOW_PROCESS_ID = x_wf_process_id
            WHERE INCIDENT_ID = l_sel_request_rec.incident_id;

            /* Roopa - begin
              Fix for bug 2798269
            */
            -- Standard check of p_commit
            IF FND_API.To_Boolean(p_commit) THEN
              COMMIT WORK;
            END IF;
            --  commit;
	    --x_wf_process_id := l_event_id;

          /**********
           Seeded or custom client Workflow was NOT launched via business event.
           Therefore, try to launch using old WF api call.
          ***********/
          ELSIF (l_sel_request_rec.workflow IS NOT NULL) THEN

 --INSERT INTO rm_tmp values (p_Incident_Number, 'Update event NOT raised successfuly, try launching old way. ',rm_tmp_seq.nextval);

            IF (l_sel_request_rec.AUTOLAUNCH_WORKFLOW_FLAG = 'Y') AND
               (( l_sel_request_rec.resource_type = 'RS_EMPLOYEE' AND
	        -- Also need to check the owner_id being passed by CIC in order to launch
	        -- their workflow.
                l_sel_request_rec.incident_owner_id IS NOT NULL) OR
		l_sel_request_rec.workflow = 'CSEADUP')   THEN --changed for bug 7484364
	       -- l_sel_request_rec.workflow <> 'CSEADUP') THEN   --Added this for bug 6974942

	      IF(p_Event_Code='CREATE_SERVICE_REQUEST') THEN

  	        l_raise_old_wf_flag := 'Y';

              -- Need this extra check for Update event.

              ELSIF(CS_Workflow_PKG.Is_Servereq_Item_Active
                          (p_request_number  => p_Incident_Number,
                           p_wf_process_id   => l_sel_request_rec.workflow_process_id )  = 'N'
                    AND l_sel_request_rec.close_flag <> 'Y') THEN

                l_raise_old_wf_flag := 'Y';

              END IF;

            -- Workflow launched manually via UI's Tools Menu.
	    ELSIF (
		   -- AUTOLAUNCH_WORKFLOW_FLAG should no be checked here since you can
		   -- manually launch a workflow with AUTOLAUNCH ON , i.e., when a workflow
		   -- is aborted and restarted in the UI Tools menu.
		   --l_sel_request_rec.AUTOLAUNCH_WORKFLOW_FLAG <> 'Y' AND
	           l_sel_request_rec.resource_type = 'RS_EMPLOYEE' AND
	           l_sel_request_rec.incident_owner_id IS NOT NULL
		   -- rmanabat 01/06/03
		   AND p_wf_manual_launch = 'Y' AND
		   CS_Workflow_PKG.Is_Servereq_Item_Active
                          (p_request_number  => p_Incident_Number,
                           p_wf_process_id   => l_sel_request_rec.workflow_process_id )  = 'N'
                   AND l_sel_request_rec.close_flag <> 'Y') THEN

              l_raise_old_wf_flag := 'Y';

            END IF;

            IF (l_raise_old_wf_flag = 'Y') THEN

	    -- We will have to launch the workflow using the old wf API
	    -- calls, i.e. , CreateProcess(), StartProcess() via Start_Servereq_Workflow().

 --INSERT INTO rm_tmp values (p_Incident_Number, 'launching WF, calling old way. ',rm_tmp_seq.nextval);

              /****************
              CS_Workflow_PKG.Start_Servereq_Workflow(
			        p_request_number	=> p_Incident_Number,
			        p_wf_process_name	=> l_sel_request_rec.workflow,
			        p_initiator_user_id	=> p_USER_ID,
			        p_initiator_resp_id	=> p_RESP_ID,
			        p_initiator_resp_appl_id=> p_RESP_APPL_ID,
				--
				-- This flag should be set to 'N' when called from the
				-- Update/Create SR api, or any other API. This is only
				-- set to 'Y' when called from the tools menu of the SR UI.
				--
				p_wf_manual_launch	=> 'N',
			        p_workflow_process_id	=> out_wf_process_id,
			        x_msg_count		=> l_msg_count,
                	        x_msg_data		=> l_msg_data);
              ***************/

              --dbms_output.put_line('Calling Launch_Servereq_Workflow ');

              CS_Workflow_PUB.Launch_Servereq_Workflow(
                    p_api_version             => 1.0,
                    p_init_msg_list           => FND_API.G_TRUE,
                    p_commit                  => p_commit,
                    p_return_status           => l_return_status,
                    p_msg_count               => l_msg_count,
                    p_msg_data                => l_msg_data,
                    p_request_number          => p_Incident_Number,
                    p_initiator_user_id       => p_USER_ID,
                    p_initiator_resp_id       => p_RESP_ID,
                    p_initiator_resp_appl_id  => p_RESP_APPL_ID,
                    p_itemkey                 => l_itemkey,
                    p_nowait                  => FND_API.G_TRUE);

              --dbms_output.put_line('Calling Launch_Servereq_Workflow,return status= '|| l_return_status);

              IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                raise FND_API.G_EXC_ERROR;
              END IF;

              l_pos := INSTR(l_itemkey, '-',-1,1); -- Bug#4007088
              x_wf_process_id := SUBSTR(l_itemkey, l_pos+1);

              --x_wf_process_id := out_wf_process_id;
              x_msg_count := l_msg_count;
              x_msg_data := l_msg_data;

               -- Show any messages returned FROM the Workflow API.
	       -- Either put this here or on the calliing SR API.

            END IF;	--  IF (l_raise_old_wf_flag = 'Y')

          END IF;	-- IF (CS_Workflow_PKG.Is_Servereq_Item_Active ...

          CLOSE l_servereq_csr;


        END IF;	-- IF (l_sel_request_csr%FOUND)

	CLOSE l_sel_request_csr;


      END IF; -- IF (p_Event_Code='CREATE_SERVICE_REQUEST' OR 'UPDATE_SERVICE_REQUEST')

      l_param_list.DELETE;

    END IF;  -- IF (Event_Code IS NULL OR Incident_Number IS NULL ...



  EXCEPTION

    WHEN l_INVALID_EVENT_ARGS THEN
      --dbms_output.put_line('Exception : WHEN l_INVALID_EVENT_ARGS ');
      --l_param_list.DELETE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( 'CS_WF_EVENT_PKG',
                                 'Raise_ServiceRequest_Event' );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => FND_API.G_FALSE );

    WHEN l_INVALID_EVENT_CODE THEN
      --dbms_output.put_line('Exception : WHEN l_INVALID_EVENT_CODE');
      --l_param_list.DELETE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( 'CS_WF_EVENT_PKG',
                                 'Raise_ServiceRequest_Event' );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => FND_API.G_FALSE );

    WHEN FND_API.G_EXC_ERROR THEN
      --dbms_output.put_line('Exception : WHEN FND_API.G_EXC_ERROR');
      --l_param_list.DELETE;
      IF (l_sel_request_csr%ISOPEN) THEN
        CLOSE l_sel_request_csr;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => FND_API.G_FALSE );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --dbms_output.put_line('Exception : WHEN FND_API.G_EXC_UNEXPECTED_ERROR');
      --l_param_list.DELETE;
      IF (l_sel_request_csr%ISOPEN) THEN
        CLOSE l_sel_request_csr;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => FND_API.G_FALSE );

    WHEN OTHERS THEN
      --dbms_output.put_line('Exception : WHEN OTHERS');
      --l_param_list.DELETE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( 'CS_WF_EVENT_PKG',
                                 'Raise_ServiceRequest_Event' );
      END IF;
      FND_MSG_PUB.Count_And_Get( p_count        => x_msg_count,
                                 p_data         => x_msg_data,
                                 p_encoded      => FND_API.G_FALSE );




  END Raise_ServiceRequest_Event;

/***************************
------------------------------------------------------------------------------
--  Procedure   : Get_Fnd_User_Role
------------------------------------------------------------------------------

PROCEDURE Get_Fnd_User_Role
  ( p_fnd_user_id       IN      NUMBER,
    x_role_name         OUT     NOCOPY VARCHAR2,
    x_role_display_name OUT     NOCOPY VARCHAR2 )
  IS
     l_employee_id      NUMBER;
BEGIN
   -- map the FND user to employee ID
  SELECT employee_id INTO l_employee_id
    FROM fnd_user
    WHERE user_id = p_fnd_user_id;

  IF (l_employee_id IS NOT NULL) THEN
     wf_directory.getrolename
       ( p_orig_system         => 'PER',
         p_orig_system_id      => l_employee_id,
         p_name                => x_role_name,
         p_display_name        => x_role_display_name );
   ELSE
     wf_directory.getrolename
       ( p_orig_system         => 'FND_USR',
         p_orig_system_id      => p_fnd_user_id,
         p_name                => x_role_name,
         p_display_name        => x_role_display_name );
  END IF;
END Get_Fnd_User_Role;
***************************/



END CS_WF_EVENT_PKG;

/
