--------------------------------------------------------
--  DDL for Package Body OEXCYMCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXCYMCA" AS
/* $Header: OEXCYCAB.pls 115.1 99/07/16 08:12:15 porting shi $ */
  PROCEDURE GET_RESULT_COLUMN (P_RESULT_TABLE IN VARCHAR2, RESULT_COLUMN OUT VARCHAR2) IS
    I          INTEGER := 1;
    QUALIFIER  VARCHAR2 (10);
    DUMMY      CHAR (1);

    BEGIN
      RESULT_COLUMN := NULL;
      WHILE I < 29 LOOP
        I := I + 1;
        QUALIFIER := 'S' || TO_CHAR (I);

        SELECT NULL
        INTO   DUMMY
        FROM   SO_ACTIONS
        WHERE  RESULT_COLUMN = QUALIFIER
          AND  RESULT_TABLE  = P_RESULT_TABLE;
      END LOOP;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RESULT_COLUMN := QUALIFIER;
    END GET_RESULT_COLUMN;
END OEXCYMCA;

/
