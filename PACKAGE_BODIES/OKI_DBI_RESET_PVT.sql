--------------------------------------------------------
--  DDL for Package Body OKI_DBI_RESET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_RESET_PVT" AS
/* $Header: OKIRIRSB.pls 115.7 2002/11/25 18:13:27 rpotnuru noship $ */

/* ***************************************************
   Procedure to reset OKI DBI table
   *************************************************** */
  PROCEDURE reset_base_tables  (
                                  errbuf  OUT NOCOPY VARCHAR2,
                                  retcode OUT NOCOPY VARCHAR2
                                ) IS
     l_sql_string   VARCHAR2(4000);

     l_oki_schema          VARCHAR2(30);
     l_status              VARCHAR2(30);
     l_industry            VARCHAR2(30);


  BEGIN
   retcode := 0 ;

   IF (FND_INSTALLATION.GET_APP_INFO('OKI', l_status, l_industry, l_oki_schema)) THEN

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_CLE_B';
     EXECUTE IMMEDIATE l_sql_string;

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_REN_B';
     EXECUTE IMMEDIATE l_sql_string;

     l_sql_string := 'TRUNCATE TABLE ' || l_oki_schema ||'.OKI_DBI_CLE_INC';
     EXECUTE IMMEDIATE l_sql_string;

     BIS_COLLECTION_UTILITIES.DeleteLogForObject('OKIDBICLEB');
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR  THEN
       RAISE;
    WHEN OTHERS
    THEN
       errbuf  := sqlerrm;
       retcode := sqlcode;
       bis_collection_utilities.put_line(errbuf || '' || retcode ) ;
       fnd_message.set_name(  application => 'FND'
                          , name          => 'CRM-DEBUG ERROR' ) ;
       fnd_message.set_token(  token => 'ROUTINE'
                           ,   value => 'OKI_DBI_RESET_PVT.reset_base_tables ' ) ;
       bis_collection_utilities.put_line(fnd_message.get) ;
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END reset_base_tables;

END OKI_DBI_RESET_PVT;

/
