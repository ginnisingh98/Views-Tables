--------------------------------------------------------
--  DDL for Package BIX_EMAILS_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_EMAILS_LOAD_PKG" AUTHID CURRENT_USER AS
/*$Header: bixemlls.pls 115.1 2003/03/21 01:28:13 achanda noship $ */

  PROCEDURE  load (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

END BIX_EMAILS_LOAD_PKG;

 

/
