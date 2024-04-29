--------------------------------------------------------
--  DDL for Package Body GMF_AR_TOTAL_OUTSTANDING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_TOTAL_OUTSTANDING" AS
/* $Header: gmfcrmtb.pls 120.2 2005/10/27 13:02:27 sschinch noship $ */


  PROCEDURE TOTAL_OUTSTANDING (CUST_ID            IN OUT NOCOPY NUMBER,
			       SITE_USE_ID        IN OUT NOCOPY NUMBER,
                               ORDER_CURRENCY     IN OUT NOCOPY VARCHAR2,
                               BASE_CUR           IN OUT NOCOPY VARCHAR2,
                               TOTAL_OUTSTANDING  OUT    NOCOPY NUMBER) IS

  BEGIN
    TOTAL_OUTSTANDING := 0;
  END TOTAL_OUTSTANDING;
END GMF_AR_TOTAL_OUTSTANDING;

/
