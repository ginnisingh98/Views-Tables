--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_COPY_PVT" AS
/* $Header: OKCVDCPB.pls 120.5.12010000.24 2013/10/10 11:41:49 skavutha ship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_COPY_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_TEMPLATE_DOC_TYPE            CONSTANT   okc_bus_doc_types_b.document_type%TYPE := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;
  G_ATTACHED_CONTRACT_SOURCE   CONSTANT   okc_template_usages.contract_source_code%TYPE := 'ATTACHED';

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30) := 'DELETED';
  G_STRUCT_CONTRACT_SOURCE     CONSTANT   VARCHAR2(30) := 'STRUCTURED';
  G_INTERNAL_PARTY_CODE        CONSTANT   VARCHAR2(30) := 'INTERNAL_ORG';
  G_COPY                       CONSTANT   VARCHAR2(30) := 'COPY';
  E_Resource_Busy              EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


FUNCTION get_orig_var_val_xml (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2,
 p_source_doc_id        IN      NUMBER,
 p_source_doc_type      IN      VARCHAR2,
 p_value_type           IN      VARCHAR2)
RETURN CLOB IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_orig_var_val_xml';
CURSOR csr_orig_target_dtls IS
SELECT kart1.id
FROM okc_articles_all lib,
     okc_k_articles_b kart,
     okc_k_articles_b kart1
WHERE lib.article_id =  kart.sav_sae_id
  AND kart.id= p_cat_id
  AND kart1.document_id = p_source_doc_id
  AND kart1.document_type = p_source_doc_type
  AND kart1.orig_system_reference_id1 = kart.orig_system_reference_id1;

CURSOR csr_source_value_id(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2)  IS
SELECT var.variable_value,
       var.variable_value_id
      , VAR.MR_VARIABLE_HTML
      , VAR.MR_VARIABLE_XML
FROM   okc_k_art_variables var
WHERE var.cat_id = p_cat_id
  AND var.variable_code = p_variable_code;

l_standard_flag     VARCHAR2(1);
l_id1 VARCHAR2(2000);
l_var_value_id okc_k_art_variables.variable_value_id%TYPE := NULL;
l_var_value  okc_k_art_variables.variable_value%TYPE := NULL;

l_MR_VARIABLE_HTML okc_k_art_variables.mr_variable_html%TYPE := to_clob(NULL);
l_MR_VARIABLE_XML  okc_k_art_variables.mr_variable_xml%TYPE  := to_clob(NULL);

BEGIN
 OPEN csr_orig_target_dtls;
   FETCH csr_orig_target_dtls INTO l_id1;
 CLOSE csr_orig_target_dtls;

 OPEN csr_source_value_id(p_cat_id=>l_id1,p_variable_code=>p_variable_code);
   FETCH csr_source_value_id INTO l_var_value,l_var_value_id,l_MR_VARIABLE_HTML,l_MR_VARIABLE_XML;
 CLOSE csr_source_value_id;

 IF p_value_type  = 'HTML' THEN
    RETURN l_MR_VARIABLE_HTML;
 ELSIF p_value_type  = 'XML' THEN
    RETURN l_MR_VARIABLE_XML;
 ELSE
   RETURN NULL;
 END IF;
END  get_orig_var_val_xml;

FUNCTION get_variable_value_id (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2)
RETURN VARCHAR2 IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_variable_value_id';
CURSOR csr_target_dtls IS
SELECT NVL(standard_yn,'N') standard_flag,
       kart.article_version_id,
       kart.ORIG_SYSTEM_REFERENCE_ID1
FROM okc_articles_all lib,
     okc_k_articles_b kart
WHERE lib.article_id =  kart.sav_sae_id
  AND kart.id= p_cat_id;

CURSOR csr_source_dtls(p_cat_id IN NUMBER) IS
SELECT article_version_id
FROM  okc_k_articles_b
WHERE id = p_cat_id;

CURSOR csr_source_value_id(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2)  IS
SELECT VAR.VARIABLE_VALUE_ID
FROM   OKC_K_ART_VARIABLES VAR
WHERE VAR.CAT_ID = p_cat_id
  AND VAR.VARIABLE_CODE = p_variable_code;

l_standard_flag     VARCHAR2(1);
l_ORIG_SYSTEM_REFERENCE_ID1 VARCHAR2(1000);
l_target_article_version_id NUMBER;
l_source_article_version_id NUMBER;
l_source_value_id  VARCHAR2(1000):= NULL;

BEGIN
 OPEN csr_target_dtls;
   FETCH csr_target_dtls INTO l_standard_flag, l_target_article_version_id, l_ORIG_SYSTEM_REFERENCE_ID1;
 CLOSE csr_target_dtls;


 -- bug 3369336
 -- copy variable values if the variable exists in the target doc article
 -- without comparing version or if it was non standard (bug 3397895 )

    OPEN csr_source_value_id(p_cat_id=>l_ORIG_SYSTEM_REFERENCE_ID1,p_variable_code=>p_variable_code);
      FETCH csr_source_value_id INTO l_source_value_id;
    CLOSE csr_source_value_id;

 RETURN l_source_value_id;

END get_variable_value_id;

FUNCTION get_orig_var_val (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2,
 p_source_doc_id        IN      NUMBER,
 p_source_doc_type      IN      VARCHAR2,
 p_value_type           IN      VARCHAR2)
RETURN VARCHAR2 IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_orig_var_val';
CURSOR csr_orig_target_dtls IS
SELECT kart1.id
FROM okc_articles_all lib,
     okc_k_articles_b kart,
     okc_k_articles_b kart1
WHERE lib.article_id =  kart.sav_sae_id
  AND kart.id= p_cat_id
  AND kart1.document_id = p_source_doc_id
  AND kart1.document_type = p_source_doc_type
  AND kart1.orig_system_reference_id1 = kart.orig_system_reference_id1;

CURSOR csr_source_value_id(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2)  IS
SELECT var.variable_value,
       var.variable_value_id
     -- , VAR.MR_VARIABLE_HTML
     -- , VAR.MR_VARIABLE_XML
FROM   okc_k_art_variables var
WHERE var.cat_id = p_cat_id
  AND var.variable_code = p_variable_code;

l_standard_flag     VARCHAR2(1);
l_id1 VARCHAR2(2000);
l_var_value_id okc_k_art_variables.variable_value_id%TYPE := NULL;
l_var_value  okc_k_art_variables.variable_value%TYPE := NULL;

l_MR_VARIABLE_HTML okc_k_art_variables.mr_variable_html%TYPE := to_clob(NULL);
l_MR_VARIABLE_XML  okc_k_art_variables.mr_variable_xml%TYPE  := to_clob(NULL);

BEGIN
 OPEN csr_orig_target_dtls;
   FETCH csr_orig_target_dtls INTO l_id1;
 CLOSE csr_orig_target_dtls;

 OPEN csr_source_value_id(p_cat_id=>l_id1,p_variable_code=>p_variable_code);
   FETCH csr_source_value_id INTO l_var_value,l_var_value_id; --,l_MR_VARIABLE_HTML,l_MR_VARIABLE_XML;
 CLOSE csr_source_value_id;

 IF p_value_type = 'ID' THEN
   RETURN l_var_value_id;
 ELSIF p_value_type = 'CAT_ID' THEN
   RETURN l_id1;
 /*ELSIF p_value_type  = 'HTML' THEN
    RETURN l_MR_VARIABLE_HTML;
 ELSIF p_value_type  = 'XML' THEN
    RETURN l_MR_VARIABLE_XML;  */
 ELSE
   RETURN l_var_value;
 END IF;

END get_orig_var_val;


FUNCTION get_variable_value (
 p_cat_id               IN      NUMBER,
 p_variable_code        IN      VARCHAR2)
RETURN VARCHAR2 IS
l_api_name                     CONSTANT VARCHAR2(30) := 'get_variable_value';
CURSOR csr_target_dtls IS
SELECT NVL(standard_yn,'N') standard_flag,
       kart.article_version_id,
       kart.ORIG_SYSTEM_REFERENCE_ID1
FROM okc_articles_all lib,
     okc_k_articles_b kart
WHERE lib.article_id =  kart.sav_sae_id
  AND kart.id= p_cat_id;

CURSOR csr_source_dtls(p_cat_id IN NUMBER) IS
SELECT article_version_id
FROM  okc_k_articles_b
WHERE id = p_cat_id;

CURSOR csr_source_value(p_cat_id IN NUMBER,p_variable_code IN VARCHAR2)  IS
SELECT VAR.VARIABLE_VALUE
FROM   OKC_K_ART_VARIABLES VAR
WHERE VAR.CAT_ID = p_cat_id
  AND VAR.VARIABLE_CODE = p_variable_code;

l_standard_flag     VARCHAR2(1);
l_ORIG_SYSTEM_REFERENCE_ID1 VARCHAR2(1000);
l_target_article_version_id NUMBER;
l_source_article_version_id NUMBER;
l_source_value  VARCHAR2(2000):= NULL;

BEGIN
 OPEN csr_target_dtls;
   FETCH csr_target_dtls INTO l_standard_flag, l_target_article_version_id, l_ORIG_SYSTEM_REFERENCE_ID1;
 CLOSE csr_target_dtls;

 -- bug 3369336
 -- copy variable values if the variable exists in the target doc article
 -- without comparing version or if it was non standard (bug 3397895 )

    OPEN csr_source_value(p_cat_id=>l_ORIG_SYSTEM_REFERENCE_ID1,p_variable_code=>p_variable_code);
      FETCH csr_source_value INTO l_source_value;
    CLOSE csr_source_value;

 RETURN l_source_value;

END get_variable_value;

--CLM Changes
FUNCTION clm_scn_filtering (
 p_source_doc_id               IN      NUMBER,
 p_source_doc_type             IN      VARCHAR2,
 p_target_doc_id               IN      NUMBER,
 p_target_doc_type             IN      VARCHAR2)
RETURN VARCHAR2 IS
l_api_name                     CONSTANT VARCHAR2(30) := 'clm_scn_filtering';
l_source_doc_type_class  VARCHAR2(100);
l_target_doc_type_class  VARCHAR2(100);
l_src_amend NUMBER;
l_tar_amend NUMBER;

CURSOR c_get_doc_type_class (c_doc_type VARCHAR2) IS
SELECT document_type_class
FROM okc_bus_doc_types_b
WHERE document_type = c_doc_type;

CURSOR c_check_sol_amendment(c_doc_id NUMBER) IS
SELECT Nvl(AMENDMENT_NUMBER,0) FROM PON_AUCTION_HEADERS_ALL
WHERE AUCTION_HEADER_ID = c_doc_id;

BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside OKC_TERMS_COPY_PVT.clm_scn_filtering');
  END IF;


  OPEN c_get_doc_type_class(p_source_doc_type);
  FETCH c_get_doc_type_class INTO l_source_doc_type_class;
  CLOSE c_get_doc_type_class;

  OPEN c_get_doc_type_class(p_target_doc_type);
  FETCH c_get_doc_type_class INTO l_target_doc_type_class;
  CLOSE c_get_doc_type_class;

  IF l_source_doc_type_class = 'PO' THEN
     IF p_source_doc_type LIKE '%MOD' AND p_target_doc_type NOT LIKE '%MOD' THEN
        RETURN 'DROP_AMEND_SEC';
     END IF;
  END IF;

  IF l_source_doc_type_class = 'SOURCING' THEN
     IF p_source_doc_type = 'SOLICITATION' AND p_target_doc_type = 'SOLICITATION' THEN

        OPEN c_check_sol_amendment(p_source_doc_id);
        FETCH c_check_sol_amendment INTO l_src_amend;
        CLOSE c_check_sol_amendment;
        OPEN c_check_sol_amendment(p_target_doc_id);
        FETCH c_check_sol_amendment INTO l_tar_amend;
        CLOSE c_check_sol_amendment;

         IF l_src_amend > 0 AND l_tar_amend = 0 THEN
            RETURN 'DROP_AMEND_SEC';
         END IF;
      END IF;

      IF l_target_doc_type_class = 'PO' THEN
         RETURN 'DROP_PROV_SEC';
      END IF;
  END IF;

  RETURN 'DROP_NOTHING';
EXCEPTION
WHEN OTHERS THEN
  RETURN 'DROP_NOTHING';
END clm_scn_filtering;


procedure copy_article_variables(
                                p_target_doc_type       IN      VARCHAR2,
                                p_source_doc_type       IN      VARCHAR2,
                                p_target_doc_id         IN      NUMBER,
                                p_source_doc_id         IN      NUMBER,
                                p_get_from_library      IN      VARCHAR2,
                                p_keep_orig_ref         IN      VARCHAR2 := 'N',
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_data              OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER
                                ,p_retain_lock_terms_yn   IN       VARCHAR2 DEFAULT 'N'
                                ) IS
-- This cursor will get variable code and values either from library
l_api_name                     CONSTANT VARCHAR2(30) := 'copy_article_variables';
CURSOR l_get_lib_variables_csr IS
SELECT KART.ID CAT_ID,
       VAR.VARIABLE_CODE,
       BUSVAR.VARIABLE_TYPE,
       BUSVAR.EXTERNAL_YN,
       BUSVAR.VALUE_SET_ID,
       Decode(Nvl(BUSVAR.mrv_flag,'N'), 'Y', NULL, DECODE(p_keep_orig_ref,'Y',get_orig_var_val(
                                                    KART.ID,VAR.VARIABLE_CODE,
                                                    P_SOURCE_DOC_ID,P_SOURCE_DOC_TYPE,'VALUE'),
                                                    get_variable_value(KART.ID,VAR.VARIABLE_CODE)
                                                    )) VARIABLE_VALUE,
       Decode (Nvl(BUSVAR.mrv_flag,'N'), 'Y', NULL, DECODE(p_keep_orig_ref,'Y',get_orig_var_val(
                                     KART.ID,VAR.VARIABLE_CODE,
                                     P_SOURCE_DOC_ID,P_SOURCE_DOC_TYPE,'ID'),
                                     get_variable_value_id(KART.ID,VAR.VARIABLE_CODE)
                                  )) VARIABLE_VALUE_ID,
       'N' OVERRIDE_GLOBAL_YN,
       Decode( Nvl(BUSVAR.mrv_flag,'N'), 'Y',
                                            DECODE(p_keep_orig_ref,'Y',
                                                                   get_orig_var_val_xml(
                                                    KART.ID,VAR.VARIABLE_CODE,
                                                    P_SOURCE_DOC_ID,P_SOURCE_DOC_TYPE,'HTML')
                                                                   ,(SELECT src.mr_variable_html FROM okc_k_art_variables src WHERE src.cat_id= KART.orig_system_reference_id1 AND  src. variable_code = VAR.variable_code)
                                                      )
                                             ,to_clob(NULL)) mr_variable_html,
       Decode(Nvl(BUSVAR.mrv_flag,'N'), 'Y',  DECODE(p_keep_orig_ref,
                                                    'Y',get_orig_var_val_xml(
                                                    KART.ID,VAR.VARIABLE_CODE,
                                                    P_SOURCE_DOC_ID,P_SOURCE_DOC_TYPE,'XML')
                                                    ,(SELECT src.mr_variable_xml FROM okc_k_art_variables src WHERE src.cat_id= KART.orig_system_reference_id1  AND src.variable_code = VAR.variable_code)
                                                    )
                                             ,to_clob(NULL)) mr_variable_xml,

       Decode(Nvl(BUSVAR.mrv_flag,'N'), 'Y', DECODE(p_keep_orig_ref,
                                                    'Y', To_Number(get_orig_var_val(
                                                    KART.ID,VAR.VARIABLE_CODE,
                                                    P_SOURCE_DOC_ID,P_SOURCE_DOC_TYPE,'CAT_ID'))
                                                    ,KART.orig_system_reference_id1
                                                    )
                                             ,NULL) SourceCatId
FROM   OKC_ARTICLE_VARIABLES VAR,
       OKC_K_ARTICLES_B KART,
       OKC_BUS_VARIABLES_B BUSVAR
WHERE  KART.ARTICLE_VERSION_ID=VAR.ARTICLE_VERSION_ID
   AND KART.DOCUMENT_TYPE=p_target_doc_type
   AND KART.DOCUMENT_ID=p_target_doc_id
   AND BUSVAR.VARIABLE_CODE=VAR.VARIABLE_CODE
   AND not exists ( select 'x' from okc_k_art_variables where cat_id=kart.id);

-- This cursor will get variable code and values fromr okc_k_art_variables
CURSOR l_get_variables_csr IS
SELECT KART.ID CAT_ID,
       VAR.VARIABLE_CODE,
       BUSVAR.VARIABLE_TYPE,
       BUSVAR.EXTERNAL_YN,
       BUSVAR.VALUE_SET_ID,
       VAR.VARIABLE_VALUE,
       VAR.VARIABLE_VALUE_ID,
       VAR.OVERRIDE_GLOBAL_YN,
       VAR.mr_variable_html,
       VAR.mr_variable_xml,
       KART1.id SourceCatId
FROM   OKC_K_ART_VARIABLES VAR,
       OKC_K_ARTICLES_B KART,
       OKC_K_ARTICLES_B KART1,
       OKC_BUS_VARIABLES_B BUSVAR
WHERE KART.DOCUMENT_TYPE=p_target_doc_type
  AND KART.DOCUMENT_ID=p_target_doc_id
  AND KART1.DOCUMENT_TYPE=p_source_doc_type
  AND KART1.DOCUMENT_ID=p_source_doc_id
  AND KART.ORIG_SYSTEM_REFERENCE_CODE=G_COPY
  AND ((KART.ORIG_SYSTEM_REFERENCE_ID1=KART1.ID AND P_KEEP_ORIG_REF = 'N') OR
       (KART.ORIG_SYSTEM_REFERENCE_ID1=KART1.ORIG_SYSTEM_REFERENCE_ID1 AND P_KEEP_ORIG_REF = 'Y'))
  AND KART1.ID=VAR.CAT_ID
  AND BUSVAR.VARIABLE_CODE=VAR.VARIABLE_CODE
   AND ( p_retain_lock_terms_yn = 'N'
        OR
        ( p_retain_lock_terms_yn = 'Y'
          AND NOT EXISTS ( SELECT 'LOCKEXISTS'
                              FROM okc_k_entity_locks
                           WHERE entity_name='CLAUSE'
                           AND   entity_pk1 = To_Char(KART.id)
                           AND   lock_by_document_type=p_target_doc_type
                           AND   lock_by_document_id=p_target_doc_id
                          )
         )
      );

TYPE CatList IS TABLE OF OKC_K_ART_VARIABLES.CAT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VarList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE VarTypeList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE ExternalList IS TABLE OF OKC_K_ART_VARIABLES.EXTERNAL_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE ValSetList IS TABLE OF OKC_K_ART_VARIABLES.ATTRIBUTE_VALUE_SET_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VarValList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_VALUE%TYPE INDEX BY BINARY_INTEGER;
TYPE VarIdList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_VALUE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE OverrideGlobalYnList IS TABLE OF OKC_K_ART_VARIABLES.OVERRIDE_GLOBAL_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE mrvariablehtmlList IS TABLE OF OKC_K_ART_VARIABLES.mr_variable_html%TYPE INDEX BY BINARY_INTEGER;
TYPE mrvariablexmlList IS TABLE OF  OKC_K_ART_VARIABLES.mr_variable_xml%TYPE  INDEX BY BINARY_INTEGER;

