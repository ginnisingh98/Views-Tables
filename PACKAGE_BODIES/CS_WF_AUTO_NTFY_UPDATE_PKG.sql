--------------------------------------------------------
--  DDL for Package Body CS_WF_AUTO_NTFY_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_WF_AUTO_NTFY_UPDATE_PKG" AS
/* $Header: cswfautb.pls 120.19.12010000.2 2009/07/22 15:30:26 gasankar ship $ */

-- --------------------------------------
-- Constants used in this package
-- --------------------------------------

-- cs_newline varchar2(1) := chr(10);
cs_delimiter varchar2(1) := ' ';
l_amp        VARCHAR2(8) := fnd_global.local_chr(38);
l_new_line   VARCHAR2(8) := fnd_global.newline;
dbg_msg      VARCHAR2(4000);

/****************************************************************************
                            Forward Declaration
 ****************************************************************************/

  PROCEDURE pull_from_list(itemlist	IN OUT	NOCOPY	VARCHAR2,
			    element	OUT	NOCOPY	VARCHAR2);

  PROCEDURE SetWorkflowAdhocUser(
			p_wf_username	IN OUT NOCOPY VARCHAR2,
			p_email_address IN VARCHAR2,
			p_display_name	IN VARCHAR2 DEFAULT NULL);

  PROCEDURE SetWorkflowAdhocRole(
                        p_wf_rolename   IN OUT NOCOPY VARCHAR2,
                        p_user_list     IN VARCHAR2) ;

   PROCEDURE Set_HTML_Notification_Details
              ( p_itemtype         IN        VARCHAR2,
                p_itemkey          IN        VARCHAR2,
                p_actid            IN        NUMBER,
                p_funmode          IN        VARCHAR2,
                p_contact_type     IN        VARCHAR2,
                p_contact_id       IN        NUMBER,
                p_request_id       IN        NUMBER,
		p_request_number   IN        VARCHAR2,
 	        p_sender           IN        VARCHAR2,
                p_email_preference IN        VARCHAR2,
                p_user_language    IN        VARCHAR2,
	        p_recipient        IN        VARCHAR2,
    		p_message_name     IN        VARCHAR2,
		p_from_status      IN        VARCHAR2,
		p_to_status        IN        VARCHAR2) ;

PROCEDURE Create_Role_List
              ( p_itemtype         IN        VARCHAR2,
                p_itemkey          IN        VARCHAR2,
                p_actid            IN        NUMBER,
                p_funmode          IN        VARCHAR2,
                p_action_code      IN        VARCHAR2,
                p_role_group_type  IN        VARCHAR2,
                p_role_group_code  IN        VARCHAR2);

-- ***************************************************************************
-- *									     *
-- *			   Service Request Item Type			     *
-- *									     *
-- ***************************************************************************

--                   -----------------------------------------
--                   |             PUBLIC SECTION            |
--                   | Following procedures are customizable |
--                   -----------------------------------------
--

  /*****************************************************************************
  -- Check_Rules_For_Event
  --   This procedure corresponds to the CHECK_RULES_FOR_EVENT function
  --   activity.
  --   This procedure checks for ALL rules defined for a given business event
  --   If there are any valid rules defined, then we continue with the process
  --   flow, otherwise we immediately go to the END activity.
  --
  --  Modification History:
  --
  --  Date        Name       Desc
  --  ----------  ---------  ---------------------------------------------
  --  09/07/04	  RMANABAT   Fix for bug 3871457. In cursors sel_primary_contact_csr,
  --			     sel_all_contacts_csr, and sel_all_contacts_csr, changed
  --			     SELECT null notification_template_id to
  --			     SELECT to_char(null) notification_template_id.
  --
  --  27-Jul-05   ANEEMUCH   Rel 12.0 changes.
  --
  *****************************************************************************/

  PROCEDURE Check_Rules_For_Event( itemtype   IN  VARCHAR2,
                                   itemkey    IN  VARCHAR2,
                                   actid      IN  NUMBER,
                                   funmode    IN  VARCHAR2,
                                   result     OUT NOCOPY VARCHAR2 ) IS

    l_event_name		VARCHAR2(240);
    --l_action_code		VARCHAR2(30);
    l_request_number    	VARCHAR2(64);
    l_request_id		NUMBER;
    --l_event_condition_id        CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_event_condition_id        VARCHAR2(30);
    l_action_code       	CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_notify_conditions_list	VARCHAR2(4000);
    l_notify_actions_list	VARCHAR2(4000);
    l_update_conditions_list	VARCHAR2(4000);
    l_update_actions_list	VARCHAR2(4000);
    l_list_element		VARCHAR2(60);
    l_ntfy_template_id		NUMBER;
    l_wf_manual_launch		VARCHAR2(1);

    l_API_ERROR                 EXCEPTION;


    CURSOR sel_action_csr IS
      -- This part of the query is for Update Rules
      SELECT csad.event_condition_id,
             csad.action_code,
	     to_char(null) notification_template_id,
	     to_char(csad.event_condition_id) || csad.action_code index_cols,
             to_char(null) role_group_type,
             to_char(null) role_group_code
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csat.from_to_status_code IS NULL
          and (csad.incident_status_id IS NOT NULL OR
               csad.resolution_code IS NOT NULL)
          and csat.relationship_type_id IN
		( select cil.link_type_id
	          FROM cs_incident_links cil
	          WHERE cil.subject_id = l_request_id)
          -- We need to add this to differentiate it from notification rules.
          -- We may have a ntfxn rule without a template_id (partially created).
	  and csad.action_code NOT like 'NOTIFY%'
      UNION
      SELECT csad.event_condition_id,
             csad.action_code,
	     to_char(null) notification_template_id,
	     to_char(csad.event_condition_id) || csad.action_code index_cols,
             to_char(null) role_group_type,
             to_char(null) role_group_code
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csat.from_to_status_code IS NOT NULL
          and csat.relationship_type_id IS NULL
          and csat.incident_status_id IS NOT NULL
          -- We need to add this to differentiate it from notification rules.
          -- We may have a ntfxn rule without a template_id (partially created).
	  and csad.action_code NOT like 'NOTIFY%'
          and csad.relationship_type_id IN
		( select cil.link_type_id
	          FROM cs_incident_links cil
	          WHERE cil.subject_id = l_request_id)
	  /******************
	  -- For 11.5.9, we are not supporting any Update Rules defined by the user.
	  -- So csad.relationship_type_id will always have a value as defined from the
	  -- seeded Rule from HLD:
	  --   Rule 2: If the status of the service request changes to Closed,
  	  --      and it has a (outgoing) Root cause of relationship, then,
	  --      update status of all related service requests to Clear.
	  -- and csad.relationship_type_id IS NULL OR
	  ***************/
      -- This part of the query is for Notification Rules
      UNION
      SELECT csad.event_condition_id,
	     csad.action_code,
	     csad.notification_template_id,
	     to_char(csad.event_condition_id) || csad.action_code index_cols,
             role_group_type,
             role_group_code
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
/* 03/01/2004 - RHUNGUND - Bug fix for 3412833
   Commenting the following table from the FROM clause since it was resulting
   in a cartesian join

	   CS_SR_ACTION_CODES_B cac
*/
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csad.notification_template_id IS NOT NULL
          -- We need to add this since a notification rule can still be created (partially)
          -- without a message template.
	  and csad.action_code like 'NOTIFY%'

      ORDER BY index_cols;

      sel_action_rec	sel_action_csr%ROWTYPE;

    -- Fix similar to 11.5.9 bug 3106572. rmanabat 10/13/03.
    CURSOR sel_incident_id_csr IS
      SELECT INCIDENT_ID
      FROM cs_incidents_all_b
      WHERE INCIDENT_NUMBER = l_request_number;

    CURSOR sel_incident_number_csr IS
      SELECT INCIDENT_NUMBER
      FROM cs_incidents_all_b
      WHERE INCIDENT_ID = l_request_id;


/* RHUNGUND - 04/05/04
   Fix for bug 3528510
  The following cursor will catch the scenario if the "relationshipCreated" event is raised
  for a non-sr object. The wf should ignore link events raised for non-sr objects
  since suport for non-sr objects is not in current scope of this wf
*/

   CURSOR check_if_rel_is_sr_csr IS
	SELECT subject_type FROM
	cs_incident_links
 	WHERE subject_id = l_request_number;
  l_subject_type VARCHAR2(35) := null;


  BEGIN
    IF (funmode = 'RUN') THEN
      l_event_name := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'EVENTNAME' );

      l_request_number := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_NUMBER' );

      l_wf_manual_launch := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'MANUAL_LAUNCH' );

/* RHUNGUND - 04/05/04
   Fix for bug 3528510 - Added the following IF block
*/
      IF(l_event_name = 'oracle.apps.cs.sr.ServiceRequest.relationshipcreated' OR
         l_event_name = 'oracle.apps.cs.sr.ServiceRequest.relationshipdeleted') THEN

          l_subject_type := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'LINK_SUBJECT_TYPE' );

          If (l_subject_type <> 'SR') THEN
          		  l_wf_manual_launch := 'Y';
          END IF;

      END IF;



      -- Fix for bug 3106572. rmanabat 09/26/03.
      IF (l_request_number IS NOT NULL) THEN
        OPEN sel_incident_id_csr;
        FETCH sel_incident_id_csr INTO l_request_id;
        IF (sel_incident_id_csr%NOTFOUND OR l_request_id IS NULL) THEN

          IF((l_event_name = 'oracle.apps.cs.sr.ServiceRequest.relationshipcreated' OR
              l_event_name = 'oracle.apps.cs.sr.ServiceRequest.relationshipdeleted')  AND
              l_subject_type <> 'SR') THEN
         	CLOSE sel_incident_id_csr;
	  ELSE
         	CLOSE sel_incident_id_csr;
          	raise l_API_ERROR;
          END IF;

        END IF;

        IF sel_incident_id_csr%ISOPEN THEN
          CLOSE sel_incident_id_csr;
        END IF;

      END IF;


      -- This check needs to be done for workflows launched manually, i.e., via UI's
      -- Launch Workflow Tools menu option. Auto notification WF had been launched
      -- when the SR was saved, so this WF launch is redundant. rmanabat .
      -- This can be replaced later by using WF_RULE2 default rule function in the
      -- event subscription, which accepts parameter values as qualifiers like
      -- what we did in SolutionAdded event subscription.

      IF (nvl(l_wf_manual_launch,'N') = 'N') THEN


        -- Knowledge Base says they are passing OBJECT_ID (incident_id) instead of number, so
        -- make sure both are instantiated here.
        IF (l_request_number IS NULL) THEN

          l_request_id := WF_ENGINE.GetItemAttrNumber(
                                    itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'OBJECT_ID' );

          OPEN sel_incident_number_csr;
          FETCH sel_incident_number_csr INTO l_request_number;
          IF (sel_incident_number_csr%NOTFOUND OR l_request_number IS NULL) THEN
            CLOSE sel_incident_number_csr;
            raise l_API_ERROR;
          END IF;
          IF sel_incident_number_csr%ISOPEN THEN
            CLOSE sel_incident_number_csr;
          END IF;

          WF_ENGINE.SetItemAttrText(
                  itemtype        => 'SERVEREQ',
                  itemkey         => itemkey,
                  aname           => 'REQUEST_NUMBER',
                  avalue          => l_request_number);

        END IF;


        OPEN sel_action_csr;
        LOOP
          FETCH sel_action_csr
	  INTO sel_action_rec;
          --INTO l_event_condition_id, l_action_code, l_ntfy_template_id;
          EXIT WHEN sel_action_csr%NOTFOUND;

	  l_event_condition_id := TO_CHAR(sel_action_rec.event_condition_id);

          /**************
            Build a condition_id/action_code list for notification rules.
          **************/
          IF (sel_action_rec.notification_template_id IS NOT NULL) THEN

            -- Check for the length, not to exceed max WF text length of 4000.
            IF (nvl(LENGTH(l_notify_conditions_list), 0) +
	        nvl(LENGTH(l_event_condition_id), 0) + 1) <= 4000  OR
	       (nvl(LENGTH(l_notify_actions_list), 0) +
	        nvl(LENGTH(sel_action_rec.action_code), 0) + 1 ) <= 4000 THEN

              IF l_notify_conditions_list IS NULL THEN
                l_notify_conditions_list := l_event_condition_id;
                l_notify_actions_list := sel_action_rec.action_code;
              ELSE
                l_notify_conditions_list := l_notify_conditions_list || ' ' || l_event_condition_id;
                l_notify_actions_list := l_notify_actions_list || ' ' || sel_action_rec.action_code;
              END IF;

	    ELSE
	      /**********
                If the query results exceeded the max allowable WF text length, then we
	        set an attribute to indicate that we need to re-query again to obtain
	        the remainder of the results which were not put in the initial list.
	      **********/
	      WF_ENGINE.SetItemAttrText(
                          itemtype        => itemtype,
                          itemkey         => itemkey,
                          aname           => 'MORE_NTFY_ACTION_LIST',
                          avalue          => 'Y' );

            END IF;

          /**************
            Build a condition_id/action_code list for update rules.
          **************/
          ELSE	-- IF (sel_action_rec.notification_template_id IS NOT NULL)

            -- Check for the length, not to exceed max WF text length of 4000.
            IF (nvl(LENGTH(l_update_conditions_list), 0) +
	        nvl(LENGTH(l_event_condition_id), 0) + 1) <= 4000  OR
	       (nvl(LENGTH(l_update_actions_list), 0) +
	        nvl(LENGTH(sel_action_rec.action_code), 0) + 1 ) <= 4000 THEN

	      IF l_update_conditions_list IS NULL THEN
	        l_update_conditions_list := l_event_condition_id;
	        l_update_actions_list := sel_action_rec.action_code;
              ELSE
	        l_update_conditions_list := l_update_conditions_list || ' ' || l_event_condition_id;
	        l_update_actions_list := l_update_actions_list || ' ' || sel_action_rec.action_code;
              END IF;

	    ELSE
	      WF_ENGINE.SetItemAttrText(
                          itemtype        => itemtype,
                          itemkey         => itemkey,
                          aname           => 'MORE_UPDATE_ACTION_LIST',
                          avalue          => 'Y' );

            END IF;
          END IF;
        END LOOP;
        CLOSE sel_action_csr;


        IF (l_update_conditions_list IS NOT NULL OR l_notify_conditions_list IS NOT NULL) THEN

          WF_ENGINE.SetItemAttrText(
  	  	itemtype	=> itemtype,
  	  	itemkey		=> itemkey,
  	  	aname		=> 'NTFY_CONDITION_LIST',
  	  	avalue		=> l_notify_conditions_list );
          WF_ENGINE.SetItemAttrText(
  	  	itemtype	=> itemtype,
  	  	itemkey		=> itemkey,
  	  	aname		=> 'NTFY_ACTION_LIST',
  	  	avalue		=> l_notify_actions_list );
          WF_ENGINE.SetItemAttrText(
  		itemtype	=> itemtype,
  		itemkey		=> itemkey,
  		aname		=> 'UPDATE_CONDITION_LIST',
  		avalue		=> l_update_conditions_list );
          WF_ENGINE.SetItemAttrText(
  		itemtype	=> itemtype,
  		itemkey		=> itemkey,
  		aname		=> 'UPDATE_ACTION_LIST',
  		avalue		=> l_update_actions_list );

          /*** This will be used later when we convert our message text to PL/SQL docs.
          WF_ENGINE.SetItemAttrText(
  		itemtype	=> itemtype,
  		itemkey		=> itemkey,
  		aname		=> 'REQUEST_DETAILS',
  		avalue		=> 'PL/SQL:RMM_TEST_WF_PKG.SR_PLSQL_DOC_ATTR1/'||
				l_request_number || 'a');
          ***/

          result := 'COMPLETE:Y';
        ELSE
          result := 'COMPLETE:N';
        END IF;

      ELSE

	result := 'COMPLETE:N';

      END IF;	-- IF (l_wf_manual_launch = 'N')

    ELSIF (funmode = 'CANCEL') THEN
        result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Check_Rules_For_Event',
                      itemtype, itemkey, actid, funmode);
      RAISE;

    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Check_Rules_For_Event',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Check_Rules_For_Event;


  /****************************************************************************
  -- Check_Notification_Rules
  --   This procedure corresponds to the CHECK_NOTIFICATION_RULES function
  --   activity.
  --
  --   The procedure checks if there are notification rules defined by checking
  --   the conditions/actions list. If the list is not empty, then we pull the
  --   first item on the lists to process. Otherwise, we end the sub-process.
  --
  ****************************************************************************/

  PROCEDURE Check_Notification_Rules( itemtype   IN  VARCHAR2,
                                   itemkey    IN  VARCHAR2,
                                   actid      IN  NUMBER,
                                   funmode    IN  VARCHAR2,
                                   result     OUT NOCOPY VARCHAR2 ) IS

    l_notify_conditions_list	VARCHAR2(4000);
    l_notify_actions_list	VARCHAR2(4000);
    l_event_condition_id	CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_action_code		CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_element			VARCHAR2(100);


  BEGIN

    IF (funmode = 'RUN') THEN

      l_notify_conditions_list := WF_ENGINE.GetItemAttrText(
  				itemtype	=> itemtype,
  				itemkey		=> itemkey,
  				aname		=> 'NTFY_CONDITION_LIST');
      l_notify_actions_list := WF_ENGINE.GetItemAttrText(
  				itemtype	=> itemtype,
  				itemkey		=> itemkey,
  				aname		=> 'NTFY_ACTION_LIST');


      IF (l_notify_conditions_list IS NOT NULL AND l_notify_actions_list IS NOT NULL) THEN

        pull_from_list(itemlist	=> l_notify_conditions_list,
		       element	=> l_element);
	l_event_condition_id := TO_NUMBER(l_element);

        pull_from_list(itemlist	=> l_notify_actions_list,
		       element	=> l_action_code);

        IF (l_event_condition_id IS NOT NULL AND l_action_code IS NOT NULL) THEN

          WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'NTFY_CONDITION_LIST',
                avalue          => l_notify_conditions_list );
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_ACTION_LIST',
                  avalue          => l_notify_actions_list );
          WF_ENGINE.SetItemAttrNumber(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_EVENT_CONDITION_ID',
                  avalue          => l_event_condition_id );
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_ACTION_CODE',
                  avalue          => l_action_code );

          result := 'COMPLETE:Y';

        ELSE
          result := 'COMPLETE:N';

        END IF;

      ELSE
          result := 'COMPLETE:N';
      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Check_Notification_Rules',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Check_Notification_Rules;


  /****************************************************************************
  -- Get_Recipients_To_Notify
  --   This procedure corresponds to the GET_NTFXN_RECIPIENTS function
  --   activity.
  --
  --   This procedure checks if there are valid recipients for the notification
  --   rule being processed.
  --   If more than one recipient is set (as in notifying owners of related SRs),
  --   then a list of recipients is created which we process one item at a time.
  ****************************************************************************/

  PROCEDURE Get_Recipients_To_Notify( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_request_number            VARCHAR2(64);
    l_request_id		NUMBER;
    l_event_name        	VARCHAR2(240);
    l_event_condition_id        CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_action_code       	CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_notify_recipient		VARCHAR2(100);
    l_request_status            VARCHAR2(30);
    l_request_status_temp	VARCHAR2(30);
    l_recipient_role_list	VARCHAR2(4000);
    l_linked_subject_list       VARCHAR2(4000);
    --l_linked_incident_id	NUMBER;
    l_linked_incident_number	VARCHAR2(64);

    l_return_status		VARCHAR2(1);
    l_msg_count			NUMBER;
    l_msg_data			VARCHAR2(2000);
    l_owner_role		VARCHAR2(320);
    l_owner_name		VARCHAR2(240);
    l_char_subject_id        	VARCHAR2(30);
    l_relationship_type_id	CS_SR_ACTION_DETAILS.relationship_type_id%TYPE;

    l_trigger_link_type		VARCHAR2(240);
    l_trigger_link_type_id	NUMBER;

    CURSOR sel_link_type_id_csr IS
      SELECT link_type_id
      FROM CS_SR_LINK_TYPES_VL
      WHERE name = l_trigger_link_type;

    CURSOR sel_event_action_csr IS
      SELECT csad.event_condition_id,
             csad.action_code,
             csad.notification_template_id,	/** this is the WF message name  **/
	     csad.relationship_type_id detail_link_type,
             csad.role_group_type,
             csad.role_group_code,
	     csat.from_to_status_code,
	     csat.incident_status_id trigger_incident_status_id,
	     csat.relationship_type_id trigger_link_type
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
	  and csad.event_condition_id = l_event_condition_id
	  and csad.action_code = l_action_code
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csad.notification_template_id IS NOT NULL
          -- We need to add this since a notification rule can still be created (partially)
          -- without a message template.
	  and csad.action_code like 'NOTIFY%';

    sel_event_action_rec	sel_event_action_csr%ROWTYPE;


    CURSOR sel_link_csr_1 IS
      SELECT
        cil.object_id,
        cil.link_id,
	inc.incident_owner_id
      FROM cs_incident_links cil,
	   cs_incidents_all_b inc
      WHERE cil.subject_id = l_request_id
	and inc.incident_id = cil.object_id
      ORDER BY cil.object_id;

    sel_link_rec        sel_link_csr_1%ROWTYPE;

    CURSOR sel_link_csr_2 IS
      SELECT
        cil.object_id,
        cil.link_id,
	inc.incident_owner_id
      FROM cs_incident_links cil,
	   cs_incidents_all_b inc
      WHERE cil.subject_id = l_request_id
        AND cil.link_type_id = l_relationship_type_id
	AND inc.incident_id = cil.object_id
      ORDER BY cil.object_id;

    /*
        Roopa - bug fix for 2788741
        For the following actions:
            NOTIFY_OWNER
            NOTIFY_OLD_OWNER
            NOTIFY_NEW_OWNER
            NOTIFY_OWNER_OF_RELATED_SR

        This activity returns N (to skip notify action) if for the above actions, the SR owner
        himself has updated the SR
    */
    l_incident_owner_id NUMBER;
    l_resource_id NUMBER;
    l_user_id NUMBER;
    l_prev_owner_id NUMBER;

    CURSOR sel_inc_owner_id IS
        SELECT incident_owner_id FROM cs_incidents_all_b WHERE
            incident_id = l_request_id;

    CURSOR sel_resource_id IS
        SELECT resource_id FROM jtf_rs_resource_extns emp, fnd_user users WHERE
            emp.source_id = users.employee_id and
            users.user_id = l_user_id;

    CURSOR sel_prev_owner_id IS
        SELECT resource_id from jtf_rs_resource_extns emp WHERE
            source_id = l_prev_owner_id;


   l_party_role_group_code        cs_party_role_group_maps.party_role_group_code%TYPE;
   l_part_role_code               cs_party_role_group_maps.party_role_code%TYPE;
   l_notify_party_role_list       varchar2(4000);
   l_notify_party_role_relsr_list varchar2(4000);

   CURSOR sel_party_role_csr IS
      SELECT party_role_code
        FROM cs_party_role_group_maps
       WHERE party_role_group_code = l_party_role_group_code
         AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                                and trunc(nvl(end_date_active,sysdate));

   sel_party_role_rec sel_party_role_csr%ROWTYPE;

  BEGIN

  IF (funmode = 'RUN') THEN

      l_request_number := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_NUMBER' );


      l_event_name := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'EVENTNAME' );

      l_event_condition_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_EVENT_CONDITION_ID' );

      l_action_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_ACTION_CODE' );


      /***********

      SELECT INCIDENT_ID
      INTO l_request_id
      FROM cs_incidents_all_b
      WHERE INCIDENT_NUMBER = l_request_number;
      *************/

      l_request_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'REQUEST_ID' );


      /*
          Roopa - begin - bug fix for 2788741
      */
      l_user_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'USER_ID' );
      l_prev_owner_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'PREV_OWNER_ID' );

      OPEN  sel_resource_id;
      FETCH sel_resource_id into l_resource_id;
      CLOSE sel_resource_id;

      IF (l_action_code = 'NOTIFY_OWNER' OR l_action_code = 'NOTIFY_NEW_OWNER') THEN
          OPEN sel_inc_owner_id;
          FETCH sel_inc_owner_id into l_incident_owner_id;
          CLOSE sel_inc_owner_id;
      ELSIF (l_action_code = 'NOTIFY_OLD_OWNER') THEN
        OPEN sel_prev_owner_id;
        FETCH sel_prev_owner_id  into l_incident_owner_id;
        CLOSE sel_prev_owner_id;
      END IF;

      IF(l_resource_id = l_incident_owner_id) THEN
        result := 'COMPLETE:N';
        return;
      END IF;

      /*
          Roopa - end - bug fix for 2788741
      */


      OPEN sel_event_action_csr;
      FETCH sel_event_action_csr
      INTO sel_event_action_rec;
      CLOSE sel_event_action_csr;

      -- Set the message template to be used for the notification
      WF_ENGINE.SetItemAttrText(
                        itemtype        => itemtype,
                        itemkey         => itemkey,
                        aname           => 'NTFY_MESSAGE_NAME',
                        avalue          => sel_event_action_rec.notification_template_id );


      /*** Rule 5: Notify service request owner, when the status of a service request	***/
      /***    he/she owns, is changed.							***/
      /*** Rule 8 : Notify the owners of related service requests when the current	***/
      /***    service request's status is changed to a specified value			***/

      IF (sel_event_action_rec.from_to_status_code IS NOT NULL) THEN

         IF (sel_event_action_rec.from_to_status_code = 'STATUS_CHANGED_TO') THEN
            l_request_status := WF_ENGINE.GetItemAttrText(
                                 itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'REQUEST_STATUS' );
         ELSIF (sel_event_action_rec.from_to_status_code = 'STATUS_CHANGED_FROM') THEN
               l_request_status := WF_ENGINE.GetItemAttrText(
                                 itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'REQUEST_STATUS_OLD' );
         END IF;

         SELECT name
           INTO l_request_status_temp
           FROM CS_INCIDENT_STATUSES_VL
          WHERE INCIDENT_STATUS_ID = sel_event_action_rec.trigger_incident_status_id;

         IF (l_request_status_temp = l_request_status) THEN

  	    IF (sel_event_action_rec.detail_link_type IS NOT NULL) THEN
	        l_relationship_type_id := sel_event_action_rec.detail_link_type;
	        OPEN sel_link_csr_2;
            ELSE
	      OPEN sel_link_csr_1;
	    END IF;

            /**************************************
             Loop through all the related service requests that satisfy
             the notification rule being processed, and build a list
             of service requests whose owners we will each then notify
            ****************************************/
            LOOP
	        IF (sel_event_action_rec.detail_link_type IS NOT NULL) THEN
	          FETCH sel_link_csr_2 INTO sel_link_rec;
	            EXIT WHEN sel_link_csr_2%NOTFOUND;
	        ELSE
	          FETCH sel_link_csr_1 INTO sel_link_rec;
	            EXIT WHEN sel_link_csr_1%NOTFOUND;
  	        END IF;

	          l_char_subject_id := TO_CHAR(sel_link_rec.object_id);

	        IF ((nvl(LENGTH(l_linked_subject_list), 0) +
	           nvl(LENGTH(l_char_subject_id), 0) + 1) <= 4000) THEN

 	           IF l_linked_subject_list IS NULL THEN
	              l_linked_subject_list := l_char_subject_id;

                   ELSE
	              l_linked_subject_list := l_linked_subject_list || ' ' || l_char_subject_id;
                   END IF;
	        ELSE
                   /*************************************
                    Will need to build another list later since it
                    won't fit here. This flag will tell us later to
                    re-query the remainding subject IDs.
                   **************************************/

	           WF_ENGINE.SetItemAttrText(
              		itemtype        => itemtype,
              		itemkey         => itemkey,
              		aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST',
              		avalue          => 'Y' );
	           EXIT;
	        END IF;
            END LOOP;

	    IF sel_link_csr_2%ISOPEN THEN
	      CLOSE sel_link_csr_2;
	    ELSIF sel_link_csr_1%ISOPEN THEN
	      CLOSE sel_link_csr_1;
	    END IF;

	    IF (l_linked_subject_list IS NOT NULL) THEN

	        WF_ENGINE.SetItemAttrText(
                              itemtype        => itemtype,
                              itemkey         => itemkey,
                              aname           => 'NTFY_LINKED_SUBJECT_LIST',
                              avalue          => l_linked_subject_list );

	        result := 'COMPLETE:Y';
	    ELSE

                -- Roopa - there might be a scenario where SR_STATUS_CHANGED event is associated
                --   with an action that does not include link/rel type as an action detail
                --   example : SR_STATUS_CHANGED(event) + NOTIFY_OWNER(action) combination
                --   the above example is a valid event-action combination. Hence result = 'Y'

                IF(sel_event_action_rec.detail_link_type IS NULL) THEN
                  result := 'COMPLETE:Y';
                ELSE
                  result := 'COMPLETE:N';
                END IF;

	    END IF;

            IF (sel_event_action_rec.action_code = 'NOTIFY_ASSOCIATED_PARTIES' OR
                sel_event_action_rec.action_code = 'NOTIFY_ALL_ASSOCIATED_PARTIES' ) THEN

                Create_Role_List
                     ( p_itemtype         => itemtype,
                       p_itemkey          => itemkey,
                       p_actid            => actid,
                       p_funmode          => funmode,
                       p_action_code      => sel_event_action_rec.action_code,
                       p_role_group_type  => sel_event_action_rec.role_group_type,
                       p_role_group_code  => sel_event_action_rec.role_group_code) ;

            END IF ;

         ELSE
            result := 'COMPLETE:N';

         END IF;		/**** IF (l_request_status_temp = l_request_status) ******/

         /*** Rule 6: Notify the service request owner, when a link type is created ***/
         /***    between the current service request to another service request 	 ***/
         /*** Rule 7 : Notify the service request owner, when a link type is deleted***/
         /***    between the current service request to another service request	 ***/

         /*** IF (sel_event_action_rec.from_to_status_code IS NOT NULL)		 ***/

      ELSIF (sel_event_action_rec.trigger_link_type IS NOT NULL) THEN

          /********************
           This section is for relationship created/deleted events
          ********************/
	  l_trigger_link_type := WF_ENGINE.GetItemAttrText(
                              	itemtype        => itemtype,
                              	itemkey         => itemkey,
                              	aname           => 'NTFY_LINK_TYPE');

	  -- Obtain link_type_id from the link type name
	  OPEN sel_link_type_id_csr;
	  FETCH sel_link_type_id_csr
	  INTO l_trigger_link_type_id;

	  IF (sel_link_type_id_csr%FOUND) THEN
             -- LINKED_INCIDENT_ID is mandatory for this rule since we can't get a
             -- handle of the linked SR when the link has been deleted.
             l_linked_incident_number := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_LINKED_INCIDENT_NUMBER' );

	     IF (sel_event_action_rec.trigger_link_type = l_trigger_link_type_id) THEN
	       result := 'COMPLETE:Y';
	     ELSE
	       result := 'COMPLETE:N';
	     END IF;

	  ELSE
	     result := 'COMPLETE:N';
	  END IF;
	     CLOSE sel_link_type_id_csr;

      ELSE	/** IF (sel_event_action_rec.from_to_status_code IS NOT NULL) **/

       	   IF (sel_event_action_rec.action_code = 'NOTIFY_ASSOCIATED_PARTIES' OR
	       sel_event_action_rec.action_code = 'NOTIFY_ALL_ASSOCIATED_PARTIES' ) THEN

     	       Create_Role_List
                     ( p_itemtype         => itemtype,
                       p_itemkey          => itemkey,
                       p_actid            => actid,
                       p_funmode          => funmode,
                       p_action_code      => sel_event_action_rec.action_code,
                       p_role_group_type  => sel_event_action_rec.role_group_type,
                       p_role_group_code  => sel_event_action_rec.role_group_code);

	    END IF ;

	  result := 'COMPLETE:Y';

      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Get_Recipients_To_Notify',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Get_Recipients_To_Notify;


  /**********************************************************************
  -- Set_Notification_Details
  --
  --   This procedure corresponds to the GET_NTFXN_RECIPIENTS function
  --   activity.
  --
  --   This procedure sets all the necessary workflow message attributes
  --   that are used to replace the tokens in the message template used
  --   for the notification.
  --   If the details are set successfully, then the result is set to
  --   'SET', otherwise it is 'UNSET'.
  --
  --  Modification History:
  --
  --  Date        Name       Desc
  --  ----------  ---------  ---------------------------------------------
  --  04/29/04	  RMANABAT   Fix for bug 3600819. Regression in functionality
  --			     of standard workflow Notify activity does not
  --			     allow users to have multiple email addresses
  --			     separatde by comma/space. Created one adhoc user
  --			     for each contact and attaced these to one adhoc
  --			     role as a list.
  -- 05/13/04     RMANABAT   Fix for bug 3628552. Use actual workflow users
  --			     for contacts, if available.
  -- 06/09/04     RMANABAT   Fix for bug 3663881. Added URL attribute to all
  --			     ntfxns to contacts. Removed hard code of jsp page
  --			     in URL.
  -- 07/13/04     RMANABAT   Fix for bug 3763848. For notification to contacts,
  --			     create just one ADHOC role and user and re-use
  --			     updating just the workflow user info.
  -- 08/12/04	  RMANABAT   Fix for bug 3830327. Ntfxn to contacts, duplicate
  --			     hz_party for the same contact points can exist.
  --			     This will result in error when attaching the same WF
  --			     user to an adhoc role. Create adhoc user for duplicate
  --			     contact WF user.
  -- 09/07/04	  RMANABAT   Fix for bug 3871457. In cursors sel_primary_contact_csr,
  --			     sel_all_contacts_csr, and sel_all_contacts_csr, changed
  --			     SELECT null person_id to SELECT to_number(null) person_id.
  -- 26-Jul-2005  ANEEMUCH   Rel 12.0 changes:
  -- 10-Mar-2006  spusegao   Modified to set the NTFY_Linked_sr_status and ntfy_linked_sr_summary attrs.
  --
  -- 14-Mar-2006  spusegao   Modified the code to send notification to the primary contacts.
  --                         to send a notification even if EMAIL is not specified as a primary contact.
  --                         The new code will derive primary contact in the following sequence.
  --                         1. If the primary contact point on the SR is EMAIL itself.
  --                         2. If primary contact point is not email then see if email for the primary
  --                            contact is specified in the CS schema. Derive the email address using it.
  --                         3. If email is not specified at all in the CS schema then check if the WF role
  --                            associated with the primary contact has an email address.
  --                         4. If WF role does not have email address then get the primary email address
  --                            either from HZ or HR depending on the contact type.
  --                         5. If primary email address is not specified then use any email address specified
  --                            This is true only for customer contact.
  --                         (Bug#5052683)
  --
  -- 15 Mar 06  spusegao     Changed the references to per_people_f  in the set_notification_details proc.
  --                         to use per_workforce_x view.
  ***********************************************************************/

  PROCEDURE Set_Notification_Details( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_request_number            VARCHAR2(64);
    l_action_code		CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_notify_recipient		VARCHAR2(100);
    l_notification_template_id	VARCHAR2(30);
    l_linked_subject_list       VARCHAR2(4000);
    l_element			VARCHAR2(100);
    l_incident_owner_id		cs_incidents_all_b.INCIDENT_OWNER_ID%TYPE;
    l_request_id		NUMBER;
    l_contact_email		VARCHAR2(2000);
    l_contact_email_list	VARCHAR2(2000);
    l_contact_point_id		NUMBER;
    l_contact_point_id_list	VARCHAR2(2000);
    l_notify_subject_id		NUMBER;

    l_party_role_code           cs_party_role_group_maps.party_role_code%TYPE;
    l_party_role_name           cs_party_roles_tl.name%TYPE;
    l_party_role_group_code     cs_party_role_group_maps.party_role_group_code%TYPE;

    l_notify_party_role_list    VARCHAR2(2000);
    l_notify_relsr_party_role_list  VARCHAR2(2000);

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_owner_role                VARCHAR2(320);
    l_owner_name                VARCHAR2(240);

    l_adhoc_role                VARCHAR2(100);
    l_adhoc_display_name        VARCHAR2(360);
    l_user			VARCHAR2(320);
    l_user_display_name		VARCHAR2(320);

    l_link_type_name		VARCHAR2(240);

    l_contact_party_id_list	VARCHAR2(2000);
    l_contact_party_id		NUMBER;
    l_party_id			NUMBER;
    l_contact_type		VARCHAR2(30);

    l_adhoc_user_list		VARCHAR2(2000);

    l_orig_system               VARCHAR2(30);
    l_orig_system_id            NUMBER;
    l_person_id                 NUMBER;

    adhoc_count			NUMBER := 0;
    l_sr_contact_point_id       NUMBER;
    l_pri_sr_contact_point_id   NUMBER;
    l_pri_email_cont_pt_id      NUMBER;
    l_sr_contact_point_type     VARCHAR2(240);
    l_contact_first_name        VARCHAR2(240);
    l_contact_last_name         VARCHAR2(240);

    -- Local Parameters for html_notifications

    l_notification_preference   VARCHAR2(240);
    l_language                  VARCHAR2(240);
    l_html_notification_flag    VARCHAR2(1);
    l_event_condition_id        NUMBER;
    l_html_contact_email_list   VARCHAR2(2000);
    l_html_adhoc_user_list      VARCHAR2(2000);
    l_contact_type_list         VARCHAR2(2000);
    l_contact_id_list           VARCHAR2(2000);
    l_notification_pref_list    VARCHAR2(2000);
    l_language_list             VARCHAR2(2000);
    l_err_code                  NUMBER;
    l_err_str                   VARCHAR2(2000);


    CURSOR sel_primary_contact_csr IS
      SELECT hcp.EMAIL_ADDRESS,
	     cshcp.party_id,
	     to_number(NULL) person_id,
	     cshcp.contact_type,
             cshcp.sr_contact_point_id
      FROM hz_contact_points hcp,
        cs_hz_sr_contact_points cshcp
      WHERE cshcp.INCIDENT_ID = l_request_id
        AND cshcp.PRIMARY_FLAG = 'Y'
        AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND hcp.CONTACT_POINT_ID = cshcp.CONTACT_POINT_ID
        AND cshcp.contact_type <> 'EMPLOYEE'
        AND cshcp.party_role_code = 'CONTACT'
      union
      select ppf.email_address,
	     ppf.party_id,
	     ppf.person_id,
	     cshcp.contact_type,
	     cshcp.sr_contact_point_id
      from per_all_people_f ppf,
        cs_hz_sr_contact_points cshcp
      where cshcp.INCIDENT_ID = l_request_id
        AND cshcp.PRIMARY_FLAG = 'Y'
	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND ppf.person_id = cshcp.party_id
        AND cshcp.contact_type = 'EMPLOYEE'
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppf.effective_start_date, SYSDATE))
        AND TRUNC(NVL(ppf.effective_end_date, SYSDATE));

