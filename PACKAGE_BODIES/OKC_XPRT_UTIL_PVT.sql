--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_UTIL_PVT" AS
/* $Header: OKCVXUTLB.pls 120.56.12010000.22 2012/06/25 19:22:41 nbingi ship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_UTIL_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  g_concat_art_no  VARCHAR2(1) := NVL(FND_PROFILE.VALUE('OKC_CONCAT_ART_NO'),'N');

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
  G_PRODUCTION_MODE            CONSTANT   VARCHAR2(1)   :=  'p';
  G_TEST_MODE                  CONSTANT   VARCHAR2(3)   :=  't';

  G_TEMPLATE_MODEL_OSR         CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODEL:';

  G_EXPERT_QA_TYPE             CONSTANT   VARCHAR2(30)  := 'CONTRACT_EXPERT';

  G_OKC_MSG_INVALID_ARGUMENT   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_INVALID_ARGUMENT';
  G_QA_STS_WARNING             CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_WARNING;
  --
  -- Template Contract Expert QA Checks/Code
  --
  G_CHECK_TEMPLATE_RULE_STATUS  CONSTANT VARCHAR2(30) := 'CHECK_TEMPLATE_RULE_STATUS';
  G_CHECK_TEMPLATE_NO_RULES     CONSTANT VARCHAR2(30) := 'CHECK_TEMPLATE_NO_RULES';

  --
  -- Template Validation - Template Rule Status Not Active
  --
  G_OKC_TEMPLATE_RULE_STATUS   CONSTANT VARCHAR2(30) := 'OKC_XPRT_TMPL_RULE_STATUS';
  G_OKC_TEMPLATE_RULE_STATUS_S CONSTANT VARCHAR2(30) := 'OKC_XPRT_TMPL_RULE_STATUS_S';

  --
  -- Template Validation - No Active Rules attached to template
  --
  G_OKC_TEMPLATE_NO_RULES   CONSTANT VARCHAR2(30) := 'OKC_XPRT_TMPL_NO_RULES';
  G_OKC_TEMPLATE_NO_RULES_S CONSTANT VARCHAR2(30) := 'OKC_XPRT_TMPL_NO_RULES_S';

  --
  -- Document Contract Expert QA Checks/Code
  --
  G_CHECK_NEW_EXPERT_ART CONSTANT VARCHAR2(30) := 'CHECK_NEW_EXPERT_ART';
  G_CHECK_OLD_EXPERT_ART CONSTANT VARCHAR2(30) := 'CHECK_OLD_EXPERT_ART';
  G_CHECK_INVALID_CONFIG CONSTANT VARCHAR2(30) := 'CHECK_INVALID_CONFIG';
  G_CHECK_INCOMPLT_CONFIG CONSTANT VARCHAR2(30) := 'CHECK_INCOMPLT_CONFIG';
  G_CHECK_EXPERT_NOT_APPLIED CONSTANT VARCHAR2(30) := 'CHECK_EXPERT_NOT_APPLIED';
  G_CHECK_TEMPLATE_NOT_PUBLISHED CONSTANT VARCHAR2(30) := 'CHECK_TEMPLATE_NOT_PUBLISHED';
  G_CHECK_INVALID_XPRT_SECTION CONSTANT VARCHAR2(30) := 'CHECK_INVALID_XPRT_SECTION';
  G_CHECK_EXPERT_PARTIALLY_RUN CONSTANT VARCHAR2(30) := 'CHECK_EXPERT_PARTIALLY_APPLIED';

  --
  -- Invalid default section in Contract Expert section
  --
  G_OKC_INVALID_XPRT_SECTION CONSTANT VARCHAR2(30) := 'OKC_INVALID_XPRT_SECTION';
  G_OKC_INVALID_XPRT_SECTION_S CONSTANT VARCHAR2(30) := 'OKC_INVALID_XPRT_SECTION_S';
  --
  -- Document Validation - Expert Never Used on Document
  --
  G_OKC_EXPERT_NOT_APPLIED CONSTANT VARCHAR2(30) := 'OKC_EXPRT_NOT_APPLIED';
  G_OKC_EXPERT_NOT_APPLIED_S CONSTANT VARCHAR2(30) := 'OKC_EXPRT_NOT_APPLIED_S';
  G_OKC_EXPERT_NOT_APPLIED_D CONSTANT VARCHAR2(30) := 'OKC_EXPRT_NOT_APPLIED_D';

  --
  -- Document Validation - Expert Partially Used on Document
  --
  G_OKC_EXPERT_PARTIALLY_RUN CONSTANT VARCHAR2(30) := 'OKC_EXPRT_PARTIALLY_APPLIED';
  G_OKC_EXPERT_PARTIALLY_RUN_S CONSTANT VARCHAR2(30) := 'OKC_EXPRT_PARTIALLY_APPLIED_S';
  G_OKC_EXPERT_PARTIALLY_RUN_D CONSTANT VARCHAR2(30) := 'OKC_EXPRT_PARTIALLY_APPLIED_D';

  --
  -- Document Validation - New Article from Expert
  --
  G_OKC_NEW_EXPERT_ART CONSTANT VARCHAR2(30) := 'OKC_EXPRT_NEW_ARTICLE';
  G_OKC_NEW_EXPERT_ART_S CONSTANT VARCHAR2(30) := 'OKC_EXPRT_NEW_ARTICLE_S';
  G_OKC_NEW_EXPERT_ART_D CONSTANT VARCHAR2(30) := 'OKC_EXPRT_NEW_ARTICLE_D';

  --
  -- Document Validation - Delete Article from Expert
  --
  G_OKC_OLD_EXPERT_ART CONSTANT VARCHAR2(30) := 'OKC_EXPRT_OLD_ARTICLE';
  G_OKC_OLD_EXPERT_ART_S CONSTANT VARCHAR2(30) := 'OKC_EXPRT_OLD_ARTICLE_S';
  G_OKC_OLD_EXPERT_ART_D CONSTANT VARCHAR2(30) := 'OKC_EXPRT_OLD_ARTICLE_D';

  --
  -- Document Validation - Incomplete Configuration
  --
  G_OKC_INCOMPLT_CONFIG CONSTANT VARCHAR2(30) := 'OKC_EXPRT_INCOMPLETE_CONFIG';
  G_OKC_INCOMPLT_CONFIG_S CONSTANT VARCHAR2(30) := 'OKC_EXPRT_INCOMPLETE_CONFIG_S';
  G_OKC_INCOMPLT_CONFIG_D CONSTANT VARCHAR2(30) := 'OKC_EXPRT_INCOMPLETE_CONFIG_D';


  --
  -- Document Validation - Invalid Configuration
  --
  G_OKC_INVALID_CONFIG CONSTANT VARCHAR2(30) := 'OKC_EXPRT_INVALID_CONFIG';
  G_OKC_INVALID_CONFIG_S CONSTANT VARCHAR2(30) := 'OKC_EXPRT_INVALID_CONFIG_S';
  G_OKC_INVALID_CONFIG_D CONSTANT VARCHAR2(30) := 'OKC_EXPRT_INVALID_CONFIG_D';

  --
  -- Contract Expert Messages
  --
  G_OKC_CONTRACT_EXPERT CONSTANT VARCHAR2(30) := 'OKC_EXPRT_CE';
  G_OKC_TEMPLATE_NOT_CE_ENABLED CONSTANT VARCHAR2(30) := 'OKC_EXPRT_TEMPL_NOT_ENABLD';
  G_OKC_EXPRT_PROFILE_DISABLED CONSTANT VARCHAR2(30) := 'OKC_EXPRT_PROFILE_DISABLED';


---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE check_import_status
(
 p_run_id           IN NUMBER,
 p_import_status    IN VARCHAR2,
 p_model_type       IN VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'check_import_status';
l_rec_number              NUMBER:= 0;
l_rule_number             NUMBER:= 0;
l_model                   VARCHAR2(450);
l_name                    cz_imp_rules.name%TYPE;
l_message                 cz_imp_rules.message%TYPE;

CURSOR csr_db_logs IS
SELECT logtime,
       caller,
       message
FROM cz_db_logs
WHERE run_id = p_run_id
ORDER BY logtime;

CURSOR csr_xfr_run_results IS
SELECT  imp_table,
        disposition,
        rec_status,
        records
FROM cz_xfr_run_results
WHERE run_id = p_run_id ;

CURSOR csr_rule_imp_dtls IS
SELECT name,
       substr(message,1,200) msg
FROM cz_imp_rules
WHERE rec_status <> 'OK'
  AND run_id = p_run_id ;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Check the model that is imported
   IF  p_model_type = 'V' THEN
      l_model := 'Variable Model';
   ELSIF  p_model_type = 'C' THEN
      l_model := 'Clause Model';
   ELSIF  p_model_type = 'T' THEN
      l_model := 'Template Model';
   ELSIF  p_model_type = 'R' THEN
      l_model := 'Rules';
   END IF;

  -- Check the cz_db_logs table for any messages and write to log file
  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'Import Summary for '||l_model||' Run Id : '||p_run_id);
  fnd_file.put_line(FND_FILE.LOG,'  ');


  -- write to debug log file
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110:Import Status ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110:Imported :  '||l_model);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Run Id :  '||p_run_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110:---------- CZ_DB_LOGS  ----------------------------- ');
     fnd_file.put_line(FND_FILE.LOG,'---------- CZ_DB_LOGS  ----------------------------- ');

  FOR csr_db_logs_rec IN csr_db_logs
    LOOP
      l_rec_number := l_rec_number +1;
      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'*************** Record   :  '||l_rec_number||'  **************');
      fnd_file.put_line(FND_FILE.LOG,'Logtime  :  '||csr_db_logs_rec.logtime);
      fnd_file.put_line(FND_FILE.LOG,'Caller   :  '||csr_db_logs_rec.caller);
      fnd_file.put_line(FND_FILE.LOG,'Message  :  '||csr_db_logs_rec.message);
      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'  ');

      -- write to debug log file
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '110: Logtime  :  '||csr_db_logs_rec.logtime);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '110: Caller   :  '||csr_db_logs_rec.caller);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '110: Message  :  '||csr_db_logs_rec.message);
         END IF;

   END LOOP;

  END IF; -- debug log



  -- If CZ import returns ERROR then there was a database or fatal error
  -- write to log and Abort the next steps of writing to log
     IF (p_import_status = G_RET_STS_UNEXP_ERROR) THEN
         fnd_file.put_line(FND_FILE.LOG,'CZ IMPORT API Return Status :  '||p_import_status);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         fnd_file.put_line(FND_FILE.LOG,'CZ IMPORT API Return Status :  '||p_import_status);
         RAISE FND_API.G_EXC_ERROR;
     END IF;


  -- Check the summary of the import run results
  fnd_file.put_line(FND_FILE.LOG,'               CZ_XFR_RUN_RESULTS');
  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------------');
   fnd_file.put_line(FND_FILE.LOG,RPAD('Import Table',25,' ')||
                                  ' Disposition'||
                                  ' Record Status'||
                                  ' Total Records'
			      );
  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------------');

  -- write to debug log file
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120:********** CZ_XFR_RUN_RESULTS  ***************************** ');
  END IF;


  -- initial l_rec_number
  l_rec_number :=0;

  FOR csr_xfr_run_results_rec IN csr_xfr_run_results
   LOOP
      l_rec_number := l_rec_number +1;
	 fnd_file.put_line(FND_FILE.LOG,RPAD(csr_xfr_run_results_rec.imp_table,25,' ')||' '||
	                                RPAD(csr_xfr_run_results_rec.disposition,11,' ')||' '||
	                                RPAD(csr_xfr_run_results_rec.rec_status,13,' ')||' '||
							  RPAD(csr_xfr_run_results_rec.records,13,' ')
				    );
	 /*
      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'*************** Record   :  '||l_rec_number||'  **************');
      fnd_file.put_line(FND_FILE.LOG,'Import Table  :  '||csr_xfr_run_results_rec.imp_table);
      fnd_file.put_line(FND_FILE.LOG,'Disposition   :  '||csr_xfr_run_results_rec.disposition);
      fnd_file.put_line(FND_FILE.LOG,'Record Status :  '||csr_xfr_run_results_rec.rec_status);
      fnd_file.put_line(FND_FILE.LOG,'Total Records :  '||csr_xfr_run_results_rec.records);
      fnd_file.put_line(FND_FILE.LOG,'  ');
      fnd_file.put_line(FND_FILE.LOG,'  ');
	 */


      -- write to debug log file
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '120: *************** Record   :  '||l_rec_number||'  **************');
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '120: Import Table  :  '||csr_xfr_run_results_rec.imp_table);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '120: Disposition   :  '||csr_xfr_run_results_rec.disposition);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '120: Record Status :  '||csr_xfr_run_results_rec.rec_status);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                           G_MODULE||l_api_name,
                           '120: Total Records :  '||csr_xfr_run_results_rec.records);
         END IF;


      -- if any status is not OK then the import program was NOT successful in importing all records
	 -- for rule import this entity is not updated to OK
	 -- Need to roll back the changes to allow PASS status (Bug logged against CZ)
        IF csr_xfr_run_results_rec.rec_status NOT IN ('OK','PASS') THEN
           x_return_status :=  G_RET_STS_ERROR;
        END IF;

   END LOOP;

  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------------');

  -- For Rule Import, if the return status is Error read message from cz_imp_rules
  IF p_model_type = 'R' THEN
      -- Check if any rules had error
	    OPEN csr_rule_imp_dtls;
	       FETCH csr_rule_imp_dtls INTO l_name, l_message;
		    IF csr_rule_imp_dtls%FOUND THEN
		      -- one or more rules in ERROR
			 fnd_file.put_line(FND_FILE.LOG,'Following Rules Could not be imported');
                fnd_file.put_line(FND_FILE.LOG,'-----------------------------------------------');
			 -- set out status to Error
                x_return_status :=  G_RET_STS_ERROR;
		    END IF;
         CLOSE csr_rule_imp_dtls;

      -- initial l_rule_number
      l_rule_number :=0;

      FOR csr_rule_imp_dtls_rec IN csr_rule_imp_dtls
       LOOP
          l_rule_number := l_rule_number +1;
          fnd_file.put_line(FND_FILE.LOG,'  ');
          fnd_file.put_line(FND_FILE.LOG,'--------------- Record   :  '||l_rule_number||'  --------------');
          fnd_file.put_line(FND_FILE.LOG,'Rule Name :  '||csr_rule_imp_dtls_rec.name);
          fnd_file.put_line(FND_FILE.LOG,'Message   :  '||csr_rule_imp_dtls_rec.msg);
          fnd_file.put_line(FND_FILE.LOG,'  ');

       END LOOP;

  END IF; -- for Rule Import only

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
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_import_status;

---------------------------------------------------
--  Function:
---------------------------------------------------
FUNCTION is_rule_line_level (
    p_rule_id    IN NUMBER
)
RETURN VARCHAR2 IS

CURSOR c1 IS
--Check the Variable Type for line level
SELECT NVL(v.line_level_flag,'N') line_level_flag
FROM okc_xprt_rule_hdrs_all rhdr,
     okc_xprt_rule_conditions rcon,
     okc_bus_variables_b v
WHERE rhdr.rule_id = rcon.rule_id
AND rcon.object_type = 'VARIABLE'
AND rcon.object_code = v.variable_code
AND SUBSTR(rcon.object_code,1,3) = 'OKC'
AND v.line_level_flag = 'Y'
AND rhdr.rule_id = p_rule_id
UNION
SELECT NVL(v.line_level_flag,'N') line_level_flag
FROM okc_xprt_rule_hdrs_all rhdr,
   okc_xprt_rule_conditions rcon,
   okc_bus_variables_b v
WHERE rhdr.rule_id = rcon.rule_id
AND rcon.object_value_type = 'VARIABLE'
AND rcon.object_code = v.variable_code
AND SUBSTR(rcon.object_code,1,3) = 'OKC'
AND v.line_level_flag = 'Y'
AND rhdr.rule_id = p_rule_id;

l_value  VARCHAR2(1) := 'N';

BEGIN

 FOR c1_rec IN c1
 LOOP
   IF c1_rec.line_level_flag = 'Y' THEN
     l_value := c1_rec.line_level_flag;
   END IF;
 END LOOP;

 RETURN l_value;
EXCEPTION
 WHEN OTHERS THEN
      --close cursors
     IF c1%ISOPEN THEN
       CLOSE c1;
     END IF;
     l_value := 'N';
     RETURN l_value;
END is_rule_line_level;

---------------------------------------------------
--  Function:
---------------------------------------------------
FUNCTION get_value_set_id
(
 p_value_set_name    IN VARCHAR2
) RETURN NUMBER IS

CURSOR csr_value_set_id IS
SELECT flex_value_set_id
FROM fnd_flex_value_sets
WHERE flex_value_set_name = p_value_set_name;

l_flex_value_set_id        fnd_flex_value_sets.flex_value_set_id%TYPE ;

BEGIN

  OPEN csr_value_set_id;
     FETCH csr_value_set_id INTO l_flex_value_set_id;
  CLOSE csr_value_set_id;

  RETURN l_flex_value_set_id;

END get_value_set_id;

---------------------------------------------------
--  Function:  This function will be called in template approval
--  Based on the return value of this function, a template will be imported
--  into CZ in the template approval workflow
---------------------------------------------------
FUNCTION xprt_enabled_template
(
 p_template_id       IN NUMBER
) RETURN VARCHAR2 IS

CURSOR csr_local_rules_templates IS
-- Local Rules on Template
SELECT 'X'
  FROM okc_xprt_template_rules r,
       okc_xprt_rule_hdrs_all h
 WHERE r.rule_id = h.rule_id
   AND h.status_code = 'ACTIVE'
   AND template_id = p_template_id ;

CURSOR csr_org_rules_templates IS
-- Org Wide Rules
SELECT 'X'
  FROM okc_terms_templates_all t,
       okc_xprt_rule_hdrs_all h
 WHERE t.org_id = h.org_id
   AND t.intent = h.intent
   AND h.status_code = 'ACTIVE'
   AND NVL(h.org_wide_flag,'N') = 'Y'
   AND t.template_id = p_template_id  ;

CURSOR csr_template_dtls IS
SELECT NVL(contract_expert_enabled,'N')
  FROM okc_terms_templates_all
 WHERE template_id = p_template_id;

l_dummy        VARCHAR2(1);
l_expert_flag  VARCHAR2(1);
l_contract_expert_enabled okc_terms_templates_all.contract_expert_enabled%TYPE;

BEGIN

  l_dummy := NULL;
  l_expert_flag := 'N';

  --
  -- Check if CE Profile is Enabled.
  --
     FND_PROFILE.GET(name=> 'OKC_K_EXPERT_ENABLED', val => l_expert_flag );

    IF NVL(l_expert_flag,'N') = 'N' THEN
        -- Not Expert enabled
        RETURN l_expert_flag;
    END IF;

  -- check the expert flag on template
  OPEN csr_template_dtls;
    FETCH csr_template_dtls INTO l_contract_expert_enabled;
  CLOSE csr_template_dtls;

  IF l_contract_expert_enabled = 'N' THEN
    l_expert_flag := 'N';
    RETURN l_expert_flag;
  END IF;

  -- check if any local rules exists
  OPEN csr_local_rules_templates;
    FETCH csr_local_rules_templates INTO l_dummy;
      IF csr_local_rules_templates%NOTFOUND THEN
	   -- check if any Org Rules exists
	      OPEN csr_org_rules_templates;
		   FETCH csr_org_rules_templates INTO l_dummy;
		     IF csr_org_rules_templates%NOTFOUND THEN
			  -- no local or org rules
			   l_expert_flag := 'N';
			ELSE
			  -- Org Rules Exists
			   l_expert_flag := 'Y';
			END IF;
		 CLOSE csr_org_rules_templates;
	 ELSE
	   -- local rules exists
	     l_expert_flag := 'Y';
	 END IF;
  CLOSE csr_local_rules_templates;

  RETURN l_expert_flag;

END xprt_enabled_template;

/*
  This API will delete all the test publications for a model
*/
PROCEDURE delete_test_publications
(
 p_devl_project_id  IN NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
) IS

CURSOR csr_get_publication_dtl IS
SELECT publication_id
FROM cz_model_publications
WHERE model_id = p_devl_project_id
AND deleted_flag = '0'
AND publication_mode ='t'
AND source_target_flag = 'S'; -- only delete 'S' and never 'T'

l_api_name                CONSTANT VARCHAR2(30) := 'delete_test_publications';
l_api_version              CONSTANT NUMBER := 1;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- for the model get all test publications and delete
     FOR rec_get_publication_dtl IN csr_get_publication_dtl
	LOOP
    	          OKC_XPRT_CZ_INT_PVT.delete_publication
		     (
		      p_api_version           => l_api_version,
		      p_init_msg_lst          => FND_API.G_FALSE,
		      p_publication_id        => rec_get_publication_dtl.publication_id,
		      x_return_status         => x_return_status,
		      x_msg_count      	      => x_msg_count,
		      x_msg_data              => x_msg_data
		      );

                 --- If any errors happen abort API
                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

	END LOOP; -- all test publications


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
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END delete_test_publications;


/*
   CZ Publication Process (cz_model_publications)
                            rec# publication_mode    source_target_flag
   create test publication   1     t                  S
   publish test pub          2     t                  T    ( new record created)

   edit test to production   1     p                  S    ( record 1 updated )
   edit test to production   2     p                  T    ( record 2 updated )

  Don't touch the source_target_flag with 'T'. Only access source_target_flag='S'
  If you delete source_target_flag='S', then the source_target_flag='T' will also be deleted.

  If you delete a publication , then the purge program auto deletes UIs associated with
  publication. So no need to explictly delete UI

  OCD shows only source_target_flag='S'  as the target record is never shown to user
*/

/*
   Procedure : create_test_publication
   This procedure does the following
   For All templates in the current concurrent request id
	Delete Test Publications
     Delete Existing UIs except the UI attached to production publication
	Create New UI
	Generate Logic for the template Model
	Create test publication for the Template Model
	Publish the test publication
*/
PROCEDURE create_test_publication
(
 x_return_status   OUT   NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) IS

CURSOR csr_templates IS
SELECT DECODE(parent_template_id, NULL, template_id, parent_template_id),
       template_model_id
  FROM okc_terms_templates_all
 WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID ;

-- UIs for the template not attached to Production publication
CURSOR csr_template_ui(p_model_id IN NUMBER) IS
SELECT ui_def_id
  FROM cz_ui_defs
 WHERE devl_project_id = p_model_id
   AND deleted_flag = '0'
   AND ui_def_id NOT IN ( SELECT ui_def_id
                            FROM cz_model_publications
					  WHERE model_id = p_model_id
					    AND publication_mode = G_PRODUCTION_MODE
					    AND  deleted_flag = '0'
					    AND source_target_flag = 'S'
                        );



l_api_version             CONSTANT NUMBER := 1;
l_api_name                CONSTANT VARCHAR2(30) := 'create_test_publication';
l_template_id             okc_terms_templates_all.template_id%TYPE;
l_template_model_id       okc_terms_templates_all.template_model_id%TYPE;
l_ui_def_id               cz_ui_defs.ui_def_id%TYPE;
l_new_ui_def_id           cz_ui_defs.ui_def_id%TYPE;
l_run_id                  NUMBER;
l_publication_id          NUMBER;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  OPEN csr_templates;
    LOOP
      FETCH csr_templates INTO l_template_id, l_template_model_id;
	 EXIT WHEN csr_templates%NOTFOUND;
	    -- Step 1:
	    -- Delete Test Publications
	    delete_test_publications
         (
          p_devl_project_id  =>  l_template_model_id,
          x_return_status    =>  x_return_status,
          x_msg_data	    =>  x_msg_data,
          x_msg_count	    =>  x_msg_count
         );
               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

	    -- Step 2:
	    -- Delete Existing UIs except the UI attached to production publication
	    OPEN csr_template_ui(p_model_id => l_template_model_id);
	      LOOP
		   FETCH csr_template_ui INTO l_ui_def_id;
		   EXIT WHEN csr_template_ui%NOTFOUND;
		    -- Call CZ delete UI API
		     OKC_XPRT_CZ_INT_PVT.delete_ui_def
               (
                p_api_version      =>  l_api_version,
                p_ui_def_id        =>  l_ui_def_id,
                x_return_status    =>  x_return_status,
                x_msg_data	     =>  x_msg_data,
                x_msg_count	     =>  x_msg_count
               ) ;

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

		 END LOOP; -- csr_template_ui
	    CLOSE csr_template_ui;

	    -- Step 3:
	    -- Create a New UI for the template Model
	    OKC_XPRT_CZ_INT_PVT.create_jrad_ui
	     (
		 p_api_version         =>  l_api_version,
           p_devl_project_id     =>  l_template_model_id,
           p_show_all_nodes      =>  '0',
           p_master_template_id  =>  OKC_XPRT_CZ_INT_PVT.G_MASTER_UI_TMPLATE_ID,
           p_create_empty_ui     => '0',
           x_ui_def_id           =>  l_new_ui_def_id,
           x_return_status       =>  x_return_status,
           x_msg_data	        =>  x_msg_data,
           x_msg_count	        =>  x_msg_count
          ) ;
         --- If any errors happen abort API
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;


	    -- Step 4:
	    -- Generate Logic for the template Model
	    OKC_XPRT_CZ_INT_PVT.generate_logic
	     (
		 p_api_version         =>  l_api_version,
		 p_init_msg_lst        =>  FND_API.G_FALSE,
           p_devl_project_id     =>  l_template_model_id,
           x_run_id              =>  l_run_id,
           x_return_status       =>  x_return_status,
           x_msg_data	        =>  x_msg_data,
           x_msg_count	        =>  x_msg_count
          ) ;

         --- If any errors happen abort API
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

	    -- Step 5:
         -- Create a test publication for the template Model
	    OKC_XPRT_CZ_INT_PVT.create_publication_request
         (
		 p_api_version         =>  l_api_version,
		 p_init_msg_lst        =>  FND_API.G_FALSE,
           p_devl_project_id     =>  l_template_model_id,
		 p_ui_def_id           =>  l_new_ui_def_id,
		 p_publication_mode    =>  't',
		 x_publication_id      =>  l_publication_id,
           x_return_status       =>  x_return_status,
           x_msg_data	        =>  x_msg_data,
           x_msg_count	        =>  x_msg_count
          ) ;

         --- If any errors happen abort API
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;


	    -- Step 6:
         -- Publish test publication for the template Model
	    OKC_XPRT_CZ_INT_PVT.publish_model
         (
           p_api_version         =>  l_api_version,
	      p_init_msg_lst        =>  FND_API.G_FALSE,
           p_publication_id      =>  l_publication_id,
	      x_run_id              =>  l_run_id,
           x_return_status       =>  x_return_status,
           x_msg_data	        =>  x_msg_data,
           x_msg_count	        =>  x_msg_count
          ) ;

         --- If any errors happen abort API
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;


	END LOOP; -- csr_templates
  CLOSE csr_templates;


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
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_test_publication;

/*
This procedure populates the questions order table for a given template.
It is called either from the 'View Question Sequence' UI or from the
back-end processes to publish/disable rules or synchronize with CZ.
*/



PROCEDURE Populate_Questions_Order
(
 p_Template_Id   IN NUMBER,
 p_Commit_Flag   IN VARCHAR2,
 p_Mode          IN VARCHAR2,
 x_Return_Status OUT NOCOPY VARCHAR2,
 x_Msg_Count     OUT NOCOPY NUMBER,
 x_Msg_Data      OUT NOCOPY VARCHAR2
) AS

  l_Api_Name CONSTANT VARCHAR2(30) := 'Populate_Questions_Order';
  l_user_id CONSTANT Number := Fnd_Global.User_Id;
  l_login_id CONSTANT Number := Fnd_Global.Login_Id;
  l_conc_request_id CONSTANT Number := Fnd_Global.Conc_Request_Id;

  cursor Template_Cursor is
  select org_id, intent from okc_terms_templates_all where template_id = p_Template_Id;

   l_Org_Id        NUMBER;
   l_Intent        VARCHAR2(1);

