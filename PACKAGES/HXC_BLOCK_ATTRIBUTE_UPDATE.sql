--------------------------------------------------------
--  DDL for Package HXC_BLOCK_ATTRIBUTE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_BLOCK_ATTRIBUTE_UPDATE" AUTHID CURRENT_USER AS
/* $Header: hxcbkatup.pkh 120.0 2005/05/29 05:27:37 appldev noship $ */

PROCEDURE replace_ids
            (p_blocks     in out nocopy hxc_block_table_type
            ,p_attributes in out nocopy hxc_attribute_table_type
	    ,p_duplicate_template in boolean
            );

PROCEDURE denormalize_time
           (p_blocks in out nocopy hxc_block_table_type
           ,p_mode   in            varchar2);

Procedure set_process_flags
           (p_blocks     in out nocopy hxc_block_table_type
           ,p_attributes in out nocopy hxc_attribute_table_type
           );

END hxc_block_attribute_update;

 

/
