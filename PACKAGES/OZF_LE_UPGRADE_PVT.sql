--------------------------------------------------------
--  DDL for Package OZF_LE_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_LE_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcles.pls 120.1 2005/10/10 04:28:49 kdhulipa noship $ */

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Process
--
-- PURPOSE
--    Populate Claims for Legal Entity and call appropriate API to
--    perform legal entity stamping process.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Process(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY NUMBER,
    p_org_id           IN  NUMBER        DEFAULT NULL
);

END OZF_LE_UPGRADE_PVT;

 

/