/*
Parameters for the procedure:

p_Template_Id: The template for which question order is to be populated

p_Commit_Flag: Depending upon 'Y' or 'N', either the procedure commits or does not.

p_mode: The processing mode in which the method is called.

p_mode can have values

P : Publish mode. There might be some rules being published currently and they can be identified using the current request id from the rules headers table.

D: Disable mode. There might be some rules being disabled currently and they can be identified using the current request id from the rules headers table.

S: Synchronization mode. This mode is passed when the API is called from the Synchronization process for the template rebuild concurrent program

U: UI mode: This mode is passed from the 'Question Reorder UI'.

x_Return_Status, x_Msg_Count, x_Msg_Data : Standard parameters for exception handling.
*/
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
                   '100: p_Template_Id:' || p_Template_Id);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '100: p_Commit_Flag:' || p_Commit_Flag);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '100: p_Mode:' || p_Mode);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '100: Parameters passed: -----------------------');
  END IF;


  x_Return_Status := g_Ret_Sts_Success;

  FOR Template_Rec IN template_cursor LOOP
    l_Org_Id := Template_Rec.Org_Id;
    l_Intent := Template_Rec.Intent;
  END LOOP;
  /*
  Delete questions from the table OKC_XPRT_QUESTION_ORDERS for the template where the questions do not exist in
  the left and right hand side of OKC_XPRT_RULE_CONDITIONS or in OKC_XPRT_RULE_OUTCOMES
  for all rules associated to the template in table OKC_XPRT_TEMPLATE_RULES or rules
  with ORG_WIDE_FLAG='Y'  and status in ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGPUB')
  */

  -- write to debug log file
  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '110: Deleting invalid questions from the table Okc_Xprt_Question_Orders');
  END IF;


  DELETE FROM Okc_Xprt_Question_Orders
   WHERE Template_Id = p_Template_Id
     AND NOT EXISTS
   (SELECT 1
            FROM Okc_Xprt_Rule_Conditions Cond,
                 okc_xprt_rule_hdrs_all   Rules,
                 Okc_Xprt_Template_Rules  Assoc,
					  Okc_xprt_questions_b quest
           WHERE Rules.Rule_Id = Cond.Rule_Id
             AND Rules.Rule_Id = Assoc.Rule_Id
             AND Assoc.Template_Id = p_Template_Id
             AND ( ( to_char(Okc_Xprt_Question_Orders.Question_Id) = Cond.Object_Code
                     AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Okc_Xprt_Question_Orders.Question_Id) = Cond.Object_Value_Code
                     AND Cond.Object_Value_Type = 'QUESTION')
                  )
				 AND quest.question_id = Okc_Xprt_Question_Orders.Question_Id
				 AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE','PENDINGPUB')
          UNION ALL  --perf Bug#5030444 Replaced UNION with UNION ALL
          SELECT 1
            FROM Okc_Xprt_Rule_Outcomes  Outs,
                 okc_xprt_rule_hdrs_all  Rules,
                 Okc_Xprt_Template_Rules Assoc,
					  Okc_xprt_questions_b quest
           WHERE Rules.Rule_Id = Assoc.Rule_Id
             AND Rules.rule_id = Outs.rule_id
             AND Assoc.Template_Id = p_Template_Id
             AND to_char(Okc_Xprt_Question_Orders.Question_Id) =
                 Outs.Object_Value_Id
             AND Outs.Object_Type = 'QUESTION'
			    AND quest.question_id = Okc_Xprt_Question_Orders.Question_Id
				 AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE','PENDINGPUB')
          UNION ALL   --perf Bug#5030444 Replaced UNION with UNION ALL
          SELECT 1
            FROM Okc_Xprt_Rule_Conditions Cond, okc_xprt_rule_hdrs_all Rules,
					  Okc_xprt_questions_b quest
           WHERE Rules.Rule_Id = Cond.Rule_Id
             AND Rules.Org_Wide_Flag = 'Y'
             AND Rules.Org_Id = l_Org_Id
             AND Rules.Intent = l_Intent
             AND ( (to_char(Okc_Xprt_Question_Orders.Question_Id) = Cond.Object_Code
                     AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Okc_Xprt_Question_Orders.Question_Id) = Cond.Object_Value_Code
                     AND Cond.Object_Value_Type = 'QUESTION')
                  )
			    AND quest.question_id = Okc_Xprt_Question_Orders.Question_Id
				 AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE','PENDINGPUB')
          UNION ALL  --perf Bug#5030444 Replaced UNION with UNION ALL
          SELECT 1
            FROM Okc_Xprt_Rule_Outcomes Outs, okc_xprt_rule_hdrs_all Rules,
					  Okc_xprt_questions_b quest
           WHERE Rules.Rule_Id = Outs.Rule_Id
             AND Rules.Org_Wide_Flag = 'Y'
             AND Rules.Org_Id = l_Org_Id
             AND Rules.Intent = l_Intent
             AND to_char(Okc_Xprt_Question_Orders.Question_Id) =
                 Outs.Object_Value_Id
             AND Outs.Object_Type = 'QUESTION'
			    AND quest.question_id = Okc_Xprt_Question_Orders.Question_Id
				 AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE','PENDINGPUB')
             );

  -- write to debug log file
  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '120: Deleted invalid questions from the table Okc_Xprt_Question_Orders');
  END IF;
  /*
      Initialize the statuses for the questions for the template
  */



  -- write to debug log file
  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '130: Initialize the status for the questions for the template.');
  END IF;
  UPDATE Okc_Xprt_Question_Orders
     SET Question_Rule_Status = 'DRAFT',
         Last_Updated_By      = l_user_id,
         Last_Update_Date     = SYSDATE,
         Last_Update_Login    = l_login_id,
	    runtime_available_flag = 'N'
   WHERE Template_Id = p_Template_Id;


  /*
  2.  Open cursor to select questions for the template
  FROM
  the left and right hand side of OKC_XPRT_RULE_CONDITIONS or in OKC_XPRT_RULE_OUTCOMES
  for all rules associated to the template in table OKC_XPRT_TEMPLATE_RULES or rules with ORG_WIDE_FLAG='Y'  and status = 'ACTIVE'
  */

  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '140: Start inserting/updating the Active rule questions.');
  END IF;

  DECLARE
    CURSOR Active_Draft_Rule_Questions IS
    	SELECT * FROM (
      SELECT distinct To_Number(Cond.Object_Code) Question_Id, Rules.Status_Code
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules,
             Okc_Xprt_Template_Rules  Assoc
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Rule_Id = Assoc.Rule_Id
         AND Assoc.Template_Id = p_Template_Id
         AND Cond.Object_Type = 'QUESTION'
         AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE')
      UNION
      SELECT distinct To_Number(Cond.Object_Value_Code) Question_Id, Rules.Status_Code
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules,
             Okc_Xprt_Template_Rules  Assoc
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Rule_Id = Assoc.Rule_Id
         AND Assoc.Template_Id = p_Template_Id
         AND Cond.Object_Value_Type = 'QUESTION'
         AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE')
      UNION
      SELECT distinct To_Number(Outs.Object_Value_Id) Question_Id, Rules.Status_Code
        FROM Okc_Xprt_Rule_Outcomes   Outs,
             okc_xprt_rule_hdrs_all   Rules,
             Okc_Xprt_Template_Rules  Assoc
       WHERE Rules.Rule_Id = Assoc.Rule_Id
         AND Assoc.Template_Id = p_Template_Id
         AND Outs.Object_Type = 'QUESTION'
         AND Outs.rule_id = Rules.rule_id
         AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE')
      UNION
      SELECT distinct To_Number(Cond.Object_Code) Question_Id, Rules.Status_Code
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Org_Wide_Flag = 'Y'
         AND Rules.Org_Id = l_Org_Id
         AND Rules.Intent = l_Intent
         AND Cond.Object_Type = 'QUESTION'
         AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE')
      UNION
      SELECT distinct To_Number(Cond.Object_Value_Code) Question_Id, Rules.Status_Code
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Org_Wide_Flag = 'Y'
         AND Rules.Org_Id = l_Org_Id
         AND Rules.Intent = l_Intent
         AND Cond.Object_Value_Type = 'QUESTION'
         AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE')
      UNION
      SELECT distinct To_Number(Outs.Object_Value_Id) Question_Id, Rules.Status_Code
        FROM Okc_Xprt_Rule_Outcomes   Outs,
             okc_xprt_rule_hdrs_all   Rules
       WHERE Rules.Rule_Id = Outs.Rule_Id
         AND Rules.Org_Wide_Flag = 'Y'
         AND Rules.Org_Id = l_Org_Id
         AND Rules.Intent = l_Intent
         AND Outs.Object_Type = 'QUESTION'
         AND Outs.rule_id = Rules.rule_id
         AND Rules.Status_Code IN ('ACTIVE', 'DRAFT', 'REVISION', 'PENDINGDISABLE')
      ) ORDER BY Status_Code DESC;
    l_Question_Id NUMBER;

  BEGIN

    /*
    3.  Run a loop on the cursor to update/insert records into OKC_XPRT_QUESTION_ORDERS and set Draft_rule_qst_flag = 'ACTIVE' or 'DRAFT' based on the rule status.

    */

    FOR Question_Rec IN Active_Draft_Rule_Questions LOOP

      l_Question_Id := Question_Rec.Question_Id;


      UPDATE Okc_Xprt_Question_Orders
         SET Question_Rule_Status = DECODE(Question_Rec.Status_Code, 'ACTIVE','ACTIVE','DRAFT' ),
             Last_Updated_By      = l_user_id,
             Last_Update_Date     = SYSDATE,
             Last_Update_Login    = l_login_id,
		   runtime_available_flag = DECODE(Question_Rec.Status_Code, 'ACTIVE', 'Y','N')
       WHERE Template_Id = p_Template_Id
         AND Question_Id = l_Question_Id;

      IF SQL%NOTFOUND THEN

        INSERT INTO Okc_Xprt_Question_Orders
          (Question_Order_Id,
           Template_Id,
           Question_Id,
           Question_Rule_Status,
		 runtime_available_flag,
           Object_Version_Number,
           Created_By,
           Creation_Date,
           Last_Updated_By,
           Last_Update_Date,
           Last_Update_Login)
        VALUES
          (OKC_XPRT_QUESTION_ORDERS_S.NEXTVAL,
           p_Template_Id,
           l_Question_Id,
           DECODE(Question_Rec.Status_Code, 'ACTIVE','ACTIVE','DRAFT'),
		 DECODE(Question_Rec.Status_Code, 'ACTIVE','Y','N'),
           1,
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           l_login_id);
      END IF;
    END LOOP;
  END;
  /*
  4.  Do similar processing for rules in Pending Publication status
  */

  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '150: End inserting/updating the Active rule questions.');

    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '160: Start inserting/updating the Pending Publication rule questions.');
  END IF;

  DECLARE
    CURSOR Pending_Rule_Questions IS
      SELECT distinct To_Number(Cond.Object_Code) Question_Id
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules,
             Okc_Xprt_Template_Rules  Assoc
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Rule_Id = Assoc.Rule_Id
         AND Assoc.Template_Id = p_Template_Id
         AND Cond.Object_Type = 'QUESTION'
         AND Rules.Status_Code IN ('PENDINGPUB')
         AND Rules.Request_Id = l_conc_request_id
      UNION
      SELECT distinct To_Number(Cond.Object_Value_Code) Question_Id
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules,
             Okc_Xprt_Template_Rules  Assoc
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Rule_Id = Assoc.Rule_Id
         AND Assoc.Template_Id = p_Template_Id
         AND Cond.Object_Value_Type = 'QUESTION'
         AND Rules.Status_Code IN ('PENDINGPUB')
         AND Rules.Request_Id = l_conc_request_id
      UNION
      SELECT distinct To_Number(Outs.Object_Value_Id) Question_Id
        FROM Okc_Xprt_Rule_Outcomes   Outs,
             okc_xprt_rule_hdrs_all   Rules,
             Okc_Xprt_Template_Rules  Assoc
       WHERE Rules.Rule_Id = Assoc.Rule_Id
         AND Assoc.Template_Id = p_Template_Id
         AND Outs.Object_Type = 'QUESTION'
         And Outs.rule_id = Rules.rule_id
         AND Rules.Status_Code IN ('PENDINGPUB')
         AND Rules.Request_Id = l_conc_request_id
      UNION
      SELECT distinct To_Number(Cond.Object_Code) Question_Id
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Org_Wide_Flag = 'Y'
         AND Rules.Org_Id = l_Org_Id
         AND Rules.Intent = l_Intent
         AND Cond.Object_Type = 'QUESTION'
         AND Rules.Status_Code IN ('PENDINGPUB')
         AND Rules.Request_Id = l_conc_request_id
      UNION
      SELECT distinct To_Number(Cond.Object_Value_Code) Question_Id
        FROM Okc_Xprt_Rule_Conditions Cond,
             okc_xprt_rule_hdrs_all   Rules
       WHERE Rules.Rule_Id = Cond.Rule_Id
         AND Rules.Org_Wide_Flag = 'Y'
         AND Rules.Org_Id = l_Org_Id
         AND Rules.Intent = l_Intent
         AND Cond.Object_Value_Type = 'QUESTION'
         AND Rules.Status_Code IN ('PENDINGPUB')
         AND Rules.Request_Id = l_conc_request_id
      UNION
      SELECT distinct To_Number(Outs.Object_Value_Id) Question_Id
        FROM Okc_Xprt_Rule_Outcomes   Outs,
             okc_xprt_rule_hdrs_all   Rules
       WHERE Rules.Rule_Id = Outs.Rule_Id
         AND Rules.Org_Wide_Flag = 'Y'
         AND Rules.Org_Id = l_Org_Id
         AND Rules.Intent = l_Intent
         AND Outs.Object_Type = 'QUESTION'
         AND Outs.rule_id = Rules.rule_id
         AND Rules.Status_Code IN ('PENDINGPUB')
         AND Rules.Request_Id = l_conc_request_id;
    l_Question_Id NUMBER;
  BEGIN

    /*
    Run a loop on the cursor to update/insert records into OKC_XPRT_QUESTION_ORDERS and set QUESTION_RULE_STATUS = 'PENDINGPUB'.

    */
    FOR Question_Rec IN Pending_Rule_Questions LOOP

      l_Question_Id := Question_Rec.Question_Id;


      UPDATE Okc_Xprt_Question_Orders
         SET Question_Rule_Status = DECODE(Question_Rule_Status,'ACTIVE','ACTIVE','PENDINGPUB'),
             Last_Updated_By      = l_user_id,
             Last_Update_Date     = SYSDATE,
             Last_Update_Login    = l_login_id,
		   runtime_available_flag = DECODE(Question_Rule_Status,'ACTIVE','Y','N')
       WHERE Template_Id = p_Template_Id
         AND Question_Id = l_Question_Id ;

      IF SQL%NOTFOUND THEN

        INSERT INTO Okc_Xprt_Question_Orders
          (Question_Order_Id,
           Template_Id,
           Question_Id,
           Question_Rule_Status,
		 runtime_available_flag,
           Object_Version_Number,
           Created_By,
           Creation_Date,
           Last_Updated_By,
           Last_Update_Date,
           Last_Update_Login)
        VALUES
          (OKC_XPRT_QUESTION_ORDERS_S.NEXTVAL,
           p_Template_Id,
           l_Question_Id,
           'PENDINGPUB',
		 'N',
           1,
           l_user_id,
           SYSDATE,
           l_user_id,
           SYSDATE,
           l_login_id);
      END IF;
    END LOOP;
  END;

  /*
  5.  Update all the records for the table and set mandatory_flag = 'N'.
  Then set mandatory_flag = 'Y' for those questions which appear only in the conditions and not in the outcome.
  In the UI mode, choose all rules for selecting the questions.
  For all other modes, only select 'ACTIVE' rules and 'PENDINGPUB' rules for the request id.
  */


  UPDATE Okc_Xprt_Question_Orders
     SET Mandatory_Flag    = 'N',
         Last_Updated_By   = l_user_id,
         Last_Update_Date  = SYSDATE,
         Last_Update_Login = l_login_id
   WHERE Template_Id = p_Template_Id;

  IF p_Mode = 'U' THEN

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
      Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                     g_Module || l_Api_Name,
                     '210: Process the "U" mode.');
    END IF;

    --Fix for perf Bug#5030429.Breaking big Update stmt into 4 small Update stmts one for each subquery
    --Update stmt1: set mandatory_flag = 'Y' for those questions which appear in the conditions of non-org wide rule
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'Y',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Conditions Cond,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Template_Rules  Assoc,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Cond.Rule_Id
               AND Rules.Rule_Id = Assoc.Rule_Id
               AND Assoc.Template_Id = p_Template_Id
               AND (
                    (to_char(Ord.Question_Id) = Cond.Object_Code
                       AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Ord.Question_Id) = Cond.Object_Value_Code
                       AND Cond.Object_Value_Type = 'QUESTION')
                    )
            );
    --Update stmt2: set mandatory_flag = 'Y' for those questions which appear in the conditions of ORG wide rule
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'Y',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Conditions Cond,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Cond.Rule_Id
               AND Rules.Org_Wide_Flag = 'Y'
               AND Rules.Org_Id = l_Org_Id
               AND Rules.Intent = l_Intent
               AND (
                    (to_char(Ord.Question_Id) = Cond.Object_Code
                       AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Ord.Question_Id) = Cond.Object_Value_Code
                       AND Cond.Object_Value_Type = 'QUESTION')
                    )
            );
    --Update stmt3: set mandatory_flag = 'N' for those questions which appear in the outcome of non-ORG wide rule
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'N',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Outcomes   Outs,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Template_Rules  Assoc,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Assoc.Rule_Id
               AND Assoc.Template_Id = p_Template_Id
               AND to_char(Ord.Question_Id) = Outs.Object_Value_Id
               AND Outs.Object_Type = 'QUESTION'
               AND rules.rule_id = outs.rule_id
	       AND rules.status_code <> 'INACTIVE' --Added for Bug#4108690
            );
     --Update stmt4: set mandatory_flag = 'N' for those questions which appear in the outcome of ORG wide rule
     UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'N',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Outcomes   Outs,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Outs.Rule_Id
               AND Rules.Org_Wide_Flag = 'Y'
               AND Rules.Org_Id = l_Org_Id
               AND Rules.Intent = l_Intent
	         AND Rules.status_code <> 'INACTIVE' --Added for Bug#4108690
               AND to_char(Ord.Question_Id) = Outs.Object_Value_Id
               AND Outs.Object_Type = 'QUESTION'
            );
  ELSE --IF p_Mode = 'U'

    IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
      Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                     g_Module || l_Api_Name,
                     '210: Process modes other than "U".');
    END IF;
    --Fix for perf Bug#5030086.Breaking big Update stmt into 4 small Update stmts
    --Update stmt1: set mandatory_flag = 'Y' for those questions which appear in the conditions of
    --Org and non-Org wide rules and rule status is ACTIVE
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'Y',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Conditions Cond,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Template_Rules  Assoc,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Cond.Rule_Id
               AND Rules.Rule_Id = Assoc.Rule_Id
               AND Assoc.Template_Id = p_Template_Id
               AND (
                    (to_char(Ord.Question_Id) = Cond.Object_Code
                       AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Ord.Question_Id) = Cond.Object_Value_Code
                       AND Cond.Object_Value_Type = 'QUESTION')
                   )
               AND Rules.Status_Code = 'ACTIVE'
            UNION
            SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Conditions Cond,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Cond.Rule_Id
               AND Rules.Org_Wide_Flag = 'Y'
               AND Rules.Org_Id = l_Org_Id
               AND Rules.Intent = l_Intent
               AND (
                    (to_char(Ord.Question_Id) = Cond.Object_Code
                       AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Ord.Question_Id) = Cond.Object_Value_Code
                       AND Cond.Object_Value_Type = 'QUESTION')
                   )
               AND Rules.Status_Code = 'ACTIVE');

    --Update stmt2: set mandatory_flag = 'Y' for those questions which appear in the conditions of
    --Org and non-Org wide rules and rule status is PENDINGPUB
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'Y',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Conditions Cond,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Template_Rules  Assoc,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Cond.Rule_Id
               AND Rules.Rule_Id = Assoc.Rule_Id
               AND Assoc.Template_Id = p_Template_Id
               AND (
                    (to_char(Ord.Question_Id) = Cond.Object_Code
                       AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Ord.Question_Id) = Cond.Object_Value_Code
                       AND Cond.Object_Value_Type = 'QUESTION')
                   )
               AND Rules.Status_Code = 'PENDINGPUB'
               AND Rules.Request_Id = l_conc_request_id
            UNION
            SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Conditions Cond,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Cond.Rule_Id
               AND Rules.Org_Wide_Flag = 'Y'
               AND Rules.Org_Id = l_Org_Id
               AND Rules.Intent = l_Intent
               AND (
                    (to_char(Ord.Question_Id) = Cond.Object_Code
                       AND Cond.Object_Type = 'QUESTION') OR
                    (to_char(Ord.Question_Id) = Cond.Object_Value_Code
                       AND Cond.Object_Value_Type = 'QUESTION')
                   )
               AND Rules.Status_Code = 'PENDINGPUB'
               AND Rules.Request_Id = l_conc_request_id );
    --Update stmt3: set mandatory_flag = 'N' for those questions which appear in the Outcome Section of
    --Org and non-Org wide rules and rule status is ACTIVE
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'N',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Outcomes   Outs,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Template_Rules  Assoc,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Assoc.Rule_Id
               AND Assoc.Template_Id = p_Template_Id
               AND to_char(Ord.Question_Id) = Outs.Object_Value_Id
               AND Outs.Object_Type = 'QUESTION'
               AND Rules.Status_Code = 'ACTIVE'
               AND rules.rule_id = outs.rule_id
            UNION
            SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Outcomes   Outs,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Outs.Rule_Id
               AND Rules.Org_Wide_Flag = 'Y'
               AND Rules.Org_Id = l_Org_Id
               AND Rules.Intent = l_Intent
               AND to_char(Ord.Question_Id) = Outs.Object_Value_Id
               AND Outs.Object_Type = 'QUESTION'
               AND Rules.Status_Code = 'ACTIVE'
               AND rules.rule_id = outs.rule_id );
    --Update stmt4: set mandatory_flag = 'N' for those questions which appear in the Outcome Section of
    --Org and non-Org wide rules and rule status is PENDINGPUB
    UPDATE Okc_Xprt_Question_Orders
       SET Mandatory_Flag    = 'N',
           Last_Updated_By   = l_user_id,
           Last_Update_Date  = SYSDATE,
           Last_Update_Login = l_login_id
     WHERE Template_Id = p_Template_Id
       AND Question_Id IN
           (SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Outcomes   Outs,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Template_Rules  Assoc,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Assoc.Rule_Id
               AND Assoc.Template_Id = p_Template_Id
               AND to_char(Ord.Question_Id) = Outs.Object_Value_Id
               AND Outs.Object_Type = 'QUESTION'
               AND Rules.Status_Code = 'PENDINGPUB'
               AND Rules.Request_Id = l_conc_request_id
               AND rules.rule_id = outs.rule_id
            UNION
            SELECT Ord.Question_Id
              FROM Okc_Xprt_Rule_Outcomes   Outs,
                   okc_xprt_rule_hdrs_all   Rules,
                   Okc_Xprt_Question_Orders Ord
             WHERE Rules.Rule_Id = Outs.Rule_Id
               AND Rules.Org_Wide_Flag = 'Y'
               AND Rules.Org_Id = l_Org_Id
               AND Rules.Intent = l_Intent
               AND to_char(Ord.Question_Id) = Outs.Object_Value_Id
               AND Outs.Object_Type = 'QUESTION'
               AND Rules.Status_Code = 'PENDINGPUB'
               AND Rules.Request_Id = l_conc_request_id);

  END IF;

  /*
  6.
  select a cursor for new records and
  set sequence_no with sequence_no+1 for each new record,
  where the intial sequence_no is max of existing sequence_no for the template .
  */
  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '220: End setting the mandatory flag.');
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '230: Start populating sequence for newly inserted questions.');

  END IF;

  DECLARE
    l_Max_Seq     NUMBER :=0;
    l_Question_Id NUMBER;
    CURSOR Questions_For_Seq IS
      SELECT Question_Id
        FROM Okc_Xprt_Question_Orders
       WHERE Template_Id = p_Template_Id
         AND Sequence_Num IS NULL
       ORDER BY Mandatory_Flag DESC;

  BEGIN
    BEGIN
      SELECT MAX(Sequence_Num)
        INTO l_Max_Seq
        FROM Okc_Xprt_Question_Orders
       WHERE Template_Id = p_Template_Id;
    EXCEPTION
      WHEN OTHERS THEN
        l_Max_Seq := 0;
    END;
    l_Max_Seq := NVL(l_Max_Seq, 0);
    FOR Question_Rec IN Questions_For_Seq LOOP
      l_Max_Seq := l_Max_Seq + 1;

      l_Question_Id := Question_Rec.Question_Id;


      UPDATE Okc_Xprt_Question_Orders
         SET Sequence_Num = l_Max_Seq
       WHERE Template_Id = p_Template_Id
         AND Question_Id = l_Question_Id;

    END LOOP;
  END;
  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '240: End populating sequence for newly inserted questions.');

  END IF;

  IF p_Commit_Flag = 'Y' THEN


    IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
      Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                     g_Module || l_Api_Name,
                     '250: Commiting the transaction');

    END IF;
    COMMIT;
  END IF;

  IF (Fnd_Log.Level_Procedure >= Fnd_Log.g_Current_Runtime_Level) THEN
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '1000: Leaving ' || g_Pkg_Name || '.' || l_Api_Name);
  END IF;


EXCEPTION

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
    Fnd_Msg_Pub.Count_And_Get(p_Encoded => 'F',
                              p_Count   => x_Msg_Count,
                              p_Data    => x_Msg_Data);

END Populate_Questions_Order;


/*
   Function : ok_to_delete_question
   This function will return 'Y' for a question id if it is not used in
rule condition or outcome.
   If used, it returns 'N'.
*/

FUNCTION Ok_To_Delete_Question(
    p_question_id         IN NUMBER)
RETURN VARCHAR2 IS
    CURSOR used_in_rule_cond_crs IS
     SELECT 'N'
      FROM OKC_XPRT_RULE_CONDITIONS
     WHERE (object_type IN ('QUESTION','CONSTANT') AND
            object_code = to_char(p_question_id) ) -- Added for bug 5663927
            OR
           (object_value_type IN ('QUESTION','CONSTANT') AND
            object_value_code = to_char(p_question_id)) -- Added for bug 5663927
     UNION
     SELECT 'N'
      FROM OKC_XPRT_RULE_OUTCOMES
      WHERE object_type = 'QUESTION'
      AND object_value_id = p_question_id;

     l_ret VARCHAR2(1) := 'Y';
BEGIN
    OPEN used_in_rule_cond_crs;
    FETCH used_in_rule_cond_crs INTO l_ret;
    CLOSE used_in_rule_cond_crs;
    RETURN l_ret;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN 'N';
    WHEN OTHERS THEN
     IF used_in_rule_cond_crs%ISOPEN THEN
       CLOSE used_in_rule_cond_crs;
     END IF;
     RETURN 'N';
END Ok_To_Delete_Question;


/*
   Procedure : create_production_publication
   This procedure will be called from Publish/Disable rules and Question Sync Concurrent programs
   This procedure does the following in 'PUBLISH' OR 'DISABLE' OR 'SYNC' modes:
   For All templates in the current concurrent request id
     Delete Production mode Publication
	DELETE the UI attached to the production publication
     Update Test mode Publication to Production mode
   Update Rule status in the current concurrent request id
   Update the runtime_available_flag in okc_xprt_question_orders table
   Delete records from okc_xprt_template_rules where deleted_flag = 'Y'
   commit the work

   This procedure can also be called in Template approval flow with mode 'TEMPLATE_APPROVAL'
   This procedure does the following in 'TEMPLATE_APPROVAL' mode:
   For the called template
     Delete Production mode Publication
     Update Test mode Publication to Production mode
   Update the runtime_available_flag in okc_xprt_question_orders table
*/
PROCEDURE create_production_publication
(
 p_calling_mode   IN  VARCHAR2,
 p_template_id    IN  NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_msg_data	      OUT NOCOPY VARCHAR2,
 x_msg_count	  OUT NOCOPY NUMBER
) IS

/*Bug 5032199 commented below cursor.Using REF cursor
CURSOR csr_templates IS
SELECT DECODE(parent_template_id, NULL, template_id, parent_template_id) template_id,
       template_model_id
  FROM okc_terms_templates_all
 WHERE template_id = DECODE(p_template_id,NULL,template_id,p_template_id)
   AND xprt_request_id = DECODE(p_calling_mode,'TEMPLATE_APPROVAL',xprt_request_id, FND_GLOBAL.CONC_REQUEST_ID);
*/

CURSOR csr_rules IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;

CURSOR csr_get_publication_id (p_template_model_id NUMBER, p_publication_mode VARCHAR2) IS
SELECT publication_id ,
       ui_def_id
  FROM cz_model_publications
 WHERE model_id = p_template_model_id
   AND deleted_flag = '0'
   AND publication_mode = p_publication_mode
   AND source_target_flag = 'S';

l_api_version             CONSTANT NUMBER := 1;
l_api_name                CONSTANT VARCHAR2(30) := 'create_production_publication';
l_template_model_id       okc_terms_templates_all.template_model_id%TYPE;
l_run_id                  NUMBER;
l_publication_id          cz_model_publications.publication_id%TYPE;
l_ui_def_id               cz_model_publications.ui_def_id%TYPE;
l_rule_id                 okc_xprt_rule_hdrs_all.rule_id%TYPE;
l_line_level_flag         okc_xprt_rule_hdrs_all.line_level_flag%TYPE;

--Bug 5032199 Using REF cursor
TYPE cur_type IS REF CURSOR;
csr_templates cur_type;
l_sql_stmt long;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  IF (p_calling_mode = 'PUBLISH' OR p_calling_mode = 'DISABLE' OR p_calling_mode = 'SYNC') THEN
     -- Standard Start of API savepoint
     SAVEPOINT g_create_prod_publication;
  END IF;

  --START: Perf Bug 5032199 Using REF cursor
  IF(p_template_id IS NOT NULL) THEN
    l_sql_stmt := 'SELECT   template_model_id
                   FROM okc_terms_templates_all
                   WHERE template_id = '||p_template_id||'
                   AND xprt_request_id = DECODE('''||p_calling_mode||''',
                   ''TEMPLATE_APPROVAL'',xprt_request_id,'||FND_GLOBAL.CONC_REQUEST_ID||')';
  ELSE
    l_sql_stmt := 'SELECT   template_model_id
                   FROM okc_terms_templates_all
                   WHERE xprt_request_id = DECODE('''||p_calling_mode||''',
                   ''TEMPLATE_APPROVAL'',xprt_request_id,'||FND_GLOBAL.CONC_REQUEST_ID||')';
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'l_sql_stmt = '||l_sql_stmt );
  END IF;
  --END:Bug 5032199

  OPEN csr_templates FOR l_sql_stmt;
    LOOP
      FETCH csr_templates INTO l_template_model_id;
	  EXIT WHEN csr_templates%NOTFOUND;
	    -- Delete Production mode publication
	    OPEN csr_get_publication_id(p_template_model_id => l_template_model_id,
		                            p_publication_mode  => G_PRODUCTION_MODE);
	      LOOP
		   FETCH csr_get_publication_id INTO l_publication_id,l_ui_def_id;
		   EXIT WHEN csr_get_publication_id%NOTFOUND;
     	   -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               '   ********************************************************');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'Calling OKC_XPRT_CZ_INT_PVT.delete_publication with parameters');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'p_api_version : '||l_api_version);
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'p_publication_id : '||l_publication_id);
		   END IF;


		    -- Call CZ delete publicaton API
		     OKC_XPRT_CZ_INT_PVT.delete_publication
               (
                p_api_version      =>  l_api_version,
			 p_init_msg_lst        =>  FND_API.G_FALSE,
                p_publication_id   =>  l_publication_id,
                x_return_status    =>  x_return_status,
                x_msg_data	       =>  x_msg_data,
                x_msg_count	       =>  x_msg_count
               ) ;


		   -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               '   ********************************************************');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'After Calling OKC_XPRT_CZ_INT_PVT.delete_publication');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'x_return_status : '||x_return_status);
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               '   ********************************************************');
		   END IF;

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


		   -- Delete the UI attached to the above production publication
		     OKC_XPRT_CZ_INT_PVT.delete_ui_def
               (
                p_api_version      =>  l_api_version,
                p_ui_def_id        =>  l_ui_def_id,
                x_return_status    =>  x_return_status,
                x_msg_data	     =>  x_msg_data,
                x_msg_count	     =>  x_msg_count
               ) ;


               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

		 END LOOP; -- csr_get_publication_id
	    CLOSE csr_get_publication_id;

	    -- Edit Test mode publication
	    OPEN csr_get_publication_id(p_template_model_id => l_template_model_id,
		                            p_publication_mode  => G_TEST_MODE);
	      LOOP
		   FETCH csr_get_publication_id INTO l_publication_id,l_ui_def_id;
		   EXIT WHEN csr_get_publication_id%NOTFOUND;

     	   -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               '   ********************************************************');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'Calling OKC_XPRT_CZ_INT_PVT.delete_publication with parameters');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'p_api_version : '||l_api_version);
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'p_publication_id : '||l_publication_id);
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'p_publication_mode : '||G_TEST_MODE);
		   END IF;

		    -- Call CZ edit publicaton API
		     OKC_XPRT_CZ_INT_PVT.edit_publication
               (
                p_api_version      =>  l_api_version,
  		      p_init_msg_lst        =>  FND_API.G_FALSE,
                p_publication_id   =>  l_publication_id,
                p_publication_mode =>  G_PRODUCTION_MODE,
                x_return_status    =>  x_return_status,
                x_msg_data	       =>  x_msg_data,
                x_msg_count	       =>  x_msg_count
               ) ;

		   -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               '   ********************************************************');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'After Calling OKC_XPRT_CZ_INT_PVT.delete_publication');
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'x_return_status : '||x_return_status);
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               '   ********************************************************');
		   END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

		 END LOOP; -- csr_get_publication_id
	    CLOSE csr_get_publication_id;

	END LOOP; -- l_tmpl_csr
  CLOSE csr_templates;

     -- Put the parameters in log file
       fnd_file.put_line(FND_FILE.LOG,'  ');
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'p_calling_mode:  '||p_calling_mode);
       fnd_file.put_line(FND_FILE.LOG,'p_template_id:  '||p_template_id);
       fnd_file.put_line(FND_FILE.LOG,'xprt_request_id:  '||FND_GLOBAL.CONC_REQUEST_ID);
       fnd_file.put_line(FND_FILE.LOG,'*********************************************** ');
       fnd_file.put_line(FND_FILE.LOG,'  ');

  IF (p_calling_mode = 'PUBLISH') THEN
      -- Update all the Question order records that have question_rule_status as PENDINGPUB
	  UPDATE Okc_Xprt_Question_Orders
	     SET runtime_available_flag = 'Y',
		    question_rule_status  = 'ACTIVE',
	         last_updated_by = FND_GLOBAL.USER_ID,
	         last_update_date = SYSDATE,
	         last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE question_rule_status = 'PENDINGPUB'
	     AND template_id IN ( SELECT template_id
		                       FROM okc_terms_templates_all
						  WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID
		                   );
   -- Delete from okc_xprt_template_rules
      DELETE FROM okc_xprt_template_rules
	  WHERE NVL(deleted_flag,'N') = 'Y'
	    AND template_id IN ( SELECT template_id
		                       FROM okc_terms_templates_all
						  WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID
		                   );

   -- Update published_flag in okc_xprt_template_rules
        UPDATE okc_xprt_template_rules
	      SET published_flag = 'Y'
	    WHERE template_id IN ( SELECT template_id
		                       FROM okc_terms_templates_all
						  WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID
		                   );
  END IF; -- p_calling_mode = 'PUBLISH'

  IF p_calling_mode = 'TEMPLATE_APPROVAL' THEN
      -- if template approval then go by template id
	  UPDATE Okc_Xprt_Question_Orders
	     SET runtime_available_flag = 'Y',
	         last_updated_by = FND_GLOBAL.USER_ID,
	         last_update_date = SYSDATE,
	         last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE template_id= p_template_id
	     AND question_rule_status = 'ACTIVE';

   -- Delete from okc_xprt_template_rules
      DELETE FROM okc_xprt_template_rules
	  WHERE NVL(deleted_flag,'N') = 'Y'
	    AND template_id =  p_template_id;

   -- Update published_flag in okc_xprt_template_rules
        UPDATE okc_xprt_template_rules
	      SET published_flag = 'Y'
	   WHERE template_id= p_template_id ;

  END IF;

  -- Update Rule status
    OPEN csr_rules;
      LOOP
        FETCH csr_rules INTO l_rule_id;
  	  EXIT WHEN csr_rules%NOTFOUND;

  	  SELECT okc_xprt_util_pvt.is_rule_line_level(l_rule_id) INTO l_line_level_flag FROM DUAL;

	  UPDATE okc_xprt_rule_hdrs_all
	     SET status_code = DECODE (p_calling_mode, 'PUBLISH', 'ACTIVE', 'DISABLE', 'INACTIVE', 'SYNC', 'ACTIVE'),
		    published_flag = 'Y',
		 line_level_flag = l_line_level_flag, --is_rule_line_level(l_rule_id),
		 last_updated_by = FND_GLOBAL.USER_ID,
		 last_update_date = SYSDATE,
		 last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE rule_id = l_rule_id;

      END LOOP;
    CLOSE csr_rules;



  --- If any errors happen abort API
  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_calling_mode = 'PUBLISH' OR p_calling_mode = 'DISABLE' OR p_calling_mode = 'SYNC') THEN
    COMMIT WORK;
  END IF;

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

      IF (p_calling_mode = 'PUBLISH' OR p_calling_mode = 'DISABLE' OR p_calling_mode = 'SYNC') THEN
	    ROLLBACK TO g_create_prod_publication;
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      IF (p_calling_mode = 'PUBLISH' OR p_calling_mode = 'DISABLE' OR p_calling_mode = 'SYNC') THEN
	    ROLLBACK TO g_create_prod_publication;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      IF (p_calling_mode = 'PUBLISH' OR p_calling_mode = 'DISABLE' OR p_calling_mode = 'SYNC') THEN
	    ROLLBACK TO g_create_prod_publication;
      END IF;

   IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
   END IF;
   x_return_status := G_RET_STS_UNEXP_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_production_publication;

------------------------------------------------------------------------------
/*========================================================================+
Procedure:  validate_template_for_expert
Description:  This API is called from OKC_DOC_QA_PVT for doc type = TEMPLATE


+========================================================================*/

PROCEDURE validate_template_for_expert(
p_api_version                  IN NUMBER,
p_init_msg_list                IN VARCHAR2,
p_template_id                  IN NUMBER,
x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
x_return_status                OUT NOCOPY VARCHAR2,
x_msg_count                    OUT NOCOPY NUMBER,
x_msg_data                     OUT NOCOPY VARCHAR2)

IS


l_api_name CONSTANT VARCHAR2(30) := 'validate_template_for_expert';
l_api_version CONSTANT NUMBER := 1;

l_ce_enabled                VARCHAR2(50);
l_template_ce_enabled       okc_terms_templates_all.contract_expert_enabled%TYPE;

l_qa_tbl_index NUMBER;

l_template_rule_status_sev        OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
l_template_rule_status_desc       OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
l_perf_template_rule_status       VARCHAR2(1);

l_def_template_sev        OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
l_def_template_desc       OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
l_def_template_status     VARCHAR2(1);

l_tmpl_non_active_rule_exists     VARCHAR2(1);

l_template_no_rule_sev            OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
l_template_no_rule_desc           OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
l_perf_template_no_rule           VARCHAR2(1);

l_tmpl_active_rule_exists         VARCHAR2(1);
l_template_name                   okc_terms_templates_all.template_name%TYPE;
l_XPRT_SCN_CODE                   okc_terms_templates_all.XPRT_SCN_CODE%TYPE;
l_section_name                    FND_LOOKUPS.MEANING%TYPE;

CURSOR csr_template_dtls IS
SELECT contract_expert_enabled , template_name , XPRT_SCN_CODE
FROM okc_terms_templates_all
WHERE template_id = p_template_id;


CURSOR csr_tmpl_non_active_rules IS
-- global rules not active
SELECT 'X'
  FROM okc_xprt_rule_hdrs_all r,
       okc_terms_templates_all t
  WHERE t.org_id = r.org_id
    AND t.intent  = r.intent
    AND t.template_id = p_template_id
    AND r.org_wide_flag = 'Y'
    AND r.status_code NOT IN ('ACTIVE','INACTIVE')
UNION ALL
 -- Local rules not active
SELECT 'X'
  FROM okc_xprt_template_rules tr,
       okc_xprt_rule_hdrs_all r
  WHERE tr.template_id = p_template_id
    AND tr.rule_id  = r.rule_id
    AND r.status_code NOT IN ('ACTIVE','INACTIVE');

CURSOR csr_tmpl_active_rules IS
-- global Active rules
SELECT 'X'
  FROM okc_xprt_rule_hdrs_all r,
       okc_terms_templates_all t
  WHERE t.org_id = r.org_id
    AND t.intent  = r.intent
    AND t.template_id = p_template_id
    AND r.org_wide_flag = 'Y'
    AND r.status_code = 'ACTIVE'
UNION ALL
 -- Local Active rules
SELECT 'X'
  FROM okc_xprt_template_rules tr,
       okc_xprt_rule_hdrs_all r
  WHERE tr.template_id = p_template_id
    AND tr.rule_id  = r.rule_id
    AND r.status_code = 'ACTIVE' ;

-- bug 4120816
CURSOR cst_tmpl_def_section (p_scn_code VARCHAR2) IS
  SELECT meaning
  FROM fnd_lookups
  WHERE lookup_type  = 'OKC_ARTICLE_SECTION'
  AND lookup_code = p_scn_code
  AND sysdate not between start_date_active and nvl(end_date_active,sysdate) ;

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		          G_MODULE||l_api_name,
		          'p_template_id : '||p_template_id);
  END IF;


      --
      -- Standard call to check for call compatibility.
      --
      IF NOT FND_API.Compatible_API_Call (l_api_version,
         	       	    	    	 	p_api_version,
          	    	    	    	l_api_name,
      		    	    	    	G_PKG_NAME)
      THEN
      	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- Initialize message list if p_init_msg_list is set to TRUE.
      --
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
      	FND_MSG_PUB.initialize;
      END IF;

      --
      --  Initialize API return status to success
      --
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Check if CE Profile is Enabled.
      --
	 FND_PROFILE.GET(name=> 'OKC_K_EXPERT_ENABLED', val => l_ce_enabled);

	 IF NVL(l_ce_enabled,'N') = 'N' THEN
	   -- Not Expert enabled, skip QA
        RETURN;
      END IF;

	 -- Check if template is Expert enabled , else skip QA
	 OPEN csr_template_dtls;
	   FETCH csr_template_dtls INTO l_template_ce_enabled, l_template_name, l_XPRT_SCN_CODE;
	 CLOSE csr_template_dtls;

      IF NVL(l_template_ce_enabled,'N') = 'N' THEN
	   RETURN;
	 END IF;

      --
      -- Get Not Applied QA Code Severity and Name
      --
      OKC_TERMS_QA_PVT.get_qa_code_detail(p_qa_code =>  G_CHECK_TEMPLATE_RULE_STATUS ,
                         x_perform_qa    => l_perf_template_rule_status,
                         x_qa_name       => l_template_rule_status_desc,
                         x_severity_flag => l_template_rule_status_sev,
                         x_return_status => x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;


      --
      -- Get Default template section severity and name
      --
      OKC_TERMS_QA_PVT.get_qa_code_detail(p_qa_code =>  G_CHECK_INVALID_XPRT_SECTION ,
                         x_perform_qa    => l_def_template_status,
                         x_qa_name       => l_def_template_desc,
                         x_severity_flag => l_def_template_sev,
                         x_return_status => x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

	 --
      -- Check for the template default section
	 --
	   OPEN cst_tmpl_def_section ( l_XPRT_SCN_CODE );
	   FETCH cst_tmpl_def_section INTO l_section_name;
	   IF cst_tmpl_def_section%FOUND THEN
           l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

           x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
           x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
           x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
           x_qa_result_tbl(l_qa_tbl_index).title               := l_template_name;
           x_qa_result_tbl(l_qa_tbl_index).section_name        := l_section_name;
           x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_INVALID_XPRT_SECTION;
           x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_INVALID_XPRT_SECTION;
           x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_INVALID_XPRT_SECTION_S);
           x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_def_template_sev;
           x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_def_template_desc;
           x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
           OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_INVALID_XPRT_SECTION);
	   END IF; -- rules not active found
	   CLOSE cst_tmpl_def_section;

      --
      -- Get Template with no rules QA Code Severity and Name
      --

      OKC_TERMS_QA_PVT.get_qa_code_detail(p_qa_code =>  G_CHECK_TEMPLATE_NO_RULES ,
                         x_perform_qa    => l_perf_template_no_rule,
                         x_qa_name       => l_template_no_rule_desc,
                         x_severity_flag => l_template_no_rule_sev,
                         x_return_status => x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
      END IF;


      --
      -- These QA Checks should always be performed sequentially,
      -- regardless of the set-up.  Therefore, if one of
      -- the checks is enabled, then both checks will
      -- be performed but with a 'Warning' severity.
      --

	 IF l_perf_template_rule_status = 'Y' THEN

	   OPEN csr_tmpl_non_active_rules;
	     FETCH csr_tmpl_non_active_rules INTO l_tmpl_non_active_rule_exists;
		IF csr_tmpl_non_active_rules%FOUND THEN
        --
        -- Template with rules in non active status
        --
        l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

        x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
        x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
        x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
        x_qa_result_tbl(l_qa_tbl_index).title               := l_template_name;
        x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
        x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_TEMPLATE_RULE_STATUS;
        x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_TEMPLATE_RULE_STATUS;
        x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_TEMPLATE_RULE_STATUS_S);
        x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_template_rule_status_sev;
        x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_template_rule_status_desc;
        x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
                         OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_TEMPLATE_RULE_STATUS);


		END IF; -- rules not active found
	   CLOSE csr_tmpl_non_active_rules;

	 END IF; -- l_perf_template_rule_status

	 IF l_perf_template_no_rule = 'Y' THEN

	   OPEN csr_tmpl_active_rules;
	     FETCH csr_tmpl_active_rules INTO l_tmpl_active_rule_exists;
		IF csr_tmpl_active_rules%NOTFOUND THEN
        --
        -- Template with no rules in active status
        --
        l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

        x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
        x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
        x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
        x_qa_result_tbl(l_qa_tbl_index).title               := l_template_name;
        x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
        x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_TEMPLATE_NO_RULES;
        x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_TEMPLATE_NO_RULES;
        x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_TEMPLATE_NO_RULES_S);
        x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_template_no_rule_sev;
        x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_template_no_rule_desc;
        x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
                         OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                        G_OKC_TEMPLATE_NO_RULES);


		END IF; -- rules not active found
	   CLOSE csr_tmpl_active_rules;


	 END IF; -- l_perf_template_no_rule

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get(
    		        p_count => x_msg_count,
            		p_data => x_msg_data
    		);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get(
    		        p_count => x_msg_count,
            		p_data => x_msg_data
    		);

        WHEN OTHERS THEN
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      		IF FND_MSG_PUB.Check_Msg_Level
    		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    		THEN
        	    	FND_MSG_PUB.Add_Exc_Msg(
        	    	     G_PKG_NAME  	    ,
        	    	     l_api_name
    	    	      );
    		END IF;

    		FND_MSG_PUB.Count_And_Get(
    		     p_count => x_msg_count,
            	     p_data => x_msg_data
    		);

