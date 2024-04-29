--------------------------------------------------------
--  DDL for Package Body CS_WF_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WF_ACTIVITIES_PKG" AS
/* $Header: cswfactb.pls 120.3 2006/04/26 10:15:31 spusegao noship $ */


-- ***************************************************************************
-- *									     *
-- *			   GLOBAL CURSORS           			     *
-- *									     *
-- ***************************************************************************

	CURSOR fs_action_csr
			(
				p_incident_id 		number,
				p_incident_action_id 	number
			) is
	SELECT
		sr.customer_id,
		--sr.customer_name,
		sr.customer_number,
		sr.inventory_item_id,
		mtl.concatenated_segments product,
		mtl.description product_description,
		CS_STD.Get_Item_Valdn_Orgzn_Id organization_id,
		sr.reference_number,
		sr.current_serial_number,
		cp.installation_date,
		sr.incident_id,
		sr.incident_number,
		sr.incident_date,
		act.task_number,
		sr.problem_code_meaning problem_code,
		sr.resolution_code_meaning resolution_code,
		--act.text_description  problem_description,
--		act.text_resolution resolution_description,
		sr.problem_code_description sr_problem_description,
		sr.resolution_code_description sr_resolution_description,
		sr.incident_urgency_id,
		sr.urgency,
			--	decode( st.status_code ,
				--CS_WF_Activities_PKG.FS_Planned_Status , 1 ,
				--CS_WF_Activities_PKG.FS_Cancelled_Status , 2 )
		sr.incident_status_id,
				--decode( st.status_code ,
				--CS_WF_Activities_PKG.FS_Planned_Status , 'Planned' ,
				--CS_WF_Activities_PKG.FS_Cancelled_Status , 'Cancelled' )
	        st.status_code,
		sr.incident_date  status_date,
		act.task_type_id incident_type_id,
--		act.action_type_meaning    incident_type,
		it.business_process_id,
--		act.action_assignee_id dispatcher_id,
--		act.action_assignee dispatcher_name,
		'N'  covered_by_contract,
--        	decode(sr.current_contact_person_id, null, sr.represented_by_name,
--	               sr.current_contact_name) current_contact_name,
--		decode(sr.current_contact_person_id,null, sr.represented_by_telephone,
--                     sr.current_contact_telephone) current_contact_telephone,
--		decode(sr.current_contact_person_id, null, sr.represented_by_area_code,
--		       sr.current_contact_area_code) current_contact_area_code,
--		decode(sr.current_contact_person_id, null, sr.represented_by_extension,
--		       sr.current_contact_extension) current_contact_extension,
--		decode(sr.current_contact_person_id, null, sr.represented_by_fax_number,
--		       sr.current_contact_fax_number) current_contact_fax_number,
--		decode(sr.current_contact_person_id, null, sr.represented_by_fax_area_code,
--		       sr.current_contact_fax_area_code) current_contact_fax_area_code,
--		decode(sr.current_contact_person_id, null, sr.represented_by_email_address,
--		       sr.current_contact_email_address) current_contact_email_address,
	    	hl.address1 || hl.address2 ship_to_address_line1,
		hl.address3  ship_to_address_line2,
		substr(hl.address3,instr(hl.address3, ',')+5 , 5 ) postal_code,
		substr(hl.address3,1,instr(hl.address3, ',') -1 ) city,
		substr(hl.address3,instr(hl.address3, ',')+2 , 2 ) state,
        	substr(hl.address3,instr(hl.address3, ',', -1, 1)+2 ) country,
		act.actual_start_date start_time,
		act.scheduled_end_date end_time,
		act.actual_end_date end_time,
		act.actual_start_date earliest_start_time,
		act.scheduled_end_date latest_finish_time,
		'N' appointment,
		null request_duration,
--		act.dispatcher_orig_syst_id employee_id,
--		act.dispatch_role_name employee_name,
		sr.incident_severity_id,
		sr.severity incident_severity_name,
		jn.notes inc_prob_description,
		act.task_status_id action_status_id
--        	act.text problem_summary
	FROM    CS_INCIDENTS_V sr,
                jtf_tasks_v act,
--		CS_INCIDENT_ACTIONS_V act,
		mtl_system_items_kfv mtl,
		cs_customer_products cp,
		cs_incident_types it,
		cs_incident_statuses st,
                hz_party_sites hps,
                hz_locations hl,
                jtf_notes_vl jn
	WHERE   it.incident_type_id = sr.incident_type_id
          AND   mtl.inventory_item_id(+) = sr.inventory_item_id
          AND   mtl.organization_id = CS_STD.Get_Item_Valdn_Orgzn_ID
	  AND   cp.customer_product_id(+) = sr.customer_product_id
	  AND   sr.incident_id = p_incident_id
	  AND   act.source_object_id = p_incident_id
	  AND   act.task_id = p_incident_action_id
--	  AND   act.dispatcher_orig_syst = 'PER'
	  AND   act.task_status_id = st.incident_status_id
          AND   sr.customer_id = hps.party_id
          AND   hps.party_site_id = hl.location_id
          AND   sr.incident_id = jn.source_object_id
          AND   jn.source_object_code = 'SR'
          AND   upper(jn.note_type) = 'SR_PROBLEM';

-- ***************************************************************************
-- *									     *
-- *			   GLOBAL CONSTANTS          		             *
-- *									     *
-- ***************************************************************************

g_fs_itemtype 	CONSTANT VARCHAR2(10) :=  'SRACTION';
g_fs_activity 	CONSTANT VARCHAR2(30) :=  'FS_NOTIFY_FIELD_ENGINEER';


-- ***************************************************************************
-- *									     *
-- *			   Service Request Item Type			     *
-- *									     *
-- ***************************************************************************

------------------------------------------------------------------------------
-- Servereq_Selector
--   This procedure sets up the responsibility and organization context for
--   multi-org sensitive code.
--
--  Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  30-Aug-2005 ANEEMUCH    Fixed FP bug 4206834, issue fixed in funcmode=TEST_CTX
--
-- -----------------------------------------------------------------------


PROCEDURE Servereq_Selector
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	NOCOPY VARCHAR2
)
IS
  l_user_id		NUMBER;
  l_resp_id		NUMBER;
  l_resp_appl_id	NUMBER;

  l_g_user_id		NUMBER;
  l_g_resp_id		NUMBER;
  l_g_resp_appl_id	NUMBER;
BEGIN

  IF (funcmode = 'RUN') THEN
    result := 'COMPLETE';

  -- Engine calls SET_CTX just before activity execution
  ELSIF (funcmode = 'SET_CTX') THEN

    -- First get the user id, resp id, and appl id
    l_user_id := WF_ENGINE.GetItemAttrNumber
		   ( itemtype	=> itemtype,
		     itemkey	=> itemkey,
		     aname	=> 'USER_ID'
		   );
    l_resp_id := WF_ENGINE.GetItemAttrNumber
		   ( itemtype	=> itemtype,
		     itemkey	=> itemkey,
		     aname	=> 'RESP_ID'
		   );
    l_resp_appl_id := WF_ENGINE.GetItemAttrNumber
			( itemtype	=> itemtype,
			  itemkey	=> itemkey,
			  aname		=> 'RESP_APPL_ID'
			);

    -- Set the database session context

    IF (NVL(l_user_id,-999) <> FND_GLOBAL.user_id OR
        NVL(l_resp_id,-999) <> FND_GLOBAL.resp_id OR
        NVL(l_resp_appl_id,-999) <> FND_GLOBAL.resp_appl_id) THEN

       FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

    END IF ;

    result := 'COMPLETE';

  -- Notification Viewer form calls TEST_CTX just before launching a form
  ELSIF (funcmode = 'TEST_CTX') THEN
    l_user_id := WF_ENGINE.GetItemAttrNumber
                   ( itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'USER_ID'
                   );
    l_resp_id := WF_ENGINE.GetItemAttrNumber
                   ( itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'RESP_ID'
                   );
    l_resp_appl_id := WF_ENGINE.GetItemAttrNumber
                        ( itemtype      => itemtype,
                          itemkey       => itemkey,
                          aname         => 'RESP_APPL_ID'
                        );


    l_g_user_id := fnd_global.user_id;
    l_g_resp_id := fnd_global.resp_id;
    l_g_resp_appl_id := fnd_global.resp_appl_id;

--    result := 'COMPLETE';
    IF l_g_user_id = l_user_id
        and l_g_resp_id = l_resp_id
        and l_g_resp_appl_id = l_resp_appl_id THEN
       result := 'TRUE';
    ELSE
       result := 'NOTSET';
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Servereq_Selector',
		    itemtype, itemkey, actid, funcmode);
    RAISE;
END Servereq_Selector;


-- ---------------------------------------------------------------------------
-- Initialize_Request
--   This procedure initializes the item attributes that will remain constant
--   over the duration of the Workflow.  These attributes include REQUEST_ID,
--   REQUEST_NUMBER, REQUEST_DATE, and REQUEST_TYPE.  In addition, the
--   ESCALATION_HISTORY item attribute is initialized with the assignment
--   information of the current owner.
-- ---------------------------------------------------------------------------

  PROCEDURE Initialize_Request(	itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 ) IS

    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_request_number	VARCHAR2(64);
    l_dummy		NUMBER;
    l_return_status	VARCHAR2(1);
    l_API_ERROR		EXCEPTION;

    /****
     Changing this for performance issues due to
     excessive shared memory and non-mergeable view.
     rmanabat 03/20/03.

    CURSOR l_ServiceRequest_csr IS
      SELECT *
        FROM CS_INCIDENTS_WORKFLOW_V
       WHERE INCIDENT_NUMBER = l_request_number;
    ****/

    /** Replacing above cursor with this. Bug 2857365. rmanabat 03/20/02 **/
    CURSOR l_ServiceRequest_csr IS
      SELECT  INC.INCIDENT_ID,
        INC.INCIDENT_NUMBER,
        INC.INCIDENT_DATE,
        TYPE.NAME INCIDENT_TYPE
      FROM cs_incidents_all_b INC,
        CS_INCIDENT_TYPES_TL TYPE
      WHERE INC.INCIDENT_NUMBER = l_request_number
        AND INC.INCIDENT_TYPE_ID = TYPE.INCIDENT_TYPE_ID(+)
        AND TYPE.LANGUAGE(+) = userenv('LANG');


    l_ServiceRequest_rec 	l_ServiceRequest_csr%ROWTYPE;
    l_errmsg_name		VARCHAR2(30);

  BEGIN

    IF (funmode = 'RUN') THEN

      -- Decode the item key to get the service request number
      CS_WORKFLOW_PUB.Decode_Servereq_Itemkey(
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_itemkey		=>  itemkey,
		p_request_number	=>  l_request_number,
		p_wf_process_id		=>  l_dummy );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Decode_Servereq_Itemkey',
			 arg1		=>  'p_itemkey=>'||itemkey );
	l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
	raise l_API_ERROR;
      END IF;

      -- Extract the service request record
      OPEN l_ServiceRequest_csr;
      FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

      -- Initialize item attributes that will remain constant
      WF_ENGINE.SetItemAttrDate(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_DATE',
		avalue		=> l_ServiceRequest_rec.incident_date );

      WF_ENGINE.SetItemAttrNumber(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_ID',
		avalue		=> l_ServiceRequest_rec.incident_id );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_NUMBER',
		avalue		=> l_ServiceRequest_rec.incident_number );

      WF_ENGINE.SetItemAttrText(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'REQUEST_TYPE',
		avalue		=> l_ServiceRequest_rec.incident_type );

      CLOSE l_ServiceRequest_csr;

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Initialize_Request',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Initialize_Request;



