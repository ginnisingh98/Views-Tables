--------------------------------------------------------
--  DDL for Package FII_FA_EXP_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_FA_EXP_B_C" AUTHID CURRENT_USER AS
/*$Header: FIIFA01S.pls 120.1 2005/10/30 05:06:02 appldev noship $*/


PROCEDURE Main (errbuf              IN OUT NOCOPY VARCHAR2,
                retcode             IN OUT NOCOPY VARCHAR2,
                p_number_of_process IN      NUMBER,
                p_worker_num        IN      NUMBER,
                p_program_type      IN      VARCHAR2,
                p_parallel_query    IN      NUMBER,
                p_sort_area_size    IN      NUMBER,
                p_hash_area_size    IN      NUMBER);


END FII_FA_EXP_B_C;

 

/
