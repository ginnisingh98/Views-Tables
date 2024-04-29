--------------------------------------------------------
--  DDL for Package Body HZ_DQM_SEARCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DQM_SEARCH_UTIL" AS
/*$Header: ARHDQUTB.pls 120.29 2006/02/11 00:19:27 schitrap noship $ */
g_within_threshold NUMBER := 4;

g_string VARCHAR2(2000);
g_curpos NUMBER;
g_delim VARCHAR2(30);
g_numtoks NUMBER;

g_num_eval NUMBER:=0;

g_no_score BOOLEAN := FALSE;

--Start of Bug No:4244535

TYPE attr_rec_type IS RECORD(attr_id hz_trans_attributes_b.ATTRIBUTE_ID%type,
                             tmp_section hz_trans_attributes_b.temp_section%type);
TYPE attr_tb_type is table of attr_rec_type index by binary_integer;
g_attr_rec attr_rec_type;
g_attr_tb  attr_tb_type;

--End of Bug No:4244535


PROCEDURE set_score IS
BEGIN
  g_no_score:= FALSE;
END;
PROCEDURE set_no_score IS
BEGIN
  g_no_score:= TRUE;
END;

PROCEDURE set_num_eval(p_num NUMBER) IS
BEGIN
  g_num_eval:=p_num;
END;

FUNCTION get_num_eval RETURN NUMBER IS
BEGIN
  RETURN g_num_eval;
END;

PROCEDURE new_search IS
BEGIN
  HZ_TRANS_PKG.clear_globals;
END;
FUNCTION subst_reserved(
    p_inp       IN  VARCHAR2) RETURN VARCHAR2 IS

retstr VARCHAR2(4000);

BEGIN
    retstr := ' ' || p_inp || ' ';
    retstr := replace(retstr,' ABOUT ',' {ABOUT} ');
    retstr := replace(retstr,' ACCUM ',' {ACCUM} ');
    retstr := replace(retstr,' AND ',' {AND} ');
    retstr := replace(retstr,' BT ',' {BT} ');
    retstr := replace(retstr,' BTG ',' {BTG} ');
    retstr := replace(retstr,' BTI ',' {BTI} ');
    retstr := replace(retstr,' BTP ',' {BTP} ');
    retstr := replace(retstr,' MINUS ',' {MINUS} ');
    retstr := replace(retstr,' NEAR ',' {NEAR} ');
    retstr := replace(retstr,' NOT ',' {NOT} ');
    retstr := replace(retstr,' NT ',' {NT} ');
    retstr := replace(retstr,' NTG ',' {NTG} ');
    retstr := replace(retstr,' NTI ',' {NTI} ');
    retstr := replace(retstr,' NTP ',' {NTP} ');
    retstr := replace(retstr,' OR ',' {OR} ');
    retstr := replace(retstr,' PT ',' {PT} ');
    retstr := replace(retstr,' RT ',' {RT} ');
    retstr := replace(retstr,' SQE ',' {SQE} ');
    retstr := replace(retstr,' SYN ',' {SYN} ');
    retstr := replace(retstr,' TR ',' {TR} ');
    retstr := replace(retstr,' TRSYN ',' {TRSYN} ');
    retstr := replace(retstr,' TT ',' {TT} ');
    retstr := replace(retstr,' WITHIN ',' {WITHIN} ');
    return rtrim(ltrim(retstr));
END;

FUNCTION check_misc (p_within VARCHAR2) RETURN VARCHAR2 IS
l_1stchar VARCHAR2(1);
l_misc_within VARCHAR2(30);
CURSOR temp_sect(p_attr_id NUMBER) IS
  SELECT nvl(temp_section,p_within) --Bug No: 4244535
  FROM HZ_TRANS_ATTRIBUTES_VL
  WHERE attribute_id = p_attr_id;
  --AND temp_section IS NOT NULL; --Bug No: 4244535
