--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_MESSAGE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_MESSAGE_HELPER" AUTHID CURRENT_USER AS
/* $Header: hxctcdmsg.pkh 115.3 2003/06/02 17:21:02 tjain noship $ */


Procedure initializeErrors;

Procedure addErrorToCollection
           (p_messages IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
           ,p_message_name IN fnd_new_messages.message_name%type
           ,p_message_level IN VARCHAR2
           ,p_message_field in VARCHAR2
           ,p_message_tokens in VARCHAR2
           ,p_application_short_name in fnd_application.application_short_name%type
           ,p_time_building_block_id in hxc_time_building_blocks.time_building_block_id%type
           ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
           ,p_time_attribute_id in hxc_time_attributes.time_attribute_id%type
           ,p_time_attribute_ovn in hxc_time_attributes.object_version_number%type
           ,p_message_extent in VARCHAR2 DEFAULT null            --Bug#2873563
           );

PROCEDURE processErrors(p_messages IN OUT nocopy hxc_self_service_time_deposit.message_table);

Procedure processErrors(p_messages in out nocopy hxc_message_table_type);

Function noErrors return BOOLEAN;

Procedure prepareErrors;

Function prepareMessages return hxc_message_table_type;

Function getMessages return hxc_message_table_type;

END hxc_timecard_message_helper;

 

/
