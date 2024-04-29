--------------------------------------------------------
--  DDL for Package GMF_AR_TOTAL_OUTSTANDING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_TOTAL_OUTSTANDING" AUTHID CURRENT_USER AS
/* $Header: gmfcrmts.pls 115.1 2002/11/11 00:35:45 rseshadr ship $ */
  PROCEDURE TOTAL_OUTSTANDING (
        CUST_ID            IN OUT NOCOPY NUMBER,
        SITE_USE_ID        IN OUT NOCOPY NUMBER,
        ORDER_CURRENCY     IN OUT NOCOPY VARCHAR2,
        BASE_CUR           IN OUT NOCOPY VARCHAR2,
        TOTAL_OUTSTANDING     OUT NOCOPY NUMBER);
END GMF_AR_TOTAL_OUTSTANDING;

 

/
