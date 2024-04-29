--------------------------------------------------------
--  DDL for Package Body OKC_ASO_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ASO_INT_GRP" AS
/* $Header: OKCGIASOB.pls 120.0 2005/05/25 18:25:49 appldev noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ASO_INT_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_MODULE_NAME                CONSTANT   VARCHAR2(250) := 'OKC.PLSQL.'||G_PKG_NAME||'.';
  G_STMT_LEVEL                 CONSTANT   NUMBER        := FND_LOG.LEVEL_STATEMENT;
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR ;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';


Procedure get_article_variable_values(
                        p_api_version        IN  Number,
                        p_init_msg_list		IN  Varchar2,
                        p_doc_id	          IN  Number,
                        p_sys_var_value_tbl  IN  OUT NOCOPY sys_var_value_tbl_type,
                        x_return_status	     OUT NOCOPY Varchar2,
                        x_msg_data	          OUT NOCOPY Varchar2,
                        x_msg_count	     OUT NOCOPY Number
                        ) IS

l_api_version       CONSTANT NUMBER := 1;
l_api_name          CONSTANT VARCHAR2(30) := 'g_get_article_variable_values';
l_debug             Boolean;
l_module            VARCHAR2(250)   := G_MODULE_NAME||l_api_name;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       l_debug := true;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'10:Entering OKC_ASO_INT_GRP.Get_Article_Variable_Values');
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'20:Calling OKC_XPRT_QUOTE_INT_PVT.Get_clause_Variable_Values');
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
    END IF;

    OKC_XPRT_QUOTE_INT_PVT.get_clause_variable_values(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_id               => p_doc_id,
                         p_sys_var_value_tbl    => p_sys_var_value_tbl,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR ;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'30:Return status from OKC_XPRT_QUOTE_INT_PVT.Get_clause_Variable_Values = '||x_return_status);
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'40:Leaving OKC_ASO_INT_GRP.get_article_variable_values');
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'50: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_ERROR Exception');
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'60: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'70: Leaving get_article_variable_values because of EXCEPTION: '||sqlerrm);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END get_article_variable_values;




Procedure  get_item_dtl_for_expert(
                        p_api_version        IN	Number,
                        p_init_msg_list	     IN	Varchar2,
                        p_doc_id	     	IN	Number,
                        x_category_tbl       OUT NOCOPY item_tbl_type,
                        x_item_tbl           OUT NOCOPY item_tbl_type,
                        x_return_status	     OUT NOCOPY Varchar2,
                        x_msg_data	     	OUT NOCOPY Varchar2,
                        x_msg_count	     OUT NOCOPY Number
                        ) IS

l_api_version          CONSTANT NUMBER := 1;
l_api_name             CONSTANT VARCHAR2(30) := 'g_get_item_dtl_for_expert';
x_variables_tbl        OKC_TERMS_UTIL_GRP.item_dtl_tbl;
l_sys_var_value_tbl    sys_var_value_tbl_type;
l_cat_index            NUMBER := -1;
l_item_index           NUMBER := -1;

l_debug                Boolean;
l_module               VARCHAR2(250)   := G_MODULE_NAME||l_api_name;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       l_debug := true;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'80:Entering OKC_ASO_INT_GRP.get_item_dtl_for_expert');
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'90:Calling OKC_XPRT_QUOTE_INT_PVT.get_clause_variable_values - 2 ');
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
    END IF;

    l_sys_var_value_tbl(0).variable_code :='OKC$S_ITEM_CATEGORY';
    l_sys_var_value_tbl(1).variable_code :='OKC$S_ITEM';

    OKC_XPRT_QUOTE_INT_PVT.get_clause_variable_values(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_id               => p_doc_id,
                         p_variables_tbl        => l_sys_var_value_tbl,
                         x_line_var_value_tbl   => x_variables_tbl,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'95:Return status from OKC_XPRT_QUOTE_INT_PVT.Get_clause_Variable_Values - 2 = '||x_return_status);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR ;
    END IF;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'100:Category count = '||x_variables_tbl.category.COUNT);
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'110:Item count     = '||x_variables_tbl.item.COUNT);
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
    END IF;

    -- Populate the categories
    IF x_variables_tbl.category.COUNT > 0 THEN
       FOR i in x_variables_tbl.category.FIRST.. x_variables_tbl.category.LAST LOOP
           l_cat_index :=x_category_tbl.count + 1;
           x_category_tbl(l_cat_index).name := x_variables_tbl.category(i);
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'120:x_category_tbl('||l_cat_index||').name = '||x_category_tbl(l_cat_index).name);
           END IF;
       END LOOP;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
    END IF;
    -- Populate the Items

    IF x_variables_tbl.item.COUNT > 0 THEN
       FOR i in x_variables_tbl.item.FIRST.. x_variables_tbl.item.LAST LOOP
          l_item_index :=x_item_tbl.count + 1;
          x_item_tbl(l_item_index).name := x_variables_tbl.item(i);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'130:x_item_tbl('||l_item_index||').name = '||x_item_tbl(l_item_index).name);
          END IF;
       END LOOP;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,' ');
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'140:Leaving OKC_ASO_INT_GRP.g_get_item_dtl_for_expert');
    END IF;

    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'160: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_ERROR Exception');
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'170: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'180: Leaving  get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END  get_item_dtl_for_expert;




Function ok_to_commit   (
                        p_api_version        IN  Number,
                        p_init_msg_list		IN  Varchar2,
                        p_doc_id	          IN  Number,
                        p_doc_type           IN  VARCHAR2,
                        p_validation_string  IN  Varchar2,
                        x_return_status	     OUT NOCOPY Varchar2,
                        x_msg_data	          OUT NOCOPY Varchar2,
                        x_msg_count	     OUT NOCOPY Number
                        )
Return Varchar2 IS

l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_ok_to_commit';
l_update_allowed              varchar2(1);

l_debug             Boolean;
l_module            VARCHAR2(250)   := G_MODULE_NAME||l_api_name;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       l_debug := true;
    END IF;

       l_update_allowed := ASO_CONTRACT_TERMS_PUB.ok_to_commit(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_id               => p_doc_id,
                         p_doc_type             => p_doc_type,
                         p_validation_string    => p_validation_string,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   return l_update_allowed;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'190: Leaving ok_to_commit: OKC_API.G_EXCEPTION_ERROR Exception');
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'200: Leaving ok_to_commit: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_module,'210: Leaving ok_to_commit because of EXCEPTION: '||sqlerrm);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

END ok_to_commit;

END OKC_ASO_INT_GRP;


/
