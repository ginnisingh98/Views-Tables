--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_IMPORT_PVT" AS
/* $Header: OKCVXCONCPGMB.pls 120.2.12010000.5 2012/06/08 15:59:03 nbingi ship $ */

------------------------------------------------------------------------------
-- GLOBAL VARIABLES
------------------------------------------------------------------------------
G_RUN_ID                       NUMBER;
G_REQUEST_ID                   NUMBER;

------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_IMPORT_PVT';
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

---------------------------------------------------
--  Procedure: This function will be return True if
--  the rule is active in cz
---------------------------------------------------
FUNCTION check_rule_active
(
  p_rule_id IN NUMBER
)
RETURN  VARCHAR2 IS

CURSOR csr_check_rule_exists (p_rule_id NUMBER) IS
SELECT 'X'
FROM cz_rules
WHERE rule_type = 200 -- Statement rule
--AND devl_project_id = p_devl_project_id
AND rule_id = persistent_rule_id
AND SUBSTR(orig_sys_ref,INSTR(orig_sys_ref,':',-1,1)+1) = to_char(p_rule_id) --For Bug# 8240959
AND deleted_flag = 0;

l_exists VARCHAR2(1);

BEGIN
OPEN  csr_check_rule_exists(p_rule_id);
FETCH csr_check_rule_exists INTO l_exists;
IF csr_check_rule_exists%FOUND THEN
   CLOSE csr_check_rule_exists;
   RETURN FND_API.G_TRUE;
ELSE
   CLOSE csr_check_rule_exists;
   RETURN FND_API.G_FALSE;
END IF;


EXCEPTION
WHEN OTHERS THEN
IF csr_check_rule_exists%ISOPEN THEN
   CLOSE csr_check_rule_exists;
END IF;

END check_rule_active;



/*====================================================================+
  Procedure Name : import_template
  Description    : This is a PUBLIC API that imports template Model
			    This API is called from template approval concurrent program
  Parameters:
                   p_template_id - Template Id of the template

+====================================================================*/

PROCEDURE import_template
(
 p_api_version              IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_commit	            IN	VARCHAR2,
 p_template_id   	    IN	NUMBER,
 p_mode               IN VARCHAR2,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) IS


G_ORGANIZATION_NAME          VARCHAR2(240);

CURSOR csr_template_dtls IS
SELECT template_name,
       DECODE(parent_template_id, NULL, template_id, parent_template_id),
       intent,
       name,
       org_id
FROM okc_terms_templates_all,
     hr_operating_units
WHERE organization_id = org_id
  AND template_id = p_template_id ;

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'import_template';
l_template_model_id        NUMBER :=NULL;
l_run_id                   NUMBER;
l_template_folder_id       NUMBER :=NULL;
l_folder_desc              VARCHAR2(255);
l_import_status            VARCHAR2(10);

l_template_name            OKC_TERMS_TEMPLATES_ALL.template_name%TYPE;
l_template_id              OKC_TERMS_TEMPLATES_ALL.template_id%TYPE;
l_intent                   OKC_TERMS_TEMPLATES_ALL.intent%TYPE;
l_org_id                   OKC_TERMS_TEMPLATES_ALL.org_id%TYPE;
l_tmpl_orig_sys_ref        cz_devl_projects.orig_sys_ref%TYPE;
l_folder_name              cz_rp_entries.name%TYPE;

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
                    '100: p_template_id '||p_template_id);
  END IF;

      -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get Template Details
  OPEN csr_template_dtls;
  FETCH csr_template_dtls INTO l_template_name,
                               l_template_id,
                               l_intent,
                               G_ORGANIZATION_NAME,
                               l_org_id;

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

  -- Put the Template Name in Concurrent Request Log File
  fnd_file.put_line(FND_FILE.LOG,' ');
  fnd_file.put_line(FND_FILE.LOG,'Template Name : '||l_template_name);

  -- Update the xprt_request_id for the current template
  UPDATE okc_terms_templates_all
	SET    xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID,
         last_update_login = FND_GLOBAL.LOGIN_ID,
		     last_update_date = SYSDATE,
		     last_updated_by = FND_GLOBAL.USER_ID
	WHERE template_id = p_template_id;

  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
      G_MODULE||l_api_name,
     '110: Calling populate_questions_order');
  END IF;

  --
  --  Call API to populate template questions
  --
  OKC_XPRT_UTIL_PVT.populate_questions_order
	   (
      p_template_id   	       => p_template_id,
	    p_commit_flag              => 'Y',
		  p_mode                     => p_mode,
      x_return_status	       => x_return_status,
      x_msg_data	            => x_msg_data,
      x_msg_count	            => x_msg_count
	   );

  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
      G_MODULE||l_api_name,
      '111: After Calling populate_questions_order x_return_status : '||x_return_status);
  END IF;

  --- If any errors happen abort API
  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

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


END import_template;




PROCEDURE sync_templates
(
 p_mode IN VARCHAR2,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) IS

-- Templates to be rebuilt for Publishing or Disabling Rules
CURSOR csr_local_rules_templates IS
-- Templates on Local Rules
SELECT DISTINCT to_char(r.template_id)
FROM   okc_terms_templates_all t,
       okc_xprt_template_rules r,
       okc_xprt_rule_hdrs_all h
WHERE r.template_id = t.template_id
AND   r.rule_id = h.rule_id
AND   t.status_code IN ('APPROVED','ON_HOLD')
AND   h.request_id = FND_GLOBAL.CONC_REQUEST_ID;


CURSOR csr_org_rules_templates(p_org_id IN NUMBER) IS
-- Org Wide Rule Templates
SELECT t.template_id
FROM   okc_terms_templates_all t
WHERE  t.org_id = p_org_id
AND    t.intent IN (SELECT DISTINCT intent
				            FROM okc_xprt_rule_hdrs_all
  				          WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
                   )
AND  t.contract_expert_enabled = 'Y'
AND  t.status_code IN ('APPROVED','ON_HOLD');

-- Cursor to check if any rule is Org Wide
CURSOR csr_org_rule_exists IS
SELECT 'X'
FROM   okc_xprt_rule_hdrs_all
WHERE  request_id = FND_GLOBAL.CONC_REQUEST_ID
AND    NVL(org_wide_flag,'N') = 'Y';

-- Get the Rule Org Id
CURSOR csr_rule_org_id IS
SELECT org_id
FROM   okc_xprt_rule_hdrs_all
WHERE  request_id = FND_GLOBAL.CONC_REQUEST_ID;

