--------------------------------------------------------
--  DDL for Package OPI_DBI_WIP_SCRAP_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WIP_SCRAP_INIT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDSCRAPIS.pls 115.0 2003/06/11 19:59:56 digupta noship $ */

/*  Wrapper routine for OPI WIP scrap data extraction for initial load
    which will be visible to the user.
*/
PROCEDURE collect_wip_scrap_init (errbuf OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY NUMBER);


/*  Common utilities for scrap initial and incremental load.
*/
PROCEDURE compute_wip_scrap_conv_rates (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER,
                                        p_opi_schema IN VARCHAR2) ;


FUNCTION check_global_setup
    RETURN BOOLEAN;



/* refresh the scrap related MVs
    Refresh the 3 MV's in this order:
    1. OPI_COMP_SCR_MV
    2. OPI_PROD_SCR_MV
    3. OPI_SCRAP_SUM_MV
*/
PROCEDURE refresh (errbuf OUT NOCOPY VARCHAR2,
                   retcode OUT NOCOPY NUMBER);



END opi_dbi_wip_scrap_init_pkg;

 

/
