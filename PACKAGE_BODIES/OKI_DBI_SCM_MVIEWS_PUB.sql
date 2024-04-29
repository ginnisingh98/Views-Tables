--------------------------------------------------------
--  DDL for Package Body OKI_DBI_SCM_MVIEWS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_SCM_MVIEWS_PUB" AS
/* $Header: OKIPIMRB.pls 115.3 2002/12/24 23:39:19 mezra noship $ */

  PROCEDURE refresh_scm
  (  errbuf       OUT NOCOPY VARCHAR2
   , retcode      OUT NOCOPY VARCHAR2
  ) IS

  BEGIN

   errbuf  := NULL ;
   retcode := 0 ;

   oki_dbi_scm_mviews_pvt.refresh_scm(errbuf, retcode) ;

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
                          , value => 'OKI_DBI_SCM_MVIEWS_PUB.refresh_scm ' ) ;
    bis_collection_utilities.put_line(fnd_message.get) ;
    RAISE_APPLICATION_ERROR(-20000,'Stack Dump Follows =>', true);
END refresh_scm ;

END oki_dbi_scm_mviews_pub ;

/
