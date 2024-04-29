--------------------------------------------------------
--  DDL for Package Body OKC_CLM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CLM_PKG" AS
/* $Header: OKCCLMPB.pls 120.0.12010000.18 2012/01/06 11:35:16 harchand noship $ */
------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_CLM_PKG';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_LEVEL_PROCEDURE            CONSTANT   NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=510; -- OKC Application
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;


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

  G_RECORD_DELETED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_DELETED;
  G_RECORD_CHANGED             CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_LOCK_RECORD_DELETED        CONSTANT VARCHAR2(200) := OKC_API.G_LOCK_RECORD_DELETED;

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
    x_udf_var_value_tbl  OUT NOCOPY  okc_xprt_xrule_values_pvt.udf_var_value_tbl_type
)
IS
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
  -- call expert API for getting udv values
  OKC_XPRT_XRULE_VALUES_PVT.get_user_defined_variables (
    p_api_version   => l_api_version,
    p_init_msg_list => p_init_msg_list ,
    p_doc_type      => p_doc_type,
    p_doc_id        => p_doc_id,
    p_org_id		    => p_org_id,
    p_intent        => p_intent,
    x_return_status => x_return_status,
    x_msg_data      => x_msg_data,
    x_msg_count     => x_msg_count,
    x_udf_var_value_tbl => x_udf_var_value_tbl
    );
     --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

 END get_user_defined_variables;
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
    x_udf_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.udf_var_value_tbl_type
)
IS

l_api_name 		VARCHAR2(30) := 'get_udv_with_procedures';
l_api_version   	CONSTANT NUMBER := 1.0;

BEGIN
 -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  --call expert API to get Procedural udv values
OKC_XPRT_XRULE_VALUES_PVT.get_udv_with_procedures (
    p_api_version   => l_api_version,
    p_init_msg_list => p_init_msg_list ,
    p_doc_type      => p_doc_type,
    p_doc_id        => p_doc_id,
    p_org_id		    => p_org_id,
    p_intent        => p_intent,
    x_return_status => x_return_status,
    x_msg_data      => x_msg_data,
    x_msg_count     => x_msg_count,
    x_udf_var_value_tbl => x_udf_var_value_tbl
    );

      --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

 END get_udv_with_procedures;


PROCEDURE  get_clm_udv_value(
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    p_variable_code    IN  VARCHAR2,
    p_clm_ref1         IN  VARCHAR2,
    p_clm_ref2         IN  VARCHAR2,
    p_clm_ref3         IN  VARCHAR2,
    p_clm_ref4         IN  VARCHAR2,
    p_clm_ref5         IN  VARCHAR2,
    p_clm_source       IN  VARCHAR2,
    p_variable_name    IN  VARCHAR2,
    p_uda_mode         IN  VARCHAR2,
    x_variable_value   OUT NOCOPY VARCHAR2
)
IS

l_api_name 		VARCHAR2(30) := 'get_clm_udv_value';


CURSOR c_get_doc_type_class (doc_type VARCHAR2) IS
SELECT document_type_class
FROM okc_bus_doc_types_b
WHERE document_type = doc_type;

l_doc_type_class VARCHAR2(100);
l_entity_name VARCHAR2(100);
l_pk1_value NUMBER;
l_pk2_value NUMBER := -1;
l_attr_grp VARCHAR2(100);
l_attr VARCHAR2(100);
l_address_type VARCHAR2(100);

CURSOR c_get_po_draft_id (c_po_header_id NUMBER) IS
SELECT draft_id
FROM po_headers_draft_all
WHERE po_header_id = c_po_header_id;

l_variable_value VARCHAR2(4000);

TYPE cur_typ IS REF CURSOR;
c cur_typ;
query_str VARCHAR2(4000);

FUNCTION extract_value_from_xml (p_address_type VARCHAR2,
                                 p_attribute VARCHAR2,
                                 p_xml_string VARCHAR2)
RETURN VARCHAR2 IS
l_start_tag  VARCHAR2(100);
l_end_tag  VARCHAR2(100);
l_start_pos NUMBER;
l_num_chars NUMBER;
l_value VARCHAR2(4000);
BEGIN
l_start_tag := '<'||p_address_type||'_'||p_attribute||'>';
l_end_tag := '</'||p_address_type||'_'||p_attribute||'>';
l_start_pos := InStr(p_xml_string,l_start_tag)+Length(l_start_tag);
l_num_chars :=  InStr(p_xml_string,l_end_tag) - l_start_pos ;
l_value :=  SubStr(p_xml_string,l_start_pos,l_num_chars);
RETURN l_value;
END;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'get_clm_udv_value');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_doc_type'||' '||p_doc_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_doc_id'||' '||p_doc_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_variable_code'||' '||p_variable_code);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_clm_ref1'||' '||p_clm_ref1);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_clm_ref2'||' '||p_clm_ref2);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_clm_ref3'||' '||p_clm_ref3);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_clm_ref4'||' '||p_clm_ref4);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_clm_ref5'||' '||p_clm_ref5);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_clm_source'||' '||p_clm_source);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_variable_name'||' '||p_variable_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter p_uda_mode'||' '||p_uda_mode);
  END IF;

  OPEN c_get_doc_type_class(p_doc_type);
  FETCH c_get_doc_type_class INTO l_doc_type_class;
  CLOSE c_get_doc_type_class;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: value l_doc_type_class'||' '||l_doc_type_class);
  END IF;

    IF p_clm_source = 'UDA' THEN

           IF l_doc_type_class = 'PO' THEN
              l_entity_name := 'PO_HEADER_EXT_ATTRS';
           ELSIF l_doc_type_class = 'SOURCING' THEN
	            l_entity_name := 'PON_AUC_HDRS_EXT_ATTRS';
	         ELSE
	            l_entity_name := 'PO_REQ_HEADER_EXT_ATTRS';
	         END IF;

              l_pk1_value   := p_doc_id;

           IF l_entity_name = 'PO_HEADER_EXT_ATTRS' THEN
              OPEN c_get_po_draft_id(p_doc_id);
              FETCH c_get_po_draft_id INTO l_pk2_value;
              CLOSE c_get_po_draft_id;
	         ELSE
	            l_pk2_value := NULL;
	         END IF;

              l_attr_grp := p_clm_ref2;
              l_attr     := p_clm_ref3;
              l_address_type := p_clm_ref4;

           IF p_clm_ref1='single' THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Parameter l_entity_name'||' '||l_entity_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Parameter l_pk1_value'||' '||l_pk1_value);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Parameter l_pk2_value'||' '||l_pk2_value);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Parameter l_attr_grp'||' '||l_attr_grp);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Parameter l_attr'||' '||l_attr);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Parameter p_uda_mode'||' '||p_uda_mode);
  END IF;