END validate_template_for_expert;


PROCEDURE build_cz_xml_init_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_template_id                  IN NUMBER,
    x_cz_xml_init_msg              OUT NOCOPY LONG,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

IS

    l_api_name CONSTANT VARCHAR2(30) := 'build_cz_xml_init_msg';
    l_api_version CONSTANT NUMBER := 1.0;

    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

    --
    -- XML Message String Variables
    --
    l_xml_init_msg VARCHAR2(2000);
    l_dummy VARCHAR2(2000);

    --
    -- CZ XML Init Message Parameters
    --
    l_database_id VARCHAR2(100);
    l_save_config_behavior VARCHAR2(30);     -- Always save to a new revision
    l_ui_type VARCHAR2(30);
    l_msg_behavior VARCHAR2(30);  -- Output Msg

    --
    -- OKC XML Init Message Parameters
    --
    l_config_header_id VARCHAR2(80);
    l_config_rev_nbr   VARCHAR2(80);
    l_product_key      VARCHAR2(80);
    l_session_id       VARCHAR2(80);
    l_config_creation_date VARCHAR2(15);
    l_config_effective_date VARCHAR2(15);
    l_config_model_lookup_date VARCHAR2(15);
    l_product_id varchar2(100);
    l_save_config_behavior varchar2(100);


    TYPE param_name_type IS TABLE OF VARCHAR2(30)
     INDEX BY BINARY_INTEGER;

    TYPE param_value_type IS TABLE OF VARCHAR2(200)
     INDEX BY BINARY_INTEGER;

    l_param_name_tbl param_name_type;
    l_param_value_tbl param_value_type;
    l_num_records NUMBER;
    l_rec_index NUMBER;

    l_org_id     okc_terms_templates_all.org_id%TYPE;
    l_intent     okc_terms_templates_all.intent%TYPE;

    CURSOR csr_config_effective_date IS
    SELECT TO_CHAR(SYSDATE, 'MM-DD-YYYY')
    FROM   dual;

    CURSOR csr_template_dtls IS
    SELECT org_id,
           intent
    FROM okc_terms_templates_all
    WHERE template_id = p_template_id;

  BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_document_id : '||p_document_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_document_type : '||p_document_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_rev_nbr : '||p_config_rev_nbr);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_template_id : '||p_template_id);
  END IF;

      x_return_status :=  G_RET_STS_SUCCESS;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Example:  <param name="config_header_id">1890</param>

    --
    -- Initialize Values
    --
    l_xml_init_msg := '<initialize>';

    l_msg_behavior := 'brief';
    l_database_id := FND_WEB_CONFIG.database_id;
    l_session_id := FND_PROFILE.value('DB_SESSION_ID');

    OPEN csr_config_effective_date;
      FETCH csr_config_effective_date INTO l_config_effective_date;
    CLOSE csr_config_effective_date;

    l_config_model_lookup_date := l_config_effective_date;
    --
    -- Set CZ Parameter Names and Values in Tables
    --
    OPEN csr_template_dtls;
      FETCH csr_template_dtls INTO l_org_id, l_intent;
    CLOSE csr_template_dtls;

    l_product_id := G_TEMPLATE_MODEL_OSR|| l_org_id||':'|| l_intent||':'|| p_template_id;


    l_param_name_tbl(1) := 'database_id';
    l_param_value_tbl(1) := l_database_id;

    l_param_name_tbl(2) := 'config_effective_date'; -- date that cz published model is effective
    l_param_value_tbl(2) := l_config_effective_date;

    l_param_name_tbl(3) := 'config_model_lookup_date';
    l_param_value_tbl(3) := l_config_model_lookup_date;

    l_param_name_tbl(4) := 'calling_application_id';
    l_param_value_tbl(4) := '510';

    l_param_name_tbl(5) := 'product_id';
    l_param_value_tbl(5) := l_product_id;

    l_param_name_tbl(6) := 'config_header_id';
    l_param_value_tbl(6) := p_config_header_id;

    l_param_name_tbl(7) := 'config_rev_nbr';
    l_param_value_tbl(7) := p_config_rev_nbr;

    l_param_name_tbl(8) := 'terminate_msg_behavior';
    l_param_value_tbl(8) := l_msg_behavior;

    l_param_name_tbl(9) := 'icx_session_ticket';
    l_param_value_tbl(9) := cz_cf_api.icx_session_ticket;


    l_param_name_tbl(10) := 'publication_mode';
    l_param_value_tbl(10) := 'P'; -- Contracts always uses the 'Production' publication

    l_param_name_tbl(13) := 'save_config_behavior';
    l_param_value_tbl(13) := 'new_revision';

    --
    -- Set OKC Parameter Names in Table
    --
    l_param_name_tbl(11) := 'okc_doc_header_id';
    l_param_value_tbl(11) := p_document_id;

    l_param_name_tbl(12) := 'okc_doc_type';
    l_param_value_tbl(12) := p_document_type;


    -- AM:  Hard coded.  Needs to be commented out after UT.
    l_param_name_tbl(14) := 'okc_test_expert';
    l_param_value_tbl(14) := 'false';

    l_num_records := l_param_name_tbl.count;
    --
    -- Loop to build XML Init Message
    --
    l_rec_index := 1;

    LOOP
    IF (l_param_value_tbl(l_rec_index) IS NOT NULL)
      THEN

         l_dummy := '<param name=' || '"' || l_param_name_tbl(l_rec_index) ||
                    '"' || '>' || l_param_value_tbl(l_rec_index) ||
                    '</param>';
         l_xml_init_msg := l_xml_init_msg || l_dummy;

	    -- debug log
	    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               l_rec_index||' : '||l_dummy);
         END IF; -- debug log

      END IF;   -- l_param_value_tbl is not null

      l_dummy := NULL;
      l_rec_index := l_rec_index + 1;

      EXIT WHEN l_rec_index > l_num_records;
    END LOOP;

    l_xml_init_msg := l_xml_init_msg || '</initialize>';
    l_xml_init_msg := REPLACE(l_xml_init_msg, ' ', '+');

    x_cz_xml_init_msg := l_xml_init_msg;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;

  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END build_cz_xml_init_msg;


PROCEDURE parse_cz_xml_terminate_msg(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_cz_xml_terminate_msg         IN LONG,
    x_valid_config                 OUT NOCOPY VARCHAR2,
    x_complete_config              OUT NOCOPY VARCHAR2,
    x_config_header_id             OUT NOCOPY NUMBER,
    x_config_rev_nbr               OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

IS

    l_api_name CONSTANT VARCHAR2(30) := 'parse_cz_xml_terminate_msg';
    l_api_version CONSTANT NUMBER := 1;
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

    l_exit_start_tag                CONSTANT VARCHAR2(20) := '<exit>';
    l_exit_end_tag                  CONSTANT VARCHAR2(20) := '</exit>';
    l_exit_start_pos                NUMBER;
    l_exit_end_pos                  NUMBER;

    l_valid_config_start_tag        CONSTANT VARCHAR2(30) := '<valid_configuration>';
    l_valid_config_end_tag          CONSTANT VARCHAR2(30) := '</valid_configuration>';
    l_valid_config_start_pos        NUMBER;
    l_valid_config_end_pos          NUMBER;

    l_complete_config_start_tag     CONSTANT VARCHAR2(30) := '<complete_configuration>';
    l_complete_config_end_tag       CONSTANT VARCHAR2(30) := '</complete_configuration>';
    l_complete_config_start_pos     NUMBER;
    l_complete_config_end_pos       NUMBER;

    l_config_header_id_start_tag    CONSTANT VARCHAR2(20) := '<config_header_id>';
    l_config_header_id_end_tag      CONSTANT VARCHAR2(20) := '</config_header_id>';
    l_config_header_id_start_pos    NUMBER;
    l_config_header_id_end_pos      NUMBER;

    l_config_rev_nbr_start_tag      CONSTANT VARCHAR2(20) := '<config_rev_nbr>';
    l_config_rev_nbr_end_tag        CONSTANT VARCHAR2(20) := '</config_rev_nbr>';
    l_config_rev_nbr_start_pos      NUMBER;
    l_config_rev_nbr_end_pos        NUMBER;

    /*---------------------------------------------------------------------+
          Possibly for debugging only.
    +---------------------------------------------------------------------*/

    l_message_text_start_tag          VARCHAR2(20) := '<message_text>';
    l_message_text_end_tag            VARCHAR2(20) := '</message_text>';
    l_message_text_start_pos          NUMBER;
    l_message_text_end_pos            NUMBER;

    l_message_type_start_tag          VARCHAR2(20) := '<message_type>';
    l_message_type_end_tag            VARCHAR2(20) := '</message_type>';
    l_message_type_start_pos          NUMBER;
    l_message_type_end_pos            NUMBER;

    l_message_text                    VARCHAR2(4000);
    l_message_type                    VARCHAR2(200);

    l_exit                            VARCHAR(20); -- save, cancel, error, processed
    l_config_header_id                NUMBER;
    l_config_rev_nbr                  NUMBER;
    l_valid_config                    VARCHAR2(10);
    l_complete_config                 VARCHAR2(10);

    l_flag                            VARCHAR2(1);
    l_true                            VARCHAR2(10);

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  l_flag := 'N';
  l_true := 'true';


     /*----------------------------------------------------------------+
     Parse Process:  <VALID_CONFIGURATION>true</VALID_CONFIGURATION>
           1st instr: posin of a(e.g. 22)
           2nd instr: gives posn of c(e.g.25)
           substr: string starting from posn a to (posn c - posn a + 1)
     +-----------------------------------------------------------------*/
      l_exit_start_pos :=
                    INSTR(p_cz_xml_terminate_msg, l_exit_start_tag,1, 1) +
                                LENGTH(l_exit_start_tag);

      l_exit_end_pos   :=
                          INSTR(p_cz_xml_terminate_msg, l_exit_end_tag,1, 1) - 1;

      l_exit           := SUBSTR (p_cz_xml_terminate_msg, l_exit_start_pos,
                                  l_exit_end_pos - l_exit_start_pos + 1);

       -- debug log
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_exit_start_pos : '||l_exit_start_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_exit_end_pos : '||l_exit_end_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_exit : '||l_exit);
       END IF;


      IF (NVL(LOWER(l_exit),'error') <> 'error')
      THEN

        --
        -- Valid Config
        --
        l_valid_config_start_pos :=
                INSTR(p_cz_xml_terminate_msg, l_valid_config_start_tag,1, 1) +
          LENGTH(l_valid_config_start_tag);

        l_valid_config_end_pos :=
                INSTR(p_cz_xml_terminate_msg, l_valid_config_end_tag,1, 1) - 1;

        l_valid_config := SUBSTR( p_cz_xml_terminate_msg, l_valid_config_start_pos,
                                  l_valid_config_end_pos -
                                  l_valid_config_start_pos + 1);

        --
        -- Complete Config
        --
        l_complete_config_start_pos :=
                   INSTR(p_cz_xml_terminate_msg, l_complete_config_start_tag,1, 1) +
                   LENGTH(l_complete_config_start_tag);
        l_complete_config_end_pos :=
                   INSTR(p_cz_xml_terminate_msg, l_complete_config_end_tag,1, 1) - 1;

        l_complete_config := SUBSTR( p_cz_xml_terminate_msg, l_complete_config_start_pos,
                                     l_complete_config_end_pos -
                                     l_complete_config_start_pos + 1);

       -- debug log
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_valid_config_start_pos : '||l_valid_config_start_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_valid_config_end_pos : '||l_valid_config_end_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_valid_config : '||l_valid_config);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_complete_config_start_pos : '||l_complete_config_start_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_complete_config_end_pos : '||l_complete_config_end_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_complete_config : '||l_complete_config);
       END IF;

        /*
        IF (UPPER(NVL(l_valid_config, 'false'))  <> UPPER(l_true)) THEN
            l_flag := 'Y';
        END IF ;

        IF (UPPER(NVL(l_complete_config, 'false')) <> UPPER(l_true) ) THEN
            l_flag := 'Y';
        END IF;
       */

      ELSE /* error in bv */
	   -- <exit>error</exit>
	   -- parse the error message
	   -- following is the sample output from CZ in case of errors in batch validate
	   /*
         <?xml version='1.0'?>
           <terminate>
             <exit>error</exit>
                <config_messages>
                    <message>
                       <message_type>error</message_type>
                       <message_text>Session cannot be started:BatchValidate.
				                 There is no published model.
                                     oracle.apps.cz.dio.pb.NoSuchModelPublicationException:
							  The Publication could not be found.
                                     The publishing information provided is:
							  product_id = OKC:TEMPLATEMODEL:::1004,
							  config_model_lookup_date = 02-02-2005,
							  publication_mode = P,
							  calling_application_id = 510.
				    </message_text>
                    </message>
                </config_messages>
           </terminate>
	   */

        --
        -- Parse Error Message text: <message_text> Error Message Text </message_text>
        --
        l_message_text_start_pos :=
                INSTR(p_cz_xml_terminate_msg,l_message_text_start_tag ,1, 1) +
          LENGTH(l_message_text_start_tag);

        l_message_text_end_pos :=
                INSTR(p_cz_xml_terminate_msg, l_message_text_end_tag,1, 1) - 1;

        l_message_text := SUBSTR( p_cz_xml_terminate_msg,l_message_text_start_pos ,
                                  l_message_text_end_pos -
                                  l_message_text_start_pos + 1);

        --
        -- Parse Error Message Type: <message_type>error</message_type>
        --
        l_message_type_start_pos :=
                INSTR(p_cz_xml_terminate_msg,l_message_type_start_tag ,1, 1) +
          LENGTH(l_message_type_start_tag);

        l_message_type_end_pos :=
                INSTR(p_cz_xml_terminate_msg, l_message_type_end_tag,1, 1) - 1;

        l_message_type := SUBSTR( p_cz_xml_terminate_msg,l_message_type_start_pos ,
                                  l_message_type_end_pos -
                                  l_message_type_start_pos + 1);

	   -- set the OUT params
	   x_msg_count := 1;
	   x_msg_data := l_message_type||' : '||l_message_text;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF; /* l_exit <> error */

      --
      -- Parsing message_text and type is not required. Debugging.
      --

     --
      -- Config_Header_Id
      --
      l_config_header_id_start_pos :=
                       INSTR(p_cz_xml_terminate_msg, l_config_header_id_start_tag, 1, 1)+
                       LENGTH(l_config_header_id_start_tag);

      l_config_header_id_end_pos :=
                       INSTR(p_cz_xml_terminate_msg, l_config_header_id_end_tag, 1, 1) - 1;

      l_config_header_id :=
                       TO_NUMBER(SUBSTR( p_cz_xml_terminate_msg,l_config_header_id_start_pos,
                                         l_config_header_id_end_pos -
                                         l_config_header_id_start_pos + 1));


      --
      -- Config_Rev_Nbr
      --
      l_config_rev_nbr_start_pos :=
                       INSTR(p_cz_xml_terminate_msg, l_config_rev_nbr_start_tag, 1, 1)+
                             LENGTH(l_config_rev_nbr_start_tag);

      l_config_rev_nbr_end_pos :=
                       INSTR(p_cz_xml_terminate_msg, l_config_rev_nbr_end_tag, 1, 1) - 1;

      l_config_rev_nbr :=
                       TO_NUMBER(SUBSTR( p_cz_xml_terminate_msg,l_config_rev_nbr_start_pos,
                                         l_config_rev_nbr_end_pos -
                                         l_config_rev_nbr_start_pos + 1));

       -- debug log
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_config_header_id_start_pos : '||l_config_header_id_start_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_config_header_id_end_pos : '||l_config_header_id_end_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_config_header_id : '||l_config_header_id);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_config_rev_nbr_start_pos : '||l_config_rev_nbr_start_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_config_rev_nbr_end_pos : '||l_config_rev_nbr_end_pos);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'l_config_rev_nbr : '||l_config_rev_nbr);
       END IF;


      x_config_header_id := l_config_header_id;
      x_config_rev_nbr   := l_config_rev_nbr;
      x_complete_config  := NVL(l_complete_config, 'FALSE');
      x_valid_config     := NVL(l_valid_config, 'FALSE');

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
		-- Uncommented this code to get proper error messages for Bug 5000619
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END parse_cz_xml_terminate_msg;



/*====================================================================+
  Procedure Name : process_qa_result
  Description    : Compares the newly selected Configurator articles
                   with the Configurator-selected articles currently in
                   the document.  It does the following:

                   a.	For each CZ Document Article not in CZ New Articles
                            -> Insert message in QA PL/SQL Table
                   b.	For each CZ New Article not in CZ Document Articles
                            -> Insert message in QA PL/SQL Table
+====================================================================*/
PROCEDURE process_qa_result(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

IS
    l_api_name CONSTANT VARCHAR2(30) := 'process_qa_result';
    l_api_version CONSTANT NUMBER := 1;

    l_article_tbl_index NUMBER;
    l_article_id NUMBER;
    l_article_version_id NUMBER;
    l_article_name  varchar2(1000);

    l_prov_allowed  varchar2(1);
    l_provision  varchar2(1);

    l_expert_articles_tbl expert_articles_tbl_type;
    l_articles_not_in_cz_tbl expert_articles_tbl_type;

    l_qa_tbl_index  NUMBER;
    l_severity      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perform_bv_qa VARCHAR2(1);

    l_new_expert_article_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_new_expert_article_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_new_expert_art VARCHAR2(1);

    l_old_expert_article_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_old_expert_article_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_old_expert_art VARCHAR2(1);

    --
    -- Cursor to check provision allowed for doc type
    --
    CURSOR l_get_prov_csr IS
    SELECT NVL(PROVISION_ALLOWED_YN,'Y')
    FROM OKC_BUS_DOC_TYPES_B
    WHERE  DOCUMENT_TYPE=p_document_type;

    --
    -- Currsor to Select the Expert Articles
    -- that are in the latest Configuration
    --
    --

    CURSOR l_get_expert_articles_from_cz IS
    SELECT SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1)
      FROM cz_config_items_v
     WHERE  config_hdr_id = p_config_header_id
       AND  config_rev_nbr = p_config_rev_nbr
       AND  orig_sys_ref LIKE 'OKC:CLAUSEMODELOPTION:%' ;

    --
    -- Currsor to Select the Expert Articles
    -- that are in the OKC rules engine

	CURSOR c_expert_articles_from_ruleng IS
	SELECT distinct outcome.object_value_id
	FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome
	WHERE rultmp.doc_id = p_document_id
	AND rultmp.doc_type = p_document_type
	AND rultmp.condition_id IS NULL
	AND nvl(rultmp.result, '*' ) = 'Y'
	AND rul.rule_id = rultmp.rule_id
	AND rul.rule_type = 'CLAUSE_SELECTION'
	AND outcome.rule_id = rul.rule_id
	AND outcome.object_type = 'CLAUSE';

    --
    -- Currsor to find Expert Articles in the new config
    -- that are also in the document.
    --
    --
    CURSOR l_article_in_doc (b_article_id NUMBER) IS
       SELECT kart.orig_article_id
       FROM   OKC_K_ARTICLES_B KART
       WHERE  document_type = p_document_type
       AND    document_id = p_document_id
       AND    source_flag='R'
       AND    NVL(kart.AMENDMENT_OPERATION_CODE, '?') <> 'DELETED'
       AND    NVL(kart.SUMMARY_AMEND_OPERATION_CODE, '?') <> 'DELETED'
       AND     kart.orig_article_id = b_article_id;

    --
    -- Currsor to Select the Expert Articles in the Document
    -- that are not in the latest Configuration
    --
    --
    CURSOR l_articles_only_in_doc (p_document_type varchar2,
                              p_document_id number,
                              p_config_header_id number,
                              p_config_rev_nbr number) IS
            SELECT orig_article_id
            FROM   okc_k_articles_b kart
            WHERE  kart.document_type = p_document_type
            AND    kart.document_id = p_document_id
            AND    kart.source_flag = 'R'  -- from Contract Expert
            AND    NVL(kart.AMENDMENT_OPERATION_CODE, '?') <> 'DELETED'
            AND    NVL(kart.SUMMARY_AMEND_OPERATION_CODE, '?') <> 'DELETED'
            --AND    (nvl(nvl(kart.ref_article_id, kart.sav_sae_id), -1) not in (
            AND    (kart.orig_article_id NOT IN (
		          SELECT SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1)
                      FROM cz_config_items_v
                     WHERE  config_hdr_id = p_config_header_id
                       AND  config_rev_nbr = p_config_rev_nbr
                       AND  orig_sys_ref LIKE 'OKC:CLAUSEMODELOPTION:%'
				                            )
				);
    --
    -- Currsor to Select the Expert Articles in the Document
    -- that are not in the okc rules engine
    --
    CURSOR l_articles_only_in_doc_ruleng (p_document_type varchar2,
                              p_document_id number) IS
            SELECT orig_article_id
            FROM   okc_k_articles_b kart
            WHERE  kart.document_type = p_document_type
            AND    kart.document_id = p_document_id
            AND    kart.source_flag = 'R'  -- from Contract Expert
            AND    NVL(kart.AMENDMENT_OPERATION_CODE, '?') <> 'DELETED'
            AND    NVL(kart.SUMMARY_AMEND_OPERATION_CODE, '?') <> 'DELETED'
            --AND    (nvl(nvl(kart.ref_article_id, kart.sav_sae_id), -1) not in (
            AND    (kart.orig_article_id NOT IN (
				SELECT distinct outcome.object_value_id
				FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome
				WHERE rultmp.doc_id = p_document_id
				AND rultmp.doc_type = p_document_type
				AND rultmp.condition_id IS NULL
				AND nvl(rultmp.result, '*' ) = 'Y'
				AND rul.rule_id = rultmp.rule_id
				AND rul.rule_type = 'CLAUSE_SELECTION'
				AND outcome.rule_id = rul.rule_id
				AND outcome.object_type = 'CLAUSE')
				);


  CURSOR csr_provision (p_article_version_id NUMBER) IS
  SELECT NVL(PROVISION_YN,'N')
  FROM   OKC_ARTICLE_VERSIONS VERS
  WHERE vers.article_version_id = p_article_version_id;


CURSOR l_get_max_article_csr(p_article_id NUMBER) IS
SELECT article_version_id
  FROM okc_article_versions
 WHERE  article_id= p_article_id
   AND  article_status in ('ON_HOLD','APPROVED')
   AND  start_date = (SELECT MAX(start_date)
                        FROM okc_article_versions
                       WHERE  article_id= p_article_id
                         AND  article_status in ('ON_HOLD','APPROVED')
				  );

  BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_document_id : '||p_document_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_document_type : '||p_document_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_rev_nbr : '||p_config_rev_nbr);

  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') <> 'Y' THEN --only if configurator is used
    IF (p_config_header_id IS NULL OR p_config_rev_nbr IS NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

    --
    -- Get New Article QA Code Severity and Name
    --
    get_qa_code_detail(p_document_type => p_document_type,
                       p_qa_code =>  G_CHECK_NEW_EXPERT_ART ,
                       x_perform_qa    => l_perf_new_expert_art,
                       x_qa_name       => l_new_expert_article_desc,
                       x_severity_flag => l_new_expert_article_sev,
                       x_return_status => x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;



    /*
    --
    -- Get New Article QA Code Severity and Name
    --
    OKC_TERMS_QA_PVT.get_qa_code_detail(p_qa_code =>  G_CHECK_NEW_EXPERT_ART ,
                       x_perform_qa    => l_perf_new_expert_art,
                       x_qa_name       => l_new_expert_article_desc,
                       x_severity_flag => l_new_expert_article_sev,
                       x_return_status => x_return_status);


    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    */

    --
    -- Get Old Article QA Code Severity and Name
    --
    get_qa_code_detail(p_document_type => p_document_type,
                       p_qa_code =>  G_CHECK_OLD_EXPERT_ART ,
                       x_perform_qa    => l_perf_old_expert_art,
                       x_qa_name       => l_old_expert_article_desc,
                       x_severity_flag => l_old_expert_article_sev,
                       x_return_status => x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;


/*    --
    -- Get Old Article QA Code Severity and Name
    --
    OKC_TERMS_QA_PVT.get_qa_code_detail(p_qa_code =>  G_CHECK_OLD_EXPERT_ART ,
                       x_perform_qa    => l_perf_old_expert_art,
                       x_qa_name       => l_old_expert_article_desc,
                       x_severity_flag => l_old_expert_article_sev,
                       x_return_status => x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

*/
    IF l_perf_old_expert_art <> 'Y' THEN
      l_old_expert_article_sev := 'W';
    END IF;

    IF l_perf_new_expert_art <> 'Y' THEN
      l_new_expert_article_sev := 'W';
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

  IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
    --
    -- Select Articles from rules engine
    --
    OPEN c_expert_articles_from_ruleng;
    FETCH c_expert_articles_from_ruleng BULK COLLECT INTO l_expert_articles_tbl;
    CLOSE c_expert_articles_from_ruleng;
  ELSE
    --
    -- Select Articles from configuration
    --
    OPEN l_get_expert_articles_from_cz;
    FETCH l_get_expert_articles_from_cz BULK COLLECT INTO l_expert_articles_tbl;
    CLOSE l_get_expert_articles_from_cz;
  END IF;

    --
    -- First Check if Provisions are allowed in the document.  If not, do not suggest
    -- them in QA.
    --
    OPEN  l_get_prov_csr;
    FETCH l_get_prov_csr INTO l_prov_allowed;
    CLOSE l_get_prov_csr;

    --
    -- Loop through the article ids table looking for
    -- articles that are in the latest configuration but
    -- not in the document.
    -- If SQL does not find the article, then the article id does not yet
    -- exist in the document.
    --
    l_article_id := NULL;

    FOR l_article_tbl_index IN 1..l_expert_articles_tbl.count LOOP

      OPEN l_article_in_doc(l_expert_articles_tbl(l_article_tbl_index));
      FETCH l_article_in_doc INTO l_article_id;

      IF (l_article_in_doc%NOTFOUND)
      THEN

             -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'Article id not in document : '||l_expert_articles_tbl(l_article_tbl_index));
		   END IF;

          --
          -- Get the article's latest version and name
          --
          l_article_version_id := NULL;
          l_article_name := NULL;

          --
          -- Article Version ID is null if there is no effective version of
          -- the article.  In this case, we do not want to suggest the article
          -- to the user, even if Contract Expert is returning the article in
          -- its configuration.
          --
		--
		-- Bug 4118467
		-- Report Expired clauses too in QA
		--

          l_article_version_id  :=
               OKC_TERMS_UTIL_PVT.Get_latest_art_version_id(
                                     l_expert_articles_tbl(l_article_tbl_index)
                                   , p_document_type
                                   , p_document_id );

		-- Bug 4118467
		-- Report Expired clauses too in QA
          --
		IF l_article_version_id IS NULL THEN
		   -- get the last expired Approved version
		   OPEN l_get_max_article_csr(p_article_id =>  l_expert_articles_tbl(l_article_tbl_index) );
		     FETCH l_get_max_article_csr INTO l_article_version_id ;
		   CLOSE l_get_max_article_csr;

		END IF; -- l_article_version_id

             -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               'l_article_version_id : '||l_article_version_id);
		   END IF;

          IF (l_article_version_id IS NOT NULL)
          THEN

            --
            -- Does this document type allow provisions?  If not, make sure that  this article
            -- is not a provision.
            --
            IF (UPPER(l_prov_allowed) <> 'Y')
            THEN
              --
              -- BV will not suggest Provisions,
              -- based on document type.  So check if this article
              -- version is a provision.
              --
                OPEN csr_provision (p_article_version_id  => l_article_version_id);
                  FETCH csr_provision INTO l_provision;
                CLOSE csr_provision;


            END IF; -- end l_prov_allowed <> Y


            --
            -- Insert this article in the QA messages if Provision is allowed or
            -- if provision is not allowed but the current article version is not a provision
            --
            IF (UPPER(l_prov_allowed) = 'Y' OR (UPPER(l_prov_allowed) <> 'Y' AND UPPER(l_provision) = 'N'))
            THEN

              l_article_name := OKC_TERMS_UTIL_PVT.get_article_name( l_expert_articles_tbl(l_article_tbl_index), l_article_version_id);
              l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;
              x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
              x_qa_result_tbl(l_qa_tbl_index).article_id          := l_expert_articles_tbl(l_article_tbl_index);
              x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
              x_qa_result_tbl(l_qa_tbl_index).title               := l_article_name;
              x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
              x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_NEW_EXPERT_ART;
              x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_NEW_EXPERT_ART;
              x_qa_result_tbl(l_qa_tbl_index).suggestion          :=
                             OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_NEW_EXPERT_ART_S);
              x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_new_expert_article_sev;
              x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_new_expert_article_desc;
              x_qa_result_tbl(l_qa_tbl_index).problem_details     :=
                             OKC_TERMS_UTIL_PVT.Get_Message('OKC',
                                                          G_OKC_NEW_EXPERT_ART_D,
                                                          'ARTICLE',
                                                          l_article_name);
            END IF; -- Provision allowed check

          END IF; -- l_article_version_id <> null

      ELSE -- %NOTFOUND

             -- debug log
		   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		               G_MODULE||l_api_name,
		               ' Article id is in the document: '||l_article_id);
		   END IF;

      END IF; -- %NOTFOUND
      CLOSE l_article_in_doc;

    END LOOP; -- end loop for articles in configuration

    --
    -- Loop through the expert articles in the doc
    -- looking for articles that are not in the new
    -- cz configuration.
    --
    l_article_id := NULL;

  IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
    OPEN l_articles_only_in_doc_ruleng(p_document_type,
                           p_document_id);

    --
    -- Get the article's latest version and name.  These
    -- are the articles in the doc that are NOT in the latest
    -- rules engine.  Suggest to delete.
    --

    FETCH  l_articles_only_in_doc_ruleng BULK COLLECT INTO   l_articles_not_in_cz_tbl;
    CLOSE l_articles_only_in_doc_ruleng;

  ELSE --configurator
    OPEN l_articles_only_in_doc(p_document_type,
                           p_document_id,
                           p_config_header_id,
                           p_config_rev_nbr);

    --
    -- Get the article's latest version and name.  These
    -- are the articles in the doc that are NOT in the latest
    -- CZ configuration.  Suggest to delete.
    --

    FETCH  l_articles_only_in_doc BULK COLLECT INTO   l_articles_not_in_cz_tbl;
    CLOSE l_articles_only_in_doc;
  END IF;

      IF (l_articles_not_in_cz_tbl.COUNT > 0) THEN

      FOR l_article_tbl_index IN 1..l_articles_not_in_cz_tbl.count LOOP

        l_article_id := l_articles_not_in_cz_tbl(l_article_tbl_index);

        l_article_version_id := NULL;
        l_article_name := NULL;
        l_article_version_id  := OKC_TERMS_UTIL_PVT.Get_latest_art_version_id( l_article_id
                                                                          , p_document_type
                                                                          , p_document_id );
        l_article_name := OKC_TERMS_UTIL_PVT.get_article_name( l_article_id
                                                          , l_article_version_id);

        l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

        x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
        x_qa_result_tbl(l_qa_tbl_index).article_id          := l_article_id;
        x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
        x_qa_result_tbl(l_qa_tbl_index).title               := l_article_name;
        x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
        x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_OLD_EXPERT_ART;
        x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_OLD_EXPERT_ART;
        x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_OLD_EXPERT_ART_S);
        x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_old_expert_article_sev;
        x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_old_expert_article_desc;
        x_qa_result_tbl(l_qa_tbl_index).problem_details     :=
                          OKC_TERMS_UTIL_PVT.Get_Message('OKC',    -- app name
                                                         G_OKC_OLD_EXPERT_ART_D, -- message name
                                                         'ARTICLE',            -- token 1
                                                         l_article_name);      -- token1 value


       END LOOP;
       END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
                IF l_articles_only_in_doc%ISOPEN
                THEN
                 CLOSE l_articles_only_in_doc;
                END IF;

                IF l_get_expert_articles_from_cz%ISOPEN
                THEN
                 CLOSE l_get_expert_articles_from_cz;
                END IF;

                IF l_get_prov_csr%ISOPEN
                THEN
                 CLOSE l_get_prov_csr;
                END IF;

                IF l_article_in_doc%ISOPEN
                THEN
                 CLOSE l_article_in_doc;
                END IF;

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                IF l_articles_only_in_doc%ISOPEN
                THEN
                 CLOSE l_articles_only_in_doc;
                END IF;
                IF l_get_expert_articles_from_cz%ISOPEN
                THEN
                 CLOSE l_get_expert_articles_from_cz;
                END IF;

                IF l_get_prov_csr%ISOPEN
                THEN
                 CLOSE l_get_prov_csr;
                END IF;

                IF l_article_in_doc%ISOPEN
                THEN
                 CLOSE l_article_in_doc;
                END IF;
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
                IF l_articles_only_in_doc%ISOPEN
                THEN
                 CLOSE l_articles_only_in_doc;
                END IF;
                IF l_get_expert_articles_from_cz%ISOPEN
                THEN
                 CLOSE l_get_expert_articles_from_cz;
                END IF;

                IF l_get_prov_csr%ISOPEN
                THEN
                 CLOSE l_get_prov_csr;
                END IF;

                IF l_article_in_doc%ISOPEN
                THEN
                 CLOSE l_article_in_doc;
                END IF;
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END process_qa_result;

/*====================================================================+
  Procedure Name : get_expert_articles
  Description    : Returns all articles for a configuration header id
                   and rev number.  This is called from the Batch Validation
                   process when BV is invoked for the Deviations report.

			    If the document does NOT support provisions then all expert
			    suggested provisions would be dropped

                   Note:  x_expert_articles_tbl could be NULL if the
                          configuration did not return any articles OR
					 if document type does NOT support provisions and
					 all expert suggested articles are provisions
+====================================================================*/
PROCEDURE get_expert_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    x_expert_articles_tbl          OUT NOCOPY expert_articles_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'get_expert_articles';
    l_prov_allowed  varchar2(1);
    l_provision  varchar2(1);
    l_expert_articles_tbl        expert_articles_tbl_type;
    j                           BINARY_INTEGER :=0;


    --
    -- Cursor to check provision allowed for doc type
    --
    CURSOR l_get_prov_csr IS
    SELECT NVL(PROVISION_ALLOWED_YN,'Y')
    FROM OKC_BUS_DOC_TYPES_B
    WHERE  DOCUMENT_TYPE=p_document_type;


    --
    -- Currsor to Select the Expert Articles
    -- that are in the latest Configuration
    --
    --

    CURSOR l_get_expert_articles_from_cz IS
    SELECT SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1)
      FROM cz_config_items_v
     WHERE  config_hdr_id = p_config_header_id
       AND  config_rev_nbr = p_config_rev_nbr
       AND  orig_sys_ref LIKE 'OKC:CLAUSEMODELOPTION:%' ;


    --
    -- Cursor to check if the article is a provision or clause
    --
    --
  CURSOR csr_art_provision (p_article_id NUMBER) IS
  SELECT NVL(PROVISION_YN,'N')
  FROM   OKC_ARTICLE_VERSIONS VERS
  WHERE vers.article_id = p_article_id;

      --cursors used for new OKC rules engine

	CURSOR c_all_expert_articles IS
	SELECT distinct outcome.object_value_id
	FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome
	WHERE rultmp.doc_id = p_document_id
	AND rultmp.doc_type = p_document_type
	AND rultmp.condition_id IS NULL
	AND nvl(rultmp.result, '*' ) = 'Y'
	AND rul.rule_id = rultmp.rule_id
	AND rul.rule_type = 'CLAUSE_SELECTION'
	AND outcome.rule_id = rul.rule_id
	AND outcome.object_type = 'CLAUSE';

	CURSOR c_expert_nonprovision_articles IS
	SELECT distinct outcome.object_value_id
	FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome, okc_article_versions ver
	WHERE rultmp.doc_id = p_document_id
	AND rultmp.doc_type = p_document_type
	AND rultmp.condition_id IS NULL
	AND nvl(rultmp.result, '*' ) = 'Y'
	AND rul.rule_id = rultmp.rule_id
	AND rul.rule_type = 'CLAUSE_SELECTION'
	AND outcome.rule_id = rul.rule_id
	AND outcome.object_type = 'CLAUSE'
	AND ver.article_id = outcome.object_value_id
	AND ver.article_version_number = outcome.object_version_number
	AND nvl(ver.provision_yn, '*') = 'N';


BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_rev_nbr : '||p_config_rev_nbr);

  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- This SQL is based on Drop 1 changes to
    -- cz_config_items_v, where CZ will
    -- add the orig_sys_ref column.
    --


    --
    -- If provisions are allowed on current document type then just return all
    -- the articles suggested by expert
    -- If provision is NOT allowed then process each article to check if it is provision an drop

    --
    -- First Check if Provisions are allowed in the document.  If not, do not suggest
    -- them in QA.
    --
    OPEN  l_get_prov_csr;
    FETCH l_get_prov_csr INTO l_prov_allowed;
    CLOSE l_get_prov_csr;

    -- Select articles from okc rules engine temp tables
    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN
		--select articles
		IF l_prov_allowed = 'Y' THEN
			OPEN c_all_expert_articles;
			FETCH c_all_expert_articles BULK COLLECT INTO x_expert_articles_tbl;
			CLOSE c_all_expert_articles;
		ELSE
			OPEN c_expert_nonprovision_articles;
			FETCH c_expert_nonprovision_articles BULK COLLECT INTO x_expert_articles_tbl;
			CLOSE c_expert_nonprovision_articles;
		END IF;

    ELSE --configurator

    IF (p_config_header_id IS NULL OR p_config_rev_nbr IS NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Select Articles from configuration

    IF l_prov_allowed = 'Y' THEN
        --
        -- Select Articles from configuration
        --
        OPEN l_get_expert_articles_from_cz;
        FETCH l_get_expert_articles_from_cz BULK COLLECT INTO x_expert_articles_tbl;
        CLOSE l_get_expert_articles_from_cz;

    ELSE
       -- Provision is Not allowed, check each article for provision flag
	  -- and drop provisons
        --
        -- Select Articles from configuration
        --
        OPEN l_get_expert_articles_from_cz;
        FETCH l_get_expert_articles_from_cz BULK COLLECT INTO l_expert_articles_tbl;
        CLOSE l_get_expert_articles_from_cz;


	   FOR i IN NVL(l_expert_articles_tbl.FIRST,0)..NVL(l_expert_articles_tbl.LAST,-1)
	   LOOP

	       OPEN csr_art_provision (p_article_id => l_expert_articles_tbl(i));
		    FETCH csr_art_provision INTO l_provision;
		  CLOSE csr_art_provision;


		  IF l_provision = 'N' THEN
		    j := j + 1;
		    x_expert_articles_tbl(j) := l_expert_articles_tbl(i);
		  END IF; -- not a provision
	   END LOOP;


    END IF;  -- l_prov_allowed = 'Y'

    END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END get_expert_articles;


/*========================================================================+
         Procedure:  contract_expert_bv
         Description:  This API is called from OKC_TERMS_QA_PVT
                       It is the main wrapper around the Batch Validation process,
                       executed from QA and from the Deviation Report processes.

+========================================================================*/

-- Removed old contract_expert_bv

/*====================================================================+
  Procedure Name : update_ce_config
  Description    : Update Expert Articles in Document.  This API
                   is called from the runtime Contract Expert page during
                   document authoring.  Specifically, it is called
                   when a user selects the 'Finish' button from Contract
                   Expert and the resulting configuration is valid and
                   complete.

			    -- Sanjay
			    Before updating the template usage record read the previous
			    config_header_id and config_rev_nbr and delete the same

  Parameters:
                   p_document_id - id of document id to be updated
                   p_document_type - type of document to be updated
                   p_config_header_id - configuration header id of resulting
                                   article configuration
                   p_config_rev_nbr - configuration number of resutling
                                   article configuration



+====================================================================*/
PROCEDURE update_ce_config(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_doc_update_mode              IN VARCHAR2,
    x_count_articles_dropped       OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_lock_xprt_yn            IN VARCHAR2 -- Conc Mod changes
   ,p_lock_terms_yn           IN VARCHAR2 -- Conc Mod changes
)

IS

    l_api_name CONSTANT VARCHAR2(30) := 'update_ce_config';
    l_api_version CONSTANT NUMBER := 1;

    l_expert_articles_tbl OKC_TERMS_MULTIREC_GRP.article_id_tbl_type;
    l_validation_string  VARCHAR2(100);

    l_old_config_header_id        okc_template_usages.config_header_id%TYPE;
    l_old_config_revision_number  okc_template_usages.config_revision_number%TYPE;

    l_src_document_type         okc_template_usages.orig_system_reference_code%TYPE;
    l_src_document_id           okc_template_usages.orig_system_reference_id1%TYPE;

    --
    -- Currsor to Select the Expert Articles
    -- that are in the latest Configuration
    --
    --

    CURSOR l_get_expert_articles_from_cz IS
    SELECT SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1)
      FROM cz_config_items_v
     WHERE  config_hdr_id = p_config_header_id
       AND  config_rev_nbr = p_config_rev_nbr
       AND  orig_sys_ref LIKE 'OKC:CLAUSEMODELOPTION:%' ;

  --
  -- Cursor to read the previous config_header_id and config_rev_nbr and delete the same
  --
  CURSOR csr_old_config_dtls IS
  SELECT config_header_id,
         config_revision_number
         , orig_system_reference_code
         , orig_system_reference_id1
    FROM okc_template_usages
   WHERE document_type  = p_document_type
     AND document_id    = p_document_id ;

  BEGIN


    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    IF (p_config_header_id is NULL OR p_config_rev_nbr is NULL OR
        p_document_id is NULL OR p_document_type is NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Read the previous configuration to be deleted
    OPEN csr_old_config_dtls;
      FETCH csr_old_config_dtls INTO l_old_config_header_id,l_old_config_revision_number,l_src_document_type,l_src_document_id;
    CLOSE csr_old_config_dtls;


    IF    p_lock_xprt_yn = 'Y'
    THEN
           IF   l_src_document_type IS NOT NULL AND l_src_document_id IS NOT NULL
            THEN
                 -- Lock base table.
                  okc_k_entity_locks_grp.lock_entity
                              ( p_api_version     => 1,
                              p_init_msg_list    => FND_API.G_FALSE ,
                              p_commit           => FND_API.G_FALSE,
                              p_entity_name      => okc_k_entity_locks_grp.G_XPRT_ENTITY,
                              p_entity_pk1       =>  To_Char(l_src_document_id),
                              p_entity_pk2       =>  To_Char(l_src_document_type),
                              p_LOCK_BY_DOCUMENT_TYPE => p_document_type,
                              p_LOCK_BY_DOCUMENT_ID => p_document_id,
                              X_RETURN_STATUS => X_RETURN_STATUS,
                              X_MSG_COUNT => X_MSG_COUNT,
                              X_MSG_DATA => X_MSG_DATA
                              );
                --------------------------------------------
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
                END IF;
              --------------------------------------------
            ELSE
              NULL;
              -- throw error;
          END IF;
    END IF; -- p_create_lock_for_xprt = 'Y'


    --
    -- Get Expert Articles from Configurator
    --
	  OPEN l_get_expert_articles_from_cz;
	     FETCH l_get_expert_articles_from_cz BULK COLLECT INTO l_expert_articles_tbl;
	  CLOSE l_get_expert_articles_from_cz;

    --
    -- Call API to Update Document with new Expert configuration
    --
    OKC_TERMS_MULTIREC_GRP.sync_doc_with_expert(
                   p_api_version => 1,
                   p_init_msg_list => FND_API.G_FALSE,
                   p_validate_commit => FND_API.G_FALSE,
                   p_validation_string => l_validation_string,
                   p_commit => FND_API.G_FALSE,
                   p_doc_type => p_document_type,
                   p_doc_id => p_document_id,
                   p_article_id_tbl => l_expert_articles_tbl,
                   p_mode => p_doc_update_mode, -- Defaults to 'NORMAL'
                   x_articles_dropped => x_count_articles_dropped,
                   x_return_status => x_return_status,
                   x_msg_count => x_msg_count,
                   x_msg_data => x_msg_data
                   ,p_lock_terms_yn => p_lock_terms_yn);


    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --
    -- Update the template usage with new config_header_id and config_rev_nbr
    --
    UPDATE okc_template_usages
       SET config_header_id = p_config_header_id,
	      config_revision_number = p_config_rev_nbr,
		 valid_config_yn = 'Y',
           last_update_date = SYSDATE,
		 last_updated_by= FND_GLOBAL.USER_ID,
		 last_update_login= FND_GLOBAL.LOGIN_ID
    WHERE document_type  = p_document_type
      AND document_id    = p_document_id ;

    /*
    OKC_TEMPLATE_USAGES_GRP.update_template_usages(
        p_api_version            => 1,
        p_init_msg_list          => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        p_commit                 => FND_API.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_document_type          => p_document_type,
        p_document_id            => p_document_id,
        p_template_id            => NULL,
        p_doc_numbering_scheme   => NULL,
        p_document_number        => NULL,
        p_article_effective_date => NULL,
        p_config_header_id       => p_config_header_id,
        p_config_revision_number => p_config_rev_nbr,
        p_valid_config_yn        => 'Y',      -- check
        p_object_version_number  => 1
    );


    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    */

    --
    -- Delete the previous configuration
    --
    --
    IF (l_old_config_header_id IS NOT NULL AND
        l_old_config_revision_number IS NOT NULL ) THEN

                  OKC_XPRT_CZ_INT_PVT.delete_configuration(
                       p_api_version          => 1.0,
                       p_init_msg_list        => FND_API.G_FALSE,
                       p_config_header_id     => l_old_config_header_id,
                       p_config_rev_nbr       => l_old_config_revision_number,
                       x_return_status        => x_return_status,
                       x_msg_data             => x_msg_data,
                       x_msg_count            => x_msg_count);

    END IF; -- delete the old configuration

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --
    -- Display appropriate message on page depending on whether articles where inserted
    -- into document or not.  In this release, we only distinguish between inserting articles
    -- and not inserting articles.  We do not explicitly inform user if articles are deleted.
    --
    /*
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* Fix for bug# 4071469.
	* If l_expert_articles_tbl.COUNT = 0 we return 'OKC_EXPRT_NO_ARTICLES' message
	* If l_expert_articles_tbl.COUNT > 0 and = x_count_articles_dropped,
	*    we return 'OKC_EXPRT_ALL_PROVISIONS' message
	* The rest of the original logic is unchanged.
    */

    IF (l_expert_articles_tbl.COUNT = 0)
    THEN
	 x_msg_data := 'OKC_EXPRT_NO_ARTICLES';

    ELSIF (l_expert_articles_tbl.COUNT = x_count_articles_dropped)
    THEN
      x_msg_data := 'OKC_EXPRT_ALL_PROVISIONS';

    ELSIF x_count_articles_dropped > 0
    THEN

      x_msg_data := 'OKC_EXPRT_UPDATED_WITH_PROVS';

    ELSE

      x_msg_data := 'OKC_EXPRT_ARTICLES_UPDATED';

    END IF;

EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN

   		x_return_status := FND_API.G_RET_STS_ERROR ;
   		FND_MSG_PUB.Count_And_Get(
   		        p_count => x_msg_count,
           		p_data => x_msg_data
   		);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   		x_return_status := FND_API.G_RET_STS_ERROR ;
   		FND_MSG_PUB.Count_And_Get(
   		        p_count => x_msg_count,
           		p_data => x_msg_data
   		);

       WHEN OTHERS THEN
   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     		IF FND_MSG_PUB.Check_Msg_Level
   		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   		THEN
       	    	FND_MSG_PUB.Add_Exc_Msg(
       	    	     G_PKG_NAME  	    ,
       	    	     l_api_name
   	    	      );
   		END IF;

   		FND_MSG_PUB.Count_And_Get(
   		     p_count => x_msg_count,
           	     p_data => x_msg_data
   		);


END update_ce_config;


/*====================================================================+
  Procedure Name : update_config_id_rev_nbr
  Description    : Update Configuration ID and Rev Number for document.
                   This API is called from the runtime Contract Expert page during
                   document authoring.  Specifically, it is called
                   when a user selects the 'Save' button from Contract
                   Expert.

			    -- Sanjay
			    Before updating the template usage record read the previous
			    config_header_id and config_rev_nbr and delete the same


  Parameters:
                   p_document_id - id of document id to be updated
                   p_document_type - type of document to be updated
                   p_template_id - id of template applied to document to be
                                   updated
                   p_config_header_id - configuration header id of resulting
                                   article configuration
                   p_config_rev_nbr - configuration number of resutling
                                   article configuration


+====================================================================*/
PROCEDURE update_config_id_rev_nbr(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_template_id                  IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_lock_xprt_yn         IN VARCHAR2)

IS
    l_api_name CONSTANT VARCHAR2(30) := 'update_config_id_rev_nbr';
    l_api_version CONSTANT NUMBER := 1;

    l_old_config_header_id        okc_template_usages.config_header_id%TYPE;
    l_old_config_revision_number  okc_template_usages.config_revision_number%TYPE;

    l_document_type  okc_template_usages.orig_system_reference_code%TYPE;
    l_document_id    okc_template_usages.orig_system_reference_id1%TYPE;

  --
  -- Cursor to read the previous config_header_id and config_rev_nbr and delete the same
  --
  CURSOR csr_old_config_dtls IS
  SELECT config_header_id,
         config_revision_number
         ,orig_system_reference_code
         ,orig_system_reference_id1
    FROM okc_template_usages
   WHERE document_type  = p_document_type
     AND document_id    = p_document_id ;


BEGIN

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    IF (p_config_header_id is NULL OR p_config_rev_nbr is NULL OR
        p_document_id is NULL OR p_document_type is NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Read the previous configuration to be deleted
    OPEN csr_old_config_dtls;
      FETCH csr_old_config_dtls INTO l_old_config_header_id,l_old_config_revision_number,l_document_type,l_document_id;
    CLOSE csr_old_config_dtls;



    IF    p_lock_xprt_yn = 'Y'
    THEN

            IF   l_document_type IS NOT NULL
                AND l_document_id IS NOT NULL

            THEN
                  -- Implement Lock
                  okc_k_entity_locks_grp.lock_entity
                              ( p_api_version     => 1,
                              p_init_msg_list    => FND_API.G_FALSE ,
                              p_commit           => FND_API.G_FALSE,
                              p_entity_name      => okc_k_entity_locks_grp.G_XPRT_ENTITY,
                              p_entity_pk1       =>  To_Char(l_document_id),
                              p_entity_pk2       => To_Char(l_document_type),
                              p_LOCK_BY_DOCUMENT_TYPE => p_document_type,
                              p_LOCK_BY_DOCUMENT_ID => p_document_id,
                              X_RETURN_STATUS => X_RETURN_STATUS,
                              X_MSG_COUNT => X_MSG_COUNT,
                              X_MSG_DATA => X_MSG_DATA
                              );
                --------------------------------------------
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
                END IF;
              --------------------------------------------
            ELSE
              NULL;
              -- throw error;
          END IF;
    END IF; -- p_create_lock_for_xprt = 'Y'

    --
    -- Update the template usage with new config_header_id and config_rev_nbr
    --
    UPDATE okc_template_usages
       SET config_header_id = p_config_header_id,
	      config_revision_number = p_config_rev_nbr,
		 valid_config_yn = 'Y',
           last_update_date = SYSDATE,
		 last_updated_by= FND_GLOBAL.USER_ID,
		 last_update_login= FND_GLOBAL.LOGIN_ID
    WHERE document_type  = p_document_type
      AND document_id    = p_document_id ;

/*
    OKC_TEMPLATE_USAGES_GRP.update_template_usages(
        p_api_version            => 1,
        p_init_msg_list          => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        p_commit                 => FND_API.G_FALSE,
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        p_document_type          => p_document_type,
        p_document_id            => p_document_id,
        p_template_id            => p_template_id,
        p_doc_numbering_scheme   => NULL,
        p_document_number        => NULL,
        p_article_effective_date => NULL,
        p_config_header_id       => p_config_header_id,
        p_config_revision_number => p_config_rev_nbr,
        p_valid_config_yn        => 'Y',      -- check
        p_object_version_number  => 1
    );


    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

 */

    --
    -- Delete the previous configuration
    --
    --
    IF (l_old_config_header_id IS NOT NULL AND
        l_old_config_revision_number IS NOT NULL ) THEN

                  OKC_XPRT_CZ_INT_PVT.delete_configuration(
                       p_api_version          => 1.0,
                       p_init_msg_list        => FND_API.G_FALSE,
                       p_config_header_id     => l_old_config_header_id,
                       p_config_rev_nbr       => l_old_config_revision_number,
                       x_return_status        => x_return_status,
                       x_msg_data             => x_msg_data,
                       x_msg_count            => x_msg_count);

    END IF; -- delete the old configuration

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN

   		x_return_status := FND_API.G_RET_STS_ERROR ;
   		FND_MSG_PUB.Count_And_Get(
   		        p_count => x_msg_count,
           		p_data => x_msg_data
   		);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   		x_return_status := FND_API.G_RET_STS_ERROR ;
   		FND_MSG_PUB.Count_And_Get(
   		        p_count => x_msg_count,
           		p_data => x_msg_data
   		);

       WHEN OTHERS THEN
   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     		IF FND_MSG_PUB.Check_Msg_Level
   		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   		THEN
       	    	FND_MSG_PUB.Add_Exc_Msg(
       	    	     G_PKG_NAME  	    ,
       	    	     l_api_name
   	    	      );
   		END IF;

   		FND_MSG_PUB.Count_And_Get(
   		     p_count => x_msg_count,
           	     p_data => x_msg_data
   		);
END update_config_id_rev_nbr;

/*====================================================================+
  Procedure Name : get_article_details
  Description    : If the given article_id exists in the
                   given document and if so, fetches its article_version_id
                   else this procedure fetches the latest article_version_id
                   from article library for the given article_id

+====================================================================*/
PROCEDURE get_article_details(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2,
    p_document_id      IN NUMBER,
    p_document_type    IN VARCHAR2,
    p_article_id       IN NUMBER,
    p_effectivity_date IN DATE,
    x_article_id       OUT NOCOPY NUMBER,
    x_article_version_id OUT NOCOPY NUMBER,
    x_doc_lib           OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2)
IS
     l_article_id NUMBER;
     l_article_version_id NUMBER;
     l_doc_lib            VARCHAR2(1);
     l_api_version      CONSTANT NUMBER := 1;
     l_api_name         CONSTANT VARCHAR2(30) := 'get_article_details';

CURSOR get_doc_article_ver_id(p_doc_id NUMBER,p_doc_type VARCHAR2,p_article_id NUMBER) IS
        select id, article_version_id, 'D' from okc_k_articles_b
        where document_id = p_doc_id
            and document_type = p_doc_type
            and ((sav_sae_id = p_article_id) or (ref_article_id = p_article_id))
            and source_flag = 'R'
            and rownum < 2;

CURSOR l_approved_ver_csr(p_article_id NUMBER, effective_date DATE) IS
          SELECT ver.article_id, ver.article_version_id, 'L'
             FROM okc_articles_all art,
               okc_article_versions ver
             WHERE art.article_id = p_article_id
                AND art.article_id = ver.article_id
                AND ver.article_status IN  ('APPROVED','ON_HOLD')
                AND nvl(effective_date,trunc(SYSDATE)) BETWEEN ver.start_date AND NVL(ver.end_date,TRUNC(SYSDATE));

-- bug 4106513
CURSOR l_approved_latest_ver_csr(p_article_id NUMBER ) IS
        SELECT ver.article_id, ver.article_version_id, 'L'
            FROM okc_article_versions ver
            WHERE ver.article_id = p_article_id
              AND ver.article_status IN ('APPROVED','ON_HOLD')
              AND ver.start_date = (SELECT max(start_date)
                            FROM okc_article_versions ver1
                            WHERE ver1.article_id = p_article_id
                            AND ver1.article_status IN ('APPROVED','ON_HOLD'));

BEGIN

	   l_doc_lib := 'D';

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
          x_return_status := G_RET_STS_SUCCESS;

		Open  get_doc_article_ver_id(p_document_id, p_document_type, p_article_id);
		fetch get_doc_article_ver_id into l_article_id, l_article_version_id, l_doc_lib;
        IF get_doc_article_ver_id%NOTFOUND  THEN
--          l_article_id := p_article_id;
--          l_article_version_id := OKC_TERMS_UTIL_PVT.Get_latest_tmpl_art_version_id(p_article_id, p_effectivity_date);
--          l_doc_lib := 'L';
		      Open  l_approved_ver_csr(p_article_id, p_effectivity_date);
		      fetch l_approved_ver_csr into l_article_id, l_article_version_id, l_doc_lib;
              if l_approved_ver_csr%NOTFOUND  THEN
    		      Open  l_approved_latest_ver_csr(p_article_id);
	   	          fetch l_approved_latest_ver_csr into l_article_id, l_article_version_id, l_doc_lib;
                  close l_approved_latest_ver_csr;
              end if;
              close l_approved_ver_csr;
        END if;
		close get_doc_article_ver_id;
        x_article_id := l_article_id;
        x_article_version_id := l_article_version_id;
        x_doc_lib := l_doc_lib;
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN
      IF get_doc_article_ver_id%ISOPEN THEN
        CLOSE get_doc_article_ver_id;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_article_details;

-------------------------FUNCTIONS USED IN RULES PAGES-----------------------------------------------------

/*====================================================================+
  Function Name : check_clause_exists
  Description    : Returns 'Y' if a clause exists in arule, otherwise returns 'N'
                   Used in Rules Summary Page
  Parameters     : p_rule_id : Rule Id
                   p_clause_id : Clause Id
+====================================================================*/

FUNCTION check_clause_exists (
    p_rule_id   IN NUMBER,
    p_clause_id IN NUMBER)
RETURN VARCHAR2 IS

CURSOR csr_cond_clause_exists IS
SELECT 'X'
FROM okc_xprt_rule_conditions c,
     okc_xprt_rule_cond_vals cv
WHERE c.rule_condition_id = cv.rule_condition_id
AND c.object_value_type = 'CLAUSE'
AND cv.object_value_code = p_clause_id
AND c.rule_id = p_rule_id ;

CURSOR csr_out_clause_exits IS
SELECT 'X'
FROM okc_xprt_rule_outcomes o
WHERE o.rule_id = p_rule_id
AND o.object_type = 'CLAUSE'
AND o.object_value_id = p_clause_id ;

l_dummy  VARCHAR2(1);
l_return VARCHAR2(1);

BEGIN
--check if clause exists as a condition value (RHS)
   OPEN csr_cond_clause_exists;
     FETCH csr_cond_clause_exists INTO l_dummy;
       IF csr_cond_clause_exists%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE csr_cond_clause_exists;

    IF l_return = 'Y' THEN
      RETURN l_return;
    END IF;

--check if clause exists as an outcome

   OPEN csr_out_clause_exits;
     FETCH csr_out_clause_exits INTO l_dummy;
       IF csr_out_clause_exits%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE csr_out_clause_exits;

    RETURN l_return;

EXCEPTION
 WHEN OTHERS THEN
 --close cursors
 IF csr_cond_clause_exists%ISOPEN THEN
   CLOSE csr_cond_clause_exists;
 END IF;

 IF csr_out_clause_exits%ISOPEN THEN
   CLOSE csr_out_clause_exits;
 END IF;

 RETURN NULL;
END check_clause_exists;

/*====================================================================+
  Function Name : check_variable_exists
  Description    : Returns 'Y' if a variable is used in a rule, otherwise returns 'N'
                   Used in Rules Summary Page
    Parameters     : p_rule_id : Rule Id
                     p_variable_code : variable_code
+====================================================================*/

FUNCTION check_variable_exists (
    p_rule_id            IN NUMBER,
    p_variable_code      IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR csr_variable_val_exists IS
SELECT 'X'
FROM okc_xprt_rule_conditions c,
     okc_xprt_rule_cond_vals cv
WHERE c.rule_condition_id = cv.rule_condition_id
  AND c.object_value_type = 'VARIABLE'
  AND cv.object_value_code = p_variable_code
  AND c.rule_id = p_rule_id ;

CURSOR csr_variable_cond_exists IS
SELECT 'X'
FROM okc_xprt_rule_conditions c
WHERE  c.object_type = 'VARIABLE'
  AND  c.object_code = p_variable_code
  AND  c.rule_id = p_rule_id ;

l_dummy  VARCHAR2(1);
l_return VARCHAR2(1);

BEGIN
--check if variable exists in condition value (RHS)
   OPEN csr_variable_val_exists;
     FETCH csr_variable_val_exists INTO l_dummy;
       IF csr_variable_val_exists%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE csr_variable_val_exists;
   IF l_return = 'Y' THEN
      RETURN l_return;
    END IF;
--check if variable exists in condition  (LHS)
   OPEN csr_variable_cond_exists;
     FETCH csr_variable_cond_exists INTO l_dummy;
       IF csr_variable_cond_exists%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE csr_variable_cond_exists;

   RETURN l_return;


EXCEPTION

 WHEN OTHERS THEN
 --close cursors
 IF csr_variable_cond_exists%ISOPEN THEN
   CLOSE csr_variable_cond_exists;
 END IF;

 IF csr_variable_val_exists%ISOPEN THEN
   CLOSE csr_variable_val_exists;
 END IF;

 RETURN NULL;
END check_variable_exists;

/*====================================================================+
  Function Name : check_question_exists
  Description    : Returns 'Y' if a question is used in a rule, otherwise returns 'N'
                   Used in Rules Summary Page
+====================================================================*/

FUNCTION check_question_exists (
    p_rule_id            IN NUMBER,
    p_question_id        IN NUMBER)
RETURN VARCHAR2 IS
 CURSOR question_exists IS
  SELECT  'x'
  FROM okc_xprt_rule_cond_vals cvals,
       okc_xprt_rule_conditions cond
  WHERE cond.rule_id = p_rule_id
  AND cond.rule_condition_id=cvals.rule_condition_id
  AND cond.object_value_type ='QUESTION'
  AND cvals.object_value_code=p_question_id
  UNION ALL
  SELECT 'x'
  FROM  okc_xprt_rule_conditions cond
  WHERE cond.rule_id = p_rule_id
  AND  cond.object_type ='QUESTION'
  AND cond.object_code=to_char(p_question_id)
  UNION ALL
  SELECT 'x'
  FROM okc_xprt_rule_outcomes xro
  WHERE xro.rule_id =p_rule_id
  AND xro.object_type='QUESTION'
  AND xro.object_value_id=p_question_id;

 l_dummy VARCHAR2(1);
  l_return VARCHAR2(1);

BEGIN
--check if question is used  in condition value (LHS/RHS) or as an outcome
 OPEN question_exists;
     FETCH question_exists INTO l_dummy;
       IF question_exists%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE question_exists;

  RETURN l_return;
EXCEPTION

 WHEN OTHERS THEN
 --close cursors
 IF question_exists%ISOPEN THEN
   CLOSE question_exists;
 END IF;
 RETURN 'N';
END check_question_exists;

/*====================================================================+
  Function Name : check_template_exists
  Description    : Returns 'Y' if a rule applies to a template
                   Used in Rules Summary Page
  Parameters     : p_rule_id  : Rule Id
                   p_template_id :  Template Id
+====================================================================*/

 FUNCTION check_template_exists (
    p_rule_id            IN NUMBER,
    p_template_id        IN NUMBER)
RETURN VARCHAR2 IS

   CURSOR all_rules IS

   -- org wide rules applicable to given template
   SELECT 'x'
    FROM okc_xprt_rule_hdrs_all rule
    WHERE rule.rule_id = p_rule_id
    AND rule.org_wide_flag = 'Y'
    AND (rule.intent, rule.org_id)  in (select intent, org_id from okc_terms_templates_all where template_id = p_template_id)

    UNION ALL

    --template specific rules
    SELECT 'x'
    FROM okc_xprt_rule_hdrs_all xrh,
         okc_xprt_template_rules xtr
    WHERE xrh.rule_id = xtr.rule_id
    AND xrh.rule_id = p_rule_id
    AND template_id=p_template_id;

  l_dummy VARCHAR2(1);
  l_return VARCHAR2(1);

BEGIN
--check if rule applies to the template specifically or thorugh Org wide rules
 OPEN all_rules;
     FETCH all_rules INTO l_dummy;
       IF all_rules%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE all_rules;

  RETURN l_return;
EXCEPTION

 WHEN OTHERS THEN
 --close cursors
 IF all_rules%ISOPEN THEN
   CLOSE all_rules;
 END IF;
 RETURN NULL;
 END check_template_exists;

/*====================================================================+
  Function Name : check_orgwide_rule_exists
  Description    : Returns 'Y' if an org wide rule exists in the user's org, Otherwise returns 'N'
                   Used to determine the templates to display in the Assigned to Templates LOV
+====================================================================*/

 FUNCTION check_orgwide_rule_exists
  RETURN VARCHAR2

  IS
 CURSOR c1 is
      select 'x'
      from okc_xprt_rule_hdrs_all
      where org_wide_flag='Y';
      --Bug#4779070 commented below condition
      /*and NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
         SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
         SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);*/

  l_dummy VARCHAR2(1);
  l_return VARCHAR2(1);

BEGIN

 OPEN c1;
     FETCH c1 INTO l_dummy;
       IF c1%NOTFOUND THEN
         l_return := 'N';
       ELSE
         l_return := 'Y';
       END IF;
   CLOSE c1;

  RETURN l_return;

EXCEPTION

 WHEN OTHERS THEN
 --close cursors
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;
 RETURN NULL;
END  check_orgwide_rule_exists;

/*====================================================================+
  Function Name : get_object_name
  Description    : Returns the condition name given the object type and object_code
                   Used to display condition name in rules update/view mode
+====================================================================*/

FUNCTION get_object_name (
    p_object_name      IN VARCHAR2,
    p_object_code      IN VARCHAR2)
RETURN VARCHAR2 IS
CURSOR c1 IS
    SELECT variable_name
    FROM okc_bus_variables_v
    WHERE variable_code=p_object_code;

CURSOR c2 IS
    SELECT question_name
    FROM okc_xprt_questions_vl
    WHERE question_id=TO_NUMBER(p_object_code)
    AND question_type='Q';
c1rec c1%ROWTYPE;
c2rec c2%ROWTYPE;
l_name VARCHAR2(150);

BEGIN
 IF p_object_name ='VARIABLE'  THEN

    OPEN c1;
    FETCH c1  INTO c1rec;
    CLOSE c1;
    l_name:=c1rec.variable_name;

 ELSIF p_object_name ='QUESTION'  THEN
    OPEN c2;
    FETCH c2  INTO c2rec;
    CLOSE c2;
    l_name:=c2rec.question_name;
  END IF;
 RETURN l_name;

EXCEPTION

 WHEN OTHERS THEN
 --close cursors
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;

  --close cursors
 IF c2%ISOPEN THEN
   CLOSE c2;
 END IF;

 RETURN NULL;

END get_object_name;

/*====================================================================+
  Function Name : get_value_display
  Description    : Returns the condition value display name
                   Used to display condition value in condition table
                   in rules update/view mode
+====================================================================*/

FUNCTION get_value_display (
    p_object_value_type      IN VARCHAR2,
    p_object_value_code      IN VARCHAR2,
    p_object_value_set_id    IN NUMBER,
    p_validation_type        IN VARCHAR2,
    p_longlist_flag          IN VARCHAR2,
    p_mode                   IN VARCHAR2 )

RETURN VARCHAR2 IS
CURSOR c1 IS
    SELECT article_title
    FROM okc_articles_all
    WHERE article_id=to_number(p_object_value_code);

CURSOR C2 IS
    SELECT question_name
    FROM okc_xprt_questions_vl
    WHERE question_id=TO_NUMBER(p_object_value_code)
    AND question_type= decode(p_object_value_type,'CONSTANT','C','Q');

 CURSOR c3 IS
    SELECT variable_name
    FROM okc_bus_variables_v
    WHERE variable_code=p_object_value_code;


/*CURSOR c2 IS
    select value.flex_value
    --,value.description
    from fnd_flex_values_vl value
where value.FLEX_VALUE_SET_ID =  p_object_value_set_id
and enabled_flag='Y'
and trunc(sysdate) between nvl(trunc(start_date_active),trunc(sysdate)) and nvl(trunc(end_date_active),trunc(sysdate))
*/

l_value  VARCHAR2(1000) := null;

BEGIN
 --This means that the value is from a poplist and display will be taken care of by the poplist
 IF p_validation_type = 'I' and p_longlist_flag = 'X' and p_mode is null THEN
   return null;
 END IF;

-- If object_type is clause, then get clause name
 If p_object_value_type = 'CLAUSE' THEN
    OPEN c1;
    FETCH c1  INTO l_value;
    CLOSE c1;

-- If object type is constant or question
 Elsif (p_object_value_type = 'CONSTANT' OR p_object_value_type ='QUESTION') THEN
    OPEN c2;
    FETCH c2  INTO l_value;
    CLOSE c2;

-- If opbject type is an expert variable
 Elsif (p_object_value_type = 'VARIABLE')  THEN

    OPEN c3;
    FETCH c3  INTO l_value;
    CLOSE c3;

 ELSIF (p_object_value_type='VALUE') AND (p_object_value_set_id is not null) THEN
    l_value := get_valueset_value ( p_object_value_set_id, p_object_value_code,    p_validation_type );
 END IF;

 RETURN NVL(l_value,NULL);

EXCEPTION
WHEN OTHERS THEN
  --close cursors
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;

 IF c2%ISOPEN THEN
   CLOSE c2;
 END IF;

 IF c3%ISOPEN THEN
   CLOSE c3;
 END IF;
 RETURN NULL;

END get_value_display;

/*====================================================================+
  Function Name : get_concat_condition_values
  Description   : Returns all the condition values as a comma separated
                  string for a given RuleCondition Id
		  Added as a part of Policy Deviations Project
+====================================================================*/

FUNCTION get_concat_condition_values (
           p_rule_condition_id      IN NUMBER)
RETURN VARCHAR2 IS

CURSOR csr_condition_values IS
 SELECT Object_Value_Code
 FROM OKC_XPRT_RULE_COND_VALS
 WHERE rule_condition_id = p_rule_condition_id;

l_concat_values  VARCHAR2(1000) := null;
l_value varchar2(1000) := null;
rec_condition_values csr_condition_values%rowtype;
BEGIN
     FOR rec_condition_values IN csr_condition_values
     LOOP
	 l_value := get_value_display(p_rule_condition_id,
					rec_condition_values.Object_Value_Code);
	IF ((length(l_concat_values)+length (l_value ))> 50 ) THEN
	     l_concat_values := substr(l_concat_values,0,(length(l_concat_values)));
	      --add '....' at the end
	    l_concat_values := l_concat_values ||'......';
	    exit;
       END IF;
       IF l_concat_values IS null THEN
	    l_concat_values := l_value;
       ELSE
	    l_concat_values := l_concat_values || ', ' || l_value;
       END IF;
   END LOOP;

RETURN l_concat_values;

EXCEPTION
WHEN OTHERS THEN
  IF csr_condition_values%ISOPEN THEN
	     CLOSE csr_condition_values;
  END IF;
RETURN NULL;
END get_concat_condition_values;

/*====================================================================+
  Bug 4728299 Added for Policy Deviations Project
  Function Name : get_concat_document_value
  Description   : Returns concatinated document value.
                  Used to concatinate Item or Item Category Variables
        		Used at View Policy Deviation Details Page to show document value
+====================================================================*/
FUNCTION get_concat_document_value (
     p_object_code      IN VARCHAR2,
     p_sequence_id      IN VARCHAR2)
RETURN VARCHAR2 is

CURSOR csr_variable_value IS
 SELECT variable_value
 FROM OKC_XPRT_DEVIATIONS_T
 WHERE variable_code = p_object_code
 AND run_id = p_sequence_id
 AND variable_value is not null;

CURSOR csr_translated_value(p_variable_id VARCHAR2, p_variable_value VARCHAR2) IS
 SELECT localized_str translated_value
 FROM cz_localized_texts
 WHERE orig_sys_ref LIKE 'OKC:VARIABLEMODELOPTION:-99:%:' || p_variable_id || ':' || p_variable_value
 AND LANGUAGE = USERENV('LANG');


l_api_name  CONSTANT VARCHAR2(30) := 'get_concat_document_value';
l_final_document_value varchar2(1000) := null;
l_variable_value varchar2(1000) := null;
l_variable_translated_value varchar2(1000) := null;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '960: Entered '||G_PKG_NAME ||'.'||l_api_name);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '960: Parameters passed: -----------------------');
     Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '960:Object Type = '||p_object_code);
     Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '960:sequence id = '||p_sequence_id  );
  END IF;
  FOR rec_variable_value in csr_variable_value
  LOOP
     l_variable_value := rec_variable_value.variable_value;
     l_variable_translated_value := null;
     OPEN  csr_translated_value(p_object_code, l_variable_value);
     FETCH csr_translated_value INTO l_variable_translated_value;
     CLOSE csr_translated_value;
     IF(l_variable_translated_value is not null) THEN
       IF l_final_document_value IS null THEN
	     l_final_document_value := l_variable_translated_value;
       ELSE
         l_final_document_value := l_final_document_value || ','||l_variable_translated_value;
       END IF;
     ELSE
       IF l_final_document_value IS null THEN
	     l_final_document_value := l_variable_value;
       ELSE
         l_final_document_value := l_final_document_value || ','||l_variable_value;
       END IF;
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '961: l_variable_value = ' || l_variable_value);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '961: l_variable_translated_value = ' || l_variable_translated_value);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '961: l_final_document_value = ' || l_final_document_value);
     END IF;
  END LOOP;
  RETURN l_final_document_value;
EXCEPTION
  WHEN OTHERS THEN
  IF csr_variable_value%ISOPEN THEN
	     CLOSE csr_variable_value;
  END IF;
  IF csr_translated_value%ISOPEN THEN
	     CLOSE csr_translated_value;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '990: Leaving From Exception Block'||G_PKG_NAME ||'.'||l_api_name);
  END IF;
  RETURN null;
END get_concat_document_value;


-- Bug 4728299 Added for Policy Deviations Project
/*====================================================================+
  Function Name : get_deviation_document_value
  Description   : Returns document value for a given condition.
                  Added as a part of Policy Deviations Project.Used at
		  View Policy Deviation Details Page to show document value
+====================================================================*/
FUNCTION get_deviation_document_value (
     p_rule_id          IN NUMBER,
     p_object_type      IN VARCHAR2,
     p_object_code      IN VARCHAR2,
     p_sequence_id      IN VARCHAR2,
     p_value_set_id     IN NUMBER,
     p_object_value_type IN VARCHAR2,
     p_object_value_code IN VARCHAR2,
     p_line_number      IN VARCHAR2)
RETURN VARCHAR2 is

CURSOR csr_config_data IS
 SELECT config_header_id,config_revision_number
 FROM OKC_TERMS_DEVIATIONS_T
 WHERE sequence_id = p_sequence_id
 AND rownum < 2;

CURSOR csr_variable_value(l_object_code VARCHAR2) IS
 SELECT variable_value
 FROM OKC_XPRT_DEVIATIONS_T
 WHERE variable_code = l_object_code
 AND (line_number = p_line_number or line_number = '-99')
 AND run_id = p_sequence_id
 AND variable_value is not null;

