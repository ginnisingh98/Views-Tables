--------------------------------------------------------
--  DDL for Package ISC_MAINT_ASSET_DT_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_ASSET_DT_ETL_PKG" AUTHID CURRENT_USER as
/*$Header: iscmaintadtetls.pls 120.0 2005/05/25 17:39:24 appldev noship $ */
procedure initial_load
( errbuf out nocopy varchar2
 , retcode out nocopy number
);


procedure incremental_load
 ( errbuf out nocopy varchar2
 , retcode out nocopy number
 );


end isc_maint_asset_dt_etl_pkg;

 

/
