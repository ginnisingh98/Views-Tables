--------------------------------------------------------
--  DDL for Package Body ENG_WORKFLOW_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_WORKFLOW_API_PKG" as
/* $Header: engwkfwb.pls 120.4.12010000.4 2013/01/04 09:59:08 ntungare ship $ */

-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

	X_org_id	NUMBER;
	X_change_notice VARCHAR2(10);

  /* Fix for bug 5131658-Added below procedure to get user's name*/
FUNCTION GetWFItemOwnerRole (itemtype         IN  VARCHAR2,
                             itemkey          IN  VARCHAR2)
RETURN VARCHAR2 IS
	x_item_owner_role       Varchar2(320);

BEGIN
	/* Find User's User Name */
	   SELECT owner_role
	   INTO x_item_owner_role
	   FROM WF_ITEMS
	   WHERE item_type = itemtype
	   AND item_key  = itemkey ;

	   Return x_item_owner_role;
EXCEPTION
	   WHEN OTHERS THEN
		Return(NULL);

END GetWFItemOwnerRole ;

/* ************************************************************************
   This procedure gets the Change Notice and Org Id and puts them into the
   variables, X_change_notice and X_org_id.
   ************************************************************************ */

PROCEDURE Get_ECO_and_OrgId(itemtype		IN VARCHAR2,
		 	    itemkey		IN VARCHAR2,
			    actid		IN NUMBER,
			    funcmode		IN VARCHAR2,
			    result		IN OUT NOCOPY VARCHAR2) IS

	X_length1	NUMBER := 0; /* length of itemkey */
	X_hyphen1	NUMBER := 0; /* pos of separator bet org and rev */
	X_length2	NUMBER := 0; /* length of eco||org */
	X_hyphen2	NUMBER := 0; /* pos of separator bet eco and org */
	X_ecoorg	VARCHAR2(50);
	X_rev_id	NUMBER;
BEGIN
  --
  -- RUN mode - normal process execution
  --
	IF (funcmode = 'RUN') THEN
	     X_change_notice := Wf_Engine.GetItemAttrText(
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'CHANGE_NOTICE');
	     X_org_id        := Wf_Engine.GetItemAttrNumber(
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'ORG_ID');
	     X_rev_id        := Wf_Engine.GetItemAttrNumber(
				itemtype => itemtype,
				itemkey  => itemkey,
				aname    => 'REV_ID');
	     IF (X_change_notice is null or X_org_id is null or
		 X_rev_id is null) THEN
	          X_length1 := LENGTH(itemkey);
	          FOR j IN 0..(X_length1 - 1) LOOP

	               IF (SUBSTR(itemkey, X_length1 - j, 1) = '-') THEN
	                    X_hyphen1 := X_length1 - j;
	                    GOTO get_rev;
	               END IF;
	          END LOOP;
	          <<get_rev>>
	          IF (X_hyphen1 <> 0) THEN
		       X_rev_id := substr(itemkey, X_hyphen1 + 1);
	               X_ecoorg := substr(itemkey,1, X_hyphen1 - 1);
		       X_length2 := length(X_ecoorg);
	               FOR k IN 0..(X_length2 - 1) LOOP
	                  IF (SUBSTR(X_ecoorg, X_length2 - k, 1) = '-') THEN
	                       X_hyphen2 := X_length2 - k;
	                       GOTO get_org;
	                  END IF;
	               END LOOP;
	               <<get_org>>
		       IF (X_hyphen2 <> 0) THEN
			  X_org_id := substr(X_ecoorg, X_hyphen2 +1);
			  X_change_notice := substr(X_ecoorg, 1, X_hyphen2 -1);
		          Wf_Engine.SetItemAttrText(itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'CHANGE_NOTICE',
						 avalue   => X_change_notice);
		          Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'ORG_ID',
						 avalue   => X_org_id);
		          Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'REV_ID',
						 avalue   => X_rev_id);
		       ELSE
			    GOTO end_get;
		       END IF;
 	          ELSE
		       GOTO end_get;
	          END IF;
	     ELSE
		  null;
	     END IF;
             <<end_get>>
             result := 'COMPLETE:FOUND ECO';
             return;

	--
        -- CANCEL mode
        --
        -- This event point is called when the activity must
        -- be undone, for example when a process is reset to an earlier point
        -- due to a loop back.
	--
        ELSIF (funcmode = 'CANCEL') THEN
             result := 'COMPLETE';
             return;
        END IF;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Get_ECO_and_OrgId',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Get_ECO_and_OrgId;


/* ************************************************************************
   This procedure gets the ECO's attribute values and sets them in the Item
   Type Attributes.
   ************************************************************************ */

PROCEDURE Get_Eco_Attributes(itemtype		IN VARCHAR2,
		 	    itemkey		IN VARCHAR2,
			    actid		IN NUMBER,
			    funcmode		IN VARCHAR2,
			    result		IN OUT NOCOPY VARCHAR2) IS
	X_length		NUMBER := 0;
	X_colon			NUMBER;
	X_description		VARCHAR2(2000);
	X_eco_status		VARCHAR2(80);
	X_initiation_date	DATE;
	X_priority_code		VARCHAR2(10);
	X_reason_code		VARCHAR2(10);
	X_estimated_eng_cost	NUMBER;
	X_estimated_mfg_cost	NUMBER;
	X_attribute_category	VARCHAR2(30);
 	X_attribute1		VARCHAR2(150);
 	X_attribute2		VARCHAR2(150);
 	X_attribute3		VARCHAR2(150);
 	X_attribute4		VARCHAR2(150);
 	X_attribute5		VARCHAR2(150);
 	X_attribute6		VARCHAR2(150);
 	X_attribute7		VARCHAR2(150);
 	X_attribute8		VARCHAR2(150);
 	X_attribute9		VARCHAR2(150);
 	X_attribute10		VARCHAR2(150);
 	X_attribute11		VARCHAR2(150);
 	X_attribute12		VARCHAR2(150);
 	X_attribute13		VARCHAR2(150);
 	X_attribute14		VARCHAR2(150);
 	X_attribute15		VARCHAR2(150);
	X_approval_status	VARCHAR2(80);
	X_org_code		VARCHAR2(3);
        /* changing for UTF8 Column Expansion */
	X_org_name		VARCHAR2(240);
	X_requestor		VARCHAR2(240);
	X_change_type		VARCHAR2(80);
        /* changing for UTF8 Column Expansion */
	X_eco_dept_name		VARCHAR2(240);
	X_eco_dept_code		VARCHAR2(3);
	X_result		VARCHAR2(2000);
        l_requestor_name        VARCHAR2(60);

    -- added by ERES
    X_approval_list_name VARCHAR2(360);

    X_owner_value           VARCHAR2(320); /* Added to fix bug 5131658*/

	/* Added below two vars for fixing bug 5215778*/
	X_task_id 		NUMBER;
	X_project_id 		NUMBER;


