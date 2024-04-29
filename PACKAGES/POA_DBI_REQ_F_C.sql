--------------------------------------------------------
--  DDL for Package POA_DBI_REQ_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_REQ_F_C" AUTHID CURRENT_USER AS
/* $Header: poadbireqfrefs.pls 120.0 2005/06/01 13:19:31 appldev noship $ */
PROCEDURE initial_load (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER
                       );


PROCEDURE populate_req_facts (errbuf          OUT NOCOPY VARCHAR2,
			      retcode         OUT NOCOPY NUMBER
                             );

END POA_DBI_REQ_F_C ;

 

/
