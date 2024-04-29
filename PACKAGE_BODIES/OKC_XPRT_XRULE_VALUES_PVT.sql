--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_XRULE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_XRULE_VALUES_PVT" AS
/* $Header: OKCVXXRULVB.pls 120.18.12010000.7 2010/04/19 08:49:16 harchand ship $ */

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_XRULE_VALUES_PVT';
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

  G_BUY_ITEM_VARIABLE_NAME     CONSTANT   VARCHAR2(50) := 'OKC$B_ITEM';
  G_BUY_ITEM_CAT_VAR_NAME      CONSTANT   VARCHAR2(50) := 'OKC$B_ITEM_CATEGORY';
  G_SELL_ITEM_VARIABLE_NAME    CONSTANT   VARCHAR2(50) := 'OKC$S_ITEM';
  G_SELL_ITEM_CAT_VAR_NAME     CONSTANT   VARCHAR2(50) := 'OKC$S_ITEM_CATEGORY';

---------------------------------------------------
--  Procedure: get_system_variables
---------------------------------------------------

PROCEDURE get_system_variables (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_only_doc_variables IN  VARCHAR2 := FND_API.G_TRUE,
    x_sys_var_value_tbl  OUT NOCOPY var_value_tbl_type
)
IS
    l_api_name          VARCHAR2(30) := 'get_system_variables';
    l_api_version       CONSTANT NUMBER := 1.0;

    l_sys_var_value_tbl OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;

    l_index             NUMBER := 1;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  OKC_TERMS_UTIL_PVT.get_system_variables(
          p_api_version        => 1.0,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data,
          x_msg_count          => x_msg_count,
          p_doc_type           => p_doc_type,
          p_doc_id             => p_doc_id,
          p_only_doc_variables => p_only_doc_variables,
          x_sys_var_value_tbl  => l_sys_var_value_tbl);

   --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- Log all Variable values in the Pl/sql table

  /*IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: All System Variables before removing Null values and Not_null values');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Variable name '||'			' ||'Variable value');
	FOR i IN l_sys_var_value_tbl.first..l_sys_var_value_tbl.last LOOP
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      l_sys_var_value_tbl(i).variable_code ||'			'||
                      l_sys_var_value_tbl(i).variable_value_id);
        END LOOP;
  END IF;*/

  FOR i IN l_sys_var_value_tbl.first..l_sys_var_value_tbl.last LOOP
      --Bug 4868007 commented below IF condition
      --IF (l_sys_var_value_tbl(i).variable_value_id IS NOT NULL AND
      --      l_sys_var_value_tbl(i).variable_value_id <> 'NOT_NULL' ) THEN
      -- Added for Bug fix 5015134. Added part of If condition
      IF (l_sys_var_value_tbl(i).variable_value_id <> 'NOT_NULL' ) THEN
          x_sys_var_value_tbl(l_index).variable_code := l_sys_var_value_tbl(i).variable_code;
          x_sys_var_value_tbl(l_index).variable_value_id := l_sys_var_value_tbl(i).variable_value_id;
          l_index := l_index + 1;
      END IF;
  END LOOP;
 -- For Bug# 6833184
 -- l_sys_var_value_tbl(i).variable_value_id will always be NULL if the
 -- document type is 'REPOSITORY'

  -- Log all Variable values in the Pl/sql table
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '140: All system variables ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '140: Variable name '||'			' ||'Variable value');
     IF (x_sys_var_value_tbl.count <> 0) THEN    -- For Bug# 6833184
	FOR i IN x_sys_var_value_tbl.first..x_sys_var_value_tbl.last LOOP
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      x_sys_var_value_tbl(i).variable_code ||'			'||
                      substr(x_sys_var_value_tbl(i).variable_value_id,1,100));
    END LOOP;
    END IF;  -- For Bug# 6833184
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

END get_system_variables;

---------------------------------------------------
--  Procedure: check_line_level_rule_exists
---------------------------------------------------

 FUNCTION check_line_level_rule_exists (
    p_doc_type           		IN  VARCHAR2,
    p_doc_id             		IN  NUMBER,
    p_org_id				IN  NUMBER)

 RETURN VARCHAR2
  IS

  cursor org_line_rule_csr (p_org_id number) is
  select 'X'
  from okc_xprt_rule_hdrs_all
  where org_wide_flag = 'Y'
  and line_level_flag = 'Y'
  and org_id = p_org_id;

  cursor template_line_rule_csr (p_doc_id number, p_doc_type varchar2) is
  select 'X'
  from okc_xprt_rule_hdrs_all rhdr,
    okc_template_usages tuse,
    okc_xprt_template_rules trule
  where tuse.document_id = p_doc_id
  and tuse.document_type = p_doc_type
  and tuse.template_id = trule.template_id
  and trule.rule_id = rhdr.rule_id
  and rhdr.line_level_flag ='Y';

  l_dummy VARCHAR2(1);
  l_return VARCHAR2(1);

BEGIN

  OPEN  template_line_rule_csr(p_doc_id,p_doc_type);
  FETCH template_line_rule_csr INTO l_dummy;
  IF (template_line_rule_csr%NOTFOUND)  THEN
	  OPEN  org_line_rule_csr(p_org_id);
	  FETCH org_line_rule_csr INTO l_dummy;
	  IF (template_line_rule_csr%NOTFOUND)  THEN
		l_return := 'N';
          ELSE
                l_return := 'Y';
	  END IF;
	  CLOSE template_line_rule_csr;
  ELSE
          l_return := 'Y';
  END IF;
  CLOSE template_line_rule_csr;

  RETURN l_return;