BEGIN
  --
  -- RUN mode - normal process execution
  --changed query for perf issue bug 5099572
	IF (funcmode = 'RUN') THEN
	     Get_ECO_and_OrgId(itemtype	 => itemtype,
			  itemkey	 => itemkey,
			  actid		=> actid,
			  funcmode	=> funcmode,
			  result	=> X_result);

	/* Fix for bug 5215778- Added task_id, project_id to the select statement.
	   Fix for bug 5200489- In the where clause, replaced person_id with party_id in the join between eec and mev */

        SELECT  eec.description,
        (SELECT meaning FROM mfg_lookups WHERE eec.status_type = lookup_code
          AND lookup_type = 'ECG_ECN_STATUS'), /* eco status */
        eec.initiation_date,
        eec.priority_code,
        eec.reason_code,
        eec.estimated_eng_cost,
        eec.estimated_mfg_cost,
        eec.attribute_category,
        eec.attribute1,
        eec.attribute2,
        eec.attribute3,
        eec.attribute4,
        eec.attribute5,
        eec.attribute6,
        eec.attribute7,
        eec.attribute8,
        eec.attribute9,
        eec.attribute10,
        eec.attribute11,
        eec.attribute12,
        eec.attribute13,
        eec.attribute14,
        eec.attribute15,
        (SELECT meaning FROM mfg_lookups WHERE eec.approval_status_type =
 lookup_code
   AND lookup_type = 'ENG_ECN_APPROVAL_STATUS'), /*approval status*/
        (SELECT organization_code FROM mtl_parameters WHERE
 organization_id=eec.organization_id),
        (SELECT NAME FROM hr_all_organization_units WHERE
 organization_id=eec.organization_id),
        mev.full_name,
        ecot.type_name,
        (SELECT NAME FROM hr_all_organization_units WHERE
 organization_id=eec.responsible_organization_id),
        (SELECT organization_code FROM mtl_parameters WHERE
 organization_id=eec.responsible_organization_id),
     eec.task_id,
     eec.project_id
   INTO X_description,
	X_eco_status,
	X_initiation_date,
	X_priority_code,
	X_reason_code,
	X_estimated_eng_cost,
	X_estimated_mfg_cost,
	X_attribute_category,
	X_attribute1,
	X_attribute2,
	X_attribute3,
	X_attribute4,
	X_attribute5,
	X_attribute6,
	X_attribute7,
	X_attribute8,
	X_attribute9,
	X_attribute10,
	X_attribute11,
	X_attribute12,
	X_attribute13,
	X_attribute14,
	X_attribute15,
	X_approval_status,
	X_org_code,
	X_org_name,
	X_requestor,
	X_change_type,
	X_eco_dept_name,
        X_eco_dept_code,
        X_task_id,
        X_project_id
    FROM per_people_f mev,
         eng_change_order_types_vl ecot,
         eng_engineering_changes eec
        WHERE eec.organization_id = X_org_id
          AND eec.change_notice = X_change_notice
          AND eec.requestor_id = mev.party_id(+)--mev.person_id(+) -- Bug 4644000
          AND eec.change_order_type_id = ecot.change_order_type_id
          AND rownum = 1;

        -- ERES Begin
        -- added by ERES to get APPROVAL_LIST_NAME

		/*
		OLD CODE, removed for performance bug 3666795
        SELECT r.name
        INTO X_approval_list_name
        FROM  wf_roles r, eng_engineering_changes eec,  eng_ecn_approval_lists al
        WHERE eec.approval_list_id = al.approval_list_id
        AND  eec.organization_id = X_org_id
	    AND eec.change_notice = X_change_notice
        AND al.approval_list_name =  r.display_name ;

		*/
        -- Bug 4260372 : Added exception handling - If the approval list id is null
        Begin
		/* new code - bug 3666795 */
		select r.name
  		INTO X_approval_list_name
  		from wf_local_roles r
  		where r.display_name in (SELECT al.approval_list_name
   		FROM  eng_ecn_approval_lists al, eng_engineering_changes eec
   		WHERE eec.approval_list_id = al.approval_list_id
   		AND  eec.organization_id = X_org_id
   		AND eec.change_notice = X_change_notice) ;
        Exception
        When NO_DATA_FOUND then
                X_approval_list_name := null;
        end;

        -- Add aproval list name in attribute APPROVAL_LIST
	    Wf_Engine.SetItemAttrText(itemtype => itemtype,
 				       itemkey	=> itemkey,
				       aname	=> 'APPROVAL_LIST',
		    	  	   avalue	=> X_approval_list_name );
        -- ERES end


	     Wf_Engine.SetItemAttrText(itemtype => itemtype,
 				       itemkey	=> itemkey,
				       aname	=> 'CHANGE_NOTICE',
		    	  	       avalue	=> X_change_notice);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ECO_DESCRIPTION',
		    	  	       avalue	=> X_description);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ECO_STATUS',
		    	  	       avalue	=> X_eco_status);
	     Wf_Engine.SetItemAttrDate(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'INITIATION_DATE',
		    	  	       avalue	=> X_initiation_date);

  	     l_requestor_name := FND_GLOBAL.USER_NAME;
  	     Wf_Engine.SetItemOwner( itemtype => itemtype,
                          itemkey  => itemkey,
                          owner    => l_requestor_name );

	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'PRIORITY_CODE',
		    	  	       avalue	=> X_priority_code);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'REASON_CODE',
		    	  	       avalue	=> X_reason_code);
	     Wf_Engine.SetItemAttrNumber(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ESTIMATED_ENG_COST',
		    	  	       avalue	=> X_estimated_eng_cost);
	     Wf_Engine.SetItemAttrNumber(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ESTIMATED_MFG_COST',
		    	  	       avalue	=> X_estimated_mfg_cost);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE_CATEGORY',
		    	  	       avalue	=> X_attribute_category);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE1',
		    	  	       avalue	=> X_attribute1);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE2',
		    	  	       avalue	=> X_attribute2);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE3',
		    	  	       avalue	=> X_attribute3);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE4',
		    	  	       avalue	=> X_attribute4);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE5',
		    	  	       avalue	=> X_attribute5);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE6',
		    	  	       avalue	=> X_attribute6);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE7',
		    	  	       avalue	=> X_attribute7);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE8',
		    	  	       avalue	=> X_attribute8);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE9',
		    	  	       avalue	=> X_attribute9);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE10',
		    	  	       avalue	=> X_attribute10);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE11',
		    	  	       avalue	=> X_attribute11);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE12',
		    	  	       avalue	=> X_attribute12);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE13',
		    	  	       avalue	=> X_attribute13);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE14',
		    	  	       avalue	=> X_attribute14);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ATTRIBUTE15',
		    	  	       avalue	=> X_attribute15);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'APPROVAL_STATUS',
		    	  	       avalue	=> X_approval_status);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ORGANIZATION_CODE',
		    	  	       avalue	=> X_org_code);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ORGANIZATION_NAME',
		    	  	       avalue	=> X_org_name);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'FULL_NAME',
		    	  	       avalue	=> X_requestor);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'CHANGE_TYPE',
		    	  	       avalue	=> X_change_type);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ECO_DEPT_NAME',
		    	  	       avalue	=> X_eco_dept_name);
	     Wf_Engine.SetItemAttrText(itemtype	=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'ECO_DEPT_CODE',
		    	  	       avalue	=> X_eco_dept_code);

	     /* Fix for bug 5215778 - Added below code to assign values to Wf attributes TASK_ID, PROJECT_ID */
             Wf_Engine.SetItemAttrNumber(itemtype=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'TASK_ID',
		    	  	       avalue	=> X_task_id);
	     Wf_Engine.SetItemAttrNumber(itemtype=> itemtype,
				       itemkey	=> itemkey,
		    	 	       aname	=> 'PROJECT_ID',
		    	  	       avalue	=> X_project_id);

       /* Fix for bug 5131658- Get FND User who starts workflow*/
             X_owner_value := GetWFItemOwnerRole(itemtype,
                                                 itemkey);
             /* Set the value to WF_SIGN_REQUESTER */
             Wf_Engine.SetItemAttrText(itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => '#WF_SIGN_REQUESTER',
                                       avalue   => X_owner_value);
            /* End of fix for bug 5131658 */
             result := 'COMPLETE:ASSIGNED ATTRIBUTES';
             RETURN;
   --
   -- CANCEL mode
   --
   -- This event point is called when the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE';
      return;
   END IF;

   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   result := '';
   RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Get_Eco_Attributes',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Get_Eco_Attributes;


