--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_IMPORT_VARIABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_IMPORT_VARIABLES_PVT" AS
/* $Header: OKCVXVARB.pls 120.7 2005/11/23 13:24:13 arsundar noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_RUN_ID                     NUMBER;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_IMPORT_VARIABLES_PVT';
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
  G_VARIABLE_MODEL_TOPNODE_OSR    CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODELTOPNODE:-99:' ;
  G_VARIABLE_MODEL_FEATURE_OSR    CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODELFEATURE:-99:' ;
  G_VARIABLE_MODEL_OPTION_OSR     CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODELOPTION:-99:' ;

  G_VAR_MODEL_TEXT_FEATURE_OSR    CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODELTEXTFEATURE:-99:' ;
  G_VAR_MODEL_DEVI_FEATURE_OSR    CONSTANT VARCHAR2(255) := 'OKC:VARIABLEMODELDEVFEATURE:-99:' ;


/*
---------------------------------------------------
--  PRIVATE Procedures and Functions
---------------------------------------------------
*/
/*====================================================================+
  Procedure Name : create_variable_model
  Description    : This is a private API that creates the Variable Model
                   Variable Model is created for Intent with Org as -99
  Parameters:
                   p_intent - Intent of the variable model
                   p_model_id - If model exists then refresh the model

+====================================================================*/