-- -----------------------------------------------------------------------
-- Update_Request_Info
--   Refresh the item attributes with the latest values in the database.
--
--  Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  05/05/2004	RMANABAT    Performance . Used Wf_Engine.SetItemAttrArray
--			    for array processing instead of individual api calls.
-- -----------------------------------------------------------------------

  PROCEDURE Update_Request_Info ( itemtype	VARCHAR2,
				  itemkey	VARCHAR2,
				  actid		NUMBER,
				  funmode	VARCHAR2,
				  result	OUT NOCOPY VARCHAR2 ) IS

    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_request_id	NUMBER;
    l_owner_role	VARCHAR2(100);
    l_owner_name  	VARCHAR2(240);
    l_errmsg_name	VARCHAR2(30);
    l_API_ERROR		  	EXCEPTION;

    /****
     Changing this for performance issues due to
     excessive shared memory and non-mergeable view.
     rmanabat 03/20/03.

    CURSOR l_ServiceRequest_csr IS
      SELECT *
        FROM cs_incidents_workflow_v
       WHERE incident_id = l_request_id;
    ****/

    /** Replacing above cursor with this. Bug 2857365. rmanabat 03/20/02 **/
    CURSOR l_ServiceRequest_csr IS
      SELECT  INC.INCIDENT_ID,
        INC.SUMMARY,
        INC.INCIDENT_OWNER_ID,
        INC.INVENTORY_ITEM_ID,
        INC.EXPECTED_RESOLUTION_DATE,
        INC.INCIDENT_DATE,
        INC.CUSTOMER_PRODUCT_ID,
        SEVERITY.NAME SEVERITY,
        STATUS.NAME STATUS_CODE,
        URGENCY.NAME URGENCY,
        RA2.PARTY_NAME CUSTOMER_NAME,
        CSLKUP.DESCRIPTION PROBLEM_CODE_DESCRIPTION,
        MTL.DESCRIPTION PRODUCT_DESCRIPTION
      FROM    CS_INCIDENTS_ALL_VL INC,
        --CS_INCIDENT_SEVERITIES_VL SEVERITY,
        CS_INCIDENT_SEVERITIES_TL SEVERITY,
        CS_INCIDENT_STATUSES_VL STATUS,
        --CS_INCIDENT_URGENCIES_VL URGENCY,
        CS_INCIDENT_URGENCIES_TL URGENCY,
        HZ_PARTIES RA2,
        CS_LOOKUPS CSLKUP,
        --MTL_SYSTEM_ITEMS_VL MTL
        MTL_SYSTEM_ITEMS_TL MTL
      WHERE INC.INCIDENT_ID = l_request_id
        AND INC.INCIDENT_STATUS_ID = STATUS.INCIDENT_STATUS_ID
        AND INC.INCIDENT_URGENCY_ID = URGENCY.INCIDENT_URGENCY_ID(+)
        AND URGENCY.LANGUAGE(+) = userenv('LANG')
        AND INC.CUSTOMER_ID = RA2.PARTY_ID(+)
        AND INC.INCIDENT_SEVERITY_ID = SEVERITY.INCIDENT_SEVERITY_ID(+)
        AND SEVERITY.LANGUAGE(+) = userenv('LANG')
        AND INC.PROBLEM_CODE = CSLKUP.LOOKUP_CODE(+)
        AND CSLKUP.LOOKUP_TYPE(+) = 'REQUEST_PROBLEM_CODE'
        AND MTL.INVENTORY_ITEM_ID(+) = INC.INVENTORY_ITEM_ID
        AND MTL.LANGUAGE(+) = userenv('LANG')
        AND (MTL.ORGANIZATION_ID = CS_STD.Get_Item_Valdn_Orgzn_ID OR MTL.ORGANIZATION_ID IS NULL);


    l_ServiceRequest_rec 	l_ServiceRequest_csr%ROWTYPE;

    /***
      New 03/17/03. rmanabat
      Fix for bug 2837253.
    ***/

    l_incident_owner_id         NUMBER;
    l_source_id                 NUMBER;

    CURSOR l_get_source_id IS
      SELECT emp.source_id
      FROM jtf_rs_resource_extns emp
      WHERE emp.resource_id = l_incident_owner_id;

    /*** end New 03/17/03. rmanabat ***/

    tvarname	Wf_Engine.NameTabTyp;
    tvarval	Wf_Engine.TextTabTyp;

    nvarname	Wf_Engine.NameTabTyp;
    nvarval	Wf_Engine.NumTabTyp;


  BEGIN

    IF (funmode = 'RUN') THEN

      -- Get the service request ID
      l_request_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'REQUEST_ID' );

      -- Extract the service request record
      OPEN l_ServiceRequest_csr;
      FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;

      l_incident_owner_id := l_ServiceRequest_rec.incident_owner_id;

      OPEN l_get_source_id;
      FETCH l_get_source_id INTO l_source_id;

      IF (l_get_source_id%FOUND AND l_source_id IS NOT NULL) THEN

        CLOSE l_get_source_id;

        -- Retrieve the role name for the request owner
        CS_WORKFLOW_PUB.Get_Employee_Role (
  		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		--p_employee_id  		=>  l_ServiceRequest_rec.incident_owner_id,
		p_employee_id  		=>  l_source_id,
		p_role_name		=>  l_owner_role,
		p_role_display_name	=>  l_owner_name );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
           (l_owner_role is NULL) THEN
          wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
	  		 proc_name	=>  'Get_Employee_Role',
	  		 arg1		=>  'p_employee_id=>'|| l_source_id);
					    --to_char(l_ServiceRequest_rec.incident_owner_id));
	  l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
	  raise l_API_ERROR;
        END IF;

      ELSE
          CLOSE l_get_source_id;
          wf_core.context( pkg_name     =>  'CS_WORKFLOW_PUB',
                         proc_name      =>  'Get_Employee_Role',
                         arg1           =>  'p_employee_id=>'||
                                            to_char(l_ServiceRequest_rec.incident_owner_id));
          l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
          raise l_API_ERROR;

      END IF;


      tvarname(1) := 'OWNER_ROLE';
      tvarval(1)  := l_owner_role;
      tvarname(2) := 'OWNER_NAME';
      tvarval(2)  := l_owner_name;
      tvarname(3) := 'PROBLEM_DESCRIPTION';
      tvarval(3)  := l_ServiceRequest_rec.problem_code_description;
      tvarname(4) := 'PRODUCT_DESCRIPTION';
      tvarval(4)  := l_ServiceRequest_rec.product_description;
      tvarname(5) := 'REQUEST_CUSTOMER';
      tvarval(5)  := l_ServiceRequest_rec.customer_name;
      tvarname(6) := 'REQUEST_SEVERITY';
      tvarval(6)  := l_ServiceRequest_rec.severity;
      tvarname(7) := 'REQUEST_STATUS';
      tvarval(7)  := l_ServiceRequest_rec.status_code;
      tvarname(8) := 'REQUEST_SUMMARY';
      tvarval(8)  := l_ServiceRequest_rec.summary;
      tvarname(9) := 'REQUEST_URGENCY';
      tvarval(9)  := l_ServiceRequest_rec.urgency;

      Wf_Engine.SetItemAttrTextArray(itemtype	=> 'SERVEREQ',
				     itemkey	=> itemkey,
				     aname	=> tvarname,
				     avalue	=> tvarval);

      nvarname(1) := 'OWNER_ID';
      nvarval(1)  := l_source_id;
      nvarname(2) := 'CUSTOMER_PRODUCT_ID';
      nvarval(2)  := l_ServiceRequest_rec.customer_product_id;
      nvarname(3) := 'INVENTORY_ITEM_ID';
      nvarval(3)  := l_ServiceRequest_rec.inventory_item_id;

      Wf_Engine.SetItemAttrNumberArray(itemtype	=> 'SERVEREQ',
				       itemkey	=> itemkey,
				       aname	=> nvarname,
				       avalue	=> nvarval);

      WF_ENGINE.SetItemAttrDate(
		itemtype	=> 'SERVEREQ',
		itemkey		=> itemkey,
		aname		=> 'EXPECTED_RESOLUTION_DATE',
		avalue		=> l_ServiceRequest_rec.expected_resolution_date );

--    Modified on 12/21/1999
--    Uncommented 05/29/2001 rmanabat. Required for notification body.
--    changed problem_description to problem_code_description .Bug# 1650881
--    Uncommented 05/29/2001 rmanabat.
--    Required for notification body. Bug# 1650881

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

    CLOSE l_ServiceRequest_csr;

  EXCEPTION
    WHEN l_API_ERROR THEN
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        CLOSE l_ServiceRequest_csr;
      END IF;
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Update_Request_Info',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Update_Request_Info;



