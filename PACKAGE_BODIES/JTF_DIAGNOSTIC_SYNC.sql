--------------------------------------------------------
--  DDL for Package Body JTF_DIAGNOSTIC_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGNOSTIC_SYNC" as
/* $Header: jtfdiagsyncb.pls 115.1 2003/07/30 00:48:16 navkumar noship $ */
PROCEDURE diagSyncAll
IS
  key1    JTF_DIAGNOSTIC_CMAP.appName%TYPE;
  key2    JTF_DIAGNOSTIC_CMAP.groupName%TYPE;
  key3    JTF_DIAGNOSTIC_CMAP.testClassName%TYPE;
  classList JTF_DIAGNOSTIC_LOG.versions%TYPE;
  CURSOR diagnose IS
    select
      appName,
      groupName,
      testClassName,
      versions
    from
      JTF_DIAGNOSTIC_LOG;
  entries INTEGER := 0;
BEGIN
  OPEN diagnose;
  LOOP
    FETCH diagnose into key1, key2, key3, classList;
    EXIT WHEN diagnose%NOTFOUND;
    entries := entries+diagsync(key1, key2, key3, classList);
  END LOOP;
  CLOSE diagnose;
END diagSyncAll;

FUNCTION diagsync(	key1 JTF_DIAGNOSTIC_CMAP.appName%TYPE,
			key2 JTF_DIAGNOSTIC_CMAP.groupName%TYPE,
			key3 JTF_DIAGNOSTIC_CMAP.testClassName%TYPE,
			classList JTF_DIAGNOSTIC_LOG.versions%TYPE)
RETURN INTEGER IS
  entries INTEGER := 0;
  x INTEGER := 0;
  prev INTEGER;
  className JTF_DIAGNOSTIC_CMAP.className%TYPE;
  parseState INTEGER := -1;
  parseString VARCHAR2(20);
BEGIN
  -- entries := entries+diagentry(key1, key2, key3, key3);
  delete from JTF_DIAGNOSTIC_CMAP
  where
	appName = key1
  and	groupName = key2
  and	testClassName = key3;

  IF(classList IS NULL)
  THEN
    return entries;
  END IF;

  LOOP
    IF(parseState = -1) THEN
      parseState := 0;
      parseString := '!#DIAGPAIR#!';
      prev := x+1;
    ELSIF(parseState = 0) THEN
      parseState := 1;
      parseString := '!#DIAGDELIM#!';
      prev := x+12;
    ELSE
      parseState := 0;
      parseString := '!#DIAGPAIR#!';
      prev := x+13;
    END IF;
    x := instr(classList, parseString, prev);
    if(x = 0) then
      if(parseState = 0) then
	className := substr(classList, prev);
	entries := entries+diagentry(key1,key2,key3,className);
      end if;
      return entries;
    end if;
    if(parseState = 0) then
      className := substr(classList, prev, x-prev);
      entries := entries+diagentry(key1, key2, key3, className);
    end if;
  END LOOP;
END diagsync;

FUNCTION diagentry(	key1 JTF_DIAGNOSTIC_CMAP.appName%TYPE,
			key2 JTF_DIAGNOSTIC_CMAP.groupName%TYPE,
			key3 JTF_DIAGNOSTIC_CMAP.testClassName%TYPE,
			className JTF_DIAGNOSTIC_CMAP.className%TYPE)
RETURN INTEGER IS
BEGIN
  insert into JTF_DIAGNOSTIC_CMAP(
	appName,
	groupName,
	testClassName,
	classname)
  values (
	key1,
	key2,
	key3,
	className);
  return 1;
EXCEPTION
  WHEN OTHERS THEN
    return 0;
END diagentry;

end jtf_diagnostic_sync;

/
