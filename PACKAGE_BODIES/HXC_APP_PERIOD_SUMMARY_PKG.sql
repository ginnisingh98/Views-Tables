--------------------------------------------------------
--  DDL for Package Body HXC_APP_PERIOD_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_APP_PERIOD_SUMMARY_PKG" as
/* $Header: hxcapsum.pkb 120.1 2005/06/30 12:11:17 jdupont noship $ */

procedure insert_summary_row
            (p_application_period_id in hxc_app_period_summary.application_period_id%type
            ,p_application_period_ovn in hxc_app_period_summary.application_period_ovn%type
            ,p_approval_status        in hxc_app_period_summary.approval_status%type
            ,p_time_recipient_id      in hxc_app_period_summary.time_recipient_id%type
            ,p_time_category_id       in hxc_app_period_summary.time_category_id%type
            ,p_start_time             in hxc_app_period_summary.start_time%type
            ,p_stop_time              in hxc_app_period_summary.stop_time%type
            ,p_resource_id            in hxc_app_period_summary.resource_id%type
            ,p_recipient_sequence     in hxc_app_period_summary.recipient_sequence%type
            ,p_category_sequence      in hxc_app_period_summary.category_sequence%type
            ,p_creation_date          in hxc_app_period_summary.creation_date%type
            ,p_notification_status    in hxc_app_period_summary.notification_status%type
            ,p_approver_id            in hxc_app_period_summary.approver_id%type
            ,p_approval_comp_id       in hxc_app_period_summary.approval_comp_id%type
	    ,p_approval_item_type     in hxc_app_period_summary.approval_item_type%type
	    ,p_approval_process_name  in hxc_app_period_summary.approval_process_name%type
	    ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type
	    ,p_data_set_id            in hxc_app_period_summary.data_set_id%type
            ) is

Begin

  insert into hxc_app_period_summary
  (application_period_id
  ,application_period_ovn
  ,approval_status
  ,time_recipient_id
  ,time_category_id
  ,start_time
  ,stop_time
  ,resource_id
  ,recipient_sequence
  ,category_sequence
  ,creation_date
  ,notification_status
  ,approver_id
  ,approval_comp_id
  ,approval_item_type
  ,approval_process_name
  ,approval_item_key
  ,data_set_id
  )
  values
  (p_application_period_id
  ,p_application_period_ovn
  ,p_approval_status
  ,p_time_recipient_id
  ,p_time_category_id
  ,p_start_time
  ,p_stop_time
  ,p_resource_id
  ,p_recipient_sequence
  ,p_category_sequence
  ,p_creation_date
  ,p_notification_status
  ,p_approver_id
  ,p_approval_comp_id
  ,p_approval_item_type
  ,p_approval_process_name
  ,p_approval_item_key
  ,NULL--p_data_set_id
  );

End;

procedure insert_summary_row
            (p_app_period_id in hxc_time_building_blocks.time_building_block_id%type
	    ,p_approval_item_type     in hxc_app_period_summary.approval_item_type%type
	    ,p_approval_process_name  in hxc_app_period_summary.approval_process_name%type
	    ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type
) is

cursor c_app_period_info(p_id in hxc_time_building_blocks.time_building_block_id%type) is
  select tbb.time_building_block_id application_period_id
        ,tbb.resource_id
        ,tbb.start_time
        ,tbb.stop_time
        ,tbb.approval_status
        ,ta1.attribute1 time_recipient_id
        ,ta1.attribute11 time_category_id
        ,decode(ta1.attribute9,'NA',0,to_number(ta1.attribute9)) recipient_sequence
        ,ta1.attribute12 category_sequence
        ,ta1.attribute13 approval_comp_id
        ,tbb.creation_date
        ,ta1.attribute4 notification_status
        ,decode(ta1.attribute3,'NA',0,to_number(ta1.attribute3)) approver_id
        ,tbb.object_version_number application_period_ovn
        ,tbb.data_set_id
    from hxc_time_building_blocks tbb, hxc_time_attribute_usages tau, hxc_time_attributes ta1
   where tbb.time_building_block_id = p_id
     and tbb.date_to = hr_general.end_of_time
     and tbb.scope = 'APPLICATION_PERIOD'
     and tau.time_building_block_id = tbb.time_building_block_id
     and tau.time_building_block_ovn = tbb.object_version_number
     and tau.time_attribute_id = ta1.time_attribute_id
     and ta1.attribute_category = 'APPROVAL'
     and tau.time_attribute_usage_id =
      (select max(time_attribute_usage_id) from hxc_time_attribute_usages tau2
       where tau2.time_building_block_id = tau.time_building_block_id
         and tau2.time_building_block_ovn = tau.time_building_block_ovn
      );

l_app_summary_row c_app_period_info%rowtype;

Begin

open c_app_period_info(p_app_period_id);
fetch c_app_period_info into l_app_summary_row;

if(c_app_period_info%found) then
  insert into hxc_app_period_summary
  (application_period_id
  ,application_period_ovn
  ,approval_status
  ,time_recipient_id
  ,time_category_id
  ,start_time
  ,stop_time
  ,resource_id
  ,recipient_sequence
  ,category_sequence
  ,creation_date
  ,notification_status
  ,approver_id
  ,approval_comp_id
  ,approval_item_type
  ,approval_process_name
  ,approval_item_key
  ,data_set_id
  )
  values
  (l_app_summary_row.application_period_id
  ,l_app_summary_row.application_period_ovn
  ,l_app_summary_row.approval_status
  ,l_app_summary_row.time_recipient_id
  ,l_app_summary_row.time_category_id
  ,l_app_summary_row.start_time
  ,l_app_summary_row.stop_time
  ,l_app_summary_row.resource_id
  ,l_app_summary_row.recipient_sequence
  ,l_app_summary_row.category_sequence
  ,l_app_summary_row.creation_date
  ,l_app_summary_row.notification_status
  ,l_app_summary_row.approver_id
  ,l_app_summary_row.approval_comp_id
  ,p_approval_item_type
  ,p_approval_process_name
  ,p_approval_item_key
  ,NULL--l_app_summary_row.data_set_id
  );
end if;

close c_app_period_info;

End insert_summary_row;

procedure update_summary_row(p_app_period_id in hxc_time_building_blocks.time_building_block_id%type
			    ,p_approval_item_type     in hxc_app_period_summary.approval_item_type%type
			    ,p_approval_process_name  in hxc_app_period_summary.approval_process_name%type
			    ,p_approval_item_key      in hxc_app_period_summary.approval_item_key%type
) is

Begin

null;

End update_summary_row;

procedure delete_summary_row(p_app_period_id in hxc_time_building_blocks.time_building_block_id%type) is

Begin

delete from hxc_app_period_summary where application_period_id = p_app_period_id;

Exception
  When others then
    FND_MESSAGE.set_name('HXC','HXC_NO_APP_PERIOD_ID');
    FND_MESSAGE.raise_error;

End delete_summary_row;

end hxc_app_period_summary_pkg;

/
