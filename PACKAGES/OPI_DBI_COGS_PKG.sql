--------------------------------------------------------
--  DDL for Package OPI_DBI_COGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_COGS_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDECOGSS.pls 120.1 2005/08/09 14:08:14 julzhang noship $ */


/*  This is the most outer wrapper for COGS initial load. The input
    and output parameters are the error buffer and return code */

PROCEDURE initial_load_cogs ( errbuf  IN OUT NOCOPY  VARCHAR2,
                              retcode IN OUT NOCOPY  VARCHAR2 );


/*  This is the most outer wrapper for COGS incremental load. The input
    and output parameters are the error buffer and return code. */

PROCEDURE incremental_load_cogs ( errbuf    IN OUT NOCOPY  VARCHAR2,
                                  retcode   IN OUT NOCOPY  VARCHAR2 );

END opi_dbi_cogs_pkg;

 

/