-- Breaking the primary contact cursor

   -- Get the primary contact info.

      CURSOR get_primary_contact_info IS
      SELECT cshcp.party_id,
             cshcp.contact_type,
             cshcp.sr_contact_point_id,
             cshcp.contact_point_type,
             cshcp.contact_point_id
        FROM cs_hz_sr_contact_points cshcp
       WHERE cshcp.INCIDENT_ID = l_request_id
         AND cshcp.PRIMARY_FLAG = 'Y'
         AND cshcp.party_role_code = 'CONTACT'
	 AND cshcp.end_date_active IS NULL;--12.1.3 Inactivate Contact Points

  -- Get the primary contact's email information from the cs_hz_sr_contact_points table.

      CURSOR get_primary_email_info_CS (p_party_id IN NUMBER) IS
      SELECT cshcp.sr_contact_point_id,
             cshcp.contact_point_id
        FROM cs_hz_sr_contact_points cshcp
       WHERE cshcp.INCIDENT_ID = l_request_id
         AND cshcp.party_role_code = 'CONTACT'
         AND cshcp.contact_point_type = 'EMAIL'
         AND cshcp.party_id = p_party_id
	 AND cshcp.end_date_active IS NULL;--12.1.3 Inactivate Contact Points

  -- Get the email information from the HZ schema for the primary contact.

     CURSOR get_primary_email_info_HZ(p_contact_point_id IN NUMBER,
                                      p_party_id IN NUMBER) IS
     SELECT email_address
       FROM hz_contact_points
      WHERE contact_point_id = p_contact_point_id
        AND contact_point_type = 'EMAIL'
        AND owner_table_name = 'HZ_PARTIES'
        AND owner_table_id   = p_party_id ;

  -- Get any customer email address starting with the primary email address.

     CURSOR get_any_cust_email_address(p_party_id  IN NUMBER) IS
     SELECT email_address
       FROM hz_contact_points
      WHERE contact_point_type = 'EMAIL'
        AND owner_table_name = 'HZ_PARTIES'
        AND owner_table_id   = p_party_id
      ORDER BY Primary_flag DESC;

  -- Get the email information from the HR schema for the primary contact.

     CURSOR get_primary_email_info_HR(p_person_id IN NUMBER) IS
     SELECT ppf.email_address
            --ppf.party_id,
            --ppf.person_id
       FROM per_workforce_x ppf
      WHERE ppf.person_id = p_person_id;
        --AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppf.effective_start_date, SYSDATE))
        --AND TRUNC(NVL(ppf.effective_end_date, SYSDATE));

  -- Get primary contact party info

     CURSOR get_prim_cont_party_info_reln (p_party_id IN NUMBER) IS
     SELECT hzp.person_first_name first_name,
            hzp.person_last_name last_name
       FROM hz_parties hzp,
            hz_relationships hzr
      WHERE hzr.PARTY_ID = p_party_id
        AND hzr.SUBJECT_ID = hzp.PARTY_ID
        AND hzr.SUBJECT_TYPE = 'PERSON';

     CURSOR get_prim_cont_party_info_per (p_party_id IN NUMBER) IS
     SELECT hzp.person_first_name first_name,
            hzp.person_last_name last_name
       FROM hz_parties hzp
      WHERE hzp.PARTY_ID = p_party_id;

     CURSOR get_prim_cont_party_info_empl (p_party_id IN NUMBER) IS
     SELECT ppf.first_name first_name,
            ppf.last_name last_name
       FROM per_workforce_x ppf
      WHERE ppf.person_id = p_party_id;

--Added and condition for party role in R12 ... aneemuch

    CURSOR sel_all_contacts_csr IS
      SELECT hcp.EMAIL_ADDRESS,
	     cshcp.party_id,
	     to_number(NULL) person_id,
	     cshcp.contact_type,
	     cshcp.sr_contact_point_id
      FROM hz_contact_points hcp,
        cs_hz_sr_contact_points cshcp
      WHERE cshcp.INCIDENT_ID = l_request_id
     	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND hcp.CONTACT_POINT_ID = cshcp.CONTACT_POINT_ID
        AND cshcp.contact_type <> 'EMPLOYEE'
        AND cshcp.party_role_code = 'CONTACT'
      UNION
      select ppf.email_address,
	     ppf.party_id,
	     ppf.person_id,
	     cshcp.contact_type,
	     cshcp.sr_contact_point_id
      from per_all_people_f ppf,
      cs_hz_sr_contact_points cshcp
      where cshcp.INCIDENT_ID = l_request_id
	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND ppf.person_id = cshcp.party_id
        AND cshcp.contact_type = 'EMPLOYEE'
        AND cshcp.party_role_code = 'CONTACT'
	AND cshcp.end_date_active IS NULL--12.1.3 Inactivate Contact Points
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppf.effective_start_date, SYSDATE))
        AND TRUNC(NVL(ppf.effective_end_date, SYSDATE));
--Added and condition for party role in R12 ... aneemuch


-- Rel 12.0 changes
-- Cursor to query contacts from cs_hz_sr_contact_points table for notification to be
-- sent to all the contacts of a particular party role code.

    CURSOR sel_party_role_contacts_csr IS
      SELECT hcp.EMAIL_ADDRESS,
	     cshcp.party_id,
	     to_number(NULL) person_id,
	     cshcp.contact_type,
	     cshcp.sr_contact_point_id
      FROM hz_contact_points hcp,
        cs_hz_sr_contact_points cshcp
      WHERE cshcp.INCIDENT_ID = l_request_id
     	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND hcp.CONTACT_POINT_ID = cshcp.CONTACT_POINT_ID
        AND cshcp.contact_type <> 'EMPLOYEE'
        AND cshcp.party_role_code = l_party_role_code
      UNION
      select ppf.email_address,
             ppf.party_id,
             ppf.person_id,
             cshcp.contact_type,
             cshcp.sr_contact_point_id
      from per_all_people_f ppf,
      cs_hz_sr_contact_points cshcp
      where cshcp.INCIDENT_ID = l_request_id
        AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND ppf.person_id = cshcp.party_id
        AND cshcp.contact_type = 'EMPLOYEE'
        AND cshcp.party_role_code = l_party_role_code
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppf.effective_start_date, SYSDATE))
        AND TRUNC(NVL(ppf.effective_end_date, SYSDATE));

--Added and condition for party role in R12 ... aneemuch


    CURSOR sel_new_contact_csr IS
      SELECT hcp.EMAIL_ADDRESS,
	     cshcp.party_id,
	     to_number(NULL) person_id,
	     cshcp.contact_type,
	     cshcp.sr_contact_point_id
      FROM hz_contact_points hcp,
           cs_hz_sr_contact_points cshcp
      WHERE
    	hcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND hcp.CONTACT_POINT_ID = l_contact_point_id
        AND hcp.CONTACT_POINT_ID = cshcp.CONTACT_POINT_ID
        AND cshcp.contact_type <> 'EMPLOYEE'
        AND cshcp.party_role_code = 'CONTACT'
      UNION
      SELECT ppf.EMAIL_ADDRESS,
	     ppf.party_id,
	     ppf.person_id,
	     cshcp.contact_type,
	     cshcp.sr_contact_point_id
      FROM per_all_people_f ppf,
           cs_hz_sr_contact_points cshcp
      WHERE
    	cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND ppf.PERSON_ID = l_contact_point_id
        AND cshcp.PARTY_ID = ppf.person_id
        AND cshcp.contact_type = 'EMPLOYEE'
        AND cshcp.party_role_code = 'CONTACT'
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppf.effective_start_date, SYSDATE))
        AND TRUNC(NVL(ppf.effective_end_date, SYSDATE));

    CURSOR sel_new_party_role_contact_csr IS
      SELECT hcp.EMAIL_ADDRESS,
             cshcp.party_id,
             to_number(NULL) person_id,
             cshcp.contact_type,
             cshcp.sr_contact_point_id,
             cpr.name,
             cpr.party_role_code
      FROM hz_contact_points hcp,
           cs_hz_sr_contact_points cshcp,
           cs_party_roles_tl cpr
      WHERE
        hcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND hcp.CONTACT_POINT_ID = l_contact_point_id
        AND hcp.CONTACT_POINT_ID = cshcp.CONTACT_POINT_ID
        AND cshcp.party_role_code = cpr.party_role_code
        AND cpr.language = userenv('LANG')
        AND cshcp.contact_type <> 'EMPLOYEE'
        AND cshcp.party_role_code <> 'CONTACT'
      UNION
      SELECT ppf.EMAIL_ADDRESS,
             ppf.party_id,
             ppf.person_id,
             cshcp.contact_type,
             cshcp.sr_contact_point_id,
             cpr.name,
             cpr.party_role_code
      FROM per_all_people_f ppf,
           cs_hz_sr_contact_points cshcp,
           cs_party_roles_tl cpr
      WHERE
        cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND ppf.PERSON_ID = l_contact_point_id
        AND cshcp.PARTY_ID = ppf.person_id
        AND cshcp.contact_type = 'EMPLOYEE'
        AND cshcp.party_role_code = cpr.party_role_code
        AND cpr.language = userenv('LANG')
        AND cshcp.party_role_code <> 'CONTACT'
        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(ppf.effective_start_date, SYSDATE))
        AND TRUNC(NVL(ppf.effective_end_date, SYSDATE));

    CURSOR sel_link_csr IS
      SELECT
	inc.incident_number,
        inc.incident_owner_id,
        cil.object_id,
        cil.link_type_id,
	cilt.name link_type_name
      FROM cs_incident_links cil,
	cs_incidents_all_b inc,
	CS_SR_LINK_TYPES_VL cilt
      WHERE cil.subject_id = l_request_id
	and cil.object_id = l_notify_subject_id
	and inc.incident_id = cil.object_id
        and cilt.link_type_id(+) = cil.link_type_id;

    sel_link_rec        sel_link_csr%ROWTYPE;

    /*
        Roopa - bug fix for 2788741
        For the following action:
            NOTIFY_OWNER_OF_RELATED_SR

        This activity returns N (to skip notify action) if for the above actions, the SR owner
        himself has updated the SR
    */
    l_incident_owner_id NUMBER;
    l_resource_id NUMBER;
    l_user_id NUMBER;

    CURSOR sel_resource_id IS
        SELECT resource_id FROM jtf_rs_resource_extns emp, fnd_user users WHERE
            emp.source_id = users.employee_id and
            users.user_id = l_user_id;

    /* Roopa - begin
       Fix for bug # 2788156
       The wf role should be checked on the employee/source id and NOT on the incident_owner_id
       This cursor will get us the employee id
    */

    CURSOR l_sel_employee_id_csr IS
      SELECT source_id FROM jtf_rs_resource_extns emp
      WHERE emp.resource_id = sel_link_rec.incident_owner_id;

    l_employee_id NUMBER;

    CURSOR l_sel_curr_sr_details_csr IS
      SELECT incident_type_id,incident_status_id,incident_urgency_id,incident_severity_id,summary
      FROM cs_incidents_all_vl inc
      WHERE inc.incident_number = l_request_number;

    l_sel_curr_sr_details_rec  l_sel_curr_sr_details_csr%ROWTYPE;

    l_prev_type_id NUMBER;
    l_prev_status_id NUMBER;
    l_prev_severity_id NUMBER;
    l_prev_urgency_id NUMBER;
    l_prev_summary VARCHAR2(240);

    l_lookup_code VARCHAR2(30);
    l_changed_field VARCHAR2(30);
    l_changed_field_list VARCHAR2(240);
    l_updated_by VARCHAR2(240);


    CURSOR l_sel_lookup_value_csr IS
      SELECT a.lookup_code, a.meaning FROM cs_lookups a
      WHERE a.lookup_type = 'CS_SR_UPDATED_FIELDS';

    l_sel_lookup_value_rec l_sel_lookup_value_csr%ROWTYPE;


    CURSOR l_get_resource_name_csr IS
      SELECT source_last_name,source_first_name
      from jtf_rs_resource_extns a, fnd_user b, cs_incidents_all_b c
      WHERE c.last_updated_by = b.user_id and
        b.employee_id = a.source_id and
        c.incident_number = l_request_number;

    l_get_resource_name_rec l_get_resource_name_csr%ROWTYPE;

    CURSOR l_get_create_rsrc_csr IS
      SELECT source_last_name,source_first_name
      from jtf_rs_resource_extns a, fnd_user b, cs_incidents_all_b c
      WHERE c.created_by = b.user_id and
        b.employee_id = a.source_id and
        c.incident_number = l_request_number;

    l_get_create_rsrc_rec l_get_create_rsrc_csr%ROWTYPE;

    l_created_by VARCHAR2(240);

    l_solution_number VARCHAR2(30);
    l_solution_summary VARCHAR2(500);

    CURSOR l_getsoln_summary_csr IS
        SELECT name from CS_KB_SETS_VL
          WHERE set_number = l_solution_number
          and status='PUB';

/* ROOPA - 11/12/03 */
    l_request_id_temp NUMBER;
    l_notify_contact_name VARCHAR2(200);
    l_serviceRequest_URL VARCHAR2(200);

 -- The following cursor is needed to fill in the 3 NEW WF item attributes:
 --   1. NTFY_LINKED_SR_STATUS
 --   2. NTFY_LINKED_SR_SUMMARY
 --   3. NTFY_LINK_TYPE
    CURSOR sel_linked_sr_details_csr IS
        SELECT a.summary, b.name
        FROM cs_incidents_all_vl a,
             cs_incident_statuses_vl b
        WHERE a.incident_status_id = b.incident_status_id AND
              a.incident_id = l_request_id;

    sel_linked_sr_details_rec sel_linked_sr_details_csr%ROWTYPE;

-- The following cursor is needed to fill in the 1 NEW WF item attributes:
  --   1. NTFY_LINK_TYPE
    CURSOR sel_linked_sr_type_csr IS
        SELECT cilt.name link_type_name
        FROM cs_incident_links cil,
             CS_SR_LINK_TYPES_VL cilt
        WHERE cilt.link_type_id = cil.link_type_id AND
              cil.subject_id = l_notify_subject_id AND
			  cil.object_id = l_request_id;

    sel_linked_sr_type_rec sel_linked_sr_type_csr%ROWTYPE;



-- The following cursor is needed to derive the contact's name.
-- At the point of opening this cursor, we already have the contact point id.
-- We use this contact point id to go against the following 2 tables to derive the
-- contact's full name :
--     1) PER_ALL_PEOPLE_F - for contact type = EMPLOYEE
--     2) HZ_RELATIONSHIPS - for contact type = PARTY_RELATIONSHIP
--     3) HZ_PARTIES - for contact type = PERSON

    l_tmp_contact_point_id NUMBER;

    CURSOR sel_contact_name_csr IS
      SELECT hzp.person_first_name first_name,
             hzp.person_last_name last_name,
             cshcp.contact_type,
             cshcp.contact_point_id
      FROM hz_parties hzp,
        hz_relationships hzr,
        cs_hz_sr_contact_points cshcp
      WHERE cshcp.INCIDENT_ID = l_request_id
        AND cshcp.sr_contact_point_id = l_tmp_contact_point_id
     	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND cshcp.contact_type = 'PARTY_RELATIONSHIP'
        AND cshcp.PARTY_ID = hzr.PARTY_ID
        AND hzr.SUBJECT_ID = hzp.PARTY_ID
        AND hzr.SUBJECT_TYPE = 'PERSON'
      UNION
      SELECT hzp.person_first_name first_name,
             hzp.person_last_name last_name,
             cshcp.contact_type,
             cshcp.contact_point_id
      FROM hz_parties hzp,
           cs_hz_sr_contact_points cshcp
      WHERE cshcp.INCIDENT_ID = l_request_id
        AND cshcp.sr_contact_point_id = l_tmp_contact_point_id
     	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND cshcp.contact_type = 'PERSON'
        AND cshcp.PARTY_ID = hzp.PARTY_ID
      UNION
      SELECT ppf.first_name first_name,
             ppf.last_name last_name,
             cshcp.contact_type,
             cshcp.contact_point_id
      FROM per_all_people_f ppf,
           cs_hz_sr_contact_points cshcp
      WHERE cshcp.INCIDENT_ID = l_request_id
        AND cshcp.sr_contact_point_id = l_tmp_contact_point_id
     	AND cshcp.CONTACT_POINT_TYPE = 'EMAIL'
        AND cshcp.contact_type = 'EMPLOYEE'
        AND cshcp.PARTY_ID = ppf.PERSON_ID;

    sel_contact_name_rec sel_contact_name_csr%ROWTYPE;

l_temp_contact_id_list VARCHAR2(2000);
l_temp_item_key VARCHAR2(100);

CURSOR check_if_item_attr_exists_csr IS
	select text_value from wf_item_attribute_values
	where item_type='SERVEREQ'
        and   name = 'CONTACT_PARTY_ID_LIST'
        and item_key = l_temp_item_key;


    -- There probably is an api to obtain the jsp name given the function,
    -- we can replace this cursor with that api when we find out.
    CURSOR sel_jsp_name_csr IS
      select WEB_HTML_CALL from fnd_form_functions
      where FUNCTION_NAME='IBU_SR_DETAILS';
    l_jsp_name	VARCHAR2(240);

--
/* End ROOPA -  11/12/03 */

    CURSOR c_user(p_orig_system IN VARCHAR2, p_orig_system_id IN NUMBER) IS
      select name,
	     substrb(display_name,1,360),
	     email_address,
             notification_preference,
             language
      from   wf_users
      where  orig_system     = p_orig_system
      and    orig_system_id  = p_orig_system_id
      order by status, start_date;
    l_email_address	VARCHAR2(320);


   CURSOR c_party_role_csr (p_party_role_code in VARCHAR2) IS
      SELECT name
        FROM cs_party_roles_vl
       WHERE party_role_code = p_party_role_code;

   	-- Cursor to check if the HTML notification is required.

   CURSOR c_check_html_notification IS
     SELECT NVL(html_notification,'N')
	   FROM cs_sr_action_details
	  WHERE event_condition_id = l_event_condition_id
	    AND action_code        = l_action_code ;


  BEGIN

    IF (funmode = 'RUN') THEN

      l_temp_item_key := itemkey;

      l_action_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_ACTION_CODE' );

      l_event_condition_id := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_EVENT_CONDITION_ID' );

      l_request_number := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_NUMBER' );

      l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID' );

      /* Roopa - begin
          Fix for bug # 2809232
      */
      OPEN l_sel_curr_sr_details_csr;
      FETCH l_sel_curr_sr_details_csr into l_sel_curr_sr_details_rec;
      CLOSE l_sel_curr_sr_details_csr;

      l_prev_type_id := WF_ENGINE.GetItemAttrText(
                                    itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'PREV_TYPE_ID' );

      l_prev_status_id :=  WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'PREV_STATUS_ID' );

      l_prev_severity_id :=  WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'PREV_SEVERITY_ID' );
      l_prev_urgency_id :=  WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'PREV_URGENCY_ID' );


      l_prev_summary :=  WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'PREV_SUMMARY' );




      /****************************
       create a list of SR attributes that were updated, which will later
       be included in the ntfxn message text.
      ****************************/

      FOR i in l_sel_lookup_value_csr LOOP
        IF(i.lookup_code = 'CS_SR_SEVERITY') THEN
           IF(l_prev_severity_id <> l_sel_curr_sr_details_rec.incident_severity_id) THEN
                l_changed_field := i.meaning;
            ELSE
                l_changed_field := null;
           END IF;
        ELSIF  (i.lookup_code = 'CS_SR_STATUS') THEN
           IF(l_prev_status_id <> l_sel_curr_sr_details_rec.incident_status_id) THEN
                l_changed_field := i.meaning;
           ELSE
                l_changed_field := null;
           END IF;
        ELSIF  (i.lookup_code = 'CS_SR_TYPE') THEN
           IF(l_prev_type_id <> l_sel_curr_sr_details_rec.incident_type_id) THEN
                l_changed_field := i.meaning;
           ELSE
                l_changed_field := null;
           END IF;
        ELSIF  (i.lookup_code = 'CS_SR_URGENCY') THEN
           IF(l_prev_urgency_id <> l_sel_curr_sr_details_rec.incident_urgency_id) THEN
                l_changed_field := i.meaning;
           ELSE
                l_changed_field := null;
           END IF;
        ELSIF  (i.lookup_code = 'CS_SR_SUMMARY') THEN
           IF(l_prev_summary <> l_sel_curr_sr_details_rec.summary) THEN
                l_changed_field := i.meaning;
           ELSE
                l_changed_field := null;
           END IF;
        END IF;

        IF(l_changed_field is not null) THEN
            IF (l_changed_field_list is NULL) THEN
                l_changed_field_list := l_changed_field;
                l_changed_field := null;
            ELSE
                l_changed_field_list := l_changed_field_list || ',' || l_changed_field;
                l_changed_field := null;
            END IF;
        END IF;

      END LOOP;

      IF(l_changed_field_list is not null) THEN
        l_changed_field_list := l_changed_field_list || ' of ';
    	  WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'CHANGED_LIST',
                  avalue          => l_changed_field_list );
      END IF;

      OPEN l_get_resource_name_csr;
      FETCH l_get_resource_name_csr INTO l_get_resource_name_rec;
      CLOSE l_get_resource_name_csr;

      l_updated_by := l_get_resource_name_rec.source_first_name || ' '
                      || l_get_resource_name_rec.source_last_name;

      WF_ENGINE.SetItemAttrText(
                 itemtype        => itemtype,
                 itemkey         => itemkey,
                 aname           => 'UPDATED_BY',
                 avalue          => l_updated_by );

      /* Roopa - end
         Fix for bug # 2809232
      */

      /* Roopa - begin
          Fix for bug # 2809222
      */
      OPEN l_get_create_rsrc_csr;
      FETCH l_get_create_rsrc_csr INTO l_get_create_rsrc_rec;
      CLOSE l_get_create_rsrc_csr;

      l_created_by := l_get_resource_name_rec.source_first_name || ' '
                      || l_get_resource_name_rec.source_last_name;

      WF_ENGINE.SetItemAttrText(
                    itemtype        => itemtype,
                    itemkey         => itemkey,
                    aname           => 'CREATED_BY',
                    avalue          => l_created_by );
      /* Roopa - end
          Fix for bug # 2809222
      */


      /* Roopa - begin
          Fix for bug # 2804495
      */
      l_solution_number := WF_ENGINE.GetItemAttrText(
                  		itemtype        => itemtype,
                  		itemkey         => itemkey,
                  		aname           => 'SOLUTION_NUMBER');
      IF (l_solution_number is not null) THEN
          OPEN l_getsoln_summary_csr;
          FETCH l_getsoln_summary_csr INTO l_solution_summary;
          CLOSE l_getsoln_summary_csr;

          IF(l_solution_summary is not null) THEN
             WF_ENGINE.SetItemAttrText(
                   itemtype        => itemtype,
                   itemkey         => itemkey,
                   aname           => 'SOLUTION SUMMARY',
                   avalue          => l_solution_summary);

          END IF;

      END IF;

      /* Roopa - end
          Fix for bug # 2804495
      */


      IF (l_action_code = 'NOTIFY_OWNER' OR l_action_code = 'NOTIFY_NEW_OWNER') THEN
        l_notify_recipient := WF_ENGINE.GetItemAttrText(
                		itemtype        => itemtype,
                		itemkey         => itemkey,
                		aname           => 'OWNER_ROLE');

      ELSIF (l_action_code = 'NOTIFY_OLD_OWNER') THEN
        l_notify_recipient := WF_ENGINE.GetItemAttrText(
                		itemtype        => itemtype,
                		itemkey         => itemkey,
                		aname           => 'PREV_OWNER_ROLE');

      ELSIF (l_action_code = 'NOTIFY_OWNER_OF_RELATED_SR') THEN
	l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                          		aname           => 'NTFY_LINKED_SUBJECT_LIST');
        IF (l_linked_subject_list IS NOT NULL) THEN
          pull_from_list(itemlist => l_linked_subject_list,
                         element  => l_element);

	  l_notify_subject_id := TO_NUMBER(l_element);

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_SUBJECT_LIST',
              avalue          => l_linked_subject_list );

	  WF_ENGINE.SetItemAttrNumber(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_SUBJECT_ID',
              avalue          => l_notify_subject_id );

	  OPEN sel_link_csr;
	  FETCH sel_link_csr INTO sel_link_rec;
	  CLOSE sel_link_csr;


          /*
              Roopa - begin - bug fix for 2788741
          */

          l_user_id := WF_ENGINE.GetItemAttrNumber(
                                      itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'USER_ID' );
          OPEN  sel_resource_id;
          FETCH sel_resource_id into l_resource_id;
          CLOSE sel_resource_id;

          IF(l_resource_id = sel_link_rec.incident_owner_id) THEN

            result := 'COMPLETE:UNSET';
            return;
          END IF;

          /*
              Roopa - end - bug fix for 2788741
          */

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_INCIDENT_NUMBER',
              avalue          => sel_link_rec.incident_number );

	  -- Get link Type name from link_type_id

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINK_TYPE',
              avalue          => sel_link_rec.link_type_name );

          /* Roopa - begin
             Fix for bug # 2788156
             The wf role should be checked on the employee/source id and NOT on the incident_owner_id
             This cursor will get us the employee id
          */

          OPEN l_sel_employee_id_csr;
          FETCH l_sel_employee_id_csr into l_employee_id;
          CLOSE l_sel_employee_id_csr;

          /* Roopa - end
             Fix for bug # 2788156
          */

          IF(l_employee_id is not null) THEN
	    CS_WORKFLOW_PUB.Get_Employee_Role (
                    p_api_version           =>  1.0,
                    p_return_status         =>  l_return_status,
                    p_msg_count             =>  l_msg_count,
                    p_msg_data              =>  l_msg_data,
                    --p_employee_id           =>  l_incident_owner_id,
                    p_employee_id           =>  l_employee_id,
                    p_role_name             =>  l_owner_role,
                    p_role_display_name     =>  l_owner_name );

	    IF (l_owner_role IS NOT NULL) THEN
	          l_notify_recipient := l_owner_role;
	    END IF;
          END iF;

        END IF;	/*** IF (l_linked_subject_list IS NOT NULL) ***/




   /* ROOPA - 11/12/03 */
   /* 11.5.10 enhancement - we have added 2 new action codes:
        1. NOTIFY_PRIM_CONTACT_OF_REL_SR - notify the prim contact of all related SRs
        2. NOTIFY_ALL_CONTACTS_OF_REL_SR - notify all contacts of all related SRs

      Facts
      ------
      1. The above 2 actions are associated only with "Service Request Status Changed" event.

      2. If the SR's status changes to/from a particular status AND if the SR has a specified
         relationship with it's linked SRs, only then these 2 actions will be executed.

      3. NOTIFY_PRIM_CONTACT_OF_REL_SR notifies only the primary contacts of related SRs while
         NOTIFY_ALL_CONTACTS_OF_REL_SR notifies all contacts of all related SRs

         The following block handles notification rules defined for these 2 actions
   */
   ELSIF (l_action_code = 'NOTIFY_PRIM_CONTACT_OF_REL_SR') THEN

	l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NTFY_LINKED_SUBJECT_LIST');

        -- Check if the html_notification flag is set

          OPEN c_check_html_notification;
         FETCH c_check_html_notification INTO l_html_notification_flag ;
         CLOSE c_check_html_notification;

