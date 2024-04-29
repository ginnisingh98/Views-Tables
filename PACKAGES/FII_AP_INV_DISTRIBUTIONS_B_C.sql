--------------------------------------------------------
--  DDL for Package FII_AP_INV_DISTRIBUTIONS_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_AP_INV_DISTRIBUTIONS_B_C" AUTHID CURRENT_USER AS
/* $Header: FIIAP20S.pls 120.0 2005/09/08 22:08:57 shanley noship $ */

-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2,
                  p_from_date     IN      VARCHAR2,
                  p_to_date       IN      VARCHAR2,
                  p_no_worker     IN      NUMBER   DEFAULT 2,
                  p_program_type  IN      VARCHAR2 DEFAULT 'I',
                  p_parallel_query IN     NUMBER,
                  p_hash_area_size IN     NUMBER,
                  p_sort_area_size IN     NUMBER
                  );


PROCEDURE WORKER(
		Errbuf		IN OUT NOCOPY VARCHAR2,
		Retcode		IN OUT NOCOPY VARCHAR2,
		p_worker_no	IN	NUMBER);


END FII_AP_INV_DISTRIBUTIONS_B_C;

 

/
