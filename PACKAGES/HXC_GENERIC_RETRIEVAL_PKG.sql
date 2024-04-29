--------------------------------------------------------
--  DDL for Package HXC_GENERIC_RETRIEVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_GENERIC_RETRIEVAL_PKG" AUTHID CURRENT_USER as
/* $Header: hxcgnret.pkh 120.3.12010000.5 2010/05/12 12:01:31 asrajago ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_generic_retrieval_pkg.';  -- Global package name


-- global PL/SQL records and tables

TYPE r_ret_criteria is RECORD (
      location_id         per_all_assignments_f.location_id%TYPE,
      payroll_id          per_all_assignments_f.payroll_id%TYPE,
      organization_id     per_all_assignments_f.organization_id%TYPE,
      gre_id              hr_soft_coding_keyflex.segment1%TYPE
);

g_ret_criteria hxc_generic_retrieval_pkg.r_ret_criteria;


--Elp changes sonarasi 14-Mar-2003
TYPE r_app_set_id_string is RECORD (
app_set_id_string VARCHAR2(200)
);

TYPE t_app_set_id_string IS TABLE OF r_app_set_id_string INDEX BY BINARY_INTEGER;

g_app_set_id_string t_app_set_id_string;
--Elp changes sonarasi over

TYPE r_field_mappings IS RECORD (
	bld_blk_info_type_id	hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
,	field_name		hxc_mapping_components.field_name%TYPE
,	attribute		hxc_mapping_components.segment%TYPE
,	context			hxc_bld_blk_info_types.bld_blk_info_type%TYPE
,	category		hxc_bld_blk_info_type_usages.building_block_category%TYPE );
--
TYPE t_field_mappings IS TABLE OF r_field_mappings INDEX BY BINARY_INTEGER;

g_field_mappings_table t_field_mappings;

-- building blocks

TYPE r_building_blocks IS RECORD (
	bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
,	type			hxc_time_building_blocks.type%TYPE
,	measure			hxc_time_building_blocks.measure%TYPE
,	start_time		hxc_time_building_blocks.start_time%TYPE
,	stop_time		hxc_time_building_blocks.stop_time%TYPE
,	parent_bb_id 		hxc_time_building_blocks.parent_building_block_id%TYPE
,	scope			hxc_time_building_blocks.scope%TYPE
,	resource_id		hxc_time_building_blocks.resource_id%TYPE
,	resource_type		hxc_time_building_blocks.resource_type%TYPE
,	comment_text		hxc_time_building_blocks.comment_text%TYPE
,	uom			hxc_time_building_blocks.unit_of_measure%TYPE
,	ovn			hxc_time_building_blocks.object_version_number%TYPE
,	changed			VARCHAR2(1)
,	deleted			VARCHAR2(1)
,	timecard_bb_id		hxc_time_building_blocks.time_building_block_id%TYPE
,	timecard_ovn		hxc_time_building_blocks.object_version_number%TYPE );

TYPE t_building_blocks IS TABLE OF r_building_blocks INDEX BY BINARY_INTEGER;

t_day_bld_blks		t_building_blocks;
t_detail_bld_blks	t_building_blocks;
t_old_detail_bld_blks 	t_building_blocks;
t_old_day_bld_blks 	t_building_blocks;

-- Bug 9494444
-- New type and variables for Recipient processing.
TYPE r_recipient_lines IS RECORD (
bb_id       NUMBER,
ovn         NUMBER,
rec_id      NUMBER,
batch_id    NUMBER);

TYPE t_recipient_lines IS TABLE OF r_recipient_lines INDEX BY BINARY_INTEGER;

t_detail_rec_lines t_recipient_lines;
t_old_detail_rec_lines t_recipient_lines;

TYPE r_timecard_block IS RECORD (
	start_time		hxc_time_building_blocks.start_time%TYPE
,	stop_time		hxc_time_building_blocks.stop_time%TYPE
,	comment_text		hxc_time_building_blocks.comment_text%TYPE );

TYPE t_timecard_blocks IS TABLE OF r_building_blocks INDEX BY BINARY_INTEGER;

t_time_bld_blks t_timecard_blocks;

-- attributes

TYPE r_time_attributes IS RECORD (
	bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
,	field_name		hxc_mapping_components.field_name%TYPE
,	value			hxc_time_attributes.attribute1%TYPE
,	context			hxc_bld_blk_info_types.bld_blk_info_type%TYPE
,	category		hxc_bld_blk_info_type_usages.building_block_category%TYPE );

TYPE t_time_attribute IS TABLE OF r_time_attributes INDEX BY BINARY_INTEGER;

t_attributes		t_time_attribute;
t_detail_attributes	t_time_attribute;
t_old_detail_attributes	t_time_attribute;

TYPE r_all_building_blocks IS RECORD (
	time_bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
,	time_ovn			hxc_time_building_blocks.object_version_number%TYPE
,	time_max_ovn			hxc_time_building_blocks.object_version_number%TYPE
,	time_start_time			hxc_time_building_blocks.start_time%TYPE
,	time_stop_time			hxc_time_building_blocks.stop_time%TYPE
,	time_comment_text		hxc_time_building_blocks.comment_text%TYPE
,	time_deleted                    hxc_time_building_blocks.comment_text%TYPE
,	day_bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
,	day_start_time			hxc_time_building_blocks.start_time%TYPE
,	day_stop_time			hxc_time_building_blocks.stop_time%TYPE
,	day_ovn				hxc_time_building_blocks.object_version_number%TYPE
,	day_max_ovn			hxc_time_building_blocks.object_version_number%TYPE
,	detail_bb_id			hxc_time_building_blocks.time_building_block_id%TYPE
,	detail_type			hxc_time_building_blocks.type%TYPE
,	detail_measure			hxc_time_building_blocks.measure%TYPE
,	detail_start_time		hxc_time_building_blocks.start_time%TYPE
,	detail_stop_time		hxc_time_building_blocks.stop_time%TYPE
,	detail_parent_bb_id 		hxc_time_building_blocks.parent_building_block_id%TYPE
,	detail_scope			hxc_time_building_blocks.scope%TYPE
,	detail_resource_id		hxc_time_building_blocks.resource_id%TYPE
,	detail_resource_type		hxc_time_building_blocks.resource_type%TYPE
,	detail_comment_text		hxc_time_building_blocks.comment_text%TYPE
,	detail_ovn			hxc_time_building_blocks.object_version_number%TYPE
,	detail_max_ovn			hxc_time_building_blocks.object_version_number%TYPE
,	detail_deleted			VARCHAR2(1)
,	detail_uom			hxc_time_building_blocks.unit_of_measure%TYPE
,	detail_date_from		hxc_time_building_blocks.date_from%TYPE
,	detail_date_to			hxc_time_building_blocks.date_to%TYPE
,	detail_approval_status		hxc_time_building_blocks.approval_status%TYPE
,	detail_approval_style_id	hxc_time_building_blocks.approval_style_id%TYPE
,	detail_ta_id			hxc_time_attributes.time_attribute_id%TYPE
,	detail_bld_blk_info_type_id	hxc_time_attributes.bld_blk_info_type_id%TYPE
,	detail_attribute1			hxc_time_attributes.attribute1%TYPE
,	detail_attribute2			hxc_time_attributes.attribute1%TYPE
,	detail_attribute3			hxc_time_attributes.attribute1%TYPE
,	detail_attribute4			hxc_time_attributes.attribute1%TYPE
,	detail_attribute5			hxc_time_attributes.attribute1%TYPE
,	detail_attribute6			hxc_time_attributes.attribute1%TYPE
,	detail_attribute7			hxc_time_attributes.attribute1%TYPE
,	detail_attribute8			hxc_time_attributes.attribute1%TYPE
,	detail_attribute9			hxc_time_attributes.attribute1%TYPE
,	detail_attribute10			hxc_time_attributes.attribute1%TYPE
,	detail_attribute11			hxc_time_attributes.attribute1%TYPE
,	detail_attribute12			hxc_time_attributes.attribute1%TYPE
,	detail_attribute13			hxc_time_attributes.attribute1%TYPE
,	detail_attribute14			hxc_time_attributes.attribute1%TYPE
,	detail_attribute15			hxc_time_attributes.attribute1%TYPE
,	detail_attribute16			hxc_time_attributes.attribute1%TYPE
,	detail_attribute17			hxc_time_attributes.attribute1%TYPE
,	detail_attribute18			hxc_time_attributes.attribute1%TYPE
,	detail_attribute19			hxc_time_attributes.attribute1%TYPE
,	detail_attribute20			hxc_time_attributes.attribute1%TYPE
,	detail_attribute21			hxc_time_attributes.attribute1%TYPE
,	detail_attribute22			hxc_time_attributes.attribute1%TYPE
,	detail_attribute23			hxc_time_attributes.attribute1%TYPE
,	detail_attribute24			hxc_time_attributes.attribute1%TYPE
,	detail_attribute25			hxc_time_attributes.attribute1%TYPE
,	detail_attribute26			hxc_time_attributes.attribute1%TYPE
,	detail_attribute27			hxc_time_attributes.attribute1%TYPE
,	detail_attribute28			hxc_time_attributes.attribute1%TYPE
,	detail_attribute29			hxc_time_attributes.attribute1%TYPE
,	detail_attribute30			hxc_time_attributes.attribute1%TYPE
,	detail_attribute_category		hxc_time_attributes.attribute_category%TYPE );

TYPE t_all_building_blocks IS TABLE OF r_all_building_blocks INDEX BY BINARY_INTEGER;

t_bb	t_all_building_blocks;

-- Transaction detail PL/SQL arrays

TYPE t_time_building_block_id	IS TABLE OF hxc_transaction_details.time_building_block_id%TYPE INDEX BY BINARY_INTEGER;
TYPE t_time_building_block_ovn IS TABLE OF hxc_transaction_details.time_building_block_ovn%TYPE INDEX BY BINARY_INTEGER;
TYPE t_transaction_id		IS TABLE OF hxc_transaction_details.transaction_id%TYPE INDEX BY BINARY_INTEGER;
TYPE t_status			IS TABLE OF hxc_transaction_details.status%TYPE INDEX BY BINARY_INTEGER;
TYPE t_exception_description	IS TABLE OF hxc_transaction_details.exception_description%TYPE INDEX BY BINARY_INTEGER;

t_tx_time_bb_id t_time_building_block_id;
t_tx_time_bb_ovn t_time_building_block_ovn;
t_tx_time_transaction_id t_transaction_id;
t_tx_time_status t_status;
t_tx_time_exception t_exception_description;

t_tx_day_bb_id t_time_building_block_id;
t_tx_day_parent_id t_time_building_block_id;
t_tx_day_bb_ovn t_time_building_block_ovn;
t_tx_day_transaction_id t_transaction_id;
t_tx_day_status t_status;
t_tx_day_exception t_exception_description;

t_tx_detail_bb_id t_time_building_block_id;
t_tx_detail_parent_id t_time_building_block_id;
t_tx_detail_bb_ovn t_time_building_block_ovn;
t_tx_detail_transaction_id t_transaction_id;
t_tx_detail_status t_status;
t_tx_detail_exception t_exception_description;

t_tx_error_bb_id t_time_building_block_id;
t_tx_error_bb_ovn t_time_building_block_ovn;
t_tx_error_transaction_id t_transaction_id;
t_tx_error_status t_status;
t_tx_error_exception t_exception_description;

g_transaction_id	hxc_transactions.transaction_id%TYPE;
g_retrieval_process_id	hxc_transactions.transaction_process_id%TYPE;
g_retrieval_tr_id	hxc_time_recipients.time_recipient_id%TYPE;

g_lock_type varchar2(35);


-- new globals to support iterative calling


G_IN_LOOP            BOOLEAN := FALSE;
G_LAST_CHUNK         BOOLEAN := FALSE;
G_NO_TIMECARDS         BOOLEAN := TRUE;
G_OVERALL_NO_TIMECARDS BOOLEAN := TRUE;
G_CHUNK_NUMBER       NUMBER := 0;
G_TRANS_CODE         hxc_transactions.transaction_code%TYPE;
G_TRANS_PREFIX       varchar2(11);

-- new globals for skipped records

TYPE r_detail_skipped IS RECORD (resource_id hxc_time_building_blocks.resource_id%TYPE,
			timecard_id hxc_time_building_blocks.time_building_block_id%TYPE,
			timecard_ovn hxc_time_building_blocks.object_version_number%TYPE,
			bb_id hxc_time_building_blocks.time_building_block_id%TYPE,
			ovn hxc_time_building_blocks.object_version_number%TYPE,
			description VARCHAR2(80));

TYPE t_detail_skipped IS TABLE OF r_detail_skipped INDEX BY BINARY_INTEGER;
g_detail_skipped t_detail_skipped;

--Bug 8888911
-- Added this datatype.
TYPE NUMBERTABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_res_list  NUMBERTABLE;
-- Bug 9458888
g_temp_tc_list NUMBERTABLE;

-- Bug 9494444
g_old_bb_ids   NUMBERTABLE;


TYPE VARCHARTAB IS TABLE OF VARCHAR2(150);



TYPE r_rtr_detail_blks IS RECORD (dummy VARCHAR2(1));
TYPE t_rtr_detail_blks IS TABLE OF r_rtr_detail_blks INDEX BY BINARY_INTEGER;
g_rtr_detail_blks t_rtr_detail_blks;

-- Bug 9458888
-- Added to process skipped details
      l_skipped_tc_id         VARCHARTAB;
      l_skipped_bb_id         VARCHARTAB;
      l_skipped_bb_ovn        VARCHARTAB;
      l_skipped_desc          VARCHARTAB;
      l_index                 NUMBER;


PROCEDURE execute_retrieval_process (
	p_process	in	hxc_retrieval_processes.name%TYPE
,	p_transaction_code in	VARCHAR2
,	p_start_date	in	DATE default null
,	p_end_date	in	DATE default null
,	p_incremental	in	VARCHAR2 default 'Y'
,	p_rerun_flag	in	VARCHAR2 default 'N'
,	p_where_clause	in	VARCHAR2
,	p_scope		in	VARCHAR2 default 'DAY'
,	p_clusive	in	VARCHAR2 default 'EX'
,       p_unique_params in      VARCHAR2 default null
,       p_since_date    in      VARCHAR2 default null
);

Procedure Update_Transaction_Status ( p_process			hxc_retrieval_processes.name%TYPE
				,     p_status			hxc_transactions.status%TYPE
				,     p_exception_description   hxc_transactions.exception_description%TYPE
				,     p_rollback BOOLEAN DEFAULT FALSE );

--Bug 8888911
--Added the new function to help easily write to
-- Conc process log and fnd_log_messages.
PROCEDURE put_log(p_text   IN VARCHAR2);

-- Bug 9458888
-- Autonomous procedure used to update the status of timecards

PROCEDURE update_rdb_status ( p_tc_list  NUMBERTABLE,
                              p_from_status   VARCHAR2,
                              p_to_status     VARCHAR2);

-- Bug 9701936
-- Added this data type and procedure definition.

TYPE NUMTABLE IS TABLE OF NUMBER;

PROCEDURE update_rdb_status ( p_tc_list  NUMTABLE,
                              p_from_status   VARCHAR2,
                              p_to_status     VARCHAR2);


end hxc_generic_retrieval_pkg;

/
