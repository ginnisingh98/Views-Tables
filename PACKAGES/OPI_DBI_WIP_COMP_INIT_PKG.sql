--------------------------------------------------------
--  DDL for Package OPI_DBI_WIP_COMP_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WIP_COMP_INIT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDCOMPLIS.pls 115.0 2003/06/11 19:58:16 digupta noship $ */

/*  Wrapper routine for OPI + OPM wip completion data extraction for
    initial load
*/
PROCEDURE collect_wip_completions_init (errbuf OUT NOCOPY VARCHAR2,
                                        retcode OUT NOCOPY NUMBER);


/*  Common Utility Functions for both initial and incremental load
*/
PROCEDURE compute_wip_comp_conv_rates (errbuf OUT NOCOPY VARCHAR2,
                                       retcode OUT NOCOPY NUMBER,
                                       p_opi_schema IN VARCHAR2);

FUNCTION check_global_setup
    RETURN BOOLEAN;

END opi_dbi_wip_comp_init_pkg;

 

/
