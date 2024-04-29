--------------------------------------------------------
--  DDL for Package Body OKC_ADOPTIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ADOPTIONS_GRP" AS
/* $Header: OKCGADPB.pls 120.0 2005/05/25 19:10:15 appldev noship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ADOPTIONS_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);

  ---------------------------------------
  -- PROCEDURE check adoption details  --
  ---------------------------------------
  -- Where Used : 'Submit for Approve', 'Localize'
  -- Where Called : 'Localized' - ArticleVAM java
  --                'Submit for Approve' - OKC_ARTICLE_STATUS_CHANGE_PVT.pending_approval
  PROCEDURE check_adoption_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    x_earlier_local_version_id     OUT NOCOPY VARCHAR2,
    p_global_article_version_id    IN NUMBER,
    p_adoption_type                IN VARCHAR2,
    p_local_org_id                 IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_check_adoption';
    l_lcz_article_id              NUMBER;

    l_global_org_id               NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    l_local_article_title         OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE;
    l_adp_row_notfound    BOOLEAN := FALSE;
    l_lcz_row_notfound    BOOLEAN := FALSE;
    l_row_found           BOOLEAN := FALSE;
    l_row_notfound        BOOLEAN := FALSE;
    l_never_adopted       BOOLEAN := FALSE;

    CURSOR l_adoption_csr (cp_global_article_version_id IN NUMBER,
                           cp_local_org_id IN NUMBER) IS
      SELECT article_id,
             start_date,
             article_status,
             local_article_version_id,
             okc_article_adoptions.adoption_type
      FROM OKC_ARTICLE_ADOPTIONS, OKC_ARTICLE_VERSIONS
       WHERE global_article_version_id = cp_global_article_version_id
        AND  article_version_id = global_article_version_id
        AND  global_yn = 'Y'
        AND  local_org_id = cp_local_org_id
        AND  article_status = 'APPROVED'
        AND  nvl(end_date, sysdate+1) >= trunc(sysdate)
        AND  okc_article_adoptions.adoption_type = 'AVAILABLE';

    CURSOR l_latest_ver_adp_csr(cp_article_id IN NUMBER,
                                    cp_article_version_id IN NUMBER,
                                    cp_local_org_id IN NUMBER) IS
-- 8.1.7.4 compatibility
SELECT
   av.start_date,
   av.end_date,
   ad.adoption_type,
   ad.adoption_status,
   av.article_version_number,
   av.article_version_id
FROM
   okc_article_versions av,
   okc_article_adoptions ad
WHERE
   av.article_id = cp_article_id
AND
   ad.global_article_version_id = av.article_version_id
AND
   ad.local_org_id = cp_local_org_id
AND
   ad.adoption_type = 'ADOPTED'
AND
   ad.global_article_version_id <> cp_article_version_id
AND
   av.start_date =   (SELECT
                        max(av1.start_date)
                      FROM
                        okc_article_versions av1,
                        okc_article_adoptions ad1
                     WHERE
                        av1.article_id = av.article_id
                     AND
                        ad1.global_article_version_id = av1.article_version_id
                     AND
                        ad1.local_org_id = ad.local_org_id
                     AND
                        ad1.adoption_type = 'ADOPTED'
                     AND
                        ad1.global_article_version_id <> cp_article_version_id
                     );

/*
     SELECT S.GLOBAL_YN,
            S.ARTICLE_STATUS,
            S.START_DATE,
            S.END_DATE,
            S.MAX_START_DATE,
            S.ADOPTION_TYPE,
            S.ADOPTION_STATUS,
            S.LOCAL_ARTICLE_VERSION_ID,
            S.ARTICLE_VERSION_NUMBER,
            S.ARTICLE_VERSION_ID
      FROM (
         SELECT
           A.GLOBAL_YN,
           A.ARTICLE_STATUS,
           A.START_DATE, A.END_DATE,
           MAX(A.START_DATE) OVER (PARTITION BY A.ARTICLE_ID) AS MAX_START_DATE,
           AD.ADOPTION_TYPE,
           AD.ADOPTION_STATUS,
           AD.LOCAL_ARTICLE_VERSION_ID,
           A.ARTICLE_VERSION_NUMBER,
           A.ARTICLE_VERSION_ID
         FROM OKC_ARTICLE_VERSIONS A, OKC_ARTICLE_ADOPTIONS AD
         WHERE A.ARTICLE_ID = cp_article_id
           AND AD.GLOBAL_ARTICLE_VERSION_ID = A.ARTICLE_VERSION_ID
           AND AD.LOCAL_ORG_ID = cp_local_org_id
           AND AD.ADOPTION_TYPE <> 'AVAILABLE'
           AND AD.GLOBAL_ARTICLE_VERSION_ID <> cp_article_version_id
           ) S
     WHERE S.START_DATE = S.MAX_START_DATE;
*/
-- Cursor to find article_id of localized articles if the global article is localized
    CURSOR l_lcz_article_id_csr(cp_global_article_id IN NUMBER,
                                cp_local_org_id IN NUMBER) IS
      SELECT distinct(ARVL.ARTICLE_ID)
      FROM   OKC_ARTICLE_ADOPTIONS ADP,
             OKC_ARTICLE_VERSIONS ARVG,
             OKC_ARTICLE_VERSIONS ARVL
      WHERE  ARVG.ARTICLE_ID = cp_global_article_id
       AND ADP.GLOBAL_ARTICLE_VERSION_ID = ARVG.ARTICLE_VERSION_ID
       AND ADP.LOCAL_ORG_ID = cp_local_org_id
       AND ADP.ADOPTION_TYPE = 'LOCALIZED'
       AND ADP.LOCAL_ARTICLE_VERSION_ID = ARVL.ARTICLE_VERSION_ID;

-- Cursor to find latest version for localized article
    CURSOR l_latest_ver_lcz_csr(cp_lcz_article_id IN NUMBER) IS
      SELECT
        AV.START_DATE,
        AV.END_DATE,
        AV.ADOPTION_TYPE,
        AV.ARTICLE_STATUS ADOPTION_STATUS,
        AV.ARTICLE_VERSION_NUMBER,
        AV.ARTICLE_VERSION_ID
      FROM   OKC_ARTICLE_VERSIONS AV
      WHERE  AV.ARTICLE_ID = cp_lcz_article_id
       AND AV.ADOPTION_TYPE = 'LOCALIZED'
       AND AV.START_DATE = ( SELECT MAX(V.START_DATE)
                             FROM OKC_ARTICLE_VERSIONS V
                             WHERE  V.ARTICLE_ID = cp_lcz_article_id
                               AND  V.ADOPTION_TYPE = 'LOCALIZED');

