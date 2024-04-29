--------------------------------------------------------
--  DDL for Package ISC_DEPOT_MARGIN_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_MARGIN_ETL_PKG" AUTHID CURRENT_USER AS
--$Header: iscdepotmrgetls.pls 120.0 2005/05/25 17:44:54 appldev noship $

-- Global Varaiables

C_ERROR         CONSTANT        NUMBER := -1;   -- concurrent manager error code
C_WARNING       CONSTANT        NUMBER := 1;    -- concurrent manager warning code
C_OK            CONSTANT        NUMBER := 0;    -- concurrent manager success code
C_ERRBUF_SIZE   CONSTANT        NUMBER := 300;  -- length of formatted error message

PROCEDURE charges_initial_load(errbuf    IN OUT NOCOPY  VARCHAR2,
                       retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE costs_initial_load(errbuf    IN OUT NOCOPY  VARCHAR2,
                       	     retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE charges_incr_load(errbuf  in out NOCOPY VARCHAR2,
                    	    retcode in out NOCOPY NUMBER);

PROCEDURE costs_incr_load(errbuf  in out NOCOPY VARCHAR2,
                    	  retcode in out NOCOPY NUMBER);

END ISC_DEPOT_margin_etl_pkg;

 

/