CURSOR csr_translated_value(p_variable_id VARCHAR2, p_variable_value VARCHAR2) IS
 SELECT localized_str translated_value
 FROM cz_localized_texts
 WHERE orig_sys_ref LIKE 'OKC:VARIABLEMODELOPTION:-99:%:' || p_variable_id || ':' || p_variable_value
 AND LANGUAGE = USERENV('LANG');

--Bug 4757962 cursor to fetch value for a given question id
CURSOR csr_get_rule_qst_values (l_config_header_id number, l_config_rev_nbr number) is
SELECT ltxt.localized_str question_value
      FROM cz_config_items_v config,
           cz_ps_nodes psn,
           cz_localized_texts ltxt
     WHERE config.config_hdr_id = l_config_header_id
       AND config.config_rev_nbr = l_config_rev_nbr
       AND config.ps_node_id = psn.ps_node_id
       AND psn.intl_text_id = ltxt.intl_text_id
       AND ltxt.LANGUAGE = USERENV('LANG')
       AND SUBSTR(config.orig_sys_ref, INSTR(config.orig_sys_ref,':',-1,2)+1,
               (INSTR(config.orig_sys_ref,':',-1,1) - (INSTR(config.orig_sys_ref,':',-1,2)+1))) = to_char(p_object_code);

-- Create Dynamic sql for the valueset values
CURSOR csr_value_set_tab IS
SELECT  application_table_name,
        value_column_name,
        id_column_name,
        additional_where_clause
FROM fnd_flex_validation_tables
WHERE flex_value_set_id = p_value_set_id;

-- cursor to find datatype of a question
CURSOR csr_get_qst_datatype is
select question_datatype from okc_xprt_questions_b
where to_char(question_id) = p_object_code;

-- cursor to fetch document value for questions based on constants
CURSOR csr_get_rule_qst_const_val (l_config_header_id number, l_config_rev_nbr number) is
SELECT to_char(Item_num_val)
      FROM cz_config_items_v config
     WHERE config.config_hdr_id = l_config_header_id
       AND config.config_rev_nbr = l_config_rev_nbr
       AND config.orig_sys_ref LIKE 'OKC:TEMPLATEMODELFEATURE:%:' || p_object_code;

l_api_name                CONSTANT VARCHAR2(30) := 'get_deviation_document_value';
l_object_code  varchar2(2000)   := null;
l_variable_value varchar2(1000) := null;
l_variable_translated_value varchar2(1000) := null;
l_question_value varchar2(1000) := null;
l_final_document_value varchar2(1000) := null; --contains final document value to be returned
l_table_name              fnd_flex_validation_tables.application_table_name%TYPE;
l_name_col                fnd_flex_validation_tables.value_column_name%TYPE;
l_id_col                  fnd_flex_validation_tables.id_column_name%TYPE;
l_additional_where_clause fnd_flex_validation_tables.additional_where_clause%TYPE;
tempName fnd_flex_validation_tables.value_column_name%TYPE ;
tempId   fnd_flex_validation_tables.id_column_name%TYPE ;
l_sql_stmt                LONG;
l_config_header_id  number;
l_config_rev_nbr    number;
l_is_rule_line_level     varchar2(1);
l_question_datatype      varchar2(10);
l_user_defined_var       varchar2(1);

TYPE cur_typ IS REF CURSOR;
c_cursor cur_typ;

BEGIN
    -- start debug log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '900: Entered '||G_PKG_NAME ||'.'||l_api_name);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '910: Parameters passed: -----------------------');
     Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '910:p_rule_id = '||p_rule_id);
     Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '910:Object Type = '||p_object_type);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '910:Object Code = '||p_object_code);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '910:Sequence Id = '||p_sequence_id);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                       g_Module || l_Api_Name,
                   '910:p_value_set_id = '||p_value_set_id);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                       g_Module || l_Api_Name,
                   '910:p_object_value_type = '||p_object_value_type);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                            g_Module || l_Api_Name,
                   '910:p_object_value_code = '||p_object_value_code);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                       g_Module || l_Api_Name,
                   '910:p_line_number = '||p_line_number);

    END IF;

    --If object_type is QUESTION then get the question response
    IF p_object_type = 'QUESTION' THEN
      OPEN csr_config_data;
      FETCH csr_config_data  INTO l_config_header_id,l_config_rev_nbr;
      CLOSE csr_config_data;

      OPEN csr_get_qst_datatype;
      FETCH csr_get_qst_datatype  INTO l_question_datatype;
      CLOSE csr_get_qst_datatype;
      if(l_question_datatype = 'N')then
          --In case of Numeric Questions get document value from cz_config_items_v.Item_num_val
          OPEN csr_get_rule_qst_const_val(l_config_header_id,l_config_rev_nbr);
          FETCH csr_get_rule_qst_const_val  INTO l_question_value;
          CLOSE csr_get_rule_qst_const_val;
          l_final_document_value := l_question_value;
      else
          OPEN csr_get_rule_qst_values(l_config_header_id,l_config_rev_nbr);
          FETCH csr_get_rule_qst_values  INTO l_question_value;
          CLOSE csr_get_rule_qst_values;
          l_final_document_value := l_question_value;
      end if;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '920:l_config_header_id = '||l_config_header_id);
       Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                    g_Module || l_Api_Name,
                    '920:l_config_rev_nbr = '||l_config_rev_nbr);
       Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                    g_Module || l_Api_Name,
                   '920:Question DataType = '||l_question_datatype);
       Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                    g_Module || l_Api_Name,
                   '920:l_final_document_value = '||l_final_document_value);
      END IF;

    --If object_type is VARIABLE then get the variable translated value as below
    Elsif (p_object_type = 'VARIABLE')  THEN
      --get the document value from OKC_XPRT_DEVIATIONS_T
      --Find whether rule is at Header level or Line Level
      l_is_rule_line_level := is_rule_line_level(p_rule_id);
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '920: l_is_rule_line_level = '||l_is_rule_line_level);
      END IF;
      --If rule is at header level and variable code is Item or Item Category then get
      --concatinated Item or Item Category Values
      IF(l_is_rule_line_level = 'N' AND
         (p_object_code='OKC$S_ITEM' OR p_object_code='OKC$S_ITEM_CATEGORY' OR
          p_object_code='OKC$B_ITEM' OR p_object_code='OKC$B_ITEM_CATEGORY')) THEN
          l_final_document_value := get_concat_document_value(p_object_code,p_sequence_id);
      ELSE
         OPEN  csr_variable_value(p_object_code);
         FETCH csr_variable_value INTO l_variable_value;
         CLOSE csr_variable_value;
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '920: Varialbe Value from xprt_deviations_T table = '||l_variable_value);
         END IF;
         --Bug#5148503 If l_variable_value is null then check whether we can find variable_value
         --using 'USER$'||p_object_code instead of p_object_code
         --NOTE:In case of User Defined Variables,variable_code will be
         --in the form 'USER$variable_code' in OKC_XPRT_DEVIATIONS_T table.So we need to search on
         --'USER$'||p_object_code
         IF(l_variable_value is NUll) THEN
            OPEN  csr_variable_value('USER$'||p_object_code);
            FETCH csr_variable_value INTO l_variable_value;
            CLOSE csr_variable_value;
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '922: Varialbe Value for USER$'||p_object_code||'='||l_variable_value);
            END IF;
		if(l_variable_value is not null) then
              l_user_defined_var := 'Y';
            end if;
         END IF;
         --Bug#4911316 for constants  no need to get translated value
         --In this case l_varialbe_value is same as translated value
         IF(p_object_value_type  = 'CONSTANT' ) THEN
           l_variable_translated_value := l_variable_value;
         ELSE  --If valueType is not CONSTANT then get transalted value
           if(l_user_defined_var = 'Y') then
             l_object_code := 'USER$'||p_object_code;
           else
             l_object_code := p_object_code;
           end if;
           OPEN  csr_translated_value(l_object_code, l_variable_value);
           FETCH csr_translated_value INTO l_variable_translated_value;
           CLOSE csr_translated_value;
         END IF;
         l_final_document_value := l_variable_translated_value;
      END IF; --IF(l_is_rule_line_level
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '920: Translated Document Value = '||l_variable_translated_value);
      END IF;

      --If translated variable value is not available in CZ table and variable value is available only
      --in OKC_XPRT_DEVIATIONS_T then need to fetch translated value using dyanmic sql query as below
      IF(l_variable_value is not null and l_variable_translated_value is null) THEN

	 -- Build the dynamic SQL for the valueset
	 OPEN csr_value_set_tab;
	 FETCH csr_value_set_tab INTO l_table_name, l_name_col, l_id_col, l_additional_where_clause;
	 CLOSE csr_value_set_tab;

	 l_sql_stmt :=  'SELECT '||l_name_col||' , '||l_id_col||
			' FROM  '||l_table_name||' '||
			l_additional_where_clause ;

	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'930: l_table_name  '||l_table_name);
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'930: l_name_col '||l_name_col);
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'930: l_id_col  '||l_id_col);
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'930: l_additional_where_clause '||l_additional_where_clause);
		 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'930: SQL STMT '||l_sql_stmt);
	 END IF;


         IF(l_table_name is not null) THEN
	 	OPEN c_cursor FOR l_sql_stmt;
		LOOP
		       FETCH c_cursor INTO tempName, tempId;
		       EXIT WHEN c_cursor%NOTFOUND;
		       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'931: tempName = '||tempName || ',tempId = '||tempId);
		       END IF;
		       if(tempId = l_variable_value) then
			 l_final_document_value := tempName;
			 exit;
			 end if;
		END LOOP;
	 	CLOSE c_cursor;
        ELSE --Bug 5255911 added else block
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				G_MODULE||l_api_name,
				'932: l_table_name is null');
	     END IF;
           --could not find translated value.So make final value as is as variable value
           l_final_document_value := l_variable_value;

	  END IF; --IF(l_table_name

      END IF; --end IF(l_variable_value is not
    END IF; --IF(p_object_type = 'QUESTION'

    -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '940: final document Value = '||l_final_document_value);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '940: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

RETURN l_final_document_value;

EXCEPTION
WHEN OTHERS THEN
  IF csr_variable_value%ISOPEN THEN
	     CLOSE csr_variable_value;
  END IF;
  IF csr_translated_value%ISOPEN THEN
	     CLOSE csr_translated_value;
  END IF;
  IF csr_config_data%ISOPEN THEN
	     CLOSE csr_config_data;
  END IF;
  IF csr_get_rule_qst_values%ISOPEN THEN
  	     CLOSE csr_get_rule_qst_values;
  END IF;
  IF csr_value_set_tab%ISOPEN THEN
  	     CLOSE csr_value_set_tab;
  END IF;
  IF csr_get_qst_datatype%ISOPEN THEN
  	     CLOSE csr_get_qst_datatype;
  END IF;
  IF csr_get_rule_qst_values%ISOPEN THEN
  	     CLOSE csr_get_rule_qst_values;
  END IF;
  IF c_cursor%ISOPEN THEN
  	     CLOSE c_cursor;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '950: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;
RETURN NULL;
END get_deviation_document_value;

/*====================================================================+
  Function Name : get_value_display -Overloaded
  Description    : Returns the condition value display name.
                   Used to display condition value in condition values inner table
                   in rules update/view mode. This function has been overloaded to
                   handle value display for the condition values row
+====================================================================*/

FUNCTION get_value_display (
    p_rule_condition_id      IN NUMBER,
    p_object_value_code      IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c1 IS
    SELECT RuleCond.Object_value_code,
           RuleCond.Object_value_type,
           fvs.flex_value_set_id OBJECT_VALUE_SET_ID,
           fvs.validation_type,
           fvs.longlist_flag
    FROM OKC_XPRT_RULE_CONDITIONS RuleCond,
    fnd_flex_value_sets fvs
    where rtrim(RuleCond.OBJECT_VALUE_SET_NAME) =  fvs.flex_value_set_name(+)
    and rule_condition_id=p_rule_condition_id;

l_value  VARCHAR2(1000) := null;
c1rec c1%rowtype;
BEGIN
--get the requitred values from the condition
    OPEN c1;
    FETCH c1  INTO c1rec;
    CLOSE c1;

-- now call the 2nd get_value_display
--we are setting the mode to CONDVAL so poplist values are also handled

    l_value := get_value_display(c1rec.Object_value_type  ,
                                p_object_value_code  ,
                                c1rec.object_value_set_id,
                                c1rec.validation_type ,
                                c1rec.longlist_flag,
                                'CONDVAL' );

 RETURN l_value;
EXCEPTION
WHEN OTHERS THEN
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;
 RETURN NULL;
END get_value_display;


/*====================================================================+
  Function Name : get_value_desc
  Description    : Returns the condition value description
                   Used to display condition value description in inner table
                   for rules update/view pages
+====================================================================*/
FUNCTION get_value_desc (
    p_rule_condition_id      IN NUMBER,
    p_object_value_code      IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR c1 IS
    SELECT RuleCond.Object_value_code,
           RuleCond.Object_value_type,
           fvs.flex_value_set_id OBJECT_VALUE_SET_ID,
           fvs.validation_type,
           fvs.longlist_flag
    FROM OKC_XPRT_RULE_CONDITIONS RuleCond,
    fnd_flex_value_sets fvs
    where RuleCond.OBJECT_VALUE_SET_NAME =  fvs.flex_value_set_name(+)
    and rule_condition_id=p_rule_condition_id;

l_value  VARCHAR2(1000) := null;
c1rec c1%rowtype;
BEGIN
--get the requitred values from the condition
    OPEN c1;
    FETCH c1  INTO c1rec;
    CLOSE c1;

-- now call the 2nd get_value_display

    l_value := get_value_desc(c1rec.Object_value_type  ,
                                p_object_value_code  ,
                                c1rec.object_value_set_id,
                                c1rec.validation_type ,
                                c1rec.longlist_flag);

 RETURN l_value;
EXCEPTION
 WHEN OTHERS THEN
  IF c1%ISOPEN THEN
   CLOSE c1;
  END IF;
  RETURN NULL;
END get_value_desc;

/*====================================================================+
  Function Name : get_value_desc
  Description    : Returns the condition value description
                   Called from previous get_value_desc
+====================================================================*/

FUNCTION get_value_desc (
    p_object_value_type      IN VARCHAR2,
    p_object_value_code      IN VARCHAR2,
    p_object_value_set_id    IN NUMBER,
    p_validation_type        IN VARCHAR2,
    p_longlist_flag          IN VARCHAR2)

RETURN VARCHAR2 IS
--Start:Perf Bug#5032199 sql Id 16474199.Commented below cursor and added new cursor
/*CURSOR c1 IS
    SELECT article_description
    FROM okc_articles_v art
    WHERE article_id=to_number(p_object_value_code)
    AND article_version_number=
           (select  max(article_version_number)
            from  okc_article_versions
            where article_id= Art.article_id);*/
CURSOR c1 IS
    SELECT article_description
    FROM okc_article_versions  art
    WHERE article_id=to_number(p_object_value_code)
    AND article_version_number=
           (select  max(article_version_number)
            from  okc_article_versions
            where article_id= to_number(p_object_value_code));
--End:Perf Bug#5032199

CURSOR C2 IS
    SELECT description
    FROM okc_xprt_questions_vl
    WHERE question_id=TO_NUMBER(p_object_value_code)
    AND question_type= decode(p_object_value_type,'CONSTANT','C','Q');

 CURSOR c3 IS
    SELECT description
    FROM okc_bus_variables_v
    WHERE variable_code=p_object_value_code;


l_value  VARCHAR2(1000) := null;

BEGIN
-- If object_type is clause, then get clause name
 If p_object_value_type = 'CLAUSE' THEN
    OPEN c1;
    FETCH c1  INTO l_value;
    CLOSE c1;

-- If object type is constant or question
 Elsif (p_object_value_type = 'CONSTANT' OR p_object_value_type ='QUESTION') THEN
    OPEN c2;
    FETCH c2  INTO l_value;
    CLOSE c2;

-- If opbject type is an expert variable
 Elsif (p_object_value_type = 'VARIABLE')  THEN
    OPEN c3;
    FETCH c3  INTO l_value;
    CLOSE c3;

 ELSIF (p_object_value_type='VALUE') and (p_object_value_set_id is not null) THEN
    l_value := get_valueset_value_desc ( p_object_value_set_id, p_object_value_code,    p_validation_type );
 END IF;

 RETURN l_value;
EXCEPTION
 WHEN OTHERS THEN
      --close cursors
     IF c1%ISOPEN THEN
       CLOSE c1;
     END IF;

     IF c2%ISOPEN THEN
       CLOSE c2;
     END IF;

     IF c3%ISOPEN THEN
       CLOSE c3;
     END IF;
     RETURN  NULL;
END get_value_desc;

/*====================================================================+
  Function Name : get_valueset_value
  Description    : Returns the value set value  based on passed in parameters
                   Called from get_value_display
+====================================================================*/

FUNCTION get_valueset_value (
    p_object_value_set_id    IN NUMBER,
    p_object_value_code      IN VARCHAR2,
    p_validation_type        IN VARCHAR2)

RETURN VARCHAR2 IS
CURSOR c1 IS
    select value.flex_value
    --,value.description
    from fnd_flex_values_vl value
where value.FLEX_VALUE_SET_ID =  p_object_value_set_id
and enabled_flag='Y'
and trunc(sysdate) between nvl(trunc(start_date_active),trunc(sysdate)) and nvl(trunc(end_date_active),trunc(sysdate))
and value.flex_value_id = to_number(p_object_value_code);

CURSOR c2 IS

select
val_tab.application_table_name,
val_tab.value_column_name,
val_tab.id_column_name,
val_tab.additional_where_clause,
val_tab.meaning_column_name
from fnd_flex_validation_tables val_tab
where val_tab.FLEX_VALUE_SET_ID =  p_object_value_set_id ;

l_value VARCHAR2(1000) := null;

c2rec c2%rowtype;
l_select_stmt VARCHAR2(2000);

 value_cursor_id INTEGER;
 ret_val INTEGER;
BEGIN

 --if value set type is independent or independent translatable
 --Added independent translatable validation for Policy Deviations

 IF (p_validation_type = 'I' OR p_validation_type = 'X' ) THEN

    OPEN c1;
    FETCH c1  INTO l_value;
    CLOSE c1;
 ELSIF (p_validation_type = 'F')THEN

 --set the sql statement for valueset
    OPEN c2;
    FETCH c2  INTO c2rec;
    CLOSE c2;

    IF c2rec.id_column_name IS NULL THEN
      RETURN null;
    END IF;

    l_select_stmt := ' SELECT ' || NVL(c2rec.id_column_name,null) ||' as  Flex_value_id,'||
                     NVL(c2rec.value_column_name,'null') ||' as  Flex_value,'||
                     NVL(c2rec.meaning_column_name,'null') ||' as  Flex_meaning FROM '||
                     c2rec.application_table_name ;


    If c2rec.additional_where_clause is not null THEN
 -- If no WHERE keyword, add it
      IF (UPPER(substr(ltrim(c2rec.additional_where_clause),1,5)) <> 'WHERE') AND
         (UPPER(substr(ltrim(c2rec.additional_where_clause),1,8)) <> 'ORDER BY') THEN

        l_select_stmt := l_select_stmt||' WHERE';
      END IF;
-- add where clause
      l_select_stmt :=l_select_stmt||' '|| c2rec.additional_where_clause;
   END IF;
--doing this becuase order by may exist in where clause
      l_select_stmt := 'SELECT FLEX_VALUE FROM ('||l_select_stmt||') WHERE FLEX_VALUE_ID = :1';


    value_cursor_id := DBMS_SQL.OPEN_CURSOR;
   --parse the query
    DBMS_SQL.PARSE(value_cursor_id,l_select_stmt,DBMS_SQL.NATIVE);
    --Bind the input variable
    DBMS_SQL.BIND_VARIABLE(value_cursor_id,':1',p_object_value_code);

    --define select lis
    DBMS_SQL.DEFINE_COLUMN(value_cursor_id,1, l_value,1000);
    --execute the query
    ret_val := DBMS_SQL.EXECUTE(value_cursor_id);
    IF DBMS_SQL.FETCH_ROWS(value_cursor_id) <> 0 THEN
      DBMS_SQL.COLUMN_VALUE(value_cursor_id,1, l_value);
    END IF;

    DBMS_SQL.CLOSE_CURSOR(value_cursor_id);
  END IF;
return l_value;
EXCEPTION
WHEN OTHERS THEN
  --close cursors
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;

 IF c2%ISOPEN THEN
   CLOSE c2;
 END IF;

 RETURN NULL;
END get_valueset_value;

/*====================================================================+
  Function Name : get_valueset_value_desc
  Description    : Returns the value set value description based on passed in parameters
                   Called from get_value_desc
+====================================================================*/

FUNCTION get_valueset_value_desc (
    p_object_value_set_id    IN NUMBER,
    p_object_value_code      IN VARCHAR2,
    p_validation_type        IN VARCHAR2)

RETURN VARCHAR2 IS
CURSOR c1 IS
    select value.description
    from fnd_flex_values_vl value
where value.FLEX_VALUE_SET_ID =  p_object_value_set_id
and enabled_flag='Y'
and trunc(sysdate) between nvl(trunc(start_date_active),trunc(sysdate)) and nvl(trunc(end_date_active),trunc(sysdate))
and value.flex_value_id = to_number(p_object_value_code);

CURSOR c2 IS

select
val_tab.application_table_name,
val_tab.value_column_name,
val_tab.id_column_name,
val_tab.additional_where_clause,
val_tab.meaning_column_name
from fnd_flex_validation_tables val_tab
where val_tab.FLEX_VALUE_SET_ID =  p_object_value_set_id ;

l_value VARCHAR2(1000) := null;

c2rec c2%rowtype;
l_select_stmt VARCHAR2(2000);

 value_cursor_id INTEGER;
 ret_val INTEGER;
BEGIN

 --if value set type is independent

 IF (p_validation_type = 'I') THEN

    OPEN c1;
    FETCH c1  INTO l_value;
    CLOSE c1;
 ELSIF (p_validation_type = 'F')THEN

 --set the sql statement for valueset
    OPEN c2;
    FETCH c2  INTO c2rec;
    CLOSE c2;

    IF c2rec.id_column_name IS NULL THEN
      RETURN null;
    END IF;
     l_select_stmt := ' SELECT ' || NVL(c2rec.id_column_name,null) ||' as  Flex_value_id,'||
                     NVL(c2rec.value_column_name,'null') ||' as  Flex_value,'||
                     NVL(c2rec.meaning_column_name,'null') ||' as  Flex_meaning FROM '||
                     c2rec.application_table_name ;


    If c2rec.additional_where_clause is not null THEN
-- add where clause
   -- If no WHERE keyword, add it
      IF (UPPER(substr(ltrim(c2rec.additional_where_clause),1,5)) <> 'WHERE') AND
         (UPPER(substr(ltrim(c2rec.additional_where_clause),1,8)) <> 'ORDER BY') THEN

        l_select_stmt := l_select_stmt||' WHERE';
      END IF;

      l_select_stmt :=l_select_stmt||' '|| c2rec.additional_where_clause;
    END IF;
--doing this becuase order by may exist in where clause
      l_select_stmt := 'SELECT FLEX_MEANING FROM ('||l_select_stmt||') WHERE FLEX_VALUE_ID = :1';

    value_cursor_id := DBMS_SQL.OPEN_CURSOR;
   --parse the query
    DBMS_SQL.PARSE(value_cursor_id,l_select_stmt,DBMS_SQL.NATIVE);
    --Bind the input variable
    DBMS_SQL.BIND_VARIABLE(value_cursor_id,':1',p_object_value_code);

    --define select lis
    DBMS_SQL.DEFINE_COLUMN(value_cursor_id,1, l_value,1000);
    --execute the query
    ret_val := DBMS_SQL.EXECUTE(value_cursor_id);
    IF DBMS_SQL.FETCH_ROWS(value_cursor_id) <> 0 THEN
      DBMS_SQL.COLUMN_VALUE(value_cursor_id,1, l_value);
    END IF;

    DBMS_SQL.CLOSE_CURSOR(value_cursor_id);
  END IF;
return l_value;

EXCEPTION
WHEN OTHERS THEN
  --close cursors
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;

 IF c2%ISOPEN THEN
   CLOSE c2;
 END IF;

 RETURN NULL;
END get_valueset_value_desc;
-----------END: FUNCTIONS USED IN RULES PAGES-------------------------------------------------------------------

/*
  This api will be called if the rule to be published has no expert enabled templates
  to be attached
*/
PROCEDURE publish_rule_with_no_tmpl
(
 p_calling_mode    IN   VARCHAR2,
 x_return_status   OUT  NOCOPY VARCHAR2,
 x_msg_data        OUT   NOCOPY VARCHAR2,
 x_msg_count       OUT   NOCOPY NUMBER
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'publish_rule_with_no_tmpl';


BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Update Rule status
  UPDATE okc_xprt_rule_hdrs_all
     SET status_code = DECODE (p_calling_mode, 'PUBLISH', 'ACTIVE', 'DISABLE', 'INACTIVE', 'SYNC', 'ACTIVE'),
	    published_flag = 'Y',
         last_updated_by = FND_GLOBAL.USER_ID,
         last_update_date = SYSDATE,
         last_update_login = FND_GLOBAL.LOGIN_ID
   WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID;


  -- commit work
   commit work;

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
      x_msg_data := SQLERRM;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      x_msg_data := SQLERRM;
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
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END publish_rule_with_no_tmpl;

------------------------------------------------------------------------------

/*
  This will be called from publish and approval concurrent program.
  This procedure will do the QA for rules before importing to CZ and if there are
  any errors will put the error details in concurrent request out and log files
  p_qa_mode = PUBLISH or APPROVAL
  p_template_id = will be passed only in case of APPROVAL
*/
PROCEDURE check_rules_validity
(
 p_qa_mode		IN VARCHAR2,
 p_template_id      IN NUMBER,
 x_sequence_id      OUT NOCOPY NUMBER,
 x_qa_status        OUT NOCOPY VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
) IS

-- Rules under Publication
CURSOR csr_publish_rules IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;

-- Rules attached to template
CURSOR csr_approval_rules IS
-- Local Rules on Template
SELECT r.rule_id
  FROM okc_xprt_template_rules r,
       okc_xprt_rule_hdrs_all h
 WHERE r.rule_id = h.rule_id
   AND h.status_code = 'ACTIVE'
   AND r.template_id = p_template_id
UNION ALL
SELECT h.rule_id
  FROM okc_terms_templates_all t,
       okc_xprt_rule_hdrs_all h
 WHERE t.org_id = h.org_id
   AND t.intent = h.intent
   AND h.status_code = 'ACTIVE'
   AND NVL(h.org_wide_flag,'N') = 'Y'
   AND t.template_id = p_template_id;

-- Rules with errors
CURSOR csr_qa_errors(p_sequence_id IN NUMBER) IS
SELECT title,
       problem_short_desc,
	  problem_details,
	  suggestion
  FROM okc_qa_errors_t
 WHERE sequence_id = p_sequence_id
   AND error_severity = 'E';

l_ruleid_tbl              OKC_XPRT_QA_PVT.RuleIdList;
l_api_name                CONSTANT VARCHAR2(30) := 'check_rules_validity';
i                         BINARY_INTEGER;

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

  -- initialize i
    i := 0;

  IF p_qa_mode = 'PUBLISH' THEN
     FOR rec_publish_rules IN csr_publish_rules
	LOOP
	  i := i + 1;
	  l_ruleid_tbl(i) := rec_publish_rules.rule_id;
	END LOOP;
  ELSE
   -- p_qa_mode is APPROVAL
     FOR rec_approval_rules IN csr_approval_rules
	LOOP
	  i := i + 1;
       l_ruleid_tbl(i) := rec_approval_rules.rule_id;
	END LOOP;
  END IF;

        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'Calling OKC_XPRT_QA_PVT.qa_rules ');

  -- Call the QA API
       OKC_XPRT_QA_PVT.qa_rules
       (
        p_qa_mode		   => p_qa_mode,
        p_ruleid_tbl        => l_ruleid_tbl,
        x_sequence_id	   => x_sequence_id,
        x_qa_status	        => x_qa_status,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data
       );

        fnd_file.put_line(FND_FILE.LOG,'  ');
        fnd_file.put_line(FND_FILE.LOG,'After OKC_XPRT_QA_PVT.qa_rules ');
        fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
        fnd_file.put_line(FND_FILE.LOG,'x_qa_status: '||x_qa_status);
        fnd_file.put_line(FND_FILE.LOG,'x_sequence_id: '||x_sequence_id);
        fnd_file.put_line(FND_FILE.LOG,'  ');

        --- If any errors happen abort API
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;

	    -- If QA had one or more errors, log the errors
	    IF x_qa_status <> 'S' THEN
	       fnd_file.put_line(FND_FILE.LOG,'  ');
	       fnd_file.put_line(FND_FILE.LOG,'Following Rules did not pass QA  ');
	       fnd_file.put_line(FND_FILE.LOG,'  ');
		  FOR rec_qa_errors IN csr_qa_errors(p_sequence_id => x_sequence_id)
		    LOOP
	           fnd_file.put_line(FND_FILE.LOG,'Rule Name   : '||rec_qa_errors.title);
	           fnd_file.put_line(FND_FILE.LOG,'QA Check    : '||rec_qa_errors.problem_short_desc);
	           fnd_file.put_line(FND_FILE.LOG,'Problem     : '||rec_qa_errors.problem_details);
	           fnd_file.put_line(FND_FILE.LOG,'Suggestion  : '||rec_qa_errors.suggestion);
	           fnd_file.put_line(FND_FILE.LOG,'  ');
		    END LOOP;

	    END IF; -- qa had errors


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
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END check_rules_validity;
-----FUNCTION USED IN RULES PAGES-(2)------------------------------------------------------------------------

/*====================================================================+
  Function Name : is_valid
  Description    :
                   Called from is_value_valid
                   Returns 'N' if a clause is on hold/expired, or question is diabled
  Parameters     : p_object_type  : Object type
                   p_object_id :  question id/clause id
+====================================================================*/
FUNCTION is_valid (
    p_object_id      IN NUMBER,
    p_object_type    IN VARCHAR2)
 RETURN VARCHAR2 IS

 Cursor c1 is
 SELECT decode(article_status,'ON_HOLD','N','EXPIRED','N','Y') valid_yn
 FROM okc_article_versions Art
 WHERE article_id= p_object_id
 AND article_version_number=
           (select  max(article_version_number)
            from  okc_article_versions
            where article_id= Art.article_id);


 Cursor c2 is
 SELECT decode(disabled_flag,'Y','N','Y') disabled_yn
 FROM okc_xprt_questions_b
 WHERE question_id= p_object_id;

 l_ret_value VARCHAR2(1) := 'Y';


 BEGIN

 IF (p_object_type = 'CLAUSE') THEN

    OPEN c1;
    FETCH c1  INTO l_ret_value;
    CLOSE c1;

 ELSIF p_object_type = ('QUESTION') THEN

    OPEN c2;
    FETCH c2  INTO l_ret_value;
    CLOSE c2;
 END IF;

 return l_ret_value;
EXCEPTION
 WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;

  IF c2%ISOPEN THEN
    CLOSE c2;
  END IF;

  RETURN 'N';
 END is_valid;


/*====================================================================+
  Bug 4723548 Created this function
  Function Name :is_value_set_changed
  Description   :Called during validation of conditions on Rules Page

  Parameters    : p_object_code  : Variable Code
                : p_object_value_set_id :  Value Set Id associated with the variable
+====================================================================*/
FUNCTION is_value_set_changed (
    p_object_code          IN VARCHAR2,
    p_object_value_set_id  IN NUMBER)
RETURN VARCHAR2 IS

Cursor c1 is
SELECT value_set_id
FROM OKC_BUS_VARIABLES_V
WHERE variable_code = p_object_code
AND  variable_type = 'U';

l_value_set_id NUMBER ;
l_ret_value VARCHAR2(1) := 'N';
l_api_name   CONSTANT VARCHAR2(30) := 'is_value_set_changed';
BEGIN
  -- start debug log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '900: Entered '||G_PKG_NAME ||'.'||l_api_name);
     Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                    '910: Parameters passed: -----------------------');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '910:p_object_code = '||p_object_code);
    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                   g_Module || l_Api_Name,
                   '910:p_object_value_set_id = '||p_object_value_set_id);
    END IF;
  --end log
  OPEN c1;
      FETCH c1  INTO l_value_set_id;
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '920: l_value_set_id '||l_value_set_id);
       END IF;
      IF l_value_set_id <> p_object_value_set_id THEN
             l_ret_value := 'Y';
      END IF;
  CLOSE c1;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '930: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;
RETURN l_ret_value;

EXCEPTION
 WHEN OTHERS THEN
   IF c1%ISOPEN THEN
     CLOSE c1;
   END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '940: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;
 RETURN 'N';
END is_value_set_changed;

/*====================================================================+
  Function Name : is_value_valid
  Description    : wrapper funtion for is_valid above.
                   Used in ruleconditionVO, and conditionvaluesVO to determine if clause/question is valid
                   Used in Rules Update/duplicate flow
  Parameters     : p_rule_condition_id : Condition Id
                   p_object_code :  condition object_code
+====================================================================*/


FUNCTION  is_value_valid (
    p_object_code          IN VARCHAR2,
    p_rule_condition_id    IN NUMBER)
RETURN VARCHAR2 IS

CURSOR c1 IS
    SELECT RuleCond.Object_value_type
    FROM OKC_XPRT_RULE_CONDITIONS RuleCond
    where rule_condition_id=p_rule_condition_id;

l_value  VARCHAR2(1) := null;
l_value_type VARCHAR2(30) ;
c1rec c1%rowtype;
BEGIN
--get the requitred values from the condition
    OPEN c1;
    FETCH c1  INTO l_value_type;
    CLOSE c1;

-- now call the is_valid

 IF (l_value_type in ('CLAUSE','QUESTION')) THEN

     l_value := is_valid( p_object_code, l_value_type);
 ELSE
 --for value set values, we have a seperate validation process, so just return 'Y'
     l_value := 'Y';
 END IF;

 RETURN l_value;
EXCEPTION
 WHEN OTHERS THEN
  IF c1%ISOPEN THEN
    CLOSE c1;
  END IF;
  RETURN 'N';
END is_value_valid;

/*====================================================================+
  Function Name : get_message
  Description    : Utility method to return the translated message
                   API assumes the message has no tokens
+====================================================================*/

FUNCTION get_message(p_appl_name    IN VARCHAR2,
                     p_msg_name     IN VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
Fnd_Message.Set_Name( p_appl_name, p_msg_name );
return fnd_message.get;

END get_message;

----------END OF FUNCTIONS USED IN RULES PAGES 2------------------------------------

PROCEDURE get_publication_id
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_template_id                  IN NUMBER,
 x_publication_id               OUT NOCOPY NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
) IS

l_api_name CONSTANT VARCHAR2(30) := 'get_publication_id';
l_api_version CONSTANT NUMBER := 1;
l_product_key  VARCHAR2(255);
l_usage_name               cz_model_usages.name%TYPE;

CURSOR csr_model_usage_name IS
SELECT name
  FROM cz_model_usages
 WHERE model_usage_id = -1 ; -- seeded for Any Usage

CURSOR csr_template_key IS
SELECT 'OKC:TEMPLATEMODEL:'||org_id||':'||intent||':'||template_id
FROM okc_terms_templates_all
WHERE template_id = p_template_id;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	     p_api_version,
        	    	    	    	               l_api_name,
    		    	    	    	               G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- get usage name for Any Usage
    --  Defaults to CZ: Publication Usage profile
     OPEN csr_model_usage_name;
	  FETCH csr_model_usage_name INTO l_usage_name;
	CLOSE csr_model_usage_name;

    -- generate the template product key
     OPEN csr_template_key;
	 FETCH csr_template_key INTO l_product_key;
	CLOSE csr_template_key;

    OKC_XPRT_CZ_INT_PVT.publication_for_product
     (
      p_api_version                  => p_api_version,
      p_init_msg_lst                 => p_init_msg_list,
      p_product_key                  => l_product_key,
      p_usage_name                   => l_usage_name,
      p_publication_mode             => 'P', -- Production
      p_effective_date               => SYSDATE,
      x_publication_id               => x_publication_id,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
     ) ;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


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
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END get_publication_id;



------------------------------------------------------------------------------
/*
   Function : ok_to_delete_clause
   This function will return 'Y' for a article id if it is not used in
rule condition or outcome.
   If used, it returns 'N'.

*/
FUNCTION ok_to_delete_clause
(
 p_article_id         IN NUMBER
) RETURN VARCHAR2 IS

CURSOR csr_clause_exists IS
-- All Clauses from Conditions
SELECT 'N'
  FROM okc_xprt_rule_cond_vals v,
       okc_xprt_rule_conditions c
 WHERE v.rule_condition_id = c.rule_condition_id
   AND c.object_type = 'CLAUSE'
   AND v.object_value_code = to_char(p_article_id) -- Added to_char function. Fix for Bug 4063007
UNION ALL
-- All Clauses from Outcome
SELECT 'N'
  FROM okc_xprt_rule_outcomes o
 WHERE  o.object_type = 'CLAUSE'
   AND o.object_value_id = p_article_id ; -- Removed to_char which is not needed here

l_delete_flag     VARCHAR2(1);

BEGIN

  OPEN csr_clause_exists;
    FETCH csr_clause_exists INTO l_delete_flag;
      IF csr_clause_exists%NOTFOUND THEN
	   -- Clause is not used in Rules
	   l_delete_flag := 'Y' ;
	 END IF;
  CLOSE csr_clause_exists;

  RETURN l_delete_flag;

END ok_to_delete_clause;

------------------------------------------------------------------------------
PROCEDURE get_qa_code_detail
(
 p_document_type      IN   VARCHAR2,
 p_qa_code            IN   VARCHAR2,
 x_perform_qa         OUT  NOCOPY VARCHAR2,
 x_qa_name            OUT  NOCOPY VARCHAR2,
 x_severity_flag      OUT  NOCOPY VARCHAR2,
 x_return_status      OUT  NOCOPY VARCHAR2
) IS