/* To remove compile time dependency on PO package
              l_variable_value := PO_UDA_PUB.get_single_attr_value(p_entity_code => l_entity_name,
                                               pk1_value     => l_pk1_value,
                                               pk2_value     => l_pk2_value,
                                               p_attr_grp_int_name => l_attr_grp,
                                               p_attr_int_name => l_attr,
                                               p_mode => p_uda_mode
                                               );
*/
              EXECUTE IMMEDIATE 'select PO_UDA_PUB.get_single_attr_value(p_entity_code => :1,
                                               pk1_value     => :2,
                                               pk2_value     => :3,
                                               p_attr_grp_int_name => :4,
                                               p_attr_int_name => :5,
                                               p_mode => :6) from dual'
                      INTO l_variable_value
                      USING l_entity_name,l_pk1_value,l_pk2_value,l_attr_grp,l_attr,p_uda_mode;

           ELSIF p_clm_ref1='address' THEN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: Parameter l_entity_name'||' '||l_entity_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: Parameter l_pk1_value'||' '||l_pk1_value);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: Parameter l_pk2_value'||' '||l_pk2_value);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: Parameter p_clm_ref2'||' '||p_clm_ref2);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: Parameter p_clm_ref3'||' '||p_clm_ref3);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '130: Parameter p_clm_ref4'||' '||p_clm_ref4);
  END IF;

/* To remove compile time dependency on PO package
              l_variable_value := PO_UDA_PUB.get_address_attr_value(p_template_id => NULL,
			                       p_entity_code => l_entity_name,
					       pk1_value     =>  l_pk1_value,
					       pk2_value     => l_pk2_value,
                                               pk3_value     => NULL,
                                               pk4_value     => NULL,
                                               pk5_value     => NULL,
                                               p_attr_grp_id  => NULL,
                                               p_attr_grp_int_name  => p_clm_ref2,
                                               p_attr_id    => NULL,
                                               p_attr_int_name  => p_clm_ref3,
                                               p_address_type  => p_clm_ref4);
*/
                 EXECUTE IMMEDIATE 'select PO_UDA_PUB.get_address_attr_value(p_template_id => NULL,
			                              p_entity_code => :2,
					                          pk1_value     =>  :3,
					                          pk2_value     => :4,
                                    pk3_value     => NULL,
                                    pk4_value     => NULL,
                                    pk5_value     => NULL,
                                    p_attr_grp_id  => NULL,
                                    p_attr_grp_int_name  => :9,
                                    p_attr_id    => NULL,
                                    p_attr_int_name  => :11,
                                    p_address_type  => :12) from dual'
                          INTO l_variable_value
                          USING l_entity_name,l_pk1_value,l_pk2_value,p_clm_ref2,p_clm_ref3,p_clm_ref4;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '140: Parameter l_variable_value'||' '||l_variable_value);
  END IF;


              IF (p_clm_ref3 = 'addressdtlsxml' OR p_clm_ref3 = 'contactdtlsxml') THEN

              l_variable_value := extract_value_from_xml(p_address_type => p_clm_ref4,
                                                         p_attribute    => p_clm_ref5,
                                                         p_xml_string   => l_variable_value);
                  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '150: Parameter l_variable_value'||' '||l_variable_value);
                  END IF;

              END IF;

           END IF;                                             -- p_clm_ref1
    ELSIF p_clm_source = 'named' THEN
       IF p_clm_ref2 = 'PO_HEADERS_ALL' THEN

          query_str := 'select '||p_clm_ref3||' from PO_HEADERS_ALL where po_header_id = '||p_doc_id;
          OPEN c FOR query_str;
          FETCH c INTO l_variable_value;
          CLOSE c;
       END IF;
    END IF;                                                -- clm_source

    x_variable_value := l_variable_value;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameter l_variable_value'||' '||x_variable_value);
  END IF;
END get_clm_udv_value;



PROCEDURE get_clm_udv (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id             IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.udf_var_value_tbl_type
)
IS

CURSOR csr_get_clm_udv (p_doc_type VARCHAR2,p_doc_id NUMBER, p_intent VARCHAR2, p_org_id NUMBER) IS
SELECT var.variable_code variable_code, --Removed USER$ to resolve Rule firing for UDV with Procedures
       var.clm_ref1,var.clm_ref2,var.clm_ref3,var.clm_ref4,var.clm_ref5, var.clm_source, vart.variable_name
  FROM okc_bus_variables_b var, okc_bus_variables_tl vart
 WHERE var.clm_source IS NOT NULL
   AND var.variable_code = vart.variable_code
   AND vart.language = 'US'
   AND var.variable_source = 'M'
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
	   AND rhdr.status_code = 'ACTIVE'
--	   AND SUBSTR(rcon.object_code,1,3)  <> 'OKC'
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
	   AND rhdr.status_code = 'ACTIVE'
--	   AND SUBSTR(rcon.object_value_code,1,3)  <> 'OKC'
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
	   AND rhdr.status_code = 'ACTIVE'
--	   AND SUBSTR(rcon.object_code,1,3)  <> 'OKC'
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
	   AND rhdr.status_code = 'ACTIVE'
--	   AND SUBSTR(rcon.object_value_code,1,3)  <> 'OKC'
	   GROUP BY rcon.object_value_code);

     /*
CURSOR csr_get_uniq_proc (p_sequence_id NUMBER) IS
SELECT distinct procedure_name procedure_name
  FROM okc_xprt_deviations_t
 WHERE run_id = p_sequence_id;


CURSOR csr_get_vars_for_proc (p_procedure_name VARCHAR2, p_sequence_id NUMBER) IS
SELECT distinct variable_code variable_code
  FROM okc_xprt_deviations_t
 WHERE run_id = p_sequence_id
   AND procedure_name = p_procedure_name;
     */
l_api_name 		VARCHAR2(30) := 'get_clm_udv';
l_api_version   	CONSTANT NUMBER := 1.0;

--l_sql_stmt              LONG;
l_sequence_id 		NUMBER;
var_tbl_cnt		NUMBER := 1;
l_udf_var_value_tbl	OKC_XPRT_XRULE_VALUES_PVT.udf_var_value_tbl_type;
/*
 --bug 8501694-kkolukul: Multiple values variables used in expert
l_udf_with_proc_mul_val_tbl  OKC_XPRT_XRULE_VALUES_PVT.udf_var_value_tbl_type;
l_hook_used NUMBER;
*/
-- CLM Changes
l_clm_udf_tbl  OKC_XPRT_XRULE_VALUES_PVT.udf_var_value_tbl_type;

TYPE VariableCodeList IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER; -- changed for R12
variableCode_tbl           VariableCodeList;

i NUMBER := 1;