--    LOOP

      IF (l_linked_subject_list IS NOT NULL) THEN

          pull_from_list(itemlist => l_linked_subject_list,
                             element  => l_element);

	  l_notify_subject_id := TO_NUMBER(l_element);

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_SUBJECT_LIST',
              avalue          => l_linked_subject_list );

	  WF_ENGINE.SetItemAttrNumber(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_SUBJECT_ID',
              avalue          => l_notify_subject_id );

	  OPEN sel_link_csr;
	  FETCH sel_link_csr INTO sel_link_rec;
	  CLOSE sel_link_csr;

           OPEN sel_linked_sr_type_csr;
          FETCH sel_linked_sr_type_csr INTO sel_linked_sr_type_rec;
          CLOSE sel_linked_sr_type_csr;


          l_user_id := WF_ENGINE.GetItemAttrNumber(
                                     itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     aname           => 'USER_ID' );

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_INCIDENT_NUMBER',
              avalue          => sel_link_rec.incident_number );


          -- Get link Type name from link_type_id

            WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_LINK_TYPE',
                      avalue          => sel_linked_sr_type_rec.link_type_name );


              l_request_id := l_notify_subject_id;

              OPEN sel_linked_sr_details_csr;
              FETCH sel_linked_sr_details_csr into sel_linked_sr_details_rec;
              CLOSE sel_linked_sr_details_csr;

              WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_LINKED_SR_STATUS',
                      avalue          => sel_linked_sr_details_rec.name );

              WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_LINKED_SR_SUMMARY',
                      avalue          => sel_linked_sr_details_rec.summary );


                OPEN get_primary_contact_info;

        	 LOOP
                    FETCH get_primary_contact_info
                     INTO l_contact_party_id,l_contact_type,l_tmp_contact_point_id,l_sr_contact_point_type,l_sr_contact_point_id;
                    EXIT WHEN get_primary_contact_info%NOTFOUND;

                    -- get the email address from the CS schema if l_contact_type is not EMAIL.

                       -- Get primary contact point ID from cs schema

                       IF l_sr_contact_point_type <> 'EMAIL' THEN

                           OPEN get_primary_email_info_CS (l_contact_party_id) ;
                          FETCH get_primary_email_info_CS INTO l_pri_sr_contact_point_id, l_pri_email_cont_pt_id ;
                          CLOSE get_primary_email_info_CS;

                       ELSE
                         l_pri_sr_contact_point_id := l_tmp_contact_point_id;
                         l_pri_email_cont_pt_id    := l_sr_contact_point_id;
                       END IF ;

                       -- get the email address if contact point id found in CS schema.

                       IF l_pri_email_cont_pt_id IS NOT NULL THEN

                          IF (l_contact_type = 'PERSON' OR l_contact_type = 'PARTY_RELATIONSHIP') THEN

                               OPEN get_primary_email_info_HZ (l_pri_email_cont_pt_id,l_contact_party_id);
                              FETCH get_primary_email_info_HZ INTO l_contact_email;
                              CLOSE get_primary_email_info_HZ;

                          ELSIF l_contact_type = 'EMPLOYEE' THEN
                               OPEN get_primary_email_info_HR (l_contact_party_id);
                              FETCH get_primary_email_info_HR INTO l_contact_email;
                              CLOSE get_primary_email_info_HR;

                          END IF;
                       END IF;

                    -- This section gets the workflow user of the contact.

                       IF (l_contact_type = 'EMPLOYEE') THEN
                           l_orig_system := 'PER';
                           l_orig_system_id := l_contact_party_id; -- l_person_id;
                       ELSE
                           l_orig_system := 'HZ_PARTY';
                           l_orig_system_id := l_contact_party_id;
                       END IF;

                        OPEN c_user(l_orig_system,l_orig_system_id);
                       FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
                       CLOSE c_user;

                       IF (l_email_address IS NOT NULL) AND (l_contact_email IS NULL) THEN
                          l_contact_email := l_email_address;

                       END IF ;

                    -- This section finds some email address of customer contact. if email address is not present
                    -- with the WF role or as a contact point in the CS schama

                       IF ((l_email_address IS NULL) AND (l_contact_email IS NULL) AND (l_contact_type <> 'EMPLOYEE')) THEN

                          FOR get_any_cust_email_address_rec IN get_any_cust_email_address(l_contact_party_id)
                              LOOP
                                 l_contact_email := get_any_cust_email_address_rec.email_address;
                                 EXIT WHEN get_any_cust_email_address%FOUND;
                              END LOOP;
                       END IF ;

                    -- Check for WF email list length not to exceed 2000

        	    IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN

                         IF (l_contact_email IS NOT NULL)THEN

                            IF l_contact_type = 'PERSON' THEN

                                OPEN get_prim_cont_party_info_per(l_contact_party_id) ;
                               FETCH get_prim_cont_party_info_per INTO l_contact_first_name , l_contact_last_name;
                               CLOSE get_prim_cont_party_info_per;

                            ELSIF l_contact_type = 'PARTY_RELATIONSHIP' THEN

                                OPEN get_prim_cont_party_info_reln(l_contact_party_id) ;
                               FETCH get_prim_cont_party_info_reln INTO l_contact_first_name , l_contact_last_name;
                               CLOSE get_prim_cont_party_info_reln;

                            ELSIF l_contact_type = 'EMPLOYEE' THEN

                                OPEN get_prim_cont_party_info_empl(l_contact_party_id) ;
                               FETCH get_prim_cont_party_info_empl INTO l_contact_first_name , l_contact_last_name;
                               CLOSE get_prim_cont_party_info_empl;

                            END IF;

                           l_notify_contact_name := l_contact_first_name|| ' ' ||l_contact_last_name;


                              WF_ENGINE.SetItemAttrText(
                                      itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'NTFY_LINKED_SR_CONTACT',
                                      avalue          => l_notify_contact_name );

                              OPEN sel_jsp_name_csr;
                	      FETCH sel_jsp_name_csr INTO l_jsp_name;
                	      CLOSE sel_jsp_name_csr;

                	      l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
        				      || '?srID=' || sel_link_rec.incident_number;

                              --l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/ibuSRDetails.jsp?srID=' || sel_link_rec.incident_number;
                              WF_ENGINE.SetItemAttrText(
                                      itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                                      avalue          => l_serviceRequest_URL);


                    	      IF (l_contact_email_list IS NULL) THEN
	                              l_contact_email_list := l_contact_email ;
            	              ELSE
	                              l_contact_email_list := l_contact_email_list ||','||l_contact_email;
                              END IF;

                              IF (l_html_contact_email_list IS NULL) THEN
	                         l_html_contact_email_list := l_contact_email ;
	                      ELSE
	                         l_html_contact_email_list := l_html_contact_email_list ||' '||l_contact_email;
	                      END IF;

                	      -- This section gets the workflow user of the contact, if none exist create an adhoc.
                              -- If contact does not have workflow user, create an adhoc user.
                              -- Adhoc user name is re-used for performance.
                	      -- The same party_id could have different contact info, but workflow schema
                	      -- only has one user/role which is the party in hz_party.

                              IF (l_user IS NULL OR
	                	  (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
                		  (l_user is not null and l_email_address <> l_contact_email) ) THEN

                		adhoc_count := adhoc_count + 1;

                                l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

                		-- need to pass display name also, otherwise the 'To' field in mail and ntfxn
	                	-- will show the adhoc name.

                                  l_user_display_name := l_contact_first_name || ', ' || l_contact_last_name;

                                SetWorkflowAdhocUser(p_wf_username      => l_user,
                                                     p_email_address    => l_contact_email,
				                     p_display_name	=> l_user_display_name);

                              END IF;

                              IF (l_adhoc_user_list IS NULL) THEN
                               l_adhoc_user_list := l_user ;
                              ELSE
                               l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
                              END IF;

                              -- Added code for HTML Notification  (01/30/2006) release 12.0

                              IF l_html_notification_flag = 'Y' THEN

  		                 IF l_html_adhoc_user_list IS NULL THEN
				    l_html_adhoc_user_list  := l_user;
				 ELSE
				    l_html_adhoc_user_list  := l_html_adhoc_user_list ||' ' ||l_user;
				 END IF ;

                                 IF l_contact_type_list IS NULL THEN
                                    IF l_contact_type = 'EMPLOYEE' THEN
                                       l_contact_type_list := 'EMP';
                                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                                       l_contact_type_list := 'PARTY';
                                    END IF;
                                 ELSE
                                    IF l_contact_type = 'EMPLOYEE' THEN
                                       l_contact_type_list := l_contact_type_list||' '||'EMP';
                                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                                       l_contact_type_list := l_contact_type_list||' '||'PARTY';
                                    END IF;
                                 END IF ;

                                 IF l_contact_id_list IS NULL THEN
                                    IF l_contact_type = 'EMPLOYEE' THEN
                                       l_contact_id_list := NVL(l_person_id,l_contact_party_id);
                                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                                       l_contact_id_list := l_contact_party_id;
                                    END IF;
                                 ELSE
                                    IF l_contact_type = 'EMPLOYEE' THEN
                                       l_contact_id_list := l_contact_id_list||' '||NVL(l_person_id,l_contact_party_id);
                                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                                       l_contact_id_list := l_contact_id_list||' '||l_contact_party_id;
                                    END IF;
                                 END IF ;

                                 IF l_notification_pref_list IS NULL THEN
                                    l_notification_pref_list := NVL(l_notification_preference,'MAILTEXT');
                                 ELSE
                                    l_notification_pref_list := l_notification_pref_list||' '||NVL(l_notification_preference,'MAILTEXT');
                                 END IF ;

                               IF l_language_list IS NULL THEN
                                    l_language_list := NVL(l_language,'AMERICAN');
                                 ELSE
                                    l_language_list := l_language_list||' '||NVL(l_language,'AMERICAN');
                                 END IF ;
                              END IF ;   -- end if for l_html_notification_flag

                              -- 11.5.10 enhancement for create interaction when email to contact sent.

                              IF l_contact_type <> 'EMPLOYEE' THEN

      	                         IF (l_contact_party_id_list IS NULL) THEN
	           	             l_contact_party_id_list := TO_CHAR(l_contact_party_id);
                    	         ELSE
        	                     l_contact_party_id_list := l_contact_party_id_list || ' '
                            	     || TO_CHAR(l_contact_party_id);
    	                         END IF;
                              END IF;

	                      -- end 11.5.10 enhancement.
                         END IF;

	            ELSE
	               EXIT;
	            END IF;

	         END LOOP;
              CLOSE get_primary_contact_info;

              l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID' );

              -- Fix for bug 3392429. Only create ADHOC role and notification if there
              -- is/are email addresses, since we send notifications for contacts via
              -- email only. rmanabat 02/12/04 .
              IF (l_contact_email_list IS NOT NULL) THEN

         	 -- If there's just one user in the list, then make the recipient that user.
        	 IF (instr(l_adhoc_user_list, ',') = 0) THEN
        	   l_notify_recipient := l_adhoc_user_list;
        	 ELSE
        	   -- We send mass notifications to one ADHOC role which has the list of
        	   -- contact's workflow users.
        	   l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';
                   SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                                        p_user_list        => l_adhoc_user_list);
                   l_notify_recipient := l_adhoc_role;
	         END IF;

              ELSE
                 l_notify_recipient := NULL;
              END IF;


              -- 11.5.10 enhancement to Create Interaction when email to contact sent.
              /* Roopa - begin bug 3360069 */
              /* Replacing the AddItemAttr() call with WF_Engine add, get and set calls
                 to factor in the scenario where this attr already exists */

              IF (l_contact_party_id_list IS NOT NULL) THEN

                  OPEN check_if_item_attr_exists_csr;
           	  FETCH check_if_item_attr_exists_csr into l_temp_contact_id_list;


        	  /****
           	  l_temp_contact_id_list := null;
        	  l_temp_contact_id_list := WF_ENGINE.GetItemAttrText( itemtype,
				                itemkey,
				   		'CONTACT_PARTY_ID_LIST',
				   		TRUE);


 	          IF(l_temp_contact_id_list is NULL) THEN
        	  *****/

                  IF(check_if_item_attr_exists_csr%NOTFOUND) THEN
        	    WF_ENGINE.AddItemAttr( itemtype,
        	  			 itemkey,
        	  			 'CONTACT_PARTY_ID_LIST',
        				 l_contact_party_id_list);
        	  ELSE

                    WF_ENGINE.SetItemAttrText(
                              itemtype        => itemtype,
                              itemkey         => itemkey,
                              aname           => 'CONTACT_PARTY_ID_LIST',
                              avalue          => l_contact_party_id_list);


        	  END IF;

                  CLOSE check_if_item_attr_exists_csr;

              END IF;
              /* Roopa - End bug 3360069 */

      ELSE
        null;
      END IF;	/*** IF (l_linked_subject_list IS NOT NULL) ***/

--    END LOOP;

              -- set the item attributes for html notification

        IF l_html_notification_flag = 'Y' THEN
                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'ADHOC_USER_LIST',
                                 AValue => l_html_adhoc_user_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_ID_LIST',
                                 AValue => l_contact_id_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_EMAIL_LIST',
                                 AValue => l_html_contact_email_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_TYPE_LIST',
                                 AValue => l_contact_type_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'NOTIFICATION_PREFERENCE_LIST',
                                 AValue => l_notification_pref_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'LANGUAGE_LIST',
                                 AValue => l_language_list);
        END IF;

   ELSIF (l_action_code = 'NOTIFY_ALL_CONTACTS_OF_REL_SR') THEN

          OPEN c_check_html_notification;
         FETCH c_check_html_notification INTO l_html_notification_flag ;
         CLOSE c_check_html_notification;

	l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NTFY_LINKED_SUBJECT_LIST');


--    LOOP
      IF (l_linked_subject_list IS NOT NULL) THEN
              pull_from_list(itemlist => l_linked_subject_list,
                             element  => l_element);

	  l_notify_subject_id := TO_NUMBER(l_element);

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_SUBJECT_LIST',
              avalue          => l_linked_subject_list );

	  WF_ENGINE.SetItemAttrNumber(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_SUBJECT_ID',
              avalue          => l_notify_subject_id );

	  OPEN sel_link_csr;
	  FETCH sel_link_csr INTO sel_link_rec;
	  CLOSE sel_link_csr;

	  OPEN sel_linked_sr_type_csr;
	  FETCH sel_linked_sr_type_csr INTO sel_linked_sr_type_rec;
	  CLOSE sel_linked_sr_type_csr;

          l_user_id := WF_ENGINE.GetItemAttrNumber(
                                     itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     aname           => 'USER_ID' );

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_INCIDENT_NUMBER',
              avalue          => sel_link_rec.incident_number );

	  -- Get link Type name from link_type_id

	  WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINK_TYPE',
              avalue          => sel_linked_sr_type_rec.link_type_name );


      l_request_id := l_notify_subject_id;
      OPEN sel_all_contacts_csr;
	  LOOP

	    FETCH sel_all_contacts_csr
	    INTO l_contact_email, l_contact_party_id, l_person_id, l_contact_type, l_tmp_contact_point_id;
	    EXIT WHEN sel_all_contacts_csr%NOTFOUND;

	    -- Check for WF email list length not to exceed 2000
	    IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN


       	  IF (l_contact_email IS NOT NULL)THEN
              OPEN sel_contact_name_csr;
              FETCH sel_contact_name_csr INTO sel_contact_name_rec;
              CLOSE sel_contact_name_csr;

              l_notify_contact_name := sel_contact_name_rec.first_name || ' ' || sel_contact_name_rec.last_name;
              WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_LINKED_SR_CONTACT',
                      avalue          => l_notify_contact_name );

              OPEN sel_jsp_name_csr;
	      FETCH sel_jsp_name_csr INTO l_jsp_name;
	      CLOSE sel_jsp_name_csr;

	      l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
				      || '?srID=' || l_request_number;

            --l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/ibuSRDetails.jsp?srID=' || l_request_number;
              WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                      avalue          => l_serviceRequest_URL);

    	      IF (l_contact_email_list IS NULL) THEN
	              l_contact_email_list := l_contact_email ;
    	      ELSE
        	       l_contact_email_list := l_contact_email_list ||','||l_contact_email;
    	      END IF;


              IF (l_html_contact_email_list IS NULL) THEN
	          l_html_contact_email_list := l_contact_email ;
	      ELSE
	          l_html_contact_email_list := l_html_contact_email_list ||' '||l_contact_email;
	      END IF;

	      -- This section gets the workflow user of the contact, if none exist create an adhoc.
              IF (l_contact_type = 'EMPLOYEE') THEN
                l_orig_system := 'PER';
                l_orig_system_id := l_person_id;
              ELSE
                l_orig_system := 'HZ_PARTY';
                l_orig_system_id := l_contact_party_id;
              END IF;

	      /****
              WF_DIRECTORY.GetUserName( p_orig_system           => l_orig_system,
                                        p_orig_system_id        => l_orig_system_id,
                                        p_name                  => l_user,
                                        p_display_name          => l_user_display_name);
	      ***/

	      OPEN c_user(l_orig_system,l_orig_system_id);
	      FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
	      CLOSE c_user;

              -- If contact does not have workflow user, create an adhoc user.
              -- Adhoc user name is re-used for performance.
	      -- The same party_id could have different contact info, but workflow schema
	      -- only has one user/role which is the party in hz_party.

              IF (l_user IS NULL OR
		  (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
		  (l_user is not null and l_email_address <> l_contact_email) ) THEN

		adhoc_count := adhoc_count + 1;

                l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

		-- need to pass display name also, other wise the 'To' field in mail and ntfxn
		-- will show the adhoc name.
                l_user_display_name := sel_contact_name_rec.last_name || ', ' || sel_contact_name_rec.first_name;

                SetWorkflowAdhocUser(p_wf_username      => l_user,
                                     p_email_address    => l_contact_email,
				     p_display_name	=> l_user_display_name);

              END IF;


              IF (l_adhoc_user_list IS NULL) THEN
               l_adhoc_user_list := l_user ;
              ELSE
               l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
              END IF;


              -- Added code for HTML Notification  (01/30/2006) release 12.0

              IF l_html_notification_flag = 'Y' THEN

		 IF l_html_adhoc_user_list IS NULL THEN
		    l_html_adhoc_user_list  := l_user;
		 ELSE
		    l_html_adhoc_user_list  := l_html_adhoc_user_list ||' ' ||l_user;
		 END IF ;

                 IF l_contact_type_list IS NULL THEN
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_type_list := 'EMP';
                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_type_list := 'PARTY';
                    END IF;
                 ELSE
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_type_list := l_contact_type_list||' '||'EMP';
                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_type_list := l_contact_type_list||' '||'PARTY';
                    END IF;
                 END IF ;

                 IF l_contact_id_list IS NULL THEN
                     IF l_contact_type = 'EMPLOYEE' THEN
                        l_contact_id_list := l_person_id;
                     ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                        l_contact_id_list := l_contact_party_id;
                     END IF;
                 ELSE
                     IF l_contact_type = 'EMPLOYEE' THEN
                        l_contact_id_list := l_contact_id_list||' '||l_person_id;
                     ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                        l_contact_id_list := l_contact_id_list||' '||l_contact_party_id;
                     END IF;
                 END IF ;

                 IF l_notification_pref_list IS NULL THEN
                    l_notification_pref_list := NVL(l_notification_preference,'MAILTEXT');
                 ELSE
                    l_notification_pref_list := l_notification_pref_list||' '||NVL(l_notification_preference,'MAILTEXT');
                 END IF ;

                 IF l_language_list IS NULL THEN
                    l_language_list := NVL(l_language,'AMERICAN');
                 ELSE
                    l_language_list := l_language_list||' '||NVL(l_language,'AMERICAN');
                 END IF ;

               END IF ;   -- end if for l_html_notification_flag

	      -- 11.5.10 enhancement for create interaction when email to contact sent.

    	      IF (l_contact_party_id_list IS NULL) THEN
        		l_contact_party_id_list := TO_CHAR(l_contact_party_id);
    	      ELSE
        		l_contact_party_id_list := l_contact_party_id_list || ' '
        		  || TO_CHAR(l_contact_party_id);
    	      END IF;
	      -- end 11.5.10 enhancement.
          END IF;

	    ELSE
	      exit;
	    END IF;
	  END LOOP;
      CLOSE sel_all_contacts_csr;

      l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID' );

      -- Fix for bug 3392429. Only create ADHOC role and notification if there
      -- is/are email addresses, since we send notifications for contacts via
      -- email only. rmanabat 02/12/04 .

      IF (l_contact_email_list IS NOT NULL) THEN

	-- If there's just one user in the list, then make the recipient that user.

	IF (instr(l_adhoc_user_list, ',') = 0) THEN
	  l_notify_recipient := l_adhoc_user_list;
	ELSE
	  -- We send mass notifications to one ADHOC role which has the list of
	  -- contact's workflow users.
	  l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';
          SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                               p_user_list        => l_adhoc_user_list);
          l_notify_recipient := l_adhoc_role;
	END IF;

      ELSE
        l_notify_recipient := NULL;
      END IF;

      -- 11.5.10 enhancement to Create Interaction when email to contact sent.
      /* Roopa - begin bug 3360069 */
      /* Replacing the AddItemAttr() call with WF_Engine add, get and set calls
         to factor in the scenario where this attr already exists */

      IF (l_contact_party_id_list IS NOT NULL) THEN

        OPEN check_if_item_attr_exists_csr;
	FETCH check_if_item_attr_exists_csr into l_temp_contact_id_list;

	/****
            l_temp_contact_id_list := null;
	    l_temp_contact_id_list := WF_ENGINE.GetItemAttrText( itemtype,
				                itemkey,
				   		'CONTACT_PARTY_ID_LIST',
				   		TRUE);

	   IF(l_temp_contact_id_list is NULL) THEN
	*****/

	IF(check_if_item_attr_exists_csr%NOTFOUND) THEN
	  WF_ENGINE.AddItemAttr( itemtype,
				 itemkey,
				 'CONTACT_PARTY_ID_LIST',
				 l_contact_party_id_list);
 	ELSE
          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'CONTACT_PARTY_ID_LIST',
                      avalue          => l_contact_party_id_list);
        END IF;
	CLOSE check_if_item_attr_exists_csr;

      END IF;

      /* Roopa - End bug 3360069 */

    ELSE
        null;
    END IF;	/*** IF (l_linked_subject_list IS NOT NULL) ***/

--    END LOOP;

     -- set the item attributes for html notification

     IF l_html_notification_flag = 'Y' THEN

        WF_ENGINE.SetItemAttrText(
                     itemtype  => itemtype,
                     itemkey   => itemkey,
                     AName  => 'ADHOC_USER_LIST',
                     AValue => l_html_adhoc_user_list);

        WF_ENGINE.SetItemAttrText(
                     itemtype  => itemtype,
                     itemkey   => itemkey,
                     AName  => 'CONTACT_ID_LIST',
                     AValue => l_contact_id_list);

        WF_ENGINE.SetItemAttrText(
                     itemtype  => itemtype,
                     itemkey   => itemkey,
                     AName  => 'CONTACT_EMAIL_LIST',
                     AValue => l_html_contact_email_list);

        WF_ENGINE.SetItemAttrText(
                     itemtype  => itemtype,
                     itemkey   => itemkey,
                     AName  => 'CONTACT_TYPE_LIST',
                     AValue => l_contact_type_list);

        WF_ENGINE.SetItemAttrText(
                     itemtype  => itemtype,
                     itemkey   => itemkey,
                     AName  => 'NOTIFICATION_PREFERENCE_LIST',
                     AValue => l_notification_pref_list);

        WF_ENGINE.SetItemAttrText(
                     itemtype  => itemtype,
                     itemkey   => itemkey,
                     AName  => 'LANGUAGE_LIST',
                     AValue => l_language_list);

        END IF;

/* END ROOPA - 11/12/03 */

/*----- Start of Associated Party changes for Related SR -------*/

   ELSIF (l_action_code = 'NOTIFY_ALL_ASSOCIATED_PARTIES') THEN


      l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                        		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NTFY_LINKED_SUBJECT_LIST');

      l_notify_relsr_party_role_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NOTIFY_RELSR_PARTY_ROLE_LIST');

      pull_from_list(itemlist => l_notify_relsr_party_role_list,
                       element  => l_element);

      l_party_role_code := l_element;

      IF (l_party_role_code IS NOT NULL) THEN
         OPEN c_party_role_csr (l_party_role_code);
         FETCH c_party_role_csr INTO l_party_role_name;

         IF c_party_role_csr%NOTFOUND THEN
            return;
         END IF;
         CLOSE c_party_role_csr;
      ELSE
         RETURN;
      END IF;

      WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'PARTY_ROLE_NAME',
              avalue          => l_party_role_name );

      WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NOTIFY_RELSR_PARTY_ROLE_LIST',
              avalue          => l_notify_relsr_party_role_list);

