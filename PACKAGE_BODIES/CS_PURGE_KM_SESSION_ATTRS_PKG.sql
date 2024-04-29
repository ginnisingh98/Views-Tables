--------------------------------------------------------
--  DDL for Package Body CS_PURGE_KM_SESSION_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_PURGE_KM_SESSION_ATTRS_PKG" AS
/* $Header: cskbsarb.pls 120.1 2005/06/22 11:59:29 appldev ship $ */


PROCEDURE start_program ( ERRBUF OUT NOCOPY VARCHAR2,
                            RETCODE OUT NOCOPY VARCHAR2,
                            DATE_OFFSET IN   NUMBER := 1
                        ) AS
BEGIN
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Start purging the km session attribute values for the previous day.');

   delete from cs_kb_session_attrs where attribute_type = 'EXTERNAL' and creation_date < ( trunc(sysdate) - DATE_OFFSET );

   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Completed purging the km session attribute.');

EXCEPTION
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Unhandled exception in CS_PURGE_KM_SESSION_ATTRS_PKG');
      ERRBUF:='Please review Log for details';
      RETCODE:='2';
END start_program;
END CS_PURGE_KM_SESSION_ATTRS_PKG;

/