-- Cursor to check uniqueness of adopted article title in local
    CURSOR l_unq_local_title_csr (cp_local_org_id IN NUMBER,
                                  cp_global_article_id IN NUMBER,
                                  cp_global_org_id IN NUMBER) IS
     SELECT  1
      FROM   OKC_ARTICLES_ALL ARTL
      WHERE  ARTL.ORG_ID = cp_local_org_id
        AND ARTL.STANDARD_YN = 'Y'
        AND ARTL.ARTICLE_TITLE = ( SELECT ARTG.ARTICLE_TITLE
                                    FROM OKC_ARTICLES_ALL ARTG
                                    WHERE ARTG.ARTICLE_ID = cp_global_article_id
                                      AND ARTG.ORG_ID = cp_global_org_id
                                      AND ARTG.STANDARD_YN= 'Y');


   l_latest_ver_adp_rec  l_latest_ver_adp_csr%ROWTYPE;
   l_latest_ver_lcz_rec  l_latest_ver_lcz_csr%ROWTYPE;
   l_adoption_rec  l_adoption_csr%ROWTYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered check_adoption with parameters: ' || p_global_article_version_id ||'*'|| p_adoption_type  ||'*'|| p_local_org_id, 2);
    END IF;
    x_earlier_local_version_id := NULL;

    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_local_org_id = G_GLOBAL_ORG_ID OR
        p_local_org_id = -99 OR
        l_global_org_id = -99) THEN
        OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_NO_ADP_GLBL_ORG');
        RAISE FND_API.G_EXC_ERROR ;
    ELSE
      IF p_global_article_version_id IS NULL Then
         OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_INV_GLOB_ADP');
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
      OPEN l_adoption_csr (p_global_article_version_id, p_local_org_id);
      FETCH l_adoption_csr INTO l_adoption_rec;
      l_row_notfound := l_adoption_csr%NOTFOUND;
      CLOSE l_adoption_csr;

-- Global Article Version must be valid for adoption should be global, approved and must be avilable for adoption
-- to the local org.

      IF (l_row_notfound) THEN
        IF (l_debug = 'Y') THEN
            okc_debug.log('200: Adoption cursor row not found', 2);
        END IF;
        OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_INV_GLOB_ADP');
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF (nvl(p_adoption_type, 'INVALID') NOT IN ('ADOPTED', 'LOCALIZED')) THEN
        IF (l_debug = 'Y') THEN
            okc_debug.log('300: Adoption type is wrong', 2);
        END IF;
        OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_INV_GLOB_ADP');
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF (l_adoption_rec.article_status = 'ON_HOLD') THEN
        IF (l_debug = 'Y') THEN
            okc_debug.log('350: Invalid status to be adopted', 2);
        END IF;
        OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_INV_STATUS_TO_ADOPT');
        RAISE FND_API.G_EXC_ERROR ;
      END IF;


      OPEN  l_latest_ver_adp_csr(l_adoption_rec.article_id, p_global_article_version_id, p_local_org_id);
        FETCH l_latest_ver_adp_csr  INTO l_latest_ver_adp_rec ;
        l_adp_row_notfound := l_latest_ver_adp_csr%NOTFOUND;
      CLOSE  l_latest_ver_adp_csr;

      OPEN  l_lcz_article_id_csr(l_adoption_rec.article_id, p_local_org_id);
        FETCH l_lcz_article_id_csr     INTO l_lcz_article_id;
        l_lcz_row_notfound := l_lcz_article_id_csr%NOTFOUND;
      CLOSE l_lcz_article_id_csr;

      x_earlier_local_version_id := l_latest_ver_adp_rec.article_version_id;

