--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_QA_PVT" AS
/* $Header: OKCVXRULQAB.pls 120.14.12010000.8 2013/09/04 05:05:44 serukull ship $ */

------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_QA_PVT';
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

  G_ERROR_RECORD_TYPE          CONSTANT   okc_qa_errors_t.error_record_type%TYPE := 'RULE';
  G_RULE_QA_SEVERITY           CONSTANT   okc_qa_errors_t.error_severity%TYPE := 'E';
  G_RULE_QA_SUCCESS            CONSTANT   okc_qa_errors_t.error_severity%TYPE := 'S';
  G_CREATION_DATE              CONSTANT   DATE := SYSDATE;

  --
  -- Rules QA Codes (lookup_type = OKC_XPRT_RULES_QA_LIST)
  --
  G_CHECK_EXPIRED_CLAUSES       CONSTANT VARCHAR2(30) := 'CHECK_EXPIRED_CLAUSES';
  G_CHECK_DRAFT_CLAUSES         CONSTANT VARCHAR2(30) := 'CHECK_DRAFT_CLAUSES';

  G_CHECK_INVALID_VSET_QST      CONSTANT VARCHAR2(30) := 'CHECK_INVALID_VSET_QST';
  G_CHECK_INVALID_VSETSQL_QST   CONSTANT VARCHAR2(30) := 'CHECK_INVALID_VSETSQL_QST';
  G_CHECK_INVALID_VSETVAL_QST   CONSTANT VARCHAR2(30) := 'CHECK_INVALID_VSETVAL_QST';


  G_CHECK_INVALID_VSET_VAR      CONSTANT VARCHAR2(30) := 'CHECK_INVALID_VSET_VAR';
  G_CHECK_INVALID_VSETSQL_VAR   CONSTANT VARCHAR2(30) := 'CHECK_INVALID_VSETSQL_VAR';
  G_CHECK_INVALID_VSETVAL_VAR   CONSTANT VARCHAR2(30) := 'CHECK_INVALID_VSETVAL_VAR';

  G_CHECK_CIRCULAR_DEPENDENCY   CONSTANT VARCHAR2(30) := 'CHECK_CIRCULAR_DEPENDENCY';

  G_CHECK_INVALID_QUESTION      CONSTANT VARCHAR2(30) := 'CHECK_INVALID_QUESTION';

  G_CHECK_RULE_TEMPLATES        CONSTANT VARCHAR2(30) := 'CHECK_RULE_TEMPLATES';

  -- Added for UDV with Procedures
  G_CHECK_NO_PROCEDURE_VAR	CONSTANT VARCHAR2(30) := 'CHECK_NO_PROCEDURE_VAR';
  G_CHECK_INVALID_PROCEDURE_VAR	CONSTANT VARCHAR2(30) := 'CHECK_INVALID_PROCEDURE_VAR';

  --
  -- Rule Validation - Rule with Expired Clauses
  --
  G_OKC_EXP_RULE_CLAUSE        CONSTANT VARCHAR2(30) := 'OKC_XPRT_EXP_RULE_CLAUSE';
  G_OKC_EXP_RULE_CLAUSE_S      CONSTANT VARCHAR2(30) := 'OKC_XPRT_EXP_RULE_CLAUSE_S';
  G_OKC_HOLD_RULE_CLAUSE       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_CLAUSE';
  G_OKC_HOLD_RULE_CLAUSE_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_HOLD_RULE_CLAUSE_S';

  --
  -- Rule Validation - Rule with Draft Clauses
  --
  G_OKC_DFT_RULE_CLAUSE        CONSTANT VARCHAR2(30) := 'OKC_XPRT_DFT_RULE_CLAUSE';
  G_OKC_DFT_RULE_CLAUSE_S      CONSTANT VARCHAR2(30) := 'OKC_XPRT_DFT_RULE_CLAUSE_S';

  --
  -- Rule Validation - Rules with questions having circular dependency
  --
  G_OKC_CIRCULAR_DEPENDENCY       CONSTANT VARCHAR2(30) := 'OKC_XPRT_CIRCULAR_DEPENDENCY';
  G_OKC_CIRCULAR_DEPENDENCY_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_CIRCULAR_DEPENDENCY_S';

  --
  -- Rule Validation - Question with invalid Valueset
  --
  G_OKC_INVALID_VSET_QST       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSET_QST';
  G_OKC_INVALID_VSET_QST_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSET_QST_S';


  --
  -- Rule Validation - Question with invalid Valueset SQL
  --
  G_OKC_INVALID_VSETSQL_QST       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETSQL_QST';
  G_OKC_INVALID_VSETSQL_QST_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETSQL_QST_S';

  --
  -- Rule Validation - Question with invalid Valueset Value
  --
  G_OKC_INVALID_VSETVAL_QST       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETVAL_QST';
  G_OKC_INVALID_VSETVAL_QST_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETVAL_QST_S';

  --
  -- Rule Validation - Variable with invalid Valueset
  --
  G_OKC_INVALID_VSET_VAR       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSET_VAR';
  G_OKC_INVALID_VSET_VAR_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSET_VAR_S';

  --
  -- Rule Validation - Variable with invalid Valueset SQL
  --
  G_OKC_INVALID_VSETSQL_VAR       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETSQL_VAR';
  G_OKC_INVALID_VSETSQL_VAR_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETSQL_VAR_S';

  --
  -- Rule Validation - Variable with invalid Valueset Value
  --
  G_OKC_INVALID_VSETVAL_VAR       CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETVAL_VAR';
  G_OKC_INVALID_VSETVAL_VAR_S     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_VSETVAL_VAR_S';

  --
  -- Rule Validation - Rule with question that is disabled
  --
  G_OKC_INVALID_QUESTION          CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_QUESTION';
  G_OKC_INVALID_QUESTION_S        CONSTANT VARCHAR2(30) := 'OKC_XPRT_INVALID_QUESTION_S';

  --
  -- Rule Validation - Non Org Wide Rule with no templates attached
  --
  G_OKC_RULE_TEMPLATES            CONSTANT VARCHAR2(30) := 'OKC_XPRT_RULE_TEMPLATES';
  G_OKC_RULE_TEMPLATES_S          CONSTANT VARCHAR2(30) := 'OKC_XPRT_RULE_TEMPLATES_S';

  --
  -- Rule Validation - Variable with No/Invalid Procedure
  --
  G_OKC_NO_PROCEDURE_VAR          CONSTANT VARCHAR2(30) := 'OKC_XPRT_NO_PROCEDURE_VAR';
  G_OKC_NO_PROCEDURE_VAR_S        CONSTANT VARCHAR2(30) := 'OKC_XPRT_NO_PROCEDURE_VAR_S';
  G_OKC_INVALID_PROCEDURE_VAR     CONSTANT VARCHAR2(30) := 'OKC_XPRT_INV_PROCEDURE_VAR';
  G_OKC_INVALID_PROCEDURE_VAR_S   CONSTANT VARCHAR2(30) := 'OKC_XPRT_INV_PROCEDURE_VAR_S';

  g_concat_art_no  VARCHAR2(1) :=  NVL(FND_PROFILE.VALUE('OKC_CONCAT_ART_NO'),'N');


---------------------------------------------------
--  Private Functions and Procedures
---------------------------------------------------

-- Display clause number in adition to the title
-- Bug 12721915 Start
FUNCTION get_article_title (p_article_id IN NUMBER
                           ,p_article_title IN VARCHAR2)
RETURN VARCHAR2 IS


  CURSOR csr_get_article_number(p_article_id IN NUMBER)
  IS
  SELECT article_number
  FROM okc_articles_all
  WHERE article_id= p_article_id;
  l_art_number okc_articles_all.article_number%TYPE;
  l_clause_title VARCHAR2(2000);

BEGIN
        IF   g_concat_art_no = 'Y' THEN
               OPEN csr_get_article_number(p_article_id);
               FETCH  csr_get_article_number INTO l_art_number;
               CLOSE  csr_get_article_number;

               IF  l_art_number IS NOT NULL
                THEN
                l_clause_title := l_art_number ||':'||p_article_title;
                ELSE
                l_clause_title := p_article_title;
                END IF;
          ELSE
            l_clause_title := p_article_title;
          END IF;
          RETURN  l_clause_title;
EXCEPTION
 WHEN OTHERS THEN
  RETURN p_article_title;
END get_article_title;


FUNCTION get_qa_code_dtls
(
 p_qa_code  IN VARCHAR2
)
RETURN VARCHAR2 IS

CURSOR csr_qa_desc IS
SELECT meaning
  FROM fnd_lookups
 WHERE lookup_type = 'OKC_XPRT_RULES_QA_LIST'
   AND lookup_code = p_qa_code;

l_meaning   fnd_lookups.meaning%TYPE;

BEGIN
  OPEN csr_qa_desc;
    FETCH csr_qa_desc INTO l_meaning;
  CLOSE csr_qa_desc;

  RETURN l_meaning;

END get_qa_code_dtls;