l_variable_value VARCHAR2(2500);

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;


  FOR  csr_get_clm_udv_rec IN csr_get_clm_udv(p_doc_type, p_doc_id, p_intent, p_org_id)
  LOOP

  get_clm_udv_value(p_doc_type=>p_doc_type,
                    p_doc_id=>p_doc_id,
                    p_variable_code => csr_get_clm_udv_rec.variable_code,
                    p_clm_ref1=>csr_get_clm_udv_rec.clm_ref1,
                    p_clm_ref2=>csr_get_clm_udv_rec.clm_ref2,
                    p_clm_ref3=>csr_get_clm_udv_rec.clm_ref3,
                    p_clm_ref4=>csr_get_clm_udv_rec.clm_ref4,
                    p_clm_ref5=>csr_get_clm_udv_rec.clm_ref5,
                    p_clm_source=>csr_get_clm_udv_rec.clm_source,
                    p_variable_name=>csr_get_clm_udv_rec.variable_name,
                    p_uda_mode=>'INTERNAL_VALUE',
                    x_variable_value=>l_variable_value
                    );

    l_udf_var_value_tbl(i).variable_code := csr_get_clm_udv_rec.variable_code;
    l_udf_var_value_tbl(i).variable_value_id:= l_variable_value;

  i:= i +1 ;

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
     IF  l_udf_var_value_tbl.Count > 0 THEN

     FOR i IN l_udf_var_value_tbl.FIRST..l_udf_var_value_tbl.LAST
          LOOP
        	l_udf_var_value_tbl.DELETE(i);
     END LOOP;

     END IF;


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

END get_clm_udv;


PROCEDURE set_clm_udv (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_document_type     IN  VARCHAR2,
    p_document_id       IN  NUMBER,
    p_output_error	IN  VARCHAR2 :=  FND_API.G_TRUE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER
)
IS

l_api_version       CONSTANT NUMBER := 1.0;
l_api_name          CONSTANT VARCHAR2(30) := 'set_clm_udv';
l_variable_value        VARCHAR2(2500) := NULL;
l_previous_var_code		okc_bus_variables_b.variable_code%TYPE := '-99';
l_return_status			VARCHAR2(10) := NULL;

CURSOR csr_get_clm_udv IS
SELECT VB.variable_code,
       KA.id,
       KA.article_version_id,
       VBT.variable_name,
       VB.clm_source,
       VB.clm_ref1,
       VB.clm_ref2,
       VB.clm_ref3,
       VB.clm_ref4,
       VB.clm_ref5
FROM okc_k_articles_b KA,
     okc_k_art_variables KV,
     okc_bus_variables_b VB,
     okc_bus_variables_tl VBT
WHERE VB.variable_code = KV.variable_code
and   VB.variable_code = VBT.variable_code
and   VBT.language = 'US'
AND KA.id = KV.cat_id
AND VB.clm_source is not null
AND KA.document_type = p_document_type
AND KA.document_id = p_document_id
ORDER BY VB.variable_code;

   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered set_clm_udv');
		FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_document_type:'||p_document_type);
		FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_document_id:'||p_document_id);
    END IF;

    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;

    /* Initialize API return status to success */
    x_return_status := G_RET_STS_SUCCESS;

    /* Clear the temp table */
    DELETE FROM OKC_TERMS_CLM_UDV_T;

    FOR csr_get_clm_udv_rec IN csr_get_clm_udv LOOP

        /* Get the variable value */
		IF l_previous_var_code <> csr_get_clm_udv_rec.variable_code THEN

		    l_variable_value := NULL;

               get_clm_udv_value(p_doc_type=>p_document_type,
                    p_doc_id=>p_document_id,
                    p_variable_code => csr_get_clm_udv_rec.variable_code,
                    p_clm_ref1=>csr_get_clm_udv_rec.clm_ref1,
                    p_clm_ref2=>csr_get_clm_udv_rec.clm_ref2,
                    p_clm_ref3=>csr_get_clm_udv_rec.clm_ref3,
                    p_clm_ref4=>csr_get_clm_udv_rec.clm_ref4,
                    p_clm_ref5=>csr_get_clm_udv_rec.clm_ref5,
                    p_clm_source=>csr_get_clm_udv_rec.clm_source,
                    p_variable_name=>csr_get_clm_udv_rec.variable_name,
                    p_uda_mode=>'DISPLAY_VALUE',
                    x_variable_value=>l_variable_value
                    );

		END IF;

		/* Insert data into the temp table */
		IF l_variable_value IS NOT NULL THEN

			INSERT INTO OKC_TERMS_CLM_UDV_T
			(
				VARIABLE_CODE,
				VARIABLE_VALUE,
				DOC_TYPE,
				DOC_ID,
				ARTICLE_VERSION_ID,
				CAT_ID
			)
			VALUES
			(
				csr_get_clm_udv_rec.variable_code,		-- VARIABLE_CODE
				l_variable_value,	 						-- VARIABLE_VALUE
				p_document_type, 							-- DOCUMENT_TYPE
				p_document_id, 								-- DOCUMENT_ID
				csr_get_clm_udv_rec.article_version_id,  -- ARTICLE_VERSION_ID
				csr_get_clm_udv_rec.id					-- CAT_ID
			);
		END IF;

		l_previous_var_code := csr_get_clm_udv_rec.variable_code;

    END LOOP;

	IF p_output_error = FND_API.G_TRUE AND FND_MSG_PUB.Count_Msg > 0 THEN

		x_return_status := G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Leaving set_clm_udv');
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving set_clm_udv : OKC_API.G_EXCEPTION_ERROR Exception');
      END IF;

      IF csr_get_clm_udv%ISOPEN THEN
         CLOSE csr_get_clm_udv;
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving set_clm_udv : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
      END IF;

      IF csr_get_clm_udv%ISOPEN THEN
         CLOSE csr_get_clm_udv;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'3000: Leaving set_clm_udv because of EXCEPTION: '||sqlerrm);
      END IF;

      IF csr_get_clm_udv%ISOPEN THEN
         CLOSE csr_get_clm_udv;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END set_clm_udv;


--CLM Changes Ends


---------------------------------------------------
--  Procedure: get_default_scn_id
---------------------------------------------------

PROCEDURE GET_DEFAULT_SCN_CODE (
 p_api_version        IN  NUMBER,
 p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
 p_article_id IN NUMBER,
 p_article_version_id IN NUMBER,
 p_doc_id IN NUMBER,
 p_doc_type IN VARCHAR2,
 x_default_scn_code OUT NOCOPY OKC_SECTIONS_B.SCN_CODE%TYPE,
 x_return_status      OUT NOCOPY VARCHAR2
 )
 IS
 l_api_name 		VARCHAR2(30) := 'get_default_scn_id';
