--------------------------------------------------------
--  DDL for Package OKI_DBI_SCM_MVIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_SCM_MVIEWS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRIMRS.pls 115.4 2002/12/24 23:38:02 mezra noship $ */

  PROCEDURE refresh_scm
 (  errbuf      OUT NOCOPY VARCHAR2
  , retcode     OUT NOCOPY VARCHAR2
 ) ;

END oki_dbi_scm_mviews_pvt ;

 

/