PROCEDURE create_variable_model
(
 p_intent               IN    VARCHAR2,
 p_model_id             IN    NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS

l_cz_imp_devl_project_rec CZ_IMP_DEVL_PROJECT%ROWTYPE;
l_api_name                CONSTANT VARCHAR2(30) := 'create_variable_model';
l_model_desc              CZ_IMP_DEVL_PROJECT.DESC_TEXT%TYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

 -- Get the Variable Model Name
    FND_MESSAGE.set_name('OKC','OKC_EXPRT_VAR_MODEL_TITLE');
    FND_MESSAGE.set_token('INTENT_MEANING',okc_util.decode_lookup('OKC_ARTICLE_INTENT',p_intent));
    l_model_desc := FND_MESSAGE.get;

 -- populate the l_cz_imp_devl_project_rec
      l_cz_imp_devl_project_rec.DEVL_PROJECT_ID:= NULL;
      l_cz_imp_devl_project_rec.INTL_TEXT_ID:=  NULL;
      l_cz_imp_devl_project_rec.ORGANIZATION_ID:= -99;
      l_cz_imp_devl_project_rec.NAME:= G_VARIABLE_MODEL_OSR||p_intent ;
      l_cz_imp_devl_project_rec.GSL_FILENAME:= NULL;
      l_cz_imp_devl_project_rec.TOP_ITEM_ID:= 1;
      l_cz_imp_devl_project_rec.VERSION:= NULL;
      l_cz_imp_devl_project_rec.EXPLOSION_TYPE:= NULL;
      l_cz_imp_devl_project_rec.DESC_TEXT:= l_model_desc;
      l_cz_imp_devl_project_rec.ORIG_SYS_REF:= G_VARIABLE_MODEL_OSR||p_intent ;
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
      l_cz_imp_devl_project_rec.SEEDED_FLAG:= '1';  -- '0' unseeded , '1' seeded

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


END create_variable_model;

/*====================================================================+
  Procedure Name : create_variable_component
  Description    : This is a private API that creates the Variable Model
                   dummy Component
  Parameters:
                   p_intent - Intent of the variable model

+====================================================================*/

PROCEDURE create_variable_component
(
 p_intent               IN    VARCHAR2,
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
l_api_name                CONSTANT VARCHAR2(30) := 'create_variable_component';
l_model_component_name    CZ_IMP_LOCALIZED_TEXTS.LOCALIZED_STR%TYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

  -- Get the Variable Model Component Name
    FND_MESSAGE.set_name('OKC','OKC_EXPRT_VAR_MODEL_TNOD_TITLE');
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
            G_VARIABLE_MODEL_TOPNODE_OSR||p_intent, -- ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_VARIABLE_MODEL_OSR||p_intent , -- FSK_DEVLPROJECT_1_1
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
      l_cz_imp_ps_nodes_rec.ORGANIZATION_ID:=  -99;
      l_cz_imp_ps_nodes_rec.ITEM_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.EXPLOSION_TYPE:=  NULL;
      l_cz_imp_ps_nodes_rec.NAME:=  G_VARIABLE_MODEL_TOPNODE_OSR||p_intent;
      l_cz_imp_ps_nodes_rec.ORIG_SYS_REF:=  G_VARIABLE_MODEL_TOPNODE_OSR||p_intent;
      l_cz_imp_ps_nodes_rec.RESOURCE_FLAG:=  NULL;
      l_cz_imp_ps_nodes_rec.TOP_ITEM_ID:=   1; -- same value as in cz_imp_devl_projects
      l_cz_imp_ps_nodes_rec.INITIAL_VALUE:=  NULL;
      l_cz_imp_ps_nodes_rec.PARENT_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.MINIMUM:=  1;
      l_cz_imp_ps_nodes_rec.MAXIMUM:=  1;
      l_cz_imp_ps_nodes_rec.PS_NODE_TYPE:=  259; -- Component
      l_cz_imp_ps_nodes_rec.FEATURE_TYPE:=  NULL;
      l_cz_imp_ps_nodes_rec.PRODUCT_FLAG:=  0;  -- 0 for Model and null for others
      l_cz_imp_ps_nodes_rec.REFERENCE_ID:=  NULL;
      l_cz_imp_ps_nodes_rec.MULTI_CONFIG_FLAG:=  NULL ; -- unused
      l_cz_imp_ps_nodes_rec.ORDER_SEQ_FLAG:=  NULL ; -- unused
      l_cz_imp_ps_nodes_rec.SYSTEM_NODE_FLAG:= NULL ; -- unused
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
      l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_1:=  G_VARIABLE_MODEL_TOPNODE_OSR||p_intent;
      l_cz_imp_ps_nodes_rec.FSK_INTLTEXT_1_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_1:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_ITEMMASTER_2_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_1:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_3_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_1:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_PSNODE_4_EXT:=  NULL;
      l_cz_imp_ps_nodes_rec.FSK_DEVLPROJECT_5_1:=  G_VARIABLE_MODEL_OSR ||p_intent;
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

        -- insert top node for Variable Model into cz_imp_ps_nodes

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


END  create_variable_component;


/*====================================================================+
  Procedure Name : create_variable_features
  Description    : This is a private API that creates the Variable Model
                   features.
			    All variables and constants are created as features
  Parameters:
                   p_intent - Intent of the variable model

+====================================================================*/

PROCEDURE create_variable_features
(
 p_intent               IN    VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS


CURSOR csr_variables(p_language IN VARCHAR2) IS
-- Expert Enabled System  Variables
-- Item and Item Categories will be seeded as type 'T' and expert enabled
SELECT distinct DECODE(SUBSTR(rcon.object_code,1,3),'OKC',rcon.object_code,'USER$' || rcon.object_code) variable_code, -- LHS of Condition
   t.variable_name variable_name,
   v.variable_datatype variable_datatype,
   t.LANGUAGE language,
   t.source_lang source_lang
FROM okc_xprt_rule_hdrs_all rhdr,
   okc_xprt_rule_conditions rcon,
   okc_bus_variables_b v,
   okc_bus_variables_tl t
WHERE rhdr.rule_id = rcon.rule_id
AND rhdr.intent = p_intent
AND rcon.object_type = 'VARIABLE'
AND rhdr.status_code NOT IN ('DRAFT','INACTIVE')
AND rcon.object_code = v.variable_code
AND v.variable_code = t.variable_code
AND t.LANGUAGE = USERENV('LANG')
--AND t.language = NVL(p_language,t.language)
UNION
SELECT distinct DECODE(SUBSTR(rcon.object_value_code,1,3),'OKC',rcon.object_value_code,'USER$' || rcon.object_value_code) variable_code, -- RHS of Condition
   t.variable_name variable_name,
   v.variable_datatype variable_datatype,
   t.LANGUAGE language,
   t.source_lang source_lang
FROM okc_xprt_rule_hdrs_all rhdr,
   okc_xprt_rule_conditions rcon,
   okc_bus_variables_b v,
   okc_bus_variables_tl t
WHERE rhdr.rule_id = rcon.rule_id
AND rhdr.intent = p_intent
AND rcon.object_value_type = 'VARIABLE'
AND rhdr.status_code NOT IN ('DRAFT','INACTIVE')
AND rcon.object_code = v.variable_code
AND v.variable_code = t.variable_code
AND t.LANGUAGE = USERENV('LANG')
--AND t.language = NVL(p_language,t.language)
UNION
SELECT distinct 'CONSTANT$' || to_char(q.question_id) variable_code,  -- Query for Constants used
   ql.question_name variable_name,
   q.question_datatype variable_datatype,
   ql.LANGUAGE language,
   ql.source_lang source_lang
FROM okc_xprt_rule_hdrs_all rhdr,
   okc_xprt_rule_conditions rcon,
   okc_xprt_questions_b q,
   okc_xprt_questions_tl ql
WHERE rhdr.rule_id = rcon.rule_id
AND rhdr.intent = p_intent
AND rcon.object_value_type = 'CONSTANT'
AND rhdr.status_code NOT IN ('DRAFT','INACTIVE')
AND rcon.object_value_code = to_char(q.question_id)
AND q.question_id = ql.question_id
AND ql.LANGUAGE = USERENV('LANG')
--AND ql.language = NVL(p_language,ql.language)
UNION
SELECT distinct to_char(rh.rule_id) variable_code, -- Deviation Rule
        rh.rule_name variable_name,
        'DR' variable_datatype, -- Will use this for decoding Deviation Rule to Option Feature
        USERENV('LANG') language,
        USERENV('LANG') source_lang
  FROM okc_xprt_rule_hdrs_all rh
 WHERE rh.rule_type = 'TERM_DEVIATION'
   AND rh.status_code NOT IN ('DRAFT','INACTIVE')
   AND rh.intent = p_intent
UNION
SELECT  'LINE_NUMBER' variable_code, -- Dummy Text feature
        'LINE_NUMBER' variable_name,
        'LN' variable_datatype, -- Will use this for decoding to  Line number to Text Feature
        USERENV('LANG') language,
        USERENV('LANG') source_lang
  FROM  dual;

l_api_name                CONSTANT VARCHAR2(30) := 'create_variable_features';

TYPE VariableCodeList IS TABLE OF cz_imp_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
TYPE VariableNameList IS TABLE OF okc_bus_variables_tl.VARIABLE_NAME%TYPE INDEX BY BINARY_INTEGER;
--TYPE VariableDatatypeList IS TABLE OF okc_bus_variables_b.VARIABLE_DATATYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE VariableDatatypeList IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER; -- changed for R12
TYPE LanguageList IS TABLE OF okc_bus_variables_tl.language%TYPE INDEX BY BINARY_INTEGER;
TYPE SourceLangList IS TABLE OF okc_bus_variables_tl.source_lang%TYPE INDEX BY BINARY_INTEGER;
TYPE SeqNoList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


variableCode_tbl           VariableCodeList;
variableName_tbl           VariableNameList;
variableDatatype_tbl       VariableDatatypeList;
language_tbl               LanguageList;
sourceLang_tbl             SourceLangList;
SeqNoList_tbl              SeqNoList;

CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');

l_language                  FND_LANGUAGES.LANGUAGE_CODE%TYPE;

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

 -- Get the variables to be imported as Features Under the Variable Model
    -- insert ALL installed language records into cz_imp_localized_texts
    OPEN csr_variables(p_language => NULL);
      FETCH csr_variables  BULK COLLECT INTO variableCode_tbl,
                                             variableName_tbl,
                                             variableDatatype_tbl,
                                             language_tbl,
                                             sourceLang_tbl;
    CLOSE  csr_variables;

    FOR i IN 1..variableCode_tbl.COUNT
    LOOP
    	SeqNoList_tbl(i) := i;
    END LOOP;

  IF variableCode_tbl.COUNT > 0 THEN


    OPEN csr_installed_languages;
      LOOP
        FETCH csr_installed_languages INTO l_language;
        EXIT WHEN csr_installed_languages%NOTFOUND;

    FORALL i IN variableCode_tbl.FIRST..variableCode_tbl.LAST
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
            variableName_tbl(i),  --LOCALIZED_STR
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
            l_language,
            --language_tbl(i),  --LANGUAGE
            DECODE(variableDatatype_tbl(i), 'LN', G_VAR_MODEL_TEXT_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), -- ORIG_SYS_REF for Line Number
                                            'DR', G_VAR_MODEL_DEVI_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), -- ORIG_SYS_REF for Deviation Rule
                                             G_VARIABLE_MODEL_FEATURE_OSR||p_intent||':'||variableCode_tbl(i)), -- ORIG_SYS_REF
            --sourceLang_tbl(i),  --SOURCE_LANG
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_VARIABLE_MODEL_OSR||p_intent , -- FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );
      END LOOP; -- for all installed languages
     CLOSE csr_installed_languages;


    -- Insert only the Current language records in cz_imp_ps_nodes
    OPEN csr_variables(p_language => USERENV('LANG'));
      FETCH csr_variables  BULK COLLECT INTO variableCode_tbl,
                                             variableName_tbl,
                                             variableDatatype_tbl,
                                             language_tbl,
                                             sourceLang_tbl;
    CLOSE  csr_variables;

    FORALL i IN variableCode_tbl.FIRST..variableCode_tbl.LAST

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
       -99, --ORGANIZATION_ID
       NULL, --ITEM_ID,
       NULL, --EXPLOSION_TYPE,
       variableCode_tbl(i), --NAME
       --G_VARIABLE_MODEL_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), --ORIG_SYS_REF
       DECODE(variableDatatype_tbl(i), 'LN', G_VAR_MODEL_TEXT_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), -- ORIG_SYS_REF for Line Number
            			       'DR', G_VAR_MODEL_DEVI_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), -- ORIG_SYS_REF for Deviation Rule
       				        G_VARIABLE_MODEL_FEATURE_OSR||p_intent||':'||variableCode_tbl(i)), -- ORIG_SYS_REF
       NULL, --RESOURCE_FLAG
       1, --TOP_ITEM_ID  -- same value as in cz_imp_devl_projects
       NULL, --INITIAL_VALUE
       NULL, --PARENT_ID
       -- 0, --MINIMUM  -- Commented for Bug 4090738
       DECODE(variableDatatype_tbl(i),'N',NULL,0), --MINIMUM -- Added for Bug 4090738
       NULL, --MAXIMUM
       261, --PS_NODE_TYPE  261:Feature
       DECODE(variableDatatype_tbl(i),'LN',4,'N',2,0), -- FEATURE_TYPE 2:Decimal and 0:option and 4: Text feature
       --DECODE(variableDatatype_tbl(i),'N',2,0), --FEATURE_TYPE 2:Decimal and 0:option
       NULL, --PRODUCT_FLAG,
       NULL, --REFERENCE_ID,
       NULL, --MULTI_CONFIG_FLAG,
       NULL, --ORDER_SEQ_FLAG,
       NULL, --SYSTEM_NODE_FLAG
       SeqNoList_tbl(i), --TREE_SEQ
       '0', --COUNTED_OPTIONS_FLAG
       '1', --UI_OMIT
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
       --G_VARIABLE_MODEL_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), --FSK_INTLTEXT_1_1
       DECODE(variableDatatype_tbl(i), 'LN', G_VAR_MODEL_TEXT_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), -- FSK_INTLTEXT_1_1 for Line Number
				   'DR', G_VAR_MODEL_DEVI_FEATURE_OSR||p_intent||':'||variableCode_tbl(i), -- FSK_INTLTEXT_1_1 for Deviation Rule
				    G_VARIABLE_MODEL_FEATURE_OSR||p_intent||':'||variableCode_tbl(i)), -- FSK_INTLTEXT_1_1
       NULL, --FSK_INTLTEXT_1_EXT,
       NULL, --FSK_ITEMMASTER_2_1,
       NULL, --FSK_ITEMMASTER_2_EXT,
       G_VARIABLE_MODEL_TOPNODE_OSR||p_intent, --FSK_PSNODE_3_1
       NULL, --FSK_PSNODE_3_EXT,
       NULL, --FSK_PSNODE_4_1,
       NULL, --FSK_PSNODE_4_EXT,
       G_VARIABLE_MODEL_OSR||p_intent, --FSK_DEVLPROJECT_5_1
       NULL, --FSK_DEVLPROJECT_5_EXT,
       NULL, --COMPONENT_SEQUENCE_ID,
       NULL, --COMPONENT_CODE,
       1, --PLAN_LEVEL  -- Plan Level for Feature:1
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


