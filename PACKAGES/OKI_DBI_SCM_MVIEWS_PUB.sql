--------------------------------------------------------
--  DDL for Package OKI_DBI_SCM_MVIEWS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SCM_MVIEWS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPIMRS.pls 115.5 2002/12/24 23:38:44 mezra noship $ */

  PROCEDURE refresh_scm
 (  errbuf      OUT NOCOPY VARCHAR2
  , retcode     OUT NOCOPY VARCHAR2
 ) ;

END oki_dbi_scm_mviews_pub ;

 

/