l_api_name                 CONSTANT VARCHAR2(30) := 'sync_templates';
l_template_id              okc_terms_templates_all.template_id%TYPE;
l_org_rules_yn             okc_xprt_rule_hdrs_all.org_wide_flag%TYPE := NULL;
l_org_id                   okc_xprt_rule_hdrs_all.org_id%TYPE;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check if any rules in current request are Org Wide Rules
    OPEN csr_org_rule_exists;
      FETCH csr_org_rule_exists INTO l_org_rules_yn;
    CLOSE csr_org_rule_exists;

  fnd_file.put_line(FND_FILE.LOG,'Org wide rules exists ? '||l_org_rules_yn);
  -- Get the Rule Org Id
    OPEN csr_rule_org_id;
      FETCH csr_rule_org_id INTO l_org_id;
    CLOSE csr_rule_org_id;

  -- debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: l_org_rules_yn  '||l_org_rules_yn);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110:  l_org_id '||l_org_id);
  END IF;



  IF l_org_rules_yn IS NULL THEN
   -- No Org Wide Rules in current concurrent request
	 -- Open the Local Csr
  	OPEN csr_local_rules_templates;
    	LOOP
      	  FETCH csr_local_rules_templates INTO l_template_id;
		      EXIT WHEN csr_local_rules_templates%NOTFOUND;
              import_template
               (
                p_api_version       => 1,
                p_init_msg_list	 => 'T',
                p_commit	           => 'T',
                p_template_id       =>  l_template_id,
                p_mode => p_mode,
                x_return_status	 =>  x_return_status,
                x_msg_data	      =>  x_msg_data,
                x_msg_count	      =>  x_msg_count
               ) ;

               --- If any errors happen abort API
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

	    END LOOP; -- local
	  CLOSE csr_local_rules_templates;

  ELSE
    -- Org Wide Rules exists in current concurrent request
	  -- Open the Org Wide Cursor
    OPEN csr_org_rules_templates(p_org_id => l_org_id);
    LOOP
		   FETCH csr_org_rules_templates INTO l_template_id;
		   EXIT WHEN csr_org_rules_templates%NOTFOUND;
    		     import_template
               (
                p_api_version       => 1,
                p_init_msg_list	 => 'T',
                p_commit	           => 'T',
                p_template_id       =>  l_template_id,
                p_mode => p_mode,
                x_return_status	 =>  x_return_status,
                x_msg_data	      =>  x_msg_data,
                x_msg_count	      =>  x_msg_count
               ) ;

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

    END LOOP; -- Org Rules Templates
	  CLOSE csr_org_rules_templates;

  END IF;

  -- Standard call to get message count and if count is 1, get message info
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


END sync_templates;



---------------------------------------------------

---------------------------------------------------
--  Procedure: This procedure will be registered as
--  Contract Expert Rules Publication concurrent program
---------------------------------------------------
PROCEDURE publish_rules
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_org_id           IN NUMBER
) IS

x_return_status       VARCHAR2(1);
x_msg_data            VARCHAR2(4000);
x_msg_count           NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'publish_rules';
req_data              VARCHAR2(240);
x_cz_cp_status        BOOLEAN;
x_phase               VARCHAR2(1000);
x_status              VARCHAR2(1000);
x_dev_phase           VARCHAR2(1000);
x_dev_status          VARCHAR2(1000);
x_message             VARCHAR2(1000);
l_rules_cnt           NUMBER;
l_sequence_id         NUMBER;
l_qa_status           VARCHAR2(1);
l_conc_pgm_desc	      FND_NEW_MESSAGES.message_text%TYPE;



CURSOR csr_get_child_req_dtls IS
SELECT SUBSTR(req_data,
                      1,
                      INSTR(req_data,':',1) -1
                    )  child_req_id,
       SUBSTR(req_data,
                      INSTR(req_data,':',1) + 1
                    ) run_id
FROM dual;

CURSOR csr_cz_imp_rules_cnt IS
SELECT COUNT(*)
  FROM cz_imp_rules
 WHERE run_id = G_RUN_ID;

-- Added for 4103931
CURSOR csr_pub_rule_list IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID;

l_rule_exists_flag VARCHAR2(1) := NULL;

l_line_level_flag         okc_xprt_rule_hdrs_all.line_level_flag%TYPE;

l_okc_rules_engine VARCHAR2(1);

l_rule_id NUMBER;

CURSOR csr_rules IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;


BEGIN

SELECT fnd_profile.Value('OKC_USE_CONTRACTS_RULES_ENGINE') INTO l_okc_rules_engine FROM dual;

fnd_file.put_line(FND_FILE.LOG,'Using OKC Rules Engine'||l_okc_rules_engine);

IF Nvl(l_okc_rules_engine,'N') = 'N' THEN

  -- Check if the concurrent program is being  restarted due to completion  of child request
      req_data := fnd_conc_global.request_data;

