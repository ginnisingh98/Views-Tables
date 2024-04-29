--------------------------------------------------------
--  DDL for Package OZF_AUTO_WRITEOFF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AUTO_WRITEOFF_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvcwos.pls 120.2 2005/12/02 04:59:54 kdhulipa ship $ */

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_Auto_Writeoff_Data
--
-- PURPOSE
--    Populate Claims for Auto Write offs and call appropriate API to
--    perform auto write off process.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Populate_Auto_Writeoff_Data(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY NUMBER,
    p_org_id           IN  NUMBER        DEFAULT NULL,
    p_claim_class      IN  VARCHAR2      DEFAULT NULL,
    p_cust_account_id  IN  NUMBER        DEFAULT NULL,
    p_claim_type_id    IN  NUMBER        DEFAULT NULL,
    p_reason_code_id   IN  NUMBER        DEFAULT NULL
);



END OZF_AUTO_WRITEOFF_PVT;

 

/