cat_tbl           CatList;
var_tbl           VarList;
var_type_tbl      VarTypeList;
external_yn_tbl   ExternalList;
value_set_id_tbl  ValSetList;
var_value_tbl     VarValList;
var_value_id_tbl  VarIdList;
override_global_yn_tbl  OverrideGlobalYnList;
-- Multi Row Variable project --serukull
mrvariablehtml_tbl   mrvariablehtmlList;
mrvariablexml_tbl   mrvariablexmlList;
SourceCatIdTbl      CatList;

dochasmrv VARCHAR2(1);




BEGIN

  x_return_status :=  G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside OKC_TERMS_COPY_PVT.copy_article_variables');
  END IF;
  IF p_get_from_library='Y' THEN
-- Bulk collecting
     OPEN  l_get_lib_variables_csr;
     FETCH l_get_lib_variables_csr BULK COLLECT INTO cat_tbl,
                                                 var_tbl,
                                                 var_type_tbl,
                                                 external_yn_tbl,
                                                 value_set_id_tbl,
                                                 var_value_tbl,
                                                 var_value_id_tbl,
                                                 override_global_yn_tbl,
                                                 mrvariablehtml_tbl,
                                                 mrvariablexml_tbl,
                                                 SourceCatIdTbl;

     CLOSE l_get_lib_variables_csr;

  ELSE
-- Bulk collecting
     OPEN  l_get_variables_csr;
     FETCH l_get_variables_csr BULK COLLECT INTO cat_tbl,
                                                 var_tbl,
                                                 var_type_tbl,
                                                 external_yn_tbl,
                                                 value_set_id_tbl,
                                                 var_value_tbl,
                                                 var_value_id_tbl,
                                                 override_global_yn_tbl,
                                                 mrvariablehtml_tbl,
                                                 mrvariablexml_tbl,
                                                 SourceCatIdTbl
                                                 ;
     CLOSE l_get_variables_csr;
  END IF;

-- Bulk inserting
  IF cat_tbl.COUNT>0 THEN
     FORALL i IN cat_tbl.FIRST..cat_tbl.LAST
            INSERT INTO OKC_K_ART_VARIABLES(cat_id,
                                            variable_code,
                                            variable_type,
                                            external_yn,
                                            attribute_value_set_id,
                                            variable_value,
                                            variable_value_id,
                                            override_global_yn,
                                            mr_variable_html,
                                            mr_variable_xml,
                                            object_version_number,
                                            creation_date,
                                            created_by,
                                            last_update_date,
                                            last_updated_by,
                                            last_update_login)
            VALUES (cat_tbl(i),
                    var_tbl(i),
                    var_type_tbl(i),
                    external_yn_tbl(i),
                    value_set_id_tbl(i),
                    var_value_tbl(i),
                    var_value_id_tbl(i),
                    override_global_yn_tbl(i),
                    mrvariablehtml_tbl(i),
                    mrvariablexml_tbl(i),
                    1,
                    sysdate,
                    Fnd_Global.User_Id,
                    sysdate,
                    Fnd_Global.User_Id,
                    Fnd_Global.Login_Id);

  END IF;

-- MRV changes Start
-- Check if Source doc has MRV

okc_mrv_util.checkdochasmrv(  docid => p_source_doc_id
                              , doctype =>p_source_doc_type
                              , dochasmrv => dochasmrv);

IF  Nvl(dochasmrv,'N')='Y' THEN
  FOR i IN SourceCatIdTbl.FIRST..SourceCatIdTbl.LAST
   LOOP
     IF mrvariablexml_tbl(i) IS NOT NULL AND SourceCatIdTbl(i) IS NOT NULL THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400: Calling UDA copy for Cat Id :'||SourceCatIdTbl(i));
          END IF;
        -- Call to UDA API.
           okc_mrv_util.copy_variable_uda_data( p_from_cat_id          => SourceCatIdTbl(i),
                                                p_from_variable_code   => var_tbl(i),
                                                p_to_cat_id            => cat_tbl(i),
                                                p_to_variable_code     => var_tbl(i),
                                                x_return_status        => x_return_status,
                                                x_msg_count            => x_msg_count,
                                                x_msg_data             => x_msg_data
                                               );
           IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
          END IF;
     END IF;   -- mrvariablexml_tbl(i) is not null
   END LOOP;
END IF;     -- dochasmrv
-- MRV changes End




  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: Leaving copy_article_variables '||x_return_status);
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving copy_article_variables:FND_API.G_EXC_ERROR Exception');
  END IF;

  IF  l_get_variables_csr%ISOPEN THEN
   CLOSE l_get_variables_csr;
  END IF;
  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_article_variables:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
  END IF;

  IF  l_get_variables_csr%ISOPEN THEN
   CLOSE l_get_variables_csr;
  END IF;
  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving copy_article_variables because of EXCEPTION: '||sqlerrm);
  END IF;

  IF  l_get_variables_csr%ISOPEN THEN
   CLOSE l_get_variables_csr;
  END IF;
  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);
  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END copy_article_variables;


procedure copy_articles(
                      p_target_doc_type         IN      VARCHAR2,
                      p_source_doc_type         IN      VARCHAR2,
                      p_target_doc_id           IN      NUMBER,
                      P_source_doc_id           IN      NUMBER,
                      p_keep_version            IN      VARCHAR2,
                      p_article_effective_date  IN      DATE,
                      p_source_version_number   IN      NUMBER := NULL,
                      p_copy_from_archive       IN      VARCHAR2 := 'N',
                      p_keep_orig_ref           IN      VARCHAR2 := 'N',
                      x_return_status           OUT NOCOPY VARCHAR2,
                      x_msg_data                OUT NOCOPY VARCHAR2,
                      x_msg_count               OUT NOCOPY NUMBER,
                      p_retain_clauses          IN       VARCHAR2 DEFAULT 'N'
                      ,p_retain_lock_terms_yn   IN       VARCHAR2 DEFAULT 'N') IS
l_api_name                     CONSTANT VARCHAR2(30) := 'copy_articles';
l_prov_allowed VARCHAR2(1) ;
l_discard      Boolean;
l_standard_yn  VARCHAR2(1) ;
l_global_yn    VARCHAR2(1) ;
l_org_id       OKC_TERMS_TEMPLATES_ALL.ORG_ID%TYPE;
l_art_title    OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE;
k              NUMBER := 0;

TYPE SavSaeIdList               IS TABLE OF OKC_K_ARTICLES_B.SAV_SAE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE AttributeCategoryList      IS TABLE OF OKC_K_ARTICLES_B.ATTRIBUTE_CATEGORY%TYPE INDEX BY BINARY_INTEGER;
TYPE AttributeList              IS TABLE OF OKC_K_ARTICLES_B.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;
TYPE SourceFlagList             IS TABLE OF OKC_K_ARTICLES_B.SOURCE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE ArticleVersionIdList       IS TABLE OF OKC_K_ARTICLES_B.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE MandatoryYnList            IS TABLE OF OKC_K_ARTICLES_B.MANDATORY_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE MandatoryRwaList           IS TABLE OF OKC_K_ARTICLES_B.MANDATORY_RWA%TYPE INDEX BY BINARY_INTEGER;
TYPE ChangeNonStdYnList         IS TABLE OF OKC_K_ARTICLES_B.CHANGE_NONSTD_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE ScnIdList                  IS TABLE OF OKC_K_ARTICLES_B.SCN_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE OrigSystemReferenceId1List IS TABLE OF OKC_K_ARTICLES_B.ORIG_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER;
TYPE LabelList                  IS TABLE OF OKC_K_ARTICLES_B.LABEL%TYPE INDEX BY BINARY_INTEGER;
TYPE DisplaySequenceList        IS TABLE OF OKC_K_ARTICLES_B.DISPLAY_SEQUENCE%TYPE INDEX BY BINARY_INTEGER;
TYPE RefArticleIdList           IS TABLE OF OKC_K_ARTICLES_B.REF_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE RefArticleVersionIdList    IS TABLE OF OKC_K_ARTICLES_B.REF_ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE OrigArticleIdList          IS TABLE OF OKC_K_ARTICLES_B.ORIG_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER;

sav_sae_tbl                    SavSaeIdList;
Attribute_category_tbl         AttributeCategoryList;
Attribute1_tbl                 AttributeList;
Attribute2_tbl                 AttributeList;
Attribute3_tbl                 AttributeList;
Attribute4_tbl                 AttributeList;
Attribute5_tbl                 AttributeList;
Attribute6_tbl                 AttributeList;
Attribute7_tbl                 AttributeList;
Attribute8_tbl                 AttributeList;
Attribute9_tbl                 AttributeList;
Attribute10_tbl                AttributeList;
Attribute11_tbl                AttributeList;
Attribute12_tbl                AttributeList;
Attribute13_tbl                AttributeList;
Attribute14_tbl                AttributeList;
Attribute15_tbl                AttributeList;
Ref_article_id_tbl             RefArticleIdList;
Ref_article_version_id_tbl     RefArticleVersionIdList;
orig_article_id_tbl            OrigArticleIdList;

Source_flag_tbl                SourceFlagList;
Article_Version_tbl            ArticleVersionIdList;
Change_nonstd_yn_tbl           ChangeNonStdYnList;
Scn_id_tbl                     ScnIdList;
Orig_System_Reference_id1_tbl  OrigSystemReferenceId1List;
Mandatory_yn_tbl               MandatoryYnList;
Mandatory_rwa_tbl              MandatoryRwaList;
Label_tbl                      LabelList;
Display_sequence_tbl            DisplaySequenceList;

sav_sae_tbl1                    SavSaeIdList;
Attribute_category_tbl1         AttributeCategoryList;
Attribute1_tbl1                 AttributeList;
Attribute2_tbl1                 AttributeList;
Attribute3_tbl1                 AttributeList;
Attribute4_tbl1                 AttributeList;
Attribute5_tbl1                 AttributeList;
Attribute6_tbl1                 AttributeList;
Attribute7_tbl1                 AttributeList;
Attribute8_tbl1                 AttributeList;
Attribute9_tbl1                 AttributeList;
Attribute10_tbl1                AttributeList;
Attribute11_tbl1                AttributeList;
Attribute12_tbl1                AttributeList;
Attribute13_tbl1                AttributeList;
Attribute14_tbl1                AttributeList;
Attribute15_tbl1                AttributeList;
Ref_article_id_tbl1             RefArticleIdList;
Ref_article_version_id_tbl1     RefArticleVersionIdList;
orig_article_id_tbl1            OrigArticleIdList;

Source_flag_tbl1                SourceFlagList;
Article_Version_tbl1            ArticleVersionIdList;
Change_nonstd_yn_tbl1           ChangeNonStdYnList;
Scn_id_tbl1                     ScnIdList;
Orig_System_Reference_id1_tbl1  OrigSystemReferenceId1List;
Mandatory_yn_tbl1               MandatoryYnList;
Mandatory_rwa_tbl1              MandatoryRwaList;
Label_tbl1                      LabelList;
Display_sequence_tbl1            DisplaySequenceList;

CURSOR l_get_prov_csr IS
SELECT nvl(PROVISION_ALLOWED_YN,'Y') FROM OKC_BUS_DOC_TYPES_B
WHERE  DOCUMENT_TYPE=p_target_doc_type;

CURSOR l_get_std_csr(b_article_id NUMBER) IS
SELECT STANDARD_YN,ARTICLE_TITLE FROM OKC_ARTICLES_ALL
WHERE  article_id=b_article_id;

CURSOR l_get_global_csr IS
SELECT global_flag FROM OKC_TERMS_TEMPLATES_ALL
WHERE  template_id=p_source_doc_id;

CURSOR l_get_org_csr IS
SELECT org_id FROM OKC_TERMS_TEMPLATES_ALL
WHERE  template_id=p_target_doc_id;

CURSOR l_get_latest_article_csr(b_article_id NUMBER) IS
SELECT article_version_id FROM OKC_ARTICLE_VERSIONS
WHERE  article_id= b_article_id
AND    article_status in ('ON_HOLD','APPROVED')
AND    nvl(p_article_effective_date,sysdate) >= Start_date
AND    nvl(p_article_effective_date,sysdate) <= nvl(end_date, nvl(p_article_effective_date,sysdate) +1);

CURSOR l_get_max_article_csr(b_article_id NUMBER) IS
SELECT article_version_id FROM OKC_ARTICLE_VERSIONS
WHERE  article_id= b_article_id
AND    article_status in ('ON_HOLD','APPROVED')
AND    start_date = (select max(start_date) FROM OKC_ARTICLE_VERSIONS
WHERE  article_id= b_article_id
AND    article_status in ('ON_HOLD','APPROVED') );

CURSOR l_get_no_std_ref_csr(b_version_ID NUMBER) IS
SELECT VERS2.ARTICLE_ID,VERS2.ARTICLE_VERSION_ID
FROM OKC_ARTICLE_VERSIONS VERS1,OKC_ARTICLE_VERSIONS VERS2
WHERE VERS1.ARTICLE_VERSION_ID=b_version_id
AND   VERS2.ARTICLE_VERSION_ID=VERS1.STD_ARTICLE_VERSION_ID;

CURSOR l_get_art_csr IS
SELECT
       SAV_SAE_ID,
       KART.ATTRIBUTE_CATEGORY,
       KART.ATTRIBUTE1,
       KART.ATTRIBUTE2,
       KART.ATTRIBUTE3,
       KART.ATTRIBUTE4,
       KART.ATTRIBUTE5,
       KART.ATTRIBUTE6,
       KART.ATTRIBUTE7,
       KART.ATTRIBUTE8,
       KART.ATTRIBUTE9,
       KART.ATTRIBUTE10,
       KART.ATTRIBUTE11,
       KART.ATTRIBUTE12,
       KART.ATTRIBUTE13,
       KART.ATTRIBUTE14,
       KART.ATTRIBUTE15,
       SOURCE_FLAG,
       ARTICLE_VERSION_ID,
       CHANGE_NONSTD_YN,
       SCN.ID SCN_ID,
       DECODE(P_KEEP_ORIG_REF,'Y',KART.ORIG_SYSTEM_REFERENCE_ID1,KART.ID) ORIG_SYSTEM_REFERENCE_ID1,
       MANDATORY_YN,
       MANDATORY_RWA,
       KART.LABEL,
       DISPLAY_SEQUENCE,
       ref_article_id,
       ref_article_version_id,
       DECODE(p_source_doc_type,G_TEMPLATE_DOC_TYPE,sav_sae_id,orig_article_id) orig_article_id
FROM OKC_K_ARTICLES_B KART,
     OKC_SECTIONS_B SCN
