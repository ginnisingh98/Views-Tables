--------------------------------------------------------
--  DDL for Package ECECATI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECECATI" AUTHID CURRENT_USER as
-- $Header: ECWCATIS.pls 120.2 2005/09/30 07:31:57 arsriniv ship $
procedure process_cati_docs
	(
	i_transaction_type	IN	varchar2,
	i_run_id		IN	number,
        o_po_batch_id           OUT NOCOPY    number
	);

/* Added a new parameter to the CATI transaction */

procedure process_cati_inbound
        (
	errbuf          	OUT NOCOPY    varchar2,
        retcode         	OUT NOCOPY    varchar2,
        i_file_path     	IN      varchar2,
        i_file_name     	IN      varchar2,
        i_run_import    	IN      varchar2,
        i_default_buyer         IN      varchar2,
        i_po_document_type      IN      varchar2,
        i_po_document_sub_type  IN      varchar2,
        i_po_create_item_flag   IN      varchar2,
        i_po_sourcing_rules     IN      varchar2,
        i_po_approval_status    IN      varchar2,
        i_po_release_method     In      varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
        i_source_charset        IN      varchar2
        );

/* Added a new parameter to the RRQI transaction */

procedure process_rrqi_inbound
        (
	errbuf          	OUT NOCOPY    varchar2,
        retcode         	OUT NOCOPY   varchar2,
        i_file_path     	IN      varchar2,
        i_file_name     	IN      varchar2,
        i_run_import    	IN      varchar2,
        i_default_buyer         IN      varchar2,
        i_po_document_type      IN      varchar2,
        i_po_document_sub_type  IN      varchar2,
        i_po_create_item_flag   IN      varchar2,
        i_po_sourcing_rules     IN      varchar2,
        i_po_approval_status    IN      varchar2,
        i_po_release_method     In      varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
        i_source_charset        IN      varchar2
        );

end ececati;

 

/
