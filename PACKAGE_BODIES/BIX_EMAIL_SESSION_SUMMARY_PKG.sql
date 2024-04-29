--------------------------------------------------------
--  DDL for Package Body BIX_EMAIL_SESSION_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_EMAIL_SESSION_SUMMARY_PKG" AS
/*$Header: bixemasb.plb 115.6 2003/10/31 02:31:26 djambula noship $ */

PROCEDURE worker(errbuf      OUT   NOCOPY VARCHAR2,
                 retcode     OUT   NOCOPY VARCHAR2,
                 p_worker_no IN NUMBER) IS
BEGIN
NULL;
EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END WORKER;

PROCEDURE  load (errbuf                OUT  NOCOPY VARCHAR2,
                 retcode               OUT  NOCOPY VARCHAR2,
                 p_number_of_processes IN   NUMBER )
IS
BEGIN
NULL;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END load;

END BIX_EMAIL_SESSION_SUMMARY_PKG;

/
