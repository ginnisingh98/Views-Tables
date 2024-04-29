--------------------------------------------------------
--  DDL for Package OPI_DBI_JOB_TXN_STG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_JOB_TXN_STG_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDJOBTRS.pls 120.1 2005/08/11 05:26 vganeshk noship $*/

 PROCEDURE GET_OPI_JOB_TXN_MUV_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

 PROCEDURE GET_OPI_JOB_TXN_MUV_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

 PROCEDURE REFRESH_MV(errbuf in out NOCOPY varchar2,
                      retcode in out NOCOPY varchar2);

END OPI_DBI_JOB_TXN_STG_PKG;

 

/
