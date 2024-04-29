--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_IMPORT_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_IMPORT_TEMPLATE_PVT" AS
/* $Header: OKCVXTMPLB.pls 120.3.12010000.2 2013/11/05 06:53:26 nbingi ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_RUN_ID                     NUMBER;
  G_ORGANIZATION_NAME          VARCHAR2(240);

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_IMPORT_TEMPLATE_PVT';
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
  G_TEMPLATE_MODEL_OSR            CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODEL:';
  G_TEMPLATE_MODEL_TOPNODE_OSR    CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODELTOPNODE:' ;
  G_TEMPLATE_MODEL_FEATURE_OSR    CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODELFEATURE:' ;
  G_TEMPLATE_MODEL_OPTION_OSR     CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODELOPTION:' ;
  G_TMPL_MODEL_CM_REF_NODE_OSR    CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEMODEL-CLAUSEMODEL-REFNODE:' ;
  G_CLAUSE_MODEL_TOPNODE_OSR      CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODELTOPNODE:' ;
  G_TEMPLATE_FOLDER_OSR           CONSTANT VARCHAR2(255) := 'OKC:TEMPLATEFOLDER:';


---------------------------------------------------
--  PRIVATE Procedures and Functions
---------------------------------------------------

---------------------------------------------------
--  Forward Declaration Procedure: create_template_options
---------------------------------------------------
PROCEDURE create_template_options
(
 p_question_id          IN    NUMBER,
 p_value_set_id         IN    NUMBER,
 p_derived_template_id  IN    NUMBER,
 p_intent               IN    VARCHAR2,
 p_org_id        	IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) ;

/*====================================================================+
  Procedure Name : create_template_model
  Description    : This is a private API that creates the Template Model
                   Each template has a corresponding Model in CZ
  Parameters:
                   p_model_id - If model exists then refresh the model
                   p_template_name - Name of the template
                   p_template_id - Id of the template
                   p_intent - Intent of the template
                   p_org_id - Org Id of the template

+====================================================================*/