l_attr_id NUMBER(15);
l_index   NUMBER;
BEGIN
  l_1stchar := substrb(p_within,1,1);
  IF l_1stchar = 'D' THEN
    RETURN p_within;
  ELSIF l_1stchar = 'M' THEN
    RETURN p_within;
  ELSE
    --Start of Bug No: 4244535
    l_attr_id := to_number(substrb(p_within,2));
    FOR i in 1..g_attr_tb.count LOOP
      IF (g_attr_tb(i).attr_id = l_attr_id) THEN
        RETURN g_attr_tb(i).tmp_section;
      END IF;
    END LOOP;
    l_index := g_attr_tb.count+1;
    OPEN temp_sect(l_attr_id);
    FETCH temp_sect INTO l_misc_within;
    IF temp_sect%FOUND THEN
      CLOSE temp_sect;
      g_attr_tb(l_index).attr_id     := l_attr_id;
      g_attr_tb(l_index).tmp_section := l_misc_within;
      RETURN l_misc_within;
    ELSE
      CLOSE temp_sect;
      g_attr_tb(l_index).attr_id     := l_attr_id;
      g_attr_tb(l_index).tmp_section := p_within;
      RETURN p_within;
    END IF;
  --End of Bug No: 4244535
  END IF;
END;

PROCEDURE add_transformation (
	p_tx_val	IN	VARCHAR2,
	p_within	IN	VARCHAR2,
	x_tx_str	IN OUT NOCOPY	VARCHAR2) IS

l_tx_val VARCHAR2(4000);

BEGIN
  IF p_tx_val IS NOT NULL THEN
    l_tx_val := p_tx_val;
    IF instrb(l_tx_val,'%')>0 OR lengthb(l_tx_val)>255 THEN ----Bug No: 3032742
      l_tx_val := subst_reserved(l_tx_val);
    ELSE
      l_tx_val := '{' || l_tx_val || '}';
    END IF;

    IF x_tx_str IS NOT NULL THEN
      x_tx_str := x_tx_str || ' OR ';
    END IF;

    IF p_within IS NULL THEN
      x_tx_str := x_tx_str || '(' || l_tx_val || ')';
    ELSE
      x_tx_str := x_tx_str ||
        '(' || l_tx_val || ') within ' || check_misc(p_within);
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_DQM_SEARCH_UTIL.add_transformation');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END add_transformation;

PROCEDURE add_filter (
	p_tx_val	IN	VARCHAR2,
	p_within	IN	VARCHAR2,
	x_filter_str	IN OUT NOCOPY	VARCHAR2) IS
BEGIN
  IF p_tx_val IS NOT NULL THEN
    IF x_filter_str IS NOT NULL THEN
      x_filter_str := x_filter_str || ' AND ';
    END IF;
    x_filter_str := x_filter_str ||
       '{' || replace(p_tx_val,'_',' ') || '} within ' || check_misc(p_within);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_DQM_SEARCH_UTIL.add_filter');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END add_filter;

PROCEDURE add_attribute (
	p_tx_str	IN	VARCHAR2,
	p_match_str	IN	VARCHAR2,
	x_contains_str	IN OUT NOCOPY	VARCHAR2) IS
BEGIN
  IF p_tx_str IS NOT NULL THEN
    IF x_contains_str IS NOT NULL THEN
      x_contains_str := x_contains_str || p_match_str;
    END IF;
    x_contains_str := x_contains_str || '('||
                      p_tx_str || ')';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_DQM_SEARCH_UTIL.add_attribute');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END add_attribute;

PROCEDURE add_attribute_with_denorm (
        p_tx_str        IN      VARCHAR2,
        p_match_str     IN      VARCHAR2,
        p_denorm_str    IN      VARCHAR2,
        x_contains_str  IN OUT NOCOPY   VARCHAR2) IS
BEGIN
  IF p_tx_str IS NOT NULL THEN
    IF x_contains_str IS NOT NULL THEN
      x_contains_str := x_contains_str || p_match_str;
    END IF;
    x_contains_str := x_contains_str || '('||
                      p_tx_str;
    IF p_denorm_str IS NOT NULL THEN
      x_contains_str := x_contains_str || ' AND ('||p_denorm_str ||'))';
    ELSE
      x_contains_str := x_contains_str || ')';
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_DQM_SEARCH_UTIL.add_attribute_with_denorm');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END add_attribute_with_denorm;


