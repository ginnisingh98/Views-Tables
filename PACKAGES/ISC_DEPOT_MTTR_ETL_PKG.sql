--------------------------------------------------------
--  DDL for Package ISC_DEPOT_MTTR_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DEPOT_MTTR_ETL_PKG" AUTHID CURRENT_USER AS
--$Header: iscdepotmttretls.pls 120.0 2005/05/25 17:25:36 appldev noship $

C_ERROR         CONSTANT        NUMBER := -1;   -- concurrent manager error code
C_WARNING       CONSTANT        NUMBER := 1;    -- concurrent manager warning code
C_OK            CONSTANT        NUMBER := 0;    -- concurrent manager success code
C_ERRBUF_SIZE   CONSTANT        NUMBER := 300;  -- length of formatted error message

PROCEDURE INITIAL_LOAD(errbuf    IN OUT NOCOPY  VARCHAR2,
                       retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE INCR_LOAD(errbuf  IN OUT NOCOPY VARCHAR2,
                    retcode IN OUT NOCOPY NUMBER);

END ISC_DEPOT_MTTR_ETL_PKG;

 

/
