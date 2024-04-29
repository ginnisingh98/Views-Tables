--------------------------------------------------------
--  DDL for Package ISC_MAINT_WO_CST_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_WO_CST_ETL_PKG" 
/* $Header: iscmaintwocstets.pls 120.0 2005/05/25 17:17:38 appldev noship $ */
AUTHID CURRENT_USER as

procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

end isc_maint_wo_cst_etl_pkg;

 

/
