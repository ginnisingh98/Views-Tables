--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_WF_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_WF_HELPER" AUTHID CURRENT_USER as
/* $Header: hxcaprwfhelper.pkh 120.0.12010000.2 2008/08/05 12:00:40 ubhat ship $ */

 C_ACTION_CODE_ATTRIBUTE constant varchar2(25) := 'NOTIFICATION_ACTION_CODE';

 C_RECIPIENT_CODE_ATTRIBUTE constant varchar2(30) :='NOTIFICATION_RECIPIENT_CODE';

TYPE t_time_building_block_id	IS TABLE OF hxc_transaction_details.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
TYPE t_time_building_block_ovn IS TABLE OF hxc_transaction_details.time_building_block_ovn%TYPE INDEX BY BINARY_INTEGER;


procedure prepare_notification(
	 			itemtype     IN varchar2,
                                itemkey      IN varchar2,
                                actid        IN number,
                                funcmode     IN varchar2,
                                result       IN OUT NOCOPY varchar2);

Procedure set_notif_attribute_values
               (p_item_type            in wf_items.item_type%type,
                p_item_key             in wf_item_activity_statuses.item_key%type,
                p_notif_action_code    in wf_item_attribute_values.text_value%type,
                p_notif_recipient_code in wf_item_attribute_values.text_value%type);


Procedure get_notif_attribute_values
              (p_item_type            in            wf_items.item_type%type,
               p_item_key             in            wf_item_activity_statuses.item_key%type,
               p_app_bb_id            in            number,
               p_notif_action_code       out nocopy varchar2,
               p_notif_recipient_code    out nocopy varchar2,
               p_approval_comp_id        out nocopy number,
               p_can_notify              out nocopy boolean);

Function is_approver_supervisor
              (p_approver_resource_id in number,
               p_resource_id in number)
           Return Boolean;

Function  find_preparer_role(p_timecard_id IN hxc_time_building_blocks.time_building_block_id%TYPE
                        ,p_timecard_ovn IN hxc_time_building_blocks.object_version_number%TYPE )
return wf_local_roles.name%type;

Function item_attribute_value_exists
              (p_item_type in wf_items.item_type%type,
               p_item_key  in wf_item_activity_statuses.item_key%type,
               p_name      in wf_item_attribute_values.name%type)
               return boolean;

Function find_role_for_recipient
              (p_recipient_code in wf_item_attribute_values.text_value%type,
               p_timecard_id    in number,
               p_timecard_ovn   in number)
               Return wf_local_roles.name%type;

procedure cleanup(itemtype     IN varchar2,
                  itemkey      IN varchar2,
                  actid        IN number,
                  funcmode     IN varchar2,
                  result       IN OUT NOCOPY varchar2);

function  find_full_name_from_role(p_role_name in wf_local_roles.name%type,
				p_effective_date in date)
return varchar2;

end hxc_approval_wf_helper;

/
