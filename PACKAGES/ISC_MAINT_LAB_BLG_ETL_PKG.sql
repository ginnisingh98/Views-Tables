--------------------------------------------------------
--  DDL for Package ISC_MAINT_LAB_BLG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_LAB_BLG_ETL_PKG" AUTHID CURRENT_USER as
/*$Header: iscmaintlblgetls.pls 120.0 2005/05/25 17:18:04 appldev noship $ */
procedure load
( errbuf out nocopy varchar2
 , retcode out nocopy number
);
end isc_maint_lab_blg_etl_pkg;

 

/
