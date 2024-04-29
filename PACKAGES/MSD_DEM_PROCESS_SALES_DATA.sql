--------------------------------------------------------
--  DDL for Package MSD_DEM_PROCESS_SALES_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_PROCESS_SALES_DATA" AUTHID CURRENT_USER AS -- specification
/* $Header: MSDDEMSDS.pls 120.0.12000000.2 2007/09/25 06:02:17 syenamar noship $ */



   --  ================= Procedures ====================
   PROCEDURE LAUNCH( ERRBUF                  OUT NOCOPY VARCHAR2,
	         RETCODE                     OUT NOCOPY NUMBER,
	         p_instance_id               IN  NUMBER );


END MSD_DEM_PROCESS_SALES_DATA;

 

/
