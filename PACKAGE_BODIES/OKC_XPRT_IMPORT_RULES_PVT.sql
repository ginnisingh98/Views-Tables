--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_IMPORT_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_IMPORT_RULES_PVT" AS
/* $Header: OKCVXRULB.pls 120.7.12010000.7 2013/07/05 07:49:35 aksgoyal ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_IMPORT_RULES_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_LEVEL_PROCEDURE            CONSTANT   NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=510; -- OKC Application

  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;


  ------------------------------------------------------------------------------
  -- Orig_sys_ref
  ------------------------------------------------------------------------------
  G_VARIABLE_MODEL_OSR            CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODEL:-99:';

  G_CLAUSE_MODEL_OSR              CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODEL:';
  G_CLAUSE_MODEL_TOPNODE_OSR      CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODELTOPNODE:' ;
  G_CLAUSE_MODEL_FEATURE_OSR      CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODELFEATURE:' ;
  G_CLAUSE_MODEL_VM_REF_NODE_OSR  CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODEL-VARIABLEMODEL-REFNODE:' ;

  G_TEMPLATE_MODEL_OSR            CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODEL:';
  G_TEMPLATE_MODEL_TOPNODE_OSR    CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODELTOPNODE:' ;
  G_TMPL_MODEL_CM_REF_NODE_OSR    CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODEL-CLAUSEMODEL-REFNODE:' ;

  G_RULE_OSR                      CONSTANT  VARCHAR2(255) := 'OKC:RULES:';
  G_XTN_RULE_OSR                  CONSTANT  VARCHAR2(255) := 'OKC:XTNRULE:';
  G_XTN_RULE_TEXT                 CONSTANT  VARCHAR2(255) := 'CALL doInputAttributeTransfer(SYSTEM_PARAMETER("BaseNode")) WHEN postConfigInit IN Global';
  G_XTN_RULE_CLASS_NAME           CONSTANT  VARCHAR2(255) := 'oracle.apps.okc.contractexpert.util.CeExtension';


/*====================================================================+
  Procedure Name : build_statement_rule
  Description    : This API builds the rule statement. It parses the rules data
                   in OKC tables and builds the rule text to be used in rule import
  Parameters:
                   p_rule_id  - Rule Id
                   p_template_id - Template Id to which the rule is attached
                   x_stmt_rule - Rule statement built by the rule parser

+====================================================================*/

PROCEDURE build_statement_rule
(
 p_rule_id                  IN NUMBER,
 p_template_id              IN NUMBER,
 x_stmt_rule                OUT NOCOPY CLOB,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
)
IS
CURSOR csr_rule_dtls IS
SELECT org_id,
       intent,
       DECODE(condition_expr_code,'ALL','AND','OR'),
       rule_type
FROM okc_xprt_rule_hdrs_all
WHERE rule_id = p_rule_id;

--DECODE(SUBSTR(rcon.object_code,1,3),'OKC',rcon.object_code,'USER$' || rcon.object_code) variable_code
CURSOR csr_rule_conditions IS
SELECT c.rule_condition_id,
       c.object_type,
       DECODE(c.object_type,
              'VARIABLE',DECODE(SUBSTR(c.object_code,1,3),'OKC',c.object_code,'USER$' || c.object_code),
              'CONSTANT','CONSTANT$' || c.object_code,
              c.object_code) object_code,
       --c.object_code,
       NVL(c.object_code_datatype,'V'),
       DECODE(c.operator,'IS','ANYTRUE',
                         'IN','ANYTRUE',
                         'IS_NOT','NOTTRUE',
                         'NOT_IN','NOTTRUE',
                         c.operator),
       c.object_value_type
FROM okc_xprt_rule_conditions c
WHERE c.rule_id = p_rule_id;

/*CURSOR csr_rule_cond_vals(p_rule_condition_id IN NUMBER) IS
SELECT v.object_value_code
FROM okc_xprt_rule_cond_vals v
WHERE v.rule_condition_id = p_rule_condition_id;*/

CURSOR csr_rule_cond_vals(p_rule_condition_id IN NUMBER) IS
SELECT DECODE(c.object_value_type,
              'VARIABLE',DECODE(SUBSTR(v.object_value_code,1,3),'OKC',v.object_value_code,'USER$' || v.object_value_code),
              'CONSTANT','CONSTANT$' || v.object_value_code,
              v.object_value_code) object_value_code
--v.object_value_code
FROM   okc_xprt_rule_cond_vals v, okc_xprt_rule_conditions c
WHERE  v.rule_condition_id = c.rule_condition_id
AND    v.rule_condition_id = p_rule_condition_id;

CURSOR csr_rule_outcomes IS
SELECT object_type,
       object_value_id
FROM okc_xprt_rule_outcomes
WHERE rule_id = p_rule_id;

l_api_name                 CONSTANT VARCHAR2(30) := 'build_statement_rule';
l_org_id                   okc_xprt_rule_hdrs_all.org_id%TYPE;
l_intent                   okc_xprt_rule_hdrs_all.intent%TYPE;
l_condition_expr_code      okc_xprt_rule_hdrs_all.condition_expr_code%TYPE;
l_rule_type		   okc_xprt_rule_hdrs_all.rule_type%TYPE;

l_rule_condition_id        okc_xprt_rule_conditions.rule_condition_id%TYPE;
l_object_type              okc_xprt_rule_conditions.object_type%TYPE;
l_object_code              okc_xprt_rule_conditions.object_code%TYPE;
l_object_code_datatype     okc_xprt_rule_conditions.object_code_datatype%TYPE;
l_operator                 okc_xprt_rule_conditions.operator%TYPE;
l_object_value_type        okc_xprt_rule_conditions.object_value_type%TYPE;

l_object_value_code        okc_xprt_rule_cond_vals.object_value_code%TYPE;

l_object_type_outcome      okc_xprt_rule_outcomes.object_type%TYPE;
l_object_value_id          okc_xprt_rule_outcomes.object_value_id%TYPE;

l_clause_prefix            VARCHAR2(4000);
l_system_var_prefix        VARCHAR2(4000);
l_question_prefix          VARCHAR2(4000);
l_deviation_prefix         VARCHAR2(4000);
-- l_stmt_rule                cz_imp_rules.rule_text%TYPE :='';
l_condition_stmt           cz_imp_rules.rule_text%TYPE ;
l_outcome_stmt             cz_imp_rules.rule_text%TYPE ;

l_temp_string              VARCHAR2(4000);

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- 8i 9i compatibility issue
  -- initialize the CLOB
  DBMS_LOB.CREATETEMPORARY(x_stmt_rule, FALSE, DBMS_LOB.CALL);

  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_org_id, l_intent, l_condition_expr_code,l_rule_type;
  CLOSE csr_rule_dtls;

  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: p_rule_id :'||p_rule_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: p_template_id :'||p_template_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: l_org_id :'||l_org_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: l_intent :'||l_intent);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: l_condition_expr_code  :'||l_condition_expr_code);
  END IF;


  --  Build Template Rule Statement

   -- Clause Prefix
   l_clause_prefix := ''''||G_TEMPLATE_MODEL_TOPNODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.'||
                       ''''||G_TMPL_MODEL_CM_REF_NODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.'||
	                  ''''||G_CLAUSE_MODEL_FEATURE_OSR||l_org_id||':'||l_intent||''''||'.' ;
   -- System Variables Prefix
   l_system_var_prefix:= ''''||G_TEMPLATE_MODEL_TOPNODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.'||
                         ''''||G_TMPL_MODEL_CM_REF_NODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.'||
                         ''''||G_CLAUSE_MODEL_VM_REF_NODE_OSR||l_org_id||':'||l_intent||''''||'.';

   -- Question Prefix
   l_question_prefix:= ''''||G_TEMPLATE_MODEL_TOPNODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.';


   -- Deviation Prefix
   l_deviation_prefix:= ''''||G_TEMPLATE_MODEL_TOPNODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.'||
                         ''''||G_TMPL_MODEL_CM_REF_NODE_OSR||l_org_id||':'||l_intent||':'||p_template_id||''''||'.'||
                         ''''||G_CLAUSE_MODEL_VM_REF_NODE_OSR||l_org_id||':'||l_intent||''''||'.';

  /*
   -- Org Rules Prefix

   -- Clause Prefix
   l_clause_prefix := ''''||G_CLAUSE_MODEL_TOPNODE_OSR||l_org_id||':'||l_intent||''''||'.'||
                      ''''||G_CLAUSE_MODEL_FEATURE_OSR||l_org_id||':'||l_intent||''''||'.';

   -- System Variables Prefix
   l_system_var_prefix := ''''||G_CLAUSE_MODEL_TOPNODE_OSR||l_org_id||':'||l_intent||''''||'.'||
                          ''''||G_CLAUSE_MODEL_VM_REF_NODE_OSR||l_org_id||':'||l_intent||''''||'.';

  */


  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '200: l_clause_prefix :'||l_clause_prefix);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '200: l_system_var_prefix :'||l_system_var_prefix);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '200: l_question_prefix :'||l_question_prefix);
  END IF;



  OPEN csr_rule_conditions;
    LOOP
      FETCH csr_rule_conditions INTO l_rule_condition_id,
                                     l_object_type,
                                     l_object_code,
                                     l_object_code_datatype,
                                     l_operator,
                                     l_object_value_type;
      EXIT WHEN csr_rule_conditions%NOTFOUND;

      -- debug log
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250: *******  Condition *********');
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250: l_rule_condition_id :'||l_rule_condition_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250: l_object_type :'||l_object_type);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250:l_object_code  :'||l_object_code);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250: l_object_code_datatype :'||l_object_code_datatype);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250: l_operator :'||l_operator);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '250: l_object_value_type  :'||l_object_value_type);
      END IF;



      -- IF x_stmt_rule IS NOT NULL THEN
      IF DBMS_LOB.getlength(x_stmt_rule) > 0 THEN
         -- x_stmt_rule := x_stmt_rule||'  '||l_condition_expr_code;
	    -- 8i 9i backward compatibility issue with clob
	    l_temp_string  := '  '||l_condition_expr_code;
	    DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);
	    --
      END IF;

	 -- Boolen is treated as Character or LOV
      -- LHS is Clause or Question / System Variable of type Character
      IF  l_object_code_datatype IN ('V','L','B') THEN
	    IF l_operator = 'ANYTRUE' THEN
             -- x_stmt_rule:= x_stmt_rule||'  '||l_operator||'  '||'(';
	        -- 8i 9i backward compatibility issue with clob
	        l_temp_string  := '  '||l_operator||'  '||'(';
	        DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);
	        --
	    ELSE
	       -- l_operator is NOTTRUE
		  --x_stmt_rule:= x_stmt_rule||'  '||'(';
	        -- 8i 9i backward compatibility issue with clob
	        l_temp_string  := '  '||'(';
	        DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);
	        --
         END IF; -- l_operator
	 /*
      ELSIF l_object_code_datatype = 'B' THEN
         -- Check N or NO
         IF l_object_value_type = 'N' THEN
            -- Boolean False
            x_stmt_rule := x_stmt_rule||'  '||'NOT'||'  '||'(';
         ELSE
            -- Boolean True
            x_stmt_rule := x_stmt_rule||'  '||'(';
         END IF; --
	  */
      ELSE
	    -- Numeric
         --x_stmt_rule:= x_stmt_rule||'  '||'(';
	    -- 8i 9i backward compatibility issue with clob
	        l_temp_string  := '  '||'(';
	        DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);
	    --
      END IF;

       -- initialize l_condition_stmt
       -- l_condition_stmt := '';
       DBMS_LOB.CREATETEMPORARY(l_condition_stmt, FALSE, DBMS_LOB.CALL);

       -- For Each Condition Get the Values and create the statement
       OPEN csr_rule_cond_vals(p_rule_condition_id => l_rule_condition_id);
         LOOP
           FETCH csr_rule_cond_vals INTO l_object_value_code;
           EXIT WHEN csr_rule_cond_vals%NOTFOUND;

              -- debug log
              IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                     G_MODULE||l_api_name,
                                     '350: #######  Condition Values #######');
                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                     G_MODULE||l_api_name,
                                     '350: l_object_value_code :'||l_object_value_code);
              END IF;


            IF l_object_type = 'CLAUSE' THEN
                -- RHS is also CLAUSE
			 IF l_operator = 'ANYTRUE' THEN
                    --IF l_condition_stmt IS NULL THEN
                    IF DBMS_LOB.getlength(l_condition_stmt) = 0 THEN
                      -- l_condition_stmt  := l_clause_prefix||''''||l_object_value_code||'''';
				  l_temp_string := l_clause_prefix||''''||l_object_value_code||'''';
				  DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                    ELSE
                      -- l_condition_stmt := l_condition_stmt||','||l_clause_prefix||''''||l_object_value_code||'''';
				  l_temp_string := ','||l_clause_prefix||''''||l_object_value_code||'''';
                      DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                    END IF; -- l_condition_stmt
			 ELSE
			   -- l_operator = NOTTRUE
			     --IF l_condition_stmt IS NULL THEN
				IF DBMS_LOB.getlength(l_condition_stmt) = 0 THEN
				   --l_condition_stmt := 'NOTTRUE('||l_clause_prefix||''''||l_object_value_code||''''||')';
				   l_temp_string := 'NOTTRUE('||l_clause_prefix||''''||l_object_value_code||''''||')';
				   DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
				ELSE
				   --l_condition_stmt := l_condition_stmt||' AND NOTTRUE('||l_clause_prefix||''''||l_object_value_code||''''||')';
				   l_temp_string := ' AND NOTTRUE('||l_clause_prefix||''''||l_object_value_code||''''||')';
                       DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
				END IF; -- l_condition_stmt
			 END IF; -- l_operator

            ELSIF l_object_type = 'VARIABLE' THEN
                IF l_object_code_datatype = 'N' THEN

                  -- RHS can be Numeric Variable / Question / Constant
                  IF l_object_value_type = 'QUESTION' THEN
                     -- RHS is Numeric Question
                     --l_condition_stmt := l_system_var_prefix||''''||l_object_code||''''||l_operator||
                     --                    l_question_prefix||''''||l_object_value_code||'''';
				 l_temp_string := l_system_var_prefix||''''||l_object_code||''''||l_operator||
                                         l_question_prefix||''''||l_object_value_code||'''';
                     DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                  ELSE
                     -- RHS is Numeric System Variable or Constant
                     --l_condition_stmt := l_system_var_prefix||''''||l_object_code||''''||l_operator||
                     --                    l_system_var_prefix||''''||l_object_value_code||'''';
                     l_temp_string := l_system_var_prefix||''''||l_object_code||''''||l_operator||
                                         l_system_var_prefix||''''||l_object_value_code||'''';
				DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);

                  END IF; -- RHS for Numeric LHS Variable

                ELSIF l_object_code_datatype IN ('V','L') THEN
                   -- RHS Can ONLY be Character System Variable Value
			    IF l_operator = 'ANYTRUE' THEN
                       --IF l_condition_stmt IS NULL THEN
				   IF DBMS_LOB.getlength(l_condition_stmt) = 0 THEN
                         --l_condition_stmt := l_system_var_prefix||''''||l_object_code||''''||'.'||
                         --                ''''||l_object_value_code||'''';
                         l_temp_string := l_system_var_prefix||''''||l_object_code||''''||'.'||
                                         ''''||l_object_value_code||'''';
					DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                       ELSE
                         --l_condition_stmt := l_condition_stmt||','||l_system_var_prefix||''''||l_object_code||
--                                         ''''||'.'||''''||l_object_value_code||'''';
                         l_temp_string := ','||l_system_var_prefix||''''||l_object_code||
                                         ''''||'.'||''''||l_object_value_code||'''';
					DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                       END IF; -- l_condition_stmt IS NULL
			    ELSE
			      -- l_operator = 'NOTTRUE'
				   --IF  l_condition_stmt IS NULL THEN
				   IF DBMS_LOB.getlength(l_condition_stmt) = 0 THEN
				      --l_condition_stmt := 'NOTTRUE('||l_system_var_prefix||''''||l_object_code||
					 --             ''''||'.'||''''||l_object_value_code||''''||')';
				      l_temp_string := 'NOTTRUE('||l_system_var_prefix||''''||l_object_code||
					              ''''||'.'||''''||l_object_value_code||''''||')';
					 DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);

				   ELSE
				      --l_condition_stmt := l_condition_stmt||' AND NOTTRUE('||l_system_var_prefix||
					--  ''''||l_object_code||''''||'.'||''''||l_object_value_code||''''||')';
				      l_temp_string := ' AND NOTTRUE('||l_system_var_prefix||
					  ''''||l_object_code||''''||'.'||''''||l_object_value_code||''''||')';
					 DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);

				   END IF; -- l_condition_stmt

			    END IF; -- l_operator


                END IF; -- RHS Type

            ELSIF l_object_type = 'QUESTION' THEN
                IF l_object_code_datatype = 'N' THEN

                    -- RHS can be Numeric Variable / Question / Constant
                  IF l_object_value_type = 'QUESTION' THEN
                     -- RHS is Numeric Question
