--------------------------------------------------------
--  DDL for Package Body HZ_DQM_MR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DQM_MR_PVT" AS
/* $Header: ARHDIMRB.pls 120.18 2006/07/21 06:24:49 rarajend noship $ */
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--- UTILITY FUNCTIONS FOR GETTING MATCH RULE INFO
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------


TYPE score_rec_type IS RECORD (
    sum_score   NUMBER,
    max_score   NUMBER,
    min_score   NUMBER
);


/*
-- just to debug execute immediate
-- if in case we use dynamic sql in our match rules
PROCEDURE sl(str VARCHAR2) IS
refstr1 varchar2(32000);
refstr2 varchar2(32000);
refstr3 varchar2(32000);
refstr4 varchar2(32000);
refstr5 varchar2(32000);
refstr6 varchar2(32000);
refstr7 varchar2(32000);
refstr8 varchar2(32000);


BEGIN
  -- SPIT OUT ONLY IF DEBUG FLAG IS ON
  IF debug_flag = 'Y'
  THEN
    refstr1 := replace(str,'''''','#');
    refstr2 := replace(refstr1,'''');
    refstr3 := replace(refstr2,'|| #%#', '@');
    refstr4 := replace(refstr3,'||');
    refstr5 := replace(refstr4,'@',' || ''%''');
    refstr6 := replace(refstr5,'#','''');
    refstr7 := replace(refstr6,'party_join_str');
    refstr8 := replace(refstr7,'subset_sql');
    dbms_output.put_line(refstr8);
  END IF;

  HZ_GEN_PLSQL.add_line(str);
END;
*/

-- Alias dbms.put_line, to avoid typing
PROCEDURE l(str VARCHAR2) IS
BEGIN
  HZ_GEN_PLSQL.add_line(str);
END;


FUNCTION get_misc_scores(p_match_rule_id number)
return score_rec_type
IS
    CURSOR c0
    IS
    select sum(sc) sum_score , max(sc) max_score , min(sc) min_score
    from
    (select  entity_name ename, sum(score) sc
     from hz_trans_attributes_vl a, hz_match_rule_secondary s
     where s.match_rule_id = p_match_rule_id
     and s.attribute_id = a.attribute_id
     group by entity_name
     order by sum(score) desc
     );
     srt score_rec_type ;
BEGIN
    -- initialise the record type , just to make sure
     srt.sum_score := 0  ;
     srt.max_score := 0 ;
     srt.min_score := 0 ;

    FOR score_rec IN c0
    LOOP
       srt.sum_score := score_rec.sum_score;
       srt.max_score := score_rec.max_score;
       srt.min_score := score_rec.min_score;
    END LOOP;
    return srt ;
END;

FUNCTION get_match_threshold (p_match_rule_id number)
RETURN number
IS
    CURSOR c0
    IS
    select match_score
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;
    l_yn  number ;
    result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_match_threshold ;


FUNCTION get_auto_merge_threshold (p_match_rule_id number)
RETURN number
IS
    CURSOR c0
    IS
    select auto_merge_score
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;
    l_yn  number ;
    result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO l_yn;
 CLOSE c0;
 RETURN l_yn ;
END get_auto_merge_threshold ;


FUNCTION get_match_all_flag (p_match_rule_id number)
RETURN varchar2
IS
    CURSOR c0
    IS
    select match_all_flag
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;
    result VARCHAR2(1);
BEGIN
 OPEN c0;
   FETCH c0 INTO result ;
 CLOSE c0;
 RETURN result ;
END get_match_all_flag ;


FUNCTION has_party_filter_attributes (p_match_rule_id number)
RETURN varchar2
IS
    result VARCHAR2(1) := 'N' ;
    filter_count number := 0;
BEGIN

    SELECT count(1) into filter_count
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = 'PARTY'
    and p.filter_flag = 'Y';
    IF filter_count > 0
    THEN
        result := 'Y';
    END IF;

    return result;
END has_party_filter_attributes ;

FUNCTION has_entity_filter_attributes (p_match_rule_id number, p_entity_name in varchar2)
RETURN varchar2
IS
    result VARCHAR2(1) := 'N' ;
    filter_count number := 0;
BEGIN

    SELECT count(1) into filter_count
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity_name
    and p.filter_flag = 'Y';
    IF filter_count > 0
    THEN
        result := 'Y';
    END IF;

    return result;
END has_entity_filter_attributes ;

-- will return true if this match rule has scoring attributes, for the passed in entity
FUNCTION has_scoring_attributes ( p_match_rule_id IN NUMBER, p_entity_name IN VARCHAR2)
RETURN BOOLEAN
IS
temp BOOLEAN := FALSE ;
BEGIN
        FOR attrs in (
        SELECT s.attribute_id
        FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
        where a.attribute_id=s.attribute_id
        and s.match_rule_id=p_match_rule_id
        and a.entity_name = p_entity_name
        )
        LOOP
            temp := TRUE ;
        END LOOP;
   return temp ;
END has_scoring_attributes ;


-- will return true if this match rule has any scoring attributes what so ever
FUNCTION has_scoring_attributes ( p_match_rule_id IN NUMBER)
RETURN BOOLEAN
IS
temp BOOLEAN := FALSE ;
BEGIN
     IF has_scoring_attributes ( p_match_rule_id, 'PARTY')
                OR
        has_scoring_attributes ( p_match_rule_id, 'PARTY_SITES')
                OR
        has_scoring_attributes ( p_match_rule_id, 'CONTACTS')
                OR
        has_scoring_attributes ( p_match_rule_id, 'CONTACT_POINTS')
     THEN
        temp := TRUE;
        return temp ;
     END IF;
     return temp;
END has_scoring_attributes ;

-------------------------------------------------------------------------
-- get_insert_threshold : This will return the threshold that needs
-- to be exceeded by every party level dup identification insert statement
-- in the generated code for the match rule
-------------------------------------------------------------------------


FUNCTION get_insert_threshold ( p_match_rule_id  NUMBER)
return number
IS
CURSOR entity_cur IS
                select  entity_name, sum(score) sc
                from hz_trans_attributes_vl a, hz_match_rule_secondary s
                where s.match_rule_id = p_match_rule_id
                and s.attribute_id = a.attribute_id
                group by entity_name
                order by sum(score) desc ;
srt score_rec_type;
threshold number;
row_count number;
match_score number;
no_of_entities number;
match_all_flag varchar2(1);
insert_threshold number;
BEGIN



    -- Get the threshold and match_all_flag
    select match_score, match_all_flag into match_score, match_all_flag
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;

    -- threhold for the most part is the match-score, except that
    -- we would change it according to the match_all_flag
    -- to force inserts and updates in  a certain way
    threshold := match_score;

    -- we want to capture the insert threshold for insert statements
    -- insert_threshold = (match score - sum of update entity scores)
    -- first, we initialize it by making it as big as the match score itself
    insert_threshold := match_score ;

    -- Get the different aggregates that would help in determining the template
    -- that need to be used -- UNION/UPDATE for the corresponding entity.
    srt := get_misc_scores(p_match_rule_id);

    -- Initialize the number of entities
    no_of_entities := 0;

    -- Get the number of entities
    FOR c0 in entity_cur
    LOOP
        no_of_entities := no_of_entities + 1;
    END LOOP;


    -- Before generating the code for the given match rule, we look at the
    -- match_all_flag to determine, the structure of the code that needs
    -- to go into the generated match rule package.
    -- The flag is always assumed to be 'N' by default ie., a match on ANY of the
    -- entities, would be given consideration.
    -- If flag = 'Y', then we need to make sure that every query after the first
    -- one is an update. We make this happen by manually setting the threshold.

    IF match_all_flag = 'Y'
    THEN
        threshold := srt.sum_score;
    END IF;

    -- Open the entity cursor, determine the templates (INSERT/UPDATE) for each
    -- entity and keep substracting the score for every update entity
    -- from insert_threshold
    row_count := 0;

    FOR entity_cur_rec in entity_cur
    LOOP
        row_count := row_count + 1;
            IF row_count = 2
            THEN
                IF (srt.sum_score - srt.max_score - threshold) < 0
                THEN
                    insert_threshold := insert_threshold - entity_cur_rec.sc ;
                END IF;
             END IF;

            IF row_count = 3
            THEN
                 IF no_of_entities = 3
                 THEN
                        IF (entity_cur_rec.sc  - threshold) < 0
                        THEN
                            insert_threshold := insert_threshold - entity_cur_rec.sc ;
                        END IF;

                 ELSE
                       IF ( entity_cur_rec.sc + srt.min_score - threshold) < 0
                       THEN
                           insert_threshold := insert_threshold - entity_cur_rec.sc ;
                       END IF;
                 END IF;
             END IF;

            IF row_count = 4
            THEN
                IF (entity_cur_rec.sc  - threshold) < 0
                THEN
                   insert_threshold := insert_threshold - entity_cur_rec.sc ;
                END IF;
            END IF;

        END LOOP;

        return insert_threshold;
END;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- MATCH RULE GENERATION FOR SPEC
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


-------------------------------------------------------------------------
-- gen_pkg_spec: A Private procedure that will generate the package spec
--               of the match rule
-------------------------------------------------------------------------