-- -------------------------------------------------------------------
-- Select_Supervisor
--   Three item attributes are updated: SUPERVISOR_ID, SUPERVISOR_NAME,
--   and SUPERVISOR_ROLE.  If the supervisor of the owner cannot be
--   found, or if the supervisor does not have a valid workflow role,
--   an exception is raised.
--
--  Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  05/05/2004	RMANABAT    Fix for bug 3612904. Changed cursor table
--			    from wf_item_activity_statuses to
--			    wf_item_activity_statuses_h because of change
--			    in schema behavior.
--  29-Aug-2005 ANEEMUCH    Fixed bug 4469412. Parameter item_key and item_type
--                          should be from parameter list in cursor sel_recipient_role_csr
-- -------------------------------------------------------------------

  PROCEDURE Select_Supervisor(  itemtype       VARCHAR2,
                                itemkey        VARCHAR2,
                                actid          NUMBER,
                                funmode        VARCHAR2,
                                result     OUT NOCOPY VARCHAR2 ) IS

    l_return_status		VARCHAR2(1);
    l_msg_count			NUMBER;
    l_msg_data			VARCHAR2(2000);
    l_owner_id   		NUMBER;
    l_supervisor_name    	VARCHAR2(240);
    l_supervisor_role		VARCHAR2(100);
    l_supervisor_id 		NUMBER;
    l_errmsg_name		VARCHAR2(30);
    l_API_ERROR			EXCEPTION;

    -- Fix for Bug# 1810781 rmanabat
    l_owner_role                VARCHAR2(240);
    l_recipient_role            VARCHAR2(30);
    l_employee_id               NUMBER;
    l_status                    VARCHAR2(8);

    CURSOR sel_recipient_role_csr IS
        select  wf.recipient_role, wf.status
        from    wf_notifications wf,
		wf_item_activity_statuses_h wi
		--Bug 2412660 modified for performance issues. related to bug 2365267.rmanabat 06/11/02
                --wf_item_activity_statuses_v wi
        where
                wf.message_name in ('ESCALATION_WITH_EXP_MSG',
                                    'ESCALATION_MSG',
				    'ASSIGNMENT_WITH_EXP_MSG',
				    'ASSIGNMENT_MSG')
                AND wf.original_recipient = l_owner_role
                AND wi.notification_id = wf.notification_id
                AND wi.item_type = itemtype
                AND wi.item_key = itemkey
		AND wi.activity_status='COMPLETE'
                --AND wi.activity_status_code='COMPLETE'
        order by wf.begin_date desc;

    CURSOR sel_employee_id_csr IS
        select  wr.orig_system_id
        from    WF_ROLES wr
        where   wr.orig_system = 'PER'
                AND wr.name = l_recipient_role;

    -- END of fix for Bug 1810781 rmanabat

  BEGIN

    IF (funmode = 'RUN') THEN

      -- Get the current owner of the request
      l_owner_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'OWNER_ID' );

      -- Fix for Bug# 1810781 rmanabat
      l_owner_role := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'OWNER_ROLE' );

      -- check only for the latest notification.
      OPEN sel_recipient_role_csr;
      FETCH sel_recipient_role_csr into l_recipient_role,l_status;

      -- check if notification was reassigned.
      IF (l_status = 'CLOSED' AND l_recipient_role <> l_owner_role) THEN

        IF (sel_recipient_role_csr%FOUND AND l_recipient_role IS NOT NULL) THEN
          OPEN sel_employee_id_csr;
          FETCH sel_employee_id_csr INTO l_employee_id;
          IF (sel_employee_id_csr%FOUND AND l_employee_id IS NOT NULL) THEN
            -- Assign the new Notification owner id if current owner
            -- is  different from recipient .
            l_owner_id := l_employee_id;
          END IF;
          CLOSE sel_employee_id_csr;
        END IF;
      END IF;

      CLOSE sel_recipient_role_csr;
      -- END of fix for Bug 1810781 rmanabat

      -- Get the supervisor information
      CS_WORKFLOW_PUB.Get_Emp_Supervisor(
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_init_msg_list		=>  FND_API.G_TRUE,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id		=>  l_owner_id,
		p_supervisor_emp_id 	=>  l_supervisor_id,
		p_supervisor_role	=>  l_supervisor_role,
		p_supervisor_name       =>  l_supervisor_name );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
         (l_supervisor_role IS NULL) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Get_Emp_Supervisor',
			 arg1		=>  'p_employee_id=>'||to_char(l_owner_id) );
	l_errmsg_name := 'CS_SR_CANT_FIND_SUPERVISOR';
	raise l_API_ERROR;
      END IF;

      -- Update the item attributes
      WF_ENGINE.SetItemAttrNumber(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'SUPERVISOR_ID',
			avalue		=> l_supervisor_id );

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'SUPERVISOR_ROLE',
			avalue		=> l_supervisor_role );

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'SUPERVISOR_NAME',
			avalue		=> l_supervisor_name );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Select_Supervisor',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Select_Supervisor;


-- -------------------------------------------------------------------
-- Update_Owner
--   Update the owner of the service request.  This procedure will set
--   the OWNER_ID of the service request.  It also updates the following
--   item attributes: OWNER_ID, OWNER_NAME, and OWNER_ROLE.
-- In 11i, l_new_owner_id is replaced by resource_id
--
--  Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  05/25/2004	RMANABAT    Fix for bug 3612904. Passed resp_id and
--			    rep_appL_id to update_servicerequest() api
--			    for security validation.
-- -------------------------------------------------------------------

  PROCEDURE Update_Owner( itemtype       VARCHAR2,
                          itemkey        VARCHAR2,
                          actid          NUMBER,
                          funmode        VARCHAR2,
                          result     OUT NOCOPY VARCHAR2 ) IS

    l_owner_id 		NUMBER;
    l_new_owner_id 	NUMBER;
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_new_owner_role	VARCHAR2(240);
    l_new_owner_name	VARCHAR2(240);
    l_errmsg_name	VARCHAR2(30);
    l_API_ERROR		EXCEPTION;
    l_user_id		NUMBER;
    l_login_id		NUMBER;
    l_request_number	VARCHAR2(64);
    l_wf_process_id	NUMBER;
    l_org_id		NUMBER;
    l_dummy_id		NUMBER;
    l_prev_owner_id 	NUMBER;
    l_prev_owner_name	VARCHAR2(240);
    l_prev_owner_role	VARCHAR2(240);
    l_resource_id   NUMBER;

    l_resource_type     VARCHAR2(240)  := 'RS_EMPLOYEE';
    l_owner_group_id    NUMBER;
    l_object_version_number  NUMBER;

    l_resp_id		NUMBER;
    l_resp_appl_id	NUMBER;

    --l_service_request_rec	CS_ServiceRequest_PVT.service_request_rec_type;
    --l_notes		CS_SERVICEREQUEST_PVT.notes_table;
    --l_contacts		CS_SERVICEREQUEST_PVT.contacts_table;
    --out_interaction_id	NUMBER;
    --out_wf_process_id	NUMBER;
    l_request_id	NUMBER;


-- Fix for bug 1361599, if end_date_active is null, record is not selected
-- modify the cursor below  added nvl(end_date_active,sysdate +1)
--
CURSOR sel_resource_csr IS
select resource_id from jtf_rs_resource_extns
where source_id = l_new_owner_id
 and category = 'EMPLOYEE'
 and sysdate between start_date_active and nvl(end_date_active,sysdate + 1);

  BEGIN

    IF (funmode = 'RUN') THEN

      -- Get the current owner of the request
      l_owner_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'OWNER_ID' );

      -- Get the employee ID of the new owner
      l_new_owner_id := WF_ENGINE.GetActivityAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				actid		=> actid,
				aname		=> 'NEW_OWNER_ID' );


      -- Get the new owner information
      CS_WORKFLOW_PUB.Get_Employee_Role (
		p_api_version		=>  1.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id  		=>  l_new_owner_id,
		p_role_name		=>  l_new_owner_role,
		p_role_display_name	=>  l_new_owner_name );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
         (l_new_owner_role IS NULL) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Get_Employee_Role',
			 arg1		=>  'p_employee_id=>'||to_char(l_new_owner_id) );
	l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
	raise l_API_ERROR;
      END IF;

      -- Get the FND_USER ID of the current owner so that we can
      -- use it for the audit record
      CS_WORKFLOW_PUB.Get_Emp_Fnd_User_ID(
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id		=>  l_owner_id,
		p_fnd_user_id		=>  l_user_id );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Get_Emp_Fnd_User_ID',
			 arg1		=>  'p_employee_id=>'||to_char(l_owner_id) );
	l_errmsg_name := 'CS_WF_SR_GET_EMP_USER_ID';
	raise l_API_ERROR;
      END IF;

      -- Get the workflow process ID
      CS_Workflow_PUB.Decode_Servereq_Itemkey(
		p_api_version		=>  1.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_itemkey		=>  itemkey,
		p_request_number	=>  l_request_number,
		p_wf_process_id		=>  l_wf_process_id );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Decode_Servereq_Itemkey',
			 arg1		=>  'p_itemkey=>'||itemkey );
	l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
	raise l_API_ERROR;
      END IF;

      BEGIN
	SELECT login_id INTO l_login_id
	FROM   fnd_logins
	WHERE  login_id = FND_GLOBAL.LOGIN_ID
	AND    user_id = l_user_id;
      EXCEPTION
	WHEN OTHERS THEN
	  l_login_id := NULL;
      END;

      SELECT org_id, object_version_number, incident_id
      INTO l_org_id, l_object_version_number, l_request_id
      FROM   CS_INCIDENTS_ALL_B
      WHERE  incident_number = l_request_number;

    -- For 11i, replace person_id with resource_id
    -- l_new_owner_id is the resource_id

    open sel_resource_csr;
    fetch sel_resource_csr into l_resource_id;
     if (sel_resource_csr%notfound) then
        null;
     end if;

    -- Commented out. Fix for bug 3065468. rmanabat 07/24/03
    --l_new_owner_id := l_resource_id;


    IF (fnd_global.resp_id is null OR fnd_global.resp_id = -1) THEN
      l_resp_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'RESP_ID' );
      l_resp_appl_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'RESP_APPL_ID' );
    ELSE
      l_resp_id := fnd_global.resp_id;
      l_resp_appl_id := fnd_global.resp_appl_id;
    END IF;

    CS_ServiceRequest_PUB.Update_Owner (
		p_api_version		=>  2.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		p_commit		=>  FND_API.G_FALSE,
		x_return_status		=>  l_return_status,
		x_msg_count		=>  l_msg_count,
		x_msg_data		=>  l_msg_data,
		p_user_id		=>  l_user_id,
		p_login_id		=>  l_login_id,
	        -- Don't need Org id for updates , SR API modified so comment out here
		--p_org_id		=>  l_org_id,
		p_request_number        =>  l_request_number,
		p_object_version_number =>  l_object_version_number,
		-- Fix for bug 3065468. rmanabat 07/24/03
		--p_owner_id		=>  l_new_owner_id,
	        p_resp_id		=> l_resp_id,
	        p_resp_appl_id		=> l_resp_appl_id,
		p_owner_id		=>  l_resource_id,
		p_owner_group_id        =>  l_owner_group_id,
		p_resource_type         =>  l_resource_type,
		p_audit_comments	=>  CS_WF_ACTIVITIES_PKG.Audit_Comments,
		p_called_by_workflow	=>  FND_API.G_TRUE,
		p_workflow_process_id	=>  l_wf_process_id,
		x_interaction_id	=>  l_dummy_id );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	FND_MSG_PUB.Count_And_Get( p_count	=> l_msg_count,
				   p_data	=> l_msg_data,
				   p_encoded	=> FND_API.G_FALSE );
        wf_core.context( pkg_name	=>  'CS_ServiceRequest_PUB',
			 proc_name	=>  'Update_Owner',
			 arg1		=>  'p_user_id=>'||l_user_id,
			 arg2		=>  'p_login_id=>'||l_login_id,
			 arg3		=>  'p_org_id=>'||l_org_id,
			 arg4		=>  'p_owner_id=>'||l_resource_id,
			 arg5		=>  'p_msg_data=>'||l_msg_data );
	l_errmsg_name := 'CS_SR_CANT_UPDATE_OWNER';
	raise l_API_ERROR;
      END IF;

      l_prev_owner_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'OWNER_ID' );

      l_prev_owner_name := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'OWNER_NAME' );

      l_prev_owner_role := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'OWNER_ROLE' );

      WF_ENGINE.SetItemAttrNumber(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'PREV_OWNER_ID',
			avalue		=> l_prev_owner_id );

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'PREV_OWNER_ROLE',
			avalue		=> l_prev_owner_role );

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'PREV_OWNER_NAME',
			avalue		=> l_prev_owner_name );

      WF_ENGINE.SetItemAttrNumber(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'OWNER_ID',
			avalue		=> l_new_owner_id );

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'OWNER_ROLE',
			avalue		=> l_new_owner_role );

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'OWNER_NAME',
			avalue		=> l_new_owner_name );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Update_Owner',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Update_Owner;