END create_variable_features;


/*====================================================================+
  Procedure Name : create_variable_options
  Description    : This is a private API that creates the Variable Model
                   options.
			    All variable values used in rules are created as options under
			    the variable feature
  Parameters:
                   p_intent - Intent of the variable model

+====================================================================*/

PROCEDURE create_variable_options
(
 p_intent               IN    VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) IS


CURSOR csr_installed_languages IS
SELECT L.LANGUAGE_CODE
  FROM FND_LANGUAGES L
WHERE L.INSTALLED_FLAG IN ('I', 'B');


CURSOR csr_variable_options IS
      -- send only distinct variable code values

      SELECT DISTINCT DECODE(SUBSTR(c.object_code,1,3),'OKC',c.object_code,'USER$' || c.object_code) variable_code,
              v.object_value_code variable_value,
		      okc_xprt_util_pvt.get_value_display(v.rule_condition_id,v.object_value_code) variable_value_desc
      FROM okc_xprt_rule_cond_vals v,
           okc_xprt_rule_conditions c,
           okc_xprt_rule_hdrs_all r
      WHERE v.rule_condition_id = c.rule_condition_id
        AND c.rule_id = r.rule_id
        AND c.object_type = 'VARIABLE'
        AND c.object_value_type = 'VALUE'
        AND r.intent = p_intent
        AND r.status_code NOT IN ('DRAFT','INACTIVE'); -- Added inactive status for bug 4758803

