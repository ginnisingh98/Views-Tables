--------------------------------------------------------
--  DDL for Package FTP_IRC_ADI_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_IRC_ADI_MIGRATE" AUTHID CURRENT_USER AS
--$Header: ftpmgrts.pls 120.1 2006/02/23 00:26:01 appldev noship $

PROCEDURE migrateparameters (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
);

PROCEDURE deleteparameters (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
);

PROCEDURE migratehistrates (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
);

PROCEDURE deletehistrates (
 errbuf   OUT NOCOPY VARCHAR2,
 retcode  OUT NOCOPY VARCHAR2,
 p_int_rate_code IN NUMBER
);

-- Bobby Mathew -  20060223 - Bug : 5048839
TYPE FTP_MULTI_TABLE IS TABLE OF NUMBER;
FUNCTION FTP_MULTI_TABLE_F RETURN FTP_MULTI_TABLE PIPELINED;
-- Bobby Mathew -  20060223 - Bug : 5048839 END

END FTP_IRC_ADI_MIGRATE;

 

/