-- ---------------------------------------------------------------------------
-- Update_Status
--   This procedure corresponds to the UPDATE_STATUS function activity.  It
--   updates the status of the service request to the value given by the
--   STATUS activity attribute.
--
--  Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  05/25/2004	RMANABAT    Fix for bug 3612904. Passed resp_id and
--			    rep_appL_id to update_servicerequest() api
--			    for security validation.
-- ---------------------------------------------------------------------------

  PROCEDURE Update_Status( itemtype      VARCHAR2,
                           itemkey       VARCHAR2,
                           actid         NUMBER,
                           funmode       VARCHAR2,
                           result    OUT NOCOPY VARCHAR2 ) IS

    l_owner_id		NUMBER;
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_user_id		NUMBER;
    l_login_id		NUMBER;
    l_errmsg_name	VARCHAR2(30);
    l_API_ERROR		EXCEPTION;
    l_request_number	VARCHAR2(64);
    l_wf_process_id	NUMBER;
    l_new_status_id	NUMBER;
    l_new_status	VARCHAR2(30);
    l_org_id		NUMBER;
    l_dummy_id		NUMBER;
    l_object_version_number   NUMBER;

-- Added new variables for # 1528813

    l_request_id   number;
    l_service_request_rec  CS_ServiceRequest_PVT.service_request_rec_type;
    l_notes     CS_SERVICEREQUEST_PVT.notes_table;
    l_contacts  CS_SERVICEREQUEST_PVT.contacts_table;
    out_interaction_id   number;
    out_wf_process_id  number;
    l_api_name  CONSTANT VARCHAR2(60)  := 'CS_WF_ACTIVITIES_PKG.Update_status';
    l_msg_index_out      number;

    l_resp_id		NUMBER;
    l_resp_appl_id	NUMBER;

  BEGIN

    IF (funmode = 'RUN') THEN

      -- Get the current owner of the request
      l_owner_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'OWNER_ID' );

      -- Get the FND User ID of the owner for the audit record

/* Commenting out this call, l_user_id used for update_service_request
  (last_updated_by) should always be the FND_USER .

      CS_WORKFLOW_PUB.Get_Emp_Fnd_User_ID(
		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id		=>  l_owner_id,
		p_fnd_user_id		=>  l_user_id );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Get_Emp_Fnd_User_ID',
			 arg1		=>  'p_employee_id=>'||to_char(l_owner_id) );
	l_errmsg_name := 'CS_WF_SR_GET_EMP_USER_ID';
	raise l_API_ERROR;
      END IF;
*/
      -- Replacing call to CS_WORKFLOW_PUB.Get_Emp_Fnd_User_ID
      -- with FND_USER profile. rmanabat 09/18/01

/* Roopa
	Fix for bug 2843395

	1) See if fnd_profile.valuw returns an id
	2) Else, see if the incident_owner_id(source_id) of the sr has a valid value
	3) Else, use fnd_global.user_id
*/
      l_user_id := fnd_profile.value('USER_ID');

      IF (l_user_id IS NULL) THEN

       IF(l_owner_id IS NOT NULL) THEN
        CS_WORKFLOW_PUB.Get_Emp_Fnd_User_ID(
  		p_api_version		=>  1.0,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_employee_id		=>  l_owner_id,
		p_fnd_user_id		=>  l_user_id );

	        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       		   wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
	  			   proc_name	=>  'Get_Emp_Fnd_User_ID',
				   arg1		=>  'p_employee_id=>'||to_char(l_owner_id) );
	  	   l_errmsg_name := 'CS_WF_SR_GET_EMP_USER_ID';
	  	   raise l_API_ERROR;
                END IF;
        ELSE
		l_user_id := fnd_global.USER_ID();
        END IF;
     END IF;

      -- Get the workflow process ID
      CS_Workflow_PUB.Decode_Servereq_Itemkey(
		p_api_version		=>  1.0,
		p_init_msg_list		=>  FND_API.G_FALSE,
		p_return_status		=>  l_return_status,
		p_msg_count		=>  l_msg_count,
		p_msg_data		=>  l_msg_data,
		p_itemkey		=>  itemkey,
		p_request_number	=>  l_request_number,
		p_wf_process_id		=>  l_wf_process_id );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        wf_core.context( pkg_name	=>  'CS_WORKFLOW_PUB',
			 proc_name	=>  'Decode_Servereq_Itemkey',
			 arg1		=>  'p_itemkey=>'||itemkey );
	l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
	raise l_API_ERROR;
      END IF;

--fix for #1528813
-- get object_version_number

      begin
      --initialise
       l_return_status := FND_API.G_RET_STS_SUCCESS;

	 select object_version_number,incident_id
	 INTO l_object_version_number,l_request_id
	 from cs_incidents_all_b
	 where incident_number = l_request_number;

--	dbms_output.put_line('object version  ' || l_object_version_number );

     exception
       WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
		CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
			p_token_an =>  l_api_name,
			p_token_v  =>  to_char(l_request_id),
			p_token_p  =>  'p_request_id' );
			raise FND_API.G_EXC_ERROR;

	  WHEN TOO_MANY_ROWS THEN
	    Null;
    end;

-- Get the new status
      l_new_status_id := WF_ENGINE.GetActivityAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				actid		=> actid,
				aname		=> 'STATUS' );

      BEGIN
	SELECT login_id INTO l_login_id
	FROM   fnd_logins
	WHERE  login_id = FND_GLOBAL.LOGIN_ID
	AND    user_id = l_user_id;
      EXCEPTION
	WHEN OTHERS THEN
	  l_login_id := NULL;
      END;

      SELECT org_id INTO l_org_id
      FROM   CS_INCIDENTS_ALL_B
      WHERE  incident_number = l_request_number;

      -- Update the status.  Note that the status ID of 2 is a seeded
      -- status that corresponds to 'CLOSED'; we use the ID instead of
      -- hardcoded value of 'CLOSED' due to translation issues

--Fix for Bug 1528813
-- Change API call to Update_ServiceRequest since it updates status too
-- Get the object version number from cs_incidents_all_b


/*
   CS_ServiceRequest_PUB.Update_Status (
		p_api_version		  =>	2.0,
		p_init_msg_list		  =>	FND_API.G_FALSE,
		p_commit		  =>	FND_API.G_FALSE,
		x_return_status		  =>	l_return_status,
		x_msg_count		  =>	l_msg_count,
		x_msg_data		  =>	l_msg_data,
  		p_user_id		  =>	l_user_id,
		p_login_id		  =>	l_login_id,
-- Don't need Org id for updates , SR API modified so comment out here
--  		p_org_id		  =>	l_org_id,
                p_request_number          =>	l_request_number,
                p_object_version_number   =>    l_object_version_number,
                p_status_id		  =>	l_new_status_id,
                p_closed_date		  =>	sysdate,
                p_audit_comments	  =>	CS_WF_ACTIVITIES_PKG.Audit_Comments,
		p_called_by_workflow	  =>	FND_API.G_TRUE,
		p_workflow_process_id	  => 	l_wf_process_id,
		x_interaction_id	  =>	l_dummy_id );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	FND_MSG_PUB.Count_And_Get( p_count	=> l_msg_count,
				   p_data	=> l_msg_data,
				   p_encoded	=> FND_API.G_FALSE );
        wf_core.context( pkg_name	=>  'CS_ServiceRequest_PUB',
			 proc_name	=>  'Update_Status',
			 arg1		=>  'p_user_id=>'||l_user_id,
			 arg2		=>  'p_org_id=>'||l_org_id,
			 arg3		=>  'p_request_number=>'||l_request_number,
			 arg4		=>  'p_status_id=>'||l_new_status_id,
			 arg5		=>  'p_msg_data=>'||l_msg_data );
	l_errmsg_name := 'CS_SR_CANT_UPDATE_STATUS';
	raise l_API_ERROR;
      END IF;
*/
-- For bug# 1528813
-- initialize

     CS_ServiceRequest_PVT.initialize_rec(l_service_request_rec);

     l_service_request_rec.status_id := l_new_status_id;
     l_service_request_rec.closed_date := sysdate;

     -- Added mandatory parameter last_update_program_code .11/19/02 rmanabat
     l_service_request_rec.last_update_program_code := 'SUPPORT.WF';

     IF (fnd_global.resp_id is null OR fnd_global.resp_id = -1) THEN
       l_resp_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'RESP_ID' );
       l_resp_appl_id := WF_ENGINE.GetItemAttrNumber(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'RESP_APPL_ID' );
     ELSE
       l_resp_id := fnd_global.resp_id;
       l_resp_appl_id := fnd_global.resp_appl_id;
     END IF;


     CS_ServiceRequest_PVT.Update_ServiceRequest
     ( p_api_version		=> 3.0, -- Changed from 2.0 for 11.5.9.
       p_init_msg_list		=> fnd_api.g_false,
       p_commit			=> fnd_api.g_true,
       p_validation_level       => fnd_api.g_valid_level_full,
       x_return_status		=> l_return_status,
       x_msg_count		=> l_msg_count,
       x_msg_data		=> l_msg_data,
       p_request_id		=> l_request_id,
       p_last_updated_by	=> l_user_id,
       p_last_update_date	=> sysdate,
       p_service_request_rec    => l_service_request_rec,
       p_notes                  => l_notes,
       p_contacts               => l_contacts,
       p_object_version_number  => l_object_version_number,
       p_resp_appl_id		=> l_resp_appl_id,
       p_resp_id		=> l_resp_id,
       x_interaction_id         => out_interaction_id,
       x_workflow_process_id    => out_wf_process_id
     );



