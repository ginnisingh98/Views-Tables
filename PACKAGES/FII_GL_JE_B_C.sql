--------------------------------------------------------
--  DDL for Package FII_GL_JE_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_JE_B_C" AUTHID CURRENT_USER AS
/*$Header: FIIGL03S.pls 115.4 2003/12/26 22:01:46 juding noship $*/

Procedure  Main (errbuf                IN OUT NOCOPY VARCHAR2,
                 retcode               IN OUT NOCOPY VARCHAR2,
                 p_start_date          IN     VARCHAR2,
                 p_end_date            IN     VARCHAR2,
                 p_number_of_process   IN     NUMBER   DEFAULT 2,
                 p_program_type        IN     VARCHAR2 DEFAULT 'I',
                 p_parallel_query      IN     NUMBER,
                 p_sort_area_size      IN     NUMBER,
                 p_hash_area_size      IN     NUMBER);

-- *****************************************************************
PROCEDURE WORKER(errbuf                IN OUT NOCOPY VARCHAR2,
                 retcode               IN  OUT NOCOPY VARCHAR2,
                 p_worker_no  IN NUMBER);


END FII_GL_JE_B_C;


 

/
