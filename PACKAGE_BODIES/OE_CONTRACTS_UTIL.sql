--------------------------------------------------------
--  DDL for Package Body OE_CONTRACTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONTRACTS_UTIL" AS
/* $Header: OEXUOKCB.pls 120.4.12010000.2 2008/11/12 12:36:53 smanian ship $ */

--ETR
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

G_PKG_NAME                     CONSTANT VARCHAR2(30) := 'OE_Contracts_Util';
--ETR

  G_CURRENT_VERSION_NUMBER     CONSTANT  NUMBER := -99; /* Note: the contract document attachment creation java API always creates the current
                                                           version of the attachment as -99 during the workflow approval process.
                                                           (the contract document attachment creation java API increments the version number
                                                           from 0,1... later after the attachment has been archived once)  */


/* this function is used to simply return the value of G_BSA_DOC_TYPE
   used within forms libraries to access G_BSA_DOC_TYPE as the PL/SQL implementation of
   the PL/SQL version used in forms does not allow direct reference to G_BSA_DOC_TYPE */
FUNCTION get_G_BSA_DOC_TYPE
RETURN VARCHAR2 IS
BEGIN
  RETURN (OE_Contracts_util.G_BSA_DOC_TYPE);
END;


/* this function is used to simply return the value of G_SO_DOC_TYPE
   used within forms libraries to access G_SO_DOC_TYPE as the PL/SQL implementation of
   the PL/SQL version used in forms does not allow direct reference to G_SO_DOC_TYPE */
FUNCTION get_G_SO_DOC_TYPE
RETURN VARCHAR2 IS
BEGIN
  RETURN (OE_Contracts_util.G_SO_DOC_TYPE);
END;


FUNCTION check_license
RETURN VARCHAR2 IS


l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_sales_contracts_enabled VARCHAR2(3);
l_dummy                      BOOLEAN;
lx_status                    VARCHAR2(1);
lx_industry                  VARCHAR2(1);
lx_oracle_schema	     VARCHAR2(30);

