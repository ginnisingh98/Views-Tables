--------------------------------------------------------
--  DDL for Package Body BNE_QUERY_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_QUERY_UTILS" AS
/* $Header: bnequeryutilsb.pls 120.2 2005/06/29 03:40:50 dvayro noship $ */

PROCEDURE VALIDATE_KEYS(P_APPLICATION_ID          IN NUMBER,
                        P_QUERY_CODE              IN VARCHAR2)
IS
BEGIN
  IF NOT BNE_INTEGRATOR_UTILS.IS_VALID_APPL_ID(P_APPLICATION_ID) THEN
    RAISE_APPLICATION_ERROR(-20000, TO_CHAR(P_APPLICATION_ID)||' is not a valid application id.');
  END IF;
  IF NOT BNE_INTEGRATOR_UTILS.IS_VALID_OBJECT_CODE(P_QUERY_CODE, 30) THEN
    RAISE_APPLICATION_ERROR(-20001, P_QUERY_CODE||' is not a valid code. Use A-Z, 0-9, _ characters only, and the code must be shorter than 30 characters in length.');
  END IF;
END VALIDATE_KEYS;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_SIMPLE_QUERY                                  --
--                                                                            --
--  DESCRIPTION: Procedure creates a Web ADI simple metadata query.           --
--               No Commit is done.                                           --
--               Throws application error 20000 if P_APPLICATION_ID is invalid--
--               Throws application error 20001 if P_QUERY_CODE is invalid    --
--               Throws application error 20002 if P_DESCRIPTION_COL and      --
--                 P_DESCRIPTION_COL_ALIAS are not both NULL/NON-NULL.        --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-Apr-04  DAGROVES  CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE CREATE_SIMPLE_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2,
                   P_ID_COL                  IN VARCHAR2,
                   P_ID_COL_ALIAS            IN VARCHAR2,
                   P_MEANING_COL             IN VARCHAR2,
                   P_MEANING_COL_ALIAS       IN VARCHAR2,
                   P_DESCRIPTION_COL         IN VARCHAR2,
                   P_DESCRIPTION_COL_ALIAS   IN VARCHAR2,
                   P_ADDITIONAL_COLS         IN VARCHAR2,
                   P_OBJECT_NAME             IN VARCHAR2,
                   P_ADDITIONAL_WHERE_CLAUSE IN VARCHAR2,
                   P_ORDER_BY_CLAUSE         IN VARCHAR2,
                   P_USER_NAME               IN VARCHAR2,
                   P_USER_ID                 IN NUMBER
                  )
IS
  X_ROWID                   VARCHAR2(2000);
  X_ADDITIONAL_WHERE_CLAUSE VARCHAR2(2000);
  X_OFFSET                  NUMBER;
  X_LOOP_CNT                NUMBER;