--                     l_condition_stmt := l_question_prefix||''''||l_object_code||''''||l_operator||
--                                         l_question_prefix||''''||l_object_value_code||'''';
                      l_temp_string:= l_question_prefix||''''||l_object_code||''''||l_operator||
                                         l_question_prefix||''''||l_object_value_code||'''';
				  DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                  ELSE
                     -- RHS is Numeric System Variable or Constant
--                     l_condition_stmt := l_question_prefix||''''||l_object_code||''''||l_operator||
--                                         l_system_var_prefix||''''||l_object_value_code||'''';
                      l_temp_string := l_question_prefix||''''||l_object_code||''''||l_operator||
                                         l_system_var_prefix||''''||l_object_value_code||'''';
				  DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                  END IF; -- RHS for Numeric LHS Variable

			 /*
                ELSIF l_object_code_datatype = 'B' THEN
                     -- Boolean Question
                    l_condition_stmt := l_question_prefix||''''||l_object_code||'''';
		      */

                ELSIF l_object_code_datatype IN ('V','L','B') THEN
			    IF l_operator = 'ANYTRUE' THEN
                       --IF l_condition_stmt IS NULL THEN
				   IF DBMS_LOB.getlength(l_condition_stmt) = 0 THEN

--                         l_condition_stmt := l_question_prefix||''''||l_object_code||''''||'.'||
--                                         ''''||l_object_value_code||'''';
                         l_temp_string := l_question_prefix||''''||l_object_code||''''||'.'||
                                         ''''||l_object_value_code||'''';
					DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
                       ELSE
--                         l_condition_stmt := l_condition_stmt||','||l_question_prefix||''''||l_object_code||
--                                         ''''||'.'||''''||l_object_value_code||'''';
                         l_temp_string := ','||l_question_prefix||''''||l_object_code||
                                         ''''||'.'||''''||l_object_value_code||'''';
					DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);

                       END IF; -- l_condition_stmt IS NULL
			     ELSE
				   -- l_operator = 'NOTTRUE'
				    --IF l_condition_stmt IS NULL THEN
				    IF DBMS_LOB.getlength(l_condition_stmt) = 0 THEN
--				       l_condition_stmt := 'NOTTRUE('||l_question_prefix||''''||l_object_code||''''||'.'||
--                                         ''''||l_object_value_code||''''||')';
				       l_temp_string := 'NOTTRUE('||l_question_prefix||''''||l_object_code||''''||'.'||
                                         ''''||l_object_value_code||''''||')';
					  DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
				    ELSE
--				       l_condition_stmt := l_condition_stmt||' AND NOTTRUE('||l_question_prefix||
--					    ''''||l_object_code||''''||'.'||''''||l_object_value_code||''''||')';
				       l_temp_string := ' AND NOTTRUE('||l_question_prefix||
					    ''''||l_object_code||''''||'.'||''''||l_object_value_code||''''||')';
					  DBMS_LOB.WRITEAPPEND(l_condition_stmt,length(l_temp_string) , l_temp_string);
				    END IF; -- l_condition_stmt

				END IF; -- l_operator

                END IF; -- RHS type

            END IF;


         END LOOP;
       CLOSE csr_rule_cond_vals;

      -- x_stmt_rule:= x_stmt_rule||l_condition_stmt||')';
	    -- 8i 9i backward compatibility issue with clob
	        --l_temp_string  := l_condition_stmt||')';
	        --DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);

		   DBMS_LOB.APPEND(x_stmt_rule,l_condition_stmt);
		   DBMS_LOB.FREETEMPORARY(l_condition_stmt);
		   l_temp_string := ')';
		   DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);


	    --


    END LOOP;
  CLOSE csr_rule_conditions;


     -- debug log
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE||l_api_name,
                            '600: Building Outcome String');
        END IF;

       -- Build the Outcome String

       -- initialize l_condition_stmt
       --l_outcome_stmt := '';
	   DBMS_LOB.CREATETEMPORARY(l_outcome_stmt, FALSE, DBMS_LOB.CALL);

IF l_rule_type = 'TERM_DEVIATION' THEN
       l_object_value_id := p_rule_id;
       -- Outcome is Deviation
	IF DBMS_LOB.getlength(l_outcome_stmt) = 0 THEN

	  l_temp_string := l_deviation_prefix||''''||l_object_value_id||'''';
		   DBMS_LOB.WRITEAPPEND(l_outcome_stmt,length(l_temp_string) , l_temp_string);
	ELSE
	  l_temp_string := ','||l_deviation_prefix||''''||l_object_value_id||'''';
		   DBMS_LOB.WRITEAPPEND(l_outcome_stmt,length(l_temp_string) , l_temp_string);
	END IF;
ELSE
     -- l_rule_type is CLAUSE_SELECTION
      OPEN csr_rule_outcomes;
        LOOP
          FETCH csr_rule_outcomes INTO l_object_type_outcome , l_object_value_id ;
          EXIT WHEN csr_rule_outcomes%NOTFOUND;
             IF l_object_type_outcome = 'CLAUSE' THEN

                --IF l_outcome_stmt IS NULL THEN
			 IF DBMS_LOB.getlength(l_outcome_stmt) = 0 THEN

                  --l_outcome_stmt  := l_clause_prefix||''''||l_object_value_id||'''';
                  l_temp_string  := l_clause_prefix||''''||l_object_value_id||'''';
			   DBMS_LOB.WRITEAPPEND(l_outcome_stmt,length(l_temp_string) , l_temp_string);

                ELSE
--                  l_outcome_stmt := l_outcome_stmt||','||l_clause_prefix||''''||l_object_value_id||'''';
                   l_temp_string := ','||l_clause_prefix||''''||l_object_value_id||'''';
			    DBMS_LOB.WRITEAPPEND(l_outcome_stmt,length(l_temp_string) , l_temp_string);
                END IF;

             ELSE
               -- Outcome is Question
                --IF l_outcome_stmt IS NULL THEN
			 IF DBMS_LOB.getlength(l_outcome_stmt) = 0 THEN

                  --l_outcome_stmt := l_question_prefix||''''||l_object_value_id||'''';
                  l_temp_string := l_question_prefix||''''||l_object_value_id||'''';
			   DBMS_LOB.WRITEAPPEND(l_outcome_stmt,length(l_temp_string) , l_temp_string);
                ELSE
                  --l_outcome_stmt := l_outcome_stmt||','||l_question_prefix||''''||l_object_value_id||'''';
                  l_temp_string := ','||l_question_prefix||''''||l_object_value_id||'''';
			   DBMS_LOB.WRITEAPPEND(l_outcome_stmt,length(l_temp_string) , l_temp_string);

                END IF;

             END IF;
        END LOOP;
      CLOSE csr_rule_outcomes;
END IF;

      -- debug log
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                              G_MODULE||l_api_name,
                              '750: After Building Outcome String ');
         END IF;


--LCT Fix
/*        OPEN csr_rule_outcomes;
         LOOP   FETCH csr_rule_outcomes INTO l_object_type_outcome , l_object_value_id ;
        CLOSE csr_rule_outcomes;

        IF l_object_type_outcome = 'QUESTION' THEN
         l_temp_string  := '  '||'REQUIRES ALLTRUE'||'  '||'(';
        ELSE
         l_temp_string  := '  '||'IMPLIES ALLTRUE'||'  '||'(';
        END IF;


  */
     --x_stmt_rule:= x_stmt_rule||'  '||'IMPLIES ALLTRUE'||'  '||'('||l_outcome_stmt||')';
	    -- 8i 9i backward compatibility issue with clob
