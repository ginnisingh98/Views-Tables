--------------------------------------------------------
--  DDL for Package HXC_FIND_NOTIFY_APRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_FIND_NOTIFY_APRS_PKG" AUTHID CURRENT_USER as
/* $Header: hxcafnawf.pkh 120.6.12010000.2 2009/06/15 13:57:14 amakrish ship $ */

  function get_description
    (p_application_period_id in hxc_app_period_summary.application_period_id%type)
   return varchar2;
  function get_description_tc
    (p_timecard_id  in hxc_timecard_summary.timecard_id%type,
     p_timecard_ovn in hxc_timecard_summary.timecard_ovn%type)
   return varchar2;
  function get_description_date
    (p_start_date  in date,
     p_end_date    in date,
     p_resource_id in number)
   return varchar2;

procedure find_apr_style(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure auto_approval(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure person_approval(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure hr_supervisor_approval(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure capture_approved_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure capture_rejected_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure capture_timeout_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure capture_apr_comment(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure capture_reject_comment(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure is_final_apr(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

-- Added for bug 8594271
procedure check_user_exists(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);


procedure formula_selects_mechanism(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure launch_wf_process(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure test_wf_result(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

procedure set_next_app_period(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);



procedure cancel_previous_notifications
  (p_app_bb_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
  ,p_app_bb_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
  );

-- Bug 3390666 ,3855544
function get_login(
   p_person_id in number,
   p_user_id IN NUMBER DEFAULT NULL)
return varchar2;

PROCEDURE cancel_previous_notifications(
  p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
);

PROCEDURE find_project_manager(
  p_itemtype in     varchar2,
  p_itemkey  in     varchar2,
  p_actid    in     number,
  p_funcmode in     varchar2,
  p_result   in out nocopy varchar2
);

function validate_person(
    p_person_id      in number,
    p_effective_date in date)
return boolean;

procedure cancel_notifications(
  p_app_bb_id IN NUMBER,
  p_archived  IN VARCHAR DEFAULT NULL);

-- Added as part of OIT

FUNCTION category_timecard_hrs (
		p_app_per_id	IN     NUMBER
  	    ,   p_time_category_name  IN VARCHAR2 )
RETURN NUMBER;

FUNCTION category_timecard_hrs (
		p_start_date	 IN    date,
		p_end_date       IN    date,
		p_resource_id    IN    NUMBER,
  	       p_time_category_name IN VARCHAR2 )
RETURN NUMBER;
function get_supervisor(
   		 p_person_id      in number,
    		 p_effective_date in date)
return number;

function get_name(
	    p_person_id      in number,
	    p_effective_date in DATE)
 return varchar2;

FUNCTION apply_round_rule(p_rounding_rule     in varchar2,
                          p_decimal_precision in varchar2,
		          p_value             in number)
                          return number;

end hxc_find_notify_aprs_pkg;

/
