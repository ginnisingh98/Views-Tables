--------------------------------------------------------
--  DDL for Package Body BIX_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_MISC" AS
/* $Header: BIXMISCB.pls 115.5 2003/01/10 00:31:28 achanda ship $ */
PROCEDURE BIX_PURGE_INT
IS
BEGIN
  DELETE from
  BIX_INTERACTIONS_INF;
  DELETE from
  BIX_INTERACTIONS;
  COMMIT;
 EXCEPTION
  WHEN OTHERS THEN
	-- DBMS_OUTPUT.PUT_LINE('Exception when purging Interactions');
	NULL;
END BIX_PURGE_INT;
procedure BIX_PURGE_INT(errbuf out nocopy varchar2,
				retcode out nocopy varchar2)
IS
BEGIN
   BIX_PURGE_INT();
END;

END BIX_MISC;

/