WHERE KART.DOCUMENT_TYPE=p_source_doc_type
  AND KART.DOCUMENT_ID=p_source_doc_id
  AND SCN.DOCUMENT_TYPE = p_target_doc_type
  AND SCN.DOCUMENT_ID   =p_target_doc_id
  AND SCN.ORIG_SYSTEM_REFERENCE_CODE =G_COPY
  AND SCN.ORIG_SYSTEM_REFERENCE_ID1=KART.SCN_ID
  AND nvl(KART.AMENDMENT_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
  AND nvl(KART.SUMMARY_AMEND_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
  AND ( p_retain_lock_terms_yn = 'N'
        OR
        ( p_retain_lock_terms_yn = 'Y'
          AND NOT EXISTS ( SELECT 'LOCKEXISTS'
                              FROM okc_k_entity_locks
                           WHERE entity_name='CLAUSE'
                           AND   entity_pk1 = To_Char(KART.id)
                           AND   lock_by_document_type=p_target_doc_type
                           AND   lock_by_document_id=p_target_doc_id
                          )
         )
      );

CURSOR l_get_orig_art_csr IS
  SELECT
       KART.SAV_SAE_ID,
       KART.ATTRIBUTE_CATEGORY,
       KART.ATTRIBUTE1,
       KART.ATTRIBUTE2,
       KART.ATTRIBUTE3,
       KART.ATTRIBUTE4,
       KART.ATTRIBUTE5,
       KART.ATTRIBUTE6,
       KART.ATTRIBUTE7,
       KART.ATTRIBUTE8,
       KART.ATTRIBUTE9,
       KART.ATTRIBUTE10,
       KART.ATTRIBUTE11,
       KART.ATTRIBUTE12,
       KART.ATTRIBUTE13,
       KART.ATTRIBUTE14,
       KART.ATTRIBUTE15,
       KART.SOURCE_FLAG,
       KART.ARTICLE_VERSION_ID,
       KART.CHANGE_NONSTD_YN,
       SCN.ID SCN_ID,
       KART.ORIG_SYSTEM_REFERENCE_ID1 ORIG_SYSTEM_REFERENCE_ID1,
       KART.MANDATORY_YN,
       KART.MANDATORY_RWA,
       KART.LABEL,
       KART.DISPLAY_SEQUENCE,
       KART.ref_article_id,
       KART.ref_article_version_id,
       DECODE(p_source_doc_type,G_TEMPLATE_DOC_TYPE,KART.sav_sae_id,KART.orig_article_id) orig_article_id
FROM OKC_K_ARTICLES_B KART,
     OKC_SECTIONS_B SCN,
     OKC_SECTIONS_B SCN1,
     OKC_K_ARTICLES_B KART1
WHERE KART.DOCUMENT_TYPE= p_source_doc_type
  AND KART.DOCUMENT_ID= p_source_doc_id
  AND SCN.DOCUMENT_TYPE = p_target_doc_type
  AND SCN.DOCUMENT_ID   = p_target_doc_id
AND SCN.ORIG_SYSTEM_REFERENCE_CODE =G_COPY
AND SCN1.DOCUMENT_TYPE = p_source_doc_type
AND SCN1.DOCUMENT_ID   = p_source_doc_id
AND SCN1.ORIG_SYSTEM_REFERENCE_ID1 = SCN.ORIG_SYSTEM_REFERENCE_ID1
AND KART1.ORIG_SYSTEM_REFERENCE_ID1 = KART.ORIG_SYSTEM_REFERENCE_ID1
AND KART1.SCN_ID = SCN1.ID
AND nvl(KART.AMENDMENT_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
AND nvl(KART.SUMMARY_AMEND_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED;

CURSOR l_get_art_from_archive_csr IS
SELECT
       SAV_SAE_ID,
       KART.ATTRIBUTE_CATEGORY,
       KART.ATTRIBUTE1,
       KART.ATTRIBUTE2,
       KART.ATTRIBUTE3,
       KART.ATTRIBUTE4,
       KART.ATTRIBUTE5,
       KART.ATTRIBUTE6,
       KART.ATTRIBUTE7,
       KART.ATTRIBUTE8,
       KART.ATTRIBUTE9,
       KART.ATTRIBUTE10,
       KART.ATTRIBUTE11,
       KART.ATTRIBUTE12,
       KART.ATTRIBUTE13,
       KART.ATTRIBUTE14,
       KART.ATTRIBUTE15,
       SOURCE_FLAG,
       ARTICLE_VERSION_ID,
       CHANGE_NONSTD_YN,
       SCN.ID SCN_ID,
       DECODE(P_KEEP_ORIG_REF,'Y',KART.ORIG_SYSTEM_REFERENCE_ID1,KART.ID) ORIG_SYSTEM_REFERENCE_ID1,
       MANDATORY_YN,
       MANDATORY_RWA,
       KART.LABEL,
       DISPLAY_SEQUENCE,
       ref_article_id,
       ref_article_version_id,
       orig_article_id
FROM OKC_K_ARTICLES_BH KART,
     OKC_SECTIONS_B SCN
WHERE KART.DOCUMENT_TYPE=p_source_doc_type
  AND KART.DOCUMENT_ID=p_source_doc_id
  AND KART.MAJOR_VERSION = nvl(p_source_version_number,OKC_API.G_MISS_NUM)
  AND SCN.DOCUMENT_TYPE = p_target_doc_type
  AND SCN.DOCUMENT_ID   =p_target_doc_id
  AND SCN.ORIG_SYSTEM_REFERENCE_CODE =G_COPY
  AND SCN.ORIG_SYSTEM_REFERENCE_ID1=KART.SCN_ID;

CURSOR l_get_local_article_csr(b_article_id IN NUMBER, b_local_org_id IN NUMBER) IS
SELECT ADP.LOCAL_ARTICLE_VERSION_ID LOCAL_ARTICLE_VERSION_ID,
       ADP.ADOPTION_TYPE,
       VERS1.ARTICLE_ID
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP,
       OKC_ARTICLE_VERSIONS  VERS1
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND    VERS.ARTICLE_ID         = b_article_id
AND    nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
AND    nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
AND    VERS.ARTICLE_STATUS   IN ('ON_HOLD','APPROVED')
AND    VERS1.ARTICLE_VERSION_ID     =ADP.LOCAL_ARTICLE_VERSION_ID
AND    ADP.ADOPTION_TYPE = 'LOCALIZED'
AND    ADP.LOCAL_ORG_ID = b_local_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
UNION ALL
SELECT ADP.GLOBAL_ARTICLE_VERSION_ID LOCAL_ARTICLE_VERSION_ID,
       ADP.ADOPTION_TYPE,
       VERS.ARTICLE_ID
FROM   OKC_ARTICLE_VERSIONS VERS,
       OKC_ARTICLE_ADOPTIONS  ADP
WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
AND    VERS.ARTICLE_ID         = b_article_id
AND    nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
AND    nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
AND    VERS.ARTICLE_STATUS     IN ('ON_HOLD','APPROVED')
AND    ADP.ADOPTION_TYPE = 'ADOPTED'
AND    ADP.LOCAL_ORG_ID = b_local_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
;

CURSOR l_get_article_csr(b_article_version_id NUMBER) IS
SELECT nvl(PROVISION_YN,'N') provision_yn
FROM OKC_ARTICLE_VERSIONS
WHERE ARTICLE_VERSION_ID=b_article_version_id;

l_article_rec       l_get_article_csr%ROWTYPE;
l_local_article_rec l_get_local_article_csr%ROWTYPE;
x_article_number    OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;

l_article_org_id  NUMBER;

CURSOR l_get_article_org_csr(b_article_id NUMBER) IS
SELECT org_id
FROM OKC_ARTICLES_ALL
WHERE article_id = b_article_id;

CURSOR l_get_max_local_article_csr(b_article_id IN NUMBER, b_article_org_id IN NUMBER) IS
SELECT DECODE(ADP.LOCAL_ARTICLE_VERSION_ID,NULL,ADP.GLOBAL_ARTICLE_VERSION_ID,ADP.LOCAL_ARTICLE_VERSION_ID),
       ADP.ADOPTION_TYPE
FROM   OKC_ARTICLE_ADOPTIONS  ADP
WHERE ADP.LOCAL_ORG_ID = b_article_org_id
AND  ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
AND  ADP.GLOBAL_ARTICLE_VERSION_ID IN (SELECT ARTICLE_VERSION_ID
                                         FROM OKC_ARTICLE_VERSIONS
                                        WHERE article_id = b_article_id)
ORDER BY ADP.creation_date desc;

CURSOR l_get_local_article_id(b_article_version_id IN NUMBER) IS
SELECT article_id
FROM okc_article_versions
WHERE article_version_id = b_article_version_id;

l_current_org_id VARCHAR2(100);
l_adoption_type  VARCHAR2(100);
l_local_article_id NUMBER;
l_max_sequence NUMBER;

CURSOR l_art_sqn_csr IS
  SELECT Max(DISPLAY_SEQUENCE) FROM okc_k_articles_b
  WHERE DOCUMENT_TYPE=P_TARGET_DOC_TYPE
    AND DOCUMENT_ID=P_TARGET_DOC_ID;


--------------------  CONC MOD CHANGES START -------------
CURSOR cur_orphan_clauses
IS
 SELECT tgt.id,tgtsec.id, lck.k_entity_lock_id
   FROM okc_k_articles_b tgt, okc_k_entity_locks lck, okc_sections_b tgtsec
   WHERE tgt.document_type= p_target_doc_type
   AND tgt.document_id=   p_target_doc_id
   AND tgt.summary_amend_operation_code = 'ADDED'
   AND lck.entity_name='DUMMYSEC'
   AND lck.lock_by_document_type=p_target_doc_type
   AND lck.lock_by_document_id= p_target_doc_id
   AND tgt.scn_id = lck.lock_by_entity_id
   AND tgtsec.document_type = p_target_doc_type
   AND tgtsec.document_id   =  p_target_doc_id
   AND lck.entity_pk1 = tgtsec.ORIG_SYSTEM_REFERENCE_ID1
   ;

CURSOR cur_orphan_upd_clauses
IS
 SELECT tgtart.id,tgtsec.id
   FROM okc_k_articles_b tgtart
       ,okc_k_articles_b srcart
       ,okc_sections_b tgtsec
   WHERE     1 = 1
   -- Target document clauses
   AND tgtart.document_type= p_target_doc_type
   AND tgtart.document_id=   p_target_doc_id
   AND tgtart.summary_amend_operation_code IN ('UPDATED','DELTED')
   AND tgtart.orig_system_reference_id1 = srcart.id
   AND srcart.document_type=p_source_doc_type
   AND srcart.document_id= p_source_doc_id
   AND tgtsec.document_type = p_target_doc_type
   AND tgtsec.document_id   =  p_target_doc_id
   AND srcart.scn_id=tgtsec.ORIG_SYSTEM_REFERENCE_ID1;

TYPE CatList IS TABLE OF okc_k_articles_b.ID%TYPE INDEX BY BINARY_INTEGER;

tgt_cat_tbl CatList;
tgt_scn_tbl CatList;
tgt_scn_upd_lock_tbl  CatList;
tgt_cat_upd_tbl CatList;
tgt_scn_upd_tbl CatList;

--------------------  CONC MOD CHANGES END  -------------

BEGIN

  x_return_status :=  G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside OKC_TERMS_COPY_PVT.copy_articles');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Parameters ');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_target_doc_type  : '||p_target_doc_type);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_target_doc_id  : '||p_target_doc_id);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_source_doc_type  : '||p_source_doc_type);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_source_doc_id  : '||p_source_doc_id);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_keep_version  : '||p_keep_version);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_article_effective_date  : '||p_article_effective_date);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_source_version_number  : '||p_source_version_number);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_copy_from_archive  : '||p_copy_from_archive);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_retain_lock_terms_yn  : '||p_retain_lock_terms_yn);
  END IF;

  OPEN  l_get_prov_csr;
  FETCH l_get_prov_csr into l_prov_allowed;
  CLOSE l_get_prov_csr;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_prov_allowed : '||l_prov_allowed);
  END IF;

  IF  p_copy_from_archive ='Y' THEN
     OPEN  l_get_art_from_archive_csr;
     FETCH l_get_art_from_archive_csr BULK COLLECT INTO
                               sav_sae_tbl,
                               Attribute_category_tbl,
                               Attribute1_tbl,
                               Attribute2_tbl,
                               Attribute3_tbl,
                               Attribute4_tbl,
                               Attribute5_tbl,
                               Attribute6_tbl,
                               Attribute7_tbl,
                               Attribute8_tbl,
                               Attribute9_tbl,
                               Attribute10_tbl,
                               Attribute11_tbl,
                               Attribute12_tbl,
                               Attribute13_tbl,
                               Attribute14_tbl,
                               Attribute15_tbl,
                               Source_flag_tbl,
                               Article_Version_tbl,
                               Change_nonstd_yn_tbl,
                               Scn_id_tbl,
                               Orig_System_Reference_id1_tbl,
                               Mandatory_yn_tbl,
                               Mandatory_rwa_tbl,
                               Label_tbl,
                               Display_sequence_tbl,
                               ref_article_id_tbl,
                               ref_article_version_id_tbl,
                               orig_article_id_tbl;
     CLOSE l_get_art_from_archive_csr;
  ELSE
     -- p_copy_from_archive is N
   IF NVL(p_keep_orig_ref,'N') = 'N' THEN
     OPEN  l_get_art_csr;
     FETCH l_get_art_csr BULK COLLECT INTO
                               sav_sae_tbl,
                               Attribute_category_tbl,
                               Attribute1_tbl,
                               Attribute2_tbl,
                               Attribute3_tbl,
                               Attribute4_tbl,
                               Attribute5_tbl,
                               Attribute6_tbl,
                               Attribute7_tbl,
                               Attribute8_tbl,
                               Attribute9_tbl,
                               Attribute10_tbl,
                               Attribute11_tbl,
                               Attribute12_tbl,
                               Attribute13_tbl,
                               Attribute14_tbl,
                               Attribute15_tbl,
                               Source_flag_tbl,
                               Article_Version_tbl,
                               Change_nonstd_yn_tbl,
                               Scn_id_tbl,
                               Orig_System_Reference_id1_tbl,
                               Mandatory_yn_tbl,
                               Mandatory_rwa_tbl,
                              Label_tbl,
                               Display_sequence_tbl,
                               ref_article_id_tbl,
                               ref_article_version_id_tbl,
                               orig_article_id_tbl;
     CLOSE l_get_art_csr;
   ELSE
     OPEN  l_get_orig_art_csr;
     FETCH l_get_orig_art_csr BULK COLLECT INTO
                               sav_sae_tbl,
                               Attribute_category_tbl,
                               Attribute1_tbl,
                               Attribute2_tbl,
                               Attribute3_tbl,
                               Attribute4_tbl,
                               Attribute5_tbl,
                               Attribute6_tbl,
                               Attribute7_tbl,
                               Attribute8_tbl,
                               Attribute9_tbl,
                               Attribute10_tbl,
                               Attribute11_tbl,
                               Attribute12_tbl,
                               Attribute13_tbl,
                               Attribute14_tbl,
                               Attribute15_tbl,
                               Source_flag_tbl,
                               Article_Version_tbl,
                               Change_nonstd_yn_tbl,
                               Scn_id_tbl,
                               Orig_System_Reference_id1_tbl,
                               Mandatory_yn_tbl,
                               Mandatory_rwa_tbl,
                               Label_tbl,
                               Display_sequence_tbl,
                               ref_article_id_tbl,
                               ref_article_version_id_tbl,
                               orig_article_id_tbl;
     CLOSE l_get_orig_art_csr;
   END IF;
  END IF; -- p_copy_from_archive

     IF p_source_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
          AND p_target_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN

         OPEN  l_get_global_csr;
         FETCH l_get_global_csr into l_global_yn;
         CLOSE l_get_global_csr;

         OPEN  l_get_org_csr;
         FETCH l_get_org_csr into l_org_id;
         CLOSE l_get_org_csr;

     END IF; -- source and target are templates

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Source Template l_global_yn : '||l_global_yn);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Target Template l_org_id : '||l_org_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Count of Articles on Source : '||sav_sae_tbl.COUNT);
        END IF;

  IF sav_sae_tbl.COUNT > 0  THEN
   FOR i IN sav_sae_tbl.FIRST..sav_sae_tbl.LAST LOOP
      l_discard := false;

     OPEN  l_get_std_csr(sav_sae_tbl(i));
     FETCH l_get_std_csr INTO l_standard_yn,l_art_title;
     CLOSE l_get_std_csr;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_standard_yn : '||l_standard_yn);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_art_title : '||l_art_title);
        END IF;

     IF p_keep_version = 'N' AND l_standard_yn='Y'
      AND p_target_doc_type<>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN

        -- check if Article is global or local
        OPEN l_get_article_org_csr(sav_sae_tbl(i));
          FETCH l_get_article_org_csr INTO l_article_org_id;
        CLOSE l_get_article_org_csr;

        -- current Org Id
       -- fnd_profile.get('ORG_ID',l_current_org_id);
       l_current_org_id := OKC_TERMS_UTIL_PVT.get_current_org_id(p_target_doc_type, p_target_doc_id);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_article_org_id : '||l_article_org_id);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_current_org_id : '||l_current_org_id);
        END IF;


        -- since p_keep_version is N we will initialize the article_version_id
        article_version_tbl(i) := NULL;

          IF nvl(l_current_org_id,'?') <> l_article_org_id THEN
           -- this is a ADOPTED OR LOCALIZED ARTICLE

                  OPEN l_get_local_article_csr(sav_sae_tbl(i), l_current_org_id);
                  FETCH l_get_local_article_csr INTO l_local_article_rec;

                  IF    l_get_local_article_csr%NOTFOUND THEN
                     -- check for max version
                          OPEN  l_get_max_local_article_csr(sav_sae_tbl(i),l_current_org_id);
                             FETCH l_get_max_local_article_csr INTO article_version_tbl(i),l_adoption_type;

                             IF l_get_max_local_article_csr%NOTFOUND THEN
                             -- discard this record
                              l_discard := true;
                              okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                             p_msg_name     => 'OKC_ART_NOT_ADOPTED',
                                             p_token1       => 'ART_TITLE',
                                             p_token1_value => l_art_title,
                                             p_token2       => 'ORG_ID',
                                             p_token2_value => l_current_org_id);
                             ELSE -- max record found
                               IF l_adoption_type = 'LOCALIZED' THEN
                                -- get the local article id and swap
                                OPEN  l_get_local_article_id(article_version_tbl(i));
                                  FETCH l_get_local_article_id INTO l_local_article_id;
                                CLOSE l_get_local_article_id;
                                -- SWAP Article Id
                                sav_sae_tbl(i) := l_local_article_id;
                               END IF; -- for adoption_type LOCALIZED

                             END IF; -- max record not found

                           CLOSE l_get_max_local_article_csr;

                  ELSE
                      -- local record found
                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: this is a ADOPTED OR LOCALIZED ARTICLE');
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_local_article_rec.adoption_type : '||l_local_article_rec.adoption_type);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_local_article_rec.article_id : '||l_local_article_rec.article_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: LOCAL_ARTICLE_VERSION_ID : '||l_local_article_rec.LOCAL_ARTICLE_VERSION_ID);
                      END IF;

                      IF l_local_article_rec.adoption_type = 'LOCALIZED' THEN
                         sav_sae_tbl(i) := l_local_article_rec.article_id;
                      ELSIF l_local_article_rec.adoption_type = 'ADOPTED' THEN
                            NULL;
                      END IF;

                       article_version_tbl(i) := l_local_article_rec.LOCAL_ARTICLE_VERSION_ID;

                       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_get_local_article_csr : '||article_version_tbl(i));
                       END IF;

                  END IF; -- for local record found
                  CLOSE  l_get_local_article_csr;

          ELSE
            -- this is local article
            OPEN  l_get_latest_article_csr(sav_sae_tbl(i));
              FETCH l_get_latest_article_csr INTO article_version_tbl(i);
            CLOSE l_get_latest_article_csr;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: this is a Local ARTICLE');
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_get_latest_article_csr : '||article_version_tbl(i));
            END IF;

            IF p_target_doc_type<>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
               AND article_version_tbl(i) IS NULL THEN
                  OPEN  l_get_max_article_csr(sav_sae_tbl(i));
                    FETCH l_get_max_article_csr INTO article_version_tbl(i);
                  CLOSE l_get_max_article_csr;

                 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_get_max_article_csr : '||article_version_tbl(i));
                 END IF;

                 -- if article_version_id is still null then discard this record
                 IF article_version_tbl(i) IS NULL THEN
                    l_discard := true;
                    okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                        p_msg_name     => 'OKC_ART_NO_APP_VERSION',
                                        p_token1       => 'ART_TITLE',
                                        p_token1_value => l_art_title);
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Discarding Local Article id : '||sav_sae_tbl(i));
                    END IF;
                 END IF; -- if article_version_id is still null

            END IF; -- for target document type not template

          END IF; -- for adopted/localized  or local article

     ELSIF l_standard_yn='N' THEN

     -- Copying Non-Standard Article

        OKC_ARTICLES_GRP.copy_article( p_api_version        => 1,
                                       p_init_msg_list      => FND_API.G_FALSE,
                                       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                                       p_commit             => FND_API.G_FALSE,
                                       p_article_version_id => article_version_tbl(i),
                                       p_new_article_title  => NULL,
                                       p_create_standard_yn => 'N',
                                       x_article_version_id => article_version_tbl(i),
                                       x_article_id         => sav_sae_tbl(i),
                                       x_article_number     => x_article_number,
                                       x_return_status      => x_return_status,
                                       x_msg_count          => x_msg_count,
                                       x_msg_data           => x_msg_data);

                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR ;
                 END IF;
                /*
                 OPEN  l_get_no_std_ref_csr(article_version_tbl(i));
                 FETCH l_get_no_std_ref_csr INTO ref_article_id_tbl(i),ref_article_version_id_tbl(i);
                 IF l_get_no_std_ref_csr%NOTFOUND THEN
                    ref_article_id_tbl(i):=NULL;
                    ref_article_version_id_tbl(i):=NULL;
                 END IF;
                 CLOSE l_get_no_std_ref_csr;
                */
     END IF; -- p_keep_version = N and std or non std art

     IF p_source_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
        AND p_target_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
        AND l_standard_yn='Y' THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Template To Template Copy l_global_yn : '||l_global_yn);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Profile OKC_GLOBAL_ORG_ID : '||fnd_profile.value('OKC_GLOBAL_ORG_ID'));
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100:Target Template org_id : '||l_org_id);
        END IF;

           IF l_global_yn = 'Y'
             AND nvl(fnd_profile.value('OKC_GLOBAL_ORG_ID'),'?') <> l_org_id THEN

                  OPEN  l_get_local_article_csr(sav_sae_tbl(i),l_org_id);
                  FETCH l_get_local_article_csr INTO l_local_article_rec;

                  IF    l_get_local_article_csr%NOTFOUND THEN
                        -- go for the max article that was adopted or localized
                           OPEN  l_get_max_local_article_csr(sav_sae_tbl(i),l_org_id);
                             FETCH l_get_max_local_article_csr INTO article_version_tbl(i),l_adoption_type;

                             IF l_get_max_local_article_csr%NOTFOUND THEN
                               l_discard := true;
                                okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                                             p_msg_name     => 'OKC_ART_NOT_ADOPTED',
                                             p_token1       => 'ART_TITLE',
                                             p_token1_value => l_art_title,
                                             p_token2       => 'ORG_ID',
                                             p_token2_value => l_org_id);
                             ELSE -- max record found
                               IF l_adoption_type = 'LOCALIZED' THEN
                                -- get the local article id and swap
                                OPEN  l_get_local_article_id(article_version_tbl(i));
                                  FETCH l_get_local_article_id INTO l_local_article_id;
                                CLOSE l_get_local_article_id;
                                -- SWAP Article Id
                                sav_sae_tbl(i) := l_local_article_id;
                               END IF; -- l_adoption_type = LOCALIZED

                             END IF; -- max article csr

                           CLOSE l_get_max_local_article_csr;

                  ELSE  -- local_article_csr found

                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_local_article_rec.adoption_type : '||l_local_article_rec.adoption_type);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_local_article_rec.article_id : '||l_local_article_rec.article_id);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_local_article_rec.LOCAL_ARTICLE_VERSION_ID : '||l_local_article_rec.LOCAL_ARTICLE_VERSION_ID);
                      END IF;

                      IF l_local_article_rec.adoption_type = 'LOCALIZED' THEN
                         sav_sae_tbl(i) := l_local_article_rec.article_id;
                      ELSIF l_local_article_rec.adoption_type = 'ADOPTED' THEN
                            NULL;
                      END IF;

                  END IF; -- record not found

                  CLOSE l_get_local_article_csr;

           END IF;  -- l_global_yn is Y

       END IF;  -- template to template copy

       IF p_target_doc_type <>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN

            OPEN  l_get_article_csr(article_version_tbl(i));
            FETCH l_get_article_csr INTO l_article_rec;
            CLOSE l_get_article_csr;
            IF l_article_rec.provision_yn='Y' and l_prov_allowed='N' THEN
               l_discard := true;
            END IF;

       END IF; -- target not template

       IF p_source_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
          AND p_target_doc_type<>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN

          source_flag_tbl(i) := 'T';

       END IF; -- template to document copy

       IF NOT l_discard THEN

          k := k +1;
          sav_sae_tbl1(k)                   := sav_sae_tbl(i);
          Attribute_category_tbl1(k)        := Attribute_category_tbl(i);
          Attribute1_tbl1(k)                := Attribute1_tbl(i);
          Attribute2_tbl1(k)                := Attribute2_tbl(i);
          Attribute3_tbl1(k)                := Attribute3_tbl(i);
          Attribute4_tbl1(k)                := Attribute4_tbl(i);
          Attribute5_tbl1(k)                := Attribute5_tbl(i);
          Attribute6_tbl1(k)                := Attribute6_tbl(i);
          Attribute7_tbl1(k)                := Attribute7_tbl(i);
          Attribute8_tbl1(k)                := Attribute8_tbl(i);
          Attribute9_tbl1(k)                := Attribute9_tbl(i);
          Attribute10_tbl1(k)               := Attribute10_tbl(i);
          Attribute11_tbl1(k)               := Attribute11_tbl(i);
          Attribute12_tbl1(k)               := Attribute12_tbl(i);
          Attribute13_tbl1(k)               := Attribute13_tbl(i);
          Attribute14_tbl1(k)               := Attribute14_tbl(i);
          Attribute15_tbl1(k)               := Attribute15_tbl(i);
          Source_flag_tbl1(k)               := Source_flag_tbl(i);
          Article_Version_tbl1(k)           := Article_Version_tbl(i);
          Change_nonstd_yn_tbl1(k)          := Change_nonstd_yn_tbl(i);
          Scn_id_tbl1(k)                    := Scn_id_tbl(i);
          Orig_System_Reference_id1_tbl1(k) := Orig_System_Reference_id1_tbl(i);
          Mandatory_yn_tbl1(k)              := Mandatory_yn_tbl(i);
          Mandatory_rwa_tbl1(k)              := Mandatory_rwa_tbl(i);
          Label_tbl1(k)                     := Label_tbl(i);
          Display_sequence_tbl1(k)          := Display_sequence_tbl(i);
          ref_article_id_tbl1(k)            := ref_article_id_tbl(i);
          ref_article_version_id_tbl1(k)    := ref_article_version_id_tbl(i);
          orig_article_id_tbl1(k)           := orig_article_id_tbl(i);

          /*kkolukul: CLM Changes: getting max sequence of articles in the Doc and
          adding new articles after that*/
          OPEN l_art_sqn_csr;
          FETCH l_art_sqn_csr INTO l_max_sequence;
          CLOSE l_art_sqn_csr;

          IF(p_retain_clauses = 'Y') THEN
             Display_sequence_tbl1(k)       := l_max_sequence + 10 ;
          ELSE
            Display_sequence_tbl1(k)          := Display_sequence_tbl(i);
          END IF;
      END IF;
  END LOOP;
