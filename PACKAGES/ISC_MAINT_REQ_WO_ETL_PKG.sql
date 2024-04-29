--------------------------------------------------------
--  DDL for Package ISC_MAINT_REQ_WO_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_REQ_WO_ETL_PKG" 
/* $Header: iscmaintreqwoets.pls 120.0 2005/05/25 17:45:20 appldev noship $ */
AUTHID CURRENT_USER as

procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

end isc_maint_req_wo_etl_pkg;

 

/