PROCEDURE create_template_model
(
 p_model_id             IN    NUMBER,
 p_template_name        IN    VARCHAR2,
 p_template_id          IN    NUMBER,
 p_intent               IN    VARCHAR2,
 p_org_id               IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

l_cz_imp_devl_project_rec CZ_IMP_DEVL_PROJECT%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'create_template_model';


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;



   -- populate the l_cz_imp_devl_project_rec
  l_cz_imp_devl_project_rec.DEVL_PROJECT_ID:= NULL;
  l_cz_imp_devl_project_rec.INTL_TEXT_ID:=  NULL;
  l_cz_imp_devl_project_rec.ORGANIZATION_ID:= p_org_id;
  l_cz_imp_devl_project_rec.NAME:= G_TEMPLATE_MODEL_OSR||
                                                       p_org_id||':'||
                                                       p_intent||':'||
                                                       p_template_id;
  l_cz_imp_devl_project_rec.GSL_FILENAME:= NULL;
  l_cz_imp_devl_project_rec.TOP_ITEM_ID:= 1;
  l_cz_imp_devl_project_rec.VERSION:= NULL;
  l_cz_imp_devl_project_rec.EXPLOSION_TYPE:= NULL;
  l_cz_imp_devl_project_rec.DESC_TEXT:= p_template_name;
  l_cz_imp_devl_project_rec.ORIG_SYS_REF:= G_TEMPLATE_MODEL_OSR||
                                                       p_org_id||':'||
                                                       p_intent||':'||
                                                       p_template_id;
  l_cz_imp_devl_project_rec.CREATION_DATE:= SYSDATE;
  l_cz_imp_devl_project_rec.LAST_UPDATE_DATE:= SYSDATE;
  l_cz_imp_devl_project_rec.DELETED_FLAG:= '0'; -- '0' Not deleted
  l_cz_imp_devl_project_rec.EFF_FROM:= NULL;
  l_cz_imp_devl_project_rec.EFF_TO:= NULL;
  l_cz_imp_devl_project_rec.CREATED_BY:= FND_GLOBAL.USER_ID;
  l_cz_imp_devl_project_rec.LAST_UPDATED_BY:= FND_GLOBAL.USER_ID;
  l_cz_imp_devl_project_rec.SECURITY_MASK:= NULL;
  l_cz_imp_devl_project_rec.EFF_MASK:= NULL;
  l_cz_imp_devl_project_rec.CHECKOUT_USER:= NULL;
  l_cz_imp_devl_project_rec.RUN_ID:= G_RUN_ID;
  l_cz_imp_devl_project_rec.REC_STATUS:= NULL;
  l_cz_imp_devl_project_rec.DISPOSITION:= NULL;
  l_cz_imp_devl_project_rec.FSK_INTLTEXT_1_1:= NULL;
  l_cz_imp_devl_project_rec.MODEL_ID:=  p_model_id;
  l_cz_imp_devl_project_rec.PLAN_LEVEL:= 0;
  l_cz_imp_devl_project_rec.PERSISTENT_PROJECT_ID:= NULL;
  l_cz_imp_devl_project_rec.MODEL_TYPE:= 'C'; -- non BOM Model
  l_cz_imp_devl_project_rec.INVENTORY_ITEM_ID:= NULL;
  l_cz_imp_devl_project_rec.PRODUCT_KEY:= G_TEMPLATE_MODEL_OSR||
                                                       p_org_id||':'||
                                                       p_intent||':'||
                                                       p_template_id;
  l_cz_imp_devl_project_rec.LAST_UPDATE_LOGIN:= FND_GLOBAL.LOGIN_ID;
  l_cz_imp_devl_project_rec.BOM_CAPTION_RULE_ID:= NULL;
  l_cz_imp_devl_project_rec.NONBOM_CAPTION_RULE_ID:= OKC_XPRT_CZ_INT_PVT.G_CAPTION_RULE_DESC; -- display desc in runtime UIs
  l_cz_imp_devl_project_rec.SEEDED_FLAG:= '1';   -- '0' unseeded , '1' seeded

  --

   -- insert the Variable Model Record into cz_devl_project
  INSERT INTO cz_imp_devl_project
  (
   DEVL_PROJECT_ID,
   INTL_TEXT_ID,
   ORGANIZATION_ID,
   NAME,
   GSL_FILENAME,
   TOP_ITEM_ID,
   VERSION,
   EXPLOSION_TYPE,
   DESC_TEXT,
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
   RUN_ID,
   REC_STATUS,
   DISPOSITION,
   FSK_INTLTEXT_1_1,
   MODEL_ID,
   PLAN_LEVEL,
   PERSISTENT_PROJECT_ID,
   MODEL_TYPE,
   INVENTORY_ITEM_ID,
   PRODUCT_KEY,
   LAST_UPDATE_LOGIN,
   BOM_CAPTION_RULE_ID,
   NONBOM_CAPTION_RULE_ID,
   SEEDED_FLAG
  )
  VALUES
  (
  l_cz_imp_devl_project_rec.DEVL_PROJECT_ID,
  l_cz_imp_devl_project_rec.INTL_TEXT_ID,
  l_cz_imp_devl_project_rec.ORGANIZATION_ID,
  l_cz_imp_devl_project_rec.NAME,
  l_cz_imp_devl_project_rec.GSL_FILENAME,
  l_cz_imp_devl_project_rec.TOP_ITEM_ID,
  l_cz_imp_devl_project_rec.VERSION,
  l_cz_imp_devl_project_rec.EXPLOSION_TYPE,
  l_cz_imp_devl_project_rec.DESC_TEXT,
  l_cz_imp_devl_project_rec.ORIG_SYS_REF,
  l_cz_imp_devl_project_rec.CREATION_DATE,
  l_cz_imp_devl_project_rec.LAST_UPDATE_DATE,
  l_cz_imp_devl_project_rec.DELETED_FLAG,
  l_cz_imp_devl_project_rec.EFF_FROM,
  l_cz_imp_devl_project_rec.EFF_TO,
  l_cz_imp_devl_project_rec.CREATED_BY,
  l_cz_imp_devl_project_rec.LAST_UPDATED_BY,
  l_cz_imp_devl_project_rec.SECURITY_MASK,
  l_cz_imp_devl_project_rec.EFF_MASK,
  l_cz_imp_devl_project_rec.CHECKOUT_USER,
  l_cz_imp_devl_project_rec.RUN_ID,
  l_cz_imp_devl_project_rec.REC_STATUS,
  l_cz_imp_devl_project_rec.DISPOSITION,
  l_cz_imp_devl_project_rec.FSK_INTLTEXT_1_1,
  l_cz_imp_devl_project_rec.MODEL_ID,
  l_cz_imp_devl_project_rec.PLAN_LEVEL,
  l_cz_imp_devl_project_rec.PERSISTENT_PROJECT_ID,
  l_cz_imp_devl_project_rec.MODEL_TYPE,
  l_cz_imp_devl_project_rec.INVENTORY_ITEM_ID,
  l_cz_imp_devl_project_rec.PRODUCT_KEY,
  l_cz_imp_devl_project_rec.LAST_UPDATE_LOGIN,
  l_cz_imp_devl_project_rec.BOM_CAPTION_RULE_ID,
  l_cz_imp_devl_project_rec.NONBOM_CAPTION_RULE_ID,
  l_cz_imp_devl_project_rec.SEEDED_FLAG
  );


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
                    '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END create_template_model;

/*====================================================================+
  Procedure Name : create_template_component
  Description    : This is a private API that creates the dummy template model
                   component
  Parameters:
                   p_template_name - Name of the template
                   p_template_id - Id of the template
                   p_intent - Intent of the template
                   p_org_id - Org Id of the template


+====================================================================*/

PROCEDURE create_template_component
(
 p_template_name        IN    VARCHAR2,
 p_template_id          IN    NUMBER,
 p_intent               IN    VARCHAR2,
 p_org_id               IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS


CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_language                  FND_LANGUAGES.LANGUAGE_CODE%TYPE;

l_cz_imp_ps_nodes_rec     CZ_IMP_PS_NODES%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'create_template_component';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Put the Name in the description Column of cz_ps_nodes

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
            p_template_name,  --LOCALIZED_STR
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
            G_TEMPLATE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent||':'||p_template_id, --ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_TEMPLATE_MODEL_OSR||p_org_id||':'||p_intent||':'||p_template_id, --FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );

      END LOOP; -- for all installed languages
     CLOSE csr_installed_languages;


  -- Populate the cz_imp_ps_nodes record

  l_cz_imp_ps_nodes_rec.PS_NODE_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.DEVL_PROJECT_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.FROM_POPULATOR_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.PROPERTY_BACKPTR:=  NULL;
  l_cz_imp_ps_nodes_rec.ITEM_TYPE_BACKPTR:=  NULL;
  l_cz_imp_ps_nodes_rec.INTL_TEXT_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.SUB_CONS_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.ORGANIZATION_ID:=  p_org_id;
  l_cz_imp_ps_nodes_rec.ITEM_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE:=  NULL;
  l_cz_imp_ps_nodes_rec.NAME:=  G_TEMPLATE_MODEL_TOPNODE_OSR||
                                                            p_org_id||':'||
                                                            p_intent||':'||
                                                            p_template_id;
  l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=  G_TEMPLATE_MODEL_TOPNODE_OSR||
                                                            p_org_id||':'||
                                                            p_intent||':'||
                                                            p_template_id;
  l_cz_imp_ps_nodes_rec.RESOURCE_FLAG:=  NULL;
  l_cz_imp_ps_nodes_rec.TOP_ITEM_ID:=  1; -- same value as in cz_imp_devl_projects
  l_cz_imp_ps_nodes_rec.INITIAL_VALUE:=  NULL;
  l_cz_imp_ps_nodes_rec.PARENT_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.MINIMUM:=  1;
  l_cz_imp_ps_nodes_rec.MAXIMUM:=  1;
  l_cz_imp_ps_nodes_rec.PS_NODE_TYPE:=  259; -- Component
  l_cz_imp_ps_nodes_rec.FEATURE_TYPE:=  NULL;
  l_cz_imp_ps_nodes_rec.PRODUCT_FLAG:=  '0';
  l_cz_imp_ps_nodes_rec.REFERENCE_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG:=  NULL;
  l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG:=   NULL;
  l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG:=  NULL;
  l_cz_imp_ps_nodes_rec.TREE_SEQ:=  1;
  l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG:=  '0';
  l_cz_imp_ps_nodes_rec.UI_OMIT:=  '0'; -- Display in UI
  l_cz_imp_ps_nodes_rec.UI_SECTION:=  0;
  l_cz_imp_ps_nodes_rec.BOM_TREATMENT:=  NULL;
  l_cz_imp_ps_nodes_rec.RUN_ID:=  G_RUN_ID;
  l_cz_imp_ps_nodes_rec.REC_STATUS:=  NULL;
  l_cz_imp_ps_nodes_rec.DISPOSITION:=  NULL;
  l_cz_imp_ps_nodes_rec.DELETED_FLAG :=  0;
  l_cz_imp_ps_nodes_rec.EFF_FROM:=  NULL;
  l_cz_imp_ps_nodes_rec.EFF_TO:=  NULL;
  l_cz_imp_ps_nodes_rec.EFF_MASK:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_STR01:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_STR02:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_STR03:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_STR04:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_NUM01:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_NUM02:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_NUM03:=  NULL;
  l_cz_imp_ps_nodes_rec.USER_NUM04:=  NULL;
  l_cz_imp_ps_nodes_rec.CHECKOUT_USER:=  NULL;
  l_cz_imp_ps_nodes_rec.CREATION_DATE:=  SYSDATE;
  l_cz_imp_ps_nodes_rec.LAST_UPDATE_DATE:=  SYSDATE;
  l_cz_imp_ps_nodes_rec.CREATED_BY:=  FND_GLOBAL.USER_ID;
  l_cz_imp_ps_nodes_rec.LAST_UPDATED_BY:=  FND_GLOBAL.USER_ID;
  l_cz_imp_ps_nodes_rec.SECURITY_MASK:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=  G_TEMPLATE_MODEL_TOPNODE_OSR||
                                                            p_org_id||':'||
                                                            p_intent||':'||
                                                            p_template_id;
  l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:= G_TEMPLATE_MODEL_OSR||
                                                          p_org_id||':'||
                                                          p_intent||':'||
                                                          p_template_id;
  l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_EXT:=  NULL;
  l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.COMPONENT_CODE:=  NULL;
  l_cz_imp_ps_nodes_rec.PLAN_LEVEL:=  0; --Plan Level for Component:0
  l_cz_imp_ps_nodes_rec.BOM_ITEM_TYPE:=  NULL;
  l_cz_imp_ps_nodes_rec.SO_ITEM_TYPE_CODE:=  NULL;
  l_cz_imp_ps_nodes_rec.MINIMUM_SELECTED:=  NULL;
  l_cz_imp_ps_nodes_rec.MAXIMUM_SELECTED:=  NULL;
  l_cz_imp_ps_nodes_rec.BOM_REQUIRED:=  NULL;
  l_cz_imp_ps_nodes_rec.MUTUALLY_EXCLUSIVE_OPTIONS:=  NULL;
  l_cz_imp_ps_nodes_rec.OPTIONAL:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_EXPLNODE_1_1:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1:=  NULL;
  l_cz_imp_ps_nodes_rec.EFFECTIVE_FROM:=  OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
  l_cz_imp_ps_nodes_rec.EFFECTIVE_UNTIL:= OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;
  l_cz_imp_ps_nodes_rec.EFFECTIVE_USAGE_MASK:=  NULL;
  l_cz_imp_ps_nodes_rec.EFFECTIVITY_SET_ID:=  NULL;
  l_cz_imp_ps_nodes_rec.FSK_EFFSET_7_1:=  NULL;
  l_cz_imp_ps_nodes_rec.DECIMAL_QTY_FLAG:=  0; -- 0 for all nodes
  l_cz_imp_ps_nodes_rec.QUOTEABLE_FLAG:=  NULL;
  l_cz_imp_ps_nodes_rec.PRIMARY_UOM_CODE:=  NULL;
  l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_PATH:=  NULL; -- Must be NULL
  l_cz_imp_ps_nodes_rec.BOM_SORT_ORDER:=  NULL;
  l_cz_imp_ps_nodes_rec.IB_TRACKABLE:=  NULL;
  l_cz_imp_ps_nodes_rec.LAST_UPDATE_LOGIN:=  FND_GLOBAL.LOGIN_ID;
  l_cz_imp_ps_nodes_rec.INITIAL_NUM_VALUE:=  NULL;
  l_cz_imp_ps_nodes_rec.SRC_APPLICATION_ID:=  G_APPLICATION_ID;
  l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_2:=  NULL;
  l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG:=  NULL;
  l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG:=  NULL;

    -- insert top node for Clause Model into cz_imp_ps_nodes

  INSERT INTO cz_imp_ps_nodes
  (
  PS_NODE_ID,
  DEVL_PROJECT_ID,
  FROM_POPULATOR_ID,
  PROPERTY_BACKPTR,
  ITEM_TYPE_BACKPTR,
  INTL_TEXT_ID,
  SUB_CONS_ID,
  ORGANIZATION_ID,
  ITEM_ID,
  EXPLOSION_TYPE,
  NAME,
  ORIG_SYS_REF,
  RESOURCE_FLAG,
  TOP_ITEM_ID,
  INITIAL_VALUE,
  PARENT_ID,
  MINIMUM,
  MAXIMUM,
  PS_NODE_TYPE,
  FEATURE_TYPE,
  PRODUCT_FLAG,
  REFERENCE_ID,
  MULTI_CONFIG_FLAG,
  ORDER_SEQ_FLAG,
  SYSTEM_NODE_FLAG,
  TREE_SEQ,
  COUNTED_OPTIONS_FLAG,
  UI_OMIT,
  UI_SECTION,
  BOM_TREATMENT,
  RUN_ID,
  REC_STATUS,
  DISPOSITION,
  DELETED_FLAG ,
  EFF_FROM,
  EFF_TO,
  EFF_MASK,
  USER_STR01,
  USER_STR02,
  USER_STR03,
  USER_STR04,
  USER_NUM01,
  USER_NUM02,
  USER_NUM03,
  USER_NUM04,
  CHECKOUT_USER,
  CREATION_DATE,
  LAST_UPDATE_DATE,
  CREATED_BY,
  LAST_UPDATED_BY,
  SECURITY_MASK,
  FSK_INTLTEXT_1_1,
  FSK_INTLTEXT_1_EXT,
  FSK_ITEMMASTER_2_1,
  FSK_ITEMMASTER_2_EXT,
  FSK_PSNODE_3_1,
  FSK_PSNODE_3_EXT,
  FSK_PSNODE_4_1,
  FSK_PSNODE_4_EXT,
  FSK_DEVLPROJECT_5_1,
  FSK_DEVLPROJECT_5_EXT,
  COMPONENT_SEQUENCE_ID,
  COMPONENT_CODE,
  PLAN_LEVEL,
  BOM_ITEM_TYPE,
  SO_ITEM_TYPE_CODE,
  MINIMUM_SELECTED,
  MAXIMUM_SELECTED,
  BOM_REQUIRED,
  MUTUALLY_EXCLUSIVE_OPTIONS,
  OPTIONAL,
  FSK_EXPLNODE_1_1,
  FSK_PSNODE_6_1,
  EFFECTIVE_FROM,
  EFFECTIVE_UNTIL,
  EFFECTIVE_USAGE_MASK,
  EFFECTIVITY_SET_ID,
  FSK_EFFSET_7_1,
  DECIMAL_QTY_FLAG,
  QUOTEABLE_FLAG,
  PRIMARY_UOM_CODE,
  COMPONENT_SEQUENCE_PATH,
  BOM_SORT_ORDER,
  IB_TRACKABLE,
  LAST_UPDATE_LOGIN,
  INITIAL_NUM_VALUE,
  SRC_APPLICATION_ID,
  FSK_ITEMMASTER_2_2,
  INSTANTIABLE_FLAG,
  DISPLAY_IN_SUMMARY_FLAG
  )
  VALUES
  (
  l_cz_imp_ps_nodes_rec.PS_NODE_ID,
  l_cz_imp_ps_nodes_rec.DEVL_PROJECT_ID,
  l_cz_imp_ps_nodes_rec.FROM_POPULATOR_ID,
  l_cz_imp_ps_nodes_rec.PROPERTY_BACKPTR,
  l_cz_imp_ps_nodes_rec.ITEM_TYPE_BACKPTR,
  l_cz_imp_ps_nodes_rec.INTL_TEXT_ID,
  l_cz_imp_ps_nodes_rec.SUB_CONS_ID,
  l_cz_imp_ps_nodes_rec.ORGANIZATION_ID,
  l_cz_imp_ps_nodes_rec.ITEM_ID,
  l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE,
  l_cz_imp_ps_nodes_rec.NAME,
  l_cz_imp_ps_nodes_rec.ORIG_SYS_REF,
  l_cz_imp_ps_nodes_rec.RESOURCE_FLAG,
  l_cz_imp_ps_nodes_rec.TOP_ITEM_ID,
  l_cz_imp_ps_nodes_rec.INITIAL_VALUE,
  l_cz_imp_ps_nodes_rec.PARENT_ID,
  l_cz_imp_ps_nodes_rec.MINIMUM,
  l_cz_imp_ps_nodes_rec.MAXIMUM,
  l_cz_imp_ps_nodes_rec.PS_NODE_TYPE,
  l_cz_imp_ps_nodes_rec.FEATURE_TYPE,
  l_cz_imp_ps_nodes_rec.PRODUCT_FLAG,
  l_cz_imp_ps_nodes_rec.REFERENCE_ID,
  l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG,
  l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG,
  l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG,
  l_cz_imp_ps_nodes_rec.TREE_SEQ,
  l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG,
  l_cz_imp_ps_nodes_rec.UI_OMIT,
  l_cz_imp_ps_nodes_rec.UI_SECTION,
  l_cz_imp_ps_nodes_rec.BOM_TREATMENT,
  l_cz_imp_ps_nodes_rec.RUN_ID,
  l_cz_imp_ps_nodes_rec.REC_STATUS,
  l_cz_imp_ps_nodes_rec.DISPOSITION,
  l_cz_imp_ps_nodes_rec.DELETED_FLAG ,
  l_cz_imp_ps_nodes_rec.EFF_FROM,
  l_cz_imp_ps_nodes_rec.EFF_TO,
  l_cz_imp_ps_nodes_rec.EFF_MASK,
  l_cz_imp_ps_nodes_rec.USER_STR01,
  l_cz_imp_ps_nodes_rec.USER_STR02,
  l_cz_imp_ps_nodes_rec.USER_STR03,
  l_cz_imp_ps_nodes_rec.USER_STR04,
  l_cz_imp_ps_nodes_rec.USER_NUM01,
  l_cz_imp_ps_nodes_rec.USER_NUM02,
  l_cz_imp_ps_nodes_rec.USER_NUM03,
  l_cz_imp_ps_nodes_rec.USER_NUM04,
  l_cz_imp_ps_nodes_rec.CHECKOUT_USER,
  l_cz_imp_ps_nodes_rec.CREATION_DATE,
  l_cz_imp_ps_nodes_rec.LAST_UPDATE_DATE,
  l_cz_imp_ps_nodes_rec.CREATED_BY,
  l_cz_imp_ps_nodes_rec.LAST_UPDATED_BY,
  l_cz_imp_ps_nodes_rec.SECURITY_MASK,
  l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1,
  l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT,
  l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1,
  l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT,
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1,
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT,
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1,
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT,
  l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1,
  l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_EXT,
  l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_ID,
  l_cz_imp_ps_nodes_rec.COMPONENT_CODE,
  l_cz_imp_ps_nodes_rec.PLAN_LEVEL,
  l_cz_imp_ps_nodes_rec.BOM_ITEM_TYPE,
  l_cz_imp_ps_nodes_rec.SO_ITEM_TYPE_CODE,
  l_cz_imp_ps_nodes_rec.MINIMUM_SELECTED,
  l_cz_imp_ps_nodes_rec.MAXIMUM_SELECTED,
  l_cz_imp_ps_nodes_rec.BOM_REQUIRED,
  l_cz_imp_ps_nodes_rec.MUTUALLY_EXCLUSIVE_OPTIONS,
  l_cz_imp_ps_nodes_rec.OPTIONAL,
  l_cz_imp_ps_nodes_rec.FSK_EXPLNODE_1_1,
  l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1,
  l_cz_imp_ps_nodes_rec.EFFECTIVE_FROM,
  l_cz_imp_ps_nodes_rec.EFFECTIVE_UNTIL,
  l_cz_imp_ps_nodes_rec.EFFECTIVE_USAGE_MASK,
  l_cz_imp_ps_nodes_rec.EFFECTIVITY_SET_ID,
  l_cz_imp_ps_nodes_rec.FSK_EFFSET_7_1,
  l_cz_imp_ps_nodes_rec.DECIMAL_QTY_FLAG,
  l_cz_imp_ps_nodes_rec.QUOTEABLE_FLAG,
  l_cz_imp_ps_nodes_rec.PRIMARY_UOM_CODE,
  l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_PATH,
  l_cz_imp_ps_nodes_rec.BOM_SORT_ORDER,
  l_cz_imp_ps_nodes_rec.IB_TRACKABLE,
  l_cz_imp_ps_nodes_rec.LAST_UPDATE_LOGIN,
  l_cz_imp_ps_nodes_rec.INITIAL_NUM_VALUE,
  l_cz_imp_ps_nodes_rec.SRC_APPLICATION_ID,
  l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_2,
  l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG,
  l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG
  );


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
                    '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END  create_template_component;

/*====================================================================+
  Procedure Name : create_template_feature
  Description    : This is a private API that creates the template model
                   feature.
			    All Questions on the template will be created as features
    Following features will be created
    Questions with datatype L or B will be created as Option features
    All the possible values for the value set will be created as options
    Questions with datatype N will be created as decimal features
    No options will be created for decimal features
    We cannot support Boolean feature for the following reasons:
    If a boolean feature is on RHS i.e outcome then making the Boolean feature
    as false also changes the LHS i.e conditions to be false.
    We don't want any changes to LHS.
    For the same reason we cannot go with the Requires rules

    All CONSTANTS used in the template rules will be created as Decimal Features
    Create the Constants as Decimal Features under the Variable Model


  Parameters:
                   p_template_name - Name of the template
                   p_derived_template_id - In case of revision template this is the
			                            parent template id, else it is template_id
                   p_template_id - Id of the template
                   p_intent - Intent of the template
                   p_org_id - Org Id of the template


+====================================================================*/
PROCEDURE create_template_feature
(
 p_template_id          IN    VARCHAR2,
 p_derived_template_id  IN    VARCHAR2,
 p_intent               IN    VARCHAR2,
 p_org_id               IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

l_cz_imp_ps_nodes_rec     CZ_IMP_PS_NODES%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'create_template_feature';
l_model_feature_name      VARCHAR2(255);
l_question_id             okc_xprt_questions_b.question_id%TYPE;
l_sequence_num            okc_xprt_question_orders.sequence_num%TYPE;
l_value_set_name          okc_xprt_questions_b.value_set_name%TYPE;
l_feature_type            NUMBER;
l_feature_min_val         NUMBER;
l_feature_max_val         NUMBER;

TYPE TmplQstIdList IS TABLE OF okc_xprt_questions_tl.question_id%TYPE INDEX BY BINARY_INTEGER;
TYPE TmplQstNameList IS TABLE OF okc_xprt_questions_tl.prompt%TYPE INDEX BY BINARY_INTEGER;
TYPE LanguageList IS TABLE OF okc_xprt_questions_tl.language%TYPE INDEX BY BINARY_INTEGER;
TYPE SourceLangList IS TABLE OF okc_xprt_questions_tl.source_lang%TYPE INDEX BY BINARY_INTEGER;

TmplQstId_tbl              TmplQstIdList;
TmplQstName_tbl            TmplQstNameList;
language_tbl               LanguageList;
sourceLang_tbl             SourceLangList;

CURSOR csr_translated_qst IS
SELECT q.question_id,
       DECODE(q.prompt,NULL,q.question_name,q.prompt),
       q.language,
       q.source_lang
FROM  okc_xprt_questions_tl q,
      okc_xprt_question_orders o
WHERE q.question_id = o.question_id
  AND o.question_rule_status IN ('ACTIVE','PENDINGPUB')
  AND o.template_id = p_template_id;

/*
   Feature Type:
   If Question datatype is 'N' then Decimal Feature
   Elsif Question datatype is 'B' then Boolean Feature
   Else Option Feature

   Minimum:
   For Option Feature, setting minimum as '1' makes the Option feature Mandatory
   For Numeric Feature setting minimum value validates the user input to be atleast the
   minimum value. This also makes the numeric feature as mandatory
   For Boolean Feature , minimum column is not applicable

   Currently we are supporing dependent questions of type LOV or Boolean(created as LOV)
   OKC content template has a seeded display rule which only displays features if 'Selected'
   is TRUE. Features with minimum as 0, will not be initially display in UI
   CZ does not have any API or mechanism to hide Numeric or Boolean features using seeded
   display rule.

   If feature type is Option feature (LOV or Boolean) then
      If Question Can be Ordered(independent) then
         minimum = 1
      Else
          -- Question Cannot be Ordered (dependent)
          minimum = 0
   Else
       -- Question datatype is Numeric
       minimum = NULL
   End If;

   Maximum:
   If feature type is Option feature then
         maximim = 1
   Else
       -- Question datatype is Numeric
       maximim = NULL
   End If;


*/
CURSOR csr_question_dtls IS
SELECT o.question_id,
       o.sequence_num,
       DECODE(q.question_datatype,'N',NULL,
                DECODE(NVL(o.mandatory_flag,'N'),'Y',1,0)), -- For LOV or Boolean create 1/1 or 0/1
       DECODE(q.question_datatype,'N',NULL,1), --For Decimal Feature, create MAX as NULL
       q.value_set_name,
       DECODE(q.question_datatype,'N',2,
                                      0) --FEATURE_TYPE 2:Decimal 0:option
FROM okc_xprt_questions_b q,
     okc_xprt_question_orders o
WHERE q.question_id = o.question_id
  AND o.question_rule_status IN ('ACTIVE','PENDINGPUB')
  AND o.template_id = p_template_id
ORDER BY sequence_num;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Insert into cz_imp_localized_text
    OPEN csr_translated_qst;
      FETCH csr_translated_qst BULK COLLECT INTO TmplQstId_tbl,
                                                  TmplQstName_tbl,
                                                  language_tbl,
                                                  sourceLang_tbl;
    CLOSE  csr_translated_qst;


  IF TmplQstName_tbl.COUNT > 0 THEN

    FORALL i IN TmplQstName_tbl.FIRST..TmplQstName_tbl.LAST

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
            TmplQstName_tbl(i),  --LOCALIZED_STR
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
            language_tbl(i),  --LANGUAGE
            G_TEMPLATE_MODEL_FEATURE_OSR||p_org_id||':'||
                                          p_intent||':'||
                                     p_derived_template_id||':'||
                                     TmplQstId_tbl(i),  -- ORIG_SYS_REF
            sourceLang_tbl(i),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_TEMPLATE_MODEL_OSR||p_org_id||':'||
                                  p_intent||':'||
                                 p_derived_template_id, -- FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );

   END IF ; --TmplQstName_tbl.COUNT > 0


  -- insert into cz_ps_nodes
  OPEN csr_question_dtls;
   LOOP
    -- initialize
    l_question_id := NULL;
    l_sequence_num := NULL;
    l_feature_min_val := NULL;
    l_feature_max_val := NULL;
    l_value_set_name := NULL;
    l_feature_type := NULL;

    FETCH csr_question_dtls INTO l_question_id,
                                 l_sequence_num,
                                 l_feature_min_val,
                                 l_feature_max_val,
                                 l_value_set_name,
                                 l_feature_type;
    EXIT WHEN csr_question_dtls%NOTFOUND;


        -- Populate the cz_imp_ps_nodes record

      l_cz_imp_ps_nodes_rec.PS_NODE_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.DEVL_PROJECT_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.FROM_POPULATOR_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.PROPERTY_BACKPTR:=  NULL;
      l_cz_imp_ps_nodes_rec.ITEM_TYPE_BACKPTR:=  NULL;
      l_cz_imp_ps_nodes_rec.INTL_TEXT_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.SUB_CONS_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.ORGANIZATION_ID:=  p_org_id;
      l_cz_imp_ps_nodes_rec.ITEM_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE:=  NULL;
      l_cz_imp_ps_nodes_rec.NAME:=  l_question_id;
      l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=   G_TEMPLATE_MODEL_FEATURE_OSR||
                                                            p_org_id||':'||
                                                            p_intent||':'||
                                                       p_derived_template_id||':'||
                                                       l_question_id;
      l_cz_imp_ps_nodes_rec.RESOURCE_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.TOP_ITEM_ID:=  1; -- same value as in cz_imp_devl_projects
      l_cz_imp_ps_nodes_rec.INITIAL_VALUE:=  NULL;
      l_cz_imp_ps_nodes_rec.PARENT_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.MINIMUM:= l_feature_min_val ; --0 for dependent and 1 for mandatory Questions
      l_cz_imp_ps_nodes_rec.MAXIMUM:= l_feature_max_val ;
      l_cz_imp_ps_nodes_rec.PS_NODE_TYPE:=  261; -- feature
      l_cz_imp_ps_nodes_rec.FEATURE_TYPE:=  l_feature_type;
      l_cz_imp_ps_nodes_rec.PRODUCT_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.REFERENCE_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.TREE_SEQ:=  l_sequence_num+1; -- As Questions must follow the top ref node
      l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG:= '0';
      l_cz_imp_ps_nodes_rec.UI_OMIT:=  '0';
      l_cz_imp_ps_nodes_rec.UI_SECTION:=  0;
      l_cz_imp_ps_nodes_rec.BOM_TREATMENT:=  NULL;
      l_cz_imp_ps_nodes_rec.RUN_ID:=  G_RUN_ID;
      l_cz_imp_ps_nodes_rec.REC_STATUS:=  NULL;
      l_cz_imp_ps_nodes_rec.DISPOSITION:=  NULL;
      l_cz_imp_ps_nodes_rec.DELETED_FLAG :=  0;
      l_cz_imp_ps_nodes_rec.EFF_FROM:=  NULL;
      l_cz_imp_ps_nodes_rec.EFF_TO:=  NULL;
      l_cz_imp_ps_nodes_rec.EFF_MASK:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_STR01:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_STR02:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_STR03:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_STR04:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_NUM01:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_NUM02:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_NUM03:=  NULL;
      l_cz_imp_ps_nodes_rec.USER_NUM04:=  NULL;
      l_cz_imp_ps_nodes_rec.CHECKOUT_USER:=  NULL;
      l_cz_imp_ps_nodes_rec.CREATION_DATE:=  SYSDATE;
      l_cz_imp_ps_nodes_rec.LAST_UPDATE_DATE:=  SYSDATE;
      l_cz_imp_ps_nodes_rec.CREATED_BY:=  FND_GLOBAL.USER_ID;
      l_cz_imp_ps_nodes_rec.LAST_UPDATED_BY:=  FND_GLOBAL.USER_ID;
      l_cz_imp_ps_nodes_rec.SECURITY_MASK:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=  G_TEMPLATE_MODEL_FEATURE_OSR||
                                              p_org_id||':'||
                                              p_intent||':'||
                                         p_derived_template_id||':'||
                                          l_question_id;
      l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  G_TEMPLATE_MODEL_TOPNODE_OSR||
                                                          p_org_id||':'||
                                                          p_intent||':'||
                                                          p_derived_template_id;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:=  G_TEMPLATE_MODEL_OSR||
                                                     p_org_id||':'||
                                                     p_intent||':'||
                                                     p_derived_template_id;
      l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.COMPONENT_CODE:=  NULL;
      l_cz_imp_ps_nodes_rec.PLAN_LEVEL:=  1; --Plan Level for feature:1
      l_cz_imp_ps_nodes_rec.BOM_ITEM_TYPE:=  NULL;
      l_cz_imp_ps_nodes_rec.SO_ITEM_TYPE_CODE:=  NULL;
      l_cz_imp_ps_nodes_rec.MINIMUM_SELECTED:=  NULL;
      l_cz_imp_ps_nodes_rec.MAXIMUM_SELECTED:=  NULL;
      l_cz_imp_ps_nodes_rec.BOM_REQUIRED:=  NULL;
      l_cz_imp_ps_nodes_rec.MUTUALLY_EXCLUSIVE_OPTIONS:=  NULL;
      l_cz_imp_ps_nodes_rec.OPTIONAL:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_EXPLNODE_1_1:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1:=  NULL;
      l_cz_imp_ps_nodes_rec.EFFECTIVE_FROM:=  OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
      l_cz_imp_ps_nodes_rec.EFFECTIVE_UNTIL:= OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;
      l_cz_imp_ps_nodes_rec.EFFECTIVE_USAGE_MASK:=  NULL;
      l_cz_imp_ps_nodes_rec.EFFECTIVITY_SET_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_EFFSET_7_1:=  NULL;
      l_cz_imp_ps_nodes_rec.DECIMAL_QTY_FLAG:=  0; -- 0 for all nodes
      l_cz_imp_ps_nodes_rec.QUOTEABLE_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.PRIMARY_UOM_CODE:=  NULL;
      l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_PATH:=  NULL; -- Must be NULL
      l_cz_imp_ps_nodes_rec.BOM_SORT_ORDER:=  NULL;
      l_cz_imp_ps_nodes_rec.IB_TRACKABLE:=  NULL;
      l_cz_imp_ps_nodes_rec.LAST_UPDATE_LOGIN:=  FND_GLOBAL.LOGIN_ID;
      l_cz_imp_ps_nodes_rec.INITIAL_NUM_VALUE:=  NULL;
      l_cz_imp_ps_nodes_rec.SRC_APPLICATION_ID:=  G_APPLICATION_ID;
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_2:=  NULL;
      l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG:=  NULL;

        -- insert features for Template Model into cz_imp_ps_nodes

      INSERT INTO cz_imp_ps_nodes
      (
      PS_NODE_ID,
      DEVL_PROJECT_ID,
      FROM_POPULATOR_ID,
      PROPERTY_BACKPTR,
      ITEM_TYPE_BACKPTR,
      INTL_TEXT_ID,
      SUB_CONS_ID,
      ORGANIZATION_ID,
      ITEM_ID,
      EXPLOSION_TYPE,
      NAME,
      ORIG_SYS_REF,
      RESOURCE_FLAG,
      TOP_ITEM_ID,
      INITIAL_VALUE,
      PARENT_ID,
      MINIMUM,
      MAXIMUM,
      PS_NODE_TYPE,
      FEATURE_TYPE,
      PRODUCT_FLAG,
      REFERENCE_ID,
      MULTI_CONFIG_FLAG,
      ORDER_SEQ_FLAG,
      SYSTEM_NODE_FLAG,
      TREE_SEQ,
      COUNTED_OPTIONS_FLAG,
      UI_OMIT,
      UI_SECTION,
      BOM_TREATMENT,
      RUN_ID,
      REC_STATUS,
      DISPOSITION,
      DELETED_FLAG ,
      EFF_FROM,
      EFF_TO,
      EFF_MASK,
      USER_STR01,
      USER_STR02,
      USER_STR03,
      USER_STR04,
      USER_NUM01,
      USER_NUM02,
      USER_NUM03,
      USER_NUM04,
      CHECKOUT_USER,
      CREATION_DATE,
      LAST_UPDATE_DATE,
      CREATED_BY,
      LAST_UPDATED_BY,
      SECURITY_MASK,
      FSK_INTLTEXT_1_1,
      FSK_INTLTEXT_1_EXT,
      FSK_ITEMMASTER_2_1,
      FSK_ITEMMASTER_2_EXT,
      FSK_PSNODE_3_1,
      FSK_PSNODE_3_EXT,
      FSK_PSNODE_4_1,
      FSK_PSNODE_4_EXT,
      FSK_DEVLPROJECT_5_1,
      FSK_DEVLPROJECT_5_EXT,
      COMPONENT_SEQUENCE_ID,
      COMPONENT_CODE,
      PLAN_LEVEL,
      BOM_ITEM_TYPE,
      SO_ITEM_TYPE_CODE,
      MINIMUM_SELECTED,
      MAXIMUM_SELECTED,
      BOM_REQUIRED,
      MUTUALLY_EXCLUSIVE_OPTIONS,
      OPTIONAL,
      FSK_EXPLNODE_1_1,
      FSK_PSNODE_6_1,
      EFFECTIVE_FROM,
      EFFECTIVE_UNTIL,
      EFFECTIVE_USAGE_MASK,
      EFFECTIVITY_SET_ID,
      FSK_EFFSET_7_1,
      DECIMAL_QTY_FLAG,
      QUOTEABLE_FLAG,
      PRIMARY_UOM_CODE,
      COMPONENT_SEQUENCE_PATH,
      BOM_SORT_ORDER,
      IB_TRACKABLE,
      LAST_UPDATE_LOGIN,
      INITIAL_NUM_VALUE,
      SRC_APPLICATION_ID,
      FSK_ITEMMASTER_2_2,
      INSTANTIABLE_FLAG,
      DISPLAY_IN_SUMMARY_FLAG
      )
      VALUES
      (
      l_cz_imp_ps_nodes_rec.PS_NODE_ID,
      l_cz_imp_ps_nodes_rec.DEVL_PROJECT_ID,
      l_cz_imp_ps_nodes_rec.FROM_POPULATOR_ID,
      l_cz_imp_ps_nodes_rec.PROPERTY_BACKPTR,
      l_cz_imp_ps_nodes_rec.ITEM_TYPE_BACKPTR,
      l_cz_imp_ps_nodes_rec.INTL_TEXT_ID,
      l_cz_imp_ps_nodes_rec.SUB_CONS_ID,
      l_cz_imp_ps_nodes_rec.ORGANIZATION_ID,
      l_cz_imp_ps_nodes_rec.ITEM_ID,
      l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE,
      l_cz_imp_ps_nodes_rec.NAME,
      l_cz_imp_ps_nodes_rec.ORIG_SYS_REF,
      l_cz_imp_ps_nodes_rec.RESOURCE_FLAG,
      l_cz_imp_ps_nodes_rec.TOP_ITEM_ID,
      l_cz_imp_ps_nodes_rec.INITIAL_VALUE,
      l_cz_imp_ps_nodes_rec.PARENT_ID,
      l_cz_imp_ps_nodes_rec.MINIMUM,
      l_cz_imp_ps_nodes_rec.MAXIMUM,
      l_cz_imp_ps_nodes_rec.PS_NODE_TYPE,
      l_cz_imp_ps_nodes_rec.FEATURE_TYPE,
      l_cz_imp_ps_nodes_rec.PRODUCT_FLAG,
      l_cz_imp_ps_nodes_rec.REFERENCE_ID,
      l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG,
      l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG,
      l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG,
      l_cz_imp_ps_nodes_rec.TREE_SEQ,
      l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG,
      l_cz_imp_ps_nodes_rec.UI_OMIT,
      l_cz_imp_ps_nodes_rec.UI_SECTION,
      l_cz_imp_ps_nodes_rec.BOM_TREATMENT,
      l_cz_imp_ps_nodes_rec.RUN_ID,
      l_cz_imp_ps_nodes_rec.REC_STATUS,
      l_cz_imp_ps_nodes_rec.DISPOSITION,
      l_cz_imp_ps_nodes_rec.DELETED_FLAG ,
      l_cz_imp_ps_nodes_rec.EFF_FROM,
      l_cz_imp_ps_nodes_rec.EFF_TO,
      l_cz_imp_ps_nodes_rec.EFF_MASK,
      l_cz_imp_ps_nodes_rec.USER_STR01,
      l_cz_imp_ps_nodes_rec.USER_STR02,
      l_cz_imp_ps_nodes_rec.USER_STR03,
      l_cz_imp_ps_nodes_rec.USER_STR04,
      l_cz_imp_ps_nodes_rec.USER_NUM01,
      l_cz_imp_ps_nodes_rec.USER_NUM02,
      l_cz_imp_ps_nodes_rec.USER_NUM03,
      l_cz_imp_ps_nodes_rec.USER_NUM04,
      l_cz_imp_ps_nodes_rec.CHECKOUT_USER,
      l_cz_imp_ps_nodes_rec.CREATION_DATE,
      l_cz_imp_ps_nodes_rec.LAST_UPDATE_DATE,
      l_cz_imp_ps_nodes_rec.CREATED_BY,
      l_cz_imp_ps_nodes_rec.LAST_UPDATED_BY,
      l_cz_imp_ps_nodes_rec.SECURITY_MASK,
      l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1,
      l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT,
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1,
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT,
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1,
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT,
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1,
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT,
      l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1,
      l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_EXT,
      l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_ID,
      l_cz_imp_ps_nodes_rec.COMPONENT_CODE,
      l_cz_imp_ps_nodes_rec.PLAN_LEVEL,
      l_cz_imp_ps_nodes_rec.BOM_ITEM_TYPE,
      l_cz_imp_ps_nodes_rec.SO_ITEM_TYPE_CODE,
      l_cz_imp_ps_nodes_rec.MINIMUM_SELECTED,
      l_cz_imp_ps_nodes_rec.MAXIMUM_SELECTED,
      l_cz_imp_ps_nodes_rec.BOM_REQUIRED,
      l_cz_imp_ps_nodes_rec.MUTUALLY_EXCLUSIVE_OPTIONS,
      l_cz_imp_ps_nodes_rec.OPTIONAL,
      l_cz_imp_ps_nodes_rec.FSK_EXPLNODE_1_1,
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1,
      l_cz_imp_ps_nodes_rec.EFFECTIVE_FROM,
      l_cz_imp_ps_nodes_rec.EFFECTIVE_UNTIL,
      l_cz_imp_ps_nodes_rec.EFFECTIVE_USAGE_MASK,
      l_cz_imp_ps_nodes_rec.EFFECTIVITY_SET_ID,
      l_cz_imp_ps_nodes_rec.FSK_EFFSET_7_1,
      l_cz_imp_ps_nodes_rec.DECIMAL_QTY_FLAG,
      l_cz_imp_ps_nodes_rec.QUOTEABLE_FLAG,
      l_cz_imp_ps_nodes_rec.PRIMARY_UOM_CODE,
      l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_PATH,
      l_cz_imp_ps_nodes_rec.BOM_SORT_ORDER,
      l_cz_imp_ps_nodes_rec.IB_TRACKABLE,
      l_cz_imp_ps_nodes_rec.LAST_UPDATE_LOGIN,
      l_cz_imp_ps_nodes_rec.INITIAL_NUM_VALUE,
      l_cz_imp_ps_nodes_rec.SRC_APPLICATION_ID,
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_2,
      l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG,
      l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG
      );

    /*
       All Values for the question features of type Option Features would be created as Options
       below the question
       parameters: p_question_id, p_value_set_id, p_derived_template_id, p_org_id, p_intent
    */
       IF l_feature_type = 0 THEN

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                              G_MODULE||l_api_name,
                              '500: Creating Options For Question Id '||l_question_id);
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                              G_MODULE||l_api_name,
                              '500: Value Set Name '||l_value_set_name);
            END IF;

           create_template_options
           (
	    p_question_id          => l_question_id,
            p_value_set_id         => okc_xprt_util_pvt.get_value_set_id(l_value_set_name),
            p_derived_template_id  => p_derived_template_id,
            p_intent               => p_intent,
            p_org_id        	   => p_org_id,
            x_return_status	   => x_return_status,
            x_msg_data	           => x_msg_data,
            x_msg_count	           => x_msg_count
           );
       END IF; -- create options for non numeric features



  END LOOP; -- created features for all questions
 CLOSE csr_question_dtls;


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
                    '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END  create_template_feature;