BEGIN
  VALIDATE_KEYS(P_APPLICATION_ID, P_QUERY_CODE);
  IF P_DESCRIPTION_COL IS     NULL AND P_DESCRIPTION_COL_ALIAS IS NOT NULL OR
     P_DESCRIPTION_COL IS NOT NULL AND P_DESCRIPTION_COL_ALIAS IS     NULL
  THEN
    RAISE_APPLICATION_ERROR(-20002, 'Require both DESCRIPTION_COL AND DESCRIPTION_COL_ALIAS or neither.');
  END IF;
  BNE_QUERIES_PKG.INSERT_ROW (
    X_ROWID                 => X_ROWID,
    X_APPLICATION_ID        => P_APPLICATION_ID,
    X_QUERY_CODE            => P_QUERY_CODE,
    X_OBJECT_VERSION_NUMBER => 1,
    X_QUERY_CLASS           => 'oracle.apps.bne.query.BneSimpleSQLQuery',
    X_USER_NAME             => P_USER_NAME,
    X_CREATION_DATE         => SYSDATE,
    X_CREATED_BY            => P_USER_ID,
    X_LAST_UPDATE_DATE      => SYSDATE,
    X_LAST_UPDATED_BY       => P_USER_ID,
    X_LAST_UPDATE_LOGIN     => 0);

  X_OFFSET := 1;
  X_ADDITIONAL_WHERE_CLAUSE := SUBSTR(P_ADDITIONAL_WHERE_CLAUSE, X_OFFSET, 2000);

  BNE_SIMPLE_QUERY_PKG.INSERT_ROW (
    X_ROWID                 => X_ROWID,
    X_APPLICATION_ID        => P_APPLICATION_ID,
    X_QUERY_CODE            => P_QUERY_CODE,
    X_OBJECT_VERSION_NUMBER => 1,
    X_ID_COL                => P_ID_COL,
    X_ID_COL_ALIAS          => P_ID_COL_ALIAS,
    X_MEANING_COL           => P_MEANING_COL,
    X_MEANING_COL_ALIAS     => P_MEANING_COL_ALIAS,
    X_DESCRIPTION_COL       => P_DESCRIPTION_COL,
    X_DESCRIPTION_COL_ALIAS => P_DESCRIPTION_COL_ALIAS,
    X_ADDITIONAL_COLS       => P_ADDITIONAL_COLS,
    X_OBJECT_NAME           => P_OBJECT_NAME,
    X_ADDITIONAL_WHERE_CLAUSE => X_ADDITIONAL_WHERE_CLAUSE,
    X_ORDER_BY_CLAUSE       => P_ORDER_BY_CLAUSE,
    X_CREATION_DATE         => SYSDATE,
    X_CREATED_BY            => P_USER_ID,
    X_LAST_UPDATE_DATE      => SYSDATE,
    X_LAST_UPDATED_BY       => P_USER_ID,
    X_LAST_UPDATE_LOGIN     => 0);

  X_LOOP_CNT := 1;
  X_OFFSET                  := X_OFFSET + 2000;
  X_ADDITIONAL_WHERE_CLAUSE := SUBSTR(P_ADDITIONAL_WHERE_CLAUSE, X_OFFSET, 2000);

  WHILE X_ADDITIONAL_WHERE_CLAUSE IS NOT NULL
  LOOP
    BNE_RAW_QUERY_PKG.INSERT_ROW (
      X_ROWID                 => X_ROWID,
      X_APPLICATION_ID        => P_APPLICATION_ID,
      X_QUERY_CODE            => P_QUERY_CODE,
      X_SEQUENCE_NUM          => X_LOOP_CNT,
      X_OBJECT_VERSION_NUMBER => 1,
      X_QUERY                 => X_ADDITIONAL_WHERE_CLAUSE,
      X_CREATION_DATE         => SYSDATE,
      X_CREATED_BY            => P_USER_ID,
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => P_USER_ID,
      X_LAST_UPDATE_LOGIN     => 0);

    X_OFFSET                  := X_OFFSET + 2000;
    X_ADDITIONAL_WHERE_CLAUSE := SUBSTR(P_ADDITIONAL_WHERE_CLAUSE, X_OFFSET, 2000);
    X_LOOP_CNT                := X_LOOP_CNT + 1;
  END LOOP;

END CREATE_SIMPLE_QUERY;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_RAW_QUERY                                     --
--                                                                            --
--  DESCRIPTION: Procedure creates a Web ADI raw metadata query.              --
--               No Commit is done.                                           --
--               Throws application error 20000 if P_APPLICATION_ID is invalid--
--               Throws application error 20001 if P_QUERY_CODE is invalid    --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-Apr-04  DAGROVES  CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE CREATE_RAW_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2,
                   P_QUERY                   IN VARCHAR2,
                   P_USER_NAME               IN VARCHAR2,
                   P_USER_ID                 IN NUMBER
                  )
IS
  X_ROWID      VARCHAR2(2000);
  X_QUERY      VARCHAR2(2000);
  X_OFFSET     NUMBER;
  X_LOOP_CNT   NUMBER;