-- Check that the global article version does not have any other later version already localized.
-- Check if the adoption type is not same as previous adoptions for the same global article
     IF (l_adp_row_notfound AND l_lcz_row_notfound) THEN
        IF (l_debug = 'Y') THEN
            okc_debug.log('200: Other version row not found', 2);
        END IF;
        l_never_adopted := TRUE;
      ELSIF (   ( NOT l_adp_row_notfound AND p_adoption_type <> 'ADOPTED')
             OR ( NOT l_lcz_row_notfound AND p_adoption_type <> 'LOCALIZED')) THEN
            IF (l_debug = 'Y') THEN
                okc_debug.log('400: Other version row different adoption', 2);
            END IF;
            OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_DIFF_ADP_TYPE');
            RAISE FND_API.G_EXC_ERROR ;
      ELSIF ( NOT l_lcz_row_notfound ) THEN
      -- localization flow
            l_lcz_row_notfound := FALSE;
            OPEN l_latest_ver_lcz_csr(l_lcz_article_id);
              FETCH l_latest_ver_lcz_csr INTO l_latest_ver_lcz_rec ;
              l_lcz_row_notfound := l_latest_ver_lcz_csr%NOTFOUND;
            CLOSE l_latest_ver_lcz_csr ;

            x_earlier_local_version_id := l_latest_ver_lcz_rec.article_version_id;
            IF (l_lcz_row_notfound) THEN
                IF (l_debug = 'Y') THEN
                    okc_debug.log('500: Localization Latest version not found', 2);
                END IF;
                OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_INV_GLOB_ADP');
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF nvl(l_latest_ver_lcz_rec.adoption_status, 'DRAFT')
                    IN ('DRAFT','REJECTED','PENDING_APPROVAL') THEN
                IF (l_debug = 'Y') THEN
                    okc_debug.log('600: Other version has adoption in Rejected/Draft/Pending Approval', 2);
                END IF;
                OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_EXIST_DRAFT_LOCALIZED');
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

      ELSIF ( NOT l_adp_row_notfound) THEN
      -- Adoption flow
            IF (l_latest_ver_adp_rec.start_date > l_adoption_rec.start_date) THEN
              IF (l_debug = 'Y') THEN
                  okc_debug.log('700: Other version has a later adoption', 2);
              END IF;
              OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_LATER_GLOB_ADP_EXIST');
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF nvl(l_latest_ver_adp_rec.adoption_status, 'REJECTED')
                    IN ('PENDING_APPROVAL') THEN
              IF (l_debug = 'Y') THEN
                  okc_debug.log('800: Other version has adoption in Pending Approval', 2);
              END IF;
              OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_EXIST_PENDING_ADOPTED');
              RAISE FND_API.G_EXC_ERROR ;
            END IF;
    END IF; -- IF (l_adp_row_notfound AND l_lcz_row_notfound)

    --Check whether adopted article title exists in local org
    IF (l_never_adopted AND p_adoption_type = 'ADOPTED') THEN

        OPEN l_unq_local_title_csr ( p_local_org_id,
                                     l_adoption_rec.article_id,
                                     l_global_org_id) ;
          FETCH l_unq_local_title_csr INTO l_local_article_title;
          l_row_found := l_unq_local_title_csr%FOUND;
        CLOSE l_unq_local_title_csr;

        IF (l_row_found) THEN
          IF (l_debug = 'Y') THEN
              okc_debug.log('1000: Duplicate title found in local org', 2);
          END IF;
          OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_DUP_TITLE_ADP_ORG');
          RAISE FND_API.G_EXC_ERROR ;
        END IF;

    END IF;

   END IF; -- IF( p_local_org_id = G_GLOBAL_ORG_ID OR p_local_org_id = -99 OR l_global_org_id = -99 )

   IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving check adoption', 2);
   END IF;
   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('3000: Leaving Check_Adoption: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('4000: Leaving Check_Adoption: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      IF l_latest_ver_adp_csr%ISOPEN THEN
         CLOSE l_latest_ver_adp_csr;
      END IF;
      IF l_lcz_article_id_csr%ISOPEN THEN
         CLOSE l_lcz_article_id_csr;
      END IF;
      IF l_latest_ver_lcz_csr%ISOPEN THEN
         CLOSE l_latest_ver_lcz_csr;
      END IF;
      IF l_adoption_csr%ISOPEN THEN
         CLOSE l_adoption_csr;
      END IF;
      IF l_unq_local_title_csr%ISOPEN THEN
         CLOSE l_unq_local_title_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,p_encoded=> 'F',  p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('5000: Leaving Check_Adoption because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_latest_ver_adp_csr%ISOPEN THEN
         CLOSE l_latest_ver_adp_csr;
      END IF;
      IF l_lcz_article_id_csr%ISOPEN THEN
         CLOSE l_lcz_article_id_csr;
      END IF;
      IF l_latest_ver_lcz_csr%ISOPEN THEN
         CLOSE l_latest_ver_lcz_csr;
      END IF;
      IF l_adoption_csr%ISOPEN THEN
         CLOSE l_adoption_csr;
      END IF;
      IF l_unq_local_title_csr%ISOPEN THEN
         CLOSE l_unq_local_title_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,p_encoded=> 'F',  p_data => x_msg_data );

  END check_adoption_details;


  PROCEDURE delete_local_adoption_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_only_local_version          IN VARCHAR2,
    p_local_article_version_id    IN NUMBER,
    p_local_org_id                 IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_delete_adoption';
    l_global_article_version_id   NUMBER := NULL;
    l_local_article_version_id    NUMBER;
    l_row_notfound    BOOLEAN := FALSE;
    l_delete_adoption              VARCHAR2(1) := 'T';

-- Cursor to find out if the current version is created as a LOCALIZED from a
-- new global article version or if it is simply a new version being created
-- from an existing local version
-- This is because when we create a new version we inherit the adoption details -- of the earlier version resulting in
-- multiple occurences of the global version

    CURSOR l_other_version_csr (cp_article_version_id IN NUMBER,
                               cp_local_org_id IN NUMBER) IS

      SELECT 'T' , global_article_version_id FROM OKC_ARTICLE_ADOPTIONS A
       WHERE local_article_version_id = cp_article_version_id
        AND  local_org_id = cp_local_org_id
        AND  EXISTS
             (SELECT '1' FROM OKC_ARTICLE_ADOPTIONS B
              WHERE B.GLOBAL_ARTICLE_VERSION_ID = A.GLOBAL_ARTICLE_VERSION_ID
               AND  B.LOCAL_ARTICLE_VERSION_ID <> A.LOCAL_ARTICLE_VERSION_ID
               AND  B.LOCAL_ORG_ID = A.LOCAL_ORG_ID);


  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered delete_adoption', 2);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
-- If a local article version is deleted the attached global article version
-- becomes available in the adoption table with adoption type as "AVAILABLE".
-- However this is only in case of LOCALIZATION of local article versions.
-- In the case of a local article version being created as a new version
-- from a prior version we delete the adoption row for this version.

    IF (p_local_org_id = G_GLOBAL_ORG_ID OR
        p_local_org_id = -99 OR
        p_local_org_id = -99 ) THEN
       NULL;
    ELSE
      l_delete_adoption := 'T';

      IF p_only_local_version = 'F' Then

-- Cursor to find out if the current version is created as a LOCALIZED from a
-- new global article version or if it is simply a new version being created
-- from an existing local version

         OPEN l_other_version_csr (p_local_article_version_id, p_local_org_id);
         FETCH l_other_version_csr into l_delete_adoption, l_global_article_version_id;
         l_row_notfound    := l_other_version_csr%NOTFOUND;
         CLOSE l_other_version_csr;
         IF l_row_notfound THEN
           l_delete_adoption := 'F';
           l_global_article_version_id := NULL; -- since we could not figure it out yet.
         END IF;
      ELSE
        l_delete_adoption := 'F';
      END IF;

-- Do not know the global article version id..
-- Simple API will figure it out if we pass the global article version id as NULL
      --dbms_output.put_line('In Adoption:' ||l_delete_adoption||'*'||p_only_local_version);

      IF l_delete_adoption = 'F' Then
         OKC_ARTICLE_ADOPTIONS_PVT.update_row(
            x_return_status => x_return_status,
            p_global_article_version_id => l_global_article_version_id,
            p_adoption_type             => 'AVAILABLE',
            p_local_org_id              => p_local_org_id,
            p_orig_local_version_id  => p_local_article_version_id,
            p_new_local_version_id  => NULL,
            p_adoption_status       => OKC_API.G_MISS_CHAR,
            p_object_version_number  => NULL
           );
      ELSIF l_delete_adoption = 'T' Then
         OKC_ARTICLE_ADOPTIONS_PVT.delete_row(
            x_return_status => x_return_status,
            p_global_article_version_id => l_global_article_version_id,
            p_local_org_id              => p_local_org_id,
            p_local_article_version_id  => p_local_article_version_id,
            p_object_version_number  => NULL
           );
     ELSE
        OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_ADP_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR ;
     END IF;
   END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving check adoption', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving delete_Adoption: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving delete_Adoption because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_other_version_csr%ISOPEN THEN
         CLOSE l_other_version_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END delete_local_adoption_details;

  PROCEDURE create_local_adoption_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_adoption_type                OUT NOCOPY VARCHAR2,

    p_article_status               IN VARCHAR2,
    p_earlier_local_version_id     IN NUMBER,
    p_local_article_version_id       IN NUMBER,
    p_global_article_version_id    IN NUMBER,
    p_local_org_id                 IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_create_adoption';
    l_local_article_version_id    NUMBER;
    l_global_article_version_id    NUMBER := -99;
    l_global_version_id_out       NUMBER;
    l_article_id                  NUMBER;
    l_local_org_id                NUMBER;
    l_adoption_type               OKC_ARTICLE_ADOPTIONS.ADOPTION_TYPE%TYPE;
    l_adoption_status             OKC_ARTICLE_ADOPTIONS.ADOPTION_STATUS%TYPE;
    l_start_date DATE;
    l_end_date DATE;
    l_row_notfound    BOOLEAN := FALSE;
    CURSOR l_adoption_csr (cp_local_article_version_id IN NUMBER,
                           cp_local_org_id IN NUMBER) IS
       SELECT global_article_version_id, adoption_type FROM
           OKC_ARTICLE_ADOPTIONS
       WHERE local_article_version_id = cp_local_article_version_id
        AND  local_org_id = cp_local_org_id;

   l_adoption_rec  l_adoption_csr%ROWTYPE;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered create_adoption', 2);
    END IF;

    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_adoption_type := NULL;
--    dbms_output.put_line(p_earlier_local_version_id||'*'||p_global_article_version_id);
    IF (p_local_org_id = G_GLOBAL_ORG_ID OR
        p_local_org_id = -99 OR
        G_GLOBAL_ORG_ID = -99) THEN
       NULL;
    ELSE
-- p_global_article_version_id should be passed for LOCALIZE option of creating
-- a new local article version.
      IF p_earlier_local_version_id IS NOT NULL THEN
         OPEN l_adoption_csr (p_earlier_local_version_id, p_local_org_id);
         FETCH l_adoption_csr INTO l_adoption_rec;
         l_row_notfound := l_adoption_csr%NOTFOUND;
         CLOSE l_adoption_csr;

-- Earlier version of the local article exists but has not been adopted ...
-- ERROR

         IF (l_row_notfound) THEN
           OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_EARLIER_NOT_ADPT');
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
/*
-- For LOCALIZE option the same global article version for a local article
-- version should not be the same for the earlier version of the same local
-- article. In other words, one LOCALIZED version cannot have multiple global
-- article versions .
-- However, this is not true if the new article version of the local article
-- is created manually as a New Version - in that case we copy the global
-- article version_id from the previous adoption.

         IF p_global_article_version_id IS NOT NULL AND
            p_global_article_version_id = l_adoption_rec.global_article_version_id THEN
            OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_MULTI_GLOB_ADPT');
            RAISE FND_API.G_EXC_ERROR ;
         END IF;
*/
-- For LOCALIZE option the earlier local article version id has a different
-- adoption type i.e. ADOPTED (as is) ... ERROR

         IF l_adoption_rec.adoption_type <> 'LOCALIZED' THEN
            OKC_API.SET_MESSAGE(G_APP_NAME, 'OKC_ART_DIFF_ADP_TYPE');
            RAISE FND_API.G_EXC_ERROR ;
         END IF;
         l_global_article_version_id := l_adoption_rec.global_article_version_id;
      ELSE  -- earlier local version id IS NULL
         l_global_article_version_id := p_global_article_version_id;
      END IF;
-- Update the available adoption row from "AVAILABLE" to "LOCALIZED"
--      dbms_output.put_line('GLOBAL VERSION ID:'||l_global_article_version_id);
--      dbms_output.put_line('LOCAL VERSION ID:'||p_local_article_version_id);
--      dbms_output.put_line('EARLIER VERSION ID:'||p_earlier_local_version_id);
      IF p_global_article_version_id IS NOT NULL THEN
           OKC_ARTICLE_ADOPTIONS_PVT.update_row(
              p_validation_level   => p_validation_level,
              x_return_status => x_return_status,
              p_global_article_version_id => p_global_article_version_id,
              p_adoption_type             => 'LOCALIZED',
              p_local_org_id              => p_local_org_id,
              p_orig_local_version_id  => NULL,
              p_new_local_version_id  => p_local_article_version_id,
              p_adoption_status       => nvl(p_article_status,'DRAFT'),
              p_object_version_number  => NULL
  );
--      dbms_output.put_line('RETURN:'||x_return_status);

        --------------------------------------------
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR ;
        END IF;
    --------------------------------------------
        x_adoption_type := 'LOCALIZED';
        return;
      END IF;

      IF l_global_article_version_id IS NOT NULL AND
         l_global_article_version_id <> -99 THEN

         IF p_earlier_local_version_id IS NULL Then

           OKC_ARTICLE_ADOPTIONS_PVT.update_row(
              p_validation_level   => p_validation_level,
              x_return_status => x_return_status,
              p_global_article_version_id => l_global_article_version_id,
              p_adoption_type             => 'LOCALIZED',
              p_local_org_id              => p_local_org_id,
              p_orig_local_version_id  => NULL,
              p_new_local_version_id  => p_local_article_version_id,
              p_adoption_status       => nvl(p_article_status,'DRAFT'),
              p_object_version_number  => NULL
  );
            x_adoption_type := 'LOCALIZED';

         ELSE

           --dbms_output.put_line('Creating Adoptions');
-- Brand new Article/version being created from "Create New version" of an
-- existing article version which has been LOCALIZED. This will copy the
-- adoption row for this new version based on global and org details from
-- the previous version.


           OKC_ARTICLE_ADOPTIONS_PVT.INSERT_ROW
              (
                p_validation_level => p_validation_level,
                x_return_status   => x_return_status,
                p_global_article_version_id=> l_global_article_version_id,
                p_adoption_type => 'LOCALIZED',
                p_local_org_id => p_local_org_id,
                p_local_article_version_id => p_local_article_version_id,
                p_adoption_status  => nvl(p_article_status,'DRAFT'),
                x_global_article_version_id => l_global_version_id_out,
                x_local_org_id           => l_local_org_id,
                x_local_article_version_id => l_local_article_version_id
               );
            x_adoption_type := 'LOCALIZED';
          END IF; -- p_earlier local article version id is NULL
       END IF; -- l_global_article_version_id is NULL
    END IF; -- local org id = global org id
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving check adoption', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving create_local_adoption_details: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving create_local_adoption_details: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      IF l_adoption_csr%ISOPEN THEN
         CLOSE l_adoption_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving create_local_adoption_details because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_adoption_csr%ISOPEN THEN
         CLOSE l_adoption_csr;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END create_local_adoption_details;

  PROCEDURE AUTO_ADOPT_ARTICLES
    (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_relationship_yn              IN VARCHAR2 := 'N',
    p_adoption_yn                  IN VARCHAR2 := 'N',
    p_fetchsize                    IN NUMBER,
    p_global_article_id            IN NUMBER,
    p_global_article_version_id    IN NUMBER
    ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'g_auto_adoption';
    l_dummy                       VARCHAR2(1) := '?';
    l_rowfound                    BOOLEAN := FALSE;
    l_local_article_version_id    NUMBER;
    i    NUMBER := 0;
    j    NUMBER := 0;
    l_global_version_id_out       NUMBER;
    l_article_id                  NUMBER;
    l_local_org_id                NUMBER;
    l_return_status               VARCHAR2(1);
    l_local_article_title         OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE;
    l_adoption_type               OKC_ARTICLE_ADOPTIONS.ADOPTION_TYPE%TYPE;
    l_adoption_status             OKC_ARTICLE_ADOPTIONS.ADOPTION_STATUS%TYPE;
    l_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    TYPE l_org_id_list         IS TABLE OF HR_ORGANIZATION_INFORMATION.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_adoption_type_list  IS TABLE OF FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_notifier_list  IS TABLE OF HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_adoption_status_list  IS TABLE OF OKC_ARTICLE_ADOPTIONS.ADOPTION_STATUS%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_adp_record_status_list  IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE l_record_status_list  IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE l_article_number_list IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_NUMBER%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_source_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.SOURCE_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_target_article_id_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.TARGET_ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_relationship_type_list IS TABLE OF OKC_ARTICLE_RELATNS_ALL.RELATIONSHIP_TYPE%TYPE INDEX BY BINARY_INTEGER ;

    l_article_number_tbl   l_article_number_list ;
    l_source_article_id_tbl   l_source_article_id_list ;
    l_target_article_id_tbl   l_target_article_id_list ;
    l_relationship_type_tbl   l_relationship_type_list ;

    l_org_id_tbl l_org_id_list;
    l_adoption_type_tbl l_adoption_type_list;
    l_notifier_tbl  l_notifier_list;
    l_adoption_status_tbl l_adoption_status_list;
    l_adp_record_status_tbl l_adp_record_status_list;

   CURSOR l_org_info_csr (cp_global_org_id IN NUMBER) IS
     SELECT ORGANIZATION_ID,
            decode(nvl(ORG_INFORMATION1,'N'),'N','AVAILABLE','Y','ADOPTED') ADOPTION_TYPE ,
            ORG_INFORMATION2

       FROM HR_ORGANIZATION_INFORMATION
      WHERE ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND ORGANIZATION_ID <> cp_global_org_id;

   CURSOR l_adoptions_csr (cp_global_version_id IN NUMBER, cp_local_org_id IN NUMBER) IS
    SELECT '1'
    FROM OKC_ARTICLE_ADOPTIONS
     WHERE GLOBAL_ARTICLE_VERSION_ID = cp_global_version_id
      AND  LOCAL_ORG_ID = cp_local_org_id
      AND  rownum < 2;

   CURSOR l_relationship_csr (cp_local_org_id IN NUMBER,
                              cp_global_article_id IN NUMBER,
                              cp_global_org_id IN NUMBER) IS
    SELECT A.ARTICLE_NUMBER,
           SOURCE_ARTICLE_ID,
           TARGET_ARTICLE_ID,
           RELATIONSHIP_TYPE
      FROM OKC_ARTICLE_RELATNS_ALL R,
           OKC_ARTICLES_ALL A
     WHERE R.SOURCE_ARTICLE_ID = cp_global_article_id
      AND  R.TARGET_ARTICLE_ID = A.ARTICLE_ID
      AND  R.ORG_ID = cp_global_org_id
      AND EXISTS
           (SELECT 1 FROM OKC_ARTICLE_VERSIONS V
            WHERE V.ARTICLE_ID = R.TARGET_ARTICLE_ID
              AND V.GLOBAL_YN = 'Y'
              AND V.ARTICLE_STATUS = 'APPROVED'
              AND NVL(V.END_DATE,SYSDATE + 1) > SYSDATE
             )
      AND EXISTS
           (SELECT 1 FROM OKC_ARTICLE_VERSIONS V1
            WHERE V1.ARTICLE_ID = R.SOURCE_ARTICLE_ID
              AND V1.GLOBAL_YN = 'Y'
              AND V1.ARTICLE_STATUS = 'APPROVED'
              AND NVL(V1.END_DATE,SYSDATE + 1) > SYSDATE
             )
    AND NOT EXISTS
      (
       SELECT '1'
       FROM OKC_ARTICLE_RELATNS_ALL R1
       WHERE R1.SOURCE_ARTICLE_ID = R.SOURCE_ARTICLE_ID AND
             R1.TARGET_ARTICLE_ID = R.TARGET_ARTICLE_ID AND
             R1.RELATIONSHIP_TYPE = R.RELATIONSHIP_TYPE AND
             R1.ORG_ID = cp_local_org_id
      );

    CURSOR l_unq_local_title_csr (cp_local_org_id IN NUMBER,
                                  cp_global_article_id IN NUMBER,
                                  cp_global_org_id IN NUMBER) IS
     SELECT  1
      FROM   OKC_ARTICLES_ALL ARTL
      WHERE  ARTL.ORG_ID = cp_local_org_id
        AND  ARTL.STANDARD_YN= 'Y'
        AND  ARTL.ARTICLE_TITLE = ( SELECT ARTG.ARTICLE_TITLE
                                    FROM OKC_ARTICLES_ALL ARTG
                                    WHERE ARTG.ARTICLE_ID = cp_global_article_id
                                      AND ARTG.ORG_ID = cp_global_org_id
                                      AND ARTG.STANDARD_YN='Y');
    l_user_id NUMBER := FND_GLOBAL.USER_ID;
    l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered create_adoption', 2);
    END IF;

    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.put_line('Global org is: '|| l_global_org_id);
    if p_adoption_yn = 'N' and p_relationship_yn = 'N' Then
       return;
    end if;
    OPEN l_org_info_csr (l_global_org_id);
    LOOP
       FETCH l_org_info_csr BULK COLLECT INTO l_org_id_tbl, l_adoption_type_tbl, l_notifier_tbl LIMIT p_fetchsize;
       i := 0;
       EXIT WHEN l_org_id_tbl.COUNT = 0;
      --dbms_output.put_line('Cursor fetched rows: '||l_org_id_tbl.COUNT);

       FOR i IN l_org_id_tbl.FIRST..l_org_id_tbl.LAST LOOP
       BEGIN
         l_adp_record_status_tbl(i) := 'S';
         --dbms_output.put_line('For Org: '||p_relationship_yn||'*'||l_org_id_tbl(i)||'*'|| l_adoption_type_tbl(i));
         if p_adoption_yn = 'Y' THEN
            l_dummy := '?';
            l_rowfound := FALSE;

-- Check adoption row already exists. Ususally this should not happen but will be if an org switches to
-- Auto Adoption

            Open l_adoptions_csr (p_global_article_version_id, l_org_id_tbl(i));
            FETCH l_adoptions_csr INTO l_dummy;
            l_rowfound := l_adoptions_csr%FOUND;
            CLOSE l_adoptions_csr;

            if (l_rowfound) THEN
               l_adp_record_status_tbl(i) := 'E';
               Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_ADP_ALREADY_EXIST',
                        p_token1       => 'ORG_ID',
                        p_token1_value => l_org_id_tbl(i));
               l_return_status := G_RET_STS_ERROR;
            else
                -- ibyon 12/16/03 bug 3302792
                -- Add duplicate check for adopted article
                -- If article title is found in the local org then
                -- adoption type becomes 'AVAILABLE'
              IF l_adoption_type_tbl(i) = 'ADOPTED' THEN

                 OPEN l_unq_local_title_csr ( l_org_id_tbl(i),
                                              p_global_article_id,
                                              l_global_org_id);
                   FETCH l_unq_local_title_csr INTO l_local_article_title;
                   l_rowfound := l_unq_local_title_csr%FOUND;
                 CLOSE l_unq_local_title_csr;

                 IF (l_rowfound) THEN
                       IF (l_debug = 'Y') THEN
                          okc_debug.log('200: AUTO ADOPTION cannot be done because duplicate article found in the org '|| l_org_id_tbl(i), 2);
                       END IF;
                    l_adoption_type_tbl(i) := 'AVAILABLE';
                    l_adoption_status_tbl(i) := NULL;
                 ELSE
                    l_adoption_status_tbl(i) := 'APPROVED';
                 END IF;
              ELSE
                l_adoption_status_tbl(i) := NULL;
              END IF;

              l_adp_record_status_tbl(i) := 'S';

            end if; -- end of if l_rowfound
          end if; -- end of if p_adoption_yn =Y
          if p_relationship_yn = 'Y' and
             nvl(l_adp_record_status_tbl(i),'S') = 'S' and
             l_adoption_type_tbl(i) = 'ADOPTED' Then
             OPEN l_relationship_csr (l_org_id_tbl(i), p_global_article_id, l_global_org_id);
             LOOP
               FETCH l_relationship_csr BULK COLLECT INTO l_article_number_tbl,
                                                       l_source_article_id_tbl,
                                                       l_target_article_id_tbl,
                                                       l_relationship_type_tbl
               LIMIT p_fetchsize;
               EXIT WHEN l_article_number_tbl.COUNT = 0;

               j := 0;
               FORALL j IN l_article_number_tbl.FIRST..l_article_number_tbl.LAST
                  INSERT INTO OKC_ARTICLE_RELATNS_ALL
                      (
                      SOURCE_ARTICLE_ID,
                      TARGET_ARTICLE_ID,
                      ORG_ID,
                      RELATIONSHIP_TYPE,
                      OBJECT_VERSION_NUMBER,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      LAST_UPDATE_DATE
                      )
                    VALUES
                      (
                      l_source_article_id_tbl(j),
                      l_target_article_id_tbl(j),
                      l_org_id_tbl(i),
                      l_relationship_type_tbl(j),
                      1.0,
                      l_User_Id,
                      sysdate,
                      l_User_Id,
                      l_login_Id,
                      sysdate
                     );

-- Revert the target and source article ids.

               j := 0;
               FORALL j IN l_article_number_tbl.FIRST..l_article_number_tbl.LAST
                  INSERT INTO OKC_ARTICLE_RELATNS_ALL
                     (
                      SOURCE_ARTICLE_ID,
                      TARGET_ARTICLE_ID,
                      ORG_ID,
                      RELATIONSHIP_TYPE,
                      OBJECT_VERSION_NUMBER,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      LAST_UPDATE_DATE
                     )
                  VALUES
                     (
                      l_target_article_id_tbl(j),
                      l_source_article_id_tbl(j),
                      l_org_id_tbl(i),
                      l_relationship_type_tbl(j),
                      1.0,
                      l_User_Id,
                      sysdate,
                      l_User_Id,
                      l_Login_Id,
                      sysdate);
               l_target_article_id_tbl.DELETE;
               l_source_article_id_tbl.DELETE;
               l_relationship_type_tbl.DELETE;
               EXIT WHEN l_relationship_csr%NOTFOUND;
             END LOOP; -- relationship csr fetch
             CLOSE l_relationship_csr;
          end if;   -- relationship_yn = Y
        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Auto_Adoption because of EXCEPTION: '||sqlerrm, 2);
             END IF;
             IF l_org_info_csr%ISOPEN THEN
                CLOSE l_org_info_csr;
             END IF;
             IF l_relationship_csr%ISOPEN THEN
                CLOSE l_relationship_csr;
             END IF;
             IF l_unq_local_title_csr%ISOPEN THEN
                CLOSE l_unq_local_title_csr;
             END IF;
             l_adp_record_status_tbl(i) := 'U';
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             x_return_status := G_RET_STS_UNEXP_ERROR ;
             exit;
        END;
        END LOOP; -- for i in l_org_id_tbl..
        i := 0;
        IF l_return_status = FND_API.G_RET_STS_SUCCESS Then
          IF p_adoption_yn = 'Y'  AND l_org_id_tbl.COUNT > 0 Then
            FORALL i in l_org_id_tbl.FIRST .. l_org_id_tbl.LAST
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
                p_global_article_version_id,
                l_adoption_type_tbl(i),
                l_org_id_tbl(i),
                l_adoption_status_tbl(i),
                NULL,
                1.0,
                l_User_Id,
                sysdate,
                l_User_Id,
                l_Login_Id,
                sysdate
             FROM DUAL
             WHERE l_adp_record_status_tbl(i) = 'S';

             l_org_id_tbl.DELETE;
             l_adoption_type_tbl.DELETE;
             l_notifier_tbl.DELETE;
             l_adoption_status_tbl.DELETE;
             l_adp_record_status_tbl.DELETE;
           END IF; -- p_adoption_yn = Y
          END IF; -- l_return_status = S
          EXIT WHEN l_org_info_csr%NOTFOUND;
  END LOOP; -- main cursor loop
  CLOSE l_org_info_csr;
  if l_return_status = 'E' THEN
        x_return_status := 'W';
  else
      x_return_status := l_return_status;
  end if;
  IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      return;
  END IF;
    -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;
    -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,p_encoded=> 'F',  p_data => x_msg_data );

  IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving check adoption', 2);
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Auto_Adoption: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Auto_Adoption: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      IF l_org_info_csr%ISOPEN THEN
         CLOSE l_org_info_csr;
      END IF;
      IF l_relationship_csr%ISOPEN THEN
         CLOSE l_relationship_csr;
      END IF;
      IF l_unq_local_title_csr%ISOPEN THEN
         CLOSE l_unq_local_title_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Auto_Adoption because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_org_info_csr%ISOPEN THEN
         CLOSE l_org_info_csr;
      END IF;
      IF l_relationship_csr%ISOPEN THEN
         CLOSE l_relationship_csr;
      END IF;
      IF l_unq_local_title_csr%ISOPEN THEN
         CLOSE l_unq_local_title_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
  END AUTO_ADOPT_ARTICLES;

