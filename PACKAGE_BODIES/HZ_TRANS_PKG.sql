--------------------------------------------------------
--  DDL for Package Body HZ_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TRANS_PKG" AS
/*$Header: ARHDQTRB.pls 120.32.12010000.2 2008/10/06 10:41:49 amstephe ship $ */

/*************** Globals *****************************/
g_threshold_length NUMBER := 6;

g_unprintables VARCHAR2(400) :=
     fnd_global.local_chr(0)||fnd_global.local_chr(1)||fnd_global.local_chr(2)||
     fnd_global.local_chr(3)||fnd_global.local_chr(4)||fnd_global.local_chr(5)||
     fnd_global.local_chr(6)||fnd_global.local_chr(7)||fnd_global.local_chr(8)||
     fnd_global.local_chr(9)||fnd_global.local_chr(10)|| fnd_global.local_chr(10)||
     fnd_global.local_chr(11)||fnd_global.local_chr(12)||fnd_global.local_chr(13)||
     fnd_global.local_chr(14)||fnd_global.local_chr(15)||fnd_global.local_chr(16)||
     fnd_global.local_chr(17)||fnd_global.local_chr(18)||fnd_global.local_chr(19)||
     fnd_global.local_chr(20)||fnd_global.local_chr(20)||fnd_global.local_chr(21)||
     fnd_global.local_chr(22)||fnd_global.local_chr(23)||fnd_global.local_chr(24)||
     fnd_global.local_chr(25)||fnd_global.local_chr(26)||fnd_global.local_chr(27)||
     fnd_global.local_chr(28)||fnd_global.local_chr(29)||fnd_global.local_chr(30)||
     fnd_global.local_chr(31);

g_last_wrperson_exact VARCHAR2(2000):='-1';
g_last_wrorg_exact VARCHAR2(2000):='-1';
g_last_wrnames_exact VARCHAR2(2000):='-1';
g_last_wraddr_exact VARCHAR2(2000):='-1';
g_last_wrstate_exact VARCHAR2(2000):='-1';
g_last_wrperson_orig VARCHAR2(2000):='-1';
g_last_wrorg_orig VARCHAR2(2000):='-1';
g_last_wrnames_orig VARCHAR2(2000):='-1';
g_last_wraddr_orig VARCHAR2(2000):='-1';
g_last_wrstate_orig VARCHAR2(2000):='-1';
g_last_wrstr VARCHAR2(4000):='-1';
g_last_wrstr_repl VARCHAR2(4000):='-1';
g_last_repl_set NUMBER := -1;

g_party_type VARCHAR2(30) := NULL;

g_match_rule_purpose VARCHAR2(1) := 'N';
g_dqm_wildchar_search boolean := false;
l_is_wildchar NUMBER;

-- VJN Introduced global variables for word_replace_noise_words_only to avoid caching
g_last_wrstr_1  VARCHAR2(4000):='-1';
g_last_wrstr_repl_1  VARCHAR2(4000):='-1';
g_last_repl_set_1 NUMBER := -1;

-- VJN Introduced global variable for Extension to Latin Characters.
g_latin_from VARCHAR2(32000);
g_latin_to VARCHAR2(32000);


TYPE charTab IS TABLE of VARCHAR2(2000) INDEX BY BINARY_INTEGER;
g_exact_for_cleansed charTab;

