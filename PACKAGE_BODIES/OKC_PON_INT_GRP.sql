--------------------------------------------------------
--  DDL for Package Body OKC_PON_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PON_INT_GRP" AS
/* $Header: OKCGISOB.pls 120.1 2005/10/11 02:47:44 ndoddi noship $ */

   l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_PON_INT_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

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

  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							  NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							  NUMBER		:= FND_LOG.LEVEL_EXCEPTION;


Procedure get_article_variable_values(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_sys_var_value_tbl       IN OUT NOCOPY sys_var_value_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        )IS
l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_get_article_variable_values';
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Calling PON_CONTERMS_UTL_GRP.Get_PO_Attribute_values');
    END IF;

    PON_CONTERMS_UTL_GRP.get_article_variable_values(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doctype_id          => p_doc_type,
                         p_doc_id               => p_doc_id,
                         p_sys_var_value_tbl    => p_sys_var_value_tbl,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);

        --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
        --------------------------------------------
     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving PON_CONTERMS_UTL_GRP.Get_PO_Attribute_values');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2400: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2500: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  /*IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving get_article_variable_values because of EXCEPTION: '||sqlerrm, 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2600: Leaving get_article_variable_values because of EXCEPTION: '||sqlerrm );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_article_variable_values;

Procedure get_changed_variables(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_sys_var_tbl            IN OUT NOCOPY sys_var_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        ) IS
l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_get_changed_variables';
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Calling PON_CONTERMS_UTL_GRP.attribute_value_changed');
    END IF;

    PON_CONTERMS_UTL_GRP.get_changed_variables(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_id               => p_doc_id,
                         p_doctype_id           => p_doc_type,
                         p_sys_var_tbl          => p_sys_var_tbl,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);

        --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
        --------------------------------------------
     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving PON_CONTERMS_UTL_GRP.attribute_value_changed');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving get_changed_variables: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2400: Leaving get_changed_variables: OKC_API.G_EXCEPTION_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving get_changed_variables: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2500: Leaving get_changed_variables: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  /*IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving get_changed_variables because of EXCEPTION: '||sqlerrm, 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2600: Leaving get_changed_variables because of EXCEPTION: '||sqlerrm );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_changed_variables;

Procedure  get_item_dtl_for_expert(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type	          IN	Varchar2,
                        p_doc_id	          IN	Number,
                        x_category_tbl            OUT   NOCOPY item_tbl_type,
                        x_item_tbl                OUT   NOCOPY item_tbl_type,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        )IS
l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_get_item_dtl_for_expert';
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Calling PON_CONTERMS_UTL_GRP.get_item_dtl_for_expert');
    END IF;

    PON_CONTERMS_UTL_GRP.get_item_category(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doctype_id		=> p_doc_type,
                         p_doc_id               => p_doc_id,
                         x_category_tbl         => x_category_tbl,
                         x_item_tbl             => x_item_tbl,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);

        --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
        --------------------------------------------
     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving PON_CONTERMS_UTL_GRP.get_item_dtl_for_expert');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2400: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2500: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  /*IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving  get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm, 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2600: Leaving  get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END  get_item_dtl_for_expert;

Function ok_to_commit   (
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type                IN    Varchar2,
                        p_doc_id	          IN	Number,
                        p_validation_string       IN    Varchar2 default NULL,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        )
Return Varchar2 IS

l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_ok_to_commit';
l_update_allowed              Varchar2(10);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

       PON_CONTERMS_UTL_GRP.ok_to_commit(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_id               => p_doc_id,
                         p_doctype_id          => p_doc_type,
                         x_update_allowed       => l_update_allowed,
                         x_return_status        => x_return_status,
                         x_msg_data             => x_msg_data,
                         x_msg_count            => x_msg_count);
        --------------------------------------------
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
        --------------------------------------------

   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   return nvl(l_update_allowed, FND_API.G_FALSE);

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving ok_to_commit: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2400: Leaving ok_to_commit: OKC_API.G_EXCEPTION_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving ok_to_commit: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2500: Leaving ok_to_commit: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;
WHEN OTHERS THEN
  /*IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving ok_to_commit because of EXCEPTION: '||sqlerrm, 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2600: Leaving ok_to_commit because of EXCEPTION: '||sqlerrm );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

END ok_to_commit;
END OKC_PON_INT_GRP;

/