IF req_data IS NULL THEN
   -- Calling the parent concurrent prorgam for the first time
   -- Execute Steps 1 to 7

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

         -- log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'Current Concurrent Request Id :  '||FND_GLOBAL.CONC_REQUEST_ID);
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'Org Id :  '||p_org_id);

	    /*
	        Step 1: Update current request Id for all rules to be published
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 1: Updating request_id for rules to be published  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        -- Update request_id for all Rules in Pending Publication for current org id
           UPDATE okc_xprt_rule_hdrs_all
              SET request_id = FND_GLOBAL.CONC_REQUEST_ID,
		        program_id = FND_GLOBAL.CONC_PROGRAM_ID,
			   program_application_id = FND_GLOBAL.PROG_APPL_ID,
			   program_update_date = SYSDATE,
			   last_update_login = FND_GLOBAL.LOGIN_ID,
			   last_update_date = SYSDATE,
			   last_updated_by = FND_GLOBAL.USER_ID
            WHERE org_id = p_org_id
		    AND intent = DECODE(NVL(fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT'),'A'),'A',
		                                  intent,
								    fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT')
						    )
              AND status_code = 'PENDINGPUB';

	    -- Check If any rules are to be processed else exit
	       IF SQL%NOTFOUND THEN
		    -- exit as no rules to be processed
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'No Rules to be processed ');
		    fnd_file.put_line(FND_FILE.LOG,'  ');

		    retcode := 0;
              errbuf := '';
		    RETURN;

		  END IF; -- no rows to be processed

		  -- commit the data
		  COMMIT WORK;

		   /*
		      Step 1.1: Rules QA checks
		   */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 1.1: Rules QA Checks old        ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

            OKC_XPRT_UTIL_PVT.check_rules_validity
            (
             p_qa_mode             => 'PUBLISH',
             p_template_id   	     => NULL,
		   x_sequence_id         => l_sequence_id,
		   x_qa_status           => l_qa_status,
             x_return_status	     => x_return_status,
             x_msg_data	          => x_msg_data,
             x_msg_count	          => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After OKC_XPRT_UTIL_PVT.check_rules_validity');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'x_qa_status: '||l_qa_status);
            fnd_file.put_line(FND_FILE.LOG,'x_sequence_id: '||l_sequence_id);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

	    -- Check If any rules had QA errors and abort
	       IF l_qa_status <> 'S' THEN
		    -- exit as no rules had QA errors
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'Rules QA Check failed');
		    fnd_file.put_line(FND_FILE.LOG,'  ');


			-- Added for Bug 4103931
			FOR csr_pub_rule_rec IN csr_pub_rule_list
			LOOP
				l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
				UPDATE okc_xprt_rule_hdrs_all
				   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
				 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
				   AND rule_id = csr_pub_rule_rec.rule_id;
           	    l_rule_exists_flag := 'F';
			END LOOP;


		    -- Added for Bug 4690232
		    COMMIT;

		    retcode := 2;
              errbuf := '';
		    RETURN;

		  END IF; -- QA Errors



		   /*
		      Step 2: Import Variable Model
		   */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 2: Importing Variable Model');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

            OKC_XPRT_IMPORT_VARIABLES_PVT.import_variables
            (
             p_api_version              => 1,
             p_init_msg_list	    => 'T',
             p_commit	            => 'T',
             p_org_id        	    => p_org_id,
             x_return_status	    => x_return_status,
             x_msg_data	            => x_msg_data,
             x_msg_count	            => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Importing Variable Model');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


		   /*
		      Step 3: Import Clause Model
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 3: Importing Clause Model');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

            OKC_XPRT_IMPORT_CLAUSES_PVT.import_clauses
            (
             p_api_version              => 1,
             p_init_msg_list	    => 'T',
             p_commit	            => 'T',
             p_org_id        	    => p_org_id,
             x_return_status	    => x_return_status,
             x_msg_data	            => x_msg_data,
             x_msg_count	            => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Importing Clause Model');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

		   /*
		      Step 4: Import Template Model(s)
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 4: Importing Template Models');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		   OKC_XPRT_IMPORT_TEMPLATE_PVT.rebuild_tmpl_pub_disable
            (
             x_return_status	       => x_return_status,
             x_msg_data	            => x_msg_data,
             x_msg_count	            => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Importing Template Models');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


		   /*
		      Step 5: Populate cz_imp_rules
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 5: Populating cz_imp_rules ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_IMPORT_RULES_PVT.import_rules_publish
             (
              x_run_id            => G_RUN_ID,
              x_return_status	    => x_return_status,
              x_msg_data	         => x_msg_data,
              x_msg_count	    => x_msg_count
		   );

               fnd_file.put_line(FND_FILE.LOG,'  ');
               fnd_file.put_line(FND_FILE.LOG,'After Populating cz_imp_rules');
               fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
               fnd_file.put_line(FND_FILE.LOG,'Rule Import Run Id : '||G_RUN_ID);
               fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

	        /*
			 Step 5.1: Count Rules to be imported
		      Check if there are any records in cz_imp_rules
			 If there are no records in cz_imp_rules then there were no expert enabled templates
			 attached to the rule. Just change the status of the rule to ACTIVE
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 5.1:Count Rules to be imported');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		    OPEN csr_cz_imp_rules_cnt;
		      FETCH csr_cz_imp_rules_cnt INTO l_rules_cnt;
		    CLOSE csr_cz_imp_rules_cnt;

              fnd_file.put_line(FND_FILE.LOG,'  ');
              fnd_file.put_line(FND_FILE.LOG,'Total Rules to be Imported to CZ: '||l_rules_cnt);
              fnd_file.put_line(FND_FILE.LOG,'  ');


              IF l_rules_cnt = 0 THEN

		       OKC_XPRT_UTIL_PVT.publish_rule_with_no_tmpl
                 (
                  p_calling_mode    =>  'PUBLISH',
			   x_return_status	 => x_return_status,
                  x_msg_data	      => x_msg_data,
                  x_msg_count	      => x_msg_count
			  );

                 fnd_file.put_line(FND_FILE.LOG,'  ');
                 fnd_file.put_line(FND_FILE.LOG,'After OKC_XPRT_UTIL_PVT.publish_rule_with_no_tmpl');
                 fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
                 fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

		       fnd_file.put_line(FND_FILE.LOG,'  ');
  		       fnd_file.put_line(FND_FILE.LOG,'Rules has No expert template attached');
		       fnd_file.put_line(FND_FILE.LOG,'  ');

		       retcode := 0;
                 errbuf := '';
		       RETURN;

		   END IF; -- l_rules_cnt = 0


		   /*
		      Step 6: Insert Extension Rules
		   */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 6: Calling API to insert extension rule records');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

		  OKC_XPRT_IMPORT_RULES_PVT.attach_extension_rule
		  (
		    p_api_version       => 1,
		    p_init_msg_list     => 'T',
		    p_run_id            => G_RUN_ID,
              x_return_status	    => x_return_status,
              x_msg_data	         => x_msg_data,
              x_msg_count	    => x_msg_count
		  );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 6: After Calling API to insert extension rule records');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

            /*
		     Step 7: Call the CZ Rule Import Concurrent Program
			CZ Pgm: Import Configuration Rules (CZRULEIMPORTCP)
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 7: Calling the CZ Rule Import Concurrent Program');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'Parameter Run Id : '||G_RUN_ID);


    	    FND_MESSAGE.set_name('OKC','OKC_XPRT_RULE_CCPRG_ACT_MSG');
            l_conc_pgm_desc := FND_MESSAGE.get;

		  G_REQUEST_ID := fnd_request.submit_request
		                  (application       => 'CZ',
					    program           => 'CZRULEIMPORTCP',
					    description       => l_conc_pgm_desc,
					    start_time        => NULL,
					    sub_request       => TRUE,
					    argument1         => G_RUN_ID
					   );

            fnd_file.put_line(FND_FILE.LOG,'Request Id of CZ Rule Concurrent Pgm :  '||G_REQUEST_ID);

		  -- commit the data
		  COMMIT WORK;

		  IF NVL(G_REQUEST_ID,0) = 0 THEN
		    -- Could Not submit Conc Pgm
		     fnd_message.set_name('OKC','OKC_XPRT_SUB_CZ_RUL_PGM');
		     fnd_file.put_line(FND_FILE.LOG,'Could NOT submit CZ Concurrent Program');

		     		 -- Added for Bug 4757731
		     		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		     		 LOOP
		     		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		     		 	UPDATE okc_xprt_rule_hdrs_all
		     		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		     		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		     		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		     		 	l_rule_exists_flag := 'F';
		     		 END LOOP;
		 COMMIT;

               RAISE FND_API.G_EXC_ERROR;
		  ELSE
		    -- child submission successful, pause the parent program
		    fnd_conc_global.set_req_globals
		    ( conc_status => 'PAUSED',
		      request_data => to_char(G_REQUEST_ID)||':'||to_char(G_RUN_ID)
		    );
		  END IF;  -- child submitted successfully

 ELSE
   -- req_data IS NOT NULL
   -- Restarting the Parent Concurrent Program after completing the child
   -- Execute the remaing steps
   /*
     Note : when the Parent pgm resumes, the session id for the pgm is different
	then the original session id. Any variables set before cannot be read
	Any variables required in this block are put in request_data and read from
	the same

   */

      OPEN csr_get_child_req_dtls;
	   FETCH csr_get_child_req_dtls INTO G_REQUEST_ID, G_RUN_ID;
	 CLOSE csr_get_child_req_dtls;

      x_cz_cp_status :=  fnd_concurrent.get_request_status
	                      (G_REQUEST_ID,
			      	   NULL,
				        NULL,
      				   x_phase,
	      			   x_status,
		      		   x_dev_phase,
			      	   x_dev_status,
	  		             x_message
      				   );

          fnd_file.put_line(FND_FILE.LOG,'  ');
        	fnd_file.put_line(FND_FILE.LOG,'After Completing CZ Rule Conc Pgm with request id :'||G_REQUEST_ID);
        	fnd_file.put_line(FND_FILE.LOG,'Run Id : '||G_RUN_ID);
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
        	fnd_file.put_line(FND_FILE.LOG,'Results ');
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
        	fnd_file.put_line(FND_FILE.LOG,'Phase : '||x_phase);
        	fnd_file.put_line(FND_FILE.LOG,'Status : '||x_status);
        	fnd_file.put_line(FND_FILE.LOG,'dev_phase : '||x_dev_phase);
        	fnd_file.put_line(FND_FILE.LOG,'dev_status : '||x_dev_status);
        	fnd_file.put_line(FND_FILE.LOG,'Message : '||substr(x_message,1,100));
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
          fnd_file.put_line(FND_FILE.LOG,'  ');

	IF x_dev_phase <> 'COMPLETED' AND
	   x_dev_status NOT IN ('NORMAL','WARNING')  THEN
	   -- error in CZ Concurrent Program
               fnd_file.put_line(FND_FILE.LOG, 'Error in CZ Rule Import Concurrent Program ');
               fnd_file.put_line(FND_FILE.LOG, 'Request Id :'||G_REQUEST_ID);
               fnd_file.put_line(FND_FILE.LOG, 'Run Id :'||G_RUN_ID);

               		 -- Added for Bug 4757731
	       		 FOR csr_pub_rule_rec IN csr_pub_rule_list
	       		 LOOP
	       		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
	       		 	UPDATE okc_xprt_rule_hdrs_all
	       		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
	       		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
	       		 	   AND rule_id = csr_pub_rule_rec.rule_id;
	       		 	l_rule_exists_flag := 'F';
	       		 END LOOP;
		 COMMIT;

               RAISE FND_API.G_EXC_ERROR;
	END IF;


            /*
		     Step 8: Check status of Rules Imported
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 8: Checking Status of Rules imported');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

               OKC_XPRT_UTIL_PVT.check_import_status
               (
                p_run_id           => G_RUN_ID,
                p_import_status    => 'S',
                p_model_type       => 'R', -- Rules Import
                x_return_status    => x_return_status,
                x_msg_data	     => x_msg_data,
                x_msg_count        => x_msg_count
               );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After checking import status');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


            /*
		     Step 9: Call the Test Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 9: Calling the Test Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_UTIL_PVT.create_test_publication
		   (
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Test Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
            /*
		     Step 10: Call the Production Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 9: Calling the Production Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_UTIL_PVT.create_production_publication
		   (
		    p_calling_mode  => 'PUBLISH',
              p_template_id   => NULL, -- pick all templates for the current request
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Production Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_pub_rule_rec IN csr_pub_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_pub_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

END IF; -- req_data IS NULL

ELSE

-- Code for the OKC Rules Engine
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

         -- log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'Current Concurrent Request Id :  '||FND_GLOBAL.CONC_REQUEST_ID);
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'Org Id :  '||p_org_id);

	    /*
	        Step 1: Update current request Id for all rules to be published
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 1: Updating request_id for rules to be published  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        -- Update request_id for all Rules in Pending Publication for current org id
           UPDATE okc_xprt_rule_hdrs_all
              SET request_id = FND_GLOBAL.CONC_REQUEST_ID,
		        program_id = FND_GLOBAL.CONC_PROGRAM_ID,
			   program_application_id = FND_GLOBAL.PROG_APPL_ID,
			   program_update_date = SYSDATE,
			   last_update_login = FND_GLOBAL.LOGIN_ID,
			   last_update_date = SYSDATE,
			   last_updated_by = FND_GLOBAL.USER_ID
            WHERE org_id = p_org_id
		    AND intent = DECODE(NVL(fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT'),'A'),'A',
		                                  intent,
								    fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT')
						    )
              AND status_code = 'PENDINGPUB';

	    -- Check If any rules are to be processed else exit
	       IF SQL%NOTFOUND THEN
		    -- exit as no rules to be processed
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'No Rules to be processed ');
		    fnd_file.put_line(FND_FILE.LOG,'  ');

		    retcode := 0;
              errbuf := '';
		    RETURN;

		  END IF; -- no rows to be processed

		  -- commit the data
		  COMMIT WORK;

		   /*
		      Step 1.1: Rules QA checks
		   */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 1.1: Rules QA Checks new         ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

            OKC_XPRT_UTIL_PVT.check_rules_validity
            (
             p_qa_mode             => 'PUBLISH',
             p_template_id   	     => NULL,
		   x_sequence_id         => l_sequence_id,
		   x_qa_status           => l_qa_status,
             x_return_status	     => x_return_status,
             x_msg_data	          => x_msg_data,
             x_msg_count	          => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After OKC_XPRT_UTIL_PVT.check_rules_validity');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'x_qa_status: '||l_qa_status);
            fnd_file.put_line(FND_FILE.LOG,'x_sequence_id: '||l_sequence_id);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               fnd_file.put_line(FND_FILE.LOG,'after');

	    -- Check If any rules had QA errors and abort
	       IF l_qa_status <> 'S' THEN
         fnd_file.put_line(FND_FILE.LOG,'in');
		    -- exit as no rules had QA errors
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'Rules QA Check failed');
		    fnd_file.put_line(FND_FILE.LOG,'  ');


			-- Added for Bug 4103931
			FOR csr_pub_rule_rec IN csr_pub_rule_list
			LOOP
				l_rule_exists_flag := check_rule_active(csr_pub_rule_rec.rule_id);
				UPDATE okc_xprt_rule_hdrs_all
				   SET status_code = DECODE(l_rule_exists_flag,'T','REVISION','F','DRAFT')
				 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
				   AND rule_id = csr_pub_rule_rec.rule_id;
           	    l_rule_exists_flag := 'F';
			END LOOP;


		    -- Added for Bug 4690232
		    COMMIT;

		    retcode := 2;
              errbuf := '';
              fnd_file.put_line(FND_FILE.LOG,'Return');
		    RETURN;

		  END IF; -- QA Errors


  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
  fnd_file.put_line(FND_FILE.LOG,'Synchronize templates with rules         ');
  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');


  sync_templates
    (
    p_mode => 'P',
    x_return_status	=> x_return_status,
    x_msg_data	    => x_msg_data,
    x_msg_count	    => x_msg_count
    );

  -- Update all the Question order records that have question_rule_status as PENDINGPUB
	UPDATE Okc_Xprt_Question_Orders
	SET runtime_available_flag = 'Y',
	    question_rule_status  = 'ACTIVE',
	    last_updated_by = FND_GLOBAL.USER_ID,
	    last_update_date = SYSDATE,
	    last_update_login = FND_GLOBAL.LOGIN_ID
	WHERE question_rule_status = 'PENDINGPUB'
	AND   template_id IN ( SELECT template_id
		                     FROM okc_terms_templates_all
				                 WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID
		                   );

  -- Delete from okc_xprt_template_rules
  DELETE FROM okc_xprt_template_rules
	WHERE NVL(deleted_flag,'N') = 'Y'
	AND   template_id IN ( SELECT template_id
		                     FROM okc_terms_templates_all
				                 WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID
		                   );

  -- Update published_flag in okc_xprt_template_rules
  UPDATE okc_xprt_template_rules
	SET    published_flag = 'Y'
	WHERE template_id IN ( SELECT template_id
		                     FROM okc_terms_templates_all
				                 WHERE xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID
		                   );
  -- Update Rule status
  OPEN csr_rules;
  LOOP
    FETCH csr_rules INTO l_rule_id;
 	  EXIT WHEN csr_rules%NOTFOUND;

  	  SELECT okc_xprt_util_pvt.is_rule_line_level(l_rule_id) INTO l_line_level_flag FROM DUAL;

  	  UPDATE okc_xprt_rule_hdrs_all
	    SET    status_code = 'ACTIVE',
		         published_flag = 'Y',
		         line_level_flag = l_line_level_flag, --is_rule_line_level(l_rule_id),
		         last_updated_by = FND_GLOBAL.USER_ID,
		         last_update_date = SYSDATE,
		         last_update_login = FND_GLOBAL.LOGIN_ID,
		         activation_date = SYSDATE
	    WHERE  rule_id = l_rule_id;

      DELETE FROM okc_xprt_rule_outcomes_active WHERE rule_id = l_rule_id;

      DELETE FROM okc_xprt_rule_cond_vals_active WHERE rule_condition_id IN (SELECT rule_condition_id FROM okc_xprt_rule_conditions WHERE rule_id = l_rule_id);

      DELETE FROM okc_xprt_rule_cond_active WHERE rule_id = l_rule_id;

      DELETE FROM okc_xprt_rule_hdrs_all_active WHERE rule_id = l_rule_id;

  END LOOP;
  CLOSE csr_rules;

  COMMIT WORK;



END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := SQLERRM;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

END publish_rules;

---------------------------------------------------
--  Procedure: This procedure will be registered as
--  Contract Expert Rules Disable concurrent program
---------------------------------------------------
PROCEDURE disable_rules
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_org_id           IN NUMBER
) IS

