--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLE_STATUS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLE_STATUS_CHANGE_PVT" AS
/* $Header: OKCVARTSTSB.pls 120.2.12010000.4 2011/07/04 11:58:16 serukull ship $ */

    l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_ARTICLE_STATUS_CHANGE_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
  G_MISS_NUM                   CONSTANT   NUMBER      := FND_API.G_MISS_NUM;
  G_MISS_CHAR                  CONSTANT   VARCHAR2(1) := FND_API.G_MISS_CHAR;
  G_MISS_DATE                  CONSTANT   DATE        := FND_API.G_MISS_DATE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

  G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
  G_GLOBAL_ORG_ID NUMBER := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
  -- MOAC
  G_CURRENT_ORG_ID             NUMBER ;
  /*
  G_CURRENT_ORG_ID             NUMBER := -99;
-- One Time fetch and cache the current Org.
  CURSOR CUR_ORG_CSR IS
        SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                                                   SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
        FROM DUAL;
   */

  ---------------------------------------
  -- PROCEDURE update_adoption_ifexists  --
  ---------------------------------------
-- Local Procedure to update article adoptions...
-- This will lock and update if exists
-- This is more applicable in this case than Simple API which will throw an
-- error if row is not found
-- Parameters: org_id, article_version_id and article_status (APPROVED,REJECTED
-- ,PENDING_APPROVAL)

  PROCEDURE update_adoption_ifexists (p_article_version_id IN NUMBER,
                                 p_org_id   IN NUMBER,
                                 p_article_status IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR l_article_adoption_csr(cp_article_version_id IN NUMBER,
                                  cp_local_org_id IN NUMBER) is
     SELECT rowid from OKC_ARTICLE_ADOPTIONS
       WHERE LOCAL_ARTICLE_VERSION_ID         = cp_article_version_id
            AND LOCAL_ORG_ID = cp_local_org_id
            AND ADOPTION_TYPE = 'LOCALIZED'
     FOR UPDATE OF object_version_number ;

    l_rowid                       ROWID;

   BEGIN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Entering update adoption if exists ', 2);
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN l_article_adoption_csr(p_article_version_id,
                                  p_org_id) ;
      FETCH l_article_adoption_csr INTO l_rowid;
      IF l_article_adoption_csr%FOUND THEN
         UPDATE OKC_ARTICLE_ADOPTIONS
           SET ADOPTION_STATUS = p_article_status,
             OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
             LAST_UPDATED_BY            = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN          = FND_GLOBAL.LOGIN_ID,
             LAST_UPDATE_DATE           = SYSDATE
         WHERE CURRENT OF l_article_adoption_csr;
      END IF;
      CLOSE l_article_adoption_csr;
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving update adoption if exists successfully', 2);
      END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving update adoption if exists because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_article_adoption_csr%ISOPEN THEN
         CLOSE l_article_adoption_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

  END update_adoption_ifexists;
  ---------------------------------------
  -- PROCEDURE update_prev_vers_enddate
  ---------------------------------------
-- Local Procedure to update end date of previous article version on approval
-- Parameters: article_id, article_version_id and end_date

  PROCEDURE update_prev_vers_enddate (p_article_version_id IN NUMBER,
                                 p_article_id IN NUMBER,
                                 p_end_date   IN DATE,
                                 p_current_org_id IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR l_earlier_version_csr(p_article_id IN NUMBER, p_article_version_id IN NUMBER) IS
-- 8.1.7.4 compatibility
select
   av.global_yn,
   av.article_status,
   av.adoption_type,
   av.start_date,
   av.end_date,
   av.article_version_number,
   av.article_version_id
from
   okc_article_versions av
where
   av.article_id = p_article_id
and
   av.start_date =   (select
                        max(av1.start_date)
                     from
                        okc_article_versions av1
                     where
                        av1.article_id = av.article_id
                     and
                        av1.end_date is null
                     and
                        av1.article_version_id <> p_article_version_id
                     );
/*
     SELECT S.GLOBAL_YN,
            S.ARTICLE_STATUS,
            S.ADOPTION_TYPE,
            S.START_DATE,
            S.END_DATE,
            S.MAX_START_DATE,
            S.ARTICLE_VERSION_NUMBER,
            S.ARTICLE_VERSION_ID
      FROM (
         SELECT
           A.GLOBAL_YN,
           A.ARTICLE_STATUS,
           A.ADOPTION_TYPE,
           A.START_DATE, A.END_DATE,
           MAX(A.START_DATE) OVER (PARTITION BY A.ARTICLE_ID) AS MAX_START_DATE,
           A.ARTICLE_VERSION_NUMBER,
           A.ARTICLE_VERSION_ID
         FROM OKC_ARTICLE_VERSIONS A
         WHERE A.ARTICLE_ID = p_article_id
          AND A.END_DATE IS NULL
          AND ARTICLE_VERSION_ID <> p_article_version_id
           ) S
     WHERE S.START_DATE = S.MAX_START_DATE;
*/
    l_earlier_version_id NUMBER := NULL;
    l_article_id NUMBER := NULL;
    l_article_status VARCHAR2(30) := NULL;
    l_new_article_status VARCHAR2(30) := NULL;
    l_earlier_version_rec  l_earlier_version_csr%ROWTYPE;


   BEGIN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Entering update prev vers end date  ', 2);
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN  l_earlier_version_csr(p_article_id, p_article_version_id);
      FETCH l_earlier_version_csr  INTO l_earlier_version_rec ;
      IF l_earlier_version_csr%FOUND THEN
         OKC_ARTICLE_VERSIONS_PVT.Update_Row(
         p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
         x_return_status              => x_return_status,
         p_article_version_id         => l_earlier_version_rec.article_version_id,
         p_article_id                 => NULL,
         p_article_version_number     => NULL,
         p_article_text               => NULL,
         p_provision_yn               => NULL,
         p_insert_by_reference        => NULL,
         p_lock_text                  => NULL,
         p_global_yn                  => NULL,
         p_article_language           => NULL,
         p_article_status             => NULL,
         p_sav_release                => NULL,
         p_start_date                 => NULL,
         p_end_date                   => p_end_date,
         p_std_article_version_id     => NULL,
         p_display_name               => NULL,
         p_translated_yn              => NULL,
         p_article_description        => NULL,
         p_date_approved              => NULL,
         p_default_section            => NULL,
         p_reference_source           => NULL,
         p_reference_text           => NULL,
         p_orig_system_reference_code => NULL,
         p_orig_system_reference_id1  => NULL,
         p_orig_system_reference_id2  => NULL,
         p_additional_instructions    => NULL,
         p_variation_description      => NULL,
         p_current_org_id             => p_current_org_id,
         p_attribute_category         => NULL,
         p_attribute1                 => NULL,
         p_attribute2                 => NULL,
         p_attribute3                 => NULL,
         p_attribute4                 => NULL,
         p_attribute5                 => NULL,
         p_attribute6                 => NULL,
         p_attribute7                 => NULL,
         p_attribute8                 => NULL,
         p_attribute9                 => NULL,
         p_attribute10                => NULL,
         p_attribute11                => NULL,
         p_attribute12                => NULL,
         p_attribute13                => NULL,
         p_attribute14                => NULL,
         p_attribute15                => NULL,
         p_object_version_number      => NULL,
         p_edited_in_word             => NULL,
         p_article_text_in_word       => NULL,
         x_article_status             => l_article_status,
         x_article_id                 => l_article_id,
         x_earlier_version_id         => l_earlier_version_id
       );
      END IF;
      CLOSE  l_earlier_version_csr;
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving update prev end date successfully', 2);
      END IF;


  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving update prev vers end date because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_earlier_version_csr%ISOPEN THEN
         CLOSE l_earlier_version_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

  END update_prev_vers_enddate;
  ---------------------------------------
  -- PROCEDURE hold_unhold  --
  ---------------------------------------
-- Procedure to set an article version status from hold to unhold (Approved)
-- and vice-versa.
-- Parameters: article_version_id , p_hold_yn => Y means Hold and N means Unhold
-- (Approved).
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.

  PROCEDURE hold_unhold(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level             IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hold_yn                      IN VARCHAR2 := 'Y',
    p_article_version_id    IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'hold_unhold';
    l_rownotfound    BOOLEAN := FALSE;
    l_earlier_version_id NUMBER := NULL;
    l_article_id NUMBER := NULL;
    l_article_status VARCHAR2(30) := NULL;
    l_new_article_status VARCHAR2(30) := NULL;

    CURSOR l_article_version_csr (cp_article_version_id IN NUMBER) IS
      SELECT org_id, article_status, global_yn, art.article_id
        FROM okc_articles_all art, okc_article_versions ver
       WHERE ver.article_id = art.article_id
        AND ver.article_version_id = cp_article_version_id
        AND art.standard_yn = 'Y'
      FOR UPDATE OF start_date;
    l_article_version_rec     l_article_version_csr%ROWTYPE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered hold_unhold with '||p_hold_yn||'*'||p_article_version_id, 2);
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    -- MOAC
    G_CURRENT_ORG_ID := mo_global.get_current_org_id();
    /*
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
    */
    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;
   -- MOAC
   if G_CURRENT_ORG_ID IS NULL Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('130: - attribute G_CURRENT_ORG_ID is invalid', 2);
      END IF;
      Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_NULL_ORG_ID');
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   end if;

    OPEN l_article_version_csr (p_article_version_id);
    FETCH l_article_version_csr INTO l_article_version_rec;
    l_rownotfound := l_article_version_csr%NOTFOUND;
    IF l_rownotfound THEN
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_VERSION_ID');
        x_return_status :=  G_RET_STS_ERROR;
    ELSIF p_hold_yn = 'Y' THEN
       IF l_article_version_rec.article_status <> 'APPROVED' Then
          OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_ART_NOT_APPROVD');
          x_return_status :=  G_RET_STS_ERROR;
       ELSIF l_article_version_rec.org_id <> G_CURRENT_ORG_ID Then
          OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_ART_DIFF_ORG');
          x_return_status :=  G_RET_STS_ERROR;
       ELSE
          l_new_article_status := 'ON_HOLD';
       END IF;
    ELSE
       IF l_article_version_rec.article_status <> 'ON_HOLD' Then
          OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_ART_NOT_HOLD');
          x_return_status :=  G_RET_STS_ERROR;
       ELSIF l_article_version_rec.org_id <> G_CURRENT_ORG_ID Then
          OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_ART_DIFF_ORG');
          x_return_status :=  G_RET_STS_ERROR;
       ELSE
         l_new_article_status := 'APPROVED';
       END IF;
    END IF;

    IF x_return_status = G_RET_STS_SUCCESS THEN

-- start update adoption table if work with global article (muteshev)
/* commented out because of bug#3251484
    IF (l_debug = 'Y') THEN
       okc_debug.log('120: Starting Update Adoption Statuses if Global Article ', 2);
    END IF;
      begin
       if l_article_version_rec.global_yn = 'Y' then
            update okc_article_adoptions
            set adoption_status     = l_new_article_status,
            OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,
            LAST_UPDATE_DATE        = SYSDATE
            where global_article_version_id = p_article_version_id
            and adoption_type = 'ADOPTED';
         if l_new_article_status = 'ON_HOLD' then
            update okc_article_adoptions
            set adoption_status     = l_new_article_status,
            OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,
            LAST_UPDATE_DATE        = SYSDATE
            where global_article_version_id = p_article_version_id
            and adoption_type = 'AVAILABLE';
         elsif l_new_article_status = 'APPROVED' then
            update okc_article_adoptions
            set adoption_status     = null,
            OBJECT_VERSION_NUMBER   = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATED_BY         = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN       = FND_GLOBAL.LOGIN_ID,
            LAST_UPDATE_DATE        = SYSDATE
            where global_article_version_id = p_article_version_id
            and adoption_type = 'AVAILABLE';
         end if;
       end if;
      exception
      when others then
         x_return_status := G_RET_STS_UNEXP_ERROR;
      end;

    IF (l_debug = 'Y') THEN
       okc_debug.log('140: Finishing Update Adoption Statuses if Global Article ', 2);
    END IF;
*/
-- end update adoption table if work with global article (muteshev)

      IF x_return_status = G_RET_STS_SUCCESS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('160: Starting Update Article Status ', 2);
    END IF;

         UPDATE OKC_ARTICLE_VERSIONS
            SET ARTICLE_STATUS = l_new_article_status,
            OBJECT_VERSION_NUMBER      = OBJECT_VERSION_NUMBER + 1,
            LAST_UPDATED_BY            = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN          = FND_GLOBAL.LOGIN_ID,
            LAST_UPDATE_DATE           = SYSDATE
            WHERE current of l_article_version_csr;
      end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('180: Finishing Update Article Status ', 2);
    END IF;

    END IF;
    CLOSE l_article_version_csr;
    --------------------------------------------
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    --------------------------------------------
    COMMIT;
    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving Hold Unhold successfully ', 2);
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving Hold_Unhold: OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_encoded=> 'F', p_data => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('400: Leaving Hold_Unhold: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,p_encoded=> 'F',  p_data => x_msg_data );

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving Hold_Unhold because of EXCEPTION: '||sqlerrm, 2);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,p_encoded=> 'F',  p_data => x_msg_data );

  END hold_unhold;

  ---------------------------------------
  -- PROCEDURE pending-approval  --
  ---------------------------------------
-- Procedure to set an article version status from draft to pending approval
-- Parameters: article_version_id , p_adopt_as_is_yn => Y means Adoption at a
-- Local Org as is and N means Local version
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.



  PROCEDURE pending_approval(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_current_org_id               IN NUMBER,
    p_adopt_as_is_yn               IN VARCHAR2,
    p_article_version_id           IN NUMBER,
    p_article_title                IN VARCHAR,
    p_article_version_number       IN VARCHAR
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'pending_approval';
    l_global_article_version_id   NUMBER := NULL;
    l_local_article_version_id    NUMBER;
    l_rownotfound                 BOOLEAN := FALSE;
    l_tmp_return_status           VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_delete_adoption             VARCHAR2(1) := 'T';
    l_rowid                       ROWID;
    l_earlier_version_id NUMBER := NULL;
    l_article_id NUMBER := NULL;
    l_article_status VARCHAR2(30) := NULL;
    l_new_article_status VARCHAR2(30) := NULL;
    l_earlier_local_version_id    NUMBER := 0; -- not used just for check_adoption_details
    l_dummy_num                   NUMBER := 0;
    l_dummy_char                  VARCHAR2(1) := '?';

    TYPE l_variable_name      IS TABLE OF  OKC_BUS_VARIABLES_TL.variable_name%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_disabled_yn        IS TABLE OF  OKC_BUS_VARIABLES_B.disabled_yn%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_value_set_id       IS TABLE OF OKC_BUS_VARIABLES_B.value_set_id%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_variable_type      IS TABLE OF OKC_BUS_VARIABLES_B.variable_type%TYPE INDEX BY BINARY_INTEGER ;
    -- Below Added for bug 5958643
    TYPE l_variable_source    IS TABLE OF OKC_BUS_VARIABLES_B.variable_source%TYPE INDEX BY BINARY_INTEGER ;
    TYPE l_procedure_name     IS TABLE OF OKC_BUS_VARIABLES_B.procedure_name%TYPE INDEX BY BINARY_INTEGER ;
    -- Above Added for bug 5958643

    -- MRV Project Changes Start
    TYPE l_mrv_flag IS TABLE OF OKC_BUS_VARIABLES_B.mrv_flag%TYPE INDEX BY BINARY_INTEGER;
    TYPE l_clm_source IS TABLE OF OKC_BUS_VARIABLES_B.clm_source%TYPE INDEX BY BINARY_INTEGER;
    -- MRV Project Changes End

    l_variable_tbl          l_variable_name;
    l_disabled_yn_tbl       l_disabled_yn;
    l_value_set_id_tbl      l_value_set_id;
    l_variable_type_tbl     l_variable_type;

    -- Below Added for bug 5958643
    l_variable_source_tbl   l_variable_source;
    l_procedure_name_tbl    l_procedure_name;

    l_mrv_flag_tbl  l_mrv_flag;
    l_clm_Source_tbl l_clm_source;

    l_procedure_spec_status        ALL_OBJECTS.status%TYPE;
    l_procedure_body_status        ALL_OBJECTS.status%TYPE;

    l_dummy                        VARCHAR2(1);
    -- Above Added for bug 5958643

    CURSOR l_check_valid_var_csr (cp_article_version_id IN NUMBER) IS
      SELECT BVT.VARIABLE_NAME,
             nvl(BVB.DISABLED_YN,'N'),
             nvl(BVB.VALUE_SET_ID, -99),
             BVB.VARIABLE_TYPE,
             BVB.VARIABLE_SOURCE, -- Added for Bug 5958643
             BVB.PROCEDURE_NAME, -- Added for Bug 5958643
             BVB.MRV_FLAG,       -- MRV Project
             BVB.CLM_SOURCE     -- MRV PROJECT
      FROM
         OKC_BUS_VARIABLES_TL BVT,
         OKC_BUS_VARIABLES_B BVB,
         OKC_ARTICLE_VARIABLES AAV
      WHERE BVB.VARIABLE_CODE = BVT.VARIABLE_CODE
      AND BVB.VARIABLE_CODE = AAV.VARIABLE_CODE
      AND BVT.LANGUAGE = USERENV('LANG')
      --AND BVB.DISABLED_YN = 'Y'
      AND AAV.ARTICLE_VERSION_ID = cp_article_version_id;

    CURSOR l_check_valid_valueset_csr (bvb_value_set_id IN NUMBER) IS
      select '1'
      from
            fnd_flex_value_sets
      where flex_value_set_id = bvb_value_set_id;

-- Below added for Bug 3737158
    CURSOR l_article_lkup_csr(cp_article_version_id IN NUMBER) is
     SELECT DEFAULT_SECTION, ARTICLE_TYPE
      FROM  OKC_ARTICLE_VERSIONS VER,OKC_ARTICLES_ALL ART
      WHERE
            ART.ARTICLE_ID = VER.ARTICLE_ID
      AND   VER.ARTICLE_VERSION_ID = cp_article_version_id;


    l_default_section OKC_ARTICLE_VERSIONS.DEFAULT_SECTION%TYPE;
    l_article_type    OKC_ARTICLES_ALL.ARTICLE_TYPE%TYPE;

-- Above added for Bug 3737158

    l_user_id NUMBER := FND_GLOBAL.USER_ID;
    l_login_id NUMBER := FND_GLOBAL.LOGIN_ID;

-- Below added for Bug 5958643
-- Expected procedure name is SCHEMA.PACKAGENAME.PROCEDURENAME

    CURSOR csr_check_proc_spec_status (p_procedure_name VARCHAR2) IS
    SELECT status
      FROM all_objects
     WHERE object_name = SUBSTR(p_procedure_name,
			      INSTR(p_procedure_name,'.')+1,
			      (INSTR(p_procedure_name,'.',1,2) -
			      INSTR(p_procedure_name,'.') - 1))
       AND object_type = 'PACKAGE'
       AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1);


    CURSOR csr_check_proc_body_status (p_procedure_name VARCHAR2) IS
    SELECT status
      FROM all_objects
     WHERE object_name = SUBSTR(p_procedure_name,
				INSTR(p_procedure_name,'.')+1,
				(INSTR(p_procedure_name,'.',1,2) -
				INSTR(p_procedure_name,'.') - 1))
       AND object_type = 'PACKAGE BODY'
       AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1);

    CURSOR csr_check_proc_exists (p_procedure_name VARCHAR2) IS
    SELECT 'X'
      FROM all_source
     WHERE name = SUBSTR(p_procedure_name,
		         INSTR(p_procedure_name,'.')+1,
		         (INSTR(p_procedure_name,'.',1,2) -
			 INSTR(p_procedure_name,'.') - 1))
       AND type = 'PACKAGE'
       AND owner = SUBSTR(p_procedure_name,1,INSTR(p_procedure_name,'.')-1)
       AND text LIKE '%' || SUBSTR(p_procedure_name,INSTR(p_procedure_name,'.',1,2)+1) || '%';

-- Above added for Bug 5958643

  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered pending approval with '||p_current_org_id ||'*'||p_adopt_as_is_yn||'*'||p_article_version_id, 2);
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    IF (p_current_org_id = G_GLOBAL_ORG_ID ) OR
        p_adopt_as_is_yn = 'N' THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('100: Validating article type and default section', 2);
       END IF;

-- Below Added for Bug 3737158
-- Standard clauses will be checked for valid lookup code

      OPEN l_article_lkup_csr (p_article_version_id);
      FETCH l_article_lkup_csr INTO l_default_section, l_article_type;
      IF l_article_lkup_csr%NOTFOUND THEN
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STD_ARTICLE_VERSION_ID');
        x_return_status := G_RET_STS_ERROR;
      END IF;
      CLOSE l_article_lkup_csr;
      if x_return_status = G_RET_STS_ERROR then
         RAISE FND_API.G_EXC_ERROR ;
      end if;

-- Check for Default Section Effectivity
      IF l_default_section IS NOT NULL THEN
        l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_ARTICLE_SECTION',l_default_section);
        IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
           Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INVALID_SECTION');
           x_return_status := G_RET_STS_ERROR;
        END IF;
      END IF;

-- Check for Article Type Effectivity
      l_tmp_return_status := Okc_Util.Check_Lookup_Code('OKC_SUBJECT',l_article_type);
      IF (l_tmp_return_status <> G_RET_STS_SUCCESS) THEN
          Okc_Api.Set_Message(G_APP_NAME, 'OKC_ART_INVALID_TYPE');
          x_return_status := G_RET_STS_ERROR;
      END IF;
      if x_return_status = G_RET_STS_ERROR then
         RAISE FND_API.G_EXC_ERROR ;
      end if;

-- Above Added for Bug 3737158

-- All the variables used should not have been inactivated since the article
-- cersion was created.

       IF (l_debug = 'Y') THEN
         okc_debug.log('100: Validating variables and assoc. with intent', 2);
       END IF;
       OPEN l_check_valid_var_csr (p_article_version_id);
       FETCH l_check_valid_var_csr BULK COLLECT INTO
                l_variable_tbl,
                l_disabled_yn_tbl,
                l_value_set_id_tbl,
                l_variable_type_tbl,
                l_variable_source_tbl,    -- Added for bug 5958643
                l_procedure_name_tbl,      -- Added for bug 5958643
                l_mrv_flag_tbl,  -- mrv project changes
                l_clm_source_tbl; -- mrv project changes
       CLOSE l_check_valid_var_csr;
       IF l_variable_tbl.COUNT > 0 THEN
         FOR i in l_variable_tbl.FIRST..l_variable_tbl.LAST LOOP
          if l_disabled_yn_tbl(i) = 'Y' then
             Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKC_ART_INACTV_VARBL',
                        p_token1       => 'VARIABLE_NAME',
                        p_token1_value => l_variable_tbl(i),
                        p_token2       => 'ARTICLE_TITLE',
                        p_token2_value => p_article_title,
                        p_token3       => 'ARTICLE_VERSION',
                        p_token3_value => p_article_version_number);
             x_return_status := G_RET_STS_ERROR;
          end if;
          if  l_variable_type_tbl(i) = 'U' AND Nvl( l_mrv_flag_tbl(i),'N') <> 'Y' then
              OPEN  l_check_valid_valueset_csr (l_value_set_id_tbl(i));
              FETCH l_check_valid_valueset_csr  INTO l_dummy_char;
              l_rownotfound := l_check_valid_valueset_csr%NOTFOUND;
              CLOSE l_check_valid_valueset_csr;
              if l_rownotfound then
                    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_ART_INV_VALUESET',
                          p_token1       => 'VARIABLE_NAME',
                          p_token1_value => l_variable_tbl(i),
                          p_token2       => 'ARTICLE_TITLE',
                          p_token2_value => p_article_title,
                          p_token3       => 'ARTICLE_VERSION',
                          p_token3_value => p_article_version_number);
                  x_return_status := G_RET_STS_ERROR;
              end if;
          end if;

          -- Below added for Bug 5958643
          if  l_variable_source_tbl(i) = 'P' then
	      OPEN csr_check_proc_spec_status(p_procedure_name => l_procedure_name_tbl(i));
	      FETCH csr_check_proc_spec_status INTO l_procedure_spec_status;

	      OPEN csr_check_proc_body_status(p_procedure_name => l_procedure_name_tbl(i));
	      FETCH csr_check_proc_body_status INTO l_procedure_body_status;

	      OPEN csr_check_proc_exists(p_procedure_name => l_procedure_name_tbl(i));
	      FETCH csr_check_proc_exists INTO l_dummy;

	      -- If Procedure Spec/Body status is INVALID then return error
              IF l_procedure_spec_status = 'INVALID' OR l_procedure_body_status = 'INVALID' THEN
                    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_XPRT_INV_PROCEDURE_VAR',
                          p_token1       => 'VARIABLE',
                          p_token1_value => l_variable_tbl(i),
                          p_token2       => 'PROCEDURE',
                          p_token2_value => l_procedure_name_tbl(i));
                  x_return_status := G_RET_STS_ERROR;
	      END IF;

	      -- If Procedure Spec/Body/API not found in DB then return error
	      IF csr_check_proc_spec_status%NOTFOUND OR csr_check_proc_body_status%NOTFOUND
	         OR csr_check_proc_exists%NOTFOUND THEN
                    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKC_XPRT_NO_PROCEDURE_VAR',
                          p_token1       => 'VARIABLE',
                          p_token1_value => l_variable_tbl(i),
                          p_token2       => 'PROCEDURE',
                          p_token2_value => l_procedure_name_tbl(i));
                  x_return_status := G_RET_STS_ERROR;
	      END IF;

	      CLOSE csr_check_proc_spec_status;
	      CLOSE csr_check_proc_body_status;
	      CLOSE csr_check_proc_exists;

          end if;
          -- Above added for Bug 5958643

         END LOOP;
         l_variable_tbl.DELETE;
         if x_return_status = G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR ;
         end if;

       END IF;
    END IF;


