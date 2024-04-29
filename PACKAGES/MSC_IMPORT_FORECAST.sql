--------------------------------------------------------
--  DDL for Package MSC_IMPORT_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_IMPORT_FORECAST" AUTHID CURRENT_USER AS
/* $Header: MSCIFSTS.pls 120.1 2005/06/21 02:53:38 appldev ship $  */
PROCEDURE Import_Forecast(
	                ERRBUF              OUT NOCOPY VARCHAR2,
					RETCODE             OUT NOCOPY NUMBER,
                    v_req_id            IN  NUMBER);

END MSC_IMPORT_FORECAST;

 

/
