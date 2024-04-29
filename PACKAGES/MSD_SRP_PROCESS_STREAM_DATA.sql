--------------------------------------------------------
--  DDL for Package MSD_SRP_PROCESS_STREAM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SRP_PROCESS_STREAM_DATA" AUTHID CURRENT_USER AS -- specification
/* $Header: MSDSRPPPS.pls 120.0 2007/11/07 10:32:49 vrepaka noship $ */



   --  ================= Procedures ====================
   PROCEDURE LAUNCH( ERRBUF                  OUT NOCOPY VARCHAR2,
	         RETCODE                     OUT NOCOPY NUMBER,
	         p_instance_id               IN  NUMBER,
                 p_stream_id                 IN  NUMBER);


END MSD_SRP_PROCESS_STREAM_DATA;


/