PROCEDURE gen_pkg_spec (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
BEGIN
    l('CREATE or REPLACE PACKAGE ' || p_pkg_name || ' AUTHID CURRENT_USER AS');
    l('PROCEDURE tca_join_entities(trap_explosion in varchar2, rows_in_chunk in number,inserted_duplicates out number);');
    HZ_IMP_DQM_STAGE.gen_pkg_spec(p_pkg_name, p_match_rule_id);
    l('');
    l('');
    l('PROCEDURE interface_tca_join_entities(p_batch_id in number,');
    l('          from_osr in varchar2, to_osr in varchar2, p_threshold in number, p_auto_merge_threshold in number);');
    l('');
    l('');
    l('PROCEDURE interface_join_entities(p_batch_id in number,');
    l('          from_osr in varchar2, to_osr in varchar2, p_threshold in number);');
    l('END ;');

END;


-------------------------------------------------------------------------
-- gen_footer:
-------------------------------------------------------------------------
PROCEDURE gen_footer
IS
BEGIN
    l('END;');
END;


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- MATCH RULE GENERATION FOR TCA JOIN
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


-------------------------------------------------------------------------
-- gen_header_tca :
-------------------------------------------------------------------------
PROCEDURE gen_header_tca (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
temp number;
BEGIN
    l('CREATE or REPLACE PACKAGE BODY ' || p_pkg_name || ' AS');
    HZ_IMP_DQM_STAGE.gen_pkg_body(p_pkg_name, p_match_rule_id);
    l('');
    l('');
    l('');
    l('');
    l('---------------------------------------------------------------');
    l('-------------------- TCA JOIN BEGINS --------------------------');
    l('---------------------------------------------------------------');
    l('PROCEDURE tca_join_entities(trap_explosion in varchar2, rows_in_chunk in number, inserted_duplicates out number)');
    l('IS');
    l('    x_ent_cur	HZ_DQM_DUP_ID_PKG.EntityCur;');
    temp := get_insert_threshold(p_match_rule_id);
    l('    x_insert_threshold number := ' || temp || ';');
    l('    l_party_limit NUMBER := 50000;');
    l('    l_detail_limit NUMBER := 100000;');
    l('BEGIN');
    l('FND_FILE.put_line(FND_FILE.log,''Start time of insert of Parties ''||to_char(sysdate,''hh24:mi:ss''));');
    l('insert into hz_dup_results(fid, tid, ord_fid, ord_tid, score)');
    l('select f, t, least(f,t), greatest(f,t), sum(score) score  from (');
END;


-------------------------------------------------------------------------
-- gen_footer_tca : A Private procedure that will generate the footer
--              for the package body of the match rule
-------------------------------------------------------------------------
PROCEDURE gen_footer_tca(p_pkg_name VARCHAR2)
IS
BEGIN
    l('');
    l('');
    l('---------- exception block ---------------');
    l('EXCEPTION');
    l('WHEN OTHERS THEN');
    l('         IF sqlcode=-1722');
    l('         THEN');
    l('             inserted_duplicates := -1;');
    l('         ELSE');
    l('             FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
    l('             FND_MESSAGE.SET_TOKEN(''PROC'',''' || p_pkg_name || '.tca_join_entities'');');
    l('             FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
    l('             FND_MSG_PUB.ADD;');
    l('             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
    l('         END IF;');
    l('END tca_join_entities;');
END;

-------------------------------------------------------------------------
-- gen_insert_template_tca :
-------------------------------------------------------------------------
PROCEDURE gen_insert_template_tca(
       p_table VARCHAR2,
       p_match_rule_id NUMBER,
       p_entity VARCHAR2,
       p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN;
no_primary_attr_rows number := 0 ;
row_count number := 0;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;
match_all_flag varchar2(1);

BEGIN


     -- aggregation should happen only for non party entities
     IF p_entity <> 'PARTY'
     THEN
        l('select f, t, max(score) score from (');
     END IF;

     l('select /*+ ORDERED */ s1.party_id f, s2.party_id t,');

     l('-------' || p_entity || ' ENTITY: SCORING SECTION ---------');

   SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

  IF has_scoring_attributes(p_match_rule_id, p_entity)
  THEN
        -- Generate the Secondary Attribute section of the query for the passed in entity
        FOR attrs in (
          SELECT score,s.attribute_id , secondary_attribute_id
          FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
          where a.attribute_id=s.attribute_id
          and s.match_rule_id=p_match_rule_id
          and a.entity_name = p_entity)
          LOOP
              outer_row_counter := outer_row_counter + 1;
              inner_row_counter := 0;

                    FOR trans in (
                      SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                      FROM hz_secondary_trans st, hz_trans_functions_vl f
                      where f.function_id=st.function_id
                      and st.secondary_attribute_id = attrs.secondary_attribute_id
                      order by transformation_weight desc)
                    LOOP
                                inner_row_counter := inner_row_counter + 1;
                                l('decode(instrb(s2.'||trans.staged_attribute_column
                                    || ',s1.'||trans.staged_attribute_column||
                                   '),1,'|| trans.score||',');

                    END LOOP;

                    l('0');

                     -- Need to have as many right parentheses as inner_row_counter
                    FOR I IN 1 .. inner_row_counter
                    LOOP
                      l(')');
                    END LOOP;

                    IF outer_row_counter < outer_row_count
                    THEN
                        l(' +  ');
                    END IF;
         END LOOP;
   ELSE
        l('0 ');
   END IF;

   l(' score ');
   l('from hz_dup_worker_chunk_gt p, '||p_table||' s1, '||p_table||' s2');
   l('where p.party_id = s1.party_id and s1.party_id<>s2.party_id ');

   --Adding the condition of 'Status = A'  below, to fix bug 4669400.
   --This will make sure that the Merged and Inactive Parties (with status as 'M' and 'I')
   --will not be considered for duplicate idenfication.

   -- Status flag should be checked only for Party entity
   IF p_entity = 'PARTY' THEN
     l('and nvl(s1.status,''A'') = ''A'' and nvl(s2.status,''A'') = ''A'' ');
   END IF;

   -- To make sure that the detail records (party sites, contacts and contact points) are
   -- are considered for duplicate indentification, only if the parent party is Active.
   IF p_entity <> 'PARTY' THEN
     l('and exists(SELECT 1 from hz_staged_parties q where q.party_id = s2.party_id and nvl(q.status,''A'') = ''A'') ');
   END IF;

   -- SET CHUNK EXPLOSION LIMIT
   IF p_entity = 'PARTY'
   THEN
        l('and 1=decode(trap_explosion,''N'',1,decode(rownum,l_party_limit,to_number(''A''),1))');
   ELSE
        l('and 1=decode(trap_explosion,''N'',1,decode(rownum,l_detail_limit,to_number(''A''),1))');
   END IF;

   l('and (');

   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('-------' || p_entity || ' ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES---------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l('or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');
   END LOOP;
   l(')');

   -- NOW, TAKE CARE OF ENTITY FILTER ATTRIBUTES FOR ALL ENTITIES
   -- OTHER THAN PARTIES
   IF p_entity <> 'PARTY' AND has_entity_filter_attributes(p_match_rule_id, p_entity)= 'Y'
   THEN
               FIRST1 := TRUE;
               FOR attrs in (
                SELECT primary_attribute_id
                FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
                where  p.match_rule_id=p_match_rule_id
                and p.attribute_id=a.attribute_id
                and a.entity_name = p_entity
                and nvl(p.filter_flag,'N') = 'Y' )
               LOOP
                          IF FIRST1
                          THEN
                               FIRST1 := FALSE;
                               l('-------' || p_entity || ' ENTITY: ACQUISITION ON FILTER ATTRIBUTES---------');
                          END IF;

                           -- between attributes
                           l('and');

                           FIRST := TRUE;
                           FOR trans in ( SELECT staged_attribute_column
                              FROM hz_primary_trans pt, hz_trans_functions_vl f
                              where f.function_id = pt.function_id
                              and pt.primary_attribute_id = attrs.primary_attribute_id
                           )
                           LOOP
                                IF FIRST
                                THEN
                                    l('-- do an or between all the transformations of an attribute -- ');
                                    l('(');
                                    l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                                    FIRST := FALSE;
                                ELSE
                                     l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                                END IF;

                           END LOOP;
                        l(')');
               END LOOP;
   END IF;

   -- complete aggregation for non party entities
   IF p_entity <> 'PARTY'
   THEN
        l(' ) group by f, t ');
   END IF;



END;


-------------------------------------------------------------------------
-- gen_insert_footer_tca : A Private procedure that will generate the footer
--              for the union part of the package body of the match rule
-------------------------------------------------------------------------
PROCEDURE gen_insert_footer_tca(p_match_rule_id number)
IS
FIRST1 boolean;
FIRST boolean;
BEGIN

   l(' )');

   -- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES
   IF has_party_filter_attributes(p_match_rule_id)= 'Y'
   THEN
                   l('------- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES---------');
                   l('where EXISTS (');
                   l('SELECT 1 FROM HZ_STAGED_PARTIES p1, HZ_STAGED_PARTIES p2');
                   l('WHERE p1.party_id = f and p2.party_id = t');
                   FIRST1 := TRUE;
                   FOR attrs in (
                    SELECT primary_attribute_id
                    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
                    where  p.match_rule_id=p_match_rule_id
                    and p.attribute_id=a.attribute_id
                    and a.entity_name = 'PARTY'
                    and nvl(p.filter_flag,'N') = 'Y' )
                   LOOP
                              IF FIRST1
                              THEN
                                   FIRST1 := FALSE;
                              END IF;

                               -- between attributes
                               l('and');

                               FIRST := TRUE;
                               FOR trans in ( SELECT staged_attribute_column
                                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                                  where f.function_id = pt.function_id
                                  and pt.primary_attribute_id = attrs.primary_attribute_id
                               )
                               LOOP
                                    IF FIRST
                                    THEN
                                        l('-- do an or between all the transformations of an attribute -- ');
                                        l('(');
                                        l('((p1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         'p2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     'p2.'|| trans.staged_attribute_column || ' = p1.'||
                                                     trans.staged_attribute_column || ')');
                                        FIRST := FALSE;
                                    ELSE
                                         l('or ((p1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         'p2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     'p2.'|| trans.staged_attribute_column || ' = p1.'||
                                                     trans.staged_attribute_column || ')');
                                    END IF;

                               END LOOP;
                            l(')');
                   END LOOP;
        l(')');
    END IF;

    l('group by f, t ');

    -- having clause should exist only if x_insert_threshold
    -- is positive
    IF get_insert_threshold(p_match_rule_id) > 0
    THEN
        l('having sum(score) >= x_insert_threshold');
    END IF;

    l(';');
    l('inserted_duplicates := (SQL%ROWCOUNT);');
    l('FND_FILE.put_line(FND_FILE.log,''Number of parties inserted ''||SQL%ROWCOUNT);');
    l('FND_FILE.put_line(FND_FILE.log,''End time of insert ''||to_char(sysdate,''hh24:mi:ss''));');
    l('FND_CONCURRENT.AF_Commit;');

END;


-------------------------------------------------------------------------
-- gen_update_template_tca : A Private procedure that will generate the header
--              for the package body of the match rule
-------------------------------------------------------------------------
PROCEDURE gen_update_template_tca (
        p_table VARCHAR2,
        p_match_rule_id NUMBER,
        p_entity VARCHAR2,
        p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN

   l('');
   l('');
   l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Beginning update of Parties on the basis of ' || p_entity || ''''|| ');');
   l('FND_FILE.put_line(FND_FILE.log,''Start time of update ''||to_char(sysdate,''hh24:mi:ss''));');
   l('open x_ent_cur for');

   -- aggregation should happen only for non party entities
   IF p_entity <> 'PARTY'
   THEN
        l('select f, t, max(score) score from (');
   END IF;

   l(' select /*+ ORDERED */ s1.party_id f, s2.party_id t,');


   SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

 IF has_scoring_attributes(p_match_rule_id, p_entity)
 THEN

          -- Generate the Secondary Attribute section of the query for the passed in entity
          FOR attrs in (
            SELECT score,s.attribute_id , secondary_attribute_id
            FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
            where a.attribute_id=s.attribute_id
            and s.match_rule_id=p_match_rule_id
            and a.entity_name = p_entity)
            LOOP
                outer_row_counter := outer_row_counter + 1;
                inner_row_counter := 0;

                      FOR trans in (
                        SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                        FROM hz_secondary_trans st, hz_trans_functions_vl f
                        where f.function_id=st.function_id
                        and st.secondary_attribute_id = attrs.secondary_attribute_id
                        order by transformation_weight desc)
                      LOOP
                                  inner_row_counter := inner_row_counter + 1;
                                  l('decode(instrb(s2.'||trans.staged_attribute_column
                                      || ',s1.'||trans.staged_attribute_column||
                                     '),1,'|| trans.score||',');

                      END LOOP;

                      l('0');

                       -- Need to have as many right parentheses as inner_row_counter
                      FOR I IN 1 .. inner_row_counter
                      LOOP
                        l(')');
                      END LOOP;

                      IF outer_row_counter < outer_row_count
                      THEN
                          l('+');
                      END IF;
           END LOOP;
   ELSE
       l('0 ');
   END IF;

   l('score');
   l('from hz_dup_worker_chunk_gt p, hz_dup_results h1, '||p_table||' s1, '||p_table||' s2');
   l('where p.party_id=h1.fid and s1.party_id = h1.fid and s2.party_id = h1.tid');
   l('and ( ');

   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ NON FILTER ATTRIBUTES SECTION ------------------------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW TAKE CARE OF FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'Y' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ FILTER ATTRIBUTES SECTION ------------------------');
                END IF;

                -- between attributes
                l('and ');


               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                        FIRST := FALSE;
                    ELSE
                        l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                    END IF;

               END LOOP;
               l(')');
   END LOOP;


   -- aggregation should happen only for non party entities
   IF p_entity <> 'PARTY'
   THEN
        l(') group by f,t ;');
   ELSE
        l(';');
   END IF;

   l('HZ_DQM_DUP_ID_PKG.update_hz_dup_results(x_ent_cur);');
   l('close x_ent_cur;');
   l('FND_FILE.put_line(FND_FILE.log,''Number of parties updated ''||SQL%ROWCOUNT);');
   l('FND_FILE.put_line(FND_FILE.log,''End time to update ''||to_char(sysdate,''hh24:mi:ss''));');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Ending update of Parties on the basis of ' || p_entity || ''''|| ');');
   l('FND_CONCURRENT.AF_Commit;');
END;




PROCEDURE gen_pkg_body_tca_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER,
        p_att_flag            IN      VARCHAR2
)
IS

CURSOR entity_cur IS
                select entity_name, entity_table_name, sc, att_flag
                from
                        (select  entity_name, decode(entity_name,
                                       'PARTY','HZ_STAGED_PARTIES',
                                       'PARTY_SITES', 'HZ_STAGED_PARTY_SITES',
                                       'CONTACTS','HZ_STAGED_CONTACTS',
                                       'CONTACT_POINTS', 'HZ_STAGED_CONTACT_POINTS') entity_table_name,
                                       sum(score) sc, 'S' att_flag
                        from hz_trans_attributes_vl a, hz_match_rule_secondary s
                        where s.match_rule_id = p_match_rule_id
                        and s.attribute_id = a.attribute_id
                        group by entity_name
                        union all
                        select  entity_name, decode(entity_name,
                                       'PARTY','HZ_STAGED_PARTIES',
                                       'PARTY_SITES', 'HZ_STAGED_PARTY_SITES',
                                       'CONTACTS','HZ_STAGED_CONTACTS',
                                       'CONTACT_POINTS', 'HZ_STAGED_CONTACT_POINTS') entity_table_name,
                                       0 sc, 'P' att_flag
                        from hz_trans_attributes_vl a, hz_match_rule_primary p
                        where p.match_rule_id = p_match_rule_id
                        and p.attribute_id = a.attribute_id
                        group by entity_name
                )
                where att_flag = p_att_flag
                order by sc desc ;
srt score_rec_type;
threshold number;
row_count number;
no_of_entities number;
template varchar2(30);
match_all_flag varchar2(1);
insert_stmt_is_open boolean;
BEGIN

    -- dbms_output.put_line('Attribute flag is ' || p_att_flag );
    -- Get the threshold and match_all_flag
    select match_score, match_all_flag into threshold, match_all_flag
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;

   -- Get the different aggregates that would help in determining the template
   -- that need to be used -- UNION/UPDATE for the corresponding entity.

       -- If attribute flag is 'P', make the threshold 0
       -- This signifies that the match rule has no scoring attributes
   IF p_att_flag = 'P'
   THEN
       threshold := 0;
       srt.sum_score := 0;
       srt.min_score := 0;
       srt.max_score := 0;
   ELSE
       srt := get_misc_scores(p_match_rule_id);
   END IF;


    -- Initialize the number of entities
    no_of_entities := 0;


    -- Get the number of entities

    FOR c0 in entity_cur
    LOOP
        no_of_entities := no_of_entities + 1;
    END LOOP;


    -- Before generating the code for the given match rule, we look at the
    -- match_all_flag to determine, the structure of the code that needs
    -- to go into the generated match rule package.
    -- The flag is always assumed to be 'N' by default ie., a match on ANY of the
    -- entities, would be given consideration.
    -- If flag = 'Y', then we need to make sure that every query after the first
    -- one is an update. We make this happen by manually setting the threshold.
    IF match_all_flag = 'Y'
    THEN
        threshold := srt.sum_score;
    END IF;


    -- Generate the Header
    gen_header_tca(p_pkg_name, p_match_rule_id);

    -- Open the entity cursor, determine the templates (INSERT/UPDATE) for each
    -- and call the appropriate function to add lines to the generated package
    -- for the corresponding entity
    row_count := 0;
    insert_stmt_is_open := false;

    -- some basic observations that would help in this logic
    -- 1. There will always be atleast one insert statement
    -- 2. all insert templates would come under the insert statement
    -- 3. all update templates are modular and do not need any special treatment for opening and closing.
    -- 4. all update templates would be together
    -- 5. when generating an update template, we need to make sure that the insert statement is closed.
    -- 6. in the event that we never have an update template, we close the insert statement, outside the loop.
    FOR entity_cur_rec in entity_cur
    LOOP
        row_count := row_count + 1;

            -- First row, is always an insert, unless the match rule returns nothing due
            -- to an erroneous combination of the threshold/match rule configuration.
            -- If that happnes we , get the hell out of here.
            IF row_count = 1
            THEN
                -- pass the first entity forcefully
                IF (srt.sum_score - threshold) >= 0
                THEN
                    -- dbms_output.put_line('about insert for first entity');
                    gen_insert_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                               match_all_flag);
                    insert_stmt_is_open := true;
                ELSE
                    -- need to handle this by reporting an error and getting the hell out of here.
                     -- dbms_output.put_line('cannot even insert first entity');
                     -- dbms_output.put_line('sum score is ' || srt.sum_score );
                     -- dbms_output.put_line('threshold' || threshold );
                     -- dbms_output.put_line('sum - threshold is ' || srt.sum_score - threshold );
                    null;
                    return ;
                END IF;
             END IF;

            IF row_count = 2
            THEN

                IF (srt.sum_score - srt.max_score - threshold) >= 0
                THEN
                    l('union all');
                    gen_insert_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                               match_all_flag);
                ELSE
                    IF insert_stmt_is_open
                    THEN
                        gen_insert_footer_tca(p_match_rule_id);
                        insert_stmt_is_open := false;
                    END IF;
                    gen_update_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                               match_all_flag);
                END IF;
             END IF;

            IF row_count = 3
            THEN
                 IF no_of_entities = 3
                 THEN
                        IF (entity_cur_rec.sc  - threshold) >= 0
                        THEN
                            l('union all');
                            gen_insert_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                                       match_all_flag);
                        ELSE
                            IF insert_stmt_is_open
                            THEN
                                gen_insert_footer_tca(p_match_rule_id);
                                insert_stmt_is_open := false;
                            END IF;
                            gen_update_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                                       match_all_flag);
                        END IF;

                 ELSE
                       IF ( entity_cur_rec.sc + srt.min_score - threshold) >= 0
                       THEN
                            l('union all');
                            gen_insert_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                                       match_all_flag);
                       ELSE
                            IF insert_stmt_is_open
                            THEN
                                gen_insert_footer_tca(p_match_rule_id);
                                insert_stmt_is_open := false;
                            END IF;
                            gen_update_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                                       match_all_flag);
                       END IF;
                 END IF;
             END IF;

            IF row_count = 4
            THEN
                IF (entity_cur_rec.sc  - threshold) >= 0
                THEN
                    l('union all');
                    gen_insert_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                               match_all_flag);
                ELSE
                    IF insert_stmt_is_open
                    THEN
                        gen_insert_footer_tca(p_match_rule_id);
                        insert_stmt_is_open := false;
                    END IF;
                    gen_update_template_tca(entity_cur_rec.entity_table_name, p_match_rule_id, entity_cur_rec.entity_name,
                                                                                               match_all_flag);
                END IF;
            END IF;

        END LOOP;

        -- Just to make sure that the insert statement is not open, after all the entity queries
        -- have been generated
        IF insert_stmt_is_open
        THEN
            gen_insert_footer_tca(p_match_rule_id);
            insert_stmt_is_open := false;
        END IF;

        -- generate the footer for the package
        gen_footer_tca(p_pkg_name) ;

