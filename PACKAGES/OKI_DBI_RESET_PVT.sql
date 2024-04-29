--------------------------------------------------------
--  DDL for Package OKI_DBI_RESET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_RESET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRIRSS.pls 115.4 2002/11/25 18:13:58 rpotnuru noship $ */


  PROCEDURE reset_base_tables  (
                                  errbuf   OUT NOCOPY VARCHAR2,
                                  retcode  OUT NOCOPY VARCHAR2
                                );

END OKI_DBI_RESET_PVT;

 

/
