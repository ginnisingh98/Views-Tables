--------------------------------------------------------
--  DDL for Package OPI_DBI_WIP_COMP_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WIP_COMP_INCR_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDCOMPLRS.pls 115.0 2003/06/11 20:08:28 digupta noship $ */


/*  Wrapper routine for OPI + OPM wip completion data extraction for
    incremental load
*/
PROCEDURE collect_wip_completions_incr (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER);


END opi_dbi_wip_comp_incr_pkg;

 

/
