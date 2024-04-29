--------------------------------------------------------
--  DDL for Package ISC_FS_TASK_ACT_BAC_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_TASK_ACT_BAC_ETL_PKG" 
/* $Header: iscfsactbacetls.pls 120.0 2005/08/28 14:56:05 kreardon noship $ */
AUTHID CURRENT_USER as

procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
);

  g_object_name constant varchar2(30) := 'ISC_FS_ACTIVITY_BACKLOG_FACT';

end isc_fs_task_act_bac_etl_pkg;

 

/
