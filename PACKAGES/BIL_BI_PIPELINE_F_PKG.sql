--------------------------------------------------------
--  DDL for Package BIL_BI_PIPELINE_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_PIPELINE_F_PKG" AUTHID CURRENT_USER AS
/*$Header: bilbpips.pls 120.2 2005/09/01 04:11:42 asolaiy noship $*/


   PROCEDURE init_load (errbuf         IN OUT NOCOPY VARCHAR2,
                   retcode             IN OUT NOCOPY VARCHAR2,
		   p_start_date        IN   VARCHAR2 ,
                   p_truncate          IN 	   VARCHAR2);

   PROCEDURE incr_load (errbuf         IN OUT NOCOPY VARCHAR2,
                   retcode             IN OUT NOCOPY VARCHAR2);


 /*

   PROCEDURE Load (errbuf              IN OUT NOCOPY VARCHAR2,
                   retcode             IN OUT NOCOPY VARCHAR2,
		   p_start_date        IN   VARCHAR2 ,
                   p_truncate          IN 	   VARCHAR2);


*/

END BIL_BI_PIPELINE_F_PKG;

 

/