l_api_name                CONSTANT VARCHAR2(30) := 'create_variable_options';
l_language                FND_LANGUAGES.LANGUAGE_CODE%TYPE;

TYPE VariableCodeList IS TABLE OF okc_xprt_rule_conditions.object_code%TYPE INDEX BY BINARY_INTEGER;
TYPE VariableOptionList IS TABLE OF okc_xprt_rule_conditions.object_value_code%TYPE INDEX BY BINARY_INTEGER;
TYPE VariableOptionDesc IS TABLE OF cz_imp_localized_texts.localized_str%TYPE INDEX BY BINARY_INTEGER;
TYPE SeqNoList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

variableCode_tbl           VariableCodeList;
variableOption_tbl         VariableOptionList;
variableOptionDesc_tbl     VariableOptionDesc;
SeqNoList_tbl              SeqNoList;


BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  x_return_status :=  G_RET_STS_SUCCESS;

 -- Get the variable values to be imported as Options Under the Variables
    OPEN csr_variable_options;
      FETCH csr_variable_options BULK COLLECT INTO variableCode_tbl,
                                                   variableOption_tbl,
                                                   variableOptionDesc_tbl;
    CLOSE csr_variable_options;

    FOR i IN 1..variableCode_tbl.COUNT
    LOOP
    	SeqNoList_tbl(i) := i;
    END LOOP;

 IF variableCode_tbl.COUNT > 0 THEN

 -- For all installed languages variable_value_desc put the  in the description Column of cz_ps_nodes
    OPEN csr_installed_languages;
      LOOP
        FETCH csr_installed_languages INTO l_language;
        EXIT WHEN csr_installed_languages%NOTFOUND;

	   FORALL i IN variableOptionDesc_tbl.FIRST..variableOptionDesc_tbl.LAST

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
            variableOptionDesc_tbl(i),  --LOCALIZED_STR
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
		  G_VARIABLE_MODEL_OPTION_OSR||p_intent||':'||variableCode_tbl(i)||':'||variableOption_tbl(i), --ORIG_SYS_REF
            USERENV('LANG'),  --SOURCE_LANG
            G_RUN_ID, -- RUN_ID
            NULL, -- REC_STATUS
            NULL, -- DISPOSITION
            NULL, -- MODEL_ID
            G_VARIABLE_MODEL_OSR||p_intent , -- FSK_DEVLPROJECT_1_1
            NULL, -- MESSAGE
            NULL -- SEEDED_FLAG
            );

      END LOOP; -- for all installed languages
     CLOSE csr_installed_languages;



  END IF; -- variableCode_tbl.COUNT > 0





  IF variableCode_tbl.COUNT > 0 THEN

    FORALL i IN variableCode_tbl.FIRST..variableCode_tbl.LAST

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
       -99, --ORGANIZATION_ID
       NULL, --ITEM_ID,
       NULL, --EXPLOSION_TYPE,
       variableOption_tbl(i), --NAME
       G_VARIABLE_MODEL_OPTION_OSR||p_intent||':'||variableCode_tbl(i)||':'||variableOption_tbl(i), --ORIG_SYS_REF
       NULL, --RESOURCE_FLAG
       1, --TOP_ITEM_ID  -- same value as in cz_imp_devl_projects
       NULL, --INITIAL_VALUE
       NULL, --PARENT_ID
       0, --MINIMUM
       NULL, --MAXIMUM
       262, --PS_NODE_TYPE  262:Option
       NULL,  --FEATURE_TYPE
       NULL, --PRODUCT_FLAG,
       NULL, --REFERENCE_ID,
       NULL, --MULTI_CONFIG_FLAG,
       NULL, --ORDER_SEQ_FLAG,
       NULL, --SYSTEM_NODE_FLAG
       SeqNoList_tbl(i) , --TREE_SEQ
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
       G_VARIABLE_MODEL_OPTION_OSR||p_intent||':'||variableCode_tbl(i)||':'||variableOption_tbl(i),  --FSK_INTLTEXT_1_1
       NULL, --FSK_INTLTEXT_1_EXT,
       NULL, --FSK_ITEMMASTER_2_1,
       NULL, --FSK_ITEMMASTER_2_EXT,
       G_VARIABLE_MODEL_FEATURE_OSR||p_intent||':'||variableCode_tbl(i) , --FSK_PSNODE_3_1
       NULL, --FSK_PSNODE_3_EXT,
       NULL, --FSK_PSNODE_4_1,
       NULL, --FSK_PSNODE_4_EXT,
       G_VARIABLE_MODEL_OSR||p_intent, --FSK_DEVLPROJECT_5_1
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


