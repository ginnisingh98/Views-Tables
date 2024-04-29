--------------------------------------------------------
--  DDL for Package Body EDW_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MESSAGE_S" AS
/* $Header: EDWCOMSB.pls 115.4 99/11/01 14:04:31 porting ship    $*/
PROCEDURE SQL_ERROR(routine IN varchar2 ,
                    location IN varchar2,
                    error_code IN number) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := routine;
          g_location := location;

          FND_MESSAGE.set_name('BIS', 'EDW_ALL_SQL_ERROR');
          FND_MESSAGE.set_token('ROUTINE', g_routine);
          FND_MESSAGE.set_token('ERR_NUMBER', g_location);
          FND_MESSAGE.set_token('SQL_ERR', SQLERRM(error_code));
        END IF;

EXCEPTION
   WHEN OTHERS THEN RAISE;
END SQL_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';
          FND_MESSAGE.set_name('BIS',error_name);
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('BIS',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('BIS',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          IF (token2 is not NULL and value2 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token2,value2);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2,
                    token3 IN varchar2,
                    value3 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('BIS',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          IF (token2 is not NULL and value2 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token2,value2);
          END IF;

          IF (token3 is not NULL and value3 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token3,value3);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_ERROR(error_name IN varchar2,
                    token1 IN varchar2,
                    value1 IN varchar2,
                    token2 IN varchar2,
                    value2 IN varchar2,
                    token3 IN varchar2,
                    value3 IN varchar2,
                    token4 IN varchar2,
                    value4 IN varchar2) IS
BEGIN
        IF (g_routine is NULL) THEN
          g_routine  := 'ERROR';

          FND_MESSAGE.set_name('BIS',error_name);

          IF (token1 is not NULL and value1 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token1,value1);
          END IF;

          IF (token2 is not NULL and value2 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token2,value2);
          END IF;

          IF (token3 is not NULL and value3 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token3,value3);
          END IF;

          IF (token4 is not NULL and value4 is not null) THEN
            FND_MESSAGE.SET_TOKEN(token4,value4);
          END IF;

          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_ERROR;

PROCEDURE APP_SET_NAME(error_name IN varchar2) IS
BEGIN
        IF (g_routine  is null) THEN
          g_routine  := 'ERROR';
          FND_MESSAGE.set_name('BIS',error_name);
        END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END APP_SET_NAME;

PROCEDURE clear IS
BEGIN
  g_routine  := NULL;
  g_location := NULL;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END CLEAR;

PROCEDURE SQL_SHOW_ERROR IS
BEGIN
null;
/*	dbms_output.put_line ('Error Occured in routine : ' ||
		g_routine || ' - Location : ' || g_location);
*/
EXCEPTION
  WHEN OTHERS THEN RAISE;
END SQL_SHOW_ERROR;

END EDW_MESSAGE_S;

/