-- The following procedure is a concurrent job that will be run if a new org is added and hence there is a
-- need to create autoadoption rows for the currently active global article versions

  PROCEDURE AUTO_ADOPT_NEWORG
           (errbuf           OUT NOCOPY VARCHAR2,
            retcode          OUT NOCOPY VARCHAR2,
            p_org_id         IN NUMBER    ,
            p_fetchsize      IN NUMBER
           ) IS

    l_api_name                    CONSTANT VARCHAR2(30) := 'g_auto_adoption_neworg';
    l_dummy                       VARCHAR2(1) := '?';
    l_row_notfound                BOOLEAN := FALSE;
    l_local_article_version_id    NUMBER;
    l_count_ver_adopted           NUMBER;
    l_count_ver_available         NUMBER;

    i    NUMBER := 0;
    j    NUMBER := 0;
    l_article_id                  NUMBER;
    l_return_status               VARCHAR2(1);
    l_adoption_type               OKC_ARTICLE_ADOPTIONS.ADOPTION_TYPE%TYPE;
    l_prev_adoption_type          OKC_ARTICLE_ADOPTIONS.ADOPTION_TYPE%TYPE;
    l_adoption_status             OKC_ARTICLE_ADOPTIONS.ADOPTION_STATUS%TYPE;
    l_adoption_type_meaning       FND_LOOKUPS.MEANING%TYPE;
    l_organization_name           HR_ORGANIZATION_UNITS.NAME%TYPE;

    l_prev_article_id         OKC_ARTICLES_ALL.ARTICLE_ID%TYPE;
    l_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    TYPE l_adoption_type_list  IS TABLE OF FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_adoption_status_list  IS TABLE OF OKC_ARTICLE_ADOPTIONS.ADOPTION_STATUS%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_adp_record_status_list  IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE l_article_version_id_list IS TABLE OF OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_article_id_list IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_article_title_list IS TABLE OF OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_orig_system_ref_code_list IS TABLE of OKC_ARTICLES_ALL.ORIG_SYSTEM_REFERENCE_CODE%TYPE INDEX BY BINARY_INTEGER ;

    l_adoption_type_tbl        l_adoption_type_list;
    l_adoption_status_tbl      l_adoption_status_list;
    l_adp_record_status_tbl    l_adp_record_status_list;
    l_article_version_id_tbl   l_article_version_id_list;
    l_article_id_tbl           l_article_id_list;
    l_article_title_tbl        l_article_title_list;
    l_orig_sys_ref_code_tbl    l_orig_system_ref_code_list;


   CURSOR l_org_info_csr (cp_org_id IN NUMBER, cp_global_org_id IN NUMBER) IS
     SELECT decode(nvl(ORG_INFORMATION1,'N'),'N','AVAILABLE','Y','ADOPTED') ADOPTION_TYPE, U.NAME
       FROM HR_ORGANIZATION_INFORMATION I,
            HR_ORGANIZATION_UNITS U
      WHERE I.ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
        AND I.ORGANIZATION_ID = cp_org_id
        AND I.ORGANIZATION_ID = U.ORGANIZATION_ID
        AND I.ORGANIZATION_ID <> cp_global_org_id;

