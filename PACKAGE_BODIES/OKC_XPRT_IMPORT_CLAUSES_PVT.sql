--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_IMPORT_CLAUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_IMPORT_CLAUSES_PVT" AS
/* $Header: OKCVXCLAB.pls 120.2 2006/02/17 02:33:48 asingam noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_RUN_ID                     NUMBER;
  G_ORGANIZATION_NAME          VARCHAR2(240);

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_IMPORT_CLAUSES_PVT';
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

  G_CLAUSE_MODEL_OSR              CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODEL:';
  G_CLAUSE_MODEL_TOPNODE_OSR      CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODELTOPNODE:' ;
  G_CLAUSE_MODEL_FEATURE_OSR      CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODELFEATURE:' ;
  G_CLAUSE_MODEL_OPTION_OSR       CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODELOPTION:' ;
  G_CLAUSE_MODEL_VM_REF_NODE_OSR  CONSTANT VARCHAR2(255) := 'OKC:CLAUSEMODEL-VARIABLEMODEL-REFNODE:' ;
  G_VARIABLE_MODEL_TOPNODE_OSR    CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODELTOPNODE:-99:' ;
  G_CLAUSE_FOLDER_OSR             CONSTANT VARCHAR2(255) := 'OKC:CLAUSEFOLDER:';

/*
---------------------------------------------------
--  PRIVATE Procedures and Functions
---------------------------------------------------
*/
/*====================================================================+
  Procedure Name : create_clause_model
  Description    : This is a private API that creates the Clause Model
                   Clause Model is created for Org and Intent
  Parameters:
                   p_intent - Intent of the variable model
                   p_model_id - If model exists then refresh the model
			    p_org_id  - Organization Id of the Clause Model

+====================================================================*/