--	        l_temp_string  := '  '||'IMPLIES ALLTRUE'||'  '||'(';
	        l_temp_string  := '  '||'REQUIRES ALLTRUE'||'  '||'(';
		   DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);

		   DBMS_LOB.APPEND(x_stmt_rule,l_outcome_stmt);
		   DBMS_LOB.FREETEMPORARY(l_outcome_stmt);
		   l_temp_string := ')';
		   DBMS_LOB.WRITEAPPEND(x_stmt_rule,length(l_temp_string) , l_temp_string);


	    --


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

	 fnd_file.put_line(FND_FILE.LOG,'  ');
	 fnd_file.put_line(FND_FILE.LOG,'Error in build_statement_rule '||SQLERRM);
	 fnd_file.put_line(FND_FILE.LOG,'  ');

      x_return_status := G_RET_STS_ERROR ;
      x_msg_data := SQLERRM;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

	 fnd_file.put_line(FND_FILE.LOG,'  ');
	 fnd_file.put_line(FND_FILE.LOG,'Unexpected Error in build_statement_rule '||SQLERRM);
	 fnd_file.put_line(FND_FILE.LOG,'  ');

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      x_msg_data := SQLERRM;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

	 fnd_file.put_line(FND_FILE.LOG,'  ');
	 fnd_file.put_line(FND_FILE.LOG,'Other Error in build_statement_rule '||SQLERRM);
	 fnd_file.put_line(FND_FILE.LOG,'  ');

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLERRM;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END build_statement_rule;


/*====================================================================+
  Procedure Name : build_and_insert_rule
  Description    : This API calls build_statement_rule to build  the rule statement.
                   It then inserts the statement into cz_imp_rules
  Parameters:
                   p_rule_id  - Rule Id
                   p_template_id - Template Id to which the rule is attached
			    p_run_id - Run Id for rules import
			    p_mode - Publish or Disable i.e P or D

+====================================================================*/


PROCEDURE build_and_insert_rule
(
 p_rule_id                  IN VARCHAR2,
 p_template_id              IN NUMBER,
 p_run_id                   IN NUMBER,
 p_mode                     IN VARCHAR2,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
) IS

CURSOR csr_rule_dtls IS
SELECT r.rule_id,
       r.org_id,
       r.intent,
       r.rule_name,
       r.rule_description,
       DECODE(p_mode,'P','0','D','1') deleted_flag,
       r.rule_type
FROM okc_xprt_rule_hdrs_all r
WHERE r.rule_id = p_rule_id ;

CURSOR csr_template_dtls IS
SELECT template_name,
       DECODE(parent_template_id, NULL, template_id, parent_template_id)
FROM OKC_TERMS_TEMPLATES_ALL
WHERE template_id = p_template_id ;

/*
CURSOR csr_template_model_id(p_org_id  IN NUMBER,
                             p_intent  IN VARCHAR2,
                             p_tmpl_id IN NUMBER) IS
*/
CURSOR csr_template_model_id(p_orig_sys_ref  IN VARCHAR2) IS
SELECT devl_project_id ,
       orig_sys_ref
FROM cz_devl_projects
WHERE orig_sys_ref = p_orig_sys_ref
  AND devl_project_id = persistent_project_id
  AND deleted_flag = 0 ;

-- WHERE orig_sys_ref = G_TEMPLATE_MODEL_OSR||p_org_id||':'||p_intent||':'||p_tmpl_id

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_api_name                CONSTANT VARCHAR2(30) := 'build_and_insert_rule';
l_rule_id                 okc_xprt_rule_hdrs_all.rule_id%TYPE;
l_org_id                  okc_xprt_rule_hdrs_all.org_id%TYPE;
l_intent                  okc_xprt_rule_hdrs_all.intent%TYPE;
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_rule_description        okc_xprt_rule_hdrs_all.rule_description%TYPE;
l_rule_type		  okc_xprt_rule_hdrs_all.rule_type%TYPE;
l_deleted_flag            cz_imp_rules.deleted_flag%TYPE;

l_rule_text               cz_imp_rules.rule_text%TYPE;
l_language                FND_LANGUAGES.LANGUAGE_CODE%TYPE;


l_template_name            OKC_TERMS_TEMPLATES_ALL.template_name%TYPE;
l_template_id              OKC_TERMS_TEMPLATES_ALL.template_id%TYPE;

l_cz_imp_rules            cz_imp_rules%ROWTYPE;
l_tmpl_orig_sys_ref        cz_devl_projects.orig_sys_ref%TYPE;

l_model_id                 cz_devl_projects.devl_project_id%TYPE :=NULL;
l_model_osr                cz_devl_projects.orig_sys_ref%TYPE := NULL;


BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_rule_id : '||p_rule_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_template_id : '||p_template_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_run_id : '||p_run_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_mode : '||p_mode);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Get the Rule Details
  OPEN csr_rule_dtls;
      FETCH csr_rule_dtls INTO  l_rule_id,
                                l_org_id,
                                l_intent,
                                l_rule_name,
                                l_rule_description,
                                l_deleted_flag,
                                l_rule_type;
  CLOSE csr_rule_dtls;

  -- Get the Template Details
        OPEN csr_template_dtls;
          FETCH csr_template_dtls INTO l_template_name,
                                       l_template_id;

            IF csr_template_dtls%NOTFOUND THEN
               -- debug Log
               IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                  G_MODULE||l_api_name,
                                  '110: Invalid Template Id: '||p_template_id);
               END IF;
               FND_MESSAGE.set_name('OKC','OKC_XPRT_INVALID_TEMPLATE');
               RAISE FND_API.G_EXC_ERROR;
            END IF;

        CLOSE csr_template_dtls;

	-- build the template OSR
	    l_tmpl_orig_sys_ref := G_TEMPLATE_MODEL_OSR||l_org_id||':'||l_intent||':'||l_template_id;

   -- Get Template Model Details
		/*
          OPEN csr_template_model_id(p_org_id  => l_org_id,
                                     p_intent  => l_intent,
                                     p_tmpl_id => l_template_id);
          */

          OPEN csr_template_model_id(p_orig_sys_ref => l_tmpl_orig_sys_ref);

            FETCH csr_template_model_id INTO l_model_id, l_model_osr;

               IF csr_template_model_id%NOTFOUND THEN
                  -- debug Log
                  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                     G_MODULE||l_api_name,
                                     '110: Template Model Does Not Exists : '||l_template_name);
                  END IF;
                  FND_MESSAGE.set_name('OKC','OKC_XPRT_INVALID_TMPL_MODEL');
                  FND_MESSAGE.set_token('TEMPLATE_NAME',l_template_name);
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

          CLOSE csr_template_model_id;

          -- debug Log
             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                G_MODULE||l_api_name,
                                '120: Template Name : '||l_template_name);
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                G_MODULE||l_api_name,
                                '120: Derived Template Id : '||l_template_id);
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                G_MODULE||l_api_name,
                                '120: Template Model Id : '||l_model_id);
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                G_MODULE||l_api_name,
                                '120: Template Model OSR : '||l_model_osr);
             END IF;

      -- For Rules to be deleted, rule text is NOT required
        IF l_deleted_flag = '1' THEN
           -- l_rule_text := NULL;
           DBMS_LOB.CREATETEMPORARY(l_rule_text, FALSE, DBMS_LOB.CALL);
        ELSE


           -- Generate the Rule Text for this Rule Id
              build_statement_rule
              (
               p_rule_id                => l_rule_id,
               p_template_id            => l_template_id,
               x_stmt_rule              => l_rule_text,
               x_return_status	   => x_return_status,
               x_msg_data	           => x_msg_data,
               x_msg_count	           => x_msg_count
              ) ;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

        END IF; -- rule text generation

      -- Insert Rule Name into cz_imp_localized_texts

          OPEN csr_installed_languages;
            LOOP
              FETCH csr_installed_languages INTO l_language;
              EXIT WHEN csr_installed_languages%NOTFOUND;

             -- Insert into cz_imp_localized_text

                  INSERT INTO CZ_IMP_LOCALIZED_TEXTS
                  (
                   LAST_UPDATE_LOGIN,
                   LOCALE_ID,
                   LOCALIZED_STR,
                   INTL_TEXT_ID,
                   CREATION_DATE,
                   LAST_UPDATE_DATE,
                   DELETED_FLAG,
                   EFF_FROM,
                   EFF_TO,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   SECURITY_MASK,
                   EFF_MASK,
                   CHECKOUT_USER,
                   LANGUAGE,
                   ORIG_SYS_REF,
                   SOURCE_LANG,
                   RUN_ID,
                   REC_STATUS,
                   DISPOSITION,
                   MODEL_ID,
                   FSK_DEVLPROJECT_1_1,
                   MESSAGE,
                   SEEDED_FLAG
                  )
                  VALUES
                  (
                  FND_GLOBAL.LOGIN_ID,  --LAST_UPDATE_LOGIN
                  NULL, -- LOCALE_ID
                  l_rule_name,  --LOCALIZED_STR
                  NULL, -- INTL_TEXT_ID
                  SYSDATE, -- CREATION_DATE
                  SYSDATE, -- LAST_UPDATE_DATE
                  '0', -- DELETED_FLAG
                  NULL, -- EFF_FROM
                  NULL, -- EFF_TO
                  FND_GLOBAL.USER_ID, -- CREATED_BY
                  FND_GLOBAL.USER_ID, -- LAST_UPDATED_BY
                  NULL, -- SECURITY_MASK
                  NULL, -- EFF_MASK
                  NULL, -- CHECKOUT_USER
                  l_language,  --LANGUAGE
                  G_RULE_OSR||l_org_id||':'||l_intent||':'||l_template_id||':'||l_rule_type||':'||l_rule_id, --ORIG_SYS_REF
                  USERENV('LANG'),  --SOURCE_LANG
                  p_run_id, -- RUN_ID
                  NULL, -- REC_STATUS
                  NULL, -- DISPOSITION
                  l_model_id, -- MODEL_ID
                  l_model_osr, --FSK_DEVLPROJECT_1_1
                  NULL, -- MESSAGE
                  NULL -- SEEDED_FLAG
                  );

            END LOOP; -- for all installed languages
           CLOSE csr_installed_languages;

        -- Populate the cz_imp_rules record

           l_cz_imp_rules.RULE_ID  := NULL;
           l_cz_imp_rules.SUB_CONS_ID  := NULL;
           l_cz_imp_rules.REASON_ID  := NULL;
           l_cz_imp_rules.AMOUNT_ID  := NULL;
           l_cz_imp_rules.GRID_ID  := NULL;
           l_cz_imp_rules.RULE_FOLDER_ID  := NULL;
           l_cz_imp_rules.DEVL_PROJECT_ID  := l_model_id;
           l_cz_imp_rules.INVALID_FLAG  := NULL;
           l_cz_imp_rules.DESC_TEXT  := l_rule_description;
           l_cz_imp_rules.NAME  := l_rule_name;  -- check
           l_cz_imp_rules.ANTECEDENT_ID  := NULL;
           l_cz_imp_rules.CONSEQUENT_ID  := NULL;
           l_cz_imp_rules.RULE_TYPE  := 200; -- Expression Rule
           l_cz_imp_rules.EXPR_RULE_TYPE  := NULL;
           l_cz_imp_rules.COMPONENT_ID  := NULL;
           l_cz_imp_rules.REASON_TYPE  := 0; -- Value in reason_id corresponds to Name of Rule
           l_cz_imp_rules.DISABLED_FLAG  := NULL;
           l_cz_imp_rules.ORIG_SYS_REF  := G_RULE_OSR||l_org_id||':'||l_intent||':'||l_template_id||':'||l_rule_type||':'||l_rule_id; --ORIG_SYS_REF
           l_cz_imp_rules.CREATION_DATE  := SYSDATE;
           l_cz_imp_rules.LAST_UPDATE_DATE  := SYSDATE;
           l_cz_imp_rules.DELETED_FLAG  := l_deleted_flag; -- check
           l_cz_imp_rules.EFF_FROM  := NULL;
           l_cz_imp_rules.EFF_TO  := NULL;
           l_cz_imp_rules.CREATED_BY  := FND_GLOBAL.USER_ID;
           l_cz_imp_rules.LAST_UPDATED_BY  := FND_GLOBAL.USER_ID;
           l_cz_imp_rules.SECURITY_MASK  := NULL;
           l_cz_imp_rules.EFF_MASK  := NULL;
           l_cz_imp_rules.CHECKOUT_USER  := NULL;
           l_cz_imp_rules.LAST_UPDATE_LOGIN  := FND_GLOBAL.LOGIN_ID;
           l_cz_imp_rules.EFFECTIVE_USAGE_MASK  := NULL;
           l_cz_imp_rules.SEQ_NBR  := NULL;
           l_cz_imp_rules.EFFECTIVE_FROM  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
           l_cz_imp_rules.EFFECTIVE_UNTIL  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;
           l_cz_imp_rules.PERSISTENT_RULE_ID  := NULL;
           l_cz_imp_rules.EFFECTIVITY_SET_ID  := NULL;
           l_cz_imp_rules.RULE_FOLDER_TYPE  := NULL;
           l_cz_imp_rules.UNSATISFIED_MSG_ID  := NULL;
           l_cz_imp_rules.UNSATISFIED_MSG_SOURCE  := NULL;
           l_cz_imp_rules.SIGNATURE_ID  := NULL;
           l_cz_imp_rules.TEMPLATE_PRIMITIVE_FLAG  := NULL;
           l_cz_imp_rules.PRESENTATION_FLAG  := NULL;
           l_cz_imp_rules.TEMPLATE_TOKEN  := NULL;
           l_cz_imp_rules.RULE_TEXT  := l_rule_text;
           l_cz_imp_rules.NOTES  := NULL;
           l_cz_imp_rules.CLASS_NAME  := NULL;
           l_cz_imp_rules.INSTANTIATION_SCOPE  := NULL;
           l_cz_imp_rules.MODEL_REF_EXPL_ID  := NULL;
           l_cz_imp_rules.MUTABLE_FLAG  := NULL;
           l_cz_imp_rules.SEEDED_FLAG  := NULL;
           l_cz_imp_rules.UI_DEF_ID  := NULL;
           l_cz_imp_rules.UI_PAGE_ID  := NULL;
           l_cz_imp_rules.UI_PAGE_ELEMENT_ID  := NULL;
           l_cz_imp_rules.MESSAGE  := NULL;
           l_cz_imp_rules.RUN_ID  := p_run_id;
           l_cz_imp_rules.DISPOSITION  := NULL;
           l_cz_imp_rules.REC_STATUS  := NULL;
           l_cz_imp_rules.FSK_DEVL_PROJECT  := l_model_osr;
           l_cz_imp_rules.FSK_LOCALIZED_TEXT_1  := G_RULE_OSR||l_org_id||':'||l_intent||':'||l_template_id||':'||l_rule_type||':'||l_rule_id;
           l_cz_imp_rules.FSK_LOCALIZED_TEXT_2  := NULL;
           l_cz_imp_rules.IMPORT_PROG_VERSION  := NULL;
           l_cz_imp_rules.FSK_COMPONENT_ID  := NULL;
           l_cz_imp_rules.FSK_MODEL_REF_EXPL_ID  := NULL;

      -- Insert into cz_imp_rules

                INSERT INTO cz_imp_rules
                (
                RULE_ID,
                SUB_CONS_ID,
                REASON_ID,
                AMOUNT_ID,
                GRID_ID,
                RULE_FOLDER_ID,
                DEVL_PROJECT_ID,
                INVALID_FLAG,
                DESC_TEXT,
                NAME,
                ANTECEDENT_ID,
                CONSEQUENT_ID,
                RULE_TYPE,
                EXPR_RULE_TYPE,
                COMPONENT_ID,
                REASON_TYPE,
                DISABLED_FLAG,
                ORIG_SYS_REF,
                CREATION_DATE,
                LAST_UPDATE_DATE,
                DELETED_FLAG,
                EFF_FROM,
                EFF_TO,
                CREATED_BY,
                LAST_UPDATED_BY,
                SECURITY_MASK,
                EFF_MASK,
                CHECKOUT_USER,
                LAST_UPDATE_LOGIN,
                EFFECTIVE_USAGE_MASK,
                SEQ_NBR,
                EFFECTIVE_FROM,
                EFFECTIVE_UNTIL,
                PERSISTENT_RULE_ID,
                EFFECTIVITY_SET_ID,
                RULE_FOLDER_TYPE,
                UNSATISFIED_MSG_ID,
                UNSATISFIED_MSG_SOURCE,
                SIGNATURE_ID,
                TEMPLATE_PRIMITIVE_FLAG,
                PRESENTATION_FLAG,
                TEMPLATE_TOKEN,
                RULE_TEXT,
                NOTES,
                CLASS_NAME,
                INSTANTIATION_SCOPE,
                MODEL_REF_EXPL_ID,
                MUTABLE_FLAG,
                SEEDED_FLAG,
                UI_DEF_ID,
                UI_PAGE_ID,
                UI_PAGE_ELEMENT_ID,
                MESSAGE,
                RUN_ID,
                DISPOSITION,
                REC_STATUS,
                FSK_DEVL_PROJECT,
                FSK_LOCALIZED_TEXT_1,
                FSK_LOCALIZED_TEXT_2,
                IMPORT_PROG_VERSION,
                FSK_COMPONENT_ID,
                FSK_MODEL_REF_EXPL_ID
                )
                VALUES
                (
                l_cz_imp_rules.RULE_ID,
                l_cz_imp_rules.SUB_CONS_ID,
                l_cz_imp_rules.REASON_ID,
                l_cz_imp_rules.AMOUNT_ID,
                l_cz_imp_rules.GRID_ID,
                l_cz_imp_rules.RULE_FOLDER_ID,
                l_cz_imp_rules.DEVL_PROJECT_ID,
                l_cz_imp_rules.INVALID_FLAG,
                l_cz_imp_rules.DESC_TEXT,
                l_cz_imp_rules.NAME,
                l_cz_imp_rules.ANTECEDENT_ID,
                l_cz_imp_rules.CONSEQUENT_ID,
                l_cz_imp_rules.RULE_TYPE,
                l_cz_imp_rules.EXPR_RULE_TYPE,
                l_cz_imp_rules.COMPONENT_ID,
                l_cz_imp_rules.REASON_TYPE,
                l_cz_imp_rules.DISABLED_FLAG,
                l_cz_imp_rules.ORIG_SYS_REF,
                l_cz_imp_rules.CREATION_DATE,
                l_cz_imp_rules.LAST_UPDATE_DATE,
                l_cz_imp_rules.DELETED_FLAG,
                l_cz_imp_rules.EFF_FROM,
                l_cz_imp_rules.EFF_TO,
                l_cz_imp_rules.CREATED_BY,
                l_cz_imp_rules.LAST_UPDATED_BY,
                l_cz_imp_rules.SECURITY_MASK,
                l_cz_imp_rules.EFF_MASK,
                l_cz_imp_rules.CHECKOUT_USER,
                l_cz_imp_rules.LAST_UPDATE_LOGIN,
                l_cz_imp_rules.EFFECTIVE_USAGE_MASK,
                l_cz_imp_rules.SEQ_NBR,
                l_cz_imp_rules.EFFECTIVE_FROM,
                l_cz_imp_rules.EFFECTIVE_UNTIL,
                l_cz_imp_rules.PERSISTENT_RULE_ID,
                l_cz_imp_rules.EFFECTIVITY_SET_ID,
                l_cz_imp_rules.RULE_FOLDER_TYPE,
                l_cz_imp_rules.UNSATISFIED_MSG_ID,
                l_cz_imp_rules.UNSATISFIED_MSG_SOURCE,
                l_cz_imp_rules.SIGNATURE_ID,
                l_cz_imp_rules.TEMPLATE_PRIMITIVE_FLAG,
                l_cz_imp_rules.PRESENTATION_FLAG,
                l_cz_imp_rules.TEMPLATE_TOKEN,
                l_cz_imp_rules.RULE_TEXT,
                l_cz_imp_rules.NOTES,
                l_cz_imp_rules.CLASS_NAME,
                l_cz_imp_rules.INSTANTIATION_SCOPE,
                l_cz_imp_rules.MODEL_REF_EXPL_ID,
                l_cz_imp_rules.MUTABLE_FLAG,
                l_cz_imp_rules.SEEDED_FLAG,
                l_cz_imp_rules.UI_DEF_ID,
                l_cz_imp_rules.UI_PAGE_ID,
                l_cz_imp_rules.UI_PAGE_ELEMENT_ID,
                l_cz_imp_rules.MESSAGE,
                l_cz_imp_rules.RUN_ID,
                l_cz_imp_rules.DISPOSITION,
                l_cz_imp_rules.REC_STATUS,
                l_cz_imp_rules.FSK_DEVL_PROJECT,
                l_cz_imp_rules.FSK_LOCALIZED_TEXT_1,
                l_cz_imp_rules.FSK_LOCALIZED_TEXT_2,
                l_cz_imp_rules.IMPORT_PROG_VERSION,
                l_cz_imp_rules.FSK_COMPONENT_ID,
                l_cz_imp_rules.FSK_MODEL_REF_EXPL_ID
                );




-- Free the CLOB Memory now
DBMS_LOB.FREETEMPORARY(l_rule_text);

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

	 fnd_file.put_line(FND_FILE.LOG,'  ');
	 fnd_file.put_line(FND_FILE.LOG,'Other Error in build_statement_rule '||SQLERRM);
	 fnd_file.put_line(FND_FILE.LOG,'  ');

      x_return_status := G_RET_STS_ERROR ;
      x_msg_data := SQLERRM;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

	 fnd_file.put_line(FND_FILE.LOG,'  ');
	 fnd_file.put_line(FND_FILE.LOG,'Unexpected Error in build_and_insert_rule '||SQLERRM);
	 fnd_file.put_line(FND_FILE.LOG,'  ');

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      x_msg_data := SQLERRM;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

	 fnd_file.put_line(FND_FILE.LOG,'  ');
	 fnd_file.put_line(FND_FILE.LOG,'Other Error in build_and_insert_rule '||SQLERRM);
	 fnd_file.put_line(FND_FILE.LOG,'  ');

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLERRM;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END build_and_insert_rule;


/*====================================================================+
  Procedure Name : import_rules_publish
  Description    : This API is called from Publish Rules concurrent program

  Parameters:
+====================================================================*/

PROCEDURE import_rules_publish
(
 x_run_id                   OUT NOCOPY NUMBER,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
) IS

-- Rules to be Published
CURSOR csr_rules IS
SELECT rule_id,
       published_flag
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;

-- Templates Attached to each Rule
CURSOR csr_templates(p_rule_id IN NUMBER) IS
-- Local Rules
SELECT r.template_id
  FROM OKC_TERMS_TEMPLATES_ALL t,
       okc_xprt_template_rules r
 WHERE r.template_id = t.template_id
   AND t.status_code IN ('APPROVED','ON_HOLD')
   AND t.contract_expert_enabled = 'Y'
   AND NVL(r.deleted_flag,'N') = 'N'
   AND r.rule_id = p_rule_id
UNION ALL
-- Org Wide Rules
SELECT t.template_id
  FROM OKC_TERMS_TEMPLATES_ALL t,
       okc_xprt_rule_hdrs_all r
 WHERE  t.org_id = r.org_id
   AND  t.intent = r.intent
   AND  t.contract_expert_enabled = 'Y'
   AND  t.status_code IN ('APPROVED','ON_HOLD')
   AND  NVL(r.org_wide_flag,'N') = 'Y'
   AND  r.rule_id = p_rule_id ;

-- If the Rule was already published to CZ, get the list of templates that were
-- associated to the Rule in last publication
-- From the above list MINUS the templates currently associated to Rule
-- This would give be the list of templates from which rule association is to be deleted

CURSOR csr_templates_to_delete(p_rule_id IN NUMBER) IS
-- Templates already pushed to CZ in previous publication
-- Changed for R12
SELECT SUBSTR(orig_sys_ref, INSTR(orig_sys_ref,':',-1,3)+1,
               (INSTR(orig_sys_ref,':',-1,2) - (INSTR(orig_sys_ref,':',-1,3)+1))
            )
  FROM cz_rules
 WHERE SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1) = to_char(p_rule_id)
   AND rule_type = 200 -- Added for Bug 5005681
   AND rule_id = persistent_rule_id
   AND deleted_flag = '0'