/*====================================================================+
  Procedure Name : create_template_options
  Description    : This is a private API that creates the Template Model
                   Options.
			    The list of possible values for the questions are created as
			    options below the question feature
  Parameters:
                   p_question_id - Question Id of the question
			    p_value_set_id - Value set id of the question response
			    p_derived_template_id - Parent template id or template id
			    p_intent - Template Intent
			    p_org_id - Org Id of the template

+====================================================================*/

PROCEDURE create_template_options
(
 p_question_id          IN    NUMBER,
 p_value_set_id         IN    NUMBER,
 p_derived_template_id  IN    NUMBER,
 p_intent               IN    VARCHAR2,
 p_org_id        	IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

-- Check the Value Set Type
-- Support Valuesets of Type Table (F) and Independent (I)
CURSOR csr_value_set_type IS
SELECT validation_type,
	  format_type
FROM fnd_flex_value_sets
WHERE flex_value_set_id = p_value_set_id;

-- Create Dynamic sql for the valueset for Table
CURSOR csr_value_set_tab IS
SELECT  application_table_name,
        value_column_name,
        id_column_name,
        additional_where_clause
FROM fnd_flex_validation_tables
WHERE flex_value_set_id = p_value_set_id;

-- SQL for Valueset type Independent
CURSOR csr_value_set_ind IS
SELECT NVL(description, flex_value_meaning),
       flex_value_id, -- flex_value,
       row_number() over (ORDER BY flex_value)
FROM fnd_flex_values_vl
WHERE flex_value_set_id = p_value_set_id
  AND enabled_flag = 'Y'
  AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active,SYSDATE+1);