-- Modified Cursor Where clause , Bug 3315511
   CURSOR l_adoptions_csr (cp_global_org_id IN NUMBER, cp_local_org_id IN NUMBER) IS
     SELECT article_version_id , article_title,
            art.article_id, art.orig_system_reference_code
       FROM OKC_ARTICLE_VERSIONS VER, OKC_ARTICLES_ALL ART
     WHERE global_yn = 'Y'
      AND  org_id = cp_global_org_id
      AND VER.article_id = ART.article_id
      AND article_status in ('APPROVED', 'ON_HOLD')
      AND nvl(end_date, sysdate) >= trunc(sysdate)
      AND NOT EXISTS
        (SELECT 1 FROM OKC_ARTICLE_ADOPTIONS
          WHERE global_article_version_id = VER.article_version_id
           AND  local_org_id = cp_local_org_id)
      UNION ALL
      SELECT article_version_id , article_title, article_id, orig_system_reference_code
        FROM
            (
             SELECT article_version_id , article_title , art.article_id ,
                    start_date , end_date,
                    global_yn , org_id , article_status,
                    art.orig_system_reference_code
             FROM   OKC_ARTICLE_VERSIONS VER, OKC_ARTICLES_ALL ART
             WHERE  VER.article_id = ART.article_id
             AND    global_yn = 'Y'
             AND    org_id = cp_global_org_id
             AND    start_date = ( SELECT max(start_date)
                                   FROM   OKC_ARTICLE_VERSIONS VER1,OKC_ARTICLES_ALL ART1
                                   WHERE  VER1.ARTICLE_ID = ART1.ARTICLE_ID
                                   AND    VER1.ARTICLE_ID = VER.ARTICLE_ID )
             )
        WHERE
             article_status = 'APPROVED'
        AND  end_date < trunc(sysdate)
        AND  NOT EXISTS
             (SELECT 1 FROM OKC_ARTICLE_ADOPTIONS
              WHERE global_article_version_id = article_version_id
              AND   local_org_id = cp_local_org_id);

   CURSOR l_dup_title_csr (
          cp_local_org_id IN NUMBER,
          cp_article_title IN VARCHAR2) IS
     SELECT '1'
       FROM OKC_ARTICLES_ALL
     WHERE org_id = cp_local_org_id
      AND article_title = cp_article_title
      AND standard_yn = 'Y';

   CURSOR l_adoption_type_meaning_csr (
          cp_adoption_type IN VARCHAR2) IS
     SELECT meaning
      FROM  FND_LOOKUPS
     WHERE  lookup_type = 'OKC_ARTICLE_ADOPTION_TYPE'
       AND  lookup_code = cp_adoption_type;


    l_user_id NUMBER := FND_GLOBAL.USER_ID;
    l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered auto_adoption for new org.', 2);
    END IF;

    FND_MSG_PUB.initialize;
    retcode := 0;
    l_count_ver_adopted         := 0;
    l_count_ver_available       := 0;