FUNCTION PARTYNAMES_EXACT_OLD_PRIVATE(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION PARTYNAMES_EXACT_NEW_PRIVATE(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION org_exact_old_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 ;


FUNCTION org_exact_new_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION person_exact_old_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2;

FUNCTION person_exact_new_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
RETURN VARCHAR2;

FUNCTION RM_PERCENTAGE(p_original_value IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION RM_SPLCHAR_PRIVATE (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2;

PROCEDURE set_party_type (
     p_party_type VARCHAR2
) IS
BEGIN
  g_party_type:=p_party_type;
  g_exact_for_cleansed.DELETE;
END;

PROCEDURE set_bulk_dup_id IS
BEGIN
  g_match_rule_purpose:='Q';
END;

PROCEDURE clear_globals IS

BEGIN
g_last_wrperson_exact :='-1';
g_last_wrorg_exact :='-1';
g_last_wrnames_exact :='-1';
g_last_wraddr_exact:='-1';
g_last_wrstate_exact:='-1';
g_last_wrperson_orig :='-1';
g_last_wrorg_orig :='-1';
g_last_wrnames_orig :='-1';
g_last_wraddr_orig :='-1';
g_last_wrstate_orig :='-1';
END;

/*
FUNCTION unprintables RETURN VARCHAR2 IS

BEGIN
  IF g_unprintables IS NULL THEN
    g_unprintables :=
     fnd_global.local_chr(0)||fnd_global.local_chr(1)||fnd_global.local_chr(2)||
     fnd_global.local_chr(3)||fnd_global.local_chr(4)||fnd_global.local_chr(5)||
     fnd_global.local_chr(6)||fnd_global.local_chr(7)||fnd_global.local_chr(8)||
     fnd_global.local_chr(9)||fnd_global.local_chr(10)|| fnd_global.local_chr(10)||
     fnd_global.local_chr(11)||fnd_global.local_chr(12)||fnd_global.local_chr(13)||
     fnd_global.local_chr(14)||fnd_global.local_chr(15)||fnd_global.local_chr(16)||
     fnd_global.local_chr(17)||fnd_global.local_chr(18)||fnd_global.local_chr(19)||
     fnd_global.local_chr(20)||fnd_global.local_chr(20)||fnd_global.local_chr(21)||
     fnd_global.local_chr(22)||fnd_global.local_chr(23)||fnd_global.local_chr(24)||
     fnd_global.local_chr(25)||fnd_global.local_chr(26)||fnd_global.local_chr(27)||
     fnd_global.local_chr(28)||fnd_global.local_chr(29)||fnd_global.local_chr(30)||
     fnd_global.local_chr(31);
  END IF;
  RETURN g_unprintables;
END;
*/

FUNCTION FIRST_WORD (
        p_original_value IN VARCHAR2,
        x_rem OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
l_exstr VARCHAR2(4000);
l_retstr VARCHAR2(4000);
l_spc_char NUMBER;

BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') THEN
    return '';
  end if;
  l_spc_char := nvl(instr(p_original_value,' '),0);
  IF l_spc_char = 0 THEN
    x_rem := '';
    RETURN p_original_value;
  ELSE
    x_rem := ltrim(substr(p_original_value,l_spc_char+1)||' ');
    RETURN substr(p_original_value,1,l_spc_char-1);
  END IF;
END;

FUNCTION CLEANSED (
        p_original_value        IN      VARCHAR2)
RETURN VARCHAR2 IS

  retstr varchar2(4000);

BEGIN

  IF (p_original_value IS NULL OR p_original_value = '') THEN
    return '';
  end if;

  retstr := p_original_value;

  -- Remove Double letters
  retstr := replace(retstr,'AA','A');
  retstr := replace(retstr,'BB','B');
  retstr := replace(retstr,'CC','C');
  retstr := replace(retstr,'DD','D');
  retstr := replace(retstr,'EE','E');
  retstr := replace(retstr,'FF','F');
  retstr := replace(retstr,'GG','G');
  retstr := replace(retstr,'HH','H');
  retstr := replace(retstr,'II','I');
  retstr := replace(retstr,'JJ','J');
  retstr := replace(retstr,'KK','K');
  retstr := replace(retstr,'LL','L');
  retstr := replace(retstr,'MM','M');
  retstr := replace(retstr,'NN','N');
  retstr := replace(retstr,'OO','O');
  retstr := replace(retstr,'PP','P');
  retstr := replace(retstr,'QQ','Q');
  retstr := replace(retstr,'RR','R');
  retstr := replace(retstr,'SS','S');
  retstr := replace(retstr,'TT','T');
  retstr := replace(retstr,'UU','U');
  retstr := replace(retstr,'VV','V');
  retstr := replace(retstr,'WW','W');
  retstr := replace(retstr,'XX','X');
  retstr := replace(retstr,'YY','Y');
  retstr := replace(retstr,'ZZ','Z');

  -- Remove Vowels (except from the 1st characters
  retstr := upper(translate(initcap(lower(retstr)),
                        '%bcdfghjklmnpqrstvwxzyaeiou',
                        '%bcdfghjklmnpqrstvwxz'));

  IF instr(retstr,'%')>0 THEN
    retstr := replace(retstr,'%A','%');
    retstr := replace(retstr,'%E','%');
    retstr := replace(retstr,'%I','%');
    retstr := replace(retstr,'%O','%');
    retstr := replace(retstr,'%U','%');
    retstr := replace(retstr,'%Y','%');
  END IF;

  RETURN retstr;

END CLEANSED;

FUNCTION cleansed_in_score_ctx (p_original_value VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    FOR I in 1..g_exact_for_cleansed.COUNT LOOP
      IF g_exact_for_cleansed(I) = p_original_value THEN
        RETURN CLEANSED(p_original_value);
      END IF;
    END LOOP;
    RETURN NULL;
END;

-- VJN introduced procedure for non-delimited word replacement

-- GOOD EXAMPLES

-- WORD LIST ID = 10380
-- T -> TING MAS -> TUNG
-- T -> TING MAS -> TUNG
-- TOKEN -- THOMAS, TTHOMAS

-- WORD LIST ID = 10381
-- T -> TING 0 -> ODA Y -> CRAP
-- TOKEN -- TOMOY

-- WORD LIST ID = 10382
-- ASAP -> APPLE  BASAP -> DUNG
-- TOKEN -- ASAPBASAP


-- WORD LIST ID = 10383
-- TOM -> TIM  M -> MARY
-- TOKEN -- TOMMY


PROCEDURE get_repl_token (
        wr_list_id              IN         NUMBER,
        original_str            IN         VARCHAR2,
        in_str                  IN  OUT    NOCOPY VARCHAR2,
        repl_token              OUT        NOCOPY VARCHAR2,
	    remainder_str           OUT        NOCOPY VARCHAR2,
        replacement_range       IN         VARCHAR2
        )
IS
FOUND boolean := FALSE ;
starting_char VARCHAR2(2 CHAR) ;
BEGIN

  starting_char := substr(in_str,1,1) || '%' ;
  FOR wr_cur in
        (
                select WR1.original_word as org_w , WR1.replacement_word as rep_w,
                       WR1.user_spec_cond_value, WR1.condition_id
                from hz_word_replacements WR1, hz_word_lists WL1
                where WL1.word_list_id = wr_list_id
                and WL1.word_list_id = WR1.word_list_id
                and WR1.original_word  like starting_char and instr( in_str, WR1.original_word)  = 1
		and ( ( staging_context = 'Y' and WR1.delete_flag = 'N')
		       OR (nvl(staging_context,'N') = 'N' and WR1.staged_flag = 'Y')
                    )
                and (WR1.replacement_word IS NULL OR WR1.replacement_word like replacement_range)
                order by length(WR1.ORIGINAL_WORD) desc
             )
 LOOP
       --dbms_output.put_line( 'In loop original word is ' || original_str );
       --dbms_output.put_line( 'In loop original string is ' || wr_cur.org_w );
       --dbms_output.put_line( 'replacement range is ' || replacement_range );
       --dbms_output.put_line( 'replacement word is ' || wr_cur.rep_w );
       --dbms_output.put_line( 'condition id is ' || wr_cur.condition_id );

       -- CHECK IF THERE ARE ANY CONDITIONS ASSOCIATED
       IF wr_cur.condition_id IS NOT NULL
       THEN
            -- CONDITION SATISFIED GET THE HELL OUT OF HERE
            IF HZ_WORD_CONDITIONS_PKG.evaluate_condition (
                                                    original_str,
                                                    wr_cur.org_w,
                                                    wr_cur.rep_w,
                                                    wr_cur.condition_id,
                                                    wr_cur.user_spec_cond_value )
            THEN
                   --dbms_output.put_line('Condition is satisfied');
                   FOUND := TRUE ;
                   repl_token := wr_cur.rep_w ;
                   remainder_str := substr(in_str,length(wr_cur.org_w) + 1);
                   exit ;

            END IF ;
       -- NO CONDITIONS. GET THE HELL OUT OF HERE !!!!!!
       ELSE
                    FOUND := TRUE ;
                    repl_token := wr_cur.rep_w ;
                    remainder_str := substr(in_str,length(wr_cur.org_w) + 1);
                    exit ;
       END IF ;
 END LOOP;
       -- if no replacement is found then repl_token is the first character of in_str and
       -- remainder is substring starting from the second character
       IF NOT FOUND
       THEN
        repl_token := substr(in_str, 1, 1);
	    remainder_str := substr(in_str,2);
       END IF;

    -- This will be used in the next recursion
    in_str := remainder_str ;

    --dbms_output.put_line( '----------------------');
    --dbms_output.put_line( 'in_str is' || in_str);
    --dbms_output.put_line( 'remainder_str is' || remainder_str);
    --dbms_output.put_line( 'repl_token is' || repl_token);
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','HZ_TRANS_PKG.replace_maximal_substr');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_repl_token ;

-- word replace delimited word replacements
FUNCTION word_replace_delimited (
        p_input_str             IN      VARCHAR2,
        p_replacement_set       IN      NUMBER,
        p_language              IN      VARCHAR2,
        p_has_spc               IN      BOOLEAN DEFAULT FALSE,
        p_noise_word_check      IN      VARCHAR2 DEFAULT 'N'
        )
RETURN VARCHAR2 IS

-- VJN CHANGED CURSOR TO TAKE INTO ACCOUNT THAT THIS COULD BE OPENED
-- FOR THE FOLLOWING SITUATIONS :
-- 1. WORD REPLACEMENT FOR ANY WORD WHETHER IT IS A NOISE WORD OR NOT
-- 2. WORD REPLACEMENT FOR NOISE WORDS

CURSOR c_wl_repl_string(cp_wl_id NUMBER, cp_orig_word
VARCHAR2, cp_replacement_range VARCHAR2 ) IS
  SELECT replacement_word, condition_id, user_spec_cond_value
  FROM HZ_WORD_REPLACEMENTS
  WHERE WORD_LIST_ID = cp_wl_id
  AND ORIGINAL_WORD = cp_orig_word
  AND ((staging_context = 'Y' AND DELETE_FLAG = 'N')
        OR (nvl(staging_context,'N') = 'N' AND STAGED_FLAG = 'Y')
      )
  AND (REPLACEMENT_WORD IS NULL OR REPLACEMENT_WORD like cp_replacement_range)
  and condition_id is not null
  order by condition_id desc ;

exstr VARCHAR2(4000);
l_repl_str VARCHAR2(4000);
l_orig_word VARCHAR2(4000);
l_repl_word VARCHAR2(4000);
l_tok VARCHAR2(4000);
l_spc_char NUMBER;
l_wl_id NUMBER;
pos NUMBER;

-- VJN introduced variables
l_remainder_str VARCHAR2(4000);
l_repl_token VARCHAR2(4000);
l_in_str VARCHAR2(4000);
l_concat_repl_token  VARCHAR2(4000);
l_non_delimited_flag VARCHAR2(1) ;
l_condition_id NUMBER ;
l_user_spec_cond_value VARCHAR2(2000);
l_replacement_range VARCHAR2(1);

NONE BOOLEAN := TRUE ;

BEGIN


  IF (p_input_str IS NULL OR p_input_str = '') then
    return '';
  end if;

  exstr := p_input_str ;
  l_wl_id := p_replacement_set;

  l_repl_str:='';
  IF p_has_spc THEN
    l_tok := HZ_DQM_SEARCH_UTIL.strtok(exstr,1,' DUMMY');
  ELSE
    l_tok := HZ_DQM_SEARCH_UTIL.strtok(exstr,1,' ');
  END IF;

 -- Determine the range of the word replacement
 -- Is it for a noise word scenario or a general one

 IF p_noise_word_check = 'Y'
 THEN
    --dbms_output.put_line('p_noise_word_check is ' || p_noise_word_check);
    l_replacement_range := '' ;
 ELSE
    --dbms_output.put_line('p_noise_word_check is ' || p_noise_word_check );
    l_replacement_range := '%' ;
 END IF ;


  ---VJN introduced changes to accomodate
  -- word replacements which are conditional
  WHILE l_tok IS NOT NULL         ----> OUTER LOOP
  LOOP
   --dbms_output.put_line('l_tok is ' || l_tok);
     l_repl_word := HZ_WORD_ARRAY_PKG.get_global_repl_word(p_replacement_set,l_tok) ;

     -- NO REPLACEMENT WHATSOEVER EXISTS FOR L_TOK
     IF  l_repl_word = '-2'
     THEN
        l_repl_str := l_repl_str || ' '|| l_tok;

     -- GLOBAL REPLACEMENT EXISTS EXISTS FOR L_TOK
     ELSIF l_repl_word <> '-1' OR l_repl_word IS NULL
     THEN

        -- when we are doing the usual replacements, only non-null replacements matter.
        IF p_noise_word_check = 'N' and l_repl_word IS NOT NULL
        THEN
           l_repl_str := l_repl_str || ' '|| l_repl_word ;
        END IF ;

        -- When we are doing noise word replacements, we basically ignore non-null replacements
        IF p_noise_word_check = 'Y' and l_repl_word IS NOT NULL
        THEN
           l_repl_str := l_repl_str || ' '|| l_tok ;
        END IF ;

     -- CONDITIONAL :: Keep trying to do the replacement in a loop
     --                until we do find a replacement, that passes the CONDITION.
     ELSE
            NONE := TRUE ;


            OPEN c_wl_repl_string(l_wl_id,l_tok, l_replacement_range);        --> CONDITIONAL LOOP FOR L_TOK BEGINS
            LOOP
            FETCH c_wl_repl_string INTO l_repl_word, l_condition_id, l_user_spec_cond_value;


                --dbms_output.put_line('Before evaluating condition exstr is' || exstr );
                --dbms_output.put_line('Before evaluating condition l_tok is' || l_tok );
                --dbms_output.put_line('Before evaluating condition l_repl_word is' || l_repl_word );
                --dbms_output.put_line('Before evaluating condition l_condition_id is' || l_condition_id );
                --dbms_output.put_line('Before evaluating condition l_user_spec_cond_value is' || l_user_spec_cond_value);

                -- Exit Loop when no rows found
                IF c_wl_repl_string%NOTFOUND
                THEN
                   exit ;
                -- Evaluate condition and if satisfied exit loop after setting NONE
                ELSIF HZ_WORD_CONDITIONS_PKG.evaluate_condition (      --------> CONDITION EVALUATION BEGINS
                                                    exstr,
                                                    l_tok,
                                                    l_repl_word,
                                                    l_condition_id,
                                                    l_user_spec_cond_value )
                THEN
                        IF l_repl_word IS NOT NULL THEN
                            l_repl_str := l_repl_str || ' '|| l_repl_word;
                        END IF ;
                        NONE := FALSE ;
                        --dbms_output.put_line('After evaluating condition l_repl_str is' || l_repl_str );
                        exit ;


                END IF;                                             --------> CONDITION EVALUATION ENDS

            END LOOP ;                                             --> CONDITIONAL LOOP FOR L_TOK ENDS

            -- NO CONDITIONS SATISFIED
            IF NONE
            THEN
                l_repl_str := l_repl_str || ' '|| l_tok;
            END IF ;


            CLOSE c_wl_repl_string;

     END IF ;


  -- One time string tokenizer call per loop
  l_tok := HZ_DQM_SEARCH_UTIL.strtok;


  END LOOP;                    ----> OUTER LOOP


  l_repl_str := ltrim(l_repl_str);

  --dbms_output.put_line('Returned String is' || l_repl_str );

  RETURN l_repl_str;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','HZ_TRANS_PKG.word_replace_delimited');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END word_replace_delimited ;

-- word replace non_delimited word replacements
FUNCTION word_replace_non_delimited (
        p_input_str             IN      VARCHAR2,
        p_replacement_set       IN      NUMBER,
        p_language              IN      VARCHAR2,
        p_has_spc               IN      BOOLEAN DEFAULT FALSE,
        p_noise_word_check      IN      VARCHAR2 DEFAULT 'N'
        )
RETURN VARCHAR2 IS

-- VJN CHANGED CURSOR TO TAKE INTO ACCOUNT THAT THIS COULD BE OPENED
-- FOR THE FOLLOWING SITUATIONS :
-- 1. WORD REPLACEMENT FOR ANY WORD WHETHER IT IS A NOISE WORD OR NOT
-- 2. WORD REPLACEMENT FOR NOISE WORDS

CURSOR c_wl_repl_string(cp_wl_id NUMBER, cp_orig_word
VARCHAR2, cp_replacement_range VARCHAR2 ) IS
  SELECT replacement_word, condition_id, user_spec_cond_value
  FROM HZ_WORD_REPLACEMENTS
  WHERE WORD_LIST_ID = cp_wl_id
  AND ORIGINAL_WORD = cp_orig_word
  AND ((staging_context = 'Y' AND DELETE_FLAG = 'N')
        OR (nvl(staging_context,'N') = 'N' AND STAGED_FLAG = 'Y')
      )
  AND (REPLACEMENT_WORD IS NULL OR REPLACEMENT_WORD like cp_replacement_range)
  and condition_id is not null
  order by condition_id desc ;

exstr VARCHAR2(4000);
l_repl_str VARCHAR2(4000);
l_orig_word VARCHAR2(4000);
l_repl_word VARCHAR2(4000);
l_tok VARCHAR2(4000);
l_spc_char NUMBER;
l_wl_id NUMBER;
pos NUMBER;

-- VJN introduced variables
l_remainder_str VARCHAR2(4000);
l_repl_token VARCHAR2(4000);
l_in_str VARCHAR2(4000);
l_concat_repl_token  VARCHAR2(4000);
l_non_delimited_flag VARCHAR2(1) ;
l_condition_id NUMBER ;
l_user_spec_cond_value VARCHAR2(2000);
l_replacement_range VARCHAR2(1);

NONE BOOLEAN := TRUE ;

BEGIN


  IF (p_input_str IS NULL OR p_input_str = '') then
    return '';
  end if;

  exstr := p_input_str ;
  l_wl_id := p_replacement_set;

  l_repl_str:='';
  IF p_has_spc THEN
    l_tok := HZ_DQM_SEARCH_UTIL.strtok(exstr,1,' DUMMY');
  ELSE
    l_tok := HZ_DQM_SEARCH_UTIL.strtok(exstr,1,' ');
  END IF;

 -- Determine the range of the word replacement
 -- Is it for a noise word scenario or a general one

 IF p_noise_word_check = 'Y'
 THEN
    --dbms_output.put_line('p_noise_word_check is ' || p_noise_word_check);
    l_replacement_range := '' ;
 ELSE
    --dbms_output.put_line('p_noise_word_check is ' || p_noise_word_check );
    l_replacement_range := '%' ;
 END IF ;


  ---VJN introduced changes to accomodate
  -- word replacements which are conditional
  WHILE l_tok IS NOT NULL         ----> OUTER LOOP
  LOOP
     --dbms_output.put_line('l_tok is ' || l_tok);
     --dbms_output.put_line( 'l_repl_str is ' || '<' || l_repl_str || '>' );
     l_repl_word := HZ_WORD_ARRAY_PKG.get_global_repl_word(p_replacement_set,l_tok) ;
     --dbms_output.put_line( 'repl_word is ' || l_repl_word );


     -- NO REPLACEMENT WHATSOEVER EXISTS FOR L_TOK
     IF  l_repl_word = '-2'
     THEN
                      -- TRY NON-DELIMITED WORD REPLACEMENTS

                       -- initialize the in/out varibale to the token value during the first pass
                       l_in_str := l_tok ;
                       l_repl_token := '';
                       l_concat_repl_token := '';
                       l_remainder_str := '';
                       --dbms_output.put_line('About to enter non-delimited Loop');
                       LOOP         ---> NON DELIMITED REPLACEMENT BEGINS
                       --dbms_output.put_line('Inside Loop');
                       IF l_in_str is null
                       THEN
                		EXIT;
                       END IF;
                       get_repl_token ( l_wl_id, l_tok, l_in_str, l_repl_token, l_remainder_str, l_replacement_range);
                       l_concat_repl_token := l_concat_repl_token || l_repl_token ;
                       --dbms_output.put_line('Concatented Replacement Token is ' || l_concat_repl_token );
                       END LOOP ;  ---> NON DELIMITED REPLACEMENT ENDS
                       l_repl_str := l_repl_str || ' '|| l_concat_repl_token ;

     -- GLOBAL REPLACEMENT EXISTS EXISTS FOR L_TOK
     ELSIF l_repl_word <> '-1' OR l_repl_word IS NULL
     THEN
        -- when we are doing the usual replacements, only non-null replacements matter.
        IF p_noise_word_check = 'N' and l_repl_word IS NOT NULL
        THEN
           l_repl_str := l_repl_str || ' '|| l_repl_word ;
        END IF ;

        -- When we are doing noise word replacements, we basically ignore non-null replacements
        IF p_noise_word_check = 'Y' and l_repl_word IS NOT NULL
        THEN
           l_repl_str := l_repl_str || ' '|| l_tok ;
        END IF ;

     -- CONDITIONAL :: Keep trying to do the replacement in a loop
     --                until we do find a replacement, that passes the CONDITION.
     ELSE
            NONE := TRUE ;

            OPEN c_wl_repl_string(l_wl_id,l_tok, l_replacement_range);        --> CONDITIONAL LOOP FOR L_TOK BEGINS
            LOOP
            FETCH c_wl_repl_string INTO l_repl_word, l_condition_id, l_user_spec_cond_value;


                --dbms_output.put_line('Before evaluating condition exstr is' || exstr );
                --dbms_output.put_line('Before evaluating condition l_tok is' || l_tok );
                --dbms_output.put_line('Before evaluating condition l_repl_word is' || l_repl_word );
                --dbms_output.put_line('Before evaluating condition l_condition_id is' || l_condition_id );
                --dbms_output.put_line('Before evaluating condition l_user_spec_cond_value is' || l_user_spec_cond_value);

                -- Exit Loop when no rows found
                IF c_wl_repl_string%NOTFOUND
                THEN
                   --dbms_output.put_line('Exiting with out evaluating condition');
                   exit ;
                -- Evaluate condition and if true, exit after setting NONE
                ELSIF HZ_WORD_CONDITIONS_PKG.evaluate_condition (      --------> CONDITION EVALUATION BEGINS
                                                    exstr,
                                                    l_tok,
                                                    l_repl_word,
                                                    l_condition_id,
                                                    l_user_spec_cond_value )
                THEN
                        IF l_repl_word IS NOT NULL THEN
                            l_repl_str := l_repl_str || ' '|| l_repl_word;
                        END IF ;
                        NONE := FALSE ;
                        --dbms_output.put_line('After evaluating condition l_repl_str is' || l_repl_str );
                        exit ;


                END IF;                                             --------> CONDITION EVALUATION ENDS

            END LOOP ;                                             --> CONDITIONAL LOOP FOR L_TOK ENDS

            CLOSE c_wl_repl_string;

            -- NO CONDITIONS SATISFIED
            IF NONE
            THEN
                       -- TRY NON-DELIMITED WORD REPLACEMENTS
                       -- initialize the in/out varibale to the token value during the first pass
                       l_in_str := l_tok ;
                       l_repl_token := '';
                       l_concat_repl_token := '';
                       l_remainder_str := '';
                       --dbms_output.put_line('About to enter non-delimited Loop');
                       LOOP         ---> NON DELIMITED REPLACEMENT BEGINS
                       -- --dbms_output.put_line('Inside Loop');
                       IF l_in_str is null
                       THEN
                		EXIT;
                       END IF;
                       get_repl_token ( l_wl_id, l_tok, l_in_str, l_repl_token, l_remainder_str, l_replacement_range);
                       l_concat_repl_token := l_concat_repl_token || l_repl_token ;
                       --dbms_output.put_line('Concatented Replacement Token is ' || l_concat_repl_token );
                       END LOOP ;  ---> NON DELIMITED REPLACEMENT ENDS
                       l_repl_str := l_repl_str || ' '|| l_concat_repl_token ;
            END IF ;

     END IF ;


  -- One time string tokenizer call per loop
  l_tok := HZ_DQM_SEARCH_UTIL.strtok;


  END LOOP;                    ----> OUTER LOOP


  l_repl_str := ltrim(l_repl_str);

  --dbms_output.put_line('Returned String is' || l_repl_str );

  RETURN l_repl_str;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','HZ_TRANS_PKG.word_replace_non_delimited');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END word_replace_non_delimited ;


FUNCTION word_replace_private (
        p_input_str             IN      VARCHAR2,
        p_replacement_set       IN      NUMBER,
        p_language              IN      VARCHAR2,
        p_has_spc               IN      BOOLEAN DEFAULT FALSE,
        p_noise_word_check      IN      VARCHAR2 DEFAULT 'N'
        )
RETURN VARCHAR2 IS
BEGIN

-- Populate Word Array
HZ_WORD_ARRAY_PKG.populate_word_arrays(p_replacement_set);

-- Delimited Word Replacement
IF HZ_WORD_ARRAY_PKG.word_list_ndl_flag_lookup(p_replacement_set) = 'N'
THEN
    RETURN word_replace_delimited (
        p_input_str,
        p_replacement_set,
        p_language,
        p_has_spc,
        p_noise_word_check
        ) ;


-- Non_Delimited Word Replacement
ELSE
     RETURN word_replace_non_delimited (
        p_input_str,
        p_replacement_set,
        p_language,
        p_has_spc,
        p_noise_word_check
        ) ;

END IF ;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','HZ_TRANS_PKG.word_replace_private');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END word_replace_private ;






-- Version of word_replace that gets called with name of word list
FUNCTION word_replace (
        p_input_str             IN      VARCHAR2,
        p_word_list_name        IN      VARCHAR2,
        p_language              IN      VARCHAR2)
     RETURN VARCHAR2 IS

CURSOR c_wl_id IS
  SELECT word_list_id FROM HZ_WORD_LISTS
  WHERE word_list_name = p_word_list_name ;

l_wl_id NUMBER;

BEGIN

  OPEN c_wl_id;
  FETCH c_wl_id INTO l_wl_id;
  IF c_wl_id%NOTFOUND THEN
    CLOSE c_wl_id;
    RETURN p_input_str;
  ELSE
    RETURN word_replace(p_input_str, l_wl_id , p_language) ;
  END IF;

  CLOSE c_wl_id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.word_replace');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END word_replace;

-- Version of word_replace that gets called with word list id
FUNCTION word_replace (
        p_input_str             IN      VARCHAR2,
        p_word_list_id          IN      NUMBER,
        p_language              IN      VARCHAR2)
     RETURN VARCHAR2 IS

BEGIN

     RETURN word_replace_private( p_input_str, p_word_list_id, p_language) ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.word_replace');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END word_replace;


-- VJN Introduced change for Bug 3829926
-- This will do a word replacement, only when the replacement word is null.
-- In other words, it would only replace noise words in the input string

FUNCTION word_replace_noise_words_only (
        p_input_str             IN      VARCHAR2,
        p_word_list_id          IN      NUMBER,
        p_language              IN      VARCHAR2,
        p_has_spc               IN      BOOLEAN DEFAULT FALSE)
     RETURN VARCHAR2 IS

BEGIN
     --dbms_output.put_line(' calling word_replace with noise words flag as Y');
     RETURN word_replace_private( p_input_str, p_word_list_id, p_language, p_has_spc, 'Y');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.word_replace_noise_words_only');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END word_replace_noise_words_only ;




/************* Simple Transformations *************************/

FUNCTION EXACT (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2 IS

  retstr varchar2(4000);
  r1 varchar2(4000);

BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') then
    return '';
  END IF;
  IF p_attribute_name = 'DUNS_NUMBER_C' THEN
    RETURN RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name);--bug 5128213
  END IF;


    retstr:= LTRIM(RTRIM(TRANSLATE(p_original_value,
                   '%0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&+-,./@'||g_latin_from ||'!"#$()''*:;<=>?[\]^_`{|}~'|| g_unprintables,
                   '%0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ       '||g_latin_to )));


  WHILE instr(retstr,'  ')>0 LOOP
    r1 := retstr;
    retstr := REPLACE(retstr, '  ',' ');
    EXIT WHEN r1 = retstr;
  END LOOP;

  IF p_attribute_name like 'DUNS_NUMBER_C' then
    return retstr||'='||lpad(retstr,9,'0');
  END IF;

  RETURN retstr;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.exact');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END EXACT;

FUNCTION CLEANSE (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2 IS

  retstr varchar2(4000);

BEGIN

  IF (p_original_value IS NULL OR p_original_value = '') THEN
    return '';
  end if;

  retstr := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);

  -- Remove Double letters
  retstr := replace(retstr,'AA','A');
  retstr := replace(retstr,'BB','B');
  retstr := replace(retstr,'CC','C');
  retstr := replace(retstr,'DD','D');
  retstr := replace(retstr,'EE','E');
  retstr := replace(retstr,'FF','F');
  retstr := replace(retstr,'GG','G');
  retstr := replace(retstr,'HH','H');
  retstr := replace(retstr,'II','I');
  retstr := replace(retstr,'JJ','J');
  retstr := replace(retstr,'KK','K');
  retstr := replace(retstr,'LL','L');
  retstr := replace(retstr,'MM','M');
  retstr := replace(retstr,'NN','N');
  retstr := replace(retstr,'OO','O');
  retstr := replace(retstr,'PP','P');
  retstr := replace(retstr,'QQ','Q');
  retstr := replace(retstr,'RR','R');
  retstr := replace(retstr,'SS','S');
  retstr := replace(retstr,'TT','T');
  retstr := replace(retstr,'UU','U');
  retstr := replace(retstr,'VV','V');
  retstr := replace(retstr,'WW','W');
  retstr := replace(retstr,'XX','X');
  retstr := replace(retstr,'YY','Y');
  retstr := replace(retstr,'ZZ','Z');

  -- Remove Vowels (except from the 1st characters
  retstr := upper(translate(initcap(lower(retstr)),
                        '%bcdfghjklmnpqrstvwxzyaeiou',
                        '%bcdfghjklmnpqrstvwxz'));
  IF instr(retstr,'%')>0 THEN
    retstr := replace(retstr,'%A','%');
    retstr := replace(retstr,'%E','%');
    retstr := replace(retstr,'%I','%');
    retstr := replace(retstr,'%O','%');
    retstr := replace(retstr,'%U','%');
    retstr := replace(retstr,'%Y','%');
  END IF;
  RETURN retstr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.exact');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CLEANSE;

FUNCTION Reverse_Phone_number(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN substrb(hz_phone_number_pkg.transpose(p_original_value)
                ,1,7);
END Reverse_Phone_number;

FUNCTION RM_SPLCHAR_CTX (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 )
RETURN VARCHAR2 IS

BEGIN
  IF p_context='STAGE' THEN
    RETURN RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name);--bug 5128213
  ELSIF p_context='SCORE' THEN
    RETURN NULL;
  ELSE
    RETURN RM_BLANKS(p_original_value,p_language,p_attribute_name,p_entity_name);
  END IF;
END;

FUNCTION EXACT_DATE(
        p_original_value        IN      DATE,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
     RETURN VARCHAR2 IS
BEGIN
  RETURN TO_CHAR(p_original_value, 'DD-MON-YYYY');
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END;

FUNCTION EXACT_NUMBER(
        p_original_value        IN      NUMBER,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
     RETURN VARCHAR2 IS
BEGIN
  RETURN TO_CHAR(p_original_value);
EXCEPTION
  WHEN INVALID_NUMBER THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;
END EXACT_NUMBER;

FUNCTION EXACT_EMAIL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

  retstr varchar2(1000);

BEGIN
  RETURN upper(p_original_value);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.EXACT_EMAIL');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END EXACT_EMAIL;

FUNCTION RM_SPLCHAR (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2 DEFAULT NULL) --bug 5128213
RETURN VARCHAR2 IS

  retstr varchar2(4000);
  r1 varchar2(4000);
  pos number;
  len number;
BEGIN
--bug 5128213 start
IF p_context='STAGE'AND next_gen_dqm = 'Y' THEN
  return RM_SPLCHAR_BLANKS(p_original_value,p_language,p_attribute_name, p_entity_name,p_context);
ELSE
  return RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);
END IF;
--bug 5128213 end

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.exact');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END RM_SPLCHAR;

--bug 5128213 start
FUNCTION RM_SPLCHAR_PRIVATE (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2 IS

  retstr varchar2(4000);
  r1 varchar2(4000);
  pos number;
  len number;
BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') then
    return '';
  END IF;

  retstr:= LTRIM(RTRIM(TRANSLATE(p_original_value,
                   '%0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.!"#$&'||g_latin_from ||'()''*+,-/:;<=>?@[\]^_`{|}~'|| g_unprintables,
                   '%0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ......'||g_latin_to )));
  WHILE instr(retstr,'  ')>0 LOOP
    r1 := retstr;
    retstr := REPLACE(retstr, '  ',' ');
    EXIT WHEN r1 = retstr;
  END LOOP;

  retstr:=REPLACE(retstr,' . ','.');
  retstr:=REPLACE(retstr,' .','.');
  retstr:=REPLACE(retstr,'. ','.');

  pos := instr(retstr,'.');
  len := length(retstr);
  WHILE (pos > 0) LOOP
    IF pos + 2 > len THEN
      retstr := substr(retstr, 1, pos-1)||substr(retstr, pos+1);
      EXIT;
    ELSE
      IF (substr(retstr,pos+2,1) in (' ','.')) THEN
        retstr := substr(retstr, 1, pos-1)||substr(retstr, pos+1);
        len := len-2;
        pos := instr(retstr, '.');
      ELSE
        pos := instr(retstr, '.', pos+2);
      END IF;
    END IF;
  END LOOP;
  retstr:=REPLACE(retstr,'.',' ');

  RETURN retstr;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.exact');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END RM_SPLCHAR_PRIVATE;
--bug 5128213 end

FUNCTION RM_BLANKS (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2 IS

  retstr varchar2(4000);

BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') then
    return '';
  END IF;

  retstr:= LTRIM(RTRIM(TRANSLATE(p_original_value,
                   '%0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'||g_latin_from || '!"#$&()''*+,-./:;<=>?@[\]^_`{|}~ '|| g_unprintables,
                   '%0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ'||g_latin_to)));

  RETURN retstr;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.exact');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END RM_BLANKS;

FUNCTION EXACT_URL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

  retstr varchar2(1000);
  l_pos NUMBER := 0;
BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') then
    return '';
  end if;

  retstr := UPPER(p_original_value);
  IF instrb(retstr,'://')>0 THEN
    retstr := substrb(retstr,instrb(retstr,':/')+3);
    l_pos := instrb(retstr,'/');
  ELSIF instrb(retstr,':/')>0 THEN
    retstr := substrb(retstr,instrb(retstr,':/')+2);
    l_pos := instrb(retstr,'/');
  ELSE
    l_pos := instrb(retstr,'/');
  END IF;

  IF l_pos > 1 THEN
    RETURN substrb(retstr,1,l_pos-1);
  ELSE
    RETURN retstr;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.CLEANSED_URL');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END EXACT_URL;

FUNCTION SOUNDX (
        p_original_value VARCHAR2,
        p_language VARCHAR2,
        p_attribute_name VARCHAR2,
        p_entity_name    VARCHAR2)
     RETURN VARCHAR2 IS
BEGIN

  RETURN soundex(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.SOUNDX');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END SOUNDX;

FUNCTION EXACT_PADDED (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  return '#' || EXACT(p_original_value,p_language,p_attribute_name,p_entity_name) || '#'
;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.exact_padded');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END EXACT_PADDED;


















/**************** Word Replacement Transformations **********/

FUNCTION CLEANSED_EMAIL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  retstr varchar2(2000);

BEGIN
  retstr := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);

  IF (retstr IS NULL OR retstr = '') then
    RETURN '';
  END IF;

  IF p_context = 'STAGE' THEN
    RETURN CLEANSED(word_replace(retstr, 5, p_language));
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    RETURN CLEANSED(word_replace(retstr, 5, p_language));
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.CLEANSED_EMAIL');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CLEANSED_EMAIL;

FUNCTION CLEANSED_URL (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  retstr varchar2(2000);
BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') then
    return '';
  end if;

  retstr := EXACT_URL(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),
               p_language,p_attribute_name,p_entity_name);

  IF (retstr IS NULL OR retstr = '') then
    RETURN '';
  END IF;

  IF p_context = 'STAGE' THEN
    RETURN LTRIM(RTRIM(CLEANSED(word_replace(retstr, 5, p_language))));
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    RETURN LTRIM(RTRIM(CLEANSED(word_replace(retstr, 5, p_language))));
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.CLEANSED_URL');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CLEANSED_URL;
FUNCTION person_exact_old_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS
  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  rem VARCHAR2(2000);
  str1 VARCHAR2(2000);

   -- VJN Introduced
  noise_removed_orig VARCHAR2(2000);

BEGIN
  IF p_context = 'STAGE' THEN
    BEGIN
    IF g_last_wrperson_orig = p_original_value THEN
      RETURN g_last_wrperson_exact;
    END IF;
    g_last_wrperson_orig := p_original_value;
    str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
    g_last_wrperson_exact:=str;
    str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);--bug 5128213
    IF str <> str1 THEN
        str := str ||' '||str1;
    END IF;

   -- VJN Introduced change for Bug 3829926
   -- VJN Get a copy of the string to be word replaced, after removing the noise words

   noise_removed_orig := word_replace_noise_words_only(str,3,p_language);
   wrstr := word_replace(str,3,p_language);

   g_last_wrperson_exact:=wrstr;


    first := FIRST_WORD(noise_removed_orig,rem);
    IF noise_removed_orig <> wrstr THEN
      g_last_wrperson_exact := wrstr||' '||noise_removed_orig ||' '||first;
    ELSE
      g_last_wrperson_exact := noise_removed_orig ||' '||first;
    END IF;
    RETURN g_last_wrperson_exact;
    EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode=-6502 THEN
          RETURN g_last_wrperson_exact;
        ELSE
          RAISE;
        END IF;
    END;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wrperson_orig = p_original_value THEN
      RETURN g_last_wrperson_exact;
    END IF;
    g_last_wrperson_orig := p_original_value;
    IF g_dqm_wildchar_search THEN
        g_last_wrperson_exact := word_replace(RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name),3,p_language);--bug 5128213
    ELSE
        g_last_wrperson_exact := word_replace(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),3,p_language);
    END IF;

    RETURN g_last_wrperson_exact;
  END IF;

END person_exact_old_private;

FUNCTION WRPerson_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS
BEGIN
 If next_gen_dqm = 'Y' THEN
  RETURN person_exact_new_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
 ELSE
  RETURN person_exact_old_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
 END IF;
END WRPerson_Exact;

FUNCTION person_exact_new_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS
  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  rem VARCHAR2(2000);
  str1 VARCHAR2(2000);

   -- VJN Introduced
  noise_removed_orig VARCHAR2(2000);

BEGIN
  IF p_context = 'STAGE' THEN
    BEGIN
    IF g_last_wrperson_orig = p_original_value THEN
      RETURN g_last_wrperson_exact;
    END IF;
    g_last_wrperson_orig := p_original_value;
    str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
    g_last_wrperson_exact:=str;
    str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);--bug 5128213
    IF str <> str1 THEN
        str := str ||' '||str1;
    END IF;

    wrstr := word_replace(str,3,p_language);

    g_last_wrperson_exact:=wrstr;
    first := FIRST_WORD(g_last_wrperson_exact,rem);
    if(first <> g_last_wrperson_exact) then
     g_last_wrperson_exact := '!'||replace(g_last_wrperson_exact,' ')||'! !'||first||' '||g_last_wrperson_exact;
    else --there is no space
     g_last_wrperson_exact := '!'||g_last_wrperson_exact||'!';
    end if;

    RETURN g_last_wrperson_exact;
    EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode=-6502 THEN
          RETURN g_last_wrperson_exact;
        ELSE
          RAISE;
        END IF;
    END;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wrperson_orig = p_original_value THEN
      RETURN g_last_wrperson_exact;
    END IF;
    g_last_wrperson_orig := p_original_value;
    IF g_dqm_wildchar_search THEN
        g_last_wrperson_exact := word_replace(RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name),3,p_language);--bug 5128213
    ELSE
        g_last_wrperson_exact := word_replace(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),3,p_language);
    END IF;

    RETURN g_last_wrperson_exact;
  END IF;

END person_exact_new_private;

FUNCTION WRPerson_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);
BEGIN
  IF p_context = 'STAGE' THEN
    RETURN CLEANSED(person_exact_old_private(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
  ELSIF p_context = 'SCORE' THEN
    RETURN cleansed_in_score_ctx(p_original_value);
  ELSE
    exstr := person_exact_old_private(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
      RETURN exstr;
    ELSE
      RETURN CLEANSED(exstr);
    END IF;
  END IF;

END WRPerson_Cleanse;

FUNCTION org_exact_old_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  rem VARCHAR2(2000);
  str1 VARCHAR2(2000);

  -- VJN Introduced
  noise_removed_orig VARCHAR2(2000);

BEGIN
  IF p_context = 'STAGE' THEN
    BEGIN
    IF g_last_wrorg_orig = p_original_value THEN
      RETURN g_last_wrorg_exact;
    END IF;
    g_last_wrorg_orig := p_original_value;

    str := EXACT(p_original_value,p_language,p_attribute_name, p_entity_name);
    str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);--bug 5128213
    IF str <> str1 THEN
         str := str ||' '||str1;
    END IF;

   -- VJN Introduced change for Bug 3829926
   -- VJN Get a copy of the string to be word replaced, after removing the noise words

   noise_removed_orig := word_replace_noise_words_only(str,2,p_language);
   g_last_wrorg_exact := word_replace(str,2,p_language);



    --dbms_output.put_line('str is ' || str);
    --dbms_output.put_line('g_last_wrorg_exact is ' || g_last_wrorg_exact );
    --dbms_output.put_line('noise_removed_orig is ' || noise_removed_orig );

    IF noise_removed_orig <> g_last_wrorg_exact THEN
      g_last_wrorg_exact := g_last_wrorg_exact||' '||noise_removed_orig;
    END IF;

    RETURN g_last_wrorg_exact;
    EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode=-6502 THEN
          RETURN g_last_wrorg_exact;
        ELSE
          RAISE;
        END IF;
    END;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wrorg_orig = p_original_value THEN
      RETURN g_last_wrorg_exact;
    END IF;
    g_last_wrorg_orig := p_original_value;

    IF g_dqm_wildchar_search THEN
        g_last_wrorg_exact := word_replace(RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name),2,p_language);--bug 5128213
    ELSE
        g_last_wrorg_exact := word_replace(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),2,p_language);
    END IF;

    RETURN g_last_wrorg_exact;
  END IF;
END org_exact_old_private;

FUNCTION WROrg_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS
BEGIN
  If next_gen_dqm = 'Y' THEN
    RETURN org_exact_new_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
  ELSE
    RETURN org_exact_old_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
  END IF;
END WROrg_Exact;

FUNCTION org_exact_new_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  rem VARCHAR2(2000);
  str1 VARCHAR2(2000);

  -- VJN Introduced
  noise_removed_orig VARCHAR2(2000);

BEGIN
  IF p_context = 'STAGE' THEN
    BEGIN
    IF g_last_wrorg_orig = p_original_value THEN
      RETURN g_last_wrorg_exact;
    END IF;
    g_last_wrorg_orig := p_original_value;

    str := EXACT(p_original_value,p_language,p_attribute_name, p_entity_name);
    str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);--bug 5128213
    IF str <> str1 THEN
         str := str ||' '||str1;
    END IF;

    g_last_wrorg_exact := word_replace(str,2,p_language);
    first := FIRST_WORD(g_last_wrorg_exact,rem);
    if(first <> g_last_wrorg_exact) then
     g_last_wrorg_exact := '!'||replace(g_last_wrorg_exact,' ')||'! !'||first||' '||g_last_wrorg_exact;
    else --no space
     g_last_wrorg_exact := '!'||g_last_wrorg_exact||'!';
    end if;

    --dbms_output.put_line('str is ' || str);
    --dbms_output.put_line('g_last_wrorg_exact is ' || g_last_wrorg_exact );
    --dbms_output.put_line('noise_removed_orig is ' || noise_removed_orig );

    RETURN g_last_wrorg_exact;
    EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode=-6502 THEN
          RETURN g_last_wrorg_exact;
        ELSE
          RAISE;
        END IF;
    END;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wrorg_orig = p_original_value THEN
      RETURN g_last_wrorg_exact;
    END IF;
    g_last_wrorg_orig := p_original_value;

    IF g_dqm_wildchar_search THEN
        g_last_wrorg_exact := word_replace(RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name),2,p_language);--bug 5128213
    ELSE
        g_last_wrorg_exact := word_replace(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),2,p_language);
    END IF;

    RETURN g_last_wrorg_exact;
  END IF;
END org_exact_new_private;


FUNCTION WROrg_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);
BEGIN
  IF p_context = 'STAGE' THEN
    RETURN CLEANSED(org_exact_old_private(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
  ELSIF p_context = 'SCORE' THEN
    RETURN cleansed_in_score_ctx(p_original_value);
  ELSE
    exstr := org_exact_old_private(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
      RETURN exstr;
    ELSE
      RETURN CLEANSED(exstr);
    END IF;
  END IF;
END WROrg_Cleanse;

FUNCTION PARTYNAMES_EXACT_OLD_PRIVATE(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS
  rem VARCHAR2(2000);
  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  str1 VARCHAR2(2000);
BEGIN
  IF p_context = 'STAGE' THEN
    IF g_last_wrnames_orig = p_original_value THEN
      RETURN g_last_wrnames_exact;
    END IF;
    g_last_wrnames_orig := p_original_value;

    IF g_party_type = 'ORGANIZATION' THEN
      g_last_wrnames_exact := org_exact_old_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSIF g_party_type = 'PERSON' THEN
      g_last_wrnames_exact := person_exact_old_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSE
      g_last_wrnames_exact := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
      str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);--bug 5128213
      IF g_last_wrnames_exact <> str1 THEN
          g_last_wrnames_exact := g_last_wrnames_exact ||' '||str1;
      END IF;
    END IF;

    RETURN g_last_wrnames_exact;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wrnames_orig = p_original_value THEN
      RETURN g_last_wrnames_exact;
    END IF;
    g_last_wrnames_orig := p_original_value;

    IF g_party_type = 'ORGANIZATION' THEN
      g_last_wrnames_exact := org_exact_old_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSIF g_party_type = 'PERSON' THEN
      g_last_wrnames_exact := person_exact_old_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSE
      IF g_dqm_wildchar_search THEN
          str := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name);--bug 5128213
      ELSE
          str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
      END IF;
      g_last_wrnames_exact:=str;
    END IF;
    RETURN g_last_wrnames_exact;
  END IF;
END PARTYNAMES_EXACT_OLD_PRIVATE;

FUNCTION WRNames_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS
l_original_value VARCHAR2(4000); --Bug No: 4084085
BEGIN
  -- Start of Bug No: 4084085
  l_original_value := p_original_value;
  if(p_context IS NULL OR p_context <> 'SEARCH') then
   l_original_value := RM_PERCENTAGE(l_original_value);
  end if;
  -- End of Bug No: 4084085
  If next_gen_dqm = 'Y' THEN
    RETURN partynames_exact_new_private(l_original_value,p_language,p_attribute_name,p_entity_name,p_context);
  ELSE
    RETURN partynames_exact_old_private(l_original_value,p_language,p_attribute_name,p_entity_name,p_context);
  END IF;
END WRNames_Exact;

FUNCTION partynames_exact_new_private(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  rem VARCHAR2(2000);
  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  str1 VARCHAR2(2000);
BEGIN
  IF p_context = 'STAGE' THEN
    IF g_last_wrnames_orig = p_original_value THEN
      RETURN g_last_wrnames_exact;
    END IF;
    g_last_wrnames_orig := p_original_value;

    IF g_party_type = 'ORGANIZATION' THEN
      g_last_wrnames_exact := org_exact_new_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSIF g_party_type = 'PERSON' THEN
      g_last_wrnames_exact := person_exact_new_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSE
      g_last_wrnames_exact := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
      str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);--bug 5128213
      IF g_last_wrnames_exact <> str1 THEN
          g_last_wrnames_exact := g_last_wrnames_exact ||' '||str1;
      END IF;
    END IF;

    RETURN g_last_wrnames_exact;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wrnames_orig = p_original_value THEN
      RETURN g_last_wrnames_exact;
    END IF;
    g_last_wrnames_orig := p_original_value;

    IF g_party_type = 'ORGANIZATION' THEN
      g_last_wrnames_exact := org_exact_new_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSIF g_party_type = 'PERSON' THEN
      g_last_wrnames_exact := person_exact_new_private(p_original_value,p_language,p_attribute_name,p_entity_name,p_context);
    ELSE
      IF g_dqm_wildchar_search THEN
          str := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name);--bug 5128213
      ELSE
          str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
      END IF;
      g_last_wrnames_exact:=str;
    END IF;
    RETURN g_last_wrnames_exact;
  END IF;
END partynames_exact_new_private;

FUNCTION WRNames_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);
l_original_value VARCHAR2(4000); -- Bug No: 4084085
BEGIN
  -- Start of Bug No: 4084085
  l_original_value := p_original_value;
  if(p_context IS NULL OR p_context <> 'SEARCH') then
   l_original_value := RM_PERCENTAGE(l_original_value);
  end if;
  -- End of Bug No: 4084085
  IF p_context = 'STAGE' THEN
    RETURN CLEANSED(partynames_exact_old_private(l_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
  ELSIF p_context = 'SCORE' THEN
    RETURN cleansed_in_score_ctx(l_original_value);
  ELSE
    exstr := partynames_exact_old_private(l_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
      RETURN exstr;
    ELSE
      RETURN CLEANSED(exstr);
    END IF;
  END IF;
END WRNames_Cleanse;

FUNCTION WRAddress_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
  str1 VARCHAR2(2000);

   -- VJN Introduced
  noise_removed_orig VARCHAR2(2000);
BEGIN
  IF p_context = 'STAGE' THEN
    IF g_last_wraddr_orig = p_original_value THEN
      RETURN g_last_wraddr_exact;
    END IF;
    g_last_wraddr_orig := p_original_value;

    str := EXACT(p_original_value,p_language,p_attribute_name, p_entity_name);
    str1 := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name, p_entity_name);
    IF str <> str1 THEN
         str := str ||' '||str1;
    END IF;


   -- VJN Introduced change for Bug 3829926
   -- VJN Get a copy of the string to be word replaced, after removing the noise words

   noise_removed_orig := word_replace_noise_words_only(str,1,p_language);
   g_last_wraddr_exact := word_replace(str,1,p_language);

    IF noise_removed_orig <> g_last_wraddr_exact THEN
      g_last_wraddr_exact := g_last_wraddr_exact||' '||noise_removed_orig;
    END IF;
    RETURN g_last_wraddr_exact;
  ELSIF p_context = 'SCORE' THEN
    RETURN NULL;
  ELSE
    IF g_last_wraddr_orig = p_original_value THEN
      RETURN g_last_wraddr_exact;
    END IF;
    g_last_wraddr_orig := p_original_value;

    IF g_dqm_wildchar_search THEN
        g_last_wraddr_exact := word_replace(RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name),1,p_language);--bug 5128213
    ELSE
        g_last_wraddr_exact := word_replace(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),1,p_language);
    END IF;
    RETURN g_last_wraddr_exact;
  END IF;
END WRAddress_Exact;

FUNCTION WRAddress_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);
BEGIN
  IF p_context = 'STAGE' THEN
    RETURN CLEANSED(WRAddress_Exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
  ELSIF p_context = 'SCORE' THEN
    RETURN cleansed_in_score_ctx(p_original_value);
  ELSE
    exstr := WRAddress_Exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
      RETURN exstr;
    ELSE
      RETURN CLEANSED(exstr);
    END IF;
  END IF;
END WRAddress_Cleanse;

FUNCTION WRState_Exact(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

  str VARCHAR2(2000);
  wrstr VARCHAR2(2000);
  first VARCHAR2(2000);
BEGIN
  IF g_last_wrstate_orig = p_original_value THEN
    RETURN g_last_wrstate_exact;
  END IF;
  g_last_wrstate_orig := p_original_value;

  IF p_context = 'STAGE' THEN
    str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
    g_last_wrstate_exact := word_replace_private(str,4,p_language,TRUE);
    IF str <> g_last_wrstate_exact THEN
      g_last_wrstate_exact := g_last_wrstate_exact ||' '||str;
    END IF;
  ELSIF p_context = 'SCORE' THEN
   g_last_wrstate_orig:='-1'; -- Bug No 7120851
    RETURN NULL;
  ELSE
    g_last_wrstate_exact := word_replace_private(EXACT(p_original_value,p_language,p_attribute_name,p_entity_name),4,p_language,TRUE);
  END IF;

  RETURN g_last_wrstate_exact;
END WRState_Exact;

FUNCTION WRState_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);
BEGIN
  IF p_context = 'STAGE' THEN
    RETURN CLEANSED(WRState_Exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
  ELSIF p_context = 'SCORE' THEN
    RETURN cleansed_in_score_ctx(p_original_value);
  ELSE
    exstr := WRState_Exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
      RETURN exstr;
    ELSE
      RETURN CLEANSED(exstr);
    END IF;
  END IF;
END WRState_Cleanse;

FUNCTION Basic_WRNames (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

wrstr VARCHAR2(4000);
str VARCHAR2(4000);
BEGIN
  IF p_context='SCORE' THEN
    RETURN NULL;
  END IF;

  str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
  IF g_party_type = 'ORGANIZATION' THEN
    RETURN word_replace(str,2,p_language);
  ELSIF g_party_type = 'PERSON' THEN
    RETURN word_replace(str,3,p_language);
  ELSIF g_party_type IS NOT NULL THEN
    RETURN str;
  ELSE
    wrstr:=word_replace(str,3,p_language);
    IF (wrstr = str) THEN
      RETURN word_replace(str,2,p_language);
    ELSE
      RETURN wrstr;
    END IF;
  END IF;
  RETURN g_last_wrnames_exact;
END;

FUNCTION Basic_Cleanse_WRNames (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);

BEGIN
  IF g_match_rule_purpose = 'Q' THEN
    exstr := Basic_WRNames(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      RETURN NULL;
    END IF;
    RETURN CLEANSED(exstr);
  ELSE
    IF p_context = 'STAGE' THEN
      RETURN CLEANSED(Basic_WRNames(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
    ELSIF p_context = 'SCORE' THEN
      RETURN cleansed_in_score_ctx(p_original_value);
    ELSE
      exstr := Basic_WRNames(p_original_value, p_language,p_attribute_name,
                   p_entity_name,p_context);
      IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
        g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
        RETURN exstr;
      ELSE
        RETURN CLEANSED(exstr);
      END IF;
    END IF;
  END IF;
END Basic_Cleanse_WRNames;


FUNCTION Basic_WRPerson (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

wrstr VARCHAR2(4000);
str VARCHAR2(4000);
BEGIN
  str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
  IF p_context='SCORE' THEN
    RETURN NULL;
  END IF;

  RETURN word_replace(str,3,p_language);
END;

FUNCTION Basic_Cleanse_WRPerson (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);

BEGIN
  IF g_match_rule_purpose = 'Q' THEN
    exstr := Basic_WRPerson(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      RETURN NULL;
    END IF;
    RETURN CLEANSED(exstr);
  ELSE
    IF p_context = 'STAGE' THEN
      RETURN CLEANSED(Basic_WRPerson(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
    ELSIF p_context = 'SCORE' THEN
      RETURN cleansed_in_score_ctx(p_original_value);
    ELSE
      exstr := Basic_WRPerson(p_original_value, p_language,p_attribute_name,
                   p_entity_name,p_context);
      IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
        g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
        RETURN exstr;
      ELSE
        RETURN CLEANSED(exstr);
      END IF;
    END IF;
  END IF;
END Basic_Cleanse_WRPerson;

FUNCTION Basic_WRAddr (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

wrstr VARCHAR2(4000);
str VARCHAR2(4000);
BEGIN
  str := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
  IF p_context='SCORE' THEN
    RETURN NULL;
  END IF;

  RETURN word_replace(str,1,p_language);
END;

FUNCTION Basic_Cleanse_WRAddr (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

exstr VARCHAR2(4000);

BEGIN
  IF g_match_rule_purpose = 'Q' THEN
    exstr := Basic_WRAddr(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context);
    IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
      RETURN NULL;
    END IF;
    RETURN CLEANSED(exstr);
  ELSE
    IF p_context = 'STAGE' THEN
      RETURN CLEANSED(Basic_WRAddr(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context));
    ELSIF p_context = 'SCORE' THEN
      RETURN cleansed_in_score_ctx(p_original_value);
    ELSE
      exstr := Basic_WRAddr(p_original_value, p_language,p_attribute_name,
                   p_entity_name,p_context);
      IF HZ_DQM_SEARCH_UTIL.estimated_length(exstr) <g_threshold_length THEN
        g_exact_for_cleansed(g_exact_for_cleansed.COUNT+1):=exstr;
        RETURN exstr;
      ELSE
        RETURN CLEANSED(exstr);
      END IF;
    END IF;
  END IF;
END Basic_Cleanse_WRAddr;














/************************* Unused Transformations ****************/

FUNCTION CLUSTER_WORD (
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

l_exstr VARCHAR2(4000);
l_retstr VARCHAR2(4000);
l_spc_char NUMBER;
l_len NUMBER;

BEGIN

  l_exstr := EXACT(p_original_value,p_language,p_attribute_name,p_entity_name);
  IF (l_exstr IS NULL OR l_exstr = '') THEN
    return '';
  end if;

  l_spc_char := nvl(instr(l_exstr,' '),0);
  l_len := length(l_exstr);

  IF l_spc_char=0 THEN
    RETURN substr(l_exstr,1,least(3,l_len));
  ELSE
    l_retstr := substr(l_exstr,1,least(3,(l_spc_char-1)));
    IF l_len>l_spc_char THEN
      l_retstr := l_retstr || ' ' || substr(l_exstr,l_spc_char+1,least(3,(l_len-l_spc_char)));
    END IF;
  END IF;

  RETURN l_retstr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.clusterw');
    FND_MESSAGE.SET_TOKEN('ERROR ' ,'val ' || p_original_value ||  ' ' || SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CLUSTER_WORD;

FUNCTION ACRONYM (
        p_original_value VARCHAR2,
        p_language VARCHAR2,
        p_attribute_name VARCHAR2,
        p_entity_name    VARCHAR2)
     RETURN VARCHAR2 IS
BEGIN

  RETURN TRANSLATE(INITCAP(LOWER(
      RM_SPLCHAR_PRIVATE(p_original_value, p_language,p_attribute_name,--bug 5128213
                       p_entity_name))),
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ',
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC' ,'HZ_TRANS_PKG.abbrev');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END ACRONYM;

FUNCTION REVERSE_NAME (
               p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

l_exstr VARCHAR2(4000);
l_retstr VARCHAR2(4000);
l_spc_char NUMBER;
l_spc_char1 NUMBER;
len NUMBER;

BEGIN
  IF (p_original_value IS NULL OR p_original_value = '') THEN
    return '';
  end if;

  l_exstr := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name);--bug 5128213

  l_spc_char := nvl(instr(l_exstr,' '),0);
  IF l_spc_char = 0 THEN
    RETURN l_exstr;
  END IF;

  l_retstr := substr(l_exstr,1,l_spc_char-1);

  l_exstr := substr(l_exstr,l_spc_char+1);
  l_spc_char := nvl(instr(l_exstr,' '),0);
  WHILE l_spc_char <> 0 LOOP
    l_exstr := substr(l_exstr,l_spc_char+1);
    l_spc_char := nvl(instr(l_exstr,' '),0);
  END LOOP;
  RETURN l_exstr || ' ' || l_retstr;

END REVERSE_NAME;

FUNCTION WRPerson_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLUSTER_WORD(WRPerson_exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context), p_language,p_attribute_name,p_entity_name);
END WRPerson_Cluster;

FUNCTION WROrg_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLUSTER_WORD(WROrg_Exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context), p_language,p_attribute_name,p_entity_name);
END WROrg_Cluster;

FUNCTION WRNames_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLUSTER_WORD(WRNames_Exact(p_original_value, p_language,p_attribute_name,
                 p_entity_name,p_context), p_language,p_attribute_name,p_entity_name);
END WRNames_Cluster;

FUNCTION Reverse_WRNames_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLUSTER_WORD(WORD_REPLACE(WORD_REPLACE(
            REVERSE_NAME(p_original_value,p_language,p_attribute_name,p_entity_name),
            2,p_language),
            3,p_language),
            p_language,p_attribute_name,p_entity_name);
END Reverse_WRNames_Cluster;

FUNCTION Reverse_WRNames_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLEANSE(WORD_REPLACE(WORD_REPLACE(
            REVERSE_NAME(p_original_value,p_language,p_attribute_name,p_entity_name),
            2,p_language),
            3,p_language),
            p_language,p_attribute_name,p_entity_name);
END Reverse_WRNames_Cleanse;

FUNCTION Reverse_WRPerson_Cluster(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLUSTER_WORD(WORD_REPLACE(
            REVERSE_NAME(p_original_value,p_language,p_attribute_name,p_entity_name),
            3,p_language),
            p_language,p_attribute_name,p_entity_name);
END Reverse_WRPerson_Cluster;

FUNCTION Reverse_WRPerson_Cleanse(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
  RETURN VARCHAR2 IS

BEGIN
  RETURN CLEANSE(WORD_REPLACE(
            REVERSE_NAME(p_original_value,p_language,p_attribute_name,p_entity_name),
            3,p_language),
            p_language,p_attribute_name,p_entity_name);
END Reverse_WRPerson_Cleanse;

PROCEDURE set_staging_context (p_staging_context varchar2)
IS
BEGIN
 staging_context := nvl(p_staging_context,'N');
END;
--Start of Bug No: 3515419
FUNCTION RM_SPLCHAR_BLANKS(
        p_original_value        IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2,
        p_context               IN      VARCHAR2)
  RETURN VARCHAR2
IS
l_str VARCHAR2(2000);
BEGIN
  IF p_context ='STAGE' THEN
    l_str := RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name);--bug 5128213
    if(instr(l_str,' ') >0 ) then
     return l_str ||' '|| RM_BLANKS(l_str,p_language,p_attribute_name,p_entity_name);
    else
     return l_str;
    end if;
  ELSE
    RETURN RM_BLANKS(RM_SPLCHAR_PRIVATE(p_original_value,p_language,p_attribute_name,p_entity_name),--bug 5128213
                     p_language,p_attribute_name,p_entity_name);
  END IF;
END;
--End of Bug No: 3515419

-- Start of Bug No: 4084085
FUNCTION RM_PERCENTAGE(p_original_value IN  VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 RETURN replace(p_original_value,'%');
END;
-- End of Bug No: 4084085
   --- THIS IS MAIN CODE FOR THE PACKAGE THAT GETS EXECUTED ONCE IN A SESSION, WHEN THIS PACKAGE GETS CALLED

   BEGIN
     SELECT count(*) INTO l_is_wildchar
     FROM HZ_DQM_STAGE_LOG
     WHERE operation = 'STAGE_FOR_WILDCHAR_SEARCH' AND ROWNUM = 1 ;
     IF  l_is_wildchar > 0 THEN
         g_dqm_wildchar_search := TRUE;
     END IF;
      -- a total of 64 latins
      g_latin_from := fnd_global.local_chr(50049)||fnd_global.local_chr(50081)||fnd_global.local_chr(50048)
                     ||fnd_global.local_chr(50080)||fnd_global.local_chr(50050)||fnd_global.local_chr(50082)
                     ||fnd_global.local_chr(50052)||fnd_global.local_chr(50084)||fnd_global.local_chr(50051)
                     ||fnd_global.local_chr(50083)||fnd_global.local_chr(50053)||fnd_global.local_chr(50085)
                     ||fnd_global.local_chr(50055)||fnd_global.local_chr(50087)||fnd_global.local_chr(50064)
                     ||fnd_global.local_chr(50096)||fnd_global.local_chr(50057)||fnd_global.local_chr(50089)
                     ||fnd_global.local_chr(50056)||fnd_global.local_chr(50088)||fnd_global.local_chr(50058)
                     ||fnd_global.local_chr(50090)||fnd_global.local_chr(50059)||fnd_global.local_chr(50091)
                     ||fnd_global.local_chr(50061)||fnd_global.local_chr(50093)||fnd_global.local_chr(50060)
                     ||fnd_global.local_chr(50092)||fnd_global.local_chr(50062)||fnd_global.local_chr(50094)
                     ||fnd_global.local_chr(50063)||fnd_global.local_chr(50095)||fnd_global.local_chr(50065)
                     ||fnd_global.local_chr(50097)||fnd_global.local_chr(50070)||fnd_global.local_chr(50102)
                     ||fnd_global.local_chr(50067)||fnd_global.local_chr(50099)||fnd_global.local_chr(50066)
                     ||fnd_global.local_chr(50098)||fnd_global.local_chr(50068)||fnd_global.local_chr(50100)
                     ||fnd_global.local_chr(50069)||fnd_global.local_chr(50101)||fnd_global.local_chr(50072)
                     ||fnd_global.local_chr(50104)||fnd_global.local_chr(15712189)||fnd_global.local_chr(15712189)
                     ||fnd_global.local_chr(50076)||fnd_global.local_chr(50108)||fnd_global.local_chr(50074)
                     ||fnd_global.local_chr(50106)||fnd_global.local_chr(50073)||fnd_global.local_chr(50105)
                     ||fnd_global.local_chr(50075)||fnd_global.local_chr(50107)||fnd_global.local_chr(50077)
                     ||fnd_global.local_chr(50109)||fnd_global.local_chr(15712189)||fnd_global.local_chr(50111)
                     ||fnd_global.local_chr(15712189)||fnd_global.local_chr(15712189)||fnd_global.local_chr(49825)
                     ||fnd_global.local_chr(49855) ;

      -- a total of 62 replacements
      g_latin_to   := 'AAAAAAAAAAAACCDDEEEEEEEEIIIIIIIINNOOOOOOOOOOOOSSUUUUUUUUYYYYZZ' ;
END;

/
