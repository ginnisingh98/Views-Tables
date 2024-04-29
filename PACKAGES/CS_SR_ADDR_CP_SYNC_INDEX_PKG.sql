--------------------------------------------------------
--  DDL for Package CS_SR_ADDR_CP_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_ADDR_CP_SYNC_INDEX_PKG" AUTHID CURRENT_USER AS
/* $Header: csadsyns.pls 115.0 2003/12/10 22:12:25 aneemuch noship $ */

/* errbuf = err messages
   retcode = 0 success, 1 = warning, 2=error
*/

PROCEDURE Sync_All_Index (ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY NUMBER,
  BMODE IN VARCHAR2 default null);

end CS_SR_ADDR_CP_SYNC_INDEX_PKG;

 

/
