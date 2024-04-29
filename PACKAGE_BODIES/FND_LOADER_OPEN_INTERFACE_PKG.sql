--------------------------------------------------------
--  DDL for Package Body FND_LOADER_OPEN_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOADER_OPEN_INTERFACE_PKG" as
/* $Header: FNDOFACB.pls 120.1 2005/08/31 13:13:36 rsekaran noship $ */

--
-- Procedure
--   LOCK_BATCH
--
-- Purpose
--   Check to see if specific batch has been locked by other users, if not, try to lock it.
--
-- Arguments:
--   IN:
--	X_batch_id - Batch_id
--   OUT:
--      X_return_status:
--         0:	Success
--	   1:	Timed out
--	   2:   Deadlock
--	   3:   Parameter error
--	   4:   Do not own lock; cannot convert
--	   5:   Illegal lockhandle
--
procedure lock_batch
(
X_batch_id 	IN 	INTEGER,
X_return_status OUT 	NOCOPY	INTEGER
)
is
  l_lockhandle 		VARCHAR2(128);
  l_lock_request_status INTEGER;
begin
  DBMS_LOCK.ALLOCATE_UNIQUE(to_char(X_batch_id),l_lockhandle);
  X_return_status:=dbms_lock.request(lockhandle=>l_lockhandle,timeout=>1);
end;

--
-- Function
--   INSERT_BATCH
--
-- Purpose
--   Insert a batch of record into fnd_loader_open_interface table.
--   If all parameters are null, this function simply return a new batch_id.
--
-- Arguments:
--   IN:
--      X_LCT 		-- lct file name
--      X_LDT 		-- ldt file name
--      X_LOADER_MODE   -- UPLOAD,DOWNLOAD,UPLOAD_PARTIAL
--      X_ENTITY 	-- Entity name
--	X_PARAMS	-- optional parameters
--
FUNCTION INSERT_BATCH RETURN INTEGER is
  l_next_seq INTEGER;
BEGIN
  SELECT
    FND_LOADER_OPEN_INTERFACE_S.nextval
  INTO
    l_next_seq
  FROM
    dual;
  return l_next_seq;
END;


FUNCTION INSERT_BATCH
(
X_LCT             IN      FND_LCT_TAB,
X_LDT             IN      FND_LDT_TAB,
X_LOADER_MODE     IN      FND_LOADER_MODE_TAB,
X_ENTITY          IN      FND_ENTITY_TAB,
X_PARAMS          IN      FND_PARAMS_TAB
) RETURN INTEGER is
  l_next_seq	INTEGER;
  type l_seq_in_batch_TAB is table of NUMBER index by binary_integer;
  l_seq_in_batch l_seq_in_batch_TAB;
  indx integer;
BEGIN
  SELECT
    FND_LOADER_OPEN_INTERFACE_S.nextval
  INTO
    l_next_seq
  FROM
    dual;

  for i in 1..X_lct.count loop
    l_seq_in_batch(i):=i;
  END loop;

  BEGIN
    FOR i IN 1..X_lct.count LOOP
      indx := i; -- Store the index of the data being inserted, in case we need to print the exception message.
      INSERT INTO FND_LOADER_OPEN_INTERFACE
      (
        batch_id,
        seq_in_batch,
        lct,
        ldt,
        loader_mode,
        entity,params
      )
      VALUES
      (
        l_next_seq,
        l_seq_in_batch(i),
        X_LCT(i),
        X_LDT(i),
        X_LOADER_MODE(i),
        X_ENTITY(i),
        X_PARAMS(i)
      );
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(-20101,'INSERT_BATCH : Failed to insert element ' || to_char(indx) || ' of the batch into the table FND_LOADER_OPEN_INTERFACE.',true);
  end;
  return l_next_seq;
END;

--
-- Procedure
--  ADD_ROW_TO_BATCH
--
-- Purpose
--  Add a list of records to fnd_loader_open_interface table with given batch_id
--
-- Arguments:
--  IN:
--    X_BATCH_ID 	-- Batch_id
--    X_LCT     	-- lct name
--    X_LDT		-- ldt name
--    X_LOADER_MODE	-- UPLOAD,DOWNLOAD,UPLOAD_PARTIAL
--    X_ENTITY		-- Entity name
--    X_PARAMS		-- options parameters.
--
PROCEDURE ADD_ROW_TO_BATCH
(
X_BATCH_ID	  IN 	  INTEGER,
X_LCT             IN      FND_LCT_TAB,
X_LDT             IN      FND_LDT_TAB,
X_LOADER_MODE     IN      FND_LOADER_MODE_TAB,
X_ENTITY          IN      FND_ENTITY_TAB,
X_PARAMS          IN      FND_PARAMS_TAB
)  is
  l_max_seq_in_batch	INTEGER;
  type l_seq_in_batch_TAB is table of NUMBER index by binary_integer;
  l_seq_in_batch l_seq_in_batch_TAB;
  indx integer;
