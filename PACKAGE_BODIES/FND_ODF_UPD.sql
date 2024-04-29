--------------------------------------------------------
--  DDL for Package Body FND_ODF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ODF_UPD" AS
/* $Header: fndpoupb.pls 115.6 2004/03/12 19:43:42 bhthiaga noship $ */
PROCEDURE odfupd_row (p_selst           IN VARCHAR2,
                      p_updst           IN VARCHAR2,
                      p_errorCode      OUT NOCOPY VARCHAR2,
                      p_retmsg         OUT NOCOPY VARCHAR2)
IS
/*  p_selSt : The select statement which return the rowids of all
 *            the rows that have a null value.
 *  p_updSt : The update statement which fills the null values with
 *            some default value.
 */
l_rowIdBulk  DBMS_SQL.Varchar2_Table; -- Array to hold the rowids.
curSel       NUMBER;                  -- Cursor for select statement
curUpd       NUMBER;                  -- Cursor for update statement
dummy        NUMBER;                  -- Dummy number
ret          NUMBER;                  -- Variable to hold the no. of rows processed.
snapshot_old EXCEPTION;
PRAGMA       EXCEPTION_INIT(snapshot_old, -1555); -- Define the Exception for
                                                  -- snapshot too old problem

BEGIN


  /* steps:
   *   Parse the dynamic query
   *   Bind an array to hold the selected rowid.
   *   Execute the query to get the data to buffer.
   */
  curSel := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(curSel, p_selSt, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_ARRAY(curSel, 1 , l_rowIdBulk, 100, 0);
  ret := DBMS_SQL.EXECUTE(curSel);

  /* Create the cursor for the update statement.
   * The dynamic update query is parsed.
   */
  curUpd := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(curUpd,p_updst,DBMS_SQL.NATIVE);


  LOOP
     -- Fetch the next batch of rows into buffer.
     ret := DBMS_SQL.FETCH_ROWS(curSel);

        if ( ret > 0 ) then

          /* Snapshot too old problem.
           * We try update for a max of 6 times.
           */
          FOR j IN 1..6 LOOP
          BEGIN
                /* Read the column value into the array */
                DBMS_SQL.COLUMN_VALUE(curSel, 1, l_rowIdBulk);

                /* Bind the array to the update cursor */
                DBMS_SQL.BIND_ARRAY(curUpd, ':1',l_rowIdBulk );
                dummy := DBMS_SQL.EXECUTE(curUpd);


                COMMIT;
                EXIT; -- no errors so break out of the inner for loop
              EXCEPTION
                 when snapshot_old then
                    null;
                 when OTHERS THEN
                    RAISE;

          END;
          END LOOP;

        end if;

   EXIT when ret <> 100; -- Exit when not 100 records is returned.
   END LOOP;
   /* Close both the cursors. */
   DBMS_SQL.CLOSE_CURSOR(curUpd);
   DBMS_SQL.CLOSE_CURSOR(curSel);

EXCEPTION
  when others then
      if DBMS_SQL.IS_OPEN(curUpd) then
          DBMS_SQL.CLOSE_CURSOR(curUpd);
      end if;
      if DBMS_SQL.IS_OPEN(curSel) then
          DBMS_SQL.CLOSE_CURSOR(curSel);
      end if;
      raise;
end odfupd_row;
end fnd_odf_upd;

/
