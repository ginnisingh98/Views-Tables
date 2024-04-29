--------------------------------------------------------
--  DDL for Package Body HZ_GEN_PLSQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEN_PLSQL" AS
/*$Header: ARHGENPB.pls 115.4 2003/02/10 21:33:29 rrangan noship $ */

FUNCTION getstrlenb(str IN VARCHAR2, max IN NUMBER)
  RETURN NUMBER;

PROCEDURE new(
    name 	IN	VARCHAR2,
    obtype 	IN  	VARCHAR2
) IS
BEGIN
  m_name := name;
  m_type := obtype;
  m_array.DELETE;
  m_idx := 0;
END;

PROCEDURE add_line(
   line IN VARCHAR2,
   newline boolean default true) IS

l_string varchar2(32767) := line;
l_len    number;
BEGIN
  LOOP
    EXIT WHEN l_string IS NULL;
    m_idx := m_idx + 1;
    l_len := getstrlenb(l_string, 255);
    m_array(m_idx) :=  substrb( l_string, 1, l_len );
    l_string := substrb( l_string, l_len+1 );
  END LOOP;

  IF LENGTH( m_array(m_idx) ) = 255 THEN
    m_idx := m_idx + 1;
    m_array(m_idx) :='';
  END IF;

  IF newline THEN
    m_array(m_idx) := m_array(m_idx) || fnd_global.local_chr(10);
  END IF;
END;

PROCEDURE compile_code IS

l_status VARCHAR2(255);
cur_hdl INT;
n NUMBER;

BEGIN

  cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(cur_hdl, m_array, 1, m_idx, false, dbms_sql.native);
  n := dbms_sql.execute(cur_hdl);

  BEGIN
    SELECT STATUS INTO l_status FROM USER_OBJECTS
    WHERE OBJECT_NAME = m_name
    AND   OBJECT_TYPE = m_type;

    IF l_status <> 'VALID' THEN
      --dbms_output.put_line('Error compiling package');
      FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_COMPILE_PKG_ERROR');
      FND_MESSAGE.SET_TOKEN('NAME', m_name);
      FND_MESSAGE.SET_TOKEN('ERROR', 'Compilation Errors');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --dbms_output.put_line('Package not created');
      FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_COMPILE_PKG_ERROR');
      FND_MESSAGE.SET_TOKEN('NAME', m_name);
      FND_MESSAGE.SET_TOKEN('ERROR', 'Package not created');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_COMPILE_PKG_ERROR');
    FND_MESSAGE.SET_TOKEN('NAME', m_name);
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END compile_code;

FUNCTION getstrlenb(str IN VARCHAR2, max IN NUMBER)
  RETURN NUMBER IS
BEGIN
  IF length(str) > 255 THEN
    RETURN 255;
  ELSE
    RETURN length(str);
  END IF;
END;



END HZ_GEN_PLSQL;

/
