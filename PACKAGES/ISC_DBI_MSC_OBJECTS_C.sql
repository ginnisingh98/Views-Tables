--------------------------------------------------------
--  DDL for Package ISC_DBI_MSC_OBJECTS_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_MSC_OBJECTS_C" AUTHID CURRENT_USER AS
/* $Header: ISCSCF8S.pls 115.1 2004/01/23 15:12:56 stsay ship $ */

  -------------------
  -- Public Functions
  -------------------

  FUNCTION LOAD_BASES RETURN NUMBER;

  ---------------------
  --  Public Procedures
  ---------------------
  PROCEDURE LOAD_FACTS(errbuf      		IN OUT NOCOPY VARCHAR2,
                       retcode     		IN OUT NOCOPY VARCHAR2);

  PROCEDURE UPDATE_FACTS(errbuf      		IN OUT NOCOPY VARCHAR2,
                       retcode     		IN OUT NOCOPY VARCHAR2);

END ISC_DBI_MSC_OBJECTS_C;

 

/