--    LOOP
      IF (l_linked_subject_list IS NOT NULL) THEN
         pull_from_list(itemlist => l_linked_subject_list,
                        element  => l_element);

	 l_notify_subject_id := TO_NUMBER(l_element);

	 WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINKED_SUBJECT_LIST',
              avalue          => l_linked_subject_list );

	 WF_ENGINE.SetItemAttrNumber(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_SUBJECT_ID',
              avalue          => l_notify_subject_id );

	 OPEN sel_link_csr;
	 FETCH sel_link_csr INTO sel_link_rec;
	 CLOSE sel_link_csr;

	 OPEN sel_linked_sr_type_csr;
	 FETCH sel_linked_sr_type_csr INTO sel_linked_sr_type_rec;
	 CLOSE sel_linked_sr_type_csr;

         l_user_id := WF_ENGINE.GetItemAttrNumber(
                                    itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'USER_ID' );

	 WF_ENGINE.SetItemAttrText(
             itemtype        => itemtype,
             itemkey         => itemkey,
             aname           => 'NTFY_LINKED_INCIDENT_NUMBER',
             avalue          => sel_link_rec.incident_number );

	 -- Get link Type name from link_type_id

	 WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'NTFY_LINK_TYPE',
              avalue          => sel_linked_sr_type_rec.link_type_name );

         l_request_id := l_notify_subject_id;

         OPEN sel_linked_sr_details_csr;
        FETCH sel_linked_sr_details_csr into sel_linked_sr_details_rec;
        CLOSE sel_linked_sr_details_csr;

        WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_LINKED_SR_STATUS',
                  avalue          => sel_linked_sr_details_rec.name );



        WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_LINKED_SR_SUMMARY',
                  avalue          => sel_linked_sr_details_rec.summary );

         OPEN sel_party_role_contacts_csr;
	 LOOP

	    FETCH sel_party_role_contacts_csr
	    INTO l_contact_email, l_contact_party_id, l_person_id, l_contact_type, l_tmp_contact_point_id;
	    EXIT WHEN sel_party_role_contacts_csr%NOTFOUND;

	    -- Check for WF email list length not to exceed 2000
	    IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN

               IF (l_contact_email IS NOT NULL)THEN
                  OPEN sel_contact_name_csr;
                  FETCH sel_contact_name_csr INTO sel_contact_name_rec;
                  CLOSE sel_contact_name_csr;

                  l_notify_contact_name := sel_contact_name_rec.first_name || ' ' || sel_contact_name_rec.last_name;
                  WF_ENGINE.SetItemAttrText(
                          itemtype        => itemtype,
                          itemkey         => itemkey,
                          aname           => 'NTFY_LINKED_SR_CONTACT',
                          avalue          => l_notify_contact_name );

                  OPEN sel_jsp_name_csr;
	          FETCH sel_jsp_name_csr INTO l_jsp_name;
	          CLOSE sel_jsp_name_csr;

                  l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
                                           || '?srID=' || l_request_number;

                  WF_ENGINE.SetItemAttrText(
                          itemtype        => itemtype,
                          itemkey         => itemkey,
                          aname           => 'NTFY_REQUEST_NUMBER_URL',
                          avalue          => l_serviceRequest_URL);

                  IF (l_contact_email_list IS NULL) THEN
                     l_contact_email_list := l_contact_email ;
                  ELSE
                     l_contact_email_list := l_contact_email_list ||','||l_contact_email;
                  END IF;

                  IF (l_contact_type = 'EMPLOYEE') THEN
                    l_orig_system := 'PER';
                    l_orig_system_id := l_person_id;
                  ELSE
                    l_orig_system := 'HZ_PARTY';
                    l_orig_system_id := l_contact_party_id;
                  END IF;

	          OPEN c_user(l_orig_system,l_orig_system_id);
	          FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
	          CLOSE c_user;

                  -- If contact does not have workflow user, create an adhoc user.
                  -- Adhoc user name is re-used for performance.
	          -- The same party_id could have different contact info, but workflow schema
	          -- only has one user/role which is the party in hz_party.

                  IF (l_user IS NULL OR
		      (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
		      (l_user is not null and l_email_address <> l_contact_email) ) THEN

		     adhoc_count := adhoc_count + 1;

                     l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

                     -- need to pass display name also, other wise the 'To' field in mail and ntfxn
                     -- will show the adhoc name.
                     l_user_display_name := sel_contact_name_rec.last_name || ', ' || sel_contact_name_rec.first_name;

                     SetWorkflowAdhocUser(p_wf_username      => l_user,
                                          p_email_address    => l_contact_email,
                                          p_display_name     => l_user_display_name);

                  END IF;

                  IF (l_adhoc_user_list IS NULL) THEN
                     l_adhoc_user_list := l_user ;
                  ELSE
                     l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
                  END IF;

	          -- 11.5.10 enhancement for create interaction when email to contact sent.
    	          IF (l_contact_party_id_list IS NULL) THEN
                     l_contact_party_id_list := TO_CHAR(l_contact_party_id);
    	          ELSE
                     l_contact_party_id_list := l_contact_party_id_list || ' '
                                                || TO_CHAR(l_contact_party_id);
                  END IF;
                  -- end 11.5.10 enhancement.
               END IF;
	    ELSE
	       exit;
	    END IF;
	 END LOOP;
         CLOSE sel_party_role_contacts_csr;

         l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID' );

      -- Fix for bug 3392429. Only create ADHOC role and notification if there
      -- is/are email addresses, since we send notifications for contacts via
      -- email only. rmanabat 02/12/04 .
         IF (l_contact_email_list IS NOT NULL) THEN

	    -- If there's just one user in the list, then make the recipient that user.
            IF (instr(l_adhoc_user_list, ',') = 0) THEN
               l_notify_recipient := l_adhoc_user_list;
            ELSE
            -- We send mass notifications to one ADHOC role which has the list of
            -- contact's workflow users.
               l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';
               SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                                    p_user_list        => l_adhoc_user_list);
               l_notify_recipient := l_adhoc_role;
            END IF;

         ELSE
            l_notify_recipient := NULL;
         END IF;

      ELSE
         null;
      END IF;	/*** IF (l_linked_subject_list IS NOT NULL) ***/
/* END ROOPA - 11/12/03 */


/*------------- End of Associated Party Related SR changes ----------------*/

     ELSIF (l_action_code = 'NOTIFY_ALL_CONTACTS') THEN

        /****************************************
         For contacts, we shall be creating a workflow Adhoc role
	 when nececessary since not all contacts are employees or
	 have workflow roles, e.g., customer contact.
         We will be sending just one notification message for all the contacts
         who has e-mail addresses. The recipient role would include the list of
	 the contact's workflow user names. This is less expensive than
	sending one e-mail for each contact.
        *****************************************/

        -- Check if the html_notification flag is set

	  OPEN c_check_html_notification;
	 FETCH c_check_html_notification INTO l_html_notification_flag ;
	 CLOSE c_check_html_notification;

        OPEN sel_all_contacts_csr;

	  LOOP

	    FETCH sel_all_contacts_csr
	    INTO l_contact_email, l_contact_party_id, l_person_id, l_contact_type, l_tmp_contact_point_id;
	    EXIT WHEN sel_all_contacts_csr%NOTFOUND;

	    -- Check for WF email list length not to exceed 2000
	    IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN

	      IF (l_contact_email_list IS NULL) THEN
	       l_contact_email_list := l_contact_email ;
	      ELSE
	       l_contact_email_list := l_contact_email_list ||','||l_contact_email;
	      END IF;

       	      IF (l_html_contact_email_list IS NULL) THEN
	          l_html_contact_email_list := l_contact_email ;
	      ELSE
	          l_html_contact_email_list := l_html_contact_email_list ||' '||l_contact_email;
	      END IF;

	      -- This section gets the workflow user of the contact, if none exist create an adhoc.

              IF (l_contact_type = 'EMPLOYEE') THEN
                l_orig_system := 'PER';
                l_orig_system_id := l_person_id;
              ELSE
                l_orig_system := 'HZ_PARTY';
                l_orig_system_id := l_contact_party_id;
              END IF;

	      /****
              WF_DIRECTORY.GetUserName( p_orig_system           => l_orig_system,
                                        p_orig_system_id        => l_orig_system_id,
                                        p_name                  => l_user,
                                        p_display_name          => l_user_display_name);
	      ***/

	      OPEN c_user(l_orig_system,l_orig_system_id);
	      FETCH c_user
               INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
	      CLOSE c_user;

              -- If contact does not have workflow user, create an adhoc user.
              -- Adhoc user name is re-used for performance.
	      -- The same party_id could have different contact info, but workflow schema
	      -- only has one user/role which is the party in hz_party.

              IF (l_user IS NULL OR
		  (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
		  (l_user is not null and l_email_address <> l_contact_email) ) THEN

	 	  adhoc_count := adhoc_count + 1;

                  l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

		  -- need to pass display name also, other wise the 'To' field in mail and ntfxn
		  -- will show the adhoc name.

                   OPEN sel_contact_name_csr;
                  FETCH sel_contact_name_csr INTO sel_contact_name_rec;
                        l_user_display_name := sel_contact_name_rec.last_name || ', ' || sel_contact_name_rec.first_name;
                  CLOSE sel_contact_name_csr;

                  SetWorkflowAdhocUser(p_wf_username      => l_user,
                                     p_email_address    => l_contact_email,
				     p_display_name	=> l_user_display_name);

              END IF;

              IF (l_adhoc_user_list IS NULL) THEN
                 l_adhoc_user_list := l_user ;
              ELSE
                 l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
              END IF;

              -- Added code for HTML Notification  (01/30/2006) release 12.0

              IF l_html_notification_flag = 'Y' THEN

                 IF l_html_adhoc_user_list IS NULL THEN
		    l_html_adhoc_user_list  := l_user;
		 ELSE
		    l_html_adhoc_user_list  := l_html_adhoc_user_list ||' ' ||l_user;
		 END IF ;

                 IF l_contact_type_list IS NULL THEN
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_type_list := 'EMP';
                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_type_list := 'PARTY';
                    END IF;
                 ELSE
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_type_list := l_contact_type_list||' '||'EMP';
                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_type_list := l_contact_type_list||' '||'PARTY';
                    END IF;
                 END IF ;

                 IF l_contact_id_list IS NULL THEN
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_id_list := l_person_id;
                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_id_list := l_contact_party_id;
                    END IF;
                 ELSE
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_id_list := l_contact_id_list||' '||l_person_id;
                    ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_id_list := l_contact_id_list||' '||l_contact_party_id;
                    END IF;
                 END IF ;

                 IF l_notification_pref_list IS NULL THEN
                    l_notification_pref_list := NVL(l_notification_preference,'MAILTEXT');
                 ELSE
                    l_notification_pref_list := l_notification_pref_list||' '||NVL(l_notification_preference,'MAILTEXT');
                 END IF ;

                 IF l_language_list IS NULL THEN
                    l_language_list := NVL(l_language,'AMERICAN');
                 ELSE
                    l_language_list := l_language_list||' '||NVL(l_language,'AMERICAN');
                 END IF ;

              END IF ;   -- end if for l_html_notification_flag

	      -- 11.5.10 enhancement for create interaction when email to contact sent.

	      IF (l_contact_party_id_list IS NULL) THEN
  		 l_contact_party_id_list := TO_CHAR(l_contact_party_id);
	      ELSE
		 l_contact_party_id_list := l_contact_party_id_list || ' '
		  || TO_CHAR(l_contact_party_id);
	      END IF;
	      -- end 11.5.10 enhancement.

	    ELSE
	      EXIT;
	    END IF;

	  END LOOP;
	CLOSE sel_all_contacts_csr;

        -- set the item attributes for html notification

        IF l_html_notification_flag = 'Y' THEN

           WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'ADHOC_USER_LIST',
                        AValue => l_html_adhoc_user_list);

           WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'CONTACT_ID_LIST',
                        AValue => l_contact_id_list);

          WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'CONTACT_EMAIL_LIST',
                        AValue => l_html_contact_email_list);

          WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'CONTACT_TYPE_LIST',
                        AValue => l_contact_type_list);

          WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'NOTIFICATION_PREFERENCE_LIST',
                        AValue => l_notification_pref_list);

          WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'LANGUAGE_LIST',
                        AValue => l_language_list);

        END IF;

        OPEN sel_jsp_name_csr;
	FETCH sel_jsp_name_csr INTO l_jsp_name;
	CLOSE sel_jsp_name_csr;

	l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
				|| '?srID=' || l_request_number;
        WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                      avalue          => l_serviceRequest_URL);

        -- Fix for bug 3392429. Only create ADHOC role and notification if there
        -- is/are email addresses, since we send notifications for contacts via
        -- email . rmanabat 02/12/04 .

        IF (l_contact_email_list IS NOT NULL) THEN

	  -- If there's just one user in the list, then make the recipient that user.

	  IF (instr(l_adhoc_user_list, ',') = 0) THEN
	    l_notify_recipient := l_adhoc_user_list;
	  ELSE
	    -- We send mass notifications to one ADHOC role which has the list of
	    -- contact's workflow users.

	    l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';

            SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                                 p_user_list        => l_adhoc_user_list);

            l_notify_recipient := l_adhoc_role;

	  END IF;

        ELSE
          l_notify_recipient := NULL;
        END IF;


	-- 11.5.10 enhancement to Create Interaction when email to contact sent.
        /* Roopa - begin bug 3360069 */
	/* Replacing the AddItemAttr() call with WF_Engine add, get and set calls
           to factor in the scenario where this attr already exists */

	IF (l_contact_party_id_list IS NOT NULL) THEN

          OPEN check_if_item_attr_exists_csr;
	  FETCH check_if_item_attr_exists_csr into l_temp_contact_id_list;

	  IF(check_if_item_attr_exists_csr%NOTFOUND) THEN
	    WF_ENGINE.AddItemAttr( itemtype,
				   itemkey,
				   'CONTACT_PARTY_ID_LIST',
				   l_contact_party_id_list);
	  ELSE
            WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'CONTACT_PARTY_ID_LIST',
                      avalue          => l_contact_party_id_list);
          END IF;
	    CLOSE check_if_item_attr_exists_csr;

	END IF;
/* Roopa - End bug 3360069 */

-- Start of code for Associated Party Notification --
     ELSIF (l_action_code = 'NOTIFY_ASSOCIATED_PARTIES') THEN


        l_notify_party_role_list := WF_ENGINE.GetItemAttrText(
                           		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NOTIFY_PARTY_ROLE_LIST');

        pull_from_list(itemlist => l_notify_party_role_list,
                       element  => l_element);

        l_party_role_code := l_element;

        IF (l_party_role_code IS NOT NULL) THEN
           OPEN c_party_role_csr (l_party_role_code);
           FETCH c_party_role_csr INTO l_party_role_name;

           IF c_party_role_csr%NOTFOUND THEN
              return;
           END IF;
           CLOSE c_party_role_csr;
        ELSE
           RETURN;
        END IF;

        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'PARTY_ROLE_NAME',
                avalue          => l_party_role_name );

        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'NOTIFY_PARTY_ROLE_LIST',
                avalue          => l_notify_party_role_list);


        OPEN sel_party_role_contacts_csr;
        LOOP

           FETCH sel_party_role_contacts_csr
           INTO l_contact_email, l_contact_party_id, l_person_id, l_contact_type, l_tmp_contact_point_id;
           EXIT WHEN sel_party_role_contacts_csr%NOTFOUND;
           -- Check for WF email list length not to exceed 2000
           IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN

              IF (l_contact_email_list IS NULL) THEN
                 l_contact_email_list := l_contact_email ;
              ELSE
                 l_contact_email_list := l_contact_email_list ||','||l_contact_email;
              END IF;

              IF (l_contact_type = 'EMPLOYEE') THEN
                l_orig_system := 'PER';
                l_orig_system_id := l_person_id;
              ELSE
                l_orig_system := 'HZ_PARTY';
                l_orig_system_id := l_contact_party_id;
              END IF;

              OPEN c_user(l_orig_system,l_orig_system_id);
              FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
              CLOSE c_user;

               -- If contact does not have workflow user, create an adhoc user.
               -- Adhoc user name is re-used for performance.
               -- The same party_id could have different contact info, but workflow schema
               -- only has one user/role which is the party in hz_party.

              IF (l_user IS NULL OR
                   (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
                   (l_user is not null and l_email_address <> l_contact_email) ) THEN

                 adhoc_count := adhoc_count + 1;

                 l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

                 -- need to pass display name also, other wise the 'To' field in mail and ntfxn
                 -- will show the adhoc name.
                 OPEN sel_contact_name_csr;
                 FETCH sel_contact_name_csr INTO sel_contact_name_rec;
                 l_user_display_name := sel_contact_name_rec.last_name || ', ' || sel_contact_name_rec.first_name;
                 CLOSE sel_contact_name_csr;

                 SetWorkflowAdhocUser(p_wf_username      => l_user,
                                      p_email_address    => l_contact_email,
                                      p_display_name     => l_user_display_name);

              END IF;

              IF (l_adhoc_user_list IS NULL) THEN
                 l_adhoc_user_list := l_user ;
              ELSE
                 l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
              END IF;

	       -- 11.5.10 enhancement for create interaction when email to contact sent.
              IF (l_contact_party_id_list IS NULL) THEN
                 l_contact_party_id_list := TO_CHAR(l_contact_party_id);
              ELSE
                 l_contact_party_id_list := l_contact_party_id_list || ' '
                                            || TO_CHAR(l_contact_party_id);
              END IF;
              -- end 11.5.10 enhancement.

           ELSE
              EXIT;

           END IF;

        END LOOP;
        CLOSE sel_party_role_contacts_csr;

        OPEN sel_jsp_name_csr;
        FETCH sel_jsp_name_csr INTO l_jsp_name;
        CLOSE sel_jsp_name_csr;

        l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
                                || '?srID=' || l_request_number;
        WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                      avalue          => l_serviceRequest_URL);

        -- Fix for bug 3392429. Only create ADHOC role and notification if there
        -- is/are email addresses, since we send notifications for contacts via
        -- email . rmanabat 02/12/04 .
        IF (l_contact_email_list IS NOT NULL) THEN

           -- If there's just one user in the list, then make the recipient that user.
           IF (instr(l_adhoc_user_list, ',') = 0) THEN
              l_notify_recipient := l_adhoc_user_list;
           ELSE
              -- We send mass notifications to one ADHOC role which has the list of
              -- contact's workflow users.
              l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';
              SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                                  p_user_list        => l_adhoc_user_list);
              l_notify_recipient := l_adhoc_role;
           END IF;

        ELSE
           l_notify_recipient := NULL;
        END IF;

     ELSIF (l_action_code = 'NOTIFY_PRIMARY_CONTACT') THEN

        -- Get the primary contact's information

          OPEN get_primary_contact_info;
         FETCH get_primary_contact_info
          INTO l_contact_party_id,l_contact_type,l_tmp_contact_point_id,l_sr_contact_point_type,l_sr_contact_point_id;

        -- get the email address from the CS schema if l_contact_type is not EMAIL.

           -- Get primary contact point ID from cs schema

           IF l_sr_contact_point_type <> 'EMAIL' THEN

               OPEN get_primary_email_info_CS (l_contact_party_id) ;
              FETCH get_primary_email_info_CS INTO l_pri_sr_contact_point_id, l_pri_email_cont_pt_id ;
              CLOSE get_primary_email_info_CS;

              -- get the email address if contact point id found in CS schema.

              IF l_pri_email_cont_pt_id IS NOT NULL THEN

                 IF (l_contact_type = 'PERSON' OR l_contact_type = 'PARTY_RELATIONSHIP') THEN

                     OPEN get_primary_email_info_HZ (l_pri_sr_contact_point_id,l_contact_party_id);
                    FETCH get_primary_email_info_HZ INTO l_contact_email;
                    CLOSE get_primary_email_info_HZ;
                 ELSIF l_contact_type = 'EMPLOYEE' THEN
                     OPEN get_primary_email_info_HR (l_contact_party_id);
                    FETCH get_primary_email_info_HR INTO l_contact_email;
                    CLOSE get_primary_email_info_HR;
                 END IF;
              END IF;

           END IF ;

        -- Check if the html_notification flag is set

	  OPEN c_check_html_notification;
	 FETCH c_check_html_notification INTO l_html_notification_flag ;
         CLOSE c_check_html_notification;

        IF (get_primary_contact_info%FOUND) THEN

	  -- This section gets the workflow user of the contact, if none exist create an adhoc.

          IF (l_contact_type = 'EMPLOYEE') THEN
            l_orig_system := 'PER';
            l_orig_system_id := l_contact_party_id; --l_person_id;
          ELSE
            l_orig_system := 'HZ_PARTY';
            l_orig_system_id := l_contact_party_id;
          END IF;

	  OPEN c_user(l_orig_system,l_orig_system_id);
	  FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
	  CLOSE c_user;

          -- If contact does not have workflow user, create an adhoc user.
          -- Adhoc user name is re-used for performance.
	  -- The same party_id could have different contact info, but workflow schema
	  -- only has one user/role which is the party in hz_party.


          IF (l_user IS NULL OR
	      (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
	      (l_user is not null and l_email_address <> l_contact_email) ) THEN

 	     adhoc_count := adhoc_count + 1;

             l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

             -- Check if the email address is available.If not then get any customer email address.

             IF ((l_email_address IS NULL) AND (l_contact_email IS NULL) AND (l_contact_type <> 'EMPLOYEE')) THEN

                FOR get_any_cust_email_address_rec IN get_any_cust_email_address(l_contact_party_id)
                    LOOP
                       l_contact_email := get_any_cust_email_address_rec.email_address;
                       EXIT WHEN get_any_cust_email_address%FOUND;
                    END LOOP;
             END IF ;

	    -- need to pass display name also, other wise the 'To' field in mail and ntfxn
	    -- will show the adhoc name.

               -- Get the contact name details

               IF l_contact_type = 'PERSON' THEN

                   OPEN get_prim_cont_party_info_per(l_contact_party_id) ;
                  FETCH get_prim_cont_party_info_per INTO l_contact_first_name , l_contact_last_name;
                  CLOSE get_prim_cont_party_info_per;

               ELSIF l_contact_type = 'PARTY_RELATIONSHIP' THEN

                   OPEN get_prim_cont_party_info_reln(l_contact_party_id) ;
                  FETCH get_prim_cont_party_info_reln INTO l_contact_first_name , l_contact_last_name;
                  CLOSE get_prim_cont_party_info_reln;

               ELSIF l_contact_type = 'EMPLOYEE' THEN

                   OPEN get_prim_cont_party_info_empl(l_contact_party_id) ;
                  FETCH get_prim_cont_party_info_empl INTO l_contact_first_name , l_contact_last_name;
                  CLOSE get_prim_cont_party_info_empl;

               END IF;


               l_user_display_name := l_contact_last_name || ', ' || l_contact_first_name;

               SetWorkflowAdhocUser(p_wf_username      => l_user,
                                 p_email_address    => NVL(l_contact_email,l_email_address),
				 p_display_name	    => l_user_display_name);

          END IF;

          -- Added code for HTML Notification  (01/30/2006) release 12.0


          IF l_html_notification_flag = 'Y' THEN

             IF (l_html_contact_email_list IS NULL) THEN
	        l_html_contact_email_list := NVL(l_contact_email,l_email_address) ;
	     ELSE
	        l_html_contact_email_list := l_html_contact_email_list ||' '||NVL(l_contact_email,l_email_address);
	     END IF;

             IF l_html_adhoc_user_list IS NULL THEN
                l_html_adhoc_user_list := l_user;
             ELSE
                l_html_adhoc_user_list := l_html_adhoc_user_list||' '||l_user;
             END IF;

             IF l_contact_type_list IS NULL THEN
                IF l_contact_type = 'EMPLOYEE' THEN
                   l_contact_type_list := 'EMP';
                ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                   l_contact_type_list := 'PARTY';
                END IF;
             ELSE
                IF l_contact_type = 'EMPLOYEE' THEN
                   l_contact_type_list := l_contact_type_list||' '||'EMP';
                ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                   l_contact_type_list := l_contact_type_list||' '||'PARTY';
                END IF;
             END IF ;

             IF l_contact_id_list IS NULL THEN
                IF l_contact_type = 'EMPLOYEE' THEN
                   l_contact_id_list := l_contact_party_id; --l_person_id;
                ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                   l_contact_id_list := l_contact_party_id;
                END IF;
             ELSE
                IF l_contact_type = 'EMPLOYEE' THEN
                   l_contact_id_list := l_contact_id_list||' '||l_contact_party_id; --l_person_id;
                ELSE -- IF l_contact_type = 'HZ_PARTY' THEN
                   l_contact_id_list := l_contact_id_list||' '||l_contact_party_id;
                END IF;
             END IF ;

             IF l_notification_pref_list IS NULL THEN
                l_notification_pref_list := NVL(l_notification_preference,'MAILTEXT');
             ELSE
                l_notification_pref_list := l_notification_pref_list||' '||NVL(l_notification_preference,'MAILTEXT');
             END IF ;

             IF l_language_list IS NULL THEN
                l_language_list := NVL(l_language,'AMERICAN');
             ELSE
                l_language_list := l_language_list||' '||NVL(l_language,'AMERICAN');
             END IF ;

          END IF ;   -- end if for l_html_notification_flag

              IF l_html_notification_flag = 'Y' THEN

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'ADHOC_USER_LIST',
                                 AValue => l_html_adhoc_user_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_ID_LIST',
                                 AValue => l_contact_id_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_EMAIL_LIST',
                                 AValue => l_html_contact_email_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_TYPE_LIST',
                                 AValue => l_contact_type_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'NOTIFICATION_PREFERENCE_LIST',
                                 AValue => l_notification_pref_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'LANGUAGE_LIST',
                                 AValue => l_language_list);

              END IF;

          --l_notify_recipient := l_adhoc_role;
            l_notify_recipient := l_user;

	  -- 11.5.10 enhancement to Create Interaction when email to contact sent.
	  /* Roopa - begin bug 3360069 */
	  /* Replacing the AddItemAttr() call with WF_Engine add, get and set calls
	     to factor in the scenario where this attr already exists */

	  IF ((l_contact_party_id IS NOT NULL) AND (l_contact_type <> 'EMPLOYEE')) THEN

            OPEN check_if_item_attr_exists_csr;
	    FETCH check_if_item_attr_exists_csr into l_temp_contact_id_list;

	    IF(check_if_item_attr_exists_csr%NOTFOUND) THEN
		    WF_ENGINE.AddItemAttr( itemtype,
					   itemkey,
				  	   'CONTACT_PARTY_ID_LIST',
				   	   l_contact_party_id);
	    ELSE
              WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'CONTACT_PARTY_ID_LIST',
                      avalue          => l_contact_party_id);
            END IF;
	    CLOSE check_if_item_attr_exists_csr;

	  END IF;

          OPEN sel_jsp_name_csr;
	  FETCH sel_jsp_name_csr INTO l_jsp_name;
	  CLOSE sel_jsp_name_csr;

	  l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
				|| '?srID=' || l_request_number;
          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                      avalue          => l_serviceRequest_URL);

	END IF;		-- IF (get_primary_contact_info%FOUND

        CLOSE get_primary_contact_info;

-- End of code for Associated Party Notification

      ELSIF (l_action_code = 'NOTIFY_NEW_CONTACT') THEN

        -- Check if the html_notification flag is set

	  OPEN c_check_html_notification;
	 FETCH c_check_html_notification INTO l_html_notification_flag ;
	 CLOSE c_check_html_notification;

        l_contact_point_id_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NEW_CONTACT_POINT_ID_LIST' );

        pull_from_list(itemlist => l_contact_point_id_list,
                       element  => l_element);

        WHILE l_element IS NOT NULL LOOP

	  l_contact_point_id := TO_NUMBER(l_element);

          OPEN sel_new_contact_csr;
	  FETCH sel_new_contact_csr
	  INTO l_contact_email, l_contact_party_id, l_person_id, l_contact_type, l_tmp_contact_point_id;
	  IF (sel_new_contact_csr%FOUND OR l_contact_email IS NOT NULL)THEN

	    -- Check for WF email list length not to exceed 2000
	    IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN

	      IF (l_contact_email_list IS NULL) THEN
	          l_contact_email_list := l_contact_email ;
	      ELSE
	          l_contact_email_list := l_contact_email_list ||','||l_contact_email;
	      END IF;

       	      IF (l_html_contact_email_list IS NULL) THEN
  	          l_html_contact_email_list := l_contact_email ;
	      ELSE
	          l_html_contact_email_list := l_html_contact_email_list ||' '||l_contact_email;
	      END IF;

	      -- This section gets the workflow user of the contact, if none exist create an adhoc.

              IF (l_contact_type = 'EMPLOYEE') THEN
                l_orig_system := 'PER';
                l_orig_system_id := l_person_id;
              ELSE
                l_orig_system := 'HZ_PARTY';
                l_orig_system_id := l_contact_party_id;
              END IF;

	      OPEN c_user(l_orig_system,l_orig_system_id);
	      FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
	      CLOSE c_user;

              -- If contact does not have workflow user, create an adhoc user.
              -- Adhoc user name is re-used for performance.
	      -- The same party_id could have different contact info, but workflow schema
	      -- only has one user/role which is the party in hz_party.

              IF (l_user IS NULL OR
	          (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
	          (l_user is not null and l_email_address <> l_contact_email) ) THEN

	        adhoc_count := adhoc_count + 1;

                l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

	        -- need to pass display name also, other wise the 'To' field in mail and ntfxn
	        -- will show the adhoc name.
                OPEN sel_contact_name_csr;
                FETCH sel_contact_name_csr INTO sel_contact_name_rec;
                l_user_display_name := sel_contact_name_rec.last_name || ', ' || sel_contact_name_rec.first_name;
                CLOSE sel_contact_name_csr;

                SetWorkflowAdhocUser(p_wf_username      => l_user,
                                     p_email_address    => l_contact_email,
				     p_display_name	=> l_user_display_name);

              END IF;

              IF (l_adhoc_user_list IS NULL) THEN
               l_adhoc_user_list := l_user ;
              ELSE
               l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
              END IF;

              IF l_html_adhoc_user_list IS NULL THEN
		 l_html_adhoc_user_list  := l_user;
	      ELSE
	         l_html_adhoc_user_list  := l_html_adhoc_user_list ||' ' ||l_user;
	      END IF ;

	      -- 11.5.10 enhancement for create interaction when email to contact sent.
	      IF (l_contact_party_id_list IS NULL) THEN
		l_contact_party_id_list := TO_CHAR(l_contact_party_id);
	      ELSE
		l_contact_party_id_list := l_contact_party_id_list || ' '
		  || TO_CHAR(l_contact_party_id);
	      END IF;

	      -- end 11.5.10 enhancement.

	    ELSE
	      EXIT;

	    END IF;

            -- Added code for HTML Notification  (01/30/2006) release 12.0

            IF l_html_notification_flag = 'Y' THEN

               IF l_contact_type_list IS NULL THEN
                  IF l_contact_type = 'EMPLOYEE' THEN
                     l_contact_type_list := 'EMP';
                  ELSE --IF l_contact_type = 'HZ_PARTY' THEN
                     l_contact_type_list := 'PARTY';
                  END IF;
                ELSE
                  IF l_contact_type = 'EMPLOYEE' THEN
                     l_contact_type_list := l_contact_type_list||' '||'EMP';
                  ELSE --IF l_contact_type = 'HZ_PARTY' THEN
                     l_contact_type_list := l_contact_type_list||' '||'PARTY';
                  END IF;
                END IF ;

                IF l_contact_id_list IS NULL THEN
                   IF l_contact_type = 'EMPLOYEE' THEN
                      l_contact_id_list := l_person_id;
                   ELSE --IF l_contact_type = 'HZ_PARTY' THEN
                      l_contact_id_list := l_contact_party_id;
                   END IF;
                 ELSE
                    IF l_contact_type = 'EMPLOYEE' THEN
                       l_contact_id_list := l_contact_id_list||' '||l_person_id;
                    ELSE --IF l_contact_type = 'HZ_PARTY' THEN
                       l_contact_id_list := l_contact_id_list||' '||l_contact_party_id;
                    END IF;
                 END IF ;

                 IF l_notification_pref_list IS NULL THEN
                    l_notification_pref_list := NVL(l_notification_preference,'MAILTEXT');
                 ELSE
                    l_notification_pref_list := l_notification_pref_list||' '||NVL(l_notification_preference,'MAILTEXT');
                 END IF ;

                 IF l_language_list IS NULL THEN
                    l_language_list := NVL(l_language,'AMERICAN');
                 ELSE
                    l_language_list := l_language_list||' '||NVL(l_language,'AMERICAN');
                 END IF ;

              END IF ;   -- end if for l_html_notification_flag

              IF l_html_notification_flag = 'Y' THEN

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'ADHOC_USER_LIST',
                                 AValue => l_html_adhoc_user_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_ID_LIST',
                                 AValue => l_contact_id_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_EMAIL_LIST',
                                 AValue => l_html_contact_email_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'CONTACT_TYPE_LIST',
                                 AValue => l_contact_type_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'NOTIFICATION_PREFERENCE_LIST',
                                 AValue => l_notification_pref_list);

                  WF_ENGINE.SetItemAttrText(
                                 itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AName  => 'LANGUAGE_LIST',
                                 AValue => l_language_list);

              END IF;

          END IF;
	  CLOSE sel_new_contact_csr;

          pull_from_list(itemlist => l_contact_point_id_list,
                         element  => l_element);

        END LOOP;


        -- Fix for bug 3392429. Only create ADHOC role and notification if there
        -- is/are email addresses, since we send notifications for contacts via
        -- email . rmanabat 02/12/04 .

        IF (l_contact_email_list IS NOT NULL) THEN

	  -- If there's just one user in the list, then make the recipient that user.
	  IF (instr(l_adhoc_user_list, ',') = 0) THEN
	    l_notify_recipient := l_adhoc_user_list;
	  ELSE
	    -- We send mass notifications to one ADHOC role which has the list of
	    -- contact's workflow users.
	    l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';
            SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                                 p_user_list        => l_adhoc_user_list);
            l_notify_recipient := l_adhoc_role;
	  END IF;

          OPEN sel_jsp_name_csr;
	  FETCH sel_jsp_name_csr INTO l_jsp_name;
	  CLOSE sel_jsp_name_csr;

	  l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
				|| '?srID=' || l_request_number;
          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                      avalue          => l_serviceRequest_URL);

	ELSE
          l_notify_recipient := NULL;
	END IF;


	-- 11.5.10 enhancement to Create Interaction when email to contact sent.
	/* Roopa - begin bug 3360069 */
	/* Replacing the AddItemAttr() call with WF_Engine add, get and set calls
	   to factor in the scenario where this attr already exists */
	IF (l_contact_party_id_list IS NOT NULL) THEN

          OPEN check_if_item_attr_exists_csr;
	  FETCH check_if_item_attr_exists_csr into l_temp_contact_id_list;

	  IF(check_if_item_attr_exists_csr%NOTFOUND) THEN
	    WF_ENGINE.AddItemAttr( itemtype,
				   itemkey,
				   'CONTACT_PARTY_ID_LIST',
				   l_contact_party_id_list);
	  ELSE
            WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'CONTACT_PARTY_ID_LIST',
                      avalue          => l_contact_party_id_list);
          END IF;
	  CLOSE check_if_item_attr_exists_csr;

	END IF;
