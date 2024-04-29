--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_TMPL_RULE_ASSNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_TMPL_RULE_ASSNS_PVT" AS
/* $Header: OKCVXRULASSNB.pls 120.0 2005/05/25 19:25:54 appldev noship $ */


  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_TMPL_RULE_ASSNS_PVT';
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


PROCEDURE copy_template_rule_assns
(
 p_api_version           IN NUMBER,
 p_init_msg_list	     IN VARCHAR2,
 p_commit	               IN VARCHAR2,
 p_source_template_id    IN NUMBER,
 p_target_template_id    IN NUMBER,
 x_return_status	     OUT NOCOPY VARCHAR2,
 x_msg_data	          OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
) IS

CURSOR csr_template_org(p_template_id IN NUMBER) IS
SELECT org_id
  FROM okc_terms_templates_all
 WHERE template_id = p_template_id;

-- get all rules on source template that are Not Inactive
CURSOR csr_template_rules IS
SELECT t.rule_id
  FROM okc_xprt_template_rules t,
       okc_xprt_rule_hdrs_all r
 WHERE r.rule_id = t.rule_id
   AND r.status_code <> 'INACTIVE'
   AND NVL(t.deleted_flag,'N') <> 'Y'
   AND t.template_id = p_source_template_id;

-- Copy all questions from the source template
-- if the question belongs to Inactive rule, UI will delete it
-- Bug 4070731 modified to copy runtime_available_flag as 'N'
-- bug 4111451 Undo the above bug 4070731
CURSOR csr_template_questions IS
SELECT question_id,
       mandatory_flag,
	  sequence_num,
	  question_rule_status,
	  runtime_available_flag
  FROM okc_xprt_question_orders
 WHERE template_id = p_source_template_id;

l_api_version              CONSTANT NUMBER := 1;
l_api_name                CONSTANT VARCHAR2(30) := 'copy_template_rule_assns';
l_source_template_org_id  okc_terms_templates_all.org_id%TYPE;
l_target_template_org_id  okc_terms_templates_all.org_id%TYPE;


TYPE ruleIdList IS TABLE OF okc_xprt_template_rules.rule_id%TYPE INDEX BY BINARY_INTEGER;
TYPE questionIdList IS TABLE OF okc_xprt_question_orders.question_id%TYPE INDEX BY BINARY_INTEGER;
TYPE mandatoryFlagList IS TABLE OF okc_xprt_question_orders.mandatory_flag%TYPE INDEX BY BINARY_INTEGER;
TYPE sequenceNumList IS TABLE OF okc_xprt_question_orders.sequence_num%TYPE INDEX BY BINARY_INTEGER;
TYPE questionRuleStatusList IS TABLE OF okc_xprt_question_orders.question_rule_status%TYPE INDEX BY BINARY_INTEGER;
TYPE runtimeAvailableFlagList IS TABLE OF okc_xprt_question_orders.runtime_available_flag%TYPE INDEX BY BINARY_INTEGER;


rule_id_tbl                  ruleIdList;
question_id_tbl              questionIdList;
mandatory_flag_tbl           mandatoryFlagList;
sequence_num_tbl             sequenceNumList;
question_rule_status_tbl     questionRuleStatusList;
runtime_available_flag_tbl   runtimeAvailableFlagList;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_source_template_id : '||p_source_template_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_target_template_id : '||p_target_template_id);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

    -- Check if both templates have the same Org Id else skip copy as we don't copy
    -- rules in case of global template to local template copy

    OPEN csr_template_org(p_template_id => p_source_template_id);
      FETCH csr_template_org INTO l_source_template_org_id;
    CLOSE csr_template_org;

    OPEN csr_template_org(p_template_id => p_target_template_id);
      FETCH csr_template_org INTO l_target_template_org_id;
    CLOSE csr_template_org;

    -- debug log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '110: l_source_template_org_id : '||l_source_template_org_id);
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '110: l_target_template_org_id : '||l_target_template_org_id);
    END IF;

    IF l_source_template_org_id = l_target_template_org_id THEN
      -- both templates in same Org, copy rules

           -- Copy Local Rules
           OPEN csr_template_rules;
             FETCH csr_template_rules BULK COLLECT INTO rule_id_tbl;
           CLOSE csr_template_rules;

           IF rule_id_tbl.COUNT > 0 THEN

       	 FORALL i IN rule_id_tbl.FIRST..rule_id_tbl.LAST

       	    INSERT INTO okc_xprt_template_rules
       	       (
                    TEMPLATE_RULE_ID,
                    TEMPLATE_ID,
                    RULE_ID,
                    OBJECT_VERSION_NUMBER,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE,
                    LAST_UPDATE_LOGIN,
				DELETED_FLAG
       		  )
       	    VALUES
       	       (
       		   okc_xprt_template_rules_s.NEXTVAL,
                  p_target_template_id,
       		   rule_id_tbl(i),
       		   1,
       		   Fnd_Global.User_Id,
                  sysdate,
                  Fnd_Global.User_Id,
                  sysdate,
                  Fnd_Global.Login_Id,
			   'N'
       		  );

           END IF;  -- rule_id_tbl.COUNT > 0

		 -- Copy Template Question Order
		 OPEN csr_template_questions;
		   FETCH csr_template_questions BULK COLLECT INTO question_id_tbl,
		                                                  mandatory_flag_tbl,
												sequence_num_tbl,
												question_rule_status_tbl,
												runtime_available_flag_tbl;
		 CLOSE csr_template_questions;

           IF question_id_tbl.COUNT > 0 THEN

       	 FORALL i IN question_id_tbl.FIRST..question_id_tbl.LAST

       	    INSERT INTO okc_xprt_question_orders
       	       (
                   QUESTION_ORDER_ID,
                   TEMPLATE_ID,
                   QUESTION_ID,
                   MANDATORY_FLAG,
                   OBJECT_VERSION_NUMBER,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   SEQUENCE_NUM,
                   QUESTION_RULE_STATUS,
                   RUNTIME_AVAILABLE_FLAG
       		  )
       	    VALUES
       	       (
       		   okc_xprt_question_orders_s.NEXTVAL,
                  p_target_template_id,
       		   question_id_tbl(i),
			   mandatory_flag_tbl(i),
       		   1,
       		   Fnd_Global.User_Id,
                  sysdate,
                  Fnd_Global.User_Id,
                  sysdate,
                  Fnd_Global.Login_Id,
			   sequence_num_tbl(i),
			   question_rule_status_tbl(i),
			   runtime_available_flag_tbl(i)
       		  );

           END IF;  -- question_id_tbl.COUNT > 0


    END IF; -- l_source_template_org_id = l_target_template_org_id



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

  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                     G_MODULE||l_api_name,
                     '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                     G_MODULE||l_api_name,
                     '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);
  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END copy_template_rule_assns;


