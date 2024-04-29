--------------------------------------------------------
--  DDL for Package HXC_ARCHIVE_RESTORE_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ARCHIVE_RESTORE_DEBUG" AUTHID CURRENT_USER as
/* $Header: hxcarcresdbg.pkh 120.0 2005/09/10 03:44:03 psnellin noship $ */


procedure print_timecard_id(p_data_set_id in number,
			    p_start_date in date,
                            p_stop_date in date);

Procedure print_attributes_id(p_data_set_id in number);

procedure print_table_record(p_table_name varchar2,
			     p_data_set_id number,
			     p_first_column varchar2,
			     p_second_column varchar2) ;


END hxc_archive_restore_debug;

 

/
