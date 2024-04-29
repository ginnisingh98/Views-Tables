--------------------------------------------------------
--  DDL for Package OPI_DBI_WIP_SCRAP_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WIP_SCRAP_INCR_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDSCRAPRS.pls 115.0 2003/06/11 20:09:22 digupta noship $ */

/*  Wrapper routine for OPI WIP scrap data extraction for
    incremental load w which will be visible to the user.
*/
PROCEDURE collect_wip_scrap_incr (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER);


END opi_dbi_wip_scrap_incr_pkg;

 

/
