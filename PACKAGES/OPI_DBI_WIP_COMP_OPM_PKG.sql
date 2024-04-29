--------------------------------------------------------
--  DDL for Package OPI_DBI_WIP_COMP_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WIP_COMP_OPM_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDCOMPLOS.pls 115.0 2003/06/11 23:15:39 pdong noship $ */

/*  ETL package for OPM wip completion data extraction for, for
    both initial and incremental load. This package is called by
    both opi_dbi_wip_comp_init_pkg and opi_dbi_wip_comp_incr_pkg.
*/

PROCEDURE collect_init_opm_wip_comp (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_global_start_date IN DATE);

PROCEDURE collect_incr_opm_wip_comp (errbuf OUT NOCOPY VARCHAR2,
                                     retcode OUT NOCOPY NUMBER,
                                     p_global_start_date IN DATE);


END opi_dbi_wip_comp_opm_pkg;

 

/
