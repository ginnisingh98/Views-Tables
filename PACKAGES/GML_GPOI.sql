--------------------------------------------------------
--  DDL for Package GML_GPOI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_GPOI" AUTHID CURRENT_USER as
-- $Header: GMLWPOIS.pls 115.5 2002/11/08 07:07:58 gmangari ship $

procedure process_gpoi_inbound
        (
        errbuf                  OUT     NOCOPY  varchar2,
        retcode                 OUT     NOCOPY  varchar2,
        i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_run_import            IN      varchar2,
	i_transaction_type	IN	varchar2,
	i_map_id		IN	number,
	i_debug_mode		IN	number
        );

end GML_GPOI;

 

/
