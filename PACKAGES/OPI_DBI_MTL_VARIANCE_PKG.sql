--------------------------------------------------------
--  DDL for Package OPI_DBI_MTL_VARIANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_MTL_VARIANCE_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDMUVETLS.pls 120.2 2005/09/01 23:05:19 vganeshk noship $ */

    --PROCEDURE GET_JOB_MTL_DETAILS_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

    --PROCEDURE GET_JOB_MTL_DETAILS_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

    PROCEDURE GET_MFG_CST_VAR_INIT(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

    PROCEDURE GET_MFG_CST_VAR_INCR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

    PROCEDURE GET_CURR_UNREC_VAR(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

    PROCEDURE REFRESH_MV(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

END OPI_DBI_MTL_VARIANCE_PKG;

 

/
