--------------------------------------------------------
--  DDL for Package POA_DBI_RCV_TXN_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_RCV_TXN_F_C" AUTHID CURRENT_USER AS
/* $Header: poadbirtxfrefs.pls 115.1 2004/06/25 21:12:53 rvickrey noship $ */
PROCEDURE initial_load (errbuf          OUT NOCOPY VARCHAR2,
			retcode         OUT NOCOPY NUMBER);


PROCEDURE populate_rcv_txn_facts (errbuf          OUT NOCOPY VARCHAR2,
				  retcode         OUT NOCOPY NUMBER);


FUNCTION get_date (txn_id NUMBER) RETURN DATE parallel_enable;

FUNCTION get_top_date (txn_id NUMBER) RETURN DATE parallel_enable;

END POA_DBI_RCV_TXN_F_C ;

 

/