CURSOR l_get_qa_detail_csr IS
SELECT fnd.meaning qa_name,
       nvl(qa.severity_flag,G_QA_STS_WARNING) severity_flag ,
       decode(fnd.enabled_flag,'N','N','Y',decode(qa.enable_qa_yn,'N','N','Y'),'Y') perform_qa
FROM FND_LOOKUPS FND,
     OKC_DOC_QA_LISTS QA
WHERE QA.DOCUMENT_TYPE(+)=p_document_type
  AND QA.QA_CODE(+) = FND.LOOKUP_CODE
  AND Fnd.LOOKUP_TYPE='OKC_TERM_QA_LIST'
  AND Fnd.lookup_code = p_qa_code;

l_api_name CONSTANT VARCHAR2(30) := 'get_qa_code_detail';

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN l_get_qa_detail_csr;
      FETCH l_get_qa_detail_csr INTO x_qa_name,
	                                x_severity_flag,
							  x_perform_qa;
		IF l_get_qa_detail_csr%NOTFOUND THEN
             FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
		   FND_MESSAGE.set_token('ARG_NAME', 'p_qa_code');
		   FND_MESSAGE.set_token('ARG_VALUE', p_qa_code);
		   FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		END IF;
    CLOSE l_get_qa_detail_csr;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

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


END get_qa_code_detail;
------------------------------------------------------------------------------

  /*====================================================================+
  Procedure Name : enable_expert_button
  Description    : Determines if the Contract Expert button should be
                   enabled in the Authoring UI.

  +====================================================================*/
PROCEDURE enable_expert_button
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_template_id                  IN NUMBER,
 p_document_id                  IN NUMBER,
 p_document_type                IN VARCHAR2,
 x_enable_expert_button         OUT NOCOPY VARCHAR2, -- FND_API.G_FALSE or G_TRUE
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name VARCHAR2(30) := 'enable_expert_button';
    l_package_procedure VARCHAR2(60);
    l_config_header_id NUMBER;
    l_expert_enabled VARCHAR2(1);
    l_ce_profile_option_enabled     VARCHAR2(100);
    l_ce_finish_flag     VARCHAR2(1);
    l_has_responses VARCHAR2(1) := 'N';

    CURSOR csr_config_header_id IS
    SELECT config_header_id, nvl(contract_expert_finish_flag, 'N')
    FROM   okc_template_usages
    WHERE  document_id = p_document_id
    AND    document_type = p_document_type
    AND    template_id = p_template_id;

    CURSOR csr_expert_enabled IS
    SELECT (nvl(contract_expert_enabled, 'N'))
    FROM   okc_terms_templates_all
    WHERE  template_id = p_template_id;

    -- bug 4234476
    -- For document_Type_class as Sourcing if variable_resolution_am IS NULL
    -- then contract expert button must be disabled.
    CURSOR csr_sourcing_level IS
    SELECT document_type_class,
           NVL(variable_resolution_am,'X')
      FROM okc_bus_doc_types_b
     WHERE document_type = p_document_type;

l_document_type_class           okc_bus_doc_types_b.document_type_class%TYPE;
l_variable_resolution_am        okc_bus_doc_types_b.variable_resolution_am%TYPE;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_enable_expert_button := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If documentType is 'OKS' then 'Expert Button' should not be displayed
    --

       IF(p_document_type is not null and trim(p_document_type)='OKS') THEN
          x_enable_expert_button := FND_API.G_FALSE;
          RETURN;
       END IF;

    -- bug 4234476
    OPEN csr_sourcing_level;
       FETCH csr_sourcing_level INTO l_document_type_class, l_variable_resolution_am;
    CLOSE csr_sourcing_level;

    IF l_document_type_class='SOURCING' AND l_variable_resolution_am = 'X' THEN
        -- Not Expert enabled
        x_enable_expert_button := FND_API.G_FALSE;
        RETURN ;
    END IF;


    --  If 'Use Contract Expert' profile is No,
    --  Expert button should not be displayed.
    --

  --
  -- Check if CE Profile is Enabled.
  --
     FND_PROFILE.GET(name=> 'OKC_K_EXPERT_ENABLED', val => l_ce_profile_option_enabled );

    IF NVL(l_ce_profile_option_enabled,'N') = 'N' THEN
        -- Not Expert enabled
        x_enable_expert_button := FND_API.G_FALSE;
        RETURN ;
    END IF;


    --
    --  If Configurator/new okc rules engine has been applied to the document
    --  then Expert should be enabled, regardless of
    --  Template setting.
    OPEN csr_config_header_id;
      FETCH csr_config_header_id INTO l_config_header_id, l_ce_finish_flag;
    CLOSE csr_config_header_id;


    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
	--checking whther the document have any expert responses
	BEGIN
		SELECT 'Y' INTO l_has_responses FROM dual
		WHERE EXISTS (SELECT 1 FROM okc_xprt_doc_ques_response WHERE doc_id = p_document_id AND doc_type = p_document_type AND response IS NOT NULL);
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	IF (l_has_responses = 'Y' OR l_ce_finish_flag = 'Y') THEN
       x_enable_expert_button := FND_API.G_TRUE;
     ELSE
       --  Is Template enabled for Expert?
        OPEN csr_expert_enabled;
        FETCH csr_expert_enabled INTO l_expert_enabled;
        CLOSE csr_expert_enabled;

        IF (upper(l_expert_enabled) = 'Y') THEN
         x_enable_expert_button := FND_API.G_TRUE;
        END IF; -- end l_expert_enabled
     END IF;

    ELSE --configurator

    IF (l_config_header_id is not NULL)
    THEN

       x_enable_expert_button := FND_API.G_TRUE;

    ELSE
       --
       --  Is Template enabled for Expert?
       --
       OPEN csr_expert_enabled;
         FETCH csr_expert_enabled INTO l_expert_enabled;
       CLOSE csr_expert_enabled;

       IF (upper(l_expert_enabled) = 'Y')
       THEN

         x_enable_expert_button := FND_API.G_TRUE;

       END IF; -- end l_expert_enabled

    END IF; -- l_config_header_id is not null
   END IF;

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

    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get(
    		        p_count => x_msg_count,
            		p_data => x_msg_data
    		);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get(
    		        p_count => x_msg_count,
            		p_data => x_msg_data
    		);

WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      		IF FND_MSG_PUB.Check_Msg_Level
    		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    		THEN
        	    	FND_MSG_PUB.Add_Exc_Msg(
        	    	     G_PKG_NAME  	    ,
        	    	     l_api_name
    	    	      );
    		END IF;

    		FND_MSG_PUB.Count_And_Get(
    		     p_count => x_msg_count,
            	     p_data => x_msg_data);
END enable_expert_button;




------------------------------------------------------------------------------
-- Begin: Added for R12

PROCEDURE get_expert_selections(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    x_expert_clauses_tbl           OUT NOCOPY expert_articles_tbl_type,
    x_expert_deviations_tbl        OUT NOCOPY dev_rule_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'get_expert_selections';

    j                           BINARY_INTEGER :=1;

    l_prov_allowed  varchar2(1);
    l_provision  varchar2(1);


    --
    -- Currsor to Select the Expert Deviations
    -- that are in the latest Configuration
    --
    --

    CURSOR l_get_xprt_det_from_cz_csr IS
    SELECT DECODE(SUBSTR(orig_sys_ref,5,3),'CLA',NULL,'VAR',item_val) line_number,
           SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1) id,
           SUBSTR(orig_sys_ref,5,3) type,
           parent_config_item_id
       FROM cz_config_items_v
     WHERE config_hdr_id = p_config_header_id
       AND config_rev_nbr = p_config_rev_nbr
       AND (orig_sys_ref LIKE 'OKC:CLAUSEMODELOPTION:%' OR
            orig_sys_ref LIKE 'OKC:VARIABLEMODELDEVFEATURE:%');


    --
    -- Cursor to check provision allowed for doc type
    --
    CURSOR l_get_prov_csr IS
    SELECT NVL(PROVISION_ALLOWED_YN,'Y')
    FROM OKC_BUS_DOC_TYPES_B
    WHERE  DOCUMENT_TYPE=p_document_type;


    --
    -- Cursor to check if the article is a provision or clause
    --
    --
    CURSOR csr_art_provision (p_article_id NUMBER) IS
    SELECT NVL(PROVISION_YN,'N')
    FROM   OKC_ARTICLE_VERSIONS VERS
    WHERE vers.article_id = p_article_id;

    --
    -- Currsor to Get Line number for deviation
    --

    CURSOR l_get_xprt_dev_line_number_csr(l_parent_config_item_id NUMBER) IS
    SELECT NVL(item_val,'-99') line_number
    FROM  cz_config_items_v
    WHERE config_hdr_id = p_config_header_id
    AND config_rev_nbr = p_config_rev_nbr
    AND parent_config_item_id = l_parent_config_item_id
    AND orig_sys_ref LIKE 'OKC:VARIABLEMODELTEXTFEATURE:%LINE_NUMBER%';

    --cursors used for new OKC rules engine

	CURSOR c_all_expert_articles IS
	SELECT distinct outcome.object_value_id
	FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome
	WHERE rultmp.doc_id = p_document_id
	AND rultmp.doc_type = p_document_type
	AND rultmp.condition_id IS NULL
	AND nvl(rultmp.result, '*' ) = 'Y'
	AND rul.rule_id = rultmp.rule_id
	AND rul.rule_type = 'CLAUSE_SELECTION'
	AND outcome.rule_id = rul.rule_id
	AND outcome.object_type = 'CLAUSE';

	CURSOR c_expert_nonprovision_articles IS
	SELECT distinct outcome.object_value_id
	FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome, okc_article_versions ver
	WHERE rultmp.doc_id = p_document_id
	AND rultmp.doc_type = p_document_type
	AND rultmp.condition_id IS NULL
	AND nvl(rultmp.result, '*' ) = 'Y'
	AND rul.rule_id = rultmp.rule_id
	AND rul.rule_type = 'CLAUSE_SELECTION'
	AND outcome.rule_id = rul.rule_id
	AND outcome.object_type = 'CLAUSE'
	AND ver.article_id = outcome.object_value_id
	AND ver.article_version_number = outcome.object_version_number
	AND nvl(ver.provision_yn, '*') = 'N';

	CURSOR c_expert_deviations IS
	SELECT null line_number, rul.rule_id
	FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul
	WHERE rultmp.doc_id = p_document_id
	AND rultmp.doc_type = p_document_type
	AND rultmp.condition_id IS NULL
	AND nvl(rultmp.result, '*' ) = 'Y'
	AND rul.rule_id = rultmp.rule_id
	AND rul.rule_type = 'TERM_DEVIATION';

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_document_id : '||p_document_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_document_type : '||p_document_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'p_config_rev_nbr : '||p_config_rev_nbr);

  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'N' THEN --only if it is configurator
    IF (p_config_header_id IS NULL OR p_config_rev_nbr IS NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- If provisions are allowed on current document type then just return all
    -- the articles suggested by expert
    -- If provision is NOT allowed then process each article to check if it is provision an drop

    --
    -- First Check if Provisions are allowed in the document.  If not, do not suggest
    -- them in QA.
    --
    OPEN  l_get_prov_csr;
    FETCH l_get_prov_csr INTO l_prov_allowed;
    CLOSE l_get_prov_csr;

    -- Select articles and deviations from okc rules engine temp tables
    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN
		--select articles
		IF l_prov_allowed = 'Y' THEN
			OPEN c_all_expert_articles;
			FETCH c_all_expert_articles BULK COLLECT INTO x_expert_clauses_tbl;
			CLOSE c_all_expert_articles;
		ELSE
			OPEN c_expert_nonprovision_articles;
			FETCH c_expert_nonprovision_articles BULK COLLECT INTO x_expert_clauses_tbl;
			CLOSE c_expert_nonprovision_articles;
		END IF;

		--select deviations
		OPEN c_expert_deviations;
		FETCH c_expert_deviations BULK COLLECT INTO x_expert_deviations_tbl;
		CLOSE c_expert_deviations;
   ELSE
    --
    -- Select Articles from configuration
    --
    FOR l_get_xprt_det_from_cz_rec IN l_get_xprt_det_from_cz_csr
    LOOP

    	IF l_get_xprt_det_from_cz_rec.type = 'CLA' -- Clause from Expert
    	THEN
	    IF l_prov_allowed = 'Y' THEN
		x_expert_clauses_tbl(j) := l_get_xprt_det_from_cz_rec.id;
		j := j + 1;

	    ELSE
	        -- PROVISION IS NOT ALLOWED, CHECK EACH ARTICLE FOR PROVISION FLAG
		-- AND DROP PROVISONS
		--
		-- SELECT ARTICLES FROM CONFIGURATION
		--
		OPEN  csr_art_provision (p_article_id => l_get_xprt_det_from_cz_rec.id);
		FETCH csr_art_provision INTO l_provision;
		CLOSE csr_art_provision;

		IF l_provision = 'N' THEN
		    x_expert_clauses_tbl(j) := l_get_xprt_det_from_cz_rec.id;
		    j := j + 1;
		END IF; -- NOT A PROVISION

	    END IF;  -- l_prov_allowed = 'Y'

	ELSE    -- Deviation from Expert

    	    OPEN  l_get_xprt_dev_line_number_csr (l_get_xprt_det_from_cz_rec.parent_config_item_id);
	    FETCH l_get_xprt_dev_line_number_csr INTO x_expert_deviations_tbl(j).line_number;
	    CLOSE l_get_xprt_dev_line_number_csr;
    	    --x_expert_deviations_tbl(j).line_number := l_get_xprt_det_from_cz_rec.line_number;
    	    x_expert_deviations_tbl(j).rule_id     := l_get_xprt_det_from_cz_rec.id;
    	    j := j + 1;

    	END IF;

    END LOOP;
   END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END get_expert_selections;

PROCEDURE get_rule_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_dev_rule_tbl                 IN dev_rule_tbl_type,
    x_dev_rule_questions_tbl	   OUT NOCOPY dev_rule_questions_tbl_type,
    x_dev_rule_variables_tbl	   OUT NOCOPY dev_rule_variables_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'get_rule_details';

    l_dev_rule_questions_tbl    dev_rule_questions_tbl_type;
    l_dev_rule_variables_tbl	dev_rule_variables_tbl_type;
    j                           BINARY_INTEGER :=0;


    --
    -- Currsor to Select Questions and Variables
    -- that are present in the  Deviations rule
    --
    --

    CURSOR l_rule_details_csr(p_dev_rule_id NUMBER) IS
	SELECT DISTINCT object_type type,
			object_code code
	  FROM okc_xprt_rule_conditions
	 WHERE rule_id = p_dev_rule_id
	   AND object_type IN ('QUESTION','VARIABLE')
	UNION ALL
	SELECT DISTINCT object_value_type type,
			object_value_code code
	  FROM okc_xprt_rule_conditions
	 WHERE rule_id = p_dev_rule_id
	   AND object_value_type IN ('QUESTION','VARIABLE');

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     -- Add Logs for printing deviations rule tbl
     IF p_dev_rule_tbl IS NOT NULL THEN
     	IF p_dev_rule_tbl.count > 0 THEN
		FOR i IN p_dev_rule_tbl.first..p_dev_rule_tbl.last LOOP
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_tbl.(' || i || ').line_number : ' || to_char(p_dev_rule_tbl(i).line_number));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_tbl.(' || i || ').rule_id : ' || to_char(p_dev_rule_tbl(i).rule_id));
	  	END LOOP;
        END IF;
     END IF;
  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Select Deviation Rules from configuration
    --
    FOR i IN p_dev_rule_tbl.FIRST..p_dev_rule_tbl.LAST
    LOOP
    	FOR l_rule_details_rec IN l_rule_details_csr(p_dev_rule_tbl(i).rule_id)
    	LOOP
    	   IF (l_rule_details_rec.type = 'QUESTION') THEN
              --x_dev_rule_questions_tbl(i).line_number := p_dev_rule_tbl(i).line_number;
    	      x_dev_rule_questions_tbl(i).rule_id := p_dev_rule_tbl(i).rule_id;
    	      x_dev_rule_questions_tbl(i).question_id := l_rule_details_rec.code;
    	   END IF;
    	   IF (l_rule_details_rec.type = 'VARIABLE') THEN
    	      x_dev_rule_variables_tbl(i).line_number := p_dev_rule_tbl(i).line_number;
       	      x_dev_rule_variables_tbl(i).rule_id := p_dev_rule_tbl(i).rule_id;
    	      x_dev_rule_variables_tbl(i).variable_id := l_rule_details_rec.code;
    	   END IF;
    	END LOOP;
    END LOOP;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END get_rule_details;


PROCEDURE get_rule_variable_values(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_sequence_id	           IN NUMBER,
    p_dev_rule_variables_tbl       IN dev_rule_variables_tbl_type,
    x_dev_rule_var_values_tbl	   OUT NOCOPY dev_rule_var_values_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'get_rule_variable_values';

    j                           BINARY_INTEGER :=0;


    --
    -- Currsor to Select Variable values for the Variables
    -- that are present in the  Deviations rule
    --
    --

    CURSOR l_get_rul_variable_values_csr (p_line_number VARCHAR2, p_variable_id VARCHAR2) IS
    SELECT variable_value variable_value
      FROM okc_xprt_deviations_t
     WHERE variable_code = p_variable_id
     AND run_id = p_sequence_id;
       --AND line_number = p_line_number;

    CURSOR l_get_translated_values_csr (p_variable_id VARCHAR2, p_variable_value VARCHAR2) IS
    SELECT localized_str translated_value
      FROM cz_localized_texts
     WHERE orig_sys_ref LIKE 'OKC:VARIABLEMODELOPTION:-99:%:' || p_variable_id || ':' || p_variable_value
	   AND LANGUAGE = USERENV('LANG');
BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     -- Add Logs for printing deviations rule variables tbl
     IF p_dev_rule_variables_tbl IS NOT NULL THEN
     	IF p_dev_rule_variables_tbl.count > 0 THEN
		FOR i IN p_dev_rule_variables_tbl.first..p_dev_rule_variables_tbl.last LOOP
	     	   IF p_dev_rule_variables_tbl.EXISTS(i) THEN
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_variables_tbl.(' || i || ').line_number : ' || to_char(p_dev_rule_variables_tbl(i).line_number));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_variables_tbl.(' || i || ').rule_id : ' || to_char(p_dev_rule_variables_tbl(i).rule_id));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_variables_tbl.(' || i || ').variable_id : ' || to_char(p_dev_rule_variables_tbl(i).variable_id));
	  	   END IF;
	  	END LOOP;
        END IF;
     END IF;
  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Select Variable values from Temp table
    --
    /*FOR i IN p_dev_rule_variables_tbl.FIRST..p_dev_rule_variables_tbl.LAST
    LOOP
    	IF p_dev_rule_variables_tbl.EXISTS(i) THEN
		FOR l_get_rul_variable_values_rec IN l_get_rul_variable_values_csr(p_dev_rule_variables_tbl(i).line_number,
										   p_dev_rule_variables_tbl(i).variable_id)
		LOOP
		   x_dev_rule_var_values_tbl(i).line_number 		:= 	p_dev_rule_variables_tbl(i).line_number;
		   x_dev_rule_var_values_tbl(i).rule_id 		:= 	p_dev_rule_variables_tbl(i).rule_id;
		   x_dev_rule_var_values_tbl(i).variable_id 		:= 	p_dev_rule_variables_tbl(i).variable_id;
		   --x_dev_rule_var_values_tbl(i).variable_value	:= 	l_get_rul_variable_values_rec.variable_value;
		   OPEN l_get_translated_values_csr(p_dev_rule_variables_tbl(i).variable_id,
		                                    l_get_rul_variable_values_rec.variable_value);
		   FETCH l_get_translated_values_csr INTO x_dev_rule_var_values_tbl(i).variable_value;
		   CLOSE l_get_translated_values_csr;
		END LOOP;
  	END IF;
    END LOOP;*/

    -- Modified for Bug 4913135 since there is a separate funtion get_deviation_document_value function
    FOR i IN p_dev_rule_variables_tbl.FIRST..p_dev_rule_variables_tbl.LAST
    LOOP
    	IF p_dev_rule_variables_tbl.EXISTS(i) THEN
		   x_dev_rule_var_values_tbl(i).line_number 		:= 	p_dev_rule_variables_tbl(i).line_number;
		   x_dev_rule_var_values_tbl(i).rule_id 		:= 	p_dev_rule_variables_tbl(i).rule_id;
		   x_dev_rule_var_values_tbl(i).variable_id 		:= 	p_dev_rule_variables_tbl(i).variable_id;
		   --x_dev_rule_var_values_tbl(i).variable_value	:= 	l_get_rul_variable_values_rec.variable_value;
  	END IF;
    END LOOP;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END get_rule_variable_values;

PROCEDURE get_rule_question_values(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_dev_rule_questions_tbl       IN dev_rule_questions_tbl_type,
    x_dev_rule_qst_values_tbl	   OUT NOCOPY dev_rule_qst_values_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'get_rule_question_values';

    j                           BINARY_INTEGER :=0;


    --
    -- Currsor to Select Variable values for the Variables
    -- that are present in the  Deviations rule
    --
    --

    CURSOR l_get_rule_qst_values_csr(p_config_header_id NUMBER, p_config_rev_nbr NUMBER, p_question_id NUMBER) IS
    SELECT ltxt.localized_str question_value
      FROM cz_config_items_v config,
           cz_ps_nodes psn,
           cz_localized_texts ltxt
     WHERE config.config_hdr_id = p_config_header_id
       AND config.config_rev_nbr = p_config_rev_nbr
       AND config.ps_node_id = psn.ps_node_id
       AND psn.intl_text_id = ltxt.intl_text_id
       AND ltxt.LANGUAGE = USERENV('LANG')
       AND SUBSTR(config.orig_sys_ref, INSTR(config.orig_sys_ref,':',-1,2)+1,
               (INSTR(config.orig_sys_ref,':',-1,1) - (INSTR(config.orig_sys_ref,':',-1,2)+1))) = to_char(p_question_id);


/*    SELECT ps_node_name question_value
      FROM cz_config_items_v
     WHERE config_hdr_id = p_config_header_id
       AND config_rev_nbr = p_config_rev_nbr
       AND SUBSTR(orig_sys_ref, INSTR(orig_sys_ref,':',-1,2)+1,
               (INSTR(orig_sys_ref,':',-1,1) - (INSTR(orig_sys_ref,':',-1,2)+1))) = to_char(p_question_id);
       --AND orig_sys_ref LIKE 'OKC:DEVIATIONS:%' ;*/

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_config_rev_nbr : '||p_config_rev_nbr);
     -- Add Logs for printing deviations rule tbl
     IF p_dev_rule_questions_tbl IS NOT NULL THEN
     	IF p_dev_rule_questions_tbl.count > 0 THEN
		FOR i IN p_dev_rule_questions_tbl.first..p_dev_rule_questions_tbl.last LOOP
		   IF p_dev_rule_questions_tbl.EXISTS(i) THEN
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_questions_tbl.(' || i || ').rule_id : ' || to_char(p_dev_rule_questions_tbl(i).rule_id));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_dev_rule_questions_tbl.(' || i || ').question_id : ' || to_char(p_dev_rule_questions_tbl(i).question_id));
	           END IF;
	  	END LOOP;
        END IF;
     END IF;

  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Select Question value from Cz config table
    --
    /*FOR i IN p_dev_rule_questions_tbl.FIRST..p_dev_rule_questions_tbl.LAST
    LOOP
      IF p_dev_rule_questions_tbl.EXISTS(i) THEN
    	FOR l_get_rule_qst_values_rec IN l_get_rule_qst_values_csr(p_config_header_id, p_config_rev_nbr,
    	                                                           p_dev_rule_questions_tbl(i).question_id)
    	LOOP
           --x_dev_rule_qst_values_tbl(i).line_number 		:= 	p_dev_rule_questions_tbl(i).line_number;
           x_dev_rule_qst_values_tbl(i).rule_id 		:= 	p_dev_rule_questions_tbl(i).rule_id;
           x_dev_rule_qst_values_tbl(i).question_id 		:= 	p_dev_rule_questions_tbl(i).question_id;
           x_dev_rule_qst_values_tbl(i).question_value	 	:= 	l_get_rule_qst_values_rec.question_value;
  	END LOOP;
      END IF;
    END LOOP;*/

    -- Modified for Bug 4913135 since there is a separate funtion get_deviation_document_value function
    FOR i IN p_dev_rule_questions_tbl.FIRST..p_dev_rule_questions_tbl.LAST
    LOOP
          IF p_dev_rule_questions_tbl.EXISTS(i) THEN
               x_dev_rule_qst_values_tbl(i).rule_id 		        := 	p_dev_rule_questions_tbl(i).rule_id;
               x_dev_rule_qst_values_tbl(i).question_id 		:= 	p_dev_rule_questions_tbl(i).question_id;
               x_dev_rule_qst_values_tbl(i).question_value	 	:= 	null;
          END IF;
    END LOOP;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END get_rule_question_values;

PROCEDURE get_article_details(
    p_api_version      		IN  NUMBER,
    p_init_msg_list    		IN  VARCHAR2,
    p_document_id      		IN  NUMBER,
    p_document_type    		IN  VARCHAR2,
    p_article_id       		IN  NUMBER,
    p_effectivity_date 		IN  DATE,
    x_article_id       		OUT NOCOPY NUMBER,
    x_article_version_id 	OUT NOCOPY NUMBER,
    x_article_title		OUT NOCOPY VARCHAR2,
    x_article_description	OUT NOCOPY VARCHAR2,
    x_doc_lib           	OUT NOCOPY VARCHAR2,
    x_scn_heading		OUT NOCOPY VARCHAR2,
    x_return_status    		OUT NOCOPY VARCHAR2,
    x_msg_count        		OUT NOCOPY NUMBER,
    x_msg_data         		OUT NOCOPY VARCHAR2)
IS

l_article_id 		NUMBER;
l_article_version_id 	NUMBER;
l_doc_lib            	VARCHAR2(1);
l_api_version      	CONSTANT NUMBER := 1;
l_api_name         	CONSTANT VARCHAR2(30) := 'get_article_details';

l_xprt_scn_code                okc_terms_templates_all.xprt_scn_code%TYPE;
l_def_scn_code  	       okc_article_versions.default_section%TYPE;
l_scn_code 				   okc_sections_b.scn_code%TYPE;


l_article_number OKC_ARTICLES_ALL.article_number%TYPE;

--Bug#4757731 cursor to get clause title and clause description
CURSOR csr_clause_details(b_article_id NUMBER, b_article_version_id NUMBER) IS
SELECT article_title,article_description, a.article_number
FROM okc_articles_all a,okc_article_versions ver
WHERE a.article_id = b_article_id
AND a.article_id = ver.article_id
AND ver.article_version_id = b_article_version_id;

CURSOR get_doc_article_ver_id IS
select sav_sae_id, article_version_id from okc_k_articles_b
where document_id = p_document_id
and document_type = p_document_type
and ((sav_sae_id = p_article_id) or (ref_article_id = p_article_id))
and source_flag = 'R'
and rownum < 2;

-- From Library

CURSOR csr_lib_clause_desc_scn (b_article_id NUMBER, b_article_version_id NUMBER) IS
SELECT nvl(default_section,'UNASSIGNED') scn_code
FROM OKC_ARTICLE_VERSIONS VERS
 WHERE vers.article_id = b_article_id
   AND vers.article_version_id = b_article_version_id;

CURSOR csr_xprt_scn_code IS
SELECT NVL(t.xprt_scn_code,'UNASSIGNED')
  FROM okc_template_usages u,
       okc_terms_templates_all t
 WHERE u.template_id = t.template_id
   AND u.document_type = p_document_type
   AND u.document_id = p_document_id ;

CURSOR l_get_lib_scn_csr(b_scn_code VARCHAR2) IS
SELECT heading FROM OKC_SECTIONS_B
 WHERE scn_code     = b_scn_code
   AND rownum=1 ;

-- From Document

CURSOR l_get_doc_scn_csr (b_article_version_id NUMBER) IS
SELECT scn.heading
FROM OKC_SECTIONS_B scn,
     OKC_K_ARTICLES_B art
WHERE art.document_type=p_document_type
AND   art.document_id =p_document_id
AND   art.article_version_id = b_article_version_id  --Bug#4757731 replaced art.sav_sae_id with art.article_version_id
AND   art.scn_id = scn.id
AND   rownum=1 ;
--CLM changes  start
CURSOR art_def_scn_csr(p_article_id NUMBER,p_article_version_id NUMBER) IS
SELECT 'x' FROM okc_art_var_sections
WHERE article_id = p_article_id
AND article_version_id = p_article_version_id
AND ROWNUM=1;
l_art_var_exists VARCHAR2(1) := 'N';
--CLM changes end


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_document_id  : '||p_document_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_document_type : '||p_document_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_article_id : '||p_article_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_effectivity_date : '||to_char(p_effectivity_date));
  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;


	-- Step 1: Get Clause values from the old get_article_details api

	get_article_details(
	    p_api_version        => p_api_version,
	    p_init_msg_list      => p_init_msg_list,
	    p_document_id        => p_document_id,
	    p_document_type      => p_document_type,
	    p_article_id         => p_article_id,
	    p_effectivity_date   => p_effectivity_date,
	    x_article_id         => l_article_id,
	    x_article_version_id => l_article_version_id ,
	    x_doc_lib            => l_doc_lib,
	    x_return_status      => x_return_status,
	    x_msg_count          => x_msg_count,
     	x_msg_data           => x_msg_data);

	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	-- Step 2: Get Clause title, description and  section info

	--Bug#4757731 Get Clause Title and Clause Description
        OPEN  csr_clause_details(p_article_id,l_article_version_id);
        FETCH csr_clause_details into x_article_title,x_article_description,l_article_number;
        CLOSE csr_clause_details;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '102: x_article_id  : '||l_article_id);
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '102: x_article_version_id  : '||l_article_version_id);
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '102: x_doc_lib   : '||l_doc_lib );
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '102: x_article_title  : '||x_article_title);
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '102: x_article_description   : '||x_article_description );
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '102: l_article_number   : '||l_article_number );

        END IF;

        -- If expert suggested clause is made non-std on the document then x_article_title is null
        IF(x_article_title is  null) THEN
           OPEN get_doc_article_ver_id;
           FETCH get_doc_article_ver_id INTO l_article_id,l_article_version_id;
           CLOSE get_doc_article_ver_id;

           OPEN csr_clause_details(l_article_id,l_article_version_id);
           FETCH csr_clause_details into x_article_title,x_article_description,l_article_number;
           CLOSE csr_clause_details;

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '103: l_article_id  : '||l_article_id);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '103: l_article_version_id  : '||l_article_version_id);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '103: x_article_title  : '||x_article_title);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '103: x_article_description   : '||x_article_description );
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '103: l_article_number   : '||l_article_number );


        END IF;

        END IF;
	--End Bug#4757731

  IF g_concat_art_no= 'Y' THEN
     IF l_article_number IS NOT NULL THEN
        x_article_title := SubStr((l_article_number ||':' || x_article_title),1,450);
     END IF;
  END IF;

        --Get Section Heading
	IF l_doc_lib = 'L' THEN
--CLM changes start
 OPEN art_def_scn_csr(p_article_id,l_article_version_id);
 FETCH art_def_scn_csr INTO l_art_var_exists;
 CLOSE art_def_scn_csr;

 IF (l_art_var_exists = 'x') THEN
 OKC_CLM_PKG.get_default_scn_code (
 p_api_version        => p_api_version,
 p_init_msg_list      => p_init_msg_list,
 p_article_id         => p_article_id,
 p_article_version_id => l_article_version_id,
 p_doc_id             => p_document_id,
 p_doc_type           => p_document_type,
 x_default_scn_code   => l_def_scn_code,
 x_return_status      => x_return_status
 ) ;
  l_scn_code := l_def_scn_code;
END IF;
IF ((l_art_var_exists = 'x' AND l_def_scn_code IS NULL) OR l_art_var_exists <> 'x') THEN
  --CLM changes end
	   OPEN csr_lib_clause_desc_scn(p_article_id,l_article_version_id);
	   FETCH csr_lib_clause_desc_scn INTO l_def_scn_code;
           CLOSE csr_lib_clause_desc_scn;

           l_scn_code := l_def_scn_code;

	   OPEN csr_xprt_scn_code;
	   FETCH csr_xprt_scn_code INTO l_xprt_scn_code;
           CLOSE csr_xprt_scn_code;

           IF l_def_scn_code = 'UNASSIGNED' THEN
	     l_scn_code := l_xprt_scn_code;
           END IF;
  END IF; --end if for CLM

	   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '104: l_def_scn_code  : '||l_def_scn_code);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '104: l_xprt_scn_code  : '||l_xprt_scn_code);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
		  '104: l_scn_code  : '|| l_scn_code);
           END IF;

           --Bug#4865126 Need to pass l_scn_code.Not l_xprt_scn_code
	   OPEN l_get_lib_scn_csr(l_scn_code);
	   FETCH l_get_lib_scn_csr INTO x_scn_heading;
           CLOSE l_get_lib_scn_csr;
	END IF;

	IF l_doc_lib = 'D' THEN

	  OPEN l_get_doc_scn_csr(l_article_version_id);
	  FETCH l_get_doc_scn_csr INTO x_scn_heading;
          CLOSE l_get_doc_scn_csr;
        END IF;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);
END get_article_details;