-- An Article (being created at a global org) is being send for Approval at a
-- global org. Updates the status of the version

    IF (p_current_org_id = G_GLOBAL_ORG_ID ) THEN
       IF (l_debug = 'Y') THEN
         okc_debug.log('100: Entered pending approval for global article at a global org', 2);
       END IF;
       OKC_ARTICLE_VERSIONS_PVT.Update_Row(
         p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
         x_return_status              => x_return_status,
         p_article_version_id         => p_article_version_id,
         p_article_id                 => NULL,
         p_article_version_number     => NULL,
         p_article_text               => NULL,
         p_provision_yn               => NULL,
         p_insert_by_reference        => NULL,
         p_lock_text                  => NULL,
         p_global_yn                  => NULL,
         p_article_language           => NULL,
         p_article_status             => 'PENDING_APPROVAL',
         p_sav_release                => NULL,
         p_start_date                 => NULL,
         p_end_date                   => NULL,
         p_std_article_version_id     => NULL,
         p_display_name               => NULL,
         p_translated_yn              => NULL,
         p_article_description        => NULL,
         p_date_approved              => NULL,
         p_default_section            => NULL,
         p_reference_source           => NULL,
         p_reference_text           => NULL,
         p_orig_system_reference_code => NULL,
         p_orig_system_reference_id1  => NULL,
         p_orig_system_reference_id2  => NULL,
         p_additional_instructions    => NULL,
         p_variation_description      => NULL,
         p_current_org_id             => p_current_org_id,
         p_attribute_category         => NULL,
         p_attribute1                 => NULL,
         p_attribute2                 => NULL,
         p_attribute3                 => NULL,
         p_attribute4                 => NULL,
         p_attribute5                 => NULL,
         p_attribute6                 => NULL,
         p_attribute7                 => NULL,
         p_attribute8                 => NULL,
         p_attribute9                 => NULL,
         p_attribute10                => NULL,
         p_attribute11                => NULL,
         p_attribute12                => NULL,
         p_attribute13                => NULL,
         p_attribute14                => NULL,
         p_attribute15                => NULL,
         p_object_version_number      => NULL,
	       p_edited_in_word             => NULL,
 	       p_article_text_in_word       => NULL,
         x_article_status             => l_article_status,
         x_article_id                 => l_article_id,
         x_earlier_version_id         => l_earlier_version_id
       );
    ELSE
       IF p_adopt_as_is_yn = 'Y' THEN

