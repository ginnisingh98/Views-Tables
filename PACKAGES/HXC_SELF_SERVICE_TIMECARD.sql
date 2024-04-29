--------------------------------------------------------
--  DDL for Package HXC_SELF_SERVICE_TIMECARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SELF_SERVICE_TIMECARD" AUTHID CURRENT_USER AS
/* $Header: hxctctprt.pkh 120.2.12010000.2 2008/10/17 15:05:37 bbayragi ship $ */


PROCEDURE fetch_blocks_and_attributes(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_timecard_id      IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_create_template  IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_lock_rowid       IN OUT NOCOPY ROWID
 ,p_timecard_action  in     VARCHAR2
 );

PROCEDURE fetch_blocks_and_attributes(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_timecard_id      IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_create_template  IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_lock_rowid       IN OUT NOCOPY ROWID
 ,p_timecard_action  in     VARCHAR2
 ,p_exclude_hours_template in VARCHAR2
 );

PROCEDURE fetch_blocks_and_attributes(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_timecard_id      IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_approval_status  IN     VARCHAR2
 ,p_create_template  IN     VARCHAR2
 ,p_block_array      IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array  IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 ,p_message_string      OUT NOCOPY VARCHAR2
 ,p_overwrite        IN     VARCHAR2
 ,p_review           IN     VARCHAR2
 ,p_lock_rowid       IN OUT NOCOPY ROWID
 ,p_timecard_action  in     VARCHAR2
 ,p_exclude_hours_template in VARCHAR2
 ,p_notif_id         in varchar2);


PROCEDURE fetch_appl_periods(
  p_resource_id      IN VARCHAR2
 ,p_resource_type    IN VARCHAR2
 ,p_timecard_id      IN VARCHAR2
 ,p_block_array     OUT NOCOPY HXC_BLOCK_TABLE_TYPE
 ,p_attribute_array OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
 ,p_message_string  OUT NOCOPY VARCHAR2
 );

PROCEDURE check_blocks_from_template(
  p_resource_id      IN     VARCHAR2
 ,p_resource_type    IN     VARCHAR2
 ,p_start_time       IN     VARCHAR2
 ,p_stop_time        IN     VARCHAR2
 ,p_template_code    IN     VARCHAR2
 ,p_messages         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
);

FUNCTION get_timecard_transferred_to(
  f_timecard_id HXC_TIMECARD_SUMMARY.TIMECARD_ID%TYPE
 ,f_timecard_ovn HXC_TIMECARD_SUMMARY.TIMECARD_OVN%TYPE) RETURN varchar2;


END hxc_self_service_timecard;

/