---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE insert_qa_errors_t
(
 p_qa_errors_t_rec IN  OKC_QA_ERRORS_T%ROWTYPE,
 x_return_status   OUT NOCOPY VARCHAR2,
 x_msg_count       OUT NOCOPY NUMBER,
 x_msg_data        OUT NOCOPY VARCHAR2
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'insert_qa_errors_t';


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

     x_return_status := G_RET_STS_SUCCESS;

        INSERT INTO OKC_QA_ERRORS_T
        (
            DOCUMENT_TYPE,
            DOCUMENT_ID,
            SEQUENCE_ID,
            ERROR_RECORD_TYPE,
            TITLE,
            ERROR_SEVERITY,
            QA_CODE,
            MESSAGE_NAME,
            PROBLEM_SHORT_DESC,
            PROBLEM_DETAILS_SHORT,
            PROBLEM_DETAILS,
            SUGGESTION,
            ARTICLE_ID,
            DELIVERABLE_ID,
            SECTION_NAME,
            REFERENCE_COLUMN1,
            REFERENCE_COLUMN2,
            REFERENCE_COLUMN3,
            REFERENCE_COLUMN4,
            REFERENCE_COLUMN5,
            CREATION_DATE,
            ERROR_RECORD_TYPE_NAME,
            ERROR_SEVERITY_NAME,
		  RULE_ID
        )
        VALUES
        (
            p_qa_errors_t_rec.DOCUMENT_TYPE,
            p_qa_errors_t_rec.DOCUMENT_ID,
            p_qa_errors_t_rec.SEQUENCE_ID,
            p_qa_errors_t_rec.ERROR_RECORD_TYPE,
            p_qa_errors_t_rec.TITLE,
            p_qa_errors_t_rec.ERROR_SEVERITY,
            p_qa_errors_t_rec.QA_CODE,
            p_qa_errors_t_rec.MESSAGE_NAME,
            p_qa_errors_t_rec.PROBLEM_SHORT_DESC,
            p_qa_errors_t_rec.PROBLEM_DETAILS_SHORT,
            p_qa_errors_t_rec.PROBLEM_DETAILS,
            p_qa_errors_t_rec.SUGGESTION,
            p_qa_errors_t_rec.ARTICLE_ID,
            p_qa_errors_t_rec.DELIVERABLE_ID,
            p_qa_errors_t_rec.SECTION_NAME,
            p_qa_errors_t_rec.REFERENCE_COLUMN1,
            p_qa_errors_t_rec.REFERENCE_COLUMN2,
            p_qa_errors_t_rec.REFERENCE_COLUMN3,
            p_qa_errors_t_rec.REFERENCE_COLUMN4,
            p_qa_errors_t_rec.REFERENCE_COLUMN5,
            p_qa_errors_t_rec.CREATION_DATE,
            p_qa_errors_t_rec.ERROR_RECORD_TYPE_NAME,
            p_qa_errors_t_rec.ERROR_SEVERITY_NAME,
		  p_qa_errors_t_rec.RULE_ID
        );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;

END insert_qa_errors_t;


---------------------------------------------------
--  Procedure
---------------------------------------------------

/*
The procedure checks for circular references among questions in rules on
each template associated with the rule to check if the rule getting published
causes any issue.
*/

PROCEDURE check_circular_dependency
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 p_ruleid_tbl     IN  RuleIdList,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

l_conc_request_id CONSTANT Number := Fnd_Global.Conc_Request_Id;

TYPE circ_rec IS REF CURSOR;
   insert_cursor circ_rec;
-- cursor to retrieve rule name
CURSOR csr_rule_dtls IS
SELECT rule_name
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

-- cursor to retrieve templates associated to the rule
CURSOR template_cursor IS
select distinct(temp.template_id) Template_Id, temp.org_id, temp.intent
from OKC_XPRT_TEMPLATE_RULES rules, okc_terms_templates_all temp
where rules.rule_id = p_rule_id
and   rules.template_id = temp.template_id
and   (sysdate between nvl(temp.start_date, sysdate) and nvl(temp.end_date, sysdate ))
UNION
-- Org Wide Rule templates. Reverted back the changes done for 5019422 by removing
-- join to okc_xprt_template_rules
SELECT t.template_id, t.org_id, t.intent
  FROM okc_terms_templates_all t,
       okc_xprt_rule_hdrs_all r
 WHERE  t.org_id = r.org_id
   AND  t.intent = r.intent
   AND  t.contract_expert_enabled = 'Y'
   -- AND  t.status_code IN ('APPROVED','ON_HOLD')
   AND  (sysdate between nvl(t.start_date, sysdate) and nvl(t.end_date, sysdate ))
   AND  NVL(r.org_wide_flag,'N') = 'Y'
   AND  r.rule_id = p_rule_id;

-- cursor to check the circular reference
CURSOR circular_check IS
select condition_question_id,outcome_question_id,level
  from OKC_XPRT_QUESTION_REF_T
  connect by prior condition_question_id = outcome_question_id ;

l_api_name                CONSTANT VARCHAR2(30) := 'check_circular_dependency';
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

l_Template_Id   NUMBER;
l_Org_Id        NUMBER;
l_Intent        VARCHAR2(1);
--l_request_rule_ids VARCHAR2(4000) := '(';

Circular_Ref_Exception Exception;
PRAGMA EXCEPTION_INIT(Circular_Ref_Exception, -1436);

--Modified for Bug 5858915
l_sql_string LONG; --VARCHAR2(4000);


condition_question_id VARCHAR2(200);
outcome_question_id VARCHAR2(200);

l_request_rule_ids OKC_TBL_NUMBER;
s NUMBER := 0;

BEGIN

  -- start debug log
  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '100: Entered ' || g_Pkg_Name || '.' || l_Api_Name);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '100: Parameters passed: -----------------------');
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '200: p_rule_Id:' || p_rule_id);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '200: p_sequence_Id:' || p_sequence_id);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '100: Parameters passed: -----------------------');
  END IF;

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name;
  CLOSE csr_rule_dtls;

  -- Build the string with all the rules.
   l_request_rule_ids := OKC_TBL_NUMBER();
   FOR i IN p_ruleid_tbl.FIRST..p_ruleid_tbl.LAST
   LOOP
        s := s +1;
        l_request_rule_ids.extend(1);
        l_request_rule_ids(s) := p_ruleid_tbl(i);

   END LOOP;
     s := s +1;
     l_request_rule_ids.extend(1);
     l_request_rule_ids(s) := p_rule_id ;

  x_Return_Status := g_Ret_Sts_Success;
  x_qa_status     :=  'S';

  FOR Template_Rec IN template_cursor LOOP

    l_Template_Id := Template_Rec.Template_Id;
    l_Org_Id := Template_Rec.Org_Id;
    l_Intent := Template_Rec.Intent;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '200: Checking for l_Template_Id:' || l_Template_Id);
    END IF;