/* ************************************************************************
   This procedure updates an ECO's Approval Status to "Approved".
   If the user updates the status to "Approved" then the Approval Date gets
   updated to today's date.
   ************************************************************************ */

PROCEDURE Approve_Eco(	     itemtype        IN VARCHAR2,
                             itemkey         IN VARCHAR2,
                             actid           IN NUMBER,
                             funcmode        IN VARCHAR2,
                             result          IN OUT NOCOPY VARCHAR2)
IS
   X_eco_result    VARCHAR2(2000);
BEGIN
   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      Get_ECO_and_OrgId(itemtype => itemtype,
                        itemkey  => itemkey,
                        actid    => actid,
                        funcmode  => funcmode,
                        result   => X_eco_result);

     UPDATE eng_engineering_changes
        SET approval_status_type = 5,
            approval_date = sysdate
      WHERE organization_id = X_org_id
        AND change_notice = X_change_notice;

      UPDATE eng_revised_items
         SET status_type = 4		/* Set Rev Item Status = Scheduled */
	    ,status_code = 4	--Bug 3526627: Changes for 11.5.10, set the status_code also
       WHERE change_notice = X_change_notice
	 AND organization_id = X_org_id
	 AND status_type = 1;		/* Rev Item Status = Open */

--bug 2307416
      UPDATE eng_engineering_changes
        SET  status_type = 4
	    ,status_code = 4	--Bug 3526627: Changes for 11.5.10, set the status_code also
       WHERE change_notice = X_change_notice
         AND organization_id = X_org_id
         AND status_type = 1;

      commit;
      <<end_procedure>>
      result := 'COMPLETE:APPROVED';
      RETURN;

   --
   -- CANCEL mode
   --
   -- This event point is called when the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE';
      return;
   END IF;

   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   result := '';
   RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Approve_Eco',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Approve_Eco;

/* ************************************************************************
   This procedure updates an ECO's Approval Status to "Rejected".
   The Approval Date is set to null.
   ************************************************************************ */

PROCEDURE Reject_Eco(       itemtype        IN VARCHAR2,
                            itemkey         IN VARCHAR2,
                            actid           IN NUMBER,
                            funcmode        IN VARCHAR2,
                            result          IN OUT NOCOPY VARCHAR2)
IS
   X_eco_result    VARCHAR2(2000);
BEGIN
   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      Get_ECO_and_OrgId(itemtype => itemtype,
                        itemkey  => itemkey,
                        actid    => actid,
                        funcmode  => funcmode,
                        result   => X_eco_result);
     UPDATE eng_engineering_changes
        SET approval_status_type = 4,
            approval_date = null
      WHERE organization_id = X_org_id
        AND change_notice = X_change_notice;

     commit;
     <<end_procedure>>
      result := 'COMPLETE:REJECTED';
      RETURN;
   --
   -- CANCEL mode
   --
   -- This event point is called when the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE';
      RETURN;
   END IF;

   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   result := '';
   RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Reject_Eco',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END Reject_Eco;


/* ************************************************************************
   This procedure sets an ECO's Approval Status to 'Processing Error'.  This
   procedure is meant to be used in the Default Error Process.
   ************************************************************************ */

PROCEDURE Set_Eco_Approval_Error(itemtype	IN VARCHAR2,
		 	    itemkey		IN VARCHAR2,
			    actid		IN NUMBER,
			    funcmode		IN VARCHAR2,
			    result		IN OUT NOCOPY VARCHAR2) IS

	X_itemkey	VARCHAR2(80);
	X_itemtype	VARCHAR2(80);
	X_eco_result	VARCHAR2(2000);
BEGIN
   --
   -- RUN mode - normal process execution
   --
	IF (funcmode = 'RUN') THEN
           X_itemkey := Wf_Engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'ERROR_ITEM_KEY');
           X_itemtype := Wf_Engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'ERROR_ITEM_TYPE');
           Get_ECO_and_OrgId(itemtype => X_itemtype,
                        itemkey  => X_itemkey,
                        actid    => actid,
                        funcmode  => funcmode,
                        result   => X_eco_result);
           UPDATE eng_engineering_changes
              SET approval_status_type = 7,
               approval_date = ''
            WHERE organization_id = X_org_id
              AND change_notice = X_change_notice;

           result := 'COMPLETE:ERRORED';
      	   RETURN;
        --
        -- CANCEL mode
   	--
    	-- This event point is called when the activity must
   	-- be undone, for example when a process is reset to an earlier point
   	-- due to a loop back.
   	--
        ELSIF (funcmode = 'CANCEL') THEN
           result := 'COMPLETE';
           RETURN;
        END IF;

	<<end_procedure>>
        --
    	-- Other execution modes may be created in the future.  Your
   	-- activity will indicate that it does not implement a mode
   	-- by returning null
   	--
   	result := '';
   	RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Set_Eco_Approval_Error',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END Set_Eco_Approval_Error;