END IF; -- count > 0

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Count of Articles on Target : '||sav_sae_tbl1.COUNT);
        END IF;

  IF sav_sae_tbl1.COUNT>0 THEN
     FORALL i IN sav_sae_tbl1.FIRST..sav_sae_tbl1.LAST
            INSERT INTO OKC_K_ARTICLES_B(
                                          ID,
                                          SAV_SAE_ID,
                                          DOCUMENT_TYPE,
                                          DOCUMENT_ID,
                                          CHR_ID,
                                          DNZ_CHR_ID,
                                          SOURCE_FLAG,
                                          MANDATORY_YN,
                                          MANDATORY_RWA,
                                          SCN_ID,
                                          LABEL,
                                          AMENDMENT_DESCRIPTION,
                                          AMENDMENT_OPERATION_CODE,
                                          ARTICLE_VERSION_ID,
                                          CHANGE_NONSTD_YN,
                                          ORIG_SYSTEM_REFERENCE_CODE,
                                          ORIG_SYSTEM_REFERENCE_ID1,
                                          ORIG_SYSTEM_REFERENCE_ID2,
                                          DISPLAY_SEQUENCE,
                                          ATTRIBUTE_CATEGORY,
                                          ATTRIBUTE1,
                                          ATTRIBUTE2,
                                          ATTRIBUTE3,
                                          ATTRIBUTE4,
                                          ATTRIBUTE5,
                                          ATTRIBUTE6,
                                          ATTRIBUTE7,
                                          ATTRIBUTE8,
                                          ATTRIBUTE9,
                                          ATTRIBUTE10,
                                          ATTRIBUTE11,
                                          ATTRIBUTE12,
                                          ATTRIBUTE13,
                                          ATTRIBUTE14,
                                          ATTRIBUTE15,
                                          PRINT_TEXT_YN,
                                          REF_ARTICLE_ID,
                                          REF_ARTICLE_VERSION_ID,
                                          OBJECT_VERSION_NUMBER,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN,
                                          LAST_UPDATE_DATE,
                                          ORIG_ARTICLE_ID)
                          VALUES(OKC_K_ARTICLES_B_S.nextval,
                                 sav_sae_tbl1(i),
                                 p_target_doc_type,
                                 p_target_doc_id,
                                 decode(p_target_doc_type,'OKC_BUY',p_target_doc_id,'OKC_SELL',p_target_doc_id, 'OKO',p_target_doc_id,'OKS',p_target_doc_id,'OKE_BUY',p_target_doc_id, 'OKE_SELL',p_target_doc_id, 'OKL',p_target_doc_id,NULL),
                                 decode(p_target_doc_type,'OKC_BUY',p_target_doc_id,'OKC_SELL',p_target_doc_id, 'OKO',p_target_doc_id,'OKS',p_target_doc_id,'OKE_BUY',p_target_doc_id, 'OKE_SELL',p_target_doc_id, 'OKL',p_target_doc_id,NULL),
                                 Source_flag_tbl1(i),
                                 Mandatory_yn_tbl1(i),
                                 Mandatory_rwa_tbl1(i),
                                 Scn_id_tbl1(i),
                                 Label_tbl1(i),
                                 Null,
                                 Null,
                                 decode(p_target_doc_type, OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,NULL,Article_Version_tbl1(i)),
                                 Change_nonstd_yn_tbl1(i),
                                 G_COPY,
                                 Orig_System_Reference_id1_tbl1(i),
                                 Null,
                                 Display_sequence_tbl1(i),
                                 Attribute_category_tbl1(i),
                                 Attribute1_tbl1(i),
                                 Attribute2_tbl1(i),
                                 Attribute3_tbl1(i),
                                 Attribute4_tbl1(i),
                                 Attribute5_tbl1(i),
                                 Attribute6_tbl1(i),
                                 Attribute7_tbl1(i),
                                 Attribute8_tbl1(i),
                                 Attribute9_tbl1(i),
                                 Attribute10_tbl1(i),
                                 Attribute11_tbl1(i),
                                 Attribute12_tbl1(i),
                                 Attribute13_tbl1(i),
                                 Attribute14_tbl1(i),
                                 Attribute15_tbl1(i),
                                 Null,
                                 ref_article_id_tbl(i),
                                 ref_article_version_id_tbl(i),
                                 1,
                                 Fnd_Global.User_Id,
                                 sysdate,
                                 Fnd_Global.User_Id,
                                 Fnd_Global.Login_Id,
                                 sysdate,
                                 orig_article_id_tbl1(i));

END IF;


--------------------  CONC MOD CHANGES START -------------


IF p_retain_lock_terms_yn = 'Y'
THEN
    -- Add Case
    -- Get the orphan records.

    -- Using the section id from the clause,  find the base section id from the okc_k_entity_locks
    -- using base section find the corresponding section in the current mod

     -- CASE ARTICLE IS ADDED IN THE TARGE DOC
     OPEN  cur_orphan_clauses;
     FETCH cur_orphan_clauses bulk COLLECT INTO  tgt_cat_tbl,tgt_scn_tbl,tgt_scn_upd_lock_tbl;
     CLOSE cur_orphan_clauses;

     IF  tgt_cat_tbl.Count > 0 THEN
        FORALL i IN tgt_cat_tbl.first..tgt_cat_tbl.last
        UPDATE okc_k_articles_b
          SET  scn_id= tgt_scn_tbl(i)
        WHERE  id= tgt_cat_tbl(i);

        -- Re-build the lock table.
        FORALL i IN tgt_scn_upd_lock_tbl.first..tgt_scn_upd_lock_tbl.last
         UPDATE okc_k_entity_locks
         SET    lock_by_entity_id = tgt_scn_tbl(i)
         WHERE k_entity_lock_id=tgt_scn_upd_lock_tbl(i);
     END IF;

     -- CASE ARTICLE IS UPDATED/DELETED  CASE ARTICLE IS ADDED IN THE TARGE DOC
     OPEN  cur_orphan_upd_clauses;
     FETCH cur_orphan_upd_clauses bulk COLLECT INTO  tgt_cat_upd_tbl,tgt_scn_upd_tbl;
     CLOSE cur_orphan_upd_clauses;

       IF  tgt_cat_upd_tbl.Count > 0 THEN
        FORALL i IN tgt_cat_upd_tbl.first..tgt_cat_upd_tbl.last
        UPDATE okc_k_articles_b
          SET  scn_id= tgt_scn_upd_tbl(i)
        WHERE  id= tgt_cat_upd_tbl(i);
      -- CASE SECTION IS MODIFED/UPDATED.
        -- MODIFY COPY SECTIONS

     END IF;
END IF;
--------------------  CONC MOD CHANGES END -----------------


  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: Leaving copy_articles '||x_return_status);
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving copy_articles:FND_API.G_EXC_ERROR Exception');
  END IF;
 IF l_get_prov_csr%ISOPEN THEN
    CLOSE l_get_prov_csr;
END IF;

IF l_get_article_csr%ISOPEN THEN
    CLOSE l_get_article_csr;
END IF;
IF l_get_local_article_csr%ISOPEN THEN
    CLOSE l_get_local_article_csr;
END IF;
IF l_get_art_csr %ISOPEN THEN
    CLOSE l_get_art_csr ;
END IF;
IF l_get_latest_article_csr%ISOPEN THEN
    CLOSE l_get_latest_article_csr;
END IF;
IF l_get_org_csr%ISOPEN THEN
    CLOSE l_get_org_csr;
END IF;
IF l_get_global_csr%ISOPEN THEN
    CLOSE l_get_global_csr;
END IF;
IF l_get_prov_csr%ISOPEN THEN
    CLOSE l_get_prov_csr;
END IF;
IF l_get_std_csr%ISOPEN THEN
    CLOSE l_get_std_csr;
END IF;

  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_articles:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
  END IF;
IF l_get_article_csr%ISOPEN THEN
    CLOSE l_get_article_csr;
END IF;
IF l_get_local_article_csr%ISOPEN THEN
    CLOSE l_get_local_article_csr;
END IF;
IF l_get_art_csr %ISOPEN THEN
    CLOSE l_get_art_csr ;
END IF;
IF l_get_latest_article_csr%ISOPEN THEN
    CLOSE l_get_latest_article_csr;
END IF;
IF l_get_org_csr%ISOPEN THEN
    CLOSE l_get_org_csr;
END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving copy_articles because of EXCEPTION: '||sqlerrm);
  END IF;

  IF l_get_article_csr%ISOPEN THEN
      CLOSE l_get_article_csr;
  END IF;


  IF l_get_local_article_csr%ISOPEN THEN
      CLOSE l_get_local_article_csr;
  END IF;

  IF l_get_art_csr %ISOPEN THEN
      CLOSE l_get_art_csr ;
  END IF;

  IF l_get_latest_article_csr%ISOPEN THEN
      CLOSE l_get_latest_article_csr;
  END IF;

  IF l_get_org_csr%ISOPEN THEN
      CLOSE l_get_org_csr;
  END IF;

  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END copy_articles;

procedure copy_sections(
                      p_target_doc_type         IN      VARCHAR2,
                      p_source_doc_type         IN      VARCHAR2,
                      p_target_doc_id           IN      NUMBER,
                      p_source_doc_id           IN      NUMBER,
                      p_source_version_number   IN      NUMBER := NULL,
                      p_copy_from_archive       IN      VARCHAR2 := 'N',
                      p_keep_orig_ref           IN      VARCHAR2 := 'N',
                      x_return_status           OUT NOCOPY VARCHAR2,
                      x_msg_data                OUT NOCOPY VARCHAR2,
                      x_msg_count               OUT NOCOPY NUMBER,
                      p_retain_clauses          IN VARCHAR2 DEFAULT 'N'
                     ,p_retain_lock_terms_yn   IN       VARCHAR2 DEFAULT 'N') IS

l_api_name                     CONSTANT VARCHAR2(30) := 'copy_sections';
TYPE AttributeCategoryList      IS TABLE OF OKC_SECTIONS_B.ATTRIBUTE_CATEGORY%TYPE INDEX BY BINARY_INTEGER;
TYPE AttributeList              IS TABLE OF OKC_SECTIONS_B.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;
TYPE ScnIdList                  IS TABLE OF OKC_SECTIONS_B.SCN_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE OrigSystemReferenceId1List IS TABLE OF OKC_SECTIONS_B.ORIG_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER;
TYPE SectionSequenceList        IS TABLE OF OKC_SECTIONS_B.SECTION_SEQUENCE%TYPE INDEX BY BINARY_INTEGER;
TYPE HeadingList                IS TABLE OF OKC_SECTIONS_B.HEADING%TYPE INDEX BY BINARY_INTEGER;
TYPE LabelList                  IS TABLE OF OKC_SECTIONS_B.LABEL%TYPE INDEX BY BINARY_INTEGER;
TYPE ScnCodeList                IS TABLE OF OKC_SECTIONS_B.SCN_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE PrintYnList                IS TABLE OF OKC_SECTIONS_B.PRINT_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE IdList                     IS TABLE OF OKC_SECTIONS_B.ID%TYPE INDEX BY BINARY_INTEGER;
TYPE DescriptionList            IS TABLE OF OKC_SECTIONS_B.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER;


Id_tbl                          IdList;
Attribute_category_tbl          AttributeCategoryList;
Attribute1_tbl                  AttributeList;
Attribute2_tbl                  AttributeList;
Attribute3_tbl                  AttributeList;
Attribute4_tbl                  AttributeList;
Attribute5_tbl                  AttributeList;
Attribute6_tbl                  AttributeList;
Attribute7_tbl                  AttributeList;
Attribute8_tbl                  AttributeList;
Attribute9_tbl                  AttributeList;
Attribute10_tbl                 AttributeList;
Attribute11_tbl                 AttributeList;
Attribute12_tbl                 AttributeList;
Attribute13_tbl                 AttributeList;
Attribute14_tbl                 AttributeList;
Attribute15_tbl                 AttributeList;
Scn_id_tbl                      ScnIdList;
Orig_System_Reference_id1_tbl   OrigSystemReferenceId1List;
Section_sequence_tbl            SectionSequenceList;
Heading_tbl                     HeadingList;
Scn_code_tbl                    ScnCodeList;
Label_tbl                       LabelList;
Print_yn_tbl                    PrintYnList;

Orig_System_Reference_id1_tbl1  OrigSystemReferenceId1List;
Id_tbl1                         IdList;

Description_tbl                  DescriptionList;

TYPE prov_section IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
prov_sec_tbl prov_section;
l_hook_used NUMBER:=0;
l_max_sequence NUMBER := 0;
l_copy_section_yn VARCHAR2(1);
l_scn_drp_action VARCHAR2(100);

CURSOR l_get_scn_csr IS
SELECT OKC_SECTIONS_B_S.NEXTVAL,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       SCN_ID SCN_ID,
       DECODE(P_KEEP_ORIG_REF,'Y',ORIG_SYSTEM_REFERENCE_ID1,ID) ORIG_SYSTEM_REFERENCE_ID1,
       SECTION_SEQUENCE,
       LABEL,
       SCN_CODE,
       HEADING,
       PRINT_YN ,
       DESCRIPTION
