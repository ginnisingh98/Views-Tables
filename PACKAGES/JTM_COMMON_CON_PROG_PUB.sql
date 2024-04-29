--------------------------------------------------------
--  DDL for Package JTM_COMMON_CON_PROG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_COMMON_CON_PROG_PUB" AUTHID CURRENT_USER AS
/* $Header: jtmpcons.pls 115.2 2002/12/09 21:39:48 pwu ship $ */
-- Start of Comments
--
-- NAME
--   JTM_COMMON_CON_PROG_PUB
--
-- PURPOSE
--   Central Entry for Mobile Concurrent Programs.
--
--   PROCEDURES:
--
--
-- NOTES
--
--
-- HISTORY
--   04-09-2002 YOHUANG Created.
--
-- Notes
--   Do_Refresh_Mobile_Data will call each procedure according to EXECUTE_FLAG, EXECUTION_ORDER,
--   and FREQUENCY. Do_Refresh_Mobile_Data itself it runs every hour.
--   Each Procedure must make use of SAVEPOINT, because, at the end, Concurrent Manager will commit everything.

-- End of Comments
--
--
--

PROCEDURE Do_Refresh_Mobile_Data
(
    errbuf              OUT NOCOPY  VARCHAR2,
    retcode             OUT NOCOPY  NUMBER
) ;

END JTM_COMMON_CON_PROG_PUB;

 

/
