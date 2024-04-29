--------------------------------------------------------
--  DDL for Package Body MRP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_UTIL" AS
/* $Header: MRPUTILB.pls 115.2 2004/08/05 18:36:07 skanta ship $  */

-- log messaging if debug is turned on
PROCEDURE MRP_DEBUG(buf  IN  VARCHAR2)
IS
BEGIN
  -- if MRP:Debug profile is not set return
  IF (G_MRP_DEBUG <> 'Y') THEN
    return;
  END IF;
  -- add a line of text to the log file and

  FND_FILE.PUT_LINE(FND_FILE.LOG, buf);

  return;

EXCEPTION
  WHEN OTHERS THEN
    return;
END MRP_DEBUG;

-- log messaging irrespective of whether debug is turned on or off
PROCEDURE MRP_LOG(buf  IN  VARCHAR2)
IS
BEGIN

  -- log the message
  FND_FILE.PUT_LINE(FND_FILE.LOG, buf);

  return;

EXCEPTION
  WHEN OTHERS THEN
    return;
END MRP_LOG;

-- out messaging
PROCEDURE MRP_OUT(buf IN VARCHAR2)
IS
BEGIN
    -- add a line of text to the output file and
	-- add the line terminator
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, buf);
	FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);

    return;

EXCEPTION
  WHEN OTHERS THEN
	return;
END MRP_OUT;

--
FUNCTION lookup_desc(l_type in mfg_lookups.lookup_type%TYPE,
                        l_code in mfg_lookups.lookup_code%TYPE) RETURN VARCHAR2 IS

    CURSOR cur_desc(x_type mfg_lookups.lookup_type%TYPE,
                    x_code mfg_lookups.lookup_code%TYPE)
    IS
     SELECT meaning
     FROM mfg_lookups
     WHERE lookup_code = x_code
     AND lookup_type = x_type;

    l_desc mfg_lookups.meaning%TYPE;
BEGIN
        IF l_code is null then return null;
        ELSE
            open cur_desc(l_type,l_code);
            fetch cur_desc into l_desc;
            close cur_desc;
        END IF;
        RETURN l_desc;
EXCEPTION
   WHEN OTHERS THEN
      RETURN null;
END lookup_desc;

END MRP_UTIL;

/
