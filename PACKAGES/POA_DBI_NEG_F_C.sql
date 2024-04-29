--------------------------------------------------------
--  DDL for Package POA_DBI_NEG_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_NEG_F_C" AUTHID CURRENT_USER AS
/* $Header: poadbinegfrefs.pls 120.0 2005/09/30 11:34:01 sriswami noship $ */
PROCEDURE initial_load (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER
                       );


PROCEDURE populate_neg_facts (errbuf          OUT NOCOPY VARCHAR2,
			      retcode         OUT NOCOPY NUMBER
                             );

END POA_DBI_NEG_F_C ;

 

/
