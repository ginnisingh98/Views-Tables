--------------------------------------------------------
--  DDL for Package OPI_DBI_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_RES_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDRESS.pls 120.2 2005/09/01 10:58:09 julzhang noship $ */

/*======================================================================
    This is the wrapper procedure for Resource initial load which extracts
    actual resource usage and resource availability data for discrete
    and process organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
    - p_degree: degree
=======================================================================*/
PROCEDURE initial_load_res_utl( errbuf  in out nocopy varchar2,
                retcode in out nocopy VARCHAR2,
                p_degree       NUMBER    );



/*======================================================================
    This procedure extracts Resource Standard Usage for initial loads.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
    - p_degree: degree
=======================================================================*/
PROCEDURE initial_load_res_std (errbuf in out  nocopy varchar2,
                retcode in out nocopy VARCHAR2,
                p_degree IN    NUMBER    );



/*======================================================================
    This is the wrapper procedure for Resource incremental load which extracts
    actual resource usage, resource availability, and resource standare usage
    data for discrete and process organizations.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================================*/
PROCEDURE incremental_load_res_utl ( errbuf  in out nocopy varchar2,
                    retcode in out  nocopy VARCHAR2      );

END opi_dbi_res_pkg;

 

/