BEGIN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('In OE_Contracts_util.check_license', 1);
  END IF;

  IF OE_CONTRACTS_UTIL.G_CNTR_LICENSED IS NULL OR
     OE_CONTRACTS_UTIL.G_CNTR_LICENSED NOT IN ('Y','N') THEN
     --this is the first time this check is being performed

     --first verify if contracts is installed
     l_dummy := FND_INSTALLATION.get_app_info  (
                   application_short_name    =>   'OKC',
                   status                    =>   lx_status,
                   industry                  =>   lx_industry,
                   oracle_schema             =>   lx_oracle_schema
     );

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('performing check first time, lx_status:  ' || lx_status, 3);
     END IF;

     IF lx_status = 'I' THEN
        --contracts is installed so check profile option to see if it is also licensed

        l_sales_contracts_enabled := NVL(FND_PROFILE.VALUE('OKC_ENABLE_SALES_CONTRACTS'),'N');
        l_sales_contracts_enabled := UPPER(SUBSTR(l_sales_contracts_enabled,1,1)); -- take 'Y' or 'N'

        IF l_debug_level > 0 THEN
           oe_debug_pub.add('l_sales_contracts_enabled: ' || l_sales_contracts_enabled, 3);
        END IF;

        IF l_sales_contracts_enabled = 'Y' THEN
           OE_CONTRACTS_UTIL.G_CNTR_LICENSED := 'Y';
           RETURN 'Y';
        ELSIF l_sales_contracts_enabled = 'N' THEN
           OE_CONTRACTS_UTIL.G_CNTR_LICENSED := 'N';
           RETURN 'N';
        ELSE
           OE_CONTRACTS_UTIL.G_CNTR_LICENSED := 'N';
           RETURN 'N';
        END IF;

     ELSE
        --contracts is not installed at all
        OE_CONTRACTS_UTIL.G_CNTR_LICENSED := 'N';
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Contracts is not installed at all, returning ''N''', 3);
        END IF;
        RETURN 'N';
     END IF;


  -- we have already performed the license check earlier so reuse the cache
  ELSE
   IF l_debug_level > 0 THEN
     oe_debug_pub.add('cache already has value, OE_CONTRACTS_UTIL.G_BSA_CNTR_LICENSE:  ' ||OE_CONTRACTS_UTIL.G_CNTR_LICENSED, 3);
   END IF;

   RETURN OE_CONTRACTS_UTIL.G_CNTR_LICENSED;
  END IF;


  IF l_debug_level > 0 THEN
     oe_debug_pub.add('End of OE_Contracts_util.check_license', 1);
  END IF;

EXCEPTION
WHEN OTHERS THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN-OTHERS in check_license', 1);
   END IF;

   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'check_license'
        );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_license;



--Copy Document Articles
PROCEDURE copy_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_copy_from_doc_id           IN  NUMBER,
   p_version_number             IN  VARCHAR2 DEFAULT NULL,
   p_copy_to_doc_id             IN  NUMBER,
   p_copy_to_doc_start_date     IN  DATE     := SYSDATE,
   p_keep_version               IN  VARCHAR2 := 'N',
   p_copy_to_doc_number         IN  NUMBER   DEFAULT NULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_debug_level                 CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_copy_to_doc_number          VARCHAR2(30) := TO_CHAR(p_copy_to_doc_number);

  l_doc_type                    VARCHAR2(5) :=  p_doc_type;
  l_copy_to_doc_id              NUMBER      :=  p_copy_to_doc_id;


  l_latest_version_number       NUMBER;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.copy_articles ', 1);
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;


   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence not performing copy ', 3);
      END IF;
      RETURN;
   END IF;


   --checking if version number passed is the latest BSA or Sales Order version
   IF p_version_number IS NOT NULL THEN
      oe_debug_pub.add('Checking for latest version number for for p_doc_type: '|| p_doc_type
                        || ' and p_copy_from_doc_id: ' || p_copy_from_doc_id, 3);

      IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
         SELECT version_number
         INTO   l_latest_version_number
         FROM   oe_blanket_headers_all
         WHERE  header_id = p_copy_from_doc_id;

      ELSIF p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
         SELECT version_number
         INTO   l_latest_version_number
         FROM   oe_order_headers_all
         WHERE  header_id = p_copy_from_doc_id;

      END IF;
      oe_debug_pub.add('l_latest_version_number for p_doc_type: '||p_doc_type || ' and p_copy_from_doc_id: '
                        || p_copy_from_doc_id || ' is: ' || l_latest_version_number, 3);
   END IF;



   -----IF p_version_number = FND_API.G_MISS_CHAR THEN
   IF p_version_number IS NULL OR
      p_version_number = l_latest_version_number THEN
      --we are in the context of copying from a BSA or Sales Order to create a new BSA or Sales Order

       IF l_debug_level > 0 THEN
         oe_debug_pub.add('Calling OKC_TERMS_COPY_GRP.copy_doc  ', 3);
         oe_debug_pub.add('p_api_version: ' || p_api_version,3);
         oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
         oe_debug_pub.add('p_commit: ' || p_commit,3);
         oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
         oe_debug_pub.add('p_copy_from_doc_id:  ' || p_copy_from_doc_id, 3);
         oe_debug_pub.add('p_copy_to_doc_id:  ' || p_copy_to_doc_id, 3);
         oe_debug_pub.add('p_keep_version:  ' || p_keep_version, 3);
         oe_debug_pub.add('p_copy_to_doc_start_date:  ' || p_copy_to_doc_start_date, 3);
         oe_debug_pub.add('l_copy_to_doc_number:  ' || l_copy_to_doc_number, 3);
       END IF;

       OKC_TERMS_COPY_GRP.copy_doc (
          p_api_version             =>  p_api_version,
          p_init_msg_list           =>  p_init_msg_list,
          p_commit                  =>  p_commit,
          p_source_doc_type         =>  l_doc_type,
          p_source_doc_id           =>  p_copy_from_doc_id,
          p_target_doc_type         =>  l_doc_type,
          p_target_doc_id           =>  l_copy_to_doc_id,
          p_keep_version            =>  p_keep_version,
          ---------p_article_effective_date  =>  p_copy_to_doc_start_date,
          p_article_effective_date  =>  NULL,   -- we should not pass effectivity date ref: Bug 3307561
          p_document_number         =>  l_copy_to_doc_number,
                                                          ----p_reinitialize_deliverables: defaulted, not passed
          x_return_status           =>  x_return_status,
          x_msg_data           	   =>  x_msg_data,
          x_msg_count          	   =>  x_msg_count,
	  p_copy_abstract_yn        => 'N'
       );

       IF l_debug_level > 0 THEN
          oe_debug_pub.add('x_return_status:  ' || x_return_status, 3);
       END IF;

       --ETR
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
       END IF;
       --ETR

   ELSIF p_version_number <> FND_API.G_MISS_CHAR AND
         p_version_number <> l_latest_version_number THEN
      --we are in the context of copying from an archived version of a BSA Sales Order to create a new BSA Sales Order

      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Calling OKC_TERMS_COPY_GRP.copy_archived_doc  ', 3);
         oe_debug_pub.add('p_api_version: ' || p_api_version,3);
         oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
         oe_debug_pub.add('p_commit: ' || p_commit,3);
         oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
         oe_debug_pub.add('p_copy_from_doc_id:  ' || p_copy_from_doc_id, 3);
         oe_debug_pub.add('p_version_number:  ' || p_version_number, 3);
         oe_debug_pub.add('p_copy_to_doc_id:  ' || p_copy_to_doc_id, 3);
         oe_debug_pub.add('p_keep_version:  ' || p_keep_version, 3);
         oe_debug_pub.add('l_copy_to_doc_number:  ' || l_copy_to_doc_number, 3);
      END IF;

      OKC_TERMS_COPY_GRP.copy_archived_doc (
         p_api_version             =>  p_api_version,
         p_init_msg_list           =>  p_init_msg_list,
         p_commit                  =>  p_commit,
         p_source_doc_type         =>  p_doc_type,
         p_source_doc_id           =>  p_copy_from_doc_id,
         p_source_version_number   =>  p_version_number,
         p_target_doc_type         =>  p_doc_type,
         p_target_doc_id           =>  p_copy_to_doc_id,
         p_document_number         =>  l_copy_to_doc_number,
         x_return_status           =>  x_return_status,
         x_msg_data                =>  x_msg_data,
         x_msg_count               =>  x_msg_count
      );

      IF l_debug_level > 0 THEN
          oe_debug_pub.add('x_return_status:  ' || x_return_status, 3);
      END IF;

      --ETR
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --ETR

   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.copy_articles, x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in copy_articles ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in copy_articles ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in copy_articles ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'copy_articles'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );


END copy_articles;




--Version articles of BSA or Sales Order
PROCEDURE version_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_version_number             IN  VARCHAR2,
   p_clear_amendment            IN  VARCHAR2 := 'Y',

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.version_articles ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;


   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence not performing versioning ', 3);
      END IF;
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_VERSION_GRP.version_doc  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_commit: ' || p_commit,3);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
      oe_debug_pub.add('p_version_number:  ' || p_version_number, 3);
   END IF;
   --go ahead and version the articles belonging to the BSA or Sales Order
   OKC_TERMS_VERSION_GRP.version_doc (
         p_api_version         	=>  p_api_version,
         p_init_msg_list       	=>  p_init_msg_list,
         p_commit               =>  p_commit,
         p_doc_type             =>  p_doc_type,
         p_doc_id               =>  p_doc_id,
         p_version_number       =>  p_version_number,
         p_clear_amendment      =>  p_clear_amendment,
         x_return_status        =>  x_return_status,
         x_msg_data           	=>  x_msg_data,
         x_msg_count          	=>  x_msg_count
   );

   IF l_debug_level > 0 THEN
          oe_debug_pub.add('x_return_status:  ' || x_return_status, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.version_articles  , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in version_articles ', 3);
   END IF;

   --close any cursors

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in version_articles ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in version_articles ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'version_articles'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );


END version_articles;




--perform QA checks upon the articles belonging to a BSA or Sales Order
PROCEDURE qa_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_qa_mode                    IN  VARCHAR2 := OKC_TERMS_QA_GRP.G_NORMAL_QA,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_qa_return_status           OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS


  l_article_exist VARCHAR2(100);
--ETR
  l_order_signed  VARCHAR2(1);
--ETR
  lx_qa_result_tbl              qa_result_tbl_type;
  l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_template_id     NUMBER;
l_template_name   VARCHAR2(240);
l_contract_source   VARCHAR2(240);
l_authoring_party   VARCHAR2(240);
l_contract_source_code   VARCHAR2(240);
l_has_primary_doc   VARCHAR2(240);
l_run_expert_flag   VARCHAR2(1); --bug6318133

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.qa_articles ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;


   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence not performing article QA ', 3);
      END IF;
      RETURN;
   END IF;

--ETR
   IF p_doc_type = OE_CONTRACTS_UTIL.get_G_SO_DOC_TYPE() THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Calling OE_CONTRACTS_UTIL_GRP.is_order_signed  ', 3);
         oe_debug_pub.add('p_api_version: ' || p_api_version,3);
         oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
         oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
         oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
      END IF;

      --Check whether Order already signed ; if signed, QA already performed
      l_order_signed :=  oe_contracts_util.is_order_signed (
                           p_api_version    =>  p_api_version,
                           p_init_msg_list  =>  p_init_msg_list,
                           p_doc_id         =>  p_doc_id,
                           x_return_status  =>  x_return_status,
                           x_msg_data       =>  x_msg_data,
                           x_msg_count      =>  x_msg_count
                       );
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('l_order_signed:  '|| l_order_signed, 3);
         oe_debug_pub.add('x_return_status: '|| x_return_status, 3);
      END IF;

      --ETR
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      --ETR

      IF l_order_signed = 'Y' THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('SO signed and therefore already QAd, hence not performing article QA ', 3);
         END IF;
         RETURN;
      END IF;
   END IF; --IF p_doc_type = 'O' THEN
 --ETR

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.is_article_exist  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
   END IF;

   --Determine whether any articles exist for the BSA or Sales Order being QA'd
   l_article_exist :=  OKC_TERMS_UTIL_GRP.is_article_exist (
                           p_api_version    =>  p_api_version,
                           p_init_msg_list  =>  p_init_msg_list,
                           p_doc_type       =>  p_doc_type,
                           p_doc_id         =>  p_doc_id,
                           x_return_status  =>  x_return_status,
                           x_msg_data       =>  x_msg_data,
                           x_msg_count      =>  x_msg_count

                       );
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_article_exist:  '|| l_article_exist, 3);
      oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_article_exist <> OKC_TERMS_UTIL_GRP.G_NO_ARTICLE_EXIST THEN    --i.e. 'NONE'
      --i.e. proceed with articles QA process only if articles exist for the BSA
     OE_CONTRACTS_UTIL.get_contract_details_all (
        p_api_version     =>  1.0,
        p_init_msg_list   =>  'F',
        p_doc_type        =>  p_doc_type,
        p_doc_id          =>  p_doc_id,
        x_template_id     =>  l_template_id,
        x_authoring_party =>  l_authoring_party,
        x_contract_source =>  l_contract_source,
        x_contract_source_code =>  l_contract_source_code,
        x_has_primary_doc =>  l_has_primary_doc,
        x_template_name   =>  l_template_name,
        x_return_status   =>  x_return_status,
        x_msg_count       =>  x_msg_count,
        x_msg_data        =>  x_msg_data
           );

      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;


      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Calling OKC_TERMS_QA_GRP.QA_doc  ', 3);
         oe_debug_pub.add('p_api_version: ' || p_api_version,3);
         oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
         oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
         oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
         oe_debug_pub.add('p_qa_mode ' || p_qa_mode,3);
      END IF;
      --p_run_expert_flag added for fix 5186582 to skip expert validations in Quote to order

      --bug6318133
	IF p_doc_type = OE_CONTRACTS_UTIL.get_G_SO_DOC_TYPE() then
		l_run_expert_flag := 'N';
	ELSE
		l_run_expert_flag := 'Y';
	END IF;


      OKC_TERMS_QA_GRP.QA_doc (
          p_api_version           =>  p_api_version,
          p_init_msg_list         =>  p_init_msg_list,
          ----p_commit                =>  p_commit,
          p_qa_mode               =>  p_qa_mode,
          p_doc_type              =>  p_doc_type,
          p_doc_id                =>  p_doc_id,
	  p_run_expert_flag       =>  l_run_expert_flag,
          x_qa_return_status      =>  x_qa_return_status,
          x_qa_result_tbl         =>  lx_qa_result_tbl,

          x_return_status         =>  x_return_status,
          x_msg_data              =>  x_msg_data,
          x_msg_count             =>  x_msg_count
      );

      IF l_debug_level > 0 THEN
         oe_debug_pub.add('x_qa_return_status:  '|| x_qa_return_status, 3);
         oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
         oe_debug_pub.add('lx_qa_result_tbl.COUNT: ' || lx_qa_result_tbl.COUNT, 3);
      END IF;

      IF l_contract_source_code = 'ATTACHED' AND l_has_primary_doc = 'N' THEN
        --set qa return status to error
        x_qa_return_status:= G_RET_STS_ERROR;
        fnd_message.set_name('ONT','ONT_NO_PRIMARY_OKC_DOCUMENT');
        OE_MSG_PUB.Add;

      END IF;

      --ETR
      IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
      --ETR

      IF l_debug_level > 0 THEN
         oe_debug_pub.add('retrieving QA messages from lx_qa_result_tbl and place them onto the FND error message stack  ', 3);
      END IF;

      --retrieve QA messages from lx_qa_result_tbl and place them onto the FND error message stack
      IF lx_qa_result_tbl.FIRST IS NOT NULL THEN
         FOR i IN lx_qa_result_tbl.FIRST..lx_qa_result_tbl.LAST LOOP

             IF lx_qa_result_tbl(i).Problem_details IS NOT NULL THEN
                fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
                fnd_message.set_token('message', lx_qa_result_tbl(i).Problem_details);  --!!!! need to use SUBSTR here ??!!!!!
                                        --Note: Problem_details is a translated string provided by the QA
                fnd_msg_pub.add;
             END IF;
         END LOOP;

         IF l_debug_level > 0 THEN
            oe_debug_pub.add('Transferring messages from FND stack to OM error message stack  ', 3);
         END IF;
         OE_MSG_PUB.Transfer_Msg_Stack;

         --Get message count and data
         OE_MSG_PUB.Count_And_Get (
               p_count      => x_msg_count,
               p_data       => x_msg_data
         );

      END IF;



   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.qa_articles  , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in qa_articles ', 3);
   END IF;

   --close any cursors

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in qa_articles ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in qa_articles ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/


  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'qa_articles'
        );
  END IF;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );


END qa_articles;


--to determine whether any non standard articles exists for the BSA or Sales Order
--called from the approval workflow to determine whether non standard articles exist for the BSA or Sales Orders being approved
FUNCTION non_standard_article_exists
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

RETURN VARCHAR2 IS
   l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_article_type        VARCHAR2(50);
BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.non_standard_article_exists ', 1);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.is_article_exist',3);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence not performing non_standard_article_exists check ', 3);
      END IF;
      ---RETURN NULL;
      RETURN 'N';
   END IF;


   l_article_type :=  OKC_TERMS_UTIL_GRP.is_article_exist (
                          p_api_version    =>  p_api_version,
                          p_init_msg_list  =>  p_init_msg_list,
                          p_doc_type       =>  p_doc_type,
                          p_doc_id         =>  p_doc_id,
                          x_return_status  =>  x_return_status,
                          x_msg_count      =>  x_msg_count,
                          x_msg_data       =>  x_msg_data
                      );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_return_status: ' || x_return_status, 3);
      oe_debug_pub.add('l_article_type: ' || l_article_type, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_article_type = OKC_TERMS_UTIL_GRP.G_NON_STANDARD_ART_EXIST THEN  --i.e. 'NON_STANDARD_EXIST'
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('End of OE_Contracts_util.non_standard_article_exists  , returning Y');
      END IF;
      RETURN 'Y';
   ELSE
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('End of OE_Contracts_util.non_standard_article_exists  , returning N');
      END IF;
      RETURN 'N';
   END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in non_standard_article_exists ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in non_standard_article_exists ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );



WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN OTHERS in non_standard_article_exists ', 3);
   END IF;

   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'non_standard_article_exists'
        );
   END IF;
   -----RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );


END non_standard_article_exists;


--workflow wrapper procedure for non_standard_article_exists()
PROCEDURE WF_non_stndrd_article_exists (
                itemtype  IN VARCHAR2,
                itemkey   IN VARCHAR2,
                actid     IN NUMBER,
                funcmode  IN VARCHAR2,
                resultout OUT NOCOPY VARCHAR2) IS

  l_non_standard_article_exists VARCHAR2(1);
  l_doc_id                   NUMBER;         -- header id of BSA or sales order
  l_sales_document_type_code VARCHAR2(30);   -- i.e. either 'B' or 'O'

  l_api_version              CONSTANT NUMBER       := 1;
  l_api_name                 CONSTANT VARCHAR2(30) := 'WF_non_standard_article_exists';
  lx_return_status           VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
  lx_msg_count               NUMBER                := 0;
  lx_msg_data                VARCHAR2(2000);

  l_debug_level              CONSTANT NUMBER       := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING WF_non_standard_article_exists',1) ;
   END IF;

   OE_STANDARD_WF.Set_Msg_Context(actid);

   --get the header id of the BSA
   --header_id is the itemkey of the workflow
   l_doc_id := to_number(itemkey);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('l_doc_id: ' || l_doc_id,3);
   END IF;

   l_sales_document_type_code := wf_engine.GetItemAttrText(itemtype,
                                                           itemkey,
                                                          'SALES_DOCUMENT_TYPE_CODE');
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('l_sales_document_type_code: ' || l_sales_document_type_code,3);
      oe_debug_pub.add('Calling non_standard_article_exists()',3);
   END IF;



   l_non_standard_article_exists :=
        non_standard_article_exists   (
            p_api_version     =>  l_api_version,
            p_doc_type        =>  l_sales_document_type_code,
            p_doc_id          =>  l_doc_id,
            x_return_status   =>  lx_return_status,
            x_msg_count       =>  lx_msg_count,
            x_msg_data        =>  lx_msg_data
        );


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('l_non_standard_article_exists: ' || l_non_standard_article_exists, 3);
      oe_debug_pub.add('lx_return_status: ' || lx_return_status, 3);
   END IF;


   IF (funcmode = 'RUN') then
       resultout := 'COMPLETE:' || l_non_standard_article_exists;  --'Y' or  'N'
       RETURN;
   END IF;

   IF (funcmode = 'CANCEL') THEN
       resultout := 'COMPLETE:';
       RETURN;
   END IF;

   IF (funcmode = 'TIMEOUT') THEN
       resultout := 'COMPLETE:';
       RETURN;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In WHEN OTHERS: ', 3);
      END IF;

      wf_core.context('OE_CONTRACTS_UTIL',
             'WF_non_standard_article_exists',
              itemtype,
              itemkey,
              to_char(actid),
              funcmode);
      RAISE;


END WF_non_stndrd_article_exists;



/* During the BSA or Sales Order approval workflow process, the notification sent by workflow
   has a link that points to the attachment representing the BSA or Sales Order.
   This procedure is used by that link (by a specialized item attribute) to point
   to the OM entity or contract entity attachment representing the BSA/Sales Order.  */
PROCEDURE attachment_location
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_workflow_string            OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_template_id            NUMBER;
  l_template_name          VARCHAR2(500);
  l_workflow_string        VARCHAR2(1000);

  l_debug_level            CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_doc_version_number     NUMBER;

  l_attachment_exist_check CHAR(1);

  --cursor to determine whether any attachments exist for the BSA or Sales Order
  CURSOR c_attachment_exist_check IS
  SELECT 'x'
  FROM   fnd_attached_documents
  WHERE
   (
     entity_name         = 'OKC_CONTRACT_DOCS'
     AND   pk1_value     = p_doc_type
     AND   pk2_value     = to_char(p_doc_id)
     -------AND   pk3_value     = l_doc_version_number
     AND   pk3_value     = G_CURRENT_VERSION_NUMBER   /* Note: the contract document attachment creation java API always creates the current
                                                         version of the attachment as -99 during the workflow approval process.
                                                         (the contract document attachment creation java API increments the version number
                                                         from 0,1... later after the attachment has been archived once)  */
   )
                      OR
   (
     entity_name         = 'OE_ORDER_HEADERS'
     AND   pk1_value     = to_char(p_doc_id)
   );



  /*********
  --cursor to get the version number of the blanket
  CURSOR c_get_bsa_version (cp_header_id NUMBER) IS
  SELECT version_number
  FROM   oe_blanket_headers_all
  WHERE  header_id    = cp_header_id;


  --cursor to get the version number of the sales order
  CURSOR c_get_so_version (cp_header_id NUMBER) IS
  SELECT version_number
  FROM   oe_order_headers_all
  WHERE  header_id    = cp_header_id;
  *********/


BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.attachment_location ', 1);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type:  '|| p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  '|| p_doc_id, 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing, proceed with procesing only if licensed
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting attachment_location ', 3);
      END IF;
      RETURN;
   END IF;



   --Determine whether any attachments exist for the BSA or sales Order, proceed with processing only if attachments exist
   IF c_attachment_exist_check%ISOPEN THEN
      CLOSE c_attachment_exist_check;
   END IF;
   OPEN c_attachment_exist_check;
   FETCH c_attachment_exist_check INTO l_attachment_exist_check;
   CLOSE c_attachment_exist_check;
   IF l_attachment_exist_check IS NULL THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('No attachments exist for the BSA or Sales Order, hence exiting attachment_location...', 3);
      END IF;
      x_workflow_string := NULL;  --returning NULL will ensure that no paper clip icon is shown in the workflow
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OE_Contracts_util.get_terms_template ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type:  '|| p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  '|| p_doc_id, 3);
   END IF;

   --first determine whether any terms and conditions have been instantiated for the BSA or Sales Order
   oe_contracts_util.get_terms_template (
      p_api_version                => 1.0,
      p_init_msg_list              => p_init_msg_list,

      p_doc_type                   => p_doc_type,
      p_doc_id                     => p_doc_id,

      x_template_id                => l_template_id,
      x_template_name              => l_template_name,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
   );


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_template_id:  '|| l_template_id, 3);
      oe_debug_pub.add('x_template_name:  '|| l_template_name, 3);
      oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
   END IF;

/*
   IF l_template_id IS NOT NULL THEN
      --terms and conditions do exist for the BSA or Sales Order so return contract attachment string to workflow request
  */
   IF OE_CONTRACTS_UTIL.Terms_Exists
           (  p_doc_type  =>   p_doc_type
            , p_doc_id    =>   p_doc_id) = 'Y' THEN

      /************
      --get the version number for pk3 of contract attachment entity OKC_CONTRACT_DOCS
      IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
         IF c_get_bsa_version%ISOPEN THEN
            CLOSE c_get_bsa_version;
         END IF;

         OPEN c_get_bsa_version (p_doc_id);
         FETCH c_get_bsa_version INTO l_doc_version_number;
         CLOSE c_get_bsa_version;

         IF l_debug_level > 0 THEN
            oe_debug_pub.add('l_doc_version_number of blanket:  '|| l_doc_version_number, 3);
         END IF;

      ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
         IF c_get_so_version%ISOPEN THEN
            CLOSE c_get_so_version;
         END IF;

         OPEN c_get_so_version (p_doc_id);
         FETCH c_get_so_version INTO l_doc_version_number;
         CLOSE c_get_so_version;

         IF l_debug_level > 0 THEN
            oe_debug_pub.add('l_doc_version_number of sales order:  '|| l_doc_version_number, 3);
         END IF;

      END IF;
      ************/

      l_workflow_string := 'FND:entity=OKC_CONTRACT_DOCS'
                            || '&' || 'pk1name=BusinessDocumentType'
                            || '&' || 'pk2name=BusinessDocumentId'
                            || '&' || 'pk3name=BusinessDocumentVersion';


      l_workflow_string := l_workflow_string ||'&'|| 'pk1value=' || p_doc_type;
      l_workflow_string := l_workflow_string ||'&'|| 'pk2value=' || p_doc_id;
      -----l_workflow_string := l_workflow_string ||'&'|| 'pk3value=' || l_doc_version_number;
      l_workflow_string := l_workflow_string ||'&'|| 'pk3value=' || G_CURRENT_VERSION_NUMBER;    --i.e. -99
      l_workflow_string := l_workflow_string ||'&'|| 'categories=OKC_REPO_CONTRACT,OKC_REPO_APP_ABSTRACT';

   ELSE
      --NO terms and conditions exist for the BSA or Sales Order so return OM attachment string to workflow request
      --Attachment entities for blanket agreements and sales orders are the same.
      l_workflow_string := 'FND:entity=OE_ORDER_HEADERS' ||'&' || 'pk1name=HEADER_ID';
      l_workflow_string := l_workflow_string || '&' || 'pk1value=' || p_doc_id;
      l_workflow_string := l_workflow_string ||'&'|| 'categories=OE_PRINT_CATEGORY';
   END IF;

   IF l_debug_level > 0 THEN
       oe_debug_pub.add('l_workflow_string:  '|| l_workflow_string, 3);
       oe_debug_pub.add('End of OE_Contracts_util.attachment_location, x_return_status ' || x_return_status, 1);
   END IF;

   x_workflow_string := l_workflow_string;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN OTHERS in attachment_location ', 3);
   END IF;

   IF c_attachment_exist_check%ISOPEN THEN
      CLOSE c_attachment_exist_check;
   END IF;

   /********
   IF c_get_bsa_version%ISOPEN THEN
      CLOSE c_get_bsa_version;
   END IF;

   IF c_get_so_version%ISOPEN THEN
      CLOSE c_get_so_version;
   END IF;
   ********/


   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in attachment_location ', 3);
  END IF;

  IF c_attachment_exist_check%ISOPEN THEN
     CLOSE c_attachment_exist_check;
  END IF;

  /********
  IF c_get_bsa_version%ISOPEN THEN
     CLOSE c_get_bsa_version;
  END IF;

  IF c_get_so_version%ISOPEN THEN
     CLOSE c_get_so_version;
  END IF;
  ********/

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in attachment_location ', 3);
  END IF;

  IF c_attachment_exist_check%ISOPEN THEN
     CLOSE c_attachment_exist_check;
  END IF;

  /********
  IF c_get_bsa_version%ISOPEN THEN
     CLOSE c_get_bsa_version;
  END IF;

  IF c_get_so_version%ISOPEN THEN
     CLOSE c_get_so_version;
  END IF;
  ********/

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_terms_template'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );




END attachment_location;



/* Check if Blanket or Sales Order has any terms and conditions instantiated against it i.e. if
   an article template exists for the Blanket or Sales Order or not.
   This just translates the output of the already existing procedure 'get_terms_template'
   into a 'Y' or 'N'  */
-- needed and requested by the preview print application
FUNCTION terms_exists (
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER
)
RETURN VARCHAR2 IS

  l_debug_level      CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_result           VARCHAR2(1) := 'N';

/*  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_template_id         NUMBER;
  l_template_name       VARCHAR2(500);
*/
BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.terms_exists ', 1);
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contracts not licensed, exiting terms_exists', 3);
      END IF;
      --RETURN NULL;
      RETURN 'N';
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OE_Contracts_util.has_terms ', 3);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
   END IF;

   --first determine whether any terms and conditions have been instantiated for the BSA or sales order
/*   oe_contracts_util.get_terms_template (
      p_api_version                => 1.0,

      p_doc_type                   => p_doc_type,
      p_doc_id                     => p_doc_id,

      x_template_id                => l_template_id,
      x_template_name              => l_template_name,
      x_return_status              => l_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data
   );


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_template_id:  '|| l_template_id, 3);
      oe_debug_pub.add('l_template_name:  '|| l_template_name, 3);
      oe_debug_pub.add('l_return_status:  '|| l_return_status, 3);
   END IF;


   IF l_template_id IS NOT NULL THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('End of OE_Contracts_util.terms_exists  , returning Y');
      END IF;
      RETURN ('Y');
   ELSE
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('End of OE_Contracts_util.terms_exists  , returning Y');
      END IF;
      RETURN ('N');
   END IF;*/

   -- check if terms exist

   l_result := OKC_TERMS_UTIL_GRP.HAS_TERMS (
      p_document_type    => p_doc_type,
      p_document_id      => p_doc_id
   );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.terms_exists result is:'||l_result );
   END IF;

   RETURN l_result;

EXCEPTION


WHEN OTHERS THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN-OTHERS in terms_exists', 1);
   END IF;

   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'terms_exists'
        );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END terms_exists;



--delete articles belonging to the BSA or Sales Order
PROCEDURE delete_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.delete_articles ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting delete_articles ', 3);
      END IF;
      RETURN;
   END IF;



   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.delete_doc ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
      oe_debug_pub.add('p_commit: ' || p_commit,3);
   END IF;

   OKC_TERMS_UTIL_GRP.delete_doc (
      p_api_version       =>  p_api_version,
      p_init_msg_list     =>  p_init_msg_list,
      p_commit	          =>  p_commit,
      p_doc_type          =>  p_doc_type,
      p_doc_id            =>  p_doc_id,
      x_return_status     =>  x_return_status,
      x_msg_data          =>  x_msg_data,
      x_msg_count         =>  x_msg_count
   );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_return_status:  ' || x_return_status, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.delete_articles, x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in delete_articles ', 3);
   END IF;

   --close any cursors

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in delete_articles ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in delete_articles ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'delete_articles'
        );
  END IF;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END delete_articles;



--purge articles belonging to the BSA's or Sales Orders
PROCEDURE purge_articles
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_tbl                    IN  doc_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.purge_articles ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting purge_articles ', 3);
      END IF;
      RETURN;
   END IF;



   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.purge_articles ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_commit: ' || p_commit,3);
   END IF;

   OKC_TERMS_UTIL_GRP.purge_doc (
      p_api_version       =>  p_api_version,
      p_init_msg_list     =>  p_init_msg_list,
      p_commit	          =>  p_commit,
      p_doc_tbl           =>  p_doc_tbl,
      x_return_status     =>  x_return_status,
      x_msg_data          =>  x_msg_data,
      x_msg_count         =>  x_msg_count
   );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_return_status:  ' || x_return_status, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.purge_articles, x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in purge_articles ', 3);
   END IF;

   --close any cursors

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in purge_articles ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in purge_articles ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'purge_articles'
        );
  END IF;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END purge_articles;



PROCEDURE get_article_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_sys_var_value_tbl          IN OUT NOCOPY sys_var_value_tbl_type,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)


IS



  /** note: in cursors based on table OE_BLANKET_HEADERS_ALL, we select on the basis
      of HEADER_ID only as it is unique and an index is based on that, we don't need SALES_DOCUMENT_TYPE_CODE  **/

  --cursor to fetch value of header level variables such as OKC$S_BLANKET_NUMBER etc. for blankets
  CURSOR c_get_bsa_header_variables IS
  SELECT bh.order_number,
         bh.agreement_id,
         bh.sold_to_org_id,
         bh.order_type_id,
         bh.cust_po_number,
         bh.version_number,
         bh.sold_to_contact_id,
         bh.salesrep_id,
         bh.transactional_curr_code,
         bhe.start_date_active,
         bhe.end_date_active,
         bh.freight_terms_code,
         bh.shipping_method_code,
         bh.payment_term_id,
         bh.invoicing_rule_id,
         bhe.blanket_min_amount,
         bhe.blanket_max_amount,
         bh.org_id
  FROM   oe_blanket_headers_all bh,
         oe_blanket_headers_ext bhe
  WHERE  bh.header_id      =   p_doc_id
    AND  bh.order_number   =   bhe.order_number;


  --cursor to fetch value of header level variables such as OKC$S_ORDER_NUMBER etc. for sales orders
  CURSOR c_get_so_header_variables IS
  SELECT oh.order_number,
         oh.blanket_number,
         oh.agreement_id,
         oh.quote_number,
         oh.sold_to_org_id,
         oh.cust_po_number,
         oh.version_number,
         oh.sold_to_contact_id,
         oh.salesrep_id,
         oh.transactional_curr_code,
         oh.freight_terms_code,
         oh.shipping_method_code,
         oh.payment_term_id,
         oh.invoicing_rule_id,
         oh.org_id
  FROM   oe_order_headers_all   oh

  WHERE  oh.header_id      =   p_doc_id;




  l_bsa_header_variables c_get_bsa_header_variables%ROWTYPE;
  l_so_header_variables  c_get_so_header_variables%ROWTYPE;
  l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.get_article_variable_values for header level variables', 1);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type,3);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id,3);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;


  -- For articles QA: -
  -- Query OM tables OE_BLANKET_HEADERS_ALL and OE_BLANKET_HEADERS_EXT to retrieve values against variable codes
  -- sent in by calling articles QA API.

  ----IF p_sys_var_value_tbl.COUNT > 0 THEN
  IF p_sys_var_value_tbl.FIRST IS NOT NULL THEN

     IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN

        IF c_get_bsa_header_variables%ISOPEN THEN
           CLOSE c_get_bsa_header_variables;
        END IF;

        OPEN c_get_bsa_header_variables;
        FETCH c_get_bsa_header_variables INTO l_bsa_header_variables;
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('c_get_bsa_header_variables%ROWCOUNT:  ' || c_get_bsa_header_variables%ROWCOUNT, 3);
        END IF;
        CLOSE c_get_bsa_header_variables;

    ELSIF p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN

        IF c_get_bsa_header_variables%ISOPEN THEN
           CLOSE c_get_so_header_variables;
        END IF;

        OPEN c_get_so_header_variables;
        FETCH c_get_so_header_variables INTO l_so_header_variables;
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('c_get_so_header_variables%ROWCOUNT:  ' || c_get_so_header_variables%ROWCOUNT, 3);
        END IF;
        CLOSE c_get_so_header_variables;

    END IF;



     -----------------------------------------------------------------------------------------------
     FOR i IN p_sys_var_value_tbl.FIRST..p_sys_var_value_tbl.LAST LOOP


     IF p_sys_var_value_tbl(i).variable_code = 'OKC$S_ORDER_NUMBER'    THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.order_number;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_BLANKET_NUMBER'    THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.get_G_BSA_DOC_TYPE() THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.order_number;
           ELSIF p_doc_type = OE_CONTRACTS_UTIL.get_G_SO_DOC_TYPE() THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.blanket_number;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_PA_NUMBER'         THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.get_G_BSA_DOC_TYPE() THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.agreement_id;
           ELSIF p_doc_type = OE_CONTRACTS_UTIL.get_G_SO_DOC_TYPE() THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.agreement_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_PA_NAME'           THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.get_G_BSA_DOC_TYPE() THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.agreement_id;
           ELSIF p_doc_type = OE_CONTRACTS_UTIL.get_G_SO_DOC_TYPE() THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.agreement_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_QUOTE_NUMBER'      THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.quote_number;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CUSTOMER_NAME'     THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.sold_to_org_id;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sold_to_org_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CUSTOMER_NUMBER'   THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.sold_to_org_id;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sold_to_org_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_BLANKET_AGREEMENT_TYPE' THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.order_type_id;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CUST_PO_NUMBER'   THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.cust_po_number;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.cust_po_number;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_VERSION_NUMBER'   THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.version_number;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.version_number;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CUST_CONTACT_NAME' THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.sold_to_contact_id;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.sold_to_contact_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_SALESREP_NAME'     THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.salesrep_id;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.salesrep_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CURRENCY_CODE'     THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.transactional_curr_code;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.transactional_curr_code;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CURRENCY_NAME'     THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.transactional_curr_code;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.transactional_curr_code;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_CURRENCY_SYMBOL'     THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.transactional_curr_code;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.transactional_curr_code;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_ACTIVATION_DATE'   THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.start_date_active;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_EXPIRATION_DATE'   THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.end_date_active;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_FREIGHT_TERMS'     THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.freight_terms_code;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.freight_terms_code;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_SHIPPING_METHOD'   THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.shipping_method_code;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.shipping_method_code;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_PAYMENT_TERM'      THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.payment_term_id;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.payment_term_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_INVOICING_RULE'    THEN
        BEGIN
           IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.invoicing_rule_id;
           ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
              p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.invoicing_rule_id;
           END IF;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_MIN_AMOUNT_AGREED' THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.blanket_min_amount;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_MAX_AMOUNT_AGREED' THEN
        BEGIN
           p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.blanket_max_amount;
        END;

     ELSIF p_sys_var_value_tbl(i).variable_code = 'OKC$S_SUPPLIER_NAME' THEN
       BEGIN
          IF p_doc_type = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE THEN
             p_sys_var_value_tbl(i).variable_value_id := l_bsa_header_variables.org_id;
          ELSIF  p_doc_type = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE THEN
             p_sys_var_value_tbl(i).variable_value_id := l_so_header_variables.org_id;
          END IF;
       END;

     ELSE NULL;
     END IF;

     IF l_debug_level > 0 THEN
        oe_debug_pub.add(p_sys_var_value_tbl(i).variable_code || ':  ' || p_sys_var_value_tbl(i).variable_value_id, 3);
     END IF;


     END LOOP;
     -----------------------------------------------------------------------------------------------

  END IF;

  IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.get_article_variable_values for header level variables, x_return_status ' || x_return_status, 1);
  END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in get_article_variable_values ', 3);
   END IF;

   --close any cursors
   IF c_get_bsa_header_variables%ISOPEN THEN
      CLOSE c_get_bsa_header_variables;
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in get_article_variable_values ', 3);
   END IF;

   --close any cursors
   IF c_get_bsa_header_variables%ISOPEN THEN
      CLOSE c_get_bsa_header_variables;
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
   );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in get_article_variable_values ', 3);
  END IF;

  IF c_get_bsa_header_variables%ISOPEN THEN
     CLOSE c_get_bsa_header_variables;
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_article_variable_values'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END get_article_variable_values;




--this overloaded signature is called from the contract expert
PROCEDURE get_article_variable_values
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_line_var_tbl               IN  line_var_tbl_type,

   x_line_var_value_tbl         OUT NOCOPY sys_var_value_tbl_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) IS

  --cursor to get all the items of the BSA i.e. internal (INT) customer (CUST) etc.
  --returns non-translatable code eg. AS54888
  CURSOR c_get_items IS
  SELECT item_identifier_type,   --eg. INT
         ordered_item,           --eg. AS54888
         ordered_item_id,
         org_id,
         inventory_item_id,
         sold_to_org_id
  FROM   oe_blanket_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE
    AND  item_identifier_type <> 'CAT'

UNION ALL

  --cursor to get all the items of the Sales Order i.e. internal (INT) customer (CUST) etc.
  --returns non-translatable code eg. AS54888
  SELECT item_identifier_type,   --eg. INT
         ordered_item,           --eg. AS54888
         ordered_item_id,
         org_id,
         inventory_item_id,
         sold_to_org_id
  FROM   oe_order_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE
    AND  item_identifier_type <> 'CAT'
  ORDER BY ordered_item;




  --cursor to retrieve the item categories (CATs) in the BSA
  --returns non-translatable code eg. 208.05
  CURSOR c_get_item_categories IS
  SELECT ordered_item
  FROM   oe_blanket_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = OE_CONTRACTS_UTIL.G_BSA_DOC_TYPE
    AND  item_identifier_type = 'CAT'

UNION ALL

  --cursor to retrieve the item categories (CATs) in the Sales Order
  --returns non-translatable code eg. 208.05
  SELECT ordered_item
  FROM   oe_order_lines_all
  WHERE  header_id            =  p_doc_id
    AND  p_doc_type           = OE_CONTRACTS_UTIL.G_SO_DOC_TYPE
    AND  item_identifier_type = 'CAT'
  ORDER BY ordered_item;




  -- cursor to retrieve categories to which the INT (internal) and non-INT items in the BSA or Sales Order belong
  /** Note: the inventory_item_id stored in  OE_BLANKET_LINES_ALL OE_ORDER_LINES_ALL against the non-INT item is
      that of the mapped INT item so we can use it directly to get the item category **/
  --  returns non-translatable code eg. HOSPITAL.MISC
  CURSOR c_get_derived_item_category (cp_org_id             NUMBER,
                                      cp_inventory_item_id  NUMBER) IS
  SELECT category_concat_segs
  FROM   mtl_item_categories_v
  WHERE  inventory_item_id  =  cp_inventory_item_id
    AND  organization_id    =  cp_org_id     -- should be inventory master org
    AND  structure_id       =  101;          -- hardcoded to 101 i.e. Item Categories  (Inv. Items)  for Order Management


  l_bsa_derived_item_category    c_get_derived_item_category%ROWTYPE;

  j                              BINARY_INTEGER := 1;
  l_master_org_id                NUMBER;
  lx_ordered_item                VARCHAR2(2000);
  lx_inventory_item              VARCHAR2(2000);
  l_debug_level                  CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.get_article_variable_values for line level variables ', 1);
      oe_debug_pub.add('p_doc_type: ' || p_doc_type, 1);
      oe_debug_pub.add('p_doc_id: ' || p_doc_id, 1);
      oe_debug_pub.add('p_line_var_tbl.COUNT: ' || p_line_var_tbl.COUNT, 1);
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;


  -- For articles wizard expert: -
  -- Query OM tables OE_BLANKET_HEADERS_ALL and OE_BLANKET_LINES_ALL to retrieve values against variable codes sent
  -- in by calling articles wizard expert API

  IF p_line_var_tbl.FIRST IS NOT NULL THEN
     FOR i IN p_line_var_tbl.FIRST..p_line_var_tbl.LAST LOOP

        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Processing for ' || p_line_var_tbl(i), 3);
        END IF;

        IF p_line_var_tbl(i) = 'OKC$S_ITEMS' THEN

           FOR c_get_items_rec IN c_get_items LOOP
              --loop thru all the items for internal INT items
              IF l_debug_level > 0 THEN
                 oe_debug_pub.add('c_get_items_rec.item_identifier_type:  '||c_get_items_rec.item_identifier_type, 3);
              END IF;

              IF c_get_items_rec.item_identifier_type = 'INT' THEN
                 x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_INTERNAL_ITEM
                 x_line_var_value_tbl(j).variable_value_id   := c_get_items_rec.ordered_item; --eg. AS54888

              ELSIF c_get_items_rec.item_identifier_type <> 'INT' THEN
                 --map the non-INT items to INT items

                 --get inventory master org
                 /******************************************************/
                 -- FOR TESTING ONLY,  REMOVE WHEN DONE!  THIS CONTEXT WILL AUTOMATICALLY BE SET IN FORMS
                 -- dbms_application_info.set_client_info('204');
                 /******************************************************/
                 l_master_org_id := TO_NUMBER(oe_sys_parameters.value (
                                           param_name   => 'MASTER_ORGANIZATION_ID'
                                    ));

                 IF l_debug_level > 0 THEN
                    oe_debug_pub.add('l_master_org_id:  ' || l_master_org_id, 3);
                    oe_debug_pub.add('mapping non-INT item to INT item, Calling OE_Id_To_Value.Ordered_Item ', 3);
                 END IF;

                 --map non-INT item to INT item
                 OE_Id_To_Value.Ordered_Item (
                    p_item_identifier_type      =>  c_get_items_rec.item_identifier_type,
                    p_inventory_item_id         =>  c_get_items_rec.inventory_item_id,
                    p_organization_id           =>  l_master_org_id,
                    p_ordered_item_id           =>  c_get_items_rec.ordered_item_id,
                    p_sold_to_org_id            =>  c_get_items_rec.sold_to_org_id,
                    p_ordered_item              =>  c_get_items_rec.ordered_item,
                    x_ordered_item              =>  lx_ordered_item,
                    x_inventory_item            =>  lx_inventory_item
                  );

                  x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_INTERNAL_ITEM
                  x_line_var_value_tbl(j).variable_value_id   := lx_inventory_item;

                  IF l_debug_level > 0 THEN
                     oe_debug_pub.add('lx_inventory_item: ' || lx_inventory_item, 3);
                     oe_debug_pub.add('x_line_var_value_tbl(j).variable_code: ' || x_line_var_value_tbl(j).variable_code,3);
                     oe_debug_pub.add('x_line_var_value_tbl(j).variable_value_id: ' || x_line_var_value_tbl(j).variable_value_id,3);
                  END IF;


              END IF;

              j := j + 1;

           END LOOP;




        ELSIF p_line_var_tbl(i) = 'OKC$S_ITEM_CATEGORIES' THEN


           --get all the item categories in the BSA
           FOR c_get_item_categories_rec IN c_get_item_categories LOOP

              x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_ITEM_CATEGORIES
              x_line_var_value_tbl(j).variable_value_id   := c_get_item_categories_rec.ordered_item;

              IF l_debug_level > 0 THEN
                 oe_debug_pub.add('x_line_var_value_tbl(j).variable_code: ' || x_line_var_value_tbl(j).variable_code,3);
                 oe_debug_pub.add('x_line_var_value_tbl(j).variable_value_id: ' || x_line_var_value_tbl(j).variable_value_id,3);
              END IF;

              j := j + 1;

           END LOOP;

           --get the item categories to which the INT and non-INT items in the BSA belong to
           /** note: the inventory_item_id stored in oe_blanket_lines_all against the non-INT items is actually that of the mapped INT
                     item so we can use it directly to get the item category  **/
           FOR c_get_items_rec IN c_get_items LOOP

               --get inventory master org
               /******************************************************/
                 -- FOR TESTING ONLY,  REMOVE WHEN DONE!!!!!  THIS CONTEXT WILL AUTOMATICALLY BE SET IN FORMS
                 --dbms_application_info.set_client_info('204');
               /******************************************************/
               l_master_org_id := TO_NUMBER(oe_sys_parameters.value (
                                           param_name   => 'MASTER_ORGANIZATION_ID'
                                  ));

               IF l_debug_level > 0 THEN
                    oe_debug_pub.add('l_master_org_id:  ' || l_master_org_id, 3);
                    oe_debug_pub.add('get the item categories to which the INT and non-INT items in the BSA belong to',3);
               END IF;

               l_bsa_derived_item_category := null;  --initialize    !!!!!!! this causes NULL values: ref: Arun/Aftab issue
               IF c_get_derived_item_category%ISOPEN THEN
                  CLOSE c_get_derived_item_category;
               END IF;
               OPEN c_get_derived_item_category(l_master_org_id, c_get_items_rec.inventory_item_id);
               FETCH c_get_derived_item_category INTO l_bsa_derived_item_category;
               CLOSE c_get_derived_item_category;

               x_line_var_value_tbl(j).variable_code     := p_line_var_tbl(i); --i.e. OKC$S_ITEM_CATEGORIES
               x_line_var_value_tbl(j).variable_value_id   := l_bsa_derived_item_category.category_concat_segs;

               IF l_debug_level > 0 THEN
                  oe_debug_pub.add('x_line_var_value_tbl(j).variable_code: ' || x_line_var_value_tbl(j).variable_code,3);
                  oe_debug_pub.add('x_line_var_value_tbl(j).variable_value_id: ' || x_line_var_value_tbl(j).variable_value_id,3);
               END IF;

               j := j + 1;

           END LOOP;

        END IF;


     END LOOP;
  END IF;   ----IF p_line_var_tbl.FIRST IS NOT NULL THEN


  IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.get_article_variable_values for line level variables, x_return_status:  '|| x_return_status, 1);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in get_article_variable_values ', 3);
   END IF;

   --close any cursors
   IF c_get_derived_item_category%ISOPEN THEN
      CLOSE c_get_derived_item_category;
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/


   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in get_article_variable_values ', 3);
  END IF;

  --close any cursors
  IF c_get_derived_item_category%ISOPEN THEN
      CLOSE c_get_derived_item_category;
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in get_article_variable_values ', 3);
  END IF;

  --close any cursors
  IF c_get_derived_item_category%ISOPEN THEN
   CLOSE c_get_derived_item_category;
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_article_variable_values'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END get_article_variable_values;





--to return details about an article template being used by a particular BSA or Sales Order
PROCEDURE get_terms_template
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,

   x_template_id                OUT NOCOPY NUMBER,
   x_template_name              OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS


   l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;


BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.get_terms_template ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting get_terms_template ', 3);
      END IF;
      x_template_id   := NULL;
      x_template_name := NULL;
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.get_terms_template  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
   END IF;

   OKC_TERMS_UTIL_GRP.get_terms_template (
        p_api_version    =>  p_api_version,
        p_init_msg_list  =>  p_init_msg_list,
        ---p_commit         =>  p_commit,
        p_doc_type	 =>  p_doc_type,
        p_doc_id	 =>  p_doc_id,
        x_template_id	 =>  x_template_id,
        x_template_name	 =>  x_template_name,
        x_return_status  =>  x_return_status,
        x_msg_count      =>  x_msg_count,
        x_msg_data       =>  x_msg_data
    );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_template_id:  '|| x_template_id, 3);
      oe_debug_pub.add('x_template_name:  '|| x_template_name, 3);
      oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('End of OE_Contracts_util.get_terms_template , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in get_terms_template ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in get_terms_template ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in get_terms_template ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_terms_template'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END get_terms_template;




/* Gets the name of a contract template. It does not have to be instantiated against anything. */
FUNCTION Get_Template_Name(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_template_id      IN  NUMBER,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS


  l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_template_name       VARCHAR2(500);


BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.Get_Template_Name ', 1);
      oe_debug_pub.add('p_api_version: ' || p_api_version, 3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.Get_Template_Name',3);
      oe_debug_pub.add('p_tempate_id: ' || p_template_id,3);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting Get_Template_Name ', 3);
      END IF;
      RETURN TO_CHAR(NULL);   --returning null is OK here as null will be displayed
   END IF;


   l_template_name := OKC_TERMS_UTIL_GRP.Get_Template_Name(
            p_api_version     =>  p_api_version,
            p_init_msg_list   =>  p_init_msg_list,
            p_template_id     =>  p_template_id,
            x_return_status   =>  x_return_status,
            x_msg_data        =>  x_msg_data,
            x_msg_count       =>  x_msg_count
   );


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_return_status: ' || x_return_status, 3);
      oe_debug_pub.add('l_template_name: ' || l_template_name, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.Get_Template_Name, returning l_template_name: ' || l_template_name);
   END IF;

   RETURN l_template_name;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in Get_Template_Name ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in Get_Template_Name ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN OTHERS in Get_Template_Name ', 3);
   END IF;

   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'non_standard_article_exists'
        );
   END IF;

   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
   );

END Get_Template_Name;




--to instantiate T's/C's from a Terms template to a BSA or Sales Order
--used internally by instantiate_doc_terms
PROCEDURE instantiate_terms
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_template_id                IN  NUMBER,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_doc_start_date             IN  DATE ,
   p_doc_number                 IN  VARCHAR2,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS

   l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.instantiate_terms ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting instantiate_terms ', 3);
      END IF;
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_COPY_GRP.copy_terms  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_template_id:  ' || p_template_id, 3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
      oe_debug_pub.add('p_doc_start_date:  ' || p_doc_start_date, 3);
      oe_debug_pub.add('p_doc_number:  ' || p_doc_number, 3);
   END IF;


   OKC_TERMS_COPY_GRP.copy_terms (
        p_api_version             =>  p_api_version,
        p_init_msg_list           =>  p_init_msg_list,
        p_commit                  =>  p_commit,
        p_template_id	          =>  p_template_id,
        p_target_doc_type	  =>  p_doc_type,
        p_target_doc_id	          =>  p_doc_id,
        ------p_article_effective_date  =>  p_doc_start_date,  -- we should not pass effectivity date ref: Bug 3307561
        p_article_effective_date  =>  NULL,
        ------------------------------p_copy_deliverables  =>  'N',    parameter no longer exists
        p_validation_string       =>  NULL,
        p_document_number         =>  p_doc_number,
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data
   );

   IF l_debug_level > 0 THEN
       oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
   END IF;

   --ETR
   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;
   --ETR

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.instantiate_terms , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in instantiate_terms ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in instantiate_terms ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in instantiate_terms ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_terms_template'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END instantiate_terms;



--to instantiate T's/C's from a Terms template to a BSA or Sales Order when after saving the BSA/Sales Order
--the contract template id is defaulted for a new BSA or Sales Order
PROCEDURE instantiate_doc_terms
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,

   p_template_id                IN  NUMBER,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_doc_start_date             IN  DATE ,
   p_doc_number                 IN  VARCHAR2,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS

   l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;

   l_instntiatd_templt_id       NUMBER;
   lx_template_name             VARCHAR2(500);

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.instantiate_doc_terms ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

    --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting instantiate_doc_terms ', 3);
      END IF;
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_template_id:  ' || p_template_id, 3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
      oe_debug_pub.add('p_doc_start_date:  ' || p_doc_start_date, 3);
      oe_debug_pub.add('p_doc_number:  ' || p_doc_number, 3);
   END IF;



   /** In case , a contract template has already been freshly defaulted for the BSA or Sales Order, we need to instantiate
       the terms and conditions of the template for the BSA or Sales Order before invoking the articles authoring UI **/

   IF p_template_id IS NOT NULL THEN


            IF l_debug_level > 0 THEN
                oe_debug_pub.add('Calling oe_contracts_util.get_terms_template', 3);
            END IF;


            --first determine whether any terms and conditions have been instantiated for the BSA or Sales Order
            oe_contracts_util.get_terms_template (
               p_api_version                => 1.0,
               p_init_msg_list              => FND_API.G_FALSE,
               p_commit                     => FND_API.G_FALSE,

               p_doc_type                   => p_doc_type,
               p_doc_id                     => p_doc_id,

               x_template_id                => l_instntiatd_templt_id,
               x_template_name              => lx_template_name,
               x_return_status              => x_return_status,
               x_msg_count                  => x_msg_count,
               x_msg_data                   => x_msg_data
           );

           IF l_debug_level > 0 THEN
                oe_debug_pub.add('l_instntiatd_templt_id: ' || l_instntiatd_templt_id, 3);
                oe_debug_pub.add('x_return_status: ' || x_return_status, 3);
           END IF;


           IF l_instntiatd_templt_id IS NULL THEN
              /** i.e. the contract template freshly defaulted in the form has not yet been
                  instantiated so go ahead and instantiate it against the BSA or SO   **/

              IF l_debug_level > 0 THEN
                 oe_debug_pub.add('Calling oe_contracts_util.instantiate_terms', 3);
              END IF;

              oe_contracts_util.instantiate_terms (
                 p_api_version                => 1.0,
                 p_init_msg_list              => FND_API.G_FALSE,
                 p_commit                     => FND_API.G_TRUE,    --important: need to save before invoking articles UI

                 p_template_id                => p_template_id,
                 p_doc_type                   => p_doc_type,
                 p_doc_id                     => p_doc_id,
                 --------p_doc_start_date             => NVL(p_doc_start_date, SYSDATE),
                 p_doc_start_date             => null,         -- we should not pass effectivity date ref: Bug 3307561
                 p_doc_number                 => p_doc_number,
                 x_return_status              => x_return_status,
                 x_msg_count                  => x_msg_count,
                 x_msg_data                   => x_msg_data
              );


              IF l_debug_level > 0 THEN
                 oe_debug_pub.add('After trying to instantiate p_template_id: ' || p_template_id, 3);
                 oe_debug_pub.add('x_return_status: ' || x_return_status, 3);
              END IF;



           END IF;

         END IF;



   IF l_debug_level > 0 THEN
      oe_debug_pub.add('End of OE_Contracts_util.instantiate_doc_terms , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in instantiate_doc_terms ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   /*****
   not needed as per meeting
   --transfer error messages on OKC stack to OM stack
   OE_MSG_PUB.Transfer_Msg_Stack;
   *****/

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in instantiate_doc_terms ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
  not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in instantiate_doc_terms ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  /*****
   not needed as per meeting
  --transfer error messages on OKC stack to OM stack
  OE_MSG_PUB.Transfer_Msg_Stack;
  *****/

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_terms_template'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );




END instantiate_doc_terms;


--ETR
--This function is to check whether or not the given order has already been
--accepted (i.e signed). Returns 'Y' if accepted, and 'N' otherwise.
 FUNCTION Is_order_signed(
    p_api_version      IN  NUMBER,
    p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,

    p_doc_id           IN  NUMBER

   ) RETURN VARCHAR2 IS
    l_api_version      CONSTANT NUMBER := 1;
    l_api_name         CONSTANT VARCHAR2(30) := 'Is_order_signed';
    l_return_value     VARCHAR2(100) := 'N';
    --ETR
    l_sign_by          VARCHAR2(240);
    l_sign_date        DATE;
    --ETR
    l_debug_level      CONSTANT NUMBER := oe_debug_pub.g_debug_level;

    CURSOR find_ord_signed IS
     SELECT a.customer_signature,
            a.customer_signature_date
       FROM oe_order_headers_all a
       WHERE a.header_id = p_doc_id;

   BEGIN
    IF (l_debug_level > 0) THEN
       oe_debug_pub.add('In OE_Contracts_util.is_order_signed', 2);
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list  = FND_API.G_TRUE THEN
       oe_msg_pub.initialize;
    END IF;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Fetching customer_signature and customer_signature_date from oe_order_headers_all ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
    END IF;

    OPEN find_ord_signed;
    FETCH find_ord_signed INTO l_sign_by, l_sign_date;
    CLOSE find_ord_signed;

    /*************************************************
    IF l_sign_by IS NULL OR l_sign_date IS NULL THEN
       l_return_value :='N';
    ELSE
       l_return_value :='Y';
    END IF;
    *************************************************/
    IF l_sign_by IS NOT NULL OR l_sign_date IS NOT NULL THEN
       l_return_value :='Y';
    ELSE
       l_return_value :='N';
    END IF;


    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Order signed ?:  sign_by = ' || l_sign_by || ' sign_date = ' || l_sign_date, 3);
       oe_debug_pub.add('Order signed ?:  return value = ' || l_return_value, 3);
    END IF;

    IF (l_debug_level > 0) THEN
       oe_debug_pub.add('End of OE_Contracts_util.is_order_signed', 2);
    END IF;
    RETURN l_return_value;

   EXCEPTION

   WHEN OTHERS THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('WHEN-OTHERS in is_order_signed: '||sqlerrm, 1);
     END IF;
     IF find_ord_signed%ISOPEN THEN
        CLOSE find_ord_signed;
     END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'is_order_signed'
        );
     END IF;
     x_return_status := G_RET_STS_UNEXP_ERROR;
  END Is_order_signed ;
--ETR



--This function will be called from process order to copy terms and coditions
--from quote to order(terms instantiated on quote)
--from quote to order(terms not instantiated on quote) ,get terms from template
-- from sales order to sales order
--instantiate from template to sales order

PROCEDURE copy_doc
(
  p_api_version              IN  NUMBER,
  p_init_msg_list            IN  VARCHAR2,
  p_commit                   IN  VARCHAR2,
  p_source_doc_type          IN  VARCHAR2,
  p_source_doc_id            IN  NUMBER,
  p_target_doc_type          IN  VARCHAR2,
  p_target_doc_id            IN  NUMBER,
  p_contract_template_id     IN  NUMBER,
  x_return_status            OUT NOCOPY VARCHAR2,
  x_msg_count                OUT NOCOPY NUMBER,
  x_msg_data                 OUT NOCOPY VARCHAR2)

  IS

  l_target_doc_type   VARCHAR2(30):=   p_target_doc_type;
  l_target_doc_id     NUMBER      := p_target_doc_id;
  l_doc_template_name VARCHAR2(240):= null;
  l_debug_level       CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_keep_version      VARCHAR2(1) := 'Y';
  l_copy_attch       VARCHAR2(1) := 'N';
  l_document_number   NUMBER:= null;

BEGIN

  IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.copy_doc ', 1);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
  END IF;

--Check contract Licence
  IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed. Exiting copy_doc', 3);
      END IF;
      RETURN;
  END IF;


  IF l_debug_level > 0 THEN
         oe_debug_pub.add('Parameter Values passed', 3);
         oe_debug_pub.add('p_api_version: ' || p_api_version,3);
         oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
         oe_debug_pub.add('p_commit: ' || p_commit,3);
         oe_debug_pub.add('p_source_doc_type: ' || p_source_doc_type,3);
         oe_debug_pub.add('p_source_doc_id:  ' || p_source_doc_id, 3);
         oe_debug_pub.add('p_target_doc_type: ' || p_target_doc_type,3);
         oe_debug_pub.add('p_target_doc_id:  ' || p_target_doc_id, 3);
         oe_debug_pub.add('p_contract_template_id' || p_contract_template_id, 3);
  END IF;

  IF p_source_doc_id is not null Then
     l_doc_template_name :=  okc_terms_util_grp.Get_Terms_Template(
                                   p_doc_type  => p_source_doc_type,
                                   p_doc_id    => p_source_doc_id);
  END IF;

     IF p_target_doc_type = 'O' THEN
       BEGIN
         SELECT order_number
         INTO l_document_number
         FROM oe_order_headers_all
         WHERE header_id =  p_target_doc_id;
       EXCEPTION
	 WHEN NO_DATA_FOUND THEN
           l_document_number := NULL;
       END;
     END IF;
     If  l_debug_level > 0 THEN
         oe_debug_pub.add('l_document_number:  ' || l_document_number, 3);
     End If;

  IF  l_doc_template_name is null       THEN
  --Instantiate from the template
   If p_contract_template_id is not null then
     If  l_debug_level > 0 THEN
              oe_debug_pub.add('Instantiating COntract Terms, No articles on source document',3);
     End If;

     OKC_TERMS_COPY_GRP.copy_terms (
        p_api_version             =>  p_api_version,
        p_init_msg_list           =>  p_init_msg_list,
        p_commit                  =>  p_commit,
        p_template_id	         =>  p_contract_template_id,
        p_target_doc_type	    =>  l_target_doc_type,
        p_target_doc_id	         =>  p_target_doc_id,
        p_validation_string       =>  NULL,
        -----p_article_effective_date  => sysdate,     -- we should not pass effectivity date ref: Bug 3307561
        p_article_effective_date  => null,
        p_document_number	     =>  to_char(l_document_number),
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data);


        IF x_return_status = FND_API.G_RET_STS_ERROR Then
           RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   End If;
  ELSE
     If  l_debug_level > 0 THEN
             oe_debug_pub.add('Terms exist in source document',3);
     End If;

     If (p_source_doc_type <> p_target_doc_type) Then
         l_copy_attch := 'Y';
     Else
         l_keep_version :='N';
     End If;

     If (p_source_doc_type =p_target_doc_type and
          p_source_doc_id =p_target_doc_id) THEN

       If  l_debug_level > 0 THEN
             oe_debug_pub.add('Target Doc and Source Document are Same. exiting copy_doc',3);
       End If;
       RETURN;
     End If;

     If  l_debug_level > 0 THEN
         oe_debug_pub.add('Calling OKC_TERMS_COPY_GRP.copy_doc',3);
         oe_debug_pub.add('p_copy_doc_attachments: ' ||l_copy_attch,3);
         oe_debug_pub.add('p_keep_version:  ' || l_keep_version, 3);
         oe_debug_pub.add('p_target_doc_type: ' ||l_target_doc_type,3);
         oe_debug_pub.add('p_target_doc_id:  ' || l_target_doc_id, 3);
     End If;

     OKC_TERMS_COPY_GRP.copy_doc (
	   p_api_version             =>  p_api_version,
   	   p_init_msg_list           =>  p_init_msg_list,
           p_commit                  =>  p_commit,
	   p_source_doc_type         =>  p_source_doc_type,
           p_source_doc_id           =>  p_source_doc_id,
	   p_target_doc_type         =>  l_target_doc_type,
	   p_target_doc_id           =>  l_target_doc_id,
	   p_keep_version            =>  l_keep_version,
           -----p_article_effective_date  =>  sysdate,
           p_article_effective_date  =>  null,   -- we should not pass effectivity date ref: Bug 3307561
           p_copy_doc_attachments    =>  l_copy_attch,
	   x_return_status           =>  x_return_status,
	   x_msg_data                =>  x_msg_data,
	   x_msg_count               =>  x_msg_count,
 	   p_copy_abstract_yn        => 'Y');


        IF x_return_status = FND_API.G_RET_STS_ERROR Then
           RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


 END IF;

 If  l_debug_level > 0 THEN
             oe_debug_pub.add('Return Status  + x_return_status',3);
 End If;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in copy_doc ', 3);
   END IF;
   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in copy_doc ', 3);
  END IF;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data);

WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in copy_doc ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'copy_doc');
  END IF;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END COPY_DOC;




-- This function is a wrapper on top of oe_line_util.get_item_info
-- procedure. This is used to get the value and description for the products
-- in the blanket sales lines.
-- This will return the internal item and description for all but customer items
-- for which it returns the customer product and description
-- This function is used in the oe_blktprt_lines_v view, for the printing solution

FUNCTION GET_ITEM_INFO
(   p_item_or_desc                  IN VARCHAR2
,   p_item_identifier_type          IN VARCHAR2
,   p_inventory_item_id             IN Number
,   p_ordered_item_id               IN Number
,   p_sold_to_org_id                IN Number
,   p_ordered_item                  IN VARCHAR2
,   p_org_id                        IN Number DEFAULT NULL
) RETURN VARCHAR2 IS

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_ordered_item varchar2(2000);
 l_inventory_item varchar2(300);
 l_ordered_item_desc varchar2(2000);
 l_return_status varchar2(30);
 l_msg_count number := 0;
 l_msg_data varchar2(2000);
 l_value varchar2(2000);

BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER GET_ITEM_INFO FUNCTION' ) ;
       oe_debug_pub.add(  'ITEM_OR_DESC : '||P_ITEM_OR_DESC ) ;
       oe_debug_pub.add(  'ITEM_IDENTIFIER_TYPE : '||P_ITEM_IDENTIFIER_TYPE ) ;
       oe_debug_pub.add(  'INVENTORY_ITEM_ID : '||P_INVENTORY_ITEM_ID ) ;
       oe_debug_pub.add(  'ORDERED_ITEM_ID : '||P_ORDERED_ITEM_ID ) ;
       oe_debug_pub.add(  'ORDERED_ITEM : '||P_ORDERED_ITEM ) ;
       oe_debug_pub.add(  'SOLD_TO_ORG_ID : '||P_SOLD_TO_ORG_ID ) ;
   END IF;

OE_LINE_UTIL.GET_ITEM_INFO (
    x_return_status         => l_return_status
,   x_msg_count             => l_msg_count
,   x_msg_data              => l_msg_data
,   p_item_identifier_type  => p_item_identifier_type
,   p_inventory_item_id     => p_inventory_item_id
,   p_ordered_item_id       => p_ordered_item_id
,   p_sold_to_org_id        => p_sold_to_org_id
,   p_ordered_item          => p_ordered_item
,   x_ordered_item          => l_ordered_item
,   x_ordered_item_desc     => l_ordered_item_desc
,   x_inventory_item        => l_inventory_item
,   p_org_id                => p_org_id

);

IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Return status from OE_LINE_UTIL.GET_ITEM_INFO is '||l_return_status) ;
END IF;

IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
   RAISE FND_API.G_EXC_ERROR;
END IF;

IF p_item_or_desc = 'I' THEN
    l_value := l_inventory_item;
ELSIF p_item_or_desc = 'D' THEN
    l_value := l_ordered_item_desc;
END IF;

IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'l_value = '||l_value ) ;
END IF;

IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'EXIT GET_ITEM_INFO FUNCTION' ) ;
END IF;

RETURN l_value;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('In oe_contracts_util.get_item_info:g_exc_error section') ;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('In oe_contracts_util.get_item_info:g_exc_unexpected_error section') ;
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('In oe_contracts_util.get_item_info: when others section') ;
       END IF;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'GET_ITEM_INFO');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_ITEM_INFO;

--FP word integration
PROCEDURE get_contract_defaults
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_doc_type                   IN  VARCHAR2,
   p_template_id                IN  NUMBER,
   x_authoring_party            OUT NOCOPY VARCHAR2,
   x_contract_source            OUT NOCOPY VARCHAR2,
   x_template_name              OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS
   l_template_description	VARCHAR2(2000); -- bug 4382305
   l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.get_contract_defaults ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting get_terms_template ', 3);
      END IF;
      x_contract_source   := NULL;
      x_authoring_party   := NULL;
      x_template_name := NULL;
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.get_contract_defaults  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_template_id:  ' || p_template_id, 3);
   END IF;

  OKC_TERMS_UTIL_GRP.get_contract_defaults (
    p_api_version    		=>  p_api_version,
    p_init_msg_list  		=>  p_init_msg_list,
    x_return_status  		=>  x_return_status,
    x_msg_data       		=>  x_msg_data,
    x_msg_count      		=>  x_msg_count,
    p_template_id	 	=>  p_template_id,
    p_document_type	 	=>  p_doc_type,
    x_authoring_party      	=>  x_authoring_party,
    x_contract_source     	=>  x_contract_source,
    x_template_name	 	=>  x_template_name,
    x_template_description  	=>  l_template_description
    );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('p_template_id:  '|| p_template_id, 3);
      oe_debug_pub.add('x_contract_source:  '|| x_contract_source, 3);
      oe_debug_pub.add('x_authoring_party:  '|| x_authoring_party, 3);
      oe_debug_pub.add('x_template_name:  '|| x_template_name, 3);
      oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('End of OE_Contracts_util.get_contract_defaults , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in get_contract_defaults ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in get_contract_defaults ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in get_contract_defaults ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_contract_defaults'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END get_contract_defaults;


--get the template name, id, source and authoring party for the doc id
PROCEDURE get_contract_details_all
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER,
   p_document_version           IN  NUMBER := NULL,
   x_template_id                OUT NOCOPY  NUMBER,
   x_authoring_party            OUT NOCOPY VARCHAR2,
   x_contract_source            OUT NOCOPY VARCHAR2,
   x_contract_source_code       OUT NOCOPY VARCHAR2,
   x_has_primary_doc            OUT NOCOPY VARCHAR2,
   x_template_name              OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)

IS

    l_has_terms    		VARCHAR2(100);
    l_authoring_party_code  	VARCHAR2(100);
    l_template_description	VARCHAR2(2000); -- bug 4382305
    l_template_instruction	VARCHAR2(2000); -- bug 4382305
    l_is_primary_doc_mergeable	VARCHAR2(100);
    l_primary_doc_file_id    	VARCHAR2(100);
    l_debug_level               CONSTANT NUMBER := oe_debug_pub.g_debug_level;


BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.get_contract_details_all ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting get_contract_details_all ', 3);
      END IF;
      x_contract_source   := NULL;
      x_authoring_party   := NULL;
      x_template_name := NULL;
      x_template_id := NULL;
      RETURN;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.get_contract_details_all  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
   END IF;

   OKC_TERMS_UTIL_GRP.get_contract_details_all (
    p_api_version    		=>  p_api_version,
    p_init_msg_list  		=>  p_init_msg_list,
    x_return_status  		=>  x_return_status,
    x_msg_data       		=>  x_msg_data,
    x_msg_count      		=>  x_msg_count,
    p_document_type	 		=>  p_doc_type,
    p_document_id	 		=>  p_doc_id,
    p_document_version          =>  p_document_version,
    x_has_terms          	=>  l_has_terms,
    x_authoring_party_code 	=>  l_authoring_party_code,
    x_authoring_party      	=>  x_authoring_party,
    x_contract_source_code 	=>  x_contract_source_code,
    x_contract_source     	=>  x_contract_source,
    x_template_id	 	=>  x_template_id,
    x_template_name	 	=>  x_template_name,
    x_template_description  	=>  l_template_description,
    x_template_instruction   	=>  l_template_instruction,
    x_has_primary_doc       	=>  x_has_primary_doc,
    x_is_primary_doc_mergeable 	=>  l_is_primary_doc_mergeable,
    x_primary_doc_file_id     	=>  l_primary_doc_file_id
    );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('x_contract_source:  '|| x_contract_source, 3);
      oe_debug_pub.add('x_contract_source_code:  '|| x_contract_source_code, 3);
      oe_debug_pub.add('x_template_id:  '|| x_template_id, 3);
      oe_debug_pub.add('x_authoring_party:  '|| x_authoring_party, 3);
      oe_debug_pub.add('x_template_name:  '|| x_template_name, 3);
      oe_debug_pub.add('x_has_primary_doc:  '|| x_has_primary_doc, 3);
      oe_debug_pub.add('x_msg_data:  '|| x_msg_data, 3); -- bug 4382305
      oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('End of OE_Contracts_util.get_contract_details_all , x_return_status ' || x_return_status, 1);
   END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in get_contract_details_all ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in get_contract_details_all ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in get_contract_details_all ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'get_contract_details_all'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END get_contract_details_all;




--check if template attached to order type is valid or not
Function Is_Terms_Template_Valid
(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   p_doc_type                   IN  VARCHAR2,
   p_template_id                IN  NUMBER,
   p_org_id           		IN  NUMBER
) RETURN VARCHAR2 IS

  l_debug_level                CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_result VARCHAR2(1) := 'N';

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.Is_Terms_Template_Valid ', 1);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_init_msg_list  = FND_API.G_TRUE THEN
      oe_msg_pub.initialize;
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting Is_Terms_Template_Valid ', 3);
      END IF;
      RETURN NULL;
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.Is_Terms_Template_Valid  ', 3);
      oe_debug_pub.add('p_api_version: ' || p_api_version,3);
      oe_debug_pub.add('p_init_msg_list: ' || p_init_msg_list,3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_template_id:  ' || p_template_id, 3);
   END IF;

  l_result := OKC_TERMS_UTIL_GRP.Is_Terms_Template_Valid (
    p_api_version    		=>  p_api_version,
    p_init_msg_list  		=>  p_init_msg_list,
    x_return_status  		=>  x_return_status,
    x_msg_data       		=>  x_msg_data,
    x_msg_count      		=>  x_msg_count,
    p_template_id	 	=>  p_template_id,
    p_doc_type	 		=>  p_doc_type,
    p_org_id      		=>  p_org_id,
    p_valid_date      		=>  SYSDATE
    );


   IF l_debug_level > 0 THEN
      oe_debug_pub.add('p_template_id:  '|| p_template_id, 3);
      oe_debug_pub.add('x_return_status:  '|| x_return_status, 3);
     oe_debug_pub.add(' l_result:  '||  l_result, 3);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('End of OE_Contracts_util.Is_Terms_Template_Valid , x_return_status ' || x_return_status, 1);
   END IF;

   RETURN l_result;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN G_EXC_ERROR in Is_Terms_Template_Valid ', 3);
   END IF;

   x_return_status := FND_API.G_RET_STS_ERROR;

   --Get message count and data
   OE_MSG_PUB.Count_And_Get (
        p_count       => x_msg_count,
        p_data        => x_msg_data
   );


WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN G_EXC_UNEXPECTED_ERROR in Is_Terms_Template_Valid ', 3);
  END IF;

  --close any cursors

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
       p_count       => x_msg_count,
       p_data        => x_msg_data
  );


WHEN OTHERS THEN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('WHEN OTHERS in Is_Terms_Template_Valid ', 3);
  END IF;

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (
                     G_PKG_NAME,
                     'Is_Terms_Template_Valid'
        );
  END IF;


  --Get message count and data
  OE_MSG_PUB.Count_And_Get (
            p_count      => x_msg_count,
            p_data       => x_msg_data
  );

END Is_Terms_Template_Valid;


--Function to check if the Authoring Party is Internal, required by Preview and Print
Function Is_Auth_Party_Internal
(
   p_doc_type                   IN  VARCHAR2,
   p_doc_id                     IN  NUMBER
 )
RETURN VARCHAR2 IS
  l_debug_level      CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_authoring_party_code  	VARCHAR2(100);
BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.Is_Auth_Party_Internal ', 1);
   END IF;

   --Check for licensing
   IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence exiting Is_Auth_Party_Internal ', 3);
      END IF;

      RETURN 'N';
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OKC_TERMS_UTIL_GRP.Get_Authoring_Party_Code', 3);
      oe_debug_pub.add('p_doc_type:  ' || p_doc_type, 3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
   END IF;

   l_authoring_party_code  := OKC_TERMS_UTIL_GRP.Get_Authoring_Party_Code(
									  p_document_type =>  p_doc_type,
									  p_document_id   =>  p_doc_id
									  );

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_authoring_party_code '||  l_authoring_party_code, 3);
   END IF;

    IF l_authoring_party_code = 'INTERNAL_ORG' THEN
        RETURN 'Y';
    ELSE
	 RETURN 'N';
    END IF;

EXCEPTION

WHEN OTHERS THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN-OTHERS in Is_Auth_Party_Internal ', 1);
   END IF;

   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'Is_Auth_Party_Internal'
        );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Is_Auth_Party_Internal;

--Function to check if Recurring Charges is Enabled, required by Preview and Print
Function Is_RChg_Enabled
(
   p_doc_id                     IN  NUMBER
 )
RETURN VARCHAR2 IS
  l_debug_level      CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_rch_enabled      VARCHAR2(1) := 'N';
  l_org_id           NUMBER := NULL;

BEGIN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('In OE_Contracts_util.Is_RChg_Enabled ', 1);
   END IF;
   --Get the org_id
   BEGIN
       SELECT org_id into l_org_id
         FROM oe_order_headers_all
	 WHERE header_id=p_doc_id;
   EXCEPTION
      when others then
	 l_org_id:=NULL;
   END;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Calling OE_SYS_PARAMETER.VALUE(RECURRING_CHARGES)', 3);
      oe_debug_pub.add('p_doc_id:  ' || p_doc_id, 3);
      oe_debug_pub.add('l_org_id:  ' || l_org_id, 3);
   END IF;

   IF l_org_id is not null then
    l_rch_enabled := nvl(OE_SYS_PARAMETERS.VALUE('RECURRING_CHARGES',l_org_id),'N');
   ELSE
    l_rch_enabled := 'N';
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('l_rch_enabled '||  l_rch_enabled, 3);
   END IF;

   return l_rch_enabled;

EXCEPTION

WHEN OTHERS THEN

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('WHEN-OTHERS in Is_RChg_Enabled ', 1);
   END IF;

   IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                'Is_RChg_Enabled'
        );
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Is_RChg_Enabled;

END OE_Contracts_util;

/