END create_variable_options;


/*
---------------------------------------------------
--  PUBLIC Procedures and Functions
---------------------------------------------------
*/
/*====================================================================+
  Procedure Name : import_variables
  Description    : This is a PUBLIC API that imports Variables and Constants
			    This API is called from publish rules concurrent program
  Parameters:
                   p_org_id - Org Id of the rules to be published

+====================================================================*/
PROCEDURE import_variables
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

-- CURSOR csr_variable_model_id(p_intent IN VARCHAR2) IS
CURSOR csr_variable_model_id(p_orig_sys_ref IN VARCHAR2) IS
SELECT devl_project_id
FROM cz_devl_projects
WHERE orig_sys_ref = p_orig_sys_ref
  AND devl_project_id = persistent_project_id
  AND deleted_flag = 0;

-- WHERE orig_sys_ref = G_VARIABLE_MODEL_OSR||p_intent

CURSOR csr_intent IS
SELECT DISTINCT INTENT
FROM okc_xprt_rule_hdrs_all
WHERE org_id = p_org_id
  AND status_code = 'PENDINGPUB';


l_intent                   VARCHAR2(1);
l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'import_variables';
l_variable_model_id        NUMBER :=NULL;
l_run_id                   NUMBER;
l_import_status            VARCHAR2(1);
l_orig_sys_ref             cz_devl_projects.orig_sys_ref%TYPE;


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

	-- Initialize l_variable_model_id
	  l_variable_model_id := NULL;

	 -- build variable model osr
	 l_orig_sys_ref := G_VARIABLE_MODEL_OSR||l_intent;

     -- check if Variable Model Already exists in CZ and get the Model Id
       -- OPEN  csr_variable_model_id(p_intent => l_intent);

       OPEN  csr_variable_model_id(p_orig_sys_ref => l_orig_sys_ref);
         FETCH csr_variable_model_id INTO l_variable_model_id;
       CLOSE csr_variable_model_id;

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
                             '150: Variable Model Id :'||l_variable_model_id);
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE||l_api_name,
                             '150: Intent :'||l_intent);
           END IF;

           create_variable_model
           (
            p_intent           => l_intent,
            p_model_id         => l_variable_model_id,
            x_return_status	=> x_return_status,
            x_msg_data	        => x_msg_data,
            x_msg_count        => x_msg_count
           );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '200: After Calling create_variable_model x_return_status : '||x_return_status);
           END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

          create_variable_component
           (
            p_intent           => l_intent,
            x_return_status	=> x_return_status,
            x_msg_data	        => x_msg_data,
            x_msg_count        => x_msg_count
           );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '300: After Calling create_variable_component x_return_status : '||x_return_status);
           END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

           create_variable_features
           (
            p_intent           => l_intent,
            x_return_status	=> x_return_status,
            x_msg_data	        => x_msg_data,
            x_msg_count        => x_msg_count
           );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '400: After Calling create_variable_feature x_return_status : '||x_return_status);
           END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;

           create_variable_options
           (
            p_intent           => l_intent,
            x_return_status	=> x_return_status,
            x_msg_data	        => x_msg_data,
            x_msg_count        => x_msg_count
           );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '500: After Calling create_variable_options x_return_status : '||x_return_status);
           END IF;

           --- If any errors happen abort API
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
           END IF;


--  END LOOP;
--CLOSE csr_intent;

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '550: Calling OKC_XPRT_CZ_INT_PVT.import_generic  ');
           END IF;

          -- Call the CZ Generic Import to push data to CZ
          OKC_XPRT_CZ_INT_PVT.import_generic
          (
           p_api_version      => l_api_version,
           p_run_id           => G_RUN_ID,
           p_rp_folder_id     => OKC_XPRT_CZ_INT_PVT.G_VARIABLE_FOLDER_ID ,
           x_run_id           => l_run_id,
           x_return_status    => l_import_status,
           x_msg_data	      => x_msg_data,
           x_msg_count        => x_msg_count
          );

           -- debug log
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE||l_api_name,
                      '600: After Calling OKC_XPRT_CZ_INT_PVT.import_generic x_return_status : '||
                       l_import_status);
           END IF;

          -- Log the Import Status and check if any records in the import tables have status not 'OK'
          OKC_XPRT_UTIL_PVT.check_import_status
          (
           p_run_id           => G_RUN_ID,
           p_import_status    => l_import_status,
           p_model_type       => 'V', -- Variable Model
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


END import_variables;





END OKC_XPRT_IMPORT_VARIABLES_PVT;

/