PROCEDURE add_search_record (
	p_rec_contains_str 	IN	VARCHAR2,
	p_filter_str		IN	VARCHAR2,
	x_contains_str		IN OUT NOCOPY	VARCHAR2) IS
BEGIN
  IF p_rec_contains_str IS NOT NULL THEN
    IF x_contains_str IS NOT NULL THEN
      x_contains_str := x_contains_str || ' OR ';
    END IF;
    IF p_filter_str IS NOT NULL THEN
      x_contains_str :=
        x_contains_str || '((' || p_rec_contains_str || ') AND '||p_filter_str||')';
    ELSE
      x_contains_str :=
        x_contains_str || '('|| p_rec_contains_str || ')';
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_DQM_SEARCH_UTIL.add_search_record');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- Remove records from HZ_DQM_PARTIES_GT which don't satisfy subset_defn
PROCEDURE remove_matches_not_in_subset (
        p_search_ctx_id         IN      NUMBER,
        p_subset_defn           IN      VARCHAR2
) IS
  l_sqlstr VARCHAR2(4000);
BEGIN
  l_sqlstr := 'DELETE FROM HZ_DQM_PARTIES_GT m WHERE NOT EXISTS ('||
              'SELECT p.party_id FROM HZ_PARTIES p '||
              'WHERE p.party_id = m.party_id AND '||
              p_subset_defn || ') AND SEARCH_CONTEXT_ID = :ctxid';
  EXECUTE IMMEDIATE l_sqlstr USING p_search_ctx_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_RESTRICT_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'remove_matches_not_in_subset');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END remove_matches_not_in_subset;

