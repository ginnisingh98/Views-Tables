--------------------------------------------------------
--  DDL for Package FII_AR_REVENUE_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AR_REVENUE_B_C" AUTHID CURRENT_USER AS
/* $Header: FIIAR18S.pls 115.5 2003/10/14 19:00:06 juding noship $ */


PROCEDURE MAIN(Errbuf          IN OUT  NOCOPY VARCHAR2,
               Retcode         IN OUT  NOCOPY VARCHAR2,
               p_sob_id	       IN      NUMBER   DEFAULT NULL,
               p_gl_from_date  IN      VARCHAR2,
               p_gl_to_date    IN      VARCHAR2,
               p_no_worker     IN      NUMBER   DEFAULT 2,
               p_program_type  IN      VARCHAR2 DEFAULT 'I',
               p_parallel_query IN     NUMBER,
               p_sort_area_size  IN    NUMBER,
               p_hash_area_size  IN    NUMBER);

PROCEDURE WORKER(
		Errbuf		IN OUT	NOCOPY VARCHAR2,
		Retcode		IN OUT	NOCOPY VARCHAR2,
		p_worker_no	IN	NUMBER);


END FII_AR_REVENUE_B_C;

 

/