/* ************************************************************************
   This procedure updates the MRP Active flag to 'Yes' for all the revised
   items for a given ECO only if the revised item is at Status 'Open' or
   'Scheduled'.
   ************************************************************************ */

PROCEDURE Set_Mrp_Active(       itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result          IN OUT NOCOPY VARCHAR2)
IS
        X_eco_result    VARCHAR2(2000);
	l_duplicate     NUMBER := 0; --Changes from bug 7602108 which are merged in bug 9726856

	--changes for bug 9726856 begin
        l_rev_seq_id NUMBER;
        other_rev_seq_id NUMBER;
        l_bill_seq_id NUMBER;
        l_comp_item_id NUMBER;
        m_bill_seq_id NUMBER;
        m_comp_item_id NUMBER;
        found_duplicate NUMBER := 0;
        num_comp_other_rev_item NUMBER;
        num_comp_rev_item NUMBER;
        found_dup_rev_wo_comp NUMBER := 0;

        Cursor c_rev_items (c_change_notice VARCHAR2, c_org_id NUMBER)
        IS
         select revised_item_sequence_id from eng_revised_items
         where change_notice = c_change_notice
         and  organization_id = c_org_id;

       Cursor c_dup_rev_items (c_rev_item_seq_id NUMBER, c_change_notice VARCHAR2, c_org_id NUMBER)
       IS
       select eri1.revised_item_sequence_id
       from eng_revised_items eri, eng_revised_items eri1
       where eri.change_notice = c_change_notice
       AND eri.organization_id = c_org_id
       AND eri.revised_item_sequence_id = c_rev_item_seq_id
	     AND eri1.organization_id = c_org_id
	     AND eri1.revised_item_sequence_id <> eri.revised_item_sequence_id
       AND eri1.revised_item_id = eri.revised_item_id
       AND eri1.scheduled_date = eri.scheduled_date
       AND eri1.mrp_active = 1
       AND eri1.status_type <> 5;

      Cursor c_comp_on_rev_item (c_rev_item_seq_id NUMBER)
      IS
       Select bill_sequence_id, component_item_id from bom_components_b
       where revised_item_sequence_id = c_rev_item_seq_id;

      Cursor c_comp_on_rev_item_dup (c_rev_item_seq_id NUMBER)
      IS
       Select bill_sequence_id, component_item_id from bom_components_b
       where revised_item_sequence_id = c_rev_item_seq_id;
       --changes for bug 9726856 end

BEGIN
   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      Get_ECO_and_OrgId(itemtype => itemtype,
                        itemkey  => itemkey,
                        actid    => actid,
                        funcmode  => funcmode,
                        result   => X_eco_result);

      /* --Changes from bug 7602108 which are merged in bug 9726856  */
      SELECT COUNT(*)
	INTO l_duplicate
	FROM eng_revised_items eri,
	eng_revised_items eri1
	WHERE eri.change_notice            = X_change_notice
	AND eri.organization_id            = X_org_id
	AND eri1.organization_id           = X_org_id
	AND eri1.revised_item_sequence_id <> eri.revised_item_sequence_id
	AND eri1.revised_item_id           = eri.revised_item_id
	AND eri1.scheduled_date            = eri.scheduled_date
	AND eri1.mrp_active                = 1
	AND eri1.status_type              <> 5; -- Not Cancelled

      if (l_duplicate <> 0) then
      --changes for bug 9726856 begin
     --more tests to see if the revised components in duplicate revised items overlap as well
     open c_rev_items (X_change_notice, X_org_id);
     loop
      fetch c_rev_items into l_rev_seq_id;
      exit when c_rev_items%NOTFOUND;

      Select count(*) into num_comp_rev_item from bom_components_b
       where revised_item_sequence_id = l_rev_seq_id;

      open c_dup_rev_items (l_rev_seq_id, X_change_notice, X_org_id);
      loop
       fetch c_dup_rev_items into other_rev_seq_id;
       exit when c_dup_rev_items%NOTFOUND;

      --if neither revised_item has any components then we cannot allow
      --duplication of revised items since the quantity of revised item will
      -- be inflated due to multiple unimplemented ecos

      Select count(*) into num_comp_other_rev_item from bom_components_b
       where revised_item_sequence_id = other_rev_seq_id;

      --our revised item under consideration has no components
      --and there exists at least another revised item that has no components
      --either but their scheduled_date match
      --we cannot allow this and hence, throw error
      if ((num_comp_other_rev_item = 0 ) and (num_comp_rev_item = 0))then
       found_dup_rev_wo_comp := 1;
       exit;
      else
       --now that you have found the relevant revised items
       --get the components on the original revised item
       open  c_comp_on_rev_item (l_rev_seq_id);
       loop
        fetch  c_comp_on_rev_item into l_bill_seq_id, l_comp_item_id;
        exit when  c_comp_on_rev_item%NOTFOUND;

           open  c_comp_on_rev_item_dup (other_rev_seq_id);
           loop
           fetch  c_comp_on_rev_item_dup into m_bill_seq_id, m_comp_item_id;

           exit when  c_comp_on_rev_item_dup%NOTFOUND;
          --finding one duplicate is good enough, you can exit loop
           if l_bill_seq_id = m_bill_seq_id and l_comp_item_id = m_comp_item_id then
           found_duplicate := 1;
           exit;
           end if;
           end loop;
           close  c_comp_on_rev_item_dup;
           if found_duplicate = 1 then
            exit;
           end if;

       end loop;
       close  c_comp_on_rev_item;
      end if; --when there exists components on the revised items
       if found_duplicate = 1 or found_dup_rev_wo_comp = 1 then
       exit;
       end if;
     end loop;
     close c_dup_rev_items;
     if found_duplicate = 1 or found_dup_rev_wo_comp = 1 then
       exit;
    end if;
   end loop;
   close c_rev_items;
   --raise error only now
   if found_duplicate = 1 or found_dup_rev_wo_comp = 1 then
    result := 'ERROR:DUPLICATE';
	  RETURN;
   else
    UPDATE eng_revised_items
	  SET mrp_active = 1	       /* Set MRP Active=Yes */
    WHERE change_notice = X_change_notice
    AND organization_id = X_org_id
    AND status_type in (1, 4);    /* Rev Item Status=Open or Scheduled */
    commit;
   end if;
   --changes for bug 9726856 end
    --result := 'ERROR:DUPLICATE'; --error check outside is commented out
 	 --RETURN;
      else
       UPDATE eng_revised_items
	 SET mrp_active = 1	       /* Set MRP Active=Yes */
         WHERE change_notice = X_change_notice
	 AND organization_id = X_org_id
         AND status_type in (1, 4);    /* Rev Item Status=Open or Scheduled */

      commit;
      end if;

      <<end_procedure>>
      result := 'COMPLETE:MRP ACTIVE';
      RETURN;
   --
   -- CANCEL mode
   --
   -- This event point is called when the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   ELSIF (funcmode = 'CANCEL') THEN
           result := 'COMPLETE';
           RETURN;
   END IF;

   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   result := '';
   RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Set_Mrp_Active',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Set_Mrp_Active;


