--------------------------------------------------------
--  DDL for Package OKC_CHR_KEYWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CHR_KEYWORD_PVT" AUTHID CURRENT_USER as
/* $Header: OKCRCKWS.pls 120.1 2006/07/25 20:06:17 upillai noship $ */

  PROCEDURE sync;
  PROCEDURE optimize;

  PROCEDURE sync_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);
  PROCEDURE optimize_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);
  PROCEDURE create_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

END;

 

/

  GRANT EXECUTE ON "APPS"."OKC_CHR_KEYWORD_PVT" TO "OKC";
