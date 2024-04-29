--------------------------------------------------------
--  DDL for Package Body OKC_OKS_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OKS_INT_GRP" AS
/* $Header: OKCGIOKSB.pls 120.0 2005/05/25 18:29:41 appldev noship $ */

   l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_OKS_INT_GRP';
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


Procedure get_article_variable_values(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
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
        okc_util.print_trace(1,' Calling OKS_AUTH_INT_PUB.Get_PO_Attribute_values');
    END IF;
    NULL;
     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving OKS_AUTH_INT_PUB.Get_PO_Attribute_values');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving get_article_variable_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving get_article_variable_values because of EXCEPTION: '||sqlerrm, 2);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_article_variable_values;

Procedure  get_item_dtl_for_expert(
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
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
        okc_util.print_trace(1,' Calling OKS_AUTH_INT_PUB.get_item_dtl_for_expert');
    END IF;

     NULL;

     IF l_debug='Y' THEN
        okc_util.print_trace(1,' Leaving OKS_AUTH_INT_PUB.get_item_dtl_for_expert');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving  get_item_dtl_for_expert: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
WHEN OTHERS THEN
  IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving  get_item_dtl_for_expert because of EXCEPTION: '||sqlerrm, 2);
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
                        p_doc_id	          IN	Number,
                        p_validation_string       IN    Varchar2 default NULL,
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        )
Return Varchar2 IS

l_api_version                 CONSTANT NUMBER := 1;
l_api_name                    CONSTANT VARCHAR2(30) := 'g_ok_to_commit';
l_update_allowed              Boolean;
l_return_value                varchar2(1);
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

       l_update_allowed :=OKS_AUTH_INT_PUB.ok_to_commit(
                         p_api_version          => l_api_version,
                         p_init_msg_list        => FND_API.G_FALSE,
                         p_doc_id               => p_doc_id,
                         p_doc_validation_string=> p_validation_string,
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

    IF l_update_allowed then
       l_return_value :=FND_API.G_TRUE;
    ELSE
        l_return_value :=FND_API.G_FALSE;
    END IF;

   return l_return_value;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  IF (l_debug = 'Y') THEN
      okc_debug.log('2400: Leaving ok_to_commit: OKC_API.G_EXCEPTION_ERROR Exception', 2);
  END IF;

  x_return_status := G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (l_debug = 'Y') THEN
      okc_debug.log('2500: Leaving ok_to_commit: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;
WHEN OTHERS THEN
  IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving ok_to_commit because of EXCEPTION: '||sqlerrm, 2);
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR ;

  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
  return FND_API.G_FALSE;

END ok_to_commit;
END OKC_OKS_INT_GRP;

/