/* ************************************************************************
   This procedure updates the MRP Active flag to 'No' for all the revised
   items for a given ECO only if the revised item is at Status 'Open' or
   'Scheduled'.
   ************************************************************************ */

PROCEDURE Set_Mrp_Inactive(     itemtype        IN VARCHAR2,
                                itemkey         IN VARCHAR2,
                                actid           IN NUMBER,
                                funcmode        IN VARCHAR2,
                                result          IN OUT NOCOPY VARCHAR2)
IS
        X_eco_result    VARCHAR2(2000);
BEGIN
   --
   -- RUN mode - normal process execution
   --
   IF (funcmode = 'RUN') THEN
      Get_ECO_and_OrgId(itemtype => itemtype,
                        itemkey  => itemkey,
                        actid    => actid,
                        funcmode  => funcmode,
                        result   => X_eco_result);
      UPDATE eng_revised_items
	 SET mrp_active = 2	       /* Set MRP Active=Yes */
       WHERE change_notice = X_change_notice
	 AND organization_id = X_org_id
         AND status_type in (1, 4);    /* Rev Item Status=Open or Scheduled */

      commit;
      <<end_procedure>>

      result := 'COMPLETE:MRP INACTIVE';
      RETURN;
   --
   -- CANCEL mode
   --
   -- This event point is called when the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   ELSIF (funcmode = 'CANCEL') THEN
           result := 'COMPLETE';
           RETURN;
   END IF;

   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   result := '';
   RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Set_Mrp_Inactive',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
END Set_Mrp_Inactive;


/************************************************
This procedure will post ERES eRecord into the evidence store.
For both Approve and Rejected case.
*****************************************/

PROCEDURE UPDATE_EVIDENCE (p_itemtype   IN VARCHAR2,
      	                   p_itemkey    IN VARCHAR2,
      	                   p_actid      IN NUMBER,
                           p_funcmode   IN VARCHAR2,
                           p_resultout  OUT NOCOPY VARCHAR2
	 ) IS

l_requester varchar2(240);
l_Event_key NUMBER;
l_Event_name varchar2(240) := 'oracle.apps.eng.ecoApproval';
l_change_notice varchar2(240);
l_user_response    varchar2(30);

l_doc_id number;
l_error number;
l_error_msg varchar2(4000);
l_doc_params      qa_edr_standard.params_tbl_type;
l_sig_id number;
l_notification_result varchar2(1000);
l_ret_status	varchar2(30);
l_msg_count	number;
l_msg_data	varchar2(1000);
l_nid  number;

l_eRecord_id     NUMBER;
l_return_status  VARCHAR2(1);
l_trans_status   VARCHAR2(30);
l_msg_index      NUMBER;
l_send_ackn     boolean;
l_autonomous_commit   VARCHAR2(1);

l_eres_doc NUMBER;

l_parameters qa_edr_standard.Params_tbl_type;
l_sign_params  qa_edr_standard.Params_tbl_type;