-- Check for possible errors returned by the API
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	FND_MSG_PUB.Count_And_Get( p_count	=> l_msg_count,
				   p_data	=> l_msg_data,
				   p_encoded	=> FND_API.G_FALSE );
        wf_core.context( pkg_name	=>  'CS_ServiceRequest_PUB',
			 proc_name	=>  'Update_Status',
			 arg1		=>  'p_user_id=>'||l_user_id,
			 arg2		=>  'p_org_id=>'||l_org_id,
			 arg3		=>  'p_request_number=>'||l_request_number,
			 arg4		=>  'p_status_id=>'||l_new_status_id,
			 arg5		=>  'p_msg_data=>'||l_msg_data );
	l_errmsg_name := 'CS_SR_CANT_UPDATE_STATUS';
	raise l_API_ERROR;
      END IF;
/*
 This is the standard error handling but am retaining the older method
 as in earlier version
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
		raise FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
*/


/* for testng - error handling  when running SQL script you need this
   to see if Update_SR API is successful
    IF (FND_MSG_PUB.Count_Msg > 1) THEN
      --Display all the error messages
      FOR j in  1..FND_MSG_PUB.Count_Msg LOOP
        FND_MSG_PUB.Get(p_msg_index=>j,
                        p_encoded=>'F',
                        p_data=>l_msg_data,
                        p_msg_index_out=>l_msg_index_out);
        DBMS_OUTPUT.PUT_LINE(l_msg_data);
      END LOOP;
    ELSE
      --Only one error
      FND_MSG_PUB.Get(p_msg_index=>1,
                      p_encoded=>'F',
                      p_data=>l_msg_data,
                      p_msg_index_out=>l_msg_index_out);
      DBMS_OUTPUT.PUT_LINE(l_msg_data);
    END IF;

	--dbms_output.put_line(' after error mesg  ' || l_return_status );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	FND_MSG_PUB.Count_And_Get( p_count	=> l_msg_count,
				   p_data	=> l_msg_data,
				   p_encoded	=> FND_API.G_FALSE );
        wf_core.context( pkg_name	=>  'CS_ServiceRequest_PVT',
			 proc_name	=>  'Update_ServiceRequest',
			 arg1		=>  'p_user_id=>'||l_user_id,
			 arg2		=>  'p_org_id=>'||l_org_id,
			 arg3		=>  'p_request_number=>'||l_request_number,
			 arg4		=>  'p_status_id=>'||l_new_status_id,
			 arg5		=>  'p_msg_data=>'||l_msg_data );
	l_errmsg_name := 'CS_SR_CANT_UPDATE_STATUS';
	raise l_API_ERROR;
      END IF;
*/
--
      -- Update the item attribute
      SELECT name
      INTO   l_new_status
      FROM   cs_incident_statuses
      WHERE  incident_status_id  = 2;

      WF_ENGINE.SetItemAttrText(
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'REQUEST_STATUS',
			avalue		=> l_new_status );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
  /* for new error handling
  WHEN FND_API.G_EXC_ERROR THEN
  l_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get( p_count     => l_msg_count,
					    p_data          => l_msg_data,
					    p_encoded  => FND_API.G_FALSE );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get( p_count     => l_msg_count,
					    	 p_data          => l_msg_data,
						 p_encoded  => FND_API.G_FALSE );
 */
  WHEN l_API_ERROR THEN
      WF_CORE.Raise(l_errmsg_name);
  WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Update_Status',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Update_Status;



-- -------------------------------------------------------------------
-- Validate_Response_Deadline
--   Return 'N' if the RESPONSE_DEADLINE item attribute is NULL or if
--   it's less than sysdate; otherwise, return 'Y'.
-- -------------------------------------------------------------------

  PROCEDURE Validate_Response_Deadline(
			          itemtype      VARCHAR2,
				  itemkey	VARCHAR2,
				  actid	        NUMBER,
				  funmode	VARCHAR2,
				  result    OUT NOCOPY VARCHAR2 ) IS
    l_response_deadline	DATE;

  BEGIN
    IF (funmode = 'RUN') THEN

      -- Get the response deadline
      l_response_deadline := WF_ENGINE.GetItemAttrDate(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'RESPONSE_DEADLINE' );

      IF (l_response_deadline IS NULL) OR
         (l_response_deadline < sysdate) THEN
        result := 'COMPLETE:N';
      ELSE
        result := 'COMPLETE:Y';
      END IF;

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Validate_Response_Deadline',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Validate_Response_Deadline;


-- ---------------------------------------------------------------------------
-- Reset_Response_Deadline
--   This procedure corresponds to the RESET_RESPONSE_DEADLINE function
--   activity.  It resets the RESPONSE_DEADLINE item attribute back to NULL.
-- ---------------------------------------------------------------------------

  PROCEDURE Reset_Response_Deadline( itemtype     VARCHAR2,
                                     itemkey      VARCHAR2,
                                     actid        NUMBER,
                                     funmode      VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2 ) IS
  BEGIN
    IF (funmode = 'RUN') THEN

      -- Reset the response deadline to NULL
      WF_ENGINE.SetItemAttrDate(itemtype        => itemtype,
				itemkey         => itemkey,
				aname           => 'RESPONSE_DEADLINE',
                                avalue          => '' );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Reset_Response_Deadline',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Reset_Response_Deadline;



-- ***************************************************************************
-- *                                                                         *
-- *                           System: Error Item Type                       *
-- *                                                                         *
-- *  Following activities are used in the Service Request Error Process     *
-- *                                                                         *
-- ***************************************************************************


-- -------------------------------------------------------------------
-- Initialize_Errors
--   Retrieve the exception messages from the process that errored out
--   and store them in the item attributes of the error process.  Also,
--   get the role of the Workflow administrator.
-- -------------------------------------------------------------------

  PROCEDURE Initialize_Errors(    itemtype      VARCHAR2,
				  itemkey	VARCHAR2,
				  actid	        NUMBER,
				  funmode	VARCHAR2,
				  result    OUT NOCOPY VARCHAR2 ) IS

    l_error_item_type	VARCHAR2(8);
    l_error_itemkey	VARCHAR2(240);
    l_error_name	VARCHAR2(30);
    l_error_msg		VARCHAR2(2000);
    l_administrator	VARCHAR2(100);
    l_monitor_url	VARCHAR2(500);

  BEGIN
    IF (funmode = 'RUN') THEN

      --
      -- Get the type and the key of the process that errored out
      --
      l_error_itemkey := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_ITEM_KEY' );

      l_error_item_type := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_ITEM_TYPE' );

      --
      -- Get the error message
      --
      l_error_name := WF_ENGINE.GetItemAttrText(
				itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_NAME' );

      IF (l_error_name IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('CS', l_error_name);
        l_error_msg := FND_MESSAGE.GET;
      END IF;

      --
      -- Get the workflow administrator
      --
      l_administrator := WF_ENGINE.GetItemAttrText(
				itemtype	=> l_error_item_type,
				itemkey		=> l_error_itemkey,
				aname		=> 'WF_ADMINISTRATOR' );
      --
      -- Set the item attributes of the error process
      --
      WF_ENGINE.SetItemAttrText(itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'ERROR_MESSAGE',
				avalue		=> l_error_msg );

      WF_ENGINE.SetItemAttrText(itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'SERVEREQ_WF_ADMIN',
				avalue		=> l_administrator );

      l_monitor_url := WF_MONITOR.GetEnvelopeURL
		     ( x_agent		=> FND_PROFILE.Value('APPS_WEB_AGENT'),
		       x_item_type	=> l_error_item_type,
		       x_item_key	=> l_error_itemkey,
		       x_admin_mode	=> 'YES'
		     );
      WF_ENGINE.SetItemAttrText(itemtype	=> itemtype,
				itemkey		=> itemkey,
				aname		=> 'SERVEREQ_MONITOR_URL',
				avalue		=> l_monitor_url );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Initialize_Errors',
		      itemtype, itemkey, actid, funmode);
      RAISE;
  END Initialize_Errors;



-- ***************************************************************************
-- *									     *
-- *			Service Request Action Item Type		     *
-- *									     *
-- ***************************************************************************

------------------------------------------------------------------------------
-- Action_Selector
--   This procedure sets up the responsibility and organization context for
--   multi-org sensitive code.
------------------------------------------------------------------------------

PROCEDURE Action_Selector
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	NOCOPY VARCHAR2
)
IS
  l_user_id		NUMBER;
  l_resp_id		NUMBER;
  l_resp_appl_id	NUMBER;