-- An Article (being created at a global org) is being send for Approval  for
-- adoption as is at a local org. Updates the status of the adoption
-- Also inherits all relationships between this article and other global articles adopted in this org if this
-- is the first version being adopted.

       IF (l_debug = 'Y') THEN
         okc_debug.log('100: Entered pending approval for global article at a local org adopted as is', 2);
       END IF;

       OKC_ADOPTIONS_GRP.check_adoption_details(
              p_api_version => p_api_version,
              p_init_msg_list => p_init_msg_list,
              p_validation_level => FND_API.G_VALID_LEVEL_FULL,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              x_earlier_local_version_id => l_earlier_local_version_id,
              p_global_article_version_id => p_article_version_id,
              p_adoption_type => 'ADOPTED',
              p_local_org_id => p_current_org_id);

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;

       OKC_ARTICLE_ADOPTIONS_PVT.update_row(
            x_return_status => x_return_status,
            p_global_article_version_id => p_article_version_id,
            p_adoption_type             => 'ADOPTED',
            p_local_org_id              => p_current_org_id,
            p_orig_local_version_id  => NULL,
            p_new_local_version_id  => NULL,
            p_adoption_status       => 'PENDING_APPROVAL',
            p_object_version_number  => NULL
           );
       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR ;
       END IF;

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
            SELECT source_article_id,
                   target_article_id,
                   p_current_org_id,
                   RELATIONSHIP_TYPE,
                   1.0,
                   l_user_id,
                   sysdate,
                   l_user_id,
                   l_login_id,
                   sysdate
              from OKC_ARTICLE_RELATNS_ALL ARL1
              WHERE org_id = G_GLOBAL_ORG_ID
                AND exists
                   (select 1 from okc_article_versions, okc_article_adoptions adp
                      where article_id = target_article_id
                       and  adp.global_article_version_id = article_version_id
                       and  adp.local_org_id = p_current_org_id
                       and  adp.adoption_type = 'ADOPTED')
               AND EXISTS
                  (select 1 from okc_article_versions
                    where article_version_id = p_article_version_id
                     and source_article_id = article_id)
               AND NOT EXISTS
                   (select 1 from okc_article_relatns_all ARL2
                      where arl1.source_article_id = arl2.source_article_id
                        and arl1.target_article_id = arl2.target_article_id
                        and arl1.relationship_type = arl2.relationship_type
                        and arl2.org_id = p_current_org_id);

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
            SELECT source_article_id,
                   target_article_id,
                   p_current_org_id,
                   relationship_type,
                   1.0,
                   l_user_id,
                   sysdate,
                   l_user_id,
                   l_login_id,
                   sysdate
              from OKC_ARTICLE_RELATNS_ALL ARL1
              WHERE org_id = G_GLOBAL_ORG_ID
              AND exists
                   (select 1 from okc_article_versions, okc_article_adoptions adp
                      where article_id = source_article_id
                       and  adp.global_article_version_id = article_version_id
                       and  adp.local_org_id = p_current_org_id
                       and  adp.adoption_type = 'ADOPTED')
               AND EXISTS
                  (select 1 from okc_article_versions
                    where article_version_id = p_article_version_id
                     and target_article_id = article_id)
               AND NOT EXISTS
                   (select 1 from okc_article_relatns_all ARL2
                      where arl1.source_article_id = arl2.source_article_id
                        and arl1.target_article_id = arl2.target_article_id
                        and arl1.relationship_type = arl2.relationship_type
                        and arl2.org_id = p_current_org_id);
       ELSE