-- The org being passed cannot be a global org.

    l_GLOBAL_ORG_ID := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    if p_org_id = l_GLOBAL_ORG_ID or p_org_id = -99 Then
      FND_MESSAGE.SET_NAME(G_APP_NAME, 'OKC_ADOPT_INVALID_ORG');
      FND_MSG_PUB.add;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(1, p_encoded =>FND_API.G_FALSE ));
      retcode := 2;
      return;
    end if;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

-- First determine whether the orgid passed is a valid org defined in HR Org definitions.

    OPEN l_org_info_csr (p_org_id,l_global_org_id);
    FETCH l_org_info_csr INTO l_adoption_type, l_organization_name;
    l_row_notfound := l_org_info_csr%NOTFOUND;
    CLOSE l_org_info_csr ;

    IF (l_row_notfound) THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('200: Org row not found', 2);
      END IF;
      FND_MESSAGE.SET_NAME(G_APP_NAME, 'OKC_ADOPT_INVALID_ORG');
      FND_MSG_PUB.add;
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(1, p_encoded =>FND_API.G_FALSE ));
      retcode := 2;
      return;
    END IF;

--  If adoption type for the org is subscribing to autoadoption, all rows will be ADOPTED and APPROVED. However, if
--  any duplicates were found, it will be AVAILABLE for Adoption.

    if l_adoption_type = 'ADOPTED' Then
       l_adoption_status := 'APPROVED';
    else
       l_adoption_status := NULL;
    end if;
    i := 0;
    l_prev_article_id := -99;
    OPEN l_adoptions_csr (l_global_org_id , p_org_id ) ;
    LOOP
       FETCH l_adoptions_csr BULK COLLECT INTO
       l_article_version_id_tbl, l_article_title_tbl,
       l_article_id_tbl, l_orig_sys_ref_code_tbl LIMIT p_fetchsize;
       i := 0;
       EXIT WHEN l_article_version_id_tbl.COUNT = 0;
       IF l_adoption_type <> 'ADOPTED' Then

          --if article is migrated then adoption_type becomes 'ADOPTED'
          --Otherwise, it is 'AVAILABLE'
         FOR i IN l_article_version_id_tbl.FIRST..l_article_version_id_tbl.LAST LOOP

          l_adp_record_status_tbl(i) := 'S';
          if instr(nvl(l_orig_sys_ref_code_tbl(i),'*'),'OKCMIG')=1 then
           l_adoption_type_tbl(i)  := 'ADOPTED';
           l_adoption_status_tbl(i) := 'APPROVED';
           l_count_ver_adopted := l_count_ver_adopted +1;
          ELSE
           l_adoption_type_tbl(i)  := 'AVAILABLE';
           l_adoption_status_tbl(i) := NULL;
           l_count_ver_available := l_count_ver_available +1;
          end if;

          l_prev_article_id := l_article_id_tbl(i);
          l_prev_adoption_type := l_adoption_type_tbl(i);

         END LOOP;
