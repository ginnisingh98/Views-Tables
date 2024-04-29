--------------------------------------------------------
--  DDL for Package Body IEM_IM_TOKENS_WRAPPERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_IM_TOKENS_WRAPPERS_PVT" as
/* $Header: iemtimwb.pls 115.6 2002/12/22 01:07:42 sboorela shipped $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_IM_TOKENS_WRAPPERS_PVT';

 FUNCTION GetTokens(p_msgid IN INTEGER, p_part IN INTEGER,
                    p_flags IN INTEGER, p_link IN VARCHAR2,
                    p_language IN VARCHAR2,
		         p_token_tab OUT NOCOPY token_tab,
                    p_errtext OUT NOCOPY VARCHAR2) RETURN INTEGER
 IS
 p_token_str VARCHAR2(32000);
 l_token_str VARCHAR2(32000);
 l_work_str VARCHAR2(3000);
 p_index NUMBER := 0;
 l_count NUMBER := 1;
 l_bool BOOLEAN := TRUE;
 l_loc_t NUMBER;
 l_status NUMBER := -1; /* defaule value for bug 2677236 */
 l_tmp_token VARCHAR2(150);
 l_token_tab1 token_tab;
 l_weight NUMBER := 1;

 l_plsql_block VARCHAR2(2000) := 'BEGIN :x := IM_IMT_API.gettokensw'||p_link||'(:a,:b,:c,:d,:e,:f,:g); END;';

BEGIN
 EXECUTE IMMEDIATE l_plsql_block USING OUT l_status, IN p_msgid,IN p_part, IN p_flags, IN p_language,
                   OUT p_token_str, OUT p_index, OUT p_errtext;

 --DBMS_OUTPUT.PUT_LINE('NUMBER OF TOKENS := '||p_index);
 IF (p_index > 0) THEN
    WHILE (l_bool) LOOP
 	SELECT INSTR(p_token_str, '<T>', 1,1) INTO l_loc_t FROM DUAL;
 	SELECT SUBSTR(p_token_str,1, l_loc_t-1) INTO l_work_str FROM DUAL;

	-- Build table from token_str returned from OES.
	SELECT l_work_str INTO l_token_tab1(l_count).TOKEN FROM DUAL;
	--INSERT INTO IEM_TOKENS(MSGID, TOKEN) VALUES(p_msgid,l_work_str);
	l_count := l_count+1;
	SELECT SUBSTR(p_token_str,l_loc_t+3) INTO l_token_str FROM DUAL;
	p_token_str := l_token_str;
	p_index := p_index-1;
	  IF (p_index < 1) THEN
	    l_bool := FALSE;
	  END IF;
    END LOOP;
    l_count:=1;
    for i in 1 .. l_token_tab1.count loop
        l_tmp_token := l_token_tab1(i).token;
	for w in (i+1) .. l_token_tab1.last loop
		if l_tmp_token = l_token_tab1(w).token then
			l_weight := l_weight+1;
			l_token_tab1(w).token := '99999';
		end if;
	end loop;
	if l_tmp_token <> '99999' then
		p_token_tab(l_count).token  := l_tmp_token;
        	p_token_tab(l_count).weight := l_weight;
		l_weight:= 1;
		l_count:= l_count+1;
	end if;
    end loop;
END IF;

 -- Appropriate err_text to be returned
 -- error number to be returned

 return l_status;

EXCEPTION
  WHEN OTHERS THEN
  p_errtext := SUBSTR(p_errtext ||' '||SQLERRM, 1, 254);
  return l_status;
  --	DBMS_OUTPUT.PUT_LINE(SQLERRM);
END gettokens;

END IEM_IM_TOKENS_WRAPPERS_PVT;

/
