--------------------------------------------------------
--  DDL for Package BIL_BI_OPDTL_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_OPDTL_F_PKG" AUTHID CURRENT_USER AS
/*$Header: bilos1s.pls 120.1 2005/09/22 06:35:32 vchahal noship $*/

/*******************************************************************/
--For Initial Load
  PROCEDURE  Init_load (errbuf             IN OUT NOCOPY VARCHAR2 ,
  			      retcode            IN OUT NOCOPY VARCHAR2,
              		p_from_date        IN 	    VARCHAR2,
				p_truncate          IN 	    VARCHAR2);

--For Incremental Load

  PROCEDURE  Incr_load (errbuf              IN OUT NOCOPY VARCHAR2 ,
  			      retcode             IN OUT NOCOPY VARCHAR2 );



END BIL_BI_OPDTL_F_PKG;


 

/