MINUS
-- list of templates to which the rule is currently attached
(
-- Local Rules
SELECT to_char(r.template_id)
  FROM OKC_TERMS_TEMPLATES_ALL t,
       okc_xprt_template_rules r
 WHERE r.template_id = t.template_id
   AND t.status_code IN ('APPROVED','ON_HOLD')
   AND t.contract_expert_enabled = 'Y'
   AND NVL(r.deleted_flag,'N') = 'N'
   AND r.rule_id = p_rule_id
UNION ALL
-- Org Wide Rules
SELECT to_char(t.template_id)
  FROM OKC_TERMS_TEMPLATES_ALL t,
       okc_xprt_rule_hdrs_all r
       --,okc_xprt_template_rules tr -- Added for Bug 5005681
 WHERE  t.org_id = r.org_id
   --AND  tr.template_id = t.template_id -- Added for Bug 5005681
   --AND  tr.rule_id = r.rule_id         -- Added for Bug 5005681
   AND  t.intent = r.intent
   AND  t.contract_expert_enabled = 'Y'
   AND  t.status_code IN ('APPROVED','ON_HOLD')
   AND  NVL(r.org_wide_flag,'N') = 'Y'
   AND  r.rule_id = p_rule_id
);

-- Generate Run Id for Rule Import
CURSOR csr_cz_run_id IS
SELECT cz_xfr_run_infos_s.NEXTVAL
FROM dual;


l_api_name                CONSTANT VARCHAR2(30) := 'import_rules_publish';
l_rule_id                 okc_xprt_template_rules.rule_id%TYPE;
l_template_id             okc_xprt_template_rules.template_id%TYPE;
l_published_flag          okc_xprt_rule_hdrs_all.published_flag%TYPE;


BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Generate the Run Id
   OPEN csr_cz_run_id;
     FETCH csr_cz_run_id INTO x_run_id;
   CLOSE csr_cz_run_id;

  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Rule Import x_run_id  : '|| x_run_id);
  END IF;


  OPEN csr_rules;
    LOOP
      FETCH csr_rules INTO l_rule_id,l_published_flag;
	 EXIT WHEN csr_rules%NOTFOUND;
	   -- For each Rule get all templates currently attached
	   OPEN csr_templates(p_rule_id => l_rule_id);
	     LOOP
		  FETCH csr_templates INTO l_template_id;
		  EXIT WHEN csr_templates%NOTFOUND;

		  build_and_insert_rule
            (
             p_rule_id                  => l_rule_id,
             p_template_id              => l_template_id,
             p_run_id                   => x_run_id,
             p_mode                     => 'P', -- Publish
             x_return_status            => x_return_status,
             x_msg_data                 => x_msg_data,
             x_msg_count                => x_msg_count
            );

		   --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;


		END LOOP; -- Template Csr
	   CLOSE csr_templates;  -- current templates

	   -- If the Rule was already published, get the difference between current templates
	   -- and templates that were attached to Rule in the previous CZ publication
	   IF l_published_flag = 'Y' THEN
     	     OPEN csr_templates_to_delete(p_rule_id => l_rule_id);
     	       LOOP
     		    FETCH csr_templates_to_delete INTO l_template_id;
           		  EXIT WHEN csr_templates_to_delete%NOTFOUND;

           		 build_and_insert_rule
                     (
                      p_rule_id                  => l_rule_id,
                      p_template_id              => l_template_id,
                      p_run_id                   => x_run_id,
                      p_mode                     => 'D', -- to be deleted
                      x_return_status            => x_return_status,
                      x_msg_data                 => x_msg_data,
                      x_msg_count                => x_msg_count
                     );

     		       --- If any errors happen abort API
                      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;


     	       END LOOP; -- csr_templates_to_delete
     	     CLOSE csr_templates_to_delete;  -- old templates

	   END IF; -- l_published_flag = 'Y'



    END LOOP; -- Rules Csr
  CLOSE csr_rules;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END import_rules_publish;

/*====================================================================+
  Procedure Name : import_rules_disable
  Description    : This API is called from Disable Rules concurrent program

  Parameters:
+====================================================================*/

PROCEDURE import_rules_disable
(
 x_run_id                   OUT NOCOPY NUMBER,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
) IS

-- Rules to be Disabled
CURSOR csr_rules IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;

/*
  In case of rules to be disabled we look at the template assciation of the rule is CZ
  and delete the same
*/
CURSOR csr_templates_to_delete(p_rule_id IN NUMBER) IS
-- Templates already pushed to CZ in previous publication
-- Changed for R12
-- Updated the substr for bug 4676800
SELECT SUBSTR(orig_sys_ref, INSTR(orig_sys_ref,':',-1,3)+1,
               (INSTR(orig_sys_ref,':',-1,2) - (INSTR(orig_sys_ref,':',-1,3)+1))
            )
  FROM cz_rules
 WHERE SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1) = to_char(p_rule_id)
   AND rule_id = persistent_rule_id
   AND deleted_flag = '0'
   AND rule_type = 200; --Added for perf Bug#5032335

-- Generate Run Id for Rule Import
CURSOR csr_cz_run_id IS
SELECT cz_xfr_run_infos_s.NEXTVAL
FROM dual;


l_api_name                CONSTANT VARCHAR2(30) := 'import_rules_disable';
l_rule_id                 okc_xprt_template_rules.rule_id%TYPE;
l_template_id             okc_xprt_template_rules.template_id%TYPE;


BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Generate the Run Id
   OPEN csr_cz_run_id;
     FETCH csr_cz_run_id INTO x_run_id;
   CLOSE csr_cz_run_id;

  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Rule Import x_run_id  : '|| x_run_id);
  END IF;


  OPEN csr_rules;
    LOOP
      FETCH csr_rules INTO l_rule_id;
	 EXIT WHEN csr_rules%NOTFOUND;

     	     OPEN csr_templates_to_delete(p_rule_id => l_rule_id);
     	       LOOP
     		    FETCH csr_templates_to_delete INTO l_template_id;
           		  EXIT WHEN csr_templates_to_delete%NOTFOUND;

           		 build_and_insert_rule
                     (
                      p_rule_id                  => l_rule_id,
                      p_template_id              => l_template_id,
                      p_run_id                   => x_run_id,
                      p_mode                     => 'D', -- to be deleted
                      x_return_status            => x_return_status,
                      x_msg_data                 => x_msg_data,
                      x_msg_count                => x_msg_count
                     );

     		       --- If any errors happen abort API
                      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;


     	       END LOOP; -- csr_templates_to_delete
     	     CLOSE csr_templates_to_delete;  -- old templates




    END LOOP; -- Rules Csr
  CLOSE csr_rules;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END import_rules_disable;


/*====================================================================+
  Procedure Name : import_rule_temp_approval
  Description    : This API is called from template approval concurrent program

  Parameters:
                 p_template_id - Template Id to be imported
+====================================================================*/

PROCEDURE import_rule_temp_approval
(
 p_template_id             IN NUMBER,
 x_run_id                  OUT NOCOPY NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_msg_data                OUT NOCOPY VARCHAR2,
 x_msg_count               OUT NOCOPY NUMBER
) IS

CURSOR csr_template_rules IS
-- Local Active Rules for template
SELECT r.rule_id
  FROM okc_xprt_template_rules r,
       okc_xprt_rule_hdrs_all h
 WHERE r.rule_id = h.rule_id
   AND h.status_code = 'ACTIVE'
   AND NVL(r.deleted_flag,'N') = 'N'
   AND r.template_id = p_template_id
UNION ALL
-- Global Active Rules for the template
SELECT r.rule_id
  FROM OKC_TERMS_TEMPLATES_ALL t,
       okc_xprt_rule_hdrs_all r
 WHERE  t.org_id = r.org_id
   AND  t.intent = r.intent
   AND  NVL(r.org_wide_flag,'N') = 'Y'
   AND  r.status_code = 'ACTIVE'
   AND  t.template_id = p_template_id ;

CURSOR csr_parent_tmpl_rules(p_parent_tmpl_id IN NUMBER) IS
-- Local Active Rules on Parent Template to be deleted
-- Delete rules on parent template and not on the revision template
SELECT r.rule_id
  FROM okc_xprt_template_rules r,
        okc_xprt_rule_hdrs_all h
 WHERE r.rule_id = h.rule_id
   AND h.status_code = 'ACTIVE'
   AND NVL(r.deleted_flag,'N') = 'N'
   AND r.template_id = p_parent_tmpl_id
MINUS
-- current local rules on revision template
SELECT r.rule_id
  FROM okc_xprt_template_rules r,
       okc_xprt_rule_hdrs_all h
 WHERE r.rule_id = h.rule_id
   AND h.status_code = 'ACTIVE'
   AND NVL(r.deleted_flag,'N') = 'N'
   AND r.template_id = p_template_id ;

CURSOR csr_template_dtls IS
SELECT parent_template_id
FROM OKC_TERMS_TEMPLATES_ALL
WHERE template_id = p_template_id ;


-- Generate Run Id for Rule Import
CURSOR csr_cz_run_id IS
SELECT cz_xfr_run_infos_s.NEXTVAL
FROM dual;


l_api_name                CONSTANT VARCHAR2(30) := 'import_rule_temp_approval';
l_rule_id                 okc_xprt_template_rules.rule_id%TYPE;
l_parent_template_id      OKC_TERMS_TEMPLATES_ALL.parent_template_id%TYPE := NULL;
l_template_id             OKC_TERMS_TEMPLATES_ALL.template_id%TYPE := NULL;



BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_template_id : '||p_template_id);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Generate the Run Id
   OPEN csr_cz_run_id;
     FETCH csr_cz_run_id INTO x_run_id;
   CLOSE csr_cz_run_id;

  -- Get Template Details
  -- In case of revision template, parent_template_id IS NOT NULL

    OPEN csr_template_dtls;
      FETCH csr_template_dtls INTO l_parent_template_id;

        IF csr_template_dtls%NOTFOUND THEN
           -- Log Error
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE||l_api_name,
                            '110: Invalid Template Id: '||p_template_id);
           END IF;
           FND_MESSAGE.set_name('OKC','OKC_XPRT_INVALID_TEMPLATE');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    CLOSE csr_template_dtls;



  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Rule Import x_run_id  : '|| x_run_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: p_template_id  : '|| p_template_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: l_parent_template_id '|| l_parent_template_id);
  END IF;

  IF l_parent_template_id IS NULL THEN
     -- Not a Revision Template
	l_template_id := p_template_id;
  ELSE
      -- Revision Template
	l_template_id := l_parent_template_id;
  END IF;

  OPEN csr_template_rules;
    LOOP
      FETCH csr_template_rules INTO l_rule_id;
	 EXIT WHEN csr_template_rules%NOTFOUND;

		  build_and_insert_rule
            (
             p_rule_id                  => l_rule_id,
             p_template_id              => l_template_id,
             p_run_id                   => x_run_id,
             p_mode                     => 'P',
             x_return_status            => x_return_status,
             x_msg_data                 => x_msg_data,
             x_msg_count                => x_msg_count
            );

     END LOOP;
  CLOSE csr_template_rules;

  -- In Case of Revision templates, delete Active Rules on Parent Template
    IF l_parent_template_id IS NOT NULL THEN
       OPEN csr_parent_tmpl_rules(p_parent_tmpl_id => l_parent_template_id);
	    LOOP
	      FETCH csr_parent_tmpl_rules INTO l_rule_id;
		 EXIT WHEN csr_parent_tmpl_rules%NOTFOUND;

		  build_and_insert_rule
            (
             p_rule_id                  => l_rule_id,
             p_template_id              => l_template_id,
             p_run_id                   => x_run_id,
             p_mode                     => 'D',
             x_return_status            => x_return_status,
             x_msg_data                 => x_msg_data,
             x_msg_count                => x_msg_count
            );

	    END LOOP;
	  CLOSE csr_parent_tmpl_rules;

    END IF; -- revision template



-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'Error in import_rule_temp_approval  '||SQLERRM);
      fnd_file.put_line(FND_FILE.LOG,'  ');

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'Unexpected Error in import_rule_temp_approval  '||SQLERRM);
      fnd_file.put_line(FND_FILE.LOG,'  ');

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'Other Error in import_rule_temp_approval  '||SQLERRM);
      fnd_file.put_line(FND_FILE.LOG,'  ');

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END import_rule_temp_approval;

---------------------------------------------------
FUNCTION check_extension_rule
(
 p_intent       	    IN	VARCHAR2,
 p_org_id		    IN  NUMBER
)
RETURN  VARCHAR2 IS

CURSOR csr_check_var_model IS
SELECT devl_project_id
FROM cz_devl_projects
WHERE orig_sys_ref = G_VARIABLE_MODEL_OSR||p_intent
AND devl_project_id = persistent_project_id
AND deleted_flag = 0;