l_api_version   	CONSTANT NUMBER := 1.0;

 CURSOR udv_value_csr(p_doc_id number, p_article_id number, p_article_version_id NUMBER)
               IS
               SELECT kvar.variable_value_id FROM okc_k_art_variables kvar,okc_k_articles_b kart
               WHERE kart.id = kvar.cat_id
               AND kart.document_id = p_doc_id
               AND kvar.variable_value_id IN
               (SELECT avs.variable_value_id FROM  okc_art_var_sections avs
               WHERE avs.article_id = p_article_id
               AND avs.article_version_id = p_article_version_id
              )
               AND kvar.variable_value_id IS NOT NULL;

  CURSOR var_type_csr(p_variable_code VARCHAR2) IS
               SELECT bv.variable_type FROM okc_bus_variables_b bv
               WHERE bv.variable_code = p_variable_code;


  CURSOR art_var_dtls_csr(p_article_id NUMBER,p_article_version_id NUMBER) IS
  SELECT variable_value_id,variable_value,variable_code
  FROM okc_art_var_sections
  WHERE article_id = p_article_id
  AND article_version_id = p_article_version_id;

  CURSOR get_varcode_from_art(p_article_id NUMBER) IS
  SELECT variable_code
  FROM okc_article_versions
  WHERE article_version_id = p_article_version_id;


  CURSOR def_scn_code_csr(p_variable_value VARCHAR2,p_article_id NUMBER,p_article_version_id NUMBER) IS
  SELECT avs.scn_CODE FROM okc_art_var_sections avs
               WHERE  avs.variable_value = p_variable_value
               AND avs.article_id = p_article_id
               AND avs.article_version_id = p_article_version_id;



  CURSOR doc_details_csr ( p_doc_id NUMBER) IS
  SELECT art.ORG_ID,art.ARTICLE_INTENT,kart.document_type
  FROM okc_articles_all art,okc_k_articles_b kart
               WHERE art.ARTICLE_ID = kart.sav_sae_id
               AND kart.document_id = p_doc_id
               AND ROWNUM=1;

  CURSOR var_value_csr(p_var_value_id NUMBER,p_article_id NUMBER,p_article_version_id NUMBER) IS
  SELECT variable_value
  FROM okc_art_var_sections
  WHERE variable_value_id = p_var_value_id
  AND article_id = p_article_id
  AND article_version_id = p_article_version_id;

  CURSOR get_var_name_csr(p_var_code VARCHAR2) IS
  SELECT variable_name
  FROM okc_bus_variables_tl
  WHERE variable_code = p_var_code;

/* To remove compile time dependency on CLM DB changes

  CURSOR get_clm_format_po_csr(p_doc_id NUMBER) IS
  SELECT  clm_document_format
  FROM po_headers_all
  WHERE po_header_id = p_doc_id;

  CURSOR get_clm_format_sol_csr(p_doc_id NUMBER) IS
  SELECT  document_format
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_doc_id;

*/

  l_var_code VARCHAR2(30) := NULL;
  l_var_value VARCHAR2(30) := NULL;
  l_var_name VARCHAR2(100);
  l_var_value_id NUMBER := NULL ;
  l_var_type VARCHAR2(1) := NULL ;
  l_def_scn_code VARCHAR2(30) := NULL ;
  l_return VARCHAR2(1) := 'N';
  l_return2 VARCHAR2(1) := 'N';
  l_org_id NUMBER := NULL ;
  l_intent VARCHAR2(1) := NULL ;
  l_doc_type VARCHAR2(30) := NULL;
  i NUMBER := 1;
  l_msg_data VARCHAR2(300) := NULL;
  l_msg_count NUMBER := NULL;

  l_count NUMBER :=0;
  l_sys_var_value_tbl okc_xprt_xrule_values_pvt.var_value_tbl_type;
  l_udf_var_value_tbl okc_xprt_xrule_values_pvt.udf_var_value_tbl_type;

  BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;
  --get doc_details
  OPEN doc_details_csr(p_doc_id) ;
  FETCH doc_details_csr INTO l_org_id,l_intent,l_doc_type;
  CLOSE doc_details_csr;
  OPEN art_var_dtls_csr(p_article_id,p_article_version_id);
  FETCH art_var_dtls_csr INTO l_var_value_id,l_var_value,l_var_code;
  IF (art_var_dtls_csr%NOTFOUND)  THEN
		      l_return := 'N';
      ELSE
          l_return := 'Y';
	  END IF;

  IF (l_return = 'Y') THEN
--Bug# 9855895

  if l_var_code is null then
     open get_varcode_from_art(p_article_id);
     fetch get_varcode_from_art into l_var_code;
     close get_varcode_from_art;
  end if;

   OPEN get_var_name_csr(l_var_code);
   FETCH  get_var_name_csr INTO l_var_name;
   CLOSE  get_var_name_csr;

   IF l_var_name = 'Format' THEN

     IF SubStr(p_doc_type,1,12) = 'SOLICITATION' THEN     --Bug 9953583
/* To remove compile time dependency on CLM DB changes
        OPEN get_clm_format_sol_csr(p_doc_id);
        FETCH get_clm_format_sol_csr INTO l_var_value;
        CLOSE get_clm_format_sol_csr;
*/
        EXECUTE IMMEDIATE 'SELECT  document_format
                           FROM pon_auction_headers_all
                           WHERE auction_header_id = :1'
                INTO l_var_value
                USING p_doc_id;
     ELSE