END;

PROCEDURE gen_pkg_body_tca_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
BEGIN
    IF has_scoring_attributes(p_match_rule_id)
    THEN
        gen_pkg_body_tca_join(p_pkg_name, p_match_rule_id, 'S');
    ELSE
        gen_pkg_body_tca_join(p_pkg_name, p_match_rule_id, 'P');
    END IF;
END ;

-----------------------------------------------------------------------------------------------------------
-- MATCH RULE GENERATION FOR THE INTERFACE TCA JOIN
-----------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------
-- gen_header_int_tca :
-------------------------------------------------------------------------
PROCEDURE gen_header_int_tca (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
temp number;
BEGIN
    l('');
    l('');
    l('');
    l('');
    l('---------------------------------------------------------------');
    l('-------------------- INTERFACE TCA JOIN BEGINS --------------------------');
    l('---------------------------------------------------------------');
    l('PROCEDURE interface_tca_join_entities( p_batch_id in number, from_osr in varchar2, to_osr in varchar2,');
    l('                                  p_threshold in number, p_auto_merge_threshold in number)');
    l('IS');
    l('x_ent_cur	HZ_DQM_DUP_ID_PKG.EntityCur;');
    temp := get_insert_threshold(p_match_rule_id);
    l('x_insert_threshold number := ' || temp || ';');
    l('BEGIN');
    l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
    l('FND_FILE.put_line(FND_FILE.log,''WU: ''||from_osr||'' to ''||to_osr);');
    l('FND_FILE.put_line(FND_FILE.log,''Start time of insert of Parties ''||to_char(sysdate,''hh24:mi:ss''));');
    l('insert into hz_imp_dup_parties(party_id,dup_party_id, score, party_osr, party_os, batch_id, auto_merge_flag');
    l(',created_by,creation_date,last_update_login,last_update_date,last_updated_by)');
    l('select f, t, sum(score) sc, party_osr, party_os, p_batch_id, ''N'' ');
    l(',hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login');
    l(',hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by');
    l('from (');
END;


-------------------------------------------------------------------------
-- gen_footer_int_tca:
-------------------------------------------------------------------------
PROCEDURE gen_footer_int_tca(p_pkg_name VARCHAR2)
IS
BEGIN
    l('');
    l('---------- exception block ---------------');
    l('EXCEPTION');
    l('WHEN OTHERS THEN');
    l('         FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
    l('         FND_MESSAGE.SET_TOKEN(''PROC'',''' || p_pkg_name || '.interface_tca_join_entities'');');
    l('         FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
    l('         FND_MSG_PUB.ADD;');
    l('         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
    l('END interface_tca_join_entities;');
END;





-------------------------------------------------------------------------
-- gen_insert_template_int_tca :
-------------------------------------------------------------------------
PROCEDURE gen_insert_template_int_tca(
       s_table VARCHAR2,
       p_table VARCHAR2,
       p_match_rule_id NUMBER,
       p_entity VARCHAR2,
       p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN
     -- finding the max, applies only to detail information viz., to non-party entities.
     IF p_entity <> 'PARTY'
     THEN
        l('select f, t, max(score) score, party_osr, party_os from (');
     END IF;

     l('select /*+ USE_CONCAT */ s1.party_id f, s2.party_id t,');

   l('-------' || p_entity || ' ENTITY: SCORING SECTION ---------');

   SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

  IF has_scoring_attributes(p_match_rule_id, p_entity)
  THEN
          -- Generate the Secondary Attribute section of the query for the passed in entity
          FOR attrs in (
            SELECT score,s.attribute_id , secondary_attribute_id
            FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
            where a.attribute_id=s.attribute_id
            and s.match_rule_id=p_match_rule_id
            and a.entity_name = p_entity)
            LOOP
                outer_row_counter := outer_row_counter + 1;
                inner_row_counter := 0;

                      FOR trans in (
                        SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                        FROM hz_secondary_trans st, hz_trans_functions_vl f
                        where f.function_id=st.function_id
                        and st.secondary_attribute_id = attrs.secondary_attribute_id
                        order by transformation_weight desc)
                      LOOP
                                  inner_row_counter := inner_row_counter + 1;
                                  l('decode(instrb(s2.'||trans.staged_attribute_column
                                      || ',s1.'||trans.staged_attribute_column||
                                     '),1,'|| trans.score||',');

                      END LOOP;

                      l('0');

                       -- Need to have as many right parentheses as inner_row_counter
                      FOR I IN 1 .. inner_row_counter
                      LOOP
                        l(')');
                      END LOOP;

                      IF outer_row_counter < outer_row_count
                      THEN
                          l('+');
                      END IF;
           END LOOP;
   ELSE
        l('0 ');
   END IF;


   l('score , s1.party_osr party_osr, s1.party_os party_os');


   -- if the passed in entity is a detail level entity, then we need to make sure
   -- that the party level filters ( if any), participate in the join
   -- for the detail
   IF p_entity <> 'PARTY' AND has_party_filter_attributes(p_match_rule_id)= 'Y'
   THEN
        l('from '||s_table||' s1, '||p_table||' s2');
   ELSE
        l('from '||s_table||' s1, '||p_table||' s2 ');
   END IF;

   -- for the detail

   IF p_entity <> 'PARTY'
   THEN
        l('where s1.party_id is not null and s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.new_party_flag = ''I''');
   ELSE
        l('where s1.party_id is not null and s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr');
   END IF;

   --Adding the condition of 'Status = A' below, to fix bug 4669400.
   --This will make sure that the Merged and Inactive Parties (with status as 'M' and 'I')
   --will not be considered for duplicate idenfication.

   -- Status flag should be checked only for Party entity
   IF p_entity = 'PARTY' THEN
     l('and nvl(s2.status,''A'') = ''A'' ');
   END IF;

   -- To make sure that the detail records (party sites, contacts and contact points) are
   -- are considered for duplicate indentification, only if the parent party is Active.
   IF p_entity <> 'PARTY' THEN
     l('and exists(SELECT 1 from hz_staged_parties q where q.party_id = s2.party_id and nvl(q.status,''A'') = ''A'') ');
   END IF;


   l('and ( ');


   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('-------' || p_entity || ' ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES ---------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW, TAKE CARE OF ENTITY FILTER ATTRIBUTES FOR ALL ENTITIES
   -- OTHER THAN PARTIES
   IF p_entity <> 'PARTY' AND has_entity_filter_attributes(p_match_rule_id,p_entity)= 'Y'
   THEN
               -- NOW TAKE CARE OF FILTER ATTRIBUTES
               FIRST1 := TRUE;
               FOR attrs in (
                SELECT primary_attribute_id
                FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
                where  p.match_rule_id=p_match_rule_id
                and p.attribute_id=a.attribute_id
                and a.entity_name = p_entity
                and nvl(p.filter_flag,'N') = 'Y' )
               LOOP
                            -- between attributes
                            IF FIRST1
                            THEN
                               FIRST1 := FALSE;
                              l('-------' || p_entity || ' ENTITY: ACQUISITION ON FILTER ATTRIBUTES ---------');
                            END IF;

                           -- between attributes
                           l('and ');

                           FIRST := TRUE;
                           FOR trans in ( SELECT staged_attribute_column
                              FROM hz_primary_trans pt, hz_trans_functions_vl f
                              where f.function_id = pt.function_id
                              and pt.primary_attribute_id = attrs.primary_attribute_id
                           )
                           LOOP
                                IF FIRST
                                THEN
                                    l('-- do an or between all the transformations of an attribute -- ');
                                    l('(');
                                    l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ' || '' '' )' );
                                    FIRST := FALSE;
                                ELSE
                                    l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ' || '' '' )' );
                                END IF;

                           END LOOP;
                           l(')');
               END LOOP;
   END IF;

   -- complete the insert statement for non-party entities
   IF p_entity <> 'PARTY'
   THEN
        l(')');
        l('group by f, t, party_osr, party_os');
   END IF;

END;

-------------------------------------------------------------------------
-- gen_dl_insert_template_int_tca :
-------------------------------------------------------------------------
PROCEDURE gen_dl_insert_template_int_tca(
       s_table VARCHAR2,
       p_table VARCHAR2,
       p_match_rule_id NUMBER,
       p_entity VARCHAR2,
       p_entity_id_name VARCHAR2,
       p_entity_osr_name VARCHAR2,
       p_entity_os_name VARCHAR2,
       p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN ;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN
   l('');
   l('-------------' || p_entity || ' LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------');
   l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Beginning insert  of ' || p_entity || ''''|| ');');
   l('FND_FILE.put_line(FND_FILE.log,''Start time of insert ''||to_char(sysdate,''hh24:mi:ss''));');

   -- BUG FIX FOR 4750317, CHANGED ORDER OF INSERTS
   l('insert into hz_imp_dup_details(party_id, score, party_osr, party_os, batch_id, entity, record_id, record_osr, record_os, dup_record_id');
   l(',created_by,creation_date,last_update_login,last_update_date,last_updated_by)');
   l('select /*+ USE_CONCAT */ s1.party_id f,');

   SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

 IF has_scoring_attributes(p_match_rule_id, p_entity)
 THEN
            -- Generate the Secondary Attribute section of the query for the passed in entity
            FOR attrs in (
              SELECT score,s.attribute_id , secondary_attribute_id
              FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
              where a.attribute_id=s.attribute_id
              and s.match_rule_id=p_match_rule_id
              and a.entity_name = p_entity)
              LOOP
                  outer_row_counter := outer_row_counter + 1;
                  inner_row_counter := 0;

                        FOR trans in (
                          SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                          FROM hz_secondary_trans st, hz_trans_functions_vl f
                          where f.function_id=st.function_id
                          and st.secondary_attribute_id = attrs.secondary_attribute_id
                          order by transformation_weight desc)
                        LOOP
                                    inner_row_counter := inner_row_counter + 1;
                                    l('decode(instrb(s2.'||trans.staged_attribute_column
                                        || ',s1.'||trans.staged_attribute_column||
                                       '),1,'|| trans.score||',');

                        END LOOP;

                        l('0');

                         -- Need to have as many right parentheses as inner_row_counter
                        FOR I IN 1 .. inner_row_counter
                        LOOP
                          l(')');
                        END LOOP;

                        IF outer_row_counter < outer_row_count
                        THEN
                            l('+');
                        END IF;
             END LOOP;
   ELSE
        l('0 ');
   END IF;

   l('score , s1.party_osr, s1.party_os, p_batch_id,' || ''''|| p_entity ||'''' ||', s1.' || p_entity_id_name || ', s1.' || p_entity_osr_name || ', s1.' || p_entity_os_name || ',');
   l('                                                                      s2.' || p_entity_id_name );
   l(',hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login');
   l(',hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by');
   l('from '||s_table||' s1, '||p_table||' s2 ');
   l('where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.new_party_flag = ''U''');
   l('and s1.party_id = s2.party_id');
   l('and ( ');

   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ NON FILTER ATTRIBUTES SECTION ------------------------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW TAKE CARE OF FILTER ATTRIBUTES
   FIRST1 := TRUE;
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'Y'
    and HZ_IMP_DQM_STAGE.EXIST_COL(a.attribute_name, a.entity_name ) = 'Y'
    )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ FILTER ATTRIBUTES SECTION ------------------------');
                END IF;

               l('and ');

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ' || '' '' )' );
                        FIRST := FALSE;
                     ELSE
                        l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ' || '' '' )' );
                    END IF;

               END LOOP;
               l(')');
   END LOOP;

-- IF THE ENTITY IS NOT A PARTY THEN WE NEED TO MAKE SURE THAT ALL PARTY LEVEL
-- ACQUISTION ATTRIBUTES (IF ANY), THAT SERVE AS FILTERS ARE MATCHED.


l(';');
l('');
l('');
l('--------UPDATE DQM ACTION FLAG IN ' || p_entity ||' INTERFACE/STAGING TABLES --------------');
l('open x_ent_cur for');
l('select distinct a.record_osr, a.record_os');
l('from hz_imp_dup_details a');
l('where a.batch_id = p_batch_id');
l('and a.party_osr between from_osr and to_osr and a.entity =''' || p_entity || ''';') ;
l('HZ_DQM_DUP_ID_PKG.update_detail_dqm_action_flag(''' ||p_entity ||''',p_batch_id, x_ent_cur);');
l('-------------' || p_entity || ' LEVEL DUPLICATE IDENTIFICATION ENDS ------------------------');
l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Ending insert of ' || p_entity || ''''|| ');');
l('FND_FILE.put_line(FND_FILE.log,''Number of records inserted ''||SQL%ROWCOUNT);');
l('FND_FILE.put_line(FND_FILE.log,''End time to insert ''||to_char(sysdate,''hh24:mi:ss''));');
l('');
l('');

END;

-------------------------------------------------------------------------
-- gen_insert_footer_int_tca :
-------------------------------------------------------------------------
PROCEDURE gen_insert_footer_int_tca(p_match_rule_id number)
IS
FIRST1 boolean;
FIRST boolean;
BEGIN
   l(')');

   -- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES
   IF has_party_filter_attributes(p_match_rule_id)= 'Y'
   THEN
                   l('------- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES---------');
                   l('where EXISTS (');
                   l('SELECT 1 FROM HZ_SRCH_PARTIES p1, HZ_STAGED_PARTIES p2');
                   l('WHERE p1.batch_id = p_batch_id and p1.party_osr = party_osr and p1.party_os = party_os');
                   l('and p2.party_id = t');
                   FIRST1 := TRUE;
                   FOR attrs in (
                    SELECT primary_attribute_id
                    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
                    where  p.match_rule_id=p_match_rule_id
                    and p.attribute_id=a.attribute_id
                    and a.entity_name = 'PARTY'
                    and nvl(p.filter_flag,'N') = 'Y'
                    and HZ_IMP_DQM_STAGE.EXIST_COL(a.attribute_name, a.entity_name ) = 'Y'
                    )
                   LOOP
                              IF FIRST1
                              THEN
                                   FIRST1 := FALSE;
                              END IF;

                               -- between attributes
                               l('and');

                               FIRST := TRUE;
                               FOR trans in ( SELECT staged_attribute_column
                                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                                  where f.function_id = pt.function_id
                                  and pt.primary_attribute_id = attrs.primary_attribute_id
                               )
                               LOOP
                                     IF FIRST
                                     THEN
                                        l('-- do an or between all the transformations of an attribute -- ');
                                        l('(');
                                        l('((p1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         'p2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     'p2.'|| trans.staged_attribute_column || ' = p1.'||
                                                     trans.staged_attribute_column || ' || '' '' )');
                                        FIRST := FALSE;
                                     ELSE
                                        l('or ((p1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         'p2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     'p2.'|| trans.staged_attribute_column || ' = p1.'||
                                                     trans.staged_attribute_column || ' || '' '' )');
                                     END IF;

                               END LOOP;
                            l(')');
                   END LOOP;
          l(')');
    END IF;

    l('group by f, t, party_osr, party_os');

    -- having clause should exist only if x_insert_threshold
    -- is positive
    IF get_insert_threshold(p_match_rule_id) > 0
    THEN
        l('having sum(score) >= x_insert_threshold');
    END IF;

    l(';');
    l('FND_FILE.put_line(FND_FILE.log,''Number of parties inserted ''||SQL%ROWCOUNT);');
    l('FND_FILE.put_line(FND_FILE.log,''End time of insert ''||to_char(sysdate,''hh24:mi:ss''));');
END;


-------------------------------------------------------------------------
-- gen_update_template_int_tca :
-------------------------------------------------------------------------
PROCEDURE gen_update_template_int_tca (
        s_table VARCHAR2,
        p_table VARCHAR2,
        p_match_rule_id NUMBER,
        p_entity VARCHAR2,
        p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN

   l('');
   l('');
   l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Beginning update of Parties on the basis of ' || p_entity || ''''|| ');');
   l('FND_FILE.put_line(FND_FILE.log,''Start time of update ''||to_char(sysdate,''hh24:mi:ss''));');

   l('open x_ent_cur for');
   l('select f,t,max(score) from (');
   l(' select /*+ USE_CONCAT */ s1.party_id f, s2.party_id t,');

  -- Generate the Secondary Attribute section of the query for the passed in entity
    SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;


  IF has_scoring_attributes(p_match_rule_id, p_entity)
  THEN

          FOR attrs in (
            SELECT score,s.attribute_id , secondary_attribute_id
            FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
            where a.attribute_id=s.attribute_id
            and s.match_rule_id=p_match_rule_id
            and a.entity_name = p_entity)
            LOOP
                outer_row_counter := outer_row_counter + 1;
                inner_row_counter := 0;

                      FOR trans in (
                        SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                        FROM hz_secondary_trans st, hz_trans_functions_vl f
                        where f.function_id=st.function_id
                        and st.secondary_attribute_id = attrs.secondary_attribute_id
                        order by transformation_weight desc)
                      LOOP
                                  inner_row_counter := inner_row_counter + 1;
                                  l('decode(instrb(s2.'||trans.staged_attribute_column
                                      || ',s1.'||trans.staged_attribute_column||
                                     '),1,'|| trans.score||',');

                      END LOOP;

                      l('0');

                       -- Need to have as many right parentheses as inner_row_counter
                      FOR I IN 1 .. inner_row_counter
                      LOOP
                        l(')');
                      END LOOP;

                      IF outer_row_counter < outer_row_count
                      THEN
                          l('+');
                      END IF;
           END LOOP;
   ELSE
        l('0 ');
   END IF;

   l('score');
   l('from hz_imp_dup_parties h1, '||s_table||' s1, '||p_table||' s2');
   l('where h1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr');
   l('and s1.batch_id = h1.batch_id and s1.party_osr = h1.party_osr and s1.party_os = h1.party_os and s2.party_id = h1.dup_party_id');
   l('and ( ');
   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ NON FILTER ATTRIBUTES SECTION ------------------------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW TAKE CARE OF FILTER ATTRIBUTES
   FIRST1 := TRUE;
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'Y'
    and HZ_IMP_DQM_STAGE.EXIST_COL(a.attribute_name, a.entity_name ) = 'Y'
    )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ FILTER ATTRIBUTES SECTION ------------------------');
                END IF;

               l('and ');

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ' || '' '' )' );
                         FIRST := FALSE;
                    ELSE
                        l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ' || '' '' )' );
                    END IF;

               END LOOP;
               l(')');
   END LOOP;
   l(') group by f,t ;');
   l('HZ_DQM_DUP_ID_PKG.update_hz_imp_dup_parties(p_batch_id, x_ent_cur);');
   l('close x_ent_cur;');
   l('FND_FILE.put_line(FND_FILE.log,''Number of parties updated ''||SQL%ROWCOUNT);');
   l('FND_FILE.put_line(FND_FILE.log,''End time to update ''||to_char(sysdate,''hh24:mi:ss''));');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Ending update of Parties on the basis of ' || p_entity || ''''|| ');');
END;

PROCEDURE  gen_thr_check_int_tca
IS
BEGIN
    -- apply threshold to hz_imp_dup_parties
l('');
l('--------DELETE ON THRESHOLD AND REMOVE INDIRECT TRANSITIVITY ---------------------');
l('');
l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
l('FND_FILE.put_line(FND_FILE.log,''DELETE ON THRESHOLD AND INDIRECT TRANSITIVITY '');');
l('FND_FILE.put_line(FND_FILE.log,''Begin time to delete ''||to_char(sysdate,''hh24:mi:ss''));');
l('');
l('delete from hz_imp_dup_parties a');
l('where (a.party_osr >= from_osr and a.party_osr <= to_osr');
l('and a.batch_id = p_batch_id)');
l('and (');
l('a.score < p_threshold');
l('or');
l('-- delete the party id whose duplicate is a bigger number, when scores are same');
l('exists');
l('      (Select 1 from hz_imp_dup_parties b');
l('       where b.batch_id=p_batch_id and a.party_id=b.party_id and a.dup_party_id > b.dup_party_id and a.score = b.score)');
l('or');
l('-- delete the party id with least score, if scores are different');
l('exists');
l('      (Select 1 from hz_imp_dup_parties b');
l('       where b.batch_id=p_batch_id and a.party_id=b.party_id and a.score < b.score)');
l(');');
l('');
l('FND_FILE.put_line(FND_FILE.log,''Number of records deleted from hz_imp_dup_parties ''||SQL%ROWCOUNT);');
l('FND_FILE.put_line(FND_FILE.log,''End time to delete ''||to_char(sysdate,''hh24:mi:ss''));');

l('--------UPDATE AUTO MERGE FLAG --------------');
l('update hz_imp_dup_parties a');
l('set a.auto_merge_flag = ''Y''');
l('where a.score >= p_auto_merge_threshold');
l('and a.party_osr >= from_osr and a.party_osr <= to_osr');
l('and a.batch_id = p_batch_id ;');
l('--------UPDATE DQM ACTION FLAG IN INTERFACE/STAGING TABLES --------------');
l('');
l('open x_ent_cur for');
l('select a.party_osr, a.party_os, a.auto_merge_flag');
l('from hz_imp_dup_parties a');
l('where a.batch_id = p_batch_id');
l('and a.party_osr between from_osr and to_osr ;');
l('HZ_DQM_DUP_ID_PKG.update_party_dqm_action_flag(p_batch_id, x_ent_cur);');
l('----------------------PARTY LEVEL DUPLICATE IDENTIFICATION ENDS --------------------');
l('');
END ;
-------------------------------------------------------------------------
-- gen_pkg_body_int_tca_join : A Private procedure that will generate the package body
--               of the match rule
-------------------------------------------------------------------------


PROCEDURE gen_pkg_body_int_tca_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER,
        p_att_flag            IN      VARCHAR2
)
IS