EXCEPTION
 WHEN OTHERS THEN
 --close cursors
 IF template_line_rule_csr%ISOPEN THEN
   CLOSE template_line_rule_csr;
 END IF;
 IF org_line_rule_csr%ISOPEN THEN
   CLOSE org_line_rule_csr;
 END IF;
 RETURN 'N';
END  check_line_level_rule_exists;


---------------------------------------------------
--  Procedure: get_line_system_variables
---------------------------------------------------

PROCEDURE get_line_system_variables (
    p_api_version        		IN  NUMBER,
    p_init_msg_list      		IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           		IN  VARCHAR2,
    p_doc_id             		IN  NUMBER,
    p_org_id				IN  NUMBER,
    x_return_status      		OUT NOCOPY VARCHAR2,
    x_msg_data           		OUT NOCOPY VARCHAR2,
    x_msg_count          		OUT NOCOPY NUMBER,
    x_line_sys_var_value_tbl            OUT NOCOPY line_sys_var_value_tbl_type,
    x_line_count         		OUT NOCOPY NUMBER,
    x_line_variables_count              OUT NOCOPY NUMBER
)
IS

  l_api_name 		varchar2(30) := 'get_line_system_variables';
  l_api_version   	constant number := 1.0;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  IF (p_doc_type = 'B' OR p_doc_type = 'O')
  THEN
	  OKC_XPRT_OM_INT_PVT.get_line_variable_values(
		  p_api_version        		=> 1.0,
		  p_init_msg_list      		=> p_init_msg_list,
		  x_return_status      		=> x_return_status,
		  x_msg_data           		=> x_msg_data,
		  x_msg_count          		=> x_msg_count,
		  p_doc_type           		=> p_doc_type,
		  p_doc_id             		=> p_doc_id,
		  x_line_sys_var_value_tbl  	=> x_line_sys_var_value_tbl,
		  x_line_count			=> x_line_count,
		  x_line_variables_count        => x_line_variables_count);
	   --null;

	   --- If any errors happen abort API
	   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
  END IF;

  IF (p_doc_type = 'QUOTE')
  THEN
	  OKC_XPRT_QUOTE_INT_PVT.get_line_variable_values(
		  p_api_version        		=> 1.0,
		  p_init_msg_list      		=> p_init_msg_list,
		  x_return_status      		=> x_return_status,
		  x_msg_data           		=> x_msg_data,
		  x_msg_count          		=> x_msg_count,
		  --p_doc_type           		=> p_doc_type,
		  p_doc_id             		=> p_doc_id,
		  x_line_sys_var_value_tbl  	=> x_line_sys_var_value_tbl,
		  x_line_count			=> x_line_count,
		  x_line_variables_count        => x_line_variables_count);

	   --null;
	   --- If any errors happen abort API
	   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
  END IF;

  -- Log all Variable values in the Pl/sql table
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: No. of Lines: '|| x_line_count);

     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Line Number'||'			' ||
                    'Variable Name   '||'			' ||
                    'Variable Value  '||'			' ||
                    'Item Id'||'			' ||
                    'Org Id');
     IF x_line_sys_var_value_tbl.COUNT > 0 THEN
      FOR i IN x_line_sys_var_value_tbl.FIRST..x_line_sys_var_value_tbl.LAST LOOP
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    x_line_sys_var_value_tbl(i).line_number ||'			'||
                    x_line_sys_var_value_tbl(i).variable_code ||'			'||
                    x_line_sys_var_value_tbl(i).variable_value ||'			'||
                    x_line_sys_var_value_tbl(i).item_id ||'			'||
                    x_line_sys_var_value_tbl(i).org_id);
      END LOOP;
     END IF;
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

END get_line_system_variables;

---------------------------------------------------
--  Procedure: get_user_defined_variables
---------------------------------------------------

PROCEDURE get_user_defined_variables (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id		 IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY udf_var_value_tbl_type
)
IS