FROM  OKC_SECTIONS_B
WHERE DOCUMENT_TYPE=P_SOURCE_DOC_TYPE
  AND DOCUMENT_ID=P_SOURCE_DOC_ID
  AND nvl(AMENDMENT_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
  AND nvl(SUMMARY_AMEND_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
  AND  (( l_scn_drp_action = 'DROP_AMEND_SEC' AND
         heading <> Nvl(fnd_profile.Value('OKC_AMENDMENT_SPECIFIC_SECTION'),'~!@#$%')
       ) OR
       (
         l_scn_drp_action = 'DROP_PROV_SEC' AND
         OKC_CODE_HOOK.IS_NOT_PROVISIONAL_SECTION(heading,P_SOURCE_DOC_TYPE, P_SOURCE_DOC_ID) = FND_API.G_TRUE
       ) OR
       l_scn_drp_action = 'DROP_NOTHING')
AND ( p_retain_lock_terms_yn = 'N'
        OR
        ( p_retain_lock_terms_yn = 'Y'
          AND NOT EXISTS ( SELECT 'LOCKEXISTS'
                              FROM okc_k_entity_locks
                           WHERE entity_name='SECTION'
                           AND   entity_pk1 = To_Char(id)
                           AND   lock_by_document_type=p_target_doc_type
                           AND   lock_by_document_id=p_target_doc_id
                          )
         )
        /*OR
        ( p_retain_lock_terms_yn = 'Y'
          AND NOT EXISTS ( SELECT 'LOCKEXISTS'
                              FROM okc_k_entity_locks  lck,okc_sections_b sec
                           WHERE entity_name='DUMMYSEC'
                           AND   entity_pk1 = To_Char(id)
                           AND   lock_by_document_type=p_target_doc_type
                           AND   lock_by_document_id=p_target_doc_id
                           AND   sec.document_type =  p_target_doc_type
                           AND   sec.document_id   =  p_target_doc_id

                          )
         )*/
      );


CURSOR l_get_scn_from_archive_csr IS
SELECT OKC_SECTIONS_B_S.NEXTVAL,
       ATTRIBUTE_CATEGORY,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       SCN_ID SCN_ID,
       DECODE(P_KEEP_ORIG_REF, 'Y', ORIG_SYSTEM_REFERENCE_ID1,ID) ORIG_SYSTEM_REFERENCE_ID1,
       SECTION_SEQUENCE,
       LABEL,
       SCN_CODE,
       HEADING,
       PRINT_YN ,
       DESCRIPTION
FROM  OKC_SECTIONS_BH
WHERE DOCUMENT_TYPE=P_SOURCE_DOC_TYPE
  AND DOCUMENT_ID=P_SOURCE_DOC_ID
  AND MAJOR_VERSION = nvl(p_source_version_number,OKC_API.G_MISS_NUM)
  AND  (( l_scn_drp_action = 'DROP_AMEND_SEC' AND
         heading <> Nvl(fnd_profile.Value('OKC_AMENDMENT_SPECIFIC_SECTION'),'~!@#$%')
       ) OR
       (
         l_scn_drp_action = 'DROP_PROV_SEC' AND
         OKC_CODE_HOOK.IS_NOT_PROVISIONAL_SECTION(heading,P_SOURCE_DOC_TYPE, P_SOURCE_DOC_ID) = FND_API.G_TRUE
       ) OR
       l_scn_drp_action = 'DROP_NOTHING');

--kkolukul: CLM changes
CURSOR l_scn_sqn_csr IS
  SELECT Max(section_sequence) FROM okc_sections_b
  WHERE DOCUMENT_TYPE=P_TARGET_DOC_TYPE
    AND DOCUMENT_ID=P_TARGET_DOC_ID;

CURSOR l_get_scn_exists_in_doc(p_scn_code varchar2) IS
    SELECT 'Y'
      FROM okc_sections_b
      WHERE document_type = p_target_doc_type
        AND document_id = p_target_doc_id
        AND scn_code = p_scn_code;

--------------------  CONC MOD CHANGES -------------
CURSOR cur_orphan_upd_sections
IS
 SELECT tgtsec.id,tgtsec2.id
   FROM okc_sections_b tgtsec
       ,okc_sections_b srcsec
       ,okc_sections_b tgtsec2
   WHERE     1 = 1
   AND tgtsec.document_type= p_target_doc_type
   AND tgtsec.document_id=   p_target_doc_id
   AND tgtsec.summary_amend_operation_code IN ('UPDATED','DELTED')
   AND tgtsec.scn_id IS NOT NULL

   AND tgtsec.orig_system_reference_id1 = srcsec.id
   AND srcsec.document_type= p_source_doc_type
   AND srcsec.document_id= p_source_doc_id
   AND tgtsec2.document_type=p_target_doc_type
   AND tgtsec2.document_id=p_target_doc_id
   AND tgtsec2.ORIG_SYSTEM_REFERENCE_ID1=srcsec.scn_id;
   --------------------  CONC MOD CHANGES -------------


TYPE ScnList IS TABLE OF okc_sections_b.ID%TYPE INDEX BY BINARY_INTEGER;



tgt_id_upd_tbl ScnList;
tgt_scn_id_upd_tbl ScnList;

BEGIN

  x_return_status :=  G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside OKC_TERMS_COPY_PVT.copy_sections');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside p_retain_lock_terms_yn : ' || p_retain_lock_terms_yn);
  END IF;


  l_scn_drp_action := clm_scn_filtering(p_source_doc_id,p_source_doc_type,p_target_doc_id,p_target_doc_type);

  IF p_copy_from_archive ='Y' THEN

        OPEN  l_get_scn_from_archive_csr;
        FETCH l_get_scn_from_archive_csr BULK COLLECT INTO
                                         id_tbl,
                                         Attribute_category_tbl,
                                         Attribute1_tbl,
                                         Attribute2_tbl,
                                         Attribute3_tbl,
                                         Attribute4_tbl,
                                         Attribute5_tbl,
                                         Attribute6_tbl,
                                         Attribute7_tbl,
                                         Attribute8_tbl,
                                         Attribute9_tbl,
                                         Attribute10_tbl,
                                         Attribute11_tbl,
                                         Attribute12_tbl,
                                         Attribute13_tbl,
                                         Attribute14_tbl,
                                         Attribute15_tbl,
                                         Scn_id_tbl,
                                         Orig_System_Reference_id1_tbl,
                                         Section_sequence_tbl,
                                         Label_tbl,
                                         Scn_code_tbl,
                                         Heading_tbl,
                                         Print_yn_tbl ,
                                         Description_tbl ;
               CLOSE l_get_scn_from_archive_csr;
  ELSE
               OPEN  l_get_scn_csr;
               FETCH l_get_scn_csr BULK COLLECT INTO
                                         id_tbl,
                                         Attribute_category_tbl,
                                         Attribute1_tbl,
                                         Attribute2_tbl,
                                         Attribute3_tbl,
                                         Attribute4_tbl,
                                         Attribute5_tbl,
                                         Attribute6_tbl,
                                         Attribute7_tbl,
                                         Attribute8_tbl,
                                         Attribute9_tbl,
                                         Attribute10_tbl,
                                         Attribute11_tbl,
                                         Attribute12_tbl,
                                         Attribute13_tbl,
                                         Attribute14_tbl,
                                         Attribute15_tbl,
                                         Scn_id_tbl,
                                         Orig_System_Reference_id1_tbl,
                                         Section_sequence_tbl,
                                         Label_tbl,
                                         Scn_code_tbl,
                                         Heading_tbl,
                                         Print_yn_tbl,
                                         Description_tbl ;
               CLOSE l_get_scn_csr;
 END IF;

  id_tbl1                        := id_tbl;
  Orig_System_Reference_id1_tbl1 := Orig_System_Reference_id1_tbl;

-- Following routine will link subsections to its parent section

  IF id_tbl.COUNT>0 THEN

     FOR i IN id_tbl.FIRST..id_tbl.LAST LOOP


          IF scn_id_tbl(i) IS NOT NULL THEN
              FOR k IN id_tbl1.FIRST..id_tbl1.LAST LOOP
                    IF Orig_System_Reference_id1_tbl1(k)= scn_id_tbl(i) THEN
                             scn_id_tbl(i) := id_tbl1(k);
                    END IF;
              END LOOP;
          END IF;
     END LOOP;

  END IF;

  /*kkolukul: clm changes: section sequence is getting copied directly from template.
    Since we are adding multiple templates, there are being 2 sections with same sequence.*/
  IF (p_retain_clauses = 'Y') THEN
    OPEN l_scn_sqn_csr;
    FETCH l_scn_sqn_csr INTO l_max_sequence;
    CLOSE l_scn_sqn_csr;

    IF id_tbl.COUNT > 0 THEN
      FOR i IN id_tbl.FIRST..id_tbl.LAST LOOP
        l_max_sequence := l_max_sequence + 10;
        Section_sequence_tbl(i) := l_max_sequence;

        OPEN l_get_scn_exists_in_doc(scn_code_tbl(i));
        FETCH l_get_scn_exists_in_doc INTO l_copy_section_yn;
        CLOSE l_get_scn_exists_in_doc;

        IF Nvl(l_copy_section_yn, 'N') = 'N' THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside Ol_copy_section_yn: ' || l_copy_section_yn);
          END IF;

        END IF;
      END LOOP;
    END IF;
  END IF;
   --end - kkolukul: clm changes



  IF id_tbl.COUNT > 0 THEN

     FORALL i IN id_tbl.FIRST..id_tbl.LAST

               INSERT INTO OKC_SECTIONS_B(
                                          ID,
                                          DOCUMENT_TYPE,
                                          DOCUMENT_ID,
                                          CHR_ID,
                                          SCN_ID,
                                          LABEL,
                                          AMENDMENT_DESCRIPTION,
                                          AMENDMENT_OPERATION_CODE,
                                          ORIG_SYSTEM_REFERENCE_CODE,
                                          ORIG_SYSTEM_REFERENCE_ID1,
                                          ORIG_SYSTEM_REFERENCE_ID2,
                                          SECTION_SEQUENCE,
                                          ATTRIBUTE_CATEGORY,
                                          ATTRIBUTE1,
                                          ATTRIBUTE2,
                                          ATTRIBUTE3,
                                          ATTRIBUTE4,
                                          ATTRIBUTE5,
                                          ATTRIBUTE6,
                                          ATTRIBUTE7,
                                          ATTRIBUTE8,
                                          ATTRIBUTE9,
                                          ATTRIBUTE10,
                                          ATTRIBUTE11,
                                          ATTRIBUTE12,
                                          ATTRIBUTE13,
                                          ATTRIBUTE14,
                                          ATTRIBUTE15,
                                          PRINT_YN,
                                          HEADING,
                                          SCN_CODE,
                                          DESCRIPTION,
                                          OBJECT_VERSION_NUMBER,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_LOGIN,
                                          LAST_UPDATE_DATE)
                          VALUES(id_tbl(i),
                                 p_target_doc_type,
                                 p_target_doc_id,
                                  decode(p_target_doc_type,'OKC_BUY',p_target_doc_id, 'OKC_SELL',p_target_doc_id, 'OKO',p_target_doc_id,'OKS',p_target_doc_id,'OKE_BUY',p_target_doc_id, 'OKE_SELL',p_target_doc_id, 'OKL',p_target_doc_id,NULL),
                                 Scn_id_tbl(i),
                                 Label_tbl(i),
                                 Null,
                                 Null,
                                 G_COPY,
                                 Orig_System_Reference_id1_tbl(i),
                                 Null,
                                 section_sequence_tbl(i),
                                 Attribute_category_tbl(i),
                                 Attribute1_tbl(i),
                                 Attribute2_tbl(i),
                                 Attribute3_tbl(i),
                                 Attribute4_tbl(i),
                                 Attribute5_tbl(i),
                                 Attribute6_tbl(i),
                                 Attribute7_tbl(i),
                                 Attribute8_tbl(i),
                                 Attribute9_tbl(i),
                                 Attribute10_tbl(i),
                                 Attribute11_tbl(i),
                                 Attribute12_tbl(i),
                                 Attribute13_tbl(i),
                                 Attribute14_tbl(i),
                                 Attribute15_tbl(i),
                                 print_yn_tbl(i),
                                 heading_tbl(i),
                                 scn_code_tbl(i),
                                 description_tbl(i),
                                 1,
                                 Fnd_Global.User_Id,
                                 sysdate,
                                 Fnd_Global.User_Id,
                                 Fnd_Global.Login_Id,
                                 sysdate);

  END IF;

 --------------------  CONC MOD CHANGES -------------

IF p_retain_lock_terms_yn = 'Y'
THEN


 -- CASE a SUB-SECTION IS UPDATED/DELETED
     OPEN  cur_orphan_upd_sections;
     FETCH cur_orphan_upd_sections bulk COLLECT INTO  tgt_id_upd_tbl ,tgt_scn_id_upd_tbl ;
     CLOSE cur_orphan_upd_sections;

       IF  tgt_id_upd_tbl.Count > 0 THEN
        FORALL i IN tgt_id_upd_tbl.first..tgt_id_upd_tbl.last
        UPDATE okc_k_articles_b
          SET  scn_id= tgt_scn_id_upd_tbl (i)
        WHERE  id= tgt_id_upd_tbl (i);
       END IF;
END IF;
--------------------  CONC MOD CHANGES -------------

  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: Leaving copy_sections '||x_return_status);
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving copy_sections:FND_API.G_EXC_ERROR Exception');
  END IF;

  IF l_get_scn_csr %ISOPEN THEN
    CLOSE l_get_scn_csr ;
  END IF;

  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_sections:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
  END IF;

  IF l_get_scn_csr %ISOPEN THEN
    CLOSE l_get_scn_csr ;
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving copy_sections because of EXCEPTION: '||sqlerrm);
  END IF;

  IF l_get_scn_csr %ISOPEN THEN
    CLOSE l_get_scn_csr ;
  END IF;

  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END copy_sections;


-- This API will be called wheneve a template is re-applied on a document.
-- It will put all the manually added article into UN-Assigned section and remove other articles and section;

procedure remove_template_based_articles(
                           p_doc_type           IN      VARCHAR2,
                           p_doc_id             IN      NUMBER,
                           p_retain_deliverable IN      VARCHAR2,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_msg_data           OUT NOCOPY VARCHAR2,
                           x_msg_count          OUT NOCOPY NUMBER) IS

l_api_name                     CONSTANT VARCHAR2(30) := 'remove_template_based_articles';
CURSOR l_get_manual_art_csr IS
SELECT count(*)
FROM  OKC_K_ARTICLES_B
WHERE DOCUMENT_TYPE =  p_doc_type
  AND DOCUMENT_ID   =  p_doc_id
  AND SOURCE_FLAG IS NULL;

CURSOR l_check_unassigned_section_csr IS
SELECT id
FROM  OKC_SECTIONS_B
WHERE DOCUMENT_TYPE =  p_doc_type
  AND DOCUMENT_ID   =  p_doc_id
  AND nvl(AMENDMENT_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
  AND nvl(SUMMARY_AMEND_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
  AND SCN_CODE = 'UNASSIGNED';

CURSOR lock_kart_for_upd_csr IS
SELECT ROWID FROM OKC_K_ARTICLES_B
      WHERE DOCUMENT_TYPE   =  p_doc_type
        AND DOCUMENT_ID     =  p_doc_id
        AND SOURCE_FLAG IS NULL FOR UPDATE NOWAIT;

CURSOR lock_var_for_del_csr IS
SELECT ROWID FROM OKC_K_ART_VARIABLES
WHERE CAT_ID IN
     (SELECT ID FROM OKC_K_ARTICLES_B
                WHERE DOCUMENT_TYPE=p_doc_type
                AND DOCUMENT_ID=p_doc_id
                AND SOURCE_FLAG IS NOT NULL) FOR UPDATE NOWAIT;

CURSOR lock_kart_for_del_csr IS
SELECT ROWID FROM OKC_K_ARTICLES_B WHERE DOCUMENT_TYPE=p_doc_type
                                 AND DOCUMENT_ID=p_doc_id
                                 AND SOURCE_FLAG IS NOT NULL FOR UPDATE NOWAIT;

CURSOR lock_scn_for_del_csr(b_scn_id NUMBER) IS
SELECT ROWID FROM OKC_SECTIONS_B
WHERE DOCUMENT_TYPE=p_doc_type
  AND DOCUMENT_ID=p_doc_id
  AND id <> b_scn_id FOR UPDATE NOWAIT;

--kkolukul: clm Changes
CURSOR objnum_mlp_tu_csr IS
  SELECT object_version_number
    FROM OKC_MLP_TEMPLATE_USAGES
    WHERE DOCUMENT_TYPE = p_doc_type AND DOCUMENT_ID = p_doc_id;

l_manual_art_count NUMBER;
l_unassigned_scn_id OKC_SECTIONS_B.ID%TYPE := 0;
l_objnum           NUMBER;
l_found            BOOLEAN;


BEGIN

  x_return_status :=  G_RET_STS_SUCCESS;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Inside OKC_TERMS_COPY_PVT.remove_template_based_articles');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_doc_type : '||p_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_doc_id : '||p_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_retain_deliverable : '||p_retain_deliverable);
  END IF;

  OPEN  l_get_manual_art_csr;
  FETCH l_get_manual_art_csr INTO l_manual_art_count;
  CLOSE l_get_manual_art_csr;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'110: l_manual_art_count : '||l_manual_art_count);
  END IF;

  IF l_manual_art_count > 0 THEN

       OPEN  l_check_unassigned_section_csr ;
       FETCH l_check_unassigned_section_csr INTO l_unassigned_scn_id;
       CLOSE l_check_unassigned_section_csr;

       IF l_unassigned_scn_id = 0 THEN

           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'120: Creating Unassgined Section ');
           END IF;

            OKC_TERMS_UTIL_PVT.create_unassigned_section(p_api_version  => 1,
                                                         p_commit       => FND_API.G_FALSE,
                                                         p_doc_type     => p_doc_type,
                                                         p_doc_id       => p_doc_id,
                                                         x_scn_id       =>l_unassigned_scn_id,
                                                         x_return_status      => x_return_status,
                                                         x_msg_count          => x_msg_count,
                                                         x_msg_data           => x_msg_data
                                                        );
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'130: l_unassigned_scn_id : '||l_unassigned_scn_id);
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'130: Cannot Create Unassgined Section : '||x_msg_data||' Status '||x_return_status);
                END IF;

                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR ;
                 END IF;


       END IF;

       OPEN  lock_kart_for_upd_csr;
       CLOSE lock_kart_for_upd_csr;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'140: Updating Manually added article sections to unassigned');
       END IF;

       UPDATE OKC_K_ARTICLES_B
       SET SCN_ID = l_unassigned_scn_id,
           LAST_UPDATED_BY   = FND_GLOBAl.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAl.LOGIN_ID,
           LAST_UPDATE_DATE  = sysdate
      WHERE DOCUMENT_TYPE   =  p_doc_type
        AND DOCUMENT_ID     =  p_doc_id
        AND SOURCE_FLAG IS NULL;

  END IF;

  OPEN  lock_var_for_del_csr;
  CLOSE lock_var_for_del_csr;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'150: Deleting Variables ');
       END IF;

  DELETE FROM OKC_K_ART_VAR_EXT_B WHERE
  Nvl(major_version,-99) = -99
   AND cat_id IN ( SELECT kart.ID
                                                    FROM  OKC_K_ARTICLES_B KART
                                                          , OKC_BUS_VARIABLES_B BUS_VAR
                                                          , OKC_K_ART_VARIABLES KVAR
                                                    WHERE kart.document_type=p_doc_type
                                                     AND   kart.document_id = p_doc_id
                                                     AND   kart.SOURCE_FLAG IS NOT NULL
                                                     AND   KVAR.cat_id=kart.id
                                                     AND   KVAR.variable_code=BUS_VAR.variable_code
                                                     AND   BUS_VAR.MRV_FLAG='Y');

  DELETE FROM OKC_K_ART_VARIABLES WHERE CAT_ID IN
                              (SELECT ID FROM OKC_K_ARTICLES_B WHERE DOCUMENT_TYPE=p_doc_type
                                                                 AND DOCUMENT_ID=p_doc_id
                                                                 AND SOURCE_FLAG IS NOT NULL);
  OPEN  lock_kart_for_del_csr;
  CLOSE lock_kart_for_del_csr;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'160: Deleting Articles ');
       END IF;

  DELETE FROM OKC_K_ARTICLES_B WHERE DOCUMENT_TYPE=p_doc_type
                                 AND DOCUMENT_ID=p_doc_id
                                 AND SOURCE_FLAG IS NOT NULL;

  OPEN  lock_scn_for_del_csr(l_unassigned_scn_id);
  CLOSE lock_scn_for_del_csr;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'170: Deleting Sections ');
       END IF;

  DELETE FROM OKC_SECTIONS_B WHERE DOCUMENT_TYPE=p_doc_type
                                 AND DOCUMENT_ID=p_doc_id
                                 AND id <> l_unassigned_scn_id;

  IF p_retain_deliverable ='N' THEN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'180: Calling OKC_DELIVERABLE_PROCESS_PVT.delete_template_deliverables ');
       END IF;

      OKC_DELIVERABLE_PROCESS_PVT.delete_template_deliverables (
                                  p_api_version    => 1,
                                  p_init_msg_list  => FND_API.G_FALSE,
                                  p_doc_id         => p_doc_id,
                                  p_doc_type       => p_doc_type,
                                  x_msg_data       => x_msg_data,
                                  x_msg_count      => x_msg_count,
                                  x_return_status  => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'180: After Call to OKC_DELIVERABLE_PROCESS_PVT.delete_template_deliverables ');
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'180: x_return_status : '||x_return_status);
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'180: x_msg_count : '||x_msg_count);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
       END IF;

       /*kkolukul: clm changes- Delete entries from multiple templates table*/

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'3900: Delete a record from okc_template_usages for the doc');
       END IF;

        l_objnum := -1;
        OPEN objnum_mlp_tu_csr;
        FETCH objnum_mlp_tu_csr INTO l_objnum;
        l_found := objnum_mlp_tu_csr%FOUND;
        CLOSE objnum_mlp_tu_csr;
        IF l_found THEN
          OKC_CLM_PKG.Delete_Usages_Row(
            x_return_status         => x_return_status,
            p_document_type         => p_doc_type,
            p_document_id           => p_doc_id,
            p_object_version_number => l_objnum
          );
         --------------------------------------------
          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
          END IF;
          --------------------------------------------
        END IF;

    ---end clm changes.

  END IF;

  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900: Leaving remove_template_based_articles '||x_return_status);
  END IF;

