--------------------------------------------------------
--  DDL for Package IES_SVY_DPYLMENT_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_SVY_DPYLMENT_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: iesdpsts.pls 120.1 2005/06/16 11:14:47 appldev  $ */
----------------------------------------------------------------------------------------------------------
-- Procedure
--   Submit_Deployment

-- PURPOSE
--   Submit Deployment to Concurrent Manager at the specified_time.
--
-- PARAMETERS

-- NOTES
-- created rrsundar 05/03/2000
---------------------------------------------------------------------------------------------------------
Procedure  Update_Deployment_Status
(
    ERRBUF                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2                                ,
    RETCODE                OUT NOCOPY /* file.sql.39 change */ BINARY_INTEGER
);
END IES_SVY_DPYLMENT_STATUS_PVT;

 

/
