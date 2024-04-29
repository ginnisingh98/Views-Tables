--------------------------------------------------------
--  DDL for Package HXC_NOTIFICATION_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_NOTIFICATION_PROCESS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcnotifprocess.pkh 120.1.12010000.2 2010/01/13 12:33:48 amakrish ship $ */
PROCEDURE approved_by
     (p_itemtype in     varchar2,
      p_itemkey  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2);

PROCEDURE timeouts_enabled
     (p_itemtype in     varchar2,
      p_itemkey  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2) ;

PROCEDURE reset_for_next_timeout(p_itemtype in     varchar2,
      p_itemkey  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2);

PROCEDURE restart_workflow(p_itemtype in     varchar2,
      p_item_key  in     varchar2,
      p_actid    in     number,
      p_funcmode in     varchar2,
      p_result   in out nocopy varchar2);

PROCEDURE is_transfer(p_itemtype in     varchar2,
                      p_itemkey  in     varchar2,
                      p_actid    in     number,
                      p_funcmode in     varchar2,
                      p_result   in out nocopy varchar2);

-- Bug 8888588 (Notification subject when Absence is enabled)
PROCEDURE exclude_total_hours(p_itemtype in     varchar2,
                      	      p_itemkey  in     varchar2,
                              p_actid    in     number,
                      	      p_funcmode in     varchar2,
                              p_result   in out nocopy varchar2);

FUNCTION evaluate_abs_pref(p_resource_id IN  NUMBER,
			   p_eval_date   IN DATE)
RETURN VARCHAR2;

END hxc_notification_process_pkg;

/
