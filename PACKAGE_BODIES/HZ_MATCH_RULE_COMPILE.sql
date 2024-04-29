--------------------------------------------------------
--  DDL for Package Body HZ_MATCH_RULE_COMPILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MATCH_RULE_COMPILE" AS
/*$Header: ARHDQMCB.pls 120.97.12010000.8 2010/03/30 07:37:05 amstephe ship $ */

g_party_and_query VARCHAR2(4000);
g_party_or_query VARCHAR2(4000);
g_party_site_query VARCHAR2(4000);
g_contact_query VARCHAR2(4000);
g_cpt_query VARCHAR2(4000);
l_purpose VARCHAR2(30);

--Start of Bug No: 4162385dbms_output.put_line(' ');
FUNCTION get_entity_level_score(p_match_rule_id NUMBER,p_entity_name VARCHAR2)
RETURN NUMBER;
--End of Bug No: 4162385


/*******************Private Procedures forward declarations ********/
PROCEDURE gen_pkg_body (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id       IN      NUMBER
);

-- VJN introduced procedure to generate body for bulk match rules
PROCEDURE gen_pkg_body_bulk (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id       IN      NUMBER
);

PROCEDURE gen_call_api_dynamic_names;

FUNCTION has_acquisition_attribs ( p_match_rule_id IN NUMBER, p_entity_name IN VARCHAR2)
RETURN BOOLEAN
IS
temp BOOLEAN := FALSE ;
BEGIN
        FOR attrs in (
        SELECT primary_attribute_id
        FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
        where  p.match_rule_id= p_match_rule_id
        and p.attribute_id=a.attribute_id
        and a.entity_name = p_entity_name
        )
        LOOP
            temp := TRUE ;
        END LOOP;
   return temp ;
END has_acquisition_attribs ;

---Start of Code Change for Match Rule Set
FUNCTION has_uncompiled_childern(p_rule_set_id NUMBER)
RETURN BOOLEAN;

PROCEDURE compile_all_rulesets (
        p_cond_rule_id   IN NUMBER
);
PROCEDURE pop_conditions(p_mrule_set_id	   IN  NUMBER,
			   p_api_name		   IN  VARCHAR2,
			   p_parameters		   IN  VARCHAR2,
			   p_eval_level IN  VARCHAR2
);
---End of Code Change for Match Rule Set

PROCEDURE generate_map_proc (
   p_entity             IN      VARCHAR2,
   p_proc_name          IN      VARCHAR2,
   p_rule_id            IN      NUMBER
);

PROCEDURE generate_map_proc_bulk (
   p_entity             IN      VARCHAR2,
   p_proc_name          IN      VARCHAR2,
   p_rule_id            IN      NUMBER
);

-- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
 -- OF THE GLOBAL CONDITION RECORD FOR REGULAR MATCH RULES

PROCEDURE generate_ent_cond_pop_rec_proc (
   p_entity             IN      VARCHAR2,
   p_rule_id		    IN      NUMBER
);


PROCEDURE generate_party_map_proc (
   p_proc_name          IN      VARCHAR2,
   p_rule_id            IN      NUMBER
);

PROCEDURE generate_party_map_proc_bulk (
   p_proc_name          IN      VARCHAR2,
   p_rule_id            IN      NUMBER
);

PROCEDURE generate_check_proc (
        p_rule_id       NUMBER);

PROCEDURE gen_pkg_spec (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id       IN      NUMBER
);

PROCEDURE gen_wrap_pkg_body(
	p_rule_id IN NUMBER
);

PROCEDURE gen_exception_block;

-- Fix for Bug 4734661. Modified to add the p_called_from parameter.
PROCEDURE generate_acquire_proc (
        p_rule_id       NUMBER
       ,p_called_from   VARCHAR2 DEFAULT NULL);

PROCEDURE generate_check_staged (
        p_rule_id       IN      NUMBER
);

PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;



/*** Private procedure for inserting lines into generated packages **/
PROCEDURE l(str VARCHAR2) IS
BEGIN
  HZ_GEN_PLSQL.add_line(str);
END;

/*** Private procedure for inserting statement , procedure level debug lines into generated packages **/
PROCEDURE d(p_msg_level NUMBER,str VARCHAR2, val VARCHAR2 DEFAULT NULL, pad VARCHAR2 DEFAULT '    ') IS
l_msg_level VARCHAR2(30);
BEGIN
  IF p_msg_level=FND_LOG.LEVEL_STATEMENT THEN
   l(pad||'IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN');
   l_msg_level :='fnd_log.level_statement';
  ELSIF p_msg_level=FND_LOG.LEVEL_PROCEDURE THEN
   l(pad||'IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN');
   l_msg_level :='fnd_log.level_procedure';
  ELSE
   RETURN;
  END IF;
  IF val IS NULL THEN
    -- REPURI. Bug 4996283. Adding tracking indentifiers for fnd log messages
    -- Passing p_module_prefix as dqm and p_module as hz_match_rule_xxx to help debug fnd logs better

    l(pad||'  hz_utility_v2pub.debug(p_message=>'''||str||' '',p_module_prefix=>''dqm'',p_module=>''hz_match_rule_xxx'',p_prefix=>NULL,p_msg_level=>'||l_msg_level||');');
  ELSE
  l(pad||'  hz_utility_v2pub.debug(p_message=>'''||str||' ''||'||val||',p_module_prefix=>''dqm'',p_module=>''hz_match_rule_xxx'',p_prefix=>NULL,p_msg_level=>'||l_msg_level||');');
  END IF;
  l(pad||'END IF;');
END;

/*** Private procedure for inserting statement , procedure level debug start lines into generated packages **/
PROCEDURE ds(p_msg_level NUMBER,pad VARCHAR2 DEFAULT '    ') IS
BEGIN
IF nvl(FND_PROFILE.VALUE('HZ_DQM_DEV_DEBUG'), 'N') = 'N'
THEN
  IF p_msg_level=FND_LOG.LEVEL_STATEMENT THEN
   l(pad||'IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN');
  ELSIF p_msg_level=FND_LOG.LEVEL_PROCEDURE THEN
   l(pad||'IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN');
  ELSE
   RETURN;
  END IF;
END IF;
END;

/*** Private procedure for inserting statement , procedure level debug content lines into generated packages **/
PROCEDURE dc(p_msg_level NUMBER,str VARCHAR2, val VARCHAR2 DEFAULT NULL, pad VARCHAR2 DEFAULT '    ') IS
l_msg_level VARCHAR2(30);
BEGIN
IF nvl(FND_PROFILE.VALUE('HZ_DQM_DEV_DEBUG'), 'N') = 'N'
THEN
  IF p_msg_level=FND_LOG.LEVEL_STATEMENT THEN
     l_msg_level :='fnd_log.level_statement';
  ELSIF p_msg_level=FND_LOG.LEVEL_PROCEDURE THEN
      l_msg_level :='fnd_log.level_procedure';
  ELSE
   RETURN;
  END IF;
  IF val IS NULL THEN
    -- REPURI. Bug 4996283. Adding tracking indentifiers for fnd log messages
    -- Passing p_module_prefix as dqm and p_module as hz_match_rule_xxx to help debug fnd logs better

    l(pad||'  hz_utility_v2pub.debug(p_message=>'''||str||''',p_module_prefix=>''dqm'',p_module=>''hz_match_rule_xxx'',p_prefix=>NULL,p_msg_level=>'||l_msg_level||');');
  ELSE
    l(pad||'  hz_utility_v2pub.debug(p_message=>'''||str||' ''||'||val||',p_module_prefix=>''dqm'',p_module=>''hz_match_rule_xxx'',p_prefix=>NULL,p_msg_level=>'||l_msg_level||');');
  END IF;
ELSE
  IF val IS NULL THEN
     l('dbms_output.put_line(SubStr(''' || str || ''', 1, 255));');
  ELSE
     l('dbms_output.put_line(SubStr(''' || str || '''||''---''||' || val || ', 1, 255));');
  END IF;

END IF;
END;

/*** Private procedure for inserting statement , procedure level debug end lines into generated packages **/
PROCEDURE de(pad VARCHAR2 DEFAULT '    ') IS
BEGIN
IF nvl(FND_PROFILE.VALUE('HZ_DQM_DEV_DEBUG'), 'N') = 'N'
THEN
  l(pad||'END IF;');
END IF;
END;

/*** VJN Introduced Private procedures for inserting
upto four consecutive procedure level debug lines with
statement level header and footer into generated
packages
     Note that str1 and val1 are not defaulted. We need atleast
one procedure level line.

     This the string - value pair version
**/
PROCEDURE ldbg_sv(str1 VARCHAR2, val1 VARCHAR2,
               str2 VARCHAR2 DEFAULT NULL, val2 VARCHAR2 DEFAULT NULL,
               str3 VARCHAR2 DEFAULT NULL, val3 VARCHAR2 DEFAULT NULL,
               str4 VARCHAR2 DEFAULT NULL, val4 VARCHAR2 DEFAULT NULL
               ) IS
BEGIN

  IF str1 IS NOT NULL
  THEN
    ds(fnd_log.level_statement, '   ');
    dc(fnd_log.level_statement, str1, val1) ;
  END IF;

  IF str2 IS NOT NULL
  THEN
    dc(fnd_log.level_statement, str2, val2) ;
  END IF;

  IF str3 IS NOT NULL
  THEN
    dc(fnd_log.level_statement, str3, val3) ;
  END IF;

  IF str4 IS NOT NULL
  THEN
    dc(fnd_log.level_statement, str4, val4) ;
  END IF;

  IF str1 IS NOT NULL
  THEN
     de ;
  END IF;

END;

/**
   This the string only version
**/
PROCEDURE ldbg_s(str1 VARCHAR2,
               str2 VARCHAR2 DEFAULT NULL,
               str3 VARCHAR2 DEFAULT NULL,
               str4 VARCHAR2 DEFAULT NULL
               ) IS
BEGIN

  IF str1 IS NOT NULL
  THEN
    ds(fnd_log.level_statement, '   ');
    dc(fnd_log.level_statement, str1 ) ;
  END IF;

  IF str2 IS NOT NULL
  THEN
    dc(fnd_log.level_statement, str2 ) ;
  END IF;

  IF str3 IS NOT NULL
  THEN
    dc(fnd_log.level_statement, str3 ) ;
  END IF;

  IF str4 IS NOT NULL
  THEN
    dc(fnd_log.level_statement, str4) ;
  END IF;

  IF str1 IS NOT NULL
  THEN
     de ;
  END IF;

END;

PROCEDURE ldbg_procedure
IS
BEGIN
  IF nvl(FND_PROFILE.VALUE('HZ_DQM_DEV_DEBUG'), 'N') = 'Y'
  THEN
    l('');
    l('PROCEDURE output_long_strings(input_str VARCHAR2 DEFAULT NULL)');
    l('IS');
    l('     remainder_str VARCHAR2(4000);');
    l('     current_pos NUMBER ;');
    l('BEGIN');
    l('     remainder_str := input_str ;');
    l('     current_pos := 1 ;');
    l('     WHILE remainder_str IS NOT NULL');
    l('     LOOP');
    l('         dbms_output.put_line(substr(remainder_str, 1 , 255 ) );');
    l('         current_pos := current_pos + 255 ;');
    l('         remainder_str := substr(input_str,current_pos );');
    l('     END LOOP ;');
    l('END ;');
   ELSE
    l('');
    l('PROCEDURE output_long_strings(input_str VARCHAR2 DEFAULT NULL)');
    l('IS');
    l('     remainder_str VARCHAR2(4000);');
    l('     current_pos NUMBER ;');
    l('     temp VARCHAR2(300) ;');
    l('BEGIN');
    l('     remainder_str := input_str ;');
    l('     current_pos := 1 ;');
    ds(fnd_log.level_statement, '   ');
    l('     WHILE remainder_str IS NOT NULL');
    l('     LOOP');
    l('     temp := substr(remainder_str, 1 , 255 );');
    dc(fnd_log.level_statement, ' ', 'temp' ) ;
    l('     current_pos := current_pos + 255 ;');
    l('     remainder_str := substr(input_str,current_pos );');
    l('     END LOOP ;');
    de ;
    l('END ;');
   END IF ;
END ;

FUNCTION num_secondary(
   p_rule_id NUMBER,
   p_entity VARCHAR2) RETURN NUMBER;


-- VJN Introduced Private procedure to generate primary attribute predicate for bulk match rules
PROCEDURE generate_bulk_predicate(
   p_rule_id IN NUMBER,
   p_dynamic_sql_flag  IN VARCHAR2 DEFAULT 'N',
   p_match_str IN VARCHAR2,
   p_entity IN VARCHAR2)
IS
FIRST1 boolean;
FIRST boolean;
BEGIN
   IF p_dynamic_sql_flag = 'Y'
   THEN
        l('            ''srch.batch_id = -1''||');
        l('            ''AND''||');
        l('            ''(''||'    );
               -- Generate the Primary Attribute section of the query for the passed in entity
         FIRST1 := TRUE;
         FOR attrs in (
          SELECT primary_attribute_id
          FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
          where  p.match_rule_id=p_rule_id
          and p.attribute_id=a.attribute_id
          and a.entity_name = p_entity
          and nvl(p.filter_flag,'N') = 'N' )
         LOOP
                      -- between attributes
                      IF FIRST1
                      THEN
                         FIRST1 := FALSE;
                         l('-------' ||  p_entity || ' LEVEL ACQUISITION ON NON-FILTER ATTRIBUTES USING B-TREE INDEXES ---------');
                      ELSE
                         -- spit out the 'AND' or 'OR' depending on the match_all_flag in the match_rule
                         l(''''||p_match_str||''''||'||');

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
                              l('''(''||');
                              l('''(srch.'|| trans.staged_attribute_column || ' is not null and ' ||
                                               'stage.'|| trans.staged_attribute_column || ' like srch.'||
                                               trans.staged_attribute_column || ' || ''''%'''')' || '''||');

                              FIRST := FALSE;
                          ELSE
                               l('''or (srch.'|| trans.staged_attribute_column || ' is not null and ' ||
                                               'stage.'|| trans.staged_attribute_column || ' like srch.'||
                                               trans.staged_attribute_column || ' || ''''%'''')' || '''||');
                          END IF;

                     END LOOP;
                   l(''')''||');
         END LOOP;
        l(''')''||');

   ELSE
         l('            srch.batch_id = -1');
         l('            AND');
         l('            (');
         -- Generate the Primary Attribute section of the query for the passed in entity
         FIRST1 := TRUE;
         FOR attrs in (
          SELECT primary_attribute_id
          FROM HZ_MATCH_RULE_PRIMARY p, HZ_TRANS_ATTRIBUTES_VL a
          where  p.match_rule_id=p_rule_id
          and p.attribute_id=a.attribute_id
          and a.entity_name = p_entity
          and nvl(p.filter_flag,'N') = 'N' )
         LOOP
                      -- between attributes
                      IF FIRST1
                      THEN
                         FIRST1 := FALSE;
                         l('-------' || 'PARTY LEVEL ACQUISITION ON NON-FILTER ATTRIBUTES USING B-TREE INDEXES ---------');
                      ELSE
                         -- spit out the 'AND' or 'OR' depending on the match_all_flag in the match_rule
                         l(p_match_str);

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
                              l('(srch.'|| trans.staged_attribute_column || ' is not null and ' ||
                                               'stage.'|| trans.staged_attribute_column || ' like srch.'||
                                               trans.staged_attribute_column || ' || ''%'')');

                              FIRST := FALSE;
                          ELSE
                               l('or (srch.'|| trans.staged_attribute_column || ' is not null and ' ||
                                               'stage.'|| trans.staged_attribute_column || ' like srch.'||
                                               trans.staged_attribute_column || ' || ''%'')'); --Bug No:3863630
                          END IF;

                     END LOOP;
                   l(')');
         END LOOP;
         l(')');
   END IF;

END ;





/**
* Public procedure to compile a match rule.
* This procedure generates a compiled PLSQL package
* spec and body for the given Match Rule (p_rule_id).
*
* The name of the generated match rule is:
*     HZ_MATCH_RULE_<p_rule_id>
*
**/
PROCEDURE compile_match_rule (
	p_rule_id	IN	NUMBER,
	p_skip_wrap	IN	VARCHAR2,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
) IS

   CURSOR check_null_set IS
    SELECT DISTINCT a.entity_name
    FROM hz_match_rule_secondary s, hz_trans_attributes_vl a
    WHERE a.attribute_id = s.attribute_id
    AND s.match_rule_id = p_rule_id
    MINUS
    SELECT DISTINCT a.entity_name
    FROM hz_match_rule_primary p, hz_trans_attributes_vl a
    WHERE a.attribute_id = p.attribute_id
    AND p.match_rule_id = p_rule_id;

   CURSOR check_inactive IS
    SELECT 1
    FROM hz_match_rule_primary p, hz_primary_trans pt, hz_trans_functions_vl f
    WHERE p.match_rule_id = p_rule_id
    AND pt.PRIMARY_ATTRIBUTE_ID = p.PRIMARY_ATTRIBUTE_ID
    AND f.function_id = pt.function_id
    AND f.ACTIVE_FLAG = 'N'
    UNION
    SELECT 1
    FROM hz_match_rule_secondary s, hz_secondary_trans pt, hz_trans_functions_vl f
    WHERE s.match_rule_id = p_rule_id
    AND pt.SECONDARY_ATTRIBUTE_ID = s.SECONDARY_ATTRIBUTE_ID
    AND f.function_id = pt.function_id
    AND f.ACTIVE_FLAG = 'N';

-- Local variable declarations
    l_tmp VARCHAR2(255);

    l_rule_id NUMBER;
    l_batch_flag VARCHAR2(1);
    l_purpose VARCHAR2(1);
    l_package_name VARCHAR2(2000);
    l_match_rule_type varchar2(30); --Code Change for Match Rule Set

BEGIN

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the compiled package name
  l_rule_id := TO_NUMBER(p_rule_id);
  l_package_name := 'HZ_MATCH_RULE_'||p_rule_id;

  -- Initialize message stack
  FND_MSG_PUB.initialize;

  BEGIN
    -- Verify that the match rule exists
    SELECT 1 INTO l_batch_flag
    FROM HZ_MATCH_RULES_VL
    WHERE match_rule_id = l_rule_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_STAGE_NO_RULE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;


  SELECT RULE_PURPOSE,NVL(MATCH_RULE_TYPE,'SINGLE') into l_purpose,l_match_rule_type FROM HZ_MATCH_RULES_VL --Code Change for Match Rule Set
  WHERE match_rule_id = l_rule_id;

 --Start of Code Change for Match Rule Set
  IF (l_match_rule_type = 'SET') THEN
    IF (has_uncompiled_childern(l_rule_id)) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_RULE_SET_UNCOMP_RULE_EXISTS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
   --Populate the match rule set primary and secondary attributes
   HZ_POP_MRULE_SET_ATTR_V2PUB.pop_mrule_set_attributes(l_rule_id);
  END IF;
 --End Of Code Change for Match Rule Set


 -- VJN : In order to make sure that Bulk Duplicate Identification Match rules
 --       have both the following versions:
 --       1. HZ_MATCH_RULE_XXX that incorporate the  "find APIS"
 --          that use the conventional B-tree indexes as opposed to Intermedia indexes.
 --       2. HZ_IMP_MATCH_RULE_XXX that incorporate the APIs which do the
 --          bulk duplicate identification, using B-tree indexes.
 --       I have changed the logic of this match rule generating package to
 --       generate HZ_MATCH_RULE_XXX for all match rules ( no matter which rule_purpose it is)
 --       and generate HZ_IMP_MATCH_RULE_XXX in addition, when the rule_purpose is "Q".

    /* abordia.  Added to check that acquisition has at least one attribute for each
     entity defined in scoring.  Added update statements since compile_match_rule
     is public api and commented unnecessary updates in compile_all_rules and
     compile_all_rules_nolog.  */
    OPEN  check_null_set;
    FETCH check_null_set INTO l_tmp;
    IF check_null_set%FOUND THEN
      CLOSE  check_null_set;
      BEGIN
        EXECUTE IMMEDIATE 'DROP PACKAGE HZ_MATCH_RULE_'||l_rule_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      fnd_message.set_name('AR','HZ_SCORING_NO_ACQUISITION');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_null_set;

    /* Check if match rule has any inactive transformations */
    OPEN check_inactive;
    FETCH check_inactive INTO l_tmp;
    IF check_inactive%FOUND THEN
      CLOSE  check_inactive;
      BEGIN
        EXECUTE IMMEDIATE 'DROP PACKAGE HZ_MATCH_RULE_'||l_rule_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      fnd_message.set_name('AR','HZ_MR_HAS_INACTIVE_TX');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE check_inactive;

    -- Generate and compile match rule package spec
    HZ_GEN_PLSQL.new(l_package_name, 'PACKAGE');
    gen_pkg_spec(l_package_name, l_rule_id);
    HZ_GEN_PLSQL.compile_code;

    -- Generate the package body
    HZ_GEN_PLSQL.new(l_package_name, 'PACKAGE BODY');

    -- VJN: generate the body for HZ_MATCH_RULE_XXX depending on the rule purpose:
    --      If rule purpose is Q, we would generate Bulk Match rules that use B-tree indexes
    --      Else we would generate Match rules that use the regular intermedia text indexes

    g_context := 'SEARCH';
    IF l_purpose = 'Q'
    THEN
       gen_pkg_body_bulk(l_package_name, l_rule_id);
    ELSE
       IF(l_purpose ='D')THEN
        g_context := 'SDIB';
       END IF;
       gen_pkg_body(l_package_name, l_rule_id);
    END IF;

    -- Compile the package body
    HZ_GEN_PLSQL.compile_code;


    IF p_skip_wrap IS NULL OR p_skip_wrap='N' THEN
      -- Generate and compile API package body (Package HZ_PARTY_SEARCH)
      HZ_GEN_PLSQL.new('HZ_PARTY_SEARCH','PACKAGE BODY');
      gen_wrap_pkg_body(p_rule_id);
      HZ_GEN_PLSQL.compile_code;
    END IF;

    EXECUTE IMMEDIATE 'ALTER PACKAGE ' || l_package_name || ' COMPILE SPECIFICATION';  --bug 5622345

    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data);

    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'C' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;

     /*
    IF l_match_rule_type <> 'SET' THEN
     compile_all_rulesets(l_rule_id);
    END IF;
    */

  -- VJN: For match rules of type "Q" viz., Bulk Match Rules, generate
  --      and compile HZ_IMP_MATCH_RULE_XXX packages

  IF l_purpose = 'Q'
  THEN
     HZ_DQM_DUP_ID_PKG.compile_match_rule(l_rule_id,x_return_status,x_msg_count,x_msg_data);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PROC','compile_match_rule');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_rule_id;
    COMMIT;
END;

PROCEDURE compile_match_rule (
	p_rule_id	IN	NUMBER,
        x_return_status         OUT NOCOPY    VARCHAR2,
        x_msg_count             OUT NOCOPY    NUMBER,
        x_msg_data              OUT NOCOPY    VARCHAR2
) IS
BEGIN
  compile_match_rule(p_rule_id,'N',x_return_status,x_msg_count,x_msg_data);
END;

/**
* Private procedure to generate the body of the API package
*    HZ_PARTY_SEARCH
*
* This procedure generates a call to the appropriate match rule
* procedure for each match rule
*
**/
PROCEDURE gen_wrap_pkg_body (
	p_rule_id	IN	NUMBER
) IS

FIRST BOOLEAN;
  l_sql VARCHAR2(4000);

  FUNCTION check_proc (p_rule_id NUMBER) RETURN BOOLEAN IS
    c NUMBER;
  BEGIN
    c := dbms_sql.open_cursor;
    dbms_sql.parse(c,replace(l_sql,'RULEID',to_char(p_rule_id)),2);
    dbms_sql.close_cursor(c);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;

BEGIN
 -- UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'T' WHERE RULE_PURPOSE='Q' AND COMPILATION_FLAG='C';
  -- Generation of code
  l('CREATE or REPLACE PACKAGE BODY HZ_PARTY_SEARCH AS');
  l('/*=======================================================================+');
  l(' |  Copyright (c) 1999 Oracle Corporation Redwood Shores, California, USA|');
  l(' |                          All rights reserved.                         |');
  l(' +=======================================================================+');
  l(' | NAME');
  l(' |      HZ_PARTY_SEARCH');
  l(' |');
  l(' | DESCRIPTION');
  l(' |');
  l(' | Compiled by the HZ Match Rule Compiler');
  l(' | PUBLIC PROCEDURES');
  l(' |    find_parties');
  l(' |    get_matching_party_sites');
  l(' |    get_matching_contacts');
  l(' |    get_matching_contact_points');
  l(' |    get_party_score_details');
  l(' |    ');
  l(' | HISTORY');
  l(' |      '||TO_CHAR(SYSDATE,'DD-MON-YYYY') || ' Generated by HZ Match Rule Compiler');
  l(' |');
  l(' *=======================================================================*/');

  l('  g_debug_count                        NUMBER := 0;');
  --l('  g_debug                              BOOLEAN := FALSE;');
  l('  g_last_rule			    NUMBER := -1;');
  l('  g_last_rule_valid	 	    BOOLEAN := FALSE;');

  --l('  PROCEDURE enable_debug;');
  --l('  PROCEDURE disable_debug;');

  -- Generate find_parties code. Backward compatible signature.
  l('  PROCEDURE find_parties (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      x_rule_id               IN OUT  NUMBER,');
  l('      p_party_search_rec      IN      party_search_rec_type,');
  l('      p_party_site_list       IN      party_site_list,');
  l('      p_contact_list          IN      contact_list,');
  l('      p_contact_point_list    IN      contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         IN OUT  NUMBER,');
  l('      x_num_matches           IN OUT  NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  BEGIN');
  d(fnd_log.level_procedure,'find_parties-1(+)');
  d(fnd_log.level_statement,'Rule ID','x_rule_id');

  l('     find_parties(p_init_msg_list,x_rule_id,p_party_search_rec,');
  l('            p_party_site_list,p_contact_list,p_contact_point_list,');
  l('            p_restrict_sql,NULL,p_search_merged,x_search_ctx_id,');
  l('            x_num_matches,x_return_status,x_msg_count,x_msg_data);');
  d(fnd_log.level_procedure,'find_parties-1(-)');
  l('  END;');
  l('');
  -- Generate find_parties code. Public  signature.
  l('  PROCEDURE find_parties (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      party_search_rec_type,');
  l('      p_party_site_list       IN      party_site_list,');
  l('      p_contact_list          IN      contact_list,');
  l('      p_contact_point_list    IN      contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');
  l('');
  d(fnd_log.level_procedure,'find_parties(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_parties(');
    l('        p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,');
    l('        p_contact_point_list,p_restrict_sql,p_match_type,p_search_merged,NULL,NULL,NULL,''N'',x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  -- Quality Score
  l(' -- User quality score ');
  l(' IF (fnd_profile.value(''HZ_QUALITY_WEIGHTING_USER_HOOK'') = ''Y'')  THEN  ');
  l('     HZ_DQM_SEARCH_UTIL.get_quality_score ( x_search_ctx_id, p_rule_id); ');
  l('  END IF; ');

  d(fnd_log.level_procedure,'find_parties(-)');
  gen_exception_block;
  l('  END;');
  l('');


  -- Generate find_persons code. Public  signature.
  l('  PROCEDURE find_persons (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      party_search_rec_type,');
  l('      p_party_site_list       IN      party_site_list,');
  l('      p_contact_list          IN      contact_list,');
  l('      p_contact_point_list    IN      contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2, ');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');
  l('');
  d(fnd_log.level_procedure,'find_persons(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  ---Bug:5261867, additional parameter null in place of p_search_merged
  l_sql := 'declare x number; y number; begin HZ_MATCH_RULE_RULEID.find_persons(-1,'||
    'HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,'||
    'HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,HZ_PARTY_SEARCH.G_MISS_CONTACT_POINT_LIST,'||
    'null,null,null,null,x,y); end;';

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    IF check_proc(RULE.MATCH_RULE_ID) THEN
      l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
      l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
      l('        FND_MSG_PUB.ADD;');
      l('        RAISE FND_API.G_EXC_ERROR;');
      l('      END IF;');
      l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_persons(');
      l('        p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,');
      l('        p_contact_point_list,p_restrict_sql,p_match_type,p_search_merged,''N'',x_search_ctx_id,x_num_matches);');
    ELSE
      l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
      l('      FND_MSG_PUB.ADD;');
      l('      RAISE FND_API.G_EXC_ERROR;');
    END IF;

  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_persons(-)');
  gen_exception_block;
  l('  END;');
  l('');


  -- Generate find_persons code. Public  signature.
  l('  PROCEDURE find_persons (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      party_search_rec_type,');
  l('      p_party_site_list       IN      party_site_list,');
  l('      p_contact_list          IN      contact_list,');
  l('      p_contact_point_list    IN      contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  BEGIN');
  l('  	find_persons (');
  l('      p_init_msg_list,p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list, ');
  l('      p_restrict_sql ,p_match_type,NULL,x_search_ctx_id,x_num_matches,x_return_status,');
  l('      x_msg_count,x_msg_data);');
  l('  END;');
  l('');

  -- Generate find_party_details code. Public  signature.
  l('  PROCEDURE find_party_details (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      party_search_rec_type,');
  l('      p_party_site_list       IN      party_site_list,');
  l('      p_contact_list          IN      contact_list,');
  l('      p_contact_point_list    IN      contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');

  ds(fnd_log.level_procedure,'    ');
  dc(fnd_log.level_procedure,'find_party_details(+)');
  de('    ');
  ds(fnd_log.level_statement,'    ');
  dc(fnd_log.level_statement,'Rule ID','p_rule_id');
  de('    ');
  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_party_details(');
    l('        p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,');
    l('        p_contact_point_list,p_restrict_sql,p_match_type,p_search_merged,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_party_details(-)');
  gen_exception_block;
  l('  END;');
  l('');
  l('  PROCEDURE find_duplicate_parties (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_dup_set_id            OUT     NUMBER,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_parties(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    IF g_last_rule<>p_rule_id OR NOT g_last_rule_valid THEN');
  l('      OPEN c_match_rule;');
  l('      FETCH c_match_rule INTO l_cmp_flag;');
  l('      IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  l('      END IF;');
  l('      g_last_rule := p_rule_id;');
  l('      g_last_rule_valid := TRUE;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_duplicate_parties(');
    l('        p_rule_id,p_party_id,');
    l('        p_restrict_sql,p_match_type,p_dup_batch_id,p_search_merged,x_dup_set_id, x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_duplicate_parties(-)');

  gen_exception_block;
  l('  END;');
  l('');

  l('');
  l('  PROCEDURE find_duplicate_party_sites (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_site_id         IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_party_sites(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_duplicate_party_sites(');
    l('        p_rule_id,p_party_site_id,p_party_id,');
    l('        p_restrict_sql,p_match_type,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_duplicate_party_sites(-)');

  gen_exception_block;
  l('  END;');

  l('');
  l('  PROCEDURE find_duplicate_contacts (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_org_contact_id        IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_contacts(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_duplicate_contacts(');
    l('        p_rule_id,p_org_contact_id,p_party_id,');
    l('        p_restrict_sql,p_match_type,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_duplicate_contacts(-)');

  gen_exception_block;
  l('  END;');

  l('');
  l('  PROCEDURE find_duplicate_contact_points (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_contact_point_id      IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_contact_points(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_duplicate_contact_points(');
    l('        p_rule_id,p_contact_point_id,p_party_id,');
    l('        p_restrict_sql,p_match_type,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_duplicate_contact_points(-)');

  gen_exception_block;
  l('  END;');
  l('');
  l('');
  l('  PROCEDURE find_parties_dynamic (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_attrib_id1            IN      NUMBER,');
  l('      p_attrib_id2            IN      NUMBER,');
  l('      p_attrib_id3            IN      NUMBER,');
  l('      p_attrib_id4            IN      NUMBER,');
  l('      p_attrib_id5            IN      NUMBER,');
  l('      p_attrib_id6            IN      NUMBER,');
  l('      p_attrib_id7            IN      NUMBER,');
  l('      p_attrib_id8            IN      NUMBER,');
  l('      p_attrib_id9            IN      NUMBER,');
  l('      p_attrib_id10           IN      NUMBER,');
  l('      p_attrib_id11           IN      NUMBER,');
  l('      p_attrib_id12           IN      NUMBER,');
  l('      p_attrib_id13           IN      NUMBER,');
  l('      p_attrib_id14           IN      NUMBER,');
  l('      p_attrib_id15           IN      NUMBER,');
  l('      p_attrib_id16           IN      NUMBER,');
  l('      p_attrib_id17           IN      NUMBER,');
  l('      p_attrib_id18           IN      NUMBER,');
  l('      p_attrib_id19           IN      NUMBER,');
  l('      p_attrib_id20           IN      NUMBER,');
  l('      p_attrib_val1           IN      VARCHAR2,');
  l('      p_attrib_val2           IN      VARCHAR2,');
  l('      p_attrib_val3           IN      VARCHAR2,');
  l('      p_attrib_val4           IN      VARCHAR2,');
  l('      p_attrib_val5           IN      VARCHAR2,');
  l('      p_attrib_val6           IN      VARCHAR2,');
  l('      p_attrib_val7           IN      VARCHAR2,');
  l('      p_attrib_val8           IN      VARCHAR2,');
  l('      p_attrib_val9           IN      VARCHAR2,');
  l('      p_attrib_val10          IN      VARCHAR2,');
  l('      p_attrib_val11          IN      VARCHAR2,');
  l('      p_attrib_val12          IN      VARCHAR2,');
  l('      p_attrib_val13          IN      VARCHAR2,');
  l('      p_attrib_val14          IN      VARCHAR2,');
  l('      p_attrib_val15          IN      VARCHAR2,');
  l('      p_attrib_val16          IN      VARCHAR2,');
  l('      p_attrib_val17          IN      VARCHAR2,');
  l('      p_attrib_val18          IN      VARCHAR2,');
  l('      p_attrib_val19          IN      VARCHAR2,');
  l('      p_attrib_val20          IN      VARCHAR2,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_parties_dynamic(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.find_parties_dynamic(');
    l('        p_rule_id,');
    l('        p_attrib_id1,p_attrib_id2,p_attrib_id3,p_attrib_id4,p_attrib_id5,');
    l('        p_attrib_id6,p_attrib_id7,p_attrib_id8,p_attrib_id9,p_attrib_id10,');
    l('        p_attrib_id11,p_attrib_id12,p_attrib_id13,p_attrib_id14,p_attrib_id15,');
    l('        p_attrib_id16,p_attrib_id17,p_attrib_id18,p_attrib_id19,p_attrib_id20,');
    l('        p_attrib_val1,p_attrib_val2,p_attrib_val3,p_attrib_val4,p_attrib_val5,');
    l('        p_attrib_val6,p_attrib_val7,p_attrib_val8,p_attrib_val9,p_attrib_val10,');
    l('        p_attrib_val11,p_attrib_val12,p_attrib_val13,p_attrib_val14,p_attrib_val15,');
    l('        p_attrib_val16,p_attrib_val17,p_attrib_val18,p_attrib_val19,p_attrib_val20,');
    l('        p_restrict_sql,p_match_type,p_search_merged,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'find_parties_dynamic(-)');

  gen_exception_block;
  l('  END;');
  l('');
  l('  PROCEDURE call_api_dynamic (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_attrib_id1            IN      NUMBER,');
  l('      p_attrib_id2            IN      NUMBER,');
  l('      p_attrib_id3            IN      NUMBER,');
  l('      p_attrib_id4            IN      NUMBER,');
  l('      p_attrib_id5            IN      NUMBER,');
  l('      p_attrib_id6            IN      NUMBER,');
  l('      p_attrib_id7            IN      NUMBER,');
  l('      p_attrib_id8            IN      NUMBER,');
  l('      p_attrib_id9            IN      NUMBER,');
  l('      p_attrib_id10           IN      NUMBER,');
  l('      p_attrib_id11           IN      NUMBER,');
  l('      p_attrib_id12           IN      NUMBER,');
  l('      p_attrib_id13           IN      NUMBER,');
  l('      p_attrib_id14           IN      NUMBER,');
  l('      p_attrib_id15           IN      NUMBER,');
  l('      p_attrib_id16           IN      NUMBER,');
  l('      p_attrib_id17           IN      NUMBER,');
  l('      p_attrib_id18           IN      NUMBER,');
  l('      p_attrib_id19           IN      NUMBER,');
  l('      p_attrib_id20           IN      NUMBER,');
  l('      p_attrib_val1           IN      VARCHAR2,');
  l('      p_attrib_val2           IN      VARCHAR2,');
  l('      p_attrib_val3           IN      VARCHAR2,');
  l('      p_attrib_val4           IN      VARCHAR2,');
  l('      p_attrib_val5           IN      VARCHAR2,');
  l('      p_attrib_val6           IN      VARCHAR2,');
  l('      p_attrib_val7           IN      VARCHAR2,');
  l('      p_attrib_val8           IN      VARCHAR2,');
  l('      p_attrib_val9           IN      VARCHAR2,');
  l('      p_attrib_val10          IN      VARCHAR2,');
  l('      p_attrib_val11          IN      VARCHAR2,');
  l('      p_attrib_val12          IN      VARCHAR2,');
  l('      p_attrib_val13          IN      VARCHAR2,');
  l('      p_attrib_val14          IN      VARCHAR2,');
  l('      p_attrib_val15          IN      VARCHAR2,');
  l('      p_attrib_val16          IN      VARCHAR2,');
  l('      p_attrib_val17          IN      VARCHAR2,');
  l('      p_attrib_val18          IN      VARCHAR2,');
  l('      p_attrib_val19          IN      VARCHAR2,');
  l('      p_attrib_val20          IN      VARCHAR2,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_api_name              IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_parties_dynamic(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- Find the match rule');
  l('      null;');
  l('');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l_sql := 'declare x number; y number; begin HZ_MATCH_RULE_RULEID.call_api_dynamic(null,null,'||
       'null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'||
       'null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,'||
       'null,null,null,null,null,null,null,null,null,null,null,null,x,y); end;';


  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    IF check_proc(RULE.MATCH_RULE_ID) THEN

      l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
      l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
      l('        FND_MSG_PUB.ADD;');
      l('        RAISE FND_API.G_EXC_ERROR;');
      l('      END IF;');

      l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.call_api_dynamic(');
      l('        p_rule_id,');
      l('        p_attrib_id1,p_attrib_id2,p_attrib_id3,p_attrib_id4,p_attrib_id5,');
      l('        p_attrib_id6,p_attrib_id7,p_attrib_id8,p_attrib_id9,p_attrib_id10,');
      l('        p_attrib_id11,p_attrib_id12,p_attrib_id13,p_attrib_id14,p_attrib_id15,');
      l('        p_attrib_id16,p_attrib_id17,p_attrib_id18,p_attrib_id19,p_attrib_id20,');
      l('        p_attrib_val1,p_attrib_val2,p_attrib_val3,p_attrib_val4,p_attrib_val5,');
      l('        p_attrib_val6,p_attrib_val7,p_attrib_val8,p_attrib_val9,p_attrib_val10,');
      l('        p_attrib_val11,p_attrib_val12,p_attrib_val13,p_attrib_val14,p_attrib_val15,');
      l('        p_attrib_val16,p_attrib_val17,p_attrib_val18,p_attrib_val19,p_attrib_val20,');
      l('        p_restrict_sql,p_api_name,p_match_type,p_party_id,p_search_merged,x_search_ctx_id,x_num_matches);');
    ELSE
      l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
      l('      FND_MSG_PUB.ADD;');
      l('      RAISE FND_API.G_EXC_ERROR;');
    END IF;

  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'call_api_dynamic(-)');

  gen_exception_block;
  l('  END; ');

  gen_call_api_dynamic_names;

  -- Generate get_matching_party_sites code
  l('PROCEDURE get_matching_party_sites (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_list	     IN	     PARTY_SITE_LIST,');
  l('        p_contact_point_list    IN	     CONTACT_POINT_LIST,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  l_num_matches NUMBER;');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_party_sites-1(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('     get_matching_party_sites(p_init_msg_list,p_rule_id,p_party_id,');
  l('            p_party_site_list,p_contact_point_list,');
  l('            NULL,NULL,x_search_ctx_id,');
  l('            l_num_matches,x_return_status,x_msg_count,x_msg_data);');
  d(fnd_log.level_procedure,'get_matching_party_sites-1(-)');

  l('  END;');

  l('PROCEDURE get_matching_party_sites (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_list       IN      PARTY_SITE_LIST,');
  l('        p_contact_point_list    IN      CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_party_sites(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');


  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');
    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.get_matching_party_sites(');
    l('        p_rule_id, p_party_id,p_party_site_list, p_contact_point_list,');
    l('        p_restrict_sql, p_match_type,null,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'get_matching_party_sites(-)');

  gen_exception_block;
  l('  END;');
  l('');
  -- Generate get_matching_contacts code
  l('PROCEDURE get_matching_contacts (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_list          IN      CONTACT_LIST,');
  l('        p_contact_point_list    IN      CONTACT_POINT_LIST,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  l_num_matches NUMBER;');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_contacts-1(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('     get_matching_contacts(p_init_msg_list,p_rule_id,p_party_id,');
  l('            p_contact_list,p_contact_point_list,');
  l('            NULL,NULL,x_search_ctx_id,');
  l('            l_num_matches,x_return_status,x_msg_count,x_msg_data);');
  d(fnd_log.level_procedure,'get_matching_contacts-1(-)');

  l('  END;');

  l('PROCEDURE get_matching_contacts (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_list	     IN	     CONTACT_LIST,');
  l('        p_contact_point_list    IN	     CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_contacts(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');


  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');
    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.get_matching_contacts(');
    l('        p_rule_id, p_party_id,p_contact_list, p_contact_point_list,');
    l('        p_restrict_sql, p_match_type,null,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  gen_exception_block;
  d(fnd_log.level_procedure,'get_matching_contacts(-)');

  l('  END;');
  l('');
  -- Generate get_matching_contact_points code
  l('PROCEDURE get_matching_contact_points (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_point_list    IN	     CONTACT_POINT_LIST,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  l_num_matches NUMBER;');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_contact_points-1(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('     get_matching_contact_points(p_init_msg_list,p_rule_id,p_party_id,');
  l('            p_contact_point_list,');
  l('            NULL,NULL,x_search_ctx_id,');
  l('            l_num_matches,x_return_status,x_msg_count,x_msg_data);');
  d(fnd_log.level_procedure,'get_matching_contact_points-1(-)');

  l('  END;');
  l('PROCEDURE get_matching_contact_points (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_point_list    IN	     CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_contact_points(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');

    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.get_matching_contact_points(');
    l('        p_rule_id, p_party_id, p_contact_point_list,');
    l('        p_restrict_sql, p_match_type,null,x_search_ctx_id,x_num_matches);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'get_matching_contact_points(-)');

  gen_exception_block;
  l('  END;');
  l('');
  -- Generate get_party_score_details code
  l('PROCEDURE get_party_score_details (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_search_ctx_id         IN      NUMBER,');
  l('      p_party_search_rec      IN      party_search_rec_type,');
  l('      p_party_site_list       IN      party_site_list,');
  l('      p_contact_list          IN      contact_list,');
  l('      p_contact_point_list    IN      contact_point_list,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  l_search_ctx_id NUMBER;');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_party_score_details(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('     l_search_ctx_id:=p_search_ctx_id;');
  l('     get_score_details(p_init_msg_list,p_rule_id,p_party_id,');
  l('            p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,');
  l('            l_search_ctx_id,x_return_status,x_msg_count,x_msg_data);');
  d(fnd_log.level_procedure,'get_party_score_details(-)');

  l('  END;');

  l('PROCEDURE get_score_details (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_search_rec      IN      party_search_rec_type,');
  l('        p_party_site_list       IN      party_site_list,');
  l('        p_contact_list          IN      contact_list,');
  l('        p_contact_point_list    IN      contact_point_list,');
  l('        x_search_ctx_id         IN OUT  NUMBER,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_score_details(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');


  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');
    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.get_score_details(');
    l('        p_rule_id,');
    l('        p_party_id, p_party_search_rec,p_party_site_list,');
    l('        p_contact_list, p_contact_point_list,x_search_ctx_id);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'get_score_details(-)');

  gen_exception_block;
  l('  END;');
  l('PROCEDURE get_party_for_search (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        x_party_search_rec      OUT NOCOPY party_search_rec_type,');
  l('        x_party_site_list       OUT NOCOPY party_site_list,');
  l('        x_contact_list          OUT NOCOPY contact_list,');
  l('        x_contact_point_list    OUT NOCOPY contact_point_list,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_party_for_search(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');
    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.get_party_for_search(');
    l('        p_party_id, x_party_search_rec,x_party_site_list,');
    l('        x_contact_list, x_contact_point_list);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'get_party_for_search(-)');

  gen_exception_block;
  l('  END;');

  l('PROCEDURE get_search_criteria (');
  l('        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_ids        IN      IDList,');
  l('        p_contact_ids           IN      IDList,');
  l('        p_contact_pt_ids        IN      IDList,');
  l('        x_party_search_rec      OUT NOCOPY party_search_rec_type,');
  l('        x_party_site_list       OUT NOCOPY party_site_list,');
  l('        x_contact_list          OUT NOCOPY contact_list,');
  l('        x_contact_point_list    OUT NOCOPY contact_point_list,');
  l('        x_return_status         OUT     VARCHAR2,');
  l('        x_msg_count             OUT     NUMBER,');
  l('        x_msg_data              OUT     VARCHAR2');
  l(') IS');
  l('  CURSOR c_match_rule IS ');
  l('    SELECT COMPILATION_FLAG ');
  l('    FROM HZ_MATCH_RULES_VL ');
  l('    WHERE MATCH_RULE_ID = p_rule_id;');
  l('  l_cmp_flag VARCHAR2(1);');
  l('  BEGIN');

  d(fnd_log.level_procedure,'get_search_criteria(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id');

  l('');
  l('    -- Initialize return status and message stack');
  l('    x_return_status := FND_API.G_RET_STS_SUCCESS;');
  l('    IF FND_API.to_Boolean(p_init_msg_list) THEN');
  l('      FND_MSG_PUB.initialize;');
  l('    END IF;');
  l('');
  l('    IF p_rule_id IS NULL OR p_rule_id = 0 THEN');
  l('      -- No MATCH RULE FOUND');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  l('    OPEN c_match_rule;');
  l('    FETCH c_match_rule INTO l_cmp_flag;');
  l('    IF c_match_rule%NOTFOUND OR l_cmp_flag <> ''C'' THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');

  FIRST := TRUE;
  FOR RULE IN (SELECT MATCH_RULE_ID,RULE_NAME
               FROM HZ_MATCH_RULES_VL
               WHERE nvl(ACTIVE_FLAG,'Y')='Y'
               AND (nvl(COMPILATION_FLAG,'N') = 'C'
               OR MATCH_RULE_ID = p_rule_id)) LOOP
    l('    -- Code for Match rule '||RULE.RULE_NAME);
    IF FIRST THEN
      l('    IF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
      FIRST := FALSE;
    ELSE
      l('    ELSIF p_rule_id='||RULE.MATCH_RULE_ID||' THEN ');
    END IF;
    l('      IF NOT HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.check_staged THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_TX_NOT_STAGED'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');
    l('      HZ_MATCH_RULE_'||RULE.MATCH_RULE_ID||'.get_search_criteria(');
    l('        p_party_id, p_party_site_ids, p_contact_ids, p_contact_pt_ids, x_party_search_rec,x_party_site_list,');
    l('        x_contact_list, x_contact_point_list);');
  END LOOP;
  l('    END IF;');
  d(fnd_log.level_procedure,'get_search_criteria(-)');

  gen_exception_block;
  l('  END;');

  /*l('  PROCEDURE enable_debug IS');

  l('  BEGIN');
  l('    g_debug_count := g_debug_count + 1;');

  l('    IF g_debug_count = 1 THEN');
  l('      IF fnd_profile.value(''HZ_API_FILE_DEBUG_ON'') = ''Y'' OR');
  l('         fnd_profile.value(''HZ_API_DBMS_DEBUG_ON'') = ''Y''');
  l('      THEN');
  l('        hz_utility_v2pub.enable_debug;');
  l('        g_debug := TRUE;');
  l('      END IF;');
  l('    END IF;');
  d('PKG: HZ_PARTY_SEARCH (+)');
  l('  END enable_debug;');

  l('  PROCEDURE disable_debug IS');

  l('  BEGIN');

  l('    IF g_debug THEN');
  d('PKG: HZ_PARTY_SEARCH (-)');
  l('      g_debug_count := g_debug_count - 1;');

  l('      IF g_debug_count = 0 THEN');
  l('        hz_utility_v2pub.disable_debug;');
  l('        g_debug := FALSE;');
  l('      END IF;');
  l('    END IF;');

  l('  END disable_debug;');
  */

  l('END;');
  -- UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'C' WHERE  COMPILATION_FLAG = 'T';

END;

/** Procedure to create score function for party sites, contacts and contact points ***/
PROCEDURE add_score_function(p_entity VARCHAR2, p_rule_id NUMBER) IS
FIRST boolean := TRUE;
l_list VARCHAR2(255);

BEGIN
  l('  FUNCTION GET_'||p_entity||'_SCORE (');
  l('       x_matchidx OUT NUMBER');
  FIRST := TRUE;
  FOR TX IN (
      SELECT f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id
      AND a.entity_name= p_entity
      ORDER BY sa.attribute_id) LOOP
     l('      ,p_table_'||TX.STAGED_ATTRIBUTE_COLUMN||' VARCHAR2');
  END LOOP;
  l('  ) RETURN NUMBER IS');
  l('    maxscore NUMBER := 0;');
  l('    l_current_score NUMBER := 0;');
  l('  BEGIN');
  l('    x_matchidx := 0;');
  IF p_entity='PARTY_SITES' THEN
    l_list := 'g_party_site_stage_list';
  ELSIF p_entity='CONTACTS' THEN
    l_list := 'g_contact_stage_list';
  ELSIF p_entity='CONTACT_POINTS' THEN
    l_list := 'g_contact_pt_stage_list';
  END IF;
  l('    IF g_score_until_thresh AND (l_current_score)>=g_thres_score THEN');
  l('       RETURN l_current_score;');
  l('    END IF;');

  l('    FOR J IN 1..'||l_list||'.COUNT LOOP');
  l('      l_current_score := 0;');
  FOR SECATTRS IN (
        SELECT SECONDARY_ATTRIBUTE_ID, SCORE, ATTRIBUTE_NAME, ENTITY_NAME, a.attribute_id
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY s
        WHERE s.match_rule_id = p_rule_id
        AND s.attribute_id = a.attribute_id
        AND a.entity_name = p_entity ) LOOP
      FIRST := TRUE;
      FOR SECTRANS IN (
          SELECT TRANSFORMATION_NAME, STAGED_ATTRIBUTE_COLUMN, f.FUNCTION_ID,
                 TRANSFORMATION_WEIGHT, SIMILARITY_CUTOFF
          FROM HZ_SECONDARY_TRANS s,
               HZ_TRANS_FUNCTIONS_VL f
          WHERE s.SECONDARY_ATTRIBUTE_ID = SECATTRS.SECONDARY_ATTRIBUTE_ID
          AND s.FUNCTION_ID = f.FUNCTION_ID
          ORDER BY TRANSFORMATION_WEIGHT desc) LOOP
        IF FIRST THEN
           FIRST := FALSE;
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('      IF HZ_DQM_SEARCH_UTIL.is_similar_match('||l_list||'(J).'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||',(50000*(J-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
           ELSE
             l('      IF HZ_DQM_SEARCH_UTIL.is_match('||l_list||'(J).'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',(50000*(J-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
           END IF;
           l('        l_current_score:=l_current_score+ '||ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100))||';');
        ELSE
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('      ELSIF l_current_score<'|| ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100)) || ' AND ');
             l('          HZ_DQM_SEARCH_UTIL.is_similar_match('||l_list||'(J).'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||',(50000*(J-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
           ELSE
             l('      ELSIF -- l_current_score<'|| ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100)) || ' AND ');
             l('          HZ_DQM_SEARCH_UTIL.is_match('||l_list||'(J).'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',(50000*(J-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
           END IF;
           l('        l_current_score:=l_current_score+ '||ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100))||';');
        END IF;
        l('        IF g_score_until_thresh AND (l_current_score)>=g_thres_score THEN');
        l('          x_matchidx:=J;');
        l('          RETURN l_current_score;');
        l('        END IF;');
      END LOOP;
      l('      END IF;');
  END LOOP;
  l('      IF maxscore<l_current_score THEN');
  l('        maxscore:=l_current_score;');
  l('        x_matchidx:=J;');
  l('      END IF;');
  l('    END LOOP;');
  l('    RETURN maxscore;');
  l('  END;');
END;

/** Procedure to create score function for party sites, contacts and contact points ***/
PROCEDURE add_insert_function(p_entity VARCHAR2, p_rule_id NUMBER) IS
FIRST boolean := TRUE;
l_list VARCHAR2(255);

BEGIN
  l('  PROCEDURE INSERT_'||p_entity||'_SCORE (');
  l('       p_party_id IN  NUMBER');
  l('       ,p_record_id IN  NUMBER');
  l('       ,p_search_ctx_id IN  NUMBER');
  IF p_entity='PARTY' THEN
    l('       ,p_search_rec IN HZ_PARTY_SEARCH.party_search_rec_type');
    l('       ,p_stage_rec IN HZ_PARTY_STAGE.party_stage_rec_type');
  ELSIF p_entity='PARTY_SITES' THEN
    l('       ,p_search_rec IN HZ_PARTY_SEARCH.party_site_search_rec_type');
    l('       ,p_stage_rec IN HZ_PARTY_STAGE.party_site_stage_rec_type');
  ELSIF p_entity='CONTACTS' THEN
    l('       ,p_search_rec IN HZ_PARTY_SEARCH.contact_search_rec_type');
    l('       ,p_stage_rec IN HZ_PARTY_STAGE.contact_stage_rec_type');
  ELSIF p_entity='CONTACT_POINTS' THEN
    l('       ,p_search_rec IN HZ_PARTY_SEARCH.contact_point_search_rec_type');
    l('       ,p_stage_rec IN HZ_PARTY_STAGE.contact_pt_stage_rec_type');
  END IF;
  FIRST := TRUE;
  FOR TX IN (
      SELECT f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id
      AND a.entity_name= p_entity
      ORDER BY sa.attribute_id) LOOP
     l('      ,p_table_'||TX.STAGED_ATTRIBUTE_COLUMN||' VARCHAR2');
  END LOOP;
  l('        ,p_idx IN NUMBER) IS');
  l('    l_current_score NUMBER:=0;');
  l('    l_score NUMBER;');
  l('    l_attrib_value VARCHAR2(2000);');
  l('  BEGIN');
  ldbg_s('Inside Calling Procedure - INSERT_'||p_entity||'_SCORE');

  FOR SECATTRS IN (
        SELECT SECONDARY_ATTRIBUTE_ID, SCORE, ATTRIBUTE_NAME, ENTITY_NAME, a.attribute_id,
               USER_DEFINED_ATTRIBUTE_NAME
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY s
        WHERE s.match_rule_id = p_rule_id
        AND s.attribute_id = a.attribute_id
        AND a.entity_name = p_entity ) LOOP
      FIRST := TRUE;
      l('     l_score :=0;');
      FOR SECTRANS IN (
          SELECT TRANSFORMATION_NAME, STAGED_ATTRIBUTE_COLUMN, f.FUNCTION_ID,
                 TRANSFORMATION_WEIGHT, SIMILARITY_CUTOFF
          FROM HZ_SECONDARY_TRANS s,
               HZ_TRANS_FUNCTIONS_VL f
          WHERE s.SECONDARY_ATTRIBUTE_ID = SECATTRS.SECONDARY_ATTRIBUTE_ID
          AND s.FUNCTION_ID = f.FUNCTION_ID
          ORDER BY TRANSFORMATION_WEIGHT desc) LOOP
        IF FIRST THEN
           FIRST := FALSE;
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('      IF HZ_DQM_SEARCH_UTIL.is_similar_match(p_stage_rec.'||
               SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||',(50000*(p_idx-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
           ELSE
	       IF(l_purpose in('S','W') and SECATTRS.attribute_id=16) --6334571
		THEN
             l('      IF HZ_DQM_SEARCH_UTIL.is_match(case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||','||
			' case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then  p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim( p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||',(50000*(p_idx-1)+'||SECTRANS.FUNCTION_ID||')) THEN');

	       ELSE
	        l('      IF HZ_DQM_SEARCH_UTIL.is_match(p_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',(50000*(p_idx-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
	       END IF;
           END IF;
           l('      l_score :='||ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100))||';');
           ldbg_sv('l_score is - ','l_score'  ) ;
        ELSE
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('      ELSIF l_current_score<'|| ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100)) ||
               ' AND ');
             l('          HZ_DQM_SEARCH_UTIL.is_similar_match(p_stage_rec.'||
               SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||',(50000*(p_idx-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
           ELSE
	      IF(l_purpose in('S','W') and SECATTRS.attribute_id=16) --6334571
		THEN
		 l('      ELSIF l_current_score<'|| ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100)) || ' AND ');
                 l('          HZ_DQM_SEARCH_UTIL.is_match(case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||','||
			' case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then  p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim( p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||',(50000*(p_idx-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
		ELSE
             l('      ELSIF l_current_score<'|| ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100)) || ' AND ');
             l('          HZ_DQM_SEARCH_UTIL.is_match(p_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',(50000*(p_idx-1)+'||SECTRANS.FUNCTION_ID||')) THEN');
	       END IF;
           END IF;
           l('      l_score :='||ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100))||';');
           ldbg_sv('l_score is - ','l_score'  ) ;
        END IF;
      END LOOP;
      l('      END IF;');
      l('      IF l_score>0 THEN');
  ldbg_s('l_score > 0');
        l('      l_attrib_value := get_attrib_val(p_record_id,'''||SECATTRS.ENTITY_NAME||''','''||SECATTRS.ATTRIBUTE_NAME||''');');
  ldbg_s('Inserting into HZ_PARTY_SCORE_DTLS_GT ...');
        l('      INSERT INTO HZ_PARTY_SCORE_DTLS_GT (PARTY_ID, RECORD_ID, SEARCH_CONTEXT_ID,');
        l('                ATTRIBUTE,ENTITY,ENTERED_VALUE, MATCHED_VALUE, ASSIGNED_SCORE)');
        l('      VALUES (');
        l('           p_party_id,p_record_id,p_search_ctx_id,'''||
	              SECATTRS.ATTRIBUTE_NAME||''','); --Bug No: 3820598
                      --replace(SECATTRS.USER_DEFINED_ATTRIBUTE_NAME,'''','''''')||''','); --Bug No: 3820598
        l('           '''||SECATTRS.ENTITY_NAME||''', p_search_rec.'||SECATTRS.ATTRIBUTE_NAME||',');
        l('           l_attrib_value,l_score);');
        ldbg_s('Inserting into HZ_PARTY_SCORE_DTLS_GT ... Done');
      l('      END IF;');
  END LOOP;
  l('    NULL;');
  l('  END;');
END;

PROCEDURE add_get_attrib_func(p_rule_id NUMBER) IS
  Type charTab IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  entList charTab;
  entity VARCHAR2(255);

BEGIN

  l('  FUNCTION get_attrib_val(');
  l('      p_record_id 	NUMBER');
  l('     ,p_entity 	VARCHAR2');
  l('     ,p_attribute 	VARCHAR2');
  l('  ) RETURN VARCHAR2 IS');
  l('  l_matched_value VARCHAR2(2000);');
  l('  l_party_type VARCHAR2(255);');
  l('  BEGIN');

  entList(1) := 'PARTY';
  entList(2) := 'PARTY_SITES';
  entList(3) := 'CONTACTS';
  entList(4) := 'CONTACT_POINTS';
  FOR I IN 1..4 LOOP
    entity := entList(I);
    l('  IF p_entity = '''||entity||''' THEN');
    FOR SECATTRS IN (
        SELECT SECONDARY_ATTRIBUTE_ID, SCORE, ATTRIBUTE_NAME, ENTITY_NAME, a.attribute_id,
               USER_DEFINED_ATTRIBUTE_NAME, SOURCE_TABLE, CUSTOM_ATTRIBUTE_PROCEDURE
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY s
        WHERE s.match_rule_id = p_rule_id
        AND s.attribute_id = a.attribute_id
        AND a.entity_name = entity) LOOP
      l('  IF p_attribute = '''||SECATTRS.ATTRIBUTE_NAME||''' THEN');
      IF entity = 'PARTY' THEN
        l('');
        IF SECATTRS.SOURCE_TABLE <> 'CUSTOM' AND SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
          l('      SELECT party_type INTO l_party_type ');
          l('      FROM HZ_PARTIES');
          l('      WHERE party_id = p_record_id;');
          l('      IF l_party_type = ''ORGANIZATION'' THEN');
          l('        SELECT '||SECATTRS.ATTRIBUTE_NAME ||
          ' INTO l_matched_value ');
          IF SECATTRS.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' or
             SECATTRS.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES' or
             SECATTRS.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES' THEN
            l('        FROM HZ_ORGANIZATION_PROFILES');
            l('        WHERE party_id = p_record_id ');
            l('        and effective_end_date is null');
          ELSE
            l('        FROM '||SECATTRS.SOURCE_TABLE);
            l('        WHERE party_id = p_record_id ');
          END IF;
          l('        and rownum = 1;');

          l('      ELSIF l_party_type = ''PERSON'' THEN');
          l('        SELECT '||SECATTRS.ATTRIBUTE_NAME ||
          ' INTO l_matched_value ');
          IF SECATTRS.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' or
             SECATTRS.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES' or
             SECATTRS.SOURCE_TABLE = 'HZ_PERSON_PROFILES' THEN
            l('        FROM HZ_PERSON_PROFILES');
            l('        WHERE party_id = p_record_id ');
            l('        and effective_end_date is null ');
          ELSE
            l('        FROM '||SECATTRS.SOURCE_TABLE);
            l('        WHERE party_id = p_record_id ');
          END IF;
          l('        and rownum = 1;');
          l('      END IF;');
        ELSE
          l('     l_matched_value := '||SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE ||
            ' (p_record_id, p_entity,'''||SECATTRS.ATTRIBUTE_NAME||''',''Y'');');
        END IF;
        l('      RETURN l_matched_value;');
     ELSIF entity = 'PARTY_SITES' THEN
       IF SECATTRS.SOURCE_TABLE <> 'CUSTOM' AND SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
          l('     BEGIN');
          l('       SELECT '|| SECATTRS.SOURCE_TABLE||'.'||
                    SECATTRS.ATTRIBUTE_NAME);
          l('       INTO l_matched_value ');
          l('       FROM HZ_PARTY_SITES, HZ_LOCATIONS');
          l('       WHERE HZ_PARTY_SITES.party_site_id = p_record_id');
          l('       AND HZ_PARTY_SITES.location_id = HZ_LOCATIONS.location_id and rownum=1;');
          l('     EXCEPTION');
          l('       WHEN NO_DATA_FOUND THEN');
          l('         l_matched_value := ''Err'';');
          l('     END;');
       ELSE
          l('     l_matched_value := '||SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE ||
            ' (p_record_id, p_entity,'''||SECATTRS.ATTRIBUTE_NAME||''',''Y'');');
       END IF;
       l('      RETURN l_matched_value;');
     ELSIF entity = 'CONTACTS' THEN
       IF SECATTRS.SOURCE_TABLE <> 'CUSTOM' AND SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
          l('     BEGIN');
          l('       SELECT '|| SECATTRS.SOURCE_TABLE||'.'||
                  SECATTRS.ATTRIBUTE_NAME);
          l('       INTO l_matched_value ');
          l('       FROM HZ_ORG_CONTACTS, HZ_RELATIONSHIPS, HZ_PERSON_PROFILES');
          l('       WHERE HZ_ORG_CONTACTS.org_contact_id = p_record_id');
          l('       AND HZ_RELATIONSHIPS.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
          l('       AND HZ_RELATIONSHIPS.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
          l('       AND HZ_RELATIONSHIPS.DIRECTIONAL_FLAG = ''F''');
          l('       AND HZ_ORG_CONTACTS.party_relationship_id = HZ_RELATIONSHIPS.relationship_id');
          l('       AND HZ_RELATIONSHIPS.subject_id = HZ_PERSON_PROFILES.party_id');
          l('       AND HZ_PERSON_PROFILES.effective_end_date IS NULL and rownum=1;');
          l('     EXCEPTION');
          l('       WHEN NO_DATA_FOUND THEN');
          l('         l_matched_value := ''Err'';');
          l('     END;');
       ELSE
          l('     l_matched_value := '||SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE ||
            ' (p_record_id, p_entity,'''||SECATTRS.ATTRIBUTE_NAME||''',''Y'');');
       END IF;
       l('      RETURN l_matched_value;');
     ELSIF entity = 'CONTACT_POINTS' THEN
       IF SECATTRS.SOURCE_TABLE <> 'CUSTOM' AND SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL THEN
          l('     BEGIN');
          l('       SELECT ' || SECATTRS.ATTRIBUTE_NAME || ' INTO l_matched_value ');
          l('       FROM HZ_CONTACT_POINTS ');
          l('       WHERE contact_point_id = p_record_id and rownum=1;');
          l('     EXCEPTION');
          l('       WHEN NO_DATA_FOUND THEN');
          l('         l_matched_value := ''Err'';');
          l('     END;');
       ELSE
          l('     l_matched_value := '||SECATTRS.CUSTOM_ATTRIBUTE_PROCEDURE ||
            ' (p_record_id, p_entity,'''||SECATTRS.ATTRIBUTE_NAME||''',''Y'');');
       END IF;
       l('      RETURN l_matched_value;');
     END IF;
     l('    END IF;');
   END LOOP;
   l('    NULL;');
   l('  END IF;');
 END LOOP;
 l('END;');
END;


PROCEDURE add_query_gen_func (p_entity VARCHAR2, p_rule_id NUMBER) IS

  l_num_primary NUMBER;
  l_list VARCHAR2(255);
  l_trans VARCHAR2(4000);
  l_query VARCHAR2(4000);
  FIRST BOOLEAN := TRUE;
  FIRST1 BOOLEAN := TRUE;
  l_den_section VARCHAR2(30) := null;
  tmp VARCHAR2(30);

BEGIN
  l('  FUNCTION INIT_'||p_entity||'_QUERY(p_match_str VARCHAR2, x_denorm_str OUT VARCHAR2) RETURN VARCHAR2 IS');
  l('    l_contains_str VARCHAR2(32000); ');
  l('    l_contains_str_temp VARCHAR2(32000); ');
  l('    l_den_contains_str VARCHAR2(32000); ');
  l('    l_den_contains_str_temp VARCHAR2(32000); ');
  l('    l_filter_str VARCHAR2(4000) := null;');
  l('    l_prim_temp VARCHAR2(4000) := null;');
  l('    l_prim_temp_den VARCHAR2(4000) := null;');
  if l_purpose in('S','W') and p_entity='CONTACT_POINTS' then
    l('    TYPE CONTACT_PT_REC_TYPE IS RECORD (');
    l('    contact_pt_type		VARCHAR2(100)) ;');

    l('    TYPE contact_pt_list IS TABLE of CONTACT_PT_REC_TYPE INDEX BY BINARY_INTEGER;');
    l('    l_cnt_pt_type contact_pt_list;');

    l('    N NUMBER:=1;');
    l('    x_modify VARCHAR2(1);');
  end if;
  l('  BEGIN');
  d(fnd_log.level_procedure,'INIT_'||p_entity||'_QUERY ');
  l('    x_denorm_str := NULL;');

  -- Setup of contains str
  l_num_primary := 0;
  SELECT count(1) INTO l_num_primary
  FROM HZ_MATCH_RULE_PRIMARY p,
       HZ_TRANS_ATTRIBUTES_VL a
  WHERE p.match_rule_id = p_rule_id
  AND   p.ATTRIBUTE_ID = a.ATTRIBUTE_ID
  AND   ENTITY_NAME = p_entity;

  IF p_entity='PARTY_SITES' THEN
    l_list := 'g_party_site_stage_list';
    l_den_section := 'D_PS';
  ELSIF p_entity='CONTACTS' THEN
    l_list := 'g_contact_stage_list';
    l_den_section := 'D_CT';
  ELSIF p_entity='CONTACT_POINTS' THEN
    l_list := 'g_contact_pt_stage_list';
    l_den_section := 'D_CPT';
  END IF;

  l_query := null;
  IF l_num_primary >0 THEN
    l('');
    l('    -- Dynamic setup of party site contains str');
    l('    --');
    l('    -- For each primary transformation add to intermedia query if it ');
    l('    -- is not null');
    l('    FOR I IN 1..'||l_list||'.COUNT LOOP');
    l('      l_contains_str_temp := null;');
    l('      l_den_contains_str_temp := null;');
    l('      l_filter_str := null;');
    IF p_entity = 'CONTACT_POINTS' THEN
      l('      l_filter_str := ''(''||'||l_list||'(I).CONTACT_POINT_TYPE||'') '';');
    END IF;

    if l_purpose in('S','W') and p_entity='CONTACT_POINTS' then
        l('      if(l_cnt_pt_type.count>0) then');
        l('      x_modify := ''Y'';');
       l('      FOR J IN 1..l_cnt_pt_type.COUNT LOOP');
        l('      IF (l_cnt_pt_type(J).contact_pt_type=g_contact_pt_stage_list(I).CONTACT_POINT_TYPE) THEN');
         l('      x_modify := ''N'';');
        l('      END IF;');
       l('      END LOOP;');
       l('      if x_modify = ''Y'' then');
        l('      l_cnt_pt_type(N).contact_pt_type := g_contact_pt_stage_list(I).CONTACT_POINT_TYPE;');
        l('      N := N+1;');
       l('      end if;');
      l('      else');
        l('      l_cnt_pt_type(N).contact_pt_type := g_contact_pt_stage_list(I).CONTACT_POINT_TYPE;');
        l('      N := N+1;');
      l('      end if;');
    end if;

    FIRST := TRUE;
    FOR PRIMATTRS IN (
      SELECT a.ATTRIBUTE_ID, PRIMARY_ATTRIBUTE_ID, ATTRIBUTE_NAME,nvl(FILTER_FLAG,'N') FILTER_FLAG,
             nvl(DENORM_FLAG,'N') DENORM_FLAG
      FROM HZ_TRANS_ATTRIBUTES_VL a,
           HZ_MATCH_RULE_PRIMARY p
      WHERE p.match_rule_id = p_rule_id
      AND p.attribute_id = a.attribute_id
      AND a.ENTITY_NAME = p_entity) LOOP
      l('');
      l('      -- Setup query string for '||PRIMATTRS.ATTRIBUTE_NAME);
      l('      l_prim_temp := null;');
      l('      l_prim_temp_den := null;');
      FIRST1 := TRUE;
      FOR PRIMTRANS IN (
        SELECT f.STAGED_ATTRIBUTE_COLUMN, f.TRANSFORMATION_NAME, nvl(f.PRIMARY_FLAG,'N') PRIMARY_FLAG
        FROM HZ_TRANS_FUNCTIONS_VL f,
           HZ_PRIMARY_TRANS pt
      WHERE pt.PRIMARY_ATTRIBUTE_ID = PRIMATTRS.PRIMARY_ATTRIBUTE_ID
      AND pt.FUNCTION_ID = f.FUNCTION_ID) LOOP
        IF PRIMATTRS.FILTER_FLAG <> 'Y' THEN

          IF PRIMTRANS.PRIMARY_FLAG = 'Y' THEN
            tmp := '''A'||PRIMATTRS.ATTRIBUTE_ID||'''';
          ELSE
            tmp := 'NULL';
          END IF;

          l('      HZ_DQM_SEARCH_UTIL.add_transformation( -- ' || PRIMTRANS.TRANSFORMATION_NAME);
          l('            '||l_list||'(I).'||
            PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||
            ','||tmp||',l_prim_temp);');
          IF PRIMATTRS.DENORM_FLAG = 'Y' THEN
            l('      HZ_DQM_SEARCH_UTIL.add_transformation( -- ' || PRIMTRANS.TRANSFORMATION_NAME);
            l('            '||l_list||'(I).'||
              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||
              ','''||l_den_section||''',l_prim_temp_den);');
          END IF;
        ELSE
          l('      HZ_DQM_SEARCH_UTIL.add_filter( -- ' || PRIMTRANS.TRANSFORMATION_NAME);
          l('             '||l_list||'(I).'||
            PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||
            ',''A'||PRIMATTRS.ATTRIBUTE_ID||''',l_filter_str);');
        END IF;
        IF FIRST1 THEN
          l_trans := '('||l_list||'(1).'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NULL OR '' '' || '||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' '' like ''% ''||'||l_list||'(1).'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' %'')';
          FIRST1 := FALSE;
        ELSE
          l_trans := l_trans|| ' OR ('|| l_list||'(1).'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NULL OR '' '' ||'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' '' like ''% ''||'||l_list||'(1).'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' %'')';
        END IF;
      END LOOP;
/*
      IF FIRST THEN
        l_query := '('||l_trans||')';
        FIRST := FALSE;
      ELSE
        l_query := l_query || ' AND (' || l_trans||')';
      END IF;
*/
      IF PRIMATTRS.FILTER_FLAG <> 'Y' THEN
        IF PRIMATTRS.DENORM_FLAG = 'Y' THEN
          l('      HZ_DQM_SEARCH_UTIL.add_attribute(l_prim_temp_den, '' AND '', l_den_contains_str_temp);');
        END IF;
        l('      HZ_DQM_SEARCH_UTIL.add_attribute(l_prim_temp, '' AND '', l_contains_str_temp);');
      END IF;
    END LOOP;

    IF p_entity='PARTY_SITES' THEN
      g_party_site_query := l_query;
    ELSIF p_entity='CONTACTS' THEN
      g_contact_query := l_query;
    ELSIF p_entity='CONTACT_POINTS' THEN
      g_cpt_query := l_query;
    END IF;
    l('');
    l('      HZ_DQM_SEARCH_UTIL.add_search_record(l_contains_str_temp, '||
      ' 	 l_filter_str, l_contains_str);');
    l('      HZ_DQM_SEARCH_UTIL.add_search_record(l_den_contains_str_temp, '||
      ' 	 null, l_den_contains_str);');
    if l_purpose in('S','W') and p_entity='CONTACT_POINTS' then
     	l('IF N>1 THEN ');
     	l(' distinct_search_cpt_types := N-1;');
     	l('ELSE');
        l(' distinct_search_cpt_types := N;');
		l('END IF;');
      ldbg_sv('distinct_search_cpt_types is - ','distinct_search_cpt_types'  ) ;
    end if;

    l('    END LOOP;');
    l('    -- Add the search criteria to query string');
    l('    IF lengthb(l_contains_str) > 4000 THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_SEARCH_CRIT_LARGE_ERROR'');');
    l('        FND_MESSAGE.SET_TOKEN(''ENTITY'','''||p_entity||''');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('    END IF;');
    l('    x_denorm_str := l_den_contains_str;');
    l('    RETURN l_contains_str;');
    l('  END;');
    l('');
  ELSE
    l('    RETURN NULL;');
    l('  END;');
    l('');
  END IF;
END;

PROCEDURE get_column_list (
	p_rule_id	IN	NUMBER,
 	p_entity	IN	VARCHAR2,
	x_select_list	OUT NOCOPY	VARCHAR2,
	x_param_list	OUT NOCOPY	VARCHAR2,
	x_into_list	OUT NOCOPY	VARCHAR2) IS

FIRST BOOLEAN;
BEGIN
  x_select_list := '';
  x_into_list := '';
  x_param_list := '';

  FIRST := TRUE;
  FOR TX IN (
      SELECT f.staged_attribute_column, a.attribute_name, f.procedure_name
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id
      AND a.entity_name= p_entity
      ORDER BY sa.attribute_id) LOOP
     --- Modified for Bug 4016594
     IF TX.ATTRIBUTE_NAME = 'DUNS_NUMBER_C' AND upper(TX.PROCEDURE_NAME) = 'HZ_TRANS_PKG.EXACT' THEN
       x_select_list := x_select_list || ', lpad(rtrim('||TX.STAGED_ATTRIBUTE_COLUMN||'),9,chr('||ascii('0')||'))';
     ELSE
       x_select_list := x_select_list || ', '||TX.STAGED_ATTRIBUTE_COLUMN;
     END IF;

     x_into_list := x_into_list || ', '||'l_'||TX.STAGED_ATTRIBUTE_COLUMN;
     IF FIRST AND p_entity = 'PARTY' THEN
       x_param_list := 'l_'||TX.STAGED_ATTRIBUTE_COLUMN;
       FIRST := FALSE;
     ELSE
       x_param_list := x_param_list||',l_'||TX.STAGED_ATTRIBUTE_COLUMN;
     END IF;
  END LOOP;
  RETURN;
END;

/**
* Private procedure to generate the body of the Public Match Rule API
* for a match rule. Package Name is:
*    HZ_MATCH_RULE_<p_rule_id>
*
* This procedure generates the code required to execute searches
*
**/
PROCEDURE gen_pkg_body (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id	IN	NUMBER
) IS

  -- Local Variables
  FIRST boolean;
  FIRST1 boolean;
  UPSTMT boolean;
  l_match_str VARCHAR2(255);
  l_attrib_cnt NUMBER;
  l_party_filter VARCHAR2(1) := null;
  l_ps_filter VARCHAR2(1) := null;
  l_contact_filter VARCHAR2(1) := null;
  l_cpt_filter VARCHAR2(1) := null;
  l_num_primary NUMBER;
  l_num_secondary NUMBER;
  l_ent VARCHAR2(30);
  l_max_score NUMBER;
  l_match_threshold NUMBER;

  TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE CharList IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  attribList NumberList;

  l_party_filter_str VARCHAR2(2000);
  l_dyn_party_filter_str VARCHAR2(2000);
  l_p_select_list VARCHAR2(1000);
  l_p_param_list VARCHAR2(1000);
  l_p_into_list VARCHAR2(1000);
  l_ps_select_list VARCHAR2(1000);
  l_ps_param_list VARCHAR2(1000);
  l_ps_into_list VARCHAR2(1000);
  l_c_select_list VARCHAR2(1000);
  l_c_param_list VARCHAR2(1000);
  l_c_into_list VARCHAR2(1000);
  l_cpt_select_list VARCHAR2(1000);
  l_cpt_param_list VARCHAR2(1000);
  l_cpt_into_list VARCHAR2(1000);
  cnt NUMBER;
  l_party_filt_bind CharList;
  party_binds CharList;
  l_cpt_type VARCHAR2(255);
  l_trans VARCHAR2(4000);
  l_auto_merge_score NUMBER;
  tmp VARCHAR2(30);
  l_party_name_score VARCHAR2(255);
  l_party_level_cnt NUMBER;
  l_rule_type VARCHAR2(30); ---Code Change for Match Rule Set

  l_entity_score_lh VARCHAR2(4000); --Bug No: 4162385
  l_entity_score_rh VARCHAR2(4000); --Bug No: 4162385

BEGIN

  -- Query match thresholds and search type
  SELECT RULE_PURPOSE, MATCH_SCORE, nvl(AUTO_MERGE_SCORE,99999), decode(MATCH_ALL_FLAG,'Y',' AND ',' OR '),
  NVL(match_rule_type,'SINGLE') ---Code Change for Match Rule Set
  INTO l_purpose, l_match_threshold, l_auto_merge_score, l_match_str,l_rule_type---Code Change for Match Rule Set
  FROM HZ_MATCH_RULES_VL
  WHERE match_rule_id = p_rule_id;

  SELECT nvl(SUM(SCORE),1) INTO l_max_score
  FROM HZ_MATCH_RULE_SECONDARY
  WHERE match_rule_id = p_rule_id;

  --bug 5878732
  IF  l_purpose in ('S','W') AND Nvl(l_match_threshold,0)<>0 THEN
  l_match_threshold:= ROUND((l_match_threshold/100) *  l_max_score);
  END IF;

  l('CREATE or REPLACE PACKAGE BODY ' || p_pkg_name || ' AS');
  l('/*=======================================================================+');
  l(' |  Copyright (c) 1999 Oracle Corporation Redwood Shores, California, USA|');
  l(' |                          All rights reserved.                         |');
  l(' +=======================================================================+');
  l(' | NAME');
  l(' |      ' || p_pkg_name);
  l(' |');
  l(' | DESCRIPTION');
  l(' |');
  l(' | Compiled by the HZ Match Rule Compiler');
  l(' | -- Do Not Modify --');
  l(' |');
  l(' | PUBLIC PROCEDURES');
  l(' |    find_parties');
  l(' |    get_matching_party_sites');
  l(' |    get_matching_contacts');
  l(' |    get_matching_contact_points');
  l(' |    get_score_details');
  l(' |    ');
  l(' | HISTORY');
  l(' |      '||TO_CHAR(SYSDATE,'DD-MON-YYYY') || ' Generated by HZ Match Rule Compiler');
  l(' |');
  l(' *=======================================================================*/');

  IF l_purpose = 'S'
  THEN
      l('');
      l('-- ==========================================================================================');
      l('-- ============MATCH RULE COMPILER GENERATED CODE FOR SEARCH MATCH RULES ====================');
      l('-- ==========================================================================================');
      l('');
  ELSIF l_purpose = 'D'
  THEN
      l('');
      l('-- ==========================================================================================');
      l('-- ============MATCH RULE COMPILER GENERATED CODE FOR DUP IDENTIFICATION MATCH RULES ========');
      l('-- ==========================================================================================');
      l('');
   ELSIF l_purpose = 'W'
  THEN
      l('');
      l('-- ==========================================================================================');
      l('-- ============MATCH RULE COMPILER GENERATED CODE FOR WEB SERVICE  MATCH RULES ========');
      l('-- ==========================================================================================');
      l('');
  END IF;

  l('  TYPE vlisttype IS TABLE of VARCHAR2(255) INDEX BY BINARY_INTEGER ;');
  l('  call_order vlisttype;');
  l('  call_max_score HZ_PARTY_SEARCH.IDList;');
  l('  call_type vlisttype;');
  l('  g_party_stage_rec  HZ_PARTY_STAGE.party_stage_rec_type;');
  l('  g_party_site_stage_list  HZ_PARTY_STAGE.party_site_stage_list;');
  l('  g_contact_stage_list  HZ_PARTY_STAGE.contact_stage_list;');
  l('  g_contact_pt_stage_list  HZ_PARTY_STAGE.contact_pt_stage_list;');
  l('  g_mappings  HZ_PARTY_SEARCH.IDList;');
  l('  g_max_id NUMBER:=2000000000;');
  l('  g_other_party_level_attribs BOOLEAN;');
  l('');
  l('  g_debug_count                        NUMBER := 0;');
  --l('  g_debug                              BOOLEAN := FALSE;');
  l('  g_score_until_thresh BOOLEAN:=false;');
  l(' ');
  l('  g_thres_score NUMBER:=1000;');
  l('  g_ps_den_only BOOLEAN;');
  l('  g_index_owner VARCHAR2(255);');
  l('  distinct_search_cpt_types NUMBER ; ');
  --l('  PROCEDURE enable_debug;');
  --l('  PROCEDURE disable_debug;');


  IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
	ldbg_procedure;
  l('FUNCTION check_estimate_hits (');
  l('  p_entity VARCHAR2,');
  l('  p_contains_str VARCHAR2) RETURN NUMBER IS');
  l('  ');
  l('  ustatus VARCHAR2(255);');
  l('  dstatus VARCHAR2(255);');
  l('  l_bool BOOLEAN;');
  l('  l_hits NUMBER := 0;'); --Bug No: 6048573
  l('BEGIN');
  l('  IF g_index_owner IS NULL THEN');
  l('    l_bool := fnd_installation.GET_APP_INFO(''AR'',ustatus,dstatus,g_index_owner);');
  l('  END IF;');
  l('  IF p_entity=''PARTY'' THEN');
  l('');
  l('    l_hits :=  CTX_QUERY.count_hits(');
  l('        g_index_owner||''.''||''HZ_STAGE_PARTIES_T1'',p_contains_str, false);');
  l('  ELSIF p_entity=''PARTY_SITES'' THEN');
  l('    l_hits :=  CTX_QUERY.count_hits(');
  l('        g_index_owner||''.''||''HZ_STAGE_PARTY_SITES_T1'',p_contains_str, false);');
  l('  ELSIF p_entity=''CONTACTS'' THEN');
  l('    l_hits :=  CTX_QUERY.count_hits(');
  l('        g_index_owner||''.''||''HZ_STAGE_CONTACT_T1'',p_contains_str, false);');
  l('  ELSIF p_entity=''CONTACT_POINTS'' THEN');
  l('    l_hits :=  CTX_QUERY.count_hits(');
  l('        g_index_owner||''.''||''HZ_STAGE_CPT_T1'',p_contains_str, false);');
  l('  END IF;');
  l('  RETURN floor(l_hits/2) ;'); --Bug No: 6048573
  l('  ');
  l('');
--bug 4959719 start
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
   --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
--bug 4959719 end
  l('END;');

  -- VJN Introduced function for Bug 3979089
  l('');
  l('');
  l('FUNCTION get_adjusted_restrict_sql (p_restrict_sql VARCHAR2)');
  l('RETURN VARCHAR2');
  l('IS');
  l('p_person_restrict_sql VARCHAR2(32767);');
  l('p_restrict1_sql VARCHAR2(32767);');
  l('p_final_restrict_sql VARCHAR2(32767);');
  l('BEGIN');
  l('   p_final_restrict_sql := p_restrict_sql ; ');
  l('   IF p_restrict_sql IS NOT NULL');
  l('   THEN');
  l('     IF instrb(p_restrict_sql, ''STAGE.'') > 0');
  l('     THEN');
  l('        p_restrict1_sql := replace( p_restrict_sql, ''STAGE.'', ''stage1.'');');
  l('     ELSIF instrb(p_restrict_sql, ''stage.'') > 0');
  l('     THEN');
  l('           p_restrict1_sql := replace( p_restrict_sql, ''stage.'', ''stage1.'');');
  l('     END IF;');

  l('    p_person_restrict_sql := ''exists ( SELECT 1 from HZ_ORG_CONTACTS oc, hz_relationships r'' ');
  l('                               ||' || ' '' where oc.org_contact_id = stage.org_contact_id and'' ');
  l('                               ||' || ' '' r.relationship_id = oc.party_relationship_id'' ');
  l('                               ||' || ' '' and r.subject_type = ''''PERSON'''' AND r.object_type = ''''ORGANIZATION'''' '' ');
  l('                               ||' || ' '' and exists ( SELECT 1 FROM HZ_PARTIES stage1 where stage1.party_id = r.subject_id'' ');
  l('                               ||' || ' '' and '' || p_restrict1_sql || '' ) )'' ; ');

  l('p_final_restrict_sql := ''((stage.org_contact_id is null and '' || p_restrict_sql || '') or (stage.org_contact_id is not null and '' ');
  l('                           || p_person_restrict_sql ||  '' ))''; ');
  l(' END IF;');
  l(' return p_final_restrict_sql ;');
  l('END;');

  /***********************************************************************
  * Private procedure to map IDs greater than the max allowed by PLSQL
  * Index-by tables.
  ************************************************************************/
  l('  FUNCTION map_id (in_id NUMBER) RETURN NUMBER IS');
  l('    l_newidx NUMBER;');
  l('  BEGIN ');
  ldbg_s('-----------------','calling the function map_id');
  ldbg_sv('argument in_id = ', 'in_id');

  l('    IF in_id<g_max_id THEN ');
  l('      RETURN in_id;');
  l('    ELSE');
  l('      FOR I in 1..g_mappings.COUNT LOOP');
  l('        IF in_id = g_mappings(I) THEN');
  l('          RETURN (g_max_id+I);');
  l('        END IF;');
  l('      END LOOP;');
  l('      l_newidx := g_mappings.COUNT+1;');
  l('      g_mappings(l_newidx) := in_id;');
  l('      RETURN (g_max_id+l_newidx);');
  l('    END IF;');
  l('  END;');

  l('  FUNCTION GET_PARTY_SCORE ');
  FIRST := TRUE;
  FOR TX IN (
      SELECT f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id
      AND a.entity_name= 'PARTY'
      ORDER BY sa.attribute_id) LOOP
     IF FIRST THEN
       l('       (');
       l('       p_table_'||TX.staged_attribute_column||' VARCHAR2');
       FIRST := FALSE;
     ELSE
       l('      ,p_table_'||TX.staged_attribute_column||' VARCHAR2');
     END IF;
  END LOOP;
  IF FIRST THEN
    l('   RETURN NUMBER IS');
  ELSE
    l('  ) RETURN NUMBER IS');
  END IF;
  l('    total NUMBER := 0;');
  l('  BEGIN');
  ldbg_s('-----------------','calling the function get_party_score');
  d(fnd_log.level_procedure,'GET_PARTY_SCORE  ');
  l('    IF g_score_until_thresh AND (total)>=g_thres_score THEN');
  ldbg_sv('get_party_score returned total = ', 'total');
  l('      RETURN total;');
  l('    END IF;');
  FOR SECATTRS IN (
        SELECT SECONDARY_ATTRIBUTE_ID, SCORE, ATTRIBUTE_NAME, ENTITY_NAME, a.attribute_id
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY s
        WHERE s.match_rule_id = p_rule_id
        AND s.attribute_id = a.attribute_id
        AND a.entity_name = 'PARTY') LOOP
      FIRST := TRUE;
      FOR SECTRANS IN (
          SELECT TRANSFORMATION_NAME, STAGED_ATTRIBUTE_COLUMN, f.FUNCTION_ID,
                 TRANSFORMATION_WEIGHT, SIMILARITY_CUTOFF
          FROM HZ_SECONDARY_TRANS s,
               HZ_TRANS_FUNCTIONS_VL f
          WHERE s.SECONDARY_ATTRIBUTE_ID = SECATTRS.SECONDARY_ATTRIBUTE_ID
          AND s.FUNCTION_ID = f.FUNCTION_ID
          ORDER BY TRANSFORMATION_WEIGHT desc) LOOP
        IF FIRST THEN
           FIRST := FALSE;
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('    IF HZ_DQM_SEARCH_UTIL.is_similar_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||','||SECTRANS.FUNCTION_ID||') THEN');
           ELSE
		IF(l_purpose IN ('S','W') and SECATTRS.attribute_id=16) --6334571
		THEN
                        l('    IF HZ_DQM_SEARCH_UTIL.is_match(case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||','||
			' case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then  p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim( p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||','||SECTRANS.FUNCTION_ID||') THEN');


         	ELSE
             l('    IF HZ_DQM_SEARCH_UTIL.is_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||','||SECTRANS.FUNCTION_ID||') THEN');
	       END IF;
           END IF;
        ELSE
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('    ELSIF HZ_DQM_SEARCH_UTIL.is_similar_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||','||SECTRANS.FUNCTION_ID||') THEN');
           ELSE
	   		IF(l_purpose IN ('S','W') and SECATTRS.attribute_id=16) --6334571
			THEN

			l('    ELSIF HZ_DQM_SEARCH_UTIL.is_match(case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||','||
			' case(instr(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',''%'')) when 0 then  p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
			' else ltrim( p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||',chr(48)) END'||','||SECTRANS.FUNCTION_ID||') THEN');

			ELSE

             l('    ELSIF HZ_DQM_SEARCH_UTIL.is_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||','||SECTRANS.FUNCTION_ID||') THEN');
		       END IF;
           END IF;
        END IF;
        l('      total := total+'||ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100))||';');
        l('      IF g_score_until_thresh AND (total)>=g_thres_score THEN ');
	ldbg_sv('get_party_score returned total = ', 'total');
        l('        RETURN total;');
        l('      END IF;');
      END LOOP;
      l('    END IF;');
  END LOOP;
  l('    RETURN total;');
  l('  END;');

  add_score_function('PARTY_SITES',p_rule_id);
  add_score_function('CONTACTS',p_rule_id);
  add_score_function('CONTACT_POINTS',p_rule_id);
  add_get_attrib_func(p_rule_id);
  add_insert_function('PARTY',p_rule_id);
  add_insert_function('PARTY_SITES',p_rule_id);
  add_insert_function('CONTACTS',p_rule_id);
  add_insert_function('CONTACT_POINTS',p_rule_id);

  --- VJN Introduced for conditional Word Replacements
  --- Populate the global condition record before doing the mapping
  --- so that mapping takes into account conditional word replacements if any
  generate_ent_cond_pop_rec_proc('PARTY', p_rule_id);
  l('');
  generate_ent_cond_pop_rec_proc('PARTY_SITES', p_rule_id);
  l('');
  generate_ent_cond_pop_rec_proc('CONTACTS', p_rule_id);
  l('');
  generate_ent_cond_pop_rec_proc('CONTACT_POINTS', p_rule_id);
  l('');


  l('  PROCEDURE init_score_context (');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list:= ');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_POINT_LIST');
  l('  ) IS');
  l('   l_dummy NUMBER;');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure init_score_context');
  ldbg_s('In init_score_context calling the Map procedures');
  l('    -- Transform search criteria');
  l('    HZ_TRANS_PKG.clear_globals;');
  l('    MAP_PARTY_REC(FALSE,p_party_search_rec, l_dummy, g_party_stage_rec);');
  l('    MAP_PARTY_SITE_REC(FALSE,p_party_site_list, l_dummy, g_party_site_stage_list);');
  l('    MAP_CONTACT_REC(FALSE,p_contact_list, l_dummy, g_contact_stage_list);');
  l('    MAP_CONTACT_POINT_REC(FALSE,p_contact_point_list, l_dummy, g_contact_pt_stage_list);');
  l('');
  l('  END;');


  l('  FUNCTION init_search(');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list:= ');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_POINT_LIST,');
  l('      p_match_type            IN  VARCHAR2,');
  l('      x_party_max_score       OUT NUMBER,');
  l('      x_ps_max_score       OUT NUMBER,');
  l('      x_contact_max_score       OUT NUMBER,');
  l('      x_cpt_max_score       OUT NUMBER');
  l('  ) RETURN NUMBER IS ');
  l('  l_entered_max_score NUMBER:=0;');
  l('  l_ps_entered_max_score NUMBER:=0;');
  l('  l_ct_entered_max_score NUMBER:=0;');
  l('  l_cpt_entered_max_score NUMBER:=0;');
  l('  vlist vlisttype;');
  l('  maxscore HZ_PARTY_SEARCH.IDList;');
  l('  l_name VARCHAR2(200);');
  l('  l_idx NUMBER; ');
  l('  l_num NUMBER; ');
  l('  total NUMBER; ');
  l('  threshold NUMBER; ');
  l('  BEGIN');
  ldbg_s('-----------------','calling the function init_search');
  l('    IF NOT check_prim_cond (p_party_search_rec,');
  l('                            p_party_site_list,');
  l('                            p_contact_list,');
  l('                            p_contact_point_list) THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_PRIMARY_COND'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  IF l_max_score=1 THEN
    ldbg_s('In init_search calling util package set_no_score');
    l('    HZ_DQM_SEARCH_UTIL.set_no_score;');
  ELSE
    ldbg_s('In init_search calling util package set_score');
    l('    HZ_DQM_SEARCH_UTIL.set_score;');
  END IF;
  l('    g_mappings.DELETE;');
  l('    g_party_site_stage_list.DELETE;');
  l('    g_contact_stage_list.DELETE;');
  l('    g_contact_pt_stage_list.DELETE;');
  l('    call_order.DELETE;');
  l('    call_max_score.DELETE;');
  l('    HZ_DQM_SEARCH_UTIL.new_search;');
  l('    HZ_TRANS_PKG.set_party_type(p_party_search_rec.PARTY_TYPE);');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(0);');
  l('');
  ldbg_s('In init_search calling the Map procedures');
  l('    -- Transform search criteria');
  -- VJN Introduced for conditional Word Replacements
  --- Populate the global condition record before doing the mapping
  --- so that mapping takes into account conditional word replacements if any
  l('POP_PARTY_COND_REC(p_party_search_rec);');
  l('');
  l('POP_PARTY_SITES_COND_REC(p_party_site_list);');
  l('');
  l('POP_CONTACTS_COND_REC(p_contact_list);');
  l('');
  l('POP_CONTACT_POINTS_COND_REC(p_contact_point_list);');
  l('');

  l('    MAP_PARTY_REC(TRUE,p_party_search_rec, l_entered_max_score, g_party_stage_rec);');
  l('    MAP_PARTY_SITE_REC(TRUE,p_party_site_list, l_ps_entered_max_score, g_party_site_stage_list);');
  l('    MAP_CONTACT_REC(TRUE,p_contact_list, l_ct_entered_max_score, g_contact_stage_list);');
  l('    MAP_CONTACT_POINT_REC(TRUE,p_contact_point_list, l_cpt_entered_max_score, g_contact_pt_stage_list);');
  l('');
  l('      ');
  ldbg_s('In init_search determining call order of entities');
  l('    l_idx := l_entered_max_score+1;');
  l('    vlist (l_idx) := ''PARTY'';');
  l('    maxscore (l_idx) := l_entered_max_score;');

  l('    l_idx := l_ps_entered_max_score+1;');
  l('    WHILE vlist.EXISTS(l_idx) LOOP');
  l('      l_idx := l_idx+1;');
  l('    END LOOP;');
  l('    vlist (l_idx) := ''PARTY_SITE'';');
  l('    maxscore (l_idx) := l_ps_entered_max_score;');
  l('');
  l('    l_idx := l_ct_entered_max_score+1;');
  l('    WHILE vlist.EXISTS(l_idx) LOOP');
  l('      l_idx := l_idx+1;');
  l('    END LOOP;');
  l('    vlist (l_idx) := ''CONTACT'';');
  l('    maxscore (l_idx) := l_ct_entered_max_score;');
  l('');
  l('    l_idx := l_cpt_entered_max_score+1;');
  l('    WHILE vlist.EXISTS(l_idx) LOOP');
  l('      l_idx := l_idx+1;');
  l('    END LOOP;');
  l('    vlist (l_idx) := ''CONTACT_POINT'';');
  l('    maxscore (l_idx) := l_cpt_entered_max_score;');
  l('');
  l('    l_num := 1;');
  l('    l_idx := vlist.LAST;');
  ldbg_s('Call order is the following');
  l('    WHILE l_idx IS NOT NULL LOOP');
  l('      call_order(l_num) := vlist(l_idx);');
  l('      call_max_score(l_num) := maxscore(l_idx);');
  ldbg_s('-----------------');
  ldbg_sv('l_num = ','l_num','entity = ', 'vlist(l_idx)', 'call_max_score for entity = ', 'maxscore(l_idx)');
  l('      l_idx := vlist.PRIOR(l_idx);');
  l('      l_num := l_num+1;');
  l('    END LOOP;  ');
  ldbg_s('-----------------');
  l('    call_order(5):=''NONE'';');
  ldbg_s('In init_search determining call type of entities');
  l('    IF p_match_type = '' OR '' THEN');
  ldbg_s('This is an OR Match Rule');
  IF l_purpose = 'S' THEN
    l('      threshold := round(('||l_match_threshold||'/'||l_max_score||')*(l_entered_max_score+l_ps_entered_max_score+l_ct_entered_max_score+l_cpt_entered_max_score));');
    ldbg_s('This is a search Match Rule');
    ldbg_sv('Threshold defined in Match Rule, after rounding off is ', 'threshold');
  ELSE
    l('      threshold := '||l_match_threshold||';');
    ldbg_s('This is a Duplicate Identification Match Rule');
    ldbg_sv('Threshold defined in Match Rule is ', 'threshold');
  END IF;

  l('      l_idx := vlist.FIRST;');
  l('      total := 0;');
  l('      l_num := 4;');
  l('      WHILE l_idx IS NOT NULL LOOP');
  l('        total := total+maxscore(l_idx);');
  l('        IF total<threshold THEN');
  l('          call_type(l_num) := ''AND'';');
  l('        ELSE');
  l('          call_type(l_num) := ''OR'';');
  l('        END IF;');
  l('        l_idx := vlist.NEXT(l_idx);');
  l('        l_num := l_num-1;');
  l('      END LOOP;');
  l('    ELSE');
  l('      call_type(1) := ''OR'';');
  l('      call_type(2) := ''AND'';');
  l('      call_type(3) := ''AND'';');
  l('      call_type(4) := ''AND'';');
  l('    END IF;');
  ldbg_s('Call types are the following');
  ldbg_s('-----------------');
  ldbg_sv('call type 1 = ', 'call_type(1)', 'call type 2 = ', 'call_type(2)','call type 3 = ', 'call_type(3)','call type 4 = ', 'call_type(4)');
  ldbg_s('-----------------');
  l('    x_party_max_score := l_entered_max_score;');
  l('    x_ps_max_score := l_ps_entered_max_score;');
  l('    x_contact_max_score := l_ct_entered_max_score;');
  l('    x_cpt_max_score := l_cpt_entered_max_score;');
  ldbg_s('init_search returned with the following max scores at each level');
  ldbg_s('-----------------');
  ldbg_sv('entered party max score = ', 'l_entered_max_score',
          'entered paty site max score = ', 'l_ps_entered_max_score',
          'entered contact max score = ', 'l_ct_entered_max_score',
          'entered contact point max score = ', 'l_cpt_entered_max_score');
  ldbg_sv('entered total score = ', '(l_entered_max_score+l_ps_entered_max_score+l_ct_entered_max_score+l_cpt_entered_max_score)');
  ldbg_s('-----------------');
  l('    RETURN (l_entered_max_score+l_ps_entered_max_score+l_ct_entered_max_score+l_cpt_entered_max_score);');
  l('  END;');


  l('  FUNCTION INIT_PARTY_QUERY(p_match_str VARCHAR2, ');
  l('              p_denorm_str VARCHAR2,');
  l('              p_party_max_score NUMBER,');
  l('              p_denorm_max_score NUMBER,');
  l('              p_non_denorm_max_score NUMBER,');
  l('              p_threshold NUMBER) RETURN VARCHAR2 IS');
  l('    l_party_contains_str VARCHAR2(32000); ');
  l('    l_party_filter VARCHAR2(1) := null;');
  l('    l_prim_temp VARCHAR2(4000);');
  l('    l_denorm_str VARCHAR2(4000);');
  l('  BEGIN');
  ldbg_s('-----------------','calling the function init_party_query');
  ldbg_sv('passed in p_match_str is ', 'p_match_str');
  ldbg_sv('passed in p_denorm_str is ', 'p_denorm_str');
  ldbg_sv('passed in p_denorm_max_score is ', 'p_denorm_max_score');
  ldbg_sv('passed in p_non_denorm_max_score is ', 'p_non_denorm_max_score');
  ldbg_sv('passed in p_threshold is ', 'p_threshold');

  l('    IF p_party_max_score<=p_threshold OR p_match_str='' AND '' THEN');
  l('      l_denorm_str := NULL;');
  ldbg_sv('calculated denorm string l_denorm_str is ', 'l_denorm_str' );
  l('    ELSE');
  l('      l_denorm_str := p_denorm_str;');
  ldbg_sv('calculated denorm string l_denorm_str is ', 'l_denorm_str');
  l('    END IF;');

  FIRST := TRUE;
  g_party_or_query := null;
  g_party_and_query := null;
  cnt := cnt+1;
  FOR PRIMATTRS IN (
    SELECT a.ATTRIBUTE_ID, PRIMARY_ATTRIBUTE_ID, ATTRIBUTE_NAME, nvl(SCORE,0) SCORE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p,
         HZ_MATCH_RULE_SECONDARY s
    WHERE p.match_rule_id = p_rule_id
    AND s.match_rule_id (+) = p_rule_id
    AND s.attribute_id (+) = a.attribute_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND nvl(FILTER_FLAG,'N') <> 'Y'
    ORDER BY SCORE) LOOP
    FIRST1 := TRUE;
    l('');
    l('    -- Setup query string for '||PRIMATTRS.ATTRIBUTE_NAME);
    l('    l_prim_temp := null;');
    FOR PRIMTRANS IN (
      SELECT f.STAGED_ATTRIBUTE_COLUMN, f.TRANSFORMATION_NAME, nvl(f.PRIMARY_FLAG,'N') PRIMARY_FLAG, f.PROCEDURE_NAME
      FROM HZ_TRANS_FUNCTIONS_VL f,
         HZ_PRIMARY_TRANS pt
    WHERE pt.PRIMARY_ATTRIBUTE_ID = PRIMATTRS.PRIMARY_ATTRIBUTE_ID
    AND pt.FUNCTION_ID = f.FUNCTION_ID)
    LOOP
        IF FIRST1 THEN
          l_trans := '(g_party_stage_rec.'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NULL OR '' ''||'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' '' like ''% ''||g_party_stage_rec.'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' %'')';
          FIRST1 := FALSE;
        ELSE
          l_trans := l_trans||' OR (g_party_stage_rec.'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NULL OR '' ''||'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' '' like ''% ''||g_party_stage_rec.'||
                     PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' %'')';
        END IF;
          IF PRIMTRANS.PRIMARY_FLAG = 'Y' THEN
            tmp := '''A'||PRIMATTRS.ATTRIBUTE_ID||'''';
          ELSE
            tmp := 'NULL';
          END IF;
        --- Modified for Bug 4016594
        IF PRIMATTRS.ATTRIBUTE_NAME = 'DUNS_NUMBER_C' AND upper(PRIMTRANS.PROCEDURE_NAME) = 'HZ_TRANS_PKG.EXACT' THEN
          l('    IF g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NOT NULL THEN');
		  l('     IF ltrim(g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||',''0'') IS NOT NULL THEN');
          l('      FOR I in lengthb(ltrim(g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||',''0''))..9 LOOP');
          l('        HZ_DQM_SEARCH_UTIL.add_transformation( -- ' || PRIMTRANS.TRANSFORMATION_NAME);
          l('          lpad(ltrim(g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||
              ',''0''),I,chr('||ascii('0')||')),'||tmp||',l_prim_temp);');
          l('      END LOOP;');
          l('     END IF;');
          l('    END IF;');
        ELSE
          l('    HZ_DQM_SEARCH_UTIL.add_transformation( -- ' || PRIMTRANS.TRANSFORMATION_NAME);
          l('          g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||
            ','||tmp||',l_prim_temp);');
        END IF;

    END LOOP;

    IF FIRST THEN
      FIRST := FALSE;
      g_party_or_query := '('||l_trans||')';
      g_party_and_query := '('||l_trans||')';
    ELSE
      g_party_or_query := g_party_or_query || ' OR (' || l_trans||')';
      g_party_and_query := g_party_and_query || ' AND (' || l_trans||')';
    END IF;

    l('');
    IF PRIMATTRS.SCORE = 0 THEN
      l('    HZ_DQM_SEARCH_UTIL.add_attribute(l_prim_temp, p_match_str, l_party_contains_str);');
    ELSE
      l('  IF l_denorm_str IS NOT NULL THEN');
      l('    IF (p_non_denorm_max_score+'||PRIMATTRS.SCORE||')>=p_threshold THEN');
      l('      l_denorm_str := NULL;');
      l('      HZ_DQM_SEARCH_UTIL.add_attribute(l_prim_temp, p_match_str, l_party_contains_str);');
      l('    ELSIF (p_non_denorm_max_score+p_denorm_max_score+'||PRIMATTRS.SCORE||')>=p_threshold THEN');
      l('      HZ_DQM_SEARCH_UTIL.add_attribute_with_denorm(l_prim_temp, p_match_str, l_denorm_str, l_party_contains_str);');
      l('      l_denorm_str := NULL;');
      l('    END IF;');
      l('  ELSE');
      l('    HZ_DQM_SEARCH_UTIL.add_attribute(l_prim_temp, p_match_str, l_party_contains_str);');
      l('  END IF;');
    END IF;
  END LOOP;
  l('    IF lengthb(l_party_contains_str) > 4000 THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_SEARCH_CRIT_LARGE_ERROR'');');
  l('      FND_MESSAGE.SET_TOKEN(''ENTITY'',''PARTY'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  l('    IF (p_match_str = '' AND '' OR p_party_max_score<p_threshold) AND l_party_contains_str IS NOT NULL AND p_denorm_str IS NOT NULL THEN');
  ldbg_s('party contains string returned by init_search is an AND between these strings ');
  ldbg_sv('l_party_contains_str = ', 'l_party_contains_str');
  ldbg_sv('p_denorm_str = ', 'p_denorm_str');
  l('      RETURN ''(''||l_party_contains_str||'') AND (''||p_denorm_str||'')'';');
  l('    ELSE');
  ldbg_s('party contains string returned by init_search is ', 'l_party_contains_str');
  l('      RETURN l_party_contains_str;');
  l('    END IF;');
  l('  END;');

  get_column_list(p_rule_id, 'PARTY',l_p_select_list,l_p_param_list, l_p_into_list);
  get_column_list(p_rule_id, 'PARTY_SITES',l_ps_select_list,l_ps_param_list, l_ps_into_list);
  get_column_list(p_rule_id, 'CONTACTS',l_c_select_list,l_c_param_list, l_c_into_list);
  get_column_list(p_rule_id, 'CONTACT_POINTS',l_cpt_select_list,l_cpt_param_list, l_cpt_into_list);

  l_party_filter_str := NULL;
  l_dyn_party_filter_str := NULL;
  FIRST := TRUE;
  cnt := 1;
  for PRIMTRANS IN (
        SELECT f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY pattr,
             HZ_PRIMARY_TRANS pfunc
        WHERE pattr.MATCH_RULE_ID = p_rule_id
        AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY'
        AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
        AND pfunc.FUNCTION_ID = f.FUNCTION_ID
        AND FILTER_FLAG  = 'Y'

        UNION

        SELECT f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
            HZ_TRANS_ATTRIBUTES_VL a
        WHERE f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.entity_name = 'PARTY'
        AND a.attribute_name='PARTY_TYPE'
        AND f.PROCEDURE_NAME='HZ_TRANS_PKG.EXACT'
        AND nvl(f.active_flag,'Y')='Y'
        AND ROWNUM=1
  ) LOOP

        IF FIRST THEN
          l_party_filter_str := '(g_party_stage_rec.'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
               ' IS NULL OR g_party_stage_rec.'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'' '' =  p.' ||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
          l_dyn_party_filter_str := '(:'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
               ' IS NULL OR :'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'''' '''' =  p.' ||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
          FIRST := FALSE;
        ELSE
          l_dyn_party_filter_str := l_dyn_party_filter_str || ' AND ' ||
               '(:'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
               ' IS NULL OR :'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'''' '''' =  p.' ||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
          l_party_filter_str := l_party_filter_str || ' AND ' ||
               '(g_party_stage_rec.'||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
               ' IS NULL OR g_party_stage_rec.'||
               PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'' '' =  p.' ||
                PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
        END IF;
        l_party_filt_bind(cnt) := 'g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN;
        cnt:=cnt+1;
  END LOOP;

  add_query_gen_func('PARTY_SITES',p_rule_id);
  add_query_gen_func('CONTACTS',p_rule_id);
  add_query_gen_func('CONTACT_POINTS',p_rule_id);

   /*********************************************************************************
   * Match rule private procedures to open a cursor for performing intermedia queries.
   *   open_party_cursor - Intermedia query on HZ_STAGED_PARTIES
   *   open_party_site_cursor - Intermedia query on HZ_STAGED_PARTY_SITES
   *   open_contact_cursor - Intermedia query on HZ_STAGED_CONTACTS
   *   open_contact_pt_cursor - Intermedia query on HZ_STAGED_CONTACT_POINTS
   *
   * Input:
   * p_dup_party_id : Called in the duplicate identification case, to filter off
   *                  the party for which we are trying find duplicates.
   * p_restrict_sql : restrict_sql criteria passed to match rule
   * p_contains_str : Intermedia query string
   * p_search_ctx_id : Only to called from find_party_details, for filtering against
   *                  party_ids returned by the party query
   * p_party_id : USed in the get_matching_party_sites, get_matching_contacts and
   *              get_matching_cpts procedures, to only find records belonging to the specified
   *              party_id
   *********************************************************************************/

  IF l_purpose IN ('S','W') THEN
    l_party_name_score:='decode(TX8,g_party_stage_rec.TX8||'' '',100,90)';
  ELSE
    BEGIN
      SELECT to_char(score) INTO l_party_name_score from HZ_MATCH_RULE_SECONDARY s, HZ_TRANS_ATTRIBUTES_VL a
      WHERE a.attribute_id = s.attribute_id
      AND s.match_rule_id = p_rule_id
      AND attribute_name = 'PARTY_NAME';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_party_name_score := '0';
    END;
  END IF;
  l('  PROCEDURE open_party_cursor_direct (');
  l('            p_dup_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_match_str VARCHAR2,');
  l('            p_search_merged VARCHAR2,');
  l('            p_party_contains_str VARCHAR2,');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('    l_sqlstr VARCHAR2(4000);');
  l('    l_search_merged VARCHAR2(1);');
  l('  BEGIN');
  ldbg_s('-----------------','calling procedure open party cursor direct');
  l('    IF (p_search_merged is null) then ');
  l('       l_search_merged := ''N'';  ');
  l('    ELSE ');
  l('       l_search_merged := p_search_merged; ');
  l('    END IF; ');
  ldbg_sv('Search Merged Flag - ','l_search_merged');
  l('    IF p_restrict_sql IS NULL AND NOT g_other_party_level_attribs AND NOT (p_party_contains_str IS NOT NULL AND instrb(p_party_contains_str,''D_PS'')>0 AND g_party_site_stage_list.COUNT=1) THEN');
  ldbg_s('Restrict SQL is NULL and other conditions met to OPEN x_cursor');
  l('     OPEN x_cursor FOR ');
  l('      SELECT PARTY_ID '|| l_p_select_list);
  l('      FROM hz_staged_parties ');
  l('      WHERE TX8 LIKE g_party_stage_rec.TX8||'' %''');
  l('      AND ((g_party_stage_rec.TX36 IS NULL OR g_party_stage_rec.TX36||'' '' =  TX36))');
  l('      AND( (l_search_merged =''Y'' ) ');
  l('           OR (l_search_merged = ''I'' AND nvl(status, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(status, ''A'') in (''A'')))  ');
  l('      AND (p_dup_party_id IS NULL OR party_id <> p_dup_party_id);');
  l('    ELSE');
  ldbg_s('Restrict SQL is NOT NULL OR other conditions not met, Else Part');
  l('      l_sqlstr := ''SELECT PARTY_ID '|| l_p_select_list||' FROM hz_staged_parties stage '';');
  l('      l_sqlstr := l_sqlstr || '' WHERE TX8 like :TX8||'''' %'''' '';');
  l('      l_sqlstr := l_sqlstr || '' AND (:TX36 IS NULL OR :TX36||'''' '''' =  TX36) '';');
  l('      IF l_search_merged = ''N'' THEN');
  l('        l_sqlstr := l_sqlstr || '' AND nvl(status,''''A'''')=''''A'''' '';');
  l('      ELSIF l_search_merged = ''I'' THEN');
  l('        l_sqlstr := l_sqlstr || '' AND nvl(status,''''A'''') in (''''A'''',''''I'''') '';');
  l('      END IF;');
  l('      l_sqlstr := l_sqlstr || '' AND (:p_dup IS NULL OR party_id <> :p_dup ) '';');
  l('      IF g_other_party_level_attribs THEN');
  FIRST := TRUE;
  cnt := 1;
  FOR PATTRS IN (
    SELECT PRIMARY_ATTRIBUTE_ID, ATTRIBUTE_NAME
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND a.attribute_name <> 'PARTY_NAME'
    AND nvl(FILTER_FLAG,'N') = 'N') LOOP
    IF FIRST THEN
      l('      l_sqlstr := l_sqlstr || '' AND ((:attr IS NULL OR '';');
      FIRST := FALSE;
    ELSE
      l('      l_sqlstr := l_sqlstr || ''     ''||p_match_str||'' (:attr IS NULL OR '';');
    END IF;

    FIRST1 := TRUE;
    FOR PRIMTRANS IN (
      SELECT f.STAGED_ATTRIBUTE_COLUMN
      FROM HZ_TRANS_FUNCTIONS_VL f,
         HZ_PRIMARY_TRANS pt
      WHERE pt.PRIMARY_ATTRIBUTE_ID = PATTRS.PRIMARY_ATTRIBUTE_ID
      AND pt.FUNCTION_ID = f.FUNCTION_ID) LOOP
        IF FIRST1 THEN
           l('      l_sqlstr := l_sqlstr || ''     ('||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' like :'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'''' %'''' '';');
           FIRST1 :=  FALSE;
           party_binds(cnt) := 'g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN;
           cnt := cnt+1;
         ELSE
           l('      l_sqlstr := l_sqlstr || ''      OR '||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' like :'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'''' %'''' '';');
         END IF;
         party_binds(cnt) := 'g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN;
         cnt := cnt+1;
    END LOOP;
    l('     l_sqlstr := l_sqlstr || '' )) '';');
  END LOOP;
  IF NOT FIRST THEN
     l('     l_sqlstr := l_sqlstr || '' ) '';');
  END IF;

  FOR PATTRS IN (
    SELECT PRIMARY_ATTRIBUTE_ID, ATTRIBUTE_NAME
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND a.attribute_name <> 'PARTY_NAME'
    AND nvl(FILTER_FLAG,'N') = 'Y') LOOP
    l('      l_sqlstr := l_sqlstr || '' AND (:attr IS NULL OR '';');

    FIRST1 := TRUE;
    FOR PRIMTRANS IN (
      SELECT f.STAGED_ATTRIBUTE_COLUMN
      FROM HZ_TRANS_FUNCTIONS_VL f,
         HZ_PRIMARY_TRANS pt
      WHERE pt.PRIMARY_ATTRIBUTE_ID = PATTRS.PRIMARY_ATTRIBUTE_ID
      AND pt.FUNCTION_ID = f.FUNCTION_ID) LOOP
         IF FIRST1 THEN
           l('      l_sqlstr := l_sqlstr || ''     ('||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' like :'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'''' %'''' '';');
           FIRST1 :=  FALSE;
           party_binds(cnt) := 'g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN;
           cnt := cnt+1;
         ELSE
           l('      l_sqlstr := l_sqlstr || ''      OR '||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' like :'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'''' %'''' '';');
         END IF;
         party_binds(cnt) := 'g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN;
         cnt := cnt+1;
    END LOOP;
    l('     l_sqlstr := l_sqlstr || '' )) '';');
  END LOOP;
  IF party_binds.COUNT=0 THEN
    l('     NULL;');
  END IF;
  l('     END IF;');
  l_party_level_cnt := cnt;
  l('     IF p_party_contains_str IS NOT NULL AND instrb(p_party_contains_str,''D_PS'')>0 AND g_party_site_stage_list.COUNT=1 THEN');
  ldbg_s('p_party_contains_str string is NOT NULL and other conditions met');
  FIRST := TRUE;
  FOR DENATTR IN (
    SELECT PRIMARY_ATTRIBUTE_ID, ATTRIBUTE_NAME
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
    AND nvl(a.denorm_flag,'N') = 'Y') LOOP
    l('      l_sqlstr := l_sqlstr || '' AND (:attr IS NULL OR '';');
    FIRST1 := TRUE;
    FOR DENTRANS IN (
      SELECT f.STAGED_ATTRIBUTE_COLUMN
      FROM HZ_TRANS_FUNCTIONS_VL f,
         HZ_PRIMARY_TRANS pt
      WHERE pt.PRIMARY_ATTRIBUTE_ID = DENATTR.PRIMARY_ATTRIBUTE_ID
      AND pt.FUNCTION_ID = f.FUNCTION_ID) LOOP
         IF FIRST1 THEN
           l('      l_sqlstr := l_sqlstr || ''     (D_PS like ''''% ''''||:'||DENTRANS.STAGED_ATTRIBUTE_COLUMN||'||'''' %'''' '';');
           FIRST1 :=  FALSE;
           party_binds(cnt) := 'g_party_site_stage_list(1).'||DENTRANS.STAGED_ATTRIBUTE_COLUMN;
           cnt := cnt+1;
         ELSE
           l('      l_sqlstr := l_sqlstr || ''      OR D_PS like ''''% ''''||:'||DENTRANS.STAGED_ATTRIBUTE_COLUMN||'||'''' %'''' '';');
         END IF;
         party_binds(cnt) := 'g_party_site_stage_list(1).'||DENTRANS.STAGED_ATTRIBUTE_COLUMN;
         cnt := cnt+1;
    END LOOP;
    l('     l_sqlstr := l_sqlstr || '' )) '';');
  END LOOP;
  IF l_party_level_cnt=cnt THEN
    l('       null;');
  END IF;
  l('     END IF;');
  ldbg_s('l_sqlstr before appending restrict_sql');
  ldbg_sv('l_sqlstr is - ','l_sqlstr');

  l('     IF p_restrict_sql IS NOT NULL THEN');
  l('       l_sqlstr := l_sqlstr || '' AND ''||p_restrict_sql||'' '';');
  l('     END IF;');
  ldbg_s('l_sqlstr after appending restrict_sql');
  ldbg_sv('l_sqlstr is - ','l_sqlstr');
  l('     IF g_other_party_level_attribs AND p_party_contains_str IS NOT NULL AND instrb(p_party_contains_str,''D_PS'')>0 AND g_party_site_stage_list.COUNT=1 THEN');
  ldbg_s('IF g_other_party_level_attribs AND p_party_contains_str IS NOT NULL AND ...');
  l('       OPEN x_cursor FOR l_sqlstr USING g_party_stage_rec.TX8,g_party_stage_rec.TX36,g_party_stage_rec.TX36,p_dup_party_id,p_dup_party_id');
  FOR I in 1..party_binds.COUNT LOOP
    l('     ,'||party_binds(I));
  END LOOP;
  l('     ;');
  l('     ELSIF g_other_party_level_attribs THEN');
  ldbg_s('ELSIF g_other_party_level_attribs THEN');
  l('       OPEN x_cursor FOR l_sqlstr USING g_party_stage_rec.TX8,g_party_stage_rec.TX36,g_party_stage_rec.TX36,p_dup_party_id,p_dup_party_id');
  FOR I in 1..(l_party_level_cnt-1)LOOP
    l('     ,'||party_binds(I));
  END LOOP;
  l('     ;');
  l('     ELSIF p_party_contains_str IS NOT NULL AND instrb(p_party_contains_str,''D_PS'')>0 AND g_party_site_stage_list.COUNT=1 THEN');
  ldbg_s('ELSIF p_party_contains_str IS NOT NULL AND ...');
  l('       OPEN x_cursor FOR l_sqlstr USING g_party_stage_rec.TX8,g_party_stage_rec.TX36,g_party_stage_rec.TX36,p_dup_party_id,p_dup_party_id');
  FOR I in l_party_level_cnt..party_binds.COUNT LOOP
    l('     ,'||party_binds(I));
  END LOOP;
  l('     ;');
  l('     ELSE');
  ldbg_s('ELSE code fork');
  l('       OPEN x_cursor FOR l_sqlstr USING g_party_stage_rec.TX8,g_party_stage_rec.TX36,g_party_stage_rec.TX36,p_dup_party_id,p_dup_party_id;');
  l('     END IF;');
  l('    END IF;');
  l('  END;');

  l('  PROCEDURE open_party_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id NUMBER,');
  l('            p_match_str VARCHAR2,');
  l('            p_search_merged VARCHAR2,');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  l_hint VARCHAR2(100); ');
  l('  l_check NUMBER; ');
  l('  l_search_merged VARCHAR2(1); ');
  l('  BEGIN');
  ldbg_s('-----------------','calling procedure open party cursor');
  l('    IF (p_search_merged is null) then ');
  l('       l_search_merged := ''N'';  ');
  l('    ELSE ');
  l('       l_search_merged := p_search_merged; ');
  l('    END IF; ');
  l('    IF p_contains_str IS NULL THEN');
  ldbg_s('part contains string is null');
  /**** To query based on party_id .. from the get_score_details flow ***/
  l('      OPEN x_cursor FOR ');
  l('        SELECT PARTY_ID '|| l_p_select_list);
  l('        FROM HZ_STAGED_PARTIES stage');
  l('        WHERE PARTY_ID = p_dup_party_id;');

  /**** Static queries when restrict_sql is null OR if p_search_ctx_id IS NOT NULL *****/
  l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');
  ldbg_s('Either restrict sql is null or search context id is not null');
  /**** When search context ID is null .. Retrieve rows using intermedia index ****/
  l('      IF p_search_ctx_id IS NULL THEN');
  ldbg_s('Search context id is null');
  l('        OPEN x_cursor FOR ');
  l('          SELECT /*+ INDEX(stage HZ_STAGE_PARTIES_T1) */ PARTY_ID '|| l_p_select_list);
  l('          FROM HZ_STAGED_PARTIES stage');
  IF l_party_filter_str IS NOT NULL THEN
    l('          WHERE contains( concat_col, p_contains_str)>0');
    l('          AND ('||replace(l_party_filter_str,'p.','stage.')||')');
  ELSE
    l('          WHERE contains( concat_col, p_contains_str)>0');
  END IF;
  l('          AND( (l_search_merged =''Y'' ) ');
  l('          OR (l_search_merged = ''I'' AND nvl(stage.status, ''A'') in (''A'', ''I''))  ');
  l('          OR (l_search_merged = ''N'' AND nvl(stage.status, ''A'') in (''A''))       ) ');
  l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');


  /**** When search context ID is not null .. Query using DQM_PARTIES_GT. Filter using
        intermedia index ****/
  l('      ELSE');
  ldbg_s('Search context id is not null');
  l('        OPEN x_cursor FOR ');
  l('            SELECT /*+ ORDERED INDEX(stage HZ_STAGED_PARTIES_U1) */ stage.PARTY_ID '|| l_p_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_PARTIES stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  l('            AND d.SEARCH_CONTEXT_ID=p_search_ctx_id');
  l('            AND d.party_id = stage.party_id');
  IF l_party_filter_str IS NOT NULL THEN
    l('            AND ('||replace(l_party_filter_str,'p.','stage.')||')');
  END IF;
  l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id)');
  l('            AND( (l_search_merged =''Y'' ) ');
  l('            OR (l_search_merged = ''I'' AND nvl(stage.status, ''A'') in (''A'', ''I''))  ');
  l('            OR (l_search_merged = ''N'' AND nvl(stage.status, ''A'') in (''A''))       ); ');
  l('      END IF;');

  /**** When restrict_sql is not null *****/
  l('    ELSE');
  ldbg_s('Restrict sql is not null');
  l('       l_check := instrb(p_restrict_sql, ''SELECTIVE''); ');
  l('       IF (l_check > 0 ) THEN ');
  ldbg_s('Restrict sql has a Selective Hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_PARTIES_U1) */''; ');
  l('       ELSE ');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGE_PARTIES_T1) */''; ');
  l('       END IF; ');
  /**** When search context ID is null .. Access using intermedia index ***/
  l('     IF p_search_ctx_id IS NULL THEN');
  l('       l_sqlstr := ''SELECT   '' || l_hint || '' PARTY_ID '|| l_p_select_list||'''||');
  l('                   '' FROM HZ_STAGED_PARTIES stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  IF l_dyn_party_filter_str IS NOT NULL THEN
    l('                   '' AND ('||replace(l_dyn_party_filter_str,'p.','stage.')||')''||');
  END IF;
  l('                   '' AND (''||p_restrict_sql||'')'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('          IF l_search_merged = ''Y'' THEN  ');
  l('                  l_sqlstr := l_sqlstr ;  ');
  l('          ELSIF l_search_merged = ''I'' THEN  ');
  l('                  l_sqlstr := l_sqlstr ||'' AND nvl(stage.status,''''A'''') in (''''A'''', ''''I'''')'';  ');
  l('          ELSE  ');
  l('                  l_sqlstr := l_sqlstr ||'' AND nvl(stage.status,''''A'''') in (''''A'''')'';  ');
  l('          END IF;  ');
  l(' 	   output_long_strings(''----------------------------------------------------------'');');
  l('      output_long_strings(''Party Contains String = ''||p_contains_str);');
  l('		output_long_strings(''Restrict Sql = ''||p_restrict_sql);');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
  FOR I in 1..l_party_filt_bind.COUNT LOOP
      l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
  END LOOP;
  l('                    ,p_dup_party_id, p_dup_party_id;');
  l('     END IF;');
  l('   END IF;');
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
   --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Bug: 3392837
  l('      elsif (instrb(SQLERRM,''ORA-20000'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_API_OTHERS_EXCEP'');');
  l('    	 FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    	 FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
  l('  END;');
  l('');

  l('  PROCEDURE open_party_site_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            p_search_merged  VARCHAR2, ');
  l('            p_search_rel_sites  VARCHAR2, ');
  l('            p_person_api  VARCHAR2, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  l_hint VARCHAR2(100); ');
  l('  l_check NUMBER; ');
  l('  l_check_dt NUMBER; ');
  l('  l_search_merged VARCHAR2(1); ');
  l('  l_status_sql VARCHAR2(100); ');
  l('  p_restrict_sql1 VARCHAR2(4000); ');
  l(' ');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure open_party_site_cursor');
  l('     IF (p_search_merged is null) then ');
  l('        l_search_merged := ''N'';  ');
  l('     ELSE ');
  l('        l_search_merged := p_search_merged; ');
  l('     END IF; ');
  /**** For a single party_id scenario. Retrieve using party_id, filter using intermedia ****/
  l('     IF p_party_id IS NOT NULL THEN');
  ldbg_s('Single Party Scenario');
  l('       IF p_search_rel_sites = ''N'' THEN');
  l('         OPEN x_cursor FOR ');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N1) */ PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID'|| l_ps_select_list);
  l('          FROM HZ_STAGED_PARTY_SITES stage');
  l('          WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('             OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('             OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND stage.party_id = p_party_id; ');
  l('       ELSE');
  l('         OPEN x_cursor FOR ');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N1) */ PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID'|| l_ps_select_list);
  l('          FROM HZ_STAGED_PARTY_SITES stage');
  l('          WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('            OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('            OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND stage.party_id = p_party_id ');
  l('          UNION');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N2) */ stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID'|| l_ps_select_list);
  l('          FROM HZ_STAGED_PARTY_SITES stage, hz_relationships r, hz_org_contacts oc');
  l('          WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('            OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('            OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND r.object_id = p_party_id ');
  l('          AND r.subject_id = stage.party_id ');
  l('          AND r.SUBJECT_TABLE_NAME = ''HZ_PARTIES'' ');
  l('          AND r.OBJECT_TABLE_NAME = ''HZ_PARTIES'' ');
  l('          AND r.relationship_id = oc.party_relationship_id');
  l('          AND oc.org_contact_id = stage.org_contact_id; ');
  l('      END IF;');
  /**** If restrict_sql is NULL or if p_search_ctx_id is not null, execute static queries **/
  l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');
  ldbg_s('Either restrict sql is null or search context id is not null');
  /**** When p_search_ctx_id IS NULL, retreive using intermedia index ***/
  l('      IF p_search_ctx_id IS NULL THEN');
  ldbg_s('Search context id is null');
  l('        OPEN x_cursor FOR ');
  l('          SELECT PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID'|| l_ps_select_list);
  l('          FROM HZ_STAGED_PARTY_SITES stage');
  IF l_party_filter_str IS NOT NULL THEN
    l('        WHERE contains( concat_col, p_contains_str)>0');
    l('        AND EXISTS (');
    l('          SELECT 1 FROM HZ_STAGED_PARTIES p');
    l('          WHERE p.PARTY_ID = stage.PARTY_ID');
    l('          AND( (l_search_merged =''Y'' )  ');
    l('          OR (l_search_merged = ''I'' AND nvl(p.status, ''A'') in (''A'', ''I''))  ');
    l('          OR (l_search_merged = ''N'' AND nvl(p.status, ''A'') in (''A''))       )  ');
    l('          AND ('||l_party_filter_str||'))');
  ELSE
    l('        WHERE contains( concat_col, p_contains_str)>0');

  END IF;
    --Start of BugNo: 4299785
    l('          AND( (l_search_merged =''Y'' )  ');
    l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
    l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
    --End of BugNo: 4299785
  l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');

  /***** Search_ctx_id is not null. Reteive using HZ_DQM_PARTIES_GT ****/
  l('      ELSE');
  ldbg_s('Search context id is not null');
  l('        IF p_person_api = ''Y'' THEN');
  l('          OPEN x_cursor FOR ');
  l('            SELECT  PARTY_SITE_ID, stage.PARTY_ID, ORG_CONTACT_ID'|| l_ps_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_PARTY_SITES stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('          OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('          OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = stage.party_id');
  l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id)');
  l('            UNION ');
  l('            SELECT /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N2) */ stage.PARTY_SITE_ID, r.subject_id, stage.ORG_CONTACT_ID'|| l_ps_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, hz_relationships r,hz_org_contacts oc, HZ_STAGED_PARTY_SITES stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('          OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('          OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = r.subject_id');
  l('            AND r.relationship_id = oc.party_relationship_id');
  l('            AND oc.org_contact_id = stage.org_contact_id');
  l('            AND (p_dup_party_id IS NULL OR r.subject_id <> p_dup_party_id);');
  l('        ELSE');
  l('          OPEN x_cursor FOR ');
  l('            SELECT  PARTY_SITE_ID, stage.PARTY_ID, ORG_CONTACT_ID'|| l_ps_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_PARTY_SITES stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('            AND( (l_search_merged =''Y'' )  ');
  l('             OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('             OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = stage.party_id');
  l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');
  l('        END IF;');

  l('      END IF;');

  /**** Restrict_sql is not null. Retrieve using intermedia ****/
  l('    ELSE');
  ldbg_s('Restrict sql is not null');
  l('       l_check := instrb(p_restrict_sql, ''SELECTIVE''); ');
  l('       l_check_dt := instrb(p_restrict_sql, ''SELECTIVE_PS''); ');
  l('       IF (l_check_dt > 0 ) THEN ');
  ldbg_s('Restrict sql has the selective_ps  hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_PARTY_SITES_U1) */''; ');
  l('       ELSIF (l_check > 0 ) THEN ');
  ldbg_s('Restrict sql has the selective hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_PARTY_SITES_N1) */''; ');
  l('       END IF; ');
  l('       IF l_search_merged = ''Y'' THEN ');
  l('               l_status_sql := '' '' ;  ');
  l('       ELSIF l_search_merged = ''I'' THEN  ');
  l('               l_status_sql := '' AND nvl(p.status,''''A'''') in (''''A'''', ''''I'''')''; ');
  l('       ELSE ');
  l('               l_status_sql := '' AND nvl(p.status,''''A'''') in (''''A'''')''; ');
  l('       END IF; ');
  /* Performance fix for Bug:4643321*/
  l(' 		/*Performance fix for Bug:4589953*/ ');
  l(' 		IF(p_person_api=''Y'') THEN ');
  l('       IF (l_check > 0 ) THEN ');
     l('       IF instrb(p_restrict_sql, ''STAGE.'') > 0 THEN ');
     l('       	p_restrict_sql1 := replace( p_restrict_sql, ''STAGE.'', ''stage1.'');');
     l('       ELSIF instrb(p_restrict_sql, ''stage.'') > 0 THEN ');
     l('       	p_restrict_sql1 := replace( p_restrict_sql, ''stage.'', ''stage1.'');');
     l('       ELSE');
     l('		p_restrict_sql1 := ''stage1.''||p_restrict_sql;');
  l('       END IF; ');
  l('       l_sqlstr := ''SELECT  /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N1) */ PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID '|| l_ps_select_list||'''||');
  l('                   '' FROM HZ_STAGED_PARTY_SITES stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  --Start of BugNo: 4299785
  l('                   ''  AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''|| ');
  --End of BugNo: 4299785
            l('         '' AND (ORG_CONTACT_ID IS NULL '' ||');
            l('       	'' AND (''||p_restrict_sql||''))'' ||');
            l('       	'' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) '' ||');
            l('         '' UNION '' ||');
  l('       			 ''SELECT /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N2) */ PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID '|| l_ps_select_list||'''||');
  l('                   '' FROM HZ_STAGED_PARTY_SITES stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  --Start of BugNo: 4299785
  l('                   ''  AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''|| ');
  --End of BugNo: 4299785

            l('         '' AND ORG_CONTACT_ID IN '' ||');
            l('         '' ( SELECT org_contact_id from HZ_ORG_CONTACTS oc, (select object_id, relationship_id, subject_id party_id from hz_relationships '' ||');
            l('         '' where subject_type = ''''PERSON'''' AND object_type = ''''ORGANIZATION'''') stage1 '' ||');
            l('         '' where stage1.relationship_id = oc.party_relationship_id '' || ');
            l('         '' and (''||p_restrict_sql1|| '') )'' ||') ;
            l('         '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str,');
  l('                    p_dup_party_id, p_dup_party_id, p_contains_str, p_dup_party_id, p_dup_party_id;');

  l('       ELSE ');
  l('       l_sqlstr := ''SELECT '' || l_hint ||'' PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID '|| l_ps_select_list||'''||');
  l('                   '' FROM HZ_STAGED_PARTY_SITES stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  --Start of BugNo: 4299785
  l('                   ''  AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''|| ');
  --End of BugNo: 4299785
  IF l_dyn_party_filter_str IS NOT NULL THEN
    l('                 '' AND EXISTS (''||');
    l('                 '' SELECT 1 FROM HZ_STAGED_PARTIES p '' || ');
    l('                 '' WHERE p.party_id = stage.party_id '' || ');
    l('                 '' AND ('||l_dyn_party_filter_str||')  ''|| l_status_sql ||'' ) '' || ');
  END IF;
  l('                   '' AND (''||get_adjusted_restrict_sql(p_restrict_sql)||'')'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
  FOR I in 1..l_party_filt_bind.COUNT LOOP
    l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
  END LOOP;
  l('                    ,p_dup_party_id, p_dup_party_id;');
  l('       END IF; ');

  l('		ELSE ');
  l('       l_sqlstr := ''SELECT '' || l_hint ||'' PARTY_SITE_ID, PARTY_ID, ORG_CONTACT_ID '|| l_ps_select_list||'''||');
  l('                   '' FROM HZ_STAGED_PARTY_SITES stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  --Start of BugNo: 4299785
  l('                   ''  AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''|| ');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''|| ');
  --End of BugNo: 4299785

  IF l_dyn_party_filter_str IS NOT NULL THEN
    l('                 '' AND EXISTS (''||');
    l('                 '' SELECT 1 FROM HZ_STAGED_PARTIES p '' || ');
    l('                 '' WHERE p.party_id = stage.party_id '' || ');
    l('                 '' AND ('||l_dyn_party_filter_str||')  ''|| l_status_sql ||'' ) '' || ');
  END IF;
  l('                   '' AND (''||p_restrict_sql||'')'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
  FOR I in 1..l_party_filt_bind.COUNT LOOP
    l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
  END LOOP;
  l('                    ,p_dup_party_id, p_dup_party_id;');
  l('		  END IF; ');
  l('    END IF;');
  l(' 	    output_long_strings(''----------------------------------------------------------'');');
  l('       output_long_strings(''Party Site Contains String = ''||p_contains_str);');
  l('		output_long_strings(''Restrict Sql = ''||p_restrict_sql);');
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Bug: 3392837
  l('      elsif (instrb(SQLERRM,''ORA-20000'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_API_OTHERS_EXCEP'');');
  l('    	 FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    	 FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
  l('  END;');
  l('');
  l('  PROCEDURE open_contact_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            p_search_merged  VARCHAR2, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  l_hint VARCHAR2(100); ');
  l('  l_check NUMBER; ');
  l('  l_check_dt NUMBER; ');
  l('  l_search_merged VARCHAR2(1); ');
  l('  l_status_sql VARCHAR2(100); ');
  l(' ');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure open_contact_cursor');
  l('     IF (p_search_merged is null) then ');
  l('        l_search_merged := ''N'';  ');
  l('     ELSE ');
  l('        l_search_merged := p_search_merged; ');
  l('     END IF; ');
  /**** For a single party_id scenario. Retrieve using party_id, filter using intermedia ****/
  l('     IF p_party_id IS NOT NULL THEN');
  ldbg_s('Single party scenario');
  l('       OPEN x_cursor FOR ');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_CONTACTS_N1) */ ORG_CONTACT_ID, PARTY_ID'|| l_c_select_list);
  l('          FROM HZ_STAGED_CONTACTS stage');
  IF l_party_filter_str IS NOT NULL THEN
    l('        WHERE contains( concat_col, p_contains_str)>0');
    l('        AND EXISTS (');
    l('          SELECT 1 FROM HZ_STAGED_PARTIES p');
    l('          WHERE p.PARTY_ID = stage.PARTY_ID');
    l('          AND( (l_search_merged =''Y'' )  ');
    l('          OR (l_search_merged = ''I'' AND nvl(p.status, ''A'') in (''A'', ''I''))  ');
    l('          OR (l_search_merged = ''N'' AND nvl(p.status, ''A'') in (''A''))       )  ');
    l('          AND ('||l_party_filter_str||'))');
  ELSE
    l('        WHERE contains( concat_col, p_contains_str)>0');
  END IF;
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND stage.party_id = p_party_id;');
  /**** If restrict_sql is NULL or if p_search_ctx_id is not null, execute static queries **/
  l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');
  ldbg_s('Either Restrict sql is null or Search Context Id is not null');
  /**** When p_search_ctx_id IS NULL, retreive using intermedia index ***/
  l('      IF p_search_ctx_id IS NULL THEN');
  ldbg_s('Search Context id is null');
  l('        OPEN x_cursor FOR ');
  l('          SELECT ORG_CONTACT_ID, PARTY_ID'|| l_c_select_list);
  l('          FROM HZ_STAGED_CONTACTS stage');
  IF l_party_filter_str IS NOT NULL THEN
    l('        WHERE contains( concat_col, p_contains_str)>0');
    l('        AND EXISTS (');
    l('          SELECT 1 FROM HZ_STAGED_PARTIES p');
    l('          WHERE p.PARTY_ID = stage.PARTY_ID');
    l('          AND( (l_search_merged =''Y'' )  ');
    l('          OR (l_search_merged = ''I'' AND nvl(p.status, ''A'') in (''A'', ''I''))  ');
    l('          OR (l_search_merged = ''N'' AND nvl(p.status, ''A'') in (''A''))       )  ');
    l('          AND ('||l_party_filter_str||'))');
  ELSE
    l('        WHERE contains( concat_col, p_contains_str)>0');
  END IF;
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');

  /***** Search_ctx_id is not null. Reteive using HZ_DQM_PARTIES_GT ****/
  l('      ELSE');
  ldbg_s('Search Context id is not null');
  l('          OPEN x_cursor FOR ');
  l('            SELECT /*+ ORDERED INDEX(stage HZ_STAGED_CONTACTS_N1) */ ORG_CONTACT_ID, stage.PARTY_ID'|| l_c_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACTS stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = stage.party_id');
/*
  IF l_party_filter_str IS NOT NULL THEN
    l('          AND EXISTS (');
    l('            SELECT 1 FROM HZ_STAGED_PARTIES p');
    l('            WHERE p.PARTY_ID = stage.PARTY_ID');
    l('            AND ('||l_party_filter_str||'))');
  END IF;
*/
   --Start of BugNo: 4299785
   l('            AND( (l_search_merged =''Y'' )  ');
   l('             OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
   l('             OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
   --End of BugNo: 4299785
  l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');
  l('      END IF;');

  /**** Restrict_sql is not null. Retrieve using intermedia ****/
  l('    ELSE');
  ldbg_s('Restrict Sql is not null');
  l('       l_check := instrb(p_restrict_sql, ''SELECTIVE''); ');
  l('       l_check_dt := instrb(p_restrict_sql, ''SELECTIVE_CT''); ');
  l('       IF (l_check_dt > 0 ) THEN ');
  ldbg_s('Restrict sql has the selective_ct hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_CONTACTS_U1) */''; ');
  l('       ELSIF (l_check > 0 ) THEN ');
  ldbg_s('Restrict sql has the selective hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_CONTACTS_N1) */''; ');
  l('       END IF; ');
  l('       IF l_search_merged = ''Y'' THEN ');
  l('               l_status_sql := '' '' ;  ');
  l('       ELSIF l_search_merged = ''I'' THEN  ');
  l('               l_status_sql := '' AND nvl(p.status,''''A'''') in (''''A'''', ''''I'''')''; ');
  l('       ELSE ');
  l('               l_status_sql := '' AND nvl(p.status,''''A'''') in (''''A'''')''; ');
  l('       END IF; ');
  l('       l_sqlstr := ''SELECT   '' || l_hint || '' ORG_CONTACT_ID, PARTY_ID '|| l_c_select_list||'''||');
  l('                   '' FROM HZ_STAGED_CONTACTS stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  IF l_dyn_party_filter_str IS NOT NULL THEN
    l('                 '' AND EXISTS (''||');
    l('                 '' SELECT 1 FROM HZ_STAGED_PARTIES p '' || ');
    l('                 '' WHERE p.party_id = stage.party_id '' || ');
    l('                 '' AND ('||l_dyn_party_filter_str||') ''|| l_status_sql ||'' ) '' || ');
  END IF;
  --Start of BugNo: 4299785
   l('                  '' AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''||');
   l('                  '' OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''||');
   l('                  '' OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''||');
  --End of BugNo: 4299785
  l('                   '' AND (''||p_restrict_sql||'')'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
  FOR I in 1..l_party_filt_bind.COUNT LOOP
    l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
  END LOOP;
  l('                    ,p_dup_party_id, p_dup_party_id;');
  l('    END IF;');
  l(' 	    output_long_strings(''----------------------------------------------------------'');');
  l('       output_long_strings(''Contacts Contains String = ''||p_contains_str);');
  l('		output_long_strings(''Restrict Sql = ''||p_restrict_sql);');
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Bug: 3392837
  l('      elsif (instrb(SQLERRM,''ORA-20000'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_API_OTHERS_EXCEP'');');
  l('    	 FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    	 FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
  l('  END;');
  l('');
  l('  PROCEDURE open_contact_pt_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            p_search_merged  VARCHAR2, ');
  l('            p_search_rel_cpts  VARCHAR2, ');
  l('            p_person_api  VARCHAR2, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp,');
  l('            p_restrict_entity VARCHAR2 DEFAULT NULL) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  l_hint VARCHAR2(100); ');
  l('  l_check NUMBER; ');
  l('  l_check_dt NUMBER; ');
  l('  l_search_merged VARCHAR2(1); ');
  l('  l_status_sql VARCHAR2(100); ');
  l('  p_restrict_sql1 VARCHAR2(4000); ');
  l(' ');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure open_contact_pt_cursor');
  l('     IF (p_search_merged is null) then ');
  l('        l_search_merged := ''N'';  ');
  l('     ELSE ');
  l('        l_search_merged := p_search_merged; ');
  l('     END IF; ');
  l('  IF p_restrict_entity = ''CONTACTS''    ');
  l('  THEN');
  l('          OPEN x_cursor FOR ');
  l('          SELECT /*+ USE_NL(d stage) ORDERED INDEX(stage HZ_STAGED_CONTACT_POINTS_N2) */ CONTACT_POINT_ID, stage.contact_point_type, stage.PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('          FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACT_POINTS stage ');
  l('          WHERE contains( concat_col, p_contains_str)>0 ');
  l('          AND d.search_context_id = p_search_ctx_id ');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND d.party_id = stage.org_contact_id ; ');
  l('   END IF; ');

  l('  IF p_restrict_entity = ''PARTY_SITES''    ');
  l('  THEN');
  l('          OPEN x_cursor FOR ');
  l('          SELECT /*+ USE_NL(d stage) ORDERED INDEX(stage HZ_STAGED_CONTACT_POINTS_N3) */ CONTACT_POINT_ID, stage.contact_point_type, stage.PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('          FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACT_POINTS stage ');
  l('          WHERE contains( concat_col, p_contains_str)>0 ');
  l('          AND d.search_context_id = p_search_ctx_id ');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND d.party_id = stage.party_site_id ; ');
  l('   END IF; ');

  l(' IF p_restrict_entity IS NULL');
  l(' THEN');

  /**** For a single party_id scenario. Retrieve using party_id, filter using intermedia ****/
  l('     IF p_party_id IS NOT NULL THEN');
  ldbg_s('Single Party Scenario');
  l('       IF p_search_rel_cpts = ''N'' THEN');
  l('         OPEN x_cursor FOR ');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N1) */ CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('          FROM HZ_STAGED_CONTACT_POINTS stage');
  l('          WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND stage.party_id = p_party_id; ');
  l('       ELSE');
  l('         OPEN x_cursor FOR ');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N1) */ CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('          FROM HZ_STAGED_CONTACT_POINTS stage');
  l('          WHERE contains( concat_col, p_contains_str)>0');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND stage.party_id = p_party_id ');
  l('          UNION');
  l('          SELECT /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N2) */ stage.CONTACT_POINT_ID, stage.contact_point_type, stage.PARTY_ID, stage.PARTY_SITE_ID, stage.ORG_CONTACT_ID '|| l_cpt_select_list);
  l('          FROM HZ_STAGED_CONTACT_POINTS stage, hz_relationships r, hz_org_contacts oc');
  l('          WHERE contains( concat_col, p_contains_str)>0');
  l('          AND r.object_id = p_party_id ');
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('                    AND r.subject_id = stage.party_id ');
  l('                    AND r.SUBJECT_TABLE_NAME = ''HZ_PARTIES'' ' );
  l('                    AND r.OBJECT_TABLE_NAME = ''HZ_PARTIES'' ');
  l('                    AND r.relationship_id = oc.party_relationship_id');
  l('                    AND oc.org_contact_id = stage.org_contact_id; ');
  l('      END IF;');

  /**** If restrict_sql is NULL or if p_search_ctx_id is not null, execute static queries **/
  l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');
  ldbg_s('Either Restrict sql is null or search_context_id is not null');
  /**** When p_search_ctx_id IS NULL, retreive using intermedia index ***/
  l('      IF p_search_ctx_id IS NULL THEN');
  ldbg_s('Either Search context id is null');
  l('        OPEN x_cursor FOR ');
  l('          SELECT CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('          FROM HZ_STAGED_CONTACT_POINTS stage');
  IF l_party_filter_str IS NOT NULL THEN
    l('        WHERE contains( concat_col, p_contains_str)>0');
    l('        AND EXISTS (');
    l('          SELECT 1 FROM HZ_STAGED_PARTIES p');
    l('          WHERE p.PARTY_ID = stage.PARTY_ID');
    l('          AND( (l_search_merged =''Y'' )  ');
    l('          OR (l_search_merged = ''I'' AND nvl(p.status, ''A'') in (''A'', ''I''))  ');
    l('          OR (l_search_merged = ''N'' AND nvl(p.status, ''A'') in (''A''))       )  ');
    l('          AND ('||l_party_filter_str||'))');
  ELSE
    l('        WHERE contains( concat_col, p_contains_str)>0');
  END IF;
  --Start of BugNo: 4299785
  l('          AND( (l_search_merged =''Y'' )  ');
  l('           OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');

  /***** Search_ctx_id is not null. Reteive using HZ_DQM_PARTIES_GT ****/
  l('      ELSE');
  ldbg_s('Search_context_id is not null');
  l('        IF p_person_api = ''Y'' THEN');
  l('          OPEN x_cursor FOR ');
  l('            SELECT CONTACT_POINT_ID, stage.contact_point_type, stage.PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACT_POINTS stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = stage.party_id');
  --Start of BugNo: 4299785
  l('            AND( (l_search_merged =''Y'' )  ');
  l('             OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('             OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id)');
  l('            UNION ');
  l('            SELECT /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N2) */ CONTACT_POINT_ID, stage.contact_point_type, r.subject_id, stage.PARTY_SITE_ID, stage.ORG_CONTACT_ID '|| l_cpt_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc, HZ_STAGED_CONTACT_POINTS stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = r.subject_id');
  l('            AND r.relationship_id = oc.party_relationship_id');
  l('            AND oc.org_contact_id = stage.org_contact_id');
  --Start of BugNo: 4299785
  l('            AND( (l_search_merged =''Y'' )  ');
  l('             OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('             OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('            AND (p_dup_party_id IS NULL OR r.subject_id <> p_dup_party_id);');
  l('        ELSE');
  l('          OPEN x_cursor FOR ');
  l('            SELECT  CONTACT_POINT_ID, stage.contact_point_type, stage.PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID '|| l_cpt_select_list);
  l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACT_POINTS stage');
  l('            WHERE contains( concat_col, p_contains_str)>0');
  l('            AND d.search_context_id = p_search_ctx_id');
  l('            AND d.party_id = stage.party_id');
  --Start of BugNo: 4299785
  l('            AND( (l_search_merged =''Y'' )  ');
  l('             OR (l_search_merged = ''I'' AND nvl(stage.status_flag, ''A'') in (''A'', ''I''))  ');
  l('             OR (l_search_merged = ''N'' AND nvl(stage.status_flag, ''A'') = ''A'')       )  ');
  --End of BugNo: 4299785
  l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');
  l('        END IF;');

  l('      END IF;');

  /**** Restrict_sql is not null. Retrieve using intermedia ****/
  l('    ELSE');
  ldbg_s('Restrict sql is not null');
  l('       l_check := instrb(p_restrict_sql, ''SELECTIVE''); ');
  l('       l_check_dt := instrb(p_restrict_sql, ''SELECTIVE_CPT''); ');
  l('       IF (l_check_dt > 0 ) THEN ');
  ldbg_s('Restrict Sql has the selective_cpt hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_U1) */''; ');
  l('       ELSIF (l_check > 0 ) THEN ');
  ldbg_s('Restrict Sql has the selective hint');
  l('           l_hint := ''/*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N1) */''; ');
  l('       END IF; ');
  l('       IF l_search_merged = ''Y'' THEN ');
  l('               l_status_sql := '' '' ;  ');
  l('       ELSIF l_search_merged = ''I'' THEN  ');
  l('               l_status_sql := '' AND nvl(p.status,''''A'''') in (''''A'''', ''''I'''')''; ');
  l('       ELSE ');
  l('               l_status_sql := '' AND nvl(p.status,''''A'''') in (''''A'''')''; ');
  l('       END IF; ');
 /* IT Performance Bug:4589953, if person API then check for relationship contact points */
  l('       IF p_person_api = ''Y'' THEN');
  l(' 		/*Performance fix for Bug:4589953*/ ');
  l('       IF (l_check > 0 ) THEN ');
     l('       IF instrb(p_restrict_sql, ''STAGE.'') > 0 THEN ');
     l('       	p_restrict_sql1 := replace( p_restrict_sql, ''STAGE.'', ''stage1.'');');
     l('       ELSIF instrb(p_restrict_sql, ''stage.'') > 0 THEN ');
     l('       	p_restrict_sql1 := replace( p_restrict_sql, ''stage.'', ''stage1.'');');
     l('       ELSE');
     l('		p_restrict_sql1 := ''stage1.''||p_restrict_sql;');
  l('       END IF; ');
  l('       	l_sqlstr := '' SELECT   /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N1) */ CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID  '|| l_cpt_select_list||'''||');
  l('                   '' FROM HZ_STAGED_CONTACT_POINTS stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0  ''||');
  l('                   '' AND (stage.org_contact_id is null ''||');
  --Start of BugNo: 4299785
  l('                   '' AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''||');
  --End of BugNo: 4299785
  l('                   '' AND (''||p_restrict_sql||''))'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) '' ||');
  l('                   '' UNION '' ||');
  l('                   '' SELECT   /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N2) */ CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID  '|| l_cpt_select_list||'''||');
  l('                   '' FROM HZ_STAGED_CONTACT_POINTS stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0  ''||');
  --Start of BugNo: 4299785
  l('                   '' AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''||');
  --End of BugNo: 4299785
    l('                 '' AND (stage.org_contact_id in '' || ');
    l('                 '' ( SELECT org_contact_id from HZ_ORG_CONTACTS oc, (select object_id, relationship_id, subject_id party_id from hz_relationships r '' ||');
    l('                 '' where subject_type = ''''PERSON'''' AND object_type = ''''ORGANIZATION'''') stage1 '' || ');
    l('                 '' where stage1.relationship_id = oc.party_relationship_id '' || ');
	l('                 '' and (''||p_restrict_sql1 || '') ) )'' ||') ;
    l('                 '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str,');
  l('                    p_dup_party_id, p_dup_party_id, p_contains_str, p_dup_party_id, p_dup_party_id;');

  l('       ELSE ');
  l('       	l_sqlstr := ''SELECT   '' || l_hint ||'' CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID  '|| l_cpt_select_list||'''||');
  l('                   '' FROM HZ_STAGED_CONTACT_POINTS stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  IF l_dyn_party_filter_str IS NOT NULL THEN
    l('                 '' AND EXISTS (''||');
    l('                 '' SELECT 1 FROM HZ_STAGED_PARTIES p '' || ');
    l('                 '' WHERE p.party_id = stage.party_id '' || ');
    l('                 '' AND ('||l_dyn_party_filter_str||')  ''|| l_status_sql ||'' ) '' || ');
  END IF;
  --Start of BugNo: 4299785
  l('                   '' AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''||');
  --End of BugNo: 4299785
  l('                   '' AND (''||get_adjusted_restrict_sql(p_restrict_sql)||'')'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
  FOR I in 1..l_party_filt_bind.COUNT LOOP
    l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
  END LOOP;
  l('                    ,p_dup_party_id, p_dup_party_id;');
  l('       END IF; ');

  l('       ELSE ');
  l('       	l_sqlstr := ''SELECT   '' || l_hint ||'' CONTACT_POINT_ID, stage.contact_point_type, PARTY_ID, PARTY_SITE_ID, ORG_CONTACT_ID  '|| l_cpt_select_list||'''||');
  l('                   '' FROM HZ_STAGED_CONTACT_POINTS stage''||');
  l('                   '' WHERE contains( concat_col, :cont)>0''||');
  IF l_dyn_party_filter_str IS NOT NULL THEN
    l('                 '' AND EXISTS (''||');
    l('                 '' SELECT 1 FROM HZ_STAGED_PARTIES p '' || ');
    l('                 '' WHERE p.party_id = stage.party_id '' || ');
    l('                 '' AND ('||l_dyn_party_filter_str||')  ''|| l_status_sql ||'' ) '' || ');
  END IF;
  --Start of BugNo: 4299785
  l('                   '' AND( (''''''||l_search_merged||'''''' =''''Y'''' )  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''I'''' AND nvl(stage.status_flag, ''''A'''') in (''''A'''', ''''I''''))  ''||');
  l('                   ''   OR (''''''||l_search_merged||'''''' = ''''N'''' AND nvl(stage.status_flag, ''''A'''') = ''''A'''')       )  ''||');
  --End of BugNo: 4299785
  l('                   '' AND (''||p_restrict_sql||'')'' ||');
  l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
  l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
  FOR I in 1..l_party_filt_bind.COUNT LOOP
    l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
  END LOOP;
  l('                    ,p_dup_party_id, p_dup_party_id;');
  l('       END IF; ');
  l('    END IF;');
  l('  END IF; ');
  l(' 	    output_long_strings(''----------------------------------------------------------'');');
  l('       output_long_strings(''Contact Points Contains String = ''||p_contains_str);');
  l('		output_long_strings(''Restrict Sql = ''||p_restrict_sql);');
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --Bug: 3392837
  l('      elsif (instrb(SQLERRM,''ORA-20000'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_API_OTHERS_EXCEP'');');
  l('    	 FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    	 FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
  l('  END;');
  l('');

 l('');
 l('  PROCEDURE return_direct_matches(p_restrict_sql VARCHAR2, p_match_str VARCHAR2, p_thresh NUMBER, p_search_ctx_id NUMBER, p_search_merged VARCHAR2, p_dup_party_id NUMBER, x_num_matches OUT NUMBER) IS');

  l('    l_sqlstr VARCHAR2(4000);');
  l('    l_search_merged VARCHAR2(1);');
  l('  BEGIN');
  l('    IF (p_search_merged is null) then ');
  l('       l_search_merged := ''N'';  ');
  l('    ELSE ');
  l('       l_search_merged := p_search_merged; ');
  l('    END IF; ');
  l('    IF p_restrict_sql IS NULL THEN');
  l('      INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
  l('      SELECT p_search_ctx_id, PARTY_ID, '||l_party_name_score);
  l('      FROM hz_staged_parties ');
  l('      WHERE TX8 LIKE g_party_stage_rec.TX8||'' %''');
  l('      AND ((g_party_stage_rec.TX36 IS NULL OR g_party_stage_rec.TX36||'' '' =  TX36))');
  l('      AND( (l_search_merged =''Y'' ) ');
  l('           OR (l_search_merged = ''I'' AND nvl(status, ''A'') in (''A'', ''I''))  ');
  l('           OR (l_search_merged = ''N'' AND nvl(status, ''A'') in (''A'')))  ');
  l('      AND (p_dup_party_id IS NULL OR party_id <> p_dup_party_id)');
  l('      AND rownum <= p_thresh;');
  l('    ELSE');
  l_party_name_score:=replace(replace(l_party_name_score,'g_party_stage_rec.TX8',':TX8'),'''','''''');
  l('      l_sqlstr := ''INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) SELECT :ctx_id, PARTY_ID, '||l_party_name_score||' FROM hz_staged_parties stage '';');
  l('      l_sqlstr := l_sqlstr || '' WHERE TX8 like :TX8||'''' %'''' '';');
  l('      l_sqlstr := l_sqlstr || '' AND (:TX36 IS NULL OR :TX36||'''' '''' =  TX36) '';');
  l('      IF l_search_merged = ''N'' THEN');
  l('        l_sqlstr := l_sqlstr || '' AND nvl(status,''''A'''')=''''A'''' '';');
  l('      ELSIF l_search_merged = ''Y'' THEN');
  l('        l_sqlstr := l_sqlstr || '' AND nvl(status,''''A'''') in (''''A'''',''''I'''') '';');
  l('      END IF;');
  l('      l_sqlstr := l_sqlstr || '' AND (:p_dup IS NULL OR party_id <> :p_dup ) '';');
  l('     l_sqlstr := l_sqlstr || '' AND ''||p_restrict_sql||'' '';');
  l('     l_sqlstr := l_sqlstr || '' AND ROWNUM <= :thresh '';');

  IF l_purpose  IN ('S','W') THEN
    l('     EXECUTE IMMEDIATE l_sqlstr USING p_search_ctx_id, g_party_stage_rec.TX8,g_party_stage_rec.TX8,g_party_stage_rec.TX36,g_party_stage_rec.TX36,p_dup_party_id,p_dup_party_id,p_thresh;');
  ELSE
    l('     EXECUTE IMMEDIATE l_sqlstr USING p_search_ctx_id, g_party_stage_rec.TX8,g_party_stage_rec.TX36,g_party_stage_rec.TX36,p_dup_party_id,p_dup_party_id,p_thresh;');
  END IF;

  l('    END IF;');
  l('    x_num_matches := SQL%ROWCOUNT;');
  l('  END;');
  l('');
  l('  FUNCTION get_new_score_rec (');
  l('    	 p_init_total_score NUMBER,');
  l('    	 p_init_party_score NUMBER,');
  l('    	 p_init_party_site_score NUMBER,');
  l('    	 p_init_contact_score NUMBER,');
  l('    	 p_init_contact_point_score NUMBER, ');
  l('    	 p_party_id NUMBER, ');
  l('    	 p_party_site_id NUMBER, ');
  l('    	 p_org_contact_id NUMBER, ');
  l('    	 p_contact_point_id NUMBER) ');
  l('     RETURN HZ_PARTY_SEARCH.score_rec IS');
  l('    l_score_rec HZ_PARTY_SEARCH.score_rec;');
  l('  BEGIN');
  ldbg_s('-----------------','calling the function get_new_score_rec to set the l_score_rec structure');
  l('    l_score_rec.TOTAL_SCORE := p_init_total_score;');
  l('    l_score_rec.PARTY_SCORE := p_init_party_score;');
  l('    l_score_rec.PARTY_SITE_SCORE := p_init_party_site_score;');
  l('    l_score_rec.CONTACT_SCORE := p_init_contact_score;');
  l('    l_score_rec.CONTACT_POINT_SCORE := p_init_contact_point_score;');
  l('    l_score_rec.PARTY_ID := p_party_id;');
  l('    l_score_rec.PARTY_SITE_ID := p_party_site_id;');
  l('    l_score_rec.ORG_CONTACT_ID := p_org_contact_id;');
  l('    l_score_rec.CONTACT_POINT_ID := p_contact_point_id;');
  l('    RETURN l_score_rec;');
  l('  END;');
END IF; ---Code Change for Match Rule Set
  l('');
  l('   /**********************************************************');
  l('   This procedure finds the set of parties that match the search');
  l('   criteria and returns a scored set of parties');
  l('');
  l('   The steps in executing the search are as follows');
  l('    1. Initialization and error checks');
  l('    2. Setup of intermedia query strings for Acquisition query');
  l('    3. Execution of Acquisition query');
  l('    4. Execution of Secondary queries to score results');
  l('    5. Setup of data temporary table to return search results');
  l('   **********************************************************/');
  l('');
  -- Generated
  l('PROCEDURE find_parties (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_dup_party_id          IN      NUMBER,');
  l('      p_dup_set_id            IN      NUMBER,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_denorm_str VARCHAR2(32000);');
  l('  l_ps_denorm_str VARCHAR2(32000);');
  l('  l_ct_denorm_str VARCHAR2(32000);');
  l('  l_cpt_denorm_str VARCHAR2(32000);');

  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_match_idx NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('  H_PARTY_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_PARTY_ID_LIST HZ_PARTY_SEARCH.IDList;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_cpt_type VARCHAR2(100);');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_ps_contact_id NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('  l_denorm_max_score NUMBER;');
  l('  l_non_denorm_max_score NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_max_thresh NUMBER;');
  l('  l_tmp NUMBER;');
  l('  l_merge_flag VARCHAR2(1);');
  l('  l_num_eval NUMBER:=0;');
  l('');
  l('  --Fix for bug 4417124 ');
  l('  l_use_contact_addr_info BOOLEAN := TRUE;');
  l('  l_use_contact_cpt_info BOOLEAN  := TRUE;');
  l('  l_use_contact_addr_flag VARCHAR2(1) := ''Y'';');
  l('  l_use_contact_cpt_flag  VARCHAR2(1) := ''Y'';');
  l('');
  l('  L_RETURN_IMM_EXC EXCEPTION;');
  l('');
  l('  ');
  l('  /********************* Find Parties private procedures *******/');

  l('  PROCEDURE push_eval IS');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure push_eval');
  ldbg_s('Emptying the lists H_PARTY_ID, H_PARTY_ID_LIST and H_SCORES');
  l('    H_PARTY_ID.DELETE;');
  l('    H_PARTY_ID_LIST.DELETE;');
  l('    H_SCORES.DELETE;        ');
  l('    g_mappings.DELETE;');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(0);');
  l('    call_order(5) := call_order(1);');
  l('    call_type(5) := ''AND'';');
  l('    call_max_score(5) := call_max_score(1);');
  l('    call_type(2) := ''OR'';');
  l('  END;');

  l('');
  l('  /**  Private procedure to acquire and score at party level  ***/');
  l('  PROCEDURE eval_party_level(p_party_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    l_precalc_score BOOLEAN := FALSE;');
  l('    l_TX35_new varchar2(4000);');--9155543
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure eval_party_level');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  ldbg_s('Match rule is AND and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is OR and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      IF (p_restrict_sql IS NULL OR instrb(p_restrict_sql, ''SELECTIVE'')=0)');
  l('         and check_estimate_hits(''PARTY'',p_party_contains_str)>l_max_thresh THEN');
  ldbg_s('In eval party level estimated hits exceed threshold');
  l('        IF g_party_stage_rec.TX8 IS NOT NULL AND nvl(FND_PROFILE.VALUE(''HZ_DQM_PN_THRESH_RESOLUTION''),''NONE'')=''SQL'' AND p_dup_batch_id IS NULL THEN');
  ldbg_s('In eval party level resolution options is set to SQL search.');
  l('          IF (l_party_site_contains_str IS NULL AND');
  l('             l_contact_contains_str IS NULL AND');
  l('             l_contact_pt_contains_str IS NULL) AND NOT g_other_party_level_attribs AND p_dup_set_id IS NULL THEN');
  l('            return_direct_matches(p_restrict_sql,l_match_str,l_max_thresh,l_search_ctx_id,p_search_merged,p_dup_party_id, x_num_matches);');
  l('            RAISE L_RETURN_IMM_EXC;');
  l('          ELSE');
  l('            open_party_cursor_direct(p_dup_party_id, p_restrict_sql, l_match_str,p_search_merged,p_party_contains_str,l_party_cur);');
  l('          END IF;');
  l('        ELSE');
  l('          IF p_index>1 THEN');
  ldbg_s('In eval party level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('      END IF;');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  ldbg_s('========== START LOOPING THROUGH WHAT IS RETURNED BY OPEN_PARTY_CURSOR ================');
  l('    IF l_party_cur IS NULL OR (not l_party_cur%ISOPEN) THEN');
  l('      open_party_cursor(p_dup_party_id, p_restrict_sql, p_party_contains_str,l_ctx_id, l_match_str,p_search_merged,l_party_cur);');
  l('    END IF;');
  l('    LOOP ');
  l('      FETCH l_party_cur INTO');
  l('         l_party_id '||l_p_into_list||';');
  l('      EXIT WHEN l_party_cur%NOTFOUND;');
  l('      l_index := map_id(l_party_id);');
     IF(l_p_param_list LIKE '%TX35%') THEN--9155543
  l('  l_TX35_new:=RTRIM(LTRIM(l_TX35));');
 	l('  l_TX35_new:=(CASE l_TX35_new WHEN ''SYNC'' THEN HZ_STAGE_MAP_TRANSFORM.den_acc_number (l_party_id) ELSE l_TX35_new END);');
 	            l_p_param_list:=replace(l_p_param_list,'l_TX35','l_TX35_new');
 	   END IF;
  l('      l_score := GET_PARTY_SCORE('||l_p_param_list||');');
    l_p_param_list:=replace(l_p_param_list,'l_TX35_new','l_TX35');
  l('      IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('        H_SCORES(l_index) := get_new_score_rec(l_score,l_score,defps,defct,defcpt, l_party_id, null, null,null);');
  l('      ELSE');
  l('        H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE+l_score;');
  l('        H_SCORES(l_index).PARTY_SCORE := l_score;');
  l('      END IF;');
  l('      IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('        H_PARTY_ID_LIST(l_index) := 1;');
  l('        H_PARTY_ID(l_party_id_idx) := l_party_id;');
  l('        l_party_id_idx:= l_party_id_idx+1;');
  l('      END IF;');
  l('      IF (l_party_id_idx-1)>l_max_thresh THEN');
  l('        IF p_index=1 AND call_order(2) = ''PARTY_SITE'' ');
  l('          AND call_type(2) = ''AND'' AND l_contact_contains_str IS NULL');
  l('          AND nvl(FND_PROFILE.VALUE(''HZ_DQM_PN_THRESH_RESOLUTION''),''NONE'')=''SQL'' ');
  l('          AND l_contact_pt_contains_str IS NULL THEN');
  l('            EXIT;');
  l('        END IF;');
  l('	      CLOSE l_party_cur;'); --Bug No: 3872745
  l('        IF p_index>1 THEN');
  ldbg_s('In eval party level estimated hits exceed threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'In eval_party_level l_party_id = ','l_party_id');
  dc(fnd_log.level_statement,'In eval_party_level l_score = ','l_score');
  de;
  l('    END LOOP;');
  ldbg_s('===========END of LOOP=====================');
  l('    CLOSE l_party_cur;');
  l('    ROLLBACK to eval_start;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_party_site_level(p_party_site_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    h_ps_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure eval_party_site_level');
  l('  IF (l_party_contains_str IS NOT NULL AND instrb(l_party_contains_str,''D_PS'')>0');
  l('      AND l_contact_contains_str IS NULL and H_PARTY_ID.COUNT > 0 and');
  l('      l_contact_pt_contains_str IS NULL) AND g_ps_den_only AND p_ins_details <> ''Y'' THEN');
  l('    l_party_id := H_SCORES.FIRST;');
  l('    WHILE l_party_id IS NOT NULL LOOP');
  l('      H_SCORES(l_party_id).TOTAL_SCORE := H_SCORES(l_party_id).TOTAL_SCORE + p_emax_score;');
  l('      l_party_id:=H_SCORES.NEXT(l_party_id);');
  l('    END LOOP;');
  l('    RETURN;');

  l('  END IF;');

  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is AND and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is OR and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      IF (p_restrict_sql IS NULL OR instrb(p_restrict_sql, ''SELECTIVE'')=0)');
  l('         and check_estimate_hits(''PARTY_SITES'',p_party_site_contains_str)>l_max_thresh THEN');
  ldbg_s('In eval party site level estimated hits exceed threshold');
  l('        IF p_index>1 THEN');
  ldbg_s('In eval party site level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');

  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('      l_ctx_id := NULL;');
  l('    END IF;');
  ldbg_s('========== START LOOPING THROUGH WHAT IS RETURNED BY OPEN_PARTY_SITE_CURSOR ================');
  l('    open_party_site_cursor(p_dup_party_id,NULL, p_restrict_sql, p_party_site_contains_str,l_ctx_id,  p_search_merged, ''N'',''N'',l_party_site_cur);');
  l('    LOOP ');
  l('      FETCH l_party_site_cur INTO');
  l('         l_party_site_id, l_ps_party_id, l_ps_contact_id '||l_ps_into_list||';');
  l('      EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('      --Fix for bug 4417124 ');
  l('      IF l_use_contact_addr_info OR l_ps_contact_id IS NULL THEN');
  l('        l_index := map_id(l_ps_party_id);');
  l('        l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          H_SCORES(l_index) := get_new_score_rec(l_score,defpt,l_score,defct,defcpt, l_ps_party_id, l_party_site_id, null,null);');
  l('        ELSE');
  l('          IF l_score > H_SCORES(l_index).PARTY_SITE_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).PARTY_SITE_SCORE+l_score;');
  l('            H_SCORES(l_index).PARTY_SITE_SCORE := l_score;');
  l('          END IF;');
  l('        END IF;');
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_ps_party_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
  l('          h_ps_id(detcnt) := l_party_site_id;');
  l('          h_ps_party_id(detcnt) := l_ps_party_id;');
  l('          IF (p_emax_score > 0) THEN ');
  l('              h_ps_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('          ELSE ');
  l('              h_ps_score(detcnt) := 0; ');
  l('          END IF; ');
  l('          detcnt := detcnt +1;');
  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'In eval_party_site_level l_party_site_id = ','l_party_site_id');
  dc(fnd_log.level_statement,'In eval_paty_site_level l_ps_party_id = ','l_ps_party_id');
  dc(fnd_log.level_statement,'In eval_party_site_level l_score = ','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  ldbg_s('===========END of LOOP=====================');
  l('    CLOSE l_party_site_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
 ldbg_s('In eval_party_site_level inserting into HZ_MATCHED_PARTY_SITES_GT from the H_PS_ID list');
  l('      FORALL I in 1..h_ps_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID,PARTY_SITE_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_ps_id(I), h_ps_party_id(I), h_ps_score(I));');
  l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at contact point level  ***/');
  l('  PROCEDURE eval_contact_level(p_contact_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    h_ct_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure eval_contact_level');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type=''AND'' THEN');
  ldbg_s('Match rule is AND and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is OR and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      IF (p_restrict_sql IS NULL OR instrb(p_restrict_sql, ''SELECTIVE'')=0)');
  l('         and check_estimate_hits(''CONTACTS'',p_contact_contains_str)>l_max_thresh THEN');
  ldbg_s('In eval contact level estimated hits exceed threshold');
  l('        IF p_index>1 THEN');
  ldbg_s('In eval contact level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  ldbg_s('========== START LOOPING THROUGH WHAT IS RETURNED BY OPEN_CONTACT_CURSOR ================');
  l('    open_contact_cursor(p_dup_party_id,NULL, p_restrict_sql, p_contact_contains_str,l_ctx_id,  p_search_merged, l_contact_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_cur INTO');
  l('         l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('      EXIT WHEN l_contact_cur%NOTFOUND;');
  l('      l_index := map_id(l_ct_party_id);');
  l('      l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');

  l('      IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('        H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,l_score,defcpt, l_ct_party_id, null, l_org_contact_id,null);');
  l('      ELSE');
  l('        IF l_score > H_SCORES(l_index).CONTACT_SCORE THEN');
  l('          H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_SCORE+l_score;');
  l('          H_SCORES(l_index).CONTACT_SCORE := l_score;');
  l('        END IF;');
  l('      END IF;');
  l('      IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('        H_PARTY_ID_LIST(l_index) := 1;');
  l('        H_PARTY_ID(l_party_id_idx) := l_ct_party_id;');
  l('        l_party_id_idx:= l_party_id_idx+1;');
  l('      END IF;');
  l('      IF p_ins_details = ''Y'' THEN');
  l('        h_ct_id(detcnt) := l_org_contact_id;');
  l('        h_ct_party_id(detcnt) := l_ct_party_id;');
  l('        IF (p_emax_score > 0) THEN ');
  l('            h_ct_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('        ELSE ');
  l('            h_ct_score(detcnt) := 0; ');
  l('        END IF; ');
  l('        detcnt := detcnt +1;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'In eval_contact_level l_org_contact_id = ','l_org_contact_id');
  dc(fnd_log.level_statement,'In eval_contact_level l_ct_party_id = ','l_ct_party_id');
  dc(fnd_log.level_statement,'In eval_contact_level l_score = ','l_score');
  de;
  l('    END LOOP;');
  ldbg_s('===========END of LOOP=====================');
  l('    CLOSE l_contact_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
  ldbg_s('In eval_contact_level inserting into HZ_MATCHED_CONTACTS_GT from the H_CT_ID list');
  l('      FORALL I in 1..h_ct_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID,ORG_CONTACT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_ct_id(I), h_ct_party_id(I), h_ct_score(I));');
  l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at contact point level  ***/');
  l('  PROCEDURE eval_cpt_level(p_contact_pt_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER, p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    h_cpt_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('    l_cpt_flag VARCHAR2(1) := ''N'';');

  --l('    l_continue VARCHAR2(1) := ''Y'';');
  l('    is_a_match VARCHAR2(1) := ''Y'';');
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure eval_cpt_level');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is AND and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is OR and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      IF (p_restrict_sql IS NULL OR instrb(p_restrict_sql, ''SELECTIVE'')=0)');
  l('         and check_estimate_hits(''CONTACT_POINTS'',p_contact_pt_contains_str)>l_max_thresh THEN');
  ldbg_s('In eval contact point level estimated hits exceed threshold');
  l('        IF p_index>1 THEN');
  ldbg_s('In eval contact point level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');

  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  ldbg_s('========== START LOOPING THROUGH WHAT IS RETURNED BY OPEN_CONTACT_PT_CURSOR ================');
  l('    open_contact_pt_cursor(p_dup_party_id,NULL, p_restrict_sql, p_contact_pt_contains_str,l_ctx_id,  p_search_merged, ''N'', ''N'',l_contact_pt_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_pt_cur INTO');
  l('         l_contact_pt_id,  l_cpt_type, l_cpt_party_id,  l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('      EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  ldbg_s('----------------------------------------------------------------------------------');
  ldbg_sv('Processing party_id - ','l_cpt_party_id');
  ldbg_sv('Contact Point Type - ','l_cpt_type');
  l('      --Fix for bug 4417124 ');
  l('      IF l_use_contact_cpt_info OR l_cpt_contact_id IS NULL THEN');
  l('        l_index := map_id(l_cpt_party_id);');
  l('        l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id,l_contact_pt_id);');
  if l_purpose IN ('S','W') then
    l('          H_SCORES(l_index).cpt_type_match(l_cpt_type) := l_score;');
    ldbg_s('Processing second Time for this party');
  else
   	ldbg_s('Processing First Time for this party');
  end if;
  ldbg_sv('l_index is - ','l_index');

   l('        ELSE');
  if l_purpose IN ('S','W') then
    l('          IF(H_SCORES(l_index).cpt_type_match.EXISTS(l_cpt_type)) then');
    l('            IF l_score > H_SCORES(l_index).cpt_type_match(l_cpt_type) then');
    l('              H_SCORES(l_index).TOTAL_SCORE :=');
    l('              H_SCORES(l_index).TOTAL_SCORE-(H_SCORES(l_index).CONTACT_POINT_SCORE-H_SCORES(l_index).cpt_type_match(l_cpt_type))+l_score;');
    l('              H_SCORES(l_index).CONTACT_POINT_SCORE := H_SCORES(l_index).CONTACT_POINT_SCORE-H_SCORES(l_index).cpt_type_match(l_cpt_type) + l_score;');
    l('              H_SCORES(l_index).cpt_type_match(l_cpt_type) := l_score;');
    ldbg_s('Passed in score greater than existing score');
    ldbg_sv('H_SCORES(l_index).TOTAL_SCORE is - ' , 'H_SCORES(l_index).TOTAL_SCORE' );
    ldbg_sv('H_SCORES(l_index).CONTACT_POINT_SCORE is - ' , 'H_SCORES(l_index).CONTACT_POINT_SCORE' );
    ldbg_sv('H_SCORES(l_index).cpt_type_match(l_cpt_type) is - ', 'H_SCORES(l_index).cpt_type_match(l_cpt_type)' );
    l('            END IF;');
    l('          ELSE');
    ldbg_s('Passed in score less than or equal to the existing score ');
    l('            H_SCORES(l_index).TOTAL_SCORE :=');
    l('            		H_SCORES(l_index).TOTAL_SCORE+l_score;');
    l('            H_SCORES(l_index).CONTACT_POINT_SCORE := H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
    l('            H_SCORES(l_index).cpt_type_match(l_cpt_type) := l_score;');
    ldbg_sv('H_SCORES(l_index).TOTAL_SCORE is - ','H_SCORES(l_index).TOTAL_SCORE' );
    ldbg_sv('H_SCORES(l_index).CONTACT_POINT_SCORE is - ','H_SCORES(l_index).CONTACT_POINT_SCORE' );
    ldbg_sv('H_SCORES(l_index).cpt_type_match(l_cpt_type) is - ','H_SCORES(l_index).cpt_type_match(l_cpt_type)' );
    l('          END IF;');
  else

  l('          IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('            H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('          END IF;');
 end if;
  l('        END IF;');
  ldbg_sv('call type is - ','p_call_type'  );
  ldbg_sv('match string is - ','l_match_str' );
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  if l_purpose  IN ('S','W')then
    l('          -- If rule is match all ');
    l('          IF l_match_str = '' AND '' THEN');
    ldbg_s('Match string is AND ');
    l('            IF H_SCORES(l_index).cpt_type_match.count = distinct_search_cpt_types then');
    l('              is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ' , 'is_a_match');
    l('            ELSE');
    l('              is_a_match := ''N'';');
    ldbg_sv('is_a_match is ' , 'is_a_match');
    l('            END IF;');
    l('          -- Else it is construed to be a match anyway');
    l('          ELSE');
    l('            is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ' , 'is_a_match');
    l('          END IF;');
    l('        IF (is_a_match=''Y'') then');
 end if;

  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_cpt_party_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  if l_purpose IN ('S','W') then
  l('      end if;');
  end if;
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
 if l_purpose  IN ('S','W') then
    l('          IF l_match_str = '' AND '' THEN');
    ldbg_s('Match string is AND ');
    l('            IF H_SCORES(l_index).cpt_type_match.count = distinct_search_cpt_types then');
    l('              is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ' , 'is_a_match');
    l('            ELSE');
    l('              is_a_match := ''N'';');
    ldbg_sv('is_a_match is ' , 'is_a_match');
    l('            END IF;');
    l('          ELSE');
    l('            is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ' , 'is_a_match');
    l('          END IF;');
    l('          IF (is_a_match=''Y'') THEN');
 end if;
  l('          FOR I IN 1..h_cpt_id.COUNT LOOP');
  l('          IF h_cpt_id(I)=l_contact_pt_id THEN');
  l('          	 l_cpt_flag := ''Y'';');
  l('          END IF;');
  l('          END LOOP;');
  l('          IF l_cpt_flag = ''Y'' THEN');
  l('          	 NULL;');
  l('          ELSE');
  l('         	 h_cpt_id(detcnt) := l_contact_pt_id;');
  l('          	 h_cpt_party_id(detcnt) := l_cpt_party_id;');
  l('          	 IF (p_emax_score > 0) THEN ');
  l('              h_cpt_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('            ELSE ');
  l('              h_cpt_score(detcnt) := 0; ');
  l('          	 END IF; ');
  l('            detcnt := detcnt +1;');
  l('          END IF;');

  if l_purpose IN ('S','W') then
  l('      end if;');
  end if;

  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'In eval_cpt_level l_contact_pt_id = ','l_contact_pt_id');
  dc(fnd_log.level_statement,'In eval_cpt_level l_cpt_party_id = ','l_cpt_party_id');
  dc(fnd_log.level_statement,'In eval_cpt_level l_score = ','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  ldbg_s('===========END of LOOP=====================');
  l('    CLOSE l_contact_pt_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
  ldbg_s('In eval_contact_point_level inserting into HZ_MATCHED_CPTS_GT from the H_CPT_ID list');
  l('      FORALL I in 1..h_cpt_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CPTS_GT (SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_cpt_id(I), h_cpt_party_id(I), h_cpt_score(I));');
  l('    END IF;');
  l('  END eval_cpt_level;');
  l('');
  l('  /**  Private procedure to call the eval procedure at each entity in the correct order ***/');
  l('  PROCEDURE do_eval (p_index NUMBER) IS');
  l('    l_ctx_id NUMBER;');
  l('    l_threshold NUMBER;'); --Bug No: 4407425
  l('    other_acq_criteria_exists BOOLEAN; '); --Bug No: 4407425
  l('    acq_cnt NUMBER; '); --Bug No:5218095
  l('  BEGIN');
  ldbg_s('-----------------','calling the procedure do_eval');
  --Start of Bug No: 4407425
  l('    IF (p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0) THEN');
  IF(l_purpose ='S') THEN
  l('     l_threshold :=  round(( l_entered_max_score / '|| l_max_score ||') * '|| l_match_threshold ||'); ');
  ELSE
  l('     l_threshold := '|| l_match_threshold ||';  ');
  END IF;
  l('    other_acq_criteria_exists := TRUE ;');
  --Start of Bug No:5218095
  /*l('    IF (call_max_score(2) = 0 and call_max_score(3) = 0 and call_max_score(4) = 0 ) THEN ');
  l('     other_criteria_exists := FALSE; ');
  l('    END IF ; ');*/
  l('    --check if acquisition criteria exists for any other entity');
  l('    IF l_party_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := 1; ');
  l('    END IF; ');
  l('    IF l_party_site_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := acq_cnt+1; ');
  l('    END IF; ');
  l('    IF l_contact_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := acq_cnt+1; ');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := acq_cnt+1; ');
  l('    END IF;  ');

  l('    IF acq_cnt>1 THEN ');
  l('    	other_acq_criteria_exists := TRUE; ');
  l('    ELSE');
  l('    	other_acq_criteria_exists := FALSE; ');
  l('    END IF;  ');
  dc(fnd_log.level_statement,'count of entities having acquisition attributes = ','acq_cnt');
  dc(fnd_log.level_statement,'call_max_score(p_index) = ','call_max_score(p_index)');
  dc(fnd_log.level_statement,'l_threshold = ','l_threshold');
  --End of Bug No:5218095
  l('    IF(l_match_str = '' AND '' AND other_acq_criteria_exists) THEN');
  --start of Bug No:5218095
  l('    	IF ( call_max_score(p_index) < l_threshold) THEN ');
  ldbg_s('When max score of entity level<l_threshold, do not evaluate ');
  l('	     	RETURN;	');
  l('    	ELSE ');
  ldbg_s('In do eval number of matches found exceeded threshold');
  l('	     	FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED''); ');
  l('	     	FND_MSG_PUB.ADD; ');
  l('	     	RAISE FND_API.G_EXC_ERROR; ');
  l('    	END IF; ');
  --end of Bug No:5218095
  l('    ELSE');
  ldbg_s('In do eval number of matches found exceeded threshold');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('     END IF; ');
  l('    END IF;');
  --End of Bug No: 4407425
  /*l('    IF p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0 THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  */
  l('    IF call_order(p_index) = ''PARTY'' AND l_party_contains_str IS NOT NULL THEN');
  l('      eval_party_level(l_party_contains_str,call_type(p_index), p_index);');
  l('    ELSIF call_order(p_index) = ''PARTY_SITE'' AND l_party_site_contains_str IS NOT NULL THEN');
  l('      eval_party_site_level(l_party_site_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    ELSIF call_order(p_index) = ''CONTACT'' AND l_contact_contains_str IS NOT NULL THEN');
  l('      eval_contact_level(l_contact_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    ELSIF call_order(p_index) = ''CONTACT_POINT'' AND l_contact_pt_contains_str IS NOT NULL THEN');
  l('      eval_cpt_level(l_contact_pt_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    END IF;');
  l('  END;');
  l('  /************ End of find_parties private procedures **********/ ');
  l('');
  l('  BEGIN');
  l('');

  ldbg_s('--------------------------------');
  ldbg_s('Entering Procedure find_parties');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters are :');
  dc(fnd_log.level_statement,'p_match_type = ','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql = ','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_set_id = ','p_dup_set_id');
  dc(fnd_log.level_statement,'p_search_merged = ','p_search_merged');
  dc(fnd_log.level_statement,'p_dup_party_id = ','p_dup_party_id');
  de;

  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');

  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    l_entered_max_score:= init_search(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list, l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');
  IF l_purpose = 'D' THEN
    ldbg_s('This is Duplicate Identification match rule');
    l('  IF l_entered_max_score < '||l_match_threshold||' THEN');
    l('    x_num_matches:=0;');
    l('    x_search_ctx_id:=0;');
    ldbg_s('Returning since maximum obtainable score of input search criteria < threshold');
    l('    RETURN;');
    l('  END IF;');
  END IF;
  l('');
  l('    --Fix for bug 4417124 ');
  l('');
  l('    SELECT use_contact_addr_flag, use_contact_cpt_flag ');
  l('    INTO l_use_contact_addr_flag, l_use_contact_cpt_flag ');
  l('    FROM hz_match_rules_b ');
  l('    WHERE match_rule_id = '||p_rule_id||'; ');
  l('');
  l('    IF NVL(l_use_contact_addr_flag, ''Y'') = ''N'' THEN');
  l('      l_use_contact_addr_info := FALSE; ');
  l('    END IF; ');
  l('');
  l('    IF NVL(l_use_contact_cpt_flag, ''Y'') = ''N'' THEN');
  l('      l_use_contact_cpt_info := FALSE; ');
  l('    END IF; ');
  l('');
  l('   --End fix for bug 4417124');
  l('');
  l('    IF p_dup_batch_id IS NOT NULL THEN');
  l('      l_max_thresh:=nvl(FND_PROFILE.VALUE(''HZ_DQM_MAX_EVAL_THRESH_BATCH''),10000);');
  l('    ELSE');
  l('      l_max_thresh:=nvl(FND_PROFILE.VALUE(''HZ_DQM_MAX_EVAL_THRESH''),200);');
  l('    END IF;');

  l('    IF nvl(FND_PROFILE.VALUE(''HZ_DQM_SCORE_UNTIL_THRESH''),''N'')=''Y'' THEN');
  l('      g_score_until_thresh := true;');
  ldbg_s('g_score_until_thresh is true');
  l('    ELSE');
  l('      g_score_until_thresh := false;');
  ldbg_s('g_score_until_thresh is false');
  l('    END IF;');
  ldbg_sv('Maximum records that will be evaluated is ', 'l_max_thresh');

  l('    -- ************************************************************');
  l('    -- STEP 2. Setup of intermedia query strings for Acquisition query');

  l('    l_party_site_contains_str := INIT_PARTY_SITES_QUERY(l_match_str,l_ps_denorm_str);');
  l('    l_contact_contains_str := INIT_CONTACTS_QUERY(l_match_str,l_ct_denorm_str);');
  l('    l_contact_pt_contains_str := INIT_CONTACT_POINTS_QUERY(l_match_str,l_cpt_denorm_str);');
  ldbg_s('Commencing the DENORM LOGIC in find_parties');
  l('    l_denorm_max_score:=0;');
  l('    l_non_denorm_max_score:=0;');
  l('    IF l_ps_denorm_str IS NOT NULL THEN');
  l('      l_denorm_max_score := l_denorm_max_score+l_ps_max_score;');
  l('      l_denorm_str := l_ps_denorm_str;');
  l('    ELSE');
  l('      l_non_denorm_max_score := l_non_denorm_max_score+l_ps_max_score;');
  l('    END IF;');

  l('    IF l_ct_denorm_str IS NOT NULL THEN');
  l('      l_denorm_max_score := l_denorm_max_score+l_contact_max_score;');
  l('      IF l_denorm_str IS NOT NULL THEN');
  l('        l_denorm_str := l_denorm_str || '' OR '' ||l_ct_denorm_str;');
  l('      ELSE');
  l('        l_denorm_str := l_ct_denorm_str;');
  l('      END IF;');
  l('    ELSE');
  l('      l_non_denorm_max_score := l_non_denorm_max_score+l_contact_max_score;');
  l('    END IF;');

  l('    IF l_cpt_denorm_str IS NOT NULL THEN');
  l('      l_denorm_max_score := l_denorm_max_score+l_cpt_max_score;');
  l('      IF l_denorm_str IS NOT NULL THEN');
  l('        l_denorm_str := l_denorm_str || '' OR '' ||l_cpt_denorm_str;');
  l('      ELSE');
  l('        l_denorm_str := l_cpt_denorm_str;');
  l('      END IF;');
  l('    ELSE');
  l('      l_non_denorm_max_score := l_non_denorm_max_score+l_cpt_max_score;');
  l('    END IF;');

  l('    l_party_contains_str := INIT_PARTY_QUERY(l_match_str, l_denorm_str, l_party_max_score, l_denorm_max_score, l_non_denorm_max_score, round(('||l_match_threshold||'/'||l_max_score||')*l_entered_max_score));');

  l('    init_score_context(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');
  ldbg_sv('Search context id in find_parties is ', 'x_search_ctx_id');
  l('    IF l_party_contains_str IS NULL THEN');
  l('      defpt := 1;');
  l('    END IF;');
  l('    IF l_party_site_contains_str IS NULL THEN');
  l('      defps := 1;');
  l('    END IF;');
  l('    IF l_contact_contains_str IS NULL THEN');
  l('      defct := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');

  ds(fnd_log.level_statement);
  ldbg_s('------------------------');
  dc(fnd_log.level_statement,'In find_parties l_match_str =  ','l_match_str');
  dc(fnd_log.level_statement,'In find_parties l_party_contains_str = ','l_party_contains_str');
  dc(fnd_log.level_statement,'In find_parties l_party_site_contains_str = ','l_party_site_contains_str');
  dc(fnd_log.level_statement,'In find_parties l_contact_contains_str = ','l_contact_contains_str');
  dc(fnd_log.level_statement,'In find_parties l_contact_pt_contains_str = ','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'In find_parties l_search_ctx_id = ','l_search_ctx_id');
  de;

  IF l_max_score=1 THEN
    ldbg_s('In find_parties l_max_score = 1');
    l('    FOR I in 1..3 LOOP');
    l('      IF (call_order(I) = ''PARTY'' AND l_party_contains_str IS NULL)');
    l('         OR (call_order(I) = ''PARTY_SITE'' AND l_party_site_contains_str IS NULL)');
    l('         OR (call_order(I) = ''CONTACT'' AND l_contact_contains_str IS NULL)');
    l('         OR (call_order(I) = ''CONTACT_POINT'' AND l_contact_pt_contains_str IS NULL) THEN');
    l('        IF call_type(I)=''OR'' THEN');
    l('          call_type(I+1):=''OR'';');
    l('        END IF;');
    l('      END IF;');
    l('    END LOOP;');
  END IF;

  /**** Call all 4 evaluation procedures ***********/
  l('    FOR I in 1..5 LOOP');
  l('      do_eval(I);');
  l('    END LOOP;');

  IF l_purpose  IN ('S','W') THEN
    d(fnd_log.level_statement,'In find_parties. This is a Search Rule. Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  ELSE
    d(fnd_log.level_statement,'In find_parties. This is a Duplicate Identification Rule. Evaluating Matches. Threshold : '||l_match_threshold);
  END IF;

  l('    x_num_matches := 0;');
  l('    l_num_eval := 0;');
  l('    IF l_match_str = '' OR '' THEN');
  l('      l_party_id := H_SCORES.FIRST;');
  l('    ELSE');
  l('      l_party_id := H_PARTY_ID_LIST.FIRST;');
  l('    END IF;');

  l('    WHILE l_party_id IS NOT NULL LOOP');
  l('      l_num_eval:= l_num_eval+1;');
  ds(fnd_log.level_statement);
  ldbg_s('----------------------');
  dc(fnd_log.level_statement,'In find_parties Match Party ID = ','H_SCORES(l_party_id).PARTY_ID');
  IF l_purpose = 'S' THEN
    dc(fnd_log.level_statement,'In find_parties Score = ','round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100)');
  ELSE
    dc(fnd_log.level_statement,'In find_parties Score = ','H_SCORES(l_party_id).TOTAL_SCORE');
  END IF;
  de;
  IF l_purpose  = ('S') THEN
  ldbg_s('In find_parties inserting Search Rule results into HZ_MATCHED_PARTIES_GT');
    l('      IF (H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100));');
    l('            x_num_matches := x_num_matches+1;');
    ldbg_s('----------------------');
  ELSIF l_purpose  = ('W') THEN

  ldbg_s('In find_parties inserting Webservice  Rule results into HZ_MATCHED_PARTIES_GT');
    l('      IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_match_threshold||' THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/'||l_max_score||')*100));');
    l('            x_num_matches := x_num_matches+1;');
    ldbg_s('----------------------');
  ELSE
    ldbg_s('In find_parties inserting Duplicate Identification results into HZ_MATCHED_PARTIES_GT');
    l('      IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_match_threshold||' THEN');
    l('          IF p_dup_set_id IS NULL THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,H_SCORES(l_party_id).TOTAL_SCORE);');
    l('             x_num_matches := x_num_matches+1;');
    l('          ELSE');
    ldbg_s('Before Inserting Duplicate Identification results into HZ_DUP_SET_PARTIES, if dup party already exists');
    l('            BEGIN');
    l('              SELECT 1 INTO l_tmp FROM HZ_DUP_SET_PARTIES'); --Bug No: 4244529
    l('              WHERE DUP_PARTY_ID = H_SCORES(l_party_id).PARTY_ID');
    l('              AND DUP_SET_BATCH_ID = p_dup_batch_id '); --Bug No: 4244529
    l('              AND ROWNUM=1;');
    l('            EXCEPTION ');
    l('              WHEN NO_DATA_FOUND THEN');
    l('                IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_auto_merge_score||' THEN');
    l('                  l_merge_flag := ''Y'';');
    l('                ELSE');
    l('                  l_merge_flag := ''N'';');
    l('                END IF;');
    ldbg_s('In find_parties inserting Duplicate Identification results into HZ_DUP_SET_PARTIES');
    ldbg_s('----------------------');
    l('                INSERT INTO HZ_DUP_SET_PARTIES (DUP_PARTY_ID,DUP_SET_ID,MERGE_SEQ_ID,');
    l('                    MERGE_BATCH_ID,SCORE,MERGE_FLAG, CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,');
    l('                    LAST_UPDATE_DATE,LAST_UPDATED_BY,DUP_SET_BATCH_ID) '); --Bug No: 4244529
    l('                VALUES (H_SCORES(l_party_id).PARTY_ID,p_dup_set_id,0,0,');
    l('                    H_SCORES(l_party_id).TOTAL_SCORE, l_merge_flag,');
    l('                    hz_utility_pub.created_by,hz_utility_pub.creation_date,');
    l('                    hz_utility_pub.last_update_login,');
    l('                    hz_utility_pub.last_update_date,');
    l('                    hz_utility_pub.user_id,p_dup_batch_id);'); --Bug No: 4244529
    l('                x_num_matches := x_num_matches+1;');
    l('            END;');
    l('          END IF;');
  END IF;
  l('      END IF;');
  l('      IF l_match_str = '' OR '' THEN');
  l('        l_party_id:=H_SCORES.NEXT(l_party_id);');
  l('      ELSE');
  l('        l_party_id:=H_PARTY_ID_LIST.NEXT(l_party_id);');
  l('      END IF;');
  l('    END LOOP;');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(l_num_eval);');
  ldbg_s('Exiting Procedure find_parties');
  ldbg_s('--------------------------------');
  l('EXCEPTION');
  l('  WHEN L_RETURN_IMM_EXC THEN');
  l('    RETURN;');
ELSE ---Start of Code Change for Match Rule Set
  l('  BEGIN');
  l('');

  d(fnd_log.level_procedure,'find_parties(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_set_id','p_dup_set_id');
  dc(fnd_log.level_statement,'p_search_merged','p_search_merged');
  dc(fnd_log.level_statement,'p_dup_party_id','p_dup_party_id');
  de;
  pop_conditions(p_rule_id,'find_parties','p_rule_id,p_party_search_rec,p_party_site_list,
  p_contact_list,p_contact_point_list,p_restrict_sql,p_match_type,p_search_merged,p_dup_party_id,
  p_dup_set_id,p_dup_batch_id,p_ins_details,x_search_ctx_id,x_num_matches','PARTY');

  d(fnd_log.level_procedure,'find_parties(-)');
  l('EXCEPTION');

END IF; ---End of Code Change for Match Rule Set

  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_parties'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_parties;');
  l('');

  l('PROCEDURE find_persons (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_dup_party_id          IN      NUMBER,');
  l('      p_dup_set_id            IN      NUMBER,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  l('');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_denorm_str VARCHAR2(32000);');
  l('  l_ps_denorm_str VARCHAR2(32000);');
  l('  l_ct_denorm_str VARCHAR2(32000);');
  l('  l_cpt_denorm_str VARCHAR2(32000);');

  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_match_idx NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('  H_PARTY_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_PARTY_ID_LIST HZ_PARTY_SEARCH.IDList;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_cpt_type VARCHAR2(100);');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_cpt_level VARCHAR2(100);');
  l('  l_ps_contact_id NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('  l_denorm_max_score NUMBER;');
  l('  l_non_denorm_max_score NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_max_thresh NUMBER;');
  l('  l_tmp NUMBER;');
  l('  l_merge_flag VARCHAR2(1);');
  l('  l_num_eval NUMBER:=0;');
  l('');
  l('  L_RETURN_IMM_EXC Exception;');
  l('');
  l('  ');
  l('  /********************* Find Parties private procedures *******/');
  FOR TX IN (
    SELECT a.attribute_name,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
            HZ_TRANS_ATTRIBUTES_VL a
        WHERE f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.entity_name = 'PARTY'
        AND a.attribute_name='PARTY_TYPE'
        AND f.PROCEDURE_NAME='HZ_TRANS_PKG.EXACT'
        AND nvl(f.active_flag,'Y')='Y'
        AND ROWNUM=1
  ) LOOP
    l('  PROCEDURE set_person_party_type IS');
    l('  BEGIN');
    l('    g_party_stage_rec.'||TX.STAGED_ATTRIBUTE_COLUMN||':= ');
    l('        HZ_TRANS_PKG.EXACT(');
    l('             ''PERSON''');
    l('             ,null,''PARTY_TYPE''');
    l('             ,''PARTY'');');
    l('  END;');
    l('    ');
    l('  PROCEDURE unset_person_party_type IS');
    l('  BEGIN');
    l('    g_party_stage_rec.'||TX.STAGED_ATTRIBUTE_COLUMN||' := '''';');
    l('  END;');
  END LOOP;
  l('  ');
  l('  FUNCTION get_person_id(p_party_id NUMBER, p_contact_id NUMBER) ');
  l('  RETURN NUMBER IS');
  l('    l_party_type VARCHAR2(255);');
  l('    l_person_id NUMBER(15);');
  l('  BEGIN');
  l('    SELECT party_type INTO l_party_type from hz_parties where party_id = p_party_id;');
  l('    IF l_party_type = ''PERSON'' THEN');
  l('      RETURN p_party_id;');
  l('    ELSIF p_contact_id IS NULL THEN');
  l('      RETURN NULL;');
  l('    ELSE');
  l('      BEGIN ');
  l('        SELECT subject_id INTO l_person_id FROM HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc, hz_parties p');
  l('        WHERE oc.org_contact_id = p_contact_id');
  l('        AND r.relationship_id = oc.party_relationship_id ');
  l('        AND r.object_id = p_party_id');
  l('        AND p.party_id = r.subject_id ');
  l('        AND p.party_type = ''PERSON''');
  l('        AND ROWNUM=1;');
  l('        ');
  l('        RETURN l_person_id;');
  l('      EXCEPTION');
  l('        WHEN NO_DATA_FOUND THEN');
  l('          RETURN NULL;');
  l('      END;      ');
  l('    END IF;');
  l('  END;  ');
  l('');
  l('  PROCEDURE push_eval IS');
  l('  BEGIN');
  l('    H_PARTY_ID.DELETE;');
  l('    H_PARTY_ID_LIST.DELETE;');
  l('    H_SCORES.DELETE;        ');
  l('    g_mappings.DELETE;');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(0);');
  l('    call_order(5) := call_order(1);');
  l('    call_type(5) := ''AND'';');
  l('    call_max_score(5) := call_max_score(1);');
  l('    call_type(2) := ''OR'';');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party level  ***/');
  l('  PROCEDURE eval_party_level(p_party_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    l_TX35_new varchar2(4000);'); --9155543
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    set_person_party_type;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      IF (p_restrict_sql IS NULL OR instrb(p_restrict_sql, ''SELECTIVE'')=0)');
  l('         and check_estimate_hits(''PARTY'',p_party_contains_str)>l_max_thresh THEN');
  ldbg_s('In eval party level estimated hits exceed threshold');
  l('        IF g_party_stage_rec.TX8 IS NOT NULL AND nvl(FND_PROFILE.VALUE(''HZ_DQM_PN_THRESH_RESOLUTION''),''NONE'')=''SQL'' THEN');
  ldbg_s('In eval party level resolution option is set to SQL search.');
  l('          IF (l_party_site_contains_str IS NULL AND');
  l('             l_contact_contains_str IS NULL AND');
  l('             l_contact_pt_contains_str IS NULL) AND NOT g_other_party_level_attribs IS NULL THEN');
  l('            return_direct_matches(p_restrict_sql,l_match_str,l_max_thresh,l_search_ctx_id,null,null, x_num_matches);');
  l('            RAISE L_RETURN_IMM_EXC;');
  l('          ELSE');
  l('            open_party_cursor_direct(p_dup_party_id, p_restrict_sql, l_match_str,null,p_party_contains_str,l_party_cur);');
  l('          END IF;');
  l('        ELSE');
  l('          IF p_index>1 THEN');
  ldbg_s('In eval party level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('      END IF;');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  l('    IF l_party_cur IS NULL OR (not l_party_cur%ISOPEN) THEN');
  l('      open_party_cursor(p_dup_party_id, p_restrict_sql, p_party_contains_str,l_ctx_id, l_match_str,p_search_merged,l_party_cur);');
  l('    END IF;');
  l('    LOOP ');
  l('      FETCH l_party_cur INTO');
  l('         l_party_id '||l_p_into_list||';');
  l('      EXIT WHEN l_party_cur%NOTFOUND;');
  l('      l_index := map_id(l_party_id);');
  IF(l_p_param_list LIKE '%TX35%') THEN --9155543
 	   l('  l_TX35_new:=RTRIM(LTRIM(l_TX35));');
 	   l('  l_TX35_new:=(CASE l_TX35_new WHEN ''SYNC'' THEN HZ_STAGE_MAP_TRANSFORM.den_acc_number (l_party_id) ELSE l_TX35_new END);');
 	   l_p_param_list:=replace(l_p_param_list,'l_TX35','l_TX35_new');
 	       END IF;
  l('      l_score := GET_PARTY_SCORE('||l_p_param_list||');');
  l_p_param_list:=replace(l_p_param_list,'l_TX35_new','l_TX35');
  l('      IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('        H_SCORES(l_index) := get_new_score_rec(l_score,l_score,defps,defct,defcpt, l_party_id, null, null,null);');
  l('      ELSE');
  l('        H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE+l_score;');
  l('        H_SCORES(l_index).PARTY_SCORE := l_score;');
  l('      END IF;');
  l('      IF NOT H_PARTY_ID_LIST.EXISTS(l_index) AND H_SCORES.EXISTS(l_index) THEN');
  l('        H_PARTY_ID_LIST(l_index) := 1;');
  l('        H_PARTY_ID(l_party_id_idx) := l_party_id;');
  l('        l_party_id_idx:= l_party_id_idx+1;');
  l('      END IF;');
  l('      IF (l_party_id_idx-1)>l_max_thresh THEN');
  l('         IF p_index=1 AND call_order(2) = ''PARTY_SITE'' ');
  l('          AND call_type(2) = ''AND'' AND l_contact_contains_str IS NULL');
  l('          AND nvl(FND_PROFILE.VALUE(''HZ_DQM_PN_THRESH_RESOLUTION''),''NONE'')=''SQL'' ');
  l('          AND l_contact_pt_contains_str IS NULL THEN');
  l('          H_PARTY_ID.DELETE(l_party_id_idx-1);');
  l('          H_PARTY_ID_LIST.DELETE(l_index);');
  l('          H_SCORES.DELETE(l_index);');
  l('          EXIT;');
  l('        END IF;');

  l('        CLOSE l_party_cur;'); --Bug No: 3872745
  l('        IF p_index>1 THEN');
  ldbg_s('In eval party level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Level Matches');
  dc(fnd_log.level_statement,'l_party_id','l_party_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('    END LOOP;');
  l('    CLOSE l_party_cur;');
  l('    ROLLBACK to eval_start;');
  l('  END;');
  l('  PROCEDURE open_person_contact_cursor(');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  BEGIN');
  l('    OPEN x_cursor FOR ');
  l('      SELECT /*+ INDEX(stage HZ_STAGED_CONTACTS_U1) */ ORG_CONTACT_ID, PARTY_ID'|| l_c_select_list);
  l('      FROM HZ_STAGED_CONTACTS stage');
  l('      WHERE contains( concat_col, p_contains_str)>0');
  l('      AND ORG_CONTACT_ID in (');
  l('            SELECT  /*+ ORDERED INDEX(d hz_dqm_parties_gt_n1) USE_NL(d r)*/ ');
  l('            org_contact_id');
  l('            from hz_dqm_parties_gt d, hz_relationships r, hz_org_contacts oc');
  l('            where d.party_id = r.subject_id');
  l('            and oc.party_relationship_id = r.relationship_id');
  l('            and d.search_context_id = p_search_ctx_id);   ');
--bug 4959719 start
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
   --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
--bug 4959719 end
  l('  END;');

  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_party_site_level(p_party_site_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    h_ps_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('    l_person_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    unset_person_party_type;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('      l_ctx_id := NULL;');
  l('    END IF;');
  l('    open_party_site_cursor(p_dup_party_id,NULL, p_restrict_sql, p_party_site_contains_str,l_ctx_id, p_search_merged,''N'', ''Y'',l_party_site_cur);');
  l('    LOOP ');
  l('      FETCH l_party_site_cur INTO');
  l('         l_party_site_id, l_ps_party_id, l_ps_contact_id '||l_ps_into_list||';');
  l('      EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('      IF l_ctx_id IS NULL THEN');
  l('        l_person_id := get_person_id(l_ps_party_id, l_ps_contact_id);');
  l('      ELSE');
  l('        l_person_id := l_ps_party_id;');
  l('      END IF;');

  l('      IF l_person_id IS NOT NULL AND l_person_id<>nvl(p_dup_party_id,-1) THEN');
  l('        l_index := map_id(l_person_id);');
  l('        l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          IF l_ctx_id IS NULL THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,l_score,defct,defcpt, l_person_id, l_party_site_id, null,null);');
  l('          END IF;');
  l('        ELSE');
  l('          IF l_score > H_SCORES(l_index).PARTY_SITE_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).PARTY_SITE_SCORE+l_score;');
  l('            H_SCORES(l_index).PARTY_SITE_SCORE := l_score;');
  l('          END IF;');
  l('        END IF;');
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) AND H_SCORES.EXISTS(l_index) THEN');
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  --l('          H_PARTY_ID(l_party_id_idx) := l_ps_party_id;');
  --Bug:4995382: SDIB BATCH W/ RULE DL ORG/PERSON DUPLICATES' ERRORS OUT
  l('          H_PARTY_ID(l_party_id_idx) := l_person_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  l('        END IF;');
  l('        IF (l_party_id_idx-1)>l_max_thresh THEN');
  l('          CLOSE l_party_site_cur;'); --Bug No: 3872745
  l('          IF p_index>1 THEN');
  ldbg_s('In eval party site level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
  l('          h_ps_id(detcnt) := l_party_site_id;');
  l('          h_ps_party_id(detcnt) := l_person_id;');
  l('          IF (p_emax_score > 0) THEN ');
  l('              h_ps_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('          ELSE ');
  l('              h_ps_score(detcnt) := 0; ');
  l('          END IF; ');
  l('          detcnt := detcnt +1;');
  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Site Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_party_site_id');
  dc(fnd_log.level_statement,'l_ps_party_id','l_person_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE l_party_site_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_ps_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID,PARTY_SITE_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_ps_id(I), h_ps_party_id(I), h_ps_score(I));');
  l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_contact_level(p_contact_contains_str VARCHAR2,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    h_ct_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('    l_person_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    l_ctx_id := l_search_ctx_id;');
  l('    unset_person_party_type;');
  l('    FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    open_person_contact_cursor(p_contact_contains_str,l_ctx_id, l_contact_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_cur INTO');
  l('         l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('      EXIT WHEN l_contact_cur%NOTFOUND;');
  l('      l_person_id := get_person_id(l_ct_party_id, l_org_contact_id);');
  l('      l_index := map_id(l_person_id);');
  l('      IF l_person_id IS NOT NULL AND H_SCORES.EXISTS(l_index) AND l_person_id<>nvl(p_dup_party_id,-1) THEN');
  l('        l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');
  l('        IF l_score > H_SCORES(l_index).CONTACT_SCORE THEN');
  l('          H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_SCORE+l_score;');
  l('          H_SCORES(l_index).CONTACT_SCORE := l_score;');
  l('        END IF;');
  l('      END IF;');
  l('      IF p_ins_details = ''Y'' THEN');
  l('        h_ct_id(detcnt) := l_org_contact_id;');
  l('        h_ct_party_id(detcnt) := l_person_id;');
  l('        IF (p_emax_score > 0) THEN ');
  l('            h_ct_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('        ELSE ');
  l('            h_ct_score(detcnt) := 0; ');
  l('        END IF; ');
  l('        detcnt := detcnt +1;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_org_contact_id');
  dc(fnd_log.level_statement,'l_ct_party_id','l_person_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('    END LOOP;');
  l('    CLOSE l_contact_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_ct_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID,ORG_CONTACT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_ct_id(I), h_ct_party_id(I), h_ct_score(I));');
  l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at contact point level  ***/');
  l('  PROCEDURE eval_cpt_level(p_contact_pt_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER, p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('    h_cpt_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('    l_person_id NUMBER;');
  --l('    l_continue VARCHAR2(1) := ''Y'';');
  l('    is_a_match VARCHAR2(1) := ''Y'';');
  l('    l_cpt_flag VARCHAR2(1) := ''N'';');
  l('  BEGIN');
  ldbg_s('-----------------');
  ldbg_s('calling the procedure eval_cpt_level - from find_persons');
  l('    SAVEPOINT eval_start;');
  l('    unset_person_party_type;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  ldbg_s('Match rule is AND and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  ldbg_s('Match rule is OR and call type is AND. Inserting into HZ_DQM_PARTIES_GT, from the H_PARTY_ID list');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  ldbg_s('====== START LOOPING THROUGH WHAT IS RETURNED BY OPEN_CONTACT_PT_CURSOR =======');
  l('    open_contact_pt_cursor(p_dup_party_id,NULL, p_restrict_sql, p_contact_pt_contains_str,l_ctx_id, p_search_merged,''N'', ''Y'',l_contact_pt_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_pt_cur INTO');
  l('         l_contact_pt_id, l_cpt_type, l_cpt_party_id,  l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('      EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  ldbg_s(' ------------------------------------' );
  ldbg_sv('Processing party_id - ','l_cpt_party_id' );
  ldbg_sv('contact point type - ','l_cpt_type' );
  l('      IF l_ctx_id IS NULL THEN');
  l('        l_person_id := get_person_id(l_cpt_party_id, l_cpt_contact_id);');
  l('      ELSE');
  l('        l_person_id := l_cpt_party_id;');
  l('      END IF;');

  l('      IF l_person_id IS NOT NULL AND l_person_id<>nvl(p_dup_party_id,-1) THEN');
  l('        l_index := map_id(l_person_id);');
  l('        l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          IF l_ctx_id IS NULL THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score, l_person_id, l_cpt_ps_id, l_cpt_contact_id,l_contact_pt_id);');
  if l_purpose IN ('S','W') then
    l('           H_SCORES(l_index).cpt_type_match(l_cpt_type) := l_score;');
    ldbg_s('Processing first time for this party');
    ldbg_sv('l_index is - ','l_index' );
    ldbg_sv('H_SCORES(l_index).cpt_type_match(l_cpt_type) is - ','H_SCORES(l_index).cpt_type_match(l_cpt_type)' );
  end if;
  l('          END IF;');
  l('        ELSE');
  if l_purpose IN ('S','W') then
	ldbg_s('Processing Second time for this party');
    l('          IF(H_SCORES(l_index).cpt_type_match.EXISTS(l_cpt_type)) then');
    l('            IF l_score > H_SCORES(l_index).cpt_type_match(l_cpt_type) then');
    l('              H_SCORES(l_index).TOTAL_SCORE :=');
    l('              H_SCORES(l_index).TOTAL_SCORE-(H_SCORES(l_index).CONTACT_POINT_SCORE - H_SCORES(l_index).cpt_type_match(l_cpt_type) )+l_score;');
    l('              H_SCORES(l_index).CONTACT_POINT_SCORE := H_SCORES(l_index).CONTACT_POINT_SCORE - H_SCORES(l_index).cpt_type_match(l_cpt_type) + l_score;');
    l('              H_SCORES(l_index).cpt_type_match(l_cpt_type) := l_score;');
    ldbg_s('Passed in score greater than existing score');
    ldbg_sv('H_SCORES(l_index).TOTAL_SCORE is - ','H_SCORES(l_index).TOTAL_SCORE' );
    ldbg_sv('H_SCORES(l_index).CONTACT_POINT_SCORE is - ','H_SCORES(l_index).CONTACT_POINT_SCORE' );
    ldbg_sv('H_SCORES(l_index).cpt_type_match(l_cpt_type) is - ','H_SCORES(l_index).cpt_type_match(l_cpt_type)' );
    l('            END IF;');
    l('          ELSE');
    ldbg_s('Passed in score less than or equal to the existing score ');
    l('            H_SCORES(l_index).TOTAL_SCORE :=');
    l('            H_SCORES(l_index).TOTAL_SCORE+l_score;');
    l('            H_SCORES(l_index).CONTACT_POINT_SCORE := H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
    l('            H_SCORES(l_index).cpt_type_match(l_cpt_type) := l_score;');
    ldbg_sv('H_SCORES(l_index).TOTAL_SCORE is - ','H_SCORES(l_index).TOTAL_SCORE' );
    ldbg_sv('H_SCORES(l_index).CONTACT_POINT_SCORE is - ','H_SCORES(l_index).CONTACT_POINT_SCORE' );
    ldbg_sv('H_SCORES(l_index).cpt_type_match(l_cpt_type) is - ','H_SCORES(l_index).cpt_type_match(l_cpt_type)' );
    l('          END IF;');
  else
  	l('          IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  	l('            H_SCORES(l_index).TOTAL_SCORE := ');
  	l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  	l('            H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  	l('          END IF;');
  end if;
  l('        END IF;');
  ldbg_sv('call type is - ','p_call_type'  );
  ldbg_sv('match string is - ','l_match_str' );
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) AND H_SCORES.EXISTS(l_index) THEN');
  if l_purpose  IN ('S','W') then
    l('          -- If rule is match all ');
    l('          IF l_match_str = '' AND '' THEN');
    ldbg_s('Match String is - AND ');
    l('            IF H_SCORES(l_index).cpt_type_match.count = distinct_search_cpt_types then');
    l('              is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ', 'is_a_match');
    l('            ELSE');
    l('              is_a_match := ''N'';');
    ldbg_sv('is_a_match is ', 'is_a_match');
    l('            END IF;');
    l('          -- Else it is construed as a match anyway ');
    l('          ELSE');
    l('            is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ', 'is_a_match');
    l('          END IF;');
    l('          IF (is_a_match=''Y'') THEN');
 end if;
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_person_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  if l_purpose IN ('S','W') then
    l('      end if;');
  end if;
  l('        END IF;');
  l('        IF (l_party_id_idx-1)>l_max_thresh THEN');
  l('          CLOSE l_contact_pt_cur;'); --Bug No: 3872745
  l('          IF p_index>1 THEN');
  ldbg_s('In eval contact point level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
 if l_purpose  IN ('S','W') then
    l('          -- If rule is match all ');
    l('          IF l_match_str = '' AND '' THEN');
    ldbg_s('Match String is - AND ');
    l('            IF H_SCORES(l_index).cpt_type_match.count = distinct_search_cpt_types then');
    l('              is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ', 'is_a_match');
    l('            ELSE');
    l('              is_a_match := ''N'';');
    ldbg_sv('is_a_match is ', 'is_a_match');
    l('            END IF;');
	l('          -- Else it is construed as a match anyway ');
    l('          ELSE');
    l('            is_a_match := ''Y'';');
    ldbg_sv('is_a_match is ', 'is_a_match');
    l('          END IF;');
    l('          IF (is_a_match=''Y'') THEN');
 end if;
  ldbg_sv('Inserting into the final array, the person_id - ','l_person_id');
  l('          FOR I IN 1..h_cpt_id.COUNT LOOP');
  l('          IF h_cpt_id(I)=l_contact_pt_id THEN');
  l('          	 l_cpt_flag := ''Y'';');
  l('          END IF;');
  l('          END LOOP;');
  l('          IF l_cpt_flag = ''Y'' THEN');
  l('          	 NULL;');
  l('          ELSE ');
  l('         	 h_cpt_id(detcnt) := l_contact_pt_id;');
  l('          h_cpt_party_id(detcnt) := l_person_id;');
  l('          	 IF (p_emax_score > 0) THEN ');
  l('              h_cpt_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('            ELSE ');
  l('              h_cpt_score(detcnt) := 0; ');
  l('          	 END IF; ');
  l('            detcnt := detcnt +1;');
  l('          END IF;');
  if l_purpose IN ('S','W') then
  l('      end if;');
  end if;

  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact pt Level Matches');
  dc(fnd_log.level_statement,'l_contact_pt_id','l_contact_pt_id');
  dc(fnd_log.level_statement,'l_cpt_party_id','l_person_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE l_contact_pt_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_cpt_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CPTS_GT (SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_cpt_id(I), h_cpt_party_id(I), h_cpt_score(I));');
  l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to call the eval procedure at each entity in the correct order ***/');
  l('  PROCEDURE do_eval (p_index NUMBER) IS');
  l('    l_ctx_id NUMBER;');
  l('    l_threshold NUMBER;'); --Bug No: 4407425
  l('    other_acq_criteria_exists BOOLEAN; '); --Bug No: 4407425
  l('    acq_cnt NUMBER; '); --Bug No:5218095
  l('  BEGIN');
  --Start of Bug No: 4407425
  l('    IF (p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0) THEN');
  IF(l_purpose ='S') THEN
  l('     l_threshold :=  round(( l_entered_max_score / '|| l_max_score ||') * '|| l_match_threshold ||'); ');
  ELSE
  l('     l_threshold := '|| l_match_threshold ||';  ');
  END IF;
  l('    other_acq_criteria_exists := TRUE ;');
  --Start of Bug No:5218095
  /*l('    IF (call_max_score(2) = 0 and call_max_score(3) = 0 and call_max_score(4) = 0 ) THEN ');
  l('     other_criteria_exists := FALSE; ');
  l('    END IF ; ');*/
  l('    --check if acquisition criteria exists for any other entity');
  l('    IF l_party_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := 1; ');
  l('    END IF; ');
  l('    IF l_party_site_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := acq_cnt+1; ');
  l('    END IF; ');
  l('    IF l_contact_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := acq_cnt+1; ');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN ');
  l('    	acq_cnt := acq_cnt+1; ');
  l('    END IF;  ');

  l('    IF acq_cnt>1 THEN ');
  l('    	other_acq_criteria_exists := TRUE; ');
  l('    ELSE');
  l('    	other_acq_criteria_exists := FALSE; ');
  l('    END IF;  ');
  dc(fnd_log.level_statement,'count of entities having acquisition attributes = ','acq_cnt');
  dc(fnd_log.level_statement,'call_max_score(p_index) = ','call_max_score(p_index)');
  dc(fnd_log.level_statement,'l_threshold = ','l_threshold');
  --End of Bug No:5218095
  l('    IF(l_match_str = '' AND '' AND other_acq_criteria_exists) THEN');
  --start of Bug No:5218095
  l('    	IF ( call_max_score(p_index) < l_threshold) THEN ');
  ldbg_s('When max score of entity level<l_threshold, do not evaluate ');
  l('	     	RETURN;	');
  l('    	ELSE ');
  ldbg_s('In do eval number of matches found exceeded threshold');
  l('	     	FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED''); ');
  l('	     	FND_MSG_PUB.ADD; ');
  l('	     	RAISE FND_API.G_EXC_ERROR; ');
  l('    	END IF; ');
  --end of Bug No:5218095
  l('	  ELSE');
  ldbg_s('In do eval number of matches found exceeded threshold');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('     END IF; ');
  l('    END IF;');
  --End of Bug No: 4407425
  /*l('    IF p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0 THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  */
  l('    IF call_order(p_index) = ''PARTY'' AND l_party_contains_str IS NOT NULL THEN');
  l('      eval_party_level(l_party_contains_str,call_type(p_index), p_index);');
  l('    ELSIF call_order(p_index) = ''PARTY_SITE'' AND l_party_site_contains_str IS NOT NULL THEN');
  l('      eval_party_site_level(l_party_site_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    ELSIF call_order(p_index) = ''CONTACT_POINT'' AND l_contact_pt_contains_str IS NOT NULL THEN');
  l('      eval_cpt_level(l_contact_pt_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    END IF;');
  l('  END;');
  l('  /************ End of find_persons private procedures **********/ ');
  l('');
  l('  BEGIN');
  l('');


  d(fnd_log.level_procedure,'find_persons(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;

  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');

  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    l_entered_max_score:= init_search(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list, l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');
  l('    l_max_thresh:=nvl(FND_PROFILE.VALUE(''HZ_DQM_MAX_EVAL_THRESH''),200);');
  l('    IF nvl(FND_PROFILE.VALUE(''HZ_DQM_SCORE_UNTIL_THRESH''),''N'')=''Y'' THEN');
  l('      g_score_until_thresh := true;');
  l('    ELSE');
  l('      g_score_until_thresh := false;');
  l('    END IF;');


  l('    -- ************************************************************');
  l('    -- STEP 2. Setup of intermedia query strings for Acquisition query');

  l('    l_party_site_contains_str := INIT_PARTY_SITES_QUERY(l_match_str,l_ps_denorm_str);');
  l('    l_contact_contains_str := INIT_CONTACTS_QUERY(l_match_str,l_ct_denorm_str);');
  l('    l_contact_pt_contains_str := INIT_CONTACT_POINTS_QUERY(l_match_str,l_cpt_denorm_str);');
  l('    l_party_contains_str := INIT_PARTY_QUERY(l_match_str, null, 0, 0, 0,0);');
  l('    init_score_context(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  l('    IF l_party_contains_str IS NULL THEN');
  l('      defpt := 1;');
  l('    END IF;');
  l('    IF l_party_site_contains_str IS NULL THEN');
  l('      defps := 1;');
  l('    END IF;');
  l('    IF l_contact_contains_str IS NULL THEN');
  l('      defct := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_party_contains_str','l_party_contains_str');
  dc(fnd_log.level_statement,'l_party_site_contains_str','l_party_site_contains_str');
  dc(fnd_log.level_statement,'l_contact_contains_str','l_contact_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  /**** Call all 4 evaluation procedures ***********/
  l('    FOR I in 1..5 LOOP');
  l('      do_eval(I);');
  l('    END LOOP;');
  l('    IF l_contact_contains_str IS NOT NULL THEN');
  l('      eval_contact_level(l_contact_contains_str,p_ins_details,l_contact_max_score);');
  l('    END IF;');
  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));

  l('    x_num_matches := 0;');
  l('    l_num_eval := 0;');
  l('    IF l_match_str = '' OR '' THEN');
  l('      l_party_id := H_SCORES.FIRST;');
  l('    ELSE');
  l('      l_party_id := H_PARTY_ID_LIST.FIRST;');
  l('    END IF;');


  l('    WHILE l_party_id IS NOT NULL LOOP');
  l('      l_num_eval:= l_num_eval+1;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Party ID','H_SCORES(l_party_id).PARTY_ID');
  IF l_purpose = 'S' THEN
    dc(fnd_log.level_statement,'Score','round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100)');
  ELSE
    dc(fnd_log.level_statement,'Score','H_SCORES(l_party_id).TOTAL_SCORE');
  END IF;
  de;
  IF l_purpose  = ('S') THEN
    l('      IF (H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100));');
    l('            x_num_matches := x_num_matches+1;');

    ELSIF l_purpose  = ('W') THEN


    l('      IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_match_threshold||' THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/'||l_max_score||')*100));');
    l('            x_num_matches := x_num_matches+1;');


  ELSE
    l('      IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_match_threshold||' THEN');
    l('          IF p_dup_set_id IS NULL THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,H_SCORES(l_party_id).TOTAL_SCORE);');
    l('             x_num_matches := x_num_matches+1;');
    l('          ELSE');
    l('            BEGIN');
    l('              SELECT  1 INTO l_tmp FROM HZ_DUP_SET_PARTIES');  --Bug No: 4244529
    l('              WHERE DUP_PARTY_ID = H_SCORES(l_party_id).PARTY_ID');
    l('              AND DUP_SET_BATCH_ID = p_dup_batch_id ');  --Bug No: 4244529
    l('              AND ROWNUM=1;');
    l('            EXCEPTION ');
    l('              WHEN NO_DATA_FOUND THEN');
    l('                IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_auto_merge_score||' THEN');
    l('                  l_merge_flag := ''Y'';');
    l('                ELSE');
    l('                  l_merge_flag := ''N'';');
    l('                END IF;');
    l('                INSERT INTO HZ_DUP_SET_PARTIES (DUP_PARTY_ID,DUP_SET_ID,MERGE_SEQ_ID,');
    l('                    MERGE_BATCH_ID,SCORE,MERGE_FLAG, CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,');
    l('                    LAST_UPDATE_DATE,LAST_UPDATED_BY,DUP_SET_BATCH_ID) '); --Bug No: 4244529
    l('                VALUES (H_SCORES(l_party_id).PARTY_ID,p_dup_set_id,0,0,');
    l('                    H_SCORES(l_party_id).TOTAL_SCORE, l_merge_flag,');
    l('                    hz_utility_pub.created_by,hz_utility_pub.creation_date,');
    l('                    hz_utility_pub.last_update_login,');
    l('                    hz_utility_pub.last_update_date,');
    l('                    hz_utility_pub.user_id,p_dup_batch_id);'); --Bug No: 4244529
    l('                x_num_matches := x_num_matches+1;');
    l('            END;');
    l('          END IF;');
  END IF;
  l('      END IF;');
  l('      IF l_match_str = '' OR '' THEN');
  l('        l_party_id:=H_SCORES.NEXT(l_party_id);');
  l('      ELSE');
  l('        l_party_id:=H_PARTY_ID_LIST.NEXT(l_party_id);');
  l('      END IF;');
  l('    END LOOP;');

  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(l_num_eval);');
  d(fnd_log.level_procedure,'find_persons(-)');


  l('EXCEPTION');
  l('  WHEN L_RETURN_IMM_EXC THEN');
  l('    RETURN;');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_persons'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_persons;');
  l('');
ELSE ---Start of Code Change for Match Rule Set
  l('BEGIN');
  d(fnd_log.level_procedure,'find_persons(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;
  pop_conditions(p_rule_id,'find_persons','p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,p_restrict_sql,p_match_type,p_search_merged,p_ins_details,x_search_ctx_id,x_num_matches','PARTY');
  d(fnd_log.level_procedure,'find_persons(-)');
   l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_persons'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_persons;');
END IF; ---End of Code Change for Match Rule Set

l('PROCEDURE find_persons (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
  l('  BEGIN');
  l('     find_persons(p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,p_restrict_sql,p_match_type,p_search_merged,null,null,null,p_ins_details,x_search_ctx_id,x_num_matches);');
  l('  END;');


  /************** find_party_details API ***************/
  l('PROCEDURE find_party_details (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_party_details(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_search_merged','p_search_merged');
  de;

  l('  find_parties(p_rule_id,p_party_search_rec,p_party_site_list, p_contact_list, p_contact_point_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,null,null, null,''Y'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  DELETE FROM HZ_MATCHED_PARTY_SITES_GT ps WHERE SEARCH_CONTEXT_ID = x_search_ctx_id ');
  l('  AND NOT EXISTS ');
  l('       (SELECT 1 FROM HZ_MATCHED_PARTIES_GT p WHERE SEARCH_CONTEXT_ID = x_search_ctx_id AND p.PARTY_ID = ps.PARTY_ID);');
  l('  DELETE FROM HZ_MATCHED_CONTACTS_GT ct WHERE SEARCH_CONTEXT_ID = x_search_ctx_id ');
  l('  AND NOT EXISTS ');
  l('       (SELECT 1 FROM HZ_MATCHED_PARTIES_GT p WHERE SEARCH_CONTEXT_ID = x_search_ctx_id AND p.PARTY_ID = ct.PARTY_ID);');
  l('  DELETE FROM HZ_MATCHED_CPTS_GT cpt WHERE SEARCH_CONTEXT_ID = x_search_ctx_id ');
  l('  AND NOT EXISTS ');
  l('       (SELECT 1 FROM HZ_MATCHED_PARTIES_GT p WHERE SEARCH_CONTEXT_ID = x_search_ctx_id AND p.PARTY_ID = cpt.PARTY_ID);');

  d(fnd_log.level_procedure,'find_party_details(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_party_details'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_party_details;');
  l('');
  /************** find_duplicate_parties API ***************/
  l('PROCEDURE find_duplicate_parties (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_dup_set_id            OUT     NUMBER,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  l_party_rec HZ_PARTY_SEARCH.party_search_rec_type;');
  l('  l_party_site_list HZ_PARTY_SEARCH.party_site_list;');
  l('  l_contact_list HZ_PARTY_SEARCH.contact_list;');
  l('  l_cpt_list HZ_PARTY_SEARCH.contact_point_list;');
  l('  l_match_idx NUMBER;');
  l('');
  l('  --Fix for bug 4417124');
  l('  l_use_contact_addr_info BOOLEAN := TRUE;');
  l('  l_use_contact_cpt_info BOOLEAN  := TRUE;');
  l('  l_use_contact_addr_flag VARCHAR2(1) := ''Y'';');
  l('  l_use_contact_cpt_flag  VARCHAR2(1) := ''Y'';');
  l('');
  l('BEGIN');
  l('');
  d(fnd_log.level_procedure,'find_duplicate_parties(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_batch_id','p_dup_batch_id');
  dc(fnd_log.level_statement,'p_search_merged','p_search_merged');
  de;
  l('');
  l('  --Fix for bug 4417124 ');
  l('');
  l('  SELECT use_contact_addr_flag, use_contact_cpt_flag ');
  l('  INTO l_use_contact_addr_flag, l_use_contact_cpt_flag ');
  l('  FROM hz_match_rules_b ');
  l('  WHERE match_rule_id = '||p_rule_id||'; ');
  l('');
  l('  IF NVL(l_use_contact_addr_flag, ''Y'') = ''N'' THEN');
  l('    l_use_contact_addr_info := FALSE; ');
  l('  END IF; ');
  l('');
  l('  IF NVL(l_use_contact_cpt_flag, ''Y'') = ''N'' THEN');
  l('    l_use_contact_cpt_info := FALSE; ');
  l('  END IF; ');
  l('');
  l(' --End fix for bug 4417124');
  l('');

  l('  get_party_for_search(');
  l('              p_party_id, l_party_rec,l_party_site_list, l_contact_list, l_cpt_list);');
  l('');
  l('    IF NOT check_prim_cond (l_party_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_cpt_list) THEN');
  l('      x_dup_set_id:=NULL;');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');

  l('  x_dup_set_id := NULL;');
  l('  IF p_dup_batch_id IS NOT NULL THEN');
  l('    SELECT HZ_MERGE_BATCH_S.nextval INTO x_dup_set_id FROM DUAL;');
  l('  END IF;');
  l('');
  l('  --Fix for bug 4417124 ');
  l('  IF l_party_rec.PARTY_TYPE = ''PERSON'' AND (l_use_contact_addr_info OR l_use_contact_cpt_info) THEN');
  l('    find_persons(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,p_party_id,x_dup_set_id,p_dup_batch_id,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSE');
  l('    find_parties(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,p_party_id,x_dup_set_id,p_dup_batch_id,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  END IF;');
  l('');
  l('  IF x_num_matches > 0 AND p_dup_batch_id IS NOT NULL THEN');
  l('    INSERT INTO HZ_DUP_SETS ( DUP_SET_ID, DUP_BATCH_ID, WINNER_PARTY_ID,');
  l('      STATUS, MERGE_TYPE, CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN,');
  l('      LAST_UPDATE_DATE, LAST_UPDATED_BY) ');
  l('    VALUES (x_dup_set_id, p_dup_batch_id, p_party_id, ''SYSBATCH'',');
  l('      ''PARTY_MERGE'', hz_utility_pub.created_by, hz_utility_pub.creation_date,');
  l('      hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,');
  l('      hz_utility_pub.user_id);');
  l('');
  l('    INSERT INTO HZ_DUP_SET_PARTIES (DUP_PARTY_ID,DUP_SET_ID,MERGE_SEQ_ID,');
  l('      MERGE_BATCH_ID,merge_flag,SCORE,CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,');
  l('      LAST_UPDATE_DATE,LAST_UPDATED_BY,DUP_SET_BATCH_ID) '); --Bug No: 4244529
  l('    VALUES (p_party_id,x_dup_set_id,0,0,');
  l('      ''Y'',100,hz_utility_pub.created_by,hz_utility_pub.creation_date,');
  l('      hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,');
  l('      hz_utility_pub.user_id,p_dup_batch_id);'); --Bug No: 4244529
  l('  ELSE');
  l('    x_dup_set_id := NULL;');
  l('  END IF;');
  d(fnd_log.level_procedure,'find_duplicate_parties(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_parties'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_parties;');


  l('');
  /************** find_duplicate_party_sites API ***************/
  l('PROCEDURE find_duplicate_party_sites (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_site_id         IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');


  l('   l_party_search_rec HZ_PARTY_SEARCH.party_search_rec_type; ');
  l('   l_party_site_list HZ_PARTY_SEARCH.party_site_list; ');
  l('   l_contact_list HZ_PARTY_SEARCH.contact_list; ');
  l('   l_contact_point_list HZ_PARTY_SEARCH.contact_point_list; ');
  l('   contact_point_ids HZ_PARTY_SEARCH.IDList; ');
  l('   p_party_site_list HZ_PARTY_SEARCH.IDList;  ');
  l('   p_contact_ids HZ_PARTY_SEARCH.IDList; ');
  l('  l_match_idx NUMBER;');

  l('   cursor get_cpts_for_party_sites is select contact_point_id  ');
  l('                         from hz_contact_points ');
  l('                         where owner_table_name = ''HZ_PARTY_SITES'' ');
  l('                         and primary_flag=''Y''');
  l('                         and owner_table_id = p_party_site_id; ');

  l('   BEGIN ');


  d(fnd_log.level_procedure,'find_duplicate_party_sites(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_party_site_id','p_party_site_id');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;

  l('     p_party_site_list(1) := p_party_site_id; ');
  l('     OPEN get_cpts_for_party_sites;');
  l('     LOOP       ');
  l('     FETCH get_cpts_for_party_sites BULK COLLECT INTO contact_point_ids; ');
  l('         EXIT WHEN get_cpts_for_party_sites%NOTFOUND; ');
  l('     END LOOP;  ');
  l('     CLOSE get_cpts_for_party_sites; ');
  l('  ');
  l('     get_search_criteria (');
  l('         null,');
  l('         p_party_site_list,');
  l('         HZ_PARTY_SEARCH.G_MISS_ID_LIST,');
  l('         contact_point_ids, ');
  l('         l_party_search_rec,');
  l('         l_party_site_list,');
  l('         l_contact_list,');
  l('         l_contact_point_list) ;');
  l('    IF NOT check_prim_cond (l_party_search_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_contact_point_list) THEN');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');
  l(' ');
  l('     get_matching_party_sites (p_rule_id, ');
  l('         p_party_id, ');
  l('         l_party_site_list, ');
  l('         l_contact_point_list,');
  l('         p_restrict_sql, ');
  l('         p_match_type, ');
  l('         p_party_site_id, ');
  l('         x_search_ctx_id,');
  l('         x_num_matches);');
  d(fnd_log.level_procedure,'find_duplicate_party_sites(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_party_sites'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_party_sites; ');
  l(' ');

  /************** find_duplicate_contacts API ***************/
  l('PROCEDURE find_duplicate_contacts (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_org_contact_id        IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');

  l(' l_party_search_rec HZ_PARTY_SEARCH.party_search_rec_type;');
  l(' l_party_site_list HZ_PARTY_SEARCH.party_site_list; ');
  l(' l_contact_list HZ_PARTY_SEARCH.contact_list; ');
  l(' l_contact_point_list HZ_PARTY_SEARCH.contact_point_list; ');
  l(' contact_point_ids HZ_PARTY_SEARCH.IDList; ');
  l(' p_party_site_list HZ_PARTY_SEARCH.IDList;   ');
  l(' p_contact_ids HZ_PARTY_SEARCH.IDList; ');
  l('  l_match_idx NUMBER;');

  l(' cursor get_cpt_for_contact_id is select  contact_point_id ');
  l('   from hz_org_contacts a, hz_relationships b, hz_contact_points c ');
  l('   where a.party_relationship_id = b.relationship_id ');
  l('     and c.owner_table_name = ''HZ_PARTIES'' ');
  l('     and c.primary_flag=''Y''');
  l('     and c.owner_table_id = b.party_id ');
  l('     and b.directional_flag = ''F''  ');
  l('     and a.org_contact_id = p_org_contact_id; ');

  l('BEGIN ');


  d(fnd_log.level_procedure,'find_duplicate_contacts(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_org_contact_id','p_org_contact_id');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;


  l('    p_contact_ids(1) := p_org_contact_id; ');
  l('    OPEN get_cpt_for_contact_id; ');
  l('    LOOP ');
  l('    FETCH get_cpt_for_contact_id BULK COLLECT INTO contact_point_ids; ');
  l('        EXIT WHEN get_cpt_for_contact_id%NOTFOUND; ');
  l('    END LOOP;  ');
  l('    CLOSE get_cpt_for_contact_id; ');
  l(' ');
  l('    get_search_criteria (');
  l('        null,');
  l('        HZ_PARTY_SEARCH.G_MISS_ID_LIST,');
  l('        p_contact_ids,');
  l('        contact_point_ids, ');
  l('        l_party_search_rec,');
  l('        l_party_site_list, ');
  l('        l_contact_list,');
  l('        l_contact_point_list) ;');
  l('    IF NOT check_prim_cond (l_party_search_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_contact_point_list) THEN');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');
  l(' ');
  l('    get_matching_contacts (p_rule_id, ');
  l('        p_party_id, ');
  l('        l_contact_list, ');
  l('        l_contact_point_list, ');
  l('        p_restrict_sql, ');
  l('        p_match_type, ');
  l('        p_org_contact_id, ');
  l('        x_search_ctx_id, ');
  l('        x_num_matches);');
  l(' ');
  d(fnd_log.level_procedure,'find_duplicate_contacts(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_contacts'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_contacts; ');
  l('');
  /************** find_duplicate_contact_points API ***************/
  l('PROCEDURE find_duplicate_contact_points (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_contact_point_id      IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l(' l_party_search_rec HZ_PARTY_SEARCH.party_search_rec_type; ');
  l('  l_party_site_list HZ_PARTY_SEARCH.party_site_list; ');
  l('   l_contact_list HZ_PARTY_SEARCH.contact_list;  ');
  l('   l_contact_point_list HZ_PARTY_SEARCH.contact_point_list;  ');
  l('   contact_point_ids HZ_PARTY_SEARCH.IDList;  ');
  l('  p_party_site_list HZ_PARTY_SEARCH.IDList;   ');
  l('  p_contact_ids HZ_PARTY_SEARCH.IDList;  ');
  l('  l_match_idx NUMBER;');

  l('');
  l('BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_contact_points(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_contact_point_id','p_contact_point_id');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;

  l('  contact_point_ids(1) := p_contact_point_id;   ');
  l('  get_search_criteria (   ');
  l('      null, ');
  l('      HZ_PARTY_SEARCH.G_MISS_ID_LIST, ');
  l('      HZ_PARTY_SEARCH.G_MISS_ID_LIST, ');
  l('      contact_point_ids,   ');
  l('      l_party_search_rec, ');
  l('      l_party_site_list, ');
  l('      l_contact_list, ');
  l('      l_contact_point_list ); ');
  l('    ');
  l('    IF NOT check_prim_cond (l_party_search_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_contact_point_list) THEN');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');
  l('   get_matching_contact_points ( ');
  l('      p_rule_id, ');
  l('      p_party_id, ');
  l('     l_contact_point_list, ');
  l('      p_restrict_sql, ');
  l('      p_match_type, ');
  l('      p_contact_point_id, ');
  l('      x_search_ctx_id, ');
  l('      x_num_matches );  ');
  d(fnd_log.level_procedure,'find_duplicate_contact_points(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_contact_points'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_contact_points;');
  l('');
  l('PROCEDURE find_parties_dynamic (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_attrib_id1            IN      NUMBER,');
  l('        p_attrib_id2            IN      NUMBER,');
  l('        p_attrib_id3            IN      NUMBER,');
  l('        p_attrib_id4            IN      NUMBER,');
  l('        p_attrib_id5            IN      NUMBER,');
  l('        p_attrib_id6            IN      NUMBER,');
  l('        p_attrib_id7            IN      NUMBER,');
  l('        p_attrib_id8            IN      NUMBER,');
  l('        p_attrib_id9            IN      NUMBER,');
  l('        p_attrib_id10           IN      NUMBER,');
  l('        p_attrib_id11           IN      NUMBER,');
  l('        p_attrib_id12           IN      NUMBER,');
  l('        p_attrib_id13           IN      NUMBER,');
  l('        p_attrib_id14           IN      NUMBER,');
  l('        p_attrib_id15           IN      NUMBER,');
  l('        p_attrib_id16           IN      NUMBER,');
  l('        p_attrib_id17           IN      NUMBER,');
  l('        p_attrib_id18           IN      NUMBER,');
  l('        p_attrib_id19           IN      NUMBER,');
  l('        p_attrib_id20           IN      NUMBER,');
  l('        p_attrib_val1           IN      VARCHAR2,');
  l('        p_attrib_val2           IN      VARCHAR2,');
  l('        p_attrib_val3           IN      VARCHAR2,');
  l('        p_attrib_val4           IN      VARCHAR2,');
  l('        p_attrib_val5           IN      VARCHAR2,');
  l('        p_attrib_val6           IN      VARCHAR2,');
  l('        p_attrib_val7           IN      VARCHAR2,');
  l('        p_attrib_val8           IN      VARCHAR2,');
  l('        p_attrib_val9           IN      VARCHAR2,');
  l('        p_attrib_val10          IN      VARCHAR2,');
  l('        p_attrib_val11          IN      VARCHAR2,');
  l('        p_attrib_val12          IN      VARCHAR2,');
  l('        p_attrib_val13          IN      VARCHAR2,');
  l('        p_attrib_val14          IN      VARCHAR2,');
  l('        p_attrib_val15          IN      VARCHAR2,');
  l('        p_attrib_val16          IN      VARCHAR2,');
  l('        p_attrib_val17          IN      VARCHAR2,');
  l('        p_attrib_val18          IN      VARCHAR2,');
  l('        p_attrib_val19          IN      VARCHAR2,');
  l('        p_attrib_val20          IN      VARCHAR2,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_search_merged         IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  BEGIN');
  l('    call_api_dynamic(p_rule_id,p_attrib_id1, p_attrib_id2,p_attrib_id3,p_attrib_id4,p_attrib_id5,');
  l('                     p_attrib_id6,p_attrib_id7,p_attrib_id8,p_attrib_id9,p_attrib_id10,');
  l('                     p_attrib_id11,p_attrib_id12,p_attrib_id13,p_attrib_id14,p_attrib_id15,');
  l('                     p_attrib_id16,p_attrib_id17,p_attrib_id18,p_attrib_id19,p_attrib_id20,');
  l('                     p_attrib_val1,p_attrib_val2,p_attrib_val3,p_attrib_val4,p_attrib_val5,');
  l('                     p_attrib_val6,p_attrib_val7,p_attrib_val8,p_attrib_val9,p_attrib_val10,');
  l('                     p_attrib_val11,p_attrib_val12,p_attrib_val13,p_attrib_val14,p_attrib_val15,');
  l('                     p_attrib_val16,p_attrib_val17,p_attrib_val18,p_attrib_val19,p_attrib_val20,');
  l('                     p_restrict_sql,''FIND_PARTIES'',p_match_type,null,p_search_merged,x_search_ctx_id,x_num_matches);');
  l(' END;');

  l('');
  /************** call_api_dynamic API ***************/
  l('PROCEDURE call_api_dynamic (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_attrib_id1            IN      NUMBER,');
  l('        p_attrib_id2            IN      NUMBER,');
  l('        p_attrib_id3            IN      NUMBER,');
  l('        p_attrib_id4            IN      NUMBER,');
  l('        p_attrib_id5            IN      NUMBER,');
  l('        p_attrib_id6            IN      NUMBER,');
  l('        p_attrib_id7            IN      NUMBER,');
  l('        p_attrib_id8            IN      NUMBER,');
  l('        p_attrib_id9            IN      NUMBER,');
  l('        p_attrib_id10           IN      NUMBER,');
  l('        p_attrib_id11           IN      NUMBER,');
  l('        p_attrib_id12           IN      NUMBER,');
  l('        p_attrib_id13           IN      NUMBER,');
  l('        p_attrib_id14           IN      NUMBER,');
  l('        p_attrib_id15           IN      NUMBER,');
  l('        p_attrib_id16           IN      NUMBER,');
  l('        p_attrib_id17           IN      NUMBER,');
  l('        p_attrib_id18           IN      NUMBER,');
  l('        p_attrib_id19           IN      NUMBER,');
  l('        p_attrib_id20           IN      NUMBER,');
  l('        p_attrib_val1           IN      VARCHAR2,');
  l('        p_attrib_val2           IN      VARCHAR2,');
  l('        p_attrib_val3           IN      VARCHAR2,');
  l('        p_attrib_val4           IN      VARCHAR2,');
  l('        p_attrib_val5           IN      VARCHAR2,');
  l('        p_attrib_val6           IN      VARCHAR2,');
  l('        p_attrib_val7           IN      VARCHAR2,');
  l('        p_attrib_val8           IN      VARCHAR2,');
  l('        p_attrib_val9           IN      VARCHAR2,');
  l('        p_attrib_val10          IN      VARCHAR2,');
  l('        p_attrib_val11          IN      VARCHAR2,');
  l('        p_attrib_val12          IN      VARCHAR2,');
  l('        p_attrib_val13          IN      VARCHAR2,');
  l('        p_attrib_val14          IN      VARCHAR2,');
  l('        p_attrib_val15          IN      VARCHAR2,');
  l('        p_attrib_val16          IN      VARCHAR2,');
  l('        p_attrib_val17          IN      VARCHAR2,');
  l('        p_attrib_val18          IN      VARCHAR2,');
  l('        p_attrib_val19          IN      VARCHAR2,');
  l('        p_attrib_val20          IN      VARCHAR2,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_api_name              IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_search_merged         IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  TYPE AttrList IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;');
  l('  l_match_idx NUMBER;');
  l('  AttrVals AttrList;');
  l('  l_party_rec HZ_PARTY_SEARCH.party_search_rec_type;');
  l('  l_party_site_list HZ_PARTY_SEARCH.party_site_list;');
  l('  l_contact_list HZ_PARTY_SEARCH.contact_list;');
  l('  l_cpt_list HZ_PARTY_SEARCH.contact_point_list;');
  l('  l_dup_set_id NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_cpt_type VARCHAR2(255);');
  l('  FIRST BOOLEAN := TRUE; ');
  l('');
  l('BEGIN');

  d(fnd_log.level_procedure,'call_api_dynamic(+)');
  l('');
  FOR I in 1..20 LOOP
    l('  IF p_attrib_id'||I||' IS NOT NULL THEN');
    l('    AttrVals(p_attrib_id'||I||'):=p_attrib_val'||I||';');
    l('  END IF;');
  END LOOP;

  FIRST := TRUE;
  FOR ATTRS IN (
      SELECT a.attribute_id, a.attribute_name, a.entity_name
      FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
      WHERE p.match_rule_id = p_rule_id
      AND p.attribute_id = a.attribute_id

      UNION

      SELECT a.attribute_id, a.attribute_name, a.entity_name
      FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
      WHERE s.match_rule_id = p_rule_id
      AND s.attribute_id = a.attribute_id) LOOP
    l('  IF AttrVals.EXISTS('||ATTRS.attribute_id||') THEN');
    IF ATTRS.entity_name='PARTY' THEN
        l('    l_party_rec.'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
        d(fnd_log.level_statement,'l_party_rec.'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
    ELSIF ATTRS.entity_name='PARTY_SITES' THEN
        l('    l_party_site_list(1).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
        d(fnd_log.level_statement,'l_party_site_list(1).'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
    ELSIF ATTRS.entity_name='CONTACTS' THEN
        l('    l_contact_list(1).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
        d(fnd_log.level_statement,'l_contact_list(1).'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
    ELSIF ATTRS.entity_name='CONTACT_POINTS' THEN
      BEGIN
        SELECT tag INTO l_cpt_type FROM fnd_lookup_values
        WHERE lookup_type = 'HZ_DQM_CPT_ATTR_TYPE'
        AND lookup_code = ATTRS.attribute_name
        AND ROWNUM=1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_cpt_type:='PHONE';
      END;

      l('    l_cpt_type := '''||l_cpt_type||''';');
      l('    FIRST := FALSE;');
      l('    FOR I in 1..l_cpt_list.COUNT LOOP');
      l('      IF l_cpt_list(I).CONTACT_POINT_TYPE=l_cpt_type THEN');
      l('        l_cpt_list(I).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
      l('        FIRST := TRUE;');
      ds(fnd_log.level_statement);
      dc(fnd_log.level_statement,'l_cpt_list(''||I||'').CONTACT_POINT_TYPE','l_cpt_type');
      dc(fnd_log.level_statement,'l_cpt_list(''||I||'').'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
      de;
      l('      END IF;');
      l('    END LOOP;');
      l('    IF not FIRST THEN');
      l('      l_idx := l_cpt_list.COUNT+1;');
      l('      l_cpt_list(l_idx).CONTACT_POINT_TYPE:=l_cpt_type;');
      l('      l_cpt_list(l_idx).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
      ds(fnd_log.level_statement);
      dc(fnd_log.level_statement,'l_cpt_list(''||l_idx||'').CONTACT_POINT_TYPE','l_cpt_type');
      dc(fnd_log.level_statement,'l_cpt_list(''||l_idx||'').'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
      de;
      l('    END IF;');
    END IF;
    l('  END IF;');
    l('');
  END LOOP;
  l('');

  l('  IF AttrVals.EXISTS(14) THEN');
  l('     l_party_rec.PARTY_TYPE:= AttrVals(14); ');
  l('  END IF; ');

  l('  IF upper(p_api_name) = ''FIND_PARTIES'' THEN');
  l('    find_parties(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,NULL,NULL,NULL,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''FIND_PARTY_DETAILS'' THEN');
  l('    find_party_details(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''FIND_PERSONS'' THEN');
  l('    find_persons(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''GET_MATCHING_PARTY_SITES'' THEN');
  l('    get_matching_party_sites(p_rule_id,p_party_id,l_party_site_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,NULL,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''GET_MATCHING_CONTACTS'' THEN');
  l('    get_matching_contacts(p_rule_id,p_party_id,l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,NULL,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''GET_MATCHING_CONTACT_POINTS'' THEN');
  l('    get_matching_contact_points(p_rule_id,p_party_id, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,NULL,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  END IF;');
  d(fnd_log.level_procedure,'call_api_dynamic(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.call_api_dynamic'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');


  l('END call_api_dynamic; ');
  l('');

  /************** get_matching_party_sites API ***************/
  l('');
  l('PROCEDURE get_matching_party_sites (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_list       IN      HZ_PARTY_SEARCH.PARTY_SITE_LIST,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_dup_party_site_id     IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  ');
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_match_idx NUMBER;');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND (a.ENTITY_NAME='PARTY_SITES' OR a.ENTITY_NAME='CONTACT_POINTS')
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_cpt_type VARCHAR2(100);');
  l('  l_cpt_level VARCHAR2(100);');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_cpt_level VARCHAR2(100);');
  l('  l_ps_contact_id NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_match_ps_list HZ_PARTY_SEARCH.IDList;');
  l('  l_cnt NUMBER:=1;');
  l('');
  l('  ');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_party_sites(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_party_site_id','p_dup_party_site_id');
  de;
  l('');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');
  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    l_entered_max_score:= init_search( HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC, p_party_site_list, HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST, p_contact_point_list,l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');

  l('');

  l('    -- ************************************************************');
  l('    -- STEP 2. Setup of intermedia query strings for Acquisition query');
  l('    l_party_site_contains_str := INIT_PARTY_SITES_QUERY(l_match_str,l_tmp);');
  l('    l_contact_pt_contains_str := INIT_CONTACT_POINTS_QUERY(l_match_str,l_tmp);');
  l('    init_score_context(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,p_party_site_list,HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_party_site_contains_str','l_party_site_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  l('    IF l_party_site_contains_str IS NULL THEN');
  l('      defps := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');
  l('    IF l_party_site_contains_str IS NOT NULL THEN');
  l('      open_party_site_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_party_site_contains_str,NULL, null,''N'', ''N'',l_party_site_cur);');
  l('      LOOP');
  l('        FETCH l_party_site_cur INTO ');
  l('            l_party_site_id, l_ps_party_id, l_ps_contact_id '||l_ps_into_list||';');
  l('        EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('      IF (p_dup_party_site_id IS NULL OR (');
  l('                p_dup_party_site_id IS NOT NULL AND l_ps_contact_id IS NULL AND ');
  l('                l_party_site_id <> p_dup_party_site_id)) THEN  ');
  l('            l_index := map_id(l_party_site_id);');
  l('            l_match_ps_list(l_cnt):= l_party_site_id ;');
  l('            l_cnt:=l_cnt+1;');
  l('            l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,l_score,defct,defcpt, l_ps_party_id, l_party_site_id, null,null);');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Site Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_party_site_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;

  l('      END IF; ');
  l('      END LOOP;');
  l('      CLOSE l_party_site_cur;');
  l('    END IF;');
  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' OR (');
  l('        ((l_cpt_max_score/l_entered_max_score)<' ||'('||l_match_threshold||'/'||l_max_score || '))' );
  l('        ) THEN');
  l('      FORALL I in 1..l_match_ps_list.COUNT');
  l('           INSERT INTO HZ_DQM_PARTIES_GT (search_context_id, party_id)');
  l('           values (l_search_ctx_id,l_match_ps_list(I));');
  l('        open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL, null,''N'', ''N'',l_contact_pt_cur,''PARTY_SITES'');');
  l('    ELSE');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL, null,''N'', ''N'',l_contact_pt_cur);');
  l('    END IF;');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_type, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('      IF (l_cpt_ps_id IS NOT NULL AND (p_dup_party_site_id IS NULL OR (');
  l('         p_dup_party_site_id IS NOT NULL AND l_cpt_contact_id IS NULL AND p_dup_party_site_id <> l_cpt_ps_id))) THEN   ');
  l('        l_index := map_id(l_cpt_ps_id);');
  l('        IF l_match_str = '' OR '' THEN');
  l('          l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('          IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          ELSE');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          END IF;');
  l('        ELSE');
  l('          IF H_SCORES.EXISTS(l_index) THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          ELSIF defps=1 THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          END IF;');
  l('        END IF;');
  l('      END IF; ');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact_point Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_cpt_ps_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END LOOP;');
  l('      CLOSE l_contact_pt_cur;');
  l('    ROLLBACK TO eval_start;');
  l('    END IF;');
  l('    x_num_matches := 0;');
  l('    l_party_site_id := H_SCORES.FIRST;');
  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  l('    WHILE l_party_site_id IS NOT NULL LOOP');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Party Site ID','H_SCORES(l_party_site_id).PARTY_SITE_ID');
  dc(fnd_log.level_statement,'Score','round((H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)*100)');
  de;
l(' IF l_match_str = '' OR '' THEN');
  --Start of Bug No: 4162385
  IF l_purpose = 'D' THEN
    l_entity_score_lh := 'H_SCORES(l_party_site_id).TOTAL_SCORE';
    l_entity_score_rh := 'ROUND(('||get_entity_level_score(p_rule_id,'PARTY_SITES')||'/'||l_max_score||') * '|| l_match_threshold || ')';
  ELSE
    l_entity_score_lh := 'H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score';
    l_entity_score_rh := l_match_threshold||'/'||l_max_score;
  END IF;
  --End of Bug No: 4162385
    l('IF ('||l_entity_score_lh||')>=( '||l_entity_score_rh||' ) THEN'); --Bug No: 4162385
    l('    INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID, PARTY_ID, PARTY_SITE_ID, SCORE) ');
    l('    VALUES (l_search_ctx_id,H_SCORES(l_party_site_id).PARTY_ID, H_SCORES(l_party_site_id).PARTY_SITE_ID, (H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)*100);');
  l('      x_num_matches := x_num_matches+1;');
  l(' END IF;');
l(' ELSE');
    l('    IF H_SCORES(l_party_site_id).PARTY_SITE_SCORE>0 AND');
    l('       H_SCORES(l_party_site_id).CONTACT_POINT_SCORE>0 AND');
    l('       ('||l_entity_score_lh||')>=('||l_entity_score_rh||') THEN'); --Bug No: 4162385
    l('      INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID, PARTY_ID, PARTY_SITE_ID, SCORE) ');
    l('      VALUES (l_search_ctx_id,H_SCORES(l_party_site_id).PARTY_ID, H_SCORES(l_party_site_id).PARTY_SITE_ID, round((H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)*100));');
  l('       x_num_matches := x_num_matches+1;');
  l('      END IF;');
l(' END IF;');
  l('      l_party_site_id:=H_SCORES.NEXT(l_party_site_id);');
  l('    END LOOP;');
ELSE ---Start of Code Change for Match Rule Set
  l('  ');
  l('  BEGIN');
  d(fnd_log.level_procedure,'get_matching_party_sites(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_party_site_id','p_dup_party_site_id');
  de;
  l('');
  pop_conditions(p_rule_id,'get_matching_party_sites','p_rule_id,p_party_id,p_party_site_list,p_contact_point_list,p_restrict_sql,p_match_type,p_dup_party_site_id,x_search_ctx_id,x_num_matches','PARTY_SITES');

END IF; ---End of Code Change for Match Rule Set
  d(fnd_log.level_procedure,'get_matching_party_sites(-)');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_matching_party_sites'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_matching_party_sites;');
  l('');

--  l('  NULL;');
--  l('END;');

  /************** get_matching_contacts API ***************/
  l('');
  l('PROCEDURE get_matching_contacts (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_list          IN      HZ_PARTY_SEARCH.CONTACT_LIST,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_dup_contact_id        IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  ');
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_match_idx NUMBER;');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND (a.ENTITY_NAME='CONTACTS' OR a.ENTITY_NAME='CONTACT_POINTS')
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_cpt_type VARCHAR2(100);');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('  l_match_contact_list HZ_PARTY_SEARCH.IDList;');
  l('  l_cnt NUMBER:=1;');
  l('');
  l('  ');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_contacts(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_contact_id','p_dup_contact_id');
  de;

  l('');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');
  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    l_entered_max_score:= init_search( HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC, HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST, p_contact_list, p_contact_point_list,l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');

  l('    -- ************************************************************');
  l('    -- STEP 2. Setup of intermedia query strings for Acquisition query');
  l('    l_contact_contains_str := INIT_CONTACTS_QUERY(l_match_str,l_tmp);');
  l('    l_contact_pt_contains_str := INIT_CONTACT_POINTS_QUERY(l_match_str,l_tmp);');
  l('    init_score_context(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,p_contact_list,p_contact_point_list);');

  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_contact_contains_str','l_contact_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  l('    IF l_contact_contains_str IS NULL THEN');
  l('      defct := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');
  l('    IF l_contact_contains_str IS NOT NULL THEN');
  l('      open_contact_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_contains_str,NULL, null, l_contact_cur);');
  l('      LOOP');
  l('        FETCH l_contact_cur INTO ');
  l('            l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('        EXIT WHEN l_contact_cur%NOTFOUND;');
  l('      IF (p_dup_contact_id IS NULL OR l_org_contact_id <> p_dup_contact_id) THEN ');
  l('        l_index := map_id(l_org_contact_id);');
  l('        l_match_contact_list(l_cnt):=l_org_contact_id;');
  l('        l_cnt:=l_cnt+1;');

  l('          l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,l_score,defcpt, l_ct_party_id, null, l_org_contact_id, null);');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_org_contact_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;

  l('      END IF; ');
  l('      END LOOP;');
  l('      CLOSE l_contact_cur;');
  l('    END IF;');

  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' OR (');
  l('        ((l_cpt_max_score/l_entered_max_score)<' ||'('||l_match_threshold||'/'||l_max_score || '))' );
  l('        ) THEN');
  l('      FORALL I in 1..l_match_contact_list.COUNT');
  l('           INSERT INTO HZ_DQM_PARTIES_GT (search_context_id, party_id)');
  l('           values (l_search_ctx_id,l_match_contact_list(I));');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL, null,''N'', ''N'',l_contact_pt_cur,''CONTACTS'');');
  l('    ELSE');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL, null,''N'', ''N'',l_contact_pt_cur);');
  l('    END IF;');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_type, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('      IF (l_cpt_contact_id IS NOT NULL AND (p_dup_contact_id IS NULL OR l_cpt_contact_id <>  p_dup_contact_id)) THEN ');
  l('        l_index := map_id(l_cpt_contact_id);');
  l('        IF l_match_str = '' OR '' THEN');
  l('          l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('          IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          ELSE');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          END IF;');
  l('        ELSE');
  l('          IF H_SCORES.EXISTS(l_index) THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          ELSIF defps=1 THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          END IF;');
  l('        END IF;');
  l('        END IF; ');
  l('      END LOOP;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact_point Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_cpt_contact_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      CLOSE l_contact_pt_cur;');
  l('    END IF;');
  l('    x_num_matches := 0;');
  l('    l_org_contact_id := H_SCORES.FIRST;');
  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  l('    WHILE l_org_contact_id IS NOT NULL LOOP');
  l('      IF l_match_str = '' OR '' THEN');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Contact ID','H_SCORES(l_org_contact_id).ORG_CONTACT_ID');
  dc(fnd_log.level_statement,'Score','round((H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)*100)');
  de;
   --Start of Bug No: 4162385
  IF l_purpose = 'D' THEN
    l_entity_score_lh := 'H_SCORES(l_org_contact_id).TOTAL_SCORE';
    l_entity_score_rh := 'ROUND(('||get_entity_level_score(p_rule_id,'CONTACTS')||'/'||l_max_score||') * '|| l_match_threshold || ')';
  ELSE
    l_entity_score_lh := 'H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score';
    l_entity_score_rh := l_match_threshold||'/'||l_max_score;
  END IF;
  --End of Bug No: 4162385
--  IF l_purpose = 'S' THEN
    l('        IF (' || l_entity_score_lh ||')>=('|| l_entity_score_rh ||') THEN'); --Bug No: 4162385
    l('            INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID, PARTY_ID, ORG_CONTACT_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_org_contact_id).PARTY_ID, H_SCORES(l_org_contact_id).ORG_CONTACT_ID, (H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)*100);');
--  ELSE
--  END IF;
  l('          x_num_matches := x_num_matches+1;');
  l('        END IF;');
  l('      ELSE');
--  IF l_purpose = 'S' THEN
    l('           IF H_SCORES(l_org_contact_id).CONTACT_SCORE>0 AND');
    l('           H_SCORES(l_org_contact_id).CONTACT_POINT_SCORE>0 AND');
    l('           (' || l_entity_score_lh ||')>=('|| l_entity_score_rh ||') THEN');  --Bug No: 4162385
    l('          INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID, PARTY_ID, ORG_CONTACT_ID, SCORE) ');
    l('          VALUES (l_search_ctx_id,H_SCORES(l_org_contact_id).PARTY_ID, H_SCORES(l_org_contact_id).ORG_CONTACT_ID, round((H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)*100));');
--  ELSE
--  END IF;
  l('          x_num_matches := x_num_matches+1;');
  l('        END IF;');
  l('      END IF;');
  l('      l_org_contact_id:=H_SCORES.NEXT(l_org_contact_id);');
  l('    END LOOP;');
ELSE ---Start of Code Change for Match Rule Set
  l('  ');
  l('  BEGIN');
  d(fnd_log.level_procedure,'get_matching_contacts(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_contact_id','p_dup_contact_id');
  de;
  pop_conditions(p_rule_id,'get_matching_contacts','p_rule_id,p_party_id,p_contact_list,p_contact_point_list,p_restrict_sql,p_match_type,p_dup_contact_id,x_search_ctx_id,x_num_matches','CONTACTS');
END IF; ---End of Code Change for Match Rule Set

  d(fnd_log.level_procedure,'get_matching_contacts(-)');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_matching_contacts'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_matching_contacts;');
  l('');


  /************** get_matching_contact_points API ***************/
  l('');
  l('PROCEDURE get_matching_contact_points (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_dup_contact_point_id  IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  l('');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_match_idx NUMBER;');
  l('  -- For Score calculation');
  l('  l_entered_max_score NUMBER;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.ENTITY_NAME='CONTACT_POINTS'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_cpt_type VARCHAR2(100);');
  l('  H_PARTY_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_CONTACT_POINT_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_SCORE  HZ_PARTY_SEARCH.IDList;');
  l('');
  l('  cnt NUMBER :=0;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  ');
  l('  BEGIN');



  d(fnd_log.level_procedure,'get_matching_contact_points(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_contact_point_id','p_dup_contact_point_id');
  de;

  l('');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');

  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    l_entered_max_score:= init_search(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC, ');
  l('       HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST, HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,');
  l('       p_contact_point_list,l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');

  l('    -- ************************************************************');
  l('    -- STEP 2. Setup of intermedia query strings for Acquisition query');
  l('    l_contact_pt_contains_str := INIT_CONTACT_POINTS_QUERY(l_match_str,l_tmp);');
  l('    init_score_context(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,p_contact_point_list);');

  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL, null,''N'', ''N'',l_contact_pt_cur);');
  l('      cnt := 1;');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_type, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('        IF (p_dup_contact_point_id IS NULL OR (');
  l('               p_dup_contact_point_id IS NOT NULL AND ');
  l('               l_cpt_ps_id IS NULL AND l_cpt_contact_id IS NULL AND ');
  l('               p_dup_contact_point_id <>  l_contact_pt_id)) THEN   ');
  l('            H_CONTACT_POINT_ID(cnt) := l_contact_pt_id;');
  l('            H_PARTY_ID(cnt) := l_cpt_party_id;');
  l('            H_SCORE(cnt) := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            cnt := cnt+1;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Point Matches');
  dc(fnd_log.level_statement,'l_contact_pt_id','l_contact_pt_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;

  l('        END IF; ');
  l('      END LOOP;');
  l('      CLOSE l_contact_pt_cur;');

  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  l('      x_num_matches := 0; ');
  l('      FOR I in 1..H_CONTACT_POINT_ID.COUNT LOOP');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Contact Point ID','H_CONTACT_POINT_ID(I)');
  dc(fnd_log.level_statement,'Score','round((H_SCORE(I)/l_entered_max_score)*100)');
  de;
  --Start of Bug No: 4162385
   IF l_purpose = 'D' THEN
    l_entity_score_lh := 'H_SCORE(I)';
    l_entity_score_rh := 'ROUND(('||get_entity_level_score(p_rule_id,'CONTACT_POINTS')||'/'||l_max_score||') * '|| l_match_threshold || ')';
  ELSE
    l_entity_score_lh := 'H_SCORE(I)/l_entered_max_score';
    l_entity_score_rh := l_match_threshold||'/'||l_max_score;
  END IF;
  --End of Bug No: 4162385

  l('        IF ('|| l_entity_score_lh ||') >= ('|| l_entity_score_rh ||') THEN'); --Bug No: 4162385
  l('        INSERT INTO HZ_MATCHED_CPTS_GT(SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  l('            l_search_ctx_id,H_CONTACT_POINT_ID(I),H_PARTY_ID(I),round(H_SCORE(I)/l_entered_max_score)*100);');
  l('            x_num_matches := x_num_matches + 1; ');
  l('        END IF;');
  l('      END LOOP; ');
  l('    END IF;');
ELSE ---Start of Code Change for Match Rule Set
  l('  BEGIN');
  d(fnd_log.level_procedure,'get_matching_contact_points(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_contact_point_id','p_dup_contact_point_id');
  de;
  pop_conditions(p_rule_id,'get_matching_contact_points','p_rule_id,p_party_id,p_contact_point_list,p_restrict_sql,p_match_type,p_dup_contact_point_id,x_search_ctx_id,x_num_matches','CONTACT_POINTS');

END IF; ---End of Code Change for Match Rule Set
  d(fnd_log.level_procedure,'get_matching_contact_points(-)');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_matching_contact_points'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_matching_contact_points;');

  l('');
  l('   /**********************************************************');
  l('   This procedure finds the score details for a specific party that ');
  l('   matched ');
  l('');
  l('   **********************************************************/');
  l('');
  l('PROCEDURE get_score_details (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('        p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('        x_search_ctx_id         IN OUT  NUMBER');
  l(') IS');
  l('');
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
    l('  l_max_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('');
  l('  l_score NUMBER;');
  l('  l_match_idx NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_cpt_type VARCHAR2(100);');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_ps_contact_id NUMBER;');
  l('  l_max_id NUMBER;');
  l('  l_max_idx NUMBER;');
  l('');
  l('  l_index NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  --Fix for bug 4417124 ');
  l('  l_use_contact_addr_info BOOLEAN:=TRUE;');
  l('  l_use_contact_cpt_info  BOOLEAN:=TRUE;');
  l('  l_TX35_new VARCHAR2(4000);'); --9155543
  l('');
  l('  BEGIN');
  l('');
  d(fnd_log.level_statement,'get_score_details(+)');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');
  l('    l_entered_max_score:= init_search(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,'' OR '', l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');

  l('    -- ************************************************************');
  l('    -- STEP 2. Setup of intermedia query strings for Acquisition query');

  l('    l_party_site_contains_str := INIT_PARTY_SITES_QUERY(l_match_str,l_tmp);');
  l('    l_contact_contains_str := INIT_CONTACTS_QUERY(l_match_str,l_tmp);');
  l('    l_contact_pt_contains_str := INIT_CONTACT_POINTS_QUERY(l_match_str,l_tmp);');

  l('    init_score_context(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    IF x_search_ctx_id IS NULL THEN');
  l('      SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('      x_search_ctx_id := l_search_ctx_id;');
  l('    ELSE');
  l('      l_search_ctx_id := x_search_ctx_id;');
  l('    END IF;');
  l('');
  l('    open_party_cursor(p_party_id, null, null,null,null,null,l_party_cur);');
  l('    LOOP ');
  l('        FETCH l_party_cur INTO');
  l('           l_party_id '||l_p_into_list||';');
  l('        EXIT WHEN l_party_cur%NOTFOUND;');
    IF(l_p_param_list LIKE '%TX35%') THEN --9155543
  l('  l_TX35_new:=RTRIM(LTRIM(l_TX35));');
 	l('  l_TX35_new:=(CASE l_TX35_new WHEN ''SYNC'' THEN HZ_STAGE_MAP_TRANSFORM.den_acc_number (l_party_id) ELSE l_TX35_new END);');
 	   l_p_param_list:=replace(l_p_param_list,'l_TX35','l_TX35_new');
 	       END IF;
  IF l_p_param_list IS NOT NULL THEN
    l('          INSERT_PARTY_SCORE(p_party_id, p_party_id, l_search_ctx_id, p_party_search_rec, g_party_stage_rec, '||l_p_param_list||',1);');
  END IF;
  l_p_param_list:=replace(l_p_param_list,'l_TX35_new','l_TX35'); --9155543
  l('    END LOOP;');
  l('    CLOSE l_party_cur;');
  l('');
  l('    IF l_party_site_contains_str IS NOT NULL THEN');
  l('      l_max_score := 0;');
  l('      l_max_id := 0;');
  l('      l_max_idx := 0;');
  l('      IF p_party_search_rec.PARTY_TYPE = ''PERSON'' AND l_use_contact_addr_info THEN');
  l('        open_party_site_cursor(null, p_party_id, null, l_party_site_contains_str,NULL,NULL, ''Y'',''N'',l_party_site_cur);');
  l('      ELSE');
  l('        open_party_site_cursor(null, p_party_id, null, l_party_site_contains_str,NULL,NULL, ''N'',''N'',l_party_site_cur);');
  l('      END IF;');
  l('      LOOP');
  l('        FETCH l_party_site_cur INTO ');
  l('            l_party_site_id, l_ps_party_id,l_ps_contact_id '||l_ps_into_list||';');
  l('        EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('        l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');
  l('        IF l_score > l_max_score THEN');
  l('          l_max_score := l_score;');
  l('          l_max_id := l_party_site_id;');
  l('          l_max_idx := l_match_idx;');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.entity_name = 'PARTY_SITES'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('          l_max_'||TX.staged_attribute_column ||' := l_'||TX.staged_attribute_column ||';');
  END LOOP;
  l('        END IF;');
  l('      END LOOP;');
  l('      CLOSE l_party_site_cur;');
  l('      IF l_max_score>0 THEN');
  l('        INSERT_PARTY_SITES_SCORE(p_party_id,l_max_id,l_search_ctx_id, p_party_site_list(l_max_idx), g_party_site_stage_list(l_max_idx) '||replace(l_ps_param_list,'l_TX','l_max_TX')||',l_max_idx);');
  l('      END IF;');
  l('    END IF;');
  l('');
  l('    IF l_contact_contains_str IS NOT NULL THEN');
  l('      l_max_score := 0;');
  l('      l_max_id := 0;');
  l('      l_max_idx := 0;');
  l('      open_contact_cursor(null, p_party_id, null, l_contact_contains_str,NULL, null, l_contact_cur);');
  l('      LOOP');
  l('        FETCH l_contact_cur INTO ');
  l('            l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('        EXIT WHEN l_contact_cur%NOTFOUND;');
  l('        l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');
  l('        IF l_score > l_max_score THEN');
  l('          l_max_score := l_score;');
  l('          l_max_id := l_org_contact_id;');
  l('          l_max_idx := l_match_idx;');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.entity_name = 'CONTACTS'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('          l_max_'||TX.staged_attribute_column ||' := l_'||TX.staged_attribute_column ||';');
  END LOOP;
  l('        END IF;');
  l('      END LOOP;');
  l('      CLOSE l_contact_cur;');
  l('      IF l_max_score>0 THEN');
  l('        INSERT_CONTACTS_SCORE(p_party_id,l_max_id,l_search_ctx_id, p_contact_list(l_max_idx), g_contact_stage_list(l_max_idx) '||replace(l_c_param_list,'l_TX','l_max_TX')||',l_max_idx);');
  l('      END IF;');
  l('    END IF;');
  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('      l_max_score := 0;');
  l('      l_max_id := 0;');
  l('      l_max_idx := 0;');
  l('      IF p_party_search_rec.PARTY_TYPE = ''PERSON'' AND l_use_contact_cpt_info THEN');
  l('        open_contact_pt_cursor(null, p_party_id, null, l_contact_pt_contains_str,NULL,NULL, ''Y'',''N'',l_contact_pt_cur);');
  l('      ELSE');
  l('        open_contact_pt_cursor(null, p_party_id, null, l_contact_pt_contains_str,NULL,NULL, ''N'',''N'',l_contact_pt_cur);');
  l('      END IF;');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_type, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('        l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('        IF l_score > l_max_score THEN');
  l('          l_max_score := l_score;');
  l('          l_max_id := l_contact_pt_id;');
  l('          l_max_idx := l_match_idx;');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.entity_name = 'CONTACT_POINTS'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('          l_max_'||TX.staged_attribute_column ||' := l_'||TX.staged_attribute_column ||';');
  END LOOP;
  l('        END IF;');
  l('      END LOOP;');
  l('      IF l_max_score>0 THEN');
  l('        INSERT_CONTACT_POINTS_SCORE(p_party_id,l_max_id,l_search_ctx_id, p_contact_point_list(l_max_idx), g_contact_pt_stage_list(l_max_idx) '||replace(l_cpt_param_list,'l_TX','l_max_TX')||',l_max_idx);');
  l('      END IF;');
  l('      CLOSE l_contact_pt_cur;');
  l('    END IF;');
  d(fnd_log.level_procedure,'get_score_details(-)');
ELSE ---Start of Code Change for Match Rule Set
  l('  BEGIN');
  l('');
  d(fnd_log.level_statement,'get_score_details(+)');
    pop_conditions(p_rule_id,'get_score_details','p_rule_id,p_party_id,p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,x_search_ctx_id','PARTY');
  d(fnd_log.level_procedure,'get_score_details(-)');
END IF; ---End of Code Change for Match Rule Set

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_score_details'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_score_details;');
  l('');

  generate_acquire_proc(p_rule_id, NULL);


  generate_party_map_proc('MAP_PARTY_REC', p_rule_id);
  l('');
  generate_map_proc('PARTY_SITES', 'MAP_PARTY_SITE_REC', p_rule_id);
  l('');
  generate_map_proc('CONTACTS', 'MAP_CONTACT_REC', p_rule_id);
  l('');
  generate_map_proc('CONTACT_POINTS', 'MAP_CONTACT_POINT_REC', p_rule_id);
  l('');
  generate_check_proc(p_rule_id);
  generate_check_staged (p_rule_id);
  /*l('  PROCEDURE enable_debug IS');

  l('  BEGIN');
  l('    g_debug_count := g_debug_count + 1;');

  l('    IF g_debug_count = 1 THEN');
  l('      IF fnd_profile.value(''HZ_API_FILE_DEBUG_ON'') = ''Y'' OR');
  l('         fnd_profile.value(''HZ_API_DBMS_DEBUG_ON'') = ''Y''');
  l('      THEN');
  l('        hz_utility_v2pub.enable_debug;');
  l('        g_debug := TRUE;');
  d('PKG: '||p_pkg_name||' (+)');
  l('      END IF;');
  l('    END IF;');
  l('  END enable_debug;');

  l('  PROCEDURE disable_debug IS');

  l('  BEGIN');

  l('    IF g_debug THEN');
  l('      g_debug_count := g_debug_count - 1;');

  l('      IF g_debug_count = 0 THEN');
  d('PKG: '||p_pkg_name||' (-)');
  l('        hz_utility_v2pub.disable_debug;');
  l('        g_debug := FALSE;');
  l('      END IF;');
  l('    END IF;');

  l('  END disable_debug;');
  */

  l('END;');
  l('');
END;


-- VJN introduced procedure that will generate the procedure check_proc_bulk
-- which would essentially return a 'Y' or null to signify the corresponding
-- XXX_contains_string contains user passed information or not.

PROCEDURE generate_check_parties_bulk (
	p_rule_id	NUMBER) IS
FIRST BOOLEAN;
BEGIN
  l('');
  l('/************************************************');
  l('  This procedure checks if the input search criteria ');
  l('  is valid. It checks if : ');
  l('   1. At least one primary condition is passed');
  l('************************************************/');
  l('');

  l('FUNCTION check_parties_bulk(');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type)');
  l('RETURN VARCHAR2 IS');
  l('  BEGIN');

  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND p.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND nvl(p.FILTER_FLAG,'N') = 'N') LOOP
    l('    IF p_party_search_rec.'||PRIMATTRS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      RETURN ''Y'' ;');
    l('    END IF;');
  END LOOP;

  l('RETURN null;');

  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_parties_bulk'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_parties_bulk ;');
  l('');
END generate_check_parties_bulk ;


-- VJN introduced procedure that will generate the procedure check_proc_bulk
-- which would essentially return a 'Y' or null to signify the corresponding
-- XXX_contains_string contains user passed information or not.

PROCEDURE generate_check_partysites_bulk (
	p_rule_id	NUMBER) IS
FIRST BOOLEAN;
BEGIN
  l('/************************************************');
  l('  This procedure checks if the input search condition ');
  l('  has party site criteria. ');
  l('************************************************/');

  l('');
  l('FUNCTION check_party_sites_bulk(');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list');
  l(')');
  l('RETURN VARCHAR2 IS');
  l('    x_primary boolean := FALSE;');
  l('  BEGIN');
  l('    FOR I IN 1..p_party_site_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'PARTY_SITES'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_party_site_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_party_site_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('');

  l(' IF x_primary = TRUE THEN RETURN ''Y''; ELSE RETURN null; END IF; ');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_party_sites_bulk'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_party_sites_bulk ;');
  l('');

END generate_check_partysites_bulk ;



-- VJN introduced procedure that will generate the procedure check_proc_bulk
-- which would essentially return a 'Y' or null to signify the corresponding
-- XXX_contains_string contains user passed information or not.

PROCEDURE generate_check_contacts_bulk (
	p_rule_id	NUMBER) IS
FIRST BOOLEAN;
BEGIN
  l('/************************************************');
  l('  This procedure checks if the input search condition ');
  l('  has contact criteria. ');
  l('************************************************/');

  l('');
  l('FUNCTION check_contacts_bulk (');
  l('      p_contact_list       IN      HZ_PARTY_SEARCH.contact_list');
  l(')');
  l('RETURN VARCHAR2 IS');
  l('    x_primary boolean := FALSE;');
  l('  BEGIN');
  l('    FOR I IN 1..p_contact_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACTS'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('');

  l(' IF x_primary = TRUE THEN RETURN ''Y''; ELSE RETURN null; END IF; ');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_contacts_bulk'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_contacts_bulk ;');
  l('');

END generate_check_contacts_bulk ;

-- VJN introduced procedure that will generate the procedure check_proc_bulk
-- which would essentially return a 'Y' or null to signify the corresponding
-- XXX_contains_string contains user passed information or not.

PROCEDURE generate_check_cpts_bulk (
	p_rule_id	NUMBER) IS
FIRST BOOLEAN;
BEGIN
  l('/************************************************');
  l('  This procedure checks if the input search condition ');
  l('  has contact criteria. ');
  l('************************************************/');

  l('');
  l('FUNCTION check_cpts_bulk (');
  l('      p_contact_point_list       IN      HZ_PARTY_SEARCH.contact_point_list');
  l(')');
  l('RETURN VARCHAR2 IS');
  l('    x_primary boolean := FALSE;');
  l('  BEGIN');
  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('');

  l(' IF x_primary = TRUE THEN RETURN ''Y''; ELSE RETURN null; END IF; ');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_cpts_bulk'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_cpts_bulk  ;');
  l('');

END generate_check_cpts_bulk ;



/**
* VJN introduced Private procedure to generate the body of the Public Match Rule API
* for a bulk match rule. This will generate Package Body for the following kind of Match rules:
*    HZ_IMP_MATCH_RULE_<p_rule_id>
*
*
**/
PROCEDURE gen_pkg_body_bulk (
        p_pkg_name      IN      VARCHAR2,
        p_rule_id	IN	NUMBER
) IS

  -- Local Variables
  FIRST boolean;
  FIRST1 boolean;
  UPSTMT boolean;
  l_match_str VARCHAR2(255);
  l_attrib_cnt NUMBER;
  l_party_filter VARCHAR2(1) := null;
  l_ps_filter VARCHAR2(1) := null;
  l_contact_filter VARCHAR2(1) := null;
  l_cpt_filter VARCHAR2(1) := null;
  l_num_primary NUMBER;
  l_num_secondary NUMBER;
  l_ent VARCHAR2(30);
  l_max_score NUMBER;
  l_match_threshold NUMBER;

  l_purpose VARCHAR2(30);
  TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE CharList IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  attribList NumberList;

  l_party_filter_str VARCHAR2(2000);
  l_dyn_party_filter_str VARCHAR2(2000);
  l_p_select_list VARCHAR2(1000);
  l_p_param_list VARCHAR2(1000);
  l_p_into_list VARCHAR2(1000);
  l_ps_select_list VARCHAR2(1000);
  l_ps_param_list VARCHAR2(1000);
  l_ps_into_list VARCHAR2(1000);
  l_c_select_list VARCHAR2(1000);
  l_c_param_list VARCHAR2(1000);
  l_c_into_list VARCHAR2(1000);
  l_cpt_select_list VARCHAR2(1000);
  l_cpt_param_list VARCHAR2(1000);
  l_cpt_into_list VARCHAR2(1000);
  cnt NUMBER;
  l_party_filt_bind CharList;
  l_cpt_type VARCHAR2(255);
  l_trans VARCHAR2(4000);
  l_auto_merge_score NUMBER;
  tmp VARCHAR2(30);
  attrib_count NUMBER;
BEGIN

  -- Query match thresholds and search type
  SELECT RULE_PURPOSE, MATCH_SCORE, nvl(AUTO_MERGE_SCORE,99999), decode(MATCH_ALL_FLAG,'Y',' AND ',' OR ')
  INTO l_purpose, l_match_threshold, l_auto_merge_score, l_match_str
  FROM HZ_MATCH_RULES_VL
  WHERE match_rule_id = p_rule_id;

  SELECT nvl(SUM(SCORE),1) INTO l_max_score
  FROM HZ_MATCH_RULE_SECONDARY
  WHERE match_rule_id = p_rule_id;

  l('CREATE or REPLACE PACKAGE BODY ' || p_pkg_name || ' AS');
  l('/*=======================================================================+');
  l(' |  Copyright (c) 1999 Oracle Corporation Redwood Shores, California, USA|');
  l(' |                          All rights reserved.                         |');
  l(' +=======================================================================+');
  l(' | NAME');
  l(' |      ' || p_pkg_name);
  l(' |');
  l(' | DESCRIPTION');
  l(' |');
  l(' | Compiled by the HZ Match Rule Compiler');
  l(' | -- Do Not Modify --');
  l(' |');
  l(' | PUBLIC PROCEDURES');
  l(' |    find_parties');
  l(' |    get_matching_party_sites');
  l(' |    get_matching_contacts');
  l(' |    get_matching_contact_points');
  l(' |    get_score_details');
  l(' |    ');
  l(' | HISTORY');
  l(' |      '||TO_CHAR(SYSDATE,'DD-MON-YYYY') || ' Generated by HZ Match Rule Compiler');
  l(' |');
  l(' *=======================================================================*/');
  l('');
  l('-- ==========================================================================================');
  l('-- ============MATCH RULE COMPILER GENERATED CODE FOR BULK MATCH RULES ======================');
  l('-- ==========================================================================================');
  l('');
  l('  TYPE vlisttype IS TABLE of VARCHAR2(255) INDEX BY BINARY_INTEGER ;');
  l('  call_order vlisttype;');
  l('  call_max_score HZ_PARTY_SEARCH.IDList;');
  l('  call_type vlisttype;');
  l('  g_party_stage_rec  HZ_PARTY_STAGE.party_stage_rec_type;');
  l('  g_party_site_stage_list  HZ_PARTY_STAGE.party_site_stage_list;');
  l('  g_contact_stage_list  HZ_PARTY_STAGE.contact_stage_list;');
  l('  g_contact_pt_stage_list  HZ_PARTY_STAGE.contact_pt_stage_list;');
  l('  g_mappings  HZ_PARTY_SEARCH.IDList;');
  l('  g_max_id NUMBER:=2000000000;');
  l('');
  l('  g_debug_count                        NUMBER := 0;');
  --l('  g_debug                              BOOLEAN := FALSE;');
  l('  g_score_until_thresh BOOLEAN:=false;');
  l(' ');
  l('  g_thres_score NUMBER:=1000;');
  --l('  PROCEDURE enable_debug;');
  --l('  PROCEDURE disable_debug;');

  -- VJN introduced for bulk_match_rule
  generate_check_parties_bulk(p_rule_id);
  generate_check_partysites_bulk(p_rule_id);
  generate_check_contacts_bulk(p_rule_id);
  generate_check_cpts_bulk(p_rule_id);

  /***********************************************************************
  * Private procedure to map IDs greater than the max allowed by PLSQL
  * Index-by tables.
  ************************************************************************/
  l('  FUNCTION map_id (in_id NUMBER) RETURN NUMBER IS');
  l('    l_newidx NUMBER;');
  l('  BEGIN ');
  l('    IF in_id<g_max_id THEN ');
  l('      RETURN in_id;');
  l('    ELSE');
  l('      FOR I in 1..g_mappings.COUNT LOOP');
  l('        IF in_id = g_mappings(I) THEN');
  l('          RETURN (g_max_id+I);');
  l('        END IF;');
  l('      END LOOP;');
  l('      l_newidx := g_mappings.COUNT+1;');
  l('      g_mappings(l_newidx) := in_id;');
  l('      RETURN (g_max_id+l_newidx);');
  l('    END IF;');
  l('  END;');

  l('  FUNCTION GET_PARTY_SCORE ');
  FIRST := TRUE;
  FOR TX IN (
      SELECT f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id
      AND a.entity_name= 'PARTY'
      ORDER BY sa.attribute_id) LOOP
     IF FIRST THEN
       l('       (');
       l('       p_table_'||TX.staged_attribute_column||' VARCHAR2');
       FIRST := FALSE;
     ELSE
       l('      ,p_table_'||TX.staged_attribute_column||' VARCHAR2');
     END IF;
  END LOOP;
  IF FIRST THEN
    l('   RETURN NUMBER IS');
  ELSE
    l('  ) RETURN NUMBER IS');
  END IF;
  l('    total NUMBER := 0;');
  l('  BEGIN');
  d(fnd_log.level_procedure,'GET_PARTY_SCORE  ');
  l('    IF g_score_until_thresh AND (total)>=g_thres_score THEN');
  l('      RETURN total;');
  l('    END IF;');
  FOR SECATTRS IN (
        SELECT SECONDARY_ATTRIBUTE_ID, SCORE, ATTRIBUTE_NAME, ENTITY_NAME, a.attribute_id
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY s
        WHERE s.match_rule_id = p_rule_id
        AND s.attribute_id = a.attribute_id
        AND a.entity_name = 'PARTY') LOOP
      FIRST := TRUE;
      FOR SECTRANS IN (
          SELECT TRANSFORMATION_NAME, STAGED_ATTRIBUTE_COLUMN, f.FUNCTION_ID,
                 TRANSFORMATION_WEIGHT, SIMILARITY_CUTOFF
          FROM HZ_SECONDARY_TRANS s,
               HZ_TRANS_FUNCTIONS_VL f
          WHERE s.SECONDARY_ATTRIBUTE_ID = SECATTRS.SECONDARY_ATTRIBUTE_ID
          AND s.FUNCTION_ID = f.FUNCTION_ID
          ORDER BY TRANSFORMATION_WEIGHT desc) LOOP
        IF FIRST THEN
           FIRST := FALSE;
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('    IF HZ_DQM_SEARCH_UTIL.is_similar_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||','||SECTRANS.FUNCTION_ID||') THEN');
           ELSE
             l('    IF HZ_DQM_SEARCH_UTIL.is_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||','||SECTRANS.FUNCTION_ID||') THEN');
           END IF;
        ELSE
           IF SECTRANS.SIMILARITY_CUTOFF IS NOT NULL THEN
             l('    ELSIF HZ_DQM_SEARCH_UTIL.is_similar_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||', '||SECTRANS.SIMILARITY_CUTOFF||','||SECTRANS.FUNCTION_ID||') THEN');
           ELSE
             l('    ELSIF HZ_DQM_SEARCH_UTIL.is_match(g_party_stage_rec.'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||
               ', p_table_'||SECTRANS.STAGED_ATTRIBUTE_COLUMN||','||SECTRANS.FUNCTION_ID||') THEN');
           END IF;
        END IF;
        l('      total := total+'||ROUND(SECATTRS.SCORE*(SECTRANS.TRANSFORMATION_WEIGHT/100))||';');
        l('      IF g_score_until_thresh AND (total)>=g_thres_score THEN ');
        l('        RETURN total;');
        l('      END IF;');
      END LOOP;
      l('    END IF;');
  END LOOP;
  l('    RETURN total;');
  l('  END;');

  add_score_function('PARTY_SITES',p_rule_id);
  add_score_function('CONTACTS',p_rule_id);
  add_score_function('CONTACT_POINTS',p_rule_id);
  add_get_attrib_func(p_rule_id);
  add_insert_function('PARTY',p_rule_id);
  add_insert_function('PARTY_SITES',p_rule_id);
  add_insert_function('CONTACTS',p_rule_id);
  add_insert_function('CONTACT_POINTS',p_rule_id);

  --- VJN Introduced for conditional Word Replacements
  --- Populate the global condition record before doing the mapping
  --- so that mapping takes into account conditional word replacements if any
  generate_ent_cond_pop_rec_proc('PARTY', p_rule_id);
  l('');
  generate_ent_cond_pop_rec_proc('PARTY_SITES', p_rule_id);
  l('');
  generate_ent_cond_pop_rec_proc('CONTACTS', p_rule_id);
  l('');
  generate_ent_cond_pop_rec_proc('CONTACT_POINTS', p_rule_id);
  l('');


  l('  PROCEDURE init_score_context (');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list:= ');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_POINT_LIST');
  l('  ) IS');
  l('   l_dummy NUMBER;');
  l('  BEGIN');
  l('    -- Transform search criteria');
  l('    HZ_TRANS_PKG.clear_globals;');
  l('    MAP_PARTY_REC(FALSE,p_party_search_rec, l_dummy, g_party_stage_rec);');
  l('    MAP_PARTY_SITE_REC(FALSE,p_party_site_list, l_dummy, g_party_site_stage_list);');
  l('    MAP_CONTACT_REC(FALSE,p_contact_list, l_dummy, g_contact_stage_list);');
  l('    MAP_CONTACT_POINT_REC(FALSE,p_contact_point_list, l_dummy, g_contact_pt_stage_list);');
  l('');
  l('  END;');


  l('  FUNCTION init_search(');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list:= ');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list:=');
  l('                                  HZ_PARTY_SEARCH.G_MISS_CONTACT_POINT_LIST,');
  l('      p_match_type            IN  VARCHAR2,');
  l('      x_party_max_score       OUT NUMBER,');
  l('      x_ps_max_score       OUT NUMBER,');
  l('      x_contact_max_score       OUT NUMBER,');
  l('      x_cpt_max_score       OUT NUMBER');
  l('  ) RETURN NUMBER IS ');
  l('  l_entered_max_score NUMBER:=0;');
  l('  l_ps_entered_max_score NUMBER:=0;');
  l('  l_ct_entered_max_score NUMBER:=0;');
  l('  l_cpt_entered_max_score NUMBER:=0;');
  l('  vlist vlisttype;');
  l('  maxscore HZ_PARTY_SEARCH.IDList;');
  l('  l_name VARCHAR2(200);');
  l('  l_idx NUMBER; ');
  l('  l_num NUMBER; ');
  l('  total NUMBER; ');
  l('  threshold NUMBER; ');
  l('  BEGIN');
  l('    IF NOT check_prim_cond (p_party_search_rec,');
  l('                            p_party_site_list,');
  l('                            p_contact_list,');
  l('                            p_contact_point_list) THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_PRIMARY_COND'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  IF l_max_score=1 THEN
    l('    HZ_DQM_SEARCH_UTIL.set_no_score;');
  ELSE
    l('    HZ_DQM_SEARCH_UTIL.set_score;');
  END IF;
  l('    g_mappings.DELETE;');
  l('    g_party_site_stage_list.DELETE;');
  l('    g_contact_stage_list.DELETE;');
  l('    g_contact_pt_stage_list.DELETE;');
  l('    call_order.DELETE;');
  l('    call_max_score.DELETE;');
  l('    HZ_DQM_SEARCH_UTIL.new_search;');
  l('    HZ_TRANS_PKG.set_party_type(p_party_search_rec.PARTY_TYPE);');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(0);');
  l('');
  l('    -- Transform search criteria');
  l('    MAP_PARTY_REC(TRUE,p_party_search_rec, l_entered_max_score, g_party_stage_rec);');
  l('    MAP_PARTY_SITE_REC(TRUE,p_party_site_list, l_ps_entered_max_score, g_party_site_stage_list);');
  l('    MAP_CONTACT_REC(TRUE,p_contact_list, l_ct_entered_max_score, g_contact_stage_list);');
  l('    MAP_CONTACT_POINT_REC(TRUE,p_contact_point_list, l_cpt_entered_max_score, g_contact_pt_stage_list);');
  l('');
  l('      ');
  l('    l_idx := l_entered_max_score+1;');
  l('    vlist (l_idx) := ''PARTY'';');
  l('    maxscore (l_idx) := l_entered_max_score;');

  l('    l_idx := l_ps_entered_max_score+1;');
  l('    WHILE vlist.EXISTS(l_idx) LOOP');
  l('      l_idx := l_idx+1;');
  l('    END LOOP;');
  l('    vlist (l_idx) := ''PARTY_SITE'';');
  l('    maxscore (l_idx) := l_ps_entered_max_score;');
  l('');
  l('    l_idx := l_ct_entered_max_score+1;');
  l('    WHILE vlist.EXISTS(l_idx) LOOP');
  l('      l_idx := l_idx+1;');
  l('    END LOOP;');
  l('    vlist (l_idx) := ''CONTACT'';');
  l('    maxscore (l_idx) := l_ct_entered_max_score;');
  l('');
  l('    l_idx := l_cpt_entered_max_score+1;');
  l('    WHILE vlist.EXISTS(l_idx) LOOP');
  l('      l_idx := l_idx+1;');
  l('    END LOOP;');
  l('    vlist (l_idx) := ''CONTACT_POINT'';');
  l('    maxscore (l_idx) := l_cpt_entered_max_score;');
  l('');
  l('    l_num := 1;');
  l('    l_idx := vlist.LAST;');
  l('    WHILE l_idx IS NOT NULL LOOP');
  l('      call_order(l_num) := vlist(l_idx);');
  l('      call_max_score(l_num) := maxscore(l_idx);');
  l('      l_idx := vlist.PRIOR(l_idx);');
  l('      l_num := l_num+1;');
  l('    END LOOP;  ');
  l('    call_order(5):=''NONE'';');
  l('    IF p_match_type = '' OR '' THEN');
  IF l_purpose = 'S' THEN
    l('      threshold := round(('||l_match_threshold||'/'||l_max_score||')*(l_entered_max_score+l_ps_entered_max_score+l_ct_entered_max_score+l_cpt_entered_max_score));');
  ELSE
    l('      threshold := '||l_match_threshold||';');
  END IF;

  l('      l_idx := vlist.FIRST;');
  l('      total := 0;');
  l('      l_num := 4;');
  l('      WHILE l_idx IS NOT NULL LOOP');
  l('        total := total+maxscore(l_idx);');
  l('        IF total<threshold THEN');
  l('          call_type(l_num) := ''AND'';');
  l('        ELSE');
  l('          call_type(l_num) := ''OR'';');
  l('        END IF;');
  l('        l_idx := vlist.NEXT(l_idx);');
  l('        l_num := l_num-1;');
  l('      END LOOP;');
  l('    ELSE');
  l('      call_type(1) := ''OR'';');
  l('      call_type(2) := ''AND'';');
  l('      call_type(3) := ''AND'';');
  l('      call_type(4) := ''AND'';');
  l('    END IF;');
  l('    x_party_max_score := l_entered_max_score;');
  l('    x_ps_max_score := l_ps_entered_max_score;');
  l('    x_contact_max_score := l_ct_entered_max_score;');
  l('    x_cpt_max_score := l_cpt_entered_max_score;');

  l('    RETURN (l_entered_max_score+l_ps_entered_max_score+l_ct_entered_max_score+l_cpt_entered_max_score);');
  l('  END;');



                FIRST := TRUE;
                g_party_or_query := null;
                g_party_and_query := null;
                cnt := cnt+1;
                FOR PRIMATTRS IN (
                  SELECT a.ATTRIBUTE_ID, PRIMARY_ATTRIBUTE_ID, ATTRIBUTE_NAME, nvl(SCORE,0) SCORE
                  FROM HZ_TRANS_ATTRIBUTES_VL a,
                       HZ_MATCH_RULE_PRIMARY p,
                       HZ_MATCH_RULE_SECONDARY s
                  WHERE p.match_rule_id = p_rule_id
                  AND s.match_rule_id (+) = p_rule_id
                  AND s.attribute_id (+) = a.attribute_id
                  AND p.attribute_id = a.attribute_id
                  AND a.ENTITY_NAME = 'PARTY'
                  AND nvl(FILTER_FLAG,'N') <> 'Y'
                  ORDER BY SCORE) LOOP
                  FIRST1 := TRUE;
                  FOR PRIMTRANS IN (
                    SELECT f.STAGED_ATTRIBUTE_COLUMN, f.TRANSFORMATION_NAME, nvl(f.PRIMARY_FLAG,'N') PRIMARY_FLAG
                    FROM HZ_TRANS_FUNCTIONS_VL f,
                       HZ_PRIMARY_TRANS pt
                  WHERE pt.PRIMARY_ATTRIBUTE_ID = PRIMATTRS.PRIMARY_ATTRIBUTE_ID
                  AND pt.FUNCTION_ID = f.FUNCTION_ID)
                  LOOP
                      IF FIRST1 THEN
                        l_trans := '(g_party_stage_rec.'||
                                   PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NULL OR '' ''||'||
                                   PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' '' like ''% ''||g_party_stage_rec.'||
                                   PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' %'')';
                        FIRST1 := FALSE;
                      ELSE
                        l_trans := l_trans||' OR (g_party_stage_rec.'||
                                   PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||' IS NULL OR '' ''||'||
                                   PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' '' like ''% ''||g_party_stage_rec.'||
                                   PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||'||'' %'')';
                      END IF;
                        IF PRIMTRANS.PRIMARY_FLAG = 'Y' THEN
                          tmp := '''A'||PRIMATTRS.ATTRIBUTE_ID||'''';
                        ELSE
                          tmp := 'NULL';
                        END IF;

                  END LOOP;

                 l('');



                END LOOP;

                get_column_list(p_rule_id, 'PARTY',l_p_select_list,l_p_param_list, l_p_into_list);
                get_column_list(p_rule_id, 'PARTY_SITES',l_ps_select_list,l_ps_param_list, l_ps_into_list);
                get_column_list(p_rule_id, 'CONTACTS',l_c_select_list,l_c_param_list, l_c_into_list);
                get_column_list(p_rule_id, 'CONTACT_POINTS',l_cpt_select_list,l_cpt_param_list, l_cpt_into_list);

                l_party_filter_str := NULL;
                l_dyn_party_filter_str := NULL;
                FIRST := TRUE;
                cnt := 1;
                for PRIMTRANS IN (
                      SELECT f.STAGED_ATTRIBUTE_COLUMN
                      FROM HZ_TRANS_FUNCTIONS_VL f,
                           HZ_TRANS_ATTRIBUTES_VL a,
                           HZ_MATCH_RULE_PRIMARY pattr,
                           HZ_PRIMARY_TRANS pfunc
                      WHERE pattr.MATCH_RULE_ID = p_rule_id
                      AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
                      AND a.ENTITY_NAME = 'PARTY'
                      AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
                      AND pfunc.FUNCTION_ID = f.FUNCTION_ID
                      AND nvl(FILTER_FLAG,'N')  = 'Y'

                      UNION

                      SELECT f.STAGED_ATTRIBUTE_COLUMN
                      FROM HZ_TRANS_FUNCTIONS_VL f,
                          HZ_TRANS_ATTRIBUTES_VL a
                      WHERE f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
                      AND a.entity_name = 'PARTY'
                      AND a.attribute_name='PARTY_TYPE'
                      AND f.PROCEDURE_NAME='HZ_TRANS_PKG.EXACT'
                      AND nvl(f.active_flag,'Y')='Y'
                      AND ROWNUM=1
                ) LOOP

                      IF FIRST THEN
                        l_party_filter_str := '(g_party_stage_rec.'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
                             ' IS NULL OR g_party_stage_rec.'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'' '' =  p.' ||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
                        l_dyn_party_filter_str := '(:'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
                             ' IS NULL OR :'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'''' '''' =  p.' ||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
                        FIRST := FALSE;
                      ELSE
                        l_dyn_party_filter_str := l_dyn_party_filter_str || ' AND ' ||
                             '(:'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
                             ' IS NULL OR :'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'''' '''' =  p.' ||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
                        l_party_filter_str := l_party_filter_str || ' AND ' ||
                             '(g_party_stage_rec.'||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN ||
                             ' IS NULL OR g_party_stage_rec.'||
                             PRIMTRANS.STAGED_ATTRIBUTE_COLUMN || '||'' '' =  p.' ||
                              PRIMTRANS.STAGED_ATTRIBUTE_COLUMN||')';
                      END IF;
                      l_party_filt_bind(cnt) := 'g_party_stage_rec.'||PRIMTRANS.STAGED_ATTRIBUTE_COLUMN;
                      cnt:=cnt+1;
                END LOOP;




   /*********************************************************************************
   * Match rule private procedures to open a cursor for performing B-tree index queries.
   *   open_party_cursor - B-tree index query on HZ_STAGED_PARTIES
   *   open_party_site_cursor - B-tree index query on HZ_STAGED_PARTY_SITES
   *   open_contact_cursor - B-tree index query on HZ_STAGED_CONTACTS
   *   open_contact_pt_cursor - B-tree index query on HZ_STAGED_CONTACT_POINTS
   *
   * Input:
   * p_dup_party_id : Called in the duplicate identification case, to filter off
   *                  the party for which we are trying find duplicates.
   * p_restrict_sql : restrict_sql criteria passed to match rule
   * p_contains_str : null or 'Y'
   * p_search_ctx_id : Only to called from find_party_details, for filtering against
   *                  party_ids returned by the party query
   * p_party_id : USed in the get_matching_party_sites, get_matching_contacts and
   *              get_matching_cpts procedures, to only find records belonging to the specified
   *              party_id
   *********************************************************************************/

  -- VJN: Introduced the code generation of match rules based on rule purpose
  --      so that Expanded Duplicate Identification Match rules uses intermedia indexes
  --      where as the bulk duplicate identification match rules use the conventional
  --      B-tree indexes.
        l('  PROCEDURE open_party_cursor(');
        l('            p_dup_party_id NUMBER, ');
        l('            p_restrict_sql VARCHAR2, ');
        l('            p_contains_str  VARCHAR2, ');
        l('            p_search_ctx_id NUMBER,');
        l('            p_match_str VARCHAR2,');
        l('            p_search_merged VARCHAR2,');
        l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
        l('  l_sqlstr VARCHAR2(4000);');
        l('  BEGIN');
        IF has_acquisition_attribs (p_rule_id, 'PARTY')
        THEN
        l('    IF p_contains_str IS NULL THEN');
        /**** To query based on party_id .. from the get_score_details flow ***/
        l('      OPEN x_cursor FOR ');
        l('        SELECT PARTY_ID '|| l_p_select_list);
        l('        FROM HZ_STAGED_PARTIES stage');
        l('        WHERE PARTY_ID = p_dup_party_id;');

        /**** Static queries when restrict_sql is null OR if p_search_ctx_id IS NOT NULL *****/
        l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');

        /**** When search context ID is null .. Retrieve rows using B-tree indexes ****/
        l('      IF p_search_ctx_id IS NULL THEN');
        l('        OPEN x_cursor FOR ');
        l('          SELECT /*+ ORDERED */ stage.PARTY_ID '|| replace(l_p_select_list,'T','stage.T'));
        l('          FROM HZ_SRCH_PARTIES srch, HZ_STAGED_PARTIES stage');
        l('          WHERE');

        generate_bulk_predicate(p_rule_id,'N',l_match_str,'PARTY');

             IF l_party_filter_str IS NOT NULL THEN
          l('          AND ('||replace(l_party_filter_str,'p.','stage.')||')');
        END IF;
        l('          AND (nvl(p_search_merged,''N'')=''Y'' OR nvl(stage.status,''A'') in (''A''))');
        l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');


        /**** When search context ID is not null .. Query using DQM_PARTIES_GT. Filter using
              B-tree index ****/
        l('      ELSE');
        l('        OPEN x_cursor FOR ');
        l('            SELECT /*+ ORDERED INDEX(stage HZ_STAGED_PARTIES_U1) */ stage.PARTY_ID '|| replace(l_p_select_list,'T','stage.T'));
        l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_PARTIES stage, HZ_SRCH_PARTIES srch');
        l('            WHERE');

        generate_bulk_predicate(p_rule_id,'N',l_match_str,'PARTY');

        l('            AND d.SEARCH_CONTEXT_ID=p_search_ctx_id');
        l('            AND d.party_id = stage.party_id');
        IF l_party_filter_str IS NOT NULL THEN
          l('            AND ('||replace(l_party_filter_str,'p.','stage.')||')');
        END IF;
        l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id)');
        l('            AND (nvl(p_search_merged,''N'')=''Y'' OR nvl(stage.status,''A'') in (''A''));');
        l('      END IF;');

        /**** When restrict_sql is not null *****/
        l('    ELSE');

        /**** When search context ID is null .. Access using B-tree index ***/
        l('     IF p_search_ctx_id IS NULL THEN');
        l('       l_sqlstr := ''SELECT /*+ ORDERED */ stage.PARTY_ID '|| replace(l_p_select_list,'T','stage.T')||'''||');
        l('                   '' FROM HZ_SRCH_PARTIES srch, HZ_STAGED_PARTIES stage''||');
        l('                   '' WHERE''||');

        generate_bulk_predicate(p_rule_id,'Y',l_match_str,'PARTY');

        IF l_dyn_party_filter_str IS NOT NULL THEN
          l('                   '' AND ('||replace(l_dyn_party_filter_str,'p.','stage.')||')''||');
        END IF;
        l('                   '' AND (''||p_restrict_sql||'')'' ||');
        l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
        l('       IF p_search_merged IS NULL OR p_search_merged <> ''Y'' THEN');
        l('         l_sqlstr := l_sqlstr ||'' AND nvl(stage.status,''''A'''') in (''''A'''')'';');
        l('       END IF;');
        l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
        FOR I in 1..l_party_filt_bind.COUNT LOOP
            l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
        END LOOP;
        l('                    ,p_dup_party_id, p_dup_party_id;');
        l('     END IF;');
        l('   END IF;');
        l('  exception');
        l('    when others then');
        l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
        l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
        l('        FND_MSG_PUB.ADD;');
        l('        RAISE FND_API.G_EXC_ERROR;');
        l('      else ');
        l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
        l('      end if;');
        ELSE
           l('NULL ;');
        END IF;
        l('  END;');
        l('');


  l('  PROCEDURE open_party_site_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  BEGIN');
  IF has_acquisition_attribs (p_rule_id, 'PARTY_SITES')
  THEN

                      /**** For a single party_id scenario. Retrieve using party_id ****/
            l('     IF p_party_id IS NOT NULL THEN');
            l('       OPEN x_cursor FOR ');
            l('          SELECT /*+ INDEX(stage HZ_STAGED_PARTY_SITES_N1) */ stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID'||
                                                       replace(l_ps_select_list,'T','stage.T') );
            l('          FROM HZ_STAGED_PARTY_SITES stage,HZ_SRCH_PSITES srch');
            l('WHERE');
            generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'PARTY_SITES');
            IF l_party_filter_str IS NOT NULL THEN
              l('        AND EXISTS (');
              l('          SELECT  /*+ INDEX(p HZ_STAGED_PARTIES_U1) */  1 FROM HZ_STAGED_PARTIES p');
              l('          WHERE p.PARTY_ID = stage.PARTY_ID');
              l('          AND ('||l_party_filter_str||'))');
            END IF;
            l('          AND stage.party_id = p_party_id;');
            /**** If restrict_sql is NULL or if p_search_ctx_id is not null, execute static queries **/
            l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');

            -- VJN new hints introduced for performance
            IF l_party_filter_str IS NOT NULL THEN
                   /**** When p_search_ctx_id IS NULL, retreive using B-tree index ***/
                  l('      IF p_search_ctx_id IS NULL THEN');
                  l('        OPEN x_cursor FOR ');
                  l('          SELECT /*+ ORDERED USE_NL(srch stage p) */  stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID'||
                                                          replace(l_ps_select_list,'T','stage.T'));
                  l('          FROM  HZ_SRCH_PSITES srch, HZ_STAGED_PARTY_SITES stage, HZ_STAGED_PARTIES p');
                  l('WHERE');
                  generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'PARTY_SITES');
                  l('    AND  p.PARTY_ID = stage.PARTY_ID');
                  l('    AND ('||l_party_filter_str||')');
            ELSE
                   /**** When p_search_ctx_id IS NULL, retreive using B-tree index ***/
                  l('      IF p_search_ctx_id IS NULL THEN');
                  l('        OPEN x_cursor FOR ');
                  l('          SELECT /*+ USE_NL(srch stage)  */  stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID'||
                                                          replace(l_ps_select_list,'T','stage.T'));
                  l('          FROM  HZ_SRCH_PSITES srch, HZ_STAGED_PARTY_SITES stage');
                  l('WHERE');
                  generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'PARTY_SITES');
            END IF;


            l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');

            /***** Search_ctx_id is not null. Retreive using HZ_DQM_PARTIES_GT ****/
            l('      ELSE');
            l('          OPEN x_cursor FOR ');
            l('            SELECT  stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID'
                               || replace(l_ps_select_list,'T','stage.T'));
            l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_PARTY_SITES stage, HZ_SRCH_PSITES srch');
            l('WHERE');
            generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'PARTY_SITES');
            l('            AND d.search_context_id = p_search_ctx_id');
            l('            AND d.party_id = stage.party_id');
            l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');
            l('      END IF;');

             -- VJN new hints introduced for performance
            IF l_dyn_party_filter_str IS NOT NULL THEN
                   /**** Restrict_sql is not null  ****/
                  l('    ELSE');
                  l('       l_sqlstr := ''SELECT /*+ ORDERED USE_NL(srch stage p) */ stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID ' ||
                                    replace(l_ps_select_list,'T','stage.T')||'''||');
                  l('                   '' FROM HZ_SRCH_PSITES srch, HZ_STAGED_PARTY_SITES stage, HZ_STAGED_PARTIES p''||');
                  l('                   '' WHERE'' ||');
                  generate_bulk_predicate(p_rule_id, 'Y', l_match_str, 'PARTY_SITES');
                  l('                 '' AND p.party_id = stage.party_id '' || ');
                  l('                 '' AND ('||l_dyn_party_filter_str||')) '' || ');
            ELSE
                   /**** Restrict_sql is not null  ****/
                  l('    ELSE');
                  l('       l_sqlstr := ''SELECT /*+ USE_NL(srch stage)  */ stage.PARTY_SITE_ID, stage.PARTY_ID, stage.ORG_CONTACT_ID ' ||
                                    replace(l_ps_select_list,'T','stage.T')||'''||');
                  l('                   '' FROM HZ_SRCH_PSITES srch, HZ_STAGED_PARTY_SITES stage''||');
                  l('                   '' WHERE'' ||');
                  generate_bulk_predicate(p_rule_id, 'Y', l_match_str, 'PARTY_SITES');
            END IF;
            l('                   '' AND (''||p_restrict_sql||'')'' ||');
            l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
            l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
            FOR I in 1..l_party_filt_bind.COUNT LOOP
              l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
            END LOOP;
            l('                    ,p_dup_party_id, p_dup_party_id;');
            l('    END IF;');
            l('  exception');
            l('    when others then');
            l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
            l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
            l('        FND_MSG_PUB.ADD;');
            l('        RAISE FND_API.G_EXC_ERROR;');
            l('      else ');
            l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
            l('      end if;');
     ELSE
          l('NULL ;');
     END IF;
          l('  END;');

  l('');
  l('  PROCEDURE open_contact_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  BEGIN');
  IF has_acquisition_attribs (p_rule_id, 'CONTACTS')
  THEN
                  /**** For a single party_id scenario. Retrieve using party_id, filter using intermedia ****/
          l('     IF p_party_id IS NOT NULL THEN');
          l('       OPEN x_cursor FOR ');
          l('          SELECT /*+ INDEX(stage HZ_STAGED_CONTACTS_N1) */ stage.ORG_CONTACT_ID, stage.PARTY_ID'||
                                                       replace(l_c_select_list,'T' , 'stage.T') );
          l('          FROM HZ_STAGED_CONTACTS stage, HZ_SRCH_CONTACTS srch');
          l('          WHERE');
          generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'CONTACTS');
          IF l_party_filter_str IS NOT NULL THEN
            l('        AND EXISTS (');
            l('          SELECT /*+ INDEX(p HZ_STAGED_PARTIES_U1) */  1 FROM HZ_STAGED_PARTIES p');
            l('          WHERE p.PARTY_ID = stage.PARTY_ID');
            l('          AND ('||l_party_filter_str||'))');
          END IF;
          l('          AND stage.party_id = p_party_id;');
          /**** If restrict_sql is NULL or if p_search_ctx_id is not null, execute static queries **/
          l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');

          /**** When p_search_ctx_id IS NULL, retreive using intermedia index ***/
          l('      IF p_search_ctx_id IS NULL THEN');
          l('        OPEN x_cursor FOR ');
          l('          SELECT /*+ USE_NL(srch stage)  */ stage.ORG_CONTACT_ID, stage.PARTY_ID'|| replace(l_c_select_list,'T','stage.T') );
          l('          FROM  HZ_SRCH_CONTACTS srch, HZ_STAGED_CONTACTS stage');
          l('          WHERE');
          generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'CONTACTS');
          IF l_party_filter_str IS NOT NULL THEN
            l('        AND EXISTS (');
            l('          SELECT /*+ INDEX(p HZ_STAGED_PARTIES_U1) */ 1 FROM HZ_STAGED_PARTIES p');
            l('          WHERE p.PARTY_ID = stage.PARTY_ID');
            l('          AND ('||l_party_filter_str||'))');
          END IF;
          l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');

          /***** Search_ctx_id is not null. Reteive using HZ_DQM_PARTIES_GT ****/
          l('      ELSE');
          l('          OPEN x_cursor FOR ');
          l('            SELECT /*+ ORDERED INDEX(stage HZ_STAGED_CONTACTS_N1) */ stage.ORG_CONTACT_ID, stage.PARTY_ID'
                                      || replace(l_c_select_list,'T' , 'stage.T') );
          l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACTS stage, HZ_SRCH_CONTACTS srch');
          l('            WHERE');
          generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'CONTACTS');
          l('            AND d.search_context_id = p_search_ctx_id');
          l('            AND d.party_id = stage.party_id');
        /*
          IF l_party_filter_str IS NOT NULL THEN
            l('          AND EXISTS (');
            l('            SELECT 1 FROM HZ_STAGED_PARTIES p');
            l('            WHERE p.PARTY_ID = stage.PARTY_ID');
            l('            AND ('||l_party_filter_str||'))');
          END IF;
        */
          l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');
          l('      END IF;');

          /**** Restrict_sql is not null. Retrieve using intermedia ****/
          l('    ELSE');
          l('       l_sqlstr := ''SELECT /*+ USE_NL(srch stage)  */  stage.ORG_CONTACT_ID, stage.PARTY_ID '||
                                                 replace(l_c_select_list,'T','stage.T')||'''||');
          l('                   '' FROM HZ_SRCH_CONTACTS srch, HZ_STAGED_CONTACTS stage''||');
          l('                   '' WHERE ''||');
          generate_bulk_predicate(p_rule_id, 'Y', l_match_str, 'CONTACTS');
          IF l_dyn_party_filter_str IS NOT NULL THEN
            l('                 '' AND EXISTS (''||');
            l('                 '' SELECT /*+ INDEX(p HZ_STAGED_PARTIES_U1) */ 1 FROM HZ_STAGED_PARTIES p '' || ');
            l('                 '' WHERE p.party_id = stage.party_id '' || ');
            l('                 '' AND ('||l_dyn_party_filter_str||')) '' || ');
          END IF;
          l('                   '' AND (''||p_restrict_sql||'')'' ||');
          l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
          l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
          FOR I in 1..l_party_filt_bind.COUNT LOOP
            l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
          END LOOP;
          l('                    ,p_dup_party_id, p_dup_party_id;');
          l('    END IF;');
          l('  exception');
          l('    when others then');
          l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
          l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
          l('        FND_MSG_PUB.ADD;');
          l('        RAISE FND_API.G_EXC_ERROR;');
          l('      else ');
          l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
          l('      end if;');
   ELSE
         l('NULL ;');
   END IF;
          l('  END;');
  l('');


  l('  PROCEDURE open_contact_pt_cursor(');
  l('            p_dup_party_id NUMBER, ');
  l('            p_party_id NUMBER, ');
  l('            p_restrict_sql VARCHAR2, ');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  l_sqlstr VARCHAR2(4000);');
  l('  BEGIN');

  IF has_acquisition_attribs (p_rule_id, 'CONTACT_POINTS')
  THEN

            /**** For a single party_id scenario. Retrieve using party_id, filter using intermedia ****/
            l('     IF p_party_id IS NOT NULL THEN');
            l('       OPEN x_cursor FOR ');
            l('          SELECT /*+ INDEX(stage HZ_STAGED_CONTACT_POINTS_N1) */ stage.CONTACT_POINT_ID, stage.PARTY_ID,'
                                  ||   'stage.PARTY_SITE_ID, stage.ORG_CONTACT_ID '
                                  || replace(l_cpt_select_list,'T','stage.T') );
            l('          FROM HZ_STAGED_CONTACT_POINTS stage, HZ_SRCH_CPTS srch');
            l('            WHERE');
            generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'CONTACT_POINTS');
            IF l_party_filter_str IS NOT NULL THEN

              l('        AND EXISTS (');
              l('          SELECT /*+ INDEX(p HZ_STAGED_PARTIES_U1) */ 1 FROM HZ_STAGED_PARTIES p');
              l('          WHERE p.PARTY_ID = stage.PARTY_ID');
              l('          AND ('||l_party_filter_str||'))');
            END IF;
            l('          AND stage.party_id = p_party_id;');
            /**** If restrict_sql is NULL or if p_search_ctx_id is not null, execute static queries **/
            l('    ELSIF p_restrict_sql IS NULL OR p_search_ctx_id IS NOT NULL THEN');

            /**** When p_search_ctx_id IS NULL, retreive using intermedia index ***/
            l('      IF p_search_ctx_id IS NULL THEN');
            l('        OPEN x_cursor FOR ');
            l('          SELECT /*+ USE_NL(srch stage)  */  stage.CONTACT_POINT_ID, stage.PARTY_ID, stage.PARTY_SITE_ID, stage.ORG_CONTACT_ID '
                                          || replace(l_cpt_select_list,'T','stage.T') );
            l('          FROM  HZ_SRCH_CPTS srch, HZ_STAGED_CONTACT_POINTS stage');
            l('            WHERE');
            generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'CONTACT_POINTS');
            IF l_party_filter_str IS NOT NULL THEN
              l('        AND EXISTS (');
              l('          SELECT  /*+ INDEX(p HZ_STAGED_PARTIES_U1) */ 1 FROM HZ_STAGED_PARTIES p');
              l('          WHERE p.PARTY_ID = stage.PARTY_ID');
              l('          AND ('||l_party_filter_str||'))');
            END IF;
            l('          AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');

            /***** Search_ctx_id is not null. Reteive using HZ_DQM_PARTIES_GT ****/
            l('      ELSE');
            l('          OPEN x_cursor FOR ');
            l('            SELECT /*+ ORDERED INDEX(stage HZ_STAGED_CONTACT_POINTS_N1) */ stage.CONTACT_POINT_ID, stage.PARTY_ID, stage.PARTY_SITE_ID, stage.ORG_CONTACT_ID '
                                          || replace(l_cpt_select_list,'T','stage.T') );
            l('            FROM HZ_DQM_PARTIES_GT d, HZ_STAGED_CONTACT_POINTS stage, HZ_SRCH_CPTS srch');
            l('            WHERE');
            generate_bulk_predicate(p_rule_id, 'N', l_match_str, 'CONTACT_POINTS');
            l('            AND d.search_context_id = p_search_ctx_id');
            l('            AND d.party_id = stage.party_id');
          /*
            IF l_party_filter_str IS NOT NULL THEN
              l('          AND EXISTS (');
              l('            SELECT 1 FROM HZ_STAGED_PARTIES p');
              l('            WHERE p.PARTY_ID = stage.PARTY_ID');
              l('            AND ('||l_party_filter_str||'))');
            END IF;
          */
            l('            AND (p_dup_party_id IS NULL OR stage.party_id <> p_dup_party_id);');
            l('      END IF;');

            /**** Restrict_sql is not null. Retrieve using intermedia ****/
            l('    ELSE');
            l('       l_sqlstr := ''SELECT /*+ USE_NL(srch stage)  */ stage.CONTACT_POINT_ID, stage.PARTY_ID, stage.PARTY_SITE_ID, stage.ORG_CONTACT_ID  '
                                                         || replace(l_cpt_select_list,'T','stage.T')||'''||');
            l('                   '' FROM HZ_SRCH_CPTS srch, HZ_STAGED_CONTACT_POINTS stage''||');
            l('                   '' WHERE''||');
            generate_bulk_predicate(p_rule_id, 'Y', l_match_str, 'CONTACT_POINTS');
            IF l_dyn_party_filter_str IS NOT NULL THEN
              l('                 '' AND EXISTS (''||');
              l('                 '' SELECT  /*+ INDEX(p HZ_STAGED_PARTIES_U1) */ 1 FROM HZ_STAGED_PARTIES p '' || ');
              l('                 '' WHERE p.party_id = stage.party_id '' || ');
              l('                 '' AND ('||l_dyn_party_filter_str||')) '' || ');
            END IF;
            l('                   '' AND (''||p_restrict_sql||'')'' ||');
            l('                   '' AND (:p_dup IS NULL OR stage.party_id <> :p_dup) ''; ');
            l('       OPEN x_cursor FOR l_sqlstr USING p_contains_str');
            FOR I in 1..l_party_filt_bind.COUNT LOOP
              l('                              ,'||l_party_filt_bind(I)||','||l_party_filt_bind(I));
            END LOOP;
            l('                    ,p_dup_party_id, p_dup_party_id;');
            l('    END IF;');
            l('  exception');
            l('    when others then');
            l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
            l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
            l('        FND_MSG_PUB.ADD;');
            l('        RAISE FND_API.G_EXC_ERROR;');
            l('      else ');
            l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
            l('      end if;');
     ELSE
          l('NULL ;');
     END IF;
          l('  END;');

  l('');
  l('  FUNCTION get_new_score_rec (');
  l('    	 p_init_total_score NUMBER,');
  l('    	 p_init_party_score NUMBER,');
  l('    	 p_init_party_site_score NUMBER,');
  l('    	 p_init_contact_score NUMBER,');
  l('    	 p_init_contact_point_score NUMBER, ');
  l('    	 p_party_id NUMBER, ');
  l('    	 p_party_site_id NUMBER, ');
  l('    	 p_org_contact_id NUMBER, ');
  l('    	 p_contact_point_id NUMBER) ');
  l('     RETURN HZ_PARTY_SEARCH.score_rec IS');
  l('    l_score_rec HZ_PARTY_SEARCH.score_rec;');
  l('  BEGIN');
  l('    l_score_rec.TOTAL_SCORE := p_init_total_score;');
  l('    l_score_rec.PARTY_SCORE := p_init_party_score;');
  l('    l_score_rec.PARTY_SITE_SCORE := p_init_party_site_score;');
  l('    l_score_rec.CONTACT_SCORE := p_init_contact_score;');
  l('    l_score_rec.CONTACT_POINT_SCORE := p_init_contact_point_score;');
  l('    l_score_rec.PARTY_ID := p_party_id;');
  l('    l_score_rec.PARTY_SITE_ID := p_party_site_id;');
  l('    l_score_rec.ORG_CONTACT_ID := p_org_contact_id;');
  l('    l_score_rec.CONTACT_POINT_ID := p_contact_point_id;');
  l('    RETURN l_score_rec;');
  l('  END;');

  l('');
  l('   /**********************************************************');
  l('   This procedure finds the set of parties that match the search');
  l('   criteria and returns a scored set of parties');
  l('');
  l('   The steps in executing the search are as follows');
  l('    1. Initialization and error checks');
  l('    2. Setup of intermedia query strings for Acquisition query');
  l('    3. Execution of Acquisition query');
  l('    4. Execution of Secondary queries to score results');
  l('    5. Setup of data temporary table to return search results');
  l('   **********************************************************/');
  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_parties ------------------------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_parties (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_dup_party_id          IN      NUMBER,');
  l('      p_dup_set_id            IN      NUMBER,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_denorm_str VARCHAR2(32000);');
  l('  l_ps_denorm_str VARCHAR2(32000);');
  l('  l_ct_denorm_str VARCHAR2(32000);');
  l('  l_cpt_denorm_str VARCHAR2(32000);');

  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_match_idx NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('  H_PARTY_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_PARTY_ID_LIST HZ_PARTY_SEARCH.IDList;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_ps_contact_id NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('  l_denorm_max_score NUMBER;');
  l('  l_non_denorm_max_score NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_max_thresh NUMBER;');
  l('  l_tmp NUMBER;');
  l('  l_merge_flag VARCHAR2(1);');
  l('  l_num_eval NUMBER:=0;');
  l('');
  l('  --Fix for bug 4417124 ');
  l('  l_use_contact_addr_info BOOLEAN := TRUE;');
  l('  l_use_contact_cpt_info BOOLEAN  := TRUE;');
  l('  l_use_contact_addr_flag VARCHAR2(1) := ''Y'';');
  l('  l_use_contact_cpt_flag  VARCHAR2(1) := ''Y'';');
  l('');
  l('    h_ps_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_score HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_score HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('');
  l('  ');
  l('  /********************* Find Parties private procedures *******/');

  l('  PROCEDURE push_eval IS');
  l('  BEGIN');
  l('    H_PARTY_ID.DELETE;');
  l('    H_PARTY_ID_LIST.DELETE;');
  l('    H_SCORES.DELETE;        ');
  l('    g_mappings.DELETE;');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(0);');
  l('    call_order(5) := call_order(1);');
  l('    call_type(5) := ''AND'';');
  l('    call_max_score(5) := call_max_score(1);');
  l('    call_type(2) := ''OR'';');
  l('  END;');

  l('');
  l('  /**  Private procedure to acquire and score at party level  ***/');
  l('  PROCEDURE eval_party_level(p_party_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  l('    open_party_cursor(p_dup_party_id, p_restrict_sql, p_party_contains_str,l_ctx_id, l_match_str,p_search_merged,l_party_cur);');
  l('    LOOP ');
  l('      FETCH l_party_cur INTO');
  l('         l_party_id '||l_p_into_list||';');
  l('      EXIT WHEN l_party_cur%NOTFOUND;');
  l('      l_index := map_id(l_party_id);');
  l('      l_score := GET_PARTY_SCORE('||l_p_param_list||');');

  l('      IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('        H_SCORES(l_index) := get_new_score_rec(l_score,l_score,defps,defct,defcpt, l_party_id, null, null,null);');
  l('      ELSE');
  l('        H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE+l_score;');
  l('        H_SCORES(l_index).PARTY_SCORE := l_score;');
  l('      END IF;');
  l('      IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('        H_PARTY_ID_LIST(l_index) := 1;');
  l('        H_PARTY_ID(l_party_id_idx) := l_party_id;');
  l('        l_party_id_idx:= l_party_id_idx+1;');
  l('      END IF;');
  l('      IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_party_cur;'); --Bug No: 3872745
  l('        IF p_index>1 THEN');
  ldbg_s('In eval party level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Level Matches');
  dc(fnd_log.level_statement,'l_party_id','l_party_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('    END LOOP;');
  l('    CLOSE l_party_cur;');
  l('    ROLLBACK to eval_start;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_party_site_level(p_party_site_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  --l('    h_ps_id HZ_PARTY_SEARCH.IDList;');
  --l('    h_ps_party_id HZ_PARTY_SEARCH.IDList;');
  --l('    h_ps_score HZ_PARTY_SEARCH.IDList;');
  --l('    detcnt NUMBER := 1;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('      l_ctx_id := NULL;');
  l('    END IF;');
  l('    open_party_site_cursor(p_dup_party_id,NULL, p_restrict_sql, p_party_site_contains_str,l_ctx_id, l_party_site_cur);');
  l('    LOOP ');
  l('      FETCH l_party_site_cur INTO');
  l('         l_party_site_id, l_ps_party_id, l_ps_contact_id '||l_ps_into_list||';');
  l('      EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('      IF l_use_contact_addr_info OR l_ps_contact_id IS NOT NULL THEN');
  l('        l_index := map_id(l_ps_party_id);');
  l('        l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          H_SCORES(l_index) := get_new_score_rec(l_score,defpt,l_score,defct,defcpt, l_ps_party_id, l_party_site_id, null,null);');
  l('        ELSE');
  l('          IF l_score > H_SCORES(l_index).PARTY_SITE_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).PARTY_SITE_SCORE+l_score;');
  l('            H_SCORES(l_index).PARTY_SITE_SCORE := l_score;');
  l('          END IF;');
  l('        END IF;');
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_ps_party_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  l('        END IF;');
  l('        IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_party_site_cur;'); --Bug No: 3872745
  l('          IF p_index>1 THEN');
  ldbg_s('In eval party site level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
  l('          h_ps_id(detcnt) := l_party_site_id;');
  l('          h_ps_party_id(detcnt) := l_ps_party_id;');
  l('          h_ps_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('          detcnt := detcnt +1;');
  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Site Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_party_site_id');
  dc(fnd_log.level_statement,'l_ps_party_id','l_ps_party_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE l_party_site_cur;');
  l('    ROLLBACK to eval_start;');
  -- l('    IF p_ins_details = ''Y'' THEN');
  -- l('      FORALL I in 1..h_ps_id.COUNT ');
  -- l('        INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID,PARTY_SITE_ID,PARTY_ID,SCORE) VALUES (');
  -- l('          l_search_ctx_id, h_ps_id(I), h_ps_party_id(I), h_ps_score(I));');
  -- l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_contact_level(p_contact_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
 -- l('    h_ct_id HZ_PARTY_SEARCH.IDList;');
 -- l('    h_ct_party_id HZ_PARTY_SEARCH.IDList;');
 -- l('    h_ct_score HZ_PARTY_SEARCH.IDList;');
 -- l('    detcnt NUMBER := 1;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type=''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  l('    open_contact_cursor(p_dup_party_id,NULL, p_restrict_sql, p_contact_contains_str,l_ctx_id, l_contact_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_cur INTO');
  l('         l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('      EXIT WHEN l_contact_cur%NOTFOUND;');
  l('      l_index := map_id(l_ct_party_id);');
  l('      l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');

  l('      IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('        H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,l_score,defcpt, l_ct_party_id, null, l_org_contact_id,null);');
  l('      ELSE');
  l('        IF l_score > H_SCORES(l_index).CONTACT_SCORE THEN');
  l('          H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_SCORE+l_score;');
  l('          H_SCORES(l_index).CONTACT_SCORE := l_score;');
  l('        END IF;');
  l('      END IF;');
  l('      IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('        H_PARTY_ID_LIST(l_index) := 1;');
  l('        H_PARTY_ID(l_party_id_idx) := l_ct_party_id;');
  l('        l_party_id_idx:= l_party_id_idx+1;');
  l('      END IF;');
  l('      IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_contact_cur;'); --Bug No: 3872745
  l('        IF p_index>1 THEN');
  ldbg_s('In eval contact level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');
  l('      IF p_ins_details = ''Y'' THEN');
  l('        h_ct_id(detcnt) := l_org_contact_id;');
  l('        h_ct_party_id(detcnt) := l_ct_party_id;');
  l('        h_ct_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('        detcnt := detcnt +1;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_org_contact_id');
  dc(fnd_log.level_statement,'l_ct_party_id','l_ct_party_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('    END LOOP;');
  l('    CLOSE l_contact_cur;');
  l('    ROLLBACK to eval_start;');
  -- l('    IF p_ins_details = ''Y'' THEN');
  -- l('      FORALL I in 1..h_ct_id.COUNT ');
  -- l('        INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID,ORG_CONTACT_ID,PARTY_ID,SCORE) VALUES (');
  -- l('          l_search_ctx_id, h_ct_id(I), h_ct_party_id(I), h_ct_score(I));');
  -- l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at contact point level  ***/');
  l('  PROCEDURE eval_cpt_level(p_contact_pt_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER, p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  -- l('    h_cpt_id HZ_PARTY_SEARCH.IDList;');
  -- l('    h_cpt_party_id HZ_PARTY_SEARCH.IDList;');
  -- l('    h_cpt_score HZ_PARTY_SEARCH.IDList;');
  -- l('    detcnt NUMBER := 1;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  l('    open_contact_pt_cursor(p_dup_party_id,NULL, p_restrict_sql, p_contact_pt_contains_str,l_ctx_id, l_contact_pt_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_pt_cur INTO');
  l('         l_contact_pt_id, l_cpt_party_id,  l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('      EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('      IF l_use_contact_cpt_info OR l_ps_contact_id IS NOT NULL THEN');
  l('        l_index := map_id(l_cpt_party_id);');
  l('        l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id,l_contact_pt_id);');
  l('        ELSE');
  l('          IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('            H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('          END IF;');
  l('        END IF;');
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) THEN');
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_cpt_party_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  l('        END IF;');
  l('        IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_contact_pt_cur;'); --Bug No: 3872745
  l('          IF p_index>1 THEN');
  ldbg_s('In eval contact point level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
  l('          h_cpt_id(detcnt) := l_contact_pt_id;');
  l('          h_cpt_party_id(detcnt) := l_cpt_party_id;');
  l('          h_cpt_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('          detcnt := detcnt +1;');
  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact pt Level Matches');
  dc(fnd_log.level_statement,'l_contact_pt_id','l_contact_pt_id');
  dc(fnd_log.level_statement,'l_cpt_party_id','l_cpt_party_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE l_contact_pt_cur;');
  l('    ROLLBACK to eval_start;');
  -- l('    IF p_ins_details = ''Y'' THEN');
  -- l('      FORALL I in 1..h_cpt_id.COUNT ');
  -- l('        INSERT INTO HZ_MATCHED_CPTS_GT (SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  -- l('          l_search_ctx_id, h_cpt_id(I), h_cpt_party_id(I), h_cpt_score(I));');
  -- l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to call the eval procedure at each entity in the correct order ***/');
  l('  PROCEDURE do_eval (p_index NUMBER) IS');
  l('    l_ctx_id NUMBER;');
  l('    l_threshold NUMBER;'); --Bug No: 4407425
  l('    other_criteria_exists BOOLEAN; '); --Bug No: 4407425
  l('  BEGIN');
  --Start of Bug No: 4407425
  l('    IF (p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0) THEN');
  l('     l_threshold := '|| l_match_threshold ||';  ');
  l('     other_criteria_exists := TRUE ;');
  l('     IF (call_max_score(2) = 0 and call_max_score(3) = 0 and call_max_score(4) = 0 ) THEN ');
  l('      other_criteria_exists := FALSE; ');
  l('     END IF ; ');
  l('    IF( (l_match_str = '' AND '' AND other_criteria_exists) OR ( call_max_score(p_index) < l_threshold) )THEN');
  l('	     RETURN;	');
  l('	  ELSE');
  ldbg_s('In do eval number of matches found exceeded threshold');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('     END IF; ');
  l('    END IF;');
  --End of Bug No: 4407425
  /*l('    IF p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0 THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  */
  l('    IF call_order(p_index) = ''PARTY'' AND l_party_contains_str IS NOT NULL THEN');
  l('      eval_party_level(l_party_contains_str,call_type(p_index), p_index);');
  l('    ELSIF call_order(p_index) = ''PARTY_SITE'' AND l_party_site_contains_str IS NOT NULL THEN');
  l('      eval_party_site_level(l_party_site_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    ELSIF call_order(p_index) = ''CONTACT'' AND l_contact_contains_str IS NOT NULL THEN');
  l('      eval_contact_level(l_contact_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    ELSIF call_order(p_index) = ''CONTACT_POINT'' AND l_contact_pt_contains_str IS NOT NULL THEN');
  l('      eval_cpt_level(l_contact_pt_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    END IF;');
  l('  END;');
  l('  /************ End of find_parties private procedures **********/ ');
  l('');
  l('  BEGIN');
  l('');


  d(fnd_log.level_procedure,'find_parties(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_set_id','p_dup_set_id');
  dc(fnd_log.level_statement,'p_search_merged','p_search_merged');
  dc(fnd_log.level_statement,'p_dup_party_id','p_dup_party_id');
  de;

  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');

  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    SAVEPOINT find_parties;');
  l('    l_entered_max_score:= init_search(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list, l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');
  IF l_purpose = 'D' THEN
  l('');
    l('    IF l_entered_max_score < '||l_match_threshold||' THEN');
    l('      x_num_matches:=0;');
    l('      x_search_ctx_id:=0;');
    l('      RETURN;');
    l('    END IF;');
  l('');
  END IF;
  l('');
  l('    --Fix for bug 4417124 ');
  l('');
  l('    SELECT use_contact_addr_flag, use_contact_cpt_flag ');
  l('    INTO l_use_contact_addr_flag, l_use_contact_cpt_flag ');
  l('    FROM hz_match_rules_b ');
  l('    WHERE match_rule_id = '||p_rule_id||'; ');
  l('');
  l('    IF p_dup_batch_id IS NOT NULL AND NVL(l_use_contact_addr_flag, ''Y'') = ''N'' THEN');
  l('      l_use_contact_addr_info := FALSE; ');
  l('    END IF; ');
  l('');
  l('    IF p_dup_batch_id IS NOT NULL AND NVL(l_use_contact_cpt_flag, ''Y'') = ''N'' THEN');
  l('      l_use_contact_cpt_info := FALSE; ');
  l('    END IF; ');
  l('');
  l('   --End fix for bug 4417124');
  l('');
  l('    l_max_thresh:=nvl(FND_PROFILE.VALUE(''HZ_DQM_MAX_EVAL_THRESH''),200);');
  l('    IF nvl(FND_PROFILE.VALUE(''HZ_DQM_SCORE_UNTIL_THRESH''),''N'')=''Y'' THEN');
  l('      g_score_until_thresh := true;');
  l('    ELSE');
  l('      g_score_until_thresh := false;');
  l('    END IF;');

  l('    l_party_site_contains_str := check_party_sites_bulk (p_party_site_list);');
  l('    l_contact_contains_str := check_contacts_bulk (p_contact_list);');
  l('    l_contact_pt_contains_str := check_cpts_bulk (p_contact_point_list);');
  /*
  l('    l_denorm_max_score:=0;');
  l('    l_non_denorm_max_score:=0;');
  l('    IF l_ps_denorm_str IS NOT NULL THEN');
  l('      l_denorm_max_score := l_denorm_max_score+l_ps_max_score;');
  l('      l_denorm_str := l_ps_denorm_str;');
  l('    ELSE');
  l('      l_non_denorm_max_score := l_non_denorm_max_score+l_ps_max_score;');
  l('    END IF;');

  l('    IF l_ct_denorm_str IS NOT NULL THEN');
  l('      l_denorm_max_score := l_denorm_max_score+l_contact_max_score;');
  l('      IF l_denorm_str IS NOT NULL THEN');
  l('        l_denorm_str := l_denorm_str || '' OR '' ||l_ct_denorm_str;');
  l('      ELSE');
  l('        l_denorm_str := l_ct_denorm_str;');
  l('      END IF;');
  l('    ELSE');
  l('      l_non_denorm_max_score := l_non_denorm_max_score+l_contact_max_score;');
  l('    END IF;');

  l('    IF l_cpt_denorm_str IS NOT NULL THEN');
  l('      l_denorm_max_score := l_denorm_max_score+l_cpt_max_score;');
  l('      IF l_denorm_str IS NOT NULL THEN');
  l('        l_denorm_str := l_denorm_str || '' OR '' ||l_cpt_denorm_str;');
  l('      ELSE');
  l('        l_denorm_str := l_cpt_denorm_str;');
  l('      END IF;');
  l('    ELSE');
  l('      l_non_denorm_max_score := l_non_denorm_max_score+l_cpt_max_score;');
  l('    END IF;');
  */
  l('    l_party_contains_str := check_parties_bulk (p_party_search_rec) ;');
  l('    init_score_context(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  l('    IF l_party_contains_str IS NULL THEN');
  l('      defpt := 1;');
  l('    END IF;');
  l('    IF l_party_site_contains_str IS NULL THEN');
  l('      defps := 1;');
  l('    END IF;');
  l('    IF l_contact_contains_str IS NULL THEN');
  l('      defct := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_party_contains_str','l_party_contains_str');
  dc(fnd_log.level_statement,'l_party_site_contains_str','l_party_site_contains_str');
  dc(fnd_log.level_statement,'l_contact_contains_str','l_contact_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  IF l_max_score=1 THEN
    l('    FOR I in 1..3 LOOP');
    l('      IF (call_order(I) = ''PARTY'' AND l_party_contains_str IS NULL)');
    l('         OR (call_order(I) = ''PARTY_SITE'' AND l_party_site_contains_str IS NULL)');
    l('         OR (call_order(I) = ''CONTACT'' AND l_contact_contains_str IS NULL)');
    l('         OR (call_order(I) = ''CONTACT_POINT'' AND l_contact_pt_contains_str IS NULL) THEN');
    l('        IF call_type(I)=''OR'' THEN');
    l('          call_type(I+1):=''OR'';');
    l('        END IF;');
    l('      END IF;');
    l('    END LOOP;');
  END IF;

  /**** Call all 4 evaluation procedures ***********/
  l('    FOR I in 1..5 LOOP');
  l('      do_eval(I);');
  l('    END LOOP;');
  l('ROLLBACK to find_parties;');
  IF l_purpose = 'S' THEN
    d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  ELSE
    d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||l_match_threshold);
  END IF;

  l('    x_num_matches := 0;');
  l('    l_num_eval := 0;');
  l('    IF l_match_str = '' OR '' THEN');
  l('      l_party_id := H_SCORES.FIRST;');
  l('    ELSE');
  l('      l_party_id := H_PARTY_ID_LIST.FIRST;');
  l('    END IF;');

  l('    WHILE l_party_id IS NOT NULL LOOP');
  l('      l_num_eval:= l_num_eval+1;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Party ID','H_SCORES(l_party_id).PARTY_ID');
  IF l_purpose = 'S' THEN
    dc(fnd_log.level_statement,'Score','round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100)');
  ELSE
    dc(fnd_log.level_statement,'Score','H_SCORES(l_party_id).TOTAL_SCORE');
  END IF;
  de;
  IF l_purpose  = ('S') THEN
    l('      IF (H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100));');
    l('            x_num_matches := x_num_matches+1;');

    ELSIF l_purpose  = ('W') THEN


    l('      IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_match_threshold||' THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/'||l_max_score||')*100));');
    l('            x_num_matches := x_num_matches+1;');


  ELSE
    l('      IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_match_threshold||' THEN');
    l('          IF p_dup_set_id IS NULL THEN');
    l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,H_SCORES(l_party_id).TOTAL_SCORE);');
    l('             x_num_matches := x_num_matches+1;');
    l('          ELSE');
    l('            BEGIN');
    l('              SELECT 1 INTO l_tmp FROM HZ_DUP_SET_PARTIES'); --Bug No: 4244529
    l('              WHERE DUP_PARTY_ID = H_SCORES(l_party_id).PARTY_ID');
    l('              AND DUP_SET_BATCH_ID = p_dup_batch_id '); --Bug No: 4244529
    l('              AND ROWNUM=1;');
    l('            EXCEPTION ');
    l('              WHEN NO_DATA_FOUND THEN');
    l('                IF H_SCORES(l_party_id).TOTAL_SCORE>='||l_auto_merge_score||' THEN');
    l('                  l_merge_flag := ''Y'';');
    l('                ELSE');
    l('                  l_merge_flag := ''N'';');
    l('                END IF;');
    l('                INSERT INTO HZ_DUP_SET_PARTIES (DUP_PARTY_ID,DUP_SET_ID,MERGE_SEQ_ID,');
    l('                    MERGE_BATCH_ID,SCORE,MERGE_FLAG, CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,');
    l('                    LAST_UPDATE_DATE,LAST_UPDATED_BY,DUP_SET_BATCH_ID) '); --Bug No: 4244529
    l('                VALUES (H_SCORES(l_party_id).PARTY_ID,p_dup_set_id,0,0,');
    l('                    H_SCORES(l_party_id).TOTAL_SCORE, l_merge_flag,');
    l('                    hz_utility_pub.created_by,hz_utility_pub.creation_date,');
    l('                    hz_utility_pub.last_update_login,');
    l('                    hz_utility_pub.last_update_date,');
    l('                    hz_utility_pub.user_id,p_dup_batch_id);'); --Bug No: 4244529
    l('                x_num_matches := x_num_matches+1;');
    l('            END;');
    l('          END IF;');
  END IF;
  l('      END IF;');
  l('      IF l_match_str = '' OR '' THEN');
  l('        l_party_id:=H_SCORES.NEXT(l_party_id);');
  l('      ELSE');
  l('        l_party_id:=H_PARTY_ID_LIST.NEXT(l_party_id);');
  l('      END IF;');
  l('    END LOOP;');
  l('');
    l('----------INSERT INTO HZ_MATCHED_PARTY_SITES -----');
    l('    IF p_ins_details = ''Y'' THEN');
    l('      FORALL I in 1..h_ps_id.COUNT ');
    l('        INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID,PARTY_SITE_ID,PARTY_ID,SCORE) VALUES (');
    l('          l_search_ctx_id, h_ps_id(I), h_ps_party_id(I), h_ps_score(I));');
    l('    END IF;');
    l('----------INSERT INTO HZ_MATCHED_CONTACTS-----');
    l('    IF p_ins_details = ''Y'' THEN');
    l('      FORALL I in 1..h_ct_id.COUNT ');
    l('        INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID,ORG_CONTACT_ID,PARTY_ID,SCORE) VALUES (');
    l('          l_search_ctx_id, h_ct_id(I), h_ct_party_id(I), h_ct_score(I));');
    l('    END IF;');
    l('----------INSERT INTO HZ_MATCHED_CPTS-----');
    l('    IF p_ins_details = ''Y'' THEN');
    l('      FORALL I in 1..h_cpt_id.COUNT ');
    l('        INSERT INTO HZ_MATCHED_CPTS_GT (SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
    l('          l_search_ctx_id, h_cpt_id(I), h_cpt_party_id(I), h_cpt_score(I));');
    l('    END IF;');
  l('');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(l_num_eval);');
  d(fnd_log.level_procedure,'find_parties(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    ROLLBACK to find_parties;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    ROLLBACK to find_parties;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    ROLLBACK to find_parties;');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_parties'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_parties;');
  l('');

  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_persons ------------------------------');
  l('-------------------------------------------------------------------------------------');

  l('PROCEDURE find_persons (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
  IF l_purpose <> 'D' THEN
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_denorm_str VARCHAR2(32000);');
  l('  l_ps_denorm_str VARCHAR2(32000);');
  l('  l_ct_denorm_str VARCHAR2(32000);');
  l('  l_cpt_denorm_str VARCHAR2(32000);');

  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_match_idx NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('  H_PARTY_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_PARTY_ID_LIST HZ_PARTY_SEARCH.IDList;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_ps_contact_id NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('  l_denorm_max_score NUMBER;');
  l('  l_non_denorm_max_score NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_max_thresh NUMBER;');
  l('  l_tmp NUMBER;');
  l('  l_merge_flag VARCHAR2(1);');
  l('  l_num_eval NUMBER:=0;');
  l('');
  l('    h_ps_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ps_score HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_ct_score HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_party_id HZ_PARTY_SEARCH.IDList;');
  l('    h_cpt_score HZ_PARTY_SEARCH.IDList;');
  l('    detcnt NUMBER := 1;');
  l('    l_person_id NUMBER;');

  l('  ');
  l('  /********************* Find Parties private procedures *******/');
  FOR TX IN (
    SELECT a.attribute_name,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
            HZ_TRANS_ATTRIBUTES_VL a
        WHERE f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.entity_name = 'PARTY'
        AND a.attribute_name='PARTY_TYPE'
        AND f.PROCEDURE_NAME='HZ_TRANS_PKG.EXACT'
        AND nvl(f.active_flag,'Y')='Y'
        AND ROWNUM=1
  ) LOOP
    l('  PROCEDURE set_person_party_type IS');
    l('  BEGIN');
    l('    g_party_stage_rec.'||TX.STAGED_ATTRIBUTE_COLUMN||':= ');
    l('        HZ_TRANS_PKG.EXACT(');
    l('             ''PERSON''');
    l('             ,null,''PARTY_TYPE''');
    l('             ,''PARTY'');');
    l('  END;');
    l('    ');
    l('  PROCEDURE unset_person_party_type IS');
    l('  BEGIN');
    l('    g_party_stage_rec.'||TX.STAGED_ATTRIBUTE_COLUMN||' := '''';');
    l('  END;');
  END LOOP;
  l('  ');
  l('  FUNCTION get_person_id(p_party_id NUMBER, p_contact_id NUMBER) ');
  l('  RETURN NUMBER IS');
  l('    l_party_type VARCHAR2(255);');
  l('    l_person_id NUMBER(15);');
  l('  BEGIN');
  l('    SELECT party_type INTO l_party_type from hz_parties where party_id = p_party_id;');
  l('    IF l_party_type = ''PERSON'' THEN');
  l('      RETURN p_party_id;');
  l('    ELSIF p_contact_id IS NULL THEN');
  l('      RETURN NULL;');
  l('    ELSE');
  l('      BEGIN ');
  l('        SELECT subject_id INTO l_person_id FROM HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc, hz_parties p');
  l('        WHERE oc.org_contact_id = p_contact_id');
  l('        AND r.relationship_id = oc.party_relationship_id ');
  l('        AND r.object_id = p_party_id');
  l('        AND p.party_id = r.subject_id ');
  l('        AND p.party_type = ''PERSON''');
  l('        AND ROWNUM=1;');
  l('        ');
  l('        RETURN l_person_id;');
  l('      EXCEPTION');
  l('        WHEN NO_DATA_FOUND THEN');
  l('          RETURN NULL;');
  l('      END;      ');
  l('    END IF;');
  l('  END;  ');
  l('');
  l('  PROCEDURE push_eval IS');
  l('  BEGIN');
  l('    H_PARTY_ID.DELETE;');
  l('    H_PARTY_ID_LIST.DELETE;');
  l('    H_SCORES.DELETE;        ');
  l('    g_mappings.DELETE;');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(0);');
  l('    call_order(5) := call_order(1);');
  l('    call_type(5) := ''AND'';');
  l('    call_max_score(5) := call_max_score(1);');
  l('    call_type(2) := ''OR'';');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party level  ***/');
  l('  PROCEDURE eval_party_level(p_party_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    set_person_party_type;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  l('    open_party_cursor(null, p_restrict_sql, p_party_contains_str,l_ctx_id, l_match_str,null,l_party_cur);');
  l('    LOOP ');
  l('      FETCH l_party_cur INTO');
  l('         l_party_id '||l_p_into_list||';');
  l('      EXIT WHEN l_party_cur%NOTFOUND;');
  l('      l_index := map_id(l_party_id);');
  l('      l_score := GET_PARTY_SCORE('||l_p_param_list||');');

  l('      IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('        H_SCORES(l_index) := get_new_score_rec(l_score,l_score,defps,defct,defcpt, l_party_id, null, null,null);');
  l('      ELSE');
  l('        H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE+l_score;');
  l('        H_SCORES(l_index).PARTY_SCORE := l_score;');
  l('      END IF;');
  l('      IF NOT H_PARTY_ID_LIST.EXISTS(l_index) AND H_SCORES.EXISTS(l_index) THEN');
  l('        H_PARTY_ID_LIST(l_index) := 1;');
  l('        H_PARTY_ID(l_party_id_idx) := l_party_id;');
  l('        l_party_id_idx:= l_party_id_idx+1;');
  l('      END IF;');
  l('      IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_party_cur;'); --Bug No: 3872745
  l('        IF p_index>1 THEN');
  ldbg_s('In eval party level number of matches found exceeded threshold');
  l('          FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('          FND_MSG_PUB.ADD;');
  l('          RAISE FND_API.G_EXC_ERROR;');
  l('        ELSE');
  l('          push_eval;');
  l('          RETURN;');
  l('        END IF;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Level Matches');
  dc(fnd_log.level_statement,'l_party_id','l_party_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('    END LOOP;');
  l('    CLOSE l_party_cur;');
  l('    ROLLBACK to eval_start;');
  l('  END;');
  l('  PROCEDURE open_person_contact_cursor(');
  l('            p_contains_str  VARCHAR2, ');
  l('            p_search_ctx_id  NUMBER, ');
  l('            x_cursor OUT HZ_PARTY_STAGE.StageCurTyp) IS');
  l('  BEGIN');
  l('    OPEN x_cursor FOR ');
  l('      SELECT /*+ INDEX(stage HZ_STAGED_CONTACTS_U1) */ ORG_CONTACT_ID, PARTY_ID'|| l_c_select_list);
  l('      FROM HZ_STAGED_CONTACTS stage');
  l('      WHERE contains( concat_col, p_contains_str)>0');
  l('      AND ORG_CONTACT_ID in (');
  l('            SELECT  /*+ ORDERED INDEX(d hz_dqm_parties_gt_n1) USE_NL(d r)*/ ');
  l('            org_contact_id');
  l('            from hz_dqm_parties_gt d, hz_relationships r, hz_org_contacts oc');
  l('            where d.party_id = r.subject_id');
  l('            and oc.party_relationship_id = r.relationship_id');
  l('            and d.search_context_id = p_search_ctx_id);   ');
--bug 4959719 start
  l('  exception');
  l('    when others then');
  l('      if (instrb(SQLERRM,''DRG-51030'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_WILDCARD_ERR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
   --Start Bug No: 3032742.
  l('      elsif (instrb(SQLERRM,''DRG-50943'')>0) then ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_SEARCH_ERROR'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  --End Bug No : 3032742.
  l('      else ');
  l('        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('      end if;');
--bug 4959719 end
  l('  END;');

  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_party_site_level(p_party_site_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
 -- l('    h_ps_id HZ_PARTY_SEARCH.IDList;');
 -- l('    h_ps_party_id HZ_PARTY_SEARCH.IDList;');
 -- l('    h_ps_score HZ_PARTY_SEARCH.IDList;');
 -- l('    detcnt NUMBER := 1;');
  l('    l_person_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    unset_person_party_type;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID)');
  l('      SELECT distinct l_search_ctx_id,r.subject_id from HZ_DQM_PARTIES_GT d, HZ_ORG_CONTACTS oc, ');
  l('                               HZ_RELATIONSHIPS r');
  l('      WHERE oc.party_relationship_id = r.relationship_id');
  l('      AND r.object_id = d.party_id');
  l('      AND d.SEARCH_CONTEXT_ID=l_search_ctx_id;');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID)');
  l('      SELECT distinct l_search_ctx_id,r.subject_id from HZ_DQM_PARTIES_GT d, HZ_ORG_CONTACTS oc, ');
  l('                               HZ_RELATIONSHIPS r');
  l('      WHERE oc.party_relationship_id = r.relationship_id');
  l('      AND r.object_id = d.party_id');
  l('      AND d.SEARCH_CONTEXT_ID=l_search_ctx_id;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('      l_ctx_id := NULL;');
  l('    END IF;');
  l('    open_party_site_cursor(null,NULL, p_restrict_sql, p_party_site_contains_str,l_ctx_id, l_party_site_cur);');
  l('    LOOP ');
  l('      FETCH l_party_site_cur INTO');
  l('         l_party_site_id, l_ps_party_id, l_ps_contact_id '||l_ps_into_list||';');
  l('      EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('      l_person_id := get_person_id(l_ps_party_id, l_ps_contact_id);');
  l('      IF l_person_id IS NOT NULL THEN');
  l('        l_index := map_id(l_person_id);');
  l('        l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          IF l_ctx_id IS NULL THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,l_score,defct,defcpt, l_person_id, l_party_site_id, null,null);');
  l('          END IF;');
  l('        ELSE');
  l('          IF l_score > H_SCORES(l_index).PARTY_SITE_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).PARTY_SITE_SCORE+l_score;');
  l('            H_SCORES(l_index).PARTY_SITE_SCORE := l_score;');
  l('          END IF;');
  l('        END IF;');
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) AND H_SCORES.EXISTS(l_index) THEN');
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_ps_party_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  l('        END IF;');
  l('        IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_party_site_cur;'); --Bug No: 3872745
  l('          IF p_index>1 THEN');
  ldbg_s('In eval party site level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
  l('          h_ps_id(detcnt) := l_party_site_id;');
  l('          h_ps_party_id(detcnt) := l_person_id;');
  l('          h_ps_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('          detcnt := detcnt +1;');
  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Site Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_party_site_id');
  dc(fnd_log.level_statement,'l_ps_party_id','l_person_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE l_party_site_cur;');
  l('    ROLLBACK to eval_start;');
  --l('    IF p_ins_details = ''Y'' THEN');
  --l('      FORALL I in 1..h_ps_id.COUNT ');
  --l('        INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID,PARTY_SITE_ID,PARTY_ID,SCORE) VALUES (');
  --l('          l_search_ctx_id, h_ps_id(I), h_ps_party_id(I), h_ps_score(I));');
  --l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at party site level  ***/');
  l('  PROCEDURE eval_contact_level(p_contact_contains_str VARCHAR2,p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
  -- l('    h_ct_id HZ_PARTY_SEARCH.IDList;');
  -- l('    h_ct_party_id HZ_PARTY_SEARCH.IDList;');
  -- l('    h_ct_score HZ_PARTY_SEARCH.IDList;');
  -- l('    detcnt NUMBER := 1;');
  -- l('    l_person_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    l_ctx_id := l_search_ctx_id;');
  l('    unset_person_party_type;');
  l('    FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    open_person_contact_cursor(p_contact_contains_str,l_ctx_id, l_contact_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_cur INTO');
  l('         l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('      EXIT WHEN l_contact_cur%NOTFOUND;');
  l('      l_person_id := get_person_id(l_ct_party_id, l_org_contact_id);');
  l('      l_index := map_id(l_person_id);');
  l('      IF l_person_id IS NOT NULL AND H_SCORES.EXISTS(l_index) THEN');
  l('        l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');
  l('        IF l_score > H_SCORES(l_index).CONTACT_SCORE THEN');
  l('          H_SCORES(l_index).TOTAL_SCORE := ');
  l('                H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_SCORE+l_score;');
  l('          H_SCORES(l_index).CONTACT_SCORE := l_score;');
  l('        END IF;');
  l('      END IF;');
  l('      IF p_ins_details = ''Y'' THEN');
  l('        h_ct_id(detcnt) := l_org_contact_id;');
  l('        h_ct_party_id(detcnt) := l_person_id;');
  l('        h_ct_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('        detcnt := detcnt +1;');
  l('      END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_org_contact_id');
  dc(fnd_log.level_statement,'l_ct_party_id','l_person_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('    END LOOP;');
  l('    CLOSE l_contact_cur;');
  l('    ROLLBACK to eval_start;');
  -- l('    IF p_ins_details = ''Y'' THEN');
  -- l('      FORALL I in 1..h_ct_id.COUNT ');
  -- l('        INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID,ORG_CONTACT_ID,PARTY_ID,SCORE) VALUES (');
  -- l('          l_search_ctx_id, h_ct_id(I), h_ct_party_id(I), h_ct_score(I));');
  -- l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to acquire and score at contact point level  ***/');
  l('  PROCEDURE eval_cpt_level(p_contact_pt_contains_str VARCHAR2,p_call_type VARCHAR2, p_index NUMBER, p_ins_details VARCHAR2,p_emax_score NUMBER) IS');
  l('    l_party_id_idx NUMBER:=1;');
  l('    l_ctx_id NUMBER;');
--  l('    h_cpt_id HZ_PARTY_SEARCH.IDList;');
--  l('    h_cpt_party_id HZ_PARTY_SEARCH.IDList;');
--  l('    h_cpt_score HZ_PARTY_SEARCH.IDList;');
--  l('    detcnt NUMBER := 1;');
--  l('    l_person_id NUMBER;');
  l('  BEGIN');
  l('    SAVEPOINT eval_start;');
  l('    unset_person_party_type;');
  l('    IF l_match_str = '' AND '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID)');
  l('      SELECT distinct l_search_ctx_id,r.subject_id from HZ_DQM_PARTIES_GT d, HZ_ORG_CONTACTS oc, ');
  l('                               HZ_RELATIONSHIPS r');
  l('      WHERE oc.party_relationship_id = r.relationship_id');
  l('      AND r.object_id = d.party_id');
  l('      AND d.SEARCH_CONTEXT_ID=l_search_ctx_id;');
  l('      H_PARTY_ID.DELETE;');
  l('      H_PARTY_ID_LIST.DELETE;');
  l('    ELSIF l_match_str = '' OR '' AND p_call_type = ''AND'' THEN');
  l('      l_ctx_id := l_search_ctx_id;');
  l('      FORALL I in 1..H_PARTY_ID.COUNT ');
  l('         INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID) VALUES (');
  l('             l_search_ctx_id,H_PARTY_ID(I));');
  l('      INSERT INTO HZ_DQM_PARTIES_GT (SEARCH_CONTEXT_ID,PARTY_ID)');
  l('      SELECT distinct l_search_ctx_id,r.subject_id from HZ_DQM_PARTIES_GT d, HZ_ORG_CONTACTS oc, ');
  l('                               HZ_RELATIONSHIPS r');
  l('      WHERE oc.party_relationship_id = r.relationship_id');
  l('      AND r.object_id = d.party_id');
  l('      AND d.SEARCH_CONTEXT_ID=l_search_ctx_id;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    ELSE');
  l('      l_ctx_id := NULL;');
  l('      l_party_id_idx := H_PARTY_ID.COUNT+1;');
  l('    END IF;');
  l('    open_contact_pt_cursor(null,NULL, p_restrict_sql, p_contact_pt_contains_str,l_ctx_id, l_contact_pt_cur);');
  l('    LOOP ');
  l('      FETCH l_contact_pt_cur INTO');
  l('         l_contact_pt_id, l_cpt_party_id,  l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('      EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('      l_person_id := get_person_id(l_cpt_party_id, l_cpt_contact_id);');
  l('      IF l_person_id IS NOT NULL THEN');
  l('        l_index := map_id(l_person_id);');
  l('        l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');

  l('        IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('          IF l_ctx_id IS NULL THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score, l_person_id, l_cpt_ps_id, l_cpt_contact_id,l_contact_pt_id);');
  l('          END IF;');
  l('        ELSE');
  l('          IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('            H_SCORES(l_index).TOTAL_SCORE := ');
  l('                  H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('            H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('          END IF;');
  l('        END IF;');
  l('        IF NOT H_PARTY_ID_LIST.EXISTS(l_index) AND H_SCORES.EXISTS(l_index) THEN');
  l('          H_PARTY_ID_LIST(l_index) := 1;');
  l('          H_PARTY_ID(l_party_id_idx) := l_person_id;');
  l('          l_party_id_idx:= l_party_id_idx+1;');
  l('        END IF;');
  l('        IF l_party_id_idx>l_max_thresh THEN');
  l('        CLOSE l_contact_pt_cur;'); --Bug No: 3872745
  l('          IF p_index>1 THEN');
  ldbg_s('In eval contact point level number of matches found exceeded threshold');
  l('            FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('            FND_MSG_PUB.ADD;');
  l('            RAISE FND_API.G_EXC_ERROR;');
  l('          ELSE');
  l('            push_eval;');
  l('            RETURN;');
  l('          END IF;');
  l('        END IF;');
  l('        IF p_ins_details = ''Y'' THEN');
  l('          h_cpt_id(detcnt) := l_contact_pt_id;');
  l('          h_cpt_party_id(detcnt) := l_person_id;');
  l('          h_cpt_score(detcnt) := round((l_score/p_emax_score)*100);');
  l('          detcnt := detcnt +1;');
  l('        END IF;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact pt Level Matches');
  dc(fnd_log.level_statement,'l_contact_pt_id','l_contact_pt_id');
  dc(fnd_log.level_statement,'l_cpt_party_id','l_person_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END IF;');
  l('    END LOOP;');
  l('    CLOSE l_contact_pt_cur;');
  l('    ROLLBACK to eval_start;');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_cpt_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CPTS_GT (SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_cpt_id(I), h_cpt_party_id(I), h_cpt_score(I));');
  l('    END IF;');
  l('  END;');
  l('');
  l('  /**  Private procedure to call the eval procedure at each entity in the correct order ***/');
  l('  PROCEDURE do_eval (p_index NUMBER) IS');
  l('    l_ctx_id NUMBER;');
  l('    l_threshold NUMBER;'); --Bug No: 4407425
  l('    other_criteria_exists BOOLEAN; '); --Bug No: 4407425
  l('  BEGIN');
  --Start of Bug No: 4407425
  l('    IF (p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0) THEN');
  l('     l_threshold := '|| l_match_threshold ||';  ');
  l('     other_criteria_exists := TRUE ;');
  l('     IF (call_max_score(2) = 0 and call_max_score(3) = 0 and call_max_score(4) = 0 ) THEN ');
  l('      other_criteria_exists := FALSE; ');
  l('     END IF ; ');
  l('    IF( (l_match_str = '' AND '' AND other_criteria_exists) OR ( call_max_score(p_index) < l_threshold) )THEN');
  l('	     RETURN;	');
  l('	  ELSE');
  ldbg_s('In do eval number of matches found exceeded threshold');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('     END IF; ');
  l('    END IF;');
  --End of Bug No: 4407425
  /*
  l('    IF p_index=5 AND call_order(5) <> ''NONE'' AND H_PARTY_ID.COUNT=0 THEN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_THRESH_EXCEEDED'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('    END IF;');
  */
  l('    IF call_order(p_index) = ''PARTY'' AND l_party_contains_str IS NOT NULL THEN');
  l('      eval_party_level(l_party_contains_str,call_type(p_index), p_index);');
  l('    ELSIF call_order(p_index) = ''PARTY_SITE'' AND l_party_site_contains_str IS NOT NULL THEN');
  l('      eval_party_site_level(l_party_site_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    ELSIF call_order(p_index) = ''CONTACT_POINT'' AND l_contact_pt_contains_str IS NOT NULL THEN');
  l('      eval_cpt_level(l_contact_pt_contains_str,call_type(p_index), p_index,p_ins_details,call_max_score(p_index));');
  l('    END IF;');
  l('  END;');
  l('  /************ End of find_persons private procedures **********/ ');
  l('');
  l('  BEGIN');
  l('');


  d(fnd_log.level_procedure,'find_persons(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;

  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');

  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    SAVEPOINT find_persons;');
  l('    l_entered_max_score:= init_search(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list, l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');
  l('    l_max_thresh:=nvl(FND_PROFILE.VALUE(''HZ_DQM_MAX_EVAL_THRESH''),200);');
  l('    IF nvl(FND_PROFILE.VALUE(''HZ_DQM_SCORE_UNTIL_THRESH''),''N'')=''Y'' THEN');
  l('      g_score_until_thresh := true;');
  l('    ELSE');
  l('      g_score_until_thresh := false;');
  l('    END IF;');

  l('    l_party_site_contains_str := check_party_sites_bulk (p_party_site_list);');
  l('    l_contact_contains_str := check_contacts_bulk (p_contact_list);');
  l('    l_contact_pt_contains_str := check_cpts_bulk (p_contact_point_list);');
  l('    l_party_contains_str := check_parties_bulk (p_party_search_rec) ;');

  l('    init_score_context(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  l('    IF l_party_contains_str IS NULL THEN');
  l('      defpt := 1;');
  l('    END IF;');
  l('    IF l_party_site_contains_str IS NULL THEN');
  l('      defps := 1;');
  l('    END IF;');
  l('    IF l_contact_contains_str IS NULL THEN');
  l('      defct := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_party_contains_str','l_party_contains_str');
  dc(fnd_log.level_statement,'l_party_site_contains_str','l_party_site_contains_str');
  dc(fnd_log.level_statement,'l_contact_contains_str','l_contact_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  /**** Call all 4 evaluation procedures ***********/
  l('    FOR I in 1..5 LOOP');
  l('      do_eval(I);');
  l('    END LOOP;');
  l('    ROLLBACK to find_persons;');
  l('    IF l_contact_contains_str IS NOT NULL THEN');
  l('      eval_contact_level(l_contact_contains_str,p_ins_details,l_contact_max_score);');
  l('    END IF;');
  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));

  l('    x_num_matches := 0;');
  l('    l_num_eval := 0;');
  l('    IF l_match_str = '' OR '' THEN');
  l('      l_party_id := H_SCORES.FIRST;');
  l('    ELSE');
  l('      l_party_id := H_PARTY_ID_LIST.FIRST;');
  l('    END IF;');

  l('    WHILE l_party_id IS NOT NULL LOOP');
  l('      l_num_eval:= l_num_eval+1;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Party ID','H_SCORES(l_party_id).PARTY_ID');
  dc(fnd_log.level_statement,'Score','round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100)');
  de;
  l('      IF (H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
  l('            INSERT INTO HZ_MATCHED_PARTIES_GT (SEARCH_CONTEXT_ID, PARTY_ID, SCORE) ');
  l('            VALUES (l_search_ctx_id,H_SCORES(l_party_id).PARTY_ID,round((H_SCORES(l_party_id).TOTAL_SCORE/l_entered_max_score)*100));');
  l('            x_num_matches := x_num_matches+1;');
  l('      END IF;');
  l('      IF l_match_str = '' OR '' THEN');
  l('        l_party_id:=H_SCORES.NEXT(l_party_id);');
  l('      ELSE');
  l('        l_party_id:=H_PARTY_ID_LIST.NEXT(l_party_id);');
  l('      END IF;');
  l('    END LOOP;');
  l('');
  l('----------INSERT INTO HZ_MATCHED_PARTY_SITES -----');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_ps_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID,PARTY_SITE_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_ps_id(I), h_ps_party_id(I), h_ps_score(I));');
  l('    END IF;');

  l('----------INSERT INTO HZ_MATCHED_CONTACTS-----');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_ct_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID,ORG_CONTACT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_ct_id(I), h_ct_party_id(I), h_ct_score(I));');
  l('    END IF;');
  l('----------INSERT INTO HZ_MATCHED_CPTS-----');
  l('    IF p_ins_details = ''Y'' THEN');
  l('      FORALL I in 1..h_cpt_id.COUNT ');
  l('        INSERT INTO HZ_MATCHED_CPTS_GT (SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  l('          l_search_ctx_id, h_cpt_id(I), h_cpt_party_id(I), h_cpt_score(I));');
  l('    END IF;');
  l('');
  l('    HZ_DQM_SEARCH_UTIL.set_num_eval(l_num_eval);');
  d(fnd_log.level_procedure,'find_persons(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    ROLLBACK to find_persons;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    ROLLBACK to find_persons;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    ROLLBACK to find_persons;');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_persons'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_persons;');
  ELSE
  l('BEGIN');
  l('      FND_MESSAGE.SET_NAME(''AR'', ''HZ_INVALID_MATCH_RULE'');');
  l('      FND_MSG_PUB.ADD;');
  l('      RAISE FND_API.G_EXC_ERROR;');
  l('END find_persons;');
  l('');
  END IF;
  l('PROCEDURE find_persons (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(')  IS');
  l('  BEGIN');
  l('      find_persons(p_rule_id,p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,');
  l('      	p_restrict_sql,p_match_type,NULL,p_ins_details,x_search_ctx_id,x_num_matches);');
  l('	END find_persons;');
  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_party_details ------------------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_party_details (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
  l('  BEGIN');


  d(fnd_log.level_procedure,'find_party_details(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_search_merged','p_search_merged');
  de;

  l('  find_parties(p_rule_id,p_party_search_rec,p_party_site_list, p_contact_list, p_contact_point_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,null,null, null,''Y'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  DELETE FROM HZ_MATCHED_PARTY_SITES_GT ps WHERE SEARCH_CONTEXT_ID = x_search_ctx_id ');
  l('  AND NOT EXISTS ');
  l('       (SELECT 1 FROM HZ_MATCHED_PARTIES_GT p WHERE SEARCH_CONTEXT_ID = x_search_ctx_id AND p.PARTY_ID = ps.PARTY_ID);');
  l('  DELETE FROM HZ_MATCHED_CONTACTS_GT ct WHERE SEARCH_CONTEXT_ID = x_search_ctx_id ');
  l('  AND NOT EXISTS ');
  l('       (SELECT 1 FROM HZ_MATCHED_PARTIES_GT p WHERE SEARCH_CONTEXT_ID = x_search_ctx_id AND p.PARTY_ID = ct.PARTY_ID);');
  l('  DELETE FROM HZ_MATCHED_CPTS_GT cpt WHERE SEARCH_CONTEXT_ID = x_search_ctx_id ');
  l('  AND NOT EXISTS ');
  l('       (SELECT 1 FROM HZ_MATCHED_PARTIES_GT p WHERE SEARCH_CONTEXT_ID = x_search_ctx_id AND p.PARTY_ID = cpt.PARTY_ID);');

  d(fnd_log.level_procedure,'find_party_details(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_party_details'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_party_details;');
  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_duplicate_parties -------------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_duplicate_parties (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_dup_set_id            OUT     NUMBER,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  l_party_rec HZ_PARTY_SEARCH.party_search_rec_type;');
  l('  l_party_site_list HZ_PARTY_SEARCH.party_site_list;');
  l('  l_contact_list HZ_PARTY_SEARCH.contact_list;');
  l('  l_cpt_list HZ_PARTY_SEARCH.contact_point_list;');
  l('  l_match_idx NUMBER;');

  l('');
  l('BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_parties(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_batch_id','p_dup_batch_id');
  dc(fnd_log.level_statement,'p_search_merged','p_search_merged');
  de;

  l('');
  l('  get_party_for_search(');
  l('              p_party_id, l_party_rec,l_party_site_list, l_contact_list, l_cpt_list);');
  l('');
  l('    IF NOT check_prim_cond (l_party_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_cpt_list) THEN');
  l('      x_dup_set_id:=NULL;');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');

  l('  x_dup_set_id := NULL;');
  l('  IF p_dup_batch_id IS NOT NULL THEN');
  l('    SELECT HZ_MERGE_BATCH_S.nextval INTO x_dup_set_id FROM DUAL;');
  l('  END IF;');
  l('');

  l('  find_parties(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,p_party_id,x_dup_set_id,p_dup_batch_id,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  IF x_num_matches > 0 AND p_dup_batch_id IS NOT NULL THEN');
  l('    INSERT INTO HZ_DUP_SETS ( DUP_SET_ID, DUP_BATCH_ID, WINNER_PARTY_ID,');
  l('      STATUS, MERGE_TYPE, CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN,');
  l('      LAST_UPDATE_DATE, LAST_UPDATED_BY) ');
  l('    VALUES (x_dup_set_id, p_dup_batch_id, p_party_id, ''SYSBATCH'',');
  l('      ''PARTY_MERGE'', hz_utility_pub.created_by, hz_utility_pub.creation_date,');
  l('      hz_utility_pub.last_update_login, hz_utility_pub.last_update_date,');
  l('      hz_utility_pub.user_id);');
  l('');
  l('    INSERT INTO HZ_DUP_SET_PARTIES (DUP_PARTY_ID,DUP_SET_ID,MERGE_SEQ_ID,');
  l('      MERGE_BATCH_ID,merge_flag,SCORE,CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,');
  l('      LAST_UPDATE_DATE,LAST_UPDATED_BY,DUP_SET_BATCH_ID) '); --Bug No: 4244529
  l('    VALUES (p_party_id,x_dup_set_id,0,0,');
  l('      ''Y'',100,hz_utility_pub.created_by,hz_utility_pub.creation_date,');
  l('      hz_utility_pub.last_update_login,hz_utility_pub.last_update_date,');
  l('      hz_utility_pub.user_id,p_dup_batch_id);'); --Bug No: 4244529
  l('  ELSE');
  l('    x_dup_set_id := NULL;');
  l('  END IF;');
  d(fnd_log.level_procedure,'find_duplicate_parties(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_parties'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_parties;');


  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_duplicate_party_sites-----------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_duplicate_party_sites (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_site_id         IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');


  l('   l_party_search_rec HZ_PARTY_SEARCH.party_search_rec_type; ');
  l('   l_party_site_list HZ_PARTY_SEARCH.party_site_list; ');
  l('   l_contact_list HZ_PARTY_SEARCH.contact_list; ');
  l('   l_contact_point_list HZ_PARTY_SEARCH.contact_point_list; ');
  l('   contact_point_ids HZ_PARTY_SEARCH.IDList; ');
  l('   p_party_site_list HZ_PARTY_SEARCH.IDList;  ');
  l('   p_contact_ids HZ_PARTY_SEARCH.IDList; ');
  l('  l_match_idx NUMBER;');

  l('   cursor get_cpts_for_party_sites is select contact_point_id  ');
  l('                         from hz_contact_points ');
  l('                         where owner_table_name = ''HZ_PARTY_SITES'' ');
  l('                         and primary_flag=''Y''');
  l('                         and owner_table_id = p_party_site_id; ');

  l('   BEGIN ');


  d(fnd_log.level_procedure,'find_duplicate_party_sites(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_party_site_id','p_party_site_id');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;

  l('     p_party_site_list(1) := p_party_site_id; ');
  l('     OPEN get_cpts_for_party_sites;');
  l('     LOOP       ');
  l('     FETCH get_cpts_for_party_sites BULK COLLECT INTO contact_point_ids; ');
  l('         EXIT WHEN get_cpts_for_party_sites%NOTFOUND; ');
  l('     END LOOP;  ');
  l('     CLOSE get_cpts_for_party_sites; ');
  l('  ');
  l('     get_search_criteria (');
  l('         null,');
  l('         p_party_site_list,');
  l('         HZ_PARTY_SEARCH.G_MISS_ID_LIST,');
  l('         contact_point_ids, ');
  l('         l_party_search_rec,');
  l('         l_party_site_list,');
  l('         l_contact_list,');
  l('         l_contact_point_list) ;');
  l('    IF NOT check_prim_cond (l_party_search_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_contact_point_list) THEN');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');
  l(' ');
  l('     get_matching_party_sites (p_rule_id, ');
  l('         p_party_id, ');
  l('         l_party_site_list, ');
  l('         l_contact_point_list,');
  l('         p_restrict_sql, ');
  l('         p_match_type, ');
  l('         p_party_site_id, ');
  l('         x_search_ctx_id,');
  l('         x_num_matches);');
  d(fnd_log.level_procedure,'find_duplicate_party_sites(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_party_sites'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_party_sites; ');
  l(' ');

  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_duplicate_contacts--------------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_duplicate_contacts (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_org_contact_id        IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');

  l(' l_party_search_rec HZ_PARTY_SEARCH.party_search_rec_type;');
  l(' l_party_site_list HZ_PARTY_SEARCH.party_site_list; ');
  l(' l_contact_list HZ_PARTY_SEARCH.contact_list; ');
  l(' l_contact_point_list HZ_PARTY_SEARCH.contact_point_list; ');
  l(' contact_point_ids HZ_PARTY_SEARCH.IDList; ');
  l(' p_party_site_list HZ_PARTY_SEARCH.IDList;   ');
  l(' p_contact_ids HZ_PARTY_SEARCH.IDList; ');
  l('  l_match_idx NUMBER;');

  l(' cursor get_cpt_for_contact_id is select  contact_point_id ');
  l('   from hz_org_contacts a, hz_relationships b, hz_contact_points c ');
  l('   where a.party_relationship_id = b.relationship_id ');
  l('     and c.owner_table_name = ''HZ_PARTIES'' ');
  l('     and c.primary_flag=''Y''');
  l('     and c.owner_table_id = b.party_id ');
  l('     and b.directional_flag = ''F''  ');
  l('     and a.org_contact_id = p_org_contact_id; ');

  l('BEGIN ');


  d(fnd_log.level_procedure,'find_duplicate_contacts(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_org_contact_id','p_org_contact_id');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;


  l('    p_contact_ids(1) := p_org_contact_id; ');
  l('    OPEN get_cpt_for_contact_id; ');
  l('    LOOP ');
  l('    FETCH get_cpt_for_contact_id BULK COLLECT INTO contact_point_ids; ');
  l('        EXIT WHEN get_cpt_for_contact_id%NOTFOUND; ');
  l('    END LOOP;  ');
  l('    CLOSE get_cpt_for_contact_id; ');
  l(' ');
  l('    get_search_criteria (');
  l('        null,');
  l('        HZ_PARTY_SEARCH.G_MISS_ID_LIST,');
  l('        p_contact_ids,');
  l('        contact_point_ids, ');
  l('        l_party_search_rec,');
  l('        l_party_site_list, ');
  l('        l_contact_list,');
  l('        l_contact_point_list) ;');
  l('    IF NOT check_prim_cond (l_party_search_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_contact_point_list) THEN');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');
  l(' ');
  l('    get_matching_contacts (p_rule_id, ');
  l('        p_party_id, ');
  l('        l_contact_list, ');
  l('        l_contact_point_list, ');
  l('        p_restrict_sql, ');
  l('        p_match_type, ');
  l('        p_org_contact_id, ');
  l('        x_search_ctx_id, ');
  l('        x_num_matches);');
  l(' ');
  d(fnd_log.level_procedure,'find_duplicate_contacts(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_contacts'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_contacts; ');
  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_duplicate_contact_points -------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_duplicate_contact_points (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_contact_point_id      IN      NUMBER,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(') IS');
  l(' l_party_search_rec HZ_PARTY_SEARCH.party_search_rec_type; ');
  l('  l_party_site_list HZ_PARTY_SEARCH.party_site_list; ');
  l('   l_contact_list HZ_PARTY_SEARCH.contact_list;  ');
  l('   l_contact_point_list HZ_PARTY_SEARCH.contact_point_list;  ');
  l('   contact_point_ids HZ_PARTY_SEARCH.IDList;  ');
  l('  p_party_site_list HZ_PARTY_SEARCH.IDList;   ');
  l('  p_contact_ids HZ_PARTY_SEARCH.IDList;  ');
  l('  l_match_idx NUMBER;');

  l('');
  l('BEGIN');


  d(fnd_log.level_procedure,'find_duplicate_contact_points(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_contact_point_id','p_contact_point_id');
  dc(fnd_log.level_statement,'p_party_id','p_party_id');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  de;

  l('  contact_point_ids(1) := p_contact_point_id;   ');
  l('  get_search_criteria (   ');
  l('      null, ');
  l('      HZ_PARTY_SEARCH.G_MISS_ID_LIST, ');
  l('      HZ_PARTY_SEARCH.G_MISS_ID_LIST, ');
  l('      contact_point_ids,   ');
  l('      l_party_search_rec, ');
  l('      l_party_site_list, ');
  l('      l_contact_list, ');
  l('      l_contact_point_list ); ');
  l('    ');
  l('    IF NOT check_prim_cond (l_party_search_rec,');
  l('                            l_party_site_list,');
  l('                            l_contact_list,');
  l('                            l_contact_point_list) THEN');
  l('      x_search_ctx_id:=NULL;');
  l('      x_num_matches:=0;');
  l('      RETURN;');
  l('    END IF;');
  l('   get_matching_contact_points ( ');
  l('      p_rule_id, ');
  l('      p_party_id, ');
  l('     l_contact_point_list, ');
  l('      p_restrict_sql, ');
  l('      p_match_type, ');
  l('      p_contact_point_id, ');
  l('      x_search_ctx_id, ');
  l('      x_num_matches );  ');
  d(fnd_log.level_procedure,'find_duplicate_contact_points(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.find_duplicate_contact_points'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END find_duplicate_contact_points;');
  l('');

  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: find_parties_dynamic-----------------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE find_parties_dynamic (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_attrib_id1            IN      NUMBER,');
  l('        p_attrib_id2            IN      NUMBER,');
  l('        p_attrib_id3            IN      NUMBER,');
  l('        p_attrib_id4            IN      NUMBER,');
  l('        p_attrib_id5            IN      NUMBER,');
  l('        p_attrib_id6            IN      NUMBER,');
  l('        p_attrib_id7            IN      NUMBER,');
  l('        p_attrib_id8            IN      NUMBER,');
  l('        p_attrib_id9            IN      NUMBER,');
  l('        p_attrib_id10           IN      NUMBER,');
  l('        p_attrib_id11           IN      NUMBER,');
  l('        p_attrib_id12           IN      NUMBER,');
  l('        p_attrib_id13           IN      NUMBER,');
  l('        p_attrib_id14           IN      NUMBER,');
  l('        p_attrib_id15           IN      NUMBER,');
  l('        p_attrib_id16           IN      NUMBER,');
  l('        p_attrib_id17           IN      NUMBER,');
  l('        p_attrib_id18           IN      NUMBER,');
  l('        p_attrib_id19           IN      NUMBER,');
  l('        p_attrib_id20           IN      NUMBER,');
  l('        p_attrib_val1           IN      VARCHAR2,');
  l('        p_attrib_val2           IN      VARCHAR2,');
  l('        p_attrib_val3           IN      VARCHAR2,');
  l('        p_attrib_val4           IN      VARCHAR2,');
  l('        p_attrib_val5           IN      VARCHAR2,');
  l('        p_attrib_val6           IN      VARCHAR2,');
  l('        p_attrib_val7           IN      VARCHAR2,');
  l('        p_attrib_val8           IN      VARCHAR2,');
  l('        p_attrib_val9           IN      VARCHAR2,');
  l('        p_attrib_val10          IN      VARCHAR2,');
  l('        p_attrib_val11          IN      VARCHAR2,');
  l('        p_attrib_val12          IN      VARCHAR2,');
  l('        p_attrib_val13          IN      VARCHAR2,');
  l('        p_attrib_val14          IN      VARCHAR2,');
  l('        p_attrib_val15          IN      VARCHAR2,');
  l('        p_attrib_val16          IN      VARCHAR2,');
  l('        p_attrib_val17          IN      VARCHAR2,');
  l('        p_attrib_val18          IN      VARCHAR2,');
  l('        p_attrib_val19          IN      VARCHAR2,');
  l('        p_attrib_val20          IN      VARCHAR2,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_search_merged         IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  BEGIN');
  l('    call_api_dynamic(p_rule_id,p_attrib_id1, p_attrib_id2,p_attrib_id3,p_attrib_id4,p_attrib_id5,');
  l('                     p_attrib_id6,p_attrib_id7,p_attrib_id8,p_attrib_id9,p_attrib_id10,');
  l('                     p_attrib_id11,p_attrib_id12,p_attrib_id13,p_attrib_id14,p_attrib_id15,');
  l('                     p_attrib_id16,p_attrib_id17,p_attrib_id18,p_attrib_id19,p_attrib_id20,');
  l('                     p_attrib_val1,p_attrib_val2,p_attrib_val3,p_attrib_val4,p_attrib_val5,');
  l('                     p_attrib_val6,p_attrib_val7,p_attrib_val8,p_attrib_val9,p_attrib_val10,');
  l('                     p_attrib_val11,p_attrib_val12,p_attrib_val13,p_attrib_val14,p_attrib_val15,');
  l('                     p_attrib_val16,p_attrib_val17,p_attrib_val18,p_attrib_val19,p_attrib_val20,');
  l('                     p_restrict_sql,''FIND_PARTIES'',p_match_type,null,p_search_merged,x_search_ctx_id,x_num_matches);');
  l(' END;');

  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: call_api_dynamic---------------------------');
  l('-------------------------------------------------------------------------------------');
  l('PROCEDURE call_api_dynamic (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_attrib_id1            IN      NUMBER,');
  l('        p_attrib_id2            IN      NUMBER,');
  l('        p_attrib_id3            IN      NUMBER,');
  l('        p_attrib_id4            IN      NUMBER,');
  l('        p_attrib_id5            IN      NUMBER,');
  l('        p_attrib_id6            IN      NUMBER,');
  l('        p_attrib_id7            IN      NUMBER,');
  l('        p_attrib_id8            IN      NUMBER,');
  l('        p_attrib_id9            IN      NUMBER,');
  l('        p_attrib_id10           IN      NUMBER,');
  l('        p_attrib_id11           IN      NUMBER,');
  l('        p_attrib_id12           IN      NUMBER,');
  l('        p_attrib_id13           IN      NUMBER,');
  l('        p_attrib_id14           IN      NUMBER,');
  l('        p_attrib_id15           IN      NUMBER,');
  l('        p_attrib_id16           IN      NUMBER,');
  l('        p_attrib_id17           IN      NUMBER,');
  l('        p_attrib_id18           IN      NUMBER,');
  l('        p_attrib_id19           IN      NUMBER,');
  l('        p_attrib_id20           IN      NUMBER,');
  l('        p_attrib_val1           IN      VARCHAR2,');
  l('        p_attrib_val2           IN      VARCHAR2,');
  l('        p_attrib_val3           IN      VARCHAR2,');
  l('        p_attrib_val4           IN      VARCHAR2,');
  l('        p_attrib_val5           IN      VARCHAR2,');
  l('        p_attrib_val6           IN      VARCHAR2,');
  l('        p_attrib_val7           IN      VARCHAR2,');
  l('        p_attrib_val8           IN      VARCHAR2,');
  l('        p_attrib_val9           IN      VARCHAR2,');
  l('        p_attrib_val10          IN      VARCHAR2,');
  l('        p_attrib_val11          IN      VARCHAR2,');
  l('        p_attrib_val12          IN      VARCHAR2,');
  l('        p_attrib_val13          IN      VARCHAR2,');
  l('        p_attrib_val14          IN      VARCHAR2,');
  l('        p_attrib_val15          IN      VARCHAR2,');
  l('        p_attrib_val16          IN      VARCHAR2,');
  l('        p_attrib_val17          IN      VARCHAR2,');
  l('        p_attrib_val18          IN      VARCHAR2,');
  l('        p_attrib_val19          IN      VARCHAR2,');
  l('        p_attrib_val20          IN      VARCHAR2,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_api_name              IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_search_merged         IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  TYPE AttrList IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;');
  l('  l_match_idx NUMBER;');
  l('  AttrVals AttrList;');
  l('  l_party_rec HZ_PARTY_SEARCH.party_search_rec_type;');
  l('  l_party_site_list HZ_PARTY_SEARCH.party_site_list;');
  l('  l_contact_list HZ_PARTY_SEARCH.contact_list;');
  l('  l_cpt_list HZ_PARTY_SEARCH.contact_point_list;');
  l('  l_dup_set_id NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_cpt_type VARCHAR2(255);');
  l('  FIRST BOOLEAN := TRUE; ');
  l('');
  l('BEGIN');

  d(fnd_log.level_procedure,'call_api_dynamic(+)');
  l('');
  FOR I in 1..20 LOOP
    l('  IF p_attrib_id'||I||' IS NOT NULL THEN');
    l('    AttrVals(p_attrib_id'||I||'):=p_attrib_val'||I||';');
    l('  END IF;');
  END LOOP;

  FIRST := TRUE;
  FOR ATTRS IN (
      SELECT a.attribute_id, a.attribute_name, a.entity_name
      FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
      WHERE p.match_rule_id = p_rule_id
      AND p.attribute_id = a.attribute_id

      UNION

      SELECT a.attribute_id, a.attribute_name, a.entity_name
      FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
      WHERE s.match_rule_id = p_rule_id
      AND s.attribute_id = a.attribute_id) LOOP
    l('  IF AttrVals.EXISTS('||ATTRS.attribute_id||') THEN');
    IF ATTRS.entity_name='PARTY' THEN
        l('    l_party_rec.'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
        d(fnd_log.level_statement,'l_party_rec.'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
    ELSIF ATTRS.entity_name='PARTY_SITES' THEN
        l('    l_party_site_list(1).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
        d(fnd_log.level_statement,'l_party_site_list(1).'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
    ELSIF ATTRS.entity_name='CONTACTS' THEN
        l('    l_contact_list(1).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
        d(fnd_log.level_statement,'l_contact_list(1).'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
    ELSIF ATTRS.entity_name='CONTACT_POINTS' THEN
      BEGIN
        SELECT tag INTO l_cpt_type FROM fnd_lookup_values
        WHERE lookup_type = 'HZ_DQM_CPT_ATTR_TYPE'
        AND lookup_code = ATTRS.attribute_name
        AND ROWNUM=1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_cpt_type:='PHONE';
      END;

      l('    l_cpt_type := '''||l_cpt_type||''';');
      l('    FIRST := FALSE;');
      l('    FOR I in 1..l_cpt_list.COUNT LOOP');
      l('      IF l_cpt_list(I).CONTACT_POINT_TYPE=l_cpt_type THEN');
      l('        l_cpt_list(I).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
      l('        FIRST := TRUE;');
      ds(fnd_log.level_statement);
      dc(fnd_log.level_statement,'l_cpt_list(''||I||'').CONTACT_POINT_TYPE','l_cpt_type');
      dc(fnd_log.level_statement,'l_cpt_list(''||I||'').'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
      de;
      l('      END IF;');
      l('    END LOOP;');
      l('    IF not FIRST THEN');
      l('      l_idx := l_cpt_list.COUNT+1;');
      l('      l_cpt_list(l_idx).CONTACT_POINT_TYPE:=l_cpt_type;');
      l('      l_cpt_list(l_idx).'||ATTRS.attribute_name||':= AttrVals('||ATTRS.attribute_id||');');
      ds(fnd_log.level_statement);
      dc(fnd_log.level_statement,'l_cpt_list(''||l_idx||'').CONTACT_POINT_TYPE','l_cpt_type');
      dc(fnd_log.level_statement,'l_cpt_list(''||l_idx||'').'||ATTRS.attribute_name,'AttrVals('||ATTRS.attribute_id||')');
      de;
      l('    END IF;');
    END IF;
    l('  END IF;');
    l('');
  END LOOP;
  l('');
  l('  IF upper(p_api_name) = ''FIND_PARTIES'' THEN');
  l('    find_parties(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,NULL,NULL,NULL,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''FIND_PARTY_DETAILS'' THEN');
  l('    find_party_details(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,p_search_merged,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''FIND_PERSONS'' THEN');
  l('    find_persons(p_rule_id,l_party_rec,l_party_site_list, l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,''N'',');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''GET_MATCHING_PARTY_SITES'' THEN');
  l('    get_matching_party_sites(p_rule_id,p_party_id,l_party_site_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,NULL,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''GET_MATCHING_CONTACTS'' THEN');
  l('    get_matching_contacts(p_rule_id,p_party_id,l_contact_list, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,NULL,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  ELSIF upper(p_api_name) = ''GET_MATCHING_CONTACT_POINTS'' THEN');
  l('    get_matching_contact_points(p_rule_id,p_party_id, l_cpt_list,');
  l('               p_restrict_sql,p_match_type,NULL,');
  l('               x_search_ctx_id,x_num_matches);');
  l('  END IF;');
  d(fnd_log.level_procedure,'call_api_dynamic(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.call_api_dynamic'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');


  l('END call_api_dynamic;');
  l('');

  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: get_matching_party_sites ------------------');
  l('-------------------------------------------------------------------------------------');

  l('');
  l('PROCEDURE get_matching_party_sites (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_list       IN      HZ_PARTY_SEARCH.PARTY_SITE_LIST,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_dup_party_site_id     IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  ');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_match_idx NUMBER;');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND (a.ENTITY_NAME='PARTY_SITES' OR a.ENTITY_NAME='CONTACT_POINTS')
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_ps_contact_id NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('');
  l('  ');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_party_sites(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_party_site_id','p_dup_party_site_id');
  de;
  l('');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');
  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    SAVEPOINT get_matching_party_sites ;');
  l('    l_entered_max_score:= init_search( HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC, p_party_site_list, HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST, p_contact_point_list,l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');

  l('');
  l('    l_party_site_contains_str := check_party_sites_bulk (p_party_site_list);');
  l('    l_contact_pt_contains_str := check_cpts_bulk (p_contact_point_list);');
  l('    init_score_context(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,p_party_site_list,HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_party_site_contains_str','l_party_site_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  l('    IF l_party_site_contains_str IS NULL THEN');
  l('      defps := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');
  l('    IF l_party_site_contains_str IS NOT NULL THEN');
  l('      open_party_site_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_party_site_contains_str,NULL,l_party_site_cur);');
  l('      LOOP');
  l('        FETCH l_party_site_cur INTO ');
  l('            l_party_site_id, l_ps_party_id, l_ps_contact_id '||l_ps_into_list||';');
  l('        EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('      IF (p_dup_party_site_id IS NULL OR (');
  l('                p_dup_party_site_id IS NOT NULL AND l_ps_contact_id IS NULL AND ');
  l('                l_party_site_id <> p_dup_party_site_id)) THEN  ');
  l('            l_index := map_id(l_party_site_id);');
  l('            l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,l_score,defct,defcpt, l_ps_party_id, l_party_site_id, null,null);');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Party Site Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_party_site_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;

  l('      END IF; ');
  l('      END LOOP;');
  l('      CLOSE l_party_site_cur;');
  l('    END IF;');
  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL,l_contact_pt_cur);');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('      IF (l_cpt_ps_id IS NOT NULL AND (p_dup_party_site_id IS NULL OR (');
  l('         p_dup_party_site_id IS NOT NULL AND l_cpt_contact_id IS NULL AND p_dup_party_site_id <> l_cpt_ps_id))) THEN   ');
  l('        l_index := map_id(l_cpt_ps_id);');
  l('        IF l_match_str = '' OR '' THEN');
  l('          l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('          IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          ELSE');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          END IF;');
  l('        ELSE');
  l('          IF H_SCORES.EXISTS(l_index) THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          ELSIF defps=1 THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          END IF;');
  l('        END IF;');
  l('      END IF; ');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact_point Level Matches');
  dc(fnd_log.level_statement,'l_party_site_id','l_cpt_ps_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      END LOOP;');
  l('      CLOSE l_contact_pt_cur;');
  l('    END IF;');
  l('    ROLLBACK to get_matching_party_sites ;');
  l('    x_num_matches := 0;');
  l('    l_party_site_id := H_SCORES.FIRST;');
  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  l('    WHILE l_party_site_id IS NOT NULL LOOP');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Party Site ID','H_SCORES(l_party_site_id).PARTY_SITE_ID');
  dc(fnd_log.level_statement,'Score','round((H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)*100)');
  de;
  l('      IF l_match_str = '' OR '' THEN');
    l('        IF (H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('            INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID, PARTY_ID, PARTY_SITE_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_party_site_id).PARTY_ID, H_SCORES(l_party_site_id).PARTY_SITE_ID, (H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)*100);');
--  END IF;
  l('          x_num_matches := x_num_matches+1;');
  l('        END IF;');
  l('      ELSE');
--  IF l_purpose = 'S' THEN
    l('           IF H_SCORES(l_party_site_id).PARTY_SITE_SCORE>0 AND');
    l('           H_SCORES(l_party_site_id).CONTACT_POINT_SCORE>0 AND');
    l('           (H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('          INSERT INTO HZ_MATCHED_PARTY_SITES_GT (SEARCH_CONTEXT_ID, PARTY_ID, PARTY_SITE_ID, SCORE) ');
    l('          VALUES (l_search_ctx_id,H_SCORES(l_party_site_id).PARTY_ID, H_SCORES(l_party_site_id).PARTY_SITE_ID, round((H_SCORES(l_party_site_id).TOTAL_SCORE/l_entered_max_score)*100));');
--  ELSE
--  END IF;
  l('          x_num_matches := x_num_matches+1;');
  l('        END IF;');
  l('      END IF;');
  l('      l_party_site_id:=H_SCORES.NEXT(l_party_site_id);');
  l('    END LOOP;');

  d(fnd_log.level_procedure,'get_matching_party_sites(-)');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    ROLLBACK to get_matching_party_sites ;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    ROLLBACK to get_matching_party_sites ;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    ROLLBACK to get_matching_party_sites ;');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_matching_party_sites'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_matching_party_sites;');
  l('');

--  l('  NULL;');
--  l('END;');

  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: get_matching_contacts --------------------');
  l('-------------------------------------------------------------------------------------');
  l('');
  l('PROCEDURE get_matching_contacts (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_list          IN      HZ_PARTY_SEARCH.CONTACT_LIST,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_dup_contact_id        IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('  ');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_match_idx NUMBER;');
  l('  l_sqlstr VARCHAR2(32000); -- Dynamic SQL String');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND (a.ENTITY_NAME='CONTACTS' OR a.ENTITY_NAME='CONTACT_POINTS')
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('');
  l('  defpt NUMBER :=0;');
  l('  defps NUMBER :=0;');
  l('  defct NUMBER :=0;');
  l('  defcpt NUMBER :=0;');
  l('  l_index NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  ');
  l('  BEGIN');


  d(fnd_log.level_procedure,'get_matching_contacts(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_contact_id','p_dup_contact_id');
  de;

  l('');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');
  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('    SAVEPOINT get_matching_contacts ;');
  l('    l_entered_max_score:= init_search( HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC, HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST, p_contact_list, p_contact_point_list,l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');
  l('    l_contact_contains_str := check_contacts_bulk (p_contact_list);');
  l('    l_contact_pt_contains_str := check_cpts_bulk (p_contact_point_list);');
  l('    init_score_context(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,p_contact_list,p_contact_point_list);');

  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');
  l('');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_contact_contains_str','l_contact_contains_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  l('    IF l_contact_contains_str IS NULL THEN');
  l('      defct := 1;');
  l('    END IF;');
  l('    IF l_contact_pt_contains_str IS NULL THEN');
  l('      defcpt := 1;');
  l('    END IF;');
  l('');
  l('    IF l_contact_contains_str IS NOT NULL THEN');
  l('      open_contact_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_contains_str,NULL,l_contact_cur);');
  l('      LOOP');
  l('        FETCH l_contact_cur INTO ');
  l('            l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('        EXIT WHEN l_contact_cur%NOTFOUND;');
  l('      IF (p_dup_contact_id IS NULL OR l_org_contact_id <> p_dup_contact_id) THEN ');
  l('        l_index := map_id(l_org_contact_id);');
  l('          l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,l_score,defcpt, l_ct_party_id, null, l_org_contact_id, null);');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_org_contact_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;

  l('      END IF; ');
  l('      END LOOP;');
  l('      CLOSE l_contact_cur;');
  l('    END IF;');

  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL,l_contact_pt_cur);');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('      IF (l_cpt_contact_id IS NOT NULL AND (p_dup_contact_id IS NULL OR l_cpt_contact_id <>  p_dup_contact_id)) THEN ');
  l('        l_index := map_id(l_cpt_contact_id);');
  l('        IF l_match_str = '' OR '' THEN');
  l('          l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('          IF NOT H_SCORES.EXISTS(l_index) THEN');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          ELSE');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          END IF;');
  l('        ELSE');
  l('          IF H_SCORES.EXISTS(l_index) THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            IF l_score > H_SCORES(l_index).CONTACT_POINT_SCORE THEN');
  l('               H_SCORES(l_index).TOTAL_SCORE := ');
  l('                      H_SCORES(l_index).TOTAL_SCORE-H_SCORES(l_index).CONTACT_POINT_SCORE+l_score;');
  l('               H_SCORES(l_index).CONTACT_POINT_SCORE := l_score;');
  l('            END IF;');
  l('          ELSIF defps=1 THEN');
  l('            l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            H_SCORES(l_index) := get_new_score_rec(l_score,defpt,defps,defct,l_score,l_cpt_party_id,l_cpt_ps_id,l_cpt_contact_id,l_contact_pt_id);');
  l('          END IF;');
  l('        END IF;');
  l('        END IF; ');
  l('      END LOOP;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact_point Level Matches');
  dc(fnd_log.level_statement,'l_org_contact_id','l_cpt_contact_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;
  l('      CLOSE l_contact_pt_cur;');
  l('    END IF;');
  l('    ROLLBACK to get_matching_contacts ;');
  l('    x_num_matches := 0;');
  l('    l_org_contact_id := H_SCORES.FIRST;');
  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  l('    WHILE l_org_contact_id IS NOT NULL LOOP');
  l('      IF l_match_str = '' OR '' THEN');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Contact ID','H_SCORES(l_org_contact_id).ORG_CONTACT_ID');
  dc(fnd_log.level_statement,'Score','round((H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)*100)');
  de;
--  IF l_purpose = 'S' THEN
    l('        IF (H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('            INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID, PARTY_ID, ORG_CONTACT_ID, SCORE) ');
    l('            VALUES (l_search_ctx_id,H_SCORES(l_org_contact_id).PARTY_ID, H_SCORES(l_org_contact_id).ORG_CONTACT_ID, (H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)*100);');
--  ELSE
--  END IF;
  l('          x_num_matches := x_num_matches+1;');
  l('        END IF;');
  l('      ELSE');
--  IF l_purpose = 'S' THEN
    l('           IF H_SCORES(l_org_contact_id).CONTACT_SCORE>0 AND');
    l('           H_SCORES(l_org_contact_id).CONTACT_POINT_SCORE>0 AND');
    l('           (H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
    l('          INSERT INTO HZ_MATCHED_CONTACTS_GT (SEARCH_CONTEXT_ID, PARTY_ID, ORG_CONTACT_ID, SCORE) ');
    l('          VALUES (l_search_ctx_id,H_SCORES(l_org_contact_id).PARTY_ID, H_SCORES(l_org_contact_id).ORG_CONTACT_ID, round((H_SCORES(l_org_contact_id).TOTAL_SCORE/l_entered_max_score)*100));');
--  ELSE
--  END IF;
  l('          x_num_matches := x_num_matches+1;');
  l('        END IF;');
  l('      END IF;');
  l('      l_org_contact_id:=H_SCORES.NEXT(l_org_contact_id);');
  l('    END LOOP;');

  d(fnd_log.level_procedure,'get_matching_contacts(-)');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    ROLLBACK to get_matching_contacts ;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    ROLLBACK to get_matching_contacts ;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    ROLLBACK to get_matching_contacts ;');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_matching_contacts'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_matching_contacts;');
  l('');
  l('-------------------------------------------------------------------------------------');
  l('--------------------  BULK MATCH RULE ::: get_matching_contact_points ---------------');
  l('-------------------------------------------------------------------------------------');
  l('');
  l('PROCEDURE get_matching_contact_points (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_dup_contact_point_id  IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(') IS');
  l('');
  l('');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  l_match_idx NUMBER;');
  l('  -- For Score calculation');
  l('  l_entered_max_score NUMBER;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.ENTITY_NAME='CONTACT_POINTS'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('');
  l('  l_score NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  H_PARTY_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_CONTACT_POINT_ID HZ_PARTY_SEARCH.IDList;');
  l('  H_SCORE  HZ_PARTY_SEARCH.IDList;');
  l('');
  l('  cnt NUMBER :=0;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  ');
  l('  BEGIN');



  d(fnd_log.level_procedure,'get_matching_contact_points(+)');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Input Parameters:');
  dc(fnd_log.level_statement,'p_match_type','p_match_type');
  dc(fnd_log.level_statement,'p_restrict_sql','p_restrict_sql');
  dc(fnd_log.level_statement,'p_dup_contact_point_id','p_dup_contact_point_id');
  de;

  l('');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');

  l('    l_match_str := ''' || l_match_str || ''';');
  l('    IF p_match_type = ''AND'' THEN');
  l('      l_match_str := '' AND '';');
  l('    ELSIF p_match_type = ''OR'' THEN');
  l('      l_match_str := '' OR '';');
  l('    END IF;');
  l('SAVEPOINT get_matching_contact_points ;');
  l('    l_entered_max_score:= init_search(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC, ');
  l('       HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST, HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,');
  l('       p_contact_point_list,l_match_str, l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');
  l('');
  l('    l_contact_pt_contains_str := check_cpts_bulk (p_contact_point_list);');
  l('    init_score_context(HZ_PARTY_SEARCH.G_MISS_PARTY_SEARCH_REC,HZ_PARTY_SEARCH.G_MISS_PARTY_SITE_LIST,HZ_PARTY_SEARCH.G_MISS_CONTACT_LIST,p_contact_point_list);');

  l('');
  l('    -- Setup Search Context ID');
  l('    SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('    x_search_ctx_id := l_search_ctx_id;');

  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'l_match_str','l_match_str');
  dc(fnd_log.level_statement,'l_contact_pt_contains_str','l_contact_pt_contains_str');
  dc(fnd_log.level_statement,'l_search_ctx_id','l_search_ctx_id');
  de;

  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('      open_contact_pt_cursor(NULL, P_PARTY_ID, p_restrict_sql, l_contact_pt_contains_str,NULL,l_contact_pt_cur);');
  l('      cnt := 1;');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('        IF (p_dup_contact_point_id IS NULL OR (');
  l('               p_dup_contact_point_id IS NOT NULL AND ');
  l('               l_cpt_ps_id IS NULL AND l_cpt_contact_id IS NULL AND ');
  l('               p_dup_contact_point_id <>  l_contact_pt_id)) THEN   ');
  l('            H_CONTACT_POINT_ID(cnt) := l_contact_pt_id;');
  l('            H_PARTY_ID(cnt) := l_cpt_party_id;');
  l('            H_SCORE(cnt) := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('            cnt := cnt+1;');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Contact Point Matches');
  dc(fnd_log.level_statement,'l_contact_pt_id','l_contact_pt_id');
  dc(fnd_log.level_statement,'l_score','l_score');
  de;

  l('        END IF; ');
  l('      END LOOP;');
  l('      CLOSE l_contact_pt_cur;');

  d(fnd_log.level_statement,'Evaluating Matches. Threshold : '||round((l_match_threshold/l_max_score)*100));
  l('ROLLBACK to get_matching_contact_points ;');
  l('      x_num_matches := 0; ');
  l('      FOR I in 1..H_CONTACT_POINT_ID.COUNT LOOP');
  ds(fnd_log.level_statement);
  dc(fnd_log.level_statement,'Match Contact Point ID','H_CONTACT_POINT_ID(I)');
  dc(fnd_log.level_statement,'Score','round((H_SCORE(I)/l_entered_max_score)*100)');
  de;
  l('        IF (H_SCORE(I)/l_entered_max_score)>=('||l_match_threshold||'/'||l_max_score||') THEN');
  l('        INSERT INTO HZ_MATCHED_CPTS_GT(SEARCH_CONTEXT_ID,CONTACT_POINT_ID,PARTY_ID,SCORE) VALUES (');
  l('            l_search_ctx_id,H_CONTACT_POINT_ID(I),H_PARTY_ID(I),round(H_SCORE(I)/l_entered_max_score)*100);');
  l('            x_num_matches := x_num_matches + 1; ');
  l('        END IF;');
  l('      END LOOP; ');
  l('    END IF;');

  d(fnd_log.level_procedure,'get_matching_contact_points(-)');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    ROLLBACK to get_matching_contact_points ;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    ROLLBACK to get_matching_contact_points ;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    ROLLBACK to get_matching_contact_points ;');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_matching_contact_points'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_matching_contact_points;');

  l('');
  l('   /**********************************************************');
  l('   This procedure finds the score details for a specific party that ');
  l('   matched ');
  l('');
  l('   **********************************************************/');
  l('');
  l('PROCEDURE get_score_details (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('        p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('        x_search_ctx_id         IN OUT  NUMBER');
  l(') IS');
  l('');
  l('  -- Strings to hold the generated Intermedia query strings');
  l('  l_party_contains_str VARCHAR2(32000); ');
  l('  l_party_site_contains_str VARCHAR2(32000);');
  l('  l_contact_contains_str VARCHAR2(32000);');
  l('  l_contact_pt_contains_str VARCHAR2(32000);');
  l('  l_tmp VARCHAR2(32000);');
  l('');
  l('  -- Other local variables');
  l('  l_match_str VARCHAR2(30); -- Match type (AND or OR)');
  l('  -- For Score calculation');
  l('  l_max_score NUMBER;');
  l('  l_entered_max_score NUMBER;');
  l('  FIRST BOOLEAN;');
  l('  l_search_ctx_id NUMBER; -- Generated Search Context ID');
  l('');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.attribute_id = sa.attribute_id) LOOP
    l('  l_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
    l('  l_max_'||TX.staged_attribute_column ||' VARCHAR2(2000);');
  END LOOP;
  l('  H_SCORES HZ_PARTY_SEARCH.score_list;');
  l('');
  l('  l_score NUMBER;');
  l('  l_match_idx NUMBER;');
  l('  l_idx NUMBER;');
  l('  l_party_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_site_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_contact_pt_cur HZ_PARTY_STAGE.StageCurTyp;');
  l('  l_party_id NUMBER;');
  l('  l_ps_party_id NUMBER;');
  l('  l_ct_party_id NUMBER;');
  l('  l_cpt_party_id NUMBER;');
  l('  l_cpt_ps_id NUMBER;');
  l('  l_cpt_contact_id NUMBER;');
  l('  l_party_site_id NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  l_contact_pt_id NUMBER;');
  l('  l_ps_contact_id NUMBER;');
  l('  l_max_id NUMBER;');
  l('  l_max_idx NUMBER;');
  l('');
  l('  l_index NUMBER;');
  l('  l_party_max_score NUMBER;');
  l('  l_ps_max_score NUMBER;');
  l('  l_contact_max_score NUMBER;');
  l('  l_cpt_max_score NUMBER;');
  l('');
  l('  ');
  l('  BEGIN');
  l('');

  d(fnd_log.level_statement,'get_score_details(+)');
  l('    -- ************************************');
  l('    -- STEP 1. Initialization and error checks');
  l('');
  l('    l_entered_max_score:= init_search(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list,'' OR '', l_party_max_score, l_ps_max_score, l_contact_max_score, l_cpt_max_score);');
  l('    g_score_until_thresh := false;');
  l('    IF l_entered_max_score = 0 THEN l_entered_max_score:=1; END IF;');

  l('    l_party_site_contains_str := check_party_sites_bulk (p_party_site_list);');
  l('    l_contact_contains_str := check_contacts_bulk (p_contact_list);');
  l('    l_contact_pt_contains_str := check_cpts_bulk (p_contact_point_list);');

  l('    init_score_context(p_party_search_rec,p_party_site_list,p_contact_list,p_contact_point_list);');
  l('');
  l('    -- Setup Search Context ID');
  l('    IF x_search_ctx_id IS NULL THEN');
  l('      SELECT hz_search_ctx_s.nextval INTO l_search_ctx_id FROM dual;');
  l('      x_search_ctx_id := l_search_ctx_id;');
  l('    ELSE');
  l('      l_search_ctx_id := x_search_ctx_id;');
  l('    END IF;');
  l('');
  l('    open_party_cursor(p_party_id, null, null,null,null,null,l_party_cur);');
  l('    LOOP ');
  l('        FETCH l_party_cur INTO');
  l('           l_party_id '||l_p_into_list||';');
  l('        EXIT WHEN l_party_cur%NOTFOUND;');
  IF l_p_param_list IS NOT NULL THEN
    l('          INSERT_PARTY_SCORE(p_party_id, p_party_id, l_search_ctx_id, p_party_search_rec, g_party_stage_rec, '||l_p_param_list||',1);');
  END IF;
  l('    END LOOP;');
  l('    CLOSE l_party_cur;');
  l('');
  l('    IF l_party_site_contains_str IS NOT NULL THEN');
  l('      l_max_score := 0;');
  l('      l_max_id := 0;');
  l('      l_max_idx := 0;');
  l('      open_party_site_cursor(null, p_party_id, null, l_party_site_contains_str,NULL,l_party_site_cur);');
  l('      LOOP');
  l('        FETCH l_party_site_cur INTO ');
  l('            l_party_site_id, l_ps_party_id,l_ps_contact_id '||l_ps_into_list||';');
  l('        EXIT WHEN l_party_site_cur%NOTFOUND;');
  l('        l_score := GET_PARTY_SITES_SCORE(l_match_idx'||l_ps_param_list||');');
  l('        IF l_score > l_max_score THEN');
  l('          l_max_score := l_score;');
  l('          l_max_id := l_party_site_id;');
  l('          l_max_idx := l_match_idx;');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.entity_name = 'PARTY_SITES'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('          l_max_'||TX.staged_attribute_column ||' := l_'||TX.staged_attribute_column ||';');
  END LOOP;
  l('        END IF;');
  l('      END LOOP;');
  l('      CLOSE l_party_site_cur;');
  l('      IF l_max_score>0 THEN');
  l('        INSERT_PARTY_SITES_SCORE(p_party_id,l_max_id,l_search_ctx_id, p_party_site_list(l_max_idx), g_party_site_stage_list(l_max_idx) '||replace(l_ps_param_list,'l_TX','l_max_TX')||',l_max_idx);');
  l('      END IF;');
  l('    END IF;');
  l('');
  l('    IF l_contact_contains_str IS NOT NULL THEN');
  l('      l_max_score := 0;');
  l('      l_max_id := 0;');
  l('      l_max_idx := 0;');
  l('      open_contact_cursor(null, p_party_id, null, l_contact_contains_str,NULL,l_contact_cur);');
  l('      LOOP');
  l('        FETCH l_contact_cur INTO ');
  l('            l_org_contact_id, l_ct_party_id '||l_c_into_list||';');
  l('        EXIT WHEN l_contact_cur%NOTFOUND;');
  l('        l_score := GET_CONTACTS_SCORE(l_match_idx'||l_c_param_list||');');
  l('        IF l_score > l_max_score THEN');
  l('          l_max_score := l_score;');
  l('          l_max_id := l_org_contact_id;');
  l('          l_max_idx := l_match_idx;');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.entity_name = 'CONTACTS'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('          l_max_'||TX.staged_attribute_column ||' := l_'||TX.staged_attribute_column ||';');
  END LOOP;
  l('        END IF;');
  l('      END LOOP;');
  l('      CLOSE l_contact_cur;');
  l('      IF l_max_score>0 THEN');
  l('        INSERT_CONTACTS_SCORE(p_party_id,l_max_id,l_search_ctx_id, p_contact_list(l_max_idx), g_contact_stage_list(l_max_idx) '||replace(l_c_param_list,'l_TX','l_max_TX')||',l_max_idx);');
  l('      END IF;');
  l('    END IF;');
  l('');
  l('    IF l_contact_pt_contains_str IS NOT NULL THEN');
  l('      l_max_score := 0;');
  l('      l_max_id := 0;');
  l('      l_max_idx := 0;');
  l('      open_contact_pt_cursor(null, p_party_id, null, l_contact_pt_contains_str,NULL,l_contact_pt_cur);');
  l('      LOOP');
  l('        FETCH l_contact_pt_cur INTO ');
  l('            l_contact_pt_id, l_cpt_party_id, l_cpt_ps_id, l_cpt_contact_id '||l_cpt_into_list||';');
  l('        EXIT WHEN l_contact_pt_cur%NOTFOUND;');
  l('        l_score := GET_CONTACT_POINTS_SCORE(l_match_idx'||l_cpt_param_list||');');
  l('        IF l_score > l_max_score THEN');
  l('          l_max_score := l_score;');
  l('          l_max_id := l_contact_pt_id;');
  l('          l_max_idx := l_match_idx;');
  FOR TX IN (
      SELECT distinct f.staged_attribute_column
      FROM hz_trans_functions_vl f, hz_secondary_trans st,
           hz_match_rule_secondary sa, HZ_TRANS_ATTRIBUTES_VL a
      WHERE sa.match_rule_id = p_rule_id
      AND st.SECONDARY_ATTRIBUTE_ID = sa.SECONDARY_ATTRIBUTE_ID
      AND st.function_id = f.function_id
      AND a.entity_name = 'CONTACT_POINTS'
      AND a.attribute_id = sa.attribute_id) LOOP
    l('          l_max_'||TX.staged_attribute_column ||' := l_'||TX.staged_attribute_column ||';');
  END LOOP;
  l('        END IF;');
  l('      END LOOP;');
  l('      IF l_max_score>0 THEN');
  l('        INSERT_CONTACT_POINTS_SCORE(p_party_id,l_max_id,l_search_ctx_id, p_contact_point_list(l_max_idx), g_contact_pt_stage_list(l_max_idx) '||replace(l_cpt_param_list,'l_TX','l_max_TX')||',l_max_idx);');
  l('      END IF;');
  l('      CLOSE l_contact_pt_cur;');
  l('    END IF;');
  l(' --------------- DELETE FROM ALL SRCH TABLES ---------------------');
  l('    DELETE FROM HZ_SRCH_PARTIES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_PSITES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CONTACTS WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CPTS WHERE batch_id = -1 ;');
  d(fnd_log.level_procedure,'get_score_details(-)');


  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l(' --------------- DELETE FROM ALL SRCH TABLES ---------------------');
  l('    DELETE FROM HZ_SRCH_PARTIES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_PSITES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CONTACTS WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CPTS WHERE batch_id = -1 ;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l(' --------------- DELETE FROM ALL SRCH TABLES ---------------------');
  l('    DELETE FROM HZ_SRCH_PARTIES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_PSITES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CONTACTS WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CPTS WHERE batch_id = -1 ;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l(' --------------- DELETE FROM ALL SRCH TABLES ---------------------');
  l('    DELETE FROM HZ_SRCH_PARTIES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_PSITES WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CONTACTS WHERE batch_id = -1 ;');
  l('    DELETE FROM HZ_SRCH_CPTS WHERE batch_id = -1 ;');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'','''||p_pkg_name||'.get_score_details'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_score_details;');
  l('');

  generate_acquire_proc(p_rule_id, 'Q');


  generate_party_map_proc_bulk('MAP_PARTY_REC', p_rule_id);
  l('');
  generate_map_proc_bulk('PARTY_SITES', 'MAP_PARTY_SITE_REC', p_rule_id);
  l('');
  generate_map_proc_bulk('CONTACTS', 'MAP_CONTACT_REC', p_rule_id);
  l('');
  generate_map_proc_bulk('CONTACT_POINTS', 'MAP_CONTACT_POINT_REC', p_rule_id);
  l('');
  generate_check_proc(p_rule_id);


  generate_check_staged (p_rule_id);
  /*l('  PROCEDURE enable_debug IS');

  l('  BEGIN');
  l('    g_debug_count := g_debug_count + 1;');

  l('    IF g_debug_count = 1 THEN');
  l('      IF fnd_profile.value(''HZ_API_FILE_DEBUG_ON'') = ''Y'' OR');
  l('         fnd_profile.value(''HZ_API_DBMS_DEBUG_ON'') = ''Y''');
  l('      THEN');
  l('        hz_utility_v2pub.enable_debug;');
  l('        g_debug := TRUE;');
  d('PKG: '||p_pkg_name||' (+)');
  l('      END IF;');
  l('    END IF;');
  l('  END enable_debug;');

  l('  PROCEDURE disable_debug IS');

  l('  BEGIN');

  l('    IF g_debug THEN');
  l('      g_debug_count := g_debug_count - 1;');

  l('      IF g_debug_count = 0 THEN');
  d('PKG: '||p_pkg_name||' (-)');
  l('        hz_utility_v2pub.disable_debug;');
  l('        g_debug := FALSE;');
  l('      END IF;');
  l('    END IF;');

  l('  END disable_debug;');
  */

  l('END;');
  l('');
END gen_pkg_body_bulk ;







FUNCTION has_trx_context(proc VARCHAR2) RETURN BOOLEAN IS

  l_sql VARCHAR2(255);
  l_entity VARCHAR2(255);
  l_procedure VARCHAR2(255);
  l_attribute VARCHAR2(255);
  c NUMBER;
  n NUMBER;
  l_custom BOOLEAN;

BEGIN
  c := dbms_sql.open_cursor;
  l_sql := 'select ' || proc ||
           '(:attrval,:lang,:attr,:entity,:ctx) from dual';
  dbms_sql.parse(c,l_sql,2);
  DBMS_SQL.BIND_VARIABLE(c,':attrval','x');
  DBMS_SQL.BIND_VARIABLE(c,':lang','x');
  DBMS_SQL.BIND_VARIABLE(c,':attr','x');
  DBMS_SQL.BIND_VARIABLE(c,':entity','x');
  DBMS_SQL.BIND_VARIABLE(c,':ctx','x');
  n:=DBMS_SQL.execute(c);
  dbms_sql.close_cursor(c);
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    dbms_sql.close_cursor(c);
    RETURN FALSE;
END;

--VJN Introduced for Bulk Match Rules
PROCEDURE generate_party_map_proc_bulk (
   p_proc_name          IN      VARCHAR2,
   p_rule_id            IN      NUMBER
) IS

  NONE BOOLEAN := TRUE;
  trxctx BOOLEAN := FALSE;
  INSERT_TRFNS varchar2(32000);
  INSERT_TRFN_VALUES varchar2(32000);

BEGIN

  l('');
  l('/************************************************');
  l('  This procedure maps a search record from the logical');
  l('  record structure to the stage schema structure ');
  l('  for the PARTY Entity after applying ');
  l('  the defined transformations');
  l('************************************************/');
  l('');
  l('PROCEDURE ' || p_proc_name || '( ');
  l('    p_search_ctx IN BOOLEAN,');
  l('    p_search_rec IN HZ_PARTY_SEARCH.party_search_rec_type, ');
  l('    x_entered_max_score OUT NUMBER,');
  l('    x_stage_rec IN OUT NOCOPY HZ_PARTY_STAGE.party_stage_rec_type');
  l('  ) IS ');
  l('  tmp VARCHAR2(4000);');
  l('BEGIN');
  ldbg_s('Inside Calling Procedure - '||p_proc_name);
  l('   IF p_search_ctx THEN');
  l('     x_entered_max_score:=0;');
  for SECATTRS IN (
        SELECT a.ATTRIBUTE_NAME, SCORE
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY') LOOP
    l('    IF p_search_rec.'||SECATTRS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      x_entered_max_score := x_entered_max_score+'||SECATTRS.SCORE||';');
    l('    END IF;');
  END LOOP;
  l('    END IF;');

  for FUNCS IN (
        SELECT a.ATTRIBUTE_NAME,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY pattr,
             HZ_PRIMARY_TRANS pfunc
        WHERE pattr.MATCH_RULE_ID = p_rule_id
        AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY'
        AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
        AND pfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.ATTRIBUTE_NAME,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr,
             HZ_SECONDARY_TRANS sfunc
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY'
        AND sattr.SECONDARY_ATTRIBUTE_ID = sfunc.SECONDARY_ATTRIBUTE_ID
        AND sfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.attribute_name,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
            HZ_TRANS_ATTRIBUTES_VL a
        WHERE f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.entity_name = 'PARTY'
        AND a.attribute_name='PARTY_TYPE'
        AND f.PROCEDURE_NAME='HZ_TRANS_PKG.EXACT'
        AND nvl(f.active_flag,'Y')='Y'
        AND ROWNUM=1
  )
  LOOP
    NONE := FALSE;
    trxctx := has_trx_context(FUNCS.PROCEDURE_NAME);
    l('  IF p_search_ctx THEN');
    l('    IF p_search_rec.'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
    l('        ' || FUNCS.PROCEDURE_NAME ||'(');
    l('             p_search_rec.'||FUNCS.ATTRIBUTE_NAME);
    l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
    IF trxctx THEN
      l('             ,''PARTY'','''||g_context||''');');
    ELSE
      l('             ,''PARTY'');');
    END IF;
    l('    ELSE');
    l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := '''';');
    l('    END IF;');
    IF NOT trxctx THEN
      l('  END IF;');
    ELSE
      l('  ELSE');
      l('    IF p_search_rec.'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
      l('      tmp :=' || FUNCS.PROCEDURE_NAME ||'(');
      l('             x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN);
      l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
      l('             ,''PARTY'',''SCORE'');');
      l('      IF tmp IS NOT NULL THEN');
      l('        x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := tmp;');
      l('      END IF;');
      l('    END IF;');
      l('  END IF;');
    END IF;
    INSERT_TRFNS := INSERT_TRFNS ||','||FUNCS.STAGED_ATTRIBUTE_COLUMN;
    INSERT_TRFN_VALUES := INSERT_TRFN_VALUES ||','||'x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN;
  END LOOP;

  IF NOT NONE THEN
     l('IF p_search_ctx THEN');
     l('     insert into HZ_SRCH_PARTIES(batch_id,party_id, party_osr,party_os' || INSERT_TRFNS
                     || ')'||' values(-1,-1,-1,-1'|| INSERT_TRFN_VALUES ||');');
     l('END IF;');
  END IF;

  IF NONE THEN
    l('  NULL;');
  END IF;


  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_TRANSFORM_PROC_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'' , ''' || p_proc_name || ''');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END;');

END generate_party_map_proc_bulk ;

PROCEDURE generate_map_proc (
   p_entity             IN      VARCHAR2,
   p_proc_name          IN      VARCHAR2,
   p_rule_id		IN      NUMBER
) IS

  NONE BOOLEAN := TRUE;
  trxctx BOOLEAN := FALSE;
BEGIN

  l('');
  l('/************************************************');
  l('  This procedure maps a search record from the logical');
  l('  record structure to the stage schema structure ');
  l('  for the '||p_entity || ' Entity after applying ');
  l('  the defined transformations');
  l('************************************************/');
  l('');
  l('PROCEDURE ' || p_proc_name || '( ');
  l('    p_search_ctx IN BOOLEAN,');
  IF p_entity = 'PARTY_SITES' THEN
    l('    p_search_list IN HZ_PARTY_SEARCH.party_site_list, ');
    l('    x_entered_max_score OUT NUMBER,');
    l('    x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.party_site_stage_list');
    l('  ) IS ');
  ELSIF p_entity = 'CONTACTS' THEN
    l('    p_search_list IN HZ_PARTY_SEARCH.contact_list, ');
    l('    x_entered_max_score OUT NUMBER,');
    l('    x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_stage_list');
    l('  ) IS ');
  ELSIF p_entity = 'CONTACT_POINTS' THEN
    l('    p_search_list IN HZ_PARTY_SEARCH.contact_point_list, ');
    l('    x_entered_max_score OUT NUMBER,');
    l('    x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_pt_stage_list');
    l('  ) IS ');
  END IF;
  l('  l_current_max_score NUMBER;');
  l('  tmp VARCHAR2(4000);');
  if l_purpose IN ('S','W') AND p_entity = 'CONTACT_POINTS' then
    l('  TYPE INDEX_VARCHAR100_TBL IS TABLE OF NUMBER INDEX BY VARCHAR2(100);');
    l('  l_cnt_pt_type_index INDEX_VARCHAR100_TBL;');

    l('  TYPE CONTACT_PT_REC_TYPE IS RECORD (');
    l('  contact_pt_type		VARCHAR2(100),');
    l('  max_score    		NUMBER) ;');

    l('  TYPE contact_pt_list IS TABLE of CONTACT_PT_REC_TYPE INDEX BY BINARY_INTEGER;');
    l('  l_cnt_pt_type contact_pt_list;');

    l('  N NUMBER := 1;');
    l('  x_modify VARCHAR2(1);');
  end if;
  l('BEGIN');
  ldbg_s('Inside Calling Procedure - '||p_proc_name);
  ldbg_s('p_entity - '||p_entity);
  l('  IF p_search_ctx THEN');
  IF p_entity = 'PARTY_SITES' THEN
    l('   g_ps_den_only:=TRUE;');
  END IF;
  l('    x_entered_max_score:=0;');
  l('    FOR I IN 1..p_search_list.COUNT LOOP');
  l('      l_current_max_score:=0;');
  IF p_entity = 'CONTACT_POINTS' THEN
    l('      x_stage_list(I).CONTACT_POINT_TYPE := p_search_list(I).CONTACT_POINT_TYPE;');
  END IF;
  for SECATTRS IN (
        SELECT a.ATTRIBUTE_NAME, SCORE, nvl(a.denorm_flag,'N') DENORM_FLAG
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity) LOOP
    l('      IF p_search_list(I).'||SECATTRS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('        l_current_max_score := l_current_max_score+'||SECATTRS.SCORE||';');
    IF p_entity = 'PARTY_SITES' AND SECATTRS.DENORM_FLAG='N' THEN
      l('        g_ps_den_only:=FALSE;');
    END IF;

    l('      END IF;');

  END LOOP;
if l_purpose  IN ('S','W') AND p_entity = 'CONTACT_POINTS' then
       l('      x_modify := ''N'';');
        l('      FOR J IN 1..l_cnt_pt_type.count LOOP');
          l('      if (l_cnt_pt_type(J).contact_pt_type = x_stage_list(I).CONTACT_POINT_TYPE) then');
 	  l('         x_modify := ''Y'';');
            l('      IF l_cnt_pt_type(J).max_score<l_current_max_score THEN');
                l('      l_cnt_pt_type(J).max_score :=l_current_max_score;');
                l('      EXIT;');
            l('      END IF;');
          l('      end if;');
        l('      END LOOP;');
        l('      if x_modify=''N'' then');
            l('      l_cnt_pt_type(N).contact_pt_type := x_stage_list(I).CONTACT_POINT_TYPE;');
            l('      l_cnt_pt_type(N).max_score := l_current_max_score;');
            l('      N:= N+1;');
        l('      end if;');

   else
  l('      IF l_current_max_score>x_entered_max_score THEN');
  l('        x_entered_max_score:=l_current_max_score;');
  l('      END IF;');
  end if;

  l('    END LOOP;');
  if l_purpose  IN ('S','W') AND p_entity = 'CONTACT_POINTS' then
      l('   FOR M IN 1..l_cnt_pt_type.count LOOP');
        l('   x_entered_max_score := x_entered_max_score+l_cnt_pt_type(M).max_score;');
    l('   END LOOP;');
  end if;
  l('  END IF;');


  for FUNCS IN (
        SELECT a.ATTRIBUTE_NAME,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY pattr,
             HZ_PRIMARY_TRANS pfunc
        WHERE pattr.MATCH_RULE_ID = p_rule_id
        AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity
        AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
        AND pfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.ATTRIBUTE_NAME,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr,
             HZ_SECONDARY_TRANS sfunc
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity
        AND sattr.SECONDARY_ATTRIBUTE_ID = sfunc.SECONDARY_ATTRIBUTE_ID
        AND sfunc.FUNCTION_ID = f.FUNCTION_ID
  )
  LOOP
    NONE := FALSE;
    l('  FOR I IN 1..p_search_list.COUNT LOOP');
    l('    IF p_search_ctx THEN');
    trxctx := has_trx_context(FUNCS.PROCEDURE_NAME);
    l('      IF p_search_list(I).'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('        x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
    l('          ' || FUNCS.PROCEDURE_NAME ||'(');
    l('             p_search_list(I).'||FUNCS.ATTRIBUTE_NAME);
    l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
    IF NOT trxctx THEN
      l('             ,''' ||p_entity||''');');
    ELSE
      l('             ,''' ||p_entity||''','''||g_context||''');');
    END IF;
    l('      ELSE');
    l('        x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := '''';');
    l('      END IF;');
    IF NOT trxctx THEN
      l('    END IF;');
    ELSE
      l('    ELSE');
      l('      IF p_search_list(I).'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
      l('        tmp := ' || FUNCS.PROCEDURE_NAME ||'(');
      l('             x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN);
      l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
      l('             ,''' ||p_entity||''',''SCORE'');');
      l('        IF tmp IS NOT NULL THEN');
      l('          x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := tmp;');
      l('        END IF;');
      l('      END IF;');
      l('    END IF;');
    END IF;
    l('  END LOOP;');
  END LOOP;
  IF NONE THEN
    l('  NULL;');
  END IF;

  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_TRANSFORM_PROC_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'' , ''' || p_proc_name || ''');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END;');

END generate_map_proc;


-- VJN INTRODUCED CODE FOR GENERATING THE POPULATION
 -- OF THE GLOBAL CONDITION RECORD FOR REGULAR MATCH RULES

PROCEDURE generate_ent_cond_pop_rec_proc (
   p_entity             IN      VARCHAR2,
   p_rule_id		IN      NUMBER
) IS

 p_proc_name VARCHAR2(200);
 NONE BOOLEAN := TRUE;


 BEGIN

  p_proc_name := 'POP_'||p_entity||'_COND_REC';
  l('');
  l('/************************************************');
  l('  This procedure populates global cond record');
  l('  for the '||p_entity || ' Entity ');
  l('************************************************/');
  l('');
  l('PROCEDURE ' || p_proc_name||'(');
    IF p_entity = 'PARTY' THEN
      l('    p_search_rec IN HZ_PARTY_SEARCH.party_search_rec_type ');
      l('  ) IS ');
    ELSIF p_entity = 'PARTY_SITES' THEN
      l('    p_search_list IN HZ_PARTY_SEARCH.party_site_list ');
      l('  ) IS ');
    ELSIF p_entity = 'CONTACTS' THEN
      l('    p_search_list IN HZ_PARTY_SEARCH.contact_list ');
      l('  ) IS ');
    ELSIF p_entity = 'CONTACT_POINTS' THEN
      l('    p_search_list IN HZ_PARTY_SEARCH.contact_point_list ');
      l('  ) IS ');
  END IF;

  l('BEGIN');

  for FUNCS IN (
        SELECT a.ATTRIBUTE_ID, a.ATTRIBUTE_NAME
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY pattr,
             HZ_PRIMARY_TRANS pfunc
        WHERE pattr.MATCH_RULE_ID = p_rule_id
        AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity
        AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
        AND pfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.ATTRIBUTE_ID, a.ATTRIBUTE_NAME
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr,
             HZ_SECONDARY_TRANS sfunc
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity
        AND sattr.SECONDARY_ATTRIBUTE_ID = sfunc.SECONDARY_ATTRIBUTE_ID
        AND sfunc.FUNCTION_ID = f.FUNCTION_ID
  )
  LOOP
     IF HZ_WORD_CONDITIONS_PKG.is_a_cond_attrib( FUNCS.attribute_id)
     THEN
        NONE := FALSE ;
        l('---------POPULATE THE GLOBAL WORD CONDITION REC FOR ' || p_entity || '-------------');
        IF p_entity = 'PARTY'
	    THEN

            l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||FUNCS.attribute_id||','||'p_search_rec.'||FUNCS.attribute_name||');');

	    ELSE
            l('------ Populate global condition record only if search list is not empty -----------');
            l(' IF p_search_list.COUNT > 0');
            l(' THEN') ;
		    l('     HZ_WORD_CONDITIONS_PKG.set_gbl_condition_rec ('||FUNCS.attribute_id||','||'p_search_list(1).'||FUNCS.attribute_name||');');
            l('END IF ;');
	    END IF;
     END IF ;
  END LOOP;

  IF NONE
  THEN
    l( 'NULL ;');
  END IF ;

  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_TRANSFORM_PROC_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'' , ''' || p_proc_name || ''');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END;');

END ;

PROCEDURE generate_map_proc_bulk (
   p_entity             IN      VARCHAR2,
   p_proc_name          IN      VARCHAR2,
   p_rule_id		IN      NUMBER
) IS

  NONE BOOLEAN := TRUE;
  trxctx BOOLEAN := FALSE;
  INSERT_TRFNS varchar2(32000);
  INSERT_TRFN_VALUES varchar2(32000);
BEGIN

  l('');
  l('/************************************************');
  l('  This procedure maps a search record from the logical');
  l('  record structure to the stage schema structure ');
  l('  for the '||p_entity || ' Entity after applying ');
  l('  the defined transformations');
  l('************************************************/');
  l('');
  l('PROCEDURE ' || p_proc_name || '( ');
  l('    p_search_ctx IN BOOLEAN,');
  IF p_entity = 'PARTY_SITES' THEN
    l('    p_search_list IN HZ_PARTY_SEARCH.party_site_list, ');
    l('    x_entered_max_score OUT NUMBER,');
    l('    x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.party_site_stage_list');
    l('  ) IS ');
  ELSIF p_entity = 'CONTACTS' THEN
    l('    p_search_list IN HZ_PARTY_SEARCH.contact_list, ');
    l('    x_entered_max_score OUT NUMBER,');
    l('    x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_stage_list');
    l('  ) IS ');
  ELSIF p_entity = 'CONTACT_POINTS' THEN
    l('    p_search_list IN HZ_PARTY_SEARCH.contact_point_list, ');
    l('    x_entered_max_score OUT NUMBER,');
    l('    x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_pt_stage_list');
    l('  ) IS ');
  END IF;
  l('  l_current_max_score NUMBER;');
  l('  tmp VARCHAR2(4000);');
  l('BEGIN');
  ldbg_s('Inside Calling Procedure - '||p_proc_name);
  ldbg_s('p_entity - '||p_entity);
  l('  IF p_search_ctx THEN');
  l('    x_entered_max_score:=0;');
  l('    FOR I IN 1..p_search_list.COUNT LOOP');
  l('      l_current_max_score:=0;');
  IF p_entity = 'CONTACT_POINTS' THEN
    l('      x_stage_list(I).CONTACT_POINT_TYPE := p_search_list(I).CONTACT_POINT_TYPE;');
  END IF;
  for SECATTRS IN (
        SELECT a.ATTRIBUTE_NAME, SCORE
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity) LOOP
    l('      IF p_search_list(I).'||SECATTRS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('        l_current_max_score := l_current_max_score+'||SECATTRS.SCORE||';');
    l('      END IF;');
  END LOOP;
  l('      IF l_current_max_score>x_entered_max_score THEN');
  l('        x_entered_max_score:=l_current_max_score;');
  l('      END IF;');
  l('    END LOOP;');
  l('  END IF;');

  for FUNCS IN (
        SELECT a.ATTRIBUTE_NAME,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY pattr,
             HZ_PRIMARY_TRANS pfunc
        WHERE pattr.MATCH_RULE_ID = p_rule_id
        AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity
        AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
        AND pfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.ATTRIBUTE_NAME,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr,
             HZ_SECONDARY_TRANS sfunc
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = p_entity
        AND sattr.SECONDARY_ATTRIBUTE_ID = sfunc.SECONDARY_ATTRIBUTE_ID
        AND sfunc.FUNCTION_ID = f.FUNCTION_ID
  )
  LOOP
    NONE := FALSE;
    l('  FOR I IN 1..p_search_list.COUNT LOOP');
    l('    IF p_search_ctx THEN');
    trxctx := has_trx_context(FUNCS.PROCEDURE_NAME);
    l('      IF p_search_list(I).'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('        x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
    l('          ' || FUNCS.PROCEDURE_NAME ||'(');
    l('             p_search_list(I).'||FUNCS.ATTRIBUTE_NAME);
    l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
    IF NOT trxctx THEN
      l('             ,''' ||p_entity||''');');
    ELSE
      l('             ,''' ||p_entity||''','''||g_context||''');');
    END IF;
    l('      ELSE');
    l('        x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := '''';');
    l('      END IF;');
    IF NOT trxctx THEN
      l('    END IF;');
    ELSE
      l('    ELSE');
      l('      IF p_search_list(I).'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
      l('        tmp := ' || FUNCS.PROCEDURE_NAME ||'(');
      l('             x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN);
      l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
      l('             ,''' ||p_entity||''',''SCORE'');');
      l('        IF tmp IS NOT NULL THEN');
      l('          x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := tmp;');
      l('        END IF;');
      l('      END IF;');
      l('    END IF;');
    END IF;
    l('  END LOOP;');
  END LOOP;

  -- VJN : For inserting into the Search Tables
   IF NOT NONE THEN

               for FUNCS IN (
                    SELECT a.ATTRIBUTE_NAME,
                           f.PROCEDURE_NAME,
                           f.STAGED_ATTRIBUTE_COLUMN
                    FROM HZ_TRANS_FUNCTIONS_VL f,
                         HZ_TRANS_ATTRIBUTES_VL a,
                         HZ_MATCH_RULE_PRIMARY pattr,
                         HZ_PRIMARY_TRANS pfunc
                    WHERE pattr.MATCH_RULE_ID = p_rule_id
                    AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
                    AND a.ENTITY_NAME = p_entity
                    AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
                    AND pfunc.FUNCTION_ID = f.FUNCTION_ID

                    UNION

                    SELECT a.ATTRIBUTE_NAME,
                           f.PROCEDURE_NAME,
                           f.STAGED_ATTRIBUTE_COLUMN
                    FROM HZ_TRANS_FUNCTIONS_VL f,
                         HZ_TRANS_ATTRIBUTES_VL a,
                         HZ_MATCH_RULE_SECONDARY sattr,
                         HZ_SECONDARY_TRANS sfunc
                    WHERE sattr.MATCH_RULE_ID = p_rule_id
                    AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
                    AND a.ENTITY_NAME = p_entity
                    AND sattr.SECONDARY_ATTRIBUTE_ID = sfunc.SECONDARY_ATTRIBUTE_ID
                    AND sfunc.FUNCTION_ID = f.FUNCTION_ID
              )
              LOOP

                NONE := FALSE;
                INSERT_TRFNS := INSERT_TRFNS ||','||FUNCS.STAGED_ATTRIBUTE_COLUMN;
                INSERT_TRFN_VALUES := INSERT_TRFN_VALUES ||','||'x_stage_list(I).'||FUNCS.STAGED_ATTRIBUTE_COLUMN;

              END LOOP;

              IF p_entity = 'PARTY_SITES'
                THEN
                    l('IF p_search_ctx THEN');
                    l('  FOR I IN 1..p_search_list.COUNT LOOP');
                    l('               insert into HZ_SRCH_PSITES(batch_id,party_id, party_osr,party_os, party_site_id,party_site_osr, party_site_os,new_party_flag ' || INSERT_TRFNS
                     ||               ')'||' values(-1,-1,-1,-1,-1,-1,-1,''Y'''|| INSERT_TRFN_VALUES ||');');
                    l('  END LOOP;');
                    l('END IF;');
                END IF;

                IF p_entity = 'CONTACTS'
                THEN
                    l('IF p_search_ctx THEN');
                    l('  FOR I IN 1..p_search_list.COUNT LOOP');
                    l('              insert into HZ_SRCH_CONTACTS(batch_id,party_id, party_osr,party_os, org_contact_id,contact_osr, contact_os,new_party_flag ' || INSERT_TRFNS
                     ||              ')'||' values(-1,-1,-1,-1,-1,-1,-1,''Y'''|| INSERT_TRFN_VALUES ||');');
                    l('  END LOOP;');
                    l('END IF;');
                END IF;

                IF p_entity = 'CONTACT_POINTS'
                THEN
                    l('IF p_search_ctx THEN');
                    l('  FOR I IN 1..p_search_list.COUNT LOOP');
                    l('              insert into HZ_SRCH_CPTS(batch_id,party_id, party_osr,party_os, contact_point_id,contact_pt_osr, contact_pt_os,contact_point_type,new_party_flag ' || INSERT_TRFNS
                     ||              ')'||' values(-1,-1,-1,-1,-1,-1,-1,-1,''Y'''|| INSERT_TRFN_VALUES ||');');
                    l('  END LOOP;');
                    l('END IF; ');
                END IF;
  END IF;

  IF NONE THEN
    l('  NULL;');
  END IF;

  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_TRANSFORM_PROC_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'' , ''' || p_proc_name || ''');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END;');

END generate_map_proc_bulk ;



PROCEDURE generate_party_map_proc (
   p_proc_name          IN      VARCHAR2,
   p_rule_id            IN      NUMBER
) IS

  NONE BOOLEAN := TRUE;
  trxctx BOOLEAN := FALSE;
  l_filt VARCHAR2(1);
BEGIN

  l('');
  l('/************************************************');
  l('  This procedure maps a search record from the logical');
  l('  record structure to the stage schema structure ');
  l('  for the PARTY Entity after applying ');
  l('  the defined transformations');
  l('************************************************/');
  l('');
  l('PROCEDURE ' || p_proc_name || '( ');
  l('    p_search_ctx IN BOOLEAN,');
  l('    p_search_rec IN HZ_PARTY_SEARCH.party_search_rec_type, ');
  l('    x_entered_max_score OUT NUMBER,');
  l('    x_stage_rec IN OUT NOCOPY HZ_PARTY_STAGE.party_stage_rec_type');
  l('  ) IS ');
  l('  tmp VARCHAR2(4000);');
  l('  l_party_name VARCHAR2(4000);');
  l('BEGIN');
  ldbg_s('Inside Calling Procedure - '||p_proc_name);
  l('   IF p_search_ctx THEN');
  l('     x_stage_rec.TX8 := NULL;');
  l('     g_other_party_level_attribs:=FALSE;');
  NONE:=TRUE;
  for PRIMATTRS IN (
        SELECT a.ATTRIBUTE_NAME
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY sattr
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY'
        ) LOOP
    IF PRIMATTRS.ATTRIBUTE_NAME not in (
          'PARTY_NAME','PARTY_TYPE','STATUS','PARTY_ALL_NAMES') THEN
      IF NONE THEN
        l('    IF p_search_rec.'||PRIMATTRS.ATTRIBUTE_NAME || ' IS NOT NULL ');
        NONE:=FALSE;
      ELSE
        l('    OR p_search_rec.'||PRIMATTRS.ATTRIBUTE_NAME || ' IS NOT NULL ');
      END IF;
    END IF;
  END LOOP;
  IF NOT NONE THEN
    l('    THEN');
    l('      g_other_party_level_attribs:=TRUE;');
    l('    END IF;');
  END IF;

  l('     x_entered_max_score:=0;');
  for SECATTRS IN (
        SELECT a.ATTRIBUTE_NAME, SCORE
        FROM HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY') LOOP
    l('    IF p_search_rec.'||SECATTRS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      x_entered_max_score := x_entered_max_score+'||SECATTRS.SCORE||';');
    l('    END IF;');
  END LOOP;
  l('    END IF;');

  for FUNCS IN (
        SELECT a.ATTRIBUTE_NAME,a.attribute_id,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_PRIMARY pattr,
             HZ_PRIMARY_TRANS pfunc
        WHERE pattr.MATCH_RULE_ID = p_rule_id
        AND pattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY'
        AND pattr.PRIMARY_ATTRIBUTE_ID = pfunc.PRIMARY_ATTRIBUTE_ID
        AND pfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.ATTRIBUTE_NAME,a.attribute_id,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
             HZ_TRANS_ATTRIBUTES_VL a,
             HZ_MATCH_RULE_SECONDARY sattr,
             HZ_SECONDARY_TRANS sfunc
        WHERE sattr.MATCH_RULE_ID = p_rule_id
        AND sattr.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.ENTITY_NAME = 'PARTY'
        AND sattr.SECONDARY_ATTRIBUTE_ID = sfunc.SECONDARY_ATTRIBUTE_ID
        AND sfunc.FUNCTION_ID = f.FUNCTION_ID

        UNION

        SELECT a.attribute_name,a.attribute_id,
               f.PROCEDURE_NAME,
               f.STAGED_ATTRIBUTE_COLUMN
        FROM HZ_TRANS_FUNCTIONS_VL f,
            HZ_TRANS_ATTRIBUTES_VL a
        WHERE f.ATTRIBUTE_ID = a.ATTRIBUTE_ID
        AND a.entity_name = 'PARTY'
        AND a.attribute_name='PARTY_TYPE'
        AND f.PROCEDURE_NAME='HZ_TRANS_PKG.EXACT'
        AND nvl(f.active_flag,'Y')='Y'
        AND ROWNUM=1
  )
  LOOP
    NONE := FALSE;
    trxctx := has_trx_context(FUNCS.PROCEDURE_NAME);
    begin
      select nvl(filter_flag, 'N') INTO l_filt
      FROM HZ_MATCH_RULE_PRIMARY p
      where p.MATCH_RULE_ID = p_rule_id
      AND p.attribute_id = FUNCS.attribute_id;
    exception
      when no_data_found then
        l_filt:='N';
    end;
    IF l_filt = 'N' THEN
    l('  IF p_search_ctx THEN');
    l('    IF p_search_rec.'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
    l('        ' || FUNCS.PROCEDURE_NAME ||'(');
    l('             p_search_rec.'||FUNCS.ATTRIBUTE_NAME);
    l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
    IF trxctx THEN
      l('             ,''PARTY'','''||g_context||''');');
    ELSE
      l('             ,''PARTY'');');
    END IF;
    l('    ELSE');
    l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := '''';');
    l('    END IF;');
    IF NOT trxctx THEN
      l('  END IF;');
    ELSE
      l('  ELSE');
      l('    IF p_search_rec.'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
      l('      tmp :=' || FUNCS.PROCEDURE_NAME ||'(');
      l('             x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN);
      l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
      l('             ,''PARTY'',''SCORE'');');
      l('      IF tmp IS NOT NULL THEN');
      l('        x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := tmp;');
      l('      END IF;');
      l('    END IF;');
      l('  END IF;');
    END IF;
    ELSE
    l('    IF p_search_rec.'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
    l('        ' || FUNCS.PROCEDURE_NAME ||'(');
    l('             p_search_rec.'||FUNCS.ATTRIBUTE_NAME);
    l('             ,null,''' || FUNCS.ATTRIBUTE_NAME || '''');
    IF trxctx THEN
      l('             ,''PARTY'',''STAGE'');');
    ELSE
      l('             ,''PARTY'');');
    END IF;
    l('    ELSE');
    l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := '''';');
    l('    END IF;');
    END IF;

    --- Modified for Bug 4016594
    IF FUNCS.ATTRIBUTE_NAME = 'DUNS_NUMBER_C' AND upper(FUNCS.PROCEDURE_NAME) = 'HZ_TRANS_PKG.EXACT' THEN
      l('    IF p_search_rec.'||FUNCS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
      l('      x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ' := ');
      l('          lpad(x_stage_rec.'||FUNCS.STAGED_ATTRIBUTE_COLUMN || ',9,''0'');');
      l('    END IF;');
    END IF;

  END LOOP;
  l('    l_party_name := p_search_rec.PARTY_NAME;');
  l('    IF l_party_name IS NULL AND p_search_rec.PARTY_ALL_NAMES IS NOT NULL THEN');
  l('      l_party_name := p_search_rec.PARTY_ALL_NAMES;');
  l('    END IF;');
  l('    IF l_party_name IS NOT NULL AND x_stage_rec.TX8 IS NULL THEN');
  l('      x_stage_rec.TX8 := HZ_TRANS_PKG.WRNAMES_EXACT(l_party_name,null,''PARTY_NAME'',''PARTY'','''||g_context||''');');
  l('    END IF;');

  IF NONE THEN
    l('  NULL;');
  END IF;


  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_TRANSFORM_PROC_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'' , ''' || p_proc_name || ''');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END;');

END generate_party_map_proc;



PROCEDURE generate_check_proc (
	p_rule_id	NUMBER) IS
FIRST BOOLEAN;
BEGIN
  l('');
  l('/************************************************');
  l('  This procedure checks if the input search criteria ');
  l('  is valid. It checks if : ');
  l('   1. At least one primary condition is passed');
  l('   2. Contact Point Type is not null for each condition');
  l('************************************************/');
  l('');

  l('FUNCTION check_prim_cond(');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list)');
  l('      RETURN BOOLEAN IS');
  l('  BEGIN');

  FIRST := TRUE;
  FOR CPTS IN (SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND p.attribute_id = a.attribute_id
       AND ATTRIBUTE_NAME <> 'CONTACT_POINT_TYPE'
       AND nvl(p.FILTER_FLAG,'N') = 'N') LOOP
    IF FIRST THEN
      l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
      l('      IF p_contact_point_list(I).CONTACT_POINT_TYPE IS NULL AND (');
      l('p_contact_point_list(I).'||CPTS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('OR p_contact_point_list(I).'||CPTS.ATTRIBUTE_NAME||' IS NOT NULL ');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l(' ) THEN');
    l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_CONTACT_POINT_TYPE'');');
    l('        FND_MSG_PUB.ADD;');
    l('        RAISE FND_API.G_EXC_ERROR;');
    l('      END IF;');
    l('    END LOOP;');
    l('');
  END IF;

  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND p.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND nvl(p.FILTER_FLAG,'N') = 'N') LOOP
    l('    IF p_party_search_rec.'||PRIMATTRS.ATTRIBUTE_NAME || ' IS NOT NULL THEN ');
    l('      RETURN TRUE;');
    l('    END IF;');
  END LOOP;

  FOR PRIMATTRS IN (
       SELECT ENTITY_NAME, ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME <> 'PARTY'
       AND p.attribute_id = a.attribute_id
       AND ATTRIBUTE_NAME <> 'CONTACT_POINT_TYPE'
       AND nvl(p.FILTER_FLAG,'N') = 'N')
  LOOP
    IF PRIMATTRS.ENTITY_NAME = 'PARTY_SITES' THEN
      l('    FOR I IN 1..p_party_site_list.COUNT LOOP');
      HZ_GEN_PLSQL.add_line('      IF p_party_site_list(I).',false);
    ELSIF PRIMATTRS.ENTITY_NAME = 'CONTACTS' THEN
      l('    FOR I IN 1..p_contact_list.COUNT LOOP');
      HZ_GEN_PLSQL.add_line('      IF p_contact_list(I).',false);
    ELSIF PRIMATTRS.ENTITY_NAME = 'CONTACT_POINTS' THEN
      l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
      HZ_GEN_PLSQL.add_line('      IF p_contact_point_list(I).',false);
    END IF;
    l(PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL THEN ');
    l('        RETURN TRUE;');
    l('      END IF;');
    l('    END LOOP;');
  END LOOP;
  l('    RETURN FALSE;');
  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_prim_cond'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_prim_cond;');
  l('');

  l('/************************************************');
  l('  This procedure checks if the input search condition ');
  l('  has party site criteria. ');
  l('************************************************/');

  l('');
  l('PROCEDURE check_party_site_cond(');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('	   x_secondary		   OUT     BOOLEAN,');
  l('	   x_primary		   OUT     BOOLEAN');
  l(') IS');
  l('  BEGIN');
  l('    x_primary:= FALSE;');
  l('    x_secondary:= FALSE;');

  l('    FOR I IN 1..p_party_site_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'PARTY_SITES'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_party_site_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_party_site_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;

  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');
  l('');

  l('    FOR I IN 1..p_party_site_list.COUNT LOOP');
  FIRST := TRUE;
  FOR SECATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'PARTY_SITES'
       AND s.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_party_site_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_party_site_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_secondary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_secondary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR SECATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND s.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;

  IF NOT FIRST THEN
    l('      THEN');
    l('        x_secondary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_secondary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_party_site_cond'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_party_site_cond;');
  l('');

  l('/************************************************');
  l('  This procedure checks if the input search condition ');
  l('  has contact criteria. ');
  l('************************************************/');

  l('');
  l('PROCEDURE check_contact_cond(');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      x_secondary             OUT     BOOLEAN,');
  l('      x_primary               OUT     BOOLEAN');
  l(') IS');

  l('  BEGIN');
  l('    x_primary:= FALSE;');
  l('    x_secondary:= FALSE;');


  l('    FOR I IN 1..p_contact_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACTS'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');
  l('');
  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('');
  l('    FOR I IN 1..p_contact_list.COUNT LOOP');
  FIRST := TRUE;
  FOR SECATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACTS'
       AND s.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_secondary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_secondary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');
  l('');

  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR SECATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND s.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_secondary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_secondary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_contact_cond'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_contact_cond;');
  l('');

  l('/************************************************');
  l('  This procedure checks if the input search condition ');
  l('  has valid contact point criteria. ');
  l('************************************************/');

  l('');
  l('PROCEDURE check_contact_point_cond(');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      x_secondary             OUT     BOOLEAN,');
  l('      x_primary               OUT     BOOLEAN');
  l(') IS');
  l('  BEGIN');
  l('    x_primary:= FALSE;');
  l('    x_secondary:= FALSE;');
  l('');
  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  l('      IF p_contact_point_list(I).CONTACT_POINT_TYPE IS NULL THEN ');
  l('        FND_MESSAGE.SET_NAME(''AR'', ''HZ_NO_CONTACT_POINT_TYPE'');');
  l('        FND_MSG_PUB.ADD;');
  l('        RAISE FND_API.G_EXC_ERROR;');
  l('      END IF;');
  l('    END LOOP;');
  l('');
  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR PRIMATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND p.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| PRIMATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
    END IF;
  END LOOP;
  IF NOT FIRST THEN
    l('      THEN');
    l('        x_primary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_primary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');

  l('    FOR I IN 1..p_contact_point_list.COUNT LOOP');
  FIRST := TRUE;
  FOR SECATTRS IN (
       SELECT ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND a.ENTITY_NAME = 'CONTACT_POINTS'
       AND s.attribute_id = a.attribute_id)
  LOOP
    IF FIRST THEN
      l('      IF p_contact_point_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL  ');
      FIRST := FALSE;
    ELSE
      l('         OR p_contact_point_list(I).'|| SECATTRS.ATTRIBUTE_NAME||' IS NOT NULL ');
    END IF;
  END LOOP;

  IF NOT FIRST THEN
    l('      THEN');
    l('        x_secondary := TRUE;');
    l('      END IF;');
    l('      EXIT WHEN x_secondary;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END LOOP;');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''check_contact_point_cond'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  END check_contact_point_cond;');
  l('');


END;

PROCEDURE generate_custom_code (
	p_rule_id       NUMBER,
        p_record 	VARCHAR2,
	p_entity	VARCHAR2,
	p_record_id	VARCHAR2) IS

BEGIN

  ldbg_s('Inside calling procedure - generate_custom_code');

  FOR CUSTATTRS IN (
    SELECT distinct ATTRIBUTE_NAME, CUSTOM_ATTRIBUTE_PROCEDURE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = p_entity
    AND (a.SOURCE_TABLE = 'CUSTOM'
    OR a.CUSTOM_ATTRIBUTE_PROCEDURE IS NOT NULL)
    UNION
    SELECT distinct ATTRIBUTE_NAME, CUSTOM_ATTRIBUTE_PROCEDURE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = p_entity
    AND (a.SOURCE_TABLE = 'CUSTOM'
    OR a.CUSTOM_ATTRIBUTE_PROCEDURE IS NOT NULL)) LOOP

    l(p_record||'.'||CUSTATTRS.ATTRIBUTE_NAME||':=');
    l('       '||CUSTATTRS.CUSTOM_ATTRIBUTE_PROCEDURE||'('||
      p_record_id||' , '''||p_entity||''','''||CUSTATTRS.ATTRIBUTE_NAME||''');');
  END LOOP;
END;

-- Fix for Bug 4734661. Modified to add the p_called_from parameter.
PROCEDURE generate_acquire_proc (
   p_rule_id       NUMBER
  ,p_called_from   VARCHAR2) IS

l_num_attrs NUMBER;
FIRST BOOLEAN;
BEGIN
  l('');
  l('/************************************************');
  l('  This procedure retrieves the match rule attributes into ');
  l('  the search record structures');
  l('************************************************/');
  l('');
  l('PROCEDURE get_party_for_search (');
  l('        p_party_id              IN      NUMBER,');
  l('        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,');
  l('        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,');
  l('        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list');
  l(') IS');
  l('  l_party_id NUMBER;');
  l('  l_party_site_ids HZ_PARTY_SEARCH.IDList;');
  l('  l_contact_ids HZ_PARTY_SEARCH.IDList;');
  l('  l_contact_pt_ids HZ_PARTY_SEARCH.IDList;');
  l('  ps NUMBER :=1;');
  l('  cpt NUMBER :=1;');
  l('  ct NUMBER :=1;');
  l('  l_use_contact_info varchar2(1);');--bug 5169483
  l('BEGIN');
  l('');

--bug 5169483
  l('    l_use_contact_info := ''Y'';');
  l('  IF nvl(FND_PROFILE.VALUE(''HZ_DQM_REL_PARTY_MATCH''),''N'')=''Y'' THEN');
  l('    l_use_contact_info := ''N'';');
  l('  END IF;');
--bug 5169483

  -- Query number of party attributes
  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
  );

  IF l_num_attrs > 0 THEN
    l('  l_party_id := p_party_id;');
  ELSE
    l('  l_party_id := null;');
  END IF;

  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
  );


  IF l_num_attrs > 0 THEN

    l('  FOR PARTY_SITES IN (');
    l(' SELECT party_site_id FROM (');  ---Code Change for Match Rule Set
    l('     SELECT party_site_id,identifying_address_flag'); ---Code Change for Match Rule Set
    l('      FROM HZ_PARTY_SITES');
    l('      WHERE party_id = p_party_id');
    l('      AND (status is null OR status = ''A'') ');
    l('      AND identifying_address_flag=''Y''');
    l('      UNION');
    l('');
    l('     SELECT party_site_id,NVL(identifying_address_flag,''N'') identifying_address_flag'); ---Code Change for Match Rule Set
    l('      FROM HZ_PARTY_SITES');
    l('      WHERE party_id = p_party_id');
    l('      AND (status is null OR status = ''A'') ');
    l('      AND (identifying_address_flag IS NULL OR identifying_address_flag = ''N'')');
    -- Fix for Bug 4734661. Include this clause only if called from gen_pkg_body and not gen_pkg_body_bulk.
    IF p_called_from IS NULL THEN
      l('      AND ROWNUM<6');
    END IF;
    l('      UNION');
    l('');
    l('     SELECT party_site_id,NVL(identifying_address_flag,''N'') identifying_address_flag');
    l('      FROM HZ_PARTY_SITES');
    l('      WHERE (status is null OR status = ''A'') ');
    l('      AND party_id in (');
    l('        SELECT party_id');
    l('        FROM HZ_ORG_CONTACTS, HZ_RELATIONSHIPS');
    l('        WHERE HZ_RELATIONSHIPS.object_id = p_party_id');
    l('        AND HZ_RELATIONSHIPS.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
    l('        AND HZ_RELATIONSHIPS.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
    l('        AND HZ_ORG_CONTACTS.party_relationship_id = HZ_RELATIONSHIPS.relationship_id');
    l('        and l_use_contact_info = ''Y''');--bug 5169483
    l('     ) ');
    -- Fix for Bug 4734661. Include this clause only if called from gen_pkg_body and not gen_pkg_body_bulk.
    IF p_called_from IS NULL THEN
      l('     AND ROWNUM<6');
    END IF;
    l(') order by identifying_address_flag desc'); ---Code Change for Match Rule Set
    l('    ) LOOP');
    l('      l_party_site_ids(ps) := PARTY_SITES.party_site_id;');
    l('      ps:=ps+1;');
    l('  END LOOP;');
  END IF;

  -- Query number of contact attributes
  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'
  );

  IF l_num_attrs > 0 THEN
    l('    FOR CONTACTS IN (');
    l('      SELECT org_contact_id');
    l('      FROM HZ_ORG_CONTACTS, HZ_RELATIONSHIPS');
    l('      WHERE HZ_RELATIONSHIPS.object_id = p_party_id');
    l('      AND HZ_RELATIONSHIPS.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
    l('      AND HZ_RELATIONSHIPS.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
    l('      AND HZ_RELATIONSHIPS.DIRECTIONAL_FLAG = ''F''');
    l('      AND HZ_ORG_CONTACTS.party_relationship_id = HZ_RELATIONSHIPS.relationship_id');
    -- Fix for Bug 4734661. Include this clause only if called from gen_pkg_body and not gen_pkg_body_bulk.
    IF p_called_from IS NULL THEN
      l('      AND ROWNUM<6 ');
    END IF;
    l('    ) LOOP');
    l('      l_contact_ids(ct) := CONTACTS.org_contact_id;');
    l('      ct := ct+1;');
    l('    END LOOP;');
  END IF;

  -- Query number of contact point attributes
  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'
  );

  IF l_num_attrs > 0 THEN
    l('    FOR CONTACT_POINTS IN (');
    l('      SELECT CONTACT_POINT_ID');
    l('      FROM HZ_CONTACT_POINTS ');
    l('      WHERE PRIMARY_FLAG = ''Y''');
    l('      AND owner_table_name = ''HZ_PARTIES''');
    l('      AND owner_table_id = p_party_id');
    l('');
    l('      UNION');
    l('');
    l('      SELECT CONTACT_POINT_ID');
    l('      FROM HZ_CONTACT_POINTS,HZ_ORG_CONTACTS, HZ_RELATIONSHIPS ');--bug 4873802
    l('      WHERE PRIMARY_FLAG = ''Y''');
    l('      AND owner_table_name = ''HZ_PARTIES''');
    l('      AND OWNER_TABLE_ID = HZ_RELATIONSHIPS.party_id');--bug 4873802
    l('      AND HZ_RELATIONSHIPS.object_id = p_party_id');
    l('      AND HZ_RELATIONSHIPS.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
    l('      AND HZ_RELATIONSHIPS.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
    l('      AND HZ_ORG_CONTACTS.party_relationship_id = HZ_RELATIONSHIPS.relationship_id');
    l('        and l_use_contact_info = ''Y''');--bug 5169483
    -- Fix for Bug 4734661. Include this clause only if called from gen_pkg_body and not gen_pkg_body_bulk.
    IF p_called_from IS NULL THEN
      l('      AND ROWNUM<6');
    END IF;
    l('      UNION');
    l('');
    l('      SELECT CONTACT_POINT_ID');
    l('      FROM HZ_CONTACT_POINTS,HZ_PARTY_SITES  ');--bug 4873802
    l('      WHERE PRIMARY_FLAG = ''Y''');
    l('      AND owner_table_name = ''HZ_PARTY_SITES''');
    l('      AND owner_table_id = party_site_id ');--bug 4873802
    l('      AND PARTY_ID = p_party_id ');
    l('      AND IDENTIFYING_ADDRESS_FLAG = ''Y'') LOOP');
    l('      l_contact_pt_ids(cpt) := CONTACT_POINTS.CONTACT_POINT_ID;');
    l('      cpt := cpt+1;');
    l('    END LOOP;');
  END IF;

  l('    get_search_criteria(l_party_id,l_party_site_ids,l_contact_ids,l_contact_pt_ids,');
  l('          x_party_search_rec,x_party_site_list,x_contact_list,x_contact_point_list);');

  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''get_party_for_search'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_party_for_search;');
  l('');

  l('PROCEDURE get_search_criteria (');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_ids        IN      HZ_PARTY_SEARCH.IDList,');
  l('        p_contact_ids           IN      HZ_PARTY_SEARCH.IDList,');
  l('        p_contact_pt_ids        IN      HZ_PARTY_SEARCH.IDList,');
  l('        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,');
  l('        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,');
  l('        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list');
  l(') IS');
  l('BEGIN');
  l('');
  ldbg_s('Inside Calling Procedure - get_search_criteria');

  -- Query number of party attributes
  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
  );

  IF l_num_attrs > 0 THEN
    l('    IF p_party_id IS NOT NULL THEN');
  ldbg_s('Before Calling Procedure - get_party_rec');
    l('      get_party_rec(p_party_id, x_party_search_rec);');
    l('    END IF;');
  END IF;

  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
  );


  IF l_num_attrs > 0 THEN
    l('    IF p_party_site_ids IS NOT NULL AND p_party_site_ids.COUNT>0 THEN');
    ldbg_s('Before Calling Procedure - get_party_site_rec');
    l('      get_party_site_rec(p_party_site_ids, x_party_site_list);');
    l('    END IF;');
  END IF;

  -- Query number of contact attributes
  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'
  );

  IF l_num_attrs > 0 THEN
    l('    IF p_contact_ids IS NOT NULL AND p_contact_ids.COUNT>0 THEN');
    ldbg_s('Before Calling Procedure - get_contact_rec');
    l('      get_contact_rec(p_contact_ids, x_contact_list);');
    l('    END IF;');
  END IF;

  -- Query number of contact point attributes
  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'

    UNION

    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'
  );

  IF l_num_attrs > 0 THEN
    l('    IF p_contact_pt_ids IS NOT NULL AND p_contact_pt_ids.COUNT>0 THEN');
    ldbg_s('Before Calling Procedure - get_contact_point_rec');
    l('      get_contact_point_rec(p_contact_pt_ids, x_contact_point_list);');
    l('    END IF;');
  END IF;
  l('EXCEPTION');
  l('  WHEN FND_API.G_EXC_ERROR THEN');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''get_search_criteria'');');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;');
  l('END get_search_criteria;');
  l('');

  l('');
  l('/************************************************');
  l('  This procedure retrieves the match rule party attributes into ');
  l('  the party search record structure ');
  l('************************************************/');
  l('');
  l('PROCEDURE get_party_rec (');
  l('        p_party_id              IN      NUMBER,');
  l('        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type');
  l(') IS');
  l('    l_party_type VARCHAR2(255);');
  l('BEGIN');
  l('');
  ldbg_s('Inside calling procedure - get_party_rec');
  l('    SELECT PARTY_TYPE INTO l_party_type');
  l('    FROM HZ_PARTIES');
  l('    WHERE PARTY_ID = p_party_id;');
  l('');
  ldbg_sv('l_party_type is - ','l_party_type'  ) ;
  l('    IF l_party_type = ''ORGANIZATION'' THEN');

  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
    AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
    UNION
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
    AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
  );

  IF l_num_attrs>0 THEN
    l('      SELECT ');
    FIRST := TRUE;
    FOR ATTRS IN (
      SELECT distinct a.ATTRIBUTE_NAME, decode(a.SOURCE_TABLE, 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES', 'HZ_ORGANIZATION_PROFILES', 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES', 'HZ_ORGANIZATION_PROFILES', a.SOURCE_TABLE) SOURCE_TABLE
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND p.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
       UNION
       SELECT distinct a.ATTRIBUTE_NAME, decode(a.SOURCE_TABLE, 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES', 'HZ_ORGANIZATION_PROFILES', 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES', 'HZ_ORGANIZATION_PROFILES', a.SOURCE_TABLE) SOURCE_TABLE
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND s.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL) LOOP

      IF FIRST THEN
        l('        translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5621864
        FIRST := FALSE;
      ELSE
        l('       ,translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5621864
      END IF;
    END LOOP;

    l('      INTO ');
    FIRST := TRUE;
    FOR ATTRS IN (
       SELECT distinct a.ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND p.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES'  OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
       UNION
       SELECT distinct a.ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND s.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES'  OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL) LOOP


      IF FIRST THEN
        l('        x_party_search_rec.'||ATTRS.ATTRIBUTE_NAME);
        FIRST := FALSE;
      ELSE
        l('       ,x_party_search_rec.'||ATTRS.ATTRIBUTE_NAME);
      END IF;
    END LOOP;

    l('      FROM HZ_PARTIES, HZ_ORGANIZATION_PROFILES');
    l('      WHERE HZ_PARTIES.party_id = HZ_ORGANIZATION_PROFILES.party_id');
    l('      AND HZ_ORGANIZATION_PROFILES.effective_end_date is NULL');
    l('      AND HZ_PARTIES.party_id = p_party_id;');
  ELSE
    l('      NULL;');
  END IF;
  l('    ELSIF l_party_type = ''PERSON'' THEN');

  SELECT COUNT(*) INTO l_num_attrs
  FROM (
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES'  OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
    AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
    UNION
    SELECT a.attribute_id
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY'
    AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES'  OR
       a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
       a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
    AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
  );

  IF l_num_attrs>0 THEN
    l('      SELECT ');
    FIRST := TRUE;
    FOR ATTRS IN (
       SELECT distinct a.ATTRIBUTE_NAME, decode(a.SOURCE_TABLE, 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES', 'HZ_PERSON_PROFILES','HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES', 'HZ_PERSON_PROFILES', a.SOURCE_TABLE)  SOURCE_TABLE
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND p.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES'  OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
       UNION
       SELECT distinct a.ATTRIBUTE_NAME, decode(a.SOURCE_TABLE, 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES', 'HZ_PERSON_PROFILES', 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES', 'HZ_PERSON_PROFILES', a.SOURCE_TABLE) SOURCE_TABLE
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND s.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES'  OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL) LOOP

      IF FIRST THEN
        l('        translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5621864
        FIRST := FALSE;
      ELSE
        l('       ,translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5621864
      END IF;
    END LOOP;

    l('      INTO ');
    FIRST := TRUE;
    FOR ATTRS IN (
       SELECT distinct a.ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_PRIMARY p
       WHERE p.match_rule_id = p_rule_id
       AND p.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES'  OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL
       UNION
       SELECT distinct a.ATTRIBUTE_NAME
       FROM HZ_TRANS_ATTRIBUTES_VL a,
            HZ_MATCH_RULE_SECONDARY s
       WHERE s.match_rule_id = p_rule_id
       AND s.attribute_id = a.attribute_id
       AND a.ENTITY_NAME = 'PARTY'
       AND (a.SOURCE_TABLE = 'HZ_PARTIES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES' OR
          a.SOURCE_TABLE = 'HZ_PERSON_PROFILES, HZ_ORGANIZATION_PROFILES' OR
          a.SOURCE_TABLE = 'HZ_ORGANIZATION_PROFILES, HZ_PERSON_PROFILES')
       AND a.CUSTOM_ATTRIBUTE_PROCEDURE IS NULL) LOOP

      IF FIRST THEN
        l('        x_party_search_rec.'||ATTRS.ATTRIBUTE_NAME);
        FIRST := FALSE;
      ELSE
        l('       ,x_party_search_rec.'||ATTRS.ATTRIBUTE_NAME);
      END IF;
    END LOOP;

    l('      FROM HZ_PARTIES, HZ_PERSON_PROFILES');
    l('      WHERE HZ_PARTIES.party_id = HZ_PERSON_PROFILES.party_id');
    l('      AND HZ_PERSON_PROFILES.effective_end_date is NULL');
    l('      AND HZ_PARTIES.party_id = p_party_id;');
  ELSE
    l('      NULL;');
  END IF;
  l('    END IF;');
  l('    x_party_search_rec.PARTY_TYPE := l_party_type;');
  generate_custom_code(p_rule_id, '    x_party_search_rec','PARTY','p_party_id');
  l('');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_PARTY_QUERY_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''get_party_rec'');');
  l('    FND_MESSAGE.SET_TOKEN(''PARTY_ID'',p_party_id);');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('END get_party_rec;');
  l('');
  l('/************************************************');
  l('  This procedure retrieves the match rule party site attributes into ');
  l('  the party site search record structure ');
  l('************************************************/');
  l('');
  l('PROCEDURE get_party_site_rec (');
  l('        p_party_site_ids       IN      HZ_PARTY_SEARCH.IDList,');
  l('        x_party_site_list      OUT NOCOPY HZ_PARTY_SEARCH.party_site_list');
  l(') IS');
  l('  CURSOR c_party_sites(cp_party_site_id NUMBER) IS');
  l('    SELECT party_site_id');
  FOR ATTRS IN (
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
    AND a.SOURCE_TABLE <> 'CUSTOM'
    UNION
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
    AND a.SOURCE_TABLE <> 'CUSTOM') LOOP

     l('      ,translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5621864
  END LOOP;
  l('    FROM HZ_PARTY_SITES, HZ_LOCATIONS');
  l('    WHERE HZ_PARTY_SITES.party_site_id = cp_party_site_id');
  l('    AND   HZ_PARTY_SITES.location_id = HZ_LOCATIONS.location_id;');
  l('');
  l('  I NUMBER;');
  l('  J NUMBER:=1;');
  l('  l_party_site_id NUMBER;');
  l('');
  l('BEGIN');
  l('');
  ldbg_s('Inside calling procedure - get_party_site_rec');
  l('    FOR I IN 1..p_party_site_ids.COUNT LOOP');
  l('      l_party_site_id := p_party_site_ids(I);');
  l('      OPEN c_party_sites(p_party_site_ids(I));');
  l('      LOOP');
  l('        FETCH c_party_sites INTO');
  l('             l_party_site_id');
  FOR ATTRS IN (
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
    AND a.SOURCE_TABLE <> 'CUSTOM'

    UNION

    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'PARTY_SITES'
    AND a.SOURCE_TABLE <> 'CUSTOM') LOOP

    l('           ,x_party_site_list(J).'||ATTRS.ATTRIBUTE_NAME);
  END LOOP;
  l('        ;');
  l('        EXIT WHEN c_party_sites%NOTFOUND;');
  l('');
  generate_custom_code(p_rule_id, '        x_party_site_list(J)','PARTY_SITES','l_party_site_id')
;
  l('        J:=J+1;');
  l('');
  l('      END LOOP;');
  l('      CLOSE c_party_sites;');
  l('    END LOOP;');
  l('');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_PARTY_QUERY_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''get_party_site_rec'');');
  l('    FND_MESSAGE.SET_TOKEN(''PARTY_ID'',l_party_site_id);');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('END get_party_site_rec;');
  l('');

  l('/************************************************');
  l('  This procedure retrieves the match rule contact attributes into ');
  l('  the contact search record structure ');
  l('************************************************/');
  l('');
  l('PROCEDURE get_contact_rec (');
  l('        p_contact_ids       IN      HZ_PARTY_SEARCH.IDList,');
  l('        x_contact_list      OUT NOCOPY HZ_PARTY_SEARCH.contact_list');
  l(') IS');
  l('  CURSOR c_contacts(cp_org_contact_id NUMBER) IS');
  l('    SELECT org_contact_id');
  FOR ATTRS IN (
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'
    AND a.SOURCE_TABLE <> 'CUSTOM'
    UNION
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'
    AND a.SOURCE_TABLE <> 'CUSTOM') LOOP

    l('      ,translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5621864
  END LOOP;
  l('    FROM HZ_ORG_CONTACTS, HZ_RELATIONSHIPS, HZ_PERSON_PROFILES');
  l('    WHERE HZ_ORG_CONTACTS.org_contact_id = cp_org_contact_id');
  l('    AND HZ_RELATIONSHIPS.SUBJECT_TABLE_NAME = ''HZ_PARTIES''');
  l('    AND HZ_RELATIONSHIPS.OBJECT_TABLE_NAME = ''HZ_PARTIES''');
  l('    AND HZ_RELATIONSHIPS.DIRECTIONAL_FLAG = ''F''');
  l('    AND HZ_ORG_CONTACTS.party_relationship_id = HZ_RELATIONSHIPS.relationship_id');
  l('    AND HZ_RELATIONSHIPS.subject_id = HZ_PERSON_PROFILES.party_id');
  l('    AND HZ_PERSON_PROFILES.effective_end_date IS NULL;');
  l('');
  l('  I NUMBER;');
  l('  l_org_contact_id NUMBER;');
  l('  J NUMBER:=1;');

  l('  BEGIN');
  l('');
  ldbg_s('Inside calling procedure - get_contact_rec');
  l('    FOR I IN 1..p_contact_ids.COUNT LOOP');
  l('      l_org_contact_id := p_contact_ids(I);');
  l('      OPEN c_contacts(p_contact_ids(I));');
  l('      LOOP');
  l('        FETCH c_contacts INTO');
  l('             l_org_contact_id');
  FOR ATTRS IN (
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'
    AND a.SOURCE_TABLE <> 'CUSTOM'

    UNION

    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACTS'
    AND a.SOURCE_TABLE <> 'CUSTOM') LOOP

    l('             ,x_contact_list(J).'||ATTRS.ATTRIBUTE_NAME);
  END LOOP;
  l('        ;');
  l('        EXIT WHEN c_contacts%NOTFOUND;');
  l('');
  generate_custom_code(p_rule_id, '        x_contact_list(J)','CONTACTS','l_org_contact_id');
  l('');
  l('        J:=J+1;');
  l('      END LOOP;');
  l('      CLOSE c_contacts;');
  l('    END LOOP;');
  l('');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_PARTY_QUERY_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''get_contact_rec'');');
  l('    FND_MESSAGE.SET_TOKEN(''PARTY_ID'',l_org_contact_id);');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('END get_contact_rec;');
  l('');
  l('/************************************************');
  l('  This procedure retrieves the match rule contact point attributes into ');
  l('  the contact point search record structure ');
  l('************************************************/');
  l('');
  l('PROCEDURE get_contact_point_rec (');
  l('        p_contact_point_ids     IN  HZ_PARTY_SEARCH.IDList,');
  l('        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list');
  l(') IS');
  l('');
  l('  -- Cursor to fetch primary contact points for party');
  l('  CURSOR c_cpts(cp_contact_point_id NUMBER) IS');
  l('    SELECT contact_point_id, contact_point_type');
  FOR ATTRS IN (
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'
    AND a.SOURCE_TABLE <> 'CUSTOM'

    UNION

    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'
    AND a.SOURCE_TABLE <> 'CUSTOM') LOOP

    l('      ,translate(' || ATTRS.SOURCE_TABLE||'.'||ATTRS.ATTRIBUTE_NAME || ', ''%'','' '')');--bug 5565522
  END LOOP;
  l('    FROM HZ_CONTACT_POINTS');
  l('    WHERE contact_point_id = cp_contact_point_id;');

  l('');
  l('  I NUMBER;');
  l('  l_contact_point_id NUMBER;');
  l('  J NUMBER:=1;');

  l('  BEGIN');
  l('');
  ldbg_s('Inside calling procedure - get_contact_point_rec');
  l('    FOR I in 1..p_contact_point_ids.COUNT LOOP');
  l('      l_contact_point_id := p_contact_point_ids(I);');
  l('      OPEN c_cpts(p_contact_point_ids(I));');
  l('      LOOP');
  l('        FETCH c_cpts INTO');
  l('             l_contact_point_id, x_contact_point_list(J).contact_point_type');

  FOR ATTRS IN (
    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_PRIMARY p
    WHERE p.match_rule_id = p_rule_id
    AND p.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'
    AND a.SOURCE_TABLE <> 'CUSTOM'

    UNION

    SELECT distinct a.ATTRIBUTE_NAME, a.SOURCE_TABLE
    FROM HZ_TRANS_ATTRIBUTES_VL a,
         HZ_MATCH_RULE_SECONDARY s
    WHERE s.match_rule_id = p_rule_id
    AND s.attribute_id = a.attribute_id
    AND a.ENTITY_NAME = 'CONTACT_POINTS'
    AND a.SOURCE_TABLE <> 'CUSTOM') LOOP


    l('             ,x_contact_point_list(J).'||ATTRS.ATTRIBUTE_NAME);
  END LOOP;
  l('        ;');
  l('        EXIT WHEN c_cpts%NOTFOUND;');
  l('');
  generate_custom_code(p_rule_id, '        x_contact_point_list(J)','CONTACT_POINTS','l_contact_point_id');
  l('        J:=J+1;');
  l('');
  l('      END LOOP;');
  l('      CLOSE c_cpts;');
  l('    END LOOP;');

  l('');
  l('EXCEPTION');
  l('  WHEN OTHERS THEN');
  l('    FND_MESSAGE.SET_NAME(''AR'', ''HZ_PARTY_QUERY_ERROR'');');
  l('    FND_MESSAGE.SET_TOKEN(''PROC'',''get_contact_point_rec'');');
  l('    FND_MESSAGE.SET_TOKEN(''PARTY_ID'',l_contact_point_id);');
  l('    FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM );');
  l('    FND_MSG_PUB.ADD;');
  l('    RAISE FND_API.G_EXC_ERROR;');
  l('END get_contact_point_rec;');

END;

PROCEDURE generate_check_staged (
	p_rule_id	IN	NUMBER
) IS

  CURSOR c_trans_func IS
    SELECT f.FUNCTION_ID
    FROM hz_primary_trans f, hz_match_rule_primary a
    WHERE a.MATCH_RULE_ID = p_rule_id
    AND a.PRIMARY_ATTRIBUTE_ID = f.PRIMARY_ATTRIBUTE_ID

    UNION

    SELECT f.FUNCTION_ID
    FROM hz_secondary_trans f, hz_match_rule_secondary a
    WHERE a.MATCH_RULE_ID = p_rule_id
    AND a.SECONDARY_ATTRIBUTE_ID = f.SECONDARY_ATTRIBUTE_ID;

---Start of Code Change for Match Rule Set
  CURSOR c_ruleset_trans_func IS
    SELECT f.FUNCTION_ID
    FROM hz_primary_trans f, hz_match_rule_primary a
    WHERE a.MATCH_RULE_ID IN (SELECT UNIQUE CONDITION_MATCH_RULE_ID
                              FROM HZ_MATCH_RULE_CONDITIONS
			      WHERE MATCH_RULE_SET_ID = p_rule_id
                             )
    AND a.PRIMARY_ATTRIBUTE_ID = f.PRIMARY_ATTRIBUTE_ID

    UNION

    SELECT f.FUNCTION_ID
    FROM hz_secondary_trans f, hz_match_rule_secondary a
    WHERE a.MATCH_RULE_ID IN (SELECT UNIQUE CONDITION_MATCH_RULE_ID
                              FROM HZ_MATCH_RULE_CONDITIONS
			      WHERE MATCH_RULE_SET_ID = p_rule_id
                             )
    AND a.SECONDARY_ATTRIBUTE_ID = f.SECONDARY_ATTRIBUTE_ID;

---End of Code Change for Match Rule Set

  l_func_id NUMBER;
  FIRST BOOLEAN := FALSE;
  l_rule_type varchar2(30); ---Code Change for Match Rule Set
BEGIN
 ---Start of Code Change for Match Rule Set
 SELECT nvl(match_rule_type,'SINGLE') into l_rule_type FROM HZ_MATCH_RULES_VL
 WHERE match_rule_id = p_rule_id;
 ---End of Code Change for Match Rule Set

  l('FUNCTION check_staged RETURN BOOLEAN IS');
  l('');
  l('  CURSOR c_check_staged IS ');
  l('    SELECT 1 FROM HZ_TRANS_FUNCTIONS_VL ');
  l('    WHERE nvl(STAGED_FLAG,''N'') = ''N'' ');
  l('    AND FUNCTION_ID in (');
  FIRST := TRUE;
IF l_rule_type <> 'SET' then ---Code Change for Match Rule Set
  OPEN c_trans_func;
  LOOP
    FETCH c_trans_func INTO l_func_id;
    EXIT WHEN c_trans_func%NOTFOUND;

    IF FIRST THEN
      l('                ' || l_func_id);
      FIRST := FALSE;
    ELSE
      l('                ,'|| l_func_id);
    END IF;
  END LOOP;
  CLOSE c_trans_func;
ELSE ---Start of Code Change for Match Rule Set
 OPEN c_ruleset_trans_func;
  LOOP
    FETCH c_ruleset_trans_func INTO l_func_id;
    EXIT WHEN c_ruleset_trans_func%NOTFOUND;

    IF FIRST THEN
      l('                ' || l_func_id);
      FIRST := FALSE;
    ELSE
      l('                ,'|| l_func_id);
    END IF;
  END LOOP;
  CLOSE c_ruleset_trans_func;

END IF; ---End of Code Change for Match Rule Set
  l('    );');

  l('  l_tmp NUMBER;');

  l('BEGIN');
  l('  IF g_staged =  1 THEN');
  l('    RETURN TRUE;');
  l('  ELSIF g_staged = 0 THEN');
  l('    RETURN FALSE;');
  l('  END IF;');
  l('');
  l('  OPEN c_check_staged;');
  l('  FETCH c_check_staged INTO l_tmp;');
  l('  IF c_check_staged%FOUND THEN');
  l('    CLOSE c_check_staged;');
  l('    g_staged := 0;');
  l('    RETURN FALSE;');
  l('  ELSE');
  l('    CLOSE c_check_staged;');
  l('    g_staged := 1;');
  l('    RETURN TRUE;');
  l('  END IF;');
  l('END check_staged;');

  l('');
  l('-- Fix for Bug 4736139');
  l('FUNCTION check_staged_var RETURN VARCHAR2 IS');
  l('  l_staged       VARCHAR2(1);');
  l('  l_staged_bool  BOOLEAN;');
  l('BEGIN');
  l('  l_staged_bool := check_staged;');
  l('  IF l_staged_bool THEN');
  l('    l_staged := ''Y'';');
  l('  ELSE');
  l('    l_staged := ''N'';');
  l('  END IF;');
  l('  RETURN l_staged;');
  l('END check_staged_var;');
  l('-- End fix for Bug 4736139');
  l('');

END;

PROCEDURE gen_pkg_spec (
	p_pkg_name 	IN	VARCHAR2,
        p_rule_id	IN	NUMBER
) IS

BEGIN

  l('CREATE or REPLACE PACKAGE ' || p_pkg_name || ' AUTHID CURRENT_USER AS');
  l('PROCEDURE map_party_rec (');
  l('        p_search_ctx IN BOOLEAN,');
  l('        p_search_rec IN HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        x_entered_max_score OUT NUMBER,');
  l('        x_stage_rec IN OUT NOCOPY HZ_PARTY_STAGE.party_stage_rec_type');
  l(');');
  l('PROCEDURE map_party_site_rec (');
  l('      p_search_ctx IN BOOLEAN,');
  l('      p_search_list IN HZ_PARTY_SEARCH.party_site_list, ');
  l('      x_entered_max_score OUT NUMBER,');
  l('      x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.party_site_stage_list');
  l(');');
  l('PROCEDURE map_contact_rec (');
  l('      p_search_ctx IN BOOLEAN,');
  l('      p_search_list IN HZ_PARTY_SEARCH.contact_list,');
  l('      x_entered_max_score OUT NUMBER,');
  l('      x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_stage_list');
  l('  );');
  l('PROCEDURE map_contact_point_rec (');
  l('      p_search_ctx IN BOOLEAN,');
  l('      p_search_list IN HZ_PARTY_SEARCH.contact_point_list,');
  l('      x_entered_max_score OUT NUMBER,');
  l('      x_stage_list IN OUT NOCOPY HZ_PARTY_STAGE.contact_pt_stage_list');
  l('  );');
  l('PROCEDURE get_party_rec (');
  l('        p_party_id              IN      NUMBER,');
  l('        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type');
  l(');');
  l('PROCEDURE get_party_site_rec (');
  l('        p_party_site_ids        IN      HZ_PARTY_SEARCH.IDList,');
  l('        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list');
  l(');');
  l('PROCEDURE get_contact_rec (');
  l('        p_contact_ids           IN      HZ_PARTY_SEARCH.IDList,');
  l('        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list');
  l(');');
  l('PROCEDURE get_contact_point_rec (');
  l('        p_contact_point_ids     IN  HZ_PARTY_SEARCH.IDList,');
  l('        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list');
  l(');');

  l('FUNCTION check_prim_cond(');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list)');
  l('   RETURN BOOLEAN;');
  l('PROCEDURE check_party_site_cond(');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      x_secondary             OUT     BOOLEAN,');
  l('      x_primary               OUT     BOOLEAN');
  l(');');
  l('PROCEDURE check_contact_cond(');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      x_secondary             OUT     BOOLEAN,');
  l('      x_primary               OUT     BOOLEAN');
  l(');');
  l('PROCEDURE check_contact_point_cond(');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      x_secondary             OUT     BOOLEAN,');
  l('      x_primary               OUT     BOOLEAN');
  l(');');
  l('PROCEDURE find_parties (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type		   IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_dup_party_id          IN      NUMBER,');
  l('      p_dup_set_id            IN      NUMBER,');
  l('      p_dup_batch_id          IN      NUMBER,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE find_persons (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      p_ins_details           IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE find_party_details (');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('      p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('      p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('      p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type		   IN      VARCHAR2,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE find_duplicate_party_sites(');
  l('      p_rule_id               IN      NUMBER,');
  l('	   p_party_site_id	   IN	   NUMBER,');
  l('	   p_party_id		   IN	   NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE find_duplicate_contacts(');
  l('      p_rule_id               IN      NUMBER,');
  l('	   p_org_contact_id	   IN	   NUMBER,');
  l('	   p_party_id		   IN	   NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE find_duplicate_contact_points(');
  l('      p_rule_id               IN      NUMBER,');
  l('	   p_contact_point_id	   IN	   NUMBER,');
  l('	   p_party_id		   IN	   NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE find_duplicate_parties (');
  l('      p_rule_id               IN      NUMBER,');
  l('	   p_party_id		   IN	   NUMBER,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('	   p_dup_batch_id	   IN	   NUMBER,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_dup_set_id            OUT     NUMBER,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE get_matching_party_sites (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_list       IN      HZ_PARTY_SEARCH.PARTY_SITE_LIST,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type	     IN      VARCHAR2,');
  l('        p_dup_party_site_id     IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE get_matching_contacts (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_list   	     IN      HZ_PARTY_SEARCH.CONTACT_LIST,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type	     IN      VARCHAR2,');
  l('        p_dup_contact_id        IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(');');
  l('');
  l('PROCEDURE get_matching_contact_points (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.CONTACT_POINT_LIST,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type	     IN      VARCHAR2,');
  l('        p_dup_contact_point_id  IN      NUMBER, ');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE get_score_details (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_search_rec      IN      HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        p_party_site_list       IN      HZ_PARTY_SEARCH.party_site_list,');
  l('        p_contact_list          IN      HZ_PARTY_SEARCH.contact_list,');
  l('        p_contact_point_list    IN      HZ_PARTY_SEARCH.contact_point_list,');
  l('        x_search_ctx_id         IN OUT  NUMBER');
  l(');');
  l('PROCEDURE find_parties_dynamic (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_attrib_id1            IN      NUMBER,');
  l('        p_attrib_id2            IN      NUMBER,');
  l('        p_attrib_id3            IN      NUMBER,');
  l('        p_attrib_id4            IN      NUMBER,');
  l('        p_attrib_id5            IN      NUMBER,');
  l('        p_attrib_id6            IN      NUMBER,');
  l('        p_attrib_id7            IN      NUMBER,');
  l('        p_attrib_id8            IN      NUMBER,');
  l('        p_attrib_id9            IN      NUMBER,');
  l('        p_attrib_id10           IN      NUMBER,');
  l('        p_attrib_id11           IN      NUMBER,');
  l('        p_attrib_id12           IN      NUMBER,');
  l('        p_attrib_id13           IN      NUMBER,');
  l('        p_attrib_id14           IN      NUMBER,');
  l('        p_attrib_id15           IN      NUMBER,');
  l('        p_attrib_id16           IN      NUMBER,');
  l('        p_attrib_id17           IN      NUMBER,');
  l('        p_attrib_id18           IN      NUMBER,');
  l('        p_attrib_id19           IN      NUMBER,');
  l('        p_attrib_id20           IN      NUMBER,');
  l('        p_attrib_val1           IN      VARCHAR2,');
  l('        p_attrib_val2           IN      VARCHAR2,');
  l('        p_attrib_val3           IN      VARCHAR2,');
  l('        p_attrib_val4           IN      VARCHAR2,');
  l('        p_attrib_val5           IN      VARCHAR2,');
  l('        p_attrib_val6           IN      VARCHAR2,');
  l('        p_attrib_val7           IN      VARCHAR2,');
  l('        p_attrib_val8           IN      VARCHAR2,');
  l('        p_attrib_val9           IN      VARCHAR2,');
  l('        p_attrib_val10          IN      VARCHAR2,');
  l('        p_attrib_val11          IN      VARCHAR2,');
  l('        p_attrib_val12          IN      VARCHAR2,');
  l('        p_attrib_val13          IN      VARCHAR2,');
  l('        p_attrib_val14          IN      VARCHAR2,');
  l('        p_attrib_val15          IN      VARCHAR2,');
  l('        p_attrib_val16          IN      VARCHAR2,');
  l('        p_attrib_val17          IN      VARCHAR2,');
  l('        p_attrib_val18          IN      VARCHAR2,');
  l('        p_attrib_val19          IN      VARCHAR2,');
  l('        p_attrib_val20          IN      VARCHAR2,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_search_merged         IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(');');
  l('PROCEDURE call_api_dynamic (');
  l('        p_rule_id               IN      NUMBER,');
  l('        p_attrib_id1            IN      NUMBER,');
  l('        p_attrib_id2            IN      NUMBER,');
  l('        p_attrib_id3            IN      NUMBER,');
  l('        p_attrib_id4            IN      NUMBER,');
  l('        p_attrib_id5            IN      NUMBER,');
  l('        p_attrib_id6            IN      NUMBER,');
  l('        p_attrib_id7            IN      NUMBER,');
  l('        p_attrib_id8            IN      NUMBER,');
  l('        p_attrib_id9            IN      NUMBER,');
  l('        p_attrib_id10           IN      NUMBER,');
  l('        p_attrib_id11           IN      NUMBER,');
  l('        p_attrib_id12           IN      NUMBER,');
  l('        p_attrib_id13           IN      NUMBER,');
  l('        p_attrib_id14           IN      NUMBER,');
  l('        p_attrib_id15           IN      NUMBER,');
  l('        p_attrib_id16           IN      NUMBER,');
  l('        p_attrib_id17           IN      NUMBER,');
  l('        p_attrib_id18           IN      NUMBER,');
  l('        p_attrib_id19           IN      NUMBER,');
  l('        p_attrib_id20           IN      NUMBER,');
  l('        p_attrib_val1           IN      VARCHAR2,');
  l('        p_attrib_val2           IN      VARCHAR2,');
  l('        p_attrib_val3           IN      VARCHAR2,');
  l('        p_attrib_val4           IN      VARCHAR2,');
  l('        p_attrib_val5           IN      VARCHAR2,');
  l('        p_attrib_val6           IN      VARCHAR2,');
  l('        p_attrib_val7           IN      VARCHAR2,');
  l('        p_attrib_val8           IN      VARCHAR2,');
  l('        p_attrib_val9           IN      VARCHAR2,');
  l('        p_attrib_val10          IN      VARCHAR2,');
  l('        p_attrib_val11          IN      VARCHAR2,');
  l('        p_attrib_val12          IN      VARCHAR2,');
  l('        p_attrib_val13          IN      VARCHAR2,');
  l('        p_attrib_val14          IN      VARCHAR2,');
  l('        p_attrib_val15          IN      VARCHAR2,');
  l('        p_attrib_val16          IN      VARCHAR2,');
  l('        p_attrib_val17          IN      VARCHAR2,');
  l('        p_attrib_val18          IN      VARCHAR2,');
  l('        p_attrib_val19          IN      VARCHAR2,');
  l('        p_attrib_val20          IN      VARCHAR2,');
  l('        p_restrict_sql          IN      VARCHAR2,');
  l('        p_api_name              IN      VARCHAR2,');
  l('        p_match_type            IN      VARCHAR2,');
  l('        p_party_id              IN      NUMBER,');
  l('        p_search_merged         IN      VARCHAR2,');
  l('        x_search_ctx_id         OUT     NUMBER,');
  l('        x_num_matches           OUT     NUMBER');
  l(');');

  l('PROCEDURE get_party_for_search (');
  l('        p_party_id              IN      NUMBER,');
  l('        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,');
  l('        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,');
  l('        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list');
  l(');');
  l('PROCEDURE get_search_criteria (');
  l('        p_party_id              IN      NUMBER,');
  l('        p_party_site_ids        IN      HZ_PARTY_SEARCH.IDList,');
  l('        p_contact_ids           IN      HZ_PARTY_SEARCH.IDList,');
  l('        p_contact_pt_ids        IN      HZ_PARTY_SEARCH.IDList,');
  l('        x_party_search_rec      OUT NOCOPY HZ_PARTY_SEARCH.party_search_rec_type,');
  l('        x_party_site_list       OUT NOCOPY HZ_PARTY_SEARCH.party_site_list,');
  l('        x_contact_list          OUT NOCOPY HZ_PARTY_SEARCH.contact_list,');
  l('        x_contact_point_list    OUT NOCOPY HZ_PARTY_SEARCH.contact_point_list');
  l(');');

  l('FUNCTION check_staged RETURN BOOLEAN;');
  l('');
  l('-- Fix for Bug 4736139');
  l('FUNCTION check_staged_var RETURN VARCHAR2;');
  l('');
  l('  g_staged NUMBER := -1;');
  l('END ' || p_pkg_name || ';');

END;

FUNCTION num_primary(
   p_entity VARCHAR2,
   p_rule_id NUMBER) RETURN NUMBER IS

l_num_primary NUMBER;
BEGIN
  SELECT count(1) INTO l_num_primary
  FROM HZ_MATCH_RULE_PRIMARY p,
       HZ_TRANS_ATTRIBUTES_VL a
  WHERE p.match_rule_id = p_rule_id
  AND   p.ATTRIBUTE_ID = a.ATTRIBUTE_ID
  AND   ENTITY_NAME = p_entity;
  RETURN l_num_primary;

END;

FUNCTION num_secondary(
   p_rule_id NUMBER,
   p_entity VARCHAR2) RETURN NUMBER IS

l_num_secondary NUMBER;
BEGIN
  SELECT count(1) INTO l_num_secondary
  FROM HZ_MATCH_RULE_SECONDARY p,
       HZ_TRANS_ATTRIBUTES_VL a
  WHERE p.match_rule_id = p_rule_id
  AND   p.ATTRIBUTE_ID = a.ATTRIBUTE_ID
  AND   ENTITY_NAME = p_entity;
  RETURN l_num_secondary;

END;


PROCEDURE gen_exception_block IS

BEGIN
  l('  --Standard call to get message count and if count is 1, get message info');
  l('  FND_MSG_PUB.Count_And_Get(');
  l('    p_encoded => FND_API.G_FALSE,');
  l('    p_count => x_msg_count,');
  l('    p_data  => x_msg_data);');
  l('  EXCEPTION');
  l('       WHEN FND_API.G_EXC_ERROR THEN');
  l('               x_return_status := FND_API.G_RET_STS_ERROR;');
  l('               FND_MSG_PUB.Count_And_Get(');
  l('                               p_encoded => FND_API.G_FALSE,');
  l('                               p_count => x_msg_count,');
  l('                               p_data  => x_msg_data);');
  l('       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN');
  l('               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
  l('               FND_MSG_PUB.Count_And_Get(');
  l('                               p_encoded => FND_API.G_FALSE,');
  l('                               p_count => x_msg_count,');
  l('                               p_data  => x_msg_data);');
  l('');
  l('       WHEN OTHERS THEN');
  l('               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;');
  l('               FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_API_ERROR'');');
  l('               FND_MESSAGE.SET_TOKEN(''PROC'' ,''HZ_PARTY_SEARCH'');');
  l('               FND_MESSAGE.SET_TOKEN(''ERROR'' ,SQLERRM);');
  l('               FND_MSG_PUB.ADD;');
  l('');
  l('               FND_MSG_PUB.Count_And_Get(');
  l('                               p_encoded => FND_API.G_FALSE,');
  l('                               p_count => x_msg_count,');
  l('                               p_data  => x_msg_data);');
END;


-- VJN put the meat of what this was earlier doing into the overloaded
-- procedure, that would do the actual compiling based on the match rule purpose
PROCEDURE compile_all_rules_nolog IS
BEGIN
  compile_all_rules_nolog('D');
  compile_all_rules_nolog('S');
  compile_all_rules_nolog('W');

END;

-- VJN introduced overloaded procedure
PROCEDURE compile_all_rules_nolog( p_rule_purpose IN varchar2)
IS

  l_return_status varchar2(100)  := null;
  l_msg_count      number(15)    := 0;
  l_msg_data      varchar2(4000)  := null;

  CURSOR c_rules_for_compile  IS
    SELECT MATCH_RULE_ID,RULE_NAME FROM HZ_MATCH_RULES_VL
    where rule_purpose = p_rule_purpose ;

  l_cur_date DATE;

  l_match_rule_id         NUMBER;
  l_rule_name HZ_MATCH_RULES_TL.RULE_NAME%TYPE;
  err VARCHAR2(2000);

BEGIN

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  l_cur_date := SYSDATE;

  UPDATE HZ_MATCH_RULES_B SET compilation_flag = 'U'
  where rule_purpose = p_rule_purpose ;

  OPEN c_rules_for_compile ;
  LOOP
    FETCH c_rules_for_compile INTO l_match_rule_id, l_rule_name;
    EXIT WHEN c_rules_for_compile%NOTFOUND;

    BEGIN
      HZ_MATCH_RULE_COMPILE.COMPILE_MATCH_RULE( l_match_rule_id,'Y',
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data) ;

    EXCEPTION
      WHEN OTHERS THEN
        UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_match_rule_id;
        COMMIT;
    END;

  END LOOP;

  -- IF p_rule_purpose <> 'Q'
  -- THEN
      HZ_GEN_PLSQL.new('HZ_PARTY_SEARCH','PACKAGE BODY');
      gen_wrap_pkg_body(-1);
      HZ_GEN_PLSQL.compile_code;
  -- END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;




PROCEDURE compile_all_rules (
        errbuf                  OUT NOCOPY     VARCHAR2,
        retcode                 OUT NOCOPY     VARCHAR2
) IS

  l_return_status varchar2(100)  := null;
  l_msg_count      number(15)    := 0;
  l_msg_data      varchar2(4000)  := null;

  CURSOR c_rules_for_compile  IS
    SELECT MATCH_RULE_ID,RULE_NAME FROM HZ_MATCH_RULES_VL ORDER BY match_rule_type DESC nulls first;--bug 5263694

  l_cur_date DATE;

  l_match_rule_id         NUMBER;
  l_rule_name HZ_MATCH_RULES_TL.RULE_NAME%TYPE;
  err VARCHAR2(2000);

BEGIN

  retcode := 0;

  outandlog('Starting Concurrent Program ''Compile Match Rules ''');
  outandlog('Start Time ' || TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
  outandlog('NEWLINE');

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  l_cur_date := SYSDATE;

  log('');

  UPDATE HZ_MATCH_RULES_B SET compilation_flag = 'U';

  OPEN c_rules_for_compile ;
  LOOP
    FETCH c_rules_for_compile INTO l_match_rule_id, l_rule_name;
    EXIT WHEN c_rules_for_compile%NOTFOUND;

    BEGIN
      log('Compiling Match Rule ' || l_rule_name || ' ... ', FALSE);
      HZ_MATCH_RULE_COMPILE.COMPILE_MATCH_RULE( l_match_rule_id,'Y',
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data) ;

      IF l_return_status = 'S' THEN
        log('Done');
      ELSE
        retcode := 1;
        log('');
        log('Error Compiling Rule : ');
        err := logerror;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        retcode := 1;
        log('');
        log('Error Compiling Rule : ');
        err := logerror(SQLERRM);
        UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_match_rule_id;
        COMMIT;
    END;
  END LOOP;
  HZ_GEN_PLSQL.new('HZ_PARTY_SEARCH','PACKAGE BODY');
  gen_wrap_pkg_body(-1);
  HZ_GEN_PLSQL.compile_code;

  IF retcode = 1 THEN
    outandlog('One or More match rules compilation had errors. Please check the log file for details');
  END IF;

  outandlog('Concurrent Program Execution completed ');
  outandlog('End Time : '|| TO_CHAR(SYSDATE, 'MM-DD-YY HH24:MI:SS'));
EXCEPTION
  WHEN OTHERS THEN
    retcode := 2;
    ROLLBACK;
    log('Errors Encountered');
    errbuf := logerror(SQLERRM);
END;

/**
* Procedure to write a message to the out file
**/
PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;

/**
* Procedure to write a message to the log file
**/
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/**
* Procedure to write a message to the out and log files
**/
PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

/**
* Function to fetch messages of the stack and log the error
* Also returns the error
**/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS

  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

PROCEDURE gen_call_api_dynamic_names IS

BEGIN
  l(' ');
  l(' FUNCTION get_attrib_id(p_str VARCHAR2)  ');
  l('   RETURN NUMBER IS  ');
  l('   l_id NUMBER;  ');
  l('   l_pl NUMBER;  ');
  l('   l_token VARCHAR2(1);  ');
  l('   BEGIN  ');
  l('        l_token := ''.'';  ');
  l('        l_pl := instrb(p_str, l_token);  ');
  l('        select attribute_id into l_id  ');
  l('        from hz_trans_attributes_b  ');
  l('        where entity_name = substrb(p_str, 0, l_pl - 1)  ');
  l('        and ATTRIBUTE_NAME = substrb(p_str, l_pl + 1);  ');
  l('        RETURN l_id;  ');
  l('   EXCEPTION WHEN NO_DATA_FOUND THEN  ');
  l('             FND_MESSAGE.SET_NAME(''AR'', ''HZ_DQM_NOATTRIB_ERROR'' ); ');
  l('             FND_MESSAGE.SET_TOKEN(''ENTITY_ATTRIBUTE'' ,p_str); ');
  l('             FND_MSG_PUB.ADD; ');
  l('             RAISE FND_API.G_EXC_ERROR; ');
  l('   END get_attrib_id;  ');

  l('  PROCEDURE call_api_dynamic_names (');
  l('      p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,');
  l('      p_rule_id               IN      NUMBER,');
  l('      p_attrib_name1            IN      VARCHAR2,');
  l('      p_attrib_name2            IN      VARCHAR2,');
  l('      p_attrib_name3            IN      VARCHAR2,');
  l('      p_attrib_name4            IN      VARCHAR2,');
  l('      p_attrib_name5            IN      VARCHAR2,');
  l('      p_attrib_name6            IN      VARCHAR2,');
  l('      p_attrib_name7            IN      VARCHAR2,');
  l('      p_attrib_name8            IN      VARCHAR2,');
  l('      p_attrib_name9            IN      VARCHAR2,');
  l('      p_attrib_name10           IN      VARCHAR2,');
  l('      p_attrib_name11           IN      VARCHAR2,');
  l('      p_attrib_name12           IN      VARCHAR2,');
  l('      p_attrib_name13           IN      VARCHAR2,');
  l('      p_attrib_name14           IN      VARCHAR2,');
  l('      p_attrib_name15           IN      VARCHAR2,');
  l('      p_attrib_name16           IN      VARCHAR2,');
  l('      p_attrib_name17           IN      VARCHAR2,');
  l('      p_attrib_name18           IN      VARCHAR2,');
  l('      p_attrib_name19           IN      VARCHAR2,');
  l('      p_attrib_name20           IN      VARCHAR2,');
  l('      p_attrib_val1           IN      VARCHAR2,');
  l('      p_attrib_val2           IN      VARCHAR2,');
  l('      p_attrib_val3           IN      VARCHAR2,');
  l('      p_attrib_val4           IN      VARCHAR2,');
  l('      p_attrib_val5           IN      VARCHAR2,');
  l('      p_attrib_val6           IN      VARCHAR2,');
  l('      p_attrib_val7           IN      VARCHAR2,');
  l('      p_attrib_val8           IN      VARCHAR2,');
  l('      p_attrib_val9           IN      VARCHAR2,');
  l('      p_attrib_val10          IN      VARCHAR2,');
  l('      p_attrib_val11          IN      VARCHAR2,');
  l('      p_attrib_val12          IN      VARCHAR2,');
  l('      p_attrib_val13          IN      VARCHAR2,');
  l('      p_attrib_val14          IN      VARCHAR2,');
  l('      p_attrib_val15          IN      VARCHAR2,');
  l('      p_attrib_val16          IN      VARCHAR2,');
  l('      p_attrib_val17          IN      VARCHAR2,');
  l('      p_attrib_val18          IN      VARCHAR2,');
  l('      p_attrib_val19          IN      VARCHAR2,');
  l('      p_attrib_val20          IN      VARCHAR2,');
  l('      p_restrict_sql          IN      VARCHAR2,');
  l('      p_api_name              IN      VARCHAR2,');
  l('      p_match_type            IN      VARCHAR2,');
  l('      p_party_id              IN      NUMBER,');
  l('      p_search_merged         IN      VARCHAR2,');
  l('      x_search_ctx_id         OUT     NUMBER,');
  l('      x_num_matches           OUT     NUMBER,');
  l('      x_return_status         OUT     VARCHAR2,');
  l('      x_msg_count             OUT     NUMBER,');
  l('      x_msg_data              OUT     VARCHAR2');
  l(' ) IS');
  l('     l_attrib_id1   NUMBER; ');
  l('       l_attrib_id2   NUMBER; ');
  l('       l_attrib_id3   NUMBER; ');
  l('       l_attrib_id4   NUMBER; ');
  l('       l_attrib_id5   NUMBER; ');
  l('       l_attrib_id6   NUMBER; ');
  l('       l_attrib_id7   NUMBER; ');
  l('       l_attrib_id8   NUMBER; ');
  l('       l_attrib_id9   NUMBER; ');
  l('       l_attrib_id10  NUMBER; ');
  l('       l_attrib_id11  NUMBER; ');
  l('       l_attrib_id12  NUMBER; ');
  l('       l_attrib_id13  NUMBER; ');
  l('       l_attrib_id14  NUMBER; ');
  l('       l_attrib_id15  NUMBER; ');
  l('       l_attrib_id16  NUMBER; ');
  l('       l_attrib_id17  NUMBER; ');
  l('       l_attrib_id18  NUMBER; ');
  l('       l_attrib_id19  NUMBER; ');
  l('       l_attrib_id20  NUMBER; ');
  l('  BEGIN');
  d(fnd_log.level_procedure,'call_api_dynamic_names(+)');
  d(fnd_log.level_statement,'Rule ID','p_rule_id ');
  l(' ');
  l('      IF (p_attrib_name1 IS NOT NULL) THEN  ');
  l('           l_attrib_id1 := get_attrib_id(p_attrib_name1); ');
  l('      END IF; ');
  l('      IF (p_attrib_name2 IS NOT NULL) THEN ');
  l('           l_attrib_id2 := get_attrib_id(p_attrib_name2); ');
  l('      END IF; ');
  l('      IF (p_attrib_name3 IS NOT NULL) THEN ');
  l('           l_attrib_id3 := get_attrib_id(p_attrib_name3); ');
  l('      END IF; ');
  l('      IF (p_attrib_name4 IS NOT NULL) THEN ');
  l('           l_attrib_id4 := get_attrib_id(p_attrib_name4); ');
  l('      END IF; ');
  l('      IF (p_attrib_name5 IS NOT NULL) THEN ');
  l('           l_attrib_id5 := get_attrib_id(p_attrib_name5); ');
  l('      END IF; ');
  l('      IF (p_attrib_name6 IS NOT NULL) THEN ');
  l('           l_attrib_id6 := get_attrib_id(p_attrib_name6); ');
  l('      END IF; ');
  l('      IF (p_attrib_name7 IS NOT NULL) THEN ');
  l('           l_attrib_id7 := get_attrib_id(p_attrib_name7); ');
  l('      END IF; ');
  l('      IF (p_attrib_name8 IS NOT NULL) THEN ');
  l('           l_attrib_id8 := get_attrib_id(p_attrib_name8); ');
  l('      END IF; ');
  l('      IF (p_attrib_name9 IS NOT NULL) THEN ');
  l('           l_attrib_id9 := get_attrib_id(p_attrib_name9); ');
  l('      END IF; ');
  l('      IF (p_attrib_name10 IS NOT NULL) THEN ');
  l('           l_attrib_id10 := get_attrib_id(p_attrib_name10); ');
  l('      END IF; ');
  l('      IF (p_attrib_name11 IS NOT NULL) THEN ');
  l('           l_attrib_id11 := get_attrib_id(p_attrib_name11); ');
  l('      END IF; ');
  l('      IF (p_attrib_name12 IS NOT NULL) THEN ');
  l('           l_attrib_id12 := get_attrib_id(p_attrib_name12); ');
  l('      END IF; ');
  l('      IF (p_attrib_name13 IS NOT NULL) THEN ');
  l('           l_attrib_id13 := get_attrib_id(p_attrib_name13); ');
  l('      END IF; ');
  l('      IF (p_attrib_name14 IS NOT NULL) THEN ');
  l('           l_attrib_id14 := get_attrib_id(p_attrib_name14); ');
  l('      END IF; ');
  l('      IF (p_attrib_name15 IS NOT NULL) THEN ');
  l('           l_attrib_id15 := get_attrib_id(p_attrib_name15); ');
  l('      END IF; ');
  l('      IF (p_attrib_name16 IS NOT NULL) THEN ');
  l('           l_attrib_id16 := get_attrib_id(p_attrib_name16); ');
  l('      END IF; ');
  l('      IF (p_attrib_name17 IS NOT NULL) THEN ');
  l('           l_attrib_id17 := get_attrib_id(p_attrib_name17); ');
  l('      END IF; ');
  l('      IF (p_attrib_name18 IS NOT NULL) THEN ');
  l('           l_attrib_id18 := get_attrib_id(p_attrib_name18);  ');
  l('      END IF; ');
  l('      IF (p_attrib_name19 IS NOT NULL) THEN ');
  l('           l_attrib_id19 := get_attrib_id(p_attrib_name19); ');
  l('      END IF; ');
  l('      IF (p_attrib_name20 IS NOT NULL) THEN ');
  l('           l_attrib_id20 := get_attrib_id(p_attrib_name20); ');
  l('      END IF; ');


  l('    hz_party_search.call_api_dynamic( ');
  l('            p_init_msg_list, p_rule_id, ');
  l('            l_attrib_id1,l_attrib_id2,l_attrib_id3,l_attrib_id4,l_attrib_id5, ');
  l('            l_attrib_id6,l_attrib_id7,l_attrib_id8,l_attrib_id9,l_attrib_id10, ');
  l('            l_attrib_id11,l_attrib_id12,l_attrib_id13,l_attrib_id14,l_attrib_id15, ');
  l('            l_attrib_id16,l_attrib_id17,l_attrib_id18,l_attrib_id19,l_attrib_id20, ');
  l('            p_attrib_val1,p_attrib_val2,p_attrib_val3,p_attrib_val4,p_attrib_val5, ');
  l('            p_attrib_val6,p_attrib_val7,p_attrib_val8,p_attrib_val9,p_attrib_val10, ');
  l('            p_attrib_val11,p_attrib_val12,p_attrib_val13,p_attrib_val14,p_attrib_val15, ');
  l('            p_attrib_val16,p_attrib_val17,p_attrib_val18,p_attrib_val19,p_attrib_val20, ');
  l('            p_restrict_sql,p_api_name,p_match_type,p_party_id,p_search_merged, ');
  l('            x_search_ctx_id,x_num_matches, x_return_status, x_msg_count, x_msg_data);  ');
  d(fnd_log.level_procedure,'call_api_dynamic_names(-)');
  gen_exception_block;
  l('  END call_api_dynamic_names; ');

END gen_call_api_dynamic_names;

---Start of Code Change for Match Rule Set
FUNCTION has_uncompiled_childern(p_rule_set_id NUMBER)
RETURN BOOLEAN
IS
CURSOR c_uncompiled_children IS
  SELECT count(unique compilation_flag) FROM HZ_MATCH_RULES_B
  WHERE  match_rule_id IN( SELECT unique condition_match_rule_id
                           FROM   HZ_MATCH_RULE_CONDITIONS
			   WHERE  match_rule_set_id = p_rule_set_id)
  AND compilation_flag <> 'C';
l_count NUMBER;

BEGIN
 OPEN  c_uncompiled_children;
 FETCH c_uncompiled_children INTO l_count;
 CLOSE c_uncompiled_children;
 IF (l_count >0 )THEN
   RETURN TRUE;
 ELSE
   RETURN FALSE;
 END IF;
END;

PROCEDURE compile_all_rulesets (
        p_cond_rule_id   IN NUMBER
) IS

  l_return_status varchar2(100)  := null;
  l_msg_count      number(15)    := 0;
  l_msg_data      varchar2(4000)  := null;

  CURSOR c_rulesets_for_compile  IS
    SELECT UNIQUE MATCH_RULE_ID,RULE_NAME FROM HZ_MATCH_RULES_VL
    WHERE COMPILATION_FLAG <> 'C'
    AND MATCH_RULE_ID IN (SELECT UNIQUE MATCH_RULE_SET_ID FROM HZ_MATCH_RULE_CONDITIONS
                          WHERE CONDITION_MATCH_RULE_ID = p_cond_rule_id)
    ;


  l_match_rule_set_id         NUMBER;
  l_rule_name HZ_MATCH_RULES_TL.RULE_NAME%TYPE;
  err VARCHAR2(2000);
  l_has_errors BOOLEAN := FALSE;
BEGIN

  -- Initialize return status and message stack
  FND_MSG_PUB.initialize;

  log('');

  OPEN c_rulesets_for_compile ;
  LOOP
    FETCH c_rulesets_for_compile INTO l_match_rule_set_id, l_rule_name;
    EXIT WHEN c_rulesets_for_compile%NOTFOUND;

    BEGIN
      log('Compiling Match Rule Set ' || l_rule_name || ' ... ', FALSE);
      HZ_MATCH_RULE_COMPILE.COMPILE_MATCH_RULE( l_match_rule_set_id,'Y',
                                               l_return_status,
                                               l_msg_count,
                                               l_msg_data) ;

      IF l_return_status = 'S' THEN
        log('Done');
      ELSE
        log('');
	l_has_errors :=TRUE;
        log('Error Compiling Rule Set: '||l_match_rule_set_id || ' msg_data='||l_msg_data);

      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        log('');
        l_has_errors :=TRUE;
        log('Error Compiling Rule Set : '||l_match_rule_set_id||' ,sqlerrm='||sqlerrm);
	UPDATE HZ_MATCH_RULES_B SET COMPILATION_FLAG = 'U' WHERE MATCH_RULE_ID = l_match_rule_set_id;
        COMMIT;
    END;
  END LOOP;
  close c_rulesets_for_compile;
 IF NOT l_has_errors THEN
  HZ_GEN_PLSQL.new('HZ_PARTY_SEARCH','PACKAGE BODY');
  gen_wrap_pkg_body(-1);
  HZ_GEN_PLSQL.compile_code;
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    log('Errors Encountered during match rule set compilation..sqlerrm='||sqlerrm);
END;

PROCEDURE pop_conditions(p_mrule_set_id	   IN  NUMBER,
			 p_api_name		   IN  VARCHAR2,
			 p_parameters		   IN  VARCHAR2,
			 p_eval_level IN  VARCHAR2)
IS

TYPE ref_conditions is ref cursor;
c_ref_conditions ref_conditions;


l_cond_string varchar2(32000);
l_add_then BOOLEAN;
l_count NUMBER;
l_value VARCHAR2(2000);
l_tmp_value varchar2(30);
l_index NUMBER;
l_sql   varchar2(1000);
l_close_if  BOOLEAN;

l_condition_match_rule_id NUMBER(15);
l_entity_name             VARCHAR2(255);
l_attribute_name          VARCHAR2(255);
l_operation               VARCHAR2(30);
l_rank                    NUMBER;

BEGIN

  IF p_eval_level = 'PARTY' THEN
    l_sql :='SELECT condition_match_rule_id,attr.entity_name,'||
            ' attr.attribute_name,operation,value,rank '||
            ' FROM   hz_match_rule_conditions cond,hz_trans_attributes_vl attr '||
            ' WHERE  cond.match_rule_set_id  = '||P_MRULE_SET_ID||
            ' AND    cond.attribute_id= attr.attribute_id (+) '||
            ' ORDER BY rank ASC';
  ELSIF p_eval_level = 'PARTY_SITES' then
    l_sql :='SELECT condition_match_rule_id,attr.entity_name,'||
            ' attr.attribute_name,operation,value,rank '||
            ' FROM   hz_match_rule_conditions cond,hz_trans_attributes_vl attr '||
            ' WHERE  cond.match_rule_set_id  = '||P_MRULE_SET_ID||
            ' AND    nvl(attr.entity_name,''XYZ'') NOT IN (''PARTY'',''CONTACTS'') '||
	    ' AND    cond.attribute_id= attr.attribute_id (+) '||
	    ' ORDER BY rank ASC';
  ELSIF p_eval_level = 'CONTACTS' then
    l_sql :='SELECT condition_match_rule_id,attr.entity_name,'||
            ' attr.attribute_name,operation,value,rank '||
            ' FROM   hz_match_rule_conditions cond,hz_trans_attributes_vl attr '||
            ' WHERE  cond.match_rule_set_id  = '||P_MRULE_SET_ID||
            ' AND    nvl(attr.entity_name,''XYZ'') NOT IN (''PARTY'',''PARTY_SITES'') '||
	    ' AND    cond.attribute_id= attr.attribute_id (+) '||
	    ' ORDER BY rank ASC';
  ELSIF p_eval_level = 'CONTACT_POINTS' then
    l_sql :='SELECT condition_match_rule_id,attr.entity_name,'||
            ' attr.attribute_name,operation,value,rank '||
            ' FROM   hz_match_rule_conditions cond,hz_trans_attributes_vl attr '||
            ' WHERE  cond.match_rule_set_id  = '||P_MRULE_SET_ID||
            ' AND    nvl(attr.entity_name,''XYZ'') NOT IN (''PARTY'',''PARTY_SITES'',''CONTACTS'') '||
	    ' AND    cond.attribute_id= attr.attribute_id (+) '||
	    ' ORDER BY rank ASC';
  ELSE
    RETURN;
  END IF;

  l_add_then    := FALSE;
  l_count       := 0;
  l_cond_string := NULL;
  l_value   := NULL;
  l_index   := 0;
  l_close_if := FALSE;
   --Start of Bug No: 4234203
  l('DECLARE');
  l(' l_condition_match_rule_id NUMBER(15);');
  l(' l_cond_rule_name VARCHAR2(255);');
  l(' CURSOR c_rule_name(p_rule_id NUMBER) IS SELECT rule_name FROM hz_match_rules_vl ');
  l(' where match_rule_id=p_rule_id ;');
  l('BEGIN');
  --End of Bug No: 4234203
  OPEN c_ref_conditions FOR l_sql;
  LOOP
    FETCH c_ref_conditions INTO l_condition_match_rule_id,l_entity_name,l_attribute_name,l_operation,
                                l_value,l_rank;
    EXIT WHEN c_ref_conditions%NOTFOUND;
     l_cond_string := NULL;
     l_count := l_count+1;
     IF l_count = 1 AND l_attribute_name IS NOT NULL THEN
        l('IF  ');
        l_add_then := TRUE;
	l_close_if := TRUE;
     ELSIF l_attribute_name IS NOT NULL THEN
        l('ELSIF  ');
        l_add_then := TRUE;
	l_close_if := TRUE;
     ELSIF l_attribute_name IS NULL AND l_add_then THEN
       l('ELSE  ');
       l_add_then := FALSE;
       l_close_if := TRUE;
     END IF;
     IF l_operation = 'LIKE' then
        l_value :=''''||HZ_TRANS_PKG.EXACT(l_value,NULL,l_attribute_name,l_entity_name)||'%''';
     ELSIF l_operation = 'IN' then
        l_tmp_value := l_value;
	l_value := NULL;
	LOOP
	 l_index := instrb(l_tmp_value,',');
	 IF l_index =0 then
	  l_value := l_value ||','''||HZ_TRANS_PKG.EXACT(l_tmp_value,NULL,l_attribute_name,l_entity_name)||'''';
	  l_value := '('||ltrim(l_value,',')||')';
	    exit;
         END IF;
	 l_value := l_value ||','''||HZ_TRANS_PKG.EXACT(substrb(l_tmp_value,1,l_index-1),NULL,l_attribute_name,l_entity_name)||'''';
	 l_tmp_value := substrb(l_tmp_value,l_index+1);
	END LOOP;

    ELSE
        l_value :=''''||HZ_TRANS_PKG.EXACT(l_value,NULL,l_attribute_name,l_entity_name)||'''';
    END IF;

    IF  l_entity_name = 'PARTY' THEN
         l_cond_string := 'HZ_TRANS_PKG.EXACT(p_party_search_rec.'||l_attribute_name||',NULL,'''||
	                   l_attribute_name||''',''PARTY'') '|| l_operation ||'  '|| l_value;
    ELSIF l_entity_name = 'PARTY_SITES' THEN
         l_cond_string := '(p_party_site_list IS NOT NULL AND p_party_site_list.COUNT >0) AND (HZ_TRANS_PKG.EXACT(p_party_site_list(1).'||
	 l_attribute_name||',NULL,'''||l_attribute_name||''',''PARTY_SITES'') '|| l_operation ||'  '|| l_value ||')';
    ELSIF l_entity_name = 'CONTACTS' THEN
         l_cond_string := '(p_contact_list IS NOT NULL AND p_contact_list.COUNT >0) AND (HZ_TRANS_PKG.EXACT(p_contact_list(1).'||
	 l_attribute_name||',NULL,'''||l_attribute_name||''',''CONTACTS'') '|| l_operation ||'  '|| l_value ||')';
    ELSIF l_entity_name = 'CONTACT_POINTS' THEN
         l_cond_string := '(p_contact_point_list IS NOT NULL AND  p_contact_point_list.COUNT >0) AND (HZ_TRANS_PKG.EXACT(p_contact_point_list(1).'||
	 l_attribute_name||',NULL,'''||l_attribute_name||''',''CONTACT_POINTS'') '|| l_operation ||'  '|| l_value ||')';
    END IF;
    IF l_add_then THEN
        l_cond_string := l_cond_string || '  THEN ';
    END IF;

    l(l_cond_string);
    l(' l_condition_match_rule_id :='|| l_condition_match_rule_id ||';'); --Bug No: 4234203
    ldbg_s('Calling '||p_api_name||' using match rule id :'||l_condition_match_rule_id); --Bug No: 4234203
    l(' HZ_MATCH_RULE_'||l_condition_match_rule_id||'.'||p_api_name||'('|| p_parameters ||');');
  END LOOP;
  CLOSE c_ref_conditions;
  IF l_close_if THEN
       l('END IF;');
  END IF;
  --Start of Bug No: 4234203
  l('EXCEPTION');
  l(' WHEN OTHERS THEN') ;
  l(' OPEN  c_rule_name(l_condition_match_rule_id);');
  l(' FETCH c_rule_name INTO l_cond_rule_name;');
  l(' CLOSE c_rule_name; ');
  l(' FND_MESSAGE.SET_NAME(''AR'', ''HZ_MATCH_RULE_SRCH_ERROR''); ');
  l(' FND_MESSAGE.SET_TOKEN(''MATCH_RULE'',l_cond_rule_name); ');
  l(' FND_MSG_PUB.ADD; ');
  l(' RAISE; ');
  l('END;');
  --End of Bug No: 4234203
END pop_conditions;
---End of Code Change for Match Rule Set

--Start of Bug No: 4162385
 FUNCTION get_entity_level_score(p_match_rule_id NUMBER,p_entity_name VARCHAR2)
 RETURN NUMBER
 IS
  l_score NUMBER;
 BEGIN
   SELECT nvl(sum(sec.score),0) INTO l_score
   FROM HZ_MATCH_RULE_SECONDARY sec,HZ_TRANS_ATTRIBUTES_VL attr
   WHERE sec.match_rule_id = p_match_rule_id
   AND   sec.attribute_id  = attr.attribute_id
   AND   attr.entity_name  =  p_entity_name;

   RETURN l_score;
 END get_entity_level_score;
--End of Bug No: 4162385

END;

/
