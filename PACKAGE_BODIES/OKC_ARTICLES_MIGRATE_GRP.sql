--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLES_MIGRATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLES_MIGRATE_GRP" AS
/* $Header: OKCGARTMIGB.pls 120.1 2005/12/06 14:18:26 rvohra noship $ */


  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200)   := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLES_MIGRATE_GRP';
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
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_EXC_PREREQ_SETUP_ERROR     EXCEPTION;
  G_GLOBAL_ORG_ID              NUMBER     := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
  G_CURRENT_ORG_ID             NUMBER     := -99;
  G_FETCHSIZE_LIMIT            NUMBER     := 300;
  G_program_id                 OKC_ARTICLES_ALL.PROGRAM_ID%TYPE;
  G_program_login_id           OKC_ARTICLES_ALL.PROGRAM_LOGIN_ID%TYPE;
  G_program_appl_id            OKC_ARTICLES_ALL.PROGRAM_APPLICATION_ID%TYPE;
  G_request_id                 OKC_ARTICLES_ALL.REQUEST_ID%TYPE;
  G_context                    VARCHAR2(50)    := NULL;
  G_user_id                    NUMBER;
  G_login_id                   NUMBER;


/*===================================================
 | PROCEDURE get_print_msgs_stack
 | This API will read the Fnd Message stack and print it in Concurrent Log
 | This API will be called whenever an error is reported.
 +==================================================*/

  PROCEDURE get_print_msgs_stack IS
    l_msg_data VARCHAR2(2000);
    l_count NUMBER;
  BEGIN
     FND_MSG_PUB.Count_And_Get( p_count => l_count, p_encoded=> 'F', p_data => l_msg_data );

     IF l_count > 1 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
     ELSE
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
     END IF;

     --recycle it
     FND_MSG_PUB.initialize;

  END get_print_msgs_stack;

/*===================================================
 | PROCEDURE conc_migrate_articles
 |           conc. program wrapper for migrate_articles
 |           This will internally call the main API.
 |           Parameters passed are
 |           1. p_fetchsize is fetch and/or commit size for BULK operations
 +==================================================*/
 PROCEDURE conc_migrate_articles (errbuf           OUT NOCOPY VARCHAR2,
                                 retcode          OUT NOCOPY VARCHAR2,
                                 p_fetchsize      IN NUMBER
                                 ) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'conc_migrate_articles';
  l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  x_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_fetchsize       NUMBER      := p_fetchsize;
   --
   l_proc varchar2(72) := G_PKG_NAME||'conc_migrate_articles';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

    --Initialize the return code
    retcode := 0;

    --Validate the parameters
    IF p_fetchsize is NULL THEN
       l_fetchsize := 100;

    ELSIF p_fetchsize > G_FETCHSIZE_LIMIT THEN
       x_return_status := G_RET_STS_ERROR;
       l_return_status := G_RET_STS_ERROR;

       Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKC_ART_IMP_LIM_FETCHSIZE');
       RAISE FND_API.G_EXC_ERROR ;
    END IF;

    -- Call the Article Migration API
    OKC_ARTICLES_MIGRATE_GRP.migrate_articles(
                              x_return_status  => l_return_status,
                              x_msg_count      => l_msg_count,
                              x_msg_data       => l_msg_data,
                              p_fetchsize      => l_fetchsize );


    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;
  COMMIT;

  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
      IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

      IF (l_debug = 'Y') THEN
         okc_debug.Log('3000: Leaving ',2);
         okc_debug.Reset_Indentation;
      END IF;
   WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       retcode := 2;
       errbuf  := substr(sqlerrm,1,200);
       IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
       END IF;
       FND_MSG_PUB.initialize;
       IF (l_debug = 'Y') THEN
         okc_debug.Log('4000: Leaving ',2);
         okc_debug.Reset_Indentation;
       END IF;
   WHEN OTHERS THEN
        retcode := 2;
        errbuf  := substr(sqlerrm,1,200);

        IF FND_MSG_PUB.Count_Msg > 0 Then
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
         END LOOP;
        END IF;
        FND_MSG_PUB.initialize;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('5000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
 END conc_migrate_articles;

/*===================================================
 | FUNCTION Get_Seq_Id
 | Get Sequence Number for New Article or New Version
 +==================================================*/

  FUNCTION Get_Seq_Id (
    p_object_type               IN VARCHAR2,
    x_object_id                 OUT NOCOPY NUMBER
  ) RETURN VARCHAR2 IS
    CURSOR l_art_csr IS
       SELECT OKC_ARTICLES_ALL_S1.NEXTVAL FROM DUAL;
    CURSOR l_ver_csr IS
       SELECT OKC_ARTICLE_VERSIONS_S1.NEXTVAL FROM DUAL;
 BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Log('100: Entered get_seq_id', 2);
    END IF;

    IF p_object_type = 'ART' THEN
      OPEN l_art_csr;
      FETCH l_art_csr INTO x_object_id                ;
      IF l_art_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_art_csr;
    ELSIF p_object_type = 'VER' THEN
      OPEN l_ver_csr;
      FETCH l_ver_csr INTO x_object_id                ;
      IF l_ver_csr%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE l_ver_csr;
    END IF;

    IF (l_debug = 'Y') THEN
     okc_debug.Log('200: Leaving get_seq_id', 2);
    END IF;
    RETURN G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN

      IF (l_debug = 'Y') THEN
        okc_debug.Log('300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm,2);
      END IF;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

      IF l_art_csr%ISOPEN THEN
        CLOSE l_art_csr;
      END IF;
      IF l_ver_csr%ISOPEN THEN
        CLOSE l_ver_csr;
      END IF;

      RETURN G_RET_STS_UNEXP_ERROR ;

  END Get_Seq_Id;
/*===================================================
 | PROCEDURE process_current_org_only
 | This API will be called to run the migration of articles to a particular
 | local org. This will be used for those articles that were skipped in the
 | migration run as they may not have been set up properly.
 | This assumes that the main migration is run to the global org.
 ==================================================*/
  PROCEDURE process_current_org_only(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2
  ) IS

-- Cursor to fetch current Org info

   CURSOR l_current_org_info_csr IS
     SELECT INF.ORGANIZATION_ID, UNIT.NAME
       FROM HR_ORGANIZATION_INFORMATION INF, HR_ALL_ORGANIZATION_UNITS UNIT
      WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND INF.ORGANIZATION_ID = UNIT.ORGANIZATION_ID
        AND INF.ORGANIZATION_ID = G_CURRENT_ORG_ID;

   l_org_id    HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE;
   l_org_name  HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
   l_row_notfound BOOLEAN:=FALSE;

  BEGIN

      SAVEPOINT bulkdml;
-- Create Auto Adoption rows.
    IF (l_debug = 'Y') THEN
       okc_debug.Log('100: Entered process current org only', 2);
    END IF;

    OPEN l_current_org_info_csr;
    FETCH l_current_org_info_csr INTO l_org_id, l_org_name;
    l_row_notfound := l_current_org_info_csr%NOTFOUND;
    CLOSE l_current_org_info_csr;

    IF l_row_notfound THEN
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => 'OKC_ART_INCMPLT_CUR_ORG_DEF');
        RAISE FND_API.G_EXC_ERROR ;
    END IF;


      INSERT INTO OKC_ARTICLE_ADOPTIONS
        (
         GLOBAL_ARTICLE_VERSION_ID,
         ADOPTION_TYPE,
         LOCAL_ORG_ID,
         ADOPTION_STATUS,
         LOCAL_ARTICLE_VERSION_ID,
         OBJECT_VERSION_NUMBER,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         LAST_UPDATE_DATE
         )
      SELECT
         VER.ARTICLE_VERSION_ID,
         'ADOPTED',
         G_CURRENT_ORG_ID,
         'APPROVED',
         NULL,
         1.0,
         G_User_Id,
         sysdate,
         G_User_Id,
         G_Login_Id,
         sysdate
      FROM OKC_ARTICLE_VERSIONS VER, OKC_ARTICLES_ALL ART
      WHERE ART.ORIG_SYSTEM_REFERENCE_CODE = 'OKCMIGORIG'
        AND VER.ORIG_SYSTEM_REFERENCE_CODE = ART.ORIG_SYSTEM_REFERENCE_CODE
        AND ART.ARTICLE_ID = VER.ARTICLE_ID
        AND ART.ORG_ID = G_GLOBAL_ORG_ID
        AND NOT EXISTS
             (SELECT 1 FROM OKC_ARTICLE_ADOPTIONS ADP
               WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VER.ARTICLE_VERSION_ID
                       AND ADP.LOCAL_ORG_ID = G_CURRENT_ORG_ID);

-- Create Relationships for the org. as a copy of the global relationships

      INSERT INTO OKC_ARTICLE_RELATNS_ALL(
        SOURCE_ARTICLE_ID,
        TARGET_ARTICLE_ID,
        ORG_ID,
        RELATIONSHIP_TYPE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
     SELECT
        REL.SOURCE_ARTICLE_ID,
        REL.TARGET_ARTICLE_ID,
        G_CURRENT_ORG_ID,
        'INCOMPATIBLE',
         1.0,
         G_User_Id,
         sysdate,
         G_User_Id,
         G_Login_Id,
         sysdate
   FROM OKC_ARTICLE_RELATNS_ALL REL
   WHERE ORG_ID = G_GLOBAL_ORG_ID
   AND  EXISTS
   (SELECT 1 FROM OKC_ARTICLES_ALL SRC, OKC_ARTICLES_ALL TAR
      WHERE SRC.orig_system_reference_code like 'OKCMIG%'
      AND SRC.article_id = REL.source_article_id
      AND SRC.org_id = G_GLOBAL_ORG_ID
      AND TAR.org_id = G_GLOBAL_ORG_ID
      AND TAR.article_id = REL.target_article_id
      AND TAR.orig_system_reference_code = SRC.orig_system_reference_code)
   AND NOT EXISTS
    (SELECT 1 FROM OKC_ARTICLE_RELATNS_ALL REL1
      WHERE REL1.source_article_id = REL.source_article_id AND
            REL1.target_article_id = REL.target_article_id AND
            REL1.org_id = G_CURRENT_ORG_ID);

   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                       p_msg_name     => 'OKC_ART_MIG_OUTPUT');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MSG_PUB.Get(1,p_encoded =>FND_API.G_FALSE ));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_org_name);

   x_return_status := G_RET_STS_SUCCESS;

   EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
             IF (l_debug = 'Y') THEN
                 okc_debug.Log('300: Error occurred in process_current_org: OKC_API.G_EXCEPTION_ERROR Exception', 2);
             END IF;
             get_print_msgs_stack;
             x_return_status := G_RET_STS_ERROR ;

           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.Log('500: Leaving current org processing because of EXCEPTION: '||sqlerrm, 2);
             END IF;
           Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

               x_return_status := G_RET_STS_UNEXP_ERROR;

               ROLLBACK TO SAVEPOINT bulkdml;
  END;