-- An Article (being created at a local org) is being send for Approval at a
-- local org. Updates the status of the version.
         IF (l_debug = 'Y') THEN
           okc_debug.log('100: Entered pending approval for local article at a local org ', 2);
         END IF;

          OKC_ARTICLE_VERSIONS_PVT.Update_Row(
            p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
            x_return_status              => x_return_status,
            p_article_version_id         => p_article_version_id,
            p_article_id                 => NULL,
            p_article_version_number     => NULL,
            p_article_text               => NULL,
            p_provision_yn               => NULL,
            p_insert_by_reference        => NULL,
            p_lock_text                  => NULL,
            p_global_yn                  => NULL,
            p_article_language           => NULL,
            p_article_status             => 'PENDING_APPROVAL',
            p_sav_release                => NULL,
            p_start_date                 => NULL,
            p_end_date                   => NULL,
            p_std_article_version_id     => NULL,
            p_display_name               => NULL,
            p_translated_yn              => NULL,
            p_article_description        => NULL,
            p_date_approved              => NULL,
            p_default_section            => NULL,
            p_reference_source           => NULL,
            p_reference_text           => NULL,
            p_orig_system_reference_code => NULL,
            p_orig_system_reference_id1  => NULL,
            p_orig_system_reference_id2  => NULL,
            p_additional_instructions    => NULL,
            p_variation_description      => NULL,
            p_current_org_id             => p_current_org_id,
            p_attribute_category         => NULL,
            p_attribute1                 => NULL,
            p_attribute2                 => NULL,
            p_attribute3                 => NULL,
            p_attribute4                 => NULL,
            p_attribute5                 => NULL,
            p_attribute6                 => NULL,
            p_attribute7                 => NULL,
            p_attribute8                 => NULL,
            p_attribute9                 => NULL,
            p_attribute10                => NULL,
            p_attribute11                => NULL,
            p_attribute12                => NULL,
            p_attribute13                => NULL,
            p_attribute14                => NULL,
            p_attribute15                => NULL,
            p_object_version_number      => NULL,
	          p_edited_in_word             => NULL,
 	          p_article_text_in_word       => NULL,
            x_article_status             => l_article_status,
            x_article_id                 => l_article_id,
            x_earlier_version_id         => l_earlier_version_id
          );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------