-- SQL for Valueset type Independent and format_type number
CURSOR csr_value_set_ind_num IS
SELECT NVL(description, flex_value_meaning),
       flex_value_id, -- flex_value,
       row_number() over (ORDER BY fnd_number.canonical_to_number(flex_value))
FROM fnd_flex_values_vl
WHERE flex_value_set_id = p_value_set_id
  AND enabled_flag = 'Y'
  AND SYSDATE BETWEEN NVL(start_date_active,SYSDATE) AND NVL(end_date_active,SYSDATE+1);

-- Question Name to be displayed in case of error
CURSOR csr_qst_name IS
SELECT question_name
FROM okc_xprt_questions_tl
WHERE question_id = p_question_id
  AND language = USERENV('LANG');

-- get the list of installed languages
-- and create records in cz_imp_localized_texts table

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');


l_api_name                CONSTANT VARCHAR2(30) := 'create_template_options';

TYPE SeqNoList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE NameList IS TABLE OF fnd_flex_validation_tables.value_column_name%TYPE INDEX BY BINARY_INTEGER;
TYPE IdList IS TABLE OF fnd_flex_validation_tables.id_column_name%TYPE INDEX BY BINARY_INTEGER;

i number;
tempSeqNo NUMBER;
tempName fnd_flex_validation_tables.value_column_name%TYPE ;
tempId fnd_flex_validation_tables.id_column_name%TYPE ;

