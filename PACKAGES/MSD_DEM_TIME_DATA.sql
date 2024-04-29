--------------------------------------------------------
--  DDL for Package MSD_DEM_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_TIME_DATA" AUTHID CURRENT_USER AS
/* $Header: msddemcals.pls 120.0.12000000.2 2007/09/25 06:10:01 syenamar noship $ */

Procedure collect_time_data(errbuf  OUT NOCOPY  VARCHAR2,
                        	  retcode OUT NOCOPY  VARCHAR2,
                        	  p_auto_run_download IN NUMBER );

end MSD_DEM_TIME_DATA;


 

/