CURSOR csr_get_udf_variables (p_doc_type VARCHAR2,p_doc_id NUMBER, p_intent VARCHAR2, p_org_id NUMBER) IS
SELECT 'USER$' || var.variable_code variable_code,
       NVL(var.variable_value_id,var.variable_value)  variable_value -- Added NVL for Bug 5233775
  FROM okc_k_art_variables var,
       okc_k_articles_b art,           -- Added for Bug 4728565
       okc_bus_variables_b bvar
 WHERE art.id = var.cat_id             -- Added for Bug 4728565
   AND art.document_id = p_doc_id      -- Added for Bug 4728565
   AND art.document_type = p_doc_type  -- Added for Bug 4728565
   AND var.variable_code = bvar.variable_code
   AND bvar.variable_source = 'M'
   AND bvar.clm_source IS NULL   --CLM Changes
   AND var.variable_code IN   ( SELECT rcon.object_code variable_code -- LHS of Condition from Template rule
                                  FROM okc_xprt_rule_hdrs_all rhdr,
                                       okc_xprt_rule_conditions rcon,
                                       okc_template_usages tuse,
                                       okc_xprt_template_rules trule
                                 WHERE tuse.document_id = p_doc_id
                                   AND tuse.document_type = p_doc_type
                                   AND tuse.template_id = trule.template_id
                                   AND trule.rule_id = rhdr.rule_id
                                   AND rhdr.rule_id = rcon.rule_id
                                   AND rcon.object_type = 'VARIABLE'
                                   AND rhdr.status_code <> 'DRAFT'
                                   AND SUBSTR(rcon.object_code,1,3)  <> 'OKC'
                                   GROUP BY rcon.object_code
                                 UNION
				SELECT rcon.object_value_code variable_code -- RHS of Condition from Template rule
                                  FROM okc_xprt_rule_hdrs_all rhdr,
                                       okc_xprt_rule_conditions rcon,
                                       okc_template_usages tuse,
                                       okc_xprt_template_rules trule
                                 WHERE tuse.document_id = p_doc_id
                                   AND tuse.document_type = p_doc_type
                                   AND tuse.template_id = trule.template_id
                                   AND trule.rule_id = rhdr.rule_id
                                   AND rhdr.rule_id = rcon.rule_id
                                   AND rcon.object_value_type = 'VARIABLE'
                                   AND rhdr.status_code <> 'DRAFT'
                                   AND SUBSTR(rcon.object_value_code,1,3)  <> 'OKC'
                                   GROUP BY rcon.object_value_code
                                 UNION
				SELECT rcon.object_code variable_code -- LHS of Condition from Global Rule
                                  FROM okc_xprt_rule_hdrs_all rhdr,
                                       okc_xprt_rule_conditions rcon
                                 WHERE rhdr.rule_id = rcon.rule_id
                                   AND rhdr.org_id = p_org_id
                                   AND rhdr.intent = p_intent
                                   AND rhdr.org_wide_flag = 'Y'
                                   AND rcon.object_type = 'VARIABLE'
                                   AND rhdr.status_code <> 'DRAFT'
                                   AND SUBSTR(rcon.object_code,1,3)  <> 'OKC'
                                   GROUP BY rcon.object_code
                                 UNION
			        SELECT rcon.object_value_code variable_code -- RHS of Condition from Global Rule
                                  FROM okc_xprt_rule_hdrs_all rhdr,
                                       okc_xprt_rule_conditions rcon
                                 WHERE rhdr.rule_id = rcon.rule_id
                                   AND rhdr.org_id = p_org_id
                                   AND rhdr.intent = p_intent
                                   AND rhdr.org_wide_flag = 'Y'
                                   AND rcon.object_value_type = 'VARIABLE'
                                   AND rhdr.status_code <> 'DRAFT'
                                   AND SUBSTR(rcon.object_value_code,1,3)  <> 'OKC'
                                   GROUP BY rcon.object_value_code);


    l_api_name 		VARCHAR2(30) := 'get_user_defined_variables';
    l_api_version   	CONSTANT NUMBER := 1.0;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  OPEN  csr_get_udf_variables(p_doc_type, p_doc_id, p_intent, p_org_id);
  FETCH csr_get_udf_variables  BULK COLLECT INTO x_udf_var_value_tbl;
  CLOSE csr_get_udf_variables;


  -- Log all User Defined Variable values in the Pl/sql table
  /*IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: User Defined Variable name '||'			' ||'User Defined Variable value');
	FOR i IN x_udf_var_value_tbl.first..x_udf_var_value_tbl.last LOOP
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      x_udf_var_value_tbl(i).variable_code ||'			'||
                      x_udf_var_value_tbl(i).variable_value_id);
        END LOOP;
  END IF;*/

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

END get_user_defined_variables;

---------------------------------------------------
--  Procedure: get_constant_values
---------------------------------------------------

PROCEDURE get_constant_values (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_constant_tbl       OUT NOCOPY constant_tbl_type
)
IS
    l_api_name 		VARCHAR2(30) := 'get_constant_values';
    l_api_version   	CONSTANT NUMBER := 1.0;
    l_intent		VARCHAR2(1);

    CURSOR csr_constants (p_intent VARCHAR2) IS
    SELECT  'CONSTANT$' || v.object_value_code constant_id, --
           q.default_value
    FROM okc_xprt_rule_cond_vals v,
         okc_xprt_rule_conditions c,
         okc_xprt_rule_hdrs_all r,
         okc_xprt_questions_b q
    WHERE v.rule_condition_id = c.rule_condition_id
      AND c.rule_id = r.rule_id
      AND to_char(q.question_id) = v.object_value_code
      AND c.object_value_type = 'CONSTANT'
      AND r.intent = p_intent
      AND r.status_code <> 'DRAFT'
    GROUP BY v.object_value_code, q.default_value;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;


  OPEN  csr_constants(p_intent);
  FETCH csr_constants  BULK COLLECT INTO x_constant_tbl;
  CLOSE csr_constants;

  -- Log all Variable values in the Pl/sql table
  /*IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Constant name '||'			' ||'Constant value');
	FOR i IN x_constant_tbl.first..x_constant_tbl.last LOOP
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      x_constant_tbl(i).constant_id ||'			'||
                      x_constant_tbl(i).value);
        END LOOP;
  END IF;*/

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

END get_constant_values;

---------------------------------------------------
--  Procedure: get_udv_with_procedures
---------------------------------------------------

PROCEDURE get_udv_with_procedures (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id		 IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY udf_var_value_tbl_type
)
IS