PROCEDURE populate_terms_deviations_tbl(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_sequence_id 	  	   IN NUMBER,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_rule_qst_values_tbl	   IN dev_rule_qst_values_tbl_type,
    p_rule_var_values_tbl	   IN dev_rule_var_values_tbl_type,
    p_clause_tbl	           IN expert_articles_tbl_type,
    p_mode			   IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'populate_terms_deviations_tbl';

    j                           BINARY_INTEGER :=0;
    l_rule_name			okc_xprt_rule_hdrs_all.rule_name%TYPE;
    l_rule_description		okc_xprt_rule_hdrs_all.rule_description%TYPE;
    l_item_name			MTL_SYSTEM_ITEMS_VL.concatenated_segments%TYPE;
    l_item_description		MTL_SYSTEM_ITEMS_VL.description%TYPE;

    l_article_id           	NUMBER;
    l_article_version_id        NUMBER;
    l_article_title		VARCHAR2(2000);
    l_article_description	VARCHAR2(2000);
    l_doc_lib           	VARCHAR2(1);
    l_scn_heading		VARCHAR2(300);

    l_item_id                   NUMBER;
    l_org_id                    NUMBER;
    l_rule_var_values_tbl  dev_rule_var_values_tbl_type;

    --For Bug 5327362
    l_rule_qst_values_tbl  dev_rule_qst_values_tbl_type;

    --
    -- Currsor to Select Deviation Rule name and description
    --
    CURSOR l_get_rul_details_csr (p_rule_id NUMBER) IS
    SELECT rule_name,
           rule_description
      FROM okc_xprt_rule_hdrs_all
     WHERE rule_id = p_rule_id;

    --
    -- Currsor to Select Item name and Description
    --
    CURSOR l_get_item_details_csr (p_item_id NUMBER, p_org_id NUMBER) IS
    SELECT concatenated_segments,
           description
      FROM mtl_system_items_vl
     WHERE inventory_item_id = p_item_id
       AND organization_id = p_org_id;

    --
    -- Currsor to Select Item name and Description
    --
    CURSOR l_line_item_details_csr (p_line_number VARCHAR2) IS
    SELECT item_id,
           org_id
      FROM okc_xprt_deviations_t
     WHERE line_number = p_line_number
     and   run_id = p_sequence_id;

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     -- Add Logs for printing deviations rule tbl
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_document_id  : '||p_document_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_document_type : '||p_document_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_sequence_id : '||p_sequence_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_config_rev_nbr : '||p_config_rev_nbr);
     IF p_rule_qst_values_tbl IS NOT NULL THEN
     	IF p_rule_qst_values_tbl.count > 0 THEN
		FOR i IN p_rule_qst_values_tbl.first..p_rule_qst_values_tbl.last LOOP
		  IF p_rule_qst_values_tbl.EXISTS(i) THEN
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_qst_values_tbl.(' || i || ').rule_id : ' || to_char(p_rule_qst_values_tbl(i).rule_id));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_qst_values_tbl.(' || i || ').question_id : ' || to_char(p_rule_qst_values_tbl(i).question_id));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_qst_values_tbl.(' || i || ').question_value : ' || to_char(p_rule_qst_values_tbl(i).question_value));
	  	  END IF;
	  	END LOOP;
        END IF;
     END IF;
     IF p_rule_var_values_tbl IS NOT NULL THEN
     	IF p_rule_var_values_tbl.count > 0 THEN
		FOR i IN p_rule_var_values_tbl.first..p_rule_var_values_tbl.last LOOP
		  IF p_rule_var_values_tbl.EXISTS(i) THEN
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_var_values_tbl.(' || i || ').line_number : ' || to_char(p_rule_var_values_tbl(i).line_number));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_var_values_tbl.(' || i || ').rule_id : ' || to_char(p_rule_var_values_tbl(i).rule_id));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_var_values_tbl.(' || i || ').variable_id : ' || to_char(p_rule_var_values_tbl(i).variable_id));
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_rule_var_values_tbl.(' || i || ').variable_value : ' || p_rule_var_values_tbl(i).variable_value);
	  	   END IF;
	  	END LOOP;
        END IF;
     END IF;
     IF p_clause_tbl IS NOT NULL THEN
     	IF p_clause_tbl.count > 0 THEN
		FOR i IN p_clause_tbl.first..p_clause_tbl.last LOOP
		  IF p_clause_tbl.EXISTS(i) THEN
	     		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    'p_clause_tbl.(' || i || ') : ' || to_char(p_clause_tbl(i)));
	  	  END IF;
	  	END LOOP;
        END IF;
     END IF;
  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --In case of Buy side line_nubers will be null
    --if Line_Number is null then assign -99 as line_number
    l_rule_var_values_tbl := p_rule_var_values_tbl;
    IF l_rule_var_values_tbl IS NOT NULL THEN
      IF l_rule_var_values_tbl.count > 0 THEN
    	FOR i IN l_rule_var_values_tbl.first..l_rule_var_values_tbl.last LOOP
    	  IF l_rule_var_values_tbl.EXISTS(i) THEN
             if(l_rule_var_values_tbl(i).line_number is null) then
                 l_rule_var_values_tbl(i).line_number := '-99';
             end if;
	     -- Begin: Fix for bug 5182270
             if (is_rule_line_level(l_rule_var_values_tbl(i).rule_id) = 'N') then
                 l_rule_var_values_tbl(i).line_number := '-99';
             end if;
	     -- End: Fix for bug 5182270
	     -- Begin: Fix for bug 5327362
             if (is_rule_line_level(l_rule_var_values_tbl(i).rule_id) = 'Y' and
                 l_rule_var_values_tbl(i).line_number = '-99') then
                 l_rule_var_values_tbl.DELETE(i);
             end if;
	     -- End: Fix for bug 5327362
	  END IF;
  	END LOOP;
      END IF;
    END IF;

	     -- Begin: Fix for bug 5327362
    l_rule_qst_values_tbl := p_rule_qst_values_tbl;
    IF l_rule_qst_values_tbl IS NOT NULL THEN
      IF l_rule_qst_values_tbl.count > 0 THEN
    	FOR i IN l_rule_qst_values_tbl.first..l_rule_qst_values_tbl.last LOOP
    	  IF l_rule_qst_values_tbl.EXISTS(i) THEN
             if (is_rule_line_level(l_rule_qst_values_tbl(i).rule_id) = 'Y') then
                 l_rule_qst_values_tbl.DELETE(i);
             end if;
	  END IF;
  	END LOOP;
      END IF;
    END IF;
    -- End: Fix for bug 5327362


    --
    -- Insert Variable value into temp table
    --
    IF l_rule_var_values_tbl.count > 0 THEN
    FOR i IN l_rule_var_values_tbl.FIRST..l_rule_var_values_tbl.LAST
    LOOP
	  IF l_rule_var_values_tbl.EXISTS(i) THEN
	    OPEN  l_get_rul_details_csr(l_rule_var_values_tbl(i).rule_id);
	    FETCH l_get_rul_details_csr INTO l_rule_name,l_rule_description;
	    CLOSE l_get_rul_details_csr;

	    OPEN  l_line_item_details_csr(l_rule_var_values_tbl(i).line_number);
	    FETCH l_line_item_details_csr INTO l_item_id,l_org_id;
	    CLOSE l_line_item_details_csr;

	    OPEN  l_get_item_details_csr(l_item_id,l_org_id);
	    FETCH l_get_item_details_csr INTO l_item_name,l_item_description;
	    CLOSE l_get_item_details_csr;


	-- Insert header variables into okc_terms_deviations_t


	    INSERT INTO OKC_TERMS_DEVIATIONS_T
	    (
	     SEQUENCE_ID,
	     DOCUMENT_TYPE,
	     DOCUMENT_ID,
	     DEVIATION_TYPE,
	     RULE_ID,
	     DEVIATION_CODE,
	     DEVIATION_CODE_MEANING,
	     LINE_NUMBER,
	     ITEM_NAME,
	     ITEM_DESCRIPTION,
	     OBJECT_TYPE,
	     OBJECT_CODE,
	     OBJECT_DESCRIPTION,
	     DOCUMENT_VALUE,
	     CONFIG_HEADER_ID,
	     CONFIG_REVISION_NUMBER
	    )
	    VALUES
	    (
	     p_sequence_id,  		     		     	                                        --SEQUENCE_ID,
           p_document_type,		     		     	                                        --DOCUMENT_TYPE,
	     p_document_id,		     		     		                                --DOCUMENT_ID,
	     'P',			     		     			                        --DEVIATION_TYPE,
	     l_rule_var_values_tbl(i).rule_id,  	     	                                        --RULE_ID,
	     l_rule_name,		     		     		                                --DEVIATION_CODE,
	     l_rule_description,	     			     	                                --DEVIATION_CODE_MEANING,
           l_rule_var_values_tbl(i).line_number,	     	                                        --LINE_NUMBER,
	     -- Begin: Fix for bug 5182270.If line_number is -99 then putting NULL for Item and Item Desc.So that
           -- in VO query Distinct Clause can remove duplicate header level rules
           DECODE(l_rule_var_values_tbl(i).line_number,'-99',NULL,l_item_name),			--ITEM_NAME,
           DECODE(l_rule_var_values_tbl(i).line_number,'-99',NULL,l_item_description),		--ITEM_DESCRIPTION,
	     'VARIABLE',		     	--OBJECT_TYPE,
	     l_rule_var_values_tbl(i).variable_id,   	--OBJECT_VALUE,
	     null,					     			                        --OBJECT_DESCRIPTION,
	     DECODE(l_rule_var_values_tbl(i).line_number,'-99',NULL,l_rule_var_values_tbl(i).variable_value),   --DOCUMENT_VALUE,
	     -- End: Fix for bug 5182270
	     p_config_header_id,			     			                        --CONFIG_HEADER_ID,
	     p_config_rev_nbr				    	 		                        --CONFIG_REVISION_NUMBER
	    );

       END IF;
    END LOOP;
    END IF;

    --
    -- Select Question responses in to temp table
    --
    IF l_rule_qst_values_tbl.count > 0 THEN
    FOR i IN l_rule_qst_values_tbl.FIRST..l_rule_qst_values_tbl.LAST
    LOOP
       IF l_rule_qst_values_tbl.EXISTS(i) THEN

	    OPEN  l_get_rul_details_csr(l_rule_qst_values_tbl(i).rule_id);
	    FETCH l_get_rul_details_csr INTO l_rule_name,l_rule_description;
	    CLOSE l_get_rul_details_csr;

	    --OPEN  l_get_item_details_csr(l_rule_qst_values_tbl(i).rule_id);
	    --FETCH l_get_item_details_csr INTO l_item_name,l_item_description;
	    --CLOSE l_get_item_details_csr;


	-- Insert header variables into okc_terms_deviations_t


	INSERT INTO OKC_TERMS_DEVIATIONS_T
	    (
	     SEQUENCE_ID,
	     DOCUMENT_TYPE,
	     DOCUMENT_ID,
	     DEVIATION_TYPE,
	     RULE_ID,
	     DEVIATION_CODE,
	     DEVIATION_CODE_MEANING,
	     LINE_NUMBER,
	     ITEM_NAME,
	     ITEM_DESCRIPTION,
	     OBJECT_TYPE,
	     OBJECT_CODE,
	     OBJECT_DESCRIPTION,
	     DOCUMENT_VALUE,
	     CONFIG_HEADER_ID,
	     CONFIG_REVISION_NUMBER
	    )
	    VALUES
	    (
	     p_sequence_id,  		     		     --SEQUENCE_ID,
          p_document_type,		     		     --DOCUMENT_TYPE,
	     p_document_id,		     		     --DOCUMENT_ID,
	     'P',			     		     --DEVIATION_TYPE,
	     l_rule_qst_values_tbl(i).rule_id,  	     --RULE_ID,
	     l_rule_name,		     		     --DEVIATION_CODE,
	     l_rule_description,	     		     --DEVIATION_CODE_MEANING,
             --NULL                                ,           --LINE_NUMBER,
             '-99', -- l_rule_qst_values_tbl(i).line_number,   --LINE_NUMBER,
	     null,		     	    	     	     --ITEM_NAME,
             null,	     		     	     	     --ITEM_DESCRIPTION,
	     'QUESTION',		     		     --OBJECT_TYPE,
	     l_rule_qst_values_tbl(i).question_id,	     --OBJECT_VALUE,
	     null,					     --OBJECT_DESCRIPTION,
	     l_rule_qst_values_tbl(i).question_value,  	     --DOCUMENT_VALUE,
	     p_config_header_id,			     --CONFIG_HEADER_ID,
	     p_config_rev_nbr			     	     --CONFIG_REVISION_NUMBER
	    );
       END IF;
    END LOOP;
    END IF;

    --
    -- Insert Clause details into temp table
    --
    IF (p_clause_tbl.COUNT > 0 AND p_mode <> 'BV') THEN
    FOR i IN p_clause_tbl.FIRST..p_clause_tbl.LAST
    LOOP
      IF p_clause_tbl.EXISTS(i) THEN
 	get_article_details(
		    p_api_version        	  => 1.0,
		    p_init_msg_list      	  => FND_API.G_FALSE,
		    p_document_type           	  => p_document_type,
		    p_document_id             	  => p_document_id,
		    p_article_id        	  => p_clause_tbl(i),
		    p_effectivity_date      	  => sysdate,
		    x_article_id           	  => l_article_id,
		    x_article_version_id          => l_article_version_id,
		    x_article_title		  => l_article_title,
		    x_article_description	  => l_article_description,
		    x_doc_lib           	  => l_doc_lib,
		    x_scn_heading		  => l_scn_heading,
		    x_return_status		  => x_return_status,
		    x_msg_count			  => x_msg_count,
		    x_msg_data			  => x_msg_data);

	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Insert Clause details into okc_terms_deviations_t


	    INSERT INTO OKC_TERMS_DEVIATIONS_T
	    (
	     SEQUENCE_ID,
	     DOCUMENT_TYPE,
	     DOCUMENT_ID,
	     DEVIATION_TYPE,
	     DOC_ARTICLE_ID,
	     DOC_ARTICLE_VERSION_ID,
	     ARTICLE_TITLE,
	     ARTICLE_DESCRIPTION,
	     SECTION_HEADING,
	     CONFIG_HEADER_ID,
	     CONFIG_REVISION_NUMBER
	    )
	    VALUES
	    (
	     p_sequence_id,  		     		     --SEQUENCE_ID,
             p_document_type,		     		     --DOCUMENT_TYPE,
	     p_document_id,		     		     --DOCUMENT_ID,
	     'C',			     		     --DEVIATION_TYPE,
	     p_clause_tbl(i),				     --DOC_ARTICLE_ID,
	     NULL,		     		             --DOC_ARTICLE_VERSION_ID
	     l_article_title,	     		                     --ARTICLE_TITLE,
	     l_article_description,   		     		     --ARTICLE_DESCRIPTION,
             l_scn_heading, 					     --SECTION_HEADING,
	     p_config_header_id,			     --CONFIG_HEADER_ID,
	     p_config_rev_nbr			     	     --CONFIG_REVISION_NUMBER
	    );
       END IF;
    END LOOP;
    END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END populate_terms_deviations_tbl;


PROCEDURE get_expert_results(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_config_header_id             IN NUMBER,
    p_config_rev_nbr               IN NUMBER,
    p_mode		           IN VARCHAR2,
    p_sequence_id 	  	   IN OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name CONSTANT VARCHAR2(30) := 'get_expert_results';

    j                           BINARY_INTEGER :=0;

    l_hdr_var_value_tbl 	OKC_XPRT_XRULE_VALUES_PVT.var_value_tbl_type;
    l_line_sysvar_value_tbl 	OKC_XPRT_XRULE_VALUES_PVT.line_sys_var_value_tbl_type;
    l_line_count		NUMBER;
    l_line_variables_count      NUMBER;
    l_intent			VARCHAR2(1);
    l_org_id			NUMBER;

    l_expert_clauses_tbl	expert_articles_tbl_type;
    l_expert_deviations_tbl     dev_rule_tbl_type;
    l_rule_questions_tbl	dev_rule_questions_tbl_type;
    l_rule_variables_tbl	dev_rule_variables_tbl_type;
    l_rule_var_values_tbl	dev_rule_var_values_tbl_type;
    l_rule_qst_values_tbl	dev_rule_qst_values_tbl_type;

BEGIN


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    'Parameters : ');
     -- Add Logs for printing deviations rule tbl
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_document_id  : '||p_document_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_document_type : '||p_document_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_config_header_id : '||p_config_header_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_config_rev_nbr : '||p_config_rev_nbr);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_mode : '||p_mode);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
		  G_MODULE||l_api_name,
		  '101: p_sequence_id : '||p_sequence_id);

  END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    --
    -- Check mode and set value for p_sequence_id for 'RUN' - runtime mode only
    -- as the value of p_sequence_id is passed in the 'BV' mode
    --
    IF (p_mode = 'RUN') THEN
        SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO p_sequence_id from DUAL;
    END IF;


    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Step 1: Get Document values from the Extension rule api

   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '110: Step 1: Get Document values from the Extension rule api');
	        END IF;

		OKC_XPRT_XRULE_VALUES_PVT.get_document_values (
		    p_api_version        	  => 1.0,
		    p_init_msg_list      	  => FND_API.G_FALSE,
		    p_doc_type           	  => p_document_type,
		    p_doc_id             	  => p_document_id,
		    x_return_status      	  => x_return_status,
		    x_msg_data           	  => x_msg_data,
		    x_msg_count          	  => x_msg_count,
		    x_hdr_var_value_tbl           => l_hdr_var_value_tbl,
		    x_line_sysvar_value_tbl       => l_line_sysvar_value_tbl,
		    x_line_count		  => l_line_count,
		    x_line_variables_count        => l_line_variables_count,
		    x_intent                      => l_intent,
		    x_org_id 			  => l_org_id);

		    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     	      	    THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;


	-- Step 2: Insert values into okc_xprt_deviations_gt

   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '120: Step 2: Insert values into okc_xprt_deviations_gt');
	        END IF;

   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '121: l_hdr_var_value_tbl.COUNT :' || TO_CHAR(l_hdr_var_value_tbl.COUNT));
	        END IF;

		  IF l_hdr_var_value_tbl.COUNT > 0 THEN

		    FOR i IN l_hdr_var_value_tbl.FIRST..l_hdr_var_value_tbl.LAST
		    LOOP
			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '122: l_hdr_var_value_tbl( '|| i || ').variable_code :' || l_hdr_var_value_tbl(i).variable_code);
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '123: l_hdr_var_value_tbl( '|| i || ').variable_value_id :' || l_hdr_var_value_tbl(i).variable_value_id);
			END IF;


		       -- Insert header variables into okc_xprt_deviations_gt

			    INSERT INTO OKC_XPRT_DEVIATIONS_T
			    (
			     RUN_ID,
			     LINE_NUMBER,
			     VARIABLE_CODE,
			     VARIABLE_VALUE,
			     ITEM_ID,
			     ORG_ID,
			     CREATION_DATE
			    )
			    VALUES
			    (
			     p_sequence_id,                            -- RUN_ID
			     '-99',                                    -- LINE_NUMBER
			     l_hdr_var_value_tbl(i).variable_code,     -- VARIABLE_CODE
			     l_hdr_var_value_tbl(i).variable_value_id, -- VARIABLE_VALUE
			     NULL, 				       -- ITEM_ID
			     NULL, 				       -- ORG_ID
			     SYSDATE
			    );
		    END LOOP;
		  END IF;


   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '124: l_line_sysvar_value_tbl.COUNT :' || TO_CHAR(l_line_sysvar_value_tbl.COUNT));
	        END IF;

		  IF l_line_sysvar_value_tbl.COUNT > 0 THEN

		    FOR i IN l_line_sysvar_value_tbl.FIRST..l_line_sysvar_value_tbl.LAST
		    LOOP

			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '125: l_line_sysvar_value_tbl( '|| i || ').line_number :' || l_line_sysvar_value_tbl(i).line_number);
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '126: l_line_sysvar_value_tbl( '|| i || ').variable_code :' || l_line_sysvar_value_tbl(i).variable_code);
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '127: l_line_sysvar_value_tbl( '|| i || ').variable_value :' || l_line_sysvar_value_tbl(i).variable_value);
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '128: l_line_sysvar_value_tbl( '|| i || ').item_id :' || l_line_sysvar_value_tbl(i).item_id);
			     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
					    G_MODULE||l_api_name,
					    '129: l_line_sysvar_value_tbl( '|| i || ').org_id :' || l_line_sysvar_value_tbl(i).org_id);
			END IF;

		       -- Insert line variables into okc_xprt_deviations_t

			    INSERT INTO OKC_XPRT_DEVIATIONS_T
			    (
			     RUN_ID,
			     LINE_NUMBER,
			     VARIABLE_CODE,
			     VARIABLE_VALUE,
			     ITEM_ID,
			     ORG_ID,
			     CREATION_DATE
			    )
			    VALUES
			    (
			     p_sequence_id,
			     l_line_sysvar_value_tbl(i).line_number,   -- LINE_NUMBER
			     l_line_sysvar_value_tbl(i).variable_code, -- VARIABLE_CODE
			     l_line_sysvar_value_tbl(i).variable_value,-- VARIABLE_VALUE
			     l_line_sysvar_value_tbl(i).item_id,       -- ITEM_ID
			     l_line_sysvar_value_tbl(i).org_id,         -- ORG_ID
			     SYSDATE
			    );
		    END LOOP;
		  END IF;


	  -- Step 3: Get Clauses and Deviations from cz_config_items_v

   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '130: Step 3: Get Clauses and Deviations from cz_config_items_v');
	        END IF;

                    get_expert_selections(
                       p_api_version      	=> 1.0,
                       p_init_msg_list    	=> FND_API.G_FALSE,
                       p_document_id      	=> p_document_id,
                       p_document_type          => p_document_type,
                       p_config_header_id 	=> p_config_header_id,
                       p_config_rev_nbr   	=> p_config_rev_nbr,
                       x_expert_clauses_tbl     => l_expert_clauses_tbl,
                       x_expert_deviations_tbl  => l_expert_deviations_tbl,
                       x_return_status    	=> x_return_status,
                       x_msg_data         	=> x_msg_data,
                       x_msg_count        	=> x_msg_count);


		      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		      THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;


	 -- Step 4: For each Deviation rule get unique list of variables and Questions

   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '140: Step 4: For each Deviation rule get unique list of variables and Questions');
	        END IF;

	        IF l_expert_deviations_tbl.COUNT > 0 THEN
		    get_rule_details(
		       p_api_version      	=> 1.0,
		       p_init_msg_list    	=> FND_API.G_FALSE,
		       p_dev_rule_tbl      	=> l_expert_deviations_tbl,
		       x_dev_rule_questions_tbl => l_rule_questions_tbl,
		       x_dev_rule_variables_tbl => l_rule_variables_tbl,
		       x_return_status    	=> x_return_status,
		       x_msg_data         	=> x_msg_data,
		       x_msg_count        	=> x_msg_count);


		      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		      THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;


	  -- Step 5: For variables in rule get value from okc_xprt_deviations_gt

	IF l_rule_variables_tbl.COUNT > 0 THEN
   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '150: Step 5: For variables in rule get value from okc_xprt_deviations_gt');
	        END IF;

                    get_rule_variable_values(
                       p_api_version      	 => 1.0,
                       p_init_msg_list    	 => FND_API.G_FALSE,
                       p_sequence_id		 => p_sequence_id,
                       p_dev_rule_variables_tbl  => l_rule_variables_tbl,
                       x_dev_rule_var_values_tbl => l_rule_var_values_tbl,
                       x_return_status    	 => x_return_status,
                       x_msg_data         	 => x_msg_data,
                       x_msg_count        	 => x_msg_count);

		      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		      THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;
	END IF;


	  -- Step 6: For questions in rule get value from cz_config_items_v

	IF l_rule_questions_tbl.COUNT > 0 THEN
   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '160: Step 6: For questions in rule get value from cz_config_items_v');
	        END IF;

                    get_rule_question_values(
                       p_api_version      	 => 1.0,
                       p_init_msg_list    	 => FND_API.G_FALSE,
                       p_config_header_id        => p_config_header_id,
                       p_config_rev_nbr          => p_config_rev_nbr,
                       p_dev_rule_questions_tbl  => l_rule_questions_tbl,
                       x_dev_rule_qst_values_tbl => l_rule_qst_values_tbl,
                       x_return_status    	 => x_return_status,
                       x_msg_data         	 => x_msg_data,
                       x_msg_count        	 => x_msg_count);


		      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		      THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;

	     END IF; -- Check for presence of Deviations from Expert
	END IF;

	  -- Step 7: Insert Clauses and Terms deviations into okc_terms_deviations_t

   	        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
				    G_MODULE||l_api_name,
				    '170: Step 7: Insert Clauses and Terms deviations into okc_terms_deviations_t');
	        END IF;

                    populate_terms_deviations_tbl(
                       p_api_version      	=> 1.0,
                       p_init_msg_list    	=> FND_API.G_FALSE,
                       p_document_id      	=> p_document_id,
                       p_document_type          => p_document_type,
                       p_sequence_id		=> p_sequence_id,
                       p_config_header_id 	=> p_config_header_id,
                       p_config_rev_nbr   	=> p_config_rev_nbr,
                       p_rule_qst_values_tbl    => l_rule_qst_values_tbl,
                       p_rule_var_values_tbl    => l_rule_var_values_tbl,
                       p_clause_tbl		=> l_expert_clauses_tbl,
                       p_mode			=> p_mode,
                       x_return_status    	=> x_return_status,
                       x_msg_data         	=> x_msg_data,
                       x_msg_count        	=> x_msg_count);


		      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		      THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		      END IF;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	     p_data => x_msg_data
  		);

END get_expert_results;

---------------------------------------------------
--  Function:
---------------------------------------------------
FUNCTION check_template_has_questions (
    p_template_id    IN NUMBER
)
RETURN VARCHAR2 IS

CURSOR c1 IS
--Check if the Template has Active rules with questions
SELECT 'X'
FROM okc_xprt_question_orders
WHERE question_rule_status = 'ACTIVE'
AND template_id = p_template_id;

l_value  VARCHAR2(1) := 'N';
l_dummy  VARCHAR2(1);

BEGIN

  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%FOUND THEN
    l_value := 'Y';
  END IF;
  CLOSE c1;

 RETURN l_value;
EXCEPTION
 WHEN OTHERS THEN
      --close cursors
     IF c1%ISOPEN THEN
       CLOSE c1;
     END IF;
     l_value := 'N';
     RETURN l_value;
END check_template_has_questions;



/*========================================================================+
         Procedure:  contract_expert_bv
         Description:  For R12 - Support for line level deviations
+========================================================================*/

PROCEDURE contract_expert_bv(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_bv_mode                      IN VARCHAR2 , -- QA is only valid mode in 11.5.10;
                                                 -- Deviation pushed to post 11.5.10.
    p_sequence_id 	  	   IN NUMBER,
    x_qa_result_tbl                IN OUT NOCOPY OKC_TERMS_QA_GRP.qa_result_tbl_type,
    x_expert_articles_tbl          OUT NOCOPY expert_articles_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)

IS

    L_COMPLETE VARCHAR2(10);
    L_VALID VARCHAR2(10);

    l_api_name CONSTANT VARCHAR2(30) := 'contract_expert_bv';
    l_api_version CONSTANT NUMBER := 1;

    -- Expert Profile Value and Template Expert Flag
    l_ce_enabled                VARCHAR2(50);
    l_template_ce_enabled       okc_terms_templates_all.contract_expert_enabled%TYPE;

    -- Header Information related local variables
    l_config_header_id NUMBER;
    l_config_rev_nbr NUMBER;
    l_new_config_header_id NUMBER;
    l_new_config_rev_nbr NUMBER;
    l_template_id    NUMBER;
    l_publication_id NUMBER;
    l_valid_config VARCHAR2(10);
    l_complete_config VARCHAR2(10);
    l_qa_tbl_index NUMBER;
    l_sequence_id NUMBER;

    l_cz_xml_init_msg VARCHAR2(2000);
    l_xml_terminate_msg LONG;
    l_cz_cfg_msgs CZ_CF_API.CFG_OUTPUT_PIECES;
    l_validation_status NUMBER;

    -- Severity related local variables
    l_expert_not_applied_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_expert_not_applied_sev_e      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_expert_not_applied_sev_w      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_expert_not_applied_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_expert_not_applied    VARCHAR2(1);

    l_expert_partially_run_desc     OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_expert_partially_run_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_perf_expert_partially_run     VARCHAR2(1);

    l_invalid_config_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_invalid_config_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_invalid_config    VARCHAR2(1);

    l_incomplt_config_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_incomplt_config_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_incomplt_config    VARCHAR2(1);

    l_new_expert_article_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_new_expert_article_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_new_expert_art VARCHAR2(1);

    l_old_expert_article_sev      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_old_expert_article_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perf_old_expert_art VARCHAR2(1);

    --Start - Added by kartik dummy variable
    l_count_articles_dropped NUMBER;
    --End - Added by kartik

    l_expert_articles_tbl expert_articles_tbl_type;
    l_ce_finish_flag 		  VARCHAR2(1);
    l_has_responses VARCHAR2(1) := 'N';
    l_has_questions VARCHAR2(1);

    --
    -- Cursor to get template information
    --
    CURSOR l_get_template_info_csr IS
	    SELECT u.config_header_id,
		   u.config_revision_number,
		   nvl(u.contract_expert_finish_flag, 'N'),
		   t.template_id,
		   t.contract_expert_enabled
	    FROM okc_template_usages u,
		 okc_terms_templates_all t
	    WHERE t.template_id = u.template_id
	      AND u.document_type= p_document_type
	      AND u.document_id =  p_document_id;