SeqNoList_tbl               SeqNoList;
NameList_tbl                NameList;
IdList_tbl                  IdList;


l_table_name              fnd_flex_validation_tables.application_table_name%TYPE;
l_name_col                fnd_flex_validation_tables.value_column_name%TYPE;
l_id_col                  fnd_flex_validation_tables.id_column_name%TYPE;
l_additional_where_clause fnd_flex_validation_tables.additional_where_clause%TYPE;
l_sql_stmt                LONG;
l_sequence_sql_stmt       LONG;
l_error_message           VARCHAR2(4000);
l_valueset_type           fnd_flex_value_sets.validation_type%TYPE;
l_valueset_format_type    fnd_flex_value_sets.format_type%TYPE;
l_question_name           okc_xprt_questions_tl.question_name%TYPE;
l_language                FND_LANGUAGES.LANGUAGE_CODE%TYPE;

TYPE cur_typ IS REF CURSOR;
c_cursor cur_typ;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Check the Valueset Type
    OPEN csr_value_set_type;
       FETCH csr_value_set_type INTO l_valueset_type, l_valueset_format_type;
    CLOSE csr_value_set_type;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                  G_MODULE||l_api_name,
                  '101: ValueSet Id  : '||p_value_set_id);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                  G_MODULE||l_api_name,
                  '101: Valueset Type : '||l_valueset_type);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                  G_MODULE||l_api_name,
                  '101: Valueset Format Type : '||l_valueset_format_type);
       END IF;


  -- Depending on the ValueSet Type open the cursor
     IF l_valueset_type = 'F' THEN
        -- Valueset is Table

         -- Build the dynamic SQL for the valueset
           OPEN csr_value_set_tab;
             FETCH csr_value_set_tab INTO l_table_name, l_name_col, l_id_col, l_additional_where_clause;
           CLOSE csr_value_set_tab;

           l_sql_stmt :=  'SELECT '||l_name_col||' , '||l_id_col||
                          ' FROM  '||l_table_name||' '||
                          l_additional_where_clause ;

           l_sequence_sql_stmt := 'SELECT rownum FROM ( '||l_sql_stmt||' )' ;

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

         -- Get the values to be imported as Options Under the questions

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
                  -- Get Question Name
                     OPEN csr_qst_name;
                       FETCH csr_qst_name INTO l_question_name;
                     CLOSE csr_qst_name;
                  -- Get the error details
                     FND_MESSAGE.set_name('OKC','OKC_XPRT_QST_VSET_ERROR');
                     FND_MESSAGE.set_token('QUESTION_NAME',l_question_name);
                     FND_MESSAGE.set_token('SQL_ERR',SQLERRM);
                     l_error_message := FND_MESSAGE.get;
                     -- Write to Concurrent Log File
                     fnd_file.put_line(FND_FILE.LOG,l_error_message);
                     -- Write to Debug Log
                      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: Error In Value Set Dynamic Sql for Question : '||l_question_name);
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: Error Message : ' ||l_error_message);
                      END IF;
                     -- Raise Error Exception
                       x_return_status := G_RET_STS_ERROR ;
                       RAISE FND_API.G_EXC_ERROR;
            END; -- Valueset Type F and SQL

            BEGIN
                -- get the sequence numbers for the options
--                 EXECUTE IMMEDIATE l_sequence_sql_stmt
--                    BULK COLLECT INTO SeqNoList_tbl ;

			  i:=0;
			  OPEN c_cursor FOR l_sequence_sql_stmt;
			  LOOP
				 FETCH c_cursor INTO tempSeqNo;
				 EXIT WHEN c_cursor%NOTFOUND;

				 -- process row here
				 SeqNoList_tbl(i) := tempSeqNo;
				 i:=i+1;
			  END LOOP;
			  CLOSE c_cursor;


            EXCEPTION
               WHEN OTHERS THEN
                  -- Get Question Name
                     OPEN csr_qst_name;
                       FETCH csr_qst_name INTO l_question_name;
                     CLOSE csr_qst_name;
                  -- Get the error details
                     FND_MESSAGE.set_name('OKC','OKC_XPRT_QST_VSET_SEQ_ERROR');
                     FND_MESSAGE.set_token('QUESTION_NAME',l_question_name);
                     FND_MESSAGE.set_token('SQL_ERR',SQLERRM);
                     l_error_message := FND_MESSAGE.get;
                     -- Write to Concurrent Log File
                     fnd_file.put_line(FND_FILE.LOG,l_error_message);
                     -- Write to Debug Log
                      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: Error In ValueSet Sql for Question Sequence: '||l_question_name);
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: Error Message : ' ||l_error_message);
                      END IF;
                     -- Raise Error Exception
                       x_return_status := G_RET_STS_ERROR ;
                       RAISE FND_API.G_EXC_ERROR;
            END; -- ValueSet Type F and Sequence

           ELSIF l_valueset_type = 'I' THEN
              -- validation type is Independent
			IF l_valueset_format_type = 'N' THEN
                 OPEN csr_value_set_ind_num;
                   FETCH csr_value_set_ind_num BULK COLLECT INTO NameList_tbl, IdList_tbl, SeqNoList_tbl;
                 CLOSE csr_value_set_ind_num;
			ELSE
                 OPEN csr_value_set_ind;
                   FETCH csr_value_set_ind BULK COLLECT INTO NameList_tbl, IdList_tbl, SeqNoList_tbl;
                 CLOSE csr_value_set_ind;
			END IF;

                 -- Check if the Valueset has atleast 1 value else error
                 IF NameList_tbl.COUNT = 0 THEN
                  -- Get Question Name
                     OPEN csr_qst_name;
                       FETCH csr_qst_name INTO l_question_name;
                     CLOSE csr_qst_name;
                  -- Get the error details
                     FND_MESSAGE.set_name('OKC','OKC_XPRT_QST_VSET_NOVAL');
                     FND_MESSAGE.set_token('QUESTION_NAME',l_question_name);
                     l_error_message := FND_MESSAGE.get;
                     -- Write to Concurrent Log File
                     fnd_file.put_line(FND_FILE.LOG,l_error_message);
                     -- Write to Debug Log
                      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: No Values defined for ValueSet in Question : '||l_question_name);
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: Error Message : ' ||l_error_message);
                      END IF;
                     -- Raise Error Exception
                       x_return_status := G_RET_STS_ERROR ;
                       RAISE FND_API.G_EXC_ERROR;
                 END IF; -- Valueset has no values

           ELSE
              -- Invalid Valueset type

                  -- Get Question Name
                     OPEN csr_qst_name;
                       FETCH csr_qst_name INTO l_question_name;
                     CLOSE csr_qst_name;

                  -- Get the error details
                     FND_MESSAGE.set_name('OKC','OKC_XPRT_QST_VSET_INVALID');
                     FND_MESSAGE.set_token('QUESTION_NAME',l_question_name);
                     l_error_message := FND_MESSAGE.get;
                     -- Write to Concurrent Log File
                     fnd_file.put_line(FND_FILE.LOG,l_error_message);
                     -- Write to Debug Log
                      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: No Values defined for ValueSet in Question : '||l_question_name);
                         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '110: Error Message : ' ||l_error_message);
                      END IF;
                     -- Raise Error Exception
                       x_return_status := G_RET_STS_ERROR ;
                       RAISE FND_API.G_EXC_ERROR;

           END IF; -- Valueset Type



  IF NameList_tbl.COUNT > 0 THEN

    OPEN csr_installed_languages;
      LOOP
        FETCH csr_installed_languages INTO l_language;
        EXIT WHEN csr_installed_languages%NOTFOUND;

        FORALL i IN NameList_tbl.FIRST..NameList_tbl.LAST

          -- Insert into cz_imp_localized_text for each installed language

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
            NameList_tbl(i),  --LOCALIZED_STR
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
            G_TEMPLATE_MODEL_OPTION_OSR||
                               p_org_id||':'||
                               p_intent||':'||
                  p_derived_template_id||':'||
                          p_question_id||':'||
                           IdList_tbl(i), --ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_TEMPLATE_MODEL_OSR||
                        p_org_id||':'||
                        p_intent||':'||
                        p_derived_template_id ,  -- FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );

      END LOOP; -- for all installed languages
     CLOSE csr_installed_languages;


    FORALL i IN NameList_tbl.FIRST..NameList_tbl.LAST

       -- Insert into cz_imp_ps_nodes

       INSERT INTO cz_imp_ps_nodes
       (
       PS_NODE_ID,
       DEVL_PROJECT_ID,
       FROM_POPULATOR_ID,
       PROPERTY_BACKPTR,
       ITEM_TYPE_BACKPTR,
       INTL_TEXT_ID,
       SUB_CONS_ID,
       ORGANIZATION_ID,
       ITEM_ID,
       EXPLOSION_TYPE,
       NAME,
       ORIG_SYS_REF,
       RESOURCE_FLAG,
       TOP_ITEM_ID,
       INITIAL_VALUE,
       PARENT_ID,
       MINIMUM,
       MAXIMUM,
       PS_NODE_TYPE,
       FEATURE_TYPE,
       PRODUCT_FLAG,
       REFERENCE_ID,
       MULTI_CONFIG_FLAG,
       ORDER_SEQ_FLAG,
       SYSTEM_NODE_FLAG,
       TREE_SEQ,
       COUNTED_OPTIONS_FLAG,
       UI_OMIT,
       UI_SECTION,
       BOM_TREATMENT,
       RUN_ID,
       REC_STATUS,
       DISPOSITION,
       DELETED_FLAG ,
       EFF_FROM,
       EFF_TO,
       EFF_MASK,
       USER_STR01,
       USER_STR02,
       USER_STR03,
       USER_STR04,
       USER_NUM01,
       USER_NUM02,
       USER_NUM03,
       USER_NUM04,
       CHECKOUT_USER,
       CREATION_DATE,
       LAST_UPDATE_DATE,
       CREATED_BY,
       LAST_UPDATED_BY,
       SECURITY_MASK,
       FSK_INTLTEXT_1_1,
       FSK_INTLTEXT_1_EXT,
       FSK_ITEMMASTER_2_1,
       FSK_ITEMMASTER_2_EXT,
       FSK_PSNODE_3_1,
       FSK_PSNODE_3_EXT,
       FSK_PSNODE_4_1,
       FSK_PSNODE_4_EXT,
       FSK_DEVLPROJECT_5_1,
       FSK_DEVLPROJECT_5_EXT,
       COMPONENT_SEQUENCE_ID,
       COMPONENT_CODE,
       PLAN_LEVEL,
       BOM_ITEM_TYPE,
       SO_ITEM_TYPE_CODE,
       MINIMUM_SELECTED,
       MAXIMUM_SELECTED,
       BOM_REQUIRED,
       MUTUALLY_EXCLUSIVE_OPTIONS,
       OPTIONAL,
       FSK_EXPLNODE_1_1,
       FSK_PSNODE_6_1,
       EFFECTIVE_FROM,
       EFFECTIVE_UNTIL,
       EFFECTIVE_USAGE_MASK,
       EFFECTIVITY_SET_ID,
       FSK_EFFSET_7_1,
       DECIMAL_QTY_FLAG,
       QUOTEABLE_FLAG,
       PRIMARY_UOM_CODE,
       COMPONENT_SEQUENCE_PATH,
       BOM_SORT_ORDER,
       IB_TRACKABLE,
       LAST_UPDATE_LOGIN,
       INITIAL_NUM_VALUE,
       SRC_APPLICATION_ID,
       FSK_ITEMMASTER_2_2,
       INSTANTIABLE_FLAG,
       DISPLAY_IN_SUMMARY_FLAG
       )
       VALUES
       (
       NULL, --PS_NODE_ID,
       NULL, --DEVL_PROJECT_ID,
       NULL, --FROM_POPULATOR_ID,
       NULL, --PROPERTY_BACKPTR,
       NULL, --ITEM_TYPE_BACKPTR,
       NULL, --INTL_TEXT_ID,
       NULL, --SUB_CONS_ID,
       p_org_id, --ORGANIZATION_ID
       NULL, --ITEM_ID,
       NULL, --EXPLOSION_TYPE,
       IdList_tbl(i), --NAME
       G_TEMPLATE_MODEL_OPTION_OSR||
                          p_org_id||':'||
                          p_intent||':'||
             p_derived_template_id||':'||
                     p_question_id||':'||
                      IdList_tbl(i),  --ORIG_SYS_REF
       NULL, --RESOURCE_FLAG
       1, --TOP_ITEM_ID  --  same value as in cz_imp_devl_projects
       NULL, --INITIAL_VALUE
       NULL, --PARENT_ID
       1, --MINIMUM
       1, --MAXIMUM
       262, --PS_NODE_TYPE  262:Option
       NULL,  --FEATURE_TYPE
       NULL, --PRODUCT_FLAG,
       NULL, --REFERENCE_ID,
       NULL, --MULTI_CONFIG_FLAG,
       NULL, --ORDER_SEQ_FLAG,
       NULL, --SYSTEM_NODE_FLAG
       SeqNoList_tbl(i), --TREE_SEQ
       '0', --COUNTED_OPTIONS_FLAG
       '0', --UI_OMIT
       0, --UI_SECTION
       NULL, --BOM_TREATMENT,
       G_RUN_ID, --RUN_ID
       NULL, --REC_STATUS,
       NULL, --DISPOSITION,
       '0', --DELETED_FLAG
       NULL, --EFF_FROM,
       NULL, --EFF_TO,
       NULL, --EFF_MASK,
       NULL, --USER_STR01,
       NULL, --USER_STR02,
       NULL, --USER_STR03,
       NULL, --USER_STR04,
       NULL, --USER_NUM01,
       NULL, --USER_NUM02,
       NULL, --USER_NUM03,
       NULL, --USER_NUM04,
       NULL, --CHECKOUT_USER,
       SYSDATE, --CREATION_DATE
       SYSDATE, --LAST_UPDATE_DATE
       FND_GLOBAL.USER_ID, --CREATED_BY
       FND_GLOBAL.USER_ID, --LAST_UPDATED_BY
       NULL, --SECURITY_MASK,
       G_TEMPLATE_MODEL_OPTION_OSR||
                          p_org_id||':'||
                          p_intent||':'||
             p_derived_template_id||':'||
                     p_question_id||':'||
                      IdList_tbl(i),  --FSK_INTLTEXT_1_1
       NULL, --FSK_INTLTEXT_1_EXT,
       NULL, --FSK_ITEMMASTER_2_1,
       NULL, --FSK_ITEMMASTER_2_EXT,
       G_TEMPLATE_MODEL_FEATURE_OSR||
                           p_org_id||':'||
                           p_intent||':'||
              p_derived_template_id||':'||
                           p_question_id,  --FSK_PSNODE_3_1
       NULL, --FSK_PSNODE_3_EXT,
       NULL, --FSK_PSNODE_4_1,
       NULL, --FSK_PSNODE_4_EXT,
       G_TEMPLATE_MODEL_OSR||
                        p_org_id||':'||
                        p_intent||':'||
                        p_derived_template_id , --FSK_DEVLPROJECT_5_1
       NULL, --FSK_DEVLPROJECT_5_EXT,
       NULL, --COMPONENT_SEQUENCE_ID,
       NULL, --COMPONENT_CODE,
       2, --PLAN_LEVEL  --Plan Level for Option:2
       NULL, --BOM_ITEM_TYPE,
       NULL, --SO_ITEM_TYPE_CODE,
       NULL, --MINIMUM_SELECTED,
       NULL, --MAXIMUM_SELECTED,
       NULL, --BOM_REQUIRED,
       NULL, --MUTUALLY_EXCLUSIVE_OPTIONS,
       NULL, --OPTIONAL,
       NULL, --FSK_EXPLNODE_1_1,
       NULL, --FSK_PSNODE_6_1,
       OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN, --EFFECTIVE_FROM
       OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END, --EFFECTIVE_UNTIL
       NULL, --EFFECTIVE_USAGE_MASK,
       NULL, --EFFECTIVITY_SET_ID,
       NULL, --FSK_EFFSET_7_1,
       '0', --DECIMAL_QTY_FLAG  -- 0 for all nodes
       NULL, --QUOTEABLE_FLAG
       NULL, --PRIMARY_UOM_CODE,
       NULL, --COMPONENT_SEQUENCE_PATH, -- Must be NULL
       NULL, --BOM_SORT_ORDER,
       NULL, --IB_TRACKABLE,
       FND_GLOBAL.LOGIN_ID, --LAST_UPDATE_LOGIN,
       NULL, --INITIAL_NUM_VALUE,
       G_APPLICATION_ID, --SRC_APPLICATION_ID
       NULL, --FSK_ITEMMASTER_2_2,
       NULL, --INSTANTIABLE_FLAG,
       NULL --DISPLAY_IN_SUMMARY_FLAG
      );

  END IF; -- if row count > 0

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