BEGIN

  IF (funcmode = 'RUN') THEN
    result := 'COMPLETE';

  -- Engine calls SET_CTX just before activity execution
  ELSIF (funcmode = 'SET_CTX') THEN

    -- First get the user id, resp id, and appl id
    l_user_id := WF_ENGINE.GetItemAttrNumber
		   ( itemtype	=> itemtype,
		     itemkey	=> itemkey,
		     aname	=> 'USER_ID'
		   );
    l_resp_id := WF_ENGINE.GetItemAttrNumber
		   ( itemtype	=> itemtype,
		     itemkey	=> itemkey,
		     aname	=> 'RESP_ID'
		   );
    l_resp_appl_id := WF_ENGINE.GetItemAttrNumber
			( itemtype	=> itemtype,
			  itemkey	=> itemkey,
			  aname		=> 'RESP_APPL_ID'
			);

    -- Set the database session context
    FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

    result := 'COMPLETE';

  -- Notification Viewer form calls TEST_CTX just before launching a form
  ELSIF (funcmode = 'TEST_CTX') THEN
    result := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Action_Selector',
		    itemtype, itemkey, actid, funcmode);
    RAISE;
END Action_Selector;


------------------------------------------------------------------------------
-- Initialize_Action
--   This procedure initializes the item attributes that will remain constant
--   over the duration of the Workflow.  These attributes include
--   REQUEST_ACTION_ID, REQUEST_ID, REQUEST_NUMER, ACTION_NUMBER, ACTION_DATE,
--   ACTION_TYPE, ACTION_STATUS, ACTION_SEVERITY, ASSIGNEE_ID, ASSIGNEE_ROLE,
--   ASSIGNEE_NAME, ACTION_SUMMARY, REQUEST_CUSTOMER, CUSTOMER_PRODUCT_ID,
--   INVENTORY_ITEM_ID, PRODUCT_DESCRIPTION, REQUEST_LOCAION,
--   ACTION_DESCRIPTION, and EXPECTED_RESOLUTION_DATE.
------------------------------------------------------------------------------

/*PROCEDURE Initialize_Action
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	VARCHAR2
)
IS
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_errmsg_name		VARCHAR2(30);
  l_request_id		NUMBER;
  l_action_number	NUMBER;
  l_dummy		NUMBER;
  l_assignee_role	VARCHAR2(100);
  l_assignee_name	VARCHAR2(240);

  l_exc_api_error	EXCEPTION;

  CURSOR l_action_csr IS
    SELECT *
    FROM   cs_inc_actions_workflow_v
    WHERE  incident_id = l_request_id
    AND    action_number = l_action_number;
  l_action_rec	 	l_action_csr%ROWTYPE;

BEGIN
  IF (funcmode = 'RUN') THEN

    -- Decode the item key to get the service request id and action number
    CS_Workflow_PUB.Decode_Action_Itemkey
      (	p_api_version	=> 1.0,
	p_return_status	=> l_return_status,
	p_msg_count	=> l_msg_count,
	p_msg_data	=> l_msg_data,
	p_itemkey	=> itemkey,
	p_request_id	=> l_request_id,
	p_action_number	=> l_action_number,
	p_wf_process_id	=> l_dummy
      );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MSG_PUB.Count_And_Get( p_count	=> l_msg_count,
				 p_data		=> l_msg_data,
				 p_encoded	=> FND_API.G_FALSE );
      WF_CORE.Context( pkg_name		=> 'CS_Workflow_PUB',
		       proc_name	=> 'Decode_Action_Itemkey',
		       arg1		=> 'p_itemkey=>'||itemkey,
		       arg2		=> 'p_msg_data=>'||l_msg_data );
      l_errmsg_name := 'CS_WF_SR_CANT_DECODE_ITEMKEY';
      RAISE l_exc_api_error;
    END IF;

    -- Extract the service request action record
    OPEN l_action_csr;
    FETCH l_action_csr INTO l_action_rec;
    CLOSE l_action_csr;

    --
    -- Set request ID first, in case if error occur, the workflow
    -- administrator can drilldown to the service request form from the error
    -- notification
    --
    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'REQUEST_ID',
	avalue		=> l_action_rec.incident_id
      );

    -- Retrieve the role name for the request action assignee
    CS_Workflow_PUB.Get_Employee_Role
      (	p_api_version		=> 1.0,
	p_return_status		=> l_return_status,
	p_msg_count		=> l_msg_count,
	p_msg_data		=> l_msg_data,
	p_employee_id		=> l_action_rec.action_assignee_id,
	p_role_name		=> l_assignee_role,
	p_role_display_name	=> l_assignee_name
      );
    IF ((l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
        (l_assignee_role IS NULL)) THEN
      FND_MSG_PUB.Count_And_Get( p_count	=> l_msg_count,
				 p_data		=> l_msg_data,
				 p_encoded	=> FND_API.G_FALSE );
      WF_CORE.Context( pkg_name	 => 'CS_Workflow_PUB',
		       proc_name => 'Get_Employee_Role',
		       arg1	 => 'p_employee_id=>'||l_action_rec.action_assignee_id,
		       arg2	 => 'p_msg_data=>'||l_msg_data );
      l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
      RAISE l_exc_api_error;
    END IF;

    -- Initialize item attributes that will remain constant
    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'REQUEST_ACTION_ID',
	avalue		=> l_action_rec.incident_action_id
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'REQUEST_NUMBER',
	avalue		=> l_action_rec.incident_number
      );

    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_NUMBER',
	avalue		=> l_action_rec.action_number
      );

    WF_ENGINE.SetItemAttrDate
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_DATE',
	avalue		=> l_action_rec.action_date
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_TYPE',
	avalue		=> l_action_rec.action_type
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_STATUS',
	avalue		=> l_action_rec.action_status
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_SEVERITY',
	avalue		=> l_action_rec.action_severity
      );

    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ASSIGNEE_ID',
	avalue		=> l_action_rec.action_assignee_id
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ASSIGNEE_ROLE',
	avalue		=> l_assignee_role
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ASSIGNEE_NAME',
	avalue		=> l_assignee_name
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_SUMMARY',
	avalue		=> l_action_rec.action_summary
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'REQUEST_CUSTOMER',
	avalue		=> l_action_rec.incident_customer
      );

    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'CUSTOMER_PRODUCT_ID',
	avalue		=> l_action_rec.customer_product_id
      );

    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'INVENTORY_ITEM_ID',
	avalue		=> l_action_rec.inventory_item_id
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'PRODUCT_DESCRIPTION',
	avalue		=> l_action_rec.product_description
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'REQUEST_LOCATION',
	avalue		=> l_action_rec.incident_location
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'ACTION_DESCRIPTION',
	avalue		=> l_action_rec.action_description
      );

    WF_ENGINE.SetItemAttrDate
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'EXPECTED_RESOLUTION_DATE',
	avalue		=> l_action_rec.expected_resolution_date
      );

    result := 'COMPLETE';

  ELSIF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE';
  END IF;

EXCEPTION
  WHEN l_exc_api_error THEN
    WF_CORE.Raise(l_errmsg_name);
  WHEN OTHERS THEN
    WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Initialize_Action',
		    itemtype, itemkey, actid, funcmode);
    RAISE;
END Initialize_Action;*/


----------------------------------------------------------------------
-- Is_Launched_From_Dispatch
--   Return 'Y' if the Workflow is launched from the Field Service
--   Dispatch Window; otherwise, return 'N'.
----------------------------------------------------------------------

PROCEDURE Is_Launched_From_Dispatch
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	NOCOPY VARCHAR2
)
IS
  l_launched_by_dispatch	VARCHAR2(1);
BEGIN
  IF (funcmode = 'RUN') THEN
    l_launched_by_dispatch := WF_ENGINE.GetItemAttrText
				( itemtype	=> itemtype,
				  itemkey	=> itemkey,
				  aname		=> 'LAUNCHED_BY_DISPATCH'
				);
    IF FND_API.To_Boolean(l_launched_by_dispatch) THEN
      result := 'COMPLETE:Y';
    ELSE
      result := 'COMPLETE:N';
    END IF;

  ELSIF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Is_Launched_From_Dispatch',
		    itemtype, itemkey, actid, funcmode);
    RAISE;
END Is_Launched_From_Dispatch;


--------------------------------------------------------------------------
-- Get_Dispatcher_Info
--   Populate the item attributes with info of the dispatch person from
--   the database.
--------------------------------------------------------------------------

/*PROCEDURE Get_Dispatcher_Info
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	VARCHAR2
)
IS
  l_request_id		NUMBER;
  l_action_number	NUMBER;
  l_orig_system		VARCHAR2(14);
  l_orig_system_id	NUMBER;
  l_role_name		VARCHAR2(100);
  l_display_name	VARCHAR2(240);
  l_errmsg_name		VARCHAR2(30);

  CURSOR l_action_csr IS
    SELECT dispatcher_orig_syst, dispatcher_orig_syst_id, dispatch_role_name
    FROM   cs_inc_actions_workflow_v
    WHERE  incident_id = l_request_id
    AND    action_number = l_action_number;

  CURSOR l_dispatch_csr IS
    SELECT display_name
    FROM   wf_roles
    WHERE  name = l_role_name;

  l_exc_invalid_role	EXCEPTION;

BEGIN
  IF (funcmode = 'RUN') THEN
    -- Get the service request ID and action number
    l_request_id := WF_ENGINE.GetItemAttrText
		      (	itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'REQUEST_ID'
		      );
    l_action_number := WF_ENGINE.GetItemAttrText
			 ( itemtype	=> itemtype,
			   itemkey	=> itemkey,
			   aname	=> 'ACTION_NUMBER'
			 );

    -- Extract the info of the dispatch person
    OPEN l_action_csr;
    FETCH l_action_csr INTO l_orig_system, l_orig_system_id, l_role_name;
    CLOSE l_action_csr;

    -- Retrieve the display name for the dispatch person
    -- Make sure the dispatch role is defined in the Workflow directory
    OPEN l_dispatch_csr;
    FETCH l_dispatch_csr INTO l_display_name;
    IF (l_dispatch_csr%NOTFOUND) THEN
      CLOSE l_dispatch_csr;
      l_errmsg_name := 'CS_WF_SR_CANT_FIND_DISPATCHER';
      RAISE l_exc_invalid_role;
    END IF;
    CLOSE l_dispatch_csr;

    -- Update service request action item attributes
    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'DISPATCHER_ORIG_SYST',
	avalue		=> l_orig_system
      );

    WF_ENGINE.SetItemAttrNumber
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'DISPATCHER_ORIG_SYST_ID',
	avalue		=> l_orig_system_id
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'DISPATCHER_ROLE',
	avalue		=> l_role_name
      );

    WF_ENGINE.SetItemAttrText
      (	itemtype	=> itemtype,
	itemkey		=> itemkey,
	aname		=> 'DISPATCHER_NAME',
	avalue		=> l_display_name
      );

    result := 'COMPLETE';

  ELSIF (funcmode = 'CANCEL') THEN
    result := 'COMPLETE';
  END IF;

EXCEPTION
  WHEN l_exc_invalid_role THEN
    WF_CORE.Raise(l_errmsg_name);
  WHEN OTHERS THEN
    WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'Get_Dispatcher_Info',
		    itemtype, itemkey, actid, funcmode);
    RAISE;
END Get_Dispatcher_Info;*/