/*===================================================
 | PROCEDURE migrate articles
 |           The users can specify if this is to be run only for an org.
 |           The default behavior is to run for all orgs that are setup
 |           through HR Org EITs.
 |           If the user specifies that this is for the current org and that
 |           belongs to the Global Org, this will be run as a regular migration
 |           The users will need to specify a batch size or commit size.
 |
 |           Parameters passed are
 |           1. p_fetchsize is fetch and/or commit size for BULK operations
 +==================================================*/
PROCEDURE migrate_articles(
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_fetchsize                    IN NUMBER := 100
  ) IS
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                    CONSTANT VARCHAR2(30) := 'migrate_articles';
  l_row_notfound                BOOLEAN := FALSE;
  l_userenv_lang                VARCHAR2(10);

  CURSOR get_languages IS
  SELECT language_code
  FROM FND_LANGUAGES
  WHERE INSTALLED_FLAG = 'B';

  -- Migration will
  -- 1. Migrate all rows for the base language as is
  -- 2. If there is a translation (article or version), a new article
  --    and version will be created.

  CURSOR l_orig_article_csr ( cp_base_language IN VARCHAR2) IS
  SELECT  -- translated both article and versions
     decode(ARTL.LANGUAGE,cp_base_language,ARTL.NAME,
      ARTL.NAME||'('||artl.language||')') ART_ARTICLE_TITLE    ,
     decode(ARTL.LANGUAGE,cp_base_language,ARTL.ID,
      -99) ART_ARTICLE_ID,
     ARTL.ID                 ART_SYSTEM_REFERENCE_ID1,
     ARTL.LANGUAGE          ART_ARTICLE_LANGUAGE,
     ARTL.LANGUAGE          ARTV_ARTICLE_LANGUAGE
  FROM OKC_STD_ARTICLES_TL ARTL
  WHERE
       ARTL.LANGUAGE = ARTL.SOURCE_LANG
   AND NOT EXISTS
      (SELECT /*+ NO_UNNEST */
       1 FROM OKC_ARTICLES_ALL
       WHERE ORIG_SYSTEM_REFERENCE_ID1 = TO_CHAR(ARTL.ID)
         AND ORIG_SYSTEM_REFERENCE_CODE in ('OKCMIGORIG', 'OKCMIGNEW')
	    AND ARTICLE_LANGUAGE = ARTL.LANGUAGE)
  UNION ALL -- translated versions only but not articles - results in new article -- distinct is needed as there may be multiple translated versions.
  SELECT DISTINCT
     ARTL.NAME||'('||artvl.language||')' ART_ARTICLE_TITLE    ,
     -99        ART_ARTICLE_ID,
     ARTL.ID                 ART_SYSTEM_REFERENCE_ID1,
     ARTVL.LANGUAGE          ART_ARTICLE_LANGUAGE,
     ARTVL.LANGUAGE          ARTV_ARTICLE_LANGUAGE
  FROM OKC_STD_ART_VERSIONS_TL ARTVL,
     OKC_STD_ARTICLES_TL ARTL
  WHERE ARTL.LANGUAGE = ARTL.SOURCE_LANG
   AND ARTL.LANGUAGE = cp_base_language
   AND ARTVL.LANGUAGE = ARTVL.SOURCE_LANG
   AND ARTVL.LANGUAGE <> cp_base_language
   AND ARTVL.SAE_ID = ARTL.ID
   AND NOT EXISTS
      (SELECT /*+ NO_UNNEST */
	  1 FROM OKC_ARTICLES_ALL
       WHERE ORIG_SYSTEM_REFERENCE_ID1 = TO_CHAR(ARTL.ID)
         AND ORIG_SYSTEM_REFERENCE_CODE in ('OKCMIGORIG', 'OKCMIGNEW')
	    AND ARTICLE_LANGUAGE = ARTVL.LANGUAGE)
   AND NOT EXISTS
      (SELECT /*+ NO_UNNEST */
	  1 FROM OKC_STD_ARTICLES_TL ARTL1
        WHERE ARTL1.LANGUAGE = ARTVL.LANGUAGE
        AND ARTL1.SOURCE_LANG = ARTVL.SOURCE_LANG
        AND ARTVL.SAE_ID = ARTL1.ID);

-- Version Details

    CURSOR l_orig_ver_csr ( cp_language IN VARCHAR2,
                            cp_article_id  IN NUMBER) IS
      SELECT
           ARTV.SAV_RELEASE,
           ARTV.DATE_ACTIVE,
           ARTVL.TEXT
      FROM OKC_STD_ART_VERSIONS_B ARTV,
           OKC_STD_ART_VERSIONS_TL ARTVL
       WHERE ARTV.SAE_ID  = cp_article_id
         AND ARTVL.LANGUAGE = ARTVL.SOURCE_LANG
         AND ARTVL.LANGUAGE = cp_language
         AND ARTVL.SAE_ID = ARTV.SAE_ID
         AND ARTVL.SAV_RELEASE = ARTV.SAV_RELEASE
       ORDER BY DATE_ACTIVE;


-- Cursor to fetch ALL Orgs that are set up for Articles

   CURSOR l_org_info_csr IS
     SELECT INF.ORGANIZATION_ID, UNIT.NAME
       FROM HR_ORGANIZATION_INFORMATION INF, HR_ALL_ORGANIZATION_UNITS UNIT
      WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND INF.ORGANIZATION_ID = UNIT.ORGANIZATION_ID;

-- Cursor to check setup:  ALL Orgs used in contracts must be set up for Articles
/*
   CURSOR l_missing_org_csr IS
     SELECT NAME FROM HR_ALL_ORGANIZATION_UNITS ORG
     WHERE EXISTS
     (
     SELECT 1 FROM OKC_K_HEADERS_B K
     WHERE NOT EXISTS
    (
     SELECT
	  '1'
       FROM HR_ORGANIZATION_INFORMATION ORGINF
       WHERE ORGINF.ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND ORGINF.ORGANIZATION_ID = K.AUTHORING_ORG_ID
     )
    AND K.AUTHORING_ORG_ID = ORG.ORGANIZATION_ID);
*/
   CURSOR l_missing_org_csr IS
     SELECT NAME FROM HR_ALL_ORGANIZATION_UNITS ORG
     WHERE NOT EXISTS
      (
       SELECT /*+ NO_UNNEST */
         '1'
         FROM HR_ORGANIZATION_INFORMATION ORGINF
         WHERE ORGINF.ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
          AND ORGINF.ORGANIZATION_ID = ORG.ORGANIZATION_ID
       )
     AND ORG.ORGANIZATION_ID IN
     (SELECT /*+ PARALLEL(K) */
	 AUTHORING_ORG_ID
	 FROM OKC_K_HEADERS_B K);