/* Roopa - End bug 3360069 */

-- Start of code for Associated Party Notification -- Associated Party Added
      ELSIF (l_action_code = 'NOTIFY_NEW_ASSOCIATE_PARTY_ADD') THEN

        l_contact_point_id_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NEW_ASSOCIATED_PARTY_ID_LIST' );

        pull_from_list(itemlist => l_contact_point_id_list,
                       element  => l_element);

        l_contact_email_list:= null;

        WHILE l_element IS NOT NULL LOOP

	  l_contact_point_id := TO_NUMBER(l_element);

          OPEN sel_new_party_role_contact_csr;
	  FETCH sel_new_party_role_contact_csr
	  INTO l_contact_email, l_contact_party_id, l_person_id, l_contact_type, l_tmp_contact_point_id,
               l_party_role_name, l_party_role_code;

          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'PARTY_ROLE_CODE',
                      avalue          => l_party_role_code);

          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'PARTY_ROLE_NAME',
                      avalue          => l_party_role_name);

	  IF (sel_new_party_role_contact_csr%FOUND OR l_contact_email IS NOT NULL)THEN

	    -- Check for WF email list length not to exceed 2000
	    IF (nvl(LENGTH(l_contact_email_list), 0) + nvl(LENGTH(l_contact_email),0) + 1) <= 2000 THEN

	      IF (l_contact_email_list IS NULL) THEN
	       l_contact_email_list := l_contact_email ;
	      ELSE
	       l_contact_email_list := l_contact_email_list ||','||l_contact_email;
	      END IF;


	      -- This section gets the workflow user of the contact, if none exist create an adhoc.
              IF (l_contact_type = 'EMPLOYEE') THEN
                l_orig_system := 'PER';
                l_orig_system_id := l_person_id;
              ELSE
                l_orig_system := 'HZ_PARTY';
                l_orig_system_id := l_contact_party_id;
              END IF;

	      OPEN c_user(l_orig_system,l_orig_system_id);
	      FETCH c_user INTO l_user, l_user_display_name, l_email_address, l_notification_preference,l_language;
	      CLOSE c_user;

              -- If contact does not have workflow user, create an adhoc user.
              -- Adhoc user name is re-used for performance.
	      -- The same party_id could have different contact info, but workflow schema
	      -- only has one user/role which is the party in hz_party.

              IF (l_user IS NULL OR
	          (l_user is not null and instr(l_adhoc_user_list,l_user) > 0) OR
	          (l_user is not null and l_email_address <> l_contact_email) ) THEN

	        adhoc_count := adhoc_count + 1;

                l_user := 'CS_WF_CONTACT_USER_DUMMY' || to_char(adhoc_count) ;

	        -- need to pass display name also, other wise the 'To' field in mail and ntfxn
	        -- will show the adhoc name.
                OPEN sel_contact_name_csr;
                FETCH sel_contact_name_csr INTO sel_contact_name_rec;
                l_user_display_name := sel_contact_name_rec.last_name || ', ' || sel_contact_name_rec.first_name;
                CLOSE sel_contact_name_csr;

                SetWorkflowAdhocUser(p_wf_username      => l_user,
                                     p_email_address    => l_contact_email,
				     p_display_name	=> l_user_display_name);

              END IF;

              IF (l_adhoc_user_list IS NULL) THEN
               l_adhoc_user_list := l_user ;
              ELSE
               l_adhoc_user_list := l_adhoc_user_list ||','||l_user;
              END IF;

	      -- 11.5.10 enhancement for create interaction when email to contact sent.
	      IF (l_contact_party_id_list IS NULL) THEN
		l_contact_party_id_list := TO_CHAR(l_contact_party_id);
	      ELSE
		l_contact_party_id_list := l_contact_party_id_list || ' '
		  || TO_CHAR(l_contact_party_id);
	      END IF;
	      -- end 11.5.10 enhancement.

	    ELSE
	      EXIT;

	    END IF;
          END IF;
	  CLOSE sel_new_party_role_contact_csr;

          pull_from_list(itemlist => l_contact_point_id_list,
                         element  => l_element);

        END LOOP;

        -- Fix for bug 3392429. Only create ADHOC role and notification if there
        -- is/are email addresses, since we send notifications for contacts via
        -- email . rmanabat 02/12/04 .
        IF (l_contact_email_list IS NOT NULL) THEN

	  -- If there's just one user in the list, then make the recipient that user.
	  IF (instr(l_adhoc_user_list, ',') = 0) THEN
	    l_notify_recipient := l_adhoc_user_list;
	  ELSE
	    -- We send mass notifications to one ADHOC role which has the list of
	    -- contact's workflow users.
	    l_adhoc_role := 'CS_WF_CONTACT_ROLE_DUMMY';
            SetWorkflowAdhocRole(p_wf_rolename      => l_adhoc_role,
                                 p_user_list        => l_adhoc_user_list);
            l_notify_recipient := l_adhoc_role;
	  END IF;

          OPEN sel_jsp_name_csr;
	  FETCH sel_jsp_name_csr INTO l_jsp_name;
	  CLOSE sel_jsp_name_csr;

	  l_serviceRequest_URL := FND_PROFILE.Value('JTF_BIS_OA_HTML') || '/' || l_jsp_name
				|| '?srID=' || l_request_number;
          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'NTFY_REQUEST_NUMBER_URL',
                      avalue          => l_serviceRequest_URL);

	ELSE
          l_notify_recipient := NULL;
	END IF;

-- End of code for Associated Party Notification -- Associated Party Added

      END IF;	-- IF (l_action_code = 'NOTIFY_OWNER' OR .......

      -- Get the message template to be used for the notification
      l_notification_template_id := WF_ENGINE.GetItemAttrText(
                        		itemtype        => itemtype,
                        		itemkey         => itemkey,
                        		aname           => 'NTFY_MESSAGE_NAME');

      IF (l_notify_recipient IS NOT NULL AND l_notification_template_id IS NOT NULL)THEN

         IF l_html_notification_flag = 'Y' THEN
            result := 'COMPLETE:SET_HTML';
         ELSE
            result := 'COMPLETE:SET';
         END IF;

        -- Set the recipient role for the notification
        WF_ENGINE.SetItemAttrText(
                          itemtype        => itemtype,
                          itemkey         => itemkey,
                          aname           => 'NTFY_RECIPIENT',
                          avalue          => l_notify_recipient);

      ELSE
        result := 'COMPLETE:UNSET';
      END IF;

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Set_Notification_Details',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Set_Notification_Details;



  /******************************************************************
  -- Create_Contact_Interaction
  --
  ******************************************************************/

  PROCEDURE Create_Contact_Interaction( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_contact_party_id_list	VARCHAR2(2000);
    l_contact_party_id		NUMBER;
    l_contact_party_name	VARCHAR2(360);
    l_element			VARCHAR2(100);
    l_request_id		NUMBER;
    l_request_number		VARCHAR2(64);
    l_user_id			NUMBER;
    l_resp_appl_id		NUMBER;
    l_login_id			NUMBER;
    l_resp_id			NUMBER;

    l_owner_role		VARCHAR2(320);
    l_error_role		VARCHAR2(320);

    l_msg_index_OUT		NUMBER;
    l_error_text		VARCHAR2(2000);
    NL				VARCHAR2(1) := fnd_global.Local_Chr(10);
    x_return_status		VARCHAR2(1);
    x_resource_id		NUMBER;
    x_resource_type		VARCHAR2(50);
    x_msg_count			NUMBER;
    x_msg_data			VARCHAR2(2000);


    CURSOR sel_contact_party_name_csr IS
      SELECT PARTY_NAME
      FROM HZ_PARTIES
      WHERE
          PARTY_ID = l_contact_party_id;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_contact_party_id_list := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'CONTACT_PARTY_ID_LIST',
	  				  ignore_notfound => TRUE);

      IF (l_contact_party_id_list IS NULL) THEN

        result := 'COMPLETE:NA';

      ELSE

        pull_from_list(itemlist => l_contact_party_id_list,
                       element  => l_element);

        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'CONTACT_PARTY_ID_LIST',
                avalue          => l_contact_party_id_list );

        l_contact_party_id := TO_NUMBER(l_element);

        l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID' );
        l_request_number := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_NUMBER' );
        l_user_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'USER_ID' );
        l_resp_appl_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'RESP_APPL_ID' );
        l_resp_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'RESP_ID' );

	l_owner_role := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'OWNER_ROLE' );


	IF (FND_GLOBAL.LOGIN_ID NOT IN (-1,0)) THEN
          l_login_id := FND_GLOBAL.LOGIN_ID;
        ELSE
          l_login_id := NULL;
        END IF;


        --CS_WF_CONTACT_ACT_PKG.Create_Interaction_Activity(
        Create_Interaction_Activity(
  		  	p_api_revision		=> 1.0,
			p_incident_id		=> l_request_id,
			p_incident_number	=> l_request_number,
                        p_party_id		=> l_contact_party_id,
                        p_user_id		=> l_user_id,
                        p_resp_appl_id		=> l_resp_appl_id,
			p_resp_id		=> l_resp_id,
                        p_login_id		=> l_login_id,
                        x_return_status		=> x_return_status,
                        x_resource_id		=> x_resource_id,
                        x_resource_type		=> x_resource_type,
                        x_msg_count		=> x_msg_count,
                        x_msg_data		=> x_msg_data);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

          result := 'COMPLETE:NOTCREATED';

	  IF ( FND_MSG_PUB.Count_Msg > 0) THEN
              FOR i IN 1..FND_MSG_PUB.Count_Msg    LOOP
                FND_MSG_PUB.Get(p_msg_index     => i,
                                p_encoded       => 'F',
                                p_data          => x_msg_data,
                                p_msg_index_OUT => l_msg_index_OUT );
                l_error_text := l_error_text || x_msg_data ||NL;
              END LOOP;
          END IF;

          WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'INTERACTION_ERR_DATA',
                avalue          => l_error_text );

          OPEN sel_contact_party_name_csr;
	  FETCH sel_contact_party_name_csr INTO l_contact_party_name;
	  CLOSE sel_contact_party_name_csr;

          WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'INTERACTION_PARTY_NAME',
                avalue          => l_contact_party_name );

	  -- Part of fix for bug 3360069. rmanabat 01/19/04.
	  IF (l_owner_role is NOT NULL) THEN
	    l_error_role := l_owner_role;
	  ELSE
	    l_error_role := 'SYSADMIN';
	  END IF;
	  WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'INTERACTION_ERROR_ROLE',
                avalue          => l_error_role );

        ELSE
          result := 'COMPLETE:CREATED';
        END IF;


      END IF;   -- IF (l_contact_party_id_list IS NOT NULL)


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Create_Contact_Interaction',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Create_Contact_Interaction;


  /******************************************************************
  -- All_Interactions_Created
  --
  ******************************************************************/

  PROCEDURE All_Interactions_Created( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_contact_party_id_list	VARCHAR2(2000);


  BEGIN

    IF (funmode = 'RUN') THEN

      l_contact_party_id_list := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'CONTACT_PARTY_ID_LIST',
					ignore_notfound => TRUE);

      IF (l_contact_party_id_list IS NULL) THEN
        result := 'COMPLETE:Y';
      ELSE
        result := 'COMPLETE:N';
      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'All_Interactions_Created',
                      itemtype, itemkey, actid, funmode);
      RAISE;

  END All_Interactions_Created;


  /******************************************************************
  -- All_Recipients_Notified
  --
  --   This procedure corresponds to the VRFY_NTFY_LIST_DONE function
  --   activity.
  --
  --   This procedure checks if all the recipients of the related
  --   service requests have been notified. If all the related SRs
  --   did not fit in the initial list, then we will have to build
  --   another list here to determine the recipients of the ntfxn.
  ******************************************************************/

  PROCEDURE All_Recipients_Notified( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_action_code		CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_linked_subject_list       VARCHAR2(4000);
    l_overflow_flag		VARCHAR2(1);
    l_relationship_type_id	CS_SR_ACTION_DETAILS.relationship_type_id%TYPE;
    l_event_condition_id        CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_char_subject_id        	VARCHAR2(30);
    l_subject_id		NUMBER;
    l_request_number            VARCHAR2(64);
    l_request_id		NUMBER;

    l_notify_relsr_party_role_list  VARCHAR2(2000);
    l_notify_party_role_list        VARCHAR2(2000);


    CURSOR sel_event_action_csr IS
      SELECT csad.event_condition_id,
             csad.action_code,
             csad.notification_template_id,	/** this is the WF message name  **/
	     csad.relationship_type_id detail_link_type
        FROM CS_SR_ACTION_DETAILS csad
       WHERE csad.event_condition_id = l_event_condition_id
	  and csad.action_code = l_action_code
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csad.notification_template_id IS NOT NULL
          and csad.action_code like 'NOTIFY%';

    sel_event_action_rec	sel_event_action_csr%ROWTYPE;


    CURSOR sel_link_csr_1 IS
      SELECT
        cil.object_id,
        cil.link_id,
	inc.incident_owner_id
      FROM cs_incident_links cil,
	   cs_incidents_all_b inc
      WHERE cil.subject_id = l_request_id
	and inc.incident_id = cil.object_id
	and cil.object_id > l_subject_id
      ORDER BY cil.object_id;

    CURSOR sel_link_csr_2 IS
      SELECT
        cil.object_id,
        cil.link_id,
	inc.incident_owner_id
      FROM cs_incident_links cil,
	   cs_incidents_all_b inc
      WHERE cil.subject_id = l_request_id
        AND cil.link_type_id = l_relationship_type_id
	AND inc.incident_id = cil.object_id
	and cil.object_id > l_subject_id
      ORDER BY cil.object_id;

    sel_link_rec        sel_link_csr_1%ROWTYPE;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_action_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_ACTION_CODE' );

      IF (l_action_code = 'NOTIFY_OWNER_OF_RELATED_SR') OR
         (l_action_code = 'NOTIFY_PRIM_CONTACT_OF_REL_SR') OR
         (l_action_code = 'NOTIFY_ALL_CONTACTS_OF_REL_SR') THEN

	l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                          		aname           => 'NTFY_LINKED_SUBJECT_LIST');

        IF (l_linked_subject_list IS NOT NULL) THEN

          result := 'COMPLETE:N';

	ELSE

	  l_overflow_flag := WF_ENGINE.GetItemAttrText(
          			itemtype        => itemtype,
              			itemkey         => itemkey,
              			aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST');

          IF (l_overflow_flag = 'Y') THEN

	    -- Reset the Overflow flag
            WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST',
                      avalue          => '' );

            l_event_condition_id := WF_ENGINE.GetItemAttrNumber(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'NTFY_EVENT_CONDITION_ID' );

	    l_subject_id := WF_ENGINE.GetItemAttrNumber(
              				itemtype        => itemtype,
              				itemkey         => itemkey,
              				aname           => 'NTFY_SUBJECT_ID');

            l_request_number := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_NUMBER' );

            l_request_id := WF_ENGINE.GetItemAttrNumber(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_ID' );

	    IF (sel_event_action_rec.detail_link_type IS NOT NULL) THEN
	      l_relationship_type_id := sel_event_action_rec.detail_link_type;
	      OPEN sel_link_csr_2;
            ELSE
	      OPEN sel_link_csr_1;
	    END IF;

            LOOP
	      IF (sel_event_action_rec.detail_link_type IS NOT NULL) THEN
	        FETCH sel_link_csr_2 INTO sel_link_rec;
	        EXIT WHEN sel_link_csr_2%NOTFOUND;
	      ELSE
	        FETCH sel_link_csr_1 INTO sel_link_rec;
	        EXIT WHEN sel_link_csr_1%NOTFOUND;
	      END IF;

	      l_char_subject_id := TO_CHAR(sel_link_rec.object_id);

	      IF ((nvl(LENGTH(l_linked_subject_list),0) +
		   nvl(LENGTH(l_char_subject_id),0) + 1) <= 4000) THEN
	        IF l_linked_subject_list IS NULL THEN
	          l_linked_subject_list := l_char_subject_id;
                ELSE
	          l_linked_subject_list := l_linked_subject_list || ' ' || l_char_subject_id;
                END IF;
	      ELSE	/**** Will need to build another list later since it won't fit here ***/
	         WF_ENGINE.SetItemAttrText(
              		itemtype        => itemtype,
              		itemkey         => itemkey,
              		aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST',
              		avalue          => 'Y' );
	         EXIT;
	      END IF;

            END LOOP;

	    IF sel_link_csr_2%ISOPEN THEN
	      CLOSE sel_link_csr_2;
	    ELSIF sel_link_csr_1%ISOPEN THEN
	      CLOSE sel_link_csr_1;
	    END IF;

	    IF (l_linked_subject_list IS NOT NULL) THEN

	      WF_ENGINE.SetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'NTFY_LINKED_SUBJECT_LIST',
                                avalue          => l_linked_subject_list );

	      result := 'COMPLETE:N';
	    ELSE
              result := 'COMPLETE:Y';
	    END IF;
          ELSE	/*** IF (l_overflow_flag = 'Y') ***/
              result := 'COMPLETE:Y';
          END IF;

        END IF;	/*** IF (l_linked_subject_list IS NOT NULL) ***/

      ELSIF (l_action_code = 'NOTIFY_ALL_ASSOCIATED_PARTIES') THEN

        l_notify_relsr_party_role_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NOTIFY_RELSR_PARTY_ROLE_LIST');

	l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                          		itemtype        => itemtype,
                          		itemkey         => itemkey,
                          		aname           => 'NTFY_LINKED_SUBJECT_LIST');

        IF (l_linked_subject_list IS NOT NULL or l_notify_relsr_party_role_list IS NOT NULL) THEN

          result := 'COMPLETE:N';

	ELSE

	  l_overflow_flag := WF_ENGINE.GetItemAttrText(
          			itemtype        => itemtype,
              			itemkey         => itemkey,
              			aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST');

          IF (l_overflow_flag = 'Y') THEN

	    -- Reset the Overflow flag
            WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST',
                      avalue          => '' );

            l_event_condition_id := WF_ENGINE.GetItemAttrNumber(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'NTFY_EVENT_CONDITION_ID' );

	    l_subject_id := WF_ENGINE.GetItemAttrNumber(
              				itemtype        => itemtype,
              				itemkey         => itemkey,
              				aname           => 'NTFY_SUBJECT_ID');

            l_request_number := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_NUMBER' );

            l_request_id := WF_ENGINE.GetItemAttrNumber(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_ID' );

	    IF (sel_event_action_rec.detail_link_type IS NOT NULL) THEN
	      l_relationship_type_id := sel_event_action_rec.detail_link_type;
	      OPEN sel_link_csr_2;
            ELSE
	      OPEN sel_link_csr_1;
	    END IF;

            LOOP
	      IF (sel_event_action_rec.detail_link_type IS NOT NULL) THEN
	        FETCH sel_link_csr_2 INTO sel_link_rec;
	        EXIT WHEN sel_link_csr_2%NOTFOUND;
	      ELSE
	        FETCH sel_link_csr_1 INTO sel_link_rec;
	        EXIT WHEN sel_link_csr_1%NOTFOUND;
	      END IF;

	      l_char_subject_id := TO_CHAR(sel_link_rec.object_id);

	      IF ((nvl(LENGTH(l_linked_subject_list),0) +
		   nvl(LENGTH(l_char_subject_id),0) + 1) <= 4000) THEN
	        IF l_linked_subject_list IS NULL THEN
	          l_linked_subject_list := l_char_subject_id;
                ELSE
	          l_linked_subject_list := l_linked_subject_list || ' ' || l_char_subject_id;
                END IF;
	      ELSE	/**** Will need to build another list later since it won't fit here ***/
	         WF_ENGINE.SetItemAttrText(
              		itemtype        => itemtype,
              		itemkey         => itemkey,
              		aname           => 'MORE_NTFY_LINKED_SUBJECT_LIST',
              		avalue          => 'Y' );
	         EXIT;
	      END IF;

            END LOOP;

	    IF sel_link_csr_2%ISOPEN THEN
	      CLOSE sel_link_csr_2;
	    ELSIF sel_link_csr_1%ISOPEN THEN
	      CLOSE sel_link_csr_1;
	    END IF;

	    IF (l_linked_subject_list IS NOT NULL) THEN

	      WF_ENGINE.SetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'NTFY_LINKED_SUBJECT_LIST',
                                avalue          => l_linked_subject_list );

	      result := 'COMPLETE:N';
	    ELSE
              result := 'COMPLETE:Y';
	    END IF;
          ELSE	/*** IF (l_overflow_flag = 'Y') ***/
            result := 'COMPLETE:Y';
          END IF;

        END IF;	/*** IF (l_linked_subject_list IS NOT NULL) ***/

      ELSIF (l_action_code = 'NOTIFY_ASSOCIATED_PARTIES') THEN
        l_notify_party_role_list := WF_ENGINE.GetItemAttrText(
                           		itemtype        => itemtype,
                          		itemkey         => itemkey,
                           		aname           => 'NOTIFY_PARTY_ROLE_LIST');

        IF (l_notify_party_role_list IS NOT NULL) THEN
          result := 'COMPLETE:N';
	ELSE
          result := 'COMPLETE:Y';
        END IF;

      ELSE	/*** IF (l_action_code = 'NOTIFY_OWNER_OF_RELATED_SR') ***/
        result := 'COMPLETE:Y';
      END IF;

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'All_Recipients_Notified',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END All_Recipients_Notified;


  /***************************************************************************
  -- Verify_Notify_Rules_Done
  --
  --   This procedure corresponds to the VRFY_NEW_STATUS function
  --   activity.
  --
  --   This procedure checks if all the notification rules has been executed.
  --   We will have to build a new rules list if there was an overflow
  --   (as indicated by the MORE_NTFY_ACTION_LIST flag) because there are
  --   more rules in the query.
  **************************************************************************/

  PROCEDURE Verify_Notify_Rules_Done( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_event_name                VARCHAR2(240);
    l_event_condition_id        CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_char_event_condition_id   VARCHAR2(30);

    l_action_code               CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_notify_conditions_list    VARCHAR2(4000);
    l_notify_actions_list       VARCHAR2(4000);
    l_overflow_flag             VARCHAR2(1);


    CURSOR sel_action_csr IS
      SELECT csad.event_condition_id,
	     csad.action_code,
	     csad.notification_template_id
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csad.notification_template_id IS NOT NULL
          and csad.action_code like 'NOTIFY%'
	  AND TO_CHAR(csad.event_condition_id) || csad.action_code >
		TO_CHAR(l_event_condition_id) || l_action_code
      ORDER BY TO_CHAR(1) || 2;

      sel_action_rec	sel_action_csr%ROWTYPE;


  BEGIN

    IF (funmode = 'RUN') THEN

      l_notify_conditions_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_CONDITION_LIST' );

      l_notify_actions_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'NTFY_ACTION_LIST' );

      IF (l_notify_conditions_list IS NOT NULL AND l_notify_actions_list IS NOT NULL) THEN
        result := 'COMPLETE:N';
      ELSE

        l_overflow_flag := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'MORE_NTFY_ACTION_LIST');

	IF (l_overflow_flag = 'Y') THEN

          -- Reset the Overflow flag
	  WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'MORE_NTFY_ACTION_LIST',
                      avalue          => '' );

          l_event_condition_id := WF_ENGINE.GetItemAttrNumber(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'NTFY_EVENT_CONDITION_ID');
          l_action_code := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'NTFY_ACTION_CODE');
          l_event_name := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'EVENTNAME' );

	  OPEN sel_action_csr;
          LOOP
          FETCH sel_action_csr INTO sel_action_rec;
          EXIT WHEN sel_action_csr%NOTFOUND;
          l_char_event_condition_id := TO_CHAR(sel_action_rec.event_condition_id);

          IF (nvl(LENGTH(l_notify_conditions_list),0) +
              nvl(LENGTH(l_char_event_condition_id),0) + 1) <= 4000  OR
             (nvl(LENGTH(l_notify_actions_list),0) +
              nvl(LENGTH(sel_action_rec.action_code),0) + 1 ) <= 4000 THEN

            IF l_notify_conditions_list IS NULL THEN
              l_notify_conditions_list := l_char_event_condition_id;
              l_notify_actions_list := sel_action_rec.action_code;
            ELSE
              l_notify_conditions_list := l_notify_conditions_list || ' ' || l_char_event_condition_id;
              l_notify_actions_list := l_notify_actions_list || ' ' || sel_action_rec.action_code;
            END IF;
          ELSE

	    WF_ENGINE.SetItemAttrText(
                        itemtype        => itemtype,
                        itemkey         => itemkey,
                        aname           => 'MORE_NTFY_ACTION_LIST',
                        avalue          => 'Y' );
            EXIT;

          END IF;
        END LOOP;
        CLOSE sel_action_csr;

        IF (l_notify_conditions_list IS NOT NULL AND l_notify_actions_list IS NOT NULL) THEN

          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_CONDITION_LIST',
                  avalue          => l_notify_conditions_list );
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_ACTION_LIST',
                  avalue          => l_notify_actions_list );

          result := 'COMPLETE:N';
	ELSE
          result := 'COMPLETE:Y';
	END IF;


        ELSE	/** IF (l_overflow_flag = 'Y') **/

          result := 'COMPLETE:Y';

        END IF;


      /** IF (l_update_conditions_list IS NOT NULL AND l_update_actions_list IS NOT NULL) **/
      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Verify_Notify_Rules_Done',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Verify_Notify_Rules_Done;


  /*****************************************************************************
  -- Check_Status_Rules
  --
  --   This procedure corresponds to the CHECK_STATUS_RULES function
  --   activity.
  --
  --   The procedure checks if there are update rules defined by checking
  --   the conditions/actions list. If the list is not empty, then we pull the
  --   first item on the lists to process. Otherwise, we end the sub-process.
  --
  *****************************************************************************/

  PROCEDURE Check_Status_Rules( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_event_action	VARCHAR2(50);
    l_actions_list	VARCHAR2(4000);
    --l_link_id		CS_INCIDENT_LINKS.LINK_ID%TYPE;
    --l_subject_id	CS_INCIDENT_LINKS.SUBJECT_ID%TYPE;
    --l_link_type_code	CS_INCIDENT_LINKS.LINK_TYPE_CODE%TYPE;

    l_update_conditions_list    VARCHAR2(4000);
    l_update_actions_list       VARCHAR2(4000);
    l_event_condition_id	CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_action_code		CS_SR_ACTION_DETAILS.action_code%TYPE;

    l_space_pos		NUMBER;
    l_element		VARCHAR2(100);


  BEGIN

    IF (funmode = 'RUN') THEN

      l_update_conditions_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_CONDITION_LIST' );

      l_update_actions_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_ACTION_LIST' );

      IF (l_update_conditions_list IS NOT NULL AND l_update_actions_list IS NOT NULL) THEN

        pull_from_list(itemlist	=> l_update_conditions_list,
		       element	=> l_element);
	l_event_condition_id := TO_NUMBER(l_element);

        pull_from_list(itemlist	=> l_update_actions_list,
		       element	=> l_action_code);

        IF (l_event_condition_id IS NOT NULL AND l_action_code IS NOT NULL) THEN
          WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'UPDATE_CONDITION_LIST',
                avalue          => l_update_conditions_list );
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'UPDATE_ACTION_LIST',
                  avalue          => l_update_actions_list );
          WF_ENGINE.SetItemAttrNumber(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'UPDATE_EVENT_CONDITION_ID',
                  avalue          => l_event_condition_id );
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'UPDATE_ACTION_CODE',
                  avalue          => l_action_code );

          result := 'COMPLETE:Y';

        ELSE
          result := 'COMPLETE:N';

        END IF;

      ELSE
          result := 'COMPLETE:N';
      END IF;

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Check_Status_Rules',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Check_Status_Rules;


  /****************************************************************************
  -- Get_Links_For_Rule
  --
  --   This procedure corresponds to the GET_STATUS_PROPAGATION_RULES function
  --   activity.
  --
  --   This procedure builds a list of related service requests that satisfy
  --   the update rule being processed.
  ****************************************************************************/

  PROCEDURE Get_Links_For_Rule( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_event_name	VARCHAR2(240);
    l_event_action	VARCHAR2(50);
    l_actions_list	VARCHAR2(4000);
    --l_link_id		VARCHAR2(20);

    --l_subject_id	CS_INCIDENT_LINKS.SUBJECT_ID%TYPE;
    l_subject_id	VARCHAR2(30);
    --l_link_type_code	CS_INCIDENT_LINKS.LINK_TYPE_CODE%TYPE;
    l_event_condition_id	CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_action_code	CS_SR_ACTION_DETAILS.action_code%TYPE;

    l_new_request_status	VARCHAR2(30);
    l_old_request_status        VARCHAR2(30);
    l_request_status	        VARCHAR2(30);
    l_request_status_temp	VARCHAR2(30);
    l_request_number		VARCHAR2(64);
    l_relationship_type_id	CS_SR_ACTION_DETAILS.relationship_type_id%TYPE;
    l_relationship_type_name	VARCHAR2(240);
    l_linked_subject_list	VARCHAR2(4000);

    l_request_id		NUMBER;

/* 03/01/2004 - RHUNGUND - Bug fix for 3412852
   Changed the order of the FROM clause since the optimization rules indicate that
   a cartesian join occurs if :
   1) If a join condition is missing for  the FROM clause tables
   2) If the FROM clause is not listing the tables in the proper order

*/
    CURSOR sel_event_action_csr IS
      SELECT csat.relationship_type_id trigger_link_type,
             csat.from_to_status_code,
             csat.incident_status_id trigger_incident_status_id,
             csad.relationship_type_id detail_link_type,
	     csad.incident_status_id detail_incident_status_id,
	     csad.resolution_code
      FROM CS_SR_EVENT_CODES_B cec,
           CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad
      WHERE
  	  cec.WF_BUSINESS_EVENT_ID =  l_event_name
          and cec.EVENT_CODE = csat.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csat.event_condition_id = csad.event_condition_id
          and csad.event_condition_id = l_event_condition_id
          and csad.action_code = l_action_code
          and csad.action_code NOT like 'NOTIFY%'
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE));




    sel_event_action_rec	sel_event_action_csr%ROWTYPE;

    CURSOR sel_link_csr IS
      SELECT cil.link_type_id,
     	cil.object_id,
        cil.link_id
      FROM cs_incident_links cil
      WHERE cil.subject_id = l_request_id
	AND cil.link_type_id = l_relationship_type_id
      ORDER BY cil.object_id;

    sel_link_rec	sel_link_csr%ROWTYPE;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_request_number := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_NUMBER' );

      l_request_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_ID' );

      l_event_name := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'EVENTNAME' );

      l_event_condition_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_EVENT_CONDITION_ID' );

      l_action_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_ACTION_CODE' );

      OPEN sel_event_action_csr;
      FETCH sel_event_action_csr INTO sel_event_action_rec;
      CLOSE sel_event_action_csr;

      IF (sel_event_action_rec.from_to_status_code IS NOT NULL) THEN

        IF (sel_event_action_rec.from_to_status_code = 'STATUS_CHANGED_TO') THEN
          l_request_status := WF_ENGINE.GetItemAttrText(
                                 itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'REQUEST_STATUS' );
        ELSIF (sel_event_action_rec.from_to_status_code = 'STATUS_CHANGED_FROM') THEN
          l_request_status := WF_ENGINE.GetItemAttrText(
                                 itemtype        => itemtype,
                                 itemkey         => itemkey,
                                 aname           => 'REQUEST_STATUS_OLD' );
        END IF;

	SELECT name
	INTO l_request_status_temp
	FROM CS_INCIDENT_STATUSES_VL
	WHERE INCIDENT_STATUS_ID = sel_event_action_rec.trigger_incident_status_id;

        IF (l_request_status = l_request_status_temp) THEN
          WF_ENGINE.SetItemAttrNumber(
  	  	itemtype	=> itemtype,
  	    	itemkey		=> itemkey,
  	  	aname		=> 'SUBJECT_STATUS_ID',
  	  	avalue		=> sel_event_action_rec.detail_incident_status_id );

        ELSE
          WF_ENGINE.SetItemAttrText(
  	  	itemtype	=> itemtype,
  	  	itemkey		=> itemkey,
  		aname		=> 'SUBJECT_STATUS_ID',
  		avalue		=> NULL);
        END IF;

        l_relationship_type_id := sel_event_action_rec.detail_link_type;


      ELSIF (sel_event_action_rec.trigger_link_type IS NOT NULL) THEN
        WF_ENGINE.SetItemAttrNumber(
  		itemtype	=> itemtype,
  	    	itemkey		=> itemkey,
  	  	aname		=> 'SUBJECT_STATUS_ID',
  	  	avalue		=> sel_event_action_rec.detail_incident_status_id );

        WF_ENGINE.SetItemAttrText(
  	  	itemtype	=> itemtype,
  	    	itemkey		=> itemkey,
  	  	aname		=> 'SUBJECT_RESOLUTION_CODE',
  	  	avalue		=> sel_event_action_rec.resolution_code );

        l_relationship_type_id := sel_event_action_rec.trigger_link_type;

      END IF;

      -- Obtain link type name from relationship_type_id
      SELECT name
      INTO l_relationship_type_name
      FROM CS_SR_LINK_TYPES_VL
      WHERE link_type_id = l_relationship_type_id;

      WF_ENGINE.SetItemAttrText(
		itemtype	=> itemtype,
		itemkey		=> itemkey,
		aname		=> 'UPDATE_RELATIONSHIP_TYPE',
		avalue		=> l_relationship_type_name);

      -- Select All Links with the link_type_code and create a subject_id list in workflow.
      -- It is guaranteed that every Rule in the list has existing Link SR, this was taken care of
      -- when building the initial Rule list in Check_Rules_For_Event().
      OPEN sel_link_csr;
      LOOP
        FETCH sel_link_csr INTO sel_link_rec;
        EXIT WHEN sel_link_csr%NOTFOUND;
	l_subject_id := TO_CHAR(sel_link_rec.object_id);

        IF ((nvl(LENGTH(l_linked_subject_list),0) + nvl(LENGTH(l_subject_id),0) + 1) <= 4000) THEN

          IF l_linked_subject_list IS NULL THEN
            l_linked_subject_list := l_subject_id;
          ELSE
            l_linked_subject_list := l_linked_subject_list || ' ' || l_subject_id;
          END IF;
	ELSE

	  WF_ENGINE.SetItemAttrText(
                        itemtype        => itemtype,
                        itemkey         => itemkey,
                        aname           => 'MORE_UPDT_LINKED_SUBJECT_LIST',
                        avalue          => 'Y' );
	  EXIT;

	END IF;

      END LOOP;
      CLOSE sel_link_csr;

      IF (l_linked_subject_list IS NOT NULL) THEN
        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'UPDATE_LINKED_SUBJECT_LIST',
                avalue          => l_linked_subject_list );

        result := 'COMPLETE:Y';

      ELSE
        result := 'COMPLETE:N';
      END IF;

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Get_Links_For_Rule',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Get_Links_For_Rule;



  /****************************************************************************
  -- Execute_Rules_Per_SR
  --
  --   This procedure corresponds to the GET_STATUS_PROPAGATION_RULES function
  --   activity.
  --
  --   This procedure iterates through the list of related service requests and
  --   sets the first item on the list to be processed.
  ****************************************************************************/

  PROCEDURE Execute_Rules_Per_SR( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    --l_subject_id	CS_INCIDENT_LINKS.SUBJECT_ID%TYPE;
    --l_subject_id	VARCHAR2(30);

    l_linked_subject_list	VARCHAR2(4000);
    l_element		VARCHAR2(100);

  BEGIN

    IF (funmode = 'RUN') THEN

      l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_LINKED_SUBJECT_LIST' );

      pull_from_list(itemlist	=> l_linked_subject_list,
			element	=> l_element);

      WF_ENGINE.SetItemAttrNumber(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'UPDATE_SUBJECT_ID',
              avalue          => TO_NUMBER(l_element) );

      WF_ENGINE.SetItemAttrText(
              itemtype        => itemtype,
              itemkey         => itemkey,
              aname           => 'UPDATE_LINKED_SUBJECT_LIST',
              avalue          => l_linked_subject_list );

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Execute_Rules_Per_SR',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Execute_Rules_Per_SR;


  /****************************************************************************
  -- Verify_Update_Valid
  --
  --   This procedure corresponds to the VRFY_NEW_STATUS function
  --   activity.
  --
  --   This procedure checks if the update being done is valid. The rules are:
  --     1.) If the SR which needs to be updated has a status with
  --         'closed flag' ON, DO NOT update the status of the service request.
  --     2.) During automatic update, workflow process should not close a
  --         service request if it has outgoing links of type
  --         duplicate of/caused by to open service requests.
  --
  --  Modification History:
  --
  --  Date        Name       Desc
  --  ----------  ---------  ---------------------------------------------
  --  05/11/04	  RMANABAT   Fix for bug 3582873. Validate if the incoming status
  --			     is either 'Clear' or 'Close' as per SRD.
  --  06/15/04	  RMANABAT   Fix for bug 3690121. Changed cursor sel_related_sr_cur
  --			     to look at inc.status_flag instead of the status
  --			     close_flag. Also validated just 'Caused By' link
  --			     to allow close of SR when 'Duplicate Of' link is
  --			     created.
  ****************************************************************************/

  PROCEDURE Verify_Update_Valid( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_subject_id	CS_INCIDENT_LINKS.SUBJECT_ID%TYPE;
    --l_link_type_code	CS_INCIDENT_LINKS.LINK_TYPE_CODE%TYPE;
    l_subject_status_id	CS_SR_ACTION_DETAILS.incident_status_id%TYPE;
    l_resolution_code	CS_SR_ACTION_DETAILS.resolution_code%TYPE;
    l_close_flag	VARCHAR2(1);
    l_link_id		CS_INCIDENT_LINKS.LINK_ID%TYPE;

    l_action_code       CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_sr_updated        NUMBER;
    l_incident_status_id        NUMBER;
    l_UNHANDLED_ACTION          EXCEPTION;

    --l_err_txt		VARCHAR2(30);

    CURSOR sel_related_sr_cur(lv_incident_id IN NUMBER) IS
      SELECT cil.link_id
      FROM cs_incident_links cil,
	   cs_incidents_all_b inc
      WHERE cil.subject_id = lv_incident_id
        -- Hard coded values for 'CAUSED BY' (2) and 'DUPLICATE OF' (3).
	AND cil.link_type_id = 2
	AND cil.object_id = inc.incident_id
	AND inc.status_flag = 'O' ;

    CURSOR sel_close_flag_csr(lv_incident_id IN NUMBER) IS
      SELECT nvl(status.close_flag,'N'),
	     inc.incident_status_id
      FROM   cs_incident_statuses status, cs_incidents_all_b inc
      WHERE  inc.incident_id = lv_incident_id
        AND inc.incident_status_id = status.incident_status_id;

  BEGIN

    IF (funmode = 'RUN') THEN

      -- SUBJECT_STATUS_ID can be null when updating resolution code . Update Rule #3.
      l_subject_status_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'SUBJECT_STATUS_ID' );

      --l_err_txt := 'Valid1';

      l_resolution_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'SUBJECT_RESOLUTION_CODE' );

      IF (l_subject_status_id IS NULL AND l_resolution_code IS NULL) THEN
        result := 'COMPLETE:N';

      ELSE

        l_subject_id := WF_ENGINE.GetItemAttrNumber(
                                    itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'UPDATE_SUBJECT_ID' );

	l_action_code := WF_ENGINE.GetItemAttrText(
                                    itemtype        => itemtype,
                                    itemkey         => itemkey,
                                    aname           => 'UPDATE_ACTION_CODE' );

        IF (l_action_code = 'CHANGE_SR_STATUS' OR l_action_code = 'CHANGE_SR_RESOLUTION') THEN
          l_sr_updated := WF_ENGINE.GetItemAttrNumber(
                                      itemtype        => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'REQUEST_ID' );
        ELSIF (l_action_code = 'CHANGE_RELATED_SR_STATUS') THEN
          l_sr_updated := l_subject_id;
        ELSE
          raise l_UNHANDLED_ACTION;
        END IF;

        --l_err_txt := 'Valid2';

        OPEN sel_close_flag_csr(l_sr_updated);
        FETCH sel_close_flag_csr
	INTO   l_close_flag, l_incident_status_id;
        CLOSE sel_close_flag_csr;

        /**********************************************
	  If the SR which needs to be updated has a status
          with 'closed flag' ON, DO NOT update the status
          of the service request.
        **********************************************/
        IF (l_close_flag = 'Y' OR l_incident_status_id = l_subject_status_id) THEN
          result := 'COMPLETE:N';
        ELSE

          /********************************************
	    During automatic update, workflow process should
            not close a service request if it has outgoing
            links of type duplicate of/caused by to open
            service requests.
          ********************************************/

	  IF (l_subject_status_id IS NULL) THEN  -- Updating resolution code only, not status.

	    result := 'COMPLETE:Y';

	  ELSE	-- Updating Status


	    IF (l_subject_status_id = 101) THEN
              l_close_flag := 'Y';
            ELSE
              SELECT nvl(status.close_flag,'N')
              INTO   l_close_flag
              FROM   cs_incident_statuses status
              WHERE  status.incident_status_id = l_subject_status_id;
            END IF;

            IF (l_close_flag = 'Y') THEN
              OPEN sel_related_sr_cur(l_sr_updated);
              FETCH sel_related_sr_cur INTO l_link_id;
              IF (sel_related_sr_cur%FOUND) THEN
                result := 'COMPLETE:N';
              ELSE
                result := 'COMPLETE:Y';
              END IF;
              CLOSE sel_related_sr_cur;
            ELSE
              result := 'COMPLETE:Y';
            END IF;

          END IF;	-- IF (l_subject_status_id IS NULL)

        END IF;

      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_UNHANDLED_ACTION THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Verify_Update_Valid',
                      itemtype, itemkey, actid, funmode);
      RAISE;
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Verify_Update_Valid',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Verify_Update_Valid;


  /*************************************************************************
  -- Update_SR
  --
  --   This procedure corresponds to the VRFY_NEW_STATUS function
  --   activity.
  --
  --   This procedure makes the call to Update_Sericerequest() api to update
  --   the status or resolution code of the SR, as defined in the update
  --   rule.
  --   Depending on the result of the update api call, we set the transition :
  --     1.  FND_API.G_RET_STS_SUCCESS - we set the renult to 'UPDATED'.
  --         We then move on and process the next related service request.
  --     2.  'L'- we set the result to 'LOCKED'. If the record is locked, We
  --         then wait for 10 secs and re-try updating the record. We attempt
  --         the update 5 times, each time waiting 10 secs. if the record is
  --         still locked. If after 5 tries we still can't update, then we set
  --         the result to 'FAILED' (item 3).
  --     3.  Otherwise (update failed) - we set the result to 'FAILED'. We
  --         then try to send a notification to the owner of the SR we are
  --         updating with the error message stack.
  --   Modification History:
  --
  --  Date        Name        Desc
  --  --------    ----------  --------------------------------------
  --  05/25/2004  RMANABAT    Fix for bug 3612904. Passed resp_id and
  --                          rep_appL_id to update_servicerequest() api
  --                          for security validation.
  *************************************************************************/

  PROCEDURE Update_SR( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_request_number    	VARCHAR2(64);
    l_request_id		NUMBER;
    l_subject_id		CS_INCIDENT_LINKS.SUBJECT_ID%TYPE;
    l_subject_status_id		CS_SR_ACTION_DETAILS.incident_status_id%TYPE;
    l_resolution_code		CS_SR_ACTION_DETAILS.resolution_code%TYPE;
    l_service_request_rec	CS_ServiceRequest_PVT.service_request_rec_type;
    l_object_version_number	NUMBER;
    l_action_code       CS_SR_ACTION_DETAILS.action_code%TYPE;

    --l_request_id		NUMBER;
    l_subject_owner_id		NUMBER;
    l_close_flag        	VARCHAR2(1);
    l_return_status     	VARCHAR2(1);
    l_msg_count         	NUMBER;
    l_msg_data          	VARCHAR2(2000);
    l_user_id           	NUMBER;
    l_notes     		CS_SERVICEREQUEST_PVT.notes_table;
    l_contacts  		CS_SERVICEREQUEST_PVT.contacts_table;
    out_interaction_id		number;
    out_wf_process_id		number;

    l_UNHANDLED_ACTION		EXCEPTION;

    l_error_text		VARCHAR2(2000);
    NL				VARCHAR2(1);
    l_msg_index_OUT		NUMBER;
    l_wf_process_id		NUMBER;

    l_resp_appl_id		NUMBER;
    l_resp_id			NUMBER;

    CURSOR sel_incident_from_number_csr IS
      SELECT object_version_number, incident_owner_id, incident_id
      FROM cs_incidents_all_b
      WHERE incident_number = l_request_number;


    CURSOR sel_incident_from_id_csr IS
      SELECT object_version_number, incident_owner_id
      FROM cs_incidents_all_b
      WHERE incident_id = l_subject_id;


  BEGIN

    NL := fnd_global.Local_Chr(10);

    IF (funmode = 'RUN') THEN


      CS_ServiceRequest_PVT.initialize_rec(l_service_request_rec);

      l_action_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_ACTION_CODE' );

      l_request_number := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_NUMBER' );

      l_user_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'USER_ID' );

      l_subject_status_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'SUBJECT_STATUS_ID' );

      l_resolution_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'SUBJECT_RESOLUTION_CODE' );

      l_subject_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_SUBJECT_ID' );

      IF (l_action_code = 'CHANGE_SR_STATUS' OR l_action_code = 'CHANGE_SR_RESOLUTION') THEN

        OPEN sel_incident_from_number_csr;
        FETCH sel_incident_from_number_csr
        INTO l_object_version_number, l_subject_owner_id, l_request_id;
        CLOSE sel_incident_from_number_csr;

      ELSIF (l_action_code = 'CHANGE_RELATED_SR_STATUS') THEN

        OPEN sel_incident_from_id_csr;
        FETCH sel_incident_from_id_csr
        INTO l_object_version_number, l_subject_owner_id;
        CLOSE sel_incident_from_id_csr;

        l_request_id := l_subject_id;

      ELSE
	RAISE l_UNHANDLED_ACTION;
      END IF;

      IF (l_subject_status_id IS NOT NULL) THEN
        l_service_request_rec.status_id := l_subject_status_id;

        SELECT nvl(status.close_flag,'N')
        INTO   l_close_flag
        FROM   cs_incident_statuses status
        WHERE  status.incident_status_id = l_subject_status_id;

        IF (l_close_flag = 'Y') THEN
          l_service_request_rec.closed_date := sysdate;
        END IF;

      END IF;

      IF (l_resolution_code IS NOT NULL) THEN
        l_service_request_rec.resolution_code := l_resolution_code;
      END IF;

      l_service_request_rec.last_update_program_code := 'SUPPORT.WF';

      --l_wf_process_id := TO_NUMBER(substr(itemkey, instr(itemkey,'-')+1));

      l_resp_appl_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'RESP_APPL_ID' );
      l_resp_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'RESP_ID' );

      CS_ServiceRequest_PVT.Update_ServiceRequest
       ( p_api_version		=> 3.0,
         p_init_msg_list	=> fnd_api.g_false,
         p_commit		=> fnd_api.g_true,
         p_validation_level	=> fnd_api.g_valid_level_full,
         x_return_status	=> l_return_status,
         x_msg_count		=> l_msg_count,
         x_msg_data		=> l_msg_data,
         p_request_id		=> l_request_id,
         --p_request_id		=> l_subject_id,
         p_last_updated_by	=> l_user_id,
         p_last_update_date	=> sysdate,
         p_service_request_rec	=> l_service_request_rec,
         p_notes		=> l_notes,
         p_contacts		=> l_contacts,
         p_object_version_number=> l_object_version_number,
	 p_resp_appl_id		=> l_resp_appl_id,
	 p_resp_id		=> l_resp_id,
	 --p_workflow_process_id  => l_wf_process_id,
         x_interaction_id	=> out_interaction_id,
         x_workflow_process_id	=> out_wf_process_id
        );

      -- Check for possible errors returned by the API
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        result := 'COMPLETE:UPDATED';
      -- We need to have a separate return status for locked row exception.
      ELSIF (l_return_status = 'L') THEN
      --ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        result := 'COMPLETE:LOCKED';
      ELSE
        -- Obtain the owner role of the related SR being updated, and set-up the
	-- the notification to be sent to the owner of the SR.
        result := 'COMPLETE:FAILED';
      END IF;


      -- IF (l_msg_data is not null) THEN
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN


        IF ( FND_MSG_PUB.Count_Msg > 0) THEN
          FOR i IN 1..FND_MSG_PUB.Count_Msg    LOOP
            FND_MSG_PUB.Get(p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => l_msg_data,
                            p_msg_index_OUT => l_msg_index_OUT );
	    l_error_text := l_error_text || l_msg_data ||NL;
          END LOOP;
        END IF;


        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'UPDATE_ERROR_DATA',
                avalue          => l_error_text );
      END IF;



        /*****************************************
        FND_MSG_PUB.Count_And_Get( p_count      => l_msg_count,
                                   p_data       => l_msg_data,
                                   p_encoded    => FND_API.G_FALSE );
        wf_core.context( pkg_name       =>  'CS_ServiceRequest_PUB',
                         proc_name      =>  'Update_Status',
                         arg1           =>  'p_user_id=>'||l_user_id,
                         arg2           =>  'p_org_id=>'||l_org_id,
                         arg3           =>  'p_request_number=>'||l_request_number,
                         arg4           =>  'p_status_id=>'||l_new_status_id,
                         arg5           =>  'p_msg_data=>'||l_msg_data );
        l_errmsg_name := 'CS_SR_CANT_UPDATE_STATUS';
        raise l_API_ERROR;
        ******************************************/

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_UNHANDLED_ACTION THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Update_SR',
		      itemtype, itemkey, actid, funmode);
      RAISE;

    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Update_SR',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Update_SR;