CURSOR csr_get_udv_with_proc (p_doc_type VARCHAR2,p_doc_id NUMBER, p_intent VARCHAR2, p_org_id NUMBER) IS
SELECT var.variable_code variable_code, --Removed USER$ to resolve Rule firing for UDV with Procedures
       procedure_name procedure_name
  FROM okc_bus_variables_b var
 WHERE var.variable_source = 'P'
   AND var.variable_code IN
       (SELECT distinct rcon.object_code  variable_code -- LHS of Condition from Template rule
	  FROM okc_xprt_rule_hdrs_all rhdr,
	       okc_xprt_rule_conditions rcon,
	       okc_template_usages tuse,
	       okc_xprt_template_rules trule
	 WHERE tuse.document_id = p_doc_id
	   AND tuse.document_type = p_doc_type
	   AND tuse.template_id = trule.template_id
	   AND trule.rule_id = rhdr.rule_id
	   AND rhdr.rule_id = rcon.rule_id
	   AND rcon.object_type = 'VARIABLE'
	   AND rhdr.status_code <> 'DRAFT'
	   AND SUBSTR(rcon.object_code,1,3)  <> 'OKC'
	   GROUP BY rcon.object_code
	 UNION
	SELECT distinct rcon.object_value_code  variable_code -- RHS of Condition from Template rule
	  FROM okc_xprt_rule_hdrs_all rhdr,
	       okc_xprt_rule_conditions rcon,
	       okc_template_usages tuse,
	       okc_xprt_template_rules trule
	 WHERE tuse.document_id = p_doc_id
	   AND tuse.document_type = p_doc_type
	   AND tuse.template_id = trule.template_id
	   AND trule.rule_id = rhdr.rule_id
	   AND rhdr.rule_id = rcon.rule_id
	   AND rcon.object_value_type = 'VARIABLE'
	   AND rhdr.status_code <> 'DRAFT'
	   AND SUBSTR(rcon.object_value_code,1,3)  <> 'OKC'
	   GROUP BY rcon.object_value_code
	 UNION
	SELECT distinct rcon.object_code variable_code -- LHS of Condition from Global Rule
	  FROM okc_xprt_rule_hdrs_all rhdr,
	       okc_xprt_rule_conditions rcon
	 WHERE rhdr.rule_id = rcon.rule_id
	   AND rhdr.org_id = p_org_id
	   AND rhdr.intent = p_intent
	   AND rhdr.org_wide_flag = 'Y'
	   AND rcon.object_type = 'VARIABLE'
	   AND rhdr.status_code <> 'DRAFT'
	   AND SUBSTR(rcon.object_code,1,3)  <> 'OKC'
	   GROUP BY rcon.object_code
	 UNION
	SELECT distinct rcon.object_value_code  variable_code -- RHS of Condition from Global Rule
	  FROM okc_xprt_rule_hdrs_all rhdr,
	       okc_xprt_rule_conditions rcon
	 WHERE rhdr.rule_id = rcon.rule_id
	   AND rhdr.org_id = p_org_id
	   AND rhdr.intent = p_intent
	   AND rhdr.org_wide_flag = 'Y'
	   AND rcon.object_value_type = 'VARIABLE'
	   AND rhdr.status_code <> 'DRAFT'
	   AND SUBSTR(rcon.object_value_code,1,3)  <> 'OKC'
	   GROUP BY rcon.object_value_code);

CURSOR csr_get_uniq_proc (p_sequence_id NUMBER) IS
SELECT distinct procedure_name procedure_name
  FROM okc_xprt_deviations_t
 WHERE run_id = p_sequence_id;


CURSOR csr_get_vars_for_proc (p_procedure_name VARCHAR2, p_sequence_id NUMBER) IS
SELECT distinct variable_code variable_code
  FROM okc_xprt_deviations_t
 WHERE run_id = p_sequence_id
   AND procedure_name = p_procedure_name;

l_api_name 		VARCHAR2(30) := 'get_udv_with_procedures';
l_api_version   	CONSTANT NUMBER := 1.0;

l_sql_stmt              LONG;
l_sequence_id 		NUMBER;
var_tbl_cnt		NUMBER := 1;
l_udf_var_value_tbl	OKC_XPRT_XRULE_VALUES_PVT.udf_var_value_tbl_type;

 --bug 8501694-kkolukul: Multiple values variables used in expert
l_udf_with_proc_mul_val_tbl  OKC_XPRT_XRULE_VALUES_PVT.udf_var_value_tbl_type;
l_hook_used NUMBER;

