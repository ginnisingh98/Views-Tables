--------------------------------------------------------
--  DDL for Package QA_DBLINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_DBLINK_PKG" AUTHID CURRENT_USER AS
/* $Header: qadblinks.pls 120.1.12010000.1 2008/07/25 09:19:17 appldev ship $ */
    --
    -- Wrapper procedure to create or drop the index.
    -- This procedure is the entry point for this package
    -- through the concurrent program 'Manage Collection
    -- element indexes'. This wrapper procedure is attached
    -- to the QADBLINK executable.
    -- argument1 -> Server Type : Server Type for Device Integration. 1 - Sensor Edge Server, 2- OPC Server (Third Party)
    -- dummy     -> Dummy Parameter : To handle Enabling/Disabling of SDR specific fields based on Server Type.
    -- argument2 -> SDR DB Link Name : 'Create a dblink using this name. If already existant then raise an error'.
    -- argument3 -> User Name for connecting to SDR database.
    -- argument4 -> Password for connecting to SDR database for the user name specified in argument2.
    -- argument5 -> Connection Descriptor (The entire TNS Entry of the SDR Database instance).
    --
    PROCEDURE wrapper(
        errbuf    OUT NOCOPY VARCHAR2,
        retcode   OUT NOCOPY NUMBER,
        argument1            VARCHAR2,
        dummy                NUMBER,
        argument2            VARCHAR2,
        argument3            VARCHAR2,
        argument4            VARCHAR2,
        argument5            VARCHAR2);

END qa_dblink_pkg;

/