-- Cursor to fetch ALL org used in 11.5.9 okc
   CURSOR l_k_org_csr IS
     SELECT DISTINCT AUTHORING_ORG_ID
     FROM OKC_K_HEADERS_B;

-- Cursor to check if same article title already exists in global org for 11.5.10
    CURSOR l_unq_csr(p_article_title IN VARCHAR2) is
       SELECT '1' FROM OKC_ARTICLES_ALL
       WHERE article_title = p_article_title
        AND  org_id = G_GLOBAL_ORG_ID
        AND  standard_yn = 'Y'
        AND rownum < 2;

-- All Tables and Datatypes for bulk associations

    TYPE list_org_name IS TABLE OF HR_ORGANIZATION_UNITS.NAME%TYPE INDEX BY BINARY_INTEGER;
    TYPE list_art_version_number IS TABLE OF OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER;
    TYPE list_org_id IS TABLE OF HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE list_system_reference_code IS TABLE OF OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE list_article_title IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_article_id IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_article_number IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_article_version_id IS TABLE OF OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_article_language IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_LANGUAGE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_art_system_reference_id1 IS TABLE OF OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_ID1%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_start_date IS TABLE OF OKC_ARTICLE_VERSIONS.START_DATE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_article_text IS TABLE OF OKC_ARTICLE_VERSIONS.ARTICLE_TEXT%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_sav_release IS TABLE OF OKC_ARTICLE_VERSIONS.SAV_RELEASE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE list_process_status IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER ;
    TYPE list_display_name IS TABLE of OKC_ARTICLE_VERSIONS.DISPLAY_NAME%TYPE INDEX BY BINARY_INTEGER ;

  l_org_id_tbl                   list_org_id;
  l_org_name_tbl                 list_org_name;
  article_title_tbl              list_article_title ;
  article_number_tbl             list_article_number ;
  article_id_tbl                 list_article_id ;
  article_language_tbl           list_article_language ;
  ver_language_tbl               list_article_language ;
  system_reference_code_tbl      list_system_reference_code ;
  art_system_reference_id1_tbl   list_art_system_reference_id1 ;
  article_version_id_tbl         list_article_version_id ;
  start_date_tbl                 list_start_date ;
  article_text_tbl               list_article_text ;
  artv_sav_release_tbl           list_sav_release ;
  t_article_id_tbl               list_article_id ;
  t_article_version_id_tbl       list_article_version_id ;
  t_start_date_tbl               list_start_date ;
  t_end_date_tbl                 list_start_date ;
  t_article_text_tbl             list_article_text ;
  t_artv_sav_release_tbl         list_sav_release ;
  t_ver_language_tbl             list_article_language ;
  t_art_language_tbl             list_article_language ;
  t_system_reference_code_tbl    list_system_reference_code ;
  t_ver_system_reference_id1_tbl list_art_system_reference_id1 ;
  t_art_version_number_tbl       list_art_version_number;
  art_process_status_tbl         list_process_status ;
  ver_process_status_tbl         list_process_status ;
  display_name_tbl               list_display_name ;
  t_display_name_tbl             list_display_name ;


   I NUMBER := 0;
   j NUMBER := 0;
   k NUMBER := 0;
   l_article_number         OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE;
   l_return_status          VARCHAR2(1);
   l_doc_sequence_type      CHAR(1);
   l_language               VARCHAR2(12);
   l_migrated               BOOLEAN :=FALSE;
   l_dummy_var              VARCHAR2(1) := '?';

------------------------------------------------------------------------
--  PROCEDURE migrate_articles body starts
-------------------------------------------------------------------------

BEGIN
  l_debug := 'Y';

  IF (l_debug = 'Y') THEN
  okc_debug.Log('100: Entered article_migrate', 2);
  END IF;


  ------------------------------------------------------------------------
  --  Variable Initialization
  -------------------------------------------------------------------------
  -- Standard Start of API savepoint
  FND_MSG_PUB.initialize;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := G_RET_STS_SUCCESS;
  --  Cache user_id and login_id
  G_user_id  := Fnd_Global.user_id;
  G_login_id := Fnd_Global.login_id;
  l_userenv_lang := USERENV('LANG');

  -- if global org is not defined then error out
  IF G_GLOBAL_ORG_ID = '-99' Then
  Okc_Api.Set_Message(p_app_name    => G_APP_NAME,
  p_msg_name     => 'OKC_ART_NO_GLOBAL_ORG');
  RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Derive and cache the base language
  OPEN get_languages;
  FETCH get_languages INTO l_language;
  l_row_notfound := get_languages%NOTFOUND;
  CLOSE get_languages;
  IF l_row_notfound THEN
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,p_msg_name     => 'OKC_ART_NO_BASE_LANG');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  -- Check for orgs in contracts that are not defined for Articles in HR_ORG

  OPEN l_missing_org_csr;
  FETCH l_missing_org_csr BULK COLLECT INTO l_org_name_tbl;
  CLOSE l_missing_org_csr;
  IF l_org_name_tbl.COUNT > 0 THEN
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
    p_msg_name     => 'OKC_ART_INCMPLT_ORG_DEF');
    get_print_msgs_stack;
    FOR i in l_org_name_tbl.FIRST..l_org_name_tbl.LAST LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG,l_org_name_tbl(i));
      --       dbms_output.put_line(l_org_name_tbl(i)||'ORG');
    END LOOP;
  l_org_name_tbl.DELETE;
  RAISE FND_API.G_EXC_ERROR ;
  END IF;

  l_org_name_tbl.DELETE;

  -- Fetch all orgs that are set up for articles
  OPEN l_org_info_csr;
  FETCH l_org_info_csr BULK COLLECT INTO l_org_id_tbl, l_org_name_tbl;
  CLOSE l_org_info_csr;

  IF l_org_id_tbl.COUNT <= 0 THEN
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
    p_msg_name     => 'OKC_ART_INCMPLT_ORG_DEF');
    get_print_msgs_stack;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  -- Update Article Text with ' ' to be migrated to OKC_ARTICLE_VERSIONS
  UPDATE OKC_STD_ART_VERSIONS_TL
  SET    TEXT = ' '
  WHERE  TEXT IS NULL;


  -- Cache all CP parameters
  IF FND_GLOBAL.CONC_PROGRAM_ID = -1 THEN
    G_PROGRAM_ID := NULL;
    G_PROGRAM_LOGIN_ID := NULL;
  ELSE
    G_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    G_PROGRAM_LOGIN_ID := FND_GLOBAL.CONC_LOGIN_ID;
  END IF;
  IF FND_GLOBAL.PROG_APPL_ID = -1 THEN
    G_PROGRAM_APPL_ID := NULL;
  ELSE
    G_PROGRAM_APPL_ID := FND_GLOBAL.PROG_APPL_ID;
  END IF;
  IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
    G_REQUEST_ID := NULL;
  ELSE
    G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
  END IF;

  i := 0;
  -- Migrate all folders from article sets
  BEGIN
    FORALL  i in l_org_id_tbl.FIRST .. l_org_id_tbl.LAST
      INSERT INTO OKC_FOLDERS_ALL_B (
      FOLDER_ID,
      OBJECT_VERSION_NUMBER,
      ORG_ID,
      SAT_CODE,
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
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      )
      SELECT
      OKC_FOLDERS_ALL_B_S1.NEXTVAL,
      1,
      l_org_id_tbl(i),
      LOOKUP_CODE,
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
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      FROM FND_LOOKUP_VALUES LKU
      WHERE LOOKUP_TYPE = 'OKC_ARTICLE_SET'
      AND  LANGUAGE = USERENV('LANG')
      AND NOT EXISTS
      (SELECT /*+ NO_UNNEST */
	  1 FROM OKC_FOLDERS_ALL_B FLD
      WHERE FLD.SAT_CODE = LKU.LOOKUP_CODE
      AND ORG_ID = l_org_id_tbl(i));
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.Log('500: Leaving Articles_Migrate because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
      p_msg_name     => G_UNEXPECTED_ERROR,
      p_token1       => G_SQLCODE_TOKEN,
      p_token1_value => sqlcode,
      p_token2       => G_SQLERRM_TOKEN,
      p_token2_value => sqlerrm);

      l_return_status := G_RET_STS_ERROR;
      x_return_status := G_RET_STS_ERROR ;
      RAISE FND_API.G_EXC_ERROR ;
  END;

  BEGIN
    INSERT INTO OKC_FOLDERS_ALL_TL (
    FOLDER_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    FOLDER_ID,
    LANGUAGE,
    SOURCE_LANG
    ) SELECT
    LKU.MEANING,
    LKU.DESCRIPTION,
    LKU.CREATED_BY,
    LKU.CREATION_DATE,
    LKU.LAST_UPDATE_DATE,
    LKU.LAST_UPDATED_BY,
    LKU.LAST_UPDATE_LOGIN,
    FLD.FOLDER_ID,
    LKU.LANGUAGE,
    LKU.LANGUAGE
    FROM FND_LOOKUP_VALUES LKU , OKC_FOLDERS_ALL_B FLD
    WHERE LOOKUP_CODE = SAT_CODE
    AND  LOOKUP_TYPE = 'OKC_ARTICLE_SET'
    AND NOT EXISTS
    (SELECT /*+ NO_UNNEST */
     1 FROM OKC_FOLDERS_ALL_TL FLDT
    WHERE FLDT.FOLDER_ID = FLD.FOLDER_ID
    AND FLDT.LANGUAGE = LKU.LANGUAGE) ;
  EXCEPTION
    WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
      okc_debug.Log('500: Leaving Articles_Migrate because of EXCEPTION: '||sqlerrm, 2);
    END IF;
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
    p_msg_name     => G_UNEXPECTED_ERROR,
    p_token1       => G_SQLCODE_TOKEN,
    p_token1_value => sqlcode,
    p_token2       => G_SQLERRM_TOKEN,
    p_token2_value => sqlerrm);
    l_return_status := G_RET_STS_ERROR;
    x_return_status := G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END;