FUNCTION strtok (
    p_string VARCHAR2 DEFAULT NULL,
    p_numtoks NUMBER DEFAULT NULL,
    p_delim VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2 IS

  l_spc_char NUMBER;
  l_numtoks NUMBER;
  ret VARCHAR2(4000); --Bug No: 3032742
  FIRST BOOLEAN;
  l_first_pos NUMBER;
BEGIN
  IF p_string IS NOT NULL THEN
    g_string := p_string;
    g_curpos := 1;
    g_delim := p_delim;
    g_numtoks := p_numtoks;
  END IF;

  IF g_string IS NULL THEN
    RETURN null;
  END IF;

  l_numtoks := 0;
  FIRST := TRUE;
  LOOP
    l_spc_char := instr(g_string,g_delim,g_curpos);
    EXIT WHEN l_spc_char = 0;

    ret := ret || ' '|| substr(g_string,g_curpos,l_spc_char-g_curpos);
    g_curpos := l_spc_char+1;
    IF FIRST THEN
      l_first_pos :=  g_curpos;
      FIRST := FALSE;
    END IF;
    l_numtoks := l_numtoks+1;
    EXIT WHEN l_numtoks=g_numtoks;
  END LOOP;
  IF l_numtoks<g_numtoks THEN
    ret := ret || ' '|| substr(g_string,g_curpos);
    l_numtoks := l_numtoks+1;
    g_string := NULL;
  END IF;
  IF l_numtoks<g_numtoks THEN
    RETURN NULL;
  ELSE
    g_curpos := l_first_pos;
    RETURN ltrim(ret);
  END IF;
END;

FUNCTION is_match(
	p_src	IN      VARCHAR2,
	p_dest	IN      VARCHAR2,
    p_attr_idx IN   NUMBER
 ) RETURN BOOLEAN IS

test VARCHAR2(2000);

BEGIN
 IF p_src IS NULL OR p_dest IS NULL  THEN
   RETURN FALSE;
 END IF;

 IF (' '||p_dest||' ' like '% '||p_src||' %') THEN
   RETURN TRUE;
 ELSE
   RETURN FALSE;
 END IF;
END;

FUNCTION is_similar_match(
        p_src   		IN      VARCHAR2,
        p_dest  		IN      VARCHAR2,
        p_min_similarity 	IN 	VARCHAR2,
        p_attr_idx              IN      NUMBER)
RETURN BOOLEAN IS
  numspc NUMBER;
  destspc NUMBER;
  l_dest VARCHAR2(2000);
BEGIN
 IF p_src IS NULL OR p_dest IS NULL  THEN
   RETURN FALSE;
 ELSIF instr(p_src,'%')>0 THEN
   RETURN is_match(p_src,p_dest,p_attr_idx);
 ELSIF NOT is_match(p_src,p_dest,p_attr_idx) THEN
    l_dest := p_dest;
    numspc:=1;
    l_dest := rtrim(p_dest);
    while (instr(p_src,' ',1,numspc)>0) LOOP
       numspc:=numspc+1;
    END LOOP;
    destspc := instr(p_dest,' ',1,numspc)-1;
    IF (destspc>0) THEN
       l_dest := substr(l_dest,1,destspc);
    END IF;
    IF is_similar(p_src,l_dest,p_min_similarity)=1 THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
 ELSE
   RETURN TRUE;
 END IF;
END;

FUNCTION is_similar(
	p_src               IN      VARCHAR2,
	p_dest              IN      VARCHAR2,
        p_min_similarity    IN      NUMBER := 100)
  RETURN NUMBER IS

m NUMBER;
n NUMBER;

TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

alist NumberList;
blist NumberList;

cost NUMBER;

D VARCHAR2(1 CHAR );
C VARCHAR2(1 CHAR );

BEGIN

  n := nvl(LENGTH(p_src),0);
  m := nvl(LENGTH(p_dest),0);

  IF n = 0 THEN
    return m;
  END IF;
  IF m = 0 THEN
    return n;
  END IF;

  FOR I IN 1..(M+1) LOOP
    alist(I) := I-1;
  END LOOP;

  FOR I IN 1..N LOOP
    IF mod(I,2) = 1 THEN
      blist(1) := I;
    ELSE
      alist(1) := I;
    END IF;

    C := substr(p_src,I,1);

    FOR J IN 2..(M+1) LOOP
      D := substr(p_dest,J-1,1);
      COST := 1;
      IF D=C THEN
        COST := 0;
      END IF;
      IF mod(I,2) = 1 THEN
        blist(J) := least(blist(J-1)+1,alist(J)+1,alist(j-1)+COST);
      ELSE
        alist(J) := least(alist(J-1)+1,blist(J)+1,blist(j-1)+COST);
      END IF;
    END LOOP;
  END LOOP;
  IF mod(n,2) = 1 THEN
    IF (1-(blist(m+1)/n))*100 > p_min_similarity THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  ELSE
    IF (1-(alist(m+1)/n))*100 > p_min_similarity THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_DQM_SEARCH_UTIL.is_similar');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- This Function tests if the DQM indexes have been created
-- and if they are valid
FUNCTION is_dqm_available
  RETURN VARCHAR2 IS

  T NUMBER;
BEGIN

  BEGIN
    SELECT 1 INTO T FROM HZ_STAGED_PARTIES
    WHERE ROWNUM=1
    AND CONTAINS (concat_col, 'dummy_string')>0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_FALSE;
  END;
  BEGIN
    SELECT 1 INTO T FROM HZ_STAGED_PARTY_SITES
    WHERE ROWNUM=1
    AND CONTAINS (CONCAT_COL, 'dummy_string')>0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_FALSE;
  END;
  BEGIN
    SELECT 1 INTO T FROM HZ_STAGED_CONTACTS
    WHERE ROWNUM=1
    AND CONTAINS (CONCAT_COL, 'dummy_string')>0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_FALSE;
  END;
  BEGIN
    SELECT 1 INTO T FROM HZ_STAGED_CONTACT_POINTS
    WHERE ROWNUM=1
    AND CONTAINS (CONCAT_COL, 'dummy_string')>0;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RETURN FND_API.G_FALSE;
  END;
  RETURN FND_API.G_TRUE;
END;


FUNCTION is_dqm_available(
p_match_rule_id NUMBER
)
  RETURN VARCHAR2 IS

  T NUMBER;
  X VARCHAR2(1);
  l_comp_flag VARCHAR2(1);
  l_count NUMBER;
  CURSOR c1 is select compilation_flag from hz_match_rules_b where match_rule_id = p_match_rule_id;
 CURSOR c2 is select count(*)
            from hz_trans_functions_b
            where function_id in (
                       select function_id
                       from hz_match_rule_primary mp, hz_primary_trans pt
                       where match_rule_id = p_match_rule_id
                       and mp.primary_attribute_id = pt.primary_attribute_id
                       union
                       select function_id
                       from hz_match_rule_secondary ms, hz_secondary_trans st
                       where match_rule_id = p_match_rule_id
                       and ms.secondary_attribute_id = st.secondary_attribute_id
            )
            and staged_flag <> 'Y'
            and nvl(active_flag, 'Y') <> 'N' ;

BEGIN
   X := hz_dqm_search_util.is_dqm_available;
    IF (X = FND_API.G_TRUE) THEN
    OPEN c1;
    FETCH c1 INTO l_comp_flag;
       IF (l_comp_flag = 'C') THEN
            OPEN c2;
            FETCH c2 INTO l_count;
            IF (l_count = 0) THEN
               X := FND_API.G_TRUE;
            ELSE
               X := FND_API.G_FALSE;
            END IF;
        ELSE
            X := FND_API.G_FALSE;
        END IF;
    ELSE
        X := FND_API.G_FALSE;
    END IF;
   RETURN X;
END is_dqm_available;



FUNCTION ESTIMATED_LENGTH(p_str VARCHAR2) RETURN NUMBER IS

l_tok VARCHAR2(4000);
l_str VARCHAR2(4000);
len NUMBER := 0;
eqpos NUMBER;
BEGIN
  RETURN lengthb(p_str);
END;

PROCEDURE update_word_list (
   p_repl_word VARCHAR2,
   p_word_list_id NUMBER) IS
  repl_str VARCHAR2(2000);
  FIRST BOOLEAN;
begin

  NULL;
END;

PROCEDURE get_quality_score (
    p_srch_ctx_id IN NUMBER,
    p_match_rule_id IN NUMBER
    )  IS

l_score NUMBER;
l_quality_weight NUMBER;
l_quality_score NUMBER;
l_final_score NUMBER ;
l_rule_purpose VARCHAR2(1);
l_party_rec HZ_PARTIES%ROWTYPE;
l_mms NUMBER;
BEGIN
     l_quality_weight := hz_dqm_quality_uh_pkg.get_quality_weighting(p_match_rule_id);
     IF (l_quality_weight > 0) THEN
         select rule_purpose into l_rule_purpose
         from hz_match_rules_vl
         where match_rule_id = p_match_rule_id;

         IF ( l_rule_purpose = 'S') THEN
           FOR TX IN (
                select party_id, score
                from hz_matched_parties_gt
                where search_context_id = p_srch_ctx_id)
           LOOP
             select * into l_party_rec
             from HZ_PARTIES
             where party_id = TX.party_id;
             l_quality_score := hz_dqm_quality_uh_pkg.get_quality_score(p_match_rule_id, l_party_rec);
             l_score := TX.score;
             l_final_score := (l_score * ( 100 - l_quality_weight) + l_quality_score * l_quality_weight)/ 100;
             update hz_matched_parties_gt
             set score = l_final_score
             where search_context_id = p_srch_ctx_id
             and party_id = TX.party_id;
           END LOOP;
         ELSIF ( l_rule_purpose = 'D') THEN
           select sum(score) into l_mms
           from hz_match_rule_secondary
           where match_rule_id =  p_match_rule_id;
           FOR TX IN (select party_id, score
                from hz_matched_parties_gt
                where search_context_id = p_srch_ctx_id)
           LOOP
             select * into l_party_rec
             from HZ_PARTIES
             where party_id = TX.party_id;
             l_score := TX.score;
             l_quality_score := hz_dqm_quality_uh_pkg.get_quality_score(p_match_rule_id, l_party_rec);
             l_final_score :=  (l_score - (l_score * l_quality_weight)/100 + (l_quality_score * l_quality_weight* l_mms)/(100*100));
             update hz_matched_parties_gt
             set score = l_final_score
             where search_context_id = p_srch_ctx_id
             and party_id = TX.party_id;
           END LOOP;
         END IF;
     END IF;
 EXCEPTION WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_QUAL_SCORE'); -- Error occured in obtaining a quality score.  Please contact system adminsitrator or turn profile option off to run DQM without quality score.
      FND_MSG_PUB.ADD;
      RAISE;
END get_quality_score;


FUNCTION validate_trans_proc(
     P_PROCEDURE_NAME IN VARCHAR2
     ) return VARCHAR2 IS
  c NUMBER;
  l_sql VARCHAR2(255);
  dotCheck NUMBER;
  procCheck NUMBER;
  l_sqlstr VARCHAR2(4000);
  l_status VARCHAR2(255);
  l_owner1 VARCHAR2(255);
  l_temp VARCHAR2(255);
  BEGIN
  	select instr(P_PROCEDURE_NAME,'.') into dotCheck from dual;
  	IF dotCheck = 0 THEN

	/*select count(*) into procCheck from sys.all_objects
	where object_name=trim(upper(P_PROCEDURE_NAME))
	and (object_type='PROCEDURE' OR object_type='FUNCTION');*/

   IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
    l_sqlstr := ' select count(*) from sys.all_procedures where object_name=trim(upper(:P_PROCEDURE_NAME)) and owner=:2';
    EXECUTE IMMEDIATE l_sql into procCheck USING P_PROCEDURE_NAME,l_owner1;
   END IF;

	IF procCheck=0 THEN
	RETURN 'INVALID';
	ELSE
	RETURN 'VALID';
	END IF;
	ELSE
        c := dbms_sql.open_cursor;
        l_sql := 'select ' || P_PROCEDURE_NAME ||
             '(:attrval,:lang,:attr,:entity) from dual';
        dbms_sql.parse(c,l_sql,2);
        dbms_sql.close_cursor(c);
        RETURN 'VALID';
        END IF;
  EXCEPTION WHEN OTHERS THEN
        RETURN 'INVALID';
  END validate_trans_proc;


FUNCTION validate_custom_proc(
     P_CUST_PROCEDURE_NAME IN VARCHAR2
     ) return VARCHAR2 IS
  c NUMBER;
  dotCheck NUMBER;
  procCheck NUMBER;
  l_sql VARCHAR2(255);
  l_sqlstr VARCHAR2(4000);
  l_status VARCHAR2(255);
  l_owner1 VARCHAR2(255);
  l_temp VARCHAR2(255);
BEGIN
 	select instr(P_CUST_PROCEDURE_NAME,'.') into dotCheck from dual;
  	IF dotCheck = 0 THEN

	/*select count(*) into procCheck from sys.all_objects
	where object_name=trim(upper(P_CUST_PROCEDURE_NAME))
	and (object_type='PROCEDURE' OR object_type='FUNCTION');*/

   IF (fnd_installation.GET_APP_INFO('AR',l_status,l_temp,l_owner1)) THEN
    l_sqlstr := ' select count(*) from sys.all_procedures where object_name=trim(upper(:1)) and owner=:2 ';
    EXECUTE IMMEDIATE l_sql into procCheck USING P_CUST_PROCEDURE_NAME,l_owner1;
   END IF;

	IF procCheck=0 THEN
	RETURN 'INVALID';
	ELSE
	RETURN 'VALID';
	END IF;
	ELSE
        c := dbms_sql.open_cursor;
        l_sql := 'select ' || P_CUST_PROCEDURE_NAME ||
             '(:record_id,:entity,:attr) from dual';
        dbms_sql.parse(c,l_sql,2);
        dbms_sql.close_cursor(c);
        RETURN 'VALID';
        END IF;
  EXCEPTION WHEN OTHERS THEN
        RETURN 'INVALID';
END validate_custom_proc;

END ;

/