EXCEPTION
WHEN  E_Resource_Busy THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'000: Leaving remove_template_based_articles:E_Resource_Busy Exception');
   END IF;

  IF lock_kart_for_upd_csr%ISOPEN THEN
    CLOSE  lock_kart_for_upd_csr;
  END IF;

  IF lock_var_for_del_csr%ISOPEN THEN
    CLOSE  lock_var_for_del_csr;
  END IF;

  IF lock_kart_for_del_csr%ISOPEN THEN
    CLOSE  lock_kart_for_del_csr;
  END IF;

  IF lock_scn_for_del_csr%ISOPEN THEN
    CLOSE  lock_scn_for_del_csr;
  END IF;

  IF l_get_manual_art_csr%ISOPEN THEN
    CLOSE l_get_manual_art_csr ;
  END IF;

  IF l_check_unassigned_section_csr%ISOPEN THEN
    CLOSE l_check_unassigned_section_csr ;
  END IF;

      Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);
      x_return_status := G_RET_STS_ERROR ;
WHEN FND_API.G_EXC_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving remove_template_based_articles:FND_API.G_EXC_ERROR Exception');
  END IF;

  IF lock_kart_for_upd_csr%ISOPEN THEN
    CLOSE  lock_kart_for_upd_csr;
  END IF;

  IF lock_var_for_del_csr%ISOPEN THEN
    CLOSE  lock_var_for_del_csr;
  END IF;

  IF lock_kart_for_del_csr%ISOPEN THEN
    CLOSE  lock_kart_for_del_csr;
  END IF;

  IF lock_scn_for_del_csr%ISOPEN THEN
    CLOSE  lock_scn_for_del_csr;
  END IF;

  IF l_get_manual_art_csr%ISOPEN THEN
    CLOSE l_get_manual_art_csr ;
  END IF;

  IF l_check_unassigned_section_csr%ISOPEN THEN
    CLOSE l_check_unassigned_section_csr ;
  END IF;

  x_return_status := G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving remove_template_based_articles:FND_API.G_EXC_UNEXPECTED_ERROR Exception');
  END IF;

  IF lock_kart_for_upd_csr%ISOPEN THEN
    CLOSE  lock_kart_for_upd_csr;
  END IF;

  IF lock_var_for_del_csr%ISOPEN THEN
    CLOSE  lock_var_for_del_csr;
  END IF;

  IF lock_kart_for_del_csr%ISOPEN THEN
    CLOSE  lock_kart_for_del_csr;
  END IF;

  IF lock_scn_for_del_csr%ISOPEN THEN
    CLOSE  lock_scn_for_del_csr;
  END IF;

  IF l_get_manual_art_csr%ISOPEN THEN
    CLOSE l_get_manual_art_csr ;
  END IF;

  IF l_check_unassigned_section_csr%ISOPEN THEN
    CLOSE l_check_unassigned_section_csr ;
  END IF;

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving remove_template_based_articles because of EXCEPTION: '||sqlerrm);
  END IF;

  IF l_get_manual_art_csr%ISOPEN THEN
    CLOSE l_get_manual_art_csr ;
  END IF;

  IF l_check_unassigned_section_csr%ISOPEN THEN
    CLOSE l_check_unassigned_section_csr ;
  END IF;

  okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                      p_msg_name     => G_UNEXPECTED_ERROR,
                      p_token1       => G_SQLCODE_TOKEN,
                      p_token1_value => sqlcode,
                      p_token2       => G_SQLERRM_TOKEN,
                      p_token2_value => sqlerrm);

  x_return_status := G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END remove_template_based_articles;

PROCEDURE copy_tc(
                  p_api_version             IN  NUMBER,
                  p_init_msg_list           IN  VARCHAR2,
                  p_commit                  IN  VARCHAR2,
                  p_source_doc_type         IN  VARCHAR2,
                  p_source_doc_id           IN  NUMBER,
                  p_target_doc_type         IN  OUT NOCOPY VARCHAR2,
                  p_target_doc_id           IN  OUT NOCOPY NUMBER,
                  p_keep_version            IN  VARCHAR2,
                  p_article_effective_date  IN  DATE,
                  p_target_template_rec     IN  OKC_TERMS_TEMPLATES_PVT.template_rec_type,
                  p_document_number         IN  VARCHAR2,
                  p_retain_deliverable      IN  VARCHAR2,
                  p_allow_duplicates        IN  VARCHAR2,
                  p_keep_orig_ref           IN  VARCHAR2,
                  x_return_status           OUT NOCOPY VARCHAR2,
                  x_msg_data                OUT NOCOPY VARCHAR2,
                  x_msg_count               OUT NOCOPY NUMBER,
                  p_copy_abstract_yn     IN VARCHAR,
			      p_copy_for_amendment      IN VARCHAR2 default 'N',
			      -- Fix for defaulting Contract Admin
			      p_contract_admin_id IN NUMBER := NULL,
			      p_legal_contact_id IN NUMBER := NULL,
                  p_retain_clauses      IN  VARCHAR2          --kkolukul: CLM Changes

                  , p_retain_lock_terms_yn  IN  VARCHAR2 -- conc Mod changes start
                  ,p_retain_lock_xprt_yn         IN VARCHAR2 -- conc Mod changes start
                        ) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'copy_tc';
l_dummy_var                VARCHAR2(1) :='?';
l_doc_type_name            OKC_BUS_DOC_TYPES_V.NAME%TYPE;
l_article_effective_date   DATE;
l_template_id              OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE;
l_document_type            OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE;
l_document_id              NUMBER;
l_get_from_library         VARCHAR2(1);
l_no_terms_found           BOOLEAN :=FALSE;
l_tmpl_usage_id            NUMBER;
lx_tmpl_usage_id           NUMBER;
l_term_instantiated        VARCHAR2(1);
l_approval_abstract_text   OKC_TEMPLATE_USAGES.APPROVAL_ABSTRACT_TEXT%TYPE;
l_contract_admin_id        OKC_TEMPLATE_USAGES.CONTRACT_ADMIN_ID%TYPE;
l_legal_contact_id         OKC_TEMPLATE_USAGES.LEGAL_CONTACT_ID%TYPE;

CURSOR l_get_allwd_tmp_usages_csr IS
SELECT '!' FROM OKC_ALLOWED_TMPL_USAGES
WHERE template_id=p_source_doc_id
AND   document_type = p_target_doc_type;

CURSOR l_get_tmpl_csr IS
SELECT * FROM OKC_TERMS_TEMPLATES_ALL
WHERE template_id=p_source_doc_id;

CURSOR l_get_doc_type_name_csr IS
SELECT name  FROM OKC_BUS_DOC_TYPES_V
WHERE  document_type = p_target_doc_type;

CURSOR l_check_tmp_usage_csr IS
SELECT '!'  FROM OKC_TEMPLATE_USAGES
WHERE document_type = p_target_doc_type
AND   document_id   = p_target_doc_id;

CURSOR l_lock_usg_csr IS
SELECT ROWID FROM OKC_TEMPLATE_USAGES
WHERE  DOCUMENT_TYPE=p_target_doc_type
AND    DOCUMENT_ID=p_target_doc_id
FOR    UPDATE NOWAIT;

CURSOR l_get_usage_csr IS
SELECT * FROM OKC_TEMPLATE_USAGES
WHERE DOCUMENT_TYPE=p_source_doc_type
AND   DOCUMENT_ID=p_source_doc_id;

CURSOR l_get_tgt_usage_csr IS
SELECT * FROM OKC_TEMPLATE_USAGES
WHERE DOCUMENT_TYPE=p_target_doc_type
AND   DOCUMENT_ID=p_target_doc_id;


-- Bug 8246502 Changes Begins
l_config_exists VARCHAR2(1):='N';

CURSOR check_config_exists(c_config_header_id number,c_config_rev_nbr number) IS
SELECT 'Y'
FROM cz_config_hdrs
WHERE  config_hdr_id  = c_config_header_id
AND  config_rev_nbr =   c_config_rev_nbr;
-- Bug 8246502 Changes Begins

CURSOR l_get_target_usage IS
SELECT 'Y' FROM OKC_TEMPLATE_USAGES
WHERE DOCUMENT_TYPE=p_target_doc_type
AND   DOCUMENT_ID=p_target_doc_id;

CURSOR l_get_allwd_usage_csr(b_source_doc_id NUMBER) IS
SELECT * from okc_allowed_tmpl_usages where
template_id=b_source_doc_id;

l_tmpl_rec l_get_tmpl_csr%ROWTYPE;
l_usage_rec l_get_usage_csr%ROWTYPE;
l_tgt_usage_rec l_get_tgt_usage_csr%ROWTYPE;

l_header_id NUMBER;
l_rev_nbr  NUMBER;
l_source_change_allowed_flag VARCHAR2(1) := 'Y';
lx_new_contract_admin_id NUMBER;  -- Added for Bug 6080483

l_copy_xprt_data VARCHAR2(1) := 'Y';

--contracts rules engines changes
l_cntrcts_ruls_eng_exists VARCHAR(1) := 'N';

BEGIN

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entering OKC_TERMS_COPY_PVT.copy_tc ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_api_version : '||p_api_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_commit : '||p_commit);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_source_doc_type : '||p_source_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_source_doc_id : '||p_source_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_target_doc_type : '||p_target_doc_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_target_doc_id : '||p_target_doc_id);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_keep_version : '||p_keep_version);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_article_effective_date : '||p_article_effective_date);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_document_number : '||p_document_number);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_retain_deliverable : '||p_retain_deliverable);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: p_allow_duplicates : '||p_allow_duplicates);
END IF;

-- Standard Start of API savepoint
SAVEPOINT g_copy_tc_pvt;

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

-- Checking If doc types are valid

  IF (p_source_doc_type IS NOT NULL
     AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_PVT.is_doc_type_valid ( p_doc_type => p_source_doc_type , x_return_status => x_return_status))) THEN

      okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKC_INVALID_DOC_TYPE',
                           p_token1       => 'DOCUMENT_TYPE',
                           p_token2_value => p_source_doc_type);
       RAISE FND_API.G_EXC_ERROR ;


  END IF;

  IF (p_target_doc_type IS NOT NULL
     AND NOT FND_API.To_Boolean(OKC_TERMS_UTIL_PVT.is_doc_type_valid ( p_doc_type => p_target_doc_type , x_return_status => x_return_status))) THEN

      okc_Api.Set_Message(p_app_name      => G_APP_NAME,
                           p_msg_name     => 'OKC_INVALID_DOC_TYPE',
                           p_token1       => 'DOCUMENT_TYPE',
                           p_token2_value => p_target_doc_type);
       RAISE FND_API.G_EXC_ERROR ;

  END IF;

IF p_target_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
   AND p_source_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN  -- Template to Template Copy

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200:Case of Template to Template Copy ');
  END IF;


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100:Start template Creation. template Name '||p_target_template_rec.template_name);
   END IF;

    OKC_TERMS_TEMPLATES_GRP.create_template(
                          p_api_version            => 1,
                          p_init_msg_list          => FND_API.G_FALSE,
                          p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                          p_commit                 => FND_API.G_FALSE,
                          x_return_status          => x_return_status,
                          x_msg_count              => x_msg_count,
                          x_msg_data               => x_msg_data,
                          p_template_name          => p_target_template_rec.template_name,
                          p_template_id            => Null,
                          p_working_copy_flag      => p_target_template_rec.working_copy_flag,
                          p_intent                 => p_target_template_rec.intent,
                          p_status_code            => p_target_template_rec.status_code,
                          p_start_date             => p_target_template_rec.start_date,
                          p_end_date               => p_target_template_rec.end_date,
                          p_global_flag            => p_target_template_rec.global_flag,
                          p_parent_template_id     => p_target_template_rec.parent_template_id,
                          p_print_template_id      => p_target_template_rec.print_template_id,
                          p_contract_expert_enabled=> p_target_template_rec.contract_expert_enabled,
                          p_xprt_clause_mandatory_flag => p_target_template_rec.xprt_clause_mandatory_flag, -- Added for 11.5.10+: Contract Expert Changes
                          p_xprt_scn_code          => p_target_template_rec.xprt_scn_code, -- bug# 4004496
                          p_template_model_id      => p_target_template_rec.template_model_id,
                          p_instruction_text       => p_target_template_rec.instruction_text,
                          p_tmpl_numbering_scheme  => p_target_template_rec.tmpl_numbering_scheme,
                          p_description            => p_target_template_rec.description,
                          p_org_id                 => p_target_template_rec.org_id,
                          p_orig_system_reference_code=> p_target_template_rec.orig_system_reference_code,
                          p_orig_system_reference_id1=> p_target_template_rec.orig_system_reference_id1,
                          p_orig_system_reference_id2=> p_target_template_rec.orig_system_reference_id2,
                          p_cz_export_wf_key       => p_target_template_rec.cz_export_wf_key,
                          p_attribute_category     => p_target_template_rec.attribute_category,
                          p_attribute1             => p_target_template_rec.attribute1,
                          p_attribute2             => p_target_template_rec.attribute2,
                          p_attribute3             => p_target_template_rec.attribute3,
                          p_attribute4             => p_target_template_rec.attribute4,
                          p_attribute5             => p_target_template_rec.attribute5,
                          p_attribute6             => p_target_template_rec.attribute6,
                          p_attribute7             => p_target_template_rec.attribute7,
                          p_attribute8             => p_target_template_rec.attribute8,
                          p_attribute9             => p_target_template_rec.attribute9,
                          p_attribute10            => p_target_template_rec.attribute10,
                          p_attribute11            => p_target_template_rec.attribute11,
                          p_attribute12            => p_target_template_rec.attribute12,
                          p_attribute13            => p_target_template_rec.attribute13,
                          p_attribute14            => p_target_template_rec.attribute14,
                          p_attribute15            => p_target_template_rec.attribute15,
		 --MLS for templates
	                  p_language               => p_target_template_rec.language,
	                  p_translated_from_tmpl_id => p_target_template_rec.translated_from_tmpl_id,

                          x_template_id            => l_template_id);

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'150:Finished template Creation. Return Status '||x_return_status||' new template_id '||l_template_id);
              END IF;

              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
              END IF;

              p_target_doc_id := l_template_id;

             IF p_target_template_rec.working_copy_flag='Y' THEN

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'160:Calling OKC_ALLOWED_TMPL_USAGES_GRP.Create_Allowed_Tmpl_Usages');
             END IF;

                 -- Copy Usage record.
                 FOR cr in l_get_allwd_usage_csr(p_target_template_rec.parent_template_id) LOOP
                   select OKC_ALLOWED_TMPL_USAGES_S.NEXTVAL into l_tmpl_usage_id from dual;
                    OKC_ALLOWED_TMPL_USAGES_GRP.Create_Allowed_Tmpl_Usages(
                                            p_api_version   =>1,
                                            p_init_msg_list =>FND_API.G_FALSE,
                                            p_commit        => FND_API.G_FALSE,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_template_id   => l_template_id,
                                            p_document_type => cr.document_type,
                                            p_default_yn    => cr.default_yn,
                                            p_allowed_tmpl_usages_id =>l_tmpl_usage_id,
                                            p_attribute_category =>cr.attribute_category,
                                            p_attribute1       =>cr.attribute1,
                                            p_attribute2       =>cr.attribute2,
                                            p_attribute3       =>cr.attribute3,
                                            p_attribute4       =>cr.attribute4,
                                            p_attribute5       =>cr.attribute5,
                                            p_attribute6       =>cr.attribute6,
                                            p_attribute7       =>cr.attribute7,
                                            p_attribute8       =>cr.attribute8,
                                            p_attribute9       =>cr.attribute9,
                                            p_attribute10      =>cr.attribute10,
                                            p_attribute11      =>cr.attribute11,
                                            p_attribute12      =>cr.attribute12,
                                            p_attribute13      =>cr.attribute13,
                                            p_attribute14      =>cr.attribute14,
                                            p_attribute15      =>cr.attribute15,
                                            x_allowed_tmpl_usages_id =>lx_tmpl_usage_id
                                          );
                        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                                 RAISE FND_API.G_EXC_ERROR ;
                        END IF;
                END LOOP;

            END IF;

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200:Calling copy_section');
              END IF;

              copy_sections(
                      p_target_doc_type  => p_target_doc_type,
                      p_source_doc_type  => p_source_doc_type,
                      p_target_doc_id    => l_template_id,
                      p_source_doc_id    => p_source_doc_id,
                      p_source_version_number    => NULL,
                      p_copy_from_archive        => 'N',
                      x_return_status    => x_return_status,
                      x_msg_data         => x_msg_data,
                      x_msg_count        => x_msg_count);

              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300:Finished copy_section. Return Status '||x_return_status);
              END IF;

              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
              END IF;

             IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400:Entering copy_articles. ');
             END IF;

             copy_articles(
                      p_target_doc_type        => p_target_doc_type,
                      p_source_doc_type        => p_source_doc_type,
                      p_target_doc_id          => l_template_id,
                      P_source_doc_id          => p_source_doc_id,
                      p_keep_version           => p_keep_version,
                      p_article_effective_date => p_article_effective_date,
                      p_source_version_number  => NULL,
                      p_copy_from_archive      =>'N',
                      x_return_status          => x_return_status,
                      x_msg_data               => x_msg_data,
                      x_msg_count              => x_msg_count);

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700:Finished copy_articles. Return Status '||x_return_status);
            END IF;

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
            END IF;

             OKC_XPRT_TMPL_RULE_ASSNS_PVT.copy_template_rule_assns(
                        p_api_version           => 1,
                        p_init_msg_list         => FND_API.G_FALSE,
                        p_commit                    => FND_API.G_FALSE,
                        p_source_template_id    => p_source_doc_id,
                        p_target_template_id    => l_template_id,
                        x_return_status         => x_return_status,
                        x_msg_data                  => x_msg_data,
                        x_msg_count                 => x_msg_count
                       );

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800:Finished copy_template_rule_assns. Return Status '||x_return_status);
            END IF;

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
            END IF;

