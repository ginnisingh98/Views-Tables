--------------------------------------------------------
--  DDL for Package IBC_CONTENT_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_CONTENT_SYNC_INDEX_PKG" AUTHID CURRENT_USER AS
/* $Header: ibcsyins.pls 120.3 2005/08/25 07:52:41 srrangar noship $ */

-- errbuf = err messages
-- retcode = 0 success, 1 = warning, 2=error

-- (TEXT)
PROCEDURE Sync_Text_Index (
  ERRBUF OUT NOCOPY VARCHAR2,
  RETCODE OUT NOCOPY NUMBER,
  BMODE IN VARCHAR2,
  pworker  IN NUMBER DEFAULT 0);

PROCEDURE Drop_Index(
  p_index_name IN VARCHAR,
  x_msg_error     OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2);
-- (TEXT) eof

PROCEDURE Request_Content_Sync_Index(
   x_request_id    OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2);

end IBC_CONTENT_SYNC_INDEX_PKG;


 

/