--Added for R12
CURSOR csr_check_cla_model IS
SELECT devl_project_id
FROM cz_devl_projects
WHERE orig_sys_ref = G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent
AND devl_project_id = persistent_project_id
AND deleted_flag = 0;

CURSOR csr_check_ext_rule (p_devl_project_id NUMBER) IS
SELECT 'X'
FROM cz_rules
WHERE rule_type = 300 -- Extension rule
AND devl_project_id = p_devl_project_id
AND rule_id = persistent_rule_id
AND deleted_flag = 0;

l_devl_project_id NUMBER;
l_exists VARCHAR2(1);

BEGIN

OPEN  csr_check_cla_model;
FETCH csr_check_cla_model INTO l_devl_project_id;
IF csr_check_cla_model%FOUND THEN
	OPEN  csr_check_ext_rule(l_devl_project_id);
	FETCH csr_check_ext_rule INTO l_exists;
	IF csr_check_ext_rule%FOUND THEN
	   RETURN FND_API.G_TRUE;
	ELSE
	   RETURN FND_API.G_FALSE;
	END IF;
	CLOSE csr_check_ext_rule;
ELSE
    RETURN FND_API.G_FALSE;
END IF;
CLOSE csr_check_cla_model;

EXCEPTION
WHEN OTHERS THEN
IF csr_check_cla_model%ISOPEN THEN
   CLOSE csr_check_cla_model;
END IF;
IF csr_check_cla_model%ISOPEN THEN
   CLOSE csr_check_cla_model;
END IF;

END check_extension_rule;

---------------------------------------------------

PROCEDURE attach_extension_rule
(
 p_api_version          IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_run_id   	        IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	        OUT	NOCOPY NUMBER
) IS

-- Added Org_id to the cusor for R12
CURSOR csr_intents IS
SELECT distinct intent, org_id
FROM okc_xprt_rule_hdrs_all r
WHERE r.request_id = fnd_global.conc_request_id;

CURSOR csr_get_var_model_dtl (l_intent VARCHAR2) IS
SELECT devl_project_id, orig_sys_ref
FROM cz_devl_projects
WHERE orig_sys_ref = G_VARIABLE_MODEL_OSR||l_intent
AND devl_project_id = persistent_project_id
AND deleted_flag = 0;

-- Added new cursor for attaching extension rule to Clause model from R12
CURSOR csr_get_cla_model_dtl (l_org_id NUMBER, l_intent VARCHAR2) IS
SELECT devl_project_id, orig_sys_ref
FROM cz_devl_projects
WHERE orig_sys_ref = G_CLAUSE_MODEL_OSR||to_char(l_org_id)||':'||l_intent
AND devl_project_id = persistent_project_id
AND deleted_flag = 0;

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_api_name                CONSTANT VARCHAR2(30) := 'attach_extension_rule';
l_rule_id                 okc_xprt_rule_hdrs_all.rule_id%TYPE;
l_org_id                  okc_xprt_rule_hdrs_all.org_id%TYPE;
l_intent                  okc_xprt_rule_hdrs_all.intent%TYPE;
l_deleted_flag            cz_imp_rules.deleted_flag%TYPE;
l_seq_nbr                 cz_imp_rules.seq_nbr%TYPE := 0;
l_rule_name		  cz_imp_rules.NAME%TYPE;
l_rule_description        cz_imp_rules.desc_text%TYPE;
l_rule_text               cz_imp_rules.rule_text%TYPE;
l_model_id                cz_imp_localized_texts.MODEL_ID%TYPE;
l_model_osr               cz_imp_localized_texts.fsk_devlproject_1_1%TYPE;

l_language                FND_LANGUAGES.LANGUAGE_CODE%TYPE;

l_cz_imp_rules            cz_imp_rules%ROWTYPE;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Set Extension rule name
  FND_MESSAGE.set_name('OKC','OKC_XPRT_XTN_RULE_NAME');
  l_rule_name := FND_MESSAGE.get; -- Get Extension rule name from OKC_XPRT_XTN_RULE_NAME message

 -- Set Extension rule description
  FND_MESSAGE.set_name('OKC','OKC_XPRT_XTN_RULE_DESC');
  l_rule_description := FND_MESSAGE.get; -- Get Extension rule description from OKC_XPRT_XTN_RULE_DESC message


OPEN csr_intents;
  LOOP
      FETCH csr_intents INTO l_intent,l_org_id;
      EXIT WHEN csr_intents%NOTFOUND;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: l_intent ' || '='||l_intent);
  END IF;

		-- Modified to attach extension rule to Clause model from R12
		OPEN  csr_get_cla_model_dtl(l_org_id, l_intent);
		FETCH csr_get_cla_model_dtl INTO l_model_id, l_model_osr;
		IF csr_get_cla_model_dtl%NOTFOUND THEN
		  RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE csr_get_cla_model_dtl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: l_model_id ' || '='||l_model_id);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: l_model_osr ' || '='||l_model_osr);
  END IF;

-- Generate the Rule Text for this Run Id if the rule doesn't exist/has been deleted/disabled
-- Check_extension rule changed in R12 to check against Clause model. Added new parameter l_org_id
IF (check_extension_rule(l_intent, l_org_id) = FND_API.G_FALSE)  THEN

  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'Creating Extension Rule for : '||l_model_osr);
  fnd_file.put_line(FND_FILE.LOG,'  ');

      -- Insert Rule Name into cz_imp_localized_texts

          OPEN csr_installed_languages;
            LOOP
              FETCH csr_installed_languages INTO l_language;
              EXIT WHEN csr_installed_languages%NOTFOUND;

             -- Insert into cz_imp_localized_text
                  INSERT INTO CZ_IMP_LOCALIZED_TEXTS
                  (
                   LAST_UPDATE_LOGIN,
                   LOCALE_ID,
                   LOCALIZED_STR,
                   INTL_TEXT_ID,
                   CREATION_DATE,
                   LAST_UPDATE_DATE,
                   DELETED_FLAG,
                   EFF_FROM,
                   EFF_TO,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   SECURITY_MASK,
                   EFF_MASK,
                   CHECKOUT_USER,
                   LANGUAGE,
                   ORIG_SYS_REF,
                   SOURCE_LANG,
                   RUN_ID,
                   REC_STATUS,
                   DISPOSITION,
                   MODEL_ID,
                   FSK_DEVLPROJECT_1_1,
                   MESSAGE,
                   SEEDED_FLAG
                  )
                  VALUES
                  (
                  FND_GLOBAL.LOGIN_ID,  --LAST_UPDATE_LOGIN
                  NULL, -- LOCALE_ID
                  l_rule_name,  --LOCALIZED_STR -
                  NULL, -- INTL_TEXT_ID
                  SYSDATE, -- CREATION_DATE
                  SYSDATE, -- LAST_UPDATE_DATE
                  '0', -- DELETED_FLAG
                  NULL, -- EFF_FROM
                  NULL, -- EFF_TO
                  FND_GLOBAL.USER_ID, -- CREATED_BY
                  FND_GLOBAL.USER_ID, -- LAST_UPDATED_BY
                  NULL, -- SECURITY_MASK
                  NULL, -- EFF_MASK
                  NULL, -- CHECKOUT_USER
                  l_language, --LANGUAGE
                  G_XTN_RULE_OSR||l_intent, --ORIG_SYS_REF
                  USERENV('LANG'),  --SOURCE_LANG
                  p_run_id, -- RUN_ID
                  NULL, -- REC_STATUS
                  NULL, -- DISPOSITION
                  l_model_id, -- MODEL_ID
                  l_model_osr, --FSK_DEVLPROJECT_1_1
                  NULL, -- MESSAGE
                  NULL -- SEEDED_FLAG
                  );

		  END LOOP;
          CLOSE  csr_installed_languages;


        -- Populate the cz_imp_rules record
           l_seq_nbr := l_seq_nbr + 1;

           l_cz_imp_rules.RULE_ID  := NULL;
           l_cz_imp_rules.SUB_CONS_ID  := NULL;
           l_cz_imp_rules.REASON_ID  := NULL;
           l_cz_imp_rules.AMOUNT_ID  := NULL;
           l_cz_imp_rules.GRID_ID  := NULL;
           l_cz_imp_rules.RULE_FOLDER_ID  := NULL;
           l_cz_imp_rules.DEVL_PROJECT_ID  := l_model_id;
           l_cz_imp_rules.INVALID_FLAG  := '0'; --Default value for valid rule
           l_cz_imp_rules.DESC_TEXT  := l_rule_description;
           l_cz_imp_rules.NAME  := l_rule_name;  -- check
           l_cz_imp_rules.ANTECEDENT_ID  := NULL;
           l_cz_imp_rules.CONSEQUENT_ID  := NULL;
           l_cz_imp_rules.RULE_TYPE  := 300; -- Extension Rule
           l_cz_imp_rules.EXPR_RULE_TYPE  := NULL; --1; --Needed for Extension rule
           l_cz_imp_rules.COMPONENT_ID  := NULL;
           l_cz_imp_rules.REASON_TYPE  := 0; -- Value in reason_id corresponds to Name of Rule
           l_cz_imp_rules.DISABLED_FLAG  := '0'; -- Indicates enabled rule
           l_cz_imp_rules.ORIG_SYS_REF  := G_XTN_RULE_OSR||l_intent;
           l_cz_imp_rules.CREATION_DATE  := SYSDATE;
           l_cz_imp_rules.LAST_UPDATE_DATE  := SYSDATE;
           l_cz_imp_rules.DELETED_FLAG  := 0; -- check
           l_cz_imp_rules.EFF_FROM  := NULL;
           l_cz_imp_rules.EFF_TO  := NULL;
           l_cz_imp_rules.CREATED_BY  := FND_GLOBAL.USER_ID;
           l_cz_imp_rules.LAST_UPDATED_BY  := FND_GLOBAL.USER_ID;
           l_cz_imp_rules.SECURITY_MASK  := NULL;
           l_cz_imp_rules.EFF_MASK  := NULL;
           l_cz_imp_rules.CHECKOUT_USER  := NULL;
           l_cz_imp_rules.LAST_UPDATE_LOGIN  := FND_GLOBAL.LOGIN_ID;
           l_cz_imp_rules.EFFECTIVE_USAGE_MASK  := NULL;
           l_cz_imp_rules.SEQ_NBR  := l_seq_nbr;
           l_cz_imp_rules.EFFECTIVE_FROM  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
           l_cz_imp_rules.EFFECTIVE_UNTIL  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;
           l_cz_imp_rules.PERSISTENT_RULE_ID  := NULL;
           l_cz_imp_rules.EFFECTIVITY_SET_ID  := NULL;
           l_cz_imp_rules.RULE_FOLDER_TYPE  := NULL;
           l_cz_imp_rules.UNSATISFIED_MSG_ID  := NULL;
           l_cz_imp_rules.UNSATISFIED_MSG_SOURCE  := '0'; -- Changed from NULL
           l_cz_imp_rules.SIGNATURE_ID  := NULL;
           l_cz_imp_rules.TEMPLATE_PRIMITIVE_FLAG  := NULL;
           l_cz_imp_rules.PRESENTATION_FLAG  := NULL; --'0'; --Default value
           l_cz_imp_rules.TEMPLATE_TOKEN  := NULL;
           -- l_cz_imp_rules.RULE_TEXT  := G_XTN_RULE_TEXT;
           l_cz_imp_rules.NOTES  := NULL;
           l_cz_imp_rules.CLASS_NAME  := G_XTN_RULE_CLASS_NAME;
           l_cz_imp_rules.INSTANTIATION_SCOPE  := 1; -- Needed for Extension rule
           l_cz_imp_rules.MODEL_REF_EXPL_ID  := NULL;
           l_cz_imp_rules.MUTABLE_FLAG  := '0'; --Default value
           l_cz_imp_rules.SEEDED_FLAG  := NULL; --Seeded CX rule
           l_cz_imp_rules.UI_DEF_ID  := NULL;
           l_cz_imp_rules.UI_PAGE_ID  := NULL;
           l_cz_imp_rules.UI_PAGE_ELEMENT_ID  := NULL;
           l_cz_imp_rules.MESSAGE  := NULL;
           l_cz_imp_rules.RUN_ID  := p_run_id; -- Input runid
           l_cz_imp_rules.DISPOSITION  := NULL;
           l_cz_imp_rules.REC_STATUS  := NULL;
           l_cz_imp_rules.FSK_DEVL_PROJECT  := l_model_osr;
           l_cz_imp_rules.FSK_LOCALIZED_TEXT_1  := G_XTN_RULE_OSR||l_intent;
           l_cz_imp_rules.FSK_LOCALIZED_TEXT_2  := NULL;
           l_cz_imp_rules.IMPORT_PROG_VERSION  := NULL;
           l_cz_imp_rules.FSK_COMPONENT_ID  := NULL;
           l_cz_imp_rules.FSK_MODEL_REF_EXPL_ID  := NULL;


      -- Insert into cz_imp_rules

                INSERT INTO cz_imp_rules
                (
                RULE_ID,
                SUB_CONS_ID,
                REASON_ID,
                AMOUNT_ID,
                GRID_ID,
                RULE_FOLDER_ID,
                DEVL_PROJECT_ID,
                INVALID_FLAG,
                DESC_TEXT,
                NAME,
                ANTECEDENT_ID,
                CONSEQUENT_ID,
                RULE_TYPE,
                EXPR_RULE_TYPE,
                COMPONENT_ID,
                REASON_TYPE,
                DISABLED_FLAG,
                ORIG_SYS_REF,
                CREATION_DATE,
                LAST_UPDATE_DATE,
                DELETED_FLAG,
                EFF_FROM,
                EFF_TO,
                CREATED_BY,
                LAST_UPDATED_BY,
                SECURITY_MASK,
                EFF_MASK,
                CHECKOUT_USER,
                LAST_UPDATE_LOGIN,
                EFFECTIVE_USAGE_MASK,
                SEQ_NBR,
                EFFECTIVE_FROM,
                EFFECTIVE_UNTIL,
                PERSISTENT_RULE_ID,
                EFFECTIVITY_SET_ID,
                RULE_FOLDER_TYPE,
                UNSATISFIED_MSG_ID,
                UNSATISFIED_MSG_SOURCE,
                SIGNATURE_ID,
                TEMPLATE_PRIMITIVE_FLAG,
                PRESENTATION_FLAG,
                TEMPLATE_TOKEN,
                RULE_TEXT,
                NOTES,
                CLASS_NAME,
                INSTANTIATION_SCOPE,
                MODEL_REF_EXPL_ID,
                MUTABLE_FLAG,
                SEEDED_FLAG,
                UI_DEF_ID,
                UI_PAGE_ID,
                UI_PAGE_ELEMENT_ID,
                MESSAGE,
                RUN_ID,
                DISPOSITION,
                REC_STATUS,
                FSK_DEVL_PROJECT,
                FSK_LOCALIZED_TEXT_1,
                FSK_LOCALIZED_TEXT_2,
                IMPORT_PROG_VERSION,
                FSK_COMPONENT_ID,
                FSK_MODEL_REF_EXPL_ID
                )
                VALUES
                (
                l_cz_imp_rules.RULE_ID,
                l_cz_imp_rules.SUB_CONS_ID,
                l_cz_imp_rules.REASON_ID,
                l_cz_imp_rules.AMOUNT_ID,
                l_cz_imp_rules.GRID_ID,
                l_cz_imp_rules.RULE_FOLDER_ID,
                l_cz_imp_rules.DEVL_PROJECT_ID,
                l_cz_imp_rules.INVALID_FLAG,
                l_cz_imp_rules.DESC_TEXT,
                l_cz_imp_rules.NAME,
                l_cz_imp_rules.ANTECEDENT_ID,
                l_cz_imp_rules.CONSEQUENT_ID,
                l_cz_imp_rules.RULE_TYPE,
                l_cz_imp_rules.EXPR_RULE_TYPE,
                l_cz_imp_rules.COMPONENT_ID,
                l_cz_imp_rules.REASON_TYPE,
                l_cz_imp_rules.DISABLED_FLAG,
                l_cz_imp_rules.ORIG_SYS_REF,
                l_cz_imp_rules.CREATION_DATE,
                l_cz_imp_rules.LAST_UPDATE_DATE,
                l_cz_imp_rules.DELETED_FLAG,
                l_cz_imp_rules.EFF_FROM,
                l_cz_imp_rules.EFF_TO,
                l_cz_imp_rules.CREATED_BY,
                l_cz_imp_rules.LAST_UPDATED_BY,
                l_cz_imp_rules.SECURITY_MASK,
                l_cz_imp_rules.EFF_MASK,
                l_cz_imp_rules.CHECKOUT_USER,
                l_cz_imp_rules.LAST_UPDATE_LOGIN,
                l_cz_imp_rules.EFFECTIVE_USAGE_MASK,
                l_cz_imp_rules.SEQ_NBR,
                l_cz_imp_rules.EFFECTIVE_FROM,
                l_cz_imp_rules.EFFECTIVE_UNTIL,
                l_cz_imp_rules.PERSISTENT_RULE_ID,
                l_cz_imp_rules.EFFECTIVITY_SET_ID,
                l_cz_imp_rules.RULE_FOLDER_TYPE,
                l_cz_imp_rules.UNSATISFIED_MSG_ID,
                l_cz_imp_rules.UNSATISFIED_MSG_SOURCE,
                l_cz_imp_rules.SIGNATURE_ID,
                l_cz_imp_rules.TEMPLATE_PRIMITIVE_FLAG,
                l_cz_imp_rules.PRESENTATION_FLAG,
                l_cz_imp_rules.TEMPLATE_TOKEN,
                --l_cz_imp_rules.RULE_TEXT,
                G_XTN_RULE_TEXT,
                l_cz_imp_rules.NOTES,
                l_cz_imp_rules.CLASS_NAME,
                l_cz_imp_rules.INSTANTIATION_SCOPE,
                l_cz_imp_rules.MODEL_REF_EXPL_ID,
                l_cz_imp_rules.MUTABLE_FLAG,
                l_cz_imp_rules.SEEDED_FLAG,
                l_cz_imp_rules.UI_DEF_ID,
                l_cz_imp_rules.UI_PAGE_ID,
                l_cz_imp_rules.UI_PAGE_ELEMENT_ID,
                l_cz_imp_rules.MESSAGE,
                l_cz_imp_rules.RUN_ID,
                l_cz_imp_rules.DISPOSITION,
                l_cz_imp_rules.REC_STATUS,
                l_cz_imp_rules.FSK_DEVL_PROJECT,
                l_cz_imp_rules.FSK_LOCALIZED_TEXT_1,
                l_cz_imp_rules.FSK_LOCALIZED_TEXT_2,
                l_cz_imp_rules.IMPORT_PROG_VERSION,
                l_cz_imp_rules.FSK_COMPONENT_ID,
                l_cz_imp_rules.FSK_MODEL_REF_EXPL_ID
                );
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '170: After Insert into cz_imp_rules' || '='||l_intent);
  END IF;