/**
          BEGIN
            savepoint adoption_dml;
            FORALL i IN l_article_version_id_tbl.FIRST..l_article_version_id_tbl.LAST
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
             VALUES
                (
                l_article_version_id_tbl(i),
                'AVAILABLE',
                p_org_id,
                NULL,
                NULL,
                1.0,
                l_User_Id,
                sysdate,
                l_User_Id,
                l_Login_Id,
                sysdate );
         EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Leaving Auto_Adoption because of EXCEPTION: '||sqlerrm, 2);
             END IF;
             l_adp_record_status_tbl(i) := 'U';
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm);
             errbuf  := substr(sqlerrm,1,200);
             rollback to adoption_dml;
         END;
**/
       else -- Org has subscribed to autoadoption. Autoadopted in all cases unless duplicates which will make it avialable for adoption
         BEGIN
         FOR i IN l_article_version_id_tbl.FIRST..l_article_version_id_tbl.LAST LOOP
          BEGIN
            l_adp_record_status_tbl(i) := 'S';

-- Perform dup. checks only if article changes - not for all versions.
--            dbms_output.put_line('PREV:NEW'||l_prev_article_id||'*'|| l_article_id_tbl(i));
            if l_prev_article_id <> l_article_id_tbl(i) Then
              j := j+1;
              --dbms_output.put_line('DUP:' );
              --but if same article_title exists,
              --then do not adopt it
              OPEN l_dup_title_csr (p_org_id,l_article_title_tbl(i));
              FETCH l_dup_title_csr INTO l_dummy;
              l_row_notfound := l_dup_title_csr%NOTFOUND;
              CLOSE l_dup_title_csr ;

              if l_row_notfound then
                l_adoption_type_tbl(i) := 'ADOPTED';
              else
                l_adoption_type_tbl(i) := 'AVAILABLE';
              end if;

            else
              l_adoption_type_tbl(i) := l_prev_adoption_type;
            end if;
            --dbms_output.put_line('PREVADP:NEWADP'||l_prev_adoption_type||'*'|| l_adoption_type_tbl(i));
          l_prev_article_id := l_article_id_tbl(i);
          l_prev_adoption_type := l_adoption_type_tbl(i);

          IF l_adoption_type_tbl(i) = 'ADOPTED' THEN
             l_adoption_status_tbl(i) := 'APPROVED';
             l_count_ver_adopted := l_count_ver_adopted +1;
          ELSE
             l_adoption_status_tbl(i) := NULL;
             l_count_ver_available := l_count_ver_available +1;
          END IF;


         EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Auto_Adoption New Org EXCEPTION: ' ||sqlerrm, 2);
             END IF;
             IF l_dup_title_csr%ISOPEN THEN
                CLOSE l_dup_title_csr;
             END IF;
             IF l_adoptions_csr%ISOPEN THEN
                CLOSE l_adoptions_csr;
             END IF;
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm);
             retcode := 2;
             errbuf  := substr(sqlerrm,1,200);
             exit; -- Fatal error must exit....
          END;
        END LOOP;
        IF l_return_status <>  G_RET_STS_SUCCESS THEN
           return;
        END IF;
     END;
   END IF;
