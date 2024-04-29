--------------------------------------------------------
--  DDL for Package ISC_FS_INV_USG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_FS_INV_USG_ETL_PKG" AUTHID CURRENT_USER AS
/*$Header: iscfsinvetls.pls 120.0 2005/08/28 14:58:01 kreardon noship $ */
PROCEDURE GET_INV_USG_INITIAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

PROCEDURE GET_INV_USG_INCREMENTAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

End ISC_FS_INV_USG_ETL_PKG;

 

/
