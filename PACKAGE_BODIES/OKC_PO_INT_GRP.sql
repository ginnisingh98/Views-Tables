--------------------------------------------------------
--  DDL for Package Body OKC_PO_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PO_INT_GRP" AS
/* $Header: OKCGIPOB.pls 120.1.12010000.2 2010/03/05 10:07:50 nvvaidya ship $ */

   l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_PO_INT_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;
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
        okc_util.print_trace(1,' Calling PO_CONTERMS_UTL_GRP.Get_PO_Attribute_values');
    END IF;

    PO_CONTERMS_UTL_GRP.Get_PO_Attribute_values(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                          p_doc_type             => p_doc_type,
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
        okc_util.print_trace(1,' Leaving PO_CONTERMS_UTL_GRP.Get_PO_Attribute_values');
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
END;

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
        okc_util.print_trace(1,' Calling PO_CONTERMS_UTL_GRP.attribute_value_changed');
    END IF;

    PO_CONTERMS_UTL_GRP.attribute_value_changed(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                          p_doc_type             => p_doc_type,
                         p_doc_id               => p_doc_id,
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
        okc_util.print_trace(1,' Leaving PO_CONTERMS_UTL_GRP.attribute_value_changed');
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
END;

Procedure get_item_dtl_for_expert(
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
l_category_tbl                    category_tbl_type;
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Calling PO_CONTERMS_UTL_GRP.get_item_categorylist');
    END IF;

    PO_CONTERMS_UTL_GRP.get_item_categorylist(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_type             => p_doc_type,
                         p_document_id          => p_doc_id,
                         x_category_tbl         => l_category_tbl,
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
        IF l_category_tbl.count > 0 THEN
              FOR i in l_category_tbl.FIRST..l_category_tbl.LAST LOOP
                      x_category_tbl(i).name := l_category_tbl(i).category_name;
              END LOOP;
        END IF;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving OKC_PO_INT_GRP.get_item_dtl_for_expert');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving get_item_dtl_for_expert: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2400: Leaving get_item_dtl_for_expert: OKC_API.G_EXCEPTION_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving get_item_dtl_for_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2500: Leaving get_item_dtl_for_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  /*IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm, 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2600: Leaving get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_item_dtl_for_expert;

Function ok_to_commit   (
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_doc_type                IN	Varchar2,
                        p_doc_id	          IN	Number,
                        p_tmpl_change             IN    Varchar2 default NULL,
                        p_validation_string       IN    Varchar2 default NULL,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        )
Return Varchar2 IS

l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_ok_to_commit';
l_update_allowed              VARCHAR2(1) :='N';
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_tmpl_change IS NULL THEN

       PO_CONTERMS_UTL_GRP.is_po_update_allowed(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                          p_doc_type             => p_doc_type ,
                         p_header_id            => p_doc_id,
                         p_callout_string       => p_validation_string,
                         p_lock_flag            => 'N',
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
   ELSE
       PO_CONTERMS_UTL_GRP.Apply_Template_Change(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                          p_doc_type             => p_doc_type,
                         p_header_id            => p_doc_id,
                         p_callout_string       => p_validation_string,
                         p_template_changed     => p_tmpl_change,
                         p_commit               => FND_API.G_FALSE,
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
   END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF l_update_allowed='Y' THEN
      return FND_API.G_TRUE;
   ELSE
      return FND_API.G_FALSE;
   END IF;

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

PROCEDURE Get_Last_Signed_Revision (
                          p_api_version            IN NUMBER,
                          p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_doc_type             IN VARCHAR2,
                          p_doc_id                 IN NUMBER,
                          p_revision_num           IN NUMBER,
                          x_signed_revision_num    OUT NOCOPY NUMBER,
                          x_return_status          OUT NOCOPY VARCHAR2,
                          x_msg_data               OUT NOCOPY VARCHAR2,
                          x_msg_count              OUT NOCOPY NUMBER)
IS
l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'Get_Last_Signed_Revision';
l_signed_record           Varchar2(1);
BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Calling PO_CONTERMS_UTL_GRP.Get_Last_Signed_Revision');
    END IF;

    PO_CONTERMS_UTL_GRP.Get_Last_Signed_Revision(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_type             => p_doc_type,
                         p_header_id            => p_doc_id,
                         p_revision_num         => p_revision_num,
                         x_signed_revision_num  => x_signed_revision_num,
                         x_signed_records       => l_signed_record,
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
            IF l_signed_record <>'Y' THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving OKC_PO_INT_GRP.Get_Last_Signed_Revision');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving Get_Last_Signed_Revision: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2400: Leaving Get_Last_Signed_Revision: OKC_API.G_EXCEPTION_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  /*IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving Get_Last_Signed_Revision: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2500: Leaving Get_Last_Signed_Revision: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception' );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  /*IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving Get_Last_Signed_Revision because of EXCEPTION: '||sqlerrm, 2);
  END IF;*/

  IF ( G_EXCP_LEVEL >= G_DBG_LEVEL ) THEN
      FND_LOG.STRING(G_EXCP_LEVEL,
          G_PKG_NAME, '2600: Leaving Get_Last_Signed_Revision because of EXCEPTION: '||sqlerrm );
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END Get_Last_Signed_Revision;

END OKC_PO_INT_GRP;

/
