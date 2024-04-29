--------------------------------------------------------
--  DDL for Package Body AR_ISPEED_API_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ISPEED_API_UTIL" AS
/* $Header: ARISPEDB.pls 115.2 2003/10/31 22:48:30 msenthil noship $ */

FUNCTION fire_concurrent_location ( argument2 VARCHAR2, argument3 VARCHAR2)
RETURN NUMBER IS

 request_id NUMBER;

BEGIN

 request_id := 0;

 request_id := FND_REQUEST.SUBMIT_REQUEST(
             'AR',       /**** Application Name ****/
             'ARFXPL',   /*** Program Name ***/
             null,       /*** Description ***/
             null,       /*** Start Time ***/
             FALSE,      /*** Sub Request ***/
             'ARTOKEN',  /*** Argument 1 ***/
             argument2,  /*** Argument 2 ***/
             argument3,  /*** Argument 3 ***/
             CHR(0),'','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','',
             '','','','','','','','','','');
  commit;
  return request_id;
END fire_concurrent_location ;

END ar_ispeed_api_util;

/
