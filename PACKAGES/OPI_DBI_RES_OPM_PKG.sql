--------------------------------------------------------
--  DDL for Package OPI_DBI_RES_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_RES_OPM_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDREOS.pls 115.1 2003/06/20 17:08:21 pdong noship $ */


/*
PROCEDURE put_line(p_msg VARCHAR2);
*/

    PROCEDURE check_setup_globals
    (
        errbuf IN OUT NOCOPY VARCHAR2,
        retcode IN OUT NOCOPY VARCHAR2
    );

    PROCEDURE initial_opm_res_actual
    (
        errbuf in out NOCOPY varchar2,
        retcode in out NOCOPY varchar2
    );

    PROCEDURE initial_opm_res_avail
    (
        errbuf in out NOCOPY varchar2,
        retcode in out NOCOPY varchar2
    );

    PROCEDURE initial_opm_res_std
    (
        errbuf in out NOCOPY varchar2,
        retcode in out NOCOPY varchar2,
        p_degree IN    NUMBER
    );


    PROCEDURE incremental_opm_res_actual
    (
        errbuf in out NOCOPY varchar2,
        retcode in out NOCOPY varchar2
    );

    PROCEDURE incremental_opm_res_avail
    (
        errbuf in out NOCOPY varchar2,
        retcode in out NOCOPY varchar2
    );

    PROCEDURE incremental_opm_res_std
    (
        errbuf in out NOCOPY varchar2,
        retcode in out NOCOPY varchar2
    );

END opi_dbi_res_opm_pkg;

 

/
