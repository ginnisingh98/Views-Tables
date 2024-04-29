--------------------------------------------------------
--  DDL for Package OKI_DBI_RESET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_RESET_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPIRSS.pls 115.3 2002/11/25 18:14:14 rpotnuru noship $ */


  PROCEDURE reset_base_tables  (
                                  errbuf  OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY VARCHAR2
                                );

END OKI_DBI_RESET_PUB;

 

/