BEGIN
IF P_FUNCMODE ='RUN' THEN

    l_requester := FND_GLOBAL.USER_NAME;

    l_Event_Key := wf_engine.GETITEMATTRNUMBER(itemtype => p_itemtype,
                                               itemkey => p_itemkey,
                                               aname =>  'CHANGE_ID');

    l_eres_doc := wf_engine.GETITEMATTRNUMBER(itemtype => p_itemtype,
                                               itemkey => p_itemkey,
                                               aname =>  'OPEN_ERES_DOC');

    l_change_notice := wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                 itemkey => p_itemkey,
                                                 aname =>  'CHANGE_NOTICE');

  IF l_eres_doc = 0
  then

  -- This is only done once, flag l_eres_doc is used to control this
  -- One eRecord is generated per approval workflow notification, therefor
  -- we call open_Documentjust the once

 /* Getting Notification Id  */
    SELECT NOTIFICATION_ID
    INTO l_nid
    FROM WF_ITEM_ACTIVITY_STATUSES
    WHERE ITEM_KEY =  p_itemkey
    AND ITEM_TYPE = p_itemtype
    AND NOTIFICATION_ID IS NOT NULL;


   /***** opendocument ******/

    --
    -- Bug 16063500
    -- The ECO Approval event should use the document format text/plain
    -- As otherwise the E-Record cannot be printed.
    --
    qa_edr_standard.open_Document (
         p_api_version      => 1.0,
         p_init_msg_list    => 'T',
         p_commit		    => 'FALSE',
         x_return_status    => l_return_status,
         x_msg_count        => l_msg_count,
         x_msg_data         => l_msg_data,
  	     P_PSIG_XML    		    => NULL,
    	 P_PSIG_DOCUMENT  	    =>  NULL,
         P_PSIG_DOCUMENTFORMAT  =>  WF_NOTIFICATION.doc_text,
         P_PSIG_REQUESTER	    => l_requester,
         P_PSIG_SOURCE    	    => NULL,
         P_EVENT_NAME  		    => l_Event_name,
         P_EVENT_KEY  		    => l_Event_Key,
         p_wf_notif_id          =>  l_nid,
         X_DOCUMENT_ID          => l_doc_id);


    /* Post document parameters      */

    l_parameters(1).param_name:='PSIG_USER_KEY_LABEL';
    FND_MESSAGE.SET_NAME('ENG','ENG_ECO_APPROVAL');
    l_parameters(1).param_value:=FND_MESSAGE.GET;
    l_parameters(1).param_displayname:=NULL;

    l_parameters(2).param_name:='PSIG_USER_KEY_VALUE';
    l_parameters(2).param_value:= l_change_notice;
    l_parameters(2).param_displayname:=NULL;

    /********  postDocumentParameter  ************/
     qa_edr_standard.Post_DocumentParameters  (
         p_api_version          => 1.0,
         p_init_msg_list        => 'T',
         p_commit		        => 'FALSE',
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         p_document_id          => l_doc_id,
         p_doc_parameters_tbl   => l_parameters);

    -- SET DOC ID
   	Wf_Engine.SetItemAttrNumber(itemtype	=> p_itemtype,
				                itemkey	=> p_itemkey,
		    	 	            aname	=> 'DOC_ID',
		    	  	             avalue	=> l_doc_id);
    end if;
    -- the rest below will be called many times, per # of signers

	Wf_Engine.SetItemAttrNumber(itemtype	=> p_itemtype,
				                itemkey	=> p_itemkey,
		    	 	            aname	=> 'OPEN_ERES_DOC',
		    	  	             avalue	=> 1);

    l_doc_id := wf_engine.GETITEMATTRNUMBER(itemtype => p_itemtype,
                                            itemkey => p_itemkey,
                                            aname =>  'DOC_ID');


    --  get the result of the notification i.e approve/rejected
    l_notification_result := wf_engine.GETITEMATTRTEXT(itemtype => p_itemtype,
                                                       itemkey => p_itemkey,
                                                       aname =>  'RESULT');


    /* Post Signature Parameters */

    -- Singning Reason
    l_sign_params(1).param_name:= 'REASON_CODE';
    l_sign_params(1).param_value:= wf_engine.getitemattrtext(p_itemtype,p_itemkey,'SIG_REASON');
    l_sign_params(1).param_displayname:= 'Signing Reason';

    -- Signer comments
    l_sign_params(2).param_name:='SIGNERS_COMMENT';
    l_sign_params(2).param_value:= wf_engine.getitemattrtext(p_itemtype,p_itemkey,'SIGNERS_COMMENTS');
    l_sign_params(2).param_displayname:='Signer Comments';


    -- Signature Type
    l_sign_params(3).param_name:='WF_SIGNER_TYPE';
    l_sign_params(3).param_value:=  wf_engine.getitemattrtext(p_itemtype,p_itemkey,'WF_SIGNER_TYPE');
    l_sign_params(3).param_displayname:='Signature Type ';

    IF l_notification_result ='Y'
    THEN
      l_user_response := 'Approved';
    ELSE
      l_user_response := 'Rejected';
    END IF;

    qa_edr_standard.Request_Signature  (
         p_api_version          => 1.0,
         p_init_msg_list        => 'T',
         p_commit		        => 'FALSE',
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         P_DOCUMENT_ID          => l_doc_id,
	     P_USER_NAME            => l_requester,
         P_ORIGINAL_RECIPIENT  	=> NULL,
         P_OVERRIDING_COMMENT 	=> NULL,
         x_signature_id         => l_sig_id
            );

      qa_edr_standard.Post_Signature  (
         p_api_version          => 1.0,
         p_init_msg_list        => 'T',
         p_commit		        => 'FALSE',
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         P_DOCUMENT_ID          => l_doc_id,
	     p_evidenceStore_id     => '1',
	     P_USER_NAME            => l_requester,
	     P_USER_RESPONSE         =>      l_user_response,
         P_ORIGINAL_RECIPIENT  	=> NULL,
         P_OVERRIDING_COMMENT 	=> NULL,
         x_signature_id          => l_sig_id
           );

      qa_edr_standard.Post_SignatureParameters    (
         p_api_version          => 1.0,
         p_init_msg_list        => 'T',
         p_commit		        => 'FALSE',
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         p_signature_id         => l_sig_id,
         p_sig_parameters_tbl	=> l_sign_params
          );

END IF;

  p_resultout := 'COMPLETE:UPDATE_EVIDENCE';
EXCEPTION
 WHEN OTHERS THEN
      WF_CORE.CONTEXT ('ENG_WORKFLOW_API_PKG','UPDATE_EVIDENCE',
                        p_itemtype,p_itemkey,SQLERRM);
      raise;

END UPDATE_EVIDENCE;


/* ************************************************************************
    This procedure gets the ERES attribute values for the ERES process,
    and sets them in the Item  Type Attributes.
   ************************************************************************ */

PROCEDURE Get_ERES_Attributes(itemtype		IN VARCHAR2,
		 	    itemkey		IN VARCHAR2,
			    actid		IN NUMBER,
			    funcmode		IN VARCHAR2,
			    result		IN OUT NOCOPY VARCHAR2) IS

    X_change_id        NUMBER;
    l_requester_name   VARCHAR2(60);
    i_param_list       wf_parameter_list_t;
    p_xmldoc		   clob;

    l_psig_event      WF_EVENT_T;
    l_event_name varchar2(240);
    l_event_key varchar2(240);


