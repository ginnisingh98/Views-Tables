--------------------------------------------------------
--  DDL for Package ECEINI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECEINI" AUTHID CURRENT_USER as
-- $Header: ECWINIS.pls 120.2 2005/09/30 07:34:08 arsriniv ship $

procedure process_invoice_inbound
        (
	errbuf          	OUT NOCOPY    varchar2,
        retcode         	OUT NOCOPY    varchar2,
        i_file_path     	IN      varchar2,
        i_file_name     	IN      varchar2,
        i_run_import    	IN      varchar2,
        i_batch_name    	IN      varchar2,
        i_hold_name     	IN      varchar2,
        i_hold_reason   	IN      varchar2,
        i_gl_date       	IN      varchar2,
        i_purge         	IN      varchar2,
	i_summarize_flag	IN	varchar2,
	i_transaction_type	In	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
	i_source_charset	IN	varchar2
        );

/* Bug 2598743 */
procedure get_group_id;

end eceini;

 

/
