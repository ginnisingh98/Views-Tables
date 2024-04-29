--------------------------------------------------------
--  DDL for Package ISC_MAINT_WO_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_MAINT_WO_ETL_PKG" AUTHID CURRENT_USER AS
/*$Header: iscmaintwoetls.pls 120.0 2005/05/25 17:23:33 appldev noship $ */

 PROCEDURE GET_WORK_ORDERS_INITIAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

 PROCEDURE GET_WORK_ORDERS_INCR_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

End ISC_MAINT_WO_ETL_PKG;

 

/
