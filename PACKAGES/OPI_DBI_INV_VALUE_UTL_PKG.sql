--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_VALUE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_VALUE_UTL_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDIVUS.pls 115.1 2003/04/29 22:15:22 warwu noship $ */

-- ---------------------------------------------------------
--  FUNCTIONS
-- ---------------------------------------------------------

  FUNCTION Get_Conversion_Rate (errbuf  IN OUT NOCOPY VARCHAR2, retcode IN OUT NOCOPY VARCHAR2) return NUMBER;

  FUNCTION Check_Intransit_Availability (p_org_id IN NUMBER) return NUMBER;

End OPI_DBI_INV_VALUE_UTL_PKG;

 

/