END create_template_options;

/*====================================================================+
  Procedure Name : create_clause_model_ref
  Description    : This is a private API that creates the reference node
                   of Clause model in the template model
  Parameters:
			    p_template_id - Template Id
                   p_intent - Intent of the variable model
                   p_org_id - Org Id of the template

+====================================================================*/

PROCEDURE create_clause_model_ref
(
 p_template_id          IN    NUMBER,
 p_intent               IN    VARCHAR2,
 p_org_id        	IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS


CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_language                  FND_LANGUAGES.LANGUAGE_CODE%TYPE;

l_cz_imp_ps_nodes_rec     CZ_IMP_PS_NODES%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'create_clause_model_ref';
l_clause_model_name       VARCHAR2(255);

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

 -- Get the Clause Model Name
    FND_MESSAGE.set_name('OKC','OKC_EXPRT_ART_MODEL_TITLE');
    FND_MESSAGE.set_token('ORG_NAME',G_ORGANIZATION_NAME);
    FND_MESSAGE.set_token('INTENT_MEANING',okc_util.decode_lookup('OKC_ARTICLE_INTENT',p_intent));
    l_clause_model_name := FND_MESSAGE.get;


  -- Put the Name in the description Column of cz_ps_nodes

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
            l_clause_model_name,  --LOCALIZED_STR
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
            G_TMPL_MODEL_CM_REF_NODE_OSR|| p_org_id||':'||p_intent||':'||p_template_id, -- ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_TEMPLATE_MODEL_OSR||p_org_id||':'||p_intent||':'||p_template_id, --FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );

      END LOOP; -- for all installed languages
     CLOSE csr_installed_languages;


  -- Populate the cz_imp_ps_nodes record

    l_cz_imp_ps_nodes_rec.PS_NODE_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.DEVL_PROJECT_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.FROM_POPULATOR_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.PROPERTY_BACKPTR:=  NULL;
    l_cz_imp_ps_nodes_rec.ITEM_TYPE_BACKPTR:=  NULL;
    l_cz_imp_ps_nodes_rec.INTL_TEXT_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.SUB_CONS_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.ORGANIZATION_ID:=  p_org_id;
    l_cz_imp_ps_nodes_rec.ITEM_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE:=  NULL;
    l_cz_imp_ps_nodes_rec.NAME:=  G_TMPL_MODEL_CM_REF_NODE_OSR||
                                                              p_org_id||':'||
                                                              p_intent||':'||
                                                              p_template_id;
    l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=  G_TMPL_MODEL_CM_REF_NODE_OSR||
                                                              p_org_id||':'||
                                                              p_intent||':'||
                                                              p_template_id;
    l_cz_imp_ps_nodes_rec.RESOURCE_FLAG:=  NULL;
    l_cz_imp_ps_nodes_rec.TOP_ITEM_ID:=  1; -- same value as in cz_imp_devl_projects
    l_cz_imp_ps_nodes_rec.INITIAL_VALUE:=  NULL;
    l_cz_imp_ps_nodes_rec.PARENT_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.MINIMUM:=  1;
    l_cz_imp_ps_nodes_rec.MAXIMUM:=  1;
    l_cz_imp_ps_nodes_rec.PS_NODE_TYPE:=  263; -- Reference Node
    l_cz_imp_ps_nodes_rec.FEATURE_TYPE:=  0;
    l_cz_imp_ps_nodes_rec.PRODUCT_FLAG:=  '0';  -- check Reference Node
    l_cz_imp_ps_nodes_rec.REFERENCE_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG:=  NULL;
    l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG:=  NULL;
    l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG:=  NULL;
    l_cz_imp_ps_nodes_rec.TREE_SEQ:=  1; -- create node just below Component node
    l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG:=  '0';
    l_cz_imp_ps_nodes_rec.UI_OMIT:=  '1';
    l_cz_imp_ps_nodes_rec.UI_SECTION:=  0;
    l_cz_imp_ps_nodes_rec.BOM_TREATMENT:=  NULL;
    l_cz_imp_ps_nodes_rec.RUN_ID:=  G_RUN_ID;
    l_cz_imp_ps_nodes_rec.REC_STATUS:=  NULL;
    l_cz_imp_ps_nodes_rec.DISPOSITION:=  NULL;
    l_cz_imp_ps_nodes_rec.DELETED_FLAG :=  0;
    l_cz_imp_ps_nodes_rec.EFF_FROM:=  NULL;
    l_cz_imp_ps_nodes_rec.EFF_TO:=  NULL;
    l_cz_imp_ps_nodes_rec.EFF_MASK:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_STR01:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_STR02:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_STR03:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_STR04:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_NUM01:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_NUM02:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_NUM03:=  NULL;
    l_cz_imp_ps_nodes_rec.USER_NUM04:=  NULL;
    l_cz_imp_ps_nodes_rec.CHECKOUT_USER:=  NULL;
    l_cz_imp_ps_nodes_rec.CREATION_DATE:=  SYSDATE;
    l_cz_imp_ps_nodes_rec.LAST_UPDATE_DATE:=  SYSDATE;
    l_cz_imp_ps_nodes_rec.CREATED_BY:=  FND_GLOBAL.USER_ID;
    l_cz_imp_ps_nodes_rec.LAST_UPDATED_BY:=  FND_GLOBAL.USER_ID;
    l_cz_imp_ps_nodes_rec.SECURITY_MASK:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=   G_TMPL_MODEL_CM_REF_NODE_OSR||
                                                              p_org_id||':'||
                                                              p_intent||':'||
                                                              p_template_id;
    l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  G_TEMPLATE_MODEL_TOPNODE_OSR||
                                                              p_org_id||':'||
                                                              p_intent||':'||
                                                              p_template_id;
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:=  G_TEMPLATE_MODEL_OSR||
                                                         p_org_id||':'||
                                                         p_intent||':'||
                                                         p_template_id;
    l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_EXT:=  NULL;
    l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.COMPONENT_CODE:=  NULL;
    l_cz_imp_ps_nodes_rec.PLAN_LEVEL:=  1;
    l_cz_imp_ps_nodes_rec.BOM_ITEM_TYPE:=  NULL;
    l_cz_imp_ps_nodes_rec.SO_ITEM_TYPE_CODE:=  NULL;
    l_cz_imp_ps_nodes_rec.MINIMUM_SELECTED:=  NULL;
    l_cz_imp_ps_nodes_rec.MAXIMUM_SELECTED:=  NULL;
    l_cz_imp_ps_nodes_rec.BOM_REQUIRED:=  NULL;
    l_cz_imp_ps_nodes_rec.MUTUALLY_EXCLUSIVE_OPTIONS:=  NULL;
    l_cz_imp_ps_nodes_rec.OPTIONAL:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_EXPLNODE_1_1:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1:=  G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent;
    l_cz_imp_ps_nodes_rec.EFFECTIVE_FROM:=  OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_BEGIN;
    l_cz_imp_ps_nodes_rec.EFFECTIVE_UNTIL:= OKC_XPRT_CZ_INT_PVT.G_CZ_EPOCH_END;
    l_cz_imp_ps_nodes_rec.EFFECTIVE_USAGE_MASK:=  NULL;
    l_cz_imp_ps_nodes_rec.EFFECTIVITY_SET_ID:=  NULL;
    l_cz_imp_ps_nodes_rec.FSK_EFFSET_7_1:=  NULL;
    l_cz_imp_ps_nodes_rec.DECIMAL_QTY_FLAG:=  0; -- 0 for all nodes
    l_cz_imp_ps_nodes_rec.QUOTEABLE_FLAG:=  NULL;
    l_cz_imp_ps_nodes_rec.PRIMARY_UOM_CODE:=  NULL;
    l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_PATH:=  NULL; -- Must be NULL
    l_cz_imp_ps_nodes_rec.BOM_SORT_ORDER:=  NULL;
    l_cz_imp_ps_nodes_rec.IB_TRACKABLE:=  NULL;
    l_cz_imp_ps_nodes_rec.LAST_UPDATE_LOGIN:=  FND_GLOBAL.LOGIN_ID;
    l_cz_imp_ps_nodes_rec.INITIAL_NUM_VALUE:=  NULL;
    l_cz_imp_ps_nodes_rec.SRC_APPLICATION_ID:=  G_APPLICATION_ID;
    l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_2:=  NULL;
    l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG:=  NULL;
    l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG:=  NULL;


    INSERT INTO cz_imp_ps_nodes
    (
    PS_NODE_ID,
    DEVL_PROJECT_ID,
    FROM_POPULATOR_ID,
    PROPERTY_BACKPTR,
    ITEM_TYPE_BACKPTR,
    INTL_TEXT_ID,
    SUB_CONS_ID,
    ORGANIZATION_ID,
    ITEM_ID,
    EXPLOSION_TYPE,
    NAME,
    ORIG_SYS_REF,
    RESOURCE_FLAG,
    TOP_ITEM_ID,
    INITIAL_VALUE,
    PARENT_ID,
    MINIMUM,
    MAXIMUM,
    PS_NODE_TYPE,
    FEATURE_TYPE,
    PRODUCT_FLAG,
    REFERENCE_ID,
    MULTI_CONFIG_FLAG,
    ORDER_SEQ_FLAG,
    SYSTEM_NODE_FLAG,
    TREE_SEQ,
    COUNTED_OPTIONS_FLAG,
    UI_OMIT,
    UI_SECTION,
    BOM_TREATMENT,
    RUN_ID,
    REC_STATUS,
    DISPOSITION,
    DELETED_FLAG ,
    EFF_FROM,
    EFF_TO,
    EFF_MASK,
    USER_STR01,
    USER_STR02,
    USER_STR03,
    USER_STR04,
    USER_NUM01,
    USER_NUM02,
    USER_NUM03,
    USER_NUM04,
    CHECKOUT_USER,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    SECURITY_MASK,
    FSK_INTLTEXT_1_1,
    FSK_INTLTEXT_1_EXT,
    FSK_ITEMMASTER_2_1,
    FSK_ITEMMASTER_2_EXT,
    FSK_PSNODE_3_1,
    FSK_PSNODE_3_EXT,
    FSK_PSNODE_4_1,
    FSK_PSNODE_4_EXT,
    FSK_DEVLPROJECT_5_1,
    FSK_DEVLPROJECT_5_EXT,
    COMPONENT_SEQUENCE_ID,
    COMPONENT_CODE,
    PLAN_LEVEL,
    BOM_ITEM_TYPE,
    SO_ITEM_TYPE_CODE,
    MINIMUM_SELECTED,
    MAXIMUM_SELECTED,
    BOM_REQUIRED,
    MUTUALLY_EXCLUSIVE_OPTIONS,
    OPTIONAL,
    FSK_EXPLNODE_1_1,
    FSK_PSNODE_6_1,
    EFFECTIVE_FROM,
    EFFECTIVE_UNTIL,
    EFFECTIVE_USAGE_MASK,
    EFFECTIVITY_SET_ID,
    FSK_EFFSET_7_1,
    DECIMAL_QTY_FLAG,
    QUOTEABLE_FLAG,
    PRIMARY_UOM_CODE,
    COMPONENT_SEQUENCE_PATH,
    BOM_SORT_ORDER,
    IB_TRACKABLE,
    LAST_UPDATE_LOGIN,
    INITIAL_NUM_VALUE,
    SRC_APPLICATION_ID,
    FSK_ITEMMASTER_2_2,
    INSTANTIABLE_FLAG,
    DISPLAY_IN_SUMMARY_FLAG
    )
    VALUES
    (
    l_cz_imp_ps_nodes_rec.PS_NODE_ID,
    l_cz_imp_ps_nodes_rec.DEVL_PROJECT_ID,
    l_cz_imp_ps_nodes_rec.FROM_POPULATOR_ID,
    l_cz_imp_ps_nodes_rec.PROPERTY_BACKPTR,
    l_cz_imp_ps_nodes_rec.ITEM_TYPE_BACKPTR,
    l_cz_imp_ps_nodes_rec.INTL_TEXT_ID,
    l_cz_imp_ps_nodes_rec.SUB_CONS_ID,
    l_cz_imp_ps_nodes_rec.ORGANIZATION_ID,
    l_cz_imp_ps_nodes_rec.ITEM_ID,
    l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE,
    l_cz_imp_ps_nodes_rec.NAME,
    l_cz_imp_ps_nodes_rec.ORIG_SYS_REF,
    l_cz_imp_ps_nodes_rec.RESOURCE_FLAG,
    l_cz_imp_ps_nodes_rec.TOP_ITEM_ID,
    l_cz_imp_ps_nodes_rec.INITIAL_VALUE,
    l_cz_imp_ps_nodes_rec.PARENT_ID,
    l_cz_imp_ps_nodes_rec.MINIMUM,
    l_cz_imp_ps_nodes_rec.MAXIMUM,
    l_cz_imp_ps_nodes_rec.PS_NODE_TYPE,
    l_cz_imp_ps_nodes_rec.FEATURE_TYPE,
    l_cz_imp_ps_nodes_rec.PRODUCT_FLAG,
    l_cz_imp_ps_nodes_rec.REFERENCE_ID,
    l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG,
    l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG,
    l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG,
    l_cz_imp_ps_nodes_rec.TREE_SEQ,
    l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG,
    l_cz_imp_ps_nodes_rec.UI_OMIT,
    l_cz_imp_ps_nodes_rec.UI_SECTION,
    l_cz_imp_ps_nodes_rec.BOM_TREATMENT,
    l_cz_imp_ps_nodes_rec.RUN_ID,
    l_cz_imp_ps_nodes_rec.REC_STATUS,
    l_cz_imp_ps_nodes_rec.DISPOSITION,
    l_cz_imp_ps_nodes_rec.DELETED_FLAG ,
    l_cz_imp_ps_nodes_rec.EFF_FROM,
    l_cz_imp_ps_nodes_rec.EFF_TO,
    l_cz_imp_ps_nodes_rec.EFF_MASK,
    l_cz_imp_ps_nodes_rec.USER_STR01,
    l_cz_imp_ps_nodes_rec.USER_STR02,
    l_cz_imp_ps_nodes_rec.USER_STR03,
    l_cz_imp_ps_nodes_rec.USER_STR04,
    l_cz_imp_ps_nodes_rec.USER_NUM01,
    l_cz_imp_ps_nodes_rec.USER_NUM02,
    l_cz_imp_ps_nodes_rec.USER_NUM03,
    l_cz_imp_ps_nodes_rec.USER_NUM04,
    l_cz_imp_ps_nodes_rec.CHECKOUT_USER,
    l_cz_imp_ps_nodes_rec.CREATION_DATE,
    l_cz_imp_ps_nodes_rec.LAST_UPDATE_DATE,
    l_cz_imp_ps_nodes_rec.CREATED_BY,
    l_cz_imp_ps_nodes_rec.LAST_UPDATED_BY,
    l_cz_imp_ps_nodes_rec.SECURITY_MASK,
    l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1,
    l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT,
    l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1,
    l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT,
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1,
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT,
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1,
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT,
    l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1,
    l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_EXT,
    l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_ID,
    l_cz_imp_ps_nodes_rec.COMPONENT_CODE,
    l_cz_imp_ps_nodes_rec.PLAN_LEVEL,
    l_cz_imp_ps_nodes_rec.BOM_ITEM_TYPE,
    l_cz_imp_ps_nodes_rec.SO_ITEM_TYPE_CODE,
    l_cz_imp_ps_nodes_rec.MINIMUM_SELECTED,
    l_cz_imp_ps_nodes_rec.MAXIMUM_SELECTED,
    l_cz_imp_ps_nodes_rec.BOM_REQUIRED,
    l_cz_imp_ps_nodes_rec.MUTUALLY_EXCLUSIVE_OPTIONS,
    l_cz_imp_ps_nodes_rec.OPTIONAL,
    l_cz_imp_ps_nodes_rec.FSK_EXPLNODE_1_1,
    l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1,
    l_cz_imp_ps_nodes_rec.EFFECTIVE_FROM,
    l_cz_imp_ps_nodes_rec.EFFECTIVE_UNTIL,
    l_cz_imp_ps_nodes_rec.EFFECTIVE_USAGE_MASK,
    l_cz_imp_ps_nodes_rec.EFFECTIVITY_SET_ID,
    l_cz_imp_ps_nodes_rec.FSK_EFFSET_7_1,
    l_cz_imp_ps_nodes_rec.DECIMAL_QTY_FLAG,
    l_cz_imp_ps_nodes_rec.QUOTEABLE_FLAG,
    l_cz_imp_ps_nodes_rec.PRIMARY_UOM_CODE,
    l_cz_imp_ps_nodes_rec.COMPONENT_SEQUENCE_PATH,
    l_cz_imp_ps_nodes_rec.BOM_SORT_ORDER,
    l_cz_imp_ps_nodes_rec.IB_TRACKABLE,
    l_cz_imp_ps_nodes_rec.LAST_UPDATE_LOGIN,
    l_cz_imp_ps_nodes_rec.INITIAL_NUM_VALUE,
    l_cz_imp_ps_nodes_rec.SRC_APPLICATION_ID,
    l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_2,
    l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG,
    l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG
    );


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
                    '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END  create_clause_model_ref;