END IF;  -- check extn rule exists

  END LOOP;
CLOSE csr_intents; -- Insert the Extension Rule for this Intent


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END attach_extension_rule;


---------------------------------------------------
PROCEDURE attach_extension_rule_tmpl
(
 p_api_version          IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_run_id   	        IN	NUMBER,
 p_template_id       IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	        OUT	NOCOPY NUMBER
) IS

-- Added Org_id to the cusor for R12
CURSOR csr_intents IS
SELECT intent,org_id
FROM OKC_TERMS_TEMPLATES_ALL t
WHERE t.template_id = p_template_id;

CURSOR csr_get_var_model_dtl (l_intent VARCHAR2) IS
SELECT devl_project_id, orig_sys_ref
FROM cz_devl_projects
WHERE orig_sys_ref = G_VARIABLE_MODEL_OSR||l_intent
AND devl_project_id = persistent_project_id
AND deleted_flag = 0;

-- Added new cursor for attaching extension rule to Clause model from R12
CURSOR csr_get_cla_model_dtl (l_org_id NUMBER, l_intent VARCHAR2) IS
SELECT devl_project_id, orig_sys_ref
FROM cz_devl_projects
WHERE orig_sys_ref = G_CLAUSE_MODEL_OSR||l_org_id||':'||l_intent
AND devl_project_id = persistent_project_id
AND deleted_flag = 0;

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_api_name                CONSTANT VARCHAR2(30) := 'attach_extension_rule_tmpl';
l_rule_id                 okc_xprt_rule_hdrs_all.rule_id%TYPE;
l_org_id                  okc_xprt_rule_hdrs_all.org_id%TYPE;
l_intent                  okc_xprt_rule_hdrs_all.intent%TYPE;
l_deleted_flag            cz_imp_rules.deleted_flag%TYPE;
l_seq_nbr                 cz_imp_rules.seq_nbr%TYPE := 0;
l_rule_name			 cz_imp_rules.NAME%TYPE;
l_rule_description        cz_imp_rules.desc_text%TYPE;
l_rule_text               cz_imp_rules.rule_text%TYPE;
l_model_id                cz_imp_localized_texts.MODEL_ID%TYPE;
l_model_osr               cz_imp_localized_texts.fsk_devlproject_1_1%TYPE;

l_language                FND_LANGUAGES.LANGUAGE_CODE%TYPE;

l_cz_imp_rules            cz_imp_rules%ROWTYPE;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Set Extension rule name
  FND_MESSAGE.set_name('OKC','OKC_XPRT_XTN_RULE_NAME');
  l_rule_name := FND_MESSAGE.get; -- Get Extension rule name from OKC_XPRT_XTN_RULE_NAME message

 -- Set Extension rule description
  FND_MESSAGE.set_name('OKC','OKC_XPRT_XTN_RULE_DESC');
  l_rule_description := FND_MESSAGE.get; -- Get Extension rule description from OKC_XPRT_XTN_RULE_DESC message


OPEN csr_intents;
  LOOP
      FETCH csr_intents INTO l_intent,l_org_id;
      EXIT WHEN csr_intents%NOTFOUND;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: l_intent ' || '='||l_intent);
  END IF;

		-- Modified to attach extension rule to Clause model from R12
		OPEN  csr_get_cla_model_dtl(l_org_id, l_intent);
		FETCH csr_get_cla_model_dtl INTO l_model_id, l_model_osr;
		IF csr_get_cla_model_dtl%NOTFOUND THEN
		  RAISE FND_API.G_EXC_ERROR;
		END IF;
		CLOSE csr_get_cla_model_dtl;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: l_model_id ' || '='||l_model_id);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: l_model_osr ' || '='||l_model_osr);
  END IF;