CURSOR entity_cur IS

                 select entity_name, search_table_name, entity_table_name, entity_id_name, entity_osr_name,
                        entity_os_name, sc, att_flag
                 from
                                    ( select  entity_name, decode(entity_name,
                                                   'PARTY','HZ_SRCH_PARTIES',
                                                   'PARTY_SITES', 'HZ_SRCH_PSITES',
                                                   'CONTACTS','HZ_SRCH_CONTACTS',
                                                   'CONTACT_POINTS', 'HZ_SRCH_CPTS') search_table_name,
                                                    decode(entity_name,
                                                   'PARTY','HZ_STAGED_PARTIES',
                                                   'PARTY_SITES', 'HZ_STAGED_PARTY_SITES',
                                                   'CONTACTS','HZ_STAGED_CONTACTS',
                                                   'CONTACT_POINTS', 'HZ_STAGED_CONTACT_POINTS') entity_table_name,
                                                    decode(entity_name,
                                                   'PARTY','PARTY_ID',
                                                   'PARTY_SITES', 'PARTY_SITE_ID',
                                                   'CONTACTS','ORG_CONTACT_ID',
                                                   'CONTACT_POINTS', 'CONTACT_POINT_ID') entity_id_name,
                                                   decode(entity_name,
                                                   'PARTY','PARTY_OSR',
                                                   'PARTY_SITES', 'PARTY_SITE_OSR',
                                                   'CONTACTS','CONTACT_OSR',
                                                   'CONTACT_POINTS', 'CONTACT_PT_OSR') entity_osr_name,
                                                   decode(entity_name,
                                                   'PARTY','PARTY_OS',
                                                   'PARTY_SITES', 'PARTY_SITE_OS',
                                                   'CONTACTS','CONTACT_OS',
                                                   'CONTACT_POINTS', 'CONTACT_PT_OS') entity_os_name,
                                                   sum(score) sc, 'S' att_flag
                                    from hz_trans_attributes_vl a, hz_match_rule_secondary s
                                    where s.match_rule_id = p_match_rule_id
                                    and s.attribute_id = a.attribute_id
                                    group by entity_name
                                    union all
                                              select  entity_name, decode(entity_name,
                                             'PARTY','HZ_SRCH_PARTIES',
                                             'PARTY_SITES', 'HZ_SRCH_PSITES',
                                             'CONTACTS','HZ_SRCH_CONTACTS',
                                             'CONTACT_POINTS', 'HZ_SRCH_CPTS') search_table_name,
                                              decode(entity_name,
                                             'PARTY','HZ_STAGED_PARTIES',
                                             'PARTY_SITES', 'HZ_STAGED_PARTY_SITES',
                                             'CONTACTS','HZ_STAGED_CONTACTS',
                                             'CONTACT_POINTS', 'HZ_STAGED_CONTACT_POINTS') entity_table_name,
                                              decode(entity_name,
                                             'PARTY','PARTY_ID',
                                             'PARTY_SITES', 'PARTY_SITE_ID',
                                             'CONTACTS','ORG_CONTACT_ID',
                                             'CONTACT_POINTS', 'CONTACT_POINT_ID') entity_id_name,
                                             decode(entity_name,
                                             'PARTY','PARTY_OSR',
                                             'PARTY_SITES', 'PARTY_SITE_OSR',
                                             'CONTACTS','CONTACT_OSR',
                                             'CONTACT_POINTS', 'CONTACT_PT_OSR') entity_osr_name,
                                             decode(entity_name,
                                             'PARTY','PARTY_OS',
                                             'PARTY_SITES', 'PARTY_SITE_OS',
                                             'CONTACTS','CONTACT_OS',
                                             'CONTACT_POINTS', 'CONTACT_PT_OS') entity_os_name,
                                             0 sc, 'P' att_flag
                                  from hz_trans_attributes_vl a, hz_match_rule_primary p
                                  where p.match_rule_id = p_match_rule_id
                                  and p.attribute_id = a.attribute_id
                                  group by entity_name
                             ) where att_flag = p_att_flag
                                order by sc desc ;
