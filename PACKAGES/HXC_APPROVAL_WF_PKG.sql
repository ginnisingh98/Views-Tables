--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcapprwf.pkh 120.3.12010000.2 2010/05/05 11:10:33 amakrish ship $ */
--
--
-- global PL/SQL records and tables
--
g_source_name     VARCHAR2(100) := 'OTL Timecard';
g_process_name    VARCHAR2(100) := 'OTL Deposit Process';
g_resource_type   VARCHAR2(100) := 'PERSON';
g_template_start  DATE          := to_date('01/01/1900','DD/MM/YYYY');
g_package         VARCHAR2(33) := 'HXC_APPROVAL_WF_PKG.'; -- Global package name

g_error_table     hxc_self_service_time_deposit.message_table;
g_error_count     NUMBER := 0;

g_time_building_blocks hxc_self_service_time_deposit.timecard_info;
g_time_attributes      hxc_self_service_time_deposit.building_block_attribute_info;
g_time_app_attributes  hxc_self_service_time_deposit.app_attributes_info;

--
--
-- This overloaded of start_approval_wf_process added by A.Rundell
-- 2003/01/03 for the second generation deposit wrapper.
-- (hxcapprwf.pkh 115.16)
--
PROCEDURE start_approval_wf_process
              (p_item_type      IN            varchar2
              ,p_item_key       IN            varchar2
              ,p_process_name   IN            varchar2
              ,p_tc_bb_id       IN            number
              ,p_tc_ovn         IN            number
              ,p_tc_resubmitted IN            varchar2
              ,p_bb_new         IN            varchar2
              );
--
PROCEDURE start_approval_wf_process
              (p_item_type               IN varchar2
              ,p_item_key                IN varchar2
              ,p_tc_bb_id                IN number
              ,p_tc_ovn                  IN number
              ,p_tc_resubmitted          IN varchar2
          ,p_error_table    OUT NOCOPY hxc_self_service_time_deposit.message_table
    ,p_time_building_blocks IN hxc_self_service_time_deposit.timecard_info
    ,p_time_attributes      IN hxc_self_service_time_deposit.building_block_attribute_info
              ,p_bb_new                  IN varchar2
              );
--
PROCEDURE create_appl_period_info
              (itemtype                  IN     varchar2
              ,itemkey                   IN     varchar2
              ,actid                     IN     number
              ,funcmode                  IN     varchar2
              ,result                    IN OUT NOCOPY varchar2
              );
--
PROCEDURE process_appl_periods(itemtype     IN varchar2,
                               itemkey      IN varchar2,
                               actid        IN number,
                               funcmode     IN varchar2,
                               result       IN OUT NOCOPY varchar2);

--
PROCEDURE is_appr_required
              (itemtype                  IN     varchar2
              ,itemkey                   IN     varchar2
              ,actid                     IN     number
              ,funcmode                  IN     varchar2
              ,result                    IN OUT NOCOPY varchar2
              );
--
PROCEDURE chk_appr_rules
              (itemtype                  IN     varchar2
              ,itemkey                   IN     varchar2
              ,actid                     IN     number
              ,funcmode                  IN     varchar2
              ,result                    IN OUT NOCOPY varchar2
              );
--
PROCEDURE find_approval_rule
              (itemtype                  IN     varchar2
              ,itemkey                   IN     varchar2
              ,actid                     IN     number
              ,funcmode                  IN     varchar2
              ,result                    IN OUT NOCOPY varchar2
              );
--
PROCEDURE execute_appr_rule
              (itemtype                  IN     varchar2
              ,itemkey                   IN     varchar2
              ,actid                     IN     number
              ,funcmode                  IN     varchar2
              ,result                    IN OUT NOCOPY varchar2
              );
--
PROCEDURE chk_approval_req
              (itemtype                  IN     varchar2
              ,itemkey                   IN     varchar2
              ,actid                     IN     number
              ,funcmode                  IN     varchar2
              ,result                    IN OUT NOCOPY varchar2
              );

--
PROCEDURE upd_apr_details
             (p_app_bb_id	         IN     number
             ,p_app_bb_ovn	         IN     number
             ,p_approver_id	         IN     number
             ,p_approved_time            IN     date
             ,p_approval_comment         IN     varchar2
             ,p_approval_status          IN     varchar2
             ,p_delegated_for            IN     varchar2
              );
--
FUNCTION get_override ( p_timecard_bb_id NUMBER
		,	p_timecard_ovn   NUMBER ) RETURN NUMBER;
--
FUNCTION code_chk (p_code IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE update_app_period(
  itemtype     IN varchar2,
  itemkey      IN varchar2,
  actid        IN number,
  funcmode     IN varchar2,
  result       IN OUT NOCOPY varchar2
);

PROCEDURE create_next_period(
  itemtype     IN varchar2,
  itemkey      IN varchar2,
  actid        IN number,
  funcmode     IN varchar2,
  result       IN OUT NOCOPY varchar2
);


Function find_mysterious_approver(
        p_item_type in wf_items.item_type%type
       ,p_item_key  in wf_item_activity_statuses.item_key%type
) return number;

--OIT Change
FUNCTION get_approval_style_id(p_period_start_date date,
                               p_period_end_date   date,
                               p_resource_id       number)
 RETURN NUMBER;

PROCEDURE is_different_time_category (itemtype     IN varchar2,
                           itemkey      IN varchar2,
                           actid        IN number,
                           funcmode     IN varchar2,
                           result       IN OUT NOCOPY varchar2);

FUNCTION item_attribute_exists
                (p_item_type in wf_items.item_type%type,
                 p_item_key  in wf_item_activity_statuses.item_key%type,
                 p_name      in wf_item_attribute_values.name%type)
   RETURN BOOLEAN;

--
end hxc_approval_wf_pkg;

/
