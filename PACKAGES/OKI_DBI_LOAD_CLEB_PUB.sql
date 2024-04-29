--------------------------------------------------------
--  DDL for Package OKI_DBI_LOAD_CLEB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_LOAD_CLEB_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPILES.pls 120.1 2006/03/28 23:31:29 asparama noship $ */


  PROCEDURE populate_base_tables (
                                  errbuf   OUT NOCOPY VARCHAR2,
                                  retcode  OUT NOCOPY VARCHAR2,
                                   p_start_date IN VARCHAR2,
                                   p_end_date IN VARCHAR2,
                                  p_no_of_workers IN NUMBER
                                );

  PROCEDURE initial_load(
                         errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2,
                          p_start_date IN VARCHAR2,
                          p_end_date IN VARCHAR2
                         );

  PROCEDURE worker       (
                         errbuf      OUT   NOCOPY VARCHAR2,
                         retcode     OUT   NOCOPY VARCHAR2,
                         p_worker_no IN NUMBER,
                         p_phase      IN NUMBER,
                         p_no_of_workers IN NUMBER
                         );
END OKI_DBI_LOAD_CLEB_PUB;

 

/