BEGIN
  --
  -- RUN mode - normal process execution
  --
	IF (funcmode = 'RUN') THEN

          -- get Event Key
    	  SELECT
             eec.change_id
	      INTO
            X_change_id
	      FROM eng_engineering_changes eec
	      WHERE eec.organization_id = X_org_id
	      AND eec.change_notice = X_change_notice;

         l_requester_name := FND_GLOBAL.USER_NAME;

		 wf_engine.setitemattrtext(itemtype => itemtype,
                  itemkey => itemkey,
                  aname => '#WF_SIGN_REQUESTER',
                 avalue => l_requester_name );

	     Wf_Engine.SetItemAttrNumber(itemtype	=> itemtype,
				                     itemkey	=> itemkey,
		    	 	                 aname	=> 'CHANGE_ID',
		    	  	                 avalue	=> X_change_id);

         -- Attachments hookup calls
         wf_engine.setitemattrtext(itemtype => itemtype,
                  itemkey => itemkey,
                  aname => '#ATTACHMENTS',
  avalue => 'FND:entity=ENG_ENGINEERING_CHANGES'||'&'||'pk1name=CHANGE_ID'||'&'||'pk1value='||X_change_id);


         /* Generate XML form business event*/

         i_param_list := wf_parameter_list_t();

         wf_event.addParameterToList(p_name          => 'ECX_MAP_CODE',
                                     p_value         => 'oracle.apps.eng.ecoGeneric',
                                     p_parameterlist =>  i_param_list);

         wf_event.addParameterToList(p_name          => 'ECX_DEBUG_LEVEL',
                                     p_value         => 5,
                                     p_parameterlist =>  i_param_list);

         wf_event.AddParameterToList('ECX_DOCUMENT_ID', X_change_id,i_param_list);

         p_xmldoc	:=  ecx_standard.GENERATE(p_event_name	=> 'oracle.apps.eng.ecoApproval',
			   						 p_event_key	    => X_change_id,
        							 p_parameter_list 	=> i_param_list
									 )  ;

          /* Generate Event Payload */

           l_psig_event := wf_engine.getItemAttrEvent(itemtype, itemkey, '#PSIG_EVENT');

           l_psig_event.setEventName('oracle.apps.eng.ecoApproval');
           l_psig_event.setEventKey(X_change_id);
           l_psig_event.setEventData(p_xmldoc);

           wf_engine.setItemAttrEvent(itemtype, itemkey,'#PSIG_EVENT',l_psig_event);

		   /* get the From attributes */

             wf_event.addParameterToList(p_name          => '#FROM_ROLE',
                                        p_value         => l_requester_name,
                                        p_parameterlist =>  i_param_list);


             result := 'COMPLETE:ASSIGNED ERES ATTRIBUTES';
             RETURN;
   --
   -- CANCEL mode
   --
   -- This event point is called when the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE';
      return;
   END IF;

   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   result := '';
   RETURN;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('ECO_APP', 'Get_ERES_Attributes',
                    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

END Get_ERES_Attributes;

-- VoteForResultType
--     Standard Voting Function
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The process activity(instance id).
--   funcmode  - Run/Cancel
-- OUT
--   result    -
--
-- USED BY ACTIVITIES
--
--   WFSTD.VoteForResultType
--
-- ACTIVITY ATTRIBUTES REFERENCED
--      VOTING_OPTION
--          - WAIT_FOR_ALL_VOTES  - Evaluate voting after all votes are cast
--                                - or a Timeout condition closes the voting
--                                - polls.  When a Timeout occurs the
--                                - voting percentages are calculated as a
--                                - percentage ofvotes cast.
--
--          - REQUIRE_ALL_VOTES   - Evaluate voting after all votes are cast.
--                                - If a Timeout occurs and all votes have not
--                                - been cast then the standard timeout
--                                - transition is taken.  Votes are calculated
--                                - as a percenatage of users notified to vote.
--
--          - TALLY_ON_EVERY_VOTE - Evaluate voting after every vote or a
--                                - Timeout condition closes the voting polls.
--                                - After every vote voting percentages are
--                                - calculated as a percentage of user notified
--                                - to vote.  After a timeout voting
--                                - percentages are calculated as a percentage
--                                - of votes cast.
--
--      "One attribute for each of the activities result type codes"
--
--          - The standard Activity VOTEFORRESULTTYPE has the WFSTD_YES_NO
--          - result type assigned.
--          - Thefore activity has two activity attributes.
--
--                  Y       - Percenatage required for Yes transition
--                  N       - Percentage required for No transition
--
procedure VoteForResultType(    itemtype   in varchar2,
                                itemkey    in varchar2,
                                actid      in number,
                                funcmode   in varchar2,
                                resultout  in out nocopy varchar2)
is
  -- Select all lookup codes for an activities result type
  cursor result_codes is
  select  wfl.lookup_code result_code
  from    wf_lookups wfl,
          wf_activities wfa,
          wf_process_activities wfpa,
          wf_items wfi  where   wfl.lookup_type         = wfa.result_type
  and     wfa.name                = wfpa.activity_name
  and     wfi.begin_date          >= wfa.begin_date
  and     wfi.begin_date          < nvl(wfa.end_date,wfi.begin_date+1)
  and     wfpa.activity_item_type = wfa.item_type
  and     wfpa.instance_id        = actid
  and     wfi.item_key            = itemkey
  and     wfi.item_type           = itemtype;

  l_code_count    pls_integer;
  l_group_id      pls_integer;
  l_user          varchar2(320);
  l_voting_option varchar2(30);
  l_per_of_total  number;
  l_per_of_vote   number;
  l_per_code      number;
  per_success     number;
  max_default     pls_integer := 0;
  default_result  varchar2(30) := '';
  result          varchar2(30) := '';
  wf_invalid_command exception;

  l_resultout VARCHAR2(2000);
  l_response_read varchar2(2);
 begin

	--
	-- Added read_response check to fix bug 3610452
	-- The attribute stores user's response of "I have read the e-record".
	-- if the answer is No, then raise application error
	--
    IF (funcmode = 'RESPOND') THEN
		l_response_read := wf_notification.getattrtext(wf_engine.context_nid, 'READ_RESPONSE');
		IF (l_response_read = 'N') THEN
				WF_CORE.CONTEXT('ENG_WORKFLOW_API_PKG', 'VoteForResultType',itemtype, itemkey,
                                                 FND_MESSAGE.GET_STRING('EDR','EDR_EREC_NOT_REVIEWED_ERR'));
				raise_application_error(-20002,FND_MESSAGE.GET_STRING('EDR','EDR_EREC_NOT_REVIEWED_ERR'));
		END IF;
    END IF;


   /* Call ERES api to start the eRecord generation process */
   UPDATE_EVIDENCE  (p_itemtype        =>itemtype,
                     p_itemkey         =>itemkey,
                     p_actid           =>actid,
                     p_funcmode        => funcmode,
                     p_resultout          => l_resultout);



  -- Do nothing unless in RUN or TIMEOUT modes
  if  (funcmode <> wf_engine.eng_run)
  and (funcmode <> wf_engine.eng_timeout) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  -- SYNCHMODE: Not allowed
  if (itemkey = wf_engine.eng_synch) then
    Wf_Core.Token('OPERATION', 'Wf_Standard.VotForResultType');
    Wf_Core.Raise('WFENG_SYNCH_DISABLED');
  end if;

  -- Get Notifications group_id for activity
  Wf_Item_Activity_Status.Notification_Status(itemtype,itemkey,actid,
      l_group_id,l_user);
  l_voting_option := Wf_Engine.GetActivityAttrText(itemtype,itemkey,
                         actid,'VOTING_OPTION');
  if (l_voting_option not in ('REQUIRE_ALL_VOTES', 'WAIT_FOR_ALL_VOTES',
                               'TALLY_ON_EVERY_VOTE')) then
    raise wf_invalid_command;
  end if;

  -- If the mode is one of:
  --   a. REQUIRE_ALL_VOTES
  --   b. WAIT_FOR_ALL_VOTES and no timeout has occurred
  -- and there are still open notifications, then return WAITING to
  -- either continue voting (in run mode) or trigger timeout processing
  -- (in timeout mode).
  if ((l_voting_option = 'REQUIRE_ALL_VOTES') or
      ((funcmode = wf_engine.eng_run) and
       (l_voting_option = 'WAIT_FOR_ALL_VOTES'))) then
    if (wf_notification.OpenNotificationsExist(l_group_id)) then
      resultout := wf_engine.eng_waiting;
      return;
    end if;
  end if;

  -- If here, then the mode is one of:
  --   a. TALLY_ON_ALL_VOTES
  --   b. WAIT_FOR_ALL_VOTES and timeout has occurred
  --   c. WAIT_FOR_ALL_VOTES and all votes are cast
  --   d. REQUIRE_ALL_VOTES and all votes are cast
  -- Tally votes.
  for result_rec in result_codes loop
    -- Tally Vote Count for this result code
    Wf_Notification.VoteCount(l_group_id,result_rec.result_code,
        l_code_count,l_per_of_total,l_per_of_vote);

    -- If this is timeout mode, then use the percent of votes cast so far.
    -- If this is run mode, then use the percent of total votes possible.
    if (funcmode = wf_engine.eng_timeout) then
      l_per_code := l_per_of_vote;
    else
      l_per_code := l_per_of_total;
    end if;

    -- Get percent vote needed for this result to succeed
    per_success := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey,
                       actid,result_rec.result_code);

    if (per_success is null) then
      -- Null value means this is a default result.
      -- Save the default result with max code_count.
      if (l_code_count > max_default) then
        max_default := l_code_count;
        default_result := result_rec.result_code;
      elsif (l_code_count = max_default) then
        -- Tie for default result.
        default_result := wf_engine.eng_tie;
      end if;
    else
      -- If:
      --   a. % vote for this result > % needed for success OR
      --   b. % vote is 100% AND
      --   c. at least 1 vote for this result
      -- then this result succeeds.
      if (((l_per_code > per_success) or (l_per_code = 100)) and
          (l_code_count > 0))
      then
        if (result is null) then
          -- Save satisfied result.
          result := result_rec.result_code;
        else
          -- This is the second result to be satisfied.  Return a tie.
          resultout := wf_engine.eng_completed||':'||wf_engine.eng_tie;
          return;
        end if;
      end if;
    end if;
  end loop;

  if (result is not null) then

    -- Return the satisfied result code.
    resultout := wf_engine.eng_completed||':'||result;
  else
    -- If we get here no non-default results were satisfied.
    if (funcmode = wf_engine.eng_run and
        wf_notification.OpenNotificationsExist(l_group_id)) then
      -- Not timed out and still open notifications.
      -- Return waiting to continue voting.
      resultout := wf_engine.eng_waiting;
    elsif (default_result is not null) then
      -- Either timeout or all notifications closed
      -- Return default result if one found.
      resultout := wf_engine.eng_completed||':'||default_result;
    elsif (funcmode =  wf_engine.eng_timeout) then
      -- If Timeout has occured then return result Timeout so the Timeout
      -- transition will occur - BUG2885157
      resultout := wf_engine.eng_completed||':'||wf_engine.eng_timeout;
    else
      -- All notifications closed, and no default.
      -- Return nomatch


      resultout := wf_engine.eng_completed||':'||wf_engine.eng_nomatch;

    end if;
  end if;

  return;
