--------------------------------------------------------
--  DDL for Package ISC_FS_TASK_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TASK_ETL_PKG" 
/* $Header: iscfstasketls.pls 120.0 2005/08/28 14:59:42 kreardon noship $ */
AUTHID CURRENT_USER as

g_object_name constant varchar2(30) := 'ISC_FS_TASK_FACT';

procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

end isc_fs_task_etl_pkg;

 

/
