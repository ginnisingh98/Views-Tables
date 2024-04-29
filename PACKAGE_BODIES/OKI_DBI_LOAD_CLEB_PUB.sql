--------------------------------------------------------
--  DDL for Package Body OKI_DBI_LOAD_CLEB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_LOAD_CLEB_PUB" AS
/* $Header: OKIPILEB.pls 120.1 2006/03/28 23:31:11 asparama noship $ */


  PROCEDURE populate_base_tables (
                                  errbuf   OUT NOCOPY VARCHAR2,
                                  retcode  OUT NOCOPY VARCHAR2,
                                   p_start_date IN VARCHAR2,
                                   p_end_date IN VARCHAR2,
				  p_no_of_workers IN NUMBER
                                ) IS
  BEGIN
     OKI_DBI_LOAD_CLEB_PVT.populate_base_tables (
                                  errbuf ,
                                  retcode ,
                                  p_start_date ,
                                  p_end_date,
				  p_no_of_workers
                                );
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        retcode := -2;
        ROLLBACK;
     WHEN OTHERS THEN
        errbuf  := sqlerrm;
        retcode := sqlcode;
      fnd_message.set_name(  application => 'FND'
                         , name          => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                          , value => 'OKI_DBI_LOAD_CLEB_PUB.populate_base_tables ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
  END populate_base_tables;

  PROCEDURE initial_load(
                         errbuf  OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY VARCHAR2,
                          p_start_date IN VARCHAR2,
                          p_end_date IN VARCHAR2
                         ) IS
  BEGIN
    OKI_DBI_LOAD_CLEB_PVT.initial_load(errbuf,
                                       retcode,
                                       p_start_date,
                                       p_end_date
                                      );
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        retcode := -2;
        ROLLBACK;
     WHEN OTHERS THEN
        errbuf  := sqlerrm;
        retcode := sqlcode;
      fnd_message.set_name(  application => 'FND'
                         , name          => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                          , value => 'OKI_DBI_LOAD_CLEB_PUB.initial_load ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
  END initial_load;

  PROCEDURE worker       (
                         errbuf      OUT   NOCOPY VARCHAR2,
                         retcode     OUT   NOCOPY VARCHAR2,
                         p_worker_no IN NUMBER,
                         p_phase      IN NUMBER,
                         p_no_of_workers IN NUMBER
                         ) IS
  BEGIN
  OKI_DBI_LOAD_CLEB_PVT.worker       (
				     errbuf ,
				     retcode,
				     p_worker_no ,
				     p_phase ,
                                     p_no_of_workers
				     );

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        retcode := -2;
        ROLLBACK;
     WHEN OTHERS THEN
        errbuf  := sqlerrm;
        retcode := sqlcode;
      fnd_message.set_name(  application => 'FND'
                         , name          => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                          , value => 'OKI_DBI_LOAD_CLEB_PUB.worker' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
  END worker;

END OKI_DBI_LOAD_CLEB_PUB;

/
