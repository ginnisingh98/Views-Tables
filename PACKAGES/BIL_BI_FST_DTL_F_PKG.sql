--------------------------------------------------------
--  DDL for Package BIL_BI_FST_DTL_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_BI_FST_DTL_F_PKG" AUTHID CURRENT_USER AS
/*$Header: bilfsts.pls 120.1 2005/09/22 06:34:52 vchahal noship $*/

PROCEDURE INIT_LOAD( ERRBUF               IN OUT NOCOPY VARCHAR2 ,
                     RETCODE              IN OUT NOCOPY VARCHAR2,
		         p_start_date         IN VARCHAR2,
			   p_truncate		IN VARCHAR2);

PROCEDURE INCR_LOAD( ERRBUF               IN OUT  NOCOPY VARCHAR2 ,
                     RETCODE              IN OUT  NOCOPY VARCHAR2
  			  -- p_number_of_process  IN NUMBER DEFAULT 1
		        ) ;




-- *****************************************************************
/*PROCEDURE WORKER(errbuf                IN OUT NOCOPY VARCHAR2,
                 retcode               IN  OUT NOCOPY VARCHAR2,
                 p_worker_no           IN NUMBER,
		     p_insert_flag         IN       VARCHAR2,
		     p_mode			VARCHAR2);
*/ -- commented out as workers are no more used in 7.0
END BIL_BI_FST_DTL_F_PKG;

 

/
