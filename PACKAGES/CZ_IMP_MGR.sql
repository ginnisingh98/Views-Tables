--------------------------------------------------------
--  DDL for Package CZ_IMP_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_IMP_MGR" AUTHID CURRENT_USER as
/*  $Header: czimngrs.pls 120.0 2005/05/25 07:14:08 appldev noship $	*/

BATCH_SIZE                    INTEGER:=10000;

G_CONCURRENT_SUCCESS          CONSTANT PLS_INTEGER  := 0;
G_CONCURRENT_ERROR            CONSTANT PLS_INTEGER  := 2;

PROCEDURE purge_cp(errbuf     IN OUT NOCOPY VARCHAR2,
		   retcode    IN OUT NOCOPY pls_integer);

PROCEDURE purge_to_date_cp(errbuf     IN OUT NOCOPY VARCHAR2,
		           retcode    IN OUT NOCOPY pls_integer,
                           p_days     IN            NUMBER);

PROCEDURE purge_to_runid_cp(errbuf    IN OUT NOCOPY VARCHAR2,
	                    retcode   IN OUT NOCOPY pls_integer,
                            p_run_id  IN            NUMBER);
END CZ_IMP_MGR;
 

/
