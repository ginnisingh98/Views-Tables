--------------------------------------------------------
--  DDL for Package HXC_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_SECURITY" AUTHID CURRENT_USER AS
/* $Header: hxcaddsec.pkh 120.2 2006/08/02 23:33:52 arundell noship $ */

  PROCEDURE add_security_attribute
    (p_blocks         in            hxc_block_table_type,
     p_attributes     in out nocopy hxc_attribute_table_type,
     p_timecard_props in            hxc_timecard_prop_table_type,
     p_messages       in out nocopy hxc_message_table_type
     );

END hxc_security;

 

/