-- Generate the Rule Text for this Run Id if the rule doesn't exist/has been deleted/disabled
-- Check_extension rule changed in R12 to check against Clause model. Added new parameter l_org_id
IF (check_extension_rule(l_intent, l_org_id) = FND_API.G_FALSE)  THEN

  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'Creating Extension Rule for : '||l_model_osr);
  fnd_file.put_line(FND_FILE.LOG,'  ');

      -- Insert Rule Name into cz_imp_localized_texts

          OPEN csr_installed_languages;
            LOOP
              FETCH csr_installed_languages INTO l_language;
              EXIT WHEN csr_installed_languages%NOTFOUND;

             -- Insert into cz_imp_localized_text
                  INSERT INTO CZ_IMP_LOCALIZED_TEXTS
                  (
                   LAST_UPDATE_LOGIN,
                   LOCALE_ID,
                   LOCALIZED_STR,
                   INTL_TEXT_ID,
                   CREATION_DATE,
                   LAST_UPDATE_DATE,
                   DELETED_FLAG,
                   EFF_FROM,
                   EFF_TO,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   SECURITY_MASK,
                   EFF_MASK,
                   CHECKOUT_USER,
                   LANGUAGE,
                   ORIG_SYS_REF,
                   SOURCE_LANG,
                   RUN_ID,
                   REC_STATUS,
                   DISPOSITION,
                   MODEL_ID,
                   FSK_DEVLPROJECT_1_1,
                   MESSAGE,
                   SEEDED_FLAG
                  )
                  VALUES
                  (
                  FND_GLOBAL.LOGIN_ID,  --LAST_UPDATE_LOGIN
                  NULL, -- LOCALE_ID
                  l_rule_name,  --LOCALIZED_STR -
                  NULL, -- INTL_TEXT_ID
                  SYSDATE, -- CREATION_DATE
                  SYSDATE, -- LAST_UPDATE_DATE
                  '0', -- DELETED_FLAG
                  NULL, -- EFF_FROM
                  NULL, -- EFF_TO
                  FND_GLOBAL.USER_ID, -- CREATED_BY
                  FND_GLOBAL.USER_ID, -- LAST_UPDATED_BY
                  NULL, -- SECURITY_MASK
                  NULL, -- EFF_MASK
                  NULL, -- CHECKOUT_USER
                  l_language, --LANGUAGE
                  G_XTN_RULE_OSR||l_intent, --ORIG_SYS_REF
                  USERENV('LANG'),  --SOURCE_LANG
                  p_run_id, -- RUN_ID
                  NULL, -- REC_STATUS
                  NULL, -- DISPOSITION
                  l_model_id, -- MODEL_ID
                  l_model_osr, --FSK_DEVLPROJECT_1_1
                  NULL, -- MESSAGE
                  NULL -- SEEDED_FLAG
                  );

		  END LOOP;
          CLOSE  csr_installed_languages;


        -- Populate the cz_imp_rules record
           l_seq_nbr := l_seq_nbr + 1;

           l_cz_imp_rules.RULE_ID  := NULL;
           l_cz_imp_rules.SUB_CONS_ID  := NULL;
           l_cz_imp_rules.REASON_ID  := NULL;
           l_cz_imp_rules.AMOUNT_ID  := NULL;
           l_cz_imp_rules.GRID_ID  := NULL;
           l_cz_imp_rules.RULE_FOLDER_ID  := NULL;
           l_cz_imp_rules.DEVL_PROJECT_ID  := l_model_id;
           l_cz_imp_rules.INVALID_FLAG  := '0'; --Default value for valid rule
           l_cz_imp_rules.DESC_TEXT  := l_rule_description;
           l_cz_imp_rules.NAME  := l_rule_name;  -- check
           l_cz_imp_rules.ANTECEDENT_ID  := NULL;
           l_cz_imp_rules.CONSEQUENT_ID  := NULL;
           l_cz_imp_rules.RULE_TYPE  := 300; -- Extension Rule
           l_cz_imp_rules.EXPR_RULE_TYPE  := NULL; --1; --Needed for Extension rule
           l_cz_imp_rules.COMPONENT_ID  := NULL;
           l_cz_imp_rules.REASON_TYPE  := 0; -- Value in reason_id corresponds to Name of Rule
           l_cz_imp_rules.DISABLED_FLAG  := '0'; -- Indicates enabled rule
           l_cz_imp_rules.ORIG_SYS_REF  := G_XTN_RULE_OSR||l_intent;
           l_cz_imp_rules.CREATION_DATE  := SYSDATE;
           l_cz_imp_rules.LAST_UPDATE_DATE  := SYSDATE;
           l_cz_imp_rules.DELETED_FLAG  := 0; -- check
           l_cz_imp_rules.EFF_FROM  := NULL;
           l_cz_imp_rules.EFF_TO  := NULL;
           l_cz_imp_rules.CREATED_BY  := FND_GLOBAL.USER_ID;
           l_cz_imp_rules.LAST_UPDATED_BY  := FND_GLOBAL.USER_ID;
           l_cz_imp_rules.SECURITY_MASK  := NULL;
           l_cz_imp_rules.EFF_MASK  := NULL;
           l_cz_imp_rules.CHECKOUT_USER  := NULL;
           l_cz_imp_rules.LAST_UPDATE_LOGIN  := FND_GLOBAL.LOGIN_ID;
           l_cz_imp_rules.EFFECTIVE_USAGE_MASK  := NULL;
           l_cz_imp_rules.SEQ_NBR  := l_seq_nbr;
           l_cz_imp_rules.EFFECTIVE_FROM  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
           l_cz_imp_rules.EFFECTIVE_UNTIL  := OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;
           l_cz_imp_rules.PERSISTENT_RULE_ID  := NULL;
           l_cz_imp_rules.EFFECTIVITY_SET_ID  := NULL;
           l_cz_imp_rules.RULE_FOLDER_TYPE  := NULL;
           l_cz_imp_rules.UNSATISFIED_MSG_ID  := NULL;
           l_cz_imp_rules.UNSATISFIED_MSG_SOURCE  := '0'; -- Changed from NULL
           l_cz_imp_rules.SIGNATURE_ID  := NULL;
           l_cz_imp_rules.TEMPLATE_PRIMITIVE_FLAG  := NULL;
           l_cz_imp_rules.PRESENTATION_FLAG  := NULL; --'0'; --Default value
           l_cz_imp_rules.TEMPLATE_TOKEN  := NULL;
           -- l_cz_imp_rules.RULE_TEXT  := G_XTN_RULE_TEXT;
           l_cz_imp_rules.NOTES  := NULL;
           l_cz_imp_rules.CLASS_NAME  := G_XTN_RULE_CLASS_NAME;
           l_cz_imp_rules.INSTANTIATION_SCOPE  := 1; -- Needed for Extension rule
           l_cz_imp_rules.MODEL_REF_EXPL_ID  := NULL;
           l_cz_imp_rules.MUTABLE_FLAG  := '0'; --Default value
           l_cz_imp_rules.SEEDED_FLAG  := NULL; --Seeded CX rule
           l_cz_imp_rules.UI_DEF_ID  := NULL;
           l_cz_imp_rules.UI_PAGE_ID  := NULL;
           l_cz_imp_rules.UI_PAGE_ELEMENT_ID  := NULL;
           l_cz_imp_rules.MESSAGE  := NULL;
           l_cz_imp_rules.RUN_ID  := p_run_id; -- Input runid
           l_cz_imp_rules.DISPOSITION  := NULL;
           l_cz_imp_rules.REC_STATUS  := NULL;
           l_cz_imp_rules.FSK_DEVL_PROJECT  := l_model_osr;
           l_cz_imp_rules.FSK_LOCALIZED_TEXT_1  := G_XTN_RULE_OSR||l_intent;
           l_cz_imp_rules.FSK_LOCALIZED_TEXT_2  := NULL;
           l_cz_imp_rules.IMPORT_PROG_VERSION  := NULL;
           l_cz_imp_rules.FSK_COMPONENT_ID  := NULL;
           l_cz_imp_rules.FSK_MODEL_REF_EXPL_ID  := NULL;


      -- Insert into cz_imp_rules

                INSERT INTO cz_imp_rules
                (
                RULE_ID,
                SUB_CONS_ID,
                REASON_ID,
                AMOUNT_ID,
                GRID_ID,
                RULE_FOLDER_ID,
                DEVL_PROJECT_ID,
                INVALID_FLAG,
                DESC_TEXT,
                NAME,
                ANTECEDENT_ID,
                CONSEQUENT_ID,
                RULE_TYPE,
                EXPR_RULE_TYPE,
                COMPONENT_ID,
                REASON_TYPE,
                DISABLED_FLAG,
                ORIG_SYS_REF,
                CREATION_DATE,
                LAST_UPDATE_DATE,
                DELETED_FLAG,
                EFF_FROM,
                EFF_TO,
                CREATED_BY,
                LAST_UPDATED_BY,
                SECURITY_MASK,
                EFF_MASK,
                CHECKOUT_USER,
                LAST_UPDATE_LOGIN,
                EFFECTIVE_USAGE_MASK,
                SEQ_NBR,
                EFFECTIVE_FROM,
                EFFECTIVE_UNTIL,
                PERSISTENT_RULE_ID,
                EFFECTIVITY_SET_ID,
                RULE_FOLDER_TYPE,
                UNSATISFIED_MSG_ID,
                UNSATISFIED_MSG_SOURCE,
                SIGNATURE_ID,
                TEMPLATE_PRIMITIVE_FLAG,
                PRESENTATION_FLAG,
                TEMPLATE_TOKEN,
                RULE_TEXT,
                NOTES,
                CLASS_NAME,
                INSTANTIATION_SCOPE,
                MODEL_REF_EXPL_ID,
                MUTABLE_FLAG,
                SEEDED_FLAG,
                UI_DEF_ID,
                UI_PAGE_ID,
                UI_PAGE_ELEMENT_ID,
                MESSAGE,
                RUN_ID,
                DISPOSITION,
                REC_STATUS,
                FSK_DEVL_PROJECT,
                FSK_LOCALIZED_TEXT_1,
                FSK_LOCALIZED_TEXT_2,
                IMPORT_PROG_VERSION,
                FSK_COMPONENT_ID,
                FSK_MODEL_REF_EXPL_ID
                )
                VALUES
                (
                l_cz_imp_rules.RULE_ID,
                l_cz_imp_rules.SUB_CONS_ID,
                l_cz_imp_rules.REASON_ID,
                l_cz_imp_rules.AMOUNT_ID,
                l_cz_imp_rules.GRID_ID,
                l_cz_imp_rules.RULE_FOLDER_ID,
                l_cz_imp_rules.DEVL_PROJECT_ID,
                l_cz_imp_rules.INVALID_FLAG,
                l_cz_imp_rules.DESC_TEXT,
                l_cz_imp_rules.NAME,
                l_cz_imp_rules.ANTECEDENT_ID,
                l_cz_imp_rules.CONSEQUENT_ID,
                l_cz_imp_rules.RULE_TYPE,
                l_cz_imp_rules.EXPR_RULE_TYPE,
                l_cz_imp_rules.COMPONENT_ID,
                l_cz_imp_rules.REASON_TYPE,
                l_cz_imp_rules.DISABLED_FLAG,
                l_cz_imp_rules.ORIG_SYS_REF,
                l_cz_imp_rules.CREATION_DATE,
                l_cz_imp_rules.LAST_UPDATE_DATE,
                l_cz_imp_rules.DELETED_FLAG,
                l_cz_imp_rules.EFF_FROM,
                l_cz_imp_rules.EFF_TO,
                l_cz_imp_rules.CREATED_BY,
                l_cz_imp_rules.LAST_UPDATED_BY,
                l_cz_imp_rules.SECURITY_MASK,
                l_cz_imp_rules.EFF_MASK,
                l_cz_imp_rules.CHECKOUT_USER,
                l_cz_imp_rules.LAST_UPDATE_LOGIN,
                l_cz_imp_rules.EFFECTIVE_USAGE_MASK,
                l_cz_imp_rules.SEQ_NBR,
                l_cz_imp_rules.EFFECTIVE_FROM,
                l_cz_imp_rules.EFFECTIVE_UNTIL,
                l_cz_imp_rules.PERSISTENT_RULE_ID,
                l_cz_imp_rules.EFFECTIVITY_SET_ID,
                l_cz_imp_rules.RULE_FOLDER_TYPE,
                l_cz_imp_rules.UNSATISFIED_MSG_ID,
                l_cz_imp_rules.UNSATISFIED_MSG_SOURCE,
                l_cz_imp_rules.SIGNATURE_ID,
                l_cz_imp_rules.TEMPLATE_PRIMITIVE_FLAG,
                l_cz_imp_rules.PRESENTATION_FLAG,
                l_cz_imp_rules.TEMPLATE_TOKEN,
                --l_cz_imp_rules.RULE_TEXT,
                G_XTN_RULE_TEXT,
                l_cz_imp_rules.NOTES,
                l_cz_imp_rules.CLASS_NAME,
                l_cz_imp_rules.INSTANTIATION_SCOPE,
                l_cz_imp_rules.MODEL_REF_EXPL_ID,
                l_cz_imp_rules.MUTABLE_FLAG,
                l_cz_imp_rules.SEEDED_FLAG,
                l_cz_imp_rules.UI_DEF_ID,
                l_cz_imp_rules.UI_PAGE_ID,
                l_cz_imp_rules.UI_PAGE_ELEMENT_ID,
                l_cz_imp_rules.MESSAGE,
                l_cz_imp_rules.RUN_ID,
                l_cz_imp_rules.DISPOSITION,
                l_cz_imp_rules.REC_STATUS,
                l_cz_imp_rules.FSK_DEVL_PROJECT,
                l_cz_imp_rules.FSK_LOCALIZED_TEXT_1,
                l_cz_imp_rules.FSK_LOCALIZED_TEXT_2,
                l_cz_imp_rules.IMPORT_PROG_VERSION,
                l_cz_imp_rules.FSK_COMPONENT_ID,
                l_cz_imp_rules.FSK_MODEL_REF_EXPL_ID
                );
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '170: After Insert into cz_imp_rules' || '='||l_intent);
  END IF;

END IF;  -- check extn rule exists

  END LOOP;
CLOSE csr_intents; -- Insert the Extension Rule for this Intent


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END attach_extension_rule_tmpl;






---------------------------------------------------


END OKC_XPRT_IMPORT_RULES_PVT;

/
