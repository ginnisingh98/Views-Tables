--------------------------------------------------------
--  DDL for Package OPI_DBI_COGS_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_COGS_OPM_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDECOGSPS.pls 115.1 2004/03/10 22:11:01 weizhou noship $ */

/**************************************************
* Package Level Constants
**************************************************/

g_ERROR CONSTANT NUMBER := -1;   -- concurrent manager error code
g_WARNING CONSTANT NUMBER := 1;  -- concurrent manager warning code
g_OK CONSTANT NUMBER := 0;  -- concurrent manager success code

/**************************************************
* Package Level User Defined Exceptions for functions
**************************************************/



/**************************************************
* Package Level User Defined Exceptions for ETL stages
**************************************************/

/* complete_refresh_OPM_margin

    Wrapper routine for the initial load of cogs for OPM ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning
    p_degree  - Is it still needed?

    History:
    Date        Author              Action
    04/03/04    Vedhanarayanan G    Defined specification.

*/
PROCEDURE complete_refresh_OPM_margin (errbuf    in out NOCOPY  VARCHAR2,
                                       retcode   in out NOCOPY  VARCHAR2,
                                       p_degree  in     NUMBER  DEFAULT 0);


/* refresh_OPM_margin

    Wrapper routine for the incremental load of cogs for OPM ETL.

    Parameters:
    retcode - 0 on successful completion, -1 on error and 1 for warning.
    errbuf - empty on successful completion, message on error or warning

    History:
    Date        Author              Action
    04/03/04    Vedhanarayanan G    Defined specification.

*/
PROCEDURE refresh_OPM_margin (errbuf  in out NOCOPY VARCHAR2,
                             retcode in out NOCOPY VARCHAR2);

END opi_dbi_cogs_opm_pkg;

 

/