BEGIN
  VALIDATE_KEYS(P_APPLICATION_ID, P_QUERY_CODE);
  BNE_QUERIES_PKG.INSERT_ROW (
    X_ROWID                 => X_ROWID,
    X_APPLICATION_ID        => P_APPLICATION_ID,
    X_QUERY_CODE            => P_QUERY_CODE,
    X_OBJECT_VERSION_NUMBER => 1,
    X_QUERY_CLASS           => 'oracle.apps.bne.query.BneRawSQLQuery',
    X_USER_NAME             => P_USER_NAME,
    X_CREATION_DATE         => SYSDATE,
    X_CREATED_BY            => P_USER_ID,
    X_LAST_UPDATE_DATE      => SYSDATE,
    X_LAST_UPDATED_BY       => P_USER_ID,
    X_LAST_UPDATE_LOGIN     => 0);

  X_OFFSET   := 1;
  X_LOOP_CNT := 1;
  X_QUERY := SUBSTR(P_QUERY, X_OFFSET, 2000);

  WHILE X_QUERY IS NOT NULL
  LOOP
    BNE_RAW_QUERY_PKG.INSERT_ROW (
      X_ROWID                 => X_ROWID,
      X_APPLICATION_ID        => P_APPLICATION_ID,
      X_QUERY_CODE            => P_QUERY_CODE,
      X_SEQUENCE_NUM          => X_LOOP_CNT,
      X_OBJECT_VERSION_NUMBER => 1,
      X_QUERY                 => X_QUERY,
      X_CREATION_DATE         => SYSDATE,
      X_CREATED_BY            => P_USER_ID,
      X_LAST_UPDATE_DATE      => SYSDATE,
      X_LAST_UPDATED_BY       => P_USER_ID,
      X_LAST_UPDATE_LOGIN     => 0);

    X_OFFSET                  := X_OFFSET + 2000;
    X_QUERY := SUBSTR(P_QUERY, X_OFFSET, 2000);
    X_LOOP_CNT                := X_LOOP_CNT + 1;
  END LOOP;
END CREATE_RAW_QUERY;

--------------------------------------------------------------------------------
--  PROCEDURE:           CREATE_JAVA_QUERY                                    --
--                                                                            --
--  DESCRIPTION: Procedure creates a Web ADI java query.                      --
--               No Commit is done.                                           --
--               Throws application error 20000 if P_APPLICATION_ID is invalid--
--               Throws application error 20001 if P_QUERY_CODE is invalid    --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-Apr-04  DAGROVES  CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE CREATE_JAVA_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2,
                   P_QUERY_CLASS             IN VARCHAR2,
                   P_USER_NAME               IN VARCHAR2,
                   P_USER_ID                 IN NUMBER
                  )
IS
  X_ROWID VARCHAR2(2000);
BEGIN
  VALIDATE_KEYS(P_APPLICATION_ID, P_QUERY_CODE);

  BNE_QUERIES_PKG.INSERT_ROW (
    X_ROWID                 => X_ROWID,
    X_APPLICATION_ID        => P_APPLICATION_ID,
    X_QUERY_CODE            => P_QUERY_CODE,
    X_OBJECT_VERSION_NUMBER => 1,
    X_QUERY_CLASS           => P_QUERY_CLASS,
    X_USER_NAME             => P_USER_NAME,
    X_CREATION_DATE         => SYSDATE,
    X_CREATED_BY            => P_USER_ID,
    X_LAST_UPDATE_DATE      => SYSDATE,
    X_LAST_UPDATED_BY       => P_USER_ID,
    X_LAST_UPDATE_LOGIN     => 0);

END CREATE_JAVA_QUERY;

--------------------------------------------------------------------------------
--  PROCEDURE:           DELETE_QUERY                                         --
--                                                                            --
--  DESCRIPTION: Procedure deletes a Web ADI query.                           --
--               No Commit is done.                                           --
--               Throws application error 20000 if P_APPLICATION_ID is invalid--
--               Throws application error 20001 if P_QUERY_CODE is invalid    --
--                                                                            --
--  PARAMETERS:                                                               --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date       Username  Description                                          --
--  22-Apr-04  DAGROVES  CREATED                                              --
--------------------------------------------------------------------------------
PROCEDURE DELETE_QUERY
                  (P_APPLICATION_ID          IN NUMBER,
                   P_QUERY_CODE              IN VARCHAR2
                  )
IS
BEGIN
  VALIDATE_KEYS(P_APPLICATION_ID, P_QUERY_CODE);

  DELETE FROM BNE_QUERIES_B    WHERE APPLICATION_ID = P_APPLICATION_ID AND QUERY_CODE = P_QUERY_CODE;
  DELETE FROM BNE_QUERIES_TL   WHERE APPLICATION_ID = P_APPLICATION_ID AND QUERY_CODE = P_QUERY_CODE;
  DELETE FROM BNE_SIMPLE_QUERY WHERE APPLICATION_ID = P_APPLICATION_ID AND QUERY_CODE = P_QUERY_CODE;
  DELETE FROM BNE_RAW_QUERY    WHERE APPLICATION_ID = P_APPLICATION_ID AND QUERY_CODE = P_QUERY_CODE;
END DELETE_QUERY;


END BNE_QUERY_UTILS;

/