exception
  when wf_invalid_command then
    Wf_Core.Context('Wf_Standard', 'VoteForResultType', itemtype,
                    itemkey, to_char(actid), funcmode);
    Wf_Core.Token('COMMAND', l_voting_option);
    Wf_Core.Raise('WFSQL_COMMAND');
  when others then
    Wf_Core.Context('Wf_Standard', 'VoteForResultType',itemtype,
                    itemkey, to_char(actid), funcmode);
    raise;
end VoteForResultType;

/* ************************************************************************
    This procedure will close the ERES document once the document is finished.
    i.e all singers viewed and signed the eRecord
    Also the document will be Acknowledgement with the corrected status

   ************************************************************************ */


PROCEDURE CLOSE_AND_ACK_ERES_DOC (p_itemtype   IN VARCHAR2,
      	                          p_itemkey    IN VARCHAR2,
      	                          p_actid      IN NUMBER,
                                  p_funcmode   IN VARCHAR2,
                                  p_resultout  OUT NOCOPY VARCHAR2
                                  ) IS

l_Event_key NUMBER;
l_Event_name varchar2(240) := 'oracle.apps.eng.ecoApproval';

l_doc_id number;
l_msg_count	number;
l_msg_data	varchar2(1000);


l_erecord_id     NUMBER;
l_return_status  VARCHAR2(1);
l_trans_status   VARCHAR2(30);
l_send_ackn     boolean;
l_autonomous_commit   VARCHAR2(1);


BEGIN
IF P_FUNCMODE ='RUN' THEN


      /***** ERES: closeDocument ******/

      l_doc_id := wf_engine.GETITEMATTRNUMBER(itemtype => p_itemtype,
                                              itemkey => p_itemkey,
                                              aname =>  'DOC_ID');
      l_Event_Key := wf_engine.GETITEMATTRNUMBER(itemtype => p_itemtype,
                                                 itemkey =>  p_itemkey,
                                                 aname =>  'CHANGE_ID');
      QA_EDR_STANDARD.Close_Document	 (
         p_api_version          => 1.0,
         p_init_msg_list        => 'T',
         p_commit		        => 'FALSE',
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         P_DOCUMENT_ID          => l_doc_id
       );
--       update edr_psig_documents set psig_xml=psig_document where document_id=l_doc_id;

      l_erecord_id := l_doc_id;
      IF l_erecord_id IS NOT NULL
      THEN
		  l_send_ackn := TRUE;
		  l_trans_status := 'SUCCESS';
          l_autonomous_commit  := 'F';
      ELSE
		  l_send_ackn := TRUE;
		  l_trans_status := 'ERROR';
          l_autonomous_commit  := 'T';
	  END IF;

      IF l_send_ackn = TRUE
      then
         QA_EDR_STANDARD.SEND_ACKN
                    (p_api_version      => 1.0
                    ,p_init_msg_list    => 'T'
                    ,x_return_status    => l_return_status
                    ,x_msg_count        => l_msg_count
                    ,x_msg_data         => l_msg_data
                    ,p_event_name       => l_Event_name
                    ,p_event_key        => l_Event_Key
                    ,p_erecord_id       => l_erecord_id
                    ,p_trans_status     => l_trans_status
                    ,p_ackn_by          => 'ECO APPROVAL WORKFLOW'
                    ,p_ackn_note        => 'WF Acknowledgement'
                    ,p_autonomous_commit=> l_autonomous_commit
                    );
       END IF;

       p_resultout := 'COMPLETE:Closed ERES Document and Acknowledged';
END IF;

EXCEPTION
 WHEN OTHERS THEN
      WF_CORE.CONTEXT ('ENG_WORKFLOW_API_PKG','CLOSE_AND_ACK_ERES_DOC',
                        p_itemtype,p_itemkey,SQLERRM);
      raise;

END CLOSE_AND_ACK_ERES_DOC;


END ENG_WORKFLOW_API_PKG;

/