x_return_status       VARCHAR2(1);
x_msg_data            VARCHAR2(4000);
x_msg_count           NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'disable_rules';
req_data              VARCHAR2(240);
x_cz_cp_status        BOOLEAN;
x_phase               VARCHAR2(1000);
x_status              VARCHAR2(1000);
x_dev_phase           VARCHAR2(1000);
x_dev_status          VARCHAR2(1000);
x_message             VARCHAR2(1000);
l_rules_cnt           NUMBER;
l_conc_pgm_desc	      FND_NEW_MESSAGES.message_text%TYPE;

CURSOR csr_get_child_req_dtls IS
SELECT SUBSTR(req_data,
                      1,
                      INSTR(req_data,':',1) -1
                    )  child_req_id,
       SUBSTR(req_data,
                      INSTR(req_data,':',1) + 1
                    ) run_id
FROM dual;

CURSOR csr_cz_imp_rules_cnt IS
SELECT COUNT(*)
  FROM cz_imp_rules
 WHERE run_id = G_RUN_ID;

-- Added for 4757731
CURSOR csr_dis_rule_list IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID;

l_rule_exists_flag VARCHAR2(1) := NULL;

l_okc_rules_engine VARCHAR2(1);

l_rule_id NUMBER;

l_line_level_flag         okc_xprt_rule_hdrs_all.line_level_flag%TYPE;

