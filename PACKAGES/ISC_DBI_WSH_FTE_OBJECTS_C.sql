--------------------------------------------------------
--  DDL for Package ISC_DBI_WSH_FTE_OBJECTS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_WSH_FTE_OBJECTS_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF9S.pls 120.0 2005/05/25 17:35:27 appldev noship $ */

  ---------------------
  --  Public PROCEDURES
  ---------------------

  PROCEDURE LOAD_FACTS(errbuf      		IN OUT NOCOPY VARCHAR2,
                      retcode     		IN OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_DETAIL_FACT(errbuf      	IN OUT NOCOPY VARCHAR2,
                               retcode     	IN OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_LEG_STOP_FACT(errbuf      	IN OUT NOCOPY VARCHAR2,
                              retcode    	IN OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_INVOICE_FACT(errbuf      	IN OUT NOCOPY VARCHAR2,
                            retcode     	IN OUT NOCOPY VARCHAR2);

END ISC_DBI_WSH_FTE_OBJECTS_C;

 

/
