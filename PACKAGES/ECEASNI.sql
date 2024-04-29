--------------------------------------------------------
--  DDL for Package ECEASNI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECEASNI" AUTHID CURRENT_USER as
-- $Header: ECWASNIS.pls 120.2 2005/09/30 07:24:36 arsriniv ship $
procedure process_asni_docs
        (
        i_transaction_type      IN      varchar2,
        i_run_id                IN      number
        );

procedure process_asni_inbound
        (
        errbuf                  OUT NOCOPY     varchar2,
        retcode                 OUT NOCOPY    varchar2,
        i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_transaction_type	In	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
	i_source_charset	IN	varchar2
        );

procedure process_sbni_inbound
        (
        errbuf                  OUT NOCOPY    varchar2,
        retcode                 OUT NOCOPY    varchar2,
        i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number,
	i_source_charset	IN	varchar2
        );

end ECEASNI;

 

/