-- Transaction will be bulk rolledback for a batch if error observed. It's a pity we cannot save exceptions due to
-- backward compatibility with 8.1.7.4

        SAVEPOINT adoption_dml;
        BEGIN
         FORALL i IN l_article_version_id_tbl.FIRST..l_article_version_id_tbl.LAST
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
                l_article_version_id_tbl(i),
                l_adoption_type_tbl(i),
                p_org_id,
                l_adoption_status_tbl(i),
                NULL,
                1.0,
                l_User_Id,
                sysdate,
                l_User_Id,
                l_Login_Id,
                sysdate
             FROM DUAL
             WHERE l_adp_record_status_tbl(i) = 'S';

-- Insert all relationships for the global articles (will be applicable only if both source and targets are adopted as is)

           INSERT INTO OKC_ARTICLE_RELATNS_ALL
              (
              SOURCE_ARTICLE_ID,
              TARGET_ARTICLE_ID,
              ORG_ID,
              RELATIONSHIP_TYPE,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE
              )
           SELECT SOURCE_ARTICLE_ID,
              TARGET_ARTICLE_ID,
              p_org_id,
              RELATIONSHIP_TYPE,
              1.0,
              l_User_Id,
              sysdate,
              l_User_Id,
              l_Login_Id,
              sysdate
           FROM OKC_ARTICLE_RELATNS_ALL R
           WHERE R.ORG_ID = l_global_org_id
            AND EXISTS
           (SELECT 1 FROM OKC_ARTICLE_VERSIONS V1, OKC_ARTICLE_ADOPTIONS A1
            WHERE V1.ARTICLE_ID = R.TARGET_ARTICLE_ID
              AND A1.GLOBAL_ARTICLE_VERSION_ID = V1.ARTICLE_VERSION_ID
              AND V1.GLOBAL_YN = 'Y'
              AND A1.ADOPTION_STATUS = 'APPROVED'
              AND A1.ADOPTION_TYPE = 'ADOPTED'
              AND A1.LOCAL_ORG_ID = p_org_id
             )
            AND EXISTS
           (SELECT 1 FROM OKC_ARTICLE_VERSIONS V2, OKC_ARTICLE_ADOPTIONS A2
            WHERE V2.ARTICLE_ID = R.SOURCE_ARTICLE_ID
              AND A2.GLOBAL_ARTICLE_VERSION_ID = V2.ARTICLE_VERSION_ID
              AND V2.GLOBAL_YN = 'Y'
              AND A2.ADOPTION_STATUS = 'APPROVED'
              AND A2.ADOPTION_TYPE = 'ADOPTED'
              AND A2.LOCAL_ORG_ID = p_org_id
             )
          AND NOT EXISTS
            (
             SELECT '1'
             FROM OKC_ARTICLE_RELATNS_ALL R1
             WHERE R1.SOURCE_ARTICLE_ID = R.SOURCE_ARTICLE_ID AND
                   R1.TARGET_ARTICLE_ID = R.TARGET_ARTICLE_ID AND
                   R1.RELATIONSHIP_TYPE = R.RELATIONSHIP_TYPE AND
                   R1.ORG_ID = p_org_id
            );

        EXCEPTION
           WHEN OTHERS THEN
             IF (l_debug = 'Y') THEN
               okc_debug.log('500: Auto_Adoption New Org EXCEPTION: ' ||sqlerrm, 2);
             END IF;
             l_adp_record_status_tbl(i) := 'U';
             l_return_status := G_RET_STS_UNEXP_ERROR ;
             FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm);
             errbuf  := substr(sqlerrm,1,200);
             rollback to adoption_dml;
        END;
--     END;
--    END IF;

      l_adoption_type_tbl.DELETE;
      l_adoption_status_tbl.DELETE;
      l_adp_record_status_tbl.DELETE;
      l_article_version_id_tbl.DELETE;
      COMMIT;
      EXIT WHEN l_adoptions_csr%NOTFOUND;
    END LOOP;
    COMMIT;

    --Get adoption type meaning
    OPEN l_adoption_type_meaning_csr (l_adoption_type);
    FETCH l_adoption_type_meaning_csr into l_adoption_type_meaning;
    CLOSE l_adoption_type_meaning_csr;

    -- Write report into OUTPUT
    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_ADP_NEWORG_OUTPUT',
                        p_token1       => 'ADOPTION_TYPE',
                        p_token1_value => l_adoption_type_meaning,
                        p_token2       => 'TOTAL_VER_ADOPTED',
                        p_token2_value => l_count_ver_adopted,
                        p_token3       => 'TOTAL_VER_AVAILABLE',
                        p_token3_value => l_count_ver_available,
                        p_token4       => 'ORG_NAME',
                        p_token4_value => l_organization_name);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MSG_PUB.Get(1,p_encoded=>FND_API.G_FALSE));

    okc_debug.log('500: Leaving Auto_Adoption New Org' );
    EXCEPTION
       WHEN OTHERS THEN
          IF (l_debug = 'Y') THEN
            okc_debug.log('500: Leaving Auto_Adoption New Org because of EXCEPTION: '||sqlerrm, 2);
          END IF;
          l_return_status := G_RET_STS_UNEXP_ERROR ;
          IF l_adoptions_csr%ISOPEN Then
             close l_adoptions_csr;
          END IF;
          FND_FILE.PUT_LINE(FND_FILE.LOG,sqlerrm);
          errbuf  := substr(sqlerrm,1,200);
          retcode := 2;
  END AUTO_ADOPT_NEWORG;

END OKC_ADOPTIONS_GRP;

/