TYPE VariableCodeList IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER; -- changed for R12
variableCode_tbl           VariableCodeList;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO l_sequence_id from DUAL;

  FOR  csr_get_udv_with_proc_rec IN csr_get_udv_with_proc(p_doc_type, p_doc_id, p_intent, p_org_id)
  LOOP
    INSERT INTO OKC_XPRT_DEVIATIONS_T
    (
     RUN_ID,
     LINE_NUMBER,
     VARIABLE_CODE,
     VARIABLE_VALUE,
     ITEM_ID,
     ORG_ID,
     CREATION_DATE,
     PROCEDURE_NAME
    )
    VALUES
    (
     l_sequence_id,                            -- RUN_ID
     NULL,                                     -- LINE_NUMBER
     csr_get_udv_with_proc_rec.variable_code,  -- VARIABLE_CODE
     NULL, 				       -- VARIABLE_VALUE
     NULL, 				       -- ITEM_ID
     NULL, 				       -- ORG_ID
     NULL,				       -- CREATION_DATE
     csr_get_udv_with_proc_rec.procedure_name  -- PROCEDURE_NAME
    );
  END LOOP;

  FOR csr_get_uniq_proc_rec IN csr_get_uniq_proc(l_sequence_id)
  LOOP
     OPEN  csr_get_vars_for_proc(csr_get_uniq_proc_rec.procedure_name, l_sequence_id);
     FETCH csr_get_vars_for_proc  BULK COLLECT INTO variableCode_tbl;
     CLOSE csr_get_vars_for_proc;

     FOR i IN 1..variableCode_tbl.COUNT
     LOOP

     l_udf_var_value_tbl(i).variable_code := variableCode_tbl(i);

   --kkolukul: Modified Code to allow multi values variables to be used in Expert
   -- start debug log
 	      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
 	                     G_MODULE||l_api_name,
 	                     '106: Before Calling code Hook ');
 	       END IF;

 	   OKC_CODE_HOOK.GET_MULTIVAL_UDV_FOR_XPRT(
 	    p_api_version                        => 1.0,
 	           p_init_msg_list               => p_init_msg_list,
 	           p_doc_type                    => p_doc_type,
 	           p_doc_id                      => p_doc_id,
 	           p_udf_var_code                => variableCode_tbl(i),
 	           x_return_status               => x_return_status,
 	           x_msg_count                   => x_msg_count,
 	           x_msg_data                    => x_msg_data,
 	           x_cust_udf_var_mul_val_tbl    => l_udf_with_proc_mul_val_tbl,
 	           x_hook_used                   => l_hook_used   );


 	      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
 	                     G_MODULE||l_api_name,
 	                     '107: After Calling code Hook - l_hook_used value: ' || l_hook_used || ' "0": Hook not used, "-1": Error in hook, any other value, hook is used');
 	       END IF;

 	     IF l_udf_with_proc_mul_val_tbl IS NOT NULL THEN
 	       IF l_udf_with_proc_mul_val_tbl.COUNT > 0 THEN
 	         FOR k in l_udf_with_proc_mul_val_tbl.first..l_udf_with_proc_mul_val_tbl.last LOOP
 	           IF l_udf_with_proc_mul_val_tbl.EXISTS(k) THEN
 	                x_udf_var_value_tbl(var_tbl_cnt).variable_code := 'USER$' || l_udf_with_proc_mul_val_tbl(k).variable_code;
 	                      x_udf_var_value_tbl(var_tbl_cnt).variable_value_id := to_char(l_udf_with_proc_mul_val_tbl(k).variable_value_id);
 	                var_tbl_cnt := var_tbl_cnt + 1;
 	            END IF;
 	         END LOOP;
 	       END IF;
 	     END IF;

 	   --END: kkolukul: Modified Code to allow multi values variables to be used in Expert
 IF  l_hook_used = 0  then
     -- Dynamically build SQL to execute the procedure
     l_sql_stmt :=  'BEGIN ' || csr_get_uniq_proc_rec.procedure_name  || '(' ||
              		  'x_return_status      =>' || ':1' || ',' ||
			  'x_msg_data           =>' || ':2' || ',' ||
			  'x_msg_count          =>' || ':3' || ',' ||
			  'p_doc_type           =>' || ':4' || ',' ||
			  'p_doc_id             =>' || ':5' || ',' ||
			  'p_variable_code     	=>' || ':6' || ',' ||
			  'x_variable_value_id 	=>' || ':7' || ' ' ||
                          '); END;';

     -- execute the dynamic sql
     -- start debug log
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '105: l_sql_stmt '|| l_sql_stmt);
     END IF;

     BEGIN
       EXECUTE IMMEDIATE l_sql_stmt USING OUT x_return_status, OUT x_msg_data, OUT x_msg_count, p_doc_type,
                                          p_doc_id, variableCode_tbl(i), IN OUT l_udf_var_value_tbl(i).variable_value_id;
     END;
   END IF; -- l_hook_used = 0

     -- If any errors happen abort API
     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     END LOOP;

     -- After executing add the list to the output table
     IF l_udf_var_value_tbl IS NOT NULL THEN
         IF l_udf_var_value_tbl.count > 0 THEN
	    FOR i IN l_udf_var_value_tbl.first..l_udf_var_value_tbl.last LOOP
	      x_udf_var_value_tbl(var_tbl_cnt).variable_code     := 'USER$' || l_udf_var_value_tbl(i).variable_code; --Appended USER$ to resolve Rule firing for UDV with Procedures
	      x_udf_var_value_tbl(var_tbl_cnt).variable_value_id := l_udf_var_value_tbl(i).variable_value_id;
	      var_tbl_cnt := var_tbl_cnt + 1;
	    END LOOP;
	  END IF;
     END IF;

     -- Clear out the PL/SQL tables
     variableCode_tbl.DELETE;
     FOR i IN l_udf_var_value_tbl.FIRST..l_udf_var_value_tbl.LAST
          LOOP
        	l_udf_var_value_tbl.DELETE(i);
     END LOOP;

  END LOOP;


  -- Log all User Defined Variable values in the Pl/sql table
  /*IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: User Defined Variable name '||'			' ||'User Defined Variable value');
	FOR i IN x_udf_var_value_tbl.first..x_udf_var_value_tbl.last LOOP
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      x_udf_var_value_tbl(i).variable_code ||'			'||
                      x_udf_var_value_tbl(i).variable_value_id);
        END LOOP;
  END IF;*/

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

END get_udv_with_procedures;


---------------------------------------------------
--  Procedure: get_document_values
---------------------------------------------------