/*
---------------------------------------------------
--  PUBLIC Procedures and Functions
---------------------------------------------------
*/
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
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) IS

CURSOR csr_cz_run_id IS
SELECT cz_xfr_run_infos_s.NEXTVAL
FROM dual;

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

/*
CURSOR csr_template_model_id(p_org_id  IN NUMBER,
                             p_intent  IN VARCHAR2,
                             p_tmpl_id IN NUMBER) IS
					    */
CURSOR csr_template_model_id(p_orig_sys_ref  IN VARCHAR2) IS
SELECT devl_project_id
FROM cz_devl_projects
WHERE orig_sys_ref = p_orig_sys_ref
  AND devl_project_id = persistent_project_id
  AND deleted_flag = 0;

   -- WHERE orig_sys_ref = G_TEMPLATE_MODEL_OSR||p_org_id||':'||p_intent||':'||p_tmpl_id

/*
CURSOR csr_template_folder(p_org_id IN NUMBER,
                           p_intent IN VARCHAR2) IS
					  */
CURSOR csr_template_folder(p_name IN VARCHAR2) IS
SELECT object_id
FROM cz_rp_entries
WHERE enclosing_folder= OKC_XPRT_CZ_INT_PVT.G_TEMPLATE_FOLDER_ID
  AND object_type = 'FLD'
  AND deleted_flag=0
  AND name = p_name;
  -- AND name = G_TEMPLATE_FOLDER_OSR||p_org_id||':'||p_intent;

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
	   SET xprt_request_id = FND_GLOBAL.CONC_REQUEST_ID,
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
		p_mode                     => 'P',
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

   -- build folder name
      l_folder_name := G_TEMPLATE_FOLDER_OSR||l_org_id||':'||l_intent;
   -- Get the Template folder Id
   /*
   OPEN csr_template_folder(p_org_id => l_org_id,
                            p_intent => l_intent);
   */
   OPEN csr_template_folder(p_name => l_folder_name);
     FETCH csr_template_folder INTO l_template_folder_id;
       IF csr_template_folder%NOTFOUND THEN
           -- Create template folder for Org and Intent

           -- Generate Folder Description
            FND_MESSAGE.set_name('OKC','OKC_XPRT_TMPL_FOLDER_DESC');
            FND_MESSAGE.set_token('ORGANIZATION_NAME',G_ORGANIZATION_NAME);
            FND_MESSAGE.set_token('INTENT',okc_util.decode_lookup('OKC_ARTICLE_INTENT',l_intent));
            l_folder_desc := FND_MESSAGE.get;

          -- folder does not exits so create the folder
            OKC_XPRT_CZ_INT_PVT.create_rp_folder(
                 p_api_version        => l_api_version,
                 p_encl_folder_id     => OKC_XPRT_CZ_INT_PVT.G_TEMPLATE_FOLDER_ID,
                 p_new_folder_name    => G_TEMPLATE_FOLDER_OSR||l_org_id||':'||l_intent,
                 p_folder_desc        => l_folder_desc,
                 p_folder_notes       => l_folder_desc,
                 x_new_folder_id      => l_template_folder_id,
                 x_return_status      => x_return_status,
                 x_msg_count          => x_msg_count,
                 x_msg_data           => x_msg_data);

                -- debug log
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '111: After Calling OKC_XPRT_CZ_INT_PVT.create_rp_folder x_return_status : '||x_return_status);
                END IF;

                 --- If any errors happen abort API
                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

       END IF; -- folder does not exists
   CLOSE csr_template_folder;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Template Folder Id: '||l_template_folder_id);
  END IF;


    -- Generate the Run Id
      OPEN csr_cz_run_id;
        FETCH csr_cz_run_id INTO G_RUN_ID;
      CLOSE csr_cz_run_id;

	-- initialize l_template_model_id
	 l_template_model_id := NULL;

	-- build the template OSR
	    l_tmpl_orig_sys_ref := G_TEMPLATE_MODEL_OSR||l_org_id||':'||l_intent||':'||l_template_id;

     -- check if Template Model Already exists in CZ and get the Model Id
	  /*
       OPEN csr_template_model_id(p_org_id  => l_org_id,
                                  p_intent  => l_intent,
                                  p_tmpl_id => l_template_id);
						    */
	  OPEN csr_template_model_id(p_orig_sys_ref => l_tmpl_orig_sys_ref);
         FETCH csr_template_model_id INTO l_template_model_id;
       CLOSE csr_template_model_id;

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Run Id :'||G_RUN_ID);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Template Name: '||l_template_name);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Derived Template Id: '||l_template_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Template Model Id :'||l_template_model_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Intent :'||l_intent);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Organization Name :'||G_ORGANIZATION_NAME);
           END IF;


            create_template_model
            (
             p_model_id           => l_template_model_id,
             p_template_name      => l_template_name,
             p_template_id        => l_template_id,
             p_intent             => l_intent,
             p_org_id             => l_org_id,
             x_return_status	  => x_return_status,
             x_msg_data	          => x_msg_data,
             x_msg_count          => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '200: After Calling create_template_model x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

           create_template_component
            (
             p_template_name      => l_template_name,
             p_template_id        => l_template_id,
             p_intent             => l_intent,
             p_org_id             => l_org_id,
             x_return_status	  => x_return_status,
             x_msg_data	          => x_msg_data,
             x_msg_count          => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '300: After Calling create_template_component x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

            -- Create the Clause Model reference Node
            create_clause_model_ref
            (
             p_template_id        => l_template_id,
             p_intent             => l_intent,
             p_org_id             => l_org_id,
             x_return_status   	  => x_return_status,
             x_msg_data	          => x_msg_data,
             x_msg_count          => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '400: After Calling create_clause_model_ref x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

            -- Questions on templates are created as features
            -- For getting questions, we pass the original template_id and the derived template id
            -- for Revision templates, p_template_id = Working copy template Id and
            -- p_derived_template_id = parent_template_id

            create_template_feature
            (
             p_template_id                => p_template_id, -- get questions using this id
             p_derived_template_id        => l_template_id,
             p_intent                     => l_intent,
             p_org_id                     => l_org_id,
             x_return_status	          => x_return_status,
             x_msg_data	                  => x_msg_data,
             x_msg_count                  => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '400: After Calling create_template_feature x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

           -- Call the CZ Generic Import to push data to CZ
           OKC_XPRT_CZ_INT_PVT.import_generic
           (
            p_api_version      => l_api_version,
            p_run_id           => G_RUN_ID,
            p_rp_folder_id     => l_template_folder_id,
            x_run_id           => l_run_id,
            x_return_status    => l_import_status,
            x_msg_data	       => x_msg_data,
            x_msg_count        => x_msg_count
           );
            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '700: After Calling OKC_XPRT_CZ_INT_PVT.import_generic x_return_status : '||
                 l_import_status);
            END IF;

          -- Log the Import Status and check if any records in the import tables have status not 'OK'
          OKC_XPRT_UTIL_PVT.check_import_status
          (
           p_run_id           => G_RUN_ID,
           p_import_status    => l_import_status,
           p_model_type       => 'T', -- Template Model
           x_return_status    => x_return_status,
           x_msg_data	      => x_msg_data,
           x_msg_count        => x_msg_count
          );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '700: After Calling OKC_XPRT_UTIL_PVT.check_import_status x_return_status : '||
                       x_return_status);
           END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

	      -- initialize l_template_model_id
	        l_template_model_id := NULL;

   	      -- build the template OSR
	        l_tmpl_orig_sys_ref := G_TEMPLATE_MODEL_OSR||l_org_id||':'||l_intent||':'||l_template_id;

		 -- Template Import was successful, update template record with the model_id
		   /*
             OPEN csr_template_model_id(p_org_id  => l_org_id,
                                        p_intent  => l_intent,
                                        p_tmpl_id => l_template_id);
								*/
             OPEN csr_template_model_id(p_orig_sys_ref => l_tmpl_orig_sys_ref);
               FETCH csr_template_model_id INTO l_template_model_id;
             CLOSE csr_template_model_id;

		   UPDATE okc_terms_templates_all
		      SET template_model_id = l_template_model_id
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


/*====================================================================+
  Procedure Name : rebuild_tmpl_pub_disable
  Description    : This is a PUBLIC API that rebuilds template Models
			    This API is called from publish and disable rules concurrent programs
  Parameters:

+====================================================================*/

PROCEDURE rebuild_tmpl_pub_disable
(
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) IS

-- Templates to be rebuilt for Publishing or Disabling Rules
CURSOR csr_local_rules_templates IS
-- Templates on Local Rules
SELECT DISTINCT to_char(r.template_id)
  FROM okc_terms_templates_all t,
       okc_xprt_template_rules r,
       okc_xprt_rule_hdrs_all h
 WHERE r.template_id = t.template_id
   AND r.rule_id = h.rule_id
   AND t.status_code IN ('APPROVED','ON_HOLD')
   AND h.request_id = FND_GLOBAL.CONC_REQUEST_ID
UNION
 -- templates already pushed to CZ
 SELECT DISTINCT SUBSTR(orig_sys_ref, INSTR(orig_sys_ref,':',-1,3)+1,
               (INSTR(orig_sys_ref,':',1,5) - (INSTR(orig_sys_ref,':',1,4)+1))
/*SELECT DISTINCT SUBSTR(cz.orig_sys_ref, INSTR(cz.orig_sys_ref,':',-1,2)+1,
               (INSTR(cz.orig_sys_ref,':',-1,1) - (INSTR(cz.orig_sys_ref,':',-1,2)+1))   */
            )
  FROM cz_rules cz,
       okc_xprt_rule_hdrs_all h
 WHERE SUBSTR(cz.orig_sys_ref,INSTR(cz.orig_sys_ref,':',-1,1)+1) = to_char(h.rule_id)
   AND h.request_id = FND_GLOBAL.CONC_REQUEST_ID
   AND cz.deleted_flag = '0'
   AND cz.rule_type = 200;  --Perf Bug#5030272 Added rule_type = 200

CURSOR csr_org_rules_templates(p_org_id IN NUMBER) IS
-- Org Wide Rule Templates
SELECT t.template_id
  FROM okc_terms_templates_all t
 WHERE  t.org_id = p_org_id
   AND  t.intent IN (
				 SELECT DISTINCT intent
				    FROM okc_xprt_rule_hdrs_all
  				   WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID
                    )
   AND  t.contract_expert_enabled = 'Y'
   AND  t.status_code IN ('APPROVED','ON_HOLD');

-- Cursor to check if any rule is Org Wide
CURSOR csr_org_rule_exists IS
SELECT 'X'
  FROM okc_xprt_rule_hdrs_all
 WHERE  request_id = FND_GLOBAL.CONC_REQUEST_ID
   AND  NVL(org_wide_flag,'N') = 'Y';

-- Get the Rule Org Id
CURSOR csr_rule_org_id IS
SELECT org_id
  FROM okc_xprt_rule_hdrs_all
 WHERE  request_id = FND_GLOBAL.CONC_REQUEST_ID;

l_api_name                 CONSTANT VARCHAR2(30) := 'rebuild_tmpl_pub_disable';
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


END rebuild_tmpl_pub_disable;




/*====================================================================+
  Procedure Name : rebuild_tmpl_sync
  Description    : This is a PUBLIC API that rebuilds template Models
			    This API is called from sync template concurrent programs
  Parameters:
                  p_org_id : Org Id in which templates are to be rebuilt
			   p_intent : Intent of templates to be rebuilt
			   p_template_id : Template Id to be rebuilt. If the template_id is
			    NOT passed, ALL templates for the above Org and Intent are
			    rebuilt
+====================================================================*/

PROCEDURE rebuild_tmpl_sync
(
 p_org_id                   IN  NUMBER,
 p_intent                   IN  VARCHAR2,
 p_template_id              IN  NUMBER DEFAULT NULL,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
) IS

CURSOR csr_templates IS
SELECT t.template_id
  FROM okc_terms_templates_all t
 WHERE  t.org_id = p_org_id
   AND  t.intent = p_intent
   AND  t.template_id = NVL(p_template_id, template_id)
   AND  t.contract_expert_enabled = 'Y'
   AND  t.status_code IN ('APPROVED','ON_HOLD') ;


l_api_name                 CONSTANT VARCHAR2(30) := 'rebuild_tmpl_pub_disable';
l_template_id              okc_terms_templates_all.template_id%TYPE;


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
                    '100: p_org_id  '||p_org_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_intent  '||p_intent);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_template_id  '||p_template_id);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get all the templates to be rebuilt
    OPEN csr_templates;
      LOOP
	   FETCH csr_templates INTO l_template_id;
	   EXIT WHEN csr_templates%NOTFOUND;

    		     import_template
               (
                p_api_version       => 1,
                p_init_msg_list	 => 'T',
                p_commit	           => 'T',
                p_template_id       =>  l_template_id,
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

	 END LOOP;
    CLOSE csr_templates;


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


END rebuild_tmpl_sync;




END OKC_XPRT_IMPORT_TEMPLATE_PVT;

/