ELSIF p_source_doc_type<>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
  AND p_target_doc_type<>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN  -- Doc to Doc Copy

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200:Case of Document to Document Copy ');
   END IF;

   OPEN  l_get_usage_csr;
   FETCH l_get_usage_csr INTO l_usage_rec;
   IF l_get_usage_csr%NOTFOUND THEN
       l_no_terms_found := TRUE;
   END IF;

   CLOSE l_get_usage_csr;

   -- Conc Mod Changes Start
    IF  (  p_retain_lock_xprt_yn = 'Y' AND
         okc_k_entity_locks_grp.isLockExists(P_ENTITY_NAME => okc_k_entity_locks_grp.G_XPRT_ENTITY,
                                               p_LOCK_BY_DOCUMENT_TYPE => p_target_doc_type,
                                               p_LOCK_BY_DOCUMENT_ID   => p_target_doc_id
                                               ) = 'Y'
         ) THEN
            -- lock exists so do not copy xprt data.
            -- if next if block is not executed then the config header id, config_revision_number will be correct only.
            l_copy_xprt_data := 'N';

             OPEN  l_get_tgt_usage_csr;
             FETCH l_get_tgt_usage_csr INTO l_tgt_usage_rec;
             CLOSE l_get_tgt_usage_csr;

             l_usage_rec.config_header_id := l_tgt_usage_rec.config_header_id;
		         l_usage_rec.config_revision_number:=l_tgt_usage_rec.config_revision_number;
		         l_usage_rec.valid_config_yn:=l_tgt_usage_rec.valid_config_yn;

     END IF;


     BEGIN
			  SELECT UPPER(FND_PROFILE.VALUE('OKC_USE_CONTRACTS_RULES_ENGINE')) INTO l_cntrcts_ruls_eng_exists FROM DUAL;
			EXCEPTION
			  WHEN OTHERS THEN
					l_cntrcts_ruls_eng_exists  :=  'N';
			END;

      IF l_cntrcts_ruls_eng_exists IS NULL THEN
        l_cntrcts_ruls_eng_exists := 'N';
      END IF;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'550: contracts rules engine available:' || l_cntrcts_ruls_eng_exists);
     END IF;


        If not l_no_terms_found  AND l_copy_xprt_data = 'Y' THEN


          IF l_usage_rec.config_header_id IS NOT NULL  AND l_cntrcts_ruls_eng_exists = 'N' THEN
            -- Bug 8246502 Changes Begins
            OPEN check_config_exists(l_usage_rec.config_header_id,l_usage_rec.config_revision_number);
            FETCH check_config_exists INTO l_config_exists;
            CLOSE check_config_exists;



            IF l_config_exists = 'Y' THEN
            -- Bug 8246502 Changes Ends

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500:Calling OKC_XPRT_CZ_INT_PVT.copy_configuration');
                END IF;

              /* Call Copy Config API provided by Contract Expert Team */
                  OKC_XPRT_CZ_INT_PVT.copy_configuration(
                                    p_api_version           => 1,
                                    p_init_msg_list         => OKC_API.G_FALSE,
                                    p_config_header_id      =>l_usage_rec.config_header_id,
                                    p_config_rev_nbr        =>l_usage_rec.config_revision_number,
                                    p_new_config_flag        => FND_API.G_TRUE,
                                    x_new_config_header_id   => l_header_id,
                                    x_new_config_rev_nbr     => l_rev_nbr,
                                    x_return_status          => x_return_status,
                                    x_msg_data               => x_msg_data,
                                    x_msg_count              => x_msg_count);

                  l_usage_rec.config_header_id := l_header_id;
                  l_usage_rec.config_revision_number:=l_rev_nbr;

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: After Calling OKC_XPRT_CZ_INT_PVT.copy_configuration');
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: x_return_status '||x_return_status);
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500: x_msg_count '||x_msg_count);
                END IF;

                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
                END IF;

				-- Bug 8246502 Change
        END IF;

        -- begin of contracts rules engine copy
				ELSIF l_cntrcts_ruls_eng_exists = 'Y' THEN

					IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'550: Contracts rules engine is enabled.');
						FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'550: Copying question and response to okc_xprt_doc_ques_response.');
                    END IF;

					BEGIN
						INSERT INTO okc_xprt_doc_ques_response(doc_question_response_id,doc_id,doc_type,question_id,response)
							(SELECT okc_xprt_doc_ques_response_s.NEXTVAL,p_target_doc_id,p_target_doc_type,question_id,response
								FROM okc_xprt_doc_ques_response WHERE doc_id = p_source_doc_id AND doc_type = p_source_doc_type );

						IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
							FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'550: Succesfull in copying values to
							okc_xprt_doc_ques_response.');
						END IF;

					EXCEPTION
						WHEN OTHERS THEN
							IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
								FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'550: Failed copying values to
								okc_xprt_doc_ques_response.');
							END IF;
					END;
					-- end of contracts rules engine copy

        END IF; -- ending here;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600:Create Template usage record ');
  END IF;

  OPEN l_get_target_usage;
  FETCH l_get_target_usage into l_term_instantiated;
  CLOSE l_get_target_usage;

  IF ( p_copy_abstract_yn = 'Y') THEN
      l_approval_abstract_text := l_usage_rec.approval_abstract_text;
  END IF;
  IF (p_copy_for_amendment = 'Y' AND l_usage_rec.contract_source_code = G_ATTACHED_CONTRACT_SOURCE)   THEN
    l_source_change_allowed_flag := 'N';
  END IF;

-- Fix for Bug 4897464
  IF (p_copy_for_amendment = 'N')   THEN
     l_usage_rec.lock_terms_flag := NULL;
     l_usage_rec.locked_by_user_id := NULL;
  END IF;

  IF (p_allow_duplicates <> 'Y'  and l_term_instantiated='Y') or l_term_instantiated is NULL THEN
         l_contract_admin_id := p_contract_admin_id;
	       l_legal_contact_id  := p_legal_contact_id;
         IF(l_contract_admin_id is null) then
            if(p_target_doc_type = 'QUOTE') then
		          l_contract_admin_id := okc_terms_util_pvt.get_default_contract_admin_id(p_target_doc_type, p_target_doc_id);
		         end if;
		         if(l_contract_admin_id is null) then
               l_contract_admin_id := l_usage_rec.contract_admin_id;
	           end if;
	       end if;
	       if(l_legal_contact_id is null) then
	          l_legal_contact_id := l_usage_rec.legal_contact_id;
         end if;
	       -- Bug# 9406214
	       if l_config_exists = 'N' then
		      l_usage_rec.config_header_id := NULL;
		      l_usage_rec.config_revision_number:=NULL;
		      l_usage_rec.valid_config_yn:=NULL;
	       end if;
        IF l_copy_xprt_data = 'Y' THEN --
         OKC_TEMPLATE_USAGES_GRP.create_template_usages(
                                   p_api_version            => 1,
                                   p_init_msg_list          => FND_API.G_FALSE,
                                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                   p_commit                 => FND_API.G_FALSE,
                                   x_return_status           => x_return_status,
                                   x_msg_data                => x_msg_data,
                                   x_msg_count               => x_msg_count,
                                   p_document_type          => p_target_doc_type,
                                   p_document_id            => p_target_doc_id,
                                   p_template_id            => l_usage_rec.template_id,
                                   p_doc_numbering_scheme   => l_usage_rec.doc_numbering_scheme,
                                   p_document_number        => p_document_number,
                                   p_article_effective_date => p_article_effective_date,
                                   p_config_header_id       => l_usage_rec.config_header_id,
                                   p_config_revision_number => l_usage_rec.config_revision_number,
                                   p_valid_config_yn        => l_usage_rec.valid_config_yn,
                                   x_document_type          => l_document_type,
                                   x_document_id            => l_document_id,
                                   p_approval_abstract_text => l_approval_abstract_text,
                                   p_contract_source_code   => l_usage_rec.contract_source_code,
                                   p_authoring_party_code   => l_usage_rec.authoring_party_code,
							p_source_change_allowed_flag => l_source_change_allowed_flag,
							-- Additional fix for bug# 4116433.
							p_autogen_deviations_flag => l_usage_rec.autogen_deviations_flag,
							p_lock_terms_flag         => l_usage_rec.lock_terms_flag,
							p_enable_reporting_flag   => l_usage_rec.enable_reporting_flag,
							p_locked_by_user_id       => l_usage_rec.locked_by_user_id,
							-- Fix for defaulting Contract Admin
							       p_contract_admin_id  => l_contract_admin_id,
							       p_legal_contact_id  => l_legal_contact_id
                    -- Concurrent Mod changes
                     ,p_orig_system_reference_code => p_source_doc_type
                     ,p_orig_system_reference_id1   =>  p_source_doc_id,
				 			--new okc rules engine contract expert parameter
							p_contract_expert_finish_flag => l_usage_rec.contract_expert_finish_flag
                                                    );
                 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600:After call to OKC_TEMPLATE_USAGES_GRP.create_template_usages x_return_status : '||x_return_status);
         END IF;
        ELSIF  Nvl(l_copy_xprt_data,'N') = 'N' THEN
                   OKC_TEMPLATE_USAGES_GRP.update_template_usages(
                                   p_api_version            => 1,
                                   p_init_msg_list          => FND_API.G_FALSE,
                                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                   p_commit                 => FND_API.G_FALSE,
                                   x_return_status           => x_return_status,
                                   x_msg_data                => x_msg_data,
                                   x_msg_count               => x_msg_count,
                                   p_document_type          => p_target_doc_type,
                                   p_document_id            => p_target_doc_id,
                                   p_template_id            => l_usage_rec.template_id,
                                   p_doc_numbering_scheme   => l_usage_rec.doc_numbering_scheme,
                                   p_document_number        => p_document_number,
                                   p_article_effective_date => p_article_effective_date,
                                   p_config_header_id       => l_usage_rec.config_header_id,
                                   p_config_revision_number => l_usage_rec.config_revision_number,
                                   p_valid_config_yn        => l_usage_rec.valid_config_yn,
                                   p_approval_abstract_text => l_approval_abstract_text,
                                   p_contract_source_code   => l_usage_rec.contract_source_code,
                                   p_authoring_party_code   => l_usage_rec.authoring_party_code,
							p_source_change_allowed_flag => l_source_change_allowed_flag,
							-- Additional fix for bug# 4116433.
							p_autogen_deviations_flag => l_usage_rec.autogen_deviations_flag,
							p_lock_terms_flag         => l_usage_rec.lock_terms_flag,
							p_enable_reporting_flag   => l_usage_rec.enable_reporting_flag,
							p_locked_by_user_id       => l_usage_rec.locked_by_user_id,
							-- Fix for defaulting Contract Admin
							       p_contract_admin_id  => l_contract_admin_id,
							       p_legal_contact_id  => l_legal_contact_id
                                                    );


           IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600:After call to OKC_TEMPLATE_USAGES_GRP.create_template_usages x_return_status : '||x_return_status);
         END IF;

        END IF;


  END IF; -- IF p_allow_duplicates <> Y' THEN

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'650:Calling copy_section');
  END IF;

   copy_sections( p_target_doc_type      => p_target_doc_type,
                  p_source_doc_type      => p_source_doc_type,
                  p_target_doc_id        => p_target_doc_id,
                  p_source_doc_id        => p_source_doc_id,
                  p_source_version_number=> NULL,
                  p_copy_from_archive    => 'N',
                  p_keep_orig_ref        => p_keep_orig_ref,
                  x_return_status        => x_return_status,
                  x_msg_data             => x_msg_data,
                  x_msg_count            => x_msg_count
                  ,p_retain_lock_terms_yn => p_retain_lock_terms_yn);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'650:Finished copy_section. Return Status '||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700:Entering copy_articles');
  END IF;

   copy_articles(
                  p_target_doc_type            => p_target_doc_type,
                  p_source_doc_type            => p_source_doc_type,
                  p_target_doc_id              => p_target_doc_id,
                  p_source_doc_id              => p_source_doc_id,
                  p_keep_version               => p_keep_version,
                  p_article_effective_date     => p_article_effective_date,
                  p_source_version_number  => NULL,
                  p_copy_from_archive      =>'N',
                  p_keep_orig_ref              => p_keep_orig_ref,
                  x_return_status              => x_return_status,
                  x_msg_data                   => x_msg_data,
                  x_msg_count                  => x_msg_count
                  ,p_retain_lock_terms_yn => p_retain_lock_terms_yn);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700:Finished copy_articles. Return Status '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

       SELECT decode(p_keep_version,'Y','N','Y') INTO l_get_from_library FROM DUAL;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800:Entering copy_article_variables.  ');
       END IF;

       copy_article_variables(
                            p_target_doc_type      => p_target_doc_type,
                            p_source_doc_type      => p_source_doc_type,
                            p_target_doc_id        => p_target_doc_id,
                            p_source_doc_id        => p_source_doc_id,
                            p_get_from_library     => l_get_from_library,
                            p_keep_orig_ref        => p_keep_orig_ref,
                            x_return_status        => x_return_status,
                            x_msg_data             => x_msg_data,
                            x_msg_count            => x_msg_count
                            ,p_retain_lock_terms_yn => p_retain_lock_terms_yn);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900:Exited copy_article_variables.Return Status  '||x_return_status);
       END IF;

        /*When we are adding multiple templates to the doc, we need to copy all the templates
         added to the doc in the new table created : okc_mlp_template_usages. Calling the
         new API created to insert to this table*/
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'910:Create template usage record in okc_mlp_template_usages');
        END IF;
        okc_clm_pkg.copy_usages_row(
                      p_target_doc_type      => p_target_doc_type,
                      p_source_doc_type      => p_source_doc_type,
                      p_target_doc_id        => p_target_doc_id,
                      p_source_doc_id        => p_source_doc_id,
                      x_return_status        => x_return_status,
                      x_msg_count            => x_msg_count,
                      x_msg_data             => x_msg_data);
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'920:Exited copy_usages_row.Return Status  '||x_return_status);
        END IF;
        --end CLM Changes

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;
  END IF;

ELSIF p_source_doc_type=OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE
  AND p_target_doc_type<>OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE THEN -- Template to Doc Copy

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'204:Case of Template to Document Copy ');
  END IF;

  OPEN  l_get_tmpl_csr ;
  FETCH l_get_tmpl_csr INTO l_tmpl_rec;
  CLOSE l_get_tmpl_csr ;


  l_dummy_var := '?';
  OPEN  l_get_allwd_tmp_usages_csr;
  FETCH l_get_allwd_tmp_usages_csr INTO l_dummy_var;
  CLOSE l_get_allwd_tmp_usages_csr;

  IF l_dummy_var = '?' THEN

       OPEN  l_get_doc_type_name_csr ;
       FETCH l_get_doc_type_name_csr INTO l_doc_type_name;
       CLOSE l_get_doc_type_name_csr ;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300:For this Template,Doc type usage not defined ');
       END IF;

       okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKC_ALLOWED_USAGE',
                           p_token1       => 'TEMPLATE_NAME',
                           p_token1_value => l_tmpl_rec.template_name,
                           p_token2       => 'DOCUMENT_TYPE',
                           p_token2_value => l_doc_type_name);
       RAISE FND_API.G_EXC_ERROR ;

  END IF;

  l_dummy_var := '?';
  OPEN  l_check_tmp_usage_csr;
  FETCH l_check_tmp_usage_csr INTO l_dummy_var;
  CLOSE l_check_tmp_usage_csr;

  IF l_dummy_var <> '?' THEN

      -- Document already using a template.Need to delete those articles.
      /* kkolukul: clm changes - if retain Clauses = 'Y' then we need to retain
         the clauses from existing template and add clauses from the new template to this set.*/

      IF (p_retain_clauses = 'N') then

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400:Document was already using template.Removing template based articles from document');
       END IF;

       remove_template_based_articles(
                                   p_doc_type       => p_target_doc_type,
                                   p_doc_id         => p_target_doc_id,
                                   p_retain_deliverable => p_retain_deliverable,
                                   x_return_status  => x_return_status,
                                   x_msg_data         => x_msg_data,
                                   x_msg_count      => x_msg_count);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400:After Call to remove_template_based_articles x_return_status : '||x_return_status);
       END IF;
                 IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                 ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                         RAISE FND_API.G_EXC_ERROR ;
                 END IF;

        OPEN   l_lock_usg_csr;
        CLOSE  l_lock_usg_csr;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400:Update the existing OKC_TEMPLATE_USAGES record with new template id : '||p_source_doc_id);
       END IF;

	  IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine

        --Added in 10+ word integration, update values for contract_source_code and authoring_party_code
        	  UPDATE OKC_TEMPLATE_USAGES
            SET TEMPLATE_ID            = p_source_doc_id,
                DOC_NUMBERING_SCHEME   = l_tmpl_rec.tmpl_numbering_scheme,
                ARTICLE_EFFECTIVE_DATE = p_article_effective_date,  -- To Check and confirm with PMs
                CONTRACT_EXPERT_FINISH_FLAG = 'N',
                LAST_UPDATED_BY        = FND_GLOBAl.USER_ID,
                LAST_UPDATE_LOGIN      = FND_GLOBAl.LOGIN_ID,
                LAST_UPDATE_DATE       = sysdate,
                CONTRACT_SOURCE_CODE   = G_STRUCT_CONTRACT_SOURCE,
                AUTHORING_PARTY_CODE   = G_INTERNAL_PARTY_CODE,
			 CONTRACT_ADMIN_ID      = p_contract_admin_id,
			 LEGAL_CONTACT_ID       = p_legal_contact_id
             WHERE document_type = p_target_doc_type
             AND   document_id   = p_target_doc_id;

	        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          	  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'405: Deleting the responses from okc_xprt_doc_ques_response table');
	        END IF;

  	  	   --deleting responses when u change the template
		   DELETE FROM okc_xprt_doc_ques_response
		   WHERE doc_id =  p_target_doc_id
		   AND doc_type = p_target_doc_type;

	 ELSE --configurator rule engine

        --Added in 10+ word integration, update values for contract_source_code and authoring_party_code
        UPDATE OKC_TEMPLATE_USAGES
            SET TEMPLATE_ID            = p_source_doc_id,
                DOC_NUMBERING_SCHEME   = l_tmpl_rec.tmpl_numbering_scheme,
                ARTICLE_EFFECTIVE_DATE = p_article_effective_date,  -- To Check and confirm with PMs
                CONFIG_HEADER_ID       = NULL,
                CONFIG_REVISION_NUMBER = NULL,
                VALID_CONFIG_YN        = NULL,
                LAST_UPDATED_BY        = FND_GLOBAl.USER_ID,
                LAST_UPDATE_LOGIN      = FND_GLOBAl.LOGIN_ID,
                LAST_UPDATE_DATE       = sysdate,
                CONTRACT_SOURCE_CODE   = G_STRUCT_CONTRACT_SOURCE,
                AUTHORING_PARTY_CODE   = G_INTERNAL_PARTY_CODE,
			 CONTRACT_ADMIN_ID      = p_contract_admin_id,
			 LEGAL_CONTACT_ID       = p_legal_contact_id
             WHERE document_type = p_target_doc_type
             AND   document_id   = p_target_doc_id;
       END IF;

       ELSE  -- else for IF (p_retain_clauses = 'N') then
       /* If p_retain_clauses is 'Y' then we are adding multiple templates to the doc. So we need to save
        all the templates added to the doc in the new table created : okc_mlp_template_usages. Calling the
        new API created to insert to this table*/
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'410:Create template usage record in okc_mlp_template_usages');
        END IF;

        okc_clm_pkg.insert_usages_row(p_document_type           => p_target_doc_type,
                                      p_document_id             => p_target_doc_id,
                                      p_template_id             => p_source_doc_id,
                                      p_doc_numbering_scheme    => l_tmpl_rec.tmpl_numbering_scheme,
                                      p_document_number         => p_document_number,
                                      p_article_effective_date  => p_article_effective_date,
                                      p_config_header_id        => Null,
                                      p_config_revision_number  => Null,
                                      p_valid_config_yn         => Null,
                                      x_return_status           => x_return_status,
                                      x_msg_count               => x_msg_count,
                                      x_msg_data                => x_msg_data);

       END IF; ---- end for IF (p_retain_clauses = 'N')

  ELSE

      --  Added for Bug 6080483
      IF p_contract_admin_id IS NULL THEN
         -- Get the contract admin
	    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'460:Calling get_sales_group_con_admin');
	    END IF;

	    lx_new_contract_admin_id := OKC_TERMS_UTIL_PVT.get_default_contract_admin_id(p_target_doc_type, p_target_doc_id );

	    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'470:After call to OKC_TERMS_UTIL_PVT.get_sales_group_con_admin p_contract_admin_id: '||lx_new_contract_admin_id);
	         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'480:After call to OKC_TERMS_UTIL_PVT.get_sales_group_con_admin x_return_status: '||x_return_status);
	    END IF;
      ELSE
	    lx_new_contract_admin_id := p_contract_admin_id;
	 END IF;




       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500:Create template usage record ');
       END IF;

         OKC_TEMPLATE_USAGES_GRP.create_template_usages(
                                 p_api_version             => 1,
                                 p_init_msg_list           => FND_API.G_FALSE,
                                 p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                 p_commit                  => FND_API.G_FALSE,
                                 x_return_status           => x_return_status,
                                 x_msg_count               => x_msg_count,
                                 x_msg_data                => x_msg_data,
                                 p_document_type           => p_target_doc_type,
                                 p_document_id             => p_target_doc_id,
                                 p_template_id             => p_source_doc_id,
                                 p_doc_numbering_scheme    => l_tmpl_rec.tmpl_numbering_scheme,
                                 p_document_number         => p_document_number,
                                 p_article_effective_date  => p_article_effective_date,
                                 p_config_header_id        => Null,
                                 p_config_revision_number  => Null,
                                 p_valid_config_yn         => Null,
						   p_contract_admin_id       => lx_new_contract_admin_id,   --p_contract_admin_id, Bug 6080483
						   p_legal_contact_id        => p_legal_contact_id,
                                 x_document_type           => l_document_type,
                                 x_document_id             => l_document_id
                                                   );

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500:After call to OKC_TEMPLATE_USAGES_GRP.create_template_usages x_return_status: '||x_return_status);
       END IF;

         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
         END IF;

  END IF;


       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'500:Calling copy_section');
       END IF;

       copy_sections(
                      p_target_doc_type  => p_target_doc_type,
                      p_source_doc_type  => p_source_doc_type,
                      p_target_doc_id    => p_target_doc_id,
                      p_source_doc_id    => p_source_doc_id,
                      p_source_version_number=> NULL,
                      p_copy_from_archive    => 'N',
                      x_return_status    => x_return_status,
                      x_msg_data         => x_msg_data,
                      x_msg_count        => x_msg_count,
                      p_retain_clauses   => p_retain_clauses);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600:Finished copy_section. Return Status '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700:Entering copy_articles ');
       END IF;

       copy_articles(
                      p_target_doc_type        => p_target_doc_type,
                      p_source_doc_type        => p_source_doc_type,
                      p_target_doc_id          => p_target_doc_id,
                      P_source_doc_id          => p_source_doc_id,
                      p_keep_version           => p_keep_version,
                      p_article_effective_date => l_article_effective_date,
                      p_source_version_number  => NULL,
                      p_copy_from_archive      =>'N',
                      x_return_status          => x_return_status,
                      x_msg_data               => x_msg_data,
                      x_msg_count              => x_msg_count);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700:Finished copy_articles. Return Status '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;


       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800:Entering copy_article_variables.  ');
       END IF;

       copy_article_variables(
                            p_target_doc_type      => p_target_doc_type,
                            p_source_doc_type      => p_source_doc_type,
                            p_target_doc_id        => p_target_doc_id,
                            p_source_doc_id        => p_source_doc_id,
                            p_get_from_library     => 'Y',
                            x_return_status        => x_return_status,
                            x_msg_data             => x_msg_data,
                            x_msg_count            => x_msg_count);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'900:Exited copy_article_variables.Return Status  '||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
               RAISE FND_API.G_EXC_ERROR ;
       END IF;

       /*kkolukul: clm changes*/
       IF (p_retain_clauses = 'Y') then
          OKC_CLM_PKG.clm_remove_dup_scn_art( p_document_type   => p_target_doc_type,
                                  p_document_id     => p_target_doc_id,
                                  x_return_status   => x_return_status,
                                  x_msg_data        => x_msg_data,
                                  x_msg_count       => x_msg_count);
       END IF;