BEGIN
	-- Initialising default values
	L_COMPLETE := 'true';
	L_VALID := 'true';

	-- Initialising severity local variables
	l_expert_not_applied_sev_e := 'E';
	l_expert_not_applied_sev_w := 'W';

	-- start debug log
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'Parameters : ');
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'p_document_id : '||p_document_id);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'p_document_type : '||p_document_type);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'p_bv_mode : '||p_bv_mode);
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'p_sequence_id : '||p_sequence_id);

	END IF;


	--
	--  Initialize API return status to success
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	--
	-- Standard call to check for call compatibility.
	--
	IF NOT FND_API.Compatible_API_Call (l_api_version,
				p_api_version,
				l_api_name,
				G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--
	-- Initialize message list if p_init_msg_list is set to TRUE.
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;


	--
	-- Check if CE Profile is Enabled.
	--
	FND_PROFILE.GET(name=> 'OKC_K_EXPERT_ENABLED', val => l_ce_enabled);

	IF NVL(l_ce_enabled,'N') = 'N' THEN
		-- Not Expert enabled, skip BV
		x_msg_data := G_OKC_EXPRT_PROFILE_DISABLED;
		RETURN;
	END IF;


	-- If mode is not authoring then get QA code Severities and Names

	IF p_bv_mode <> 'AUTH' THEN

		--
		-- Get Not Applied QA Code Severity and Name
		--
		get_qa_code_detail(p_document_type => p_document_type,
			       p_qa_code =>  G_CHECK_EXPERT_NOT_APPLIED ,
			       x_perform_qa    => l_perf_expert_not_applied,
			       x_qa_name       => l_expert_not_applied_desc,
			       x_severity_flag => l_expert_not_applied_sev,
			       x_return_status => x_return_status);

		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		END IF;

		--
		-- Get Partially Applied QA Code Severity and Name
		--
		get_qa_code_detail(p_document_type => p_document_type,
			       p_qa_code =>  G_CHECK_EXPERT_PARTIALLY_RUN ,
			       x_perform_qa    => l_perf_expert_partially_run,
			       x_qa_name       => l_expert_partially_run_desc,
			       x_severity_flag => l_expert_partially_run_sev,
			       x_return_status => x_return_status);

		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		END IF;

		--
		-- Get Invalid Config QA Code Severity and Name
		--
		get_qa_code_detail(p_document_type => p_document_type,
			       p_qa_code =>  G_CHECK_INVALID_CONFIG ,
			       x_perform_qa    => l_perf_invalid_config,
			       x_qa_name       => l_invalid_config_desc,
			       x_severity_flag => l_invalid_config_sev,
			       x_return_status => x_return_status);

		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		END IF;


		--
		-- Get Incomplete Config QA Code Severity and Name
		--
		get_qa_code_detail(p_document_type => p_document_type,
			       p_qa_code =>  G_CHECK_INCOMPLT_CONFIG ,
			       x_perform_qa    => l_perf_incomplt_config,
			       x_qa_name       => l_incomplt_config_desc,
			       x_severity_flag => l_incomplt_config_sev,
			       x_return_status => x_return_status);

		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		END IF;

		--
		-- Get New Article QA Code Severity and Name
		--
		get_qa_code_detail(p_document_type => p_document_type,
			       p_qa_code =>  G_CHECK_NEW_EXPERT_ART ,
			       x_perform_qa    => l_perf_new_expert_art,
			       x_qa_name       => l_new_expert_article_desc,
			       x_severity_flag => l_new_expert_article_sev,
			       x_return_status => x_return_status);

		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		END IF;


		--
		-- Get Old Article QA Code Severity and Name
		--
		get_qa_code_detail(p_document_type => p_document_type,
			       p_qa_code =>  G_CHECK_OLD_EXPERT_ART ,
			       x_perform_qa    => l_perf_old_expert_art,
			       x_qa_name       => l_old_expert_article_desc,
			       x_severity_flag => l_old_expert_article_sev,
			       x_return_status => x_return_status);

		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		END IF;

		--
		-- Contract Expert QA Checks are inter-dependent.
		-- Therefore, if any one of the qa codes for
		-- Contract Expert is enabled, then all checks
		-- will be executed.
		--
		--  Bug 4773590 Commented below stmt
		/*IF (l_perf_expert_not_applied <> 'Y' AND
		l_perf_invalid_config <> 'Y' AND l_perf_incomplt_config <> 'Y' AND
		l_perf_old_expert_art <> 'Y' AND  l_perf_new_expert_art <> 'Y')
		THEN
			RETURN;
		END IF;*/

		--
		-- These QA Checks should always be performed sequentially,
		-- regardless of the set-up.  Therefore, if one of
		-- the checks is disabled, that check will still
		-- be performed but with a 'Warning' severity.
		--
		IF l_perf_expert_not_applied <> 'Y'
		THEN
			l_expert_not_applied_sev := 'W';
		END IF;

		IF l_perf_invalid_config <> 'Y'
		THEN
			l_invalid_config_sev := 'E';
		END IF;

		IF l_perf_incomplt_config <> 'Y'
		THEN
			l_incomplt_config_sev := 'E';
		END IF;

		--
		-- By default the severity of following should be Error
		-- as per Policy Deviation Enhancement.
		--
		l_expert_partially_run_sev := 'E';
		l_invalid_config_sev := 'E';
		l_incomplt_config_sev := 'E';

	END IF;



	--
	-- Retrieve Template Usage Info
	--
	OPEN  l_get_template_info_csr;
	FETCH l_get_template_info_csr INTO l_config_header_id, l_config_rev_nbr, l_ce_finish_flag,
			       l_template_id,l_template_ce_enabled;
	CLOSE l_get_template_info_csr;

	-- debug log
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'l_config_header_id : '||l_config_header_id);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'l_config_rev_nbr : '||l_config_rev_nbr);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'l_ce_finish_flag : '||l_ce_finish_flag);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'l_template_id : '||l_template_id);
	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	    G_MODULE||l_api_name,
	    'l_template_ce_enabled : '||l_template_ce_enabled);
	END IF;

	IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine

	--checking whther the document have any expert responses
	BEGIN
		SELECT 'Y' INTO l_has_responses FROM dual
		WHERE EXISTS (SELECT 1 FROM okc_xprt_doc_ques_response WHERE doc_id = p_document_id AND doc_type = p_document_type AND response IS NOT NULL);
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		NULL;
	END;

	-- Template Enabled for Expert?

	IF (NVL(l_template_ce_enabled,'N') <> 'Y') THEN
		-- Template is not enabled for expert
		x_msg_data := G_OKC_TEMPLATE_NOT_CE_ENABLED;
		RETURN;
	END IF;

	--authoring flow is called when we apply a template and the contract expert dont have any questions, it automatically runs contract expert if it doesnt ahve any questions
	-- but in the okc rules engine we have removed this autorun contract expert functionality, so the user has to run the contract expert manually.
	--So, removing the authoring flow code in new okc rules engine case as it is not needed.

	/*--
	-- Template is enabled for Expert.
	-- Check if CE has been invoked at all or not in authoring flow.
	-- Add Error in Stack.
	--
	--checking whther contract expert has been invoked or not
	IF (l_has_responses = 'N' AND l_ce_finish_flag = 'N' AND p_bv_mode = 'AUTH')
	THEN
		--
		-- Contract Expert has not been invoked on the document
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_NOT_APPLIED_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_not_applied_sev_w;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_not_applied_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details     :=
			       OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_EXPERT_NOT_APPLIED_D);
		RETURN;
	END IF; */


	--
	-- Template is enabled for Expert.
	-- Check if CE has been invoked at all or not.
	-- Add Error in Stack.
	--
	--checking whther contract expert has been invoked or not
	IF (l_has_responses = 'N' AND l_ce_finish_flag = 'N' AND (p_bv_mode = 'QA' OR p_bv_mode = 'APPR')) THEN
		--
		-- Contract Expert has not been invoked on the document
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_NOT_APPLIED_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_not_applied_sev_e;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_not_applied_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
			       OKC_TERMS_UTIL_PVT.Get_Message('OKC',
							      G_OKC_EXPERT_NOT_APPLIED_D);
		RETURN;
	END IF;

	--initialising rules engine
	OKC_XPRT_RULES_ENGINE_PVT.init_contract_expert(p_document_id, p_document_type, l_template_id, l_has_questions);

	--
	-- Template is enabled for Expert.
	-- Check if CE has been partially invoked.
	-- Add Error in Stack.
	--

	IF ((l_has_responses = 'Y' AND l_ce_finish_flag = 'N' AND (p_bv_mode = 'QA' OR p_bv_mode = 'APPR'))
		OR (OKC_XPRT_RULES_ENGINE_PVT.has_all_questions_answered(p_document_id, p_document_type) = 'N' AND (p_bv_mode = 'QA' OR p_bv_mode = 'APPR')) ) THEN
		--
		-- Contract Expert has not been applied to the document
		--Contract Expert ran partially

		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_PARTIALLY_RUN;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_PARTIALLY_RUN;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_PARTIALLY_RUN_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_partially_run_sev;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_partially_run_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
			       OKC_TERMS_UTIL_PVT.Get_Message('OKC',
							      G_OKC_EXPERT_PARTIALLY_RUN_D);
		RETURN;

	END IF;

	IF (p_bv_mode = 'QA') THEN

		process_qa_result(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_qa_result_tbl        => x_qa_result_tbl,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);


		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	-- p_bv_mode is 'DEV' for deviation report
	ELSIF (p_bv_mode = 'DEV') THEN

		-- if clause rules have no questions or has answered questions
		IF check_rule_type_has_questions(l_template_id,'CLAUSE_SELECTION') <> 'Y' OR has_unanswered_questions(p_document_type, p_document_id,'CLAUSE_SELECTION') <> 'Y' THEN

			process_qa_result(
				p_api_version          => 1.0,
				p_init_msg_list        => FND_API.G_FALSE,
				p_document_id          => p_document_id,
				p_document_type        => p_document_type,
				p_config_header_id     => l_new_config_header_id,
				p_config_rev_nbr       => l_new_config_rev_nbr,
				x_qa_result_tbl        => x_qa_result_tbl,
				x_return_status        => x_return_status,
				x_msg_data             => x_msg_data,
				x_msg_count            => x_msg_count);


			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	     END IF;

		-- if policy rules have no questions or has answered questions
		IF check_rule_type_has_questions(l_template_id,'TERM_DEVIATION') <> 'Y' OR has_unanswered_questions(p_document_type, p_document_id,'TERM_DEVIATION') <> 'Y' THEN

			get_expert_articles(
				p_api_version      => 1.0,
				p_init_msg_list    => FND_API.G_FALSE,
				p_document_id          => p_document_id,
				p_document_type        => p_document_type,
				p_config_header_id => l_new_config_header_id,
				p_config_rev_nbr   => l_new_config_rev_nbr,
				x_expert_articles_tbl  => x_expert_articles_tbl,
				x_return_status    => x_return_status,
				x_msg_data         => x_msg_data,
				x_msg_count        => x_msg_count);

			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
			THEN
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;


			--SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO l_sequence_id from DUAL;
			l_sequence_id := p_sequence_id;

			get_expert_results(
				p_api_version      	=> 1.0,
				p_init_msg_list    	=> FND_API.G_FALSE,
				p_document_id      	=> p_document_id,
				p_document_type          => p_document_type,
				p_mode                   => 'BV',
				p_sequence_id		=> l_sequence_id,
				p_config_header_id 	=> l_new_config_header_id,
				p_config_rev_nbr   	=> l_new_config_rev_nbr,
				x_return_status    	=> x_return_status,
				x_msg_data         	=> x_msg_data,
				x_msg_count        	=> x_msg_count);


			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)	THEN
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		RETURN;
	ELSIF (p_bv_mode = 'APPR') THEN

		process_qa_result(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_qa_result_tbl        => x_qa_result_tbl,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		get_expert_articles(
			p_api_version      => 1.0,
			p_init_msg_list    => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id => l_new_config_header_id,
			p_config_rev_nbr   => l_new_config_rev_nbr,
			x_expert_articles_tbl  => x_expert_articles_tbl,
			x_return_status    => x_return_status,
			x_msg_data         => x_msg_data,
			x_msg_count        => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


		--SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO l_sequence_id from DUAL;
		l_sequence_id := p_sequence_id;

		get_expert_results(
		p_api_version      	=> 1.0,
		p_init_msg_list    	=> FND_API.G_FALSE,
		p_document_id      	=> p_document_id,
		p_document_type          => p_document_type,
		p_mode                   => 'BV',
		p_sequence_id		=> l_sequence_id,
		p_config_header_id 	=> l_new_config_header_id,
		p_config_rev_nbr   	=> l_new_config_rev_nbr,
		x_return_status    	=> x_return_status,
		x_msg_data         	=> x_msg_data,
		x_msg_count        	=> x_msg_count);


		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
      END IF; -- p_bv_mode

     ELSE --configurator
	--
	-- Template Enabled for Expert?
	-- BV will be executed even if Template is disabled for Expert
	-- if Expert has been previously applied to document
	--
	IF (NVL(l_template_ce_enabled,'N') <> 'Y')
	THEN
		IF (l_config_header_id IS NULL OR l_config_rev_nbr IS NULL)
		THEN
			-- Expert has never been applied to document
			x_msg_data := G_OKC_TEMPLATE_NOT_CE_ENABLED;
			RETURN;
		END IF;
	END IF;


	--Bug 5077098
	--check whether template is published.If template is not published then return
	get_publication_id(
	 p_api_version                  => p_api_version,
	 p_init_msg_list                => p_init_msg_list,
	 p_template_id                  => l_template_id,
	 x_publication_id               => l_publication_id,
	 x_return_status                => x_return_status,
	 x_msg_count                    => x_msg_count,
	 x_msg_data                     => x_msg_data );

	IF (l_publication_id is null ) THEN
		RETURN;
	END IF;
	-- end Bug 5077098


	--If Clause Selection has Rules and mode is AUTHORING
	--Add QA message and Return
	IF check_rule_type_has_questions(l_template_id,'CLAUSE_SELECTION') = 'Y' AND (p_bv_mode = 'AUTH')
	THEN
		--
		-- Add QA Message for expert needs to be run
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_NOT_APPLIED_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_not_applied_sev_w;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_not_applied_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details     :=
			       OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_EXPERT_NOT_APPLIED_D);
		RETURN;

	END IF;
	--
	-- Template is enabled for Expert.
	-- But if CE has not been invoked at all, do not execute BV.
	-- Add Error in Stack.
	--
	IF ((l_config_header_id IS NULL OR l_config_rev_nbr IS NULL) AND check_template_has_questions(l_template_id) = 'Y' AND p_bv_mode = 'QA')
	THEN
		--
		-- Contract Expert has not been applied to the document
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_NOT_APPLIED_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_not_applied_sev_e;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_not_applied_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
			       OKC_TERMS_UTIL_PVT.Get_Message('OKC',
							      G_OKC_EXPERT_NOT_APPLIED_D);
		RETURN;
	END IF; -- config_header_id is null or config_rev_nbr is null


	--
	-- All Requirements are met.
	-- Build XML Init Msg for BV.
	--
	build_cz_xml_init_msg(
		p_api_version      => 1.0,
		p_init_msg_list    => FND_API.G_FALSE,
		p_document_id      => p_document_id,
		p_document_type    => p_document_type,
		p_config_header_id => l_config_header_id,
		p_config_rev_nbr   => l_config_rev_nbr,
		p_template_id      => l_template_id,
		x_cz_xml_init_msg  => l_cz_xml_init_msg,
		x_return_status    => x_return_status,
		x_msg_data         => x_msg_data,
		x_msg_count        => x_msg_count);


	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_cz_xml_init_msg IS NULL)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--
	-- Invoke BV.
	--
	OKC_XPRT_CZ_INT_PVT.batch_validate(
		p_api_version          => 1.0,
		p_init_msg_list        => FND_API.G_FALSE,
		p_cz_xml_init_msg      => l_cz_xml_init_msg,
		x_cz_xml_terminate_msg => l_xml_terminate_msg, -- this has been converted
							       -- internally from
							       -- HTML_PIECES to LONG.
		x_return_status        => x_return_status,
		x_msg_data             => x_msg_data,
		x_msg_count            => x_msg_count);


	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_xml_terminate_msg IS NULL)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	--
	-- Parse BV Results
	--
	parse_cz_xml_terminate_msg(
		p_api_version          => 1.0,
		p_init_msg_list        => FND_API.G_FALSE,
		p_cz_xml_terminate_msg => l_xml_terminate_msg,
		x_valid_config         => l_valid_config,
		x_complete_config      => l_complete_config,
		x_config_header_id     => l_new_config_header_id,
		x_config_rev_nbr       => l_new_config_rev_nbr,
		x_return_status        => x_return_status,
		x_msg_data             => x_msg_data,
		x_msg_count            => x_msg_count);

	/*
	Bug # 4115488
	If one or more questions on a existing configuration were deleted due to the rule
	getting disabled, when we run batch validate in back end, CZ returns valid_configuration
	as false.
	In 'DEV' mode, we need to continue processing the expert clauses from CZ even if the
	valid_configuration is false
	*/

	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--
	-- Template is enabled for Expert.
	-- But if CE has been partially invoked, do not execute BV.
	-- Add Error in Stack.
	--

	IF ((l_config_header_id IS NOT NULL AND l_config_rev_nbr IS NOT NULL) AND check_template_has_questions(l_template_id) = 'Y' AND (LOWER(l_complete_config) <> L_COMPLETE) AND p_bv_mode = 'QA')
	THEN
		--
		-- Contract Expert has not been applied to the document
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_PARTIALLY_RUN;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_PARTIALLY_RUN;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_PARTIALLY_RUN_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_partially_run_sev;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_partially_run_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
			       OKC_TERMS_UTIL_PVT.Get_Message('OKC',
							      G_OKC_EXPERT_PARTIALLY_RUN_D);
							      -- delete config before return
		-- delete config before return
		--
		-- Delete BV Configuration from CZ.
		--

		OKC_XPRT_CZ_INT_PVT.delete_configuration(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		RETURN;

	END IF;

	-- If mode is QA and configuration is incomplete
	-- Add QA message and Return

	IF (LOWER(l_complete_config) <> L_COMPLETE) AND (p_bv_mode = 'QA')
	THEN

		--
		-- Add QA Message for invalid configuration
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               :=
		OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_INCOMPLT_CONFIG;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_INCOMPLT_CONFIG;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          :=
		OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_INCOMPLT_CONFIG_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_incomplt_config_sev;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_incomplt_config_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details     :=
		OKC_TERMS_UTIL_PVT.Get_Message('OKC',
				    G_OKC_INCOMPLT_CONFIG_D);

		-- delete config before return
		--
		-- Delete BV Configuration from CZ.
		--

		OKC_XPRT_CZ_INT_PVT.delete_configuration(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		RETURN;

	END IF;

	-- If mode is QA and configuration is Invalid
	-- Add QA message and Return

	IF (LOWER(l_valid_config) <> L_VALID) AND (p_bv_mode = 'QA')
	THEN
		--
		-- Add QA Message for invalid configuration
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_INVALID_CONFIG;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_INVALID_CONFIG;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_INVALID_CONFIG_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_invalid_config_sev;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_invalid_config_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details     :=
		OKC_TERMS_UTIL_PVT.Get_Message('OKC',
					    G_OKC_INVALID_CONFIG_D);
		-- delete config before return
		--
		-- Delete BV Configuration from CZ.
		--
		OKC_XPRT_CZ_INT_PVT.delete_configuration(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		RETURN;

	END IF;

	--If mode is approval and no previous configuration exists and template has questions
	-- or invalid configuration, Add QA message and Return.

	IF (((l_config_header_id IS NULL OR l_config_rev_nbr IS NULL) AND check_template_has_questions(l_template_id) = 'Y' ) OR (LOWER(l_valid_config) <> L_VALID)) AND (p_bv_mode = 'APPR')
	THEN
		--
		-- Add QA Message for invalid configuration
		--
		l_qa_tbl_index := x_qa_result_tbl.COUNT + 1;

		x_qa_result_tbl(l_qa_tbl_index).error_record_type   := G_EXPERT_QA_TYPE;
		x_qa_result_tbl(l_qa_tbl_index).article_id          := NULL;
		x_qa_result_tbl(l_qa_tbl_index).deliverable_id      := NULL;
		x_qa_result_tbl(l_qa_tbl_index).title               := OKC_TERMS_UTIL_PVT.Get_Message('OKC', G_OKC_CONTRACT_EXPERT);
		x_qa_result_tbl(l_qa_tbl_index).section_name        := NULL;
		x_qa_result_tbl(l_qa_tbl_index).qa_code             := G_CHECK_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).message_name        := G_OKC_EXPERT_NOT_APPLIED;
		x_qa_result_tbl(l_qa_tbl_index).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message('OKC',G_OKC_EXPERT_NOT_APPLIED_S);
		x_qa_result_tbl(l_qa_tbl_index).error_severity      := l_expert_not_applied_sev_e;
		x_qa_result_tbl(l_qa_tbl_index).problem_short_desc  := l_expert_not_applied_desc;
		x_qa_result_tbl(l_qa_tbl_index).problem_details       :=
		OKC_TERMS_UTIL_PVT.Get_Message('OKC',
				      'OKC_EXPRT_NOT_RUN');

		-- delete config before return
		--
		-- Delete BV Configuration from CZ.
		--
		OKC_XPRT_CZ_INT_PVT.delete_configuration(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		RETURN;

	END IF;

	--If mode is DEVIATION and Invalid Configuration and if both Clause and Policy Rules have
	--Questions then Add QA message and Return.

	IF (p_bv_mode = 'DEV') AND (LOWER(l_valid_config) <> L_VALID) AND  (check_rule_type_has_questions(l_template_id,'CLAUSE_SELECTION') = 'Y' AND check_rule_type_has_questions(l_template_id,'TERM_DEVIATION') = 'Y')
	THEN

		-- delete config before return
		--
		-- Delete BV Configuration from CZ.
		--
		OKC_XPRT_CZ_INT_PVT.delete_configuration(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		-- Raises error for invalid configuration
		FND_MESSAGE.set_name('OKC', G_OKC_INVALID_CONFIG_D);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;

		RETURN;

    END IF;


	--
	-- Config Valid and Complete => Process BV Results
	-- We will always execute this in QA as Deviation has been
	-- pushed to post 11.5.10.
	--
	IF (p_bv_mode = 'QA') THEN

		process_qa_result(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_qa_result_tbl        => x_qa_result_tbl,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);


		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


	-- p_bv_mode is 'DEV' for deviation report
	ELSIF (p_bv_mode = 'DEV') THEN
		-- if clause rules have no questions or has answered questions
		IF check_rule_type_has_questions(l_template_id,'CLAUSE_SELECTION') <> 'Y' OR has_unanswered_questions(p_document_type, p_document_id,'CLAUSE_SELECTION') <> 'Y' THEN

			process_qa_result(
				p_api_version          => 1.0,
				p_init_msg_list        => FND_API.G_FALSE,
				p_document_id          => p_document_id,
				p_document_type        => p_document_type,
				p_config_header_id     => l_new_config_header_id,
				p_config_rev_nbr       => l_new_config_rev_nbr,
				x_qa_result_tbl        => x_qa_result_tbl,
				x_return_status        => x_return_status,
				x_msg_data             => x_msg_data,
				x_msg_count            => x_msg_count);


			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	        END IF;

		-- if policy rules have no questions or has answered questions
		IF check_rule_type_has_questions(l_template_id,'TERM_DEVIATION') <> 'Y' OR has_unanswered_questions(p_document_type, p_document_id,'TERM_DEVIATION') <> 'Y' THEN

			get_expert_articles(
				p_api_version      => 1.0,
				p_init_msg_list    => FND_API.G_FALSE,
				p_document_id          => p_document_id,
				p_document_type        => p_document_type,
				p_config_header_id => l_new_config_header_id,
				p_config_rev_nbr   => l_new_config_rev_nbr,
				x_expert_articles_tbl  => x_expert_articles_tbl,
				x_return_status    => x_return_status,
				x_msg_data         => x_msg_data,
				x_msg_count        => x_msg_count);

			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
			THEN
				raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;


			--SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO l_sequence_id from DUAL;
			l_sequence_id := p_sequence_id;

			get_expert_results(
				p_api_version      	=> 1.0,
				p_init_msg_list    	=> FND_API.G_FALSE,
				p_document_id      	=> p_document_id,
				p_document_type          => p_document_type,
				p_mode                   => 'BV',
				p_sequence_id		=> l_sequence_id,
				p_config_header_id 	=> l_new_config_header_id,
				p_config_rev_nbr   	=> l_new_config_rev_nbr,
				x_return_status    	=> x_return_status,
				x_msg_data         	=> x_msg_data,
				x_msg_count        	=> x_msg_count);


			IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
			THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;

		RETURN;
   ELSIF (p_bv_mode = 'AUTH') THEN

		update_ce_config(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			p_doc_update_mode      => 'BV',
			x_count_articles_dropped => l_count_articles_dropped,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	ELSIF (p_bv_mode = 'APPR') THEN

		process_qa_result(
			p_api_version          => 1.0,
			p_init_msg_list        => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id     => l_new_config_header_id,
			p_config_rev_nbr       => l_new_config_rev_nbr,
			x_qa_result_tbl        => x_qa_result_tbl,
			x_return_status        => x_return_status,
			x_msg_data             => x_msg_data,
			x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		get_expert_articles(
			p_api_version      => 1.0,
			p_init_msg_list    => FND_API.G_FALSE,
			p_document_id          => p_document_id,
			p_document_type        => p_document_type,
			p_config_header_id => l_new_config_header_id,
			p_config_rev_nbr   => l_new_config_rev_nbr,
			x_expert_articles_tbl  => x_expert_articles_tbl,
			x_return_status    => x_return_status,
			x_msg_data         => x_msg_data,
			x_msg_count        => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;


		--SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO l_sequence_id from DUAL;
		l_sequence_id := p_sequence_id;

		get_expert_results(
		p_api_version      	=> 1.0,
		p_init_msg_list    	=> FND_API.G_FALSE,
		p_document_id      	=> p_document_id,
		p_document_type          => p_document_type,
		p_mode                   => 'BV',
		p_sequence_id		=> l_sequence_id,
		p_config_header_id 	=> l_new_config_header_id,
		p_config_rev_nbr   	=> l_new_config_rev_nbr,
		x_return_status    	=> x_return_status,
		x_msg_data         	=> x_msg_data,
		x_msg_count        	=> x_msg_count);


		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

    -------------------- END OF CODE CHANGES BY KARTK -----------------------

    END IF; -- p_bv_mode

    --
    -- Delete BV Configuration from CZ.
    --
    --Bug#4757962 In DEV mode do not delete configuration
    --CODE MODIFIED BY KARTIK ADDED AUTHORING MODE FOR NOT TO DELETE CONFIGURATION-----------------------------
	IF(p_bv_mode = 'QA') THEN
		OKC_XPRT_CZ_INT_PVT.delete_configuration(
		       p_api_version          => 1.0,
		       p_init_msg_list        => FND_API.G_FALSE,
		       p_config_header_id     => l_new_config_header_id,
		       p_config_rev_nbr       => l_new_config_rev_nbr,
		       x_return_status        => x_return_status,
		       x_msg_data             => x_msg_data,
		       x_msg_count            => x_msg_count);

		IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF; --IF(p_bv_mode <> 'DEV')
 END IF;

    --
    -- Standard call to get message count and if count is 1, get message info.
    --
    FND_MSG_PUB.Count_And_Get(
       	  	p_count => x_msg_count,
            	p_data => x_msg_data
    		);

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

  		x_return_status := FND_API.G_RET_STS_ERROR ;
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  		x_return_status := FND_API.G_RET_STS_ERROR ;
		/*
  		FND_MSG_PUB.Count_And_Get(
  		        p_count => x_msg_count,
          		p_data => x_msg_data
  		); */

      WHEN OTHERS THEN
  		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    		IF FND_MSG_PUB.Check_Msg_Level
  		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  		THEN
      	    	FND_MSG_PUB.Add_Exc_Msg(
      	    	     G_PKG_NAME  	    ,
      	    	     l_api_name
  	    	      );
  		END IF;

  		FND_MSG_PUB.Count_And_Get(
  		     p_count => x_msg_count,
          	 p_data  => x_msg_data
  		);

END contract_expert_bv;



-- End: Added for R12

-- Rajendra

  /*====================================================================+
  Procedure Name : is_template_applied
  Description    : This would check if the template is already
                   instantiated on any document.

  +====================================================================*/

PROCEDURE is_template_applied (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    p_document_type             IN            VARCHAR2,
    p_document_id               IN            NUMBER,
    p_template_id               IN            NUMBER,
    x_template_applied_yn       OUT  NOCOPY   VARCHAR2,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2
) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name VARCHAR2(30) := 'is_template_applied';
    l_package_procedure VARCHAR2(60);
    l_template_applied  VARCHAR2(1);

    CURSOR csr_tmpl_applied_yn IS
    SELECT 'X'
      FROM okc_template_usages
      WHERE document_type = p_document_type
        AND document_id = p_document_id
        AND template_id = p_template_id;

    BEGIN
        -- start debug log
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                          G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        --
	   -- Standard call to check for call compatibility.
        --
        IF NOT FND_API.Compatible_API_Call (l_api_version,
	                                   p_api_version,
	                                   l_api_name,
	                                   G_PKG_NAME)
	   THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --
        -- Initialize message list if p_init_msg_list is set to TRUE.
        --
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        --
        --  Initialize API return status to success
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN csr_tmpl_applied_yn;
        FETCH csr_tmpl_applied_yn INTO l_template_applied;
        IF csr_tmpl_applied_yn%FOUND THEN
           -- template already applied
           x_template_applied_yn := 'Y';
           RETURN;
        ELSE
           -- template not applied
           x_template_applied_yn := 'N';
           RETURN;
        END IF;
        CLOSE csr_tmpl_applied_yn;

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

    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get(
    		        p_count => x_msg_count,
            		p_data => x_msg_data
    		);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    		x_return_status := FND_API.G_RET_STS_ERROR ;
    		FND_MSG_PUB.Count_And_Get(
    		        p_count => x_msg_count,
            		p_data => x_msg_data
    		);

WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      		IF FND_MSG_PUB.Check_Msg_Level
    		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    		THEN
        	    	FND_MSG_PUB.Add_Exc_Msg(
        	    	     G_PKG_NAME  	    ,
        	    	     l_api_name
    	    	      );
    		END IF;

    		FND_MSG_PUB.Count_And_Get(
    		     p_count => x_msg_count,
            	     p_data => x_msg_data);
END is_template_applied;

 /*====================================================================+
  Procedure Name : get_current_config_dtls
  Description    : This would get the current config_header_id and
                   config_revision_number is the contract expert was
                   already run on the quote. It would also check if the
                   template is contract expert enabled.

  +====================================================================*/

PROCEDURE get_current_config_dtls (
    p_api_version               IN            NUMBER,
    p_init_msg_list             IN            VARCHAR2,
    p_document_type             IN            VARCHAR2,
    p_document_id               IN            NUMBER,
    p_template_id               IN            NUMBER,
    x_expert_enabled_yn         OUT  NOCOPY   VARCHAR2,
    x_config_header_id          OUT  NOCOPY   NUMBER,
    x_config_rev_nbr            OUT  NOCOPY   NUMBER,
    x_return_status             OUT  NOCOPY   VARCHAR2,
    x_msg_count                 OUT  NOCOPY   NUMBER,
    x_msg_data                  OUT  NOCOPY   VARCHAR2
) IS

    l_api_version CONSTANT NUMBER := 1;
    l_api_name VARCHAR2(30) := 'get_current_config_dtls';
    l_package_procedure VARCHAR2(60);
    l_template_id       NUMBER;

    /*l_contract_expert_enabled  VARCHAR2(1);
    l_config_header_id  NUMBER;
    l_config_rev_nbr    NUMBER;
    l_template_id       NUMBER;*/

    CURSOR l_get_template_info_csr IS
        SELECT u.config_header_id,
               u.config_revision_number,
               t.template_id,
               t.contract_expert_enabled
        FROM okc_template_usages u,
             okc_terms_templates_all t
        WHERE t.template_id = u.template_id
          AND u.document_type= p_document_type
          AND u.document_id =  p_document_id
		AND t.template_id = p_template_id;

    BEGIN
        -- start debug log
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                          G_MODULE||l_api_name,
                          '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
        END IF;

        --
	   -- Standard call to check for call compatibility.
        --
        IF NOT FND_API.Compatible_API_Call (l_api_version,
	                                   p_api_version,
	                                   l_api_name,
	                                   G_PKG_NAME)
	   THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --
        -- Initialize message list if p_init_msg_list is set to TRUE.
        --
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
        END IF;

        --
        --  Initialize API return status to success
        --
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN l_get_template_info_csr;
        FETCH l_get_template_info_csr INTO x_config_header_id, x_config_rev_nbr, l_template_id, x_expert_enabled_yn;
        CLOSE l_get_template_info_csr;

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

     		x_return_status := FND_API.G_RET_STS_ERROR ;
     		FND_MSG_PUB.Count_And_Get(
     		        p_count => x_msg_count,
             		p_data => x_msg_data
     		);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                         G_MODULE||l_api_name,
                         '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
       END IF;

     		x_return_status := FND_API.G_RET_STS_ERROR ;
     		FND_MSG_PUB.Count_And_Get(
     		        p_count => x_msg_count,
             		p_data => x_msg_data
     		);

 WHEN OTHERS THEN
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                         G_MODULE||l_api_name,
                         '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
       END IF;

     		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       		IF FND_MSG_PUB.Check_Msg_Level
     		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     		THEN
         	    	FND_MSG_PUB.Add_Exc_Msg(
         	    	     G_PKG_NAME  	    ,
         	    	     l_api_name
     	    	      );
     		END IF;

     		FND_MSG_PUB.Count_And_Get(
     		     p_count => x_msg_count,
             	     p_data => x_msg_data);
 END get_current_config_dtls;


/*========================================================================================+
  Function Name : check_rule_type_has_questions
  Description   : Returns 'Y' if a template with specified rule type has active questions,
		          otherwise returns 'N'. Used in Rules Summary Page
  Parameters    : p_template_id template id
	           	  p_rule_type	 rule type either 'CLAUSE_SELECTION' OR 'TERM_DEVIATION'
+========================================================================================*/

FUNCTION check_rule_type_has_questions (
    p_template_id   IN NUMBER,
    p_rule_type IN VARCHAR2)
  RETURN VARCHAR2 IS

CURSOR csr_rules(p_org_id NUMBER, p_intent VARCHAR2) IS
SELECT tr.rule_id
  FROM okc_xprt_template_rules tr,
       okc_xprt_rule_hdrs_all rhdr
 WHERE tr.rule_id = rhdr.rule_id
   AND tr.template_id = p_template_id
   AND rhdr.rule_type = p_rule_type
   AND rhdr.status_code IN ('ACTIVE','PENDING_PUB')
UNION ALL
SELECT r.rule_id
  FROM OKC_TERMS_TEMPLATES_ALL t,
       okc_xprt_rule_hdrs_all r
 WHERE  t.org_id = p_org_id
   AND  t.intent = p_intent
   AND r.rule_type = p_rule_type
   AND  r.status_code IN ('ACTIVE','PENDING_PUB')
   AND  NVL(r.org_wide_flag,'N') = 'Y'
   AND  t.template_id = p_template_id;


CURSOR csr_questions(p_rule_id NUMBER) IS
  SELECT  object_code question_id
  FROM okc_xprt_rule_conditions cond
  WHERE cond.rule_id = p_rule_id
  AND cond.object_value_type ='QUESTION'
    UNION ALL
  SELECT object_code question_id
  FROM  okc_xprt_rule_conditions cond
  WHERE cond.rule_id = p_rule_id
  AND  cond.object_type ='QUESTION'
    UNION ALL
  SELECT object_value_id||'' question_id
  FROM okc_xprt_rule_outcomes xro
  WHERE xro.rule_id = p_rule_id
  AND xro.object_type='QUESTION';

CURSOR csr_main IS
  SELECT org_id, intent
  FROM okc_terms_templates_all
  WHERE template_id = p_template_id;

l_dummy  VARCHAR2(1);
l_return VARCHAR2(1);
l_org_id NUMBER;
l_intent VARCHAR2(40);

rec_rule csr_rules%rowtype;
rec_question csr_questions%rowtype;
rec_main csr_main%rowtype;

BEGIN
     l_return := 'N';
     OPEN csr_main;
     FETCH csr_main INTO rec_main;
	l_org_id := rec_main.org_id;
	l_intent := rec_main.intent;
     CLOSE csr_main;

     IF l_org_id IS NULL THEN
	 RETURN 'N';
     ELSE
	   FOR rec_rule IN csr_rules( rec_main.org_id, rec_main.intent)
	   LOOP
		  FOR rec_question IN csr_questions(rec_rule.rule_id)
		  LOOP
			SELECT 'x' into l_dummy
			FROM okc_xprt_question_orders
			WHERE question_rule_status = 'ACTIVE'
			AND template_id = p_template_id
			AND question_id = rec_question.question_id;

			IF l_dummy = 'x' THEN
			 RETURN 'Y';
			END IF;
		  END LOOP;
	   END LOOP;
       END IF;
   RETURN 'N';

EXCEPTION
 WHEN OTHERS THEN
 --close cursors
 IF csr_main%ISOPEN THEN
   CLOSE csr_main;
 END IF;
 IF csr_rules%ISOPEN THEN
   CLOSE csr_rules;
 END IF;
 IF csr_questions%ISOPEN THEN
   CLOSE csr_questions;
 END IF;
 RETURN 'N';
END check_rule_type_has_questions;

PROCEDURE contract_expert_bv(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_bv_mode                      IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
IS

l_expert_articles_tbl expert_articles_tbl_type;
l_qa_result_tbl_type OKC_TERMS_QA_GRP.qa_result_tbl_type;
BEGIN

	 contract_expert_bv(
	    p_api_version           =>     p_api_version,
	    p_init_msg_list         =>     p_init_msg_list,
	    p_document_id           =>     p_document_id,
	    p_document_type         =>     p_document_type,
	    p_bv_mode               =>     p_bv_mode,
	    p_sequence_id 	        =>	   NULL,
	    x_qa_result_tbl         =>     l_qa_result_tbl_type  ,
	    x_expert_articles_tbl   =>     l_expert_articles_tbl ,
  	    x_return_status         =>     x_return_status,
	    x_msg_count             =>     x_msg_count,
	    x_msg_data              =>     x_msg_data );


END contract_expert_bv;

FUNCTION is_config_complete(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
 ) RETURN VARCHAR2 IS

 l_api_name         CONSTANT VARCHAR2(30) := 'is_config_complete';

 CURSOR doc_config_details_csr IS
  select nvl(config_status, 0)
  from cz_config_hdrs_v chv, okc_template_usages otu
  where chv.config_hdr_id = otu.config_header_id
  and chv.config_rev_nbr = otu.config_revision_number
  and otu.document_type = p_document_type
  and otu.document_id = p_document_id;

  l_result     NUMBER;

BEGIN
    l_result := 0;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Entering is_config_complete ');
    END IF;

    OPEN  doc_config_details_csr ;
    FETCH doc_config_details_csr  into  l_result;
    IF doc_config_details_csr%NOTFOUND THEN
       l_result := 0;
    END IF;
    CLOSE doc_config_details_csr ;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Result is_config_complete : ['||l_result||']');
    END IF;

    IF l_result = 2 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving is_config_complete of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END is_config_complete;

FUNCTION has_unanswered_questions(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER,
    p_rule_type             IN  VARCHAR2
 ) RETURN VARCHAR2 IS

 l_api_name         CONSTANT VARCHAR2(30) := 'has_unanswered_questions';

 CURSOR doc_template_dtls_csr IS
  select u.template_id, a.contract_expert_enabled, u.contract_source_code, nvl(u.contract_expert_finish_flag, 'N')
  from okc_template_usages u, okc_terms_templates_all a
  where u.template_id = a.template_id
  and u.document_type = p_document_type
  and u.document_id = p_document_id;

  l_return_val     VARCHAR2(1);
  l_template_id okc_terms_templates_all.template_id%type;
  l_expert_enabled okc_terms_templates_all.contract_expert_enabled%type;
  l_contract_source okc_template_usages.contract_source_code%type;
  l_has_questions VARCHAR2(1);
  l_ce_enabled VARCHAR2(50);
  l_ce_finish_flag VARCHAR2(1);

BEGIN
    l_return_val := 'N';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Entering has_unanswered_questions ');
    END IF;

    OPEN  doc_template_dtls_csr ;
    FETCH doc_template_dtls_csr  into l_template_id, l_expert_enabled, l_contract_source, l_ce_finish_flag;
    IF doc_template_dtls_csr%NOTFOUND THEN
       l_return_val := 'N';
    END IF;
    CLOSE doc_template_dtls_csr ;

    -- Bug#  6329925. Check if CE Profile is Enabled
    FND_PROFILE.GET(name=> 'OKC_K_EXPERT_ENABLED', val => l_ce_enabled);

    IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine
    	IF NVL(l_ce_enabled,'N') = 'N' OR l_contract_source <> 'STRUCTURED' OR NVL(l_expert_enabled, 'N') <> 'Y' OR OKC_XPRT_RULES_ENGINE_PVT.has_all_questions_answered(p_document_id, p_document_type) = 'Y' THEN
       l_return_val := 'N';

   	 /* Expert is not run completely */
    	ELSIF OKC_XPRT_RULES_ENGINE_PVT.has_all_questions_answered(p_document_id, p_document_type) = 'N' THEN
          l_has_questions := check_rule_type_has_questions(
    			p_template_id => l_template_id,
				p_rule_type => p_rule_type );

          IF l_has_questions = 'Y' THEN
             l_return_val := 'Y';
          END IF;
	END IF;

    ELSE --configurator

    IF NVL(l_ce_enabled,'N') = 'N' OR l_contract_source <> 'STRUCTURED' OR NVL(l_expert_enabled, 'N') <> 'Y' THEN
       l_return_val := 'N';

    /* Expert is not run completely */
    ELSIF is_config_complete(
                              p_document_type, p_document_id) <> 'Y' THEN
          l_has_questions := check_rule_type_has_questions(
    			p_template_id => l_template_id,
				p_rule_type => p_rule_type );

          IF l_has_questions = 'Y' THEN
             l_return_val := 'Y';
          END IF;

    END IF;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Result has_unanswered_questions : ['||l_return_val||']');
    END IF;

    RETURN l_return_val;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving has_unanswered_questions of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END has_unanswered_questions;


/*====================================================================+
  Procedure Name : update_document
  Description    : Update Expert Articles in Document.  This API
                   is called from the runtime Contract Expert page during
                   document authoring.  Specifically, it is called
                   when a user selects the 'Finish' button from Contract
                   Expert. This method is called in the flow of new OKC
                   Rules Engine.

  Parameters:
                   p_document_id - id of document id to be updated
                   p_document_type - type of document to be updated

+====================================================================*/
PROCEDURE update_document(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    p_document_id                  IN NUMBER,
    p_document_type                IN VARCHAR2,
    p_doc_update_mode              IN VARCHAR2,
    x_count_articles_dropped       OUT NOCOPY NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_lock_xprt_yn            IN VARCHAR2 := 'N' -- Conc Mod changes
   ,p_lock_terms_yn           IN VARCHAR2 := 'N' -- Conc Mod changes
)

IS

    l_api_name CONSTANT VARCHAR2(30) := 'update_document';
    l_api_version CONSTANT NUMBER := 1;

    l_expert_articles_tbl OKC_TERMS_MULTIREC_GRP.article_id_tbl_type;
    l_validation_string  VARCHAR2(100);

    l_src_document_type okc_template_usages.orig_system_reference_code%TYPE;
    l_src_document_id okc_template_usages.orig_system_reference_id1%TYPE;

   -- Currsor to Select the Expert Articles

    CURSOR c_get_expert_articles IS
    SELECT distinct outcome.object_value_id
    FROM okc_xprt_rule_eval_result_t rultmp, okc_xprt_rule_hdrs_all_v rul, okc_xprt_rule_outcomes_act_v outcome
    WHERE rultmp.doc_id = p_document_id
    AND rultmp.doc_type = p_document_type
    AND rultmp.condition_id IS NULL
    AND nvl(rultmp.result, '*' ) = 'Y'
    AND rul.rule_id = rultmp.rule_id
    AND rul.rule_type = 'CLAUSE_SELECTION'
    AND outcome.rule_id = rul.rule_id
    AND outcome.object_type = 'CLAUSE';

	CURSOR c_base_table_dtls IS
	SELECT orig_system_reference_code, orig_system_reference_id1
	FROM okc_template_usages
	WHERE document_type = p_document_type
	AND document_id = p_document_id;

  BEGIN


    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
       	       	    	    	 	p_api_version,
        	    	    	    	l_api_name,
    		    	    	    	G_PKG_NAME)
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    IF (p_document_id is NULL OR p_document_type is NULL)
    THEN
      x_msg_data := 'OKC_EXPRT_NULL_PARAM';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    --  Initialize API return status to success
    --
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	--concurrent mod changes start
	-- Read the base table details
    	OPEN c_base_table_dtls;
      	FETCH c_base_table_dtls INTO l_src_document_type,l_src_document_id;
    	CLOSE c_base_table_dtls;

    	IF p_lock_xprt_yn = 'Y' THEN
     	IF l_src_document_type IS NOT NULL AND l_src_document_id IS NOT NULL THEN
                 -- Lock base table.
                  okc_k_entity_locks_grp.lock_entity
                              ( p_api_version     => 1,
                              p_init_msg_list    => FND_API.G_FALSE ,
                              p_commit           => FND_API.G_FALSE,
                              p_entity_name      => okc_k_entity_locks_grp.G_XPRT_ENTITY,
                              p_entity_pk1       =>  To_Char(l_src_document_id),
                              p_entity_pk2       =>  To_Char(l_src_document_type),
                              p_LOCK_BY_DOCUMENT_TYPE => p_document_type,
                              p_LOCK_BY_DOCUMENT_ID => p_document_id,
                              X_RETURN_STATUS => X_RETURN_STATUS,
                              X_MSG_COUNT => X_MSG_COUNT,
                              X_MSG_DATA => X_MSG_DATA
                              );
                --------------------------------------------
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
                END IF;
              --------------------------------------------
		ELSE
              NULL;
              -- throw error;
          END IF;
    	END IF; -- p_create_lock_for_xprt = 'Y'
	--concurrent mod chanegs end

    --
    -- Get Expert Articles from Configurator
    --
	  OPEN c_get_expert_articles;
	     FETCH c_get_expert_articles BULK COLLECT INTO l_expert_articles_tbl;
	  CLOSE c_get_expert_articles;

    --
    -- Call API to Update Document with new Expert configuration
    --
    OKC_TERMS_MULTIREC_GRP.sync_doc_with_expert(
                   p_api_version => 1,
                   p_init_msg_list => FND_API.G_FALSE,
                   p_validate_commit => FND_API.G_FALSE,
                   p_validation_string => l_validation_string,
                   p_commit => FND_API.G_FALSE,
                   p_doc_type => p_document_type,
                   p_doc_id => p_document_id,
                   p_article_id_tbl => l_expert_articles_tbl,
                   p_mode => p_doc_update_mode, -- Defaults to 'NORMAL'
                   x_articles_dropped => x_count_articles_dropped,
                   x_return_status => x_return_status,
                   x_msg_count => x_msg_count,
                   x_msg_data => x_msg_data
                   ,p_lock_terms_yn => p_lock_terms_yn);


    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --updating the contract expert finish status to Y.
    UPDATE okc_template_usages
    SET contract_expert_finish_flag = 'Y'
    WHERE document_id = p_document_id
    AND document_type = p_document_type;

    --purging the temp tables used for evaluating contract expert rules engine
    DELETE okc_xprt_rule_eval_result_t WHERE doc_id = p_document_id and doc_type = p_document_type;
    DELETE okc_xprt_rule_eval_condval_t WHERE doc_id = p_document_id and doc_type = p_document_type;

    --
    -- Display appropriate message on page depending on whether articles where inserted
    -- into document or not.  In this release, we only distinguish between inserting articles
    -- and not inserting articles.  We do not explicitly inform user if articles are deleted.
    --
    /*
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* Fix for bug# 4071469.
	* If l_expert_articles_tbl.COUNT = 0 we return 'OKC_EXPRT_NO_ARTICLES' message
	* If l_expert_articles_tbl.COUNT > 0 and = x_count_articles_dropped,
	*    we return 'OKC_EXPRT_ALL_PROVISIONS' message
	* The rest of the original logic is unchanged.
    */

    IF (l_expert_articles_tbl.COUNT = 0)
    THEN
	 x_msg_data := 'OKC_EXPRT_NO_ARTICLES';

    ELSIF (l_expert_articles_tbl.COUNT = x_count_articles_dropped)
    THEN
      x_msg_data := 'OKC_EXPRT_ALL_PROVISIONS';

    ELSIF x_count_articles_dropped > 0
    THEN

      x_msg_data := 'OKC_EXPRT_UPDATED_WITH_PROVS';

    ELSE

      x_msg_data := 'OKC_EXPRT_ARTICLES_UPDATED';

    END IF;

EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN

   		x_return_status := FND_API.G_RET_STS_ERROR ;
   		FND_MSG_PUB.Count_And_Get(
   		        p_count => x_msg_count,
           		p_data => x_msg_data
   		);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   		x_return_status := FND_API.G_RET_STS_ERROR ;
   		FND_MSG_PUB.Count_And_Get(
   		        p_count => x_msg_count,
           		p_data => x_msg_data
   		);

       WHEN OTHERS THEN
   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     		IF FND_MSG_PUB.Check_Msg_Level
   		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   		THEN
       	    	FND_MSG_PUB.Add_Exc_Msg(
       	    	     G_PKG_NAME  	    ,
       	    	     l_api_name
   	    	      );
   		END IF;

   		FND_MSG_PUB.Count_And_Get(
   		     p_count => x_msg_count,
           	     p_data => x_msg_data
   		);

END update_document;

END OKC_XPRT_UTIL_PVT ;

/