PROCEDURE get_document_values (
    p_api_version        	  IN  NUMBER,
    p_init_msg_list      	  IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           	  IN  VARCHAR2,
    p_doc_id             	  IN  NUMBER,
    x_return_status      	  OUT NOCOPY VARCHAR2,
    x_msg_data           	  OUT NOCOPY VARCHAR2,
    x_msg_count          	  OUT NOCOPY NUMBER,
    x_hdr_var_value_tbl           OUT NOCOPY var_value_tbl_type,
    x_line_sysvar_value_tbl       OUT NOCOPY line_sys_var_value_tbl_type,
    x_line_count		  OUT NOCOPY NUMBER,
    x_line_variables_count        OUT NOCOPY NUMBER,
    x_intent                      OUT NOCOPY VARCHAR2,
    x_org_id			  OUT NOCOPY NUMBER
)
IS

    l_api_name 		VARCHAR2(30) := 'get_document_values';
    l_api_version   	CONSTANT NUMBER := 1.0;

    l_sys_var_value_tbl var_value_tbl_type;
    l_category_tbl    	OKC_TERMS_UTIL_GRP.item_tbl_type;
    l_item_tbl        	OKC_TERMS_UTIL_GRP.item_tbl_type;
    l_constant_tbl      constant_tbl_type;
    l_udf_var_value_tbl udf_var_value_tbl_type;
    l_udf_var_with_proc_value_tbl udf_var_value_tbl_type;
    l_clm_udf_tbl udf_var_value_tbl_type;    -- CLM Changes

    l_intent		VARCHAR2(1);
    var_tbl_cnt		NUMBER;
    l_org_id		NUMBER;
    l_line_level_rules_flag VARCHAR2(1);

    l_old_variable_value_id  VARCHAR2(2500); --Bug# 9595800

    CURSOR csr_get_intent (p_doc_type VARCHAR2) IS
    SELECT intent
    FROM okc_bus_doc_types_b b
    WHERE b.document_type = p_doc_type;

    CURSOR csr_get_org_id (p_doc_type VARCHAR2, p_doc_id NUMBER) IS
    SELECT t.org_id org_id
    FROM okc_template_usages u,
         okc_terms_templates_all t
    WHERE u.document_type = p_doc_type
      AND u.document_id = p_doc_id
      AND u.template_id = t.template_id;

    --Bug# 9595800
    CURSOR c_get_old_item(p_variable_value_id VARCHAR2) IS
    SELECT DISTINCT OBJECT_VALUE_CODE
    FROM okc_xprt_rule_cond_vals  val
    WHERE InStr(OBJECT_VALUE_CODE,p_variable_value_id||'_',1,1) = 1
    AND OBJECT_VALUE_CODE <> p_variable_value_id
    AND RULE_CONDITION_ID IN (SELECT rule_condition_id
                              FROM OKC_XPRT_RULE_CONDITIONS
                              WHERE OBJECT_CODE = 'OKC$S_ITEM'
                              AND rule_id IN (SELECT rhdr.rule_id
                                              FROM okc_xprt_rule_hdrs_all rhdr,
                                              okc_template_usages tuse,
                                              okc_xprt_template_rules trule
                                              WHERE tuse.document_id = p_doc_id
                                              AND tuse.document_type = p_doc_type
                                              AND tuse.template_id = trule.template_id
                                              AND trule.rule_id = rhdr.rule_id
                                              AND rhdr.status_code <> 'DRAFT'
                                              UNION
                                 			        SELECT rhdr.rule_id
                                              FROM okc_xprt_rule_hdrs_all rhdr
                                              WHERE rhdr.org_id = l_org_id
                                              AND rhdr.intent = l_intent
                                              AND rhdr.org_wide_flag = 'Y'
                                              AND rhdr.status_code <> 'DRAFT'
                                               )
                              );

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  OPEN  csr_get_intent(p_doc_type);
  FETCH csr_get_intent INTO l_intent;
  IF (csr_get_intent%NOTFOUND)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE csr_get_intent;
  x_intent := l_intent;

  OPEN  csr_get_org_id(p_doc_type, p_doc_id);
  FETCH csr_get_org_id INTO l_org_id;
  IF (csr_get_org_id%NOTFOUND)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE csr_get_org_id;
  x_org_id := l_org_id;

  -- Step 1: Get Header level document Variables
  get_system_variables(
	  p_api_version        		=> 1.0,
	  p_init_msg_list      		=> p_init_msg_list,
	  x_return_status      		=> x_return_status,
	  x_msg_data           		=> x_msg_data,
	  x_msg_count          		=> x_msg_count,
	  p_doc_type           		=> p_doc_type,
	  p_doc_id             		=> p_doc_id,
	  p_only_doc_variables          => 'F',
	  x_sys_var_value_tbl		=> l_sys_var_value_tbl);

   --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Finished Step1 - Get Header level document variabels');
  END IF;


  -- Step 2: Check for Line Level Rules
  l_line_level_rules_flag := check_line_level_rule_exists(
				  p_doc_type           		=> p_doc_type,
				  p_doc_id             		=> p_doc_id,
				  p_org_id		  	=> l_org_id);


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Finished Step2 - Check for Line level rules');
  END IF;

  -- Step 3: If Line level rules exist, Get Line level document Variables, else get Item/Item Categories
  IF (l_line_level_rules_flag = 'Y')
  THEN
  	get_line_system_variables(
	  p_api_version        		=> 1.0,
	  p_init_msg_list      		=> p_init_msg_list,
	  x_return_status      		=> x_return_status,
	  x_msg_data           		=> x_msg_data,
	  x_msg_count          		=> x_msg_count,
	  p_doc_type           		=> p_doc_type,
	  p_doc_id             		=> p_doc_id,
	  p_org_id			=> l_org_id,
	  x_line_sys_var_value_tbl  	=> x_line_sysvar_value_tbl,
	  x_line_count			=> x_line_count,
	  x_line_variables_count        => x_line_variables_count);

          --- If any errors happen abort API
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

	  -- start debug log
	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    '130: Finished Step3. Line level rules flag is Y. After calling get_line_system_variables');
	  END IF;

  ELSE
        OKC_TERMS_UTIL_GRP.get_item_dtl_for_expert(
          p_api_version        => 1.0,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data,
          x_msg_count          => x_msg_count,
          p_doc_type           => p_doc_type,
          p_doc_id             => p_doc_id,
          x_category_tbl       => l_category_tbl,
          x_item_tbl           => l_item_tbl);

          --- If any errors happen abort API
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Add Item/Item Category to header level variables
	  var_tbl_cnt := l_sys_var_value_tbl.COUNT + 1;
	  IF l_category_tbl IS NOT NULL THEN
	      IF l_category_tbl.count > 0 THEN
			  FOR i IN l_category_tbl.first..l_category_tbl.last LOOP
			      IF l_intent = 'B' THEN
				  l_sys_var_value_tbl(var_tbl_cnt).variable_code := G_BUY_ITEM_CAT_VAR_NAME;
			      ELSE
				  l_sys_var_value_tbl(var_tbl_cnt).variable_code := G_SELL_ITEM_CAT_VAR_NAME;
			      END IF;
			      l_sys_var_value_tbl(var_tbl_cnt).variable_value_id := l_category_tbl(i).name;
			      var_tbl_cnt := var_tbl_cnt + 1;
			  END LOOP;
		  END IF;
	  END IF;

	  IF l_item_tbl IS NOT NULL THEN
	      IF l_item_tbl.count > 0 THEN
			  FOR i IN l_item_tbl.first..l_item_tbl.last LOOP
			   IF l_item_tbl(i).NAME IS NOT NULL THEN
				  IF l_intent = 'B' THEN
				     l_sys_var_value_tbl(var_tbl_cnt).variable_code := G_BUY_ITEM_VARIABLE_NAME;
				  ELSE
				     l_sys_var_value_tbl(var_tbl_cnt).variable_code := G_SELL_ITEM_VARIABLE_NAME;
				  END IF;
				  l_sys_var_value_tbl(var_tbl_cnt).variable_value_id := l_item_tbl(i).name;
				  var_tbl_cnt := var_tbl_cnt + 1;
			   END IF;
			  END LOOP;
		  END IF;
	  END IF;


    --Bug# 9595800
 IF OKC_CODE_HOOK.IS_NEW_KFF_ITEM_SEG_ENABLED THEN
    IF l_sys_var_value_tbl IS NOT NULL THEN
      IF l_sys_var_value_tbl.Count > 0 THEN
        FOR i IN l_sys_var_value_tbl.first..l_sys_var_value_tbl.last LOOP
          IF l_intent <> 'B' THEN
            IF l_sys_var_value_tbl(i).variable_code = G_SELL_ITEM_VARIABLE_NAME THEN
               OPEN c_get_old_item(l_sys_var_value_tbl(i).variable_value_id);
               FETCH c_get_old_item INTO l_old_variable_value_id;
               CLOSE c_get_old_item;
                l_sys_var_value_tbl(var_tbl_cnt).variable_code := G_SELL_ITEM_VARIABLE_NAME;
                l_sys_var_value_tbl(var_tbl_cnt).variable_value_id := l_old_variable_value_id;
                var_tbl_cnt := var_tbl_cnt + 1;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END IF;
 END IF;


	  x_line_count := 1; -- Since no Lines, need to set line count to 1 for the CX Java code
	  x_line_variables_count := 0; -- Since no Lines, need to set line variables count to 0 for the CX Java code

	  -- start debug log
	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    '140: Finished Step3. Line level rules flag is N. After calling OKC_TERMS_UTIL_GRP.get_item_dtl_for_expert');
          END IF;

   END IF;


  -- Step 4: Get User Defined Variables
  get_user_defined_variables(
	  p_api_version        		=> 1.0,
	  p_init_msg_list      		=> p_init_msg_list,
	  x_return_status      		=> x_return_status,
	  x_msg_data           		=> x_msg_data,
	  x_msg_count          		=> x_msg_count,
	  p_doc_type           		=> p_doc_type,
	  p_doc_id             		=> p_doc_id,
	  p_org_id                      => l_org_id,
	  p_intent                      => l_intent,
	  x_udf_var_value_tbl    	=> l_udf_var_value_tbl);

   --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '150: Finished Step4 - Get User Defined variabels');
  END IF;

  -- Step 4a: Get User Defined Variables with Procedures - Added for UDV Enhancements
  get_udv_with_procedures(
	  p_api_version        		=> 1.0,
	  p_init_msg_list      		=> p_init_msg_list,
	  x_return_status      		=> x_return_status,
	  x_msg_data           		=> x_msg_data,
	  x_msg_count          		=> x_msg_count,
	  p_doc_type           		=> p_doc_type,
	  p_doc_id             		=> p_doc_id,
	  p_org_id                      => l_org_id,
	  p_intent                      => l_intent,
	  x_udf_var_value_tbl    	=> l_udf_var_with_proc_value_tbl);

   --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '150: Finished Step4 - Get User Defined variabels');
  END IF;

  -- Step 4a: Get User Defined Variables of UDA type for CLM
  okc_clm_pkg.get_clm_udv(
	  p_api_version        		=> 1.0,
	  p_init_msg_list      		=> p_init_msg_list,
	  x_return_status      		=> x_return_status,
	  x_msg_data           		=> x_msg_data,
	  x_msg_count          		=> x_msg_count,
	  p_doc_type           		=> p_doc_type,
	  p_doc_id             		=> p_doc_id,
	  p_org_id                      => l_org_id,
	  p_intent                      => l_intent,
	  x_udf_var_value_tbl    	=> l_clm_udf_tbl);

   --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '150: Finished Step4 - Get CLM UDA UDVariables');
  END IF;

  -- Step 5: Get Constant Values
  get_constant_values(
	  p_api_version        		=> 1.0,
	  p_init_msg_list      		=> p_init_msg_list,
	  x_return_status      		=> x_return_status,
	  x_msg_data           		=> x_msg_data,
	  x_msg_count          		=> x_msg_count,
	  p_intent                      => l_intent,
	  x_constant_tbl  		=> l_constant_tbl);

   --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '160: Finished Step5 - Get Constant values');
  END IF;

  -- Step 6: Consolidate Header Variables for Expert Runtime

  IF l_sys_var_value_tbl.COUNT > 0 THEN
  FOR i IN l_sys_var_value_tbl.first..l_sys_var_value_tbl.last LOOP
      IF l_sys_var_value_tbl.EXISTS(i) THEN
        x_hdr_var_value_tbl(i).variable_code := l_sys_var_value_tbl(i).variable_code;
        x_hdr_var_value_tbl(i).variable_value_id := l_sys_var_value_tbl(i).variable_value_id;
      END IF;
  END LOOP;
  END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '161: Finished adding system variable values');
  END IF;

  var_tbl_cnt := x_hdr_var_value_tbl.count + 1;
  IF l_constant_tbl.COUNT > 0 THEN
  for i in l_constant_tbl.first..l_constant_tbl.last loop
      IF l_constant_tbl.EXISTS(i)THEN
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_code := l_constant_tbl(i).constant_id;
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_value_id := l_constant_tbl(i).value;
	  var_tbl_cnt := var_tbl_cnt + 1;
      END IF;
  end loop;
  END IF;

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '162: Finished adding constant values');
  END IF;

  var_tbl_cnt := x_hdr_var_value_tbl.count + 1;
  IF l_udf_var_value_tbl.COUNT > 0 THEN
  for i in l_udf_var_value_tbl.first..l_udf_var_value_tbl.last loop
      IF l_udf_var_value_tbl.EXISTS(i) THEN
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_code := l_udf_var_value_tbl(i).variable_code;
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_value_id := to_char(l_udf_var_value_tbl(i).variable_value_id);
	  var_tbl_cnt := var_tbl_cnt + 1;
      END IF;
  end loop;
  END IF;

  -- Begin: Added for UDV with Procedures enhancement
  IF l_udf_var_with_proc_value_tbl.COUNT > 0 THEN
  for i in l_udf_var_with_proc_value_tbl.first..l_udf_var_with_proc_value_tbl.last loop
      IF l_udf_var_with_proc_value_tbl.EXISTS(i) THEN
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_code := l_udf_var_with_proc_value_tbl(i).variable_code;
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_value_id := to_char(l_udf_var_with_proc_value_tbl(i).variable_value_id);
	  var_tbl_cnt := var_tbl_cnt + 1;
      END IF;
  end loop;
  END IF;
  -- End: Added for UDV with Procedures enhancement

  -- Begin: Added for CLM UDA
  IF l_clm_udf_tbl.COUNT > 0 THEN
  for i in l_clm_udf_tbl.first..l_clm_udf_tbl.last loop
      IF l_clm_udf_tbl.EXISTS(i) THEN
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_code := l_clm_udf_tbl(i).variable_code;
	  x_hdr_var_value_tbl(var_tbl_cnt).variable_value_id := to_char(l_clm_udf_tbl(i).variable_value_id);
	  var_tbl_cnt := var_tbl_cnt + 1;
      END IF;
  end loop;
  END IF;
  -- End: Added for CLM UDA

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '163: Finished adding User defined variable values');
  END IF;

  -- Log all Variable values in the Pl/sql table
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
                    '170: Finished Step6 - Consolidate all variabels');

        -- Print All Header Variables
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '180: All Header variables ');
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '190: Variable name '||'			' ||'Variable value');
  IF x_hdr_var_value_tbl.Count > 0 THEN
	FOR i IN x_hdr_var_value_tbl.first..x_hdr_var_value_tbl.last LOOP
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                      x_hdr_var_value_tbl(i).variable_code ||'			'||
                      x_hdr_var_value_tbl(i).variable_value_id);
        END LOOP;
  END IF;
  /*
        -- Print All Line Variables
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '200: All Line variables ');
	IF (l_line_level_rules_flag = 'Y')
		FOR i IN x_line_sysvar_value_tbl.FIRST..x_line_sysvar_value_tbl.LAST LOOP

		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
			    G_MODULE||l_api_name,
			    '210: Line Number'||'			' ||
			    'Variable Name   '||'			' ||
			    'Variable Value  '||'			' ||
			    'Item Id'||'			' ||
			    'Org Id');

		     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
			      x_line_sysvar_value_tbl(i).line_number ||'			'||
			      x_line_sysvar_value_tbl(i).variable_code ||'			'||
			      x_line_sysvar_value_tbl(i).variable_value ||'			'||
			      x_line_sysvar_value_tbl(i).item_id ||'			'||
			      x_line_sysvar_value_tbl(i).org_id);
		END LOOP;
        END IF;

        -- Print Line count
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE||l_api_name,
	               '220: No. of Lines: '|| x_line_count);

*/
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

 END get_document_values;


END OKC_XPRT_XRULE_VALUES_PVT;

/