BEGIN

  SELECT
    nvl(MAX(SEQ_IN_BATCH),0)
  INTO
    l_max_seq_in_batch
  FROM
    FND_LOADER_OPEN_INTERFACE
  WHERE
    BATCH_ID=X_BATCH_ID;

  FOR i in 1..X_lct.count loop
    l_seq_in_batch(i):=i+l_max_seq_in_batch;
  END loop;


  BEGIN
      FOR i IN 1..X_lct.count LOOP
        indx := i; -- Store the index of the data being inserted, in case we need to print the exception message.
        INSERT INTO FND_LOADER_OPEN_INTERFACE
        (
          batch_id,
          seq_in_batch,
          lct,
          ldt,
          loader_mode,
          entity,params
        )
        VALUES
        (
          X_BATCH_ID,
          l_seq_in_batch(i),
          X_LCT(i),
          X_LDT(i),
          X_LOADER_MODE(i),
          X_ENTITY(i),
          X_PARAMS(i)
        );
      END LOOP;
      COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(-20201,'ADD_ROW_TO_BATCH : Failed to add element number ' || to_char(indx) || ' to the batch '|| to_char(X_BATCH_ID),true);
  END;
END ADD_ROW_TO_BATCH;

--
-- Procedure
--  ADD_ROW_TO_BATCH
--
-- Purpose
--  Add a record to fnd_loader_open_interface table with given batch_id
--
-- Arguments:
--  IN:
--    X_BATCH_ID 	-- Batch_id
--    X_LCT     	-- lct name
--    X_LDT		-- ldt name
--    X_LOADER_MODE	-- UPLOAD,DOWNLOAD,UPLOAD_PARTIAL
--    X_ENTITY		-- Entity name
--    X_PARAMS		-- options parameters.
--
PROCEDURE ADD_ROW_TO_BATCH
(
X_BATCH_ID	  IN 	  INTEGER,
X_LCT             IN      VARCHAR2,
X_LDT             IN      VARCHAR2,
X_LOADER_MODE     IN      VARCHAR2,
X_ENTITY          IN      VARCHAR2,
X_PARAMS          IN      VARCHAR2
)  is
  l_max_seq_in_batch	INTEGER;
BEGIN

  SELECT
    nvl(MAX(SEQ_IN_BATCH),0)
  INTO
    l_max_seq_in_batch
  FROM
    FND_LOADER_OPEN_INTERFACE
  WHERE
    BATCH_ID=X_BATCH_ID;

  begin
      INSERT INTO FND_LOADER_OPEN_INTERFACE
      (
        batch_id,
        seq_in_batch,
        lct,
        ldt,
        loader_mode,
        entity,params
      )
      values
      (
        X_BATCH_ID,
        l_max_seq_in_batch + 1,
        X_LCT,
        X_LDT,
        X_LOADER_MODE,
        X_ENTITY,
        X_PARAMS
      );
      commit;
  exception
    when others then
    raise_application_error(-20301,'ADD_ROW_TO_BATCH : Failed to add the job with lct file: ' || nvl(X_LCT,'NULL') || ' and ldt file : ' ||
                                    nvl(X_LDT,'NULL') || ' to the batch ' || TO_CHAR(X_BATCH_ID) ,true);
  end;
END ADD_ROW_TO_BATCH;

--
-- Procedure
--  DELETE_BATCH
--
-- Purpose
--  Purge record with specific batch_id from fnd_loader_open_interface table;
--
-- Arguments
--   IN:
--     X_BATCH_ID	-- Batch_id
--
PROCEDURE DELETE_BATCH(
  X_BATCH_ID        IN      INTEGER
) IS
BEGIN
  BEGIN
      DELETE FROM
        fnd_loader_open_interface
      WHERE
        batch_id=X_BATCH_ID;
      commit;
  EXCEPTION
     WHEN OTHERS THEN
        raise_application_error(-20401,'DELETE_BATCH : Failed to delete the batch : ' || to_char(X_BATCH_ID),true);
  END;
END DELETE_BATCH;

END FND_LOADER_OPEN_INTERFACE_PKG;

/
