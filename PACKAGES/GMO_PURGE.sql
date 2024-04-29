--------------------------------------------------------
--  DDL for Package GMO_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_PURGE" AUTHID CURRENT_USER AS
/* $Header: GMOVPRGS.pls 120.0 2005/09/21 06:08 bchopra noship $ */

-- Cleans the device temporary data
PROCEDURE PURGE_DEVICE_DATA(P_END_DATE  IN DATE,
                            P_TRUNCATE_TABLE IN VARCHAR2,
                            P_COMMIT IN VARCHAR2);
-- Cleans the instruction temporary data
PROCEDURE PURGE_INSTRUCTION_DATA(P_END_DATE IN DATE,
                            P_TRUNCATE_TABLE IN VARCHAR2,
                            P_COMMIT IN VARCHAR2);

-- Clean all GMO temporary data
PROCEDURE PURGE_ALL(P_END_DATE IN DATE,
                    P_TRUNCATE_TABLE IN VARCHAR2,
                    P_COMMIT IN VARCHAR2);
--
-- PURGE_ALL
--   Concurrent Program version of PURGE_ALL
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   P_MODULE_NAME default null for all modules i.e. DEVICE and INSTRUCTION
--   P_AGE Minimum age of data to purge, default to 1 in concurrent program.
--  P_TRUNCATE_TABLE Y or N to indicate truncation of table instead of delete

PROCEDURE PURGE_ALL(ERRBUF       OUT NOCOPY VARCHAR2,
                    RETCODE      OUT NOCOPY VARCHAR2,
                    P_MODULE_NAME IN VARCHAR2 DEFAULT NULL,
                    P_AGE    IN VARCHAR2 ,
                    P_TRUNCATE_TABLE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.NO);


END GMO_PURGE;

 

/
