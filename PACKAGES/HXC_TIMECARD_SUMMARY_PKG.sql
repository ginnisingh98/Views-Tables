--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: hxctcsum.pkh 120.0 2005/05/29 05:01:24 appldev noship $ */

c_normal_mode    CONSTANT VARCHAR2(6) := 'NORMAL';
c_migration_mode CONSTANT VARCHAR2(9) := 'MIGRATION';

type detail is record
  (time_building_block_id  hxc_time_building_blocks.time_building_block_id%type
  ,time_building_block_ovn hxc_time_building_blocks.object_version_number%type
  ,creation_date           hxc_time_building_blocks.creation_date%type
  );

type details is table of detail index by binary_integer;

procedure get_recorded_hours
           (p_timecard_id  in            hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn in            hxc_time_building_blocks.object_version_number%type
           ,p_hours           out nocopy number
           ,p_details         out nocopy details
           );

procedure insert_summary_row(p_timecard_id           in hxc_time_building_blocks.time_building_block_id%type
                            ,p_mode                  in varchar2 default 'NORMAL'
                            ,p_attribute_category    in varchar2 default null
                            ,p_attribute1            in varchar2 default null
                            ,p_attribute2            in varchar2 default null
                            ,p_attribute3            in varchar2 default null
                            ,p_attribute4            in varchar2 default null
                            ,p_attribute5            in varchar2 default null
                            ,p_attribute6            in varchar2 default null
                            ,p_attribute7            in varchar2 default null
                            ,p_attribute8            in varchar2 default null
                            ,p_attribute9            in varchar2 default null
                            ,p_attribute10           in varchar2 default null
                            ,p_attribute11           in varchar2 default null
                            ,p_attribute12           in varchar2 default null
                            ,p_attribute13           in varchar2 default null
                            ,p_attribute14           in varchar2 default null
                            ,p_attribute15           in varchar2 default null
                            ,p_attribute16           in varchar2 default null
                            ,p_attribute17           in varchar2 default null
                            ,p_attribute18           in varchar2 default null
                            ,p_attribute19           in varchar2 default null
                            ,p_attribute20           in varchar2 default null
                            ,p_attribute21           in varchar2 default null
                            ,p_attribute22           in varchar2 default null
                            ,p_attribute23           in varchar2 default null
                            ,p_attribute24           in varchar2 default null
                            ,p_attribute25           in varchar2 default null
                            ,p_attribute26           in varchar2 default null
                            ,p_attribute27           in varchar2 default null
                            ,p_attribute28           in varchar2 default null
                            ,p_attribute29           in varchar2 default null
                            ,p_attribute30           in varchar2 default null
			    ,p_approval_item_type    in varchar2
			    ,p_approval_process_name in varchar2
			    ,p_approval_item_key     in varchar2
		   	    ,p_tk_audit_item_type    in varchar2
			    ,p_tk_audit_process_name in varchar2
			    ,p_tk_audit_item_key     in varchar2
			    );

procedure update_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
			    ,p_approval_item_type     in hxc_timecard_summary.approval_item_type%type
			    ,p_approval_process_name  in hxc_timecard_summary.approval_process_name%type
			    ,p_approval_item_key      in hxc_timecard_summary.approval_item_key%type
			);

procedure delete_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type);

procedure reject_timecard(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type);

Procedure approve_timecard(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type);

Procedure submit_timecard(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type);

end hxc_timecard_summary_pkg;

 

/