-- insert into the global temp table

    l_sql_string   := 'select distinct to_char(cond.object_code) condition_question_id, to_char(object_value_id) outcome_question_id
			from OKC_XPRT_RULE_CONDITIONS cond, OKC_XPRT_RULE_OUTCOMES outcome
			where cond.object_type = ''QUESTION''
			and   outcome.object_type = ''QUESTION''
			and   cond.rule_id = outcome.rule_id
			and   cond.rule_id in (

			select distinct assoc.rule_id from OKC_XPRT_TEMPLATE_RULES assoc, OKC_XPRT_RULE_HDRS_ALL rules
			where assoc.rule_id = rules.rule_id
			and assoc.template_id = ' ||l_Template_Id ||
			' and rules.status_code in (''ACTIVE'',''PENDINGPUB'',''REVISION'',''PENDINGDISABLE'')

			UNION ALL

			select distinct rule_id from OKC_XPRT_RULE_HDRS_ALL
			where status_code in  (''ACTIVE'',''PENDINGPUB'',''REVISION'',''PENDINGDISABLE'')
			and   org_wide_flag = ''Y''
			and   org_id =  ' ||l_Org_Id ||
			' and   intent =  ''' ||l_Intent|| '''' ||

			' UNION ALL

			select distinct h.rule_id from OKC_XPRT_RULE_HDRS_ALL h, table(:b1) r
			where h.org_wide_flag = ''Y''
      and   h.rule_id=value(r)
			and   h.org_id =  ' ||l_Org_Id||
			' and   h.intent =  ''' ||l_Intent|| '''' ||


			' UNION ALL

    	select distinct assoc.rule_id from OKC_XPRT_TEMPLATE_RULES assoc, OKC_XPRT_RULE_HDRS_ALL rules,table(:b2) t
			where assoc.rule_id = rules.rule_id
      and rules.rule_id = value(t)
			and assoc.template_id =  ' ||l_Template_Id||
			')

			UNION ALL

     select distinct to_char(cond.object_value_code) condition_question_id, to_char(object_value_id) outcome_question_id
			from OKC_XPRT_RULE_CONDITIONS cond, OKC_XPRT_RULE_OUTCOMES outcome
			where cond.object_value_type = ''QUESTION''
			and   outcome.object_type = ''QUESTION''
			and   cond.rule_id = outcome.rule_id
			and   cond.rule_id in (
			select distinct assoc.rule_id from OKC_XPRT_TEMPLATE_RULES assoc, OKC_XPRT_RULE_HDRS_ALL rules
			where assoc.rule_id = rules.rule_id
			and assoc.template_id =  ' ||l_Template_Id||
			' and rules.status_code in  (''ACTIVE'',''PENDINGPUB'',''REVISION'',''PENDINGDISABLE'')

			UNION ALL

			select distinct rule_id from OKC_XPRT_RULE_HDRS_ALL
			where status_code in (''ACTIVE'',''PENDINGPUB'',''REVISION'',''PENDINGDISABLE'')
			and   org_wide_flag = ''Y''
			and   org_id =  ' ||l_Org_Id||
			' and   intent =  ''' ||l_Intent|| '''' ||

            ' UNION ALL

			select distinct h.rule_id from OKC_XPRT_RULE_HDRS_ALL h, table(:b3) s
			where h.org_wide_flag = ''Y''
      and   h.rule_id = value(s)
			and   h.org_id =  ' ||l_Org_Id||
			' and   h.intent =  ''' ||l_Intent|| '''' ||
			' UNION ALL

      select distinct assoc.rule_id from OKC_XPRT_TEMPLATE_RULES assoc, OKC_XPRT_RULE_HDRS_ALL rules, table(:b4) u
			where assoc.rule_id = rules.rule_id
      and  rules.rule_id = value(u)
			and assoc.template_id =  ' ||l_Template_Id||

			' )';

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
				   g_Module || l_Api_Name,
				   '205a: Stored the SQL on l_sql_string');
	  END IF;






	  OPEN  insert_cursor FOR l_sql_string USING l_request_rule_ids,l_request_rule_ids,l_request_rule_ids,l_request_rule_ids;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
				   g_Module || l_Api_Name,
				   '205b: l_sql_string :' || l_sql_string);
	  END IF;



            LOOP

              FETCH insert_cursor INTO  condition_question_id, outcome_question_id;

	      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
				   g_Module || l_Api_Name,
				   '210: condition_question_id:' || condition_question_id);
		    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
				   g_Module || l_Api_Name,
				   '220: outcome_question_id:' || outcome_question_id);
	      END IF;

              EXIT WHEN insert_cursor%NOTFOUND;
              insert into OKC_XPRT_QUESTION_REF_T
		    (
		     condition_question_id,
		     outcome_question_id
		    )
		    values
		    (
		     condition_question_id,
		     outcome_question_id
		    );
           END LOOP;

		     CLOSE insert_cursor;


	begin

	  FOR rec IN circular_check LOOP
	  	null;
	--    exit;
	  END LOOP;

	exception

	  WHEN Circular_Ref_Exception THEN

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 Fnd_Log.STRING(Fnd_Log.Level_Procedure,
							 g_Module || l_Api_Name,
							 '300: Failed for l_Template_Id:' || l_Template_Id);
	   END IF;

		 delete from OKC_XPRT_QUESTION_REF_T;

		 raise Circular_Ref_Exception;
	end;


	delete from OKC_XPRT_QUESTION_REF_T;

    -- For each template, we need to check for circular reference
    -- Only if all the templates are OK, we return success
    -- Else we add the rule to the QA error stack
  END LOOP;

EXCEPTION

    WHEN Circular_Ref_Exception THEN

    	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
    	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
    	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
    	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
    	    l_qa_errors_t_rec.QA_CODE                    := G_CHECK_CIRCULAR_DEPENDENCY;
    	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_CIRCULAR_DEPENDENCY;
    	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_CHECK_CIRCULAR_DEPENDENCY);
    	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                            G_OKC_CIRCULAR_DEPENDENCY);
    	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                            G_OKC_CIRCULAR_DEPENDENCY_S);
    	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
    	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

    	    -- insert into okc_qa_errors_t
    	    insert_qa_errors_t
    	    (
    	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
    		x_return_status        =>  x_return_status,
              x_msg_count            =>  x_msg_count,
              x_msg_data             =>  x_msg_data
    	    );

    	    -- set QA status to Error
             x_qa_status     :=  'E';


        -- handle the QA error
    WHEN OTHERS THEN

    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.g_Current_Runtime_Level) THEN
      Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                     g_Module || l_Api_Name,
                     '4000: Leaving ' || g_Pkg_Name || '.' || l_Api_Name);
    END IF;

    IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.g_Msg_Lvl_Unexp_Error) THEN
      Fnd_Msg_Pub.Add_Exc_Msg(g_Pkg_Name, l_Api_Name);
    END IF;
    x_Return_Status := g_Ret_Sts_Unexp_Error;
    x_msg_data := SQLERRM;
    x_msg_count := 1;
    Fnd_Msg_Pub.Count_And_Get(p_Encoded => 'F',
                              p_Count   => x_Msg_Count,
                              p_Data    => x_Msg_Data);

END check_circular_dependency;

---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_expired_clauses
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

CURSOR csr_rule_dtls IS
SELECT rule_name
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

CURSOR csr_clause_options IS
SELECT article_id,
       article_title
FROM
(
        -- All DISTINCT Clauses from Conditions
        SELECT v.object_value_code article_id,
               a.article_title
        FROM okc_xprt_rule_cond_vals v,
             okc_xprt_rule_conditions c,
             okc_xprt_rule_hdrs_all r,
             okc_articles_all a
        WHERE v.rule_condition_id = c.rule_condition_id
          AND c.rule_id = r.rule_id
          AND a.article_id = to_number(v.object_value_code) -- Fixed for Bug 4935811. Removed to_char on article_id
          AND c.object_type = 'CLAUSE'
          AND r.rule_id  = p_rule_id
	  GROUP BY v.object_value_code, a.article_title
        UNION
        -- All DISTINCT Clauses from Outcome
        SELECT to_char(o.object_value_id) article_id,
               a.article_title
        FROM okc_xprt_rule_outcomes o,
             okc_xprt_rule_hdrs_all r,
             okc_articles_all a
        WHERE o.rule_id = r.rule_id
          AND a.article_id = o.object_value_id
          AND o.object_type = 'CLAUSE'
          AND r.rule_id  = p_rule_id
	   GROUP BY o.object_value_id, a.article_title
 ) ;

CURSOR l_check_art_effectivity(p_article_id IN NUMBER) IS
SELECT v.article_status
FROM okc_article_versions v,
     okc_articles_all a
WHERE a.article_id = v.article_id
  AND a.article_id = p_article_id
  AND v.article_status IN ('APPROVED','ON_HOLD')
  AND sysdate BETWEEN v.start_date AND NVL(v.end_date,sysdate+1);

CURSOR csr_approved_ver_exists(p_article_id IN NUMBER) IS
SELECT 'x'
FROM okc_article_versions v,
     okc_articles_all a
WHERE a.article_id = v.article_id
  AND a.article_id = p_article_id
  AND v.article_status IN ('APPROVED','ON_HOLD');


  l_clause_title VARCHAR2(2000);


l_api_name                CONSTANT VARCHAR2(30) := 'check_expired_clauses';
l_dummy                   VARCHAR2(1);
l_status                  VARCHAR2(30);
l_approved_exists         VARCHAR2(1) :=NULL;
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name;
  CLOSE csr_rule_dtls;

  -- Get all Clauses in the current Rule
  FOR rec_clause_options IN csr_clause_options
  LOOP
    -- For each clause check if there exists a version valid as of sysdate
    OPEN l_check_art_effectivity(p_article_id => rec_clause_options.article_id);
      FETCH l_check_art_effectivity INTO l_status;
	  IF l_check_art_effectivity%NOTFOUND THEN
	    -- article version not active as of SYSDATE
	    -- Check if the article has a approved version existing
	    l_approved_exists := NULL;
	    OPEN csr_approved_ver_exists(p_article_id => rec_clause_options.article_id);
           FETCH csr_approved_ver_exists INTO l_approved_exists;
		  IF csr_approved_ver_exists%FOUND THEN
		   -- clause was approved and current version is expired
    	 -- No valid clause versions as of sysdate

              -- Bug 12721915 Start
              IF g_concat_art_no = 'Y'  THEN
                 l_clause_title := get_article_title (rec_clause_options.article_id,rec_clause_options.article_title);
              ELSE
                 l_clause_title := rec_clause_options.article_title;
              END IF;
           -- Bug 12721915 End

    	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
    	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
    	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
    	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
    	    l_qa_errors_t_rec.QA_CODE                    := G_CHECK_EXPIRED_CLAUSES;
    	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_EXP_RULE_CLAUSE;
    	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_CHECK_EXPIRED_CLAUSES);
    	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                            G_OKC_EXP_RULE_CLAUSE,
    											 'CLAUSE', l_clause_title

    											 );
    	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                            G_OKC_EXP_RULE_CLAUSE_S,
    											 'CLAUSE', l_clause_title
    											 );
    	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
    	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

    	    -- insert into okc_qa_errors_t
    	    insert_qa_errors_t
    	    (
    	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
    		x_return_status        =>  x_return_status,
              x_msg_count            =>  x_msg_count,
              x_msg_data             =>  x_msg_data
    	    );

    	    -- set QA status to Error
         x_qa_status     :=  'E';

	    END IF; -- Clause had a approved version
         CLOSE csr_approved_ver_exists;
	  Else
	     If l_status = 'ON_HOLD' THEN

            -- Bug 12721915 Start
              IF g_concat_art_no = 'Y'  THEN
                 l_clause_title := get_article_title (rec_clause_options.article_id,rec_clause_options.article_title);
              ELSE
                 l_clause_title := rec_clause_options.article_title;
              END IF;
           -- Bug 12721915 End


		   l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
		   l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
             l_qa_errors_t_rec.TITLE                      := l_rule_name;
	        l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
	        l_qa_errors_t_rec.QA_CODE                    := G_CHECK_EXPIRED_CLAUSES;
	        l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_HOLD_RULE_CLAUSE;
	        l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
		                                                        G_OKC_HOLD_RULE_CLAUSE,
		    											 'CLAUSE_NAME',
		    											 l_clause_title
		    											 );
             l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
	                                                             G_OKC_HOLD_RULE_CLAUSE_S,
											           'CLAUSE',
											           l_clause_title
											           );
		   l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
		   l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

		   -- insert into okc_qa_errors_t
		   insert_qa_errors_t
		   (
		    	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
		    		x_return_status        =>  x_return_status,
		          x_msg_count            =>  x_msg_count,
		          x_msg_data             =>  x_msg_data
		   );

		   -- set QA status to Error
             x_qa_status     :=  'E';
		End IF;
	  END IF; -- no valid clause version
    CLOSE l_check_art_effectivity;

  END LOOP; -- all clauses in rule

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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_expired_clauses;

---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_draft_clauses
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

CURSOR csr_rule_dtls IS
SELECT rule_name
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

CURSOR csr_clause_options IS
SELECT article_id,
       article_title
FROM
(
        -- All DISTINCT Clauses from Conditions
        SELECT v.object_value_code article_id,
               a.article_title
        FROM okc_xprt_rule_cond_vals v,
             okc_xprt_rule_conditions c,
             okc_xprt_rule_hdrs_all r,
             okc_articles_all a
        WHERE v.rule_condition_id = c.rule_condition_id
          AND c.rule_id = r.rule_id
          AND to_char(a.article_id) = v.object_value_code
          AND c.object_type = 'CLAUSE'
          AND r.rule_id  = p_rule_id
	  GROUP BY v.object_value_code, a.article_title
        UNION
        -- All DISTINCT Clauses from Outcome
        SELECT to_char(o.object_value_id) article_id,
               a.article_title
        FROM okc_xprt_rule_outcomes o,
             okc_xprt_rule_hdrs_all r,
             okc_articles_all a
        WHERE o.rule_id = r.rule_id
          AND a.article_id = o.object_value_id
          AND o.object_type = 'CLAUSE'
          AND r.rule_id  = p_rule_id
	   GROUP BY o.object_value_id, a.article_title
 ) ;

CURSOR l_check_art_effectivity(p_article_id IN NUMBER) IS
SELECT 'x'
FROM okc_article_versions v,
     okc_articles_all a
WHERE a.article_id = v.article_id
  AND a.article_id = p_article_id
  AND v.article_status IN ('DRAFT','PENDING_APPROVAL','REJECTED')
  -- AND sysdate BETWEEN v.start_date AND NVL(v.end_date,sysdate+1)
  AND NOT EXISTS
  (
   SELECT 'x'
     FROM okc_article_versions v,
          okc_articles_all a
     WHERE a.article_id = v.article_id
       AND a.article_id = p_article_id
       AND v.article_status IN ('APPROVED','ON_HOLD')
  )
  ;

l_api_name                CONSTANT VARCHAR2(30) := 'check_draft_clauses';
l_dummy                   VARCHAR2(1);
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

l_clause_title VARCHAR2(2000);

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name;
  CLOSE csr_rule_dtls;

  -- Get all Clauses in the current Rule
  FOR rec_clause_options IN csr_clause_options
  LOOP
    -- For each clause check if there exists a version valid as of sysdate
    OPEN l_check_art_effectivity(p_article_id => rec_clause_options.article_id);
      FETCH l_check_art_effectivity INTO l_dummy;
	  IF l_check_art_effectivity%FOUND THEN
	    -- Draft Version and no approved version exists

            -- Bug 12721915 Start
              IF g_concat_art_no = 'Y'  THEN
                 l_clause_title := get_article_title (rec_clause_options.article_id,rec_clause_options.article_title);
              ELSE
                 l_clause_title := rec_clause_options.article_title;
              END IF;
           -- Bug 12721915 End


	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
	    l_qa_errors_t_rec.QA_CODE                    := G_check_draft_clauses;
	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_DFT_RULE_CLAUSE;
	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_CHECK_DRAFT_CLAUSES);
	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_DFT_RULE_CLAUSE,
											 'CLAUSE',
											 l_clause_title
											 );
	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_DFT_RULE_CLAUSE_S,
											 'CLAUSE',
											 l_clause_title
											 );
	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

	    -- insert into okc_qa_errors_t
	    insert_qa_errors_t
	    (
	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
		x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data
	    );

	    -- set QA status to Error
         x_qa_status     :=  'E';

	  END IF; -- no valid clause version
    CLOSE l_check_art_effectivity;

  END LOOP; -- all clauses in rule

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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_draft_clauses;

---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_invalid_vset_qst
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

CURSOR csr_rule_dtls IS
SELECT rule_name
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

-- List of questions used in rule
CURSOR csr_rule_questions IS
-- Questions in Conditions
SELECT DISTINCT q.question_name question_name,
       c.object_value_set_name value_set_name,
	  q.question_id question_id
FROM okc_xprt_rule_conditions c,
     okc_xprt_questions_vl q
WHERE q.question_id = c.object_code
  AND c.object_type='QUESTION'
  AND c.object_code_datatype IN ('L','B')
  AND c.rule_id = p_rule_id
UNION
-- Questions in Outcome
SELECT DISTINCT q.question_name question_name,
       q.value_set_name value_set_name,
	  q.question_id question_id
FROM okc_xprt_rule_outcomes o,
     okc_xprt_questions_vl q
WHERE q.question_id = o.object_value_id
  AND o.object_type='QUESTION'
  AND q.question_datatype IN ('L','B')
  AND o.rule_id = p_rule_id;

-- List of Values used in Rule for a Question
CURSOR csr_rule_question_values(p_question_id IN NUMBER) IS
SELECT v.object_value_code question_value
FROM  okc_xprt_rule_conditions c,
      okc_xprt_rule_cond_vals v
WHERE c.rule_condition_id = v.rule_condition_id
   AND c.object_type = 'QUESTION'
   AND c.object_code_datatype IN ('L','B')
   AND c.rule_id = p_rule_id
   AND c.object_code = to_char(p_question_id);

CURSOR csr_value_set_dtls(p_value_set_name IN VARCHAR2) IS
SELECT validation_type,
       flex_value_set_id
FROM FND_FLEX_VALUE_SETS
WHERE flex_value_set_name = p_value_set_name;

-- Create Dynamic sql for the valueset for Table
CURSOR csr_value_set_tab(p_value_set_id IN NUMBER) IS
SELECT  application_table_name,
        value_column_name,
        id_column_name,
        additional_where_clause
FROM fnd_flex_validation_tables
WHERE flex_value_set_id = p_value_set_id;

-- SQL for Valueset type Independent
CURSOR csr_value_set_ind(p_flex_value_id IN NUMBER) IS
SELECT 'x'
FROM fnd_flex_values_vl
WHERE flex_value_id = p_flex_value_id
  AND enabled_flag = 'Y'
  AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active,SYSDATE+1);


TYPE NameList IS TABLE OF fnd_flex_validation_tables.value_column_name%TYPE INDEX BY BINARY_INTEGER;
TYPE IdList IS TABLE OF fnd_flex_validation_tables.id_column_name%TYPE INDEX BY BINARY_INTEGER;

l_api_name                CONSTANT VARCHAR2(30) := 'check_invalid_vset_qst';
l_validation_type         FND_FLEX_VALUE_SETS.validation_type%TYPE;
l_value_set_id            FND_FLEX_VALUE_SETS.flex_value_set_id%TYPE;
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

l_table_name              fnd_flex_validation_tables.application_table_name%TYPE;
l_name_col                fnd_flex_validation_tables.value_column_name%TYPE;
l_id_col                  fnd_flex_validation_tables.id_column_name%TYPE;
l_additional_where_clause fnd_flex_validation_tables.additional_where_clause%TYPE;
l_sql_stmt                LONG;
l_error_message           VARCHAR2(4000);
l_found                   VARCHAR2(1);
l_dummy                   VARCHAR2(1);

NameList_tbl                NameList;
IdList_tbl                  IdList;

TYPE cur_typ IS REF CURSOR;
c_cursor cur_typ;

i number;

tempName fnd_flex_validation_tables.value_column_name%TYPE ;
tempId fnd_flex_validation_tables.id_column_name%TYPE ;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name;
  CLOSE csr_rule_dtls;

  -- Get all questions in the current Rule
  FOR rec_rule_questions IN csr_rule_questions
  LOOP
    OPEN csr_value_set_dtls(p_value_set_name => rec_rule_questions.value_set_name);
      FETCH csr_value_set_dtls INTO l_validation_type,l_value_set_id;
	  IF csr_value_set_dtls%NOTFOUND THEN
	    -- Value Set deleted
	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
	    l_qa_errors_t_rec.QA_CODE                    := G_CHECK_INVALID_VSET_QST;
	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_INVALID_VSET_QST;
	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_CHECK_INVALID_VSET_QST);
	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_INVALID_VSET_QST,
											 'QUESTION',
											 rec_rule_questions.question_name
											 );
	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_INVALID_VSET_QST_S,
											 'QUESTION',
											 rec_rule_questions.question_name
											 );
	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

	    -- insert into okc_qa_errors_t
	    insert_qa_errors_t
	    (
	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
		x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data
	    );

	    -- set QA status to Error
         x_qa_status     :=  'E';

         CLOSE csr_value_set_dtls;
	    RETURN;
	  END IF; -- valueset deleted

	  -- If Validation Type is table then check the dynamic sql is valid
	  IF l_validation_type = 'F' THEN

        -- Valueset is Table

         -- Build the dynamic SQL for the valueset
           OPEN csr_value_set_tab(p_value_set_id => l_value_set_id);
             FETCH csr_value_set_tab INTO l_table_name, l_name_col, l_id_col, l_additional_where_clause;
           CLOSE csr_value_set_tab;

           l_sql_stmt :=  'SELECT '||l_name_col||' , '||l_id_col||
                          ' FROM  '||l_table_name||' '||
                          l_additional_where_clause ;

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_table_name  '||l_table_name);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_name_col '||l_name_col);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_id_col  '||l_id_col);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_additional_where_clause '||l_additional_where_clause);
           END IF;
         -- execute the dynamic sql
            BEGIN
--              EXECUTE IMMEDIATE l_sql_stmt
--                 BULK COLLECT INTO NameList_tbl, IdList_tbl ;
			  i:=0;
			  OPEN c_cursor FOR l_sql_stmt;
			  LOOP
				 FETCH c_cursor INTO tempName, tempId;
				 EXIT WHEN c_cursor%NOTFOUND;

				 -- process row here
				 NameList_tbl(i) := tempName;
				 IdList_tbl(i) := tempId;
				 i:=i+1;
			  END LOOP;
			  CLOSE c_cursor;



            EXCEPTION
               WHEN OTHERS THEN
			   -- SQL is Invalid
             	    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
             	    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
             	    l_qa_errors_t_rec.TITLE                := l_rule_name;
             	    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
             	    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETSQL_QST;
             	    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETSQL_QST;
             	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETSQL_QST);
             	    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETSQL_QST,
             											 'QUESTION',
             											 rec_rule_questions.question_name
             											 );
             	    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETSQL_QST_S,
             											 'QUESTION',
             											 rec_rule_questions.question_name
             											 );
             	    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
             	    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

             	    -- insert into okc_qa_errors_t
             	    insert_qa_errors_t
             	    (
             	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
             		x_return_status        =>  x_return_status,
                    x_msg_count            =>  x_msg_count,
                    x_msg_data             =>  x_msg_data
             	    );

             	    -- set QA status to Error
                      x_qa_status     :=  'E';
                   CLOSE csr_value_set_dtls;
             	    RETURN;
            END; -- Valueset Type F and SQL

		  -- SQL Is Valid, check if the Value used in Rule still exists
		  FOR rec_rule_question_values IN csr_rule_question_values(p_question_id => rec_rule_questions.question_id)
		  LOOP
		    -- check if value exists
		    l_found := 'N';
		    FOR i IN NVL(IdList_tbl.FIRST,0)..NVL(IdList_tbl.LAST,-1)
		    LOOP
		     IF IdList_tbl(i) = rec_rule_question_values.question_value THEN
			  -- found value
			   l_found := 'Y';
			END IF; -- check if the value matches
		    END LOOP; -- for all ids
		    -- check if question value was found
		    IF l_found = 'N' THEN
		      -- question value not in value set sql
             	    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
             	    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
             	    l_qa_errors_t_rec.TITLE                := l_rule_name;
             	    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
             	    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETVAL_QST;
             	    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETVAL_QST;
             	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETVAL_QST);
             	    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_QST,
             											 'QUESTION',
             											 rec_rule_questions.question_name,
             											 'VALUE_SET_NAME',
             											 rec_rule_questions.value_set_name
             											 );
             	    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_QST_S,
             											 'QUESTION',
             											 rec_rule_questions.question_name
             											 );
             	    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
             	    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

             	    -- insert into okc_qa_errors_t
             	    insert_qa_errors_t
             	    (
             	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
             		x_return_status        =>  x_return_status,
                    x_msg_count            =>  x_msg_count,
                    x_msg_data             =>  x_msg_data
             	    );

             	    -- set QA status to Error
                      x_qa_status     :=  'E';
                   CLOSE csr_value_set_dtls;
             	    RETURN;
		    END IF; -- question value was not found

		  END LOOP; -- for each value for the question type Table



	  END IF; -- validation_type is 'F'

	  -- csr_value_set_ind(p_flex_value_id => rec_rule_question_values.question_value)
	  IF l_validation_type = 'I' THEN
	    FOR rec_rule_question_values IN csr_rule_question_values(p_question_id => rec_rule_questions.question_id)
		  LOOP
		    -- check if value exists
		    OPEN csr_value_set_ind(p_flex_value_id => rec_rule_question_values.question_value);
		      FETCH csr_value_set_ind INTO l_dummy;
			 IF csr_value_set_ind%NOTFOUND THEN
		      -- question value not in value set independent value set
             	    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
             	    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
             	    l_qa_errors_t_rec.TITLE                := l_rule_name;
             	    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
             	    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETVAL_QST;
             	    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETVAL_QST;
             	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETVAL_QST);
             	    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_QST,
             											 'QUESTION',
             											 rec_rule_questions.question_name,
													 'VALUE_SET_NAME',
							                               rec_rule_questions.value_set_name
             											 );
             	    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_QST_S,
             											 'QUESTION',
             											 rec_rule_questions.question_name
             											 );
             	    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
             	    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

             	    -- insert into okc_qa_errors_t
             	    insert_qa_errors_t
             	    (
             	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
             		x_return_status        =>  x_return_status,
                    x_msg_count            =>  x_msg_count,
                    x_msg_data             =>  x_msg_data
             	    );

             	    -- set QA status to Error
                      x_qa_status     :=  'E';
		         CLOSE csr_value_set_ind;
                   CLOSE csr_value_set_dtls;
             	    RETURN;
			 END IF; -- question value not exists
		    CLOSE csr_value_set_ind;


            END LOOP; -- for each value for the question type Independent

	  END IF; -- validation_type is 'I'





    CLOSE csr_value_set_dtls;

  END LOOP; -- all questions in rule

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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_invalid_vset_qst;


---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_invalid_vset_var
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

CURSOR csr_rule_dtls IS
SELECT rule_name
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

-- List of system variables in Rule
CURSOR csr_rule_variables IS
SELECT DISTINCT okc_xprt_util_pvt.get_object_name(c.OBJECT_TYPE,c.OBJECT_CODE)  variable_name,
       c.object_code  variable_code,
       c.object_value_set_name value_set_name
  FROM okc_xprt_rule_conditions c
 WHERE c.rule_id = p_rule_id
   AND c.object_type = 'VARIABLE'
   AND c.object_code_datatype = 'V';

-- List of Values used in Rule for a Variable
CURSOR csr_rule_variable_values(p_variable_name IN VARCHAR2) IS
SELECT v.object_value_code variable_value
FROM  okc_xprt_rule_conditions c,
      okc_xprt_rule_cond_vals v
WHERE c.rule_condition_id = v.rule_condition_id
   AND c.object_type = 'VARIABLE'
   AND c.object_code_datatype = 'V'
   AND c.rule_id = p_rule_id
   AND c.object_code = p_variable_name;

CURSOR csr_value_set_dtls(p_value_set_name IN VARCHAR2) IS
SELECT validation_type,
       flex_value_set_id
FROM FND_FLEX_VALUE_SETS
WHERE flex_value_set_name = p_value_set_name;

-- Create Dynamic sql for the valueset for Table
CURSOR csr_value_set_tab(p_value_set_id IN NUMBER) IS
SELECT  application_table_name,
        value_column_name,
        id_column_name,
        additional_where_clause
FROM fnd_flex_validation_tables
WHERE flex_value_set_id = p_value_set_id;

-- SQL for Valueset type Independent
CURSOR csr_value_set_ind(p_flex_value_id IN NUMBER) IS
SELECT 'x'
FROM fnd_flex_values_vl
WHERE flex_value_id = p_flex_value_id
  AND enabled_flag = 'Y'
  AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active,SYSDATE+1);

--Bug 5721543 New cursor for checking Item value against MTL_SYSTEM_ITEMS_VL
CURSOR csr_sell_item_exists(p_concatenated_segments VARCHAR2) IS
select 'X'
from MTL_SYSTEM_ITEMS_VL
where organization_id =
  TO_NUMBER(oe_sys_parameters.value('MASTER_ORGANIZATION_ID', to_number(fnd_profile.value('ORG_ID'))))
AND (bom_item_type = 1 OR bom_item_type = 4)
AND vendor_warranty_flag = 'N'
AND primary_uom_code <> 'ENR'
AND concatenated_segments = p_concatenated_segments
order by 1;


--Bug 4691106 replaced fnd_flex_validation_tables.value_column_name%TYPE with VARCHAR2(1000)
TYPE NameList IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
TYPE IdList IS TABLE OF fnd_flex_validation_tables.id_column_name%TYPE INDEX BY BINARY_INTEGER;

l_api_name                CONSTANT VARCHAR2(30) := 'check_invalid_vset_var';
l_validation_type         FND_FLEX_VALUE_SETS.validation_type%TYPE;
l_value_set_id            FND_FLEX_VALUE_SETS.flex_value_set_id%TYPE;
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

l_table_name              fnd_flex_validation_tables.application_table_name%TYPE;
l_name_col                fnd_flex_validation_tables.value_column_name%TYPE;
l_id_col                  fnd_flex_validation_tables.id_column_name%TYPE;
l_additional_where_clause fnd_flex_validation_tables.additional_where_clause%TYPE;
l_sql_stmt                LONG;
l_error_message           VARCHAR2(4000);
l_found                   VARCHAR2(1);
l_dummy                   VARCHAR2(1);

NameList_tbl                NameList;
IdList_tbl                  IdList;

TYPE cur_typ IS REF CURSOR;
c_cursor cur_typ;

i number;

--Bug 4691106 replaced tempName fnd_flex_validation_tables.value_column_name%TYPE ; with below stmt
tempName VARCHAR2(1000) ;
tempId fnd_flex_validation_tables.id_column_name%TYPE ;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name;
  CLOSE csr_rule_dtls;

  -- Get all Variables in the current Rule
  FOR rec_rule_variables IN csr_rule_variables
  LOOP
    OPEN csr_value_set_dtls(p_value_set_name => rec_rule_variables.value_set_name);
      FETCH csr_value_set_dtls INTO l_validation_type,l_value_set_id;
	  IF csr_value_set_dtls%NOTFOUND THEN
	    -- Value Set deleted
	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
	    l_qa_errors_t_rec.QA_CODE                    := G_CHECK_INVALID_VSET_VAR;
	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_INVALID_VSET_VAR;
	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_check_invalid_vset_var);
	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_INVALID_VSET_VAR,
											 'VARIABLE',
											 rec_rule_variables.variable_name,
                                                        'VALUE_SET_NAME',
											 rec_rule_variables.value_set_name
											 );
	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_INVALID_VSET_VAR_S,
											 'VARIABLE',
											 rec_rule_variables.variable_name
											 );
	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

	    -- insert into okc_qa_errors_t
	    insert_qa_errors_t
	    (
	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
		x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data
	    );

	    -- set QA status to Error
         x_qa_status     :=  'E';

         CLOSE csr_value_set_dtls;
	    RETURN;
	  END IF; -- valueset deleted

	  -- Begin: Fix for Bug 5721543
	  -- If Variable code is OKC$S_ITEM then use the special cursor to validate the item
	  -- prsence in the Item value set query, Else follow the regular steps of verifying query, check the value

	  IF rec_rule_variables.variable_code = 'OKC$S_ITEM' THEN
	     -- Add Cursor for getting the Item value used in Rule
	     FOR  rec_rule_variable_values IN csr_rule_variable_values(rec_rule_variables.variable_code)
	     LOOP
		     -- Check if the Item exists in the Item value set
		     OPEN csr_sell_item_exists(rec_rule_variable_values.variable_value);
		     FETCH csr_sell_item_exists INTO l_dummy;
		     IF csr_sell_item_exists%NOTFOUND THEN
			    -- Add Value not found QA failure
			    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
			    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
			    l_qa_errors_t_rec.TITLE                := l_rule_name;
			    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
			    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETVAL_VAR;
			    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETVAL_VAR;
			    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETVAL_VAR);
			    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
									  G_OKC_INVALID_VSETVAL_VAR,
													 'VARIABLE',
													 rec_rule_variables.variable_name,
														 'VAR_VALUE',
														 rec_rule_variable_values.variable_value,
														 'VALUE_SET_NAME',
														 rec_rule_variables.value_set_name
													 );
			    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
									  G_OKC_INVALID_VSETVAL_VAR_S,
													 'VARIABLE',
													 rec_rule_variables.variable_name
													 );
			    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
			    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

			    -- insert into okc_qa_errors_t
			    insert_qa_errors_t
			    (
			     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
				x_return_status        =>  x_return_status,
			    x_msg_count            =>  x_msg_count,
			    x_msg_data             =>  x_msg_data
			    );

			    -- set QA status to Error
			   x_qa_status     :=  'E';
			   RETURN;
	             END IF;
	             CLOSE csr_sell_item_exists;
	     END LOOP;
	  ELSE  --  Added for Bug 5721543
	     -- Variable code in Rule is not OKC$S_ITEM
	     -- Follow regular steps, Check Value set query, check  rule value against Value set values


	  -- If Validation Type is table then check the dynamic sql is valid
	  IF l_validation_type = 'F' THEN

        -- Valueset is Table

         -- Build the dynamic SQL for the valueset
           OPEN csr_value_set_tab(p_value_set_id => l_value_set_id);
             FETCH csr_value_set_tab INTO l_table_name, l_name_col, l_id_col, l_additional_where_clause;
           CLOSE csr_value_set_tab;

           l_sql_stmt :=  'SELECT '||l_name_col||' , '||l_id_col||
                          ' FROM  '||l_table_name||' '||
                          l_additional_where_clause ;

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_table_name  '||l_table_name);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_name_col '||l_name_col);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_id_col  '||l_id_col);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '150: l_additional_where_clause '||l_additional_where_clause);
           END IF;

	    -- put sql in log
	     fnd_file.put_line(FND_FILE.LOG,' ');
	     fnd_file.put_line(FND_FILE.LOG,'Variable : '||rec_rule_variables.variable_name);
	     fnd_file.put_line(FND_FILE.LOG,'Dynamic SQL for Valueset: '||rec_rule_variables.value_set_name);
	     fnd_file.put_line(FND_FILE.LOG,'SELECT '||l_name_col||' , '||l_id_col);
	     fnd_file.put_line(FND_FILE.LOG,'FROM '||l_table_name||'  ');
	     fnd_file.put_line(FND_FILE.LOG,l_additional_where_clause);
	     fnd_file.put_line(FND_FILE.LOG,' ');

         -- execute the dynamic sql
            BEGIN
--              EXECUTE IMMEDIATE l_sql_stmt
--                 BULK COLLECT INTO NameList_tbl, IdList_tbl ;

			  i:=0;
			  OPEN c_cursor FOR l_sql_stmt;
			  LOOP
				 FETCH c_cursor INTO tempName, tempId;
				 EXIT WHEN c_cursor%NOTFOUND;

				 -- process row here
				 NameList_tbl(i) := tempName;
				 IdList_tbl(i) := tempId;
				 i:=i+1;
			  END LOOP;
			  CLOSE c_cursor;

            EXCEPTION
               WHEN OTHERS THEN
			   -- SQL is Invalid
             	    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
             	    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
             	    l_qa_errors_t_rec.TITLE                := l_rule_name;
             	    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
             	    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETSQL_VAR;
             	    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETSQL_VAR;
             	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETSQL_VAR);
             	    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETSQL_VAR,
             											 'VARIABLE',
             											 rec_rule_variables.variable_name,
                                                                  'VALUE_SET_NAME',
											           rec_rule_variables.value_set_name
             											 );
             	    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETSQL_VAR_S,
             											 'VARIABLE',
             											 rec_rule_variables.variable_name
             											 );
             	    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
             	    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

             	    -- insert into okc_qa_errors_t
             	    insert_qa_errors_t
             	    (
             	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
             		x_return_status        =>  x_return_status,
                    x_msg_count            =>  x_msg_count,
                    x_msg_data             =>  x_msg_data
             	    );

             	    -- set QA status to Error
                      x_qa_status     :=  'E';
			    CLOSE csr_value_set_dtls;
             	    RETURN;
            END; -- Valueset Type F and SQL

		  -- SQL Is Valid, check if the Value used in Rule still exists
		  FOR rec_rule_variable_values IN csr_rule_variable_values(p_variable_name => rec_rule_variables.variable_code)
		  LOOP
		    -- check if value exists
		    l_found := 'N';
		    FOR i IN NVL(IdList_tbl.FIRST,0)..NVL(IdList_tbl.LAST,-1)
		    LOOP
		     IF IdList_tbl(i) = rec_rule_variable_values.variable_value THEN
			  -- found value
			   l_found := 'Y';
			END IF; -- check if the value matches
		    END LOOP; -- for all ids
		    -- check if variable value was found
		    IF l_found = 'N' THEN
		      -- variable value not in value set sql
             	    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
             	    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
             	    l_qa_errors_t_rec.TITLE                := l_rule_name;
             	    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
             	    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETVAL_VAR;
             	    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETVAL_VAR;
             	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETVAL_VAR);
             	    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_VAR,
             											 'VARIABLE',
             											 rec_rule_variables.variable_name,
													 'VAR_VALUE',
													 rec_rule_variable_values.variable_value,
													 'VALUE_SET_NAME',
													 rec_rule_variables.value_set_name
             											 );
             	    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_VAR_S,
             											 'VARIABLE',
             											 rec_rule_variables.variable_name
             											 );
             	    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
             	    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

             	    -- insert into okc_qa_errors_t
             	    insert_qa_errors_t
             	    (
             	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
             		x_return_status        =>  x_return_status,
                    x_msg_count            =>  x_msg_count,
                    x_msg_data             =>  x_msg_data
             	    );

             	    -- set QA status to Error
                      x_qa_status     :=  'E';
			    CLOSE csr_value_set_dtls;
             	    RETURN;
		    END IF; -- variable value was not found

		  END LOOP; -- for each value for the variable type Table



	  END IF; -- validation_type is 'F'

	  -- csr_value_set_ind(p_flex_value_id => rec_rule_variable_values.variable_value)
	  IF l_validation_type = 'I' THEN
	    FOR rec_rule_variable_values IN csr_rule_variable_values(p_variable_name => rec_rule_variables.variable_code)
		  LOOP
		    -- check if value exists
		    OPEN csr_value_set_ind(p_flex_value_id => rec_rule_variable_values.variable_value);
		      FETCH csr_value_set_ind INTO l_dummy;
			 IF csr_value_set_ind%NOTFOUND THEN
		      -- variable value not in value set independent value set
             	    l_qa_errors_t_rec.SEQUENCE_ID          := p_sequence_id;
             	    l_qa_errors_t_rec.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
             	    l_qa_errors_t_rec.TITLE                := l_rule_name;
             	    l_qa_errors_t_rec.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
             	    l_qa_errors_t_rec.QA_CODE              := G_CHECK_INVALID_VSETVAL_VAR;
             	    l_qa_errors_t_rec.MESSAGE_NAME         := G_OKC_INVALID_VSETVAL_VAR;
             	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC   := get_qa_code_dtls(G_CHECK_INVALID_VSETVAL_VAR);
             	    l_qa_errors_t_rec.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_VAR,
             											 'VARIABLE',
             											 rec_rule_variables.variable_name
             											 );
             	    l_qa_errors_t_rec.SUGGESTION           := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                                  G_OKC_INVALID_VSETVAL_VAR_S,
             											 'VARIABLE',
             											 rec_rule_variables.variable_name
             											 );
             	    l_qa_errors_t_rec.CREATION_DATE        := G_CREATION_DATE;
             	    l_qa_errors_t_rec.RULE_ID              := p_rule_id;

             	    -- insert into okc_qa_errors_t
             	    insert_qa_errors_t
             	    (
             	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
             		x_return_status        =>  x_return_status,
                    x_msg_count            =>  x_msg_count,
                    x_msg_data             =>  x_msg_data
             	    );

             	    -- set QA status to Error
                      x_qa_status     :=  'E';
		         CLOSE csr_value_set_ind;
			    CLOSE csr_value_set_dtls;
             	    RETURN;
			 END IF; -- variable value not exists
		    CLOSE csr_value_set_ind;


            END LOOP; -- for each value for the variable type Independent

	  END IF; -- validation_type is 'I'

    END IF; -- Variable name in Rule is not OKC$S_ITEM for bug 5721543

    CLOSE csr_value_set_dtls;

  END LOOP; -- all variables in rule

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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_invalid_vset_var;

---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_invalid_questions
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

CURSOR csr_rule_dtls IS
SELECT rule_name
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

-- List of questions used in rule
CURSOR csr_rule_questions IS
-- Questions in Conditions LHS
SELECT DISTINCT q.question_name question_name
FROM okc_xprt_rule_conditions c,
     okc_xprt_questions_vl q
WHERE q.question_id = c.object_code
  AND c.object_type='QUESTION'
  AND c.rule_id = p_rule_id
  AND q.disabled_flag = 'Y'
UNION
-- Questions in Conditions RHS
SELECT DISTINCT q.question_name question_name
FROM okc_xprt_rule_conditions c,
     okc_xprt_questions_vl q
WHERE q.question_id = c.object_value_code
  AND c.object_value_type='QUESTION'
  AND c.rule_id = p_rule_id
  AND q.disabled_flag = 'Y'
UNION
-- Questions in Outcome
SELECT DISTINCT q.question_name question_name
FROM okc_xprt_rule_outcomes o,
     okc_xprt_questions_vl q
WHERE q.question_id = o.object_value_id
  AND o.object_type='QUESTION'
  AND o.rule_id = p_rule_id
  AND q.disabled_flag = 'Y' ;

l_api_name                CONSTANT VARCHAR2(30) := 'check_invalid_questions';
l_dummy                   VARCHAR2(1);
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name;
  CLOSE csr_rule_dtls;

  -- Check if any questions on the rule is disabled
    FOR rec_rule_questions IN csr_rule_questions
    LOOP
	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
	    l_qa_errors_t_rec.QA_CODE                    := G_CHECK_INVALID_QUESTION;
	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_INVALID_QUESTION;
	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_CHECK_INVALID_QUESTION);
	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_INVALID_QUESTION,
											 'QUESTION',
											 rec_rule_questions.question_name
											 );
	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_INVALID_QUESTION_S,
											 'QUESTION',
											 rec_rule_questions.question_name
											 );
	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

	    -- insert into okc_qa_errors_t
	    insert_qa_errors_t
	    (
	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
		x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data
	    );

	    -- set QA status to Error
         x_qa_status     :=  'E';
	 END LOOP; -- all questions that were disabled

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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_invalid_questions;

---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_rule_templates
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS


CURSOR csr_rule_dtls IS
SELECT rule_name, NVL(org_wide_flag,'N')
  FROM okc_xprt_rule_hdrs_all
 WHERE rule_id = p_rule_id;

CURSOR csr_rule_templates IS
SELECT 'x'
  FROM okc_xprt_template_rules
 WHERE rule_id = p_rule_id
   AND NVL(deleted_flag,'N') = 'N' ;

l_api_name                CONSTANT VARCHAR2(30) := 'check_rule_templates';
l_dummy                   VARCHAR2(1);
l_rule_name               okc_xprt_rule_hdrs_all.rule_name%TYPE;
l_org_wide_flag           okc_xprt_rule_hdrs_all.org_wide_flag%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- Get Rule Name
  OPEN csr_rule_dtls;
    FETCH csr_rule_dtls INTO l_rule_name, l_org_wide_flag;
  CLOSE csr_rule_dtls;

  -- If Rule is Org Wide then return
  IF l_org_wide_flag = 'Y' THEN
     RETURN;
  ELSE
     -- rule is NOT Org Wide, check if there exists atleast one template
	-- assigned to this rule

	OPEN csr_rule_templates;
	  FETCH csr_rule_templates INTO l_dummy;
	  IF csr_rule_templates%NOTFOUND THEN
	    -- error
	    l_qa_errors_t_rec.SEQUENCE_ID                := p_sequence_id;
	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
	    l_qa_errors_t_rec.TITLE                      := l_rule_name;
	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SEVERITY;
	    l_qa_errors_t_rec.QA_CODE                    := G_CHECK_RULE_TEMPLATES;
	    l_qa_errors_t_rec.MESSAGE_NAME               := G_OKC_RULE_TEMPLATES;
	    l_qa_errors_t_rec.PROBLEM_SHORT_DESC         := get_qa_code_dtls(G_CHECK_RULE_TEMPLATES);
	    l_qa_errors_t_rec.PROBLEM_DETAILS            := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_RULE_TEMPLATES
											 );
	    l_qa_errors_t_rec.SUGGESTION                 := OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_RULE_TEMPLATES_S
											 );
	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
	    l_qa_errors_t_rec.RULE_ID                    := p_rule_id;

	    -- insert into okc_qa_errors_t
	    insert_qa_errors_t
	    (
	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
		x_return_status        =>  x_return_status,
          x_msg_count            =>  x_msg_count,
          x_msg_data             =>  x_msg_data
	    );

	    -- set QA status to Error
         x_qa_status     :=  'E';

	  END IF; -- csr_rule_templates%NOTFOUND
	CLOSE csr_rule_templates;
  END IF; -- l_org_wide_flag = 'Y'



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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END  check_rule_templates;


---------------------------------------------------
--  Procedure
---------------------------------------------------
PROCEDURE check_invalid_udv_procedure
(
 p_rule_id        IN NUMBER,
 p_sequence_id    IN NUMBER,
 x_qa_status      OUT NOCOPY VARCHAR2,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_count      OUT NOCOPY NUMBER,
 x_msg_data       OUT NOCOPY VARCHAR2
) IS

CURSOR csr_rule_variables_w_proc IS
-- Expert Enabled User Defined Variables with Procedures
SELECT distinct v.procedure_name procedure_name,
   rcon.object_code variable_code, -- LHS of Condition
   t.variable_name variable_name,
   rhdr.rule_name rule_name
FROM okc_xprt_rule_hdrs_all rhdr,
   okc_xprt_rule_conditions rcon,
   okc_bus_variables_b v,
   okc_bus_variables_tl t
WHERE rhdr.rule_id = rcon.rule_id
AND rhdr.rule_id = p_rule_id
AND rcon.object_type = 'VARIABLE'
AND rcon.object_code = v.variable_code
AND v.variable_code = t.variable_code
AND v.variable_source = 'P'
AND t.LANGUAGE = USERENV('LANG')
UNION
SELECT distinct v.procedure_name procedure_name,
   rcon.object_value_code variable_code, -- RHS of Condition
   t.variable_name variable_name,
   rhdr.rule_name rule_name
FROM okc_xprt_rule_hdrs_all rhdr,
   okc_xprt_rule_conditions rcon,
   okc_bus_variables_b v,
   okc_bus_variables_tl t
WHERE rhdr.rule_id = rcon.rule_id
AND rhdr.rule_id = p_rule_id
AND rcon.object_value_type = 'VARIABLE'
AND rcon.object_code = v.variable_code
AND v.variable_code = t.variable_code
AND v.variable_source = 'P'
AND t.LANGUAGE = USERENV('LANG');

--Expected procedure name is SCHEMA.PACKAGENAME.PROCEDURENAME

CURSOR csr_check_proc_spec_status (p_procedure_name VARCHAR2) IS
SELECT status
FROM all_objects
WHERE object_name = SUBSTR(p_procedure_name,
                           INSTR(p_procedure_name,'.')+1,
                           (INSTR(p_procedure_name,'.',1,2) -
                            INSTR(p_procedure_name,'.') - 1))
AND object_type = 'PACKAGE'
AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1);


CURSOR csr_check_proc_body_status (p_procedure_name VARCHAR2) IS
SELECT status
FROM all_objects
WHERE object_name = SUBSTR(p_procedure_name,
                           INSTR(p_procedure_name,'.')+1,
                           (INSTR(p_procedure_name,'.',1,2) -
                            INSTR(p_procedure_name,'.') - 1))
AND object_type = 'PACKAGE BODY'
AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1);

CURSOR csr_check_proc_exists (p_procedure_name VARCHAR2) IS
SELECT 'X'
FROM all_source
WHERE name = SUBSTR(p_procedure_name,
                           INSTR(p_procedure_name,'.')+1,
                           (INSTR(p_procedure_name,'.',1,2) -
                            INSTR(p_procedure_name,'.') - 1))
AND type = 'PACKAGE'
AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1)
-- Added +1 for Instr for bug 5964390
AND text LIKE '%' || SUBSTR(p_procedure_name,INSTR(p_procedure_name,'.',1,2)+1) || '%';


l_api_name                CONSTANT VARCHAR2(30) := 'check_invalid_udv_procedure';
l_dummy                   VARCHAR2(1);
l_procedure_spec_status        ALL_OBJECTS.status%TYPE;
l_procedure_body_status        ALL_OBJECTS.status%TYPE;
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  FOR rec_rule_variables_w_proc IN csr_rule_variables_w_proc
  LOOP

     -- Check procedure existence and validity
     OPEN csr_check_proc_spec_status(p_procedure_name => rec_rule_variables_w_proc.procedure_name);
     FETCH csr_check_proc_spec_status INTO l_procedure_spec_status;

     OPEN csr_check_proc_body_status(p_procedure_name => rec_rule_variables_w_proc.procedure_name);
     FETCH csr_check_proc_body_status INTO l_procedure_body_status;

     OPEN csr_check_proc_exists(p_procedure_name => rec_rule_variables_w_proc.procedure_name);
     FETCH csr_check_proc_exists INTO l_dummy;

     -- Debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                         G_MODULE||l_api_name,
                         '120: Checking Procedure spec/body ' || rec_rule_variables_w_proc.procedure_name ||
                         'validity for variable'||rec_rule_variables_w_proc.variable_name);
     END IF;

     -- If Procedure Spec is invalid in DB then return warning
     IF l_procedure_spec_status = 'INVALID' OR l_procedure_body_status = 'INVALID' THEN
     	-- VARIABLE PROCEDURE IS INVALID
     	L_QA_ERRORS_T_REC.SEQUENCE_ID          := P_SEQUENCE_ID;
     	L_QA_ERRORS_T_REC.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
     	L_QA_ERRORS_T_REC.TITLE                := rec_rule_variables_w_proc.rule_name;
     	L_QA_ERRORS_T_REC.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
     	L_QA_ERRORS_T_REC.QA_CODE              := G_CHECK_INVALID_PROCEDURE_VAR;
     	L_QA_ERRORS_T_REC.MESSAGE_NAME         := G_OKC_INVALID_PROCEDURE_VAR;
     	L_QA_ERRORS_T_REC.PROBLEM_SHORT_DESC   := GET_QA_CODE_DTLS(G_CHECK_INVALID_PROCEDURE_VAR);
     	L_QA_ERRORS_T_REC.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.GET_MESSAGE('OKC',
     							                         G_OKC_INVALID_PROCEDURE_VAR,
     					      				         'VARIABLE',
										 rec_rule_variables_w_proc.variable_name,
     										 'PROCEDURE',
     										 rec_rule_variables_w_proc.procedure_name);
     	L_QA_ERRORS_T_REC.SUGGESTION           := OKC_TERMS_UTIL_PVT.GET_MESSAGE('OKC',
     							                         G_OKC_INVALID_PROCEDURE_VAR_S,
     										 'VARIABLE',
										 rec_rule_variables_w_proc.variable_name,
     										 'PROCEDURE',
     										 rec_rule_variables_w_proc.procedure_name);
     	L_QA_ERRORS_T_REC.CREATION_DATE        := G_CREATION_DATE;
     	L_QA_ERRORS_T_REC.RULE_ID              := P_RULE_ID;

     	-- INSERT INTO OKC_QA_ERRORS_T
        INSERT_QA_ERRORS_T
     	(
     	  P_QA_ERRORS_T_REC      =>  L_QA_ERRORS_T_REC,
     	  X_RETURN_STATUS        =>  X_RETURN_STATUS,
     	  X_MSG_COUNT            =>  X_MSG_COUNT,
     	  X_MSG_DATA             =>  X_MSG_DATA
     	 );

     	 -- SET QA STATUS TO ERROR
     	 x_qa_status     :=  'E';
     	 CLOSE csr_check_proc_spec_status;
     	 CLOSE csr_check_proc_body_status;
     	 CLOSE csr_check_proc_exists;
     	 RETURN;
      END IF; -- Procedure Spec is invalid

     -- Debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                         G_MODULE||l_api_name,
                         '110: Checking Procedure spec/body ' || rec_rule_variables_w_proc.procedure_name ||
                         'existence for variable'||rec_rule_variables_w_proc.variable_name);
     END IF;

     -- If Procedure Spec/Body/API not found in DB then return warning
     IF csr_check_proc_spec_status%NOTFOUND OR csr_check_proc_body_status%NOTFOUND
        OR csr_check_proc_exists%NOTFOUND THEN
     	-- VARIABLE PROCEDURE IS NULL
     	L_QA_ERRORS_T_REC.SEQUENCE_ID          := P_SEQUENCE_ID;
     	L_QA_ERRORS_T_REC.ERROR_RECORD_TYPE    := G_ERROR_RECORD_TYPE;
     	L_QA_ERRORS_T_REC.TITLE                := rec_rule_variables_w_proc.rule_name;
     	L_QA_ERRORS_T_REC.ERROR_SEVERITY       := G_RULE_QA_SEVERITY;
     	L_QA_ERRORS_T_REC.QA_CODE              := G_CHECK_NO_PROCEDURE_VAR;
     	L_QA_ERRORS_T_REC.MESSAGE_NAME         := G_OKC_NO_PROCEDURE_VAR;
     	L_QA_ERRORS_T_REC.PROBLEM_SHORT_DESC   := GET_QA_CODE_DTLS(G_CHECK_NO_PROCEDURE_VAR);
     	L_QA_ERRORS_T_REC.PROBLEM_DETAILS      := OKC_TERMS_UTIL_PVT.GET_MESSAGE('OKC',
     							                         G_OKC_NO_PROCEDURE_VAR,
     					      				         'VARIABLE',
     										 rec_rule_variables_w_proc.variable_name,
     										 'PROCEDURE',
     										 rec_rule_variables_w_proc.procedure_name);
     	L_QA_ERRORS_T_REC.SUGGESTION           := OKC_TERMS_UTIL_PVT.GET_MESSAGE('OKC',
     							                         G_OKC_NO_PROCEDURE_VAR_S,
     										 'VARIABLE',
     										 rec_rule_variables_w_proc.variable_name,
										 'PROCEDURE',
     										 rec_rule_variables_w_proc.procedure_name);
     	L_QA_ERRORS_T_REC.CREATION_DATE        := G_CREATION_DATE;
     	L_QA_ERRORS_T_REC.RULE_ID              := P_RULE_ID;

     	-- INSERT INTO OKC_QA_ERRORS_T
             INSERT_QA_ERRORS_T
     	(
     	  P_QA_ERRORS_T_REC      =>  L_QA_ERRORS_T_REC,
     	  X_RETURN_STATUS        =>  X_RETURN_STATUS,
     	  X_MSG_COUNT            =>  X_MSG_COUNT,
     	  X_MSG_DATA             =>  X_MSG_DATA
     	 );

     	 -- SET QA STATUS TO ERROR
     	 x_qa_status     :=  'E';
     	 RETURN;
     END IF; -- Procedure Spec/Body not existing in DB



      CLOSE csr_check_proc_spec_status;
      CLOSE csr_check_proc_body_status;
      CLOSE csr_check_proc_exists;

  END LOOP; -- all Vairables with procedures in rule

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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_invalid_udv_procedure;


/*
  Procedure to be called from UI and Import
  p_qa_mode : PUBLISH when publishing rules
              APPROVAL when approving template
		    DISABLE when disabling a rule
*/

PROCEDURE qa_rules
(
 p_qa_mode		    IN  VARCHAR2,
 p_ruleid_tbl           IN  RuleIdList,
 x_sequence_id		    OUT NOCOPY NUMBER,
 x_qa_status	         OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

CURSOR l_seq_csr IS
SELECT OKC_QA_ERRORS_T_S.NEXTVAL
  FROM DUAL;

--Added for Bug 4725397
CURSOR c_get_rule_org_id (p_rule_id NUMBER) IS
SELECT rules.org_id
FROM okc_xprt_rule_hdrs_all rules
WHERE rules.rule_id = p_rule_id;

l_api_name                CONSTANT VARCHAR2(30) := 'qa_rules';
l_sequence_id             okc_qa_errors_t.sequence_id%TYPE;
l_qa_status               VARCHAR2(1);
l_rule_qa_status          VARCHAR2(1);
l_qa_errors_t_rec         OKC_QA_ERRORS_T%ROWTYPE;
l_rule_org_id             NUMBER;
cyclic_check_flag         VARCHAR2(3);


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameter : '||p_qa_mode);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  x_qa_status     :=  'S';

  -- generate the sequence
  OPEN l_seq_csr;
    FETCH l_seq_csr INTO l_sequence_id;
  CLOSE l_seq_csr;

  x_sequence_id  := l_sequence_id;

  -- debug
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Sequence Id : '||l_sequence_id);
  END IF;

  --Added for Bug 4725397
  IF p_ruleid_tbl.COUNT > 0 THEN
     OPEN c_get_rule_org_id(p_ruleid_tbl(1));
     FETCH c_get_rule_org_id INTO l_rule_org_id;
     CLOSE c_get_rule_org_id;
     MO_GLOBAL.SET_POLICY_CONTEXT('S',l_rule_org_id);
  END IF;

   -- QA all rules in p_ruleid_tbl

   FOR i IN p_ruleid_tbl.FIRST..p_ruleid_tbl.LAST
   LOOP

	   -- Reset Rule QA status
	   l_rule_qa_status := 'S';

        /*
	     Following QA Checks are only done in PUBLISH mode
		1. check_expired_clauses
		2. check_draft_clauses
		3. check_circular_dependency
		4. check_invalid_questions
		5. check_rule_templates
		6. check_invalid_vset_var
	   */

	   IF p_qa_mode = 'PUBLISH' THEN

          	check_expired_clauses
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_expired_clauses x_qa_status : '||x_qa_status);
                END IF;


               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

          	check_draft_clauses
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_draft_clauses x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

         select fnd_profile.value('OKC_DISABLE_CYCLIC_CHECK') into cyclic_check_flag from dual;

           IF (NVL(cyclic_check_flag,'N')='N') THEN

          	check_circular_dependency
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                p_ruleid_tbl     =>  p_ruleid_tbl,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );
      END IF;


        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_circular_dependency x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;


          	check_invalid_questions
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_invalid_questions x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

          	check_rule_templates
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_rule_templates x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

          	check_invalid_vset_var
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_invalid_vset_var x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

		END IF; -- p_qa_mode is PUBLISH

		/*
		  Following QA Checks are always run for both modes i.e PUBLISH and APPROVAL
		  1. check_invalid_vset_qst
		*/

	   IF p_qa_mode IN ('PUBLISH','APPROVAL') THEN

          	check_invalid_vset_qst
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: After Calling check_invalid_vset_qst x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;


          	check_invalid_udv_procedure
               (
                p_rule_id        =>  p_ruleid_tbl(i),
                p_sequence_id    =>  l_sequence_id,
                x_qa_status      =>  l_qa_status,
                x_return_status  =>  x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data       =>  x_msg_data
               );

        	      IF l_qa_status = 'E' THEN
        	         x_qa_status := 'E';
			    l_rule_qa_status := 'E';
        	      END IF;

                -- debug
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '125: After Calling check_invalid_udv_procedure x_qa_status : '||x_qa_status);
                END IF;

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

	   END IF; -- p_qa_mode IN ('PUBLISH','APPROVAL')

	   -- If the rule passed all QAs successfully then insert into okc_qa_errors_t as success
	   IF l_rule_qa_status = 'S' THEN

        	    l_qa_errors_t_rec.SEQUENCE_ID                := l_sequence_id;
        	    l_qa_errors_t_rec.ERROR_RECORD_TYPE          := G_ERROR_RECORD_TYPE;
        	    l_qa_errors_t_rec.ERROR_SEVERITY             := G_RULE_QA_SUCCESS;
        	    l_qa_errors_t_rec.CREATION_DATE              := G_CREATION_DATE;
        	    l_qa_errors_t_rec.RULE_ID                    := p_ruleid_tbl(i);

        	    -- insert into okc_qa_errors_t
        	    insert_qa_errors_t
        	    (
        	     p_qa_errors_t_rec      =>  l_qa_errors_t_rec,
        		x_return_status        =>  x_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data
        	    );

               --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;

	   END IF; -- Rule QA was successful


   END LOOP; -- all rules in p_ruleid_tbl



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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END qa_rules;

/*
  This procedure will be called from Rules Publish or Disable UI
  p_sync_mode = PUBLISH or DISABLE
  p_org_id  Org Id of the Rules
  Depending on the p_sync_mode this API will update the rule status and kick-off the
  concurrent program to publish or disable rules

*/
PROCEDURE sync_rules
(
 p_sync_mode            IN  VARCHAR2,
 p_org_id               IN  NUMBER,
 p_ruleid_tbl           IN  RuleIdList,
 x_request_id  	    OUT NOCOPY NUMBER,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'sync_rules';
i                         BINARY_INTEGER;
l_user_name               fnd_user.user_name%TYPE;
l_notify                  BOOLEAN;
l_conc_pgm_desc		 fnd_new_messages.message_text%TYPE;

CURSOR csr_wf_role_user IS
SELECT name
  FROM wf_roles
 WHERE name = FND_GLOBAL.USER_NAME;

 l_conc_pgm VARCHAR2(100);
 l_okc_rules_engine VARCHAR2(1);

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameter p_sync_mode : '||p_sync_mode);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_org_id '||p_org_id);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- initialize i
     i := 0;

  -- For all rules in p_ruleid_tbl update the rule status to PENDINGPUB or PENDINGDISABLE
     FOR i IN NVL(p_ruleid_tbl.FIRST,0)..NVL(p_ruleid_tbl.LAST,-1)
	  LOOP
	    UPDATE okc_xprt_rule_hdrs_all
	       SET status_code = DECODE(p_sync_mode,'PUBLISH','PENDINGPUB',
		                                       'DISABLE','PENDINGDISABLE',
									     p_sync_mode)
		WHERE rule_id = p_ruleid_tbl(i);
	  END LOOP; -- all rules


   -- Commit the data
      commit work;

   -- Set the Notification User
      OPEN csr_wf_role_user;
	   FETCH csr_wf_role_user INTO l_user_name;
	     IF csr_wf_role_user%FOUND THEN
		  -- set Notify user
		   l_notify := fnd_submit.add_notification(FND_GLOBAL.USER_NAME);
		END IF; --
	 CLOSE csr_wf_role_user;

   -- Submit the Concurrent Program
      IF p_sync_mode = 'PUBLISH' THEN

    	    FND_MESSAGE.set_name('OKC','OKC_XPRT_RULE_CPRG_ACT_MSG');
            l_conc_pgm_desc := FND_MESSAGE.get;

      SELECT fnd_profile.Value('OKC_USE_CONTRACTS_RULES_ENGINE') INTO l_okc_rules_engine FROM dual;
      SELECT Decode(Nvl(l_okc_rules_engine,'N'),'Y','OKC_XPRT_PUBLISH_RULES_OKC','OKC_XPRT_PUBLISH_RULES') INTO l_conc_pgm FROM dual;


   		 x_request_id  := fnd_request.submit_request
		                  (application       => 'OKC',
					    program           => l_conc_pgm,
					    description       => l_conc_pgm_desc,
					    start_time        => NULL,
					    sub_request       => FALSE,
					    argument1         => p_org_id
					   );

	ELSIF p_sync_mode = 'DISABLE' THEN

    	    FND_MESSAGE.set_name('OKC','OKC_XPRT_RULE_CPRG_DIS_MSG');
            l_conc_pgm_desc := FND_MESSAGE.get;

      SELECT fnd_profile.Value('OKC_USE_CONTRACTS_RULES_ENGINE') INTO l_okc_rules_engine FROM dual;
      SELECT Decode(Nvl(l_okc_rules_engine,'N'),'Y','OKC_XPRT_DISABLE_RULES_OKC','OKC_XPRT_DISABLE_RULES') INTO l_conc_pgm FROM dual;

   		 x_request_id  := fnd_request.submit_request
		                  (application       => 'OKC',
					    program           => l_conc_pgm,
					    description       => l_conc_pgm_desc,
					    start_time        => NULL,
					    sub_request       => FALSE,
					    argument1         => p_org_id
					   );
	END IF;

   -- Commit the data
      commit work;


     IF NVL(x_request_id,0) = 0 THEN
	     -- Could Not submit Conc Pgm
	     fnd_message.set_name('OKC','OKC_XPRT_SUB_CZ_RUL_PGM');
          RAISE FND_API.G_EXC_ERROR;
     END IF; -- x_request_id is 0


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'x_request_id : '||x_request_id);
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

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   x_msg_data := SQLERRM;
   x_msg_count := 1;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END sync_rules;

END OKC_XPRT_QA_PVT ;


/
