--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_VALUE_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_VALUE_INCR_PKG" AUTHID CURRENT_USER as
/* $Header: OPIDIVRS.pls 120.1 2005/08/02 01:48:58 achandak noship $ */

PROCEDURE Refresh (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2
);

/*PROCEDURE Extract_Daily_Activity (
  errbuf  IN OUT NOCOPY VARCHAR2,
  retcode IN OUT NOCOPY VARCHAR2,
  inception_date IN DATE
);*/

END OPI_DBI_INV_VALUE_INCR_PKG;

 

/
