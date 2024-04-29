--------------------------------------------------------
--  DDL for Package ISC_DEPOT_BACKLOG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_BACKLOG_ETL_PKG" AUTHID CURRENT_USER as
/* $Header: iscdepotetlbs.pls 120.1 2006/09/21 01:20:27 kreardon noship $ */

procedure initial_load
( errbuf    in out nocopy  varchar2
, retcode   in out nocopy  number
);

procedure incr_load
( errbuf  in out nocopy varchar2
, retcode in out nocopy number
);

function get_last_run_date
( p_fact_name in  varchar2
, x_run_date  out nocopy date
, x_message   out nocopy varchar2
)
return number;

function err_mesg
( p_mesg      in varchar2
, p_proc_name in varchar2 default null
, p_stmt_id   in number default -1
)
return varchar2;

function check_initial_load_setup
( x_global_start_date out nocopy date
, x_isc_schema        out nocopy varchar2
, x_message           out nocopy varchar2
)
return number;

end isc_depot_backlog_etl_pkg;

 

/