/********************************************************************
  -- Set_Notify_Error
  --   This procedure corresponds to the SET_NTFY_ERROR_DETAILS function
  --   activity.
  --   This procedure sets the notification details for sending the
  --   error message when the update activity failed.
********************************************************************/

  PROCEDURE Set_Notify_Error( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_request_number    	VARCHAR2(64);
    l_request_id		NUMBER;
    l_subject_id		CS_INCIDENT_LINKS.SUBJECT_ID%TYPE;
    l_subject_status_id		CS_SR_ACTION_DETAILS.incident_status_id%TYPE;
    l_action_code       CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_subject_owner_id		NUMBER;

    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_owner_role        VARCHAR2(100);
    l_owner_name        VARCHAR2(240);

    CURSOR l_cs_sr_get_empid_csr IS
      SELECT inc.incident_number, emp.source_id
      FROM jtf_rs_resource_extns emp ,
           cs_incidents_all_b inc
      WHERE emp.resource_id = inc.incident_owner_id
        AND inc.incident_id = l_subject_id;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_action_code := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_ACTION_CODE' );

      l_request_number := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'REQUEST_NUMBER' );

      l_subject_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_SUBJECT_ID' );

      IF (l_action_code = 'CHANGE_SR_STATUS' OR l_action_code = 'CHANGE_SR_RESOLUTION') THEN

        l_owner_role := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'OWNER_ROLE' );

      ELSIF (l_action_code = 'CHANGE_RELATED_SR_STATUS') THEN

	/*************
        SELECT incident_number, incident_owner_id
        INTO l_request_number, l_subject_owner_id
        FROM cs_incidents_all_b
        WHERE incident_id = l_subject_id;

        IF (l_subject_owner_id IS NULL)THEN
	  l_owner_role := NULL;
	ELSE
	*************/

        OPEN l_cs_sr_get_empid_csr;
	FETCH l_cs_sr_get_empid_csr
	INTO l_request_number, l_subject_owner_id;

	IF( l_cs_sr_get_empid_csr%NOTFOUND OR l_subject_owner_id IS NULL) THEN
	  l_owner_role := NULL;
        ELSE

	  -- Retrieve the role name for the request owner
          CS_WORKFLOW_PUB.Get_Employee_Role (
                    p_api_version           =>  1.0,
                    p_return_status         =>  l_return_status,
                    p_msg_count             =>  l_msg_count,
                    p_msg_data              =>  l_msg_data,
                    --p_employee_id           =>  l_subject_id,
                    p_employee_id           =>  l_subject_owner_id,
                    p_role_name             =>  l_owner_role,
                    p_role_display_name     =>  l_owner_name );
	END IF;
	CLOSE l_cs_sr_get_empid_csr;

      END IF;

      If (l_owner_role IS NOT NULL) THEN

        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'UPDATE_REQUEST_ROLE',
                avalue          => l_owner_role );

        WF_ENGINE.SetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'UPDATE_REQUEST_NUMBER',
                avalue          => l_request_number );

        result := 'COMPLETE:SET';

      ELSE
        result := 'COMPLETE:UNSET';
      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Set_Notify_Error',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Set_Notify_Error;


/***********************************************************************
  -- Verify_All_Links_Done
  --   This procedure corresponds to the VRFY_NEW_STATUS function
  --   activity.
  --   The procedure verifies if the Linked Service Request list has
  --   been exhausted. If not then the procedure returns an 'N' which
  --   tells the workflow to process the next rule on the list.
  --   If the list has been exhausted, we check if the list overload flag
  --   is set to 'Y' (which means the initial list did not fit all the
  --   queried rows), if it is not then we return a 'Y' telling the
  --   workflow that all Linked Service Requests has been processed.
  --   If the overflow flag is 'Y', then we build another list
  --   starting from the next linked incident_id (object_id) item of
  --   the last item on the previous list.
**********************************************************************/

  PROCEDURE Verify_All_Links_Done( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_linked_subject_list       VARCHAR2(4000);
    --l_link_type_code    	CS_INCIDENT_LINKS.LINK_TYPE_CODE%TYPE;
    --l_event_condition_id        CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    --l_action_code       	CS_SR_ACTION_DETAILS.action_code%TYPE;
    l_relationship_type_id      CS_SR_ACTION_DETAILS.relationship_type_id%TYPE;
    l_relationship_type_name    VARCHAR2(240);
    l_subject_id		NUMBER;
    l_char_subject_id		VARCHAR2(30);
    l_request_number            VARCHAR2(64);
    l_request_id		NUMBER;

    l_overflow_flag             VARCHAR2(1);

    CURSOR sel_link_csr IS
      SELECT cil.link_type_id,
        cil.object_id,
        cil.link_id
      FROM cs_incident_links cil,
           CS_SR_LINK_TYPES_VL cilt
      WHERE cil.subject_id = l_request_id
        AND cil.link_type_id = cilt.link_type_id
        AND cilt.name = l_relationship_type_name
	AND cil.object_id > l_subject_id
      ORDER BY cil.object_id;

    sel_link_rec        sel_link_csr%ROWTYPE;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_linked_subject_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_LINKED_SUBJECT_LIST' );

      IF (l_linked_subject_list IS NOT NULL) THEN
        result := 'COMPLETE:N';
      ELSE

        l_overflow_flag := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'MORE_UPDT_LINKED_SUBJECT_LIST');

        IF (l_overflow_flag = 'Y') THEN

	  -- Reset the Overflow flag
          WF_ENGINE.SetItemAttrText(
                        itemtype        => itemtype,
                        itemkey         => itemkey,
                        aname           => 'MORE_UPDT_LINKED_SUBJECT_LIST',
                        avalue          => '' );

          l_request_number := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'REQUEST_NUMBER' );
          l_request_id := WF_ENGINE.GetItemAttrNumber(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'REQUEST_ID' );
          l_relationship_type_name := WF_ENGINE.GetItemAttrText(
	  			  itemtype	=> itemtype,
				  itemkey	=> itemkey,
				  aname		=> 'UPDATE_RELATIONSHIP_TYPE');
          l_subject_id := WF_ENGINE.GetItemAttrNumber(
              			  itemtype        => itemtype,
              			  itemkey         => itemkey,
              			  aname           => 'UPDATE_SUBJECT_ID');

	  OPEN sel_link_csr;
	  LOOP
	    FETCH sel_link_csr INTO sel_link_rec;
	    EXIT WHEN sel_link_csr%NOTFOUND;
	    l_char_subject_id := TO_CHAR(sel_link_rec.object_id);

	    IF ((nvl(LENGTH(l_linked_subject_list),0) +
		 nvl(LENGTH(l_char_subject_id),0) + 1) <= 4000) THEN

              IF l_linked_subject_list IS NULL THEN
                l_linked_subject_list := l_char_subject_id;
              ELSE
                l_linked_subject_list := l_linked_subject_list || ' ' || l_char_subject_id;
              END IF;
	    ELSE
              WF_ENGINE.SetItemAttrText(
                            itemtype        => itemtype,
                            itemkey         => itemkey,
                            aname           => 'MORE_UPDT_LINKED_SUBJECT_LIST',
                            avalue          => 'Y' );
	      EXIT;

            END IF;

          END LOOP;
          CLOSE sel_link_csr;

	  IF (l_linked_subject_list IS NOT NULL) THEN
            WF_ENGINE.SetItemAttrText(
                    itemtype        => itemtype,
                    itemkey         => itemkey,
                    aname           => 'UPDATE_LINKED_SUBJECT_LIST',
                    avalue          => l_linked_subject_list );

            result := 'COMPLETE:N';
	  ELSE
            result := 'COMPLETE:Y';
	  END IF;
        ELSE  /*** IF (l_overflow_flag = 'Y') ***/
              result := 'COMPLETE:Y';
        END IF;


      END IF;	/** IF (l_linked_subject_list IS NOT NULL) **/

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Verify_All_Links_Done',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Verify_All_Links_Done;


