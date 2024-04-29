--------------------------------------------------------
--  DDL for Package Body FUN_RICH_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RICH_MESSAGE_PKG" AS
/* $Header: FUNXTMRULRTMUTB.pls 120.0 2005/06/20 04:30:10 ammishra noship $ */


TYPE token_rec_type IS RECORD (
   TOK_NAM   VARCHAR2(100),
   TOK_VAL   VARCHAR2(100)
);

TYPE token_tab_type IS TABLE OF token_rec_type INDEX BY BINARY_INTEGER;

g_token_list token_tab_type;
g_token_count NUMBER := 0;


FUNCTION GET_MESSAGE_PRIVATE(APPIN IN VARCHAR2,
                            NAMEIN IN VARCHAR2)
RETURN CLOB;

FUNCTION CLOB_REPLACE(P_LOB IN OUT nocopy CLOB,
                      P_WHAT IN VARCHAR2,
      	              P_WITH IN VARCHAR2 ) RETURN CLOB
IS
temp_clob        CLOB;
end_offset       INTEGER := 1;
start_offset     INTEGER := 1;
occurence        NUMBER := 1;
replace_str_len  NUMBER := LENGTH(P_WITH);
temp_clob_len    NUMBER := 0;
dest_lob_len     NUMBER := 0;

BEGIN
  IF DBMS_LOB.ISOPEN(P_LOB) = 0 THEN
    NULL;
  END IF;
  DBMS_LOB.CREATETEMPORARY(temp_clob,TRUE,DBMS_LOB.SESSION);
  LOOP
    end_offset := DBMS_LOB.INSTR(P_LOB,P_WHAT,1,occurence);
    IF end_offset = 0 THEN
      temp_clob_len := DBMS_LOB.GETLENGTH(temp_clob);
      dest_lob_len := DBMS_LOB.GETLENGTH(P_LOB) - start_offset + 1;
      IF dest_lob_len > 0 THEN
        DBMS_LOB.COPY(temp_clob,P_LOB,dest_lob_len,temp_clob_len+1,start_offset);
      END IF;
      EXIT;
    END IF;
    temp_clob_len := DBMS_LOB.GETLENGTH(temp_clob);
    IF (end_offset - start_offset) > 0 THEN
      DBMS_LOB.COPY(temp_clob,P_LOB,(end_offset - start_offset),temp_clob_len+1,start_offset);
    END IF;
    start_offset := end_offset + LENGTH(P_WHAT);
    occurence := occurence + 1;
    IF P_WITH IS NOT NULL THEN
      DBMS_LOB.WRITEAPPEND(temp_clob,replace_str_len,P_WITH);
    END IF;
  END LOOP;
  IF LENGTH(P_WHAT) > LENGTH(P_WITH) THEN
    DBMS_LOB.TRIM(P_LOB,DBMS_LOB.GETLENGTH(temp_clob));
  END IF;
--  DBMS_LOB.COPY(dest_lob,temp_clob,DBMS_LOB.GETLENGTH(temp_clob),1,1);
  RETURN temp_clob;

END;

/*
FUNCTION TEST RETURN CLOB IS
BEGIN
  TOKEN_TAB(1).TOK_NAM := 'ROWID';
  TOKEN_TAB(1).TOK_VAL := '931';

  TOKEN_TAB(2).TOK_NAM := 'LANGUAGE_CODE';
  TOKEN_TAB(2).TOK_VAL := 'US';

  MSGTEST := FUN_RICH_MESSAGE_PKG.get('SQLAP','FUN_RULE_DEFINED_MSG106',TOKEN_TAB);

  RETURN MSGTEST;
END;
*/

PROCEDURE init_token_list IS
BEGIN
    g_token_count := 0;
END init_token_list;

PROCEDURE add_token(name VARCHAR2, value VARCHAR2) IS
    l_token_rec token_rec_type;
  BEGIN
    l_token_rec.tok_nam := name;
    l_token_rec.tok_val := value;

    g_token_count := g_token_count + 1;
    g_token_list(g_token_count) := l_token_rec;

END add_token;

--Method to be called from Java programs where token substitutions would happen in Java.
FUNCTION GET_MESSAGE_JAVA(APPLICATION_SHORT_NAME  IN VARCHAR2,
             MESSAGE_NAME in varchar2
            ) return CLOB IS

MSG       CLOB;
SRCH      VARCHAR2(2000);
TOK_NAM   VARCHAR2(100);
TOK_VAL   VARCHAR2(100);

BEGIN

IF (MESSAGE_NAME IS NULL) THEN
    MSG := '';
    RETURN MSG;
END IF;

MSG := GET_MESSAGE_PRIVATE(APPLICATION_SHORT_NAME, MESSAGE_NAME);

IF ((MSG IS NULL) OR (MSG = '')) THEN
    MSG := MESSAGE_NAME;
END IF;

RETURN MSG;  --Returns the CLOB message text with tokens.

END;

FUNCTION GET_MESSAGE(APPLICATION_SHORT_NAME  IN VARCHAR2,
             MESSAGE_NAME IN VARCHAR2
            ) RETURN CLOB IS

MSG       CLOB;
SRCH      VARCHAR2(2000);
TOK_NAM   VARCHAR2(100);
TOK_VAL   VARCHAR2(100);

BEGIN

IF (MESSAGE_NAME IS NULL) THEN
    MSG := '';
    RETURN MSG;
END IF;

MSG := GET_MESSAGE_PRIVATE(APPLICATION_SHORT_NAME, MESSAGE_NAME);

IF ((MSG IS NULL) OR (MSG = '')) THEN
    MSG := MESSAGE_NAME;
END IF;

--THis table contains records of Token name and Token Value.

FOR i IN 1 .. G_TOKEN_LIST.COUNT
LOOP
    TOK_NAM := G_TOKEN_LIST(i).TOK_NAM;
    TOK_VAL := G_TOKEN_LIST(i).TOK_VAL;

    IF (TOK_NAM IS NOT NULL OR TOK_NAM <> '') THEN
       SRCH := '&'||'amp;' || TOK_NAM;
       MSG := CLOB_REPLACE(MSG,SRCH,TOK_VAL);
    END IF;

END LOOP;

RETURN MSG;

END;

FUNCTION GET_MESSAGE_PRIVATE(APPIN IN VARCHAR2,
         	     NAMEIN IN VARCHAR2)
RETURN CLOB IS

	MSG CLOB;

BEGIN

	SELECT MESSAGE_TEXT
	INTO MSG
	FROM FUN_RICH_MESSAGES_VL M, FND_APPLICATION A
	WHERE M.MESSAGE_NAME = NAMEIN
	AND A.APPLICATION_SHORT_NAME = APPIN
	AND M.APPLICATION_ID = A.APPLICATION_ID
        FOR UPDATE;  --Else LOB Locator complains.

  RETURN MSG;
EXCEPTION

	/* NULL HANDLING */
	WHEN NO_DATA_FOUND THEN
	  MSG := NULL;
          RETURN MSG;

	WHEN OTHERS THEN
	  MSG := NULL;
          RETURN MSG;

END;


END FUN_RICH_MESSAGE_PKG;

/