/* To remove compile time dependency on CLM DB changes
        OPEN get_clm_format_po_csr(p_doc_id);
        FETCH get_clm_format_po_csr INTO l_var_value;
        CLOSE get_clm_format_po_csr;
*/
        EXECUTE IMMEDIATE 'SELECT  clm_document_format
                           FROM po_headers_all
                           WHERE po_header_id = :1'
                INTO l_var_value
                USING p_doc_id;
     END IF;

   OPEN  def_scn_code_csr(l_var_value,p_article_id,p_article_version_id);
   FETCH def_scn_code_csr INTO l_def_scn_code;
   CLOSE def_scn_code_csr;

   ELSE

  OPEN var_type_csr(l_var_code) ;
  FETCH var_type_csr INTO l_var_type;
  CLOSE var_type_csr;

      IF (l_var_type = 'S') THEN
    --call to get_system_variables
      get_system_variables
        ( p_api_version        => l_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_data           => l_msg_data,
          x_msg_count          => l_msg_count,
          p_doc_type           => l_doc_type,
          p_doc_id             => p_doc_id,
          p_only_doc_variables => FND_API.G_FALSE,
          x_sys_var_value_tbl  => l_sys_var_value_tbl);


    --for results table, get default_scn_code from okc_art_var_sections
    FOR i IN l_sys_var_value_tbl.FIRST..l_sys_var_value_tbl.LAST LOOP
      IF (l_sys_var_value_tbl(i).variable_code = l_var_code) THEN
      OPEN def_scn_code_csr(l_sys_var_value_tbl(i).variable_value_id,p_article_id,p_article_version_id);
      FETCH def_scn_code_csr INTO l_def_scn_code;
      CLOSE def_scn_code_csr;
      END IF;
    END LOOP;
   END IF;

      IF (l_var_type = 'P') THEN
       --call to get_udv_with_procedure
       get_udv_with_procedures(
    p_api_version   => l_api_version,
    p_init_msg_list => p_init_msg_list ,
    p_doc_type      => l_doc_type,
    p_doc_id        => p_doc_id,
    p_org_id		    => l_org_id,
    p_intent        => l_intent,
    x_return_status => x_return_status,
    x_msg_data      => l_msg_data,
    x_msg_count     => l_msg_count,
    x_udf_var_value_tbl => l_udf_var_value_tbl
    );
    --for results table, get default_scn_code from okc_art_var_sections
     FOR i IN l_udf_var_value_tbl.FIRST..l_udf_var_value_tbl.LAST  LOOP
     IF (l_udf_var_value_tbl(i).variable_code = l_var_code) THEN
      OPEN var_value_csr(l_udf_var_value_tbl(i).variable_value_id,p_article_id,p_article_version_id);
      FETCH var_value_csr INTO l_var_value;
      CLOSE var_value_csr;

      OPEN  def_scn_code_csr(l_var_value,p_article_id,p_article_version_id);
      FETCH def_scn_code_csr INTO l_def_scn_code;
      CLOSE def_scn_code_csr;

     END IF;
     END LOOP;
   END IF;

    IF (l_var_type = 'U') THEN
  OPEN udv_value_csr(p_doc_id,p_article_id,p_article_version_id);
  FETCH udv_value_csr INTO l_var_value_id;
      IF (udv_value_csr%NOTFOUND)  THEN
	   l_return2 := 'N';
      ELSE
    l_return2 := 'Y';
	  END IF;

  CLOSE udv_value_csr;

     IF (l_return2 = 'Y') THEN
   OPEN var_value_csr(l_var_value_id,p_article_id,p_article_version_id);
   FETCH var_value_csr INTO l_var_value;
   CLOSE var_value_csr;

      OPEN  def_scn_code_csr(l_var_value,p_article_id,p_article_version_id);
      FETCH def_scn_code_csr INTO l_def_scn_code;
      CLOSE def_scn_code_csr;
    END IF; --l_return2
     END IF;   --udv_type if condn

END IF;

  END IF; --l_return if condn
  --- If any errors happen abort API
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 x_default_scn_code := l_def_scn_code;

END get_default_scn_code;

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
    x_sys_var_value_tbl  OUT NOCOPY okc_xprt_xrule_values_pvt.var_value_tbl_type
)
IS
    l_api_name          VARCHAR2(30) := 'get_system_variables';
    l_api_version       CONSTANT NUMBER := 1.0;

    l_sys_var_value_tbl okc_xprt_xrule_values_pvt.var_value_tbl_type;
BEGIN

OKC_XPRT_XRULE_VALUES_PVT.get_system_variables(
          p_api_version        => l_api_version,
          p_init_msg_list      => p_init_msg_list,
          x_return_status      => x_return_status,
          x_msg_data           => x_msg_data,
          x_msg_count          => x_msg_count,
          p_doc_type           => p_doc_type,
          p_doc_id             => p_doc_id,
          p_only_doc_variables => p_only_doc_variables,
          x_sys_var_value_tbl  => l_sys_var_value_tbl);

END get_system_variables;

PROCEDURE clm_remove_dup_sections( p_document_type   IN   VARCHAR2,
                                  p_document_id     IN   NUMBER,
                                  x_return_status   OUT  NOCOPY VARCHAR2,
                                  x_msg_data        OUT  NOCOPY VARCHAR2,
                                  x_msg_count       OUT  NOCOPY NUMBER)
 IS

  TYPE DupScnIdList IS TABLE OF OKC_SECTIONS_B.ID%TYPE INDEX BY BINARY_INTEGER;
  --TYPE ScnCodeList IS TABLE OF OKC_SECTIONS_B.SCN_CODE%TYPE INDEX BY BINARY_INTEGER;

  l_api_name  CONSTANT VARCHAR2(30) := 'clm_remove_dup_scn_art';
  --l_dup_scn_code_tbl ScnCodeList;
  l_dup_scn_id_tbl DupScnIdList;
  l_remaining_scn_ids VARCHAR2(4000);
  l_del_stmt VARCHAR2(4000);

    CURSOR l_get_dup_sec_csr IS
      SELECT scn_code, Count(scn_code)
        FROM okc_sections_b
        WHERE document_type = p_document_type
          AND document_id = p_document_id
        GROUP BY scn_code
        HAVING (Count(scn_code) >1 );

    CURSOR l_get_dup_sec_ids_csr(p_scn_code VARCHAR2) IS
      SELECT id
        FROM okc_sections_b
        WHERE document_type = p_document_type
          AND document_id = p_document_id
          AND scn_code = p_scn_code
        ORDER BY id;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: entered okc_terms_copy_pvt.clm_remove_dup_scn_art');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: param p_document_type: ' || p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: param p_document_id: ' || p_document_id);
  END IF;

  /*for each duplicate section_code in the document find their
    first section_id and replace all the remaining ones with first Id*/
   FOR rec IN l_get_dup_sec_csr LOOP
    OPEN l_get_dup_sec_ids_csr(rec.scn_code);
    FETCH l_get_dup_sec_ids_csr BULK COLLECT INTO l_dup_scn_id_tbl;
    CLOSE l_get_dup_sec_ids_csr;
   FOR i IN l_dup_scn_id_tbl.first..l_dup_scn_id_tbl.last LOOP
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'400: in FOR loop');
    END IF;

    l_remaining_scn_ids := NULL;

    IF (i <> 1) THEN
      if (i NOT IN (l_dup_scn_id_tbl.last) )THEN
        l_remaining_scn_ids := l_remaining_scn_ids || l_dup_scn_id_tbl(i) || ', ';
      ELSE
        l_remaining_scn_ids := l_remaining_scn_ids || l_dup_scn_id_tbl(i);
      END IF;
    END IF;
   END LOOP;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'500: l_dup_scn_id_tbl(1): '|| l_dup_scn_id_tbl(1));
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: l_remaining_scn_ids: '|| l_remaining_scn_ids);
   END IF;

   IF l_remaining_scn_ids IS NOT NULL THEN
    UPDATE okc_k_articles_b
      SET scn_id = l_dup_scn_id_tbl(1),
          display_sequence = display_sequence +  ((SELECT Max(display_sequence) FROM okc_k_articles_b
                                WHERE document_type = p_document_type AND document_id = p_document_id
                                AND scn_id = l_dup_scn_id_tbl(1)))
      WHERE document_type = p_document_type
      AND document_id = p_document_id
      AND scn_id IN (l_remaining_scn_ids);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'700: Update done on okc_k_articles_b table ');
    END IF;

   /*When all the articles are updated with the first section_id, delete the remaining sections from okc_sections_b table*/

    l_del_stmt := 'DELETE FROM okc_sections_b WHERE id IN (' || l_remaining_scn_ids || ')';
    EXECUTE IMMEDIATE l_del_stmt;

   END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'800: Delete done on okc_sections_b table ');
    END IF;
  END LOOP; -- FOR rec IN l_get_dup_sec_csr LOOP

  x_return_status := 'S';