/*************************************************************************
  -- Verify_Update_Rules_Done
  --   This procedure corresponds to the VRFY_NEW_STATUS function
  --   activity.
  --   The procedure verifies if the Update Rules (conditions + actions is
  --   unique) list has been exhausted. If not then the procedure returns
  --   an 'N' which tells the workflow to process the next rule on the list.
  --   If the list has been exhausted, we check if the list overload flag
  --   is set to 'Y' (which means the initial list did not fit all the
  --   queried rows), if it is not then we return a 'Y' telling the
  --   workflow that all update rules has been processed. If the overflow
  --   flag is 'Y', then we build another list starting from the next
  --   condition+action item of the last item on the previous list.
************************************************************************/

  PROCEDURE Verify_Update_Rules_Done( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS

    l_update_conditions_list    VARCHAR2(4000);
    l_update_actions_list       VARCHAR2(4000);
    l_event_name        	VARCHAR2(240);
    --l_action_code       	VARCHAR2(30);
    l_request_number    	VARCHAR2(64);
    l_event_condition_id        CS_SR_ACTION_TRIGGERS.event_condition_id%TYPE;
    l_char_event_condition_id   VARCHAR2(30);
    l_action_code       	CS_SR_ACTION_DETAILS.action_code%TYPE;

    l_overflow_flag             VARCHAR2(1);
    l_request_id		NUMBER;

    CURSOR sel_action_csr IS
      SELECT csad.event_condition_id,
             csad.action_code,
	     to_char(csad.event_condition_id) || csad.action_code index_cols
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csat.from_to_status_code IS NULL
          and csad.action_code NOT like 'NOTIFY%'
          and (csad.incident_status_id IS NOT NULL OR
               csad.resolution_code IS NOT NULL)
          and csat.relationship_type_id IN
		( select cil.link_type_id
	          FROM cs_incident_links cil
	          WHERE cil.subject_id = l_request_id)
	  AND TO_CHAR(csad.event_condition_id) || csad.action_code >
		TO_CHAR(l_event_condition_id) || l_action_code
      UNION
      SELECT csad.event_condition_id,
             csad.action_code,
	     to_char(csad.event_condition_id) || csad.action_code index_cols
      FROM CS_SR_ACTION_TRIGGERS csat,
           CS_SR_ACTION_DETAILS csad,
	   CS_SR_EVENT_CODES_B cec
      WHERE
	  cec.WF_BUSINESS_EVENT_ID = l_event_name
          and csat.EVENT_CODE = cec.EVENT_CODE
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csat.start_date_active, SYSDATE))
              and TRUNC(NVL(csat.end_date_active, SYSDATE))
          and csad.event_condition_id = csat.event_condition_id
          and TRUNC(SYSDATE) BETWEEN TRUNC(NVL(csad.start_date_active, SYSDATE))
              and TRUNC(NVL(csad.end_date_active, SYSDATE))
          and csat.from_to_status_code IS NOT NULL
          and csat.relationship_type_id IS NULL
          and csat.incident_status_id IS NOT NULL
          and csad.action_code NOT like 'NOTIFY%'
          and csad.relationship_type_id IN
		( select cil.link_type_id
	          FROM cs_incident_links cil
	          WHERE cil.subject_id = l_request_id)
	  AND TO_CHAR(csad.event_condition_id) || csad.action_code >
		TO_CHAR(l_event_condition_id) || l_action_code
      ORDER BY index_cols;

    sel_action_rec    sel_action_csr%ROWTYPE;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_update_conditions_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_CONDITION_LIST' );

      l_update_actions_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'UPDATE_ACTION_LIST' );

      IF (l_update_conditions_list IS NOT NULL AND l_update_actions_list IS NOT NULL) THEN
        result := 'COMPLETE:N';
      ELSE

        l_overflow_flag := WF_ENGINE.GetItemAttrText(
                                itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'MORE_UPDATE_ACTION_LIST');

	IF (l_overflow_flag = 'Y') THEN

          -- Reset the Overflow flag
          WF_ENGINE.SetItemAttrText(
                      itemtype        => itemtype,
                      itemkey         => itemkey,
                      aname           => 'MORE_UPDATE_ACTION_LIST',
                      avalue          => '' );

	  l_event_condition_id := WF_ENGINE.GetItemAttrNumber(
                    			itemtype        => itemtype,
                    			itemkey         => itemkey,
                    			aname           => 'UPDATE_EVENT_CONDITION_ID');
	  l_action_code := WF_ENGINE.GetItemAttrText(
                    			itemtype        => itemtype,
                    			itemkey         => itemkey,
                    			aname           => 'UPDATE_ACTION_CODE');
          l_event_name := WF_ENGINE.GetItemAttrText(
                                      	itemtype        => itemtype,
                                      	itemkey         => itemkey,
                                      	aname           => 'EVENTNAME' );
          l_request_number := WF_ENGINE.GetItemAttrText(
                                  	itemtype        => itemtype,
                                  	itemkey         => itemkey,
                                  	aname           => 'REQUEST_NUMBER' );
          l_request_id := WF_ENGINE.GetItemAttrNumber(
                                  	itemtype        => itemtype,
                                  	itemkey         => itemkey,
                                  	aname           => 'REQUEST_ID' );

	  OPEN sel_action_csr;
  	  LOOP
	    FETCH sel_action_csr INTO sel_action_rec;
	    EXIT WHEN sel_action_csr%NOTFOUND;
	    l_char_event_condition_id := TO_CHAR(sel_action_rec.event_condition_id);

	    IF (nvl(LENGTH(l_update_conditions_list),0) +
                nvl(LENGTH(l_char_event_condition_id),0) + 1) <= 4000  OR
               (nvl(LENGTH(l_update_actions_list),0) +
                nvl(LENGTH(sel_action_rec.action_code),0) + 1 ) <= 4000 THEN

              IF l_update_conditions_list IS NULL THEN
                l_update_conditions_list := l_char_event_condition_id;
                l_update_actions_list := sel_action_rec.action_code;
              ELSE
                l_update_conditions_list := l_update_conditions_list || ' ' || l_char_event_condition_id;
                l_update_actions_list := l_update_actions_list || ' ' || sel_action_rec.action_code;
              END IF;
	    ELSE

              WF_ENGINE.SetItemAttrText(
                          itemtype        => itemtype,
                          itemkey         => itemkey,
                          aname           => 'MORE_UPDATE_ACTION_LIST',
                          avalue          => 'Y' );
	      EXIT;

            END IF;
	  END LOOP;
	  CLOSE sel_action_csr;

	  IF (l_update_conditions_list IS NOT NULL AND l_update_actions_list IS NOT NULL) THEN

            WF_ENGINE.SetItemAttrText(
                    itemtype        => itemtype,
                    itemkey         => itemkey,
                    aname           => 'UPDATE_CONDITION_LIST',
                    avalue          => l_update_conditions_list );
            WF_ENGINE.SetItemAttrText(
                    itemtype        => itemtype,
                    itemkey         => itemkey,
                    aname           => 'UPDATE_ACTION_LIST',
                    avalue          => l_update_actions_list );

            result := 'COMPLETE:N';
	  ELSE
            result := 'COMPLETE:Y';
	  END IF;

        ELSE    /** IF (l_overflow_flag = 'Y') **/

          result := 'COMPLETE:Y';

        END IF;

      END IF;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Verify_Update_Rules_Done',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Verify_Update_Rules_Done;


/***********************************************************************
-- Get_Request_Attributes
--   This procedure initializes the item attributes that will remain constant
--   over the duration of the Workflow.  These attributes include REQUEST_ID,
--   REQUEST_NUMBER, REQUEST_DATE, and REQUEST_TYPE.
--   Modification History:
--
--  Date        Name        Desc
--  --------    ----------  --------------------------------------
--  06/23/2004  RMANABAT    Fix for bug 3715297. set SENDER_ROLE
--                          attribute when event is NOT raised from BES wrapper
--			    api, like in Solutions Linked event owned by KM.
--  06/08/2006  klou        Fix bug 5245018.  Added call to pass the attribute value
--                          for problem code
***********************************************************************/

  PROCEDURE Get_Request_Attributes( itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funmode         VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS

    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_owner_role        VARCHAR2(100);
    l_owner_name        VARCHAR2(240);
    l_errmsg_name       VARCHAR2(30);
    l_old_incident_owner_id	NUMBER;
    l_new_contact_point_id	NUMBER;
    l_new_contact_point_name	VARCHAR2(360);
    l_API_ERROR         EXCEPTION;

    l_request_number            VARCHAR2(64);

    l_resource_id       NUMBER;
    l_role_display_name VARCHAR2(360);
    l_role_name         VARCHAR2(320);

    /******************
    CURSOR l_ServiceRequest_csr IS
        SELECT *
        FROM CS_INCIDENTS_WORKFLOW_V
        WHERE INCIDENT_NUMBER = l_request_number;
    ***************/

    /**
      Going directly to TL tables to solve performance issue of
      non-mergeable views and excessive shared memory usage.
      rmanabat 03/18/03. Bug 2857365 .
    **/

/* 03/01/2004 - RHUNGUND - Bug fix for 3432700

   Performance fine-tuning.
   Removed outer joins from the following where conditions
   1)  AND INC.INCIDENT_TYPE_ID = TYPE.INCIDENT_TYPE_ID(+)
   2)  AND TYPE.LANGUAGE(+) = userenv('LANG')
   3)  AND INC.INCIDENT_URGENCY_ID = URGENCY.INCIDENT_URGENCY_ID(+)
   4) AND INC.INCIDENT_SEVERITY_ID = SEVERITY.INCIDENT_SEVERITY_ID(+)
*/

/* 03/31/2004 - RHUNGUND - Bug fix for 3531540
   Re-introduce the following outer join :
AND INC.INCIDENT_URGENCY_ID = URGENCY.INCIDENT_URGENCY_ID(+)
   since URGENCY is not a mandatory sr attribute and if a sr does not have an URGENCY value, the following SQL will not bring up any records if outer join is not present
*/

    CURSOR l_ServiceRequest_csr IS
      SELECT  INC.INCIDENT_ID,
        INC.SUMMARY,
        INC.INCIDENT_OWNER_ID,
        INC.INVENTORY_ITEM_ID,
        INC.EXPECTED_RESOLUTION_DATE,
        INC.INCIDENT_DATE,
        INC.CUSTOMER_PRODUCT_ID,
        TYPE.NAME INCIDENT_TYPE,
        SEVERITY.NAME SEVERITY,
        STATUS.NAME STATUS_CODE,
        URGENCY.NAME URGENCY,
        RA2.PARTY_NAME CUSTOMER_NAME,
        CSLKUP.DESCRIPTION PROBLEM_CODE_DESCRIPTION,
        MTL.DESCRIPTION PRODUCT_DESCRIPTION,
        INC.PROBLEM_CODE --5245018
      FROM    CS_INCIDENTS_ALL_VL INC,
        --CS_INCIDENT_TYPES_VL TYPE,
	CS_INCIDENT_TYPES_TL TYPE,
        --CS_INCIDENT_SEVERITIES_VL SEVERITY,
	CS_INCIDENT_SEVERITIES_TL SEVERITY,
        CS_INCIDENT_STATUSES_VL STATUS,
        --CS_INCIDENT_URGENCIES_VL URGENCY,
        CS_INCIDENT_URGENCIES_TL URGENCY,
        HZ_PARTIES RA2,
        CS_LOOKUPS CSLKUP,
        --MTL_SYSTEM_ITEMS_VL MTL
        MTL_SYSTEM_ITEMS_TL MTL
      WHERE INC.INCIDENT_NUMBER = l_request_number
        AND INC.INCIDENT_TYPE_ID = TYPE.INCIDENT_TYPE_ID
	AND TYPE.LANGUAGE = userenv('LANG')
        AND INC.INCIDENT_STATUS_ID = STATUS.INCIDENT_STATUS_ID
        AND INC.INCIDENT_URGENCY_ID = URGENCY.INCIDENT_URGENCY_ID(+)
	AND URGENCY.LANGUAGE(+) = userenv('LANG')
        AND INC.CUSTOMER_ID = RA2.PARTY_ID(+)
        AND INC.INCIDENT_SEVERITY_ID = SEVERITY.INCIDENT_SEVERITY_ID
	AND SEVERITY.LANGUAGE(+) = userenv('LANG')
        AND INC.PROBLEM_CODE = CSLKUP.LOOKUP_CODE(+)
        AND CSLKUP.LOOKUP_TYPE(+) = 'REQUEST_PROBLEM_CODE'
        AND MTL.INVENTORY_ITEM_ID(+) = INC.INVENTORY_ITEM_ID
	AND MTL.LANGUAGE(+) = userenv('LANG')
        AND (MTL.ORGANIZATION_ID = CS_STD.Get_Item_Valdn_Orgzn_ID OR MTL.ORGANIZATION_ID IS NULL);
        --AND NVL(MTL.ORGANIZATION_ID,CS_STD.Get_Item_Valdn_Orgzn_ID) = CS_STD.Get_Item_Valdn_Orgzn_ID;

      l_ServiceRequest_rec        l_ServiceRequest_csr%ROWTYPE;


    /***
      New 03/17/03. rmanabat
      Fix for bug 2837253.
    ***/

    l_incident_owner_id		NUMBER;
    --l_source_id			NUMBER;

    /***
    CURSOR l_get_source_id IS
      SELECT emp.source_id
      FROM jtf_rs_resource_extns emp
      WHERE emp.resource_id = l_incident_owner_id;
    ***/

    /*** end New 03/17/03. rmanabat ***/

    CURSOR l_get_source_id(p_resource_id IN NUMBER) IS
      select emp.source_id , emp.resource_name
      from jtf_rs_resource_extns_vl emp
      where emp.resource_id = p_resource_id;
    l_get_source_id_rec       l_get_source_id%ROWTYPE;

    CURSOR l_sel_adhocrole_csr(c_role_name IN VARCHAR2) IS
      SELECT display_name,expiration_date
      FROM wf_local_roles
      WHERE name = c_role_name;
    l_sel_adhocrole_rec l_sel_adhocrole_csr%ROWTYPE;

  BEGIN

    IF (funmode = 'RUN') THEN

      l_request_number := WF_ENGINE.GetItemAttrText(
                              itemtype        => itemtype,
                              itemkey         => itemkey,
                              aname           => 'REQUEST_NUMBER' );

      OPEN l_ServiceRequest_csr;
      FETCH l_ServiceRequest_csr INTO l_ServiceRequest_rec;
      CLOSE l_ServiceRequest_csr;

      IF (l_ServiceRequest_rec.incident_owner_id IS NOT NULL) THEN

        l_incident_owner_id := l_ServiceRequest_rec.incident_owner_id;
        OPEN l_get_source_id(l_incident_owner_id);
        FETCH l_get_source_id INTO l_get_source_id_rec;

        IF (l_get_source_id%FOUND AND l_get_source_id_rec.source_id IS NOT NULL) THEN

          -- Retrieve the role name for the request owner
          CS_WORKFLOW_PUB.Get_Employee_Role (
                    p_api_version           =>  1.0,
                    p_return_status         =>  l_return_status,
                    p_msg_count             =>  l_msg_count,
                    p_msg_data              =>  l_msg_data,
                    --p_employee_id           =>  l_ServiceRequest_rec.incident_owner_id,
                    p_employee_id           =>  l_get_source_id_rec.source_id,
                    p_role_name             =>  l_owner_role,
                    p_role_display_name     =>  l_owner_name );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR
             (l_owner_role is NULL) THEN
            CLOSE l_get_source_id;
            wf_core.context( pkg_name       =>  'CS_WORKFLOW_PUB',
                             proc_name      =>  'Get_Employee_Role',
                             arg1           =>  'p_employee_id=>'||l_get_source_id_rec.source_id);
            l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';

            raise l_API_ERROR;
          END IF;

        ELSE
          CLOSE l_get_source_id;
          wf_core.context( pkg_name       =>  'CS_WF_AUTO_NTFY_UPDATE_PKG',
                           proc_name      =>  'Get_Request_Attributes',
                           arg1           =>  'p_employee_id=>'|| l_get_source_id_rec.source_id);
          l_errmsg_name := 'CS_WF_SR_CANT_FIND_OWNER';
          raise l_API_ERROR;

        END IF;

        IF l_get_source_id%ISOPEN THEN
          CLOSE l_get_source_id;
        END IF;


      END IF;



      /*******
        Note: Ideally, these attributes should be set before the event is raised, in
        the BES wrapper API. Take the scenario when an SR is created and an event is
        raised, the event is placed in the WF_DEFERRED queue. If the SR is updated
        before the event is de-queued, these attributes would reflect the latest data,
        including those which were changed, and not those when the SR was created.
        The disadvantage of adding this as part of the parameter list is the per-
        formance cost. The more parameters are added when raising the event, the
        more theperformance deteriorates (as pointed out by the Workflow team. max.
        number of parameters in an event is 100).
      *******/

       -- Initialize item attributes that will remain constant
      WF_ENGINE.SetItemAttrDate(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_DATE',
                avalue          => l_ServiceRequest_rec.incident_date );

      WF_ENGINE.SetItemAttrNumber(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_ID',
                avalue          => l_ServiceRequest_rec.incident_id );

      /***** IF Request_id is given, request_number is derived in Check_Rules_For_Event()
      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_NUMBER',
                avalue          => l_ServiceRequest_rec.incident_number );
      *****/

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_TYPE',
                avalue          => l_ServiceRequest_rec.incident_type );


      -- Update service request item attributes
      WF_ENGINE.SetItemAttrNumber(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'OWNER_ID',
                avalue          => l_ServiceRequest_rec.incident_owner_id );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'OWNER_ROLE',
                avalue          => l_owner_role );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'OWNER_NAME',
                avalue          => l_owner_name );

      WF_ENGINE.SetItemAttrNumber(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'CUSTOMER_PRODUCT_ID',
                avalue          => l_ServiceRequest_rec.customer_product_id );

      WF_ENGINE.SetItemAttrDate(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'EXPECTED_RESOLUTION_DATE',
                avalue          => l_ServiceRequest_rec.expected_resolution_date );

      WF_ENGINE.SetItemAttrNumber(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'INVENTORY_ITEM_ID',
                avalue          => l_ServiceRequest_rec.inventory_item_id );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'PROBLEM_DESCRIPTION',
                avalue          => l_ServiceRequest_rec.problem_code_description );

      -- 5245018_start
      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'PROBLEM_CODE',
                avalue          => l_ServiceRequest_rec.problem_code );
      -- 5245018_eof

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'PRODUCT_DESCRIPTION',
                avalue          => l_ServiceRequest_rec.product_description );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_CUSTOMER',
                avalue          => l_ServiceRequest_rec.customer_name );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_SEVERITY',
                avalue          => l_ServiceRequest_rec.severity );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_STATUS',
                avalue          => l_ServiceRequest_rec.status_code );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_SUMMARY',
                avalue          => l_ServiceRequest_rec.summary );

      WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'REQUEST_URGENCY',
                avalue          => l_ServiceRequest_rec.urgency );


      -- Get the old incident_owner role if old incident owner is given
      l_old_incident_owner_id := WF_ENGINE.GetItemAttrText(
                itemtype        => itemtype,
                itemkey         => itemkey,
                aname           => 'PREV_OWNER_ID');

      IF (l_old_incident_owner_id IS NOT NULL) THEN

        CS_WORKFLOW_PUB.Get_Employee_Role (
                  p_api_version           =>  1.0,
                  p_return_status         =>  l_return_status,
                  p_msg_count             =>  l_msg_count,
                  p_msg_data              =>  l_msg_data,
                  p_employee_id           =>  l_old_incident_owner_id,
                  p_role_name             =>  l_owner_role,
                  p_role_display_name     =>  l_owner_name );

        IF (l_owner_role IS NOT NULL) THEN
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'PREV_OWNER_ROLE',
                  avalue          => l_owner_role );
          WF_ENGINE.SetItemAttrText(
                  itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'PREV_OWNER_NAME',
                  avalue          => l_owner_name );
	END IF;


      END IF;


      l_role_name := WF_ENGINE.GetItemAttrText(
                              itemtype        => itemtype,
                              itemkey         => itemkey,
                              aname           => 'SENDER_ROLE' );

      IF (l_role_name IS NULL) THEN

        l_resource_id :=  NVL(FND_PROFILE.VALUE('CS_SR_DEFAULT_SYSTEM_RESOURCE'), -1);
        OPEN l_get_source_id(l_resource_id);
        FETCH l_get_source_id INTO l_get_source_id_rec;

        l_role_name := 'CS_WF_ROLE_DUMMY';
        OPEN l_sel_adhocrole_csr(l_role_name);
        FETCH l_sel_adhocrole_csr INTO l_sel_adhocrole_rec;

        IF (l_sel_adhocrole_csr%FOUND) THEN

	  -- expired adhoc role, renew expiration date.
          IF (nvl(l_sel_adhocrole_rec.EXPIRATION_DATE, SYSDATE) < sysdate) THEN
            wf_directory.SetAdHocRoleExpiration(role_name         => l_role_name,
                                                expiration_date   => sysdate + 365);
          END IF;

	  -- change display name if needed.
          IF (l_sel_adhocrole_rec.display_name <> l_get_source_id_rec.resource_name) THEN
            l_role_display_name := l_get_source_id_rec.resource_name;
            wf_directory.SetAdHocRoleAttr(role_name       => l_role_name,
                                          display_name    => l_role_display_name);
          END IF;

        ELSE

          wf_directory.CreateAdHocRole(role_name          => l_role_name,
                                       role_display_name  => l_role_display_name,
                                       expiration_date    => sysdate + 365);

          l_role_display_name := l_get_source_id_rec.resource_name;

          wf_directory.SetAdHocRoleAttr(role_name         => l_role_name,
                                        display_name      => l_role_display_name);
        END IF;

        IF l_sel_adhocrole_csr%ISOPEN THEN
          CLOSE l_sel_adhocrole_csr;
        END IF;
        IF l_get_source_id%ISOPEN THEN
          CLOSE l_get_source_id;
        END IF;

        WF_ENGINE.SetItemAttrText(
                itemtype        => 'SERVEREQ',
                itemkey         => itemkey,
                aname           => 'SENDER_ROLE',
                avalue          => l_role_name );


      END IF;	-- IF (l_role_name IS NULL)

      result := 'COMPLETE';

    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

  EXCEPTION
    WHEN l_API_ERROR THEN
      IF (l_ServiceRequest_csr%ISOPEN) THEN
        CLOSE l_ServiceRequest_csr;
      END IF;
      WF_CORE.Raise(l_errmsg_name);
    WHEN OTHERS THEN
      WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Get_Request_Attributes',
                      itemtype, itemkey, actid, funmode);
      RAISE;

  END Get_Request_Attributes;


/**************************************************************
-- pull_from_list
--   Pull an element from the list , and return the element
--   and the updated list
**************************************************************/

  PROCEDURE pull_from_list(itemlist	IN OUT	NOCOPY VARCHAR2,
			    element	OUT	NOCOPY VARCHAR2) IS

    --l_out_list		VARCHAR2(4000);
    l_space_pos		NUMBER;

  BEGIN

    l_space_pos := instr(itemlist, ' ');

    IF l_space_pos <> 0 THEN
      element := substr(itemlist, 1, l_space_pos - 1);
      itemlist := substr(itemlist, l_space_pos + 1, nvl(length(itemlist),0) - l_space_pos);
    ELSE  -- No space, means only one record in list
      element := itemlist;
      itemlist := NULL;
    END IF;

  END pull_from_list;


--  ---------------------------------------------------------------------------
--  Procedure   : Get_Fnd_User_Role
--  ---------------------------------------------------------------------------

  PROCEDURE Get_Fnd_User_Role
    ( p_fnd_user_id       IN      NUMBER,
      x_role_name         OUT     NOCOPY VARCHAR2,
      x_role_display_name OUT     NOCOPY VARCHAR2 ) IS

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



  /***********************************************************************
  -- Create_Interaction_Activity
  --
  -- Modification History:
  --  Date        Name        Desc
  --  --------    ----------  --------------------------------------
  --  07/14/2004  RMANABAT    Fix for bug 3766921. Removed literals used in
  --			      cursors.
  ***********************************************************************/
  PROCEDURE Create_Interaction_Activity(
                        p_api_revision  IN      NUMBER,
                        p_init_msg_list IN      VARCHAR2,
                        p_commit        IN      VARCHAR2,
                        p_incident_id   IN      NUMBER,
                        p_incident_number       IN VARCHAR2 DEFAULT NULL,
                        p_party_id      IN      NUMBER,
                        p_user_id       IN      NUMBER,
                        p_resp_appl_id  IN      NUMBER,
                        p_resp_id       IN      NUMBER,
                        p_login_id      IN      NUMBER,
                        x_return_status OUT     NOCOPY  VARCHAR2,
                        x_resource_id   OUT     NOCOPY  NUMBER,
                        x_resource_type OUT     NOCOPY  VARCHAR2,
                        x_msg_count     OUT     NOCOPY  NUMBER,
                        x_msg_data      OUT     NOCOPY  VARCHAR2) IS


    c_wrap_id           NUMBER;
    l_int_wrapup_id     NUMBER;
    l_act_wrapup_id     NUMBER;
    --l_return_status   VARCHAR2(1);
    --l_msg_count               NUMBER;
    --l_msg_data                VARCHAR2(2000);
    l_action_id         NUMBER;
    l_action_item_id    NUMBER;
    l_user_id           NUMBER;

    p_wrap_id           NUMBER;
    l_new_interaction_id        NUMBER;
    l_interaction_rec   JTF_IH_PUB.interaction_rec_type;
    l_activity_rec      JTF_IH_PUB.activity_rec_type;

    l_default_int_outcome_id    NUMBER;
    l_default_int_outcome       jtf_ih_wrap_ups_vl.outcome_short_desc%TYPE;
    l_result_reqd               jtf_ih_wrap_ups_vl.result_required%TYPE;
    l_default_int_result_id     NUMBER;
    l_default_int_result        jtf_ih_wrap_ups_vl.result_short_desc%TYPE;
    l_reason_reqd               jtf_ih_wrap_ups_vl.reason_required%TYPE;
    l_default_int_reason_id     jtf_ih_wrap_ups_vl.reason_id%TYPE;
    l_default_int_reason        jtf_ih_wrap_ups_vl.reason_short_desc%TYPE;
    l_incident_number           VARCHAR2(64);
    l_default_result_id         NUMBER;
    l_default_reason_id         NUMBER;
    l_default_result            jtf_ih_wrap_ups_vl.result_short_desc%TYPE;
    l_activity_id               NUMBER;
    l_default_reason            jtf_ih_wrap_ups_vl.reason_short_desc%TYPE;

    l_default_outcome_id        NUMBER;
    l_default_outcome           jtf_ih_wrap_ups_vl.outcome_short_desc%TYPE;

    l_action_item		VARCHAR2(80);
    l_action			VARCHAR2(80);

    l_NO_RESOURCE_FOUND		EXCEPTION;

    CURSOR is_interaction_active(c_incident_id number) IS
      select b.interaction_id
      from jtf_ih_activities a,
           jtf_ih_interactions b
      where a.doc_ref='SR'
            and a.doc_id = c_incident_id
            and a.interaction_id = b.interaction_id
            and b.active = 'Y';

    CURSOR wrap_cur IS
      select outcome_id,
             outcome_short_desc,
             result_required,
             result_id,
             result_short_desc,
             reason_required,
             reason_id,
             reason_short_desc
      from jtf_ih_wrap_ups_vl
      where wrap_id = c_wrap_id;

    CURSOR c_action_item_id IS
      SELECT nvl(action_item_id,0)
      FROM jtf_ih_action_items_vl
      --WHERE action_item = 'Sr'
      WHERE action_item = l_action_item
            AND  rownum < 2;

    CURSOR c_action_id IS
      SELECT nvl(action_id,0)
      FROM jtf_ih_actions_vl
      --WHERE action = 'Automated Email Sent'
      WHERE action = l_action
            AND  rownum < 2;

    CURSOR c_incident_number IS
      SELECT incident_number
      FROM cs_incidents_all_b
      WHERE incident_id = p_incident_id;


    CURSOR sel_contact_party_name_csr IS
      SELECT PARTY_NAME
      FROM HZ_PARTIES
      WHERE
          PARTY_ID = p_party_id;

    l_int_profile       varchar2(30);
    l_failed            NUMBER := 0;
    l_msg_index_OUT     NUMBER;
    l_error_text        VARCHAR2(2000);
    NL                  VARCHAR2(1);
    d_user_id		NUMBER;
    d_resp_appl_id	NUMBER;
    d_resp_id		NUMBER;
    d_login_id		NUMBER;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_int_wrapup_id := FND_PROFILE.Value('CSC_CC_WRAPUP_INTERACTION_DEFAULTS');

    l_action_item := 'Sr';
    l_action := 'Automated Email Sent';

    l_interaction_rec := JTF_IH_PUB.INIT_INTERACTION_REC;
    l_activity_rec := JTF_IH_PUB.INIT_ACTIVITY_REC;

    l_int_profile := FND_PROFILE.Value('CS_SR_INTERACTION_LOGGING');
    NL := fnd_global.Local_Chr(10);

    IF ( l_int_profile is  null or  l_int_profile ='AUTO_INT_LOG' ) THEN


      IF (p_user_id is null) THEN
       fnd_profile.get('USER_ID', d_user_id);
      ELSE
	d_user_id := p_user_id;
      END  IF;

      IF (p_login_id is null) THEN
        fnd_profile.get('LOGIN_ID', d_login_id);
      ELSE
	d_login_id := p_login_id;
      END IF;

      IF (p_resp_id is null) THEN
        fnd_profile.get('RESP_ID', d_resp_id);
      ELSE
	d_resp_id := p_resp_id;
      END IF;

      IF (p_resp_appl_id is null) THEN
        fnd_profile.get('RESP_APPL_ID', d_resp_appl_id);
      ELSE
	d_resp_appl_id := p_resp_appl_id;
      END IF;


      IF ( l_int_wrapup_id is not null ) THEN
        c_wrap_id := l_int_wrapup_id;

        OPEN wrap_cur;
        fetch wrap_cur into
          l_default_int_outcome_id,
          l_default_int_outcome,
          l_result_reqd,
          l_default_int_result_id,
          l_default_int_result,
          l_reason_reqd,
          l_default_int_reason_id,
          l_default_int_reason;
        close wrap_cur;

/* Roopa - Begin - Fix for bug 3360069 */
/* Initializing the local vars with FND_GLOBAL values if the local vars are null in value */
/* It's necessary to hard code the value of d_resp_appl_id to 170 since
   WF item attr RESP_APPL_ID has returned a null value and create and close
   interaction calls will fail if we pass a null value for resp_appl_id/handler_id */
       IF(d_resp_appl_id is NULL or d_resp_appl_id = -1) THEN
		d_resp_appl_id := 170;
       END IF;

	IF(d_resp_id is NULL) THEN
		d_resp_id := FND_GLOBAL.RESP_ID;
	END IF;

	IF(d_user_id is NULL) THEN
		d_user_id := FND_GLOBAL.USER_ID;
	END IF;

	IF(d_login_id is NULL) THEN
		d_login_id := FND_GLOBAL.LOGIN_ID;
	END IF;
