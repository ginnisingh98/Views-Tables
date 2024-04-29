--------------------------------------------------------
--  DDL for Package JTM_MASTER_CONC_PROG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_MASTER_CONC_PROG_PUB" AUTHID CURRENT_USER AS
/* $Header: jtmpcons.pls 120.3 2005/12/30 11:32:56 utekumal noship $ */
-- Start of Comments
--
-- NAME
--   JTM_MASTER_CONC_PROG_PUB
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
    retcode             OUT NOCOPY  NUMBER,
    Category_Type       IN    VARCHAR2
) ;

END JTM_MASTER_CONC_PROG_PUB;

 

/