------------------------------------------------------------------------
-- Bulk fetch all articles rows based on the fetchsize passed by the user
-- the outermost loop of this procedure
-------------------------------------------------------------------------
  OPEN l_orig_article_csr(l_language);
  LOOP
  BEGIN
    k := 0;
    j := 0;
    FETCH l_orig_article_csr BULK COLLECT INTO
    article_title_tbl ,
    article_id_tbl  ,
    art_system_reference_id1_tbl,
    article_language_tbl ,
    ver_language_tbl
    LIMIT p_fetchsize;

    EXIT WHEN article_id_tbl.COUNT=0;
    -- for each batch of articles

    FOR i in article_id_tbl.FIRST ..article_id_tbl.LAST LOOP
      BEGIN
        G_CONTEXT := 'ART';
        -- Initialization for each iteration
        l_row_notfound       := FALSE;
        l_return_status      := G_RET_STS_SUCCESS;
        x_return_status      := G_RET_STS_SUCCESS;
        ver_process_status_tbl(i) := 'S';
        art_process_status_tbl(i) := 'S';
        system_reference_code_tbl(i) := 'OKCMIGORIG';
        display_name_tbl(i) := '';
        --   generate article number

        OKC_ARTICLES_GRP.GET_ARTICLE_SEQ_NUMBER
        (p_article_number => NULL,
        p_seq_type_info_only  => 'N',
        p_org_id => G_GLOBAL_ORG_ID,
        x_article_number => l_article_number,
        x_doc_sequence_type => l_doc_sequence_type,
        x_return_status   => x_return_status
        ) ;

        IF x_return_status = G_RET_STS_SUCCESS Then
          IF l_article_number is NULL Then
            art_process_status_tbl(i) :='U';
            Okc_Api.Set_Message(p_app_name => G_APP_NAME,
            p_msg_name     => 'OKC_ART_MIG_NO_AUTO_NUMBER');
            RAISE G_EXC_PREREQ_SETUP_ERROR;
          ELSE
            article_number_tbl(i) := l_article_number;
          END IF;
        ELSIF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          article_number_tbl(i) := NULL;
          l_return_status := x_return_status;
          art_process_status_tbl(i) := 'U';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
          article_number_tbl(i) := NULL;
          art_process_status_tbl(i) := 'U';
          l_return_status := x_return_status;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Check if the article title of this article already exists in 11.5.10
        l_row_notfound := FALSE;
        OPEN l_unq_csr(article_title_tbl(i));
        FETCH l_unq_csr INTO l_dummy_var;
        l_row_notfound := l_unq_csr%NOTFOUND;
        CLOSE l_unq_csr;

        IF not l_row_notfound THEN
          article_title_tbl(i) := article_title_tbl(i)||' '||l_article_number;
          display_name_tbl(i)  := article_title_tbl(i);
        END IF;

        -- Fetch all versions for the article

        OPEN l_orig_ver_csr(ver_language_tbl(i), art_system_reference_id1_tbl(i));
        FETCH l_orig_ver_csr BULK COLLECT INTO
        artv_sav_release_tbl,
        start_date_tbl  ,
        article_text_tbl;
        CLOSE l_orig_ver_csr;

        IF start_date_tbl.COUNT <= 0 THEN
          -- Article may have been translated and the version is not. Try the base language
          -- This is not a frequent case.

          OPEN l_orig_ver_csr(l_language, art_system_reference_id1_tbl(i));
          FETCH l_orig_ver_csr BULK COLLECT INTO
          artv_sav_release_tbl,
          start_date_tbl  ,
          article_text_tbl;
          CLOSE l_orig_ver_csr;
          IF start_date_tbl.COUNT <= 0 THEN
            art_process_status_tbl(i) := 'E';
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKC_MIG_ERR_NO_VER',
            p_token1       => 'ARTICLE_TITLE',
            p_token1_value => article_title_tbl(i)
            );
            RAISE  FND_API.G_EXC_ERROR ;
          ELSE
            ver_language_tbl(i) := l_language;
            article_id_tbl(i) := -99; -- new article ..ids will be generated later
          END IF;
        END IF;

        -- Generate article id only for new articles
        IF article_id_tbl(i) = -99 Then
          system_reference_code_tbl(i) := 'OKCMIGNEW';
        END IF;
        -- Generate article id for all articles as OA currently has problems handling
        -- the old 39 digit Ids.

        x_return_status := Get_Seq_Id (p_object_type => 'ART',
        x_object_id  =>  article_id_tbl(i));

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          art_process_status_tbl(i) := 'U';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          l_return_status := x_return_status;
          art_process_status_tbl(i) := 'E';
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
        -- Message article versions data

        FOR j in start_date_tbl.FIRST .. start_date_tbl.LAST LOOP
          BEGIN
            G_CONTEXT := 'AVN';
            ver_process_status_tbl(j) := 'S';

            /**
            -- We will update article text with ' ' if they are null upfront
            -- Basic validation: article text being NULL
            IF article_text_tbl(j) IS NULL Then
            art_process_status_tbl(i) := 'E';
            ver_process_status_tbl(j) := 'E';
            Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKC_MIG_ERR_NO_TEXT',
            p_token1       => 'ARTICLE_NAME',
            p_token1_value => article_title_tbl(i),
            p_token2       => 'ARTICLE_VERSION',
            p_token2_value => artv_sav_release_tbl(j)
            );
            RAISE FND_API.G_EXC_ERROR ;
            END IF;
            **/

            -- Generate article version id only for all article versions

            x_return_status := Get_Seq_Id (p_object_type => 'VER',
            x_object_id  =>  article_version_id_tbl(j));
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
              ver_process_status_tbl(j) := 'U';
              art_process_status_tbl(i) := 'U';
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
              l_return_status := x_return_status;
              ver_process_status_tbl(j) := 'E';
              art_process_status_tbl(i) := 'E';
              RAISE FND_API.G_EXC_ERROR ;
            END IF;


          EXCEPTION
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              IF (l_debug = 'Y') THEN
                okc_debug.Log('400: Leaving version processing loop due to OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
              END IF;
              --
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => sqlcode,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => sqlerrm);

              IF l_orig_article_csr%ISOPEN THEN
                CLOSE l_orig_article_csr;
              END IF;
              IF l_orig_ver_csr%ISOPEN THEN
                CLOSE l_orig_ver_csr;
	         END IF;
              IF l_unq_csr%ISOPEN THEN
                CLOSE l_unq_csr;
	         END IF;
              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;
              exit; -- exit this  loop

            WHEN FND_API.G_EXC_ERROR THEN
              IF (l_debug = 'Y') THEN
                okc_debug.Log('400: Error in this version: OKC_API.G_EXC_ERROR Exception', 2);
              END IF;
              --

              l_return_status := G_RET_STS_ERROR ;
              x_return_status := G_RET_STS_ERROR ;

            WHEN OTHERS THEN
              IF (l_debug = 'Y') THEN
                okc_debug.Log('500: Leaving version processing loop due to EXCEPTION: '||sqlerrm, 2);
              END IF;
              Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
              p_msg_name     => G_UNEXPECTED_ERROR,
              p_token1       => G_SQLCODE_TOKEN,
              p_token1_value => sqlcode,
              p_token2       => G_SQLERRM_TOKEN,
              p_token2_value => sqlerrm);


              IF l_orig_article_csr%ISOPEN THEN
                CLOSE l_orig_article_csr;
              END IF;
              IF l_orig_ver_csr%ISOPEN THEN
                CLOSE l_orig_ver_csr;
	         END IF;
              IF l_unq_csr%ISOPEN THEN
                CLOSE l_unq_csr;
	         END IF;

              l_return_status := G_RET_STS_UNEXP_ERROR ;
              x_return_status := G_RET_STS_UNEXP_ERROR ;
              exit;
          END;

        END LOOP; -- end of FOR i in start_date_tbl.FIRST ..
        -------------------------------------------------------------------------
        -- initialize l_return_status to track status of DML execution
        IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          art_process_status_tbl(i) := 'U';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          exit;
        END IF;

        -- For successful rows push to a larger collection for eventual bulk insert of versions

        if art_process_status_tbl(i) = 'S' Then
          l_migrated := TRUE;

          FOR j in start_date_tbl.FIRST..start_date_tbl.LAST LOOP
            t_article_id_tbl(k) := article_id_tbl(i);
            t_article_text_tbl(k) := article_text_tbl(j);
            t_art_version_number_tbl(k) := j;
            t_article_version_id_tbl(k) := article_version_id_tbl(j);
            t_start_date_tbl(k) := start_date_tbl(j);
            t_end_date_tbl(k) := NULL;
            if j > 1 Then
              t_end_date_tbl(k-1) := t_start_date_tbl(k)-1/86400;
            end if;
            t_art_language_tbl(k) := article_language_tbl(i);
            t_ver_language_tbl(k) := ver_language_tbl(i);
            t_system_reference_code_tbl(k) := system_reference_code_tbl(i);
            t_ver_system_reference_id1_tbl(k) := art_system_reference_id1_tbl(i);
            t_artv_sav_release_tbl(k) := artv_sav_release_tbl(j);
            t_display_name_tbl(k) := display_name_tbl(i);
            k := k+1;
          END LOOP;
        end if;

        article_version_id_tbl.DELETE;
        article_text_tbl.DELETE;
        start_date_tbl.DELETE;
        artv_sav_release_tbl.DELETE;
      EXCEPTION
        WHEN G_EXC_PREREQ_SETUP_ERROR THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('400: Leaving loop for individual article processing loop : Prereq is not properly set', 2);
          END IF;
          --

          IF l_orig_article_csr%ISOPEN THEN
            CLOSE l_orig_article_csr;
          END IF;
          l_return_status := G_RET_STS_ERROR ;
          x_return_status := G_RET_STS_ERROR ;
          RAISE G_EXC_PREREQ_SETUP_ERROR;
          exit;-- exit this loop

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('400: Leaving loop for individual article processing loop due to OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
          END IF;
          --
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);


          IF l_orig_article_csr%ISOPEN THEN
            CLOSE l_orig_article_csr;
          END IF;
          IF l_orig_ver_csr%ISOPEN THEN
            CLOSE l_orig_ver_csr;
	     END IF;
          IF l_unq_csr%ISOPEN THEN
            CLOSE l_unq_csr;
	     END IF;
          l_return_status := G_RET_STS_UNEXP_ERROR ;
          x_return_status := G_RET_STS_UNEXP_ERROR ;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          exit; -- exit this loop

        WHEN FND_API.G_EXC_ERROR THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('400: Leaving Articles_Migration: OKC_API.G_EXC_ERROR Exception', 2);
          END IF;
          --
          l_return_status := G_RET_STS_ERROR ;
          x_return_status := G_RET_STS_ERROR ;
          --             exit; -- exit this loop

        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving loop for individual article processing loop due to EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);


          IF l_orig_article_csr%ISOPEN THEN
            CLOSE l_orig_article_csr;
          END IF;
          IF l_orig_ver_csr%ISOPEN THEN
            CLOSE l_orig_ver_csr;
	     END IF;
          IF l_unq_csr%ISOPEN THEN
            CLOSE l_unq_csr;
	     END IF;

          l_return_status := G_RET_STS_UNEXP_ERROR ;
          x_return_status := G_RET_STS_UNEXP_ERROR ;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
          exit; -- exit this loop
      END;
    END LOOP; -- end of FOR i in article_id_tbl.FIRST ..line 880 approx

    l_return_status := G_RET_STS_SUCCESS;
    get_print_msgs_stack;

    IF t_article_version_id_tbl.COUNT > 0 THEN

      SAVEPOINT bulkdml;
      -- Bulk insert New Articles

      BEGIN
        i := 0;
        G_context := 'ART';
        FORALL  i in article_id_tbl.FIRST ..article_id_tbl.LAST
          INSERT INTO OKC_ARTICLES_ALL(
          ARTICLE_ID,
          ARTICLE_TITLE,
          ORG_ID,
          ARTICLE_NUMBER,
          STANDARD_YN,
          ARTICLE_INTENT,
          ARTICLE_LANGUAGE,
          ARTICLE_TYPE,
          ORIG_SYSTEM_REFERENCE_CODE,
          ORIG_SYSTEM_REFERENCE_ID1,
          ORIG_SYSTEM_REFERENCE_ID2,
          CZ_TRANSFER_STATUS_FLAG,
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
          PROGRAM_ID,
          PROGRAM_LOGIN_ID,
          PROGRAM_APPLICATION_ID,
          REQUEST_ID,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
          SELECT
          article_id_tbl(i),
          article_title_tbl(i),
          G_GLOBAL_ORG_ID,
          article_number_tbl(i),
          'Y',                             -- Standard YN
          'S',                             -- Article Intent
          article_language_tbl(i),
          sbt_code,
          system_reference_code_tbl(i),     -- Orig System Reference Code
          id,                               -- Orig System Reference ID1
          NULL,                            -- Orig System Reference ID2
          'N',                             -- CZ Transfer Status Flag
          attribute_category,
          substrb(attribute1,1,150),
          substrb(attribute2,1,150),
          substrb(attribute3,1,150),
          substrb(attribute4,1,150),
          substrb(attribute5,1,150),
          substrb(attribute6,1,150),
          substrb(attribute7,1,150),
          substrb(attribute8,1,150),
          substrb(attribute9,1,150),
          substrb(attribute10,1,150),
          substrb(attribute11,1,150),
          substrb(attribute12,1,150),
          substrb(attribute13,1,150),
          substrb(attribute14,1,150),
          substrb(attribute15,1,150),
          G_PROGRAM_ID,
          G_PROGRAM_LOGIN_ID,
          G_PROGRAM_APPL_ID,
          G_REQUEST_ID,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,                       -- Created By
          CREATION_DATE,                         -- Creation Date
          LAST_UPDATED_BY,                       -- Last Updated By
          LAST_UPDATE_LOGIN,                      -- Last Update Login
          sysdate                          -- Last Update Date
          FROM OKC_STD_ARTICLES_B
          WHERE art_process_status_tbl(i) = 'S'
          AND id = art_system_reference_id1_tbl(i);
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Articles_Migrate because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      --
      --  End of Insert into OKC_ARTICLES_ALL
      --
      --


      BEGIN
        G_context := 'AVN';
        i := 0;

        -- Bulk insert New Article Versions

        FORALL  i in t_article_version_id_tbl.FIRST ..t_article_version_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_VERSIONS(
          ARTICLE_VERSION_ID,
          ARTICLE_ID,
          ARTICLE_VERSION_NUMBER,
          ARTICLE_TEXT,
          PROVISION_YN,
          INSERT_BY_REFERENCE,
          LOCK_TEXT,
          GLOBAL_YN,
          ARTICLE_LANGUAGE,
          ARTICLE_STATUS,
          SAV_RELEASE,
          START_DATE,
          END_DATE,
          STD_ARTICLE_VERSION_ID,
          DISPLAY_NAME,
          TRANSLATED_YN,
          ARTICLE_DESCRIPTION,
          DATE_APPROVED,
          DEFAULT_SECTION,
          REFERENCE_SOURCE,
          REFERENCE_TEXT,
          ORIG_SYSTEM_REFERENCE_CODE,
          ORIG_SYSTEM_REFERENCE_ID1,
          ORIG_SYSTEM_REFERENCE_ID2,
          ADDITIONAL_INSTRUCTIONS,
          VARIATION_DESCRIPTION,
          ADOPTION_TYPE,
          PROGRAM_ID,
          PROGRAM_LOGIN_ID,
          PROGRAM_APPLICATION_ID,
          REQUEST_ID,
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
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
          SELECT
          t_article_version_id_tbl(i),
          t_article_id_tbl(i),
          t_art_version_number_tbl(i),  -- Article Version Number
          text,       -- Article Text
          'N',                      -- Provision Yn
          'N',                      -- Insert by Reference
          'N',                      -- Lock Text
          'Y',                      -- Global Yn
          t_art_language_tbl(i),
          'APPROVED',               -- Article Status
          b.sav_release,  -- Sav Release
          t_start_date_tbl(i),        -- Start Date
          t_end_date_tbl(i),        -- End Date
          NULL,                     -- Std Article Version Id
          t_display_name_tbl(i),       -- Display Name
          NULL,                     -- Translated Yn
          t.short_description,
          sysdate,                  -- Date Approved
          NULL,                     -- Default Section
          'OKCMIGRATE',             -- Reference Source
          NULL,                     -- Reference Text
          t_system_reference_code_tbl(i),     -- Orig System Reference Code
          t_ver_system_reference_id1_tbl(i), -- System Reference ID1
          NULL,                     -- Orig System Reference Id2
          NULL,                     -- Additional Instructions
          NULL,                     -- Variation Description
          NULL,                     -- Adoption Type
          G_PROGRAM_ID,
          G_PROGRAM_LOGIN_ID,
          G_PROGRAM_APPL_ID,
          G_REQUEST_ID,
          b.attribute_category,
          substrb(b.attribute1,1,150),
          substrb(b.attribute2,1,150),
          substrb(b.attribute3,1,150),
          substrb(b.attribute4,1,150),
          substrb(b.attribute5,1,150),
          substrb(b.attribute6,1,150),
          substrb(b.attribute7,1,150),
          substrb(b.attribute8,1,150),
          substrb(b.attribute9,1,150),
          substrb(b.attribute10,1,150),
          substrb(b.attribute11,1,150),
          substrb(b.attribute12,1,150),
          substrb(b.attribute13,1,150),
          substrb(b.attribute14,1,150),
          substrb(b.attribute15,1,150),         b.object_version_number,            -- Object Version Number
          b.created_by,               -- Created By
          b.creation_date,                 -- Creation Date
          b.last_updated_by,               -- Last Updated By
          b.last_update_login,              -- Last Update Login
          SYSDATE                           -- Last Update Date
          FROM OKC_STD_ART_VERSIONS_B B,
          OKC_STD_ART_VERSIONS_TL T
          WHERE
          B.SAE_ID = t_ver_system_reference_id1_tbl(i)
          AND B.SAV_RELEASE = t_artv_sav_release_tbl(i)
          AND T.LANGUAGE =  t_ver_language_tbl(i)
          AND T.SAE_ID = B.SAE_ID
          AND T.SAV_RELEASE = B.SAV_RELEASE
          AND EXISTS
          (SELECT 1 FROM OKC_ARTICLES_ALL ART WHERE
          ART.ARTICLE_ID = t_article_id_tbl(i)  AND
          ART.ORIG_SYSTEM_REFERENCE_ID1 = TO_CHAR(B.SAE_ID) AND
          ART.ORIG_SYSTEM_REFERENCE_ID1 = t_ver_system_reference_id1_tbl(i));

      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Versions because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      --
      -- End of Insert into OKC_ARTICLE_VERSIONS
      --
      --
      -- Bulk insert Article relationships
      BEGIN
        G_context := 'ARL';
        FORALL  i in article_id_tbl.FIRST ..article_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL(
          SOURCE_ARTICLE_ID,
          TARGET_ARTICLE_ID,
          ORG_ID,
          RELATIONSHIP_TYPE,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
		SELECT /*+ ORDERED USE_NL(INC,TAR) */
          SRC.ARTICLE_ID source_article_id,
          TAR.ARTICLE_ID target_article_id,
                                        ORG.ORGANIZATION_ID,
          'INCOMPATIBLE',
          INC.object_version_number,
          INC.created_by,
          INC.creation_date,
          INC.last_updated_by,
          INC.last_update_login,
          INC.last_update_date
          FROM  OKC_ARTICLES_ALL SRC, OKC_STD_ART_INCMPTS INC, OKC_ARTICLES_ALL TAR,
          HR_ORGANIZATION_INFORMATION ORG
          WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
          AND SRC.orig_system_reference_id1 = INC.SAE_ID
          AND SRC.orig_system_reference_code in ('OKCMIGNEW' , 'OKCMIGORIG')
          AND TAR.orig_system_reference_id1 = TO_CHAR(INC.SAE_ID_FOR)
          AND TAR.orig_system_reference_code = SRC.orig_system_reference_code
          AND SRC.article_id = article_id_tbl(i)
          AND art_process_status_tbl(i) = 'S'
          AND NOT EXISTS
          (SELECT /*+ NO_UNNEST */
		 1 FROM OKC_ARTICLE_RELATNS_ALL REL1
          WHERE rel1.source_article_id = src.article_id and
          rel1.target_article_id = tar.article_id and
          rel1.org_id = org.organization_id);

      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Relations because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      BEGIN
        G_context := 'ARL2';
        FORALL  i in article_id_tbl.FIRST ..article_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL(
          SOURCE_ARTICLE_ID,
          TARGET_ARTICLE_ID,
          ORG_ID,
          RELATIONSHIP_TYPE,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
		SELECT /*+ ORDERED USE_NL(INC,SRC) */
          SRC.ARTICLE_ID source_article_id,
          TAR.ARTICLE_ID target_article_id,
                                        ORG.ORGANIZATION_ID,
          'INCOMPATIBLE',
          INC.object_version_number,
          INC.created_by,
          INC.creation_date,
          INC.last_updated_by,
          INC.last_update_login,
          INC.last_update_date
          FROM OKC_ARTICLES_ALL TAR, OKC_STD_ART_INCMPTS INC, OKC_ARTICLES_ALL SRC,
          HR_ORGANIZATION_INFORMATION ORG
          WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
          AND SRC.orig_system_reference_id1 = TO_CHAR(INC.SAE_ID)
          AND SRC.orig_system_reference_code in ('OKCMIGNEW' , 'OKCMIGORIG')
          AND TAR.orig_system_reference_id1 = INC.SAE_ID_FOR
          AND TAR.orig_system_reference_code = SRC.orig_system_reference_code
          AND TAR.article_id = article_id_tbl(i)
          AND art_process_status_tbl(i) = 'S'
          AND NOT EXISTS
          (SELECT /*+ NO_UNNEST */
		 1 FROM OKC_ARTICLE_RELATNS_ALL REL1
          WHERE rel1.source_article_id = src.article_id and
          rel1.target_article_id = tar.article_id and
          rel1.org_id = org.organization_id);

      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Relations because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      BEGIN
        G_context := 'ARL3';
        FORALL  i in article_id_tbl.FIRST ..article_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL(
          SOURCE_ARTICLE_ID,
          TARGET_ARTICLE_ID,
          ORG_ID,
          RELATIONSHIP_TYPE,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
		SELECT /*+ ORDERED USE_NL(INC,TAR) */
          TAR.ARTICLE_ID target_article_id,
          SRC.ARTICLE_ID source_article_id,
          ORG.ORGANIZATION_ID,
          'INCOMPATIBLE',
          INC.object_version_number,
          INC.created_by,
          INC.creation_date,
          INC.last_updated_by,
          INC.last_update_login,
          INC.last_update_date
          FROM  OKC_ARTICLES_ALL SRC, OKC_STD_ART_INCMPTS INC, OKC_ARTICLES_ALL TAR,
          HR_ORGANIZATION_INFORMATION ORG
          WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
          AND SRC.orig_system_reference_id1 = INC.SAE_ID
          AND SRC.orig_system_reference_code in ('OKCMIGNEW' , 'OKCMIGORIG')
          AND TAR.orig_system_reference_id1 = TO_CHAR(INC.SAE_ID_FOR)
          AND TAR.orig_system_reference_code = SRC.orig_system_reference_code
          AND SRC.article_id = article_id_tbl(i)
          AND art_process_status_tbl(i) = 'S'
          AND NOT EXISTS
          (SELECT /*+ NO_UNNEST */
		 1 FROM OKC_ARTICLE_RELATNS_ALL REL1
          WHERE rel1.source_article_id = src.article_id and
          rel1.target_article_id = tar.article_id and
          rel1.org_id = org.organization_id);

      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Relations because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      BEGIN
        G_context := 'ARL4';
        FORALL  i in article_id_tbl.FIRST ..article_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_RELATNS_ALL(
          SOURCE_ARTICLE_ID,
          TARGET_ARTICLE_ID,
          ORG_ID,
          RELATIONSHIP_TYPE,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE)
		SELECT /*+ ORDERED USE_NL(INC,SRC) */
          TAR.ARTICLE_ID target_article_id,
          SRC.ARTICLE_ID source_article_id,
          ORG.ORGANIZATION_ID,
          'INCOMPATIBLE',
          INC.object_version_number,
          INC.created_by,
          INC.creation_date,
          INC.last_updated_by,
          INC.last_update_login,
          INC.last_update_date
          FROM OKC_ARTICLES_ALL TAR, OKC_STD_ART_INCMPTS INC, OKC_ARTICLES_ALL SRC,
          HR_ORGANIZATION_INFORMATION ORG
          WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
          AND SRC.orig_system_reference_id1 = TO_CHAR(INC.SAE_ID)
          AND SRC.orig_system_reference_code in ('OKCMIGNEW' , 'OKCMIGORIG')
          AND TAR.orig_system_reference_id1 = INC.SAE_ID_FOR
          AND TAR.orig_system_reference_code = SRC.orig_system_reference_code
          AND TAR.article_id = article_id_tbl(i)
          AND art_process_status_tbl(i) = 'S'
          AND NOT EXISTS
          (SELECT /*+ NO_UNNEST */
		 1 FROM OKC_ARTICLE_RELATNS_ALL REL1
          WHERE rel1.source_article_id = src.article_id and
          rel1.target_article_id = tar.article_id and
          rel1.org_id = org.organization_id);

      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Relations because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      BEGIN
        G_context := 'ADP';

        -- Bulk insert Article Adoptions
        FORALL  i in t_article_version_id_tbl.FIRST ..t_article_version_id_tbl.LAST
          INSERT INTO OKC_ARTICLE_ADOPTIONS
          (
          GLOBAL_ARTICLE_VERSION_ID,
          ADOPTION_TYPE,
          LOCAL_ORG_ID,
          ADOPTION_STATUS,
          LOCAL_ARTICLE_VERSION_ID,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE
          )
          SELECT
          t_article_version_id_tbl(i),
          'ADOPTED',
          organization_id,
          'APPROVED',
          NULL,
          1.0,
          G_User_Id,
          sysdate,
          G_User_Id,
          G_Login_Id,
          sysdate
          FROM HR_ORGANIZATION_INFORMATION
          WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
          AND ORGANIZATION_ID <> G_GLOBAL_ORG_ID
          AND NOT EXISTS
          (SELECT /*+ NO_UNNEST */
		 1 FROM OKC_ARTICLE_ADOPTIONS
          WHERE GLOBAL_ARTICLE_VERSION_ID = t_article_version_id_tbl(i)
          AND LOCAL_ORG_ID = ORGANIZATION_ID);
      EXCEPTION
        WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
          okc_debug.Log('500: Leaving Article Versions because of EXCEPTION: '||sqlerrm, 2);
        END IF;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
        p_msg_name     => G_UNEXPECTED_ERROR,
        p_token1       => G_SQLCODE_TOKEN,
        p_token1_value => sqlcode,
        p_token2       => G_SQLERRM_TOKEN,
        p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
        l_return_status := G_RET_STS_ERROR;
        x_return_status := G_RET_STS_ERROR;
        ROLLBACK TO SAVEPOINT bulkdml;
        RAISE FND_API.G_EXC_ERROR;
      END;

      -- Update contract articles with newly generated ids.
      -- Newly Generated Ids has been moved to column Old_id of OKC_K_ARTICLES_B

      BEGIN
        G_context := 'KART';
        FORALL  i in t_article_version_id_tbl.FIRST ..t_article_version_id_tbl.LAST
          UPDATE OKC_K_ARTICLES_B B
          SET ARTICLE_VERSION_ID = t_article_version_id_tbl(i),
          SAV_SAE_ID = t_article_id_tbl(i),
          ORIG_ARTICLE_ID = t_article_id_tbl(i)
          WHERE OLD_ID IN
          (SELECT TL.ID FROM OKC_K_ARTICLES_TL TL
          WHERE sav_sav_release=t_artv_sav_release_tbl(i)
          AND language=l_language
          AND text is NULL )
          AND sav_sae_id = t_ver_system_reference_id1_tbl(i)
          AND l_language = t_art_language_tbl(i)
          AND ARTICLE_VERSION_ID IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Versions because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => 'OKC_ART_FETCH_FAILED');

          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      -- Update contract articles history with newly generated ids.
      -- Newly Generated Ids has been moved to column Old_id of OKC_K_ARTICLES_BH

      BEGIN
        G_context := 'KARTH';
        FORALL  i in t_article_version_id_tbl.FIRST ..t_article_version_id_tbl.LAST
          UPDATE OKC_K_ARTICLES_BH B
          SET ARTICLE_VERSION_ID = t_article_version_id_tbl(i),
          SAV_SAE_ID = t_article_id_tbl(i),
          ORIG_ARTICLE_ID = t_article_id_tbl(i)
          WHERE (OLD_ID, MAJOR_VERSION) IN
        (SELECT TL.ID, TL.MAJOR_VERSION FROM OKC_K_ARTICLES_TLH TL
          WHERE sav_sav_release=t_artv_sav_release_tbl(i)
		AND TL.ID = B.OLD_ID
		AND TL.MAJOR_VERSION = B.MAJOR_VERSION
          AND language=l_language
          AND text is NULL )
          AND sav_sae_id = t_ver_system_reference_id1_tbl(i)
          AND l_language = t_art_language_tbl(i)
          AND ARTICLE_VERSION_ID IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
          okc_debug.Log('500: Leaving Article Versions because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);

          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      BEGIN
        FORALL  i in article_id_tbl.FIRST ..article_id_tbl.LAST
          INSERT INTO OKC_FOLDER_CONTENTS
          (
          FOLDER_ID,
          MEMBER_ID,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE
          )
          SELECT
          FOLDER_ID,
          article_id_tbl(i),
          1.0,
          SM.CREATED_BY,
          SM.CREATION_DATE,
          SM.LAST_UPDATED_BY,
          SM.LAST_UPDATE_LOGIN,
          SM.LAST_UPDATE_DATE
          FROM OKC_STD_ART_SET_MEMS SM, OKC_FOLDERS_ALL_B FLD
          WHERE FLD.SAT_CODE = SM.SAT_CODE
          AND  SAE_ID = art_system_reference_id1_tbl(i)
          AND system_reference_code_tbl(i) = 'OKCMIGORIG'
          AND art_process_status_tbl(i) = 'S'
          AND NOT EXISTS
          (SELECT /*+ NO_UNNEST */
		 1 FROM OKC_FOLDER_CONTENTS
          WHERE FOLDER_ID = FLD.FOLDER_ID
          AND MEMBER_ID = article_id_tbl(i));
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Versions because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);

          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;

      ---------------------------------------------------------------------
      /* Migrate Attachments, Attachments exist at the version level
        update records in FND_ATTACHED_DOCUMENTS table
          ENTITY_NAME[varchar2(40)] : old(STD_ARTICLE_VERSIONS_B), new (?)
          PK1_VALUE[varchar2(100)] : old (sae_id:number), new (article_version_id:number)
          PK2_VALUE[varchar2(100)] : old (sav_release:varchar), new ( NULL)
          LAST_UPDATE_DATE : sysdate
          LAST_UPDATE_LOGIN:
          LAST_UPDATED_BY:
      */
      ---------------------------------------------------------------------

      BEGIN
        G_context := 'ATT';
        i := 0;

        -- Update Article Version Attachments
        FORALL  i in t_article_version_id_tbl.FIRST ..t_article_version_id_tbl.LAST
          UPDATE FND_ATTACHED_DOCUMENTS
          SET ENTITY_NAME = 'OKC_ARTICLE_VERSIONS',
          PK1_VALUE = to_char(t_article_version_id_tbl(i)),
          PK2_VALUE = NULL,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATE_LOGIN = G_Login_Id,
          LAST_UPDATED_BY = G_User_Id
          WHERE ENTITY_NAME = 'OKC_STD_ARTICLES_B'
          AND PK1_VALUE = t_ver_system_reference_id1_tbl(i)
          AND PK2_VALUE = t_artv_sav_release_tbl(i)
          AND EXISTS
          (SELECT 1 FROM OKC_ARTICLES_ALL ART WHERE
          ART.ARTICLE_ID = t_article_id_tbl(i) AND
          ART.ORIG_SYSTEM_REFERENCE_ID1 = t_ver_system_reference_id1_tbl(i));
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.Log('500: Leaving Article Version Attachments because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
          p_msg_name     => G_UNEXPECTED_ERROR,
          p_token1       => G_SQLCODE_TOKEN,
          p_token1_value => sqlcode,
          p_token2       => G_SQLERRM_TOKEN,
          p_token2_value => sqlerrm);
          Okc_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKC_ART_FETCH_FAILED',
                              p_token1       => 'CONTEXT',
                              p_token1_value => g_context);
          l_return_status := G_RET_STS_ERROR;
          x_return_status := G_RET_STS_ERROR;
          ROLLBACK TO SAVEPOINT bulkdml;
          RAISE FND_API.G_EXC_ERROR;
      END;


      /*
      UPDATE OKC_STD_ART_SET_MEMS MEM
      SET SAE_ID = article_id_tbl(i)
      WHERE SAE_ID = art_system_reference_id1_tbl(i)
      AND system_reference_code_tbl(i) = 'OKCMIGORIG'
      AND art_process_status_tbl(i) = 'S';
      */

    END IF; -- end of (if t_article_version_tbl.COUNT > 0)

    i := 0;
    ------------------------------------------------------------------------
    --------------- End of Do_DML for migrate related tables   ------------
    -------------------------------------------------------------------------
    COMMIT;
    -- Now delete cache for next bulk fetch

    ver_language_tbl.DELETE;
    article_title_tbl.DELETE;
    article_number_tbl.DELETE;
    article_id_tbl.DELETE;
    article_language_tbl.DELETE;
    system_reference_code_tbl.DELETE;
    art_system_reference_id1_tbl.DELETE;
    article_version_id_tbl.DELETE;
    start_date_tbl.DELETE;
    article_text_tbl.DELETE;
    artv_sav_release_tbl.DELETE;
    t_ver_language_tbl.DELETE;
    t_art_language_tbl.DELETE;
    t_article_id_tbl.DELETE;
    t_article_version_id_tbl.DELETE;
    t_art_version_number_tbl.DELETE;
    t_start_date_tbl.DELETE;
    t_end_date_tbl.DELETE;
    t_article_text_tbl.DELETE;
    t_artv_sav_release_tbl.DELETE;
    art_process_status_tbl.DELETE;
    ver_process_status_tbl.DELETE;
    t_ver_system_reference_id1_tbl.DELETE;
    t_system_reference_code_tbl.DELETE;
    t_display_name_tbl.DELETE;
    display_name_tbl.DELETE;

    EXIT WHEN l_orig_article_csr%NOTFOUND;
  EXCEPTION  -- from line 871 approx

    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
        okc_debug.Log('300: Error occurred in this fetch... Moving on to next fetch: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      l_return_status := G_RET_STS_ERROR ;
      x_return_status := G_RET_STS_ERROR ;

	 -- MKS 09/10 ... Table variables should be initialized for every batch run. This error still make the pgm continue for next batch.
      ver_language_tbl.DELETE;
      article_title_tbl.DELETE;
      article_number_tbl.DELETE;
      article_id_tbl.DELETE;
      article_language_tbl.DELETE;
      system_reference_code_tbl.DELETE;
      art_system_reference_id1_tbl.DELETE;
      article_version_id_tbl.DELETE;
      start_date_tbl.DELETE;
      article_text_tbl.DELETE;
      artv_sav_release_tbl.DELETE;
      t_ver_language_tbl.DELETE;
      t_art_language_tbl.DELETE;
      t_article_id_tbl.DELETE;
      t_article_version_id_tbl.DELETE;
      t_art_version_number_tbl.DELETE;
      t_start_date_tbl.DELETE;
      t_end_date_tbl.DELETE;
      t_article_text_tbl.DELETE;
      t_artv_sav_release_tbl.DELETE;
      art_process_status_tbl.DELETE;
      ver_process_status_tbl.DELETE;
      t_ver_system_reference_id1_tbl.DELETE;
      t_system_reference_code_tbl.DELETE;
      t_display_name_tbl.DELETE;
      display_name_tbl.DELETE;

    WHEN G_EXC_PREREQ_SETUP_ERROR THEN
      IF (l_debug = 'Y') THEN
        okc_debug.Log('400: Leaving Fetch Loop: No more processing: Prereq is not properly set(AUTONUMBER)', 2);
      END IF;
      --
      l_return_status := G_RET_STS_ERROR ;
      x_return_status := G_RET_STS_ERROR ;
      get_print_msgs_stack;
      exit;-- exit this loop


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
        okc_debug.Log('400: Leaving Fetch Loop: No more processing: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;

      IF l_orig_article_csr%ISOPEN THEN
        CLOSE l_orig_article_csr;
      END IF;
      IF l_orig_ver_csr%ISOPEN THEN
        CLOSE l_orig_ver_csr;
	 END IF;
      IF l_unq_csr%ISOPEN THEN
        CLOSE l_unq_csr;
	 END IF;
      l_return_status := G_RET_STS_UNEXP_ERROR ;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack;
      exit;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.Log('500: Leaving Fetch Loop: No more processing: because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      IF l_orig_article_csr%ISOPEN THEN
        CLOSE l_orig_article_csr;
      END IF;
      IF l_orig_ver_csr%ISOPEN THEN
        CLOSE l_orig_ver_csr;
	 END IF;
      IF l_unq_csr%ISOPEN THEN
        CLOSE l_unq_csr;
	 END IF;
      l_return_status := G_RET_STS_UNEXP_ERROR ;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
      get_print_msgs_stack;
      --   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data, p_encoded => G_FALSE );
      exit;
  END; -- line 871 approx
  END LOOP; -- line 870 approx


-----------------------------------------------------------------------
-- End of outermost loop for bulk fetch
-----------------------------------------------------------------------

  IF l_orig_article_csr%ISOPEN THEN
    CLOSE l_orig_article_csr;
  END IF;

  IF not l_migrated THEN
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
    p_msg_name     => 'OKC_ART_MIG_OUTPUT_NO_ART');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MSG_PUB.Get(1,p_encoded =>FND_API.G_FALSE ));
  ELSE
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
    p_msg_name     => 'OKC_ART_MIG_OUTPUT');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MSG_PUB.Get(1,p_encoded =>FND_API.G_FALSE ));
    FOR i in l_org_name_tbl.FIRST..l_org_name_tbl.LAST LOOP
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_org_name_tbl(i));
    END LOOP;
  END IF;

  FND_MSG_PUB.initialize;
  l_org_id_tbl.DELETE;
  l_org_name_tbl.DELETE;

  IF (l_debug = 'Y') THEN
    okc_debug.Log('200: Leaving articles migrate', 2);
  END IF;
  x_return_status := l_return_status;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF (l_debug = 'Y') THEN
      okc_debug.Log('300: Leaving Articles_Migrate: OKC_API.G_EXCEPTION_ERROR Exception', 2);
    END IF;
    get_print_msgs_stack;
    x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (l_debug = 'Y') THEN
      okc_debug.Log('400: Leaving Articles_Migrate: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
    END IF;

    IF l_orig_article_csr%ISOPEN THEN
      CLOSE l_orig_article_csr;
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    get_print_msgs_stack;

  WHEN OTHERS THEN
    IF (l_debug = 'Y') THEN
      okc_debug.Log('500: Leaving Articles_Migrate because of EXCEPTION: '||sqlerrm, 2);
    END IF;

    IF l_orig_article_csr%ISOPEN THEN
      CLOSE l_orig_article_csr;
    END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    get_print_msgs_stack;
    --  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data, p_encoded => G_FALSE );
END migrate_articles;


END OKC_ARTICLES_MIGRATE_GRP;

/