-- check if the local article being approved is created as a localizaion from
-- a global article. In that case update the adoption row.
-- More efficient to use dirct DML than Simple API.

         update_adoption_ifexists (p_article_version_id,
                                   p_current_org_id,
                                   'PENDING_APPROVAL',
                                   x_return_status );

       END IF;
    END IF;
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving pending approval successfully', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving pending approval OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving pending approval of EXCEPTION: '||sqlerrm, 2);
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END pending_approval;

  ---------------------------------------
  -- PROCEDURE approve
  ---------------------------------------
-- Procedure to set an article version status from pending approval to approved.
-- Parameters: article_version_id , p_adopt_as_is_yn => Y means Adoption at a
-- Local Org as is and N means Local version
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.

  PROCEDURE approve(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_current_org_id               IN NUMBER,
    p_adopt_as_is_yn               IN VARCHAR2,
    p_article_version_id    IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'approve';
    l_global_article_version_id   NUMBER := NULL;
    l_local_article_version_id    NUMBER;
    l_rownotfound    BOOLEAN := FALSE;
    l_delete_adoption              VARCHAR2(1) := 'T';
    l_rowid                       ROWID;
    CURSOR l_article_version_csr (cp_article_version_id IN NUMBER) IS
      SELECT global_yn, org_id, art.article_id, start_date
        FROM okc_articles_all art, okc_article_versions ver
       WHERE ver.article_id = art.article_id
        AND ver.article_version_id = cp_article_version_id;
    l_article_version_rec l_article_version_csr%ROWTYPE;
    l_earlier_version_id NUMBER := NULL;
    l_article_id NUMBER := NULL;
    l_article_status VARCHAR2(30) := NULL;
    l_new_article_status VARCHAR2(30) := NULL;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered approved with '||p_current_org_id ||'*'||p_adopt_as_is_yn||'*'||p_article_version_id, 2);
    END IF;
    x_return_status := G_RET_STS_SUCCESS;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    OPEN l_article_version_csr (p_article_version_id);
    FETCH l_article_version_csr INTO l_article_version_rec;
    l_rownotfound := l_article_version_csr%NOTFOUND;
    CLOSE l_article_version_csr;
    IF l_rownotfound THEN
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_VERSION_ID');
        x_return_status :=  G_RET_STS_ERROR;
        return;
    END IF;
    --  Initialize API return status to success
    IF (p_current_org_id  = G_GLOBAL_ORG_ID ) THEN

-- An Article (being created at a global org) is being Approved at a
--global org. Updates the status of the version
       IF (l_debug = 'Y') THEN
          okc_debug.log('100: Entered approve of global article at a global org', 2);
       END IF;

       OKC_ARTICLE_VERSIONS_PVT.Update_Row(
         p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
         x_return_status              => x_return_status,
         p_article_version_id         => p_article_version_id,
         p_article_id                 => NULL,
         p_article_version_number     => NULL,
         p_article_text               => NULL,
         p_provision_yn               => NULL,
         p_insert_by_reference        => NULL,
         p_lock_text                  => NULL,
         p_global_yn                  => NULL,
         p_article_language           => NULL,
         p_article_status             => 'APPROVED',
         p_sav_release                => NULL,
         p_start_date                 => NULL,
         p_end_date                   => NULL,
         p_std_article_version_id     => NULL,
         p_display_name               => NULL,
         p_translated_yn              => NULL,
         p_article_description        => NULL,
         p_date_approved              => sysdate,
         p_default_section            => NULL,
         p_reference_source           => NULL,
         p_reference_text           => NULL,
         p_orig_system_reference_code => NULL,
         p_orig_system_reference_id1  => NULL,
         p_orig_system_reference_id2  => NULL,
         p_additional_instructions    => NULL,
         p_variation_description      => NULL,
         p_current_org_id             => p_current_org_id ,
         p_attribute_category         => NULL,
         p_attribute1                 => NULL,
         p_attribute2                 => NULL,
         p_attribute3                 => NULL,
         p_attribute4                 => NULL,
         p_attribute5                 => NULL,
         p_attribute6                 => NULL,
         p_attribute7                 => NULL,
         p_attribute8                 => NULL,
         p_attribute9                 => NULL,
         p_attribute10                => NULL,
         p_attribute11                => NULL,
         p_attribute12                => NULL,
         p_attribute13                => NULL,
         p_attribute14                => NULL,
         p_attribute15                => NULL,
         p_object_version_number      => NULL,
	       p_edited_in_word             => NULL,
 	       p_article_text_in_word       => NULL,
         x_article_status             => l_article_status,
         x_article_id                 => l_article_id,
         x_earlier_version_id         => l_earlier_version_id
       );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------
-- Update the end date of the previous version as a second less than the current
-- version unless there is an existing end date

       update_prev_vers_enddate (p_article_version_id ,
                                 l_article_version_rec.article_id,
                                 l_article_version_rec.start_date - 1/86400,
                                 p_current_org_id,
                                 x_return_status );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------

--  If a global article is approved at a global org it will trigger
-- autoadoption of the article for all orgs that have subscribed to Articles.
-- Adoption row will be created as ADOPTED or PENDING APPROVAL depending upon
-- how the org has been set up in HR Orgs for auto-adoption

         IF l_article_version_rec.global_YN = 'Y' THEN
            IF (l_debug = 'Y') THEN
               okc_debug.log('100: Calling Auto Adoption ', 2);
            END IF;
           OKC_ADOPTIONS_GRP.AUTO_ADOPT_ARTICLES
            (
              p_api_version                  => 1.0,
              p_init_msg_list                => p_init_msg_list,
              p_validation_level             => FND_API.G_VALID_LEVEL_NONE,
              p_commit                       => FND_API.G_FALSE,
              x_return_status                => x_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data,
              p_relationship_yn              => 'Y',
              p_adoption_yn                  => 'Y',
              p_fetchsize                    => 100,
              p_global_article_id            => l_article_version_rec.article_id,
              p_global_article_version_id    => p_article_version_id
            );
         END IF;
    ELSIF (l_article_version_rec.org_id = G_GLOBAL_ORG_ID ) THEN

-- An Article (being created at a global org) is being Approved   for
-- "adopted as is" at a local org. Updates the status of the adoption

       IF (l_debug = 'Y') THEN
          okc_debug.log('100: Entered approve of global article adopted as is at a local org', 2);
       END IF;

         OKC_ARTICLE_ADOPTIONS_PVT.update_row(
            x_return_status => x_return_status,
            p_global_article_version_id => p_article_version_id,
            p_adoption_type             => 'ADOPTED',
            p_local_org_id              => p_current_org_id ,
            p_orig_local_version_id  => NULL,
            p_new_local_version_id  => NULL,
            p_adoption_status       => 'APPROVED',
            p_object_version_number  => NULL
           );
    ELSE

-- An Article (being created at a local org) is being Approved  at a local org.
-- Updates the status of the version

       IF (l_debug = 'Y') THEN
          okc_debug.log('100: Entered approve of local article at a local org', 2);
       END IF;

       OKC_ARTICLE_VERSIONS_PVT.Update_Row(
            p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
            x_return_status              => x_return_status,
            p_article_version_id         => p_article_version_id,
            p_article_id                 => NULL,
            p_article_version_number     => NULL,
            p_article_text               => NULL,
            p_provision_yn               => NULL,
            p_insert_by_reference        => NULL,
            p_lock_text                  => NULL,
            p_global_yn                  => NULL,
            p_article_language           => NULL,
            p_article_status             => 'APPROVED',
            p_sav_release                => NULL,
            p_start_date                 => NULL,
            p_end_date                   => NULL,
            p_std_article_version_id     => NULL,
            p_display_name               => NULL,
            p_translated_yn              => NULL,
            p_article_description        => NULL,
            p_date_approved              => sysdate,
            p_default_section            => NULL,
            p_reference_source           => NULL,
            p_reference_text           => NULL,
            p_orig_system_reference_code => NULL,
            p_orig_system_reference_id1  => NULL,
            p_orig_system_reference_id2  => NULL,
            p_additional_instructions    => NULL,
            p_variation_description      => NULL,
            p_current_org_id             => p_current_org_id ,
            p_attribute_category         => NULL,
            p_attribute1                 => NULL,
            p_attribute2                 => NULL,
            p_attribute3                 => NULL,
            p_attribute4                 => NULL,
            p_attribute5                 => NULL,
            p_attribute6                 => NULL,
            p_attribute7                 => NULL,
            p_attribute8                 => NULL,
            p_attribute9                 => NULL,
            p_attribute10                => NULL,
            p_attribute11                => NULL,
            p_attribute12                => NULL,
            p_attribute13                => NULL,
            p_attribute14                => NULL,
            p_attribute15                => NULL,
            p_object_version_number      => NULL,
	          p_edited_in_word             => NULL,
 	          p_article_text_in_word       => NULL,
            x_article_status             => l_article_status,
            x_article_id                 => l_article_id,
            x_earlier_version_id         => l_earlier_version_id
          );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------

-- Update the end date of the previous version as a second less than the current
-- version unless there is an existing end date

        update_prev_vers_enddate (p_article_version_id ,
                                 l_article_version_rec.article_id,
                                 l_article_version_rec.start_date - 1/86400,
                                 p_current_org_id,
                                 x_return_status );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------
-- check if the local article being approved is created as a localizaion from
-- a global article. In that case update the adoption row.
-- More efficient to use dirct DML than Simple API.

         update_adoption_ifexists (p_article_version_id,
                                   p_current_org_id ,
                                   'APPROVED',
                                   x_return_status );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------

       END IF;
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving approve successfully', 2);
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (l_debug = 'Y') THEN
         okc_debug.log('300: Leaving approve because of OKC_API.G_EXCEPTION_ERROR Exception', 2);
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN OTHERS THEN
      IF (l_debug = 'Y') THEN
        okc_debug.log('500: Leaving approve because of EXCEPTION: '||sqlerrm, 2);
      END IF;
      IF l_article_version_csr%ISOPEN THEN
         CLOSE l_article_version_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END approve;
  ---------------------------------------
  -- PROCEDURE reject
  ---------------------------------------
-- Procedure to set an article version status from pending approval to rejected.
-- Parameters: article_version_id , p_adopt_as_is_yn => Y means Adoption at a
-- Local Org as is and N means Local version
-- This will be called from the UI only. So we can save db access to check
-- if article version is global or Not.

  PROCEDURE reject(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_current_org_id               IN NUMBER,
    p_adopt_as_is_yn               IN VARCHAR2,
    p_article_version_id    IN NUMBER
  ) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'reject';
    l_global_article_version_id   NUMBER := NULL;
    l_local_article_version_id    NUMBER;
    l_rownotfound    BOOLEAN := FALSE;
    l_delete_adoption              VARCHAR2(1) := 'T';
    l_rowid                       ROWID;
    CURSOR l_article_version_csr (cp_article_version_id IN NUMBER) IS
      SELECT global_yn, org_id, art.article_id, start_date
        FROM okc_articles_all art, okc_article_versions ver
       WHERE ver.article_id = art.article_id
        AND ver.article_version_id = cp_article_version_id;
    l_article_version_rec l_article_version_csr%ROWTYPE;
    l_earlier_version_id NUMBER := NULL;
    l_article_id NUMBER := NULL;
    l_article_status VARCHAR2(30) := NULL;
    l_new_article_status VARCHAR2(30) := NULL;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.log('100: Entered reject with '||p_current_org_id ||'*'||p_adopt_as_is_yn||'*'||p_article_version_id, 2);
    END IF;
    x_return_status := G_RET_STS_SUCCESS;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    OPEN l_article_version_csr (p_article_version_id);
    FETCH l_article_version_csr INTO l_article_version_rec;
    l_rownotfound := l_article_version_csr%NOTFOUND;
    CLOSE l_article_version_csr;
    IF l_rownotfound THEN
        Okc_Api.Set_Message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'ARTICLE_VERSION_ID');
        x_return_status :=  G_RET_STS_ERROR;
        return;
    END IF;
    --  Initialize API return status to success