EXCEPTION

WHEN NO_DATA_FOUND THEN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving clm_remove_dup_scn_art No Data in Source');
  END IF;
  null;

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving clm_remove_dup_scn_art: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 IF l_get_dup_sec_csr%ISOPEN THEN
    CLOSE  l_get_dup_sec_csr;
 END IF;

 IF l_get_dup_sec_ids_csr%ISOPEN THEN
    CLOSE  l_get_dup_sec_ids_csr;
 END IF;

 x_return_status := G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN

IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_archived_doc because of EXCEPTION: '||sqlerrm);
END IF;

 IF l_get_dup_sec_csr%ISOPEN THEN
    CLOSE  l_get_dup_sec_csr;
 END IF;

 IF l_get_dup_sec_ids_csr%ISOPEN THEN
    CLOSE  l_get_dup_sec_ids_csr;
 END IF;

x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

END clm_remove_dup_sections;


PROCEDURE clm_remove_dup_articles( p_document_type   IN   VARCHAR2,
                                  p_document_id     IN   NUMBER,
                                  x_return_status   OUT  NOCOPY VARCHAR2,
                                  x_msg_data        OUT  NOCOPY VARCHAR2,
                                  x_msg_count       OUT  NOCOPY NUMBER)
IS

 l_api_name  CONSTANT VARCHAR2(30) := 'clm_remove_dup_articles';

 TYPE ArticleVersionIdList       IS TABLE OF OKC_K_ARTICLES_B.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER;

 l_art_ver_ids_tbl ArticleVersionIdList;
 l_dup_articles VARCHAR2(4000);
 l_del_stmt VARCHAR2(4000);

 CURSOR l_get_dup_articles_csr IS
  SELECT sav_sae_id, scn_id
    FROM okc_k_articles_b
    WHERE document_type = p_document_type
    AND document_id = p_document_id
    GROUP BY sav_sae_id, scn_id
    HAVING (Count(sav_sae_id) >1 );

  CURSOR l_get_dup_art_ids(p_article_id NUMBER, p_scn_id NUMBER) IS
    SELECT id
      FROM okc_k_articles_b
      where document_type = p_document_type
      AND document_id = p_document_id
      AND sav_sae_id = p_article_id
      AND scn_id = p_scn_id
      ORDER BY id asc;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: entered okc_terms_copy_pvt.clm_remove_dup_articles');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: param p_document_type: ' || p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: param p_document_id: ' || p_document_id);
  END IF;

  FOR rec IN  l_get_dup_articles_csr LOOP
    OPEN l_get_dup_art_ids(rec.sav_sae_id, rec.scn_id);
    FETCH l_get_dup_art_ids BULK COLLECT INTO l_art_ver_ids_tbl;
    CLOSE l_get_dup_art_ids;

     l_dup_articles := NULL;
    FOR i IN l_art_ver_ids_tbl.first..l_art_ver_ids_tbl.last LOOP
     IF i<> 1 THEN
      IF i NOT IN (l_art_ver_ids_tbl.last) THEN
        l_dup_articles := l_dup_articles || l_art_ver_ids_tbl(i) || ', ';
      ELSE
        l_dup_articles := l_dup_articles || l_art_ver_ids_tbl(i);
      END IF;
     END IF;
    END LOOP;

    IF l_dup_articles IS NOT NULL THEN
      l_del_stmt := 'DELETE FROM okc_k_articles_b WHERE id IN (' || l_dup_articles || ')';
      EXECUTE IMMEDIATE l_del_stmt;
    END IF;

  END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving clm_remove_dup_articles No Data in Source');
  END IF;
  null;

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving clm_remove_dup_articles: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

IF l_get_dup_articles_csr%ISOPEN THEN
    CLOSE  l_get_dup_articles_csr;
 END IF;

 IF l_get_dup_art_ids%ISOPEN THEN
    CLOSE  l_get_dup_art_ids;
 END IF;

 x_return_status := G_RET_STS_UNEXP_ERROR ;

WHEN OTHERS THEN

IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_archived_doc because of EXCEPTION: '||sqlerrm);
END IF;

 IF l_get_dup_articles_csr%ISOPEN THEN
    CLOSE  l_get_dup_articles_csr;
 END IF;

 IF l_get_dup_art_ids%ISOPEN THEN
    CLOSE  l_get_dup_art_ids;
 END IF;

x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

END clm_remove_dup_articles;

PROCEDURE clm_remove_dup_scn_art( p_document_type   IN   VARCHAR2,
                                  p_document_id     IN   NUMBER,
                                  x_return_status   OUT  NOCOPY VARCHAR2,
                                  x_msg_data        OUT  NOCOPY VARCHAR2,
                                  x_msg_count       OUT  NOCOPY NUMBER)
 IS

 l_api_name  CONSTANT VARCHAR2(30) := 'clm_remove_dup_scn_art';

 BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: entered okc_terms_copy_pvt.clm_remove_dup_scn_art');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: param p_document_type: ' || p_document_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: param p_document_id: ' || p_document_id);
    END IF;

    clm_remove_dup_sections( p_document_type   => p_document_type,
                             p_document_id     => p_document_id,
                                  x_return_status   => x_return_status,
                                  x_msg_data        => x_msg_data,
                                  x_msg_count       => x_msg_count);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'400: After clm_remove_dup_sections : x_return_status' || x_return_status);
    END IF;


    clm_remove_dup_articles( p_document_type   => p_document_type,
                                  p_document_id     => p_document_id,
                                  x_return_status   => x_return_status,
                                  x_msg_data        => x_msg_data,
                                  x_msg_count       => x_msg_count);

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'500: After clm_remove_dup_articles : x_return_status' || x_return_status);
    END IF;

 END clm_remove_dup_scn_art;

