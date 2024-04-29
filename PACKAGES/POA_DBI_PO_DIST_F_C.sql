--------------------------------------------------------
--  DDL for Package POA_DBI_PO_DIST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_PO_DIST_F_C" AUTHID CURRENT_USER AS
/* $Header: poadbipodfrefs.pls 115.3 2004/06/25 19:22:47 rvickrey noship $ */
PROCEDURE initial_load (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER);


PROCEDURE populate_po_dist_facts (errbuf          OUT NOCOPY VARCHAR2,
				  retcode         OUT NOCOPY NUMBER);


END POA_DBI_PO_DIST_F_C ;

 

/