srt score_rec_type;
threshold number;
match_all_flag varchar2(1);
row_count number;
no_of_entities number;
template varchar2(30);
insert_stmt_is_open boolean;
BEGIN

    -- Get the threshold and match_all_flag
    select match_score, match_all_flag into threshold, match_all_flag
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;

    -- Get the different aggregates that would help in determining the template
   -- that need to be used -- UNION/UPDATE for the corresponding entity.

       -- If attribute flag is 'P', make the threshold 0
       -- This signifies that the match rule has no scoring attributes
   IF p_att_flag = 'P'
   THEN
       threshold := 0;
       srt.sum_score := 0;
       srt.min_score := 0;
       srt.max_score := 0;
   ELSE
       srt := get_misc_scores(p_match_rule_id);
   END IF;


    -- Initialize the number of entities
    no_of_entities := 0;

    -- Get the number of entities
    FOR c0 in entity_cur
    LOOP
        no_of_entities := no_of_entities + 1;
    END LOOP;


    -- Before generating the code for the given match rule, we look at the
    -- match_all_flag to determine, the structure of the code that needs
    -- to go into the generated match rule package.
    -- The flag is always assumed to be 'N' by default ie., a match on ANY of the
    -- entities, would be given consideration.
    -- If flag = 'Y', then we need to make sure that every query after the first
    -- one is an update. We make this happen by manually setting the threshold.
    IF match_all_flag = 'Y'
    THEN
        threshold := srt.sum_score;
    END IF;

    -- Generate the Header
    gen_header_int_tca (p_pkg_name, p_match_rule_id);

    l('------------------ PARTY LEVEL DUPLICATE IDENTIFICATION BEGINS --------------------');

    -- Open the entity cursor, determine the templates (INSERT/UPDATE) for each
    -- and call the appropriate function to add lines to the generated package
    -- for the corresponding entity
    row_count := 0;
    insert_stmt_is_open := false;

    -- some basic observations that would help in this logic
    -- 1. There will always be atleast one insert statement
    -- 2. all insert templates would come under the insert statement
    -- 3. all update templates are modular and do not need any special treatment for opening and closing.
    -- 4. all update templates would be together
    -- 5. when gnerating an update template, we need to make sure that the insert statement is closed.
    -- 6. in the event that we never have an update template, we close the insert statement, outside the loop.
    FOR entity_cur_rec in entity_cur
    LOOP
        row_count := row_count + 1;



            -- First row, is always an insert, unless the match rule returns nothing due
            -- to an erroneous combination of the threshold/match rule configuration.
            -- If that happnes we , get the hell out of here.
            IF row_count = 1
            THEN
                -- pass the first entity forcefully
                IF (srt.sum_score - threshold) >= 0
                THEN
                    gen_insert_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                                         entity_cur_rec.entity_name, match_all_flag);
                    insert_stmt_is_open := true;
                ELSE
                    -- need to handle this by reporting an error and getting the hell out of here.
                    null;
                    return ;
                END IF;
             END IF;

            IF row_count = 2
            THEN

                IF (srt.sum_score - srt.max_score - threshold) >= 0
                THEN
                    l('union all');
                    gen_insert_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                                             entity_cur_rec.entity_name, match_all_flag);
                ELSE
                    IF insert_stmt_is_open
                    THEN
                        gen_insert_footer_int_tca(p_match_rule_id) ;
                        insert_stmt_is_open := false;
                    END IF;
                    gen_update_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                                     entity_cur_rec.entity_name, match_all_flag);
                END IF;
             END IF;

            IF row_count = 3
            THEN
                 IF no_of_entities = 3
                 THEN
                        IF (entity_cur_rec.sc  - threshold) >= 0
                        THEN
                            l('union all');
                            gen_insert_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                                        p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                        ELSE
                            IF insert_stmt_is_open
                            THEN
                                gen_insert_footer_int_tca(p_match_rule_id) ;
                                insert_stmt_is_open := false;
                            END IF;
                            gen_update_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                           entity_cur_rec.entity_name, match_all_flag);
                        END IF;

                 ELSE
                       IF ( entity_cur_rec.sc + srt.min_score - threshold) >= 0
                       THEN
                            l('union all');
                            gen_insert_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                              entity_cur_rec.entity_name, match_all_flag);
                       ELSE
                            IF insert_stmt_is_open
                            THEN
                                gen_insert_footer_int_tca(p_match_rule_id) ;
                                insert_stmt_is_open := false;
                            END IF;
                            gen_update_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                                    p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                       END IF;
                 END IF;
             END IF;

            IF row_count = 4
            THEN
                IF (entity_cur_rec.sc  - threshold) >= 0
                THEN
                    l('union all');
                    gen_insert_template_int_tca(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                              p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                ELSE
                    IF insert_stmt_is_open
                    THEN
                        gen_insert_footer_int_tca(p_match_rule_id);
                        insert_stmt_is_open := false;
                    END IF;
                    gen_update_template_int_tca(entity_cur_rec.search_table_name, entity_cur_rec.entity_table_name,
                                            p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                END IF;
            END IF;

        END LOOP;

        -- Just to make sure that the insert statement is not open, after all the entity queries
        -- have been generated
        IF insert_stmt_is_open
        THEN
            gen_insert_footer_int_tca(p_match_rule_id) ;
            insert_stmt_is_open := false;
        END IF;

        -- generate threshold check
        gen_thr_check_int_tca ;

        -- generate code for detail level duplicate identification
        FOR entity_cur_rec in entity_cur
        LOOP
            IF entity_cur_rec.entity_name <> 'PARTY'
            THEN
                gen_dl_insert_template_int_tca(entity_cur_rec.search_table_name,
                                               entity_cur_rec.entity_table_name,
                                               p_match_rule_id,
                                               entity_cur_rec.entity_name,
                                               entity_cur_rec.entity_id_name,
                                               entity_cur_rec.entity_osr_name,
                                               entity_cur_rec.entity_os_name,
                                               match_all_flag );
            END IF;

        END LOOP;
        -- generate the footer for the package
        gen_footer_int_tca(p_pkg_name) ;

END;

PROCEDURE gen_pkg_body_int_tca_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
BEGIN
    IF has_scoring_attributes(p_match_rule_id)
    THEN
        gen_pkg_body_int_tca_join(p_pkg_name, p_match_rule_id, 'S');
    ELSE
        gen_pkg_body_int_tca_join(p_pkg_name, p_match_rule_id, 'P');
    END IF;
END ;


------------------------------------------------------------------------
-- MATCH RULE GENERATION FOR INTERFACE JOIN
------------------------------------------------------------------------



-------------------------------------------------------------------------
-- gen_header_int :
-------------------------------------------------------------------------
PROCEDURE gen_header_int (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
temp number;
BEGIN
    l('');
    l('');
    l('');
    l('');
    l('---------------------------------------------------------------');
    l('-------------------- INTERFACE JOIN BEGINS --------------------------');
    l('---------------------------------------------------------------');
    l('PROCEDURE interface_join_entities(p_batch_id in number,');
    l('          from_osr in varchar2, to_osr in varchar2, p_threshold in number)');
    l('IS');
    l('x_ent_cur	HZ_DQM_DUP_ID_PKG.EntityCur;');
    temp := get_insert_threshold(p_match_rule_id);
    l('    x_insert_threshold number := ' || temp || ';');
    l('BEGIN');
    l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
    l('FND_FILE.put_line(FND_FILE.log,''WU: ''||from_osr||'' to ''||to_osr);');
    l('FND_FILE.put_line(FND_FILE.log,''Start time of insert of Parties ''||to_char(sysdate,''hh24:mi:ss''));');
    l('insert into hz_int_dup_results(batch_id, f_osr,t_osr,ord_f_osr,ord_t_osr,score,f_os, t_os)');
    l('select p_batch_id, f, t, least(f,t), greatest(f,t), sum(score) score, fos, tos from (');
END;

-------------------------------------------------------------------------
-- gen_insert_template_int :
-------------------------------------------------------------------------
PROCEDURE gen_insert_template_int(
       s_table VARCHAR2,
       p_table VARCHAR2,
       p_match_rule_id NUMBER,
       p_entity VARCHAR2,
       p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN
     -- finding the max, applies only to detail information viz., to non-party entities.
     IF p_entity <> 'PARTY'
     THEN
        l('select f, t, max(score) score, fos, tos from (');
     END IF;

     l('select /*+ USE_CONCAT */ s1.party_osr f, s2.party_osr t,');


   l('-------' || p_entity || ' ENTITY: SCORING SECTION ---------');

   SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

  IF has_scoring_attributes(p_match_rule_id, p_entity)
  THEN
        -- Generate the Secondary Attribute section of the query for the passed in entity
        FOR attrs in (
          SELECT score,s.attribute_id , secondary_attribute_id
          FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
          where a.attribute_id=s.attribute_id
          and s.match_rule_id=p_match_rule_id
          and a.entity_name = p_entity)
          LOOP
              outer_row_counter := outer_row_counter + 1;
              inner_row_counter := 0;

                    FOR trans in (
                      SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                      FROM hz_secondary_trans st, hz_trans_functions_vl f
                      where f.function_id=st.function_id
                      and st.secondary_attribute_id = attrs.secondary_attribute_id
                      order by transformation_weight desc)
                    LOOP
                                inner_row_counter := inner_row_counter + 1;
                                l('decode(instrb(s2.'||trans.staged_attribute_column
                                    || ',s1.'||trans.staged_attribute_column||
                                   '),1,'|| trans.score||',');
                    END LOOP;

                    l('0');

                     -- Need to have as many right parentheses as inner_row_counter
                    FOR I IN 1 .. inner_row_counter
                    LOOP
                      l(')');
                    END LOOP;

                    IF outer_row_counter < outer_row_count
                    THEN
                        l('+');
                    END IF;
         END LOOP;
   ELSE
        l('0 ');
   END IF;

   l('score, s1.party_os fos, s2.party_os tos');


   -- if the passed in entity is a detail level entity, then we need to make sure
   -- that the party level filters ( if any), participate in the join
   -- for the detail
   IF p_entity <> 'PARTY' AND has_party_filter_attributes(p_match_rule_id)= 'Y'
   THEN
        l('from '||s_table||' s1, '||s_table||' s2');
   ELSE
        l('from '||s_table||' s1, '||s_table||' s2 ');
   END IF;

   l('where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr and s1.party_osr <> s2.party_osr');
   l('and s2.batch_id = p_batch_id and not exists (select 1 from HZ_INT_DUP_RESULTS WHERE t_osr = s1.party_osr and batch_id = p_batch_id)');
   -- only for contact point types
   IF p_entity = 'CONTACT_POINTS'
   THEN
     l('and s1.contact_point_type = s2.contact_point_type');
   END IF;

   l('and (');

   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('-------' || p_entity || ' ENTITY: ACQUISITION ON NON-FILTER ATTRIBUTES ---------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW, TAKE CARE OF ENTITY FILTER ATTRIBUTES FOR ALL ENTITIES
   -- OTHER THAN PARTIES
   IF p_entity <> 'PARTY' AND has_entity_filter_attributes(p_match_rule_id, p_entity)= 'Y'
   THEN

                       FIRST1 := TRUE;
                       FOR attrs in (
                        SELECT primary_attribute_id
                        FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
                        where  p.match_rule_id=p_match_rule_id
                        and p.attribute_id=a.attribute_id
                        and a.entity_name = p_entity
                        and nvl(p.filter_flag,'N') = 'Y' )
                       LOOP
                                    -- between attributes
                                    IF FIRST1
                                    THEN
                                       FIRST1 := FALSE;
                                      l('-------' || p_entity || ' ENTITY: ACQUISITION ON FILTER ATTRIBUTES ---------');
                                    END IF;

                                   -- between attributes
                                   l('and ');

                                   FIRST := TRUE;
                                   FOR trans in ( SELECT staged_attribute_column
                                      FROM hz_primary_trans pt, hz_trans_functions_vl f
                                      where f.function_id = pt.function_id
                                      and pt.primary_attribute_id = attrs.primary_attribute_id
                                   )
                                   LOOP
                                        IF FIRST
                                        THEN
                                            l('-- do an or between all the transformations of an attribute -- ');
                                            l('(');
                                            l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                                            FIRST := FALSE;
                                        ELSE
                                              l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                                        END IF;

                                   END LOOP;
                                   l(')');
                       END LOOP;

   END IF;

   -- complete the insert statement for non-party entities
   IF p_entity <> 'PARTY'
   THEN
        l(')');
        l('group by f, t, fos, tos');
   END IF;

END;

-------------------------------------------------------------------------
-- gen_dl_insert_template_int :
-------------------------------------------------------------------------
PROCEDURE gen_dl_insert_template_int(
       s_table VARCHAR2,
       p_table VARCHAR2,
       p_match_rule_id NUMBER,
       p_entity VARCHAR2,
       p_entity_osr_name VARCHAR2,
       p_entity_os_name VARCHAR2,
       p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN ;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN

   l('-------------' || p_entity || ' LEVEL DUPLICATE IDENTIFICATION BEGINS ------------------------');
   l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Beginning insert  of ' || p_entity || ''''|| ');');
   l('FND_FILE.put_line(FND_FILE.log,''Start time of insert ''||to_char(sysdate,''hh24:mi:ss''));');
   l('insert into hz_imp_int_dedup_results(batch_id, winner_record_osr, winner_record_os,');
   l('dup_record_osr, dup_record_os, detail_party_osr, detail_party_os, entity, score,');
   l('dup_creation_date,dup_last_update_date');
   l(',created_by,creation_date,last_update_login,last_update_date,last_updated_by)');
   l('select /*+ USE_CONCAT */ p_batch_id, s1.' || p_entity_osr_name || ', s1.' || p_entity_os_name || ',');
   l('s2.' || p_entity_osr_name || ', s2.' || p_entity_os_name || ',');
   l('s1.party_osr, s2.party_os,' || '''' || p_entity || ''',');
   SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

 IF has_scoring_attributes(p_match_rule_id, p_entity)
 THEN
          -- Generate the Secondary Attribute section of the query for the passed in entity
          FOR attrs in (
            SELECT score,s.attribute_id , secondary_attribute_id
            FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
            where a.attribute_id=s.attribute_id
            and s.match_rule_id=p_match_rule_id
            and a.entity_name = p_entity)
            LOOP
                outer_row_counter := outer_row_counter + 1;
                inner_row_counter := 0;

                      FOR trans in (
                        SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                        FROM hz_secondary_trans st, hz_trans_functions_vl f
                        where f.function_id=st.function_id
                        and st.secondary_attribute_id = attrs.secondary_attribute_id
                        order by transformation_weight desc)
                      LOOP
                                  inner_row_counter := inner_row_counter + 1;
                                  l('decode(nvl(s1.'||trans.staged_attribute_column||
                                     ',''N1''),nvl(substrb(s2.'||trans.staged_attribute_column||
                                     ',1,length(s1.'||trans.staged_attribute_column||')),''N2''),'||trans.score||', ');

                      END LOOP;

                      l('0');

                       -- Need to have as many right parentheses as inner_row_counter
                      FOR I IN 1 .. inner_row_counter
                      LOOP
                        l(')');
                      END LOOP;

                      IF outer_row_counter < outer_row_count
                      THEN
                          l('+');
                      END IF;
           END LOOP;
   ELSE
        l('0 ');
   END IF;

   l('score ,hz_utility_v2pub.creation_date, hz_utility_v2pub.last_update_date');
   l(',hz_utility_v2pub.created_by,hz_utility_v2pub.creation_date,hz_utility_v2pub.last_update_login');
   l(',hz_utility_v2pub.last_update_date,hz_utility_v2pub.last_updated_by');
   l('from '||s_table||' s1, '||s_table||' s2 ');
   l('where s1.batch_id = p_batch_id and s1.party_osr between from_osr and to_osr ');
   l(' and ( ( (s1.party_osr = s2.party_osr) and ( nvl(s1.party_id, 1) = nvl(s2.party_id,1) ) ) OR ( s1.party_id = s2.party_id) ) '); -- bug 5393826
   l('and s2.batch_id = p_batch_id and s1.' || p_entity_osr_name || ' < ' || 's2.' || p_entity_osr_name );

   -- only for contact point types
   IF p_entity = 'CONTACT_POINTS'
   THEN
     l('and s1.contact_point_type = s2.contact_point_type');
   END IF;

   l('and ( ');

   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ NON FILTER ATTRIBUTES SECTION ------------------------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW TAKE CARE OF FILTER ATTRIBUTES
   FIRST1 := TRUE;
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'Y'
    and HZ_IMP_DQM_STAGE.EXIST_COL(a.attribute_name, a.entity_name ) = 'Y'
    )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ FILTER ATTRIBUTES SECTION ------------------------');
                END IF;

               l('and ');

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                        FIRST := FALSE;
                    ELSE
                        l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                    END IF;

               END LOOP;
               l(')');
   END LOOP;

-- IF THE ENTITY IS NOT A PARTY THEN WE NEED TO MAKE SURE THAT ALL PARTY LEVEL
-- ACQUISTION ATTRIBUTES (IF ANY), THAT SERVE AS FILTERS ARE MATCHED.


l(';');
l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Ending insert of ' || p_entity || ''''|| ');');
l('FND_FILE.put_line(FND_FILE.log,''Number of records inserted ''||SQL%ROWCOUNT);');
l('FND_FILE.put_line(FND_FILE.log,''End time to insert ''||to_char(sysdate,''hh24:mi:ss''));');
l('FND_CONCURRENT.AF_Commit;');
END;

-------------------------------------------------------------------------
-- gen_insert_footer_int :
-------------------------------------------------------------------------
PROCEDURE gen_insert_footer_int(p_match_rule_id number)
IS
FIRST1 boolean;
FIRST boolean;
BEGIN
   l(')');

   -- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES
   IF has_party_filter_attributes(p_match_rule_id)= 'Y'
   THEN
                   l('------- ONE TIME CHECK FOR PARTY LEVEL FILTER ATTRIBUTES---------');
                   l('where EXISTS (');
                   l('SELECT 1 FROM HZ_SRCH_PARTIES p1, HZ_SRCH_PARTIES p2');
                   l('WHERE p1.batch_id = p_batch_id and p1.party_osr = f and p1.party_os = fos');
                   l('and p2.batch_id = p_batch_id and p2.party_osr = t and p2.party_os = tos');
                   FIRST1 := TRUE;
                   FOR attrs in (
                    SELECT primary_attribute_id
                    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
                    where  p.match_rule_id=p_match_rule_id
                    and p.attribute_id=a.attribute_id
                    and a.entity_name = 'PARTY'
                    and nvl(p.filter_flag,'N') = 'Y'
                    and HZ_IMP_DQM_STAGE.EXIST_COL(a.attribute_name, a.entity_name ) = 'Y'
                    )
                   LOOP
                              IF FIRST1
                              THEN
                                   FIRST1 := FALSE;
                              END IF;

                               -- between attributes
                               l('and');

                               FIRST := TRUE;
                               FOR trans in ( SELECT staged_attribute_column
                                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                                  where f.function_id = pt.function_id
                                  and pt.primary_attribute_id = attrs.primary_attribute_id
                               )
                               LOOP
                                     IF FIRST
                                     THEN
                                        l('-- do an or between all the transformations of an attribute -- ');
                                        l('(');
                                        l('((p1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         'p2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     'p2.'|| trans.staged_attribute_column || ' = p1.'||
                                                     trans.staged_attribute_column || ')');
                                        FIRST := FALSE;
                                     ELSE
                                        l('or ((p1.'|| trans.staged_attribute_column || ' is null and ' ||
                                         'p2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     'p2.'|| trans.staged_attribute_column || ' = p1.'||
                                                     trans.staged_attribute_column || ')');
                                     END IF;

                               END LOOP;
                            l(')');
                   END LOOP;
           l(')');
   END IF;

   l('group by f, t, fos, tos');

    -- having clause should exist only if x_insert_threshold
    -- is positive
    IF get_insert_threshold(p_match_rule_id) > 0
    THEN
        l('having sum(score) >= x_insert_threshold');
    END IF;

   l(';');
   l('FND_FILE.put_line(FND_FILE.log,''Number of parties inserted ''||SQL%ROWCOUNT);');
   l('FND_FILE.put_line(FND_FILE.log,''End time of insert ''||to_char(sysdate,''hh24:mi:ss''));');
   l('FND_CONCURRENT.AF_Commit;');
END;


-------------------------------------------------------------------------
-- gen_update_template_int :
-------------------------------------------------------------------------
PROCEDURE gen_update_template_int (
        s_table VARCHAR2,
        p_table VARCHAR2,
        p_match_rule_id NUMBER,
        p_entity VARCHAR2,
        p_match_all_flag VARCHAR2
)
IS
FIRST BOOLEAN ;
FIRST1 BOOLEAN;
outer_row_count number := 0 ;
inner_row_counter number := 0;
outer_row_counter number := 0;

BEGIN

   l('');
   l('');
   l('FND_FILE.put_line(FND_FILE.log,''------------------------------------------------'');');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Beginning update of Parties on the basis of ' || p_entity || ''''|| ');');
   l('FND_FILE.put_line(FND_FILE.log,''Start time of update ''||to_char(sysdate,''hh24:mi:ss''));');
   l('open x_ent_cur for');
   l('select f,t,max(score) from (');
   l(' select /*+ USE_CONCAT */ s1.party_osr f, s2.party_osr t,');

  -- Generate the Secondary Attribute section of the query for the passed in entity
    SELECT count(1) into outer_row_count
   FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
   where a.attribute_id=s.attribute_id
   and s.match_rule_id=p_match_rule_id
   and a.entity_name = p_entity;

  IF has_scoring_attributes(p_match_rule_id, p_entity)
  THEN

          FOR attrs in (
            SELECT score,s.attribute_id , secondary_attribute_id
            FROM HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
            where a.attribute_id=s.attribute_id
            and s.match_rule_id=p_match_rule_id
            and a.entity_name = p_entity)
            LOOP
                outer_row_counter := outer_row_counter + 1;
                inner_row_counter := 0;

                      FOR trans in (
                        SELECT round(transformation_weight/100*attrs.score) score, staged_attribute_column
                        FROM hz_secondary_trans st, hz_trans_functions_vl f
                        where f.function_id=st.function_id
                        and st.secondary_attribute_id = attrs.secondary_attribute_id
                        order by transformation_weight desc)
                      LOOP
                                  inner_row_counter := inner_row_counter + 1;
                                  l('decode(instrb(s2.'||trans.staged_attribute_column
                                      || ',s1.'||trans.staged_attribute_column||
                                     '),1,'|| trans.score||',');

                      END LOOP;

                      l('0');

                       -- Need to have as many right parentheses as inner_row_counter
                      FOR I IN 1 .. inner_row_counter
                      LOOP
                        l(')');
                      END LOOP;

                      IF outer_row_counter < outer_row_count
                      THEN
                          l('+');
                      END IF;
           END LOOP;
   ELSE
        l('0 ');
   END IF;

   l('score');
   l('from hz_int_dup_results h1, '||s_table||' s1, '||s_table||' s2');
   l('where');
   l('s1.party_osr = h1.f_osr and s2.party_osr = h1.t_osr and h1.batch_id = p_batch_id');
   l('and s1.party_osr between from_osr and to_osr');

   -- only for contact point types
   IF p_entity = 'CONTACT_POINTS'
   THEN
     l('and s1.contact_point_type = s2.contact_point_type');
   END IF;


   l('and ( ');

   -- Generate the Primary Attribute section of the query for the passed in entity
   -- TAKE CARE OF NON-FILTER ATTRIBUTES FIRST
   FIRST1 := TRUE;
   -- Generate the Primary Attribute section of the query for the passed in entity
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'N' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ NON FILTER ATTRIBUTES SECTION ------------------------');
                ELSE
                    IF p_match_all_flag = 'Y'
                    THEN
                        l('and');
                    ELSE
                        l('or');
                    END IF;

                END IF;

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('(s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' like s1.'||
                                         trans.staged_attribute_column || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                        FIRST := FALSE;
                    ELSE
                         l(' or (s1.'|| trans.staged_attribute_column || ' is not null and ' ||
                                         's2.'|| trans.staged_attribute_column || ' '|| ' like s1.'||
                                         trans.staged_attribute_column || ' ' || ' || decode(sign(lengthb(s1.' || trans.staged_attribute_column || ')-'|| HZ_DQM_DUP_ID_PKG.l_like_comparison_min_length || '),1,''%'',''''))');
                    END IF;

               END LOOP;
             l(')');

   END LOOP;
   l(')');

   -- NOW TAKE CARE OF FILTER ATTRIBUTES
   FIRST1 := TRUE;
   FOR attrs in (
    SELECT primary_attribute_id
    FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
    where  p.match_rule_id=p_match_rule_id
    and p.attribute_id=a.attribute_id
    and a.entity_name = p_entity
    and nvl(p.filter_flag,'N') = 'Y' )
   LOOP
                -- between attributes
                IF FIRST1
                THEN
                   FIRST1 := FALSE;
                   l('------------ FILTER ATTRIBUTES SECTION ------------------------');
                END IF;

               l('and ');

               FIRST := TRUE;
               FOR trans in ( SELECT staged_attribute_column
                  FROM hz_primary_trans pt, hz_trans_functions_vl f
                  where f.function_id = pt.function_id
                  and pt.primary_attribute_id = attrs.primary_attribute_id
               )
               LOOP
                    IF FIRST
                    THEN
                        l('-- do an or between all the transformations of an attribute -- ');
                        l('(');
                        l('((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                         FIRST := FALSE;
                    ELSE
                        l('or ((s1.'|| trans.staged_attribute_column || ' is null and ' ||
                                              's2.'|| trans.staged_attribute_column || ' is null) or ' ||
                                                     's2.'|| trans.staged_attribute_column || ' = s1.'||
                                                     trans.staged_attribute_column || ')');
                    END IF;

               END LOOP;
               l(')');
   END LOOP;
   l(') group by f,t ;');
   l('HZ_DQM_DUP_ID_PKG.update_hz_int_dup_results(p_batch_id,x_ent_cur);');
   l('close x_ent_cur;');
   l('FND_FILE.put_line(FND_FILE.log,''Number of parties updated ''||SQL%ROWCOUNT);');
   l('FND_FILE.put_line(FND_FILE.log,''End time to update ''||to_char(sysdate,''hh24:mi:ss''));');
   l('FND_FILE.put_line(FND_FILE.log,'||''''|| 'Ending update of Parties on the basis of ' || p_entity || ''''|| ');');
   l('FND_CONCURRENT.AF_Commit;');

END;

-------------------------------------------------------------------------
-- gen_footer_int :
-------------------------------------------------------------------------
PROCEDURE gen_footer_int(p_pkg_name VARCHAR2)
IS
BEGIN
    l('');
    l('---------- exception block ---------------');
    l('EXCEPTION');
    l('WHEN OTHERS THEN');
    l('         FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
    l('         FND_MESSAGE.SET_TOKEN(''PROC'',''' || p_pkg_name || '.interface_join_entities'');');
    l('         FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
    l('         FND_MSG_PUB.ADD;');
    l('         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
    l('END interface_join_entities;');
END;



-------------------------------------------------------------------------
-- gen_pkg_body_int_join : A Private procedure that will generate the package body
--               of the match rule
-------------------------------------------------------------------------

PROCEDURE gen_pkg_body_int_join(
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER,
        p_att_flag            IN      VARCHAR2
)
IS
CURSOR entity_cur IS
                select entity_name, search_table_name, entity_table_name, entity_osr_name, entity_os_name, sc, att_flag
                from
                        (select  entity_name, decode(entity_name,
                                       'PARTY','HZ_SRCH_PARTIES',
                                       'PARTY_SITES', 'HZ_SRCH_PSITES',
                                       'CONTACTS','HZ_SRCH_CONTACTS',
                                       'CONTACT_POINTS', 'HZ_SRCH_CPTS') search_table_name,
                                        decode(entity_name,
                                       'PARTY','HZ_STAGED_PARTIES',
                                       'PARTY_SITES', 'HZ_STAGED_PARTY_SITES',
                                       'CONTACTS','HZ_STAGED_CONTACTS',
                                       'CONTACT_POINTS', 'HZ_STAGED_CONTACT_POINTS') entity_table_name,
                                        decode(entity_name,
                                       'PARTY','PARTY_OSR',
                                       'PARTY_SITES', 'PARTY_SITE_OSR',
                                       'CONTACTS','CONTACT_OSR',
                                       'CONTACT_POINTS', 'CONTACT_PT_OSR') entity_osr_name,
                                        decode(entity_name,
                                       'PARTY','PARTY_OS',
                                       'PARTY_SITES', 'PARTY_SITE_OS',
                                       'CONTACTS','CONTACT_OS',
                                       'CONTACT_POINTS', 'CONTACT_PT_OS') entity_os_name,
                                       sum(score) sc, 'S' att_flag
                        from hz_trans_attributes_vl a, hz_match_rule_secondary s
                        where s.match_rule_id = p_match_rule_id
                        and s.attribute_id = a.attribute_id
                        group by entity_name
                        union all
                      select  entity_name, decode(entity_name,
                     'PARTY','HZ_SRCH_PARTIES',
                     'PARTY_SITES', 'HZ_SRCH_PSITES',
                     'CONTACTS','HZ_SRCH_CONTACTS',
                     'CONTACT_POINTS', 'HZ_SRCH_CPTS') search_table_name,
                      decode(entity_name,
                     'PARTY','HZ_STAGED_PARTIES',
                     'PARTY_SITES', 'HZ_STAGED_PARTY_SITES',
                     'CONTACTS','HZ_STAGED_CONTACTS',
                     'CONTACT_POINTS', 'HZ_STAGED_CONTACT_POINTS') entity_table_name,
                      decode(entity_name,
                     'PARTY','PARTY_OSR',
                     'PARTY_SITES', 'PARTY_SITE_OSR',
                     'CONTACTS','CONTACT_OSR',
                     'CONTACT_POINTS', 'CONTACT_PT_OSR') entity_osr_name,
                      decode(entity_name,
                     'PARTY','PARTY_OS',
                     'PARTY_SITES', 'PARTY_SITE_OS',
                     'CONTACTS','CONTACT_OS',
                     'CONTACT_POINTS', 'CONTACT_PT_OS') entity_os_name,
                      0 sc, 'P' att_flag
                      from hz_trans_attributes_vl a, hz_match_rule_primary p
                      where p.match_rule_id = p_match_rule_id
                      and  p.attribute_id = a.attribute_id
                      group by entity_name
                ) where att_flag = p_att_flag
                order by sc desc ;
srt score_rec_type;
threshold number;
match_all_flag varchar2(1);
row_count number;
no_of_entities number;
template varchar2(30);
insert_stmt_is_open boolean;
BEGIN

    -- Get the threshold and match_all_flag
    select match_score, match_all_flag into threshold, match_all_flag
    from hz_match_rules_vl
    where match_rule_id = p_match_rule_id;

   -- Get the different aggregates that would help in determining the template
   -- that need to be used -- UNION/UPDATE for the corresponding entity.

       -- If attribute flag is 'P', make the threshold 0
       -- This signifies that the match rule has no scoring attributes
   IF p_att_flag = 'P'
   THEN
       threshold := 0;
       srt.sum_score := 0;
       srt.min_score := 0;
       srt.max_score := 0;
   ELSE
       srt := get_misc_scores(p_match_rule_id);
   END IF;


    -- Initialize the number of entities
    no_of_entities := 0;

    -- Get the number of entities
    FOR c0 in entity_cur
    LOOP
        no_of_entities := no_of_entities + 1;
    END LOOP;


    -- Before generating the code for the given match rule, we look at the
    -- match_all_flag to determine, the structure of the code that needs
    -- to go into the generated match rule package.
    -- The flag is always assumed to be 'N' by default ie., a match on ANY of the
    -- entities, would be given consideration.
    -- If flag = 'Y', then we need to make sure that every query after the first
    -- one is an update. We make this happen by manually setting the threshold.
    IF match_all_flag = 'Y'
    THEN
        threshold := srt.sum_score;
    END IF;

    -- Generate the Header
    gen_header_int(p_pkg_name, p_match_rule_id);

    l('------------------ PARTY LEVEL DUPLICATE IDENTIFICATION BEGINS --------------------');

    -- Open the entity cursor, determine the templates (INSERT/UPDATE) for each
    -- and call the appropriate function to add lines to the generated package
    -- for the corresponding entity
    row_count := 0;
    insert_stmt_is_open := false;

    -- some basic observations that would help in this logic
    -- 1. There will always be atleast one insert statement
    -- 2. all insert templates would come under the insert statement
    -- 3. all update templates are modular and do not need any special treatment for opening and closing.
    -- 4. all update templates would be together
    -- 5. when gnerating an update template, we need to make sure that the insert statement is closed.
    -- 6. in the event that we never have an update template, we close the insert statement, outside the loop.
    FOR entity_cur_rec in entity_cur
    LOOP
        row_count := row_count + 1;



            -- First row, is always an insert, unless the match rule returns nothing due
            -- to an erroneous combination of the threshold/match rule configuration.
            -- If that happnes we , get the hell out of here.
            IF row_count = 1
            THEN
                -- pass the first entity forcefully
                IF (srt.sum_score - threshold) >= 0
                THEN
                    gen_insert_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                                         entity_cur_rec.entity_name, match_all_flag);
                    insert_stmt_is_open := true;
                ELSE
                    -- need to handle this by reporting an error and getting the hell out of here.
                    null;
                    return ;
                END IF;
             END IF;

            IF row_count = 2
            THEN

                IF (srt.sum_score - srt.max_score - threshold) >= 0
                THEN
                    l('union all');
                    gen_insert_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                                             entity_cur_rec.entity_name, match_all_flag);
                ELSE
                    IF insert_stmt_is_open
                    THEN
                        gen_insert_footer_int(p_match_rule_id) ;
                        insert_stmt_is_open := false;
                    END IF;
                    gen_update_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                                     entity_cur_rec.entity_name, match_all_flag);
                END IF;
             END IF;

            IF row_count = 3
            THEN
                 IF no_of_entities = 3
                 THEN
                        IF (entity_cur_rec.sc  - threshold) >= 0
                        THEN
                            l('union all');
                            gen_insert_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                                        p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                        ELSE
                            IF insert_stmt_is_open
                            THEN
                                gen_insert_footer_int(p_match_rule_id) ;
                                insert_stmt_is_open := false;
                            END IF;
                            gen_update_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                           entity_cur_rec.entity_name, match_all_flag);
                        END IF;

                 ELSE
                       IF ( entity_cur_rec.sc + srt.min_score - threshold) >= 0
                       THEN
                            l('union all');
                            gen_insert_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name, p_match_rule_id,
                                                              entity_cur_rec.entity_name, match_all_flag);
                       ELSE
                            IF insert_stmt_is_open
                            THEN
                                gen_insert_footer_int(p_match_rule_id) ;
                                insert_stmt_is_open := false;
                            END IF;
                            gen_update_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                                    p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                       END IF;
                 END IF;
             END IF;

            IF row_count = 4
            THEN
                IF (entity_cur_rec.sc  - threshold) >= 0
                THEN
                    l('union all');
                    gen_insert_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                              p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                ELSE
                    IF insert_stmt_is_open
                    THEN
                        gen_insert_footer_int(p_match_rule_id);
                        insert_stmt_is_open := false;
                    END IF;
                    gen_update_template_int(entity_cur_rec.search_table_name, entity_cur_rec.entity_table_name,
                                            p_match_rule_id, entity_cur_rec.entity_name, match_all_flag);
                END IF;
            END IF;

        END LOOP;

        -- Just to make sure that the insert statement is not open, after all the entity queries
        -- have been generated
        IF insert_stmt_is_open
        THEN
            gen_insert_footer_int(p_match_rule_id) ;
            insert_stmt_is_open := false;
        END IF;

        -- generate code for detail level duplicate identification
        FOR entity_cur_rec in entity_cur
        LOOP
            IF entity_cur_rec.entity_name <> 'PARTY'
            THEN
                gen_dl_insert_template_int(entity_cur_rec.search_table_name,entity_cur_rec.entity_table_name,
                                          p_match_rule_id, entity_cur_rec.entity_name, entity_cur_rec.entity_osr_name,
                                                           entity_cur_rec.entity_os_name, match_all_flag );
            END IF;

        END LOOP;
        -- generate the footer for the package
        gen_footer_int(p_pkg_name) ;

END;


PROCEDURE gen_pkg_body_int_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
)
IS
BEGIN
    IF has_scoring_attributes(p_match_rule_id)
    THEN
        gen_pkg_body_int_join(p_pkg_name, p_match_rule_id, 'S');
    ELSE
        gen_pkg_body_int_join(p_pkg_name, p_match_rule_id, 'P');
    END IF;
END ;



END;

/
