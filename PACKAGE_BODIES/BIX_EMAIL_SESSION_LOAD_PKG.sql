--------------------------------------------------------
--  DDL for Package Body BIX_EMAIL_SESSION_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_EMAIL_SESSION_LOAD_PKG" AS
/*$Header: bixemslb.plb 115.3 2003/10/31 02:31:38 djambula noship $ */

PROCEDURE  load (errbuf   OUT  NOCOPY VARCHAR2,
                 retcode  OUT  NOCOPY VARCHAR2)
IS
BEGIN
NULL;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END load;

END BIX_EMAIL_SESSION_LOAD_PKG;

/
