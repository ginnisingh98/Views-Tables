--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_CPCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_CPCS_PKG" AUTHID CURRENT_USER as
/* $Header: OPIDIVCPCSS.pls 115.0 2004/02/06 22:08:58 ltong noship $ */

 PROCEDURE Run_Period_Close_Adjustment (errbuf  IN OUT NOCOPY VARCHAR2, retcode IN OUT NOCOPY VARCHAR2);


END OPI_DBI_INV_CPCS_PKG;

 

/