-- An Article (being created at a global org) is being Rejected at a
--global org. Updates the status of the version

    IF (p_current_org_id  = G_GLOBAL_ORG_ID ) THEN
       IF (l_debug = 'Y') THEN
          okc_debug.log('100: Entered reject of global article at a global org', 2);
       END IF;
       OKC_ARTICLE_VERSIONS_PVT.Update_Row(
         p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
         x_return_status              => x_return_status,
         p_article_version_id         => p_article_version_id,
         p_article_id                 => NULL,
         p_article_version_number     => NULL,
         p_article_text               => NULL,
         p_provision_yn               => NULL,
         p_insert_by_reference        => NULL,
         p_lock_text                  => NULL,
         p_global_yn                  => NULL,
         p_article_language           => NULL,
         p_article_status             => 'REJECTED',
         p_sav_release                => NULL,
         p_start_date                 => NULL,
         p_end_date                   => NULL,
         p_std_article_version_id     => NULL,
         p_display_name               => NULL,
         p_translated_yn              => NULL,
         p_article_description        => NULL,
         p_date_approved              => NULL,
         p_default_section            => NULL,
         p_reference_source           => NULL,
         p_reference_text           => NULL,
         p_orig_system_reference_code => NULL,
         p_orig_system_reference_id1  => NULL,
         p_orig_system_reference_id2  => NULL,
         p_additional_instructions    => NULL,
         p_variation_description      => NULL,
         p_current_org_id             => p_current_org_id ,
         p_attribute_category         => NULL,
         p_attribute1                 => NULL,
         p_attribute2                 => NULL,
         p_attribute3                 => NULL,
         p_attribute4                 => NULL,
         p_attribute5                 => NULL,
         p_attribute6                 => NULL,
         p_attribute7                 => NULL,
         p_attribute8                 => NULL,
         p_attribute9                 => NULL,
         p_attribute10                => NULL,
         p_attribute11                => NULL,
         p_attribute12                => NULL,
         p_attribute13                => NULL,
         p_attribute14                => NULL,
         p_attribute15                => NULL,
         p_object_version_number      => NULL,
	       p_edited_in_word             => NULL,
 	       p_article_text_in_word       => NULL,
         x_article_status             => l_article_status,
         x_article_id                 => l_article_id,
         x_earlier_version_id         => l_earlier_version_id
       );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------
    ELSIF (l_article_version_rec.org_id = G_GLOBAL_ORG_ID ) THEN