PROCEDURE insert_usages_row( p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_template_id            IN NUMBER,
    p_doc_numbering_scheme   IN NUMBER,
    p_document_number        IN VARCHAR2,
    p_article_effective_date IN DATE,
    p_config_header_id       IN NUMBER,
    p_config_revision_number IN NUMBER,
    p_valid_config_yn        IN VARCHAR2,
    p_orig_system_reference_code IN VARCHAR2 ,
    p_orig_system_reference_id1 IN NUMBER,
    p_orig_system_reference_id2 IN NUMBER,
    p_lock_terms_flag        IN VARCHAR2,
    p_locked_by_user_id      IN NUMBER,
    p_primary_template         IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER)
  IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_usages_row';

    l_object_version_number  OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;
    l_created_by             OKC_TEMPLATE_USAGES.CREATED_BY%TYPE;
    l_creation_date          OKC_TEMPLATE_USAGES.CREATION_DATE%TYPE;
    l_last_updated_by        OKC_TEMPLATE_USAGES.LAST_UPDATED_BY%TYPE;
    l_last_update_login      OKC_TEMPLATE_USAGES.LAST_UPDATE_LOGIN%TYPE;
    l_last_update_date       OKC_TEMPLATE_USAGES.LAST_UPDATE_DATE%TYPE;
    l_authoring_party_code   OKC_TEMPLATE_USAGES.authoring_party_code%type;

    l_temp_exists VARCHAR2(1) := 'N';

    CURSOR l_get_temp_already_exists_csr IS
      SELECT 'Y' FROM okc_mlp_template_usages
        WHERE document_type = p_document_type
          AND document_id = p_document_id
          AND template_id = p_template_id;

  BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered insert_usages_row ');
   END IF;

     -- Set Internal columns
    l_object_version_number  := 1;
    l_creation_date := Sysdate;
    l_created_by := Fnd_Global.User_Id;
    l_last_update_date := l_creation_date;
    l_last_updated_by := l_created_by;
    l_last_update_login := Fnd_Global.Login_Id;

    --Item level validations

    IF ( p_valid_config_yn NOT IN ('Y','N') AND p_valid_config_yn IS NOT NULL) THEN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: - attribute VALID_CONFIG_YN is invalid');
        END IF;
      --  Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'VALID_CONFIG_YN');
        x_return_status := G_RET_STS_ERROR;
    END IF;

    OPEN l_get_temp_already_exists_csr;
    FETCH l_get_temp_already_exists_csr INTO l_temp_exists;
    CLOSE l_get_temp_already_exists_csr;

    IF l_temp_exists <> 'Y' THEN
      INSERT INTO okc_mlp_template_usages(
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        lock_terms_flag,
        locked_by_user_id,
        primary_template	   )
      VALUES (
        p_document_type,
        p_document_id,
        p_template_id,
        p_doc_numbering_scheme,
        p_document_number,
        p_article_effective_date,
        p_config_header_id,
        p_config_revision_number,
        p_valid_config_yn,
        p_orig_system_reference_code,
        p_orig_system_reference_id1,
        p_orig_system_reference_id2,
        l_object_version_number,
        l_created_by,
        l_creation_date,
        l_last_updated_by,
        l_last_update_login,
        l_last_update_date,
        p_lock_terms_flag,
        p_locked_by_user_id,
        p_primary_template
	    );
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving Insert_Row');
    END IF;

       x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Insert_Row:OTHERS Exception');
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
         x_return_status := G_RET_STS_ERROR;

  END insert_usages_row;

FUNCTION Lock_Row(
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
  ) RETURN VARCHAR2 IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (cp_document_type VARCHAR2, cp_document_id NUMBER, cp_object_version_number NUMBER) IS
    SELECT object_version_number
      FROM OKC_MLP_TEMPLATE_USAGES
     WHERE DOCUMENT_TYPE = cp_document_type AND DOCUMENT_ID = cp_document_id
       AND (object_version_number = cp_object_version_number OR cp_object_version_number IS NULL)
    FOR UPDATE OF object_version_number NOWAIT;

    CURSOR  lchk_csr (cp_document_type VARCHAR2, cp_document_id NUMBER) IS
    SELECT object_version_number
      FROM OKC_MLP_TEMPLATE_USAGES
     WHERE DOCUMENT_TYPE = cp_document_type AND DOCUMENT_ID = cp_document_id;

    l_return_status                VARCHAR2(1);
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_object_version_number       OKC_TEMPLATE_USAGES.OBJECT_VERSION_NUMBER%TYPE;

    l_row_notfound                BOOLEAN := FALSE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Lock_Row');
    END IF;

    BEGIN

      OPEN lock_csr( p_document_type, p_document_id, p_object_version_number );
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

     EXCEPTION
      WHEN E_Resource_Busy THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Leaving Lock_Row:E_Resource_Busy Exception');
        END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.Set_Message(G_FND_APP,G_UNABLE_TO_RESERVE_REC);
        RETURN( G_RET_STS_ERROR );
    END;

    IF ( l_row_notfound ) THEN
      l_return_status := G_RET_STS_ERROR;

      OPEN lchk_csr(p_document_type, p_document_id);
      FETCH lchk_csr INTO l_object_version_number;
      l_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;

      IF (l_row_notfound) THEN
        Okc_Api.Set_Message(G_FND_APP,G_LOCK_RECORD_DELETED,
                   'ENTITYNAME','OKC_MLP_TEMPLATE_USAGES',
                   'PKEY',p_document_type||':'||p_document_id,
                   'OVN',p_object_version_number
                    );
      ELSIF l_object_version_number > p_object_version_number THEN
        Okc_Api.Set_Message(G_FND_APP,G_RECORD_CHANGED);
      ELSIF l_object_version_number = -1 THEN
        Okc_Api.Set_Message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      ELSE -- it can be the only above condition. It can happen after restore version
        Okc_Api.Set_Message(G_FND_APP,G_RECORD_CHANGED);
      END IF;
     ELSE
      l_return_status := G_RET_STS_SUCCESS;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Leaving Lock_Row');
    END IF;

    RETURN( l_return_status );

  EXCEPTION
    WHEN OTHERS THEN

      IF (lock_csr%ISOPEN) THEN
        CLOSE lock_csr;
      END IF;
      IF (lchk_csr%ISOPEN) THEN
        CLOSE lchk_csr;
      END IF;

      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'400: Leaving Lock_Row because of EXCEPTION: '||sqlerrm);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      RETURN( G_RET_STS_UNEXP_ERROR );
  END Lock_Row;

PROCEDURE Delete_Usages_Row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_document_type          IN VARCHAR2,
    p_document_id            IN NUMBER,
    p_object_version_number  IN NUMBER
  ) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'Delete_Usages_Row';
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered Delete_Usages_Row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Locking row');
    END IF;

    x_return_status := Lock_row(
      p_document_type          => p_document_type,
      p_document_id            => p_document_id,
      p_object_version_number  => p_object_version_number
    );
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: Removing rows');
    END IF;

     DELETE FROM OKC_MLP_TEMPLATE_USAGES WHERE DOCUMENT_TYPE = p_document_type AND DOCUMENT_ID = p_document_id;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Leaving Delete_Row');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving Delete_Usages_Row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving Delete_Usages_Row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'700: Leaving Delete_Usages_Row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END Delete_Usages_Row;

