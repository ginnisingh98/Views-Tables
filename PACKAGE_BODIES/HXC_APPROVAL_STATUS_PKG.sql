--------------------------------------------------------
--  DDL for Package Body HXC_APPROVAL_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APPROVAL_STATUS_PKG" as
/* $Header: hxcapvst.pkb 120.6.12010000.2 2010/05/05 11:19:36 amakrish ship $ */
--
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- procedure
--   update_status
--
-- description
--   Wrapper procedure the updates the status of an APPLICATION PERIOD
--   building block. Performs a validation to check if the correct
--   Time Building Block is being updated. Calls the Workflow to transisition
--   to HXC_APP_SET_PERIODS node.
-- parameters
--	      p_approvals     -PL/SQL Type holding item_type,key,aprv_comments.
--            p_aprv_status   - new status of approval form row
--
--
PROCEDURE update_status
            (p_approvals   in APPROVAL_REC_TABLE_TYPE,
	     p_aprv_status in VARCHAR2) IS
--
--
l_index Number;
l_abs_enabled varchar2(1);
l_activity varchar2(100);

BEGIN

l_index := p_approvals.first;

WHILE p_approvals.exists(l_index)
  LOOP
  Begin
        -- initialize
        l_abs_enabled := 'N';
	--
	-- Set Approval Status
	--
	wf_engine.SetItemAttrText(itemtype  => p_approvals(l_index).item_type,
                          itemkey   => p_approvals(l_index).item_key,
                          aname     => 'APPROVAL_STATUS',
                          avalue    =>  p_aprv_status);
	-- Set Comments
	--
	wf_engine.SetItemAttrText(itemtype  => p_approvals(l_index).item_type,
                          itemkey   => p_approvals(l_index).item_key,
                          aname     => 'APR_REJ_REASON',
                          avalue    =>  p_approvals(l_index).aprv_comments);
	--
	-- hr_utility.trace('Completing activity');
	--

        l_abs_enabled := wf_engine.GetItemAttrText(itemtype => p_approvals(l_index).item_type,
                                                   itemkey  => p_approvals(l_index).item_key  ,
                                                   aname    => 'IS_ABS_ENABLED',
                                                   ignore_notfound => true);


	IF l_abs_enabled = 'Y' THEN
	  l_activity := 'APPROVAL_NOTIFICATION:TC_APR_NOTIFICATION_ABS';
	ELSE
	  l_activity := 'APPROVAL_NOTIFICATION:TC_APR_NOTIFICATION';
	END IF;

	-- Check that there is a NOTIFIED activity to complete.
	--
	   wf_engine.CompleteActivityInternalName
	       (itemtype    => p_approvals(l_index).item_type
	       ,itemkey     => p_approvals(l_index).item_key
	       ,activity    => l_activity
	       ,result      => p_aprv_status);       -- not using a result code

	--
	-- hr_utility.trace('Completed activity');
	--
	--
Exception
   When others then
   -- Probably errored with XXXX is not a notified activity for HXCEMP/XXXXX
   -- Try the other notification

   IF l_abs_enabled = 'Y' THEN
     l_activity := 'FIND_AND_NOTIFY_APPROVERS:TC_APR_NOTIFICATION_ABS';
   ELSE
     l_activity := 'FIND_AND_NOTIFY_APPROVERS:TC_APR_NOTIFICATION';
   END IF;

   wf_engine.CompleteActivityInternalName
       (itemtype    => p_approvals(l_index).item_type
       ,itemkey     => p_approvals(l_index).item_key
       ,activity    => l_activity
       ,result      => p_aprv_status);
END;
l_index := p_approvals.next(l_index);
END LOOP;

END update_status;
--
END hxc_approval_status_pkg;

/