-- An Article (being created at a global org) is being Rejected for
-- "Adopted As Is" at a local org. Updates the status of the adoption.
-- The Article becomes Pending Adoption and all global relationships are deleted if this is the first version being adopted.

       IF (l_debug = 'Y') THEN
          okc_debug.log('100: Entered reject of global article adopted as is at a local org', 2);
       END IF;

         OKC_ARTICLE_ADOPTIONS_PVT.update_row(
            x_return_status => x_return_status,
            p_global_article_version_id => p_article_version_id,
            p_adoption_type             => 'AVAILABLE',
            p_local_org_id              => p_current_org_id ,
            p_orig_local_version_id  => NULL,
            p_new_local_version_id  => NULL,
            p_adoption_status       => 'REJECTED',
            p_object_version_number  => NULL
           );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------
         DELETE FROM OKC_ARTICLE_RELATNS_ALL
          WHERE source_article_id = l_article_version_rec.article_id
           AND  org_id = p_current_org_id
           AND  NOT EXISTS
             (SELECT 1 FROM OKC_ARTICLE_ADOPTIONS ADP, OKC_ARTICLE_VERSIONS AV
                WHERE ARTICLE_ID = l_article_version_rec.article_id
                 AND  ARTICLE_VERSION_ID <> p_article_version_id
                 AND  ADP.ADOPTION_TYPE = 'ADOPTED'
                 AND  global_article_version_id = article_version_id
             );

         DELETE FROM OKC_ARTICLE_RELATNS_ALL
          WHERE target_article_id = l_article_version_rec.article_id
           AND  org_id = p_current_org_id
           AND  NOT EXISTS
             (SELECT 1 FROM OKC_ARTICLE_ADOPTIONS ADP, OKC_ARTICLE_VERSIONS AV
                WHERE ARTICLE_ID = l_article_version_rec.article_id
                 AND  ARTICLE_VERSION_ID <> p_article_version_id
                 AND  ADP.ADOPTION_TYPE = 'ADOPTED'
                 AND  global_article_version_id = article_version_id
             );

    ELSE

