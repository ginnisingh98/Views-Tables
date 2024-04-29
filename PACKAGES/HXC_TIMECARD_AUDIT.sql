--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_AUDIT" AUTHID CURRENT_USER AS
/* $Header: hxctcaudit.pkh 120.0.12010000.3 2010/03/05 06:40:17 sabvenug ship $ */

-- Bug 8888801
-- New datatype.
TYPE VARCHARTABLE IS TABLE OF VARCHAR2(10) INDEX BY VARCHAR2(50);
g_valid_rec VARCHARTABLE;



Procedure audit_deposit
  (p_transaction_info  in out nocopy hxc_timecard.transaction_info
  ,p_messages          in out nocopy hxc_message_table_type
  );

Procedure maintain_latest_details
  (p_blocks           in hxc_block_table_type
  );

-- Bug 8888801
-- Added new data type to
-- track time recipients.
FUNCTION valid_time_recipient(p_recipient   IN VARCHAR2,
                              p_app_set_id  IN NUMBER)
RETURN BOOLEAN;

/* Added for 8888904 */
PROCEDURE maintain_rdb_snapshot(p_blocks     IN hxc_block_table_type,
                                p_attributes IN hxc_attribute_table_type);

g_valid_bld_blk VARCHARTABLE;


END hxc_timecard_audit;

/
