--------------------------------------------------------
--  DDL for Package Body OKI_DBI_RESET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_RESET_PUB" AS
/* $Header: OKIPIRSB.pls 115.3 2002/11/25 18:13:44 rpotnuru noship $ */

/* ***************************************************
   Procedure to reset OKI DBI files
   *************************************************** */
  PROCEDURE reset_base_tables  (
                                  errbuf  OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY VARCHAR2
                                ) IS
  BEGIN
     OKI_DBI_RESET_PVT.reset_base_tables  (
                                            errbuf ,
                                            retcode
                                          );
  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RAISE;
   WHEN OTHERS THEN
      fnd_message.set_name(  application => 'FND'
                           , name          => 'CRM-DEBUG ERROR' ) ;
      fnd_message.set_token(  token => 'ROUTINE'
                            , value => 'OKI_DBI_RESET_PUB.reset_base_tables ' ) ;
      bis_collection_utilities.put_line(fnd_message.get) ;
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END reset_base_tables;

END OKI_DBI_RESET_PUB;

/
