--------------------------------------------------------
--  DDL for Package FND_LOADER_OPEN_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOADER_OPEN_INTERFACE_PKG" AUTHID CURRENT_USER as
/* $Header: FNDOFACS.pls 120.2 2005/08/31 13:13:04 rsekaran noship $ */

TYPE FND_LCT_TAB        is table of VARCHAR2(400) index by binary_integer;
TYPE FND_LDT_TAB        is table of VARCHAR2(400) index by binary_integer;
TYPE FND_BATCH_ID_TAB   is table of NUMBER index by binary_integer;
TYPE FND_SEQ_IN_BATCH_TAB is table of NUMBER index by binary_integer;
TYPE FND_LOADER_MODE_TAB is table of VARCHAR2(30) index by binary_integer;
TYPE FND_ENTITY_TAB     is table of VARCHAR2(30) index by binary_integer;
TYPE FND_PARAMS_TAB     is table of VARCHAR2(1000) index by binary_integer;

--
-- Function
--   INSERT_BATCH
--
-- Purpose
--   Insert a batch of record into fnd_loader_open_interface table.
--
-- Arguments:
--   IN:
--      X_LCT           -- lct file name
--      X_LDT           -- ldt file name
--      X_LOADER_MODE   -- UPLOAD,DOWNLOAD,UPLOAD_PARTIAL
--      X_ENTITY        -- Entity name
--      X_PARAMS        -- optional parameters
--
FUNCTION INSERT_BATCH RETURN INTEGER;

FUNCTION INSERT_BATCH
(
X_LCT             IN      FND_LCT_TAB ,
X_LDT             IN      FND_LDT_TAB ,
X_LOADER_MODE     IN      FND_LOADER_MODE_TAB,
X_ENTITY          IN      FND_ENTITY_TAB ,
X_PARAMS          IN      FND_PARAMS_TAB
) RETURN INTEGER ;

--
-- Procedure
--  DELETE_BATCH
--
-- Purpose
--  Purge record with specific batch_id from fnd_loader_open_interface table;
--
-- Arguments
--   IN:
--     X_BATCH_ID       -- Batch_id
--
PROCEDURE DELETE_BATCH(
X_BATCH_ID        IN      INTEGER
);

--
-- Procedure
--  ADD_ROW_TO_BATCH
--
-- Purpose
--  Add a list of records to fnd_loader_open_interface table with given batch_id
--
-- Arguments:
--  IN:
--    X_BATCH_ID        -- Batch_id
--    X_LCT             -- lct name
--    X_LDT             -- ldt name
--    X_LOADER_MODE     -- UPLOAD,DOWNLOAD,UPLOAD_PARTIAL
--    X_ENTITY          -- Entity name
--    X_PARAMS          -- options parameters.
--
PROCEDURE ADD_ROW_TO_BATCH
(
X_BATCH_ID	  IN	  INTEGER,
X_LCT             IN      FND_LCT_TAB,
X_LDT             IN      FND_LDT_TAB,
X_LOADER_MODE     IN      FND_LOADER_MODE_TAB,
X_ENTITY          IN      FND_ENTITY_TAB,
X_PARAMS          IN      FND_PARAMS_TAB
);


--
-- Procedure (Overloaded)
--  ADD_ROW_TO_BATCH
--
-- Purpose
--  Add a record to fnd_loader_open_interface table with given batch_id
--
-- Arguments:
--  IN:
--    X_BATCH_ID        -- Batch_id
--    X_LCT             -- lct name
--    X_LDT             -- ldt name
--    X_LOADER_MODE     -- UPLOAD,DOWNLOAD,UPLOAD_PARTIAL
--    X_ENTITY          -- Entity name
--    X_PARAMS          -- options parameters.
--
PROCEDURE ADD_ROW_TO_BATCH
(
X_BATCH_ID	  IN	  INTEGER,
X_LCT             IN      VARCHAR2,
X_LDT             IN      VARCHAR2,
X_LOADER_MODE     IN      VARCHAR2,
X_ENTITY          IN      VARCHAR2,
X_PARAMS          IN      VARCHAR2
);


--
-- Procedure
--   LOCK_BATCH
--
-- Purpose
--   Check to see if specific batch has been locked by other users, if not, try to lock it.
--
-- Arguments:
--   IN:
--      X_batch_id - Batch_id
--   OUT:
--      X_return_status:
--         0:   Success
--         1:   Timed out
--         2:   Deadlock
--         3:   Parameter error
--         4:   Do not own lock; cannot convert
--         5:   Illegal lockhandle
--
PROCEDURE LOCK_BATCH
(
X_BATCH_ID        IN      	INTEGER,
X_RETURN_STATUS   OUT 	NOCOPY  INTEGER
);

end FND_LOADER_OPEN_INTERFACE_PKG;

 

/