PROCEDURE delete_template_rule_assns
(
 p_api_version           IN NUMBER,
 p_init_msg_list	     IN VARCHAR2,
 p_commit	               IN VARCHAR2,
 p_template_id           IN NUMBER,
 x_return_status	     OUT NOCOPY VARCHAR2,
 x_msg_data	          OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'delete_template_rule_assns';
l_api_version              CONSTANT NUMBER := 1;



BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
  x_return_status :=  G_RET_STS_SUCCESS;

  -- delete template rules
  DELETE FROM okc_xprt_template_rules
        WHERE template_id = p_template_id;

  -- delete template questions
  DELETE FROM okc_xprt_question_orders
        WHERE template_id = p_template_id;



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

  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                     G_MODULE||l_api_name,
                     '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                     G_MODULE||l_api_name,
                     '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);
  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END delete_template_rule_assns;

PROCEDURE merge_template_rule_assns
(
 p_api_version           IN NUMBER,
 p_init_msg_list	     IN VARCHAR2,
 p_commit	               IN VARCHAR2,
 p_template_id           IN NUMBER,
 p_parent_template_id    IN NUMBER,
 x_return_status	     OUT NOCOPY VARCHAR2,
 x_msg_data	          OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
) IS

l_api_name                CONSTANT VARCHAR2(30) := 'merge_template_rule_assns';
l_api_version              CONSTANT NUMBER := 1;

CURSOR csr_xprt_enabled IS
SELECT NVL(contract_expert_enabled,'N')
   FROM okc_terms_templates_all
 WHERE template_id = p_parent_template_id;

 l_xprt_enabled_flag    okc_terms_templates_all.contract_expert_enabled%TYPE;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Delete Parent Template Rules
     DELETE FROM okc_xprt_template_rules
	     WHERE  template_id = p_parent_template_id;

  -- Delete Parent Template Questions
     DELETE FROM okc_xprt_question_orders
	      WHERE  template_id = p_parent_template_id;

  -- Check if the revision template is expert enabled and if not delete the rule data

  OPEN csr_xprt_enabled;
  FETCH csr_xprt_enabled INTO l_xprt_enabled_flag;
  CLOSE csr_xprt_enabled;

  IF l_xprt_enabled_flag = 'N' THEN

     -- Delete Parent Template Rules
     DELETE FROM okc_xprt_template_rules
            WHERE  template_id = p_template_id;

     -- Delete Parent Template Questions
     DELETE FROM okc_xprt_question_orders
            WHERE  template_id = p_template_id;

  ELSE
     -- revision template IS expert enabled

     -- Update okc_xprt_template_rules for Revision template
     UPDATE okc_xprt_template_rules
	   SET template_id = p_parent_template_id,
	       last_update_date = SYSDATE,
		  last_updated_by= FND_GLOBAL.USER_ID,
		  last_update_login= FND_GLOBAL.LOGIN_ID
     WHERE template_id = p_template_id;

     -- Update okc_xprt_question_orders for Revision template
     UPDATE okc_xprt_question_orders
        SET template_id = p_parent_template_id,
	       last_update_date = SYSDATE,
		  last_updated_by= FND_GLOBAL.USER_ID,
		  last_update_login= FND_GLOBAL.LOGIN_ID
     WHERE template_id = p_template_id;

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

  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                     G_MODULE||l_api_name,
                     '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                     G_MODULE||l_api_name,
                     '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);
  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END merge_template_rule_assns;




END OKC_XPRT_TMPL_RULE_ASSNS_PVT;

/
