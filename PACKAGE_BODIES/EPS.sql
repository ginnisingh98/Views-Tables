--------------------------------------------------------
--  DDL for Package Body EPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EPS" AS
/* $Header: epsuserb.pls 115.2 2002/11/08 19:08:18 dkang ship $ */
  --
  --  Get error text
  --
  FUNCTION  getErrorMsg(status  NUMBER)
            RETURN VARCHAR2 IS
    msg  VARCHAR2(2000) := '' ;
  BEGIN

    IF xrbGetMessage(status, msg, 2000) = 0 THEN
      msg := 'Unknown error code or message file missing' ;
    END IF;
    RETURN msg ;

  END getErrorMsg ;

  --
  -- Query express
  --
  FUNCTION query (express_server VARCHAR2,
                  qry0  VARCHAR2,
                  qry1  VARCHAR2,
                  qry2  VARCHAR2,
                  qry3  VARCHAR2,
                  qry4  VARCHAR2,
                  qry5  VARCHAR2,
                  qry6  VARCHAR2,
                  qry7  VARCHAR2,
                  qry8  VARCHAR2,
                  qry9  VARCHAR2) RETURN EPS_express_list_t AS
    report_id NUMBER := 0;
    t     EPS_express_list_t := EPS_express_list_t();
    i     NUMBER := 1;
    status NUMBER := 0;
    map   VARCHAR2(100)  := '';
    buffer VARCHAR2(4000) := '';
    nrows NUMBER := 0;
    ncols NUMBER := 0;
  BEGIN
    --
    -- Generate a unique id for the query
    --
    SELECT EPS_report_id.NEXTVAL
      INTO report_id
      FROM DUAL;

    --
    -- Prepare the query
    --
    status := XPPrepare(report_id, express_server, qry0) ;
    IF status <> 0 THEN
      DECLARE
         msg  VARCHAR2(2000);
         BEGIN
             msg := getErrorMsg(status) ;
             RAISE_APPLICATION_ERROR(-status, msg);
         END;
      RETURN t;
    END IF;

    --
    -- Fetch from the query
    --
    DECLARE
      buffer_size NUMBER := 4000;
      buffer_ptr  NUMBER := 0;
      obj         EPS_express_t := EPS_express_t(NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL,
                                                     NULL,NULL,NULL,NULL,NULL);
      curr_row    NUMBER := 0;
    BEGIN
      LOOP
        --
        -- Fetch N Rows
        --
        status := XPFetchN(report_id, buffer_size, buffer, ncols, nrows);

        --
        -- Put the rows into the table of objects
        --
        IF (status = 1403 OR status = 0) AND
            nrows > 0
        THEN
          --
          -- Parse each row
          --
          curr_row   := 1;
          buffer_ptr := 1;
          t.EXTEND(nrows);

          LOOP
            t(i) := ParseRow(buffer,buffer_size,buffer_ptr,ncols,nrows);
            i := i + 1;
            curr_row := curr_row + 1;

            IF curr_row > nrows THEN
              EXIT; -- LOOP
            END IF;
          END LOOP;
        ELSE
          DECLARE
            msg  VARCHAR2(2000);
          BEGIN
            IF status = 1403 THEN
              EXIT ;     -- LOOP
            END IF ;
            msg := getErrorMsg(status);
            RAISE_APPLICATION_ERROR(-status, msg);
          END;
        END IF;

        IF status = 1403 THEN
          EXIT; -- LOOP
        END IF;
      END LOOP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    --
    -- Return the results
    --
    RETURN t;
  END;

  --
  -- Express DLL callout functions
  --
  --
  -- OCI Callout - XPPrepare - Prepare an Express Query
  --
  FUNCTION XPPrepare(in_report_id      IN NATURAL,
                     in_express_server IN VARCHAR2,
                     in_qry            IN VARCHAR2)
                    RETURN NATURAL AS
  EXTERNAL
  LIBRARY EPS_lib
  NAME "XPPrepare"
  LANGUAGE C
  WITH CONTEXT;

  --
  -- OCI Callout - XPFetch - Fetch a row from an Express Query
  --
  -- Return 0 SUCCESS else Exception return code if fail
  --
  FUNCTION XPFetch(in_report_id NATURAL,
                   c0           IN OUT NOCOPY VARCHAR2,
                   c1           IN OUT NOCOPY VARCHAR2,
                   c2           IN OUT NOCOPY VARCHAR2,
                   c3           IN OUT NOCOPY VARCHAR2,
                   c4           IN OUT NOCOPY VARCHAR2,
                   c5           IN OUT NOCOPY VARCHAR2,
                   c6           IN OUT NOCOPY VARCHAR2,
                   c7           IN OUT NOCOPY VARCHAR2,
                   c8           IN OUT NOCOPY VARCHAR2,
                   c9           IN OUT NOCOPY VARCHAR2,
                   c10          IN OUT NOCOPY VARCHAR2,
                   c11          IN OUT NOCOPY VARCHAR2,
                   c12          IN OUT NOCOPY VARCHAR2,
                   c13          IN OUT NOCOPY VARCHAR2,
                   c14          IN OUT NOCOPY VARCHAR2,
                   c15          IN OUT NOCOPY VARCHAR2,
                   c16          IN OUT NOCOPY VARCHAR2,
                   c17          IN OUT NOCOPY VARCHAR2,
                   c18          IN OUT NOCOPY VARCHAR2,
                   c19          IN OUT NOCOPY VARCHAR2,
                   c20          IN OUT NOCOPY VARCHAR2,
                   c21          IN OUT NOCOPY VARCHAR2,
                   c22          IN OUT NOCOPY VARCHAR2,
                   c23          IN OUT NOCOPY VARCHAR2,
                   c24          IN OUT NOCOPY VARCHAR2,
                   c25          IN OUT NOCOPY VARCHAR2,
                   c26          IN OUT NOCOPY VARCHAR2,
                   c27          IN OUT NOCOPY VARCHAR2,
                   c28          IN OUT NOCOPY VARCHAR2,
                   c29          IN OUT NOCOPY VARCHAR2,
                   c30          IN OUT NOCOPY VARCHAR2,
                   c31          IN OUT NOCOPY VARCHAR2,
                   c32          IN OUT NOCOPY VARCHAR2,
                   c33          IN OUT NOCOPY VARCHAR2,
                   c34          IN OUT NOCOPY VARCHAR2,
                   c35          IN OUT NOCOPY VARCHAR2,
                   c36          IN OUT NOCOPY VARCHAR2,
                   c37          IN OUT NOCOPY VARCHAR2,
                   c38          IN OUT NOCOPY VARCHAR2,
                   c39          IN OUT NOCOPY VARCHAR2)
                  RETURN NATURAL AS
  EXTERNAL
  LIBRARY EPS_lib
  NAME "XPFetch"
  LANGUAGE C
  WITH CONTEXT;

  --
  -- OCI Callout - XPFetchN - Fetch multiple rows from an Express Query
  --
  -- Return 0 SUCCESS else Exception return code if fail
  --
  FUNCTION XPFetchN(in_report_id NATURAL,
                    buffer_size  NATURAL,
                    buffer       IN OUT NOCOPY VARCHAR2,
                    num_cols     OUT NOCOPY NATURAL,
                    num_rows     OUT NOCOPY NATURAL)
                  RETURN NATURAL AS
  EXTERNAL
  LIBRARY EPS_lib
  NAME "XPFetchN"
  LANGUAGE C
  WITH CONTEXT;


  --
  -- OCI Callout - xrbGetMessage - Get EPS error message
  --
  FUNCTION xrbGetMessage(msgno       IN NATURAL,
                         buffer      IN OUT NOCOPY VARCHAR2,
                         bufsize     IN NATURAL)
                       RETURN NATURAL AS
  EXTERNAL
  LIBRARY EPS_lib
  NAME "xrbGetMessage"
  LANGUAGE C ;



  FUNCTION ParseRow(buffer      IN OUT NOCOPY VARCHAR2,
                    buffer_size IN NUMBER,
                    buffer_ptr  IN OUT NOCOPY NUMBER,
                    ncols       IN NUMBER,
                    nrows       IN NUMBER)
                  RETURN EPS_express_t IS
    t EPS_express_t := EPS_express_t(NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL,
                                         NULL,NULL,NULL,NULL,NULL);
  BEGIN
    IF ncols >= 1 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c0);
    END IF;
    IF ncols >= 2 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c1);
    END IF;
    IF ncols >= 3 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c2);
    END IF;
    IF ncols >= 4 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c3);
    END IF;
    IF ncols >= 5 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c4);
    END IF;
    IF ncols >= 6 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c5);
    END IF;
    IF ncols >= 7 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c6);
    END IF;
    IF ncols >= 8 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c7);
    END IF;
    IF ncols >= 9 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c8);
    END IF;
    IF ncols >= 10 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c9);
    END IF;
    IF ncols >= 11 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c10);
    END IF;
    IF ncols >= 12 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c11);
    END IF;
    IF ncols >= 13 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c12);
    END IF;
    IF ncols >= 14 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c13);
    END IF;
    IF ncols >= 15 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c14);
    END IF;
    IF ncols >= 16 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c15);
    END IF;
    IF ncols >= 17 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c16);
    END IF;
    IF ncols >= 18 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c17);
    END IF;
    IF ncols >= 19 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c18);
    END IF;
    IF ncols >= 20 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c19);
    END IF;
    IF ncols >= 21 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c20);
    END IF;
    IF ncols >= 22 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c21);
    END IF;
    IF ncols >= 23 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c22);
    END IF;
    IF ncols >= 24 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c23);
    END IF;
    IF ncols >= 25 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c24);
    END IF;
    IF ncols >= 26 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c25);
    END IF;
    IF ncols >= 27 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c26);
    END IF;
    IF ncols >= 28 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c27);
    END IF;
    IF ncols >= 29 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c28);
    END IF;
    IF ncols >= 30 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c29);
    END IF;
    IF ncols >= 31 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c30);
    END IF;
    IF ncols >= 32 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c31);
    END IF;
    IF ncols >= 33 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c32);
    END IF;
    IF ncols >= 34 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c33);
    END IF;
    IF ncols >= 35 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c34);
    END IF;
    IF ncols >= 36 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c35);
    END IF;
    IF ncols >= 37 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c36);
    END IF;
    IF ncols >= 38 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c37);
    END IF;
    IF ncols >= 39 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c38);
    END IF;
    IF ncols >= 40 THEN
      buffer_ptr := ParseCol(buffer,buffer_size,buffer_ptr,t.c39);
    END IF;
    RETURN t;
  END;

  FUNCTION ParseCol(buffer      IN OUT NOCOPY VARCHAR2,
                    buffer_size IN NUMBER,
                    buffer_ptr  IN NUMBER,
                    col_val     IN OUT NOCOPY VARCHAR2)
                  RETURN NUMBER IS
    buffer_ptr_new NUMBER := 0;
    buffer_ptr_old NUMBER := 0;
  BEGIN
    -- the column lies between single \,
    -- double \\s indicate a \ in the value and not a delimeter
      buffer_ptr_new := buffer_ptr;
    LOOP
      buffer_ptr_old := buffer_ptr_new;
      buffer_ptr_new := INSTR(buffer, '\', buffer_ptr_old, 1);

      --
      -- Test for error finding the \
      --
      IF buffer_ptr_new = 0 THEN
        DECLARE
          msg  VARCHAR2(2000);
        BEGIN
          msg := getErrorMsg(20013) ;
          RAISE_APPLICATION_ERROR(-20013, msg);
        END;
      END IF;

      --
      -- Copy the output
      --
      col_val := col_val || SUBSTR(buffer, buffer_ptr_old, buffer_ptr_new - buffer_ptr_old);

      buffer_ptr_new := buffer_ptr_new + LENGTH('\'); -- move past the \

      --
      -- Test for a \\
      --
      IF (buffer_ptr_new < buffer_size - 1) AND
          SUBSTR(buffer, buffer_ptr_new, 1) = '\'
      THEN
        col_val := col_val || '\';
        buffer_ptr_new := buffer_ptr_new + LENGTH('\');
      ELSE
        EXIT; -- LOOP;
      END IF;
    END LOOP;

    -- Check for encoded NA and empty measure string values

    IF  col_val = '__NULL' THEN
       col_val := NULL ;
    ELSIF col_val = '__EMPTY_STR' THEN
       col_val := '' ;
    END IF ;

    RETURN buffer_ptr_new;
  END;

END EPS;

/
