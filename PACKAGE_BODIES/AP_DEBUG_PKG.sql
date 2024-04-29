--------------------------------------------------------
--  DDL for Package Body AP_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_DEBUG_PKG" AS
/* $Header: apdebugb.pls 120.1 2003/06/13 19:42:03 isartawi noship $ */

/* This procedure will split the message into 80 character chunks and print
it to the log or report file. */

PROCEDURE SPLIT (P_string IN VARCHAR2) IS

  stemp    VARCHAR2(80);
  nlength  NUMBER := 1;

BEGIN

  WHILE(length(P_string) >= nlength)
  LOOP

    -- M Sameen 21-FEB-2001 Bug 1645569
    -- Changed substr to substrb

    stemp := substrb(P_string, nlength, 80);
    fnd_file.put_line(FND_FILE.LOG, stemp);
    nlength := (nlength + 80);

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    -- AP_DEBUG_PKG.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM);
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END SPLIT;

/* This is an overloaded procedure to set the tokens and retrieve the fnd
   message and print it to the appropriate log/report file.
   In our pl/sql code, we generally report errors using this version of print
   and never go beyond token2 and its value. So, in order to preserve the
   defaulting order such that we did not have to give a lot of "commas",
   the P_called_online param was placed in that spot.
*/
PROCEDURE Print
       (
        P_debug                 IN      VARCHAR2,
        P_app_short_name        IN      VARCHAR2,
        P_message_name          IN      VARCHAR2,
        P_token1                IN      VARCHAR2,
        P_value1                IN      VARCHAR2 DEFAULT NULL,
        P_token2                IN      VARCHAR2 DEFAULT NULL,
        P_value2                IN      VARCHAR2 DEFAULT NULL,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE,
        P_token3                IN      VARCHAR2 DEFAULT NULL,
        P_value3                IN      VARCHAR2 DEFAULT NULL,
        P_token4                IN      VARCHAR2 DEFAULT NULL,
        P_value4                IN      VARCHAR2 DEFAULT NULL,
        P_token5                IN      VARCHAR2 DEFAULT NULL,
        P_value5                IN      VARCHAR2 DEFAULT NULL,
        P_token6                IN      VARCHAR2 DEFAULT NULL,
        P_value6                IN      VARCHAR2 DEFAULT NULL
       ) IS

BEGIN

  IF P_debug = 'Y' THEN

    fnd_message.set_name(P_app_short_name,P_message_name);

    IF ( P_token1 IS NOT NULL ) and ( P_value1 IS NOT NULL ) THEN
      fnd_message.set_token(P_token1,P_value1);
    END IF;

    IF ( P_token2 IS NOT NULL ) and ( P_value2 IS NOT NULL ) THEN
      fnd_message.set_token(P_token2,P_value2);
    END IF;

    IF ( P_token3 IS NOT NULL ) and ( P_value3 IS NOT NULL ) THEN
      fnd_message.set_token(P_token3,P_value3);
    END IF;

    IF ( P_token4 IS NOT NULL ) and ( P_value4 IS NOT NULL ) THEN
      fnd_message.set_token(P_token4,P_value4);
    END IF;

    IF ( P_token5 IS NOT NULL ) and ( P_value5 IS NOT NULL ) THEN
      fnd_message.set_token(P_token5,P_value5);
    END IF;

    IF ( P_token6 IS NOT NULL ) and ( P_value6 IS NOT NULL ) THEN
      fnd_message.set_token(P_token6,P_value6);
    END IF;

    IF (P_called_online = FALSE) THEN
      SPLIT(fnd_message.get);
    END IF;

  END IF;

END Print;

/* This is an overloaded procedure to split a message string into 132 character
strings. */

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_string                IN      VARCHAR2,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        ) IS

BEGIN

  IF (P_Debug = 'Y' AND P_called_online = FALSE) THEN
    SPLIT(P_string);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- AP_DEBUG_PKG.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM);
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;


/* This is an overloaded procedure to concatenate a given variable name and
the date value. */

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_name         IN      VARCHAR2,
        P_variable_value        IN      DATE,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        ) IS

BEGIN

  IF (P_Debug = 'Y' AND P_called_online = FALSE) THEN
    SPLIT(P_variable_name || ' = ' || to_char(P_variable_value,
                                                  'DD-MON-YYYY HH24:MI:SS'));
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- AP_DEBUG_PKG.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM);
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;

/* This is an overloaded procedure to concatenate a given variable name and
the number value. */

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_name         IN      VARCHAR2,
        P_variable_value        IN      NUMBER,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        ) IS

BEGIN

  IF (P_Debug = 'Y' AND P_called_online = FALSE) THEN
    SPLIT(P_variable_name || ' = ' || to_char(P_variable_value));
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- AP_DEBUG_PKG.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM);
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;

/* This is an overloaded procedure to concatenate a given variable name and
the string value. */

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_name         IN      VARCHAR2,
        P_variable_value        IN      VARCHAR2,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        ) IS

BEGIN

  IF (P_Debug = 'Y' AND P_called_online = FALSE) THEN
    SPLIT(P_variable_name || ' = ' || P_variable_value);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- AP_DEBUG_PKG.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM);
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;

/* This is an overloaded procedure to concatenate a given variable name and
the boolean value.  In the following proc, the variable_value is passed before
the variable_name to avoid matching signatures with the (second from top)
overloaded version of Print. */

PROCEDURE Print
        (
        P_debug                 IN      VARCHAR2,
        P_variable_value        IN      BOOLEAN,
        P_variable_name         IN      VARCHAR2,
        P_called_online         IN      BOOLEAN  DEFAULT FALSE
        ) IS

  vtemp  VARCHAR2(10) := 'FALSE';

BEGIN

  IF (P_Debug = 'Y' AND P_called_online = FALSE) THEN
    IF ( P_variable_value ) THEN
      vtemp := 'TRUE';
    ELSE
      vtemp := 'FALSE';
    END IF;

    SPLIT(P_variable_name || ' = ' || vtemp);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    -- AP_DEBUG_PKG.Print('Y','SQLAP','AP_DEBUG','ERROR',SQLERRM);
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END Print;

END AP_DEBUG_PKG;

/