-- An Article (being created at a local org) is being Rejected at a
--local org. Updates the status of the version
       IF (l_debug = 'Y') THEN
          okc_debug.log('100: Entered reject of local article at a local org', 2);
       END IF;

       OKC_ARTICLE_VERSIONS_PVT.Update_Row(
            p_validation_level           => FND_API.G_VALID_LEVEL_NONE,
            x_return_status              => x_return_status,
            p_article_version_id         => p_article_version_id,
            p_article_id                 => NULL,
            p_article_version_number     => NULL,
            p_article_text               => NULL,
            p_provision_yn               => NULL,
            p_insert_by_reference        => NULL,
            p_lock_text                  => NULL,
            p_global_yn                  => NULL,
            p_article_language           => NULL,
            p_article_status             => 'REJECTED',
            p_sav_release                => NULL,
            p_start_date                 => NULL,
            p_end_date                   => NULL,
            p_std_article_version_id     => NULL,
            p_display_name               => NULL,
            p_translated_yn              => NULL,
            p_article_description        => NULL,
            p_date_approved              => NULL,
            p_default_section            => NULL,
            p_reference_source           => NULL,
            p_reference_text           => NULL,
            p_orig_system_reference_code => NULL,
            p_orig_system_reference_id1  => NULL,
            p_orig_system_reference_id2  => NULL,
            p_additional_instructions    => NULL,
            p_variation_description      => NULL,
            p_current_org_id             => p_current_org_id ,
            p_attribute_category         => NULL,
            p_attribute1                 => NULL,
            p_attribute2                 => NULL,
            p_attribute3                 => NULL,
            p_attribute4                 => NULL,
            p_attribute5                 => NULL,
            p_attribute6                 => NULL,
            p_attribute7                 => NULL,
            p_attribute8                 => NULL,
            p_attribute9                 => NULL,
            p_attribute10                => NULL,
            p_attribute11                => NULL,
            p_attribute12                => NULL,
            p_attribute13                => NULL,
            p_attribute14                => NULL,
            p_attribute15                => NULL,
            p_object_version_number      => NULL,
            p_edited_in_word             => NULL,
 	          p_article_text_in_word       => NULL,
            x_article_status             => l_article_status,
            x_article_id                 => l_article_id,
            x_earlier_version_id         => l_earlier_version_id
          );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;
    --------------------------------------------

-- check if the local article being rejected is created as a localizaion from
-- a global article. In that case update the adoption row.
-- More efficient to use direct DML than Simple API.

         update_adoption_ifexists (p_article_version_id,
                                   p_current_org_id ,
                                   'REJECTED',
                                   x_return_status );
    --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
         END IF;

    END IF;
    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR ;
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
      IF l_article_version_csr%ISOPEN THEN
         CLOSE l_article_version_csr;
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;

  END reject;
  -- MOAC
  /*
  BEGIN
    OPEN cur_org_csr;
    FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
    CLOSE cur_org_csr;
  */

END OKC_ARTICLE_STATUS_CHANGE_PVT;

/