/* Roopa - End - Fix for bug 3360069 */

        l_interaction_rec.party_id := p_party_id;
        -- Get the application id AND pass that IN handler_id
        l_interaction_rec.handler_id := d_resp_appl_id;
        l_user_id := d_user_id;

        -- Get the corresponding RESOURCE_ID, fOR the l_user_id, FROM JTF Resource schema
	/****
        SELECT  a.resource_id
        into    l_interaction_rec.resource_id
        FROM    jtf_rs_resource_extns a
        WHERE   a.user_id    = l_user_id;
	****/

	-- Get the resource from the profile instead. Part of fix for bug 3360069.
	-- rmanabat 01/19/04.
        l_interaction_rec.resource_id := FND_PROFILE.VALUE('CS_SR_DEFAULT_SYSTEM_RESOURCE');
	IF (l_interaction_rec.resource_id is NULL) THEN
	  raise l_NO_RESOURCE_FOUND;
	END IF;

        l_interaction_rec.outcome_id    := l_default_int_outcome_id;
        l_interaction_rec.result_id     := l_default_int_result_id;
        l_interaction_rec.reason_id     := l_default_int_reason_id;
         l_interaction_rec.start_date_time  := sysdate;
        l_interaction_rec.duration         := 0;


        -- Start the interaction
       jtf_ih_pub.open_interaction(
                        1.0,
                        p_init_msg_list,
                        p_commit,
                        d_resp_appl_id,
                        d_resp_id,
                        d_user_id,
                        d_login_id,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        l_interaction_rec,
                        l_new_interaction_id);


      END IF;  -- IF ( l_int_wrapup_id is not null )


      IF (l_new_interaction_id IS NULL OR x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;

      ELSE


        l_act_wrapup_id := FND_PROFILE.Value('CSC_CC_WRAPUP_ACTIVITY_DEFAULTS');

        IF (l_act_wrapup_id is not null) THEN
        -- Get the Activity defaults
          p_wrap_id := l_act_wrapup_id;

          OPEN wrap_cur;
          FETCH wrap_cur INTO
            l_default_outcome_id,
            l_default_outcome,
            l_result_reqd,
            l_default_result_id,
            l_default_result,
            l_reason_reqd,
            l_default_reason_id,
            l_default_reason;
          CLOSE wrap_cur;

          OPEN c_action_item_id;
          FETCH c_action_item_id INTO
            l_action_item_id;
          CLOSE c_action_item_id;

          OPEN c_action_id;
          FETCH c_action_id INTO l_action_id;
          CLOSE c_action_id;

          IF (p_incident_number IS NULL) THEN
            OPEN c_incident_number;
            FETCH c_incident_number INTO l_incident_number;
            CLOSE c_incident_number;
          ELSE
            l_incident_number := p_incident_number;
          END IF;

          l_activity_rec.interaction_id  := l_new_interaction_id;
          l_activity_rec.action_id       := l_action_id;
          l_activity_rec.outcome_id      := l_default_outcome_id;
          l_activity_rec.result_id       := l_default_result_id;
          l_activity_rec.reason_id       := l_default_reason_id;
          l_activity_rec.action_item_id  := l_action_item_id;
          --l_activity_rec.cust_account_id := l_account_id;
          l_activity_rec.doc_id          := p_incident_id;
          l_activity_rec.doc_ref         := 'SR';
          l_activity_rec.doc_source_object_name := l_incident_number;
          l_activity_rec.start_date_time := sysdate;
          --l_activity_rec.end_date_time := fnd_standard.system_date;
          l_activity_rec.end_date_time := sysdate;


          jtf_ih_pub.add_activity( 1.0,
                                   p_init_msg_list,
                                   p_commit,
                                   d_resp_appl_id,
                                   d_resp_id,
                                   d_user_id,
                                   d_login_id,
                                   x_return_status,
                                   x_msg_count,
                                   x_msg_data,
                                   l_activity_rec,
                                   l_activity_id);


          IF (l_activity_id IS NULL OR x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

            raise FND_API.G_EXC_ERROR;
            /**********
            l_failed = 1;

            IF ( FND_MSG_PUB.Count_Msg > 0) THEN
              FOR i IN 1..FND_MSG_PUB.Count_Msg    LOOP
                FND_MSG_PUB.Get(p_msg_index     => i,
                                p_encoded       => 'F',
                                p_data          => l_msg_data,
                                p_msg_index_OUT => l_msg_index_OUT );
                l_error_text := l_error_text || l_msg_data ||NL;
              END LOOP;
            END IF;
            **********/

          END IF;


        END IF; -- IF (l_act_wrapup_id is not null)

/* Roopa - Begin - Fix for bug 3360069 */
/* Initializing the local vars with FND_GLOBAL values if the local vars are null in value */
       IF(d_resp_appl_id is NULL or d_resp_appl_id = -1) THEN
		d_resp_appl_id := 170;
       END IF;

	IF(d_resp_id is NULL) THEN
		d_resp_id := FND_GLOBAL.RESP_ID;
	END IF;

	IF(d_user_id is NULL) THEN
		d_user_id := FND_GLOBAL.USER_ID;
	END IF;

	IF(d_login_id is NULL) THEN
		d_login_id := FND_GLOBAL.LOGIN_ID;
	END IF;
/* Roopa - End - Fix for bug 3360069 */


        l_interaction_rec.handler_id     := d_resp_appl_id;
        l_interaction_rec.interaction_id := l_new_interaction_id;
        l_interaction_rec.outcome_id  := l_default_int_outcome_id;
        l_interaction_rec.result_id  := l_default_result_id;
        l_interaction_rec.reason_id  := l_default_reason_id;
        --l_interaction_rec.end_date_time  := fnd_standard.system_date;
        l_interaction_rec.end_date_time  := sysdate;

        jtf_ih_pub.close_interaction
                                   ( 1.0,
                                     p_init_msg_list,
                                     p_commit,
                                     d_resp_appl_id,
                                     d_resp_id,
                                     d_user_id,
                                     d_login_id,
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data,
                                     l_interaction_rec);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          raise FND_API.G_EXC_ERROR;
        END IF;

      END IF;   -- (l_new_interaction_id IS NOT NULL)




    END IF;  -- IF ( l_int_profile is  null or  l_int_profile ='AUTO_INT_LOG' )

  EXCEPTION

    WHEN l_NO_RESOURCE_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.initialize;
      FND_MESSAGE.Set_Name('CS', 'CS_SR_WF_NO_INT_RESOURCE');
      FND_MESSAGE.Set_Token('API_NAME', 'CS_WF_AUTO_NTFY_UPDATE_PKG.Create_Interaction_Activity');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
        );

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
        );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Create_Interaction_Activity');
      END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count => x_msg_count,
          p_data  => x_msg_data
        );


  END Create_Interaction_Activity;



  /***********************************************************************
  -- SetWorkflowAdhocUser
  --   This procedure creates/updates a dummy adhoc user . This adhoc user
  --   is assigned the email address from the IN parameter and it's
  --   expiration date is extended if it has expired. This adhoc user is mainly
  --   used for notificaion to contacts, for performance reasons.
  --
  -- Modification History:
  --  Date        Name        Desc
  --  --------    ----------  --------------------------------------
  --  07/13/2004  RMANABAT    Created.
  --  07/28/2004  RMANABAT    Changed referred table in cursor from WF_LOCAL_USERS
  --			      to WF_LOCAL_ROLES since calling create_adhocuser()
  --			      creates a row in WF_LOCAL_ROLES .
  ***********************************************************************/

  PROCEDURE SetWorkflowAdhocUser(
			p_wf_username	IN OUT NOCOPY VARCHAR2,
			p_email_address IN VARCHAR2,
			p_display_name	IN VARCHAR2 DEFAULT NULL) IS

    CURSOR sel_user_csr(c_user_name IN VARCHAR2) IS
      SELECT display_name,expiration_date
      FROM wf_local_roles
      WHERE name = c_user_name;
    l_sel_user_rec sel_user_csr%ROWTYPE;

    l_wf_username	VARCHAR2(320);
    l_user_display_name	VARCHAR2(360);

  BEGIN

    l_wf_username := p_wf_username;
    l_user_display_name := p_display_name;

    OPEN sel_user_csr(l_wf_username);
    FETCH sel_user_csr INTO l_sel_user_rec;

    IF (sel_user_csr%FOUND) THEN

      -- expired adhoc user, renew expiration date.
      IF (nvl(l_sel_user_rec.EXPIRATION_DATE, SYSDATE) < sysdate) THEN
        wf_directory.SetAdHocUserExpiration(user_name         => l_wf_username,
                                            expiration_date   => sysdate + 365);
      END IF;

      wf_directory.SetAdHocUserAttr(user_name		=> l_wf_username,
				    display_name	=> l_user_display_name,
                                    email_address	=> p_email_address);

    ELSE

      WF_DIRECTORY.CreateAdHocUser(name			=> l_wf_username,
                                   display_name		=> l_user_display_name,
                                   email_address	=> p_email_address);
    END IF;

    p_wf_username := l_wf_username;

    IF sel_user_csr%ISOPEN THEN
      CLOSE sel_user_csr;
    END IF;

  END SetWorkflowAdhocUser;


  /***********************************************************************
  -- SetWorkflowAdhocRole
  --   This procedure creates/updates a dummy adhoc role . This adhoc role
  --   is assigned the user list from the IN parameter and it's
  --   expiration date is extended if it has expired. This adhoc role is mainly
  --   used for notificaion to contacts, for performance reasons.
  --
  -- Modification History:
  --  Date        Name        Desc
  --  --------    ----------  --------------------------------------
  --  07/13/2004  RMANABAT    Created.
  ***********************************************************************/
  PROCEDURE SetWorkflowAdhocRole(
			p_wf_rolename	IN OUT NOCOPY VARCHAR2,
			p_user_list	IN VARCHAR2) IS

    CURSOR l_sel_adhocrole_csr(c_role_name IN VARCHAR2) IS
      SELECT display_name,expiration_date
      FROM wf_local_roles
      WHERE name = c_role_name;
    l_sel_adhocrole_rec l_sel_adhocrole_csr%ROWTYPE;

    l_wf_rolename       VARCHAR2(320);
    l_role_display_name VARCHAR2(360);

  BEGIN

    l_wf_rolename := p_wf_rolename;

    OPEN l_sel_adhocrole_csr(l_wf_rolename);
    FETCH l_sel_adhocrole_csr INTO l_sel_adhocrole_rec;

    IF (l_sel_adhocrole_csr%FOUND) THEN

      -- expired adhoc role, renew expiration date.
      IF (nvl(l_sel_adhocrole_rec.EXPIRATION_DATE, SYSDATE) < sysdate) THEN
        wf_directory.SetAdHocRoleExpiration(role_name         => l_wf_rolename,
                                            expiration_date   => sysdate + 365);
      END IF;

      wf_directory.RemoveUsersFromAdHocRole(role_name	=> l_wf_rolename);

      wf_directory.AddUsersToAdHocRole(role_name	=> l_wf_rolename,
                                       role_users	=> p_user_list);

    ELSE

      wf_directory.CreateAdHocRole(role_name		=> l_wf_rolename,
                                   role_display_name	=> l_role_display_name,
                                   role_users		=> p_user_list);

    END IF;

    IF l_sel_adhocrole_csr%ISOPEN THEN
      CLOSE l_sel_adhocrole_csr;
    END IF;

  END SetWorkflowAdhocRole;


  PROCEDURE Prepare_HTML_Notification
              ( itemtype   IN  VARCHAR2,
                itemkey    IN  VARCHAR2,
                actid      IN  NUMBER,
                funmode    IN  VARCHAR2,
                result     OUT NOCOPY VARCHAR2 ) IS

  l_request_id               NUMBER;
  l_contact_id               NUMBER;
  l_contact_email            VARCHAR2(240);
  l_adhoc_user               VARCHAR2(240);
  l_contact_type             VARCHAR2(240);
  l_language                 VARCHAR2(240);
  l_notification_pref        VARCHAR2(240);
  l_message_name             VARCHAR2(240);

  l_contact_id_list          VARCHAR2(2000);
  l_contact_email_list       VARCHAR2(2000);
  l_adhoc_user_list          VARCHAR2(2000);
  l_contact_type_list        VARCHAR2(2000);
  l_language_list            VARCHAR2(2000);
  l_notification_pref_list   VARCHAR2(2000);

  l_element                  VARCHAR2(100);
  l_element1                 VARCHAR2(100);
  l_element2                 VARCHAR2(100);
  l_notification_template    VARCHAR2(240);
  l_user_display_name        VARCHAR2(240);
  l_notify_recipient         VARCHAR2(240);
  l_return_status            VARCHAR2(3);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAr2(1000);
  l_adhoc_role               VARCHAr2(240);
  l_message_id               NUMBER;
  l_count                    NUMBER := 0;
  l_request_number           NUMBER;
  l_sender                   VARCHAR2(240);
  l_from_status              VARCHAR2(240);
  l_to_status                VARCHAR2(240);


  BEGIN

  -- Log debug messages

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION')) THEN

          dbg_msg := ('In CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('ItemType :'||ItemType);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('ItemKey :'||ItemKey);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

        END IF;
      END IF;


  -- Get necessary item attributes


  IF (funmode = 'RUN') THEN

     l_request_id             := WF_ENGINE.GetItemAttrText(
                                         itemtype        => itemtype,
                                         itemkey         => itemkey,
                                         aname           => 'REQUEST_ID' );

     l_request_number          := WF_ENGINE.GetItemAttrText(
                                         itemtype        => itemtype,
                                         itemkey         => itemkey,
                                         aname           => 'REQUEST_NUMBER' );

     l_sender                  :=  WF_ENGINE.GetItemAttrText(
                                         itemtype        => itemtype,
                                         itemkey         => itemkey,
                                         aname           => 'SENDER_ROLE' );

     l_contact_id_list  := WF_ENGINE.GetItemAttrText(
                                         itemtype        => itemtype,
                                         itemkey         => itemkey,
                                         aname           => 'CONTACT_ID_LIST' );

     l_contact_email_list     := WF_ENGINE.GetItemAttrText(
                                         itemtype        => itemtype,
                                         itemkey         => itemkey,
                                         aname           => 'CONTACT_EMAIL_LIST' );

     l_adhoc_user_list        := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'ADHOC_USER_LIST');

     l_contact_type_list      := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'CONTACT_TYPE_LIST');

     l_language_list          := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'LANGUAGE_LIST');

     l_notification_pref_list := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'NOTIFICATION_PREFERENCE_LIST');

     l_message_name           := WF_ENGINE.GetItemAttrText(
                                          itemtype        => itemtype,
                                          itemkey         => itemkey,
                                          aname           => 'NTFY_MESSAGE_NAME');


      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION')) THEN

          dbg_msg := ('l_request_id : '||l_request_id);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_request_number : '||l_request_number);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_sender : '||l_sender);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_contact_id_list : ' ||l_contact_id_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_contact_email_list : '||l_contact_email_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_adhoc_user_list : '||l_adhoc_user_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_contact_type_list : '||l_contact_type_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_language_list : '||l_language_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_notification_pref_list : '||l_notification_pref_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_message_name : '||l_message_name);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

        END IF;
      END IF;

     IF l_message_name = 'CS_SR_IBU_EVT_STATUS_CHANGED' THEN

	    l_from_status := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_STATUS_OLD');

	    l_to_status   := WF_ENGINE.GetItemAttrText(
                                        itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'REQUEST_STATUS');
     END IF;

            -- Get the message Name
  -- Set the Notification Details Required to send the email/wf html notification.

     IF l_contact_id_list IS NOT NULL THEN
	    l_count := 1;

        pull_from_list(itemlist => l_contact_email_list,
                       element  => l_element);

        pull_from_list(itemlist => l_contact_id_list,
                       element  => l_element1);

        pull_from_list(itemlist => l_adhoc_user_list,
                       element  => l_adhoc_user);

        pull_from_list(itemlist => l_contact_type_list,
                       element  => l_contact_type);

        pull_from_list(itemlist => l_language_list,
                       element  => l_language);

        pull_from_list(itemlist => l_notification_pref_list,
                       element  => l_notification_pref);

        WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'ADHOC_USER_LIST',
                        AValue => l_adhoc_user_list);

        WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'CONTACT_ID_LIST',
                        AValue => l_contact_id_list);

        WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'CONTACT_EMAIL_LIST',
                        AValue => l_contact_email_list);

        WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'CONTACT_TYPE_LIST',
                        AValue => l_contact_type_list);

        WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'NOTIFICATION_PREFERENCE_LIST',
                        AValue => l_notification_pref_list);

        WF_ENGINE.SetItemAttrText
                      ( itemtype  => itemtype,
                        itemkey   => itemkey,
                        AName  => 'LANGUAGE_LIST',
                        AValue => l_language_list);

      END IF;

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION')) THEN

          dbg_msg := ('Processing HTML Notification following set of attributes');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_element : '||l_element);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_element1 : '||l_element1);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_adhoc_user : '||l_adhoc_user);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_contact_type : '||l_contact_type);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_language : '||l_language);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

          dbg_msg := ('l_notification_pref : '||l_notification_pref);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

        END IF;
      END IF;

      -- Set the recipient role for the notification

      WF_ENGINE.SetItemAttrText
                ( itemtype        => itemtype,
                  itemkey         => itemkey,
                  aname           => 'NTFY_RECIPIENT',
                  avalue          => l_adhoc_user);


      l_contact_email    := l_element;
      l_contact_id := to_number(l_element1);

      -- Set the notification details as per the IBU templates.

      -- Call IBU API wrapper

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION')) THEN

          dbg_msg := ('Calling CS_WF_AUTO_NTFY_UPDATE_PKG.Set_HTML_Notification_Details Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

        END IF;
      END IF;

      Set_HTML_Notification_Details
              ( p_itemtype         => itemtype,
                p_itemkey          => itemkey,
                p_actid            => actid,
                p_funmode          => funmode,
                p_contact_type     => l_contact_type,
                p_contact_id       => to_number(l_contact_id),
                p_request_id       => to_number(l_request_id),
		p_request_number   => l_request_number,
		p_sender           => l_sender,
                p_email_preference => l_notification_pref,
                p_user_language    => l_language,
		p_recipient        => l_adhoc_user,
		p_message_name     => l_message_name,
 	 	p_from_status      => l_from_status,
 		p_to_status        => l_to_status) ;


      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION')) THEN

          dbg_msg := ('After Calling CS_WF_AUTO_NTFY_UPDATE_PKG.Set_HTML_Notification_Details Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
          END IF;

        END IF;
      END IF;

      result := 'COMPLETE';

  ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
  END IF;

  IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
    IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION')) THEN

      dbg_msg := ('Prepare_HTML_Notification Proc Result : '||result);
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.PREPARE_HTML_NOTIFICATION', dbg_msg);
      END IF;

    END IF;
  END IF;

  EXCEPTION
       WHEN OTHERS THEN
            WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Send_HTML_Notification',
		    itemtype, itemkey, actid, funmode);
            RAISE;

  END Prepare_HTML_Notification;

PROCEDURE Set_HTML_Notification_Details
           ( p_itemtype         IN        VARCHAR2,
             p_itemkey          IN        VARCHAR2,
             p_actid            IN        NUMBER,
             p_funmode          IN        VARCHAR2,
             p_contact_type     IN        VARCHAR2,
             p_contact_id       IN        NUMBER,
             p_request_id       IN        NUMBER,
	     p_request_number   IN        VARCHAR2,
 	     p_sender           IN        VARCHAR2,
             p_email_preference IN        VARCHAR2,
             p_user_language    IN        VARCHAR2,
             p_recipient        IN        VARCHAR2,
	     p_message_name     IN        VARCHAR2,
	     p_from_status      IN        VARCHAR2,
	     p_to_status        IN        VARCHAR2) IS

 l_count          NUMBER :=0 ;
 l_count1         NUMBER :=0 ;
 l_ticket_number  VARCHAR2(2000);
 l_ticket_valid   BOOLEAN:= FALSE;
 l_request        UTL_HTTP.REQ;
 l_response       UTL_HTTP.RESP;
 l_out_value      VARCHAR2(32000);
 l_ibu_url        VARCHAR2(2000);
 l_host           VARCHAR2(2000);
 l_request_number VARCHAR2(240);
 l_message_id     NUMBER;
 l_mail_pref      VARCHAR2(240);

  BEGIN

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS')) THEN

          dbg_msg := ('In CS_WF_AUTO_NTFY_UPDATE_PKG.Set_HTML_Notification_Details Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS', dbg_msg);
          END IF;

        END IF;
      END IF;

   -- Get the ticket number

      l_ticket_number := FND_HTTP_TICKET.GET_SERVICE_TICKET_STRING('CS_IBU_EMAIL');

   -- Set the mail preference

      IF (p_email_preference = 'MAILHTML' OR p_email_preference = 'MAILHTML2') THEN
         l_mail_pref := 'MAILHTML';
      ELSE
         l_mail_pref := 'MAILTEXT';
      END IF ;

   -- set the ibu url

	  l_ibu_url := '/OA_HTML/ibuEmailContentProvider.jsp?ibuSRNum='||p_request_number||l_amp||'ibuSRID='
                       || p_request_id ||l_amp||'ibuTicketNum=' || l_ticket_number || l_amp||'ibuEmailIBUCONTENTPref='
                       || l_mail_pref || l_amp||'IBUContactID=' || p_contact_id || l_amp||'IBUContactType='
                       || p_contact_type || l_amp||'IBULanguage=' || p_user_language ;

   -- Get the host

      FND_PROFILE.GET('APPS_FRAMEWORK_AGENT',l_host);

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS')) THEN

          dbg_msg := ('l_mail_pref : '||l_mail_pref);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS', dbg_msg);
          END IF;

          dbg_msg := ('IBU URL : '||l_host||l_ibu_url);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS', dbg_msg);
          END IF;

        END IF;
      END IF;

	 -- bug 5661159
	 IF lower(substr(nvl(l_host, ''), 1, 5)) = 'https' THEN
         UTL_HTTP.SET_WALLET('file:' || FND_PROFILE.Value('FND_DB_WALLET_DIR'));
	 END IF;
	 -- bug 5661159_eof

      l_request := UTL_HTTP.BEGIN_REQUEST(l_host||l_ibu_url);

      l_response := UTL_HTTP.Get_Response(l_request);

      LOOP
          l_count := l_count + 1 ;
          UTL_HTTP.READ_LINE(l_response, l_out_value,TRUE);

          IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
            IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS')) THEN
              dbg_msg := ('l_count : '||l_count||'   l_count1'||l_count1);
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS', dbg_msg);
              END IF;

              dbg_msg := ('Response Line : '||substr(l_out_value,1,4000));
              IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.SET_HTML_NOTIFICATION_DETAILS', dbg_msg);
              END IF;

            END IF;
          END IF;

          IF l_count1 > 0 THEN
             l_count1 := l_count1 + 1;
          END IF ;

          IF l_out_value = 'EMAILCONTENTSTART' THEN
             l_count1 := 1;
          END IF ;

          IF ((length(l_out_value) >0 ) AND(l_mail_pref = 'MAILTEXT')) THEN
             l_out_value := REPLACE(l_out_value,'\n',l_new_line);
          END IF;

          IF l_count1 = 2 THEN

              WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname       => 'STYLESHEET',
                                 avalue      => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 3 then

              WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname       => 'BRANDINGINFO',
                                 avalue      => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );

          ELSIF l_count1 = 4 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT1',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );

          ELSIF l_count1 = 5 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT2',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 6 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT3',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 7 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT4',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 8 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT5',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );



          ELSIF l_count1 = 9 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT6',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );



          ELSIF l_count1 = 10 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT7',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );



          ELSIF l_count1 = 11 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT8',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 12 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT9',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 13 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT10',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 14 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT11',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 15 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT12',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 16 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT13',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 17 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT14',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 18 then

                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname     => 'IBU_CONTENT15',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );


          ELSIF l_count1 = 19 then

                NULL;
          ELSIF l_count1 = 20 then

             IF l_count1 IS NOT NULL THEN
                      WF_ENGINE.SetItemAttrText(
                                 itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                                 aname       => 'URL_LINK',
                                 avalue    => 'plsql:IBU_SUBS_DOC_PKG.set_msg_body_token/'||l_out_value );

             END IF;
          END IF ;

          IF l_out_value = 'EMAILCONTENTEND' THEN
             EXIT;
          END IF;

END LOOP;

      UTL_HTTP.End_Response(l_response);

  EXCEPTION
        WHEN UTL_HTTP.END_OF_BODY THEN
             UTL_HTTP.End_Response(l_response);
        WHEN OTHERS THEN
             WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Verify_Notify_Rules_Done',
	 	      p_itemtype, p_itemkey, p_actid, p_funmode);
      RAISE;
  END Set_HTML_Notification_Details;

  PROCEDURE Are_All_HTML_Recips_Notified( itemtype   IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funmode    IN  VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS


    l_contact_id_list  VARCHAR2(2000);

    BEGIN

      IF((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        IF (FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.ARE_ALL_HTML_RECIPS_NOTIFIED')) THEN

          dbg_msg := ('In CS_WF_AUTO_NTFY_UPDATE_PKG.Are_All_HTML_Recips_Notified Procedure');
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.ARE_ALL_HTML_RECIPS_NOTIFIED', dbg_msg);
          END IF;

          dbg_msg := ('l_contact_id_list : '||l_contact_id_list);
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_WF_AUTO_NTFY_UPDATE_PKG.ARE_ALL_HTML_RECIPS_NOTIFIED', dbg_msg);
          END IF;

        END IF;
      END IF;
    IF (funmode = 'RUN') THEN

      l_contact_id_list := WF_ENGINE.GetItemAttrText(
                                  itemtype        => itemtype,
                                  itemkey         => itemkey,
                                  aname           => 'CONTACT_ID_LIST' );

      IF (l_contact_id_list IS NOT NULL ) THEN
        result := 'COMPLETE:N';
      ELSE
        result := 'COMPLETE:Y';
      END IF ;


    ELSIF (funmode = 'CANCEL') THEN
      result := 'COMPLETE';
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Are_All_HTML_Recips_Notified',
		      itemtype, itemkey, actid, funmode);
      RAISE;

  END Are_All_HTML_Recips_Notified;

PROCEDURE Create_Role_List
              ( p_itemtype         IN        VARCHAR2,
                p_itemkey          IN        VARCHAR2,
                p_actid            IN        NUMBER,
                p_funmode          IN        VARCHAR2,
                p_action_code      IN        VARCHAR2,
                p_role_group_type  IN        VARCHAR2,
                p_role_group_code  IN        VARCHAR2) IS

   l_party_role_group_code        cs_party_role_group_maps.party_role_group_code%TYPE;
   l_part_role_code               cs_party_role_group_maps.party_role_code%TYPE;
   l_notify_party_role_list       varchar2(4000);
   l_notify_party_role_relsr_list varchar2(4000);

   CURSOR sel_party_role_csr IS
      SELECT party_role_code
        FROM cs_party_role_group_maps
       WHERE party_role_group_code = l_party_role_group_code
         AND trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                                and trunc(nvl(end_date_active,sysdate));

   sel_party_role_rec sel_party_role_csr%ROWTYPE;

BEGIN
--x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF (p_action_code = 'NOTIFY_ASSOCIATED_PARTIES') THEN
    IF (p_role_group_type = 'ROLEGROUP') THEN
       l_party_role_group_code := p_role_group_code;

       OPEN sel_party_role_csr;
            LOOP
              FETCH sel_party_role_csr into sel_party_role_rec;
                    EXIT WHEN sel_party_role_csr%NOTFOUND;

              -- Check for the length, not to exceed max WF text length of 4000.

              IF (nvl(LENGTH(l_notify_party_role_list), 0) +
                  nvl(LENGTH(sel_party_role_rec.party_role_code), 0) + 1) <= 4000 THEN

                 IF l_notify_party_role_list IS NULL THEN
                    l_notify_party_role_list := sel_party_role_rec.party_role_code;
                 ELSE
                    l_notify_party_role_list := l_notify_party_role_list || ' ' || sel_party_role_rec.party_role_code;
                 END IF;
              ELSE
                /**********
                 If the query results exceeded the max allowable WF text length, then we
                 set an attribute to indicate that we need to re-query again to obtain
                 the remainder of the results which were not put in the initial list.
                 **********/

                 WF_ENGINE.SetItemAttrText
 		        (itemtype        => p_itemtype,
                         itemkey         => p_itemkey,
                         aname           => 'MORE_NTFY_ACTION_LIST',
                         avalue          => 'Y' );

              END IF;
            END LOOP;
       CLOSE sel_party_role_csr;
    ELSE  --(sel_action_rec.role_group_type = 'ROLEGROUP') THEN
        l_party_role_group_code := p_role_group_code;

        IF (nvl(LENGTH(l_notify_party_role_list), 0) +
            nvl(LENGTH(l_party_role_group_code), 0) + 1) <= 4000 THEN

           IF l_notify_party_role_list IS NULL THEN
              l_notify_party_role_list := l_party_role_group_code;
           ELSE
              l_notify_party_role_list := l_notify_party_role_list || ' ' || l_party_role_group_code;
           END IF;

        ELSE
          /**********
           If the query results exceeded the max allowable WF text length, then we
           set an attribute to indicate that we need to re-query again to obtain
           the remainder of the results which were not put in the initial list.
          **********/

           WF_ENGINE.SetItemAttrText
		    (itemtype        => p_itemtype,
                     itemkey         => p_itemkey,
                     aname           => 'MORE_NTFY_ACTION_LIST',
                     avalue          => 'Y' );

        END IF;
    END IF;   --(sel_action_rec.role_group_type = 'GROUP') THEN

 ELSIF (p_action_code = 'NOTIFY_ALL_ASSOCIATED_PARTIES') THEN
       IF (p_role_group_type = 'ROLEGROUP') THEN
           l_party_role_group_code := p_role_group_code;

          OPEN sel_party_role_csr;
              LOOP
                FETCH sel_party_role_csr into sel_party_role_rec;
                 EXIT WHEN sel_party_role_csr%NOTFOUND;

                -- Check for the length, not to exceed max WF text length of 4000.
                IF (nvl(LENGTH(l_notify_party_role_relsr_list), 0) +
                    nvl(LENGTH(sel_party_role_rec.party_role_code), 0) + 1) <= 4000 THEN

                    IF l_notify_party_role_relsr_list IS NULL THEN
                       l_notify_party_role_relsr_list := sel_party_role_rec.party_role_code;
                    ELSE
                       l_notify_party_role_relsr_list := l_notify_party_role_relsr_list || ' ' || sel_party_role_rec.party_role_code;
                    END IF;

                ELSE
                  /**********
                   If the query results exceeded the max allowable WF text length, then we
                   set an attribute to indicate that we need to re-query again to obtain
	               the remainder of the results which were not put in the initial list.
                   **********/

                   WF_ENGINE.SetItemAttrText
                            (itemtype        => p_itemtype,
                             itemkey         => p_itemkey,
                             aname           => 'MORE_NTFY_ACTION_LIST',
                             avalue          => 'Y' );

                END IF;

              END LOOP;
          CLOSE sel_party_role_csr;
       ELSE  --(sel_action_rec.role_group_type = 'ROLEGROUP') THEN
            l_party_role_group_code := p_role_group_code;

            IF (nvl(LENGTH(l_notify_party_role_relsr_list), 0) +
                nvl(LENGTH(l_party_role_group_code), 0) + 1) <= 4000 THEN

               IF l_notify_party_role_relsr_list IS NULL THEN
                  l_notify_party_role_relsr_list := l_party_role_group_code;
               ELSE
                  l_notify_party_role_relsr_list := l_notify_party_role_relsr_list || ' ' || l_party_role_group_code;
               END IF;

            ELSE
               /**********
                If the query results exceeded the max allowable WF text length, then we
                set an attribute to indicate that we need to re-query again to obtain
  	            the remainder of the results which were not put in the initial list.
                **********/

                WF_ENGINE.SetItemAttrText
		         (itemtype        => p_itemtype,
                          itemkey         => p_itemkey,
                          aname           => 'MORE_NTFY_ACTION_LIST',
                          avalue          => 'Y' );

            END IF;
       END IF;   --(sel_action_rec.role_group_type = 'ROLEGROUP') THEN

  END IF;

  WF_ENGINE.SetItemAttrText
           (itemtype	=> p_itemtype,
            itemkey	=> p_itemkey,
	    aname	=> 'NOTIFY_PARTY_ROLE_LIST',
  	    avalue	=> l_notify_party_role_list );

  WF_ENGINE.SetItemAttrText
           (itemtype	=> p_itemtype,
  	    itemkey	=> p_itemkey,
  	    aname	=> 'NOTIFY_RELSR_PARTY_ROLE_LIST',
  	    avalue	=> l_notify_party_role_relsr_list );

EXCEPTION
         WHEN OTHERS THEN
              WF_CORE.Context('CS_WF_AUTO_NTFY_UPDATE_PKG', 'Create_Role_List',
		      p_itemtype, p_itemkey, p_actid, p_funmode);
      RAISE;
END Create_Role_List;

END CS_WF_AUTO_NTFY_UPDATE_PKG;

/
