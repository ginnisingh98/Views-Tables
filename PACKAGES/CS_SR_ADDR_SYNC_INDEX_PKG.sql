--------------------------------------------------------
--  DDL for Package CS_SR_ADDR_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_ADDR_SYNC_INDEX_PKG" AUTHID CURRENT_USER AS
/* $Header: csadsyis.pls 115.0 2003/12/10 22:11:56 aneemuch noship $ */

-- errbuf = err messages
-- retcode = 0 success, 1 = warning, 2=error

PROCEDURE Sync_All_Index (
   ERRBUF            OUT   NOCOPY   VARCHAR2,
   RETCODE           OUT   NOCOPY   NUMBER,
   BMODE             IN             VARCHAR2   default null);

PROCEDURE Sync_Address_Index  (
   ERRBUF            OUT   NOCOPY   VARCHAR2,
   RETCODE           OUT   NOCOPY   NUMBER,
   BMODE             IN             VARCHAR2);

end CS_SR_ADDR_SYNC_INDEX_PKG;

 

/
