--------------------------------------------------------
--  DDL for Package HXC_TIMEKEEPER_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMEKEEPER_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: hxctimekeeperwf.pkh 120.0 2005/05/29 06:27:05 appldev noship $ */

FUNCTION GET_ITEM_KEY RETURN NUMBER;

FUNCTION GET_NAME(
    p_person_id      in number,
    p_effective_date in DATE)
RETURN VARCHAR2;

PROCEDURE start_child_process
              (p_tc_item_type      IN        VARCHAR2
              ,p_tc_item_key       IN        VARCHAR2
              ,p_tc_process_name   IN        VARCHAR2
              ,p_tc_bb_id          IN        NUMBER
              ,p_tc_bb_ovn         IN        NUMBER
	      ,p_tc_start_time     IN        DATE
	      ,p_tc_stop_time      IN        DATE
	      ,p_tc_resource_id    IN	     NUMBER
	      ,p_tc_timekeeper_id  IN        NUMBER
	      ,p_tc_tk_nofity_type IN	     VARCHAR2
	      ,p_tc_tk_nofity_to   IN	     VARCHAR2
              );

PROCEDURE start_tk_wf_process
              (p_item_type      IN            varchar2
              ,p_item_key       IN            varchar2
              ,p_process_name   IN            varchar2
              ,p_tc_bb_id       IN            number
              ,p_tc_ovn         IN            number
	      ,p_tc_resource_id IN	      NUMBER
	      ,p_timekeeper_id  IN            NUMBER
	      ,p_tk_nofity_type IN	      VARCHAR2
	      ,p_tk_nofity_to   IN	      VARCHAR2);

PROCEDURE START_TK_NOTIFICATION (
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

PROCEDURE FIND_NTF_TO(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) ;

PROCEDURE PERSON_NOTIFY(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) ;

PROCEDURE SUPERVISOR_NOTIFY(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2) ;

PROCEDURE capture_approved_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

PROCEDURE capture_rejected_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

PROCEDURE update_tk_ntf_result(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

PROCEDURE cancel_previous_notifications
( p_tk_audit_item_type in     varchar2
 ,p_tk_audit_item_key in     varchar2
);

procedure capture_timeout_status(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2);

Function begin_audit_process
	  (p_timecard_id   in hxc_time_building_blocks.time_building_block_id%type
	  ,p_timecard_ovn  in hxc_time_building_blocks.object_version_number%type
	  ,p_resource_id   in hxc_time_building_blocks.resource_id%type
	  ,p_timekeeper_id in hxc_time_building_blocks.resource_id%type
	  ,p_tk_audit_enabled in VARCHAR2
	  ,p_tk_notify_to  in VARCHAR2
	  ,p_tk_notify_type in VARCHAR2
	  ,p_property_table               hxc_timecard_prop_table_type
           ) return VARCHAR2 ;

END hxc_timekeeper_wf_pkg;


 

/