CURSOR csr_rules IS
SELECT rule_id
  FROM okc_xprt_rule_hdrs_all
 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;



BEGIN

SELECT fnd_profile.Value('OKC_USE_CONTRACTS_RULES_ENGINE') INTO l_okc_rules_engine FROM dual;

fnd_file.put_line(FND_FILE.LOG,'Using OKC Rules Engine'||l_okc_rules_engine);

IF Nvl(l_okc_rules_engine,'N') = 'N' THEN

  -- Check if the concurrent program is being  restarted due to completion  of child request
      req_data := fnd_conc_global.request_data;

IF req_data IS NULL THEN
   -- Calling the parent concurrent prorgam for the first time
   -- Execute Steps 1 to 4

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

         -- log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'Current Concurrent Request Id :  '||FND_GLOBAL.CONC_REQUEST_ID);
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'Org Id :  '||p_org_id);

	    /*
	        Step 1: Update current request Id for all rules to be published
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 1: Updating request_id for rules to be published  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        -- Update request_id for all Rules in Pending Publication for current org id
           UPDATE okc_xprt_rule_hdrs_all
              SET request_id = FND_GLOBAL.CONC_REQUEST_ID,
		        program_id = FND_GLOBAL.CONC_PROGRAM_ID,
			   program_application_id = FND_GLOBAL.PROG_APPL_ID,
			   program_update_date = SYSDATE,
			   last_update_login = FND_GLOBAL.LOGIN_ID,
			   last_update_date = SYSDATE,
			   last_updated_by = FND_GLOBAL.USER_ID
            WHERE org_id = p_org_id
		    AND intent = DECODE(NVL(fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT'),'A'),'A',
		                                  intent,
								    fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT')
						    )
              AND status_code = 'PENDINGDISABLE';

	    -- Check If any rules are to be processed else exit
	       IF SQL%NOTFOUND THEN
		    -- exit as no rules to be processed
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'No Rules to be processed ');
		    fnd_file.put_line(FND_FILE.LOG,'  ');

		    retcode := 0;
              errbuf := '';
		    RETURN;

		  END IF; -- no rows to be processed

		  -- commit the data
		  COMMIT WORK;

	     /*
		      Step 2: Import Template Model(s)
          */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 2: Importing Template Models');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		   OKC_XPRT_IMPORT_TEMPLATE_PVT.rebuild_tmpl_pub_disable
            (
             x_return_status	       => x_return_status,
             x_msg_data	            => x_msg_data,
             x_msg_count	            => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Importing Template Models');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


		   /*
		      Step 3: Populate cz_imp_rules
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 3: Populating cz_imp_rules ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_IMPORT_RULES_PVT.import_rules_disable
             (
              x_run_id            => G_RUN_ID,
              x_return_status	    => x_return_status,
              x_msg_data	         => x_msg_data,
              x_msg_count	    => x_msg_count
		   );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Populating cz_imp_rules');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'Rule Import Run Id : '||G_RUN_ID);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
	        /*
			 Step 3.1: Count Rules to be imported
		      Check if there are any records in cz_imp_rules
			 If there are no records in cz_imp_rules then there were no expert enabled templates
			 attached to the rule. Just change the status of the rule to INACTIVE
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 3.1:Count Rules to be imported');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		    OPEN csr_cz_imp_rules_cnt;
		      FETCH csr_cz_imp_rules_cnt INTO l_rules_cnt;
		    CLOSE csr_cz_imp_rules_cnt;

              fnd_file.put_line(FND_FILE.LOG,'  ');
              fnd_file.put_line(FND_FILE.LOG,'Total Rules to be Imported to CZ: '||l_rules_cnt);
              fnd_file.put_line(FND_FILE.LOG,'  ');


              IF l_rules_cnt = 0 THEN

		       OKC_XPRT_UTIL_PVT.publish_rule_with_no_tmpl
                 (
                  p_calling_mode    =>  'DISABLE',
			   x_return_status	 => x_return_status,
                  x_msg_data	      => x_msg_data,
                  x_msg_count	      => x_msg_count
			  );

                 fnd_file.put_line(FND_FILE.LOG,'  ');
                 fnd_file.put_line(FND_FILE.LOG,'After OKC_XPRT_UTIL_PVT.publish_rule_with_no_tmpl');
                 fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
                 fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

		       fnd_file.put_line(FND_FILE.LOG,'  ');
  		       fnd_file.put_line(FND_FILE.LOG,'Rules has No expert template attached');
		       fnd_file.put_line(FND_FILE.LOG,'  ');

		       retcode := 0;
                 errbuf := '';
		       RETURN;

		   END IF; -- l_rules_cnt = 0

            /*
		     Step 4: Call the CZ Rule Import Concurrent Program
			CZ Pgm: Import Configuration Rules (CZRULEIMPORTCP)
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 4: Calling the CZ Rule Import Concurrent Program');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'Parameter Run Id : '||G_RUN_ID);

    	    FND_MESSAGE.set_name('OKC','OKC_XPRT_RULE_CCPRG_DIS_MSG');
            l_conc_pgm_desc := FND_MESSAGE.get;

		  G_REQUEST_ID := fnd_request.submit_request
		                  (application       => 'CZ',
					    program           => 'CZRULEIMPORTCP',
					    description       => l_conc_pgm_desc,
					    start_time        => NULL,
					    sub_request       => TRUE,
					    argument1         => G_RUN_ID
					   );

            fnd_file.put_line(FND_FILE.LOG,'Request Id of CZ Rule Concurrent Pgm :  '||G_REQUEST_ID);

		  -- commit the data
		  COMMIT WORK;

		  IF NVL(G_REQUEST_ID,0) = 0 THEN
		    -- Could Not submit Conc Pgm
		     fnd_message.set_name('OKC','OKC_XPRT_SUB_CZ_RUL_PGM');
		     fnd_file.put_line(FND_FILE.LOG,'Could NOT submit CZ Concurrent Program');
 		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
               RAISE FND_API.G_EXC_ERROR;
		  ELSE
		    -- child submission successful, pause the parent program
		    fnd_conc_global.set_req_globals
		    ( conc_status => 'PAUSED',
		      request_data => to_char(G_REQUEST_ID)||':'||to_char(G_RUN_ID)
		    );
		  END IF;  -- child submitted successfully

 ELSE
   -- req_data IS NOT NULL
   -- Restarting the Parent Concurrent Program after completing the child
   -- Execute the remaing steps
   /*
     Note : when the Parent pgm resumes, the session id for the pgm is different
	then the original session id. Any variables set before cannot be read
	Any variables required in this block are put in request_data and read from
	the same

   */

      OPEN csr_get_child_req_dtls;
	   FETCH csr_get_child_req_dtls INTO G_REQUEST_ID, G_RUN_ID;
	 CLOSE csr_get_child_req_dtls;

      x_cz_cp_status :=  fnd_concurrent.get_request_status
	                      (G_REQUEST_ID,
			      	   NULL,
				        NULL,
      				   x_phase,
	      			   x_status,
		      		   x_dev_phase,
			      	   x_dev_status,
	  		             x_message
      				   );

          fnd_file.put_line(FND_FILE.LOG,'  ');
        	fnd_file.put_line(FND_FILE.LOG,'After Completing CZ Rule Conc Pgm with request id :'||G_REQUEST_ID);
        	fnd_file.put_line(FND_FILE.LOG,'Run Id : '||G_RUN_ID);
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
        	fnd_file.put_line(FND_FILE.LOG,'Results ');
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
        	fnd_file.put_line(FND_FILE.LOG,'Phase : '||x_phase);
        	fnd_file.put_line(FND_FILE.LOG,'Status : '||x_status);
        	fnd_file.put_line(FND_FILE.LOG,'dev_phase : '||x_dev_phase);
        	fnd_file.put_line(FND_FILE.LOG,'dev_status : '||x_dev_status);
        	fnd_file.put_line(FND_FILE.LOG,'Message : '||substr(x_message,1,100));
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
          fnd_file.put_line(FND_FILE.LOG,'  ');

	IF x_dev_phase <> 'COMPLETED' AND
	   x_dev_status NOT IN ('NORMAL','WARNING')  THEN
	   -- error in CZ Concurrent Program
               fnd_file.put_line(FND_FILE.LOG, 'Error in CZ Rule Import Concurrent Program ');
               fnd_file.put_line(FND_FILE.LOG, 'Request Id :'||G_REQUEST_ID);
               fnd_file.put_line(FND_FILE.LOG, 'Run Id :'||G_RUN_ID);
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
               RAISE FND_API.G_EXC_ERROR;
	END IF;


            /*
		     Step 5: Check status of Rules Imported
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 5: Checking Status of Rules imported');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

               OKC_XPRT_UTIL_PVT.check_import_status
               (
                p_run_id           => G_RUN_ID,
                p_import_status    => 'S',
                p_model_type       => 'R', -- Rules Import
                x_return_status    => x_return_status,
                x_msg_data	     => x_msg_data,
                x_msg_count        => x_msg_count
               );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After checking import status');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

            /*
		     Step 6: Call the Test Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 6: Calling the Test Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');


             OKC_XPRT_UTIL_PVT.create_test_publication
		   (
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Test Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

            /*
		     Step 7: Call the Production Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 7: Calling the Production Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_UTIL_PVT.create_production_publication
		   (
		    p_calling_mode  => 'DISABLE',
              p_template_id   => NULL, -- pick all templates for the current request
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Production Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF (x_return_status = G_RET_STS_ERROR) THEN
		 -- Added for Bug 4757731
		 FOR csr_dis_rule_rec IN csr_dis_rule_list
		 LOOP
		 	l_rule_exists_flag := check_rule_active(csr_dis_rule_rec.rule_id);
		 	UPDATE okc_xprt_rule_hdrs_all
		 	   SET status_code = DECODE(l_rule_exists_flag,'T','ACTIVE',status_code)
		 	 WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
		 	   AND rule_id = csr_dis_rule_rec.rule_id;
		 	l_rule_exists_flag := 'F';
		 END LOOP;
		 COMMIT;
		 -- Added for Bug 4757731
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


















    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

END IF; -- req_data IS NULL

ELSE
-- New OKC Rules Engine

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

         -- log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'Current Concurrent Request Id :  '||FND_GLOBAL.CONC_REQUEST_ID);
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'Org Id :  '||p_org_id);

	    /*
	        Step 1: Update current request Id for all rules to be published
	    */

         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'Step 1: Updating request_id for rules to be published  ');
         fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
         fnd_file.put_line(FND_FILE.LOG,'  ');

        -- Update request_id for all Rules in Pending Publication for current org id
           UPDATE okc_xprt_rule_hdrs_all
              SET request_id = FND_GLOBAL.CONC_REQUEST_ID,
		        program_id = FND_GLOBAL.CONC_PROGRAM_ID,
			   program_application_id = FND_GLOBAL.PROG_APPL_ID,
			   program_update_date = SYSDATE,
			   last_update_login = FND_GLOBAL.LOGIN_ID,
			   last_update_date = SYSDATE,
			   last_updated_by = FND_GLOBAL.USER_ID
            WHERE org_id = p_org_id
		    AND intent = DECODE(NVL(fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT'),'A'),'A',
		                                  intent,
								    fnd_profile.value('OKC_LIBRARY_ACCESS_INTENT')
						    )
              AND status_code = 'PENDINGDISABLE';

	    -- Check If any rules are to be processed else exit
	       IF SQL%NOTFOUND THEN
		    -- exit as no rules to be processed
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'No Rules to be processed ');
		    fnd_file.put_line(FND_FILE.LOG,'  ');

		    retcode := 0;
              errbuf := '';
		    RETURN;

		  END IF; -- no rows to be processed

		  -- commit the data
		  COMMIT WORK;

  fnd_file.put_line(FND_FILE.LOG,'  ');
  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
  fnd_file.put_line(FND_FILE.LOG,'Synchronize templates with rules         ');
  fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
  fnd_file.put_line(FND_FILE.LOG,'  ');


  sync_templates
    (
    p_mode => 'D',
    x_return_status	=> x_return_status,
    x_msg_data	    => x_msg_data,
    x_msg_count	    => x_msg_count
    );



  -- Update Rule status
  OPEN csr_rules;
  LOOP
    FETCH csr_rules INTO l_rule_id;
 	  EXIT WHEN csr_rules%NOTFOUND;

  	  SELECT okc_xprt_util_pvt.is_rule_line_level(l_rule_id) INTO l_line_level_flag FROM DUAL;

  	  UPDATE okc_xprt_rule_hdrs_all
	    SET    status_code = 'INACTIVE',
		         published_flag = 'Y',
		         line_level_flag = l_line_level_flag, --is_rule_line_level(l_rule_id),
		         last_updated_by = FND_GLOBAL.USER_ID,
		         last_update_date = SYSDATE,
		         last_update_login = FND_GLOBAL.LOGIN_ID
	    WHERE  rule_id = l_rule_id;

      DELETE FROM okc_xprt_rule_outcomes_active WHERE rule_id = l_rule_id;

      DELETE FROM okc_xprt_rule_cond_vals_active WHERE rule_condition_id IN (SELECT rule_condition_id FROM okc_xprt_rule_conditions WHERE rule_id = l_rule_id);

      DELETE FROM okc_xprt_rule_cond_active WHERE rule_id = l_rule_id;

      DELETE FROM okc_xprt_rule_hdrs_all_active WHERE rule_id = l_rule_id;

  END LOOP;
  CLOSE csr_rules;

  COMMIT WORK;