-- ***************************************************************************
-- *									     *
-- *			   FIELD SERVICE DISPATCH ACTIVITIES                 *
-- *									     *
-- ***************************************************************************

PROCEDURE IS_MOBILE_INSTALLED (
	itemtype	IN	VARCHAR2,
  	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	NOCOPY VARCHAR2
) IS
  l_mobile_installed	VARCHAR2(1);
BEGIN
  	IF (funcmode = 'RUN') THEN
		SELECT NVL(UPPER(USE_MOBILE_FLD_SRV_FLAG) , 'N')
		INTO  l_mobile_installed
		FROM CS_SYSTEM_PARAMETERS;

    		IF l_mobile_installed = 'Y' THEN
      			result := 'COMPLETE:Y';
    		ELSE
      			result := 'COMPLETE:N';
    		END IF;

  	ELSIF (funcmode = 'CANCEL') THEN
    		result := 'COMPLETE';
  	END IF;

EXCEPTION
  	WHEN OTHERS THEN
    		WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'IS_MOBILE_INSTALLED',
		    itemtype, itemkey, actid, funcmode);
    	RAISE;
END IS_MOBILE_INSTALLED;


/*PROCEDURE IS_ACTION_CLOSED (
	itemtype	IN	VARCHAR2,
  	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	VARCHAR2
) IS
	l_request_id	CS_INCIDENT_ACTIONS.INCIDENT_ID%TYPE;
	l_action_number	CS_INCIDENT_ACTIONS.ACTION_NUM%TYPE;
	l_close_flag	CS_INCIDENT_STATUSES.CLOSE_FLAG%TYPE;

	CURSOR l_stat_cur IS
    	SELECT b.close_flag
    	FROM   CS_INCIDENT_ACTIONS a, CS_INCIDENT_STATUSES b
   	WHERE  a.incident_id = l_request_id AND
		a.action_num = l_action_number AND
		a.action_status_id = b.incident_status_id;

BEGIN
  	IF (funcmode = 'RUN') THEN
    		-- Get the service request ID and action number
    		l_request_id := WF_ENGINE.GetItemAttrText (
			itemtype	=> itemtype,
			itemkey		=> itemkey,
			aname		=> 'REQUEST_ID');

    		l_action_number := WF_ENGINE.GetItemAttrText (
			itemtype	=> itemtype,
		   	itemkey		=> itemkey,
		   	aname		=> 'ACTION_NUMBER');

		OPEN  l_stat_cur;
		FETCH l_stat_cur INTO l_close_flag;
		CLOSE l_stat_cur;

    		IF l_close_flag = 'Y' THEN
      			result := 'COMPLETE:Y';
    		ELSE
      			result := 'COMPLETE:N';
    		END IF;

  	ELSIF (funcmode = 'CANCEL') THEN
    		result := 'COMPLETE';
  	END IF;

EXCEPTION
  	WHEN OTHERS THEN
	IF l_stat_cur%ISOPEN THEN
		CLOSE l_stat_cur;
	END IF;

    	WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'IS_ACTION_CLOSED',
		    itemtype, itemkey, actid, funcmode);
    	RAISE;
END IS_ACTION_CLOSED;*/

PROCEDURE IS_FS_INSERT (
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	NOCOPY VARCHAR2
) IS
	l_fs_mode		VARCHAR2(10) := NULL;
BEGIN

	--- This attribute identifies whether to do insert or update
	--- on the interface table

	l_fs_mode := WF_ENGINE.GetItemAttrText (
			itemtype	=> itemtype,
		     	itemkey		=> itemkey,
		     	aname		=> 'FS_INTERFACE_MODE');
	IF (funcmode = 'RUN') THEN

		IF l_fs_mode is NULL THEN
      			result := 'COMPLETE:Y';
		ELSE
      			result := 'COMPLETE:N';
    		END IF;
	ELSIF (funcmode = 'CANCEL') THEN
    		result := 'COMPLETE';
  	END IF;
EXCEPTION
  	WHEN OTHERS THEN
    	WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'IS_FS_INSERT',
		    itemtype, itemkey, actid, funcmode);
    	RAISE;
END IS_FS_INSERT;


-- Removed on 12/22/1999 since table CS_MFS_INTERFACE table is no longer present.
/*PROCEDURE INSERT_FS_INTERFACE (
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	VARCHAR2) IS

	action_rec fs_action_csr%ROWTYPE;
	l_fs_interface_id	NUMBER;

	ACTION_NOT_FOUND 	EXCEPTION;
  	l_errmsg_name		VARCHAR2(30);
	l_incident_id		NUMBER;
	l_incident_action_id	NUMBER;
	l_response              VARCHAR2(80) := NULL ;
BEGIN
	l_incident_id := WF_ENGINE.GetItemAttrNumber (
			itemtype	=> itemtype,
		     	itemkey		=> itemkey,
		     	aname		=> 'REQUEST_ID');

	l_incident_action_id := WF_ENGINE.GetItemAttrNumber (
			itemtype	=> itemtype,
		     	itemkey		=> itemkey,
		     	aname		=> 'REQUEST_ACTION_ID');


	OPEN fs_action_csr(l_incident_id, l_incident_action_id);
	FETCH fs_action_csr into action_rec;

	IF fs_action_csr%NOTFOUND THEN
       		wf_core.context(
			pkg_name	=>  'CS_WF_ACTIVITIES_PKG',
		 	proc_name	=>  'INSERT_FS_INTERFACE',
		 	arg1		=>  'p_itemkey=>'||itemkey );
		l_errmsg_name := 'CS_WF_SR_ACTION_NOT_FOUND';
			RAISE ACTION_NOT_FOUND;
	END IF;

	SELECT CS_MFS_INTERFACE_S.nextval
		INTO l_fs_interface_id FROM DUAL;

	INSERT INTO CS_MFS_INTERFACE
	(
		FIELD_SERVICE_INTERFACE_ID,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		STATUS_FLAG,
		ORG_ID,
		INCIDENT_NUMBER,
		ACTION_NUM,
		INCIDENT_DATE,
		BUSINESS_PROCESS_ID,
		PROBLEM_CODE,
		PROBLEM_DESCRIPTION,
		RESOLUTION_CODE,
		RESOLUTION_DESCRIPTION,
		INCIDENT_URGENCY_ID,
		URGENCY,
		INCIDENT_STATUS_ID,
		STATUS_CODE,
		STATUS_DATE,
		INCIDENT_TYPE_ID,
		INCIDENT_TYPE,
		DISPATCHER_ID,
		DISPATCHER_NAME,
		COVERED_BY_CONTRACT,
		CURRENT_CONTACT_NAME,
		CURRENT_CONTACT_TELEPHONE,
		CURRENT_CONTACT_AREA_CODE,
		CURRENT_CONTACT_EXTENSION,
		CURRENT_CONTACT_FAX_NUMBER,
		CURRENT_CONTACT_FAX_AREA_CODE,
		CURRENT_CONTACT_EMAIL_ADDRESS,
		SHIP_TO_ADDRESS_LINE1,
		SHIP_TO_ADDRESS_LINE2,
		POSTAL_CODE,
		CITY,
		STATE,
		COUNTRY,
		START_TIME,
		END_TIME,
		EARLIEST_START_TIME,
		LATEST_FINISH_TIME,
		APPOINTMENT,
		REQUEST_DURATION,
		EMPLOYEE_ID,
		EMPLOYEE_NAME,
		CUSTOMER_ID,
		CUSTOMER_NUMBER,
		--CUSTOMER_NAME,
		INVENTORY_ITEM_ID,
		PRODUCT,
		PRODUCT_DESCRIPTION,
		ORGANIZATION_ID,
		REFERENCE_NUMBER,
		CURRENT_SERIAL_NUMBER,
		INSTALLATION_DATE,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		CONTEXT,
                SR_PROBLEM_DESCRIPTION,
                SR_RESOLUTION_DESCRIPTION,
		incident_severity_id,
		incident_severity_name,
		inc_prob_description,
		action_status_id,
		problem_summary)
	VALUES(
		l_fs_interface_id,
		sysdate,
		FND_GLOBAL.user_id,
		sysdate,
		FND_GLOBAL.user_id,
		FND_GLOBAL.login_id,
		'1',
		NULL,
		action_rec.incident_number,
		action_rec.action_num,
		action_rec.incident_date,
		action_rec.business_process_id,
		action_rec.problem_code,
		--action_rec.problem_description,
		action_rec.resolution_code,
		action_rec.resolution_description,
		action_rec.incident_urgency_id,
		action_rec.urgency,
		action_rec.INCIDENT_STATUS_ID,
		action_rec.STATUS_CODE,
		action_rec.status_date,
		action_rec.incident_type_id,
		action_rec.incident_type,
		action_rec.dispatcher_id,
		action_rec.dispatcher_name,
		action_rec.covered_by_contract,
		action_rec.current_contact_name,
		action_rec.current_contact_telephone,
		action_rec.current_contact_area_code,
		action_rec.current_contact_extension,
		action_rec.current_contact_fax_number,
		action_rec.current_contact_fax_area_code,
		action_rec.current_contact_email_address,
		action_rec.ship_to_address_line1,
		action_rec.ship_to_address_line2,
		action_rec.postal_code,
		action_rec.city,
		action_rec.state,
		action_rec.country,
		action_rec.start_time,
		action_rec.end_time,
		action_rec.earliest_start_time,
		action_rec.latest_finish_time,
		action_rec.appointment,
		action_rec.request_duration,
		action_rec.employee_id,
		wf_directory.getroledisplayname(action_rec.employee_name),
		action_rec.customer_id,
		action_rec.customer_number,
		--action_rec.customer_name,
		action_rec.inventory_item_id,
		action_rec.product,
		action_rec.product_description,
		action_rec.organization_id,
		action_rec.reference_number,
		action_rec.current_serial_number,
		action_rec.installation_date,
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
		NULL,
		NULL,
            --    action_rec.sr_problem_description,
                action_rec.sr_resolution_description,
		action_rec.incident_severity_id,
		action_rec.incident_severity_name,
		action_rec.inc_prob_description,
		action_rec.action_status_id,
		action_rec.problem_summary);
	-- Set the mode to updated to have the workflow update this record
	-- when it loops through next time

	WF_ENGINE.SetItemAttrText(
		itemtype	=> itemtype,
		itemkey		=> itemkey,
		aname		=> 'FS_INTERFACE_MODE',
		avalue		=> 'CREATED');

	WF_ENGINE.SetItemAttrNumber(
		itemtype	=> itemtype,
		itemkey		=> itemkey,
		aname		=> 'FS_INTERFACE_ID',
		avalue		=> l_fs_interface_id);
	CLOSE fs_action_csr;
EXCEPTION
    	WHEN ACTION_NOT_FOUND THEN
      		WF_CORE.Raise(l_errmsg_name);
		IF fs_action_csr%ISOPEN THEN
			CLOSE fs_action_csr;
		END IF;
  	WHEN OTHERS THEN
    		WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'INSERT_FS_INTERFACE',
		    itemtype, itemkey, actid, funcmode);
		IF fs_action_csr%ISOPEN THEN
			CLOSE fs_action_csr;
		END IF;
    		RAISE;
END INSERT_FS_INTERFACE;*/