END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Leaving copy_tc');
END IF;

EXCEPTION

WHEN  E_Resource_Busy THEN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'000: Leaving copy_tc:E_Resource_Busy Exception');
  END IF;

 IF l_get_doc_type_name_csr%ISOPEN THEN
    CLOSE  l_get_doc_type_name_csr;
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
 END IF;

 IF l_get_allwd_tmp_usages_csr%ISOPEN THEN
    CLOSE  l_get_allwd_tmp_usages_csr;
 END IF;

 IF l_check_tmp_usage_csr%ISOPEN THEN
    CLOSE  l_check_tmp_usage_csr;
 END IF;

 IF l_lock_usg_csr%ISOPEN THEN
    CLOSE  l_lock_usg_csr;
 END IF;

 IF l_get_usage_csr%ISOPEN THEN
    CLOSE  l_get_usage_csr;
 END IF;

  ROLLBACK TO g_copy_tc_pvt;
  x_return_status := G_RET_STS_ERROR ;
  Okc_Api.Set_Message( G_FND_APP, G_UNABLE_TO_RESERVE_REC);

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving copy_tc: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 IF l_get_doc_type_name_csr%ISOPEN THEN
    CLOSE  l_get_doc_type_name_csr;
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
 END IF;

 IF l_get_allwd_tmp_usages_csr%ISOPEN THEN
    CLOSE  l_get_allwd_tmp_usages_csr;
 END IF;

 IF l_check_tmp_usage_csr%ISOPEN THEN
    CLOSE  l_check_tmp_usage_csr;
 END IF;

 IF l_lock_usg_csr%ISOPEN THEN
    CLOSE  l_lock_usg_csr;
 END IF;

 IF l_get_usage_csr%ISOPEN THEN
    CLOSE  l_get_usage_csr;
 END IF;

 ROLLBACK TO g_copy_tc_pvt;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving copy_tc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 IF l_get_doc_type_name_csr%ISOPEN THEN
    CLOSE  l_get_doc_type_name_csr;
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
 END IF;

 IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
 END IF;

 IF l_get_allwd_tmp_usages_csr%ISOPEN THEN
    CLOSE  l_get_allwd_tmp_usages_csr;
 END IF;

 IF l_check_tmp_usage_csr%ISOPEN THEN
    CLOSE  l_check_tmp_usage_csr;
 END IF;

 IF l_lock_usg_csr%ISOPEN THEN
    CLOSE  l_lock_usg_csr;
 END IF;

 IF l_get_usage_csr%ISOPEN THEN
    CLOSE  l_get_usage_csr;
 END IF;

 ROLLBACK TO g_copy_tc_pvt;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_tc because of EXCEPTION: '||sqlerrm);
END IF;

IF l_get_doc_type_name_csr%ISOPEN THEN
    CLOSE  l_get_doc_type_name_csr;
END IF;

IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
END IF;

IF l_get_tmpl_csr%ISOPEN THEN
    CLOSE  l_get_tmpl_csr;
END IF;

IF l_get_allwd_tmp_usages_csr%ISOPEN THEN
    CLOSE  l_get_allwd_tmp_usages_csr;
END IF;

IF l_check_tmp_usage_csr%ISOPEN THEN
    CLOSE  l_check_tmp_usage_csr;
END IF;

IF l_lock_usg_csr%ISOPEN THEN
    CLOSE  l_lock_usg_csr;
END IF;

ROLLBACK TO g_copy_tc_pvt;
x_return_status := G_RET_STS_UNEXP_ERROR ;
IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END copy_tc;


procedure copy_archived_doc(
                           p_api_version           IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_source_doc_type       IN   VARCHAR2,
                           p_source_doc_id         IN   NUMBER,
                           p_source_version_number IN   NUMBER,
                           p_target_doc_type       IN   VARCHAR2,
                           p_target_doc_id         IN   NUMBER,
                           p_document_number       IN   VARCHAR2,
                           p_allow_duplicates        IN  VARCHAR2,
                           x_return_status         OUT  NOCOPY VARCHAR2,
                           x_msg_data              OUT  NOCOPY VARCHAR2,
                           x_msg_count             OUT  NOCOPY NUMBER
                           ) IS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'copy_archived_doc';
l_dummy_var                VARCHAR2(1) :='?';
l_document_type            VARCHAR2(30);
l_document_id              NUMBER;
l_term_found               VARCHAR2(1):= NULL;

CURSOR l_get_usage_csr IS
SELECT * FROM OKC_TEMPLATE_USAGES_H
WHERE DOCUMENT_TYPE=p_source_doc_type
AND   DOCUMENT_ID=p_source_doc_id
AND   MAJOR_VERSION=p_source_version_number;

CURSOR l_get_target_usage IS
SELECT 'Y'  FROM OKC_TEMPLATE_USAGES
WHERE DOCUMENT_TYPE=p_target_doc_type
AND   DOCUMENT_ID=p_target_doc_id;

CURSOR l_get_variables_csr IS
SELECT KART.ID CAT_ID,
       VAR.VARIABLE_CODE,
       VAR.VARIABLE_TYPE,
       VAR.EXTERNAL_YN,
       VAR.ATTRIBUTE_VALUE_SET_ID,
       VAR.VARIABLE_VALUE,
       VAR.VARIABLE_VALUE_ID,
       VAR.OVERRIDE_GLOBAL_YN,
       VAR.MR_VARIABLE_HTML,
       VAR.MR_VARIABLE_XML,
       BUS_VAR.MRV_FLAG
FROM   OKC_K_ART_VARIABLES_H VAR,
       OKC_K_ARTICLES_B KART,
       OKC_K_ARTICLES_BH KART1,
       OKC_BUS_VARIABLES_B BUS_VAR
WHERE KART.ORIG_SYSTEM_REFERENCE_ID1=KART1.ID
  AND VAR.CAT_ID=KART1.ID
  AND KART.DOCUMENT_TYPE=p_target_doc_type
  AND KART.DOCUMENT_ID=p_target_doc_id
  AND KART1.DOCUMENT_TYPE=p_source_doc_type
  AND KART1.DOCUMENT_ID=p_source_doc_id
  AND KART1.MAJOR_VERSION = p_source_version_number
  AND KART.ORIG_SYSTEM_REFERENCE_CODE=G_COPY
  AND VAR.MAJOR_VERSION = p_source_version_number;

TYPE CatList IS TABLE OF OKC_K_ART_VARIABLES.CAT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VarList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE VarTypeList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE ExternalList IS TABLE OF OKC_K_ART_VARIABLES.EXTERNAL_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE ValSetList IS TABLE OF OKC_K_ART_VARIABLES.ATTRIBUTE_VALUE_SET_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE VarValList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_VALUE%TYPE INDEX BY BINARY_INTEGER;
TYPE VarIdList IS TABLE OF OKC_K_ART_VARIABLES.VARIABLE_VALUE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE OverrideGlobalYnList IS TABLE OF OKC_K_ART_VARIABLES.OVERRIDE_GLOBAL_YN%TYPE INDEX BY BINARY_INTEGER;
TYPE mrvariablehtml IS TABLE OF  OKC_K_ART_VARIABLES.mr_variable_html%TYPE INDEX BY BINARY_INTEGER;
TYPE mrvariablexml IS TABLE OF  OKC_K_ART_VARIABLES.mr_variable_xml%TYPE INDEX BY BINARY_INTEGER;
TYPE MRVFLAG IS TABLE OF OKC_BUS_VARIABLES_B.MRV_FLAG%TYPE INDEX BY BINARY_INTEGER;

cat_tbl           CatList;
var_tbl           VarList;
var_type_tbl      VarTypeList;
external_yn_tbl   ExternalList;
value_set_id_tbl  ValSetList;
var_value_tbl     VarValList;
var_value_id_tbl  VarIdList;
override_global_yn_tbl OverrideGlobalYnList;
mr_variable_html_tbl mrvariablehtml;
mr_variable_xml_tbl mrvariablexml;
mrv_flag_tbl MRVFLAG;

l_usage_rec l_get_usage_csr%ROWTYPE;



BEGIN

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entering OKC_TERMS_COPY_PVT.copy_archived_doc ');
END IF;

-- Standard Start of API savepoint
SAVEPOINT g_copy_archived_doc_pvt;

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

/*   Create Template Usage Record */

   OPEN  l_get_usage_csr;
   FETCH l_get_usage_csr INTO l_usage_rec;
     IF (l_get_usage_csr%NOTFOUND ) THEN
        CLOSE l_get_usage_csr;
        RAISE NO_DATA_FOUND;
     END IF;
   CLOSE l_get_usage_csr;

   OPEN l_get_target_usage;
   FETCH l_get_target_usage into l_term_found;
   CLOSE l_get_target_usage;

   IF l_usage_rec.config_header_id IS NOT NULL THEN

      /* Call Copy Config API provided by Contract Expert Team */

      NULL;

     /* After Copy Set. l_usage_rec.config_header_id  and l_usage_rec.Config_revision_number to values returned from Above API */

   END IF;

  IF ( p_allow_duplicates <>'Y' and l_term_found='Y') OR l_term_found IS NULL THEN
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200:Create usage record ');
     END IF;

     OKC_TEMPLATE_USAGES_GRP.create_template_usages(
                               p_api_version            => 1,
                               p_init_msg_list          => FND_API.G_FALSE,
                               p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
                               p_commit                 => FND_API.G_FALSE,
                               x_return_status       => x_return_status,
                               x_msg_data                    => x_msg_data,
                               x_msg_count                   => x_msg_count,
                               p_document_type          => p_target_doc_type,
                               p_document_id            => p_target_doc_id,
                               p_template_id            => l_usage_rec.template_id,
                               p_doc_numbering_scheme   => l_usage_rec.doc_numbering_scheme,
                               p_document_number        => p_document_number,
                               p_article_effective_date => sysdate,
                               p_config_header_id       => l_usage_rec.config_header_id,
                               p_config_revision_number => l_usage_rec.config_revision_number,
                               p_valid_config_yn        => l_usage_rec.valid_config_yn,
                               x_document_type          => l_document_type,
                               x_document_id            => l_document_id,
						 -- Additional fix for bug# 4116433.
						 p_approval_abstract_text => l_usage_rec.approval_abstract_text,
	                          p_contract_source_code   => l_usage_rec.contract_source_code,
	                          p_authoring_party_code   => l_usage_rec.authoring_party_code,
	                          p_source_change_allowed_flag => l_usage_rec.source_change_allowed_flag,
						 p_autogen_deviations_flag => l_usage_rec.autogen_deviations_flag
                                                );
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300:Finished usage record creation.Return Status'||x_return_status);
     END IF;

     IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
     END IF;
  END IF; -- IF ( p_allow_duplicates <>'Y' and l_term_found='Y') OR l_term_found is NULL THEN

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400:Calling copy_section');
END IF;

copy_sections(
              p_target_doc_type          => p_target_doc_type,
              p_source_doc_type          => p_source_doc_type,
              p_target_doc_id            => p_target_doc_id,
              p_source_doc_id            => p_source_doc_id,
              p_source_version_number    => p_source_version_number,
              p_copy_from_archive        => 'Y',
              x_return_status            => x_return_status,
              x_msg_data                 => x_msg_data,
              x_msg_count                => x_msg_count);

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'300:Finished copy_section. Return Status '||x_return_status);
END IF;

IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
END IF;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'400:Entering copy_articles. ');
END IF;

  copy_articles(
               p_target_doc_type        => p_target_doc_type,
               p_source_doc_type        => p_source_doc_type,
               p_target_doc_id          => p_target_doc_id,
               p_source_doc_id          => p_source_doc_id,
               p_keep_version           => 'N',
               p_article_effective_date => Null,
               p_source_version_number  => p_source_version_number,
               p_copy_from_archive      =>'Y',
               x_return_status          => x_return_status,
               x_msg_data               => x_msg_data,
               x_msg_count              => x_msg_count);

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700:Finished copy_articles. Return Status '||x_return_status);
END IF;

IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: Copying article variables');
  END IF;

-- Bulk collecting
  OPEN  l_get_variables_csr;
  FETCH l_get_variables_csr BULK COLLECT INTO cat_tbl,
                                              var_tbl,
                                              var_type_tbl,
                                              external_yn_tbl,
                                              value_set_id_tbl,
                                              var_value_tbl,
                                              var_value_id_tbl,
                                              override_global_yn_tbl,
                                              mr_variable_html_tbl,
                                              mr_variable_xml_tbl,
                                              MRV_flag_tbl;
  CLOSE l_get_variables_csr;

-- Bulk inserting
  IF cat_tbl.COUNT > 0 THEN
     FORALL i IN cat_tbl.FIRST..cat_tbl.LAST
            INSERT INTO OKC_K_ART_VARIABLES(cat_id,
                                            variable_code,
                                            variable_type,
                                            external_yn,
                                            attribute_value_set_id,
                                            variable_value,
                                            variable_value_id,
                                            override_global_yn,
                                            object_version_number,
                                            creation_date,
                                            created_by,
                                            last_update_date,
                                            last_updated_by,
                                            last_update_login,
                                            mr_variable_html,
                                            mr_variable_xml
                                            )
            VALUES (cat_tbl(i),
                    var_tbl(i),
                    var_type_tbl(i),
                    external_yn_tbl(i),
                    value_set_id_tbl(i),
                    var_value_tbl(i),
                    var_value_id_tbl(i),
                    override_global_yn_tbl(i),
                    1,
                    sysdate,
                    Fnd_Global.User_Id,
                    sysdate,
                    Fnd_Global.User_Id,
                    Fnd_Global.Login_Id,
                    mr_variable_html_tbl(i),
                    mr_variable_xml_tbl(i));

      FOR i IN  cat_tbl.FIRST..cat_tbl.LAST
      LOOP
           IF MRV_flag_tbl(i) = 'Y' THEN
            OKC_K_ART_VARIABLES_PVT.restore_mrv_uda_data_version(cat_tbl(i),p_source_version_number);
           END IF;
      END LOOP;
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;

-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Leaving copy_archived_doc');
END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN
  IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving copy_archived_doc No Terms Data in Source');
  END IF;
  null;

WHEN FND_API.G_EXC_ERROR THEN

 IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'800: Leaving copy_archived_doc: OKC_API.G_EXCEPTION_ERROR Exception');
 END IF;

 IF l_get_usage_csr%ISOPEN THEN
    CLOSE  l_get_usage_csr;
 END IF;

 IF l_get_variables_csr%ISOPEN THEN
    CLOSE  l_get_variables_csr;
 END IF;

 ROLLBACK TO g_copy_archived_doc_pvt;
 x_return_status := G_RET_STS_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

 IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving copy_archived_doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 END IF;

 IF l_get_usage_csr%ISOPEN THEN
    CLOSE  l_get_usage_csr;
 END IF;

 IF l_get_variables_csr%ISOPEN THEN
    CLOSE  l_get_variables_csr;
 END IF;

 ROLLBACK TO g_copy_archived_doc_pvt;
 x_return_status := G_RET_STS_UNEXP_ERROR ;
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

WHEN OTHERS THEN

IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1000: Leaving copy_archived_doc because of EXCEPTION: '||sqlerrm);
END IF;

 IF l_get_usage_csr%ISOPEN THEN
    CLOSE  l_get_usage_csr;
 END IF;

 IF l_get_variables_csr%ISOPEN THEN
    CLOSE  l_get_variables_csr;
 END IF;

ROLLBACK TO g_copy_archived_doc_pvt;
x_return_status := G_RET_STS_UNEXP_ERROR ;

IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
END IF;

FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END copy_archived_doc;

END OKC_TERMS_COPY_PVT;

/