FUNCTION check_dup_templates( p_document_type          IN VARCHAR2,
                               p_document_id            IN NUMBER,
                               p_template_id            IN NUMBER)
  RETURN VARCHAR2
  IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_dup_templates';

    CURSOR l_template_exists_csr IS
      SELECT 'Y' FROM dual WHERE p_template_id IN (
        SELECT template_id FROM okc_template_usages
        WHERE document_type = p_document_type AND document_id = p_document_id
        UNION ALL
        SELECT template_id FROM okc_mlp_template_usages
        WHERE document_type = p_document_type AND document_id = p_document_id);

    l_template_exists VARCHAR2(1) := 'N';

  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered check_dup_templates');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: p_document_type ' || p_document_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: p_document_id ' || p_document_id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: p_template_id ' || p_template_id);
    END IF;

    OPEN l_template_exists_csr;
    FETCH l_template_exists_csr INTO l_template_exists;
    CLOSE l_template_exists_csr;

    RETURN l_template_exists;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'500: Leaving check_dup_templates:FND_API.G_EXC_ERROR Exception');
      END IF;
      --x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'600: Leaving check_dup_templates:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      --x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'700: Leaving check_dup_templates because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      --x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_dup_templates;

PROCEDURE copy_usages_row(
                      p_target_doc_type         IN      VARCHAR2,
                      p_source_doc_type         IN      VARCHAR2,
                      p_target_doc_id           IN      NUMBER,
                      p_source_doc_id           IN      NUMBER,
                      x_return_status           OUT NOCOPY VARCHAR2,
                      x_msg_data                OUT NOCOPY VARCHAR2,
                      x_msg_count               OUT NOCOPY NUMBER)
  IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'copy_usages_row';

    TYPE TemplateIdList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.TEMPLATE_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE DocNumSchemeList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.DOC_NUMBERING_SCHEME%TYPE INDEX BY BINARY_INTEGER;
    TYPE DocumentNumberList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.DOCUMENT_NUMBER%TYPE INDEX BY BINARY_INTEGER;
    TYPE ArticleEffectiveDateList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.ARTICLE_EFFECTIVE_DATE%TYPE INDEX BY BINARY_INTEGER;
    TYPE ConfigHeaderIdList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.CONFIG_HEADER_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE ConfigRevisionNumberList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.CONFIG_REVISION_NUMBER%TYPE INDEX BY BINARY_INTEGER;
    TYPE ValidConfigYNList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.VALID_CONFIG_YN%TYPE INDEX BY BINARY_INTEGER;
    TYPE OrigSystemRefCodeList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE OrigSystemRefIdList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.ORIG_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER;
    TYPE LockTermsList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.lock_terms_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE LockedByUserIdList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.locked_by_user_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE PrimaryTemplateList IS TABLE OF OKC_MLP_TEMPLATE_USAGES.primary_template%TYPE INDEX BY BINARY_INTEGER;

    TemplateIdTbl TemplateIdList;
    DocNumSchemeTbl DocNumSchemeList;
    DocumentNumberTbl DocumentNumberList;
    ArticleEffectiveDateTbl ArticleEffectiveDateList;
    ConfigHeaderIdTbl ConfigHeaderIdList;
    ConfigRevisionNumberTbl ConfigRevisionNumberList;
    ValidConfigYNTbl ValidConfigYNList;
    OrigSystemRefCodeTbl OrigSystemRefCodeList;
    OrigSystemRefId1Tbl OrigSystemRefIdList;
    OrigSystemRefId2Tbl OrigSystemRefIdList;
    LockTermsTbl LockTermsList;
    LockedByUserIdTbl LockedByUserIdList;
    PrimaryTemplateTbl PrimaryTemplateList;

    CURSOR l_get_mlp_temp_csr IS
      SELECT  TEMPLATE_ID,
              DOC_NUMBERING_SCHEME,
              DOCUMENT_NUMBER,
              ARTICLE_EFFECTIVE_DATE,
              CONFIG_HEADER_ID,
              CONFIG_REVISION_NUMBER,
              VALID_CONFIG_YN,
              ORIG_SYSTEM_REFERENCE_CODE,
              ORIG_SYSTEM_REFERENCE_ID1,
              ORIG_SYSTEM_REFERENCE_ID2,
              LOCK_TERMS_FLAG,
              LOCKED_BY_USER_ID,
              PRIMARY_TEMPLATE
        FROM okc_mlp_template_usages
        WHERE document_type = p_source_doc_type
          AND document_id   = p_source_doc_id;

  BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered copy_usages_row');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: p_target_doc_type ' || p_target_doc_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300: p_source_doc_type ' || p_source_doc_type);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: p_source_doc_id ' || p_source_doc_id);
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: p_target_doc_id ' || p_target_doc_id);
    END IF;

    OPEN l_get_mlp_temp_csr;
    FETCH l_get_mlp_temp_csr BULK COLLECT INTO  TemplateIdTbl,
                                                DocNumSchemeTbl,
                                                DocumentNumberTbl,
                                                ArticleEffectiveDateTbl,
                                                ConfigHeaderIdTbl,
                                                ConfigRevisionNumberTbl,
                                                ValidConfigYNTbl,
                                                OrigSystemRefCodeTbl,
                                                OrigSystemRefId1Tbl,
                                                OrigSystemRefId2Tbl,
                                                LockTermsTbl,
                                                LockedByUserIdTbl,
                                                PrimaryTemplateTbl;
    CLOSE l_get_mlp_temp_csr;

    IF TemplateIdTbl.COUNT > 0 THEN
      FORALL i IN TemplateIdTbl.FIRST..TemplateIdTbl.LAST

       INSERT INTO okc_mlp_template_usages(
        DOCUMENT_TYPE,
        DOCUMENT_ID,
        TEMPLATE_ID,
        DOC_NUMBERING_SCHEME,
        DOCUMENT_NUMBER,
        ARTICLE_EFFECTIVE_DATE,
        CONFIG_HEADER_ID,
        CONFIG_REVISION_NUMBER,
        VALID_CONFIG_YN,
        ORIG_SYSTEM_REFERENCE_CODE,
        ORIG_SYSTEM_REFERENCE_ID1,
        ORIG_SYSTEM_REFERENCE_ID2,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        lock_terms_flag,
        locked_by_user_id,
        primary_template	   )
       VALUES (
        p_target_doc_type,
        p_target_doc_id,
        TemplateIdTbl(i),
        DocNumSchemeTbl(i),
        DocumentNumberTbl(i),
        ArticleEffectiveDateTbl(i),
        ConfigHeaderIdTbl(i),
        ConfigRevisionNumberTbl(i),
        ValidConfigYNTbl(i),
        OrigSystemRefCodeTbl(i),
        OrigSystemRefId1Tbl(i),
        OrigSystemRefId2Tbl(i),
        1,
        Fnd_Global.User_Id,
        sysdate,
        Fnd_Global.User_Id,
        Fnd_Global.Login_Id,
        SYSDATE,
        LockTermsTbl(i),
        LockedByUserIdTbl(i),
        PrimaryTemplateTbl(i)
	     );
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600: Leaving copy_usages_row '||x_return_status);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'700: Leaving copy_usages_row:FND_API.G_EXC_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving copy_usages_row:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving copy_usages_row because of EXCEPTION: '||sqlerrm);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END copy_usages_row;


END OKC_CLM_PKG;

/