/*PROCEDURE UPDATE_FS_INTERFACE (
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	VARCHAR2) IS

	action_rec fs_action_csr%ROWTYPE;
	l_fs_interface_id	NUMBER;

	ACTION_NOT_FOUND 	EXCEPTION;
  	l_errmsg_name		VARCHAR2(30);
	l_incident_id		NUMBER;
	l_incident_action_id	NUMBER;

BEGIN
	l_incident_id := WF_ENGINE.GetItemAttrNumber (
			itemtype	=> itemtype,
		     	itemkey		=> itemkey,
		     	aname		=> 'REQUEST_ID');

	l_incident_action_id := WF_ENGINE.GetItemAttrNumber (
			itemtype	=> itemtype,
		     	itemkey		=> itemkey,
		     	aname		=> 'REQUEST_ACTION_ID');


	OPEN fs_action_csr(l_incident_id, l_incident_action_id);
	FETCH fs_action_csr into action_rec;

	IF fs_action_csr%NOTFOUND THEN
       		wf_core.context(
			pkg_name	=>  'CS_WF_ACTIVITIES_PKG',
		 	proc_name	=>  'UPDATE_FS_INTERFACE',
		 	arg1		=>  'p_itemkey=>'||itemkey );
		l_errmsg_name := 'CS_WF_SR_ACTION_NOT_FOUND';
			RAISE ACTION_NOT_FOUND;
	END IF;

	l_fs_interface_id := WF_ENGINE.GetItemAttrNumber (
			itemtype	=> itemtype,
		     	itemkey		=> itemkey,
		     	aname		=> 'FS_INTERFACE_ID');

	UPDATE CS_MFS_INTERFACE
	SET
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = FND_GLOBAL.user_id,
		LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
		STATUS_FLAG = 1,
		INCIDENT_NUMBER =action_rec.incident_number,
		ACTION_NUM =action_rec.action_num,
		INCIDENT_DATE =action_rec.incident_date,
		BUSINESS_PROCESS_ID =action_rec.business_process_id,
		PROBLEM_CODE =action_rec.problem_code,
		--PROBLEM_DESCRIPTION =action_rec.problem_description,
		RESOLUTION_CODE =action_rec.resolution_code,
		RESOLUTION_DESCRIPTION =action_rec.resolution_description,
		INCIDENT_URGENCY_ID =action_rec.incident_urgency_id,
		URGENCY =action_rec.urgency,
		INCIDENT_STATUS_ID =action_rec.INCIDENT_STATUS_ID,
		STATUS_CODE =action_rec.STATUS_CODE,
		STATUS_DATE =action_rec.status_date,
		INCIDENT_TYPE_ID =action_rec.incident_type_id,
		INCIDENT_TYPE =action_rec.incident_type,
		DISPATCHER_ID =	action_rec.dispatcher_id,
		DISPATCHER_NAME =	action_rec.dispatcher_name,
		COVERED_BY_CONTRACT =action_rec.covered_by_contract,
		CURRENT_CONTACT_NAME =	action_rec.current_contact_name,
		CURRENT_CONTACT_TELEPHONE =	action_rec.current_contact_telephone,
		CURRENT_CONTACT_AREA_CODE =	action_rec.current_contact_area_code,
		CURRENT_CONTACT_EXTENSION =action_rec.current_contact_extension,
		CURRENT_CONTACT_FAX_NUMBER =action_rec.current_contact_fax_number,
		CURRENT_CONTACT_FAX_AREA_CODE =action_rec.current_contact_fax_area_code,
		CURRENT_CONTACT_EMAIL_ADDRESS =action_rec.current_contact_email_address,
		SHIP_TO_ADDRESS_LINE1 =action_rec.ship_to_address_line1,
		SHIP_TO_ADDRESS_LINE2 =	action_rec.ship_to_address_line2,
		POSTAL_CODE =action_rec.postal_code,
		CITY =action_rec.city,
		STATE =action_rec.state,
		COUNTRY =action_rec.country,
		START_TIME =action_rec.start_time,
		END_TIME =action_rec.end_time,
		EARLIEST_START_TIME =action_rec.earliest_start_time,
		LATEST_FINISH_TIME =action_rec.latest_finish_time,
		APPOINTMENT =action_rec.appointment,
		REQUEST_DURATION =action_rec.request_duration,
		EMPLOYEE_ID =action_rec.employee_id,
		EMPLOYEE_NAME =wf_directory.getroledisplayname(action_rec.employee_name),
		CUSTOMER_ID =action_rec.customer_id,
		CUSTOMER_NUMBER =action_rec.customer_number,
		--CUSTOMER_NAME =action_rec.customer_name,
		INVENTORY_ITEM_ID =action_rec.inventory_item_id,
		PRODUCT =action_rec.product,
		PRODUCT_DESCRIPTION =action_rec.product_description,
		ORGANIZATION_ID =	action_rec.organization_id,
		REFERENCE_NUMBER =action_rec.reference_number,
		CURRENT_SERIAL_NUMBER =action_rec.current_serial_number,
		INSTALLATION_DATE =action_rec.installation_date
	WHERE FIELD_SERVICE_INTERFACE_ID = l_fs_interface_id;

	WF_ENGINE.SetItemAttrText(
		itemtype	=> itemtype,
		itemkey		=> itemkey,
		aname		=> 'FS_INTERFACE_MODE',
		avalue		=> 'UPDATED');
	CLOSE fs_action_csr;

EXCEPTION
    	WHEN ACTION_NOT_FOUND THEN
      		WF_CORE.Raise(l_errmsg_name);
		IF fs_action_csr%ISOPEN THEN
			CLOSE fs_action_csr;
		END IF;
  	WHEN OTHERS THEN
    		WF_CORE.Context('CS_WF_ACTIVITIES_PKG', 'UPDATE_FS_INTERFACE',
		    itemtype, itemkey, actid, funcmode);
		IF fs_action_csr%ISOPEN THEN
			CLOSE fs_action_csr;
		END IF;
    		RAISE;
END UPDATE_FS_INTERFACE;*/



/*PROCEDURE SET_FS_WF_RESPONSE(
	p_incident_number  	IN NUMBER,
	p_action_number		IN NUMBER,
	p_response 		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2) IS

	l_wf_id          NUMBER ;
	l_wf_key         VARCHAR2(2000) ;
	l_wf_active      VARCHAR2(1) := NULL ;
	WF_NOT_ACTIVE	EXCEPTION;
	l_incident_id	CS_INCIDENTS.INCIDENT_ID%TYPE;
	x_msg_count	NUMBER;

BEGIN
	-- Initialize the return status to Success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	SELECT inc.incident_id,
		act.workflow_process_id,
		CS_WORKFLOW_PKG.IS_ACTION_ITEM_ACTIVE(
                                    act.incident_id,
                                    act.action_num,
                                    act.workflow_process_id)
    	INTO   l_incident_id,l_wf_id,l_wf_active
    	FROM   CS_INCIDENT_ACTIONS ACT, CS_INCIDENTS_ALL_B INC
    	WHERE  inc.incident_id = act.incident_id
	AND inc.incident_number = p_incident_number
    	AND act.action_num  = p_action_number ;

 	l_wf_key := to_char(l_incident_id) || '-' ||
                 to_char(p_action_number)  || '-' || to_char(l_wf_id) ;
	--dbms_output.put_line('ACTIVE ' || l_wf_active || ' ' || l_wf_key);

     	IF l_wf_active = 'Y' THEN
     		WF_ENGINE.CompleteActivity (
          		itemtype 	=> g_fs_itemtype,
          		itemkey 	=> l_wf_key,
          		activity 	=> g_fs_activity,
          		result 		=> p_response);
	ELSE
		RAISE WF_NOT_ACTIVE;
     	END IF ;

EXCEPTION
     WHEN WF_NOT_ACTIVE THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.Set_Name('CS', 'CS_SR_WORKFLOW_NOT_ACTIVE');
	FND_MSG_PUB.Add;
      	FND_MSG_PUB.Count_And_Get(
			p_count		=> x_msg_count,
	         	p_data		=> x_msg_data,
		 	p_encoded	=> FND_API.G_FALSE );
     WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.Set_Name('CS', sqlerrm);
	FND_MSG_PUB.Add;
      	FND_MSG_PUB.Count_And_Get(
			p_count		=> x_msg_count,
	         	p_data		=> x_msg_data,
		 	p_encoded	=> FND_API.G_FALSE );

END SET_FS_WF_RESPONSE; */

-- ---------------------------
-- Initialization of package
-- ---------------------------

BEGIN

  --
  -- We need to get the audit comments from the message dictionary
  -- due to translation issues
  --
  FND_MESSAGE.Set_Name('CS', 'CS_WF_AUDIT_COMMENTS');
  CS_WF_ACTIVITIES_PKG.Audit_Comments := FND_MESSAGE.Get;

END CS_WF_ACTIVITIES_PKG;

/
