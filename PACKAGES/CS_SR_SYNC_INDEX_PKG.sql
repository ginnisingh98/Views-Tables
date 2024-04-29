--------------------------------------------------------
--  DDL for Package CS_SR_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_SYNC_INDEX_PKG" AUTHID CURRENT_USER AS
/* $Header: cssrsyxs.pls 120.1 2005/08/29 23:31:34 aneemuch noship $ */

-- errbuf = err messages
-- retcode = 0 success, 1 = warning, 2=error

PROCEDURE Sync_All_Index (
   ERRBUF            OUT   NOCOPY   VARCHAR2,
   RETCODE           OUT   NOCOPY   NUMBER,
   BMODE             IN             VARCHAR2   default null);

PROCEDURE Sync_Summary_Index  (
   ERRBUF            OUT   NOCOPY   VARCHAR2,
   RETCODE           OUT   NOCOPY   NUMBER,
   BMODE             IN             VARCHAR2);

-- (TEXT)
PROCEDURE Sync_Text_Index (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY NUMBER,
  BMODE IN VARCHAR2,
  pindex_with IN VARCHAR2,
  pworker  IN NUMBER DEFAULT 0);

PROCEDURE Drop_Index(
  p_index_name IN VARCHAR,
  x_msg_error     OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2);

FUNCTION get_max_parallel_worker return number;

-- (TEXT) eof

end CS_SR_SYNC_INDEX_PKG;


 

/