END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := SQLERRM;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

END disable_rules;

---------------------------------------------------
--  Procedure: This procedure will be registered as
--  Contract Expert Template Sync concurrent program
---------------------------------------------------
PROCEDURE rebuild_templates
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_org_id           IN NUMBER,
 p_intent           IN VARCHAR2,
 p_template_id      IN NUMBER DEFAULT NULL
) IS

CURSOR csr_tmpl_dtls IS
SELECT 'x'
  FROM okc_terms_templates_all t
 WHERE  t.org_id = p_org_id
   AND  t.intent = p_intent
   AND  t.template_id = NVL(p_template_id, template_id);

CURSOR csr_active_rules_cnt IS
SELECT COUNT(*)
  FROM okc_xprt_rule_hdrs_all
 WHERE org_id = p_org_id
   AND intent = p_intent
   AND status_code = 'ACTIVE';

x_return_status       VARCHAR2(1);
x_msg_data            VARCHAR2(4000);
x_msg_count           NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'rebuild_templates';
l_dummy               VARCHAR2(1);
l_rule_count          NUMBER;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

         -- log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'Current Concurrent Request Id :  '||FND_GLOBAL.CONC_REQUEST_ID);
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'Org Id :  '||p_org_id);
         fnd_file.put_line(FND_FILE.LOG,'Intent :  '||p_intent);
         fnd_file.put_line(FND_FILE.LOG,'Template Id :  '||p_template_id);

	    -- Validate Parameters if p_template_id IS NOT NULL
		    OPEN csr_tmpl_dtls;
		      FETCH csr_tmpl_dtls INTO l_dummy;
	    	       IF csr_tmpl_dtls%NOTFOUND THEN
		        -- exit as no templates to be processed
			   CLOSE csr_tmpl_dtls;
		        fnd_file.put_line(FND_FILE.LOG,'  ');
		        fnd_file.put_line(FND_FILE.LOG,'No Templates to be synchronized ');
		        fnd_file.put_line(FND_FILE.LOG,'  ');
		        retcode := 0;
                  errbuf := '';
		        RETURN;
		      END IF; -- no rows to be processed
		    CLOSE csr_tmpl_dtls;

		-- Validate if there is atleast 1 ACTIVE Rule for the Org and Intent
		    OPEN csr_active_rules_cnt;
		      FETCH csr_active_rules_cnt INTO l_rule_count;
		    CLOSE csr_active_rules_cnt;

		     IF l_rule_count = 0 THEN
			  -- no active rules
		        fnd_file.put_line(FND_FILE.LOG,'  ');
		        fnd_file.put_line(FND_FILE.LOG,'No Active Rules for the Org and Intent');
		        fnd_file.put_line(FND_FILE.LOG,'  ');
		        retcode := 0;
                  errbuf := '';
		        RETURN;
		      END IF; -- no active rules

	     /*
		      Step 1: Import Template Model(s)
          */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 1: Importing Template Models');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		   OKC_XPRT_IMPORT_TEMPLATE_PVT.rebuild_tmpl_sync
            (
		   p_org_id                => p_org_id,
             p_intent                => p_intent,
             p_template_id           => p_template_id,
             x_return_status	       => x_return_status,
             x_msg_data	            => x_msg_data,
             x_msg_count	            => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Importing Template Models');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;



            /*
		     Step 2: Call the Test Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 2: Calling the Test Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_UTIL_PVT.create_test_publication
		   (
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Test Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

                --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;


            /*
		     Step 3: Call the Production Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 3: Calling the Production Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_UTIL_PVT.create_production_publication
		   (
		    p_calling_mode  => 'SYNC',
              p_template_id   => NULL, -- pick all templates for the current request
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Production Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

                --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;

















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

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := SQLERRM;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

END rebuild_templates;

---------------------------------------------------
--  Procedure: This procedure will be registered as
--  Contract Expert Publish Template During Approval
---------------------------------------------------
PROCEDURE tmpl_approval_publish_rules
(
 errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY VARCHAR2,
 p_template_id      IN NUMBER
) IS

x_return_status       VARCHAR2(1);
x_msg_data            VARCHAR2(4000);
x_msg_count           NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'tmpl_approval_publish_rules';
req_data              VARCHAR2(240);
x_cz_cp_status        BOOLEAN;
x_phase               VARCHAR2(1000);
x_status              VARCHAR2(1000);
x_dev_phase           VARCHAR2(1000);
x_dev_status          VARCHAR2(1000);
x_message             VARCHAR2(1000);
l_rules_cnt           NUMBER;
l_sequence_id         NUMBER;
l_qa_status           VARCHAR2(1);
l_conc_pgm_desc	      FND_NEW_MESSAGES.message_text%TYPE;


CURSOR csr_get_child_req_dtls IS
SELECT SUBSTR(req_data,
                      1,
                      INSTR(req_data,':',1) -1
                    )  child_req_id,
       SUBSTR(req_data,
                      INSTR(req_data,':',1) + 1
                    ) run_id
FROM dual;

CURSOR csr_cz_imp_rules_cnt IS
SELECT COUNT(*)
  FROM cz_imp_rules
 WHERE run_id = G_RUN_ID;


 l_okc_rules_engine VARCHAR2(1);


BEGIN



SELECT fnd_profile.Value('OKC_USE_CONTRACTS_RULES_ENGINE') INTO l_okc_rules_engine FROM dual;

fnd_file.put_line(FND_FILE.LOG,'Using OKC Rules Engine'||l_okc_rules_engine);

IF Nvl(l_okc_rules_engine,'N') = 'N' THEN

  -- Check if the concurrent program is being  restarted due to completion  of child request
      req_data := fnd_conc_global.request_data;

IF req_data IS NULL THEN
   -- Calling the parent concurrent prorgam for the first time
   -- Execute Steps 1 to 3

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

         -- log file
         fnd_file.put_line(FND_FILE.LOG,'  ');
         fnd_file.put_line(FND_FILE.LOG,'Current Concurrent Request Id :  '||FND_GLOBAL.CONC_REQUEST_ID);
         fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
         fnd_file.put_line(FND_FILE.LOG,'Template Id :  '||p_template_id);

		   /*
		      Step 0: Template Rules QA checks
		   */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 0: Template Rules QA Checks         ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

            OKC_XPRT_UTIL_PVT.check_rules_validity
            (
             p_qa_mode             => 'APPROVAL',
             p_template_id   	     => p_template_id,
		   x_sequence_id         => l_sequence_id,
		   x_qa_status           => l_qa_status,
             x_return_status	     => x_return_status,
             x_msg_data	          => x_msg_data,
             x_msg_count	          => x_msg_count
            ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After OKC_XPRT_UTIL_PVT.check_rules_validity');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'x_qa_status: '||l_qa_status);
            fnd_file.put_line(FND_FILE.LOG,'x_sequence_id: '||l_sequence_id);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

	    -- Check If any rules had QA errors and abort
	       IF l_qa_status <> 'S' THEN
		    -- exit as no rules had QA errors
		    fnd_file.put_line(FND_FILE.LOG,'  ');
		    fnd_file.put_line(FND_FILE.LOG,'Template Rules QA Check failed');
		    fnd_file.put_line(FND_FILE.LOG,'  ');

		    retcode := 2;
              errbuf := '';
		    RETURN;

		  END IF; -- QA Errors



	     /*
		      Step 1: Import Template Model
          */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 1: Importing Template Model');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		   OKC_XPRT_IMPORT_TEMPLATE_PVT.import_template
               (
                p_api_version       => 1,
                p_init_msg_list	 => 'T',
                p_commit	           => 'T',
                p_template_id       =>  p_template_id,
                x_return_status	 =>  x_return_status,
                x_msg_data	      =>  x_msg_data,
                x_msg_count	      =>  x_msg_count
               ) ;

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Importing Template Model');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


		   /*
		      Step 2: Populate cz_imp_rules
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 2: Populating cz_imp_rules ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_IMPORT_RULES_PVT.import_rule_temp_approval
             (
		    p_template_id       => p_template_id,
              x_run_id            => G_RUN_ID,
              x_return_status	    => x_return_status,
              x_msg_data	         => x_msg_data,
              x_msg_count	    => x_msg_count
		   );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Populating cz_imp_rules');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'x_msg_data: '||x_msg_data);
            fnd_file.put_line(FND_FILE.LOG,'Rule Import Run Id : '||G_RUN_ID);
            fnd_file.put_line(FND_FILE.LOG,'  ');

               --- If any errors happen abort API
               IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;


	        /*
			 Step 2.1: Count Rules to be imported
		      Check if there are any records in cz_imp_rules
			 If there are no records in cz_imp_rules then Template has no rules attached
			 Skip the rule import process
		   */

             fnd_file.put_line(FND_FILE.LOG,'  ');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'Step 2.1:Count Rules to be imported');
             fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
             fnd_file.put_line(FND_FILE.LOG,'  ');

		    OPEN csr_cz_imp_rules_cnt;
		      FETCH csr_cz_imp_rules_cnt INTO l_rules_cnt;
		    CLOSE csr_cz_imp_rules_cnt;

              fnd_file.put_line(FND_FILE.LOG,'  ');
              fnd_file.put_line(FND_FILE.LOG,'Total Rules to be Imported to CZ: '||l_rules_cnt);
              fnd_file.put_line(FND_FILE.LOG,'  ');


              IF l_rules_cnt = 0 THEN

		       fnd_file.put_line(FND_FILE.LOG,'  ');
  		       fnd_file.put_line(FND_FILE.LOG,'Template has no Rules attached');
		       fnd_file.put_line(FND_FILE.LOG,'  ');

		       retcode := 0;
                 errbuf := '';
		       RETURN;

		   END IF; -- l_rules_cnt = 0

		   /*
		      Step 2.2: Insert Extension Rules in Template Approval Flow
		   */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 2.2: Calling API to insert extension rule records');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

		  OKC_XPRT_IMPORT_RULES_PVT.attach_extension_rule_tmpl
		  (
		    p_api_version       => 1,
		    p_init_msg_list     => 'T',
		    p_run_id            => G_RUN_ID,
		    p_template_id       => p_template_id,
              x_return_status	    => x_return_status,
              x_msg_data	         => x_msg_data,
              x_msg_count	    => x_msg_count
		  );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 2.2: After Calling API to insert extension rule records');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');



            /*
		     Step 3: Call the CZ Rule Import Concurrent Program
			CZ Pgm: Import Configuration Rules (CZRULEIMPORTCP)
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 3: Calling the CZ Rule Import Concurrent Program');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'Parameter Run Id : '||G_RUN_ID);

    	    FND_MESSAGE.set_name('OKC','OKC_XPRT_RULE_CCPRG_TMPL_MSG');
            l_conc_pgm_desc := FND_MESSAGE.get;

		  G_REQUEST_ID := fnd_request.submit_request
		                  (application       => 'CZ',
					    program           => 'CZRULEIMPORTCP',
					    description       => l_conc_pgm_desc,
					    start_time        => NULL,
					    sub_request       => TRUE,
					    argument1         => G_RUN_ID
					   );

            fnd_file.put_line(FND_FILE.LOG,'Request Id of CZ Rule Concurrent Pgm :  '||G_REQUEST_ID);

		  -- commit the data
		  COMMIT WORK;


		  IF NVL(G_REQUEST_ID,0) = 0 THEN
		    -- Could Not submit Conc Pgm
		     fnd_message.set_name('OKC','OKC_XPRT_SUB_CZ_RUL_PGM');
		     fnd_file.put_line(FND_FILE.LOG,'Could NOT submit CZ Concurrent Program');
               RAISE FND_API.G_EXC_ERROR;
		  ELSE
		    -- child submission successful, pause the parent program
		    fnd_conc_global.set_req_globals
		    ( conc_status => 'PAUSED',
		      request_data => to_char(G_REQUEST_ID)||':'||to_char(G_RUN_ID)
		    );
		  END IF;  -- child submitted successfully

 ELSE
   -- req_data IS NOT NULL
   -- Restarting the Parent Concurrent Program after completing the child
   -- Execute the remaing steps
   /*
     Note : when the Parent pgm resumes, the session id for the pgm is different
	then the original session id. Any variables set before cannot be read
	Any variables required in this block are put in request_data and read from
	the same

   */

      OPEN csr_get_child_req_dtls;
	   FETCH csr_get_child_req_dtls INTO G_REQUEST_ID, G_RUN_ID;
	 CLOSE csr_get_child_req_dtls;

      x_cz_cp_status :=  fnd_concurrent.get_request_status
	                      (G_REQUEST_ID,
			      	   NULL,
				        NULL,
      				   x_phase,
	      			   x_status,
		      		   x_dev_phase,
			      	   x_dev_status,
	  		             x_message
      				   );

          fnd_file.put_line(FND_FILE.LOG,'  ');
        	fnd_file.put_line(FND_FILE.LOG,'After Completing CZ Rule Conc Pgm with request id :'||G_REQUEST_ID);
        	fnd_file.put_line(FND_FILE.LOG,'Run Id : '||G_RUN_ID);
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
        	fnd_file.put_line(FND_FILE.LOG,'Results ');
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
        	fnd_file.put_line(FND_FILE.LOG,'Phase : '||x_phase);
        	fnd_file.put_line(FND_FILE.LOG,'Status : '||x_status);
        	fnd_file.put_line(FND_FILE.LOG,'dev_phase : '||x_dev_phase);
        	fnd_file.put_line(FND_FILE.LOG,'dev_status : '||x_dev_status);
        	fnd_file.put_line(FND_FILE.LOG,'Message : '||substr(x_message,1,100));
          fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
          fnd_file.put_line(FND_FILE.LOG,'  ');

	IF x_dev_phase <> 'COMPLETED' AND
	   x_dev_status NOT IN ('NORMAL','WARNING')  THEN
	   -- error in CZ Concurrent Program
               fnd_file.put_line(FND_FILE.LOG, 'Error in CZ Rule Import Concurrent Program ');
               fnd_file.put_line(FND_FILE.LOG, 'Request Id :'||G_REQUEST_ID);
               fnd_file.put_line(FND_FILE.LOG, 'Run Id :'||G_RUN_ID);
               RAISE FND_API.G_EXC_ERROR;
	END IF;


            /*
		     Step 4: Check status of Rules Imported
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 4: Checking Status of Rules imported');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

               OKC_XPRT_UTIL_PVT.check_import_status
               (
                p_run_id           => G_RUN_ID,
                p_import_status    => 'S',
                p_model_type       => 'R', -- Rules Import
                x_return_status    => x_return_status,
                x_msg_data	     => x_msg_data,
                x_msg_count        => x_msg_count
               );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After checking import status');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

                --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;


            /*
		     Step 5: Call the Test Publication API
		  */

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'Step 5: Calling the Test Publication API');
            fnd_file.put_line(FND_FILE.LOG,'----------------------------------------------------------  ');
            fnd_file.put_line(FND_FILE.LOG,'  ');

             OKC_XPRT_UTIL_PVT.create_test_publication
		   (
              x_return_status => x_return_status,
              x_msg_data	     => x_msg_data,
              x_msg_count     => x_msg_count
             );

            fnd_file.put_line(FND_FILE.LOG,'  ');
            fnd_file.put_line(FND_FILE.LOG,'After Calling the Test Publication API ');
            fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||x_return_status);
            fnd_file.put_line(FND_FILE.LOG,'  ');

                --- If any errors happen abort API
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;


    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

END IF; -- req_data IS NULL

ELSE


              import_template
               (
                p_api_version       => 1,
                p_init_msg_list	 => 'T',
                p_commit	           => 'T',
                p_template_id       =>  p_template_id,
                p_mode => 'P',
                x_return_status	 =>  x_return_status,
                x_msg_data	      =>  x_msg_data,
                x_msg_count	      =>  x_msg_count
               ) ;

               --- If any errors happen abort API
              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;



END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := x_msg_data;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    retcode := 2;
    errbuf  := SQLERRM;
    fnd_file.put_line(FND_FILE.LOG,'x_return_status: '||G_RET_STS_UNEXP_ERROR);
    fnd_file.put_line(FND_FILE.LOG,'errbuf : '||errbuf);
    fnd_file.put_line(FND_FILE.LOG,'  ');

END tmpl_approval_publish_rules;

END OKC_XPRT_IMPORT_PVT ;

/