PROCEDURE create_clause_model
(
 p_intent               IN    VARCHAR2,
 p_model_id             IN    NUMBER,
 p_org_id               IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

l_cz_imp_devl_project_rec CZ_IMP_DEVL_PROJECT%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'create_clause_model';
l_model_desc              CZ_IMP_DEVL_PROJECT.DESC_TEXT%TYPE;

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
    l_model_desc := FND_MESSAGE.get;


        -- populate the l_cz_imp_devl_project_rec
       l_cz_imp_devl_project_rec.DEVL_PROJECT_ID:= NULL;
       l_cz_imp_devl_project_rec.INTL_TEXT_ID:=  NULL;
       l_cz_imp_devl_project_rec.ORGANIZATION_ID:= p_org_id;
       l_cz_imp_devl_project_rec.NAME:= G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent ;
       l_cz_imp_devl_project_rec.GSL_FILENAME:= NULL;
       l_cz_imp_devl_project_rec.TOP_ITEM_ID:= 1;
       l_cz_imp_devl_project_rec.VERSION:= NULL;
       l_cz_imp_devl_project_rec.EXPLOSION_TYPE:= NULL;
       l_cz_imp_devl_project_rec.DESC_TEXT:= l_model_desc;
       l_cz_imp_devl_project_rec.ORIG_SYS_REF:= G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent ;
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
       l_cz_imp_devl_project_rec.PRODUCT_KEY:= NULL;
       l_cz_imp_devl_project_rec.LAST_UPDATE_LOGIN:= FND_GLOBAL.LOGIN_ID;
       l_cz_imp_devl_project_rec.BOM_CAPTION_RULE_ID:= NULL;
       l_cz_imp_devl_project_rec.NONBOM_CAPTION_RULE_ID:= OKC_XPRT_CZ_INT_PVT.G_CAPTION_RULE_DESC; -- display desc in runtime UIs
       l_cz_imp_devl_project_rec.SEEDED_FLAG:= '1';   -- '0' unseeded , '1' seeded

       --

        -- insert the Clause Model Record into cz_devl_project
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


END create_clause_model;

/*====================================================================+
  Procedure Name : create_clause_component
  Description    : This is a private API that creates the dummy Clause Component
  Parameters:
                   p_intent - Intent of the variable model
			    p_org_id  - Organization Id of the Clause Model

+====================================================================*/

PROCEDURE create_clause_component
(
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
l_api_name                CONSTANT VARCHAR2(30) := 'create_clause_component';
l_model_component_name    CZ_IMP_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Get the Clause Model Component Name
    FND_MESSAGE.set_name('OKC','OKC_EXPRT_ART_MODEL_TNOD_TITLE');
    FND_MESSAGE.set_token('ORG_NAME',G_ORGANIZATION_NAME);
    FND_MESSAGE.set_token('INTENT_MEANING',okc_util.decode_lookup('OKC_ARTICLE_INTENT',p_intent));
    l_model_component_name := FND_MESSAGE.get;


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
            l_model_component_name,  --LOCALIZED_STR
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
            G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent, -- ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent, -- FSK_DEVLPROJECT_1_1
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
       l_cz_imp_ps_nodes_rec.NAME:=  G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=  G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent;
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
       l_cz_imp_ps_nodes_rec.UI_OMIT:=  '0'; -- 0 for Root Node
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
       l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=  G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:=  G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent;
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


END  create_clause_component;

/*====================================================================+
  Procedure Name : create_clause_feature
  Description    : This is a private API that creates the dummy Clause feature
  Parameters:
                   p_intent - Intent of the variable model
			    p_org_id  - Organization Id of the Clause Model

+====================================================================*/

PROCEDURE create_clause_feature
(
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
l_api_name                CONSTANT VARCHAR2(30) := 'create_clause_feature';
l_model_feature_name      CZ_IMP_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Get the Clause Model Component Name
    FND_MESSAGE.set_name('OKC','OKC_EXPRT_ART_FEATURE_TITLE');
    FND_MESSAGE.set_token('ORG_NAME',G_ORGANIZATION_NAME);
    FND_MESSAGE.set_token('INTENT_MEANING',okc_util.decode_lookup('OKC_ARTICLE_INTENT',p_intent));
    l_model_feature_name := FND_MESSAGE.get;

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
            l_model_feature_name,  --LOCALIZED_STR
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
            G_CLAUSE_MODEL_FEATURE_OSR||p_org_id||':'||p_intent, -- ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent, -- FSK_DEVLPROJECT_1_1
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
       l_cz_imp_ps_nodes_rec.NAME:= G_CLAUSE_MODEL_FEATURE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=  G_CLAUSE_MODEL_FEATURE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.RESOURCE_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.TOP_ITEM_ID:=  1; -- same value as in cz_imp_devl_projects
       l_cz_imp_ps_nodes_rec.INITIAL_VALUE:=  NULL;
       l_cz_imp_ps_nodes_rec.PARENT_ID:=  NULL;
       l_cz_imp_ps_nodes_rec.MINIMUM:=  0; -- 0 for feature
       l_cz_imp_ps_nodes_rec.MAXIMUM:=  NULL;
       l_cz_imp_ps_nodes_rec.PS_NODE_TYPE:=  261; -- feature
       l_cz_imp_ps_nodes_rec.FEATURE_TYPE:=  0;
       l_cz_imp_ps_nodes_rec.PRODUCT_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.REFERENCE_ID:=  NULL;
       l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.TREE_SEQ:=  1;
       l_cz_imp_ps_nodes_rec.COUNTED_OPTIONS_FLAG:= '0';
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
       l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=  G_CLAUSE_MODEL_FEATURE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:=  G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent;
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


END  create_clause_feature;

/*====================================================================+
  Procedure Name : create_clause_options
  Description    : This is a private API that creates the Clause options
                   All Clauses used in Rules are created as options under the
			    dummy feature
  Parameters:
                   p_intent - Intent of the variable model
			    p_org_id  - Organization Id of the Clause Model

+====================================================================*/

PROCEDURE create_clause_options
(
 p_intent               IN    VARCHAR2,
 p_org_id        	IN	NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

CURSOR csr_clause_options IS
SELECT article_id,
       article_title,
       rownum
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
          AND a.article_id = to_number(v.object_value_code) -- Fix for bug 5030078.Removed to_char and added to_number
          AND c.object_type = 'CLAUSE'
          AND r.org_id = p_org_id
          AND r.intent = p_intent
          AND r.status_code <> 'DRAFT'
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
          AND r.org_id = p_org_id
          AND r.intent = p_intent
          AND r.status_code <> 'DRAFT'
	   GROUP BY o.object_value_id, a.article_title
 ) ;

-- Since the Clause Title will be stored in description column and
-- clause is not translated, get the list of installed languages
-- and create records in cz_imp_localized_texts table

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');


l_api_name                CONSTANT VARCHAR2(30) := 'create_clause_options';

TYPE ClauseIdList IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;
TYPE ClauseTitleList IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;
TYPE SeqNoList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE LanguageList IS TABLE OF VARCHAR2(450) INDEX BY BINARY_INTEGER;

ClauseIdList_tbl            ClauseIdList;
ClauseTitleList_tbl         ClauseTitleList;
SeqNoList_tbl               SeqNoList;
l_language                  FND_LANGUAGES.LANGUAGE_CODE%TYPE;



BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

 -- Get the Clause values to be imported as Options Under the Clause feature
    OPEN csr_clause_options;
      FETCH csr_clause_options BULK COLLECT INTO ClauseIdList_tbl,
                                                 ClauseTitleList_tbl,
                                                 SeqNoList_tbl;
    CLOSE csr_clause_options;


  IF ClauseIdList_tbl.COUNT > 0 THEN

    OPEN csr_installed_languages;
      LOOP
        FETCH csr_installed_languages INTO l_language;
        EXIT WHEN csr_installed_languages%NOTFOUND;

        FORALL i IN ClauseIdList_tbl.FIRST..ClauseIdList_tbl.LAST

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
            ClauseTitleList_tbl(i),  --LOCALIZED_STR
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
            G_CLAUSE_MODEL_OPTION_OSR||p_org_id ||':'||p_intent||':'||ClauseIdList_tbl(i),--ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent , -- FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );

      END LOOP; -- for all installed languages
     CLOSE csr_installed_languages;


    FORALL i IN ClauseIdList_tbl.FIRST..ClauseIdList_tbl.LAST

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
       NULL, --ITEM_ID
       NULL, --EXPLOSION_TYPE,
       ClauseIdList_tbl(i), --NAME
       G_CLAUSE_MODEL_OPTION_OSR||p_org_id ||':'||p_intent||':'||ClauseIdList_tbl(i), --ORIG_SYS_REF
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
       '1', --UI_OMIT
       NULL, --UI_SECTION
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
       G_CLAUSE_MODEL_OPTION_OSR||p_org_id ||':'||p_intent||':'||ClauseIdList_tbl(i),--FSK_INTLTEXT_1_1
       NULL, --FSK_INTLTEXT_1_EXT,
       NULL, --FSK_ITEMMASTER_2_1,
       NULL, --FSK_ITEMMASTER_2_EXT,
       G_CLAUSE_MODEL_FEATURE_OSR||p_org_id||':'||p_intent , --FSK_PSNODE_3_1
       NULL, --FSK_PSNODE_3_EXT,
       NULL, --FSK_PSNODE_4_1,
       NULL, --FSK_PSNODE_4_EXT,
       G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent , --FSK_DEVLPROJECT_5_1
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
       '1' --DISPLAY_IN_SUMMARY_FLAG -- 1: For Clauses to display in Summary UI
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


END create_clause_options;

/*====================================================================+
  Procedure Name : create_variable_model_ref
  Description    : This is a private API that creates the reference node
                   of Variable Model under the Clause Model
  Parameters:
                   p_intent - Intent of the variable model
                   p_model_id - If model exists then refresh the model

+====================================================================*/

PROCEDURE create_variable_model_ref
(
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
l_api_name                CONSTANT VARCHAR2(30) := 'create_variable_model_ref';
l_variable_model_name     CZ_IMP_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Get Variable model name
    FND_MESSAGE.set_name('OKC','OKC_EXPRT_VAR_MODEL_TITLE');
    FND_MESSAGE.set_token('INTENT_MEANING',okc_util.decode_lookup('OKC_ARTICLE_INTENT',p_intent));
    l_variable_model_name := FND_MESSAGE.get;

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
            l_variable_model_name,  --LOCALIZED_STR
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
            G_CLAUSE_MODEL_VM_REF_NODE_OSR||p_org_id||':'||p_intent, -- ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent, -- FSK_DEVLPROJECT_1_1
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
       l_cz_imp_ps_nodes_rec.NAME:= G_CLAUSE_MODEL_VM_REF_NODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=  G_CLAUSE_MODEL_VM_REF_NODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.RESOURCE_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.TOP_ITEM_ID:=  1; -- same value as in cz_imp_devl_projects
       l_cz_imp_ps_nodes_rec.INITIAL_VALUE:=  NULL;
       l_cz_imp_ps_nodes_rec.PARENT_ID:=  NULL;
       l_cz_imp_ps_nodes_rec.MINIMUM:=  1;
       l_cz_imp_ps_nodes_rec.MAXIMUM:=  NULL;
       l_cz_imp_ps_nodes_rec.PS_NODE_TYPE:=  263; -- Reference Node
       l_cz_imp_ps_nodes_rec.FEATURE_TYPE:=  0;
       l_cz_imp_ps_nodes_rec.PRODUCT_FLAG:=  '0';  -- check Reference Node
       l_cz_imp_ps_nodes_rec.REFERENCE_ID:=  NULL;
       l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG:=  NULL;
       l_cz_imp_ps_nodes_rec.TREE_SEQ:=  2;
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
       l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=  G_CLAUSE_MODEL_VM_REF_NODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  G_CLAUSE_MODEL_TOPNODE_OSR||p_org_id||':'||p_intent;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
       l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:=  G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent;
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
       l_cz_imp_ps_nodes_rec.FSK_PSNODE_6_1:=  G_VARIABLE_MODEL_TOPNODE_OSR||p_intent;
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
       l_cz_imp_ps_nodes_rec.INSTANTIABLE_FLAG:=  '4';
       l_cz_imp_ps_nodes_rec.DISPLAY_IN_SUMMARY_FLAG:=  NULL;

         -- insert Variable Model reference into cz_imp_ps_nodes

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


END  create_variable_model_ref;



/*
---------------------------------------------------
--  PUBLIC Procedures and Functions
---------------------------------------------------
*/
/*====================================================================+
  Procedure Name : import_clauses
  Description    : This is a PUBLIC API that imports Clauses used in rules
			    This API is called from publish rules concurrent program
  Parameters:
                   p_org_id - Org Id of the rules to be published

+====================================================================*/

PROCEDURE import_clauses
(
 p_api_version              IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_commit	            IN	VARCHAR2,
 p_org_id        	    IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) IS

CURSOR csr_cz_run_id IS
SELECT cz_xfr_run_infos_s.NEXTVAL
FROM dual;

-- CURSOR csr_clause_model_id(p_intent IN VARCHAR2) IS
CURSOR csr_clause_model_id(p_orig_sys_ref IN VARCHAR2) IS
SELECT devl_project_id
FROM cz_devl_projects
WHERE orig_sys_ref = p_orig_sys_ref
  AND devl_project_id = persistent_project_id
  AND deleted_flag = 0;

-- WHERE orig_sys_ref = G_CLAUSE_MODEL_OSR||p_org_id||':'||p_intent

CURSOR csr_intent IS
SELECT DISTINCT INTENT
FROM okc_xprt_rule_hdrs_all
WHERE org_id = p_org_id
  AND status_code ='PENDINGPUB';

CURSOR csr_org_name IS
SELECT name
FROM   hr_operating_units
WHERE  organization_id = p_org_id;

CURSOR csr_clause_folder(p_folder_name IN VARCHAR2) IS
SELECT object_id
FROM cz_rp_entries
WHERE enclosing_folder= OKC_XPRT_CZ_INT_PVT.G_CLAUSE_FOLDER_ID
  AND object_type = 'FLD'
  AND deleted_flag=0
  AND name = p_folder_name ;
  -- AND name = G_CLAUSE_FOLDER_OSR||p_org_id;

l_intent                   okc_xprt_rule_hdrs_all.intent%TYPE;
l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'import_clauses';
l_clause_model_id          NUMBER :=NULL;
l_run_id                   NUMBER;
l_clause_folder_id         NUMBER :=NULL;
l_folder_desc              VARCHAR2(255);
l_import_status            VARCHAR2(10);
l_orig_sys_ref             cz_devl_projects.orig_sys_ref%TYPE;
l_clause_folder_name       cz_rp_entries.name%TYPE;

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
                    '100: p_org_id '||p_org_id);
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

-- Get the Organization Name
  OPEN csr_org_name;
    FETCH csr_org_name INTO G_ORGANIZATION_NAME;
  CLOSE csr_org_name;

   -- build folder name
   l_clause_folder_name  := G_CLAUSE_FOLDER_OSR||p_org_id;

   -- Get the Clause folder Id
   OPEN csr_clause_folder(p_folder_name => l_clause_folder_name);
     FETCH csr_clause_folder INTO l_clause_folder_id;
       IF csr_clause_folder%NOTFOUND THEN
           -- Create Org  folder

           -- Generate Folder Description
            FND_MESSAGE.set_name('OKC','OKC_EXPRT_ALIB_ORG_FOLDER_TITL');
            FND_MESSAGE.set_token('ORG_NAME',G_ORGANIZATION_NAME);
            l_folder_desc := FND_MESSAGE.get;

          -- folder does not exits so create the folder
            OKC_XPRT_CZ_INT_PVT.create_rp_folder(
                 p_api_version        => l_api_version,
                 p_encl_folder_id     => OKC_XPRT_CZ_INT_PVT.G_CLAUSE_FOLDER_ID,
                 p_new_folder_name    => G_CLAUSE_FOLDER_OSR||p_org_id,
                 p_folder_desc        => l_folder_desc,
                 p_folder_notes       => l_folder_desc,
                 x_new_folder_id      => l_clause_folder_id,
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
   CLOSE csr_clause_folder;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '120: Clause Folder Id: '||l_clause_folder_id);
  END IF;


    /*
    -- Generate the Run Id
      OPEN csr_cz_run_id;
        FETCH csr_cz_run_id INTO G_RUN_ID;
      CLOSE csr_cz_run_id;
   */

OPEN csr_intent;
  LOOP
    FETCH csr_intent INTO l_intent;
    EXIT WHEN csr_intent%NOTFOUND;

	-- Initialize l_clause_model_id
	 l_clause_model_id := NULL;

	-- Build Orig_sys_ref
	  l_orig_sys_ref := G_CLAUSE_MODEL_OSR||p_org_id||':'||l_intent ;

     -- check if Clause Model Already exists in CZ and get the Model Id
       -- OPEN  csr_clause_model_id(p_intent => l_intent);

       OPEN  csr_clause_model_id(p_orig_sys_ref => l_orig_sys_ref);
         FETCH csr_clause_model_id INTO l_clause_model_id;
       CLOSE csr_clause_model_id;

    -- CZ allows ONLY 1 model import for each run_id
    -- Generate the Run Id
      OPEN csr_cz_run_id;
        FETCH csr_cz_run_id INTO G_RUN_ID;
      CLOSE csr_cz_run_id;

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Run Id :'||G_RUN_ID);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Clause Model Id :'||l_clause_model_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Intent :'||l_intent);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Organization Name :'||G_ORGANIZATION_NAME);
           END IF;


            create_clause_model
            (
             p_intent           => l_intent,
             p_model_id         => l_clause_model_id,
             p_org_id           => p_org_id,
             x_return_status	=> x_return_status,
             x_msg_data	        => x_msg_data,
             x_msg_count        => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '200: After Calling create_clause_model x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;


           create_clause_component
            (
             p_intent           => l_intent,
             p_org_id           => p_org_id,
             x_return_status	=> x_return_status,
             x_msg_data	        => x_msg_data,
             x_msg_count        => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '300: After Calling create_clause_component x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

            create_clause_feature
            (
             p_intent           => l_intent,
             p_org_id        	=> p_org_id,
             x_return_status	=> x_return_status,
             x_msg_data	        => x_msg_data,
             x_msg_count        => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '400: After Calling create_clause_feature x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

            create_clause_options
            (
             p_intent           => l_intent,
             p_org_id        	=> p_org_id,
             x_return_status	=> x_return_status,
             x_msg_data	        => x_msg_data,
             x_msg_count        => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '500: After Calling create_clause_options x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

            create_variable_model_ref
            (
             p_intent           => l_intent,
             p_org_id        	=> p_org_id,
             x_return_status	=> x_return_status,
             x_msg_data	        => x_msg_data,
             x_msg_count        => x_msg_count
            );

            -- debug log
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                G_MODULE||l_api_name,
                '600: After Calling create_variable_model_ref x_return_status : '||x_return_status);
            END IF;

             --- If any errors happen abort API
             IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;

--  END LOOP;
--CLOSE csr_intent;

           -- Call the CZ Generic Import to push data to CZ
           OKC_XPRT_CZ_INT_PVT.import_generic
           (
            p_api_version      => l_api_version,
            p_run_id           => G_RUN_ID,
            p_rp_folder_id     => l_clause_folder_id,
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
           p_model_type       => 'C', -- Clause Model
           x_return_status    => x_return_status,
           x_msg_data	      => x_msg_data,
           x_msg_count        => x_msg_count
          );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '750: After Calling OKC_XPRT_UTIL_PVT.check_import_status x_return_status : '||
                       x_return_status);
           END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

  END LOOP;
CLOSE csr_intent;

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


END import_clauses;





END OKC_XPRT_IMPORT_CLAUSES_PVT;

/
