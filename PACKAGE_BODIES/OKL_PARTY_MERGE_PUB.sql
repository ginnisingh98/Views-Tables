--------------------------------------------------------
--  DDL for Package Body OKL_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PARTY_MERGE_PUB" AS
/* $Header: OKLPPMGB.pls 120.8.12010000.3 2008/10/21 22:47:54 apaul ship $ */

  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;
  --------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : CREATE_PARTY_SITE
  -- Description     : This procedure create a new Party Site using the data from
  --                   an existing party site. New Party Site is created for the
  --                   party of the given customer account.
  -- Business Rules  :
  -- Parameters      :
	--   p_cust_acct_id -> is the customer account id, which is used to get the
	--                     party for which the site needs to be created
  --   p_old_party_site_id -> is the party site id which is to be copied
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE CREATE_PARTY_SITE(
    p_init_msg_list      IN  VARCHAR2,
    p_cust_acct_id       IN  NUMBER,
    p_old_party_site_id  IN  NUMBER,
    x_new_party_site_id  OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    l_api_name              VARCHAR2(30) := 'CREATE_PARTY_SITE';
    l_return_status         VARCHAR2(1);

    x_party_site_number     hz_party_sites.party_site_number%TYPE;
    p_party_site_rec        HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    l_prof_value VARCHAR2(1);
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_PARTY_MERGE_PUB.CREATE_PARTY_SITE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_init_msg_list => p_init_msg_list
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Obtain the details of the given Party Site which is to be copied
    SELECT LOCATION_ID
       , PARTY_SITE_NUMBER
       , orig_system_reference
       , party_site_name
       , language
       , addressee
       , global_location_number
    INTO p_party_site_rec.location_id
       , p_party_site_rec.party_site_number
       , p_party_site_rec.orig_system_reference
       , p_party_site_rec.party_site_name
       , p_party_site_rec.language
       , p_party_site_rec.addressee
       , p_party_site_rec.global_location_number
    FROM hz_party_sites
    WHERE party_site_id = p_old_party_site_id;

    --Obtain the Party of the given Customer Account
    SELECT PARTY_ID INTO p_party_site_rec.party_id
    FROM HZ_CUST_ACCOUNTS_ALL HCA
    WHERE HCA.CUST_ACCOUNT_ID = p_cust_acct_id;

    p_party_site_rec.identifying_address_flag := 'N';
    p_party_site_rec.status := 'A';
    p_party_site_rec.created_by_module := 'OKL';
    p_party_site_rec.application_id := 540;

    --Obtain the profile value to find out whether site number is to be passed
    --or not.
    SELECT NVL(FND_PROFILE.VALUE('HZ_GENERATE_PARTY_SITE_NUMBER'), 'Y') INTO l_prof_value FROM DUAL;

    IF l_prof_value = 'Y'
    THEN
      p_party_site_rec.party_site_number := NULL;
    END IF;

    --Call the Create Party Site API
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE');
    END IF;

    HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE(
      p_init_msg_list         => p_init_msg_list,
      p_party_site_rec        => p_party_site_rec,
      x_party_site_id         => x_new_party_site_id,
      x_party_site_number     => x_party_site_number,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE'
         ,'Party Site Number ' || x_party_site_number ||
          ' New Party Site Id '|| x_new_party_site_id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END CREATE_PARTY_SITE;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : CREATE_PARTY_SITE_USE
  -- Description     : This procedure create a new Party Site Use using the data
  --                   from an existing party site use. New Party Site Use is
  --                   created for the given party site.
  -- Business Rules  :
  -- Parameters      :
	--   p_party_site_id -> is the party site id for which the site use needs to be
  --                      created
  --   p_old_party_site_use_id -> is the party site use id which is to be copied
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE CREATE_PARTY_SITE_USE(
    p_init_msg_list          IN  VARCHAR2,
    p_party_site_id          IN  NUMBER,
    p_old_party_site_use_id  IN  NUMBER,
    x_new_party_site_use_id  OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2)
  IS
    l_api_name              VARCHAR2(30) := 'CREATE_PARTY_SITE_USE';
    l_return_status         VARCHAR2(1);

    p_party_site_use_rec    HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_PARTY_MERGE_PUB.CREATE_PARTY_SITE_USE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_init_msg_list => p_init_msg_list
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Obtain the details of the existing Site Use
    SELECT COMMENTS
         , SITE_USE_TYPE
         , PRIMARY_PER_TYPE
         , STATUS
    INTO p_party_site_use_rec.COMMENTS
       , p_party_site_use_rec.SITE_USE_TYPE
       , p_party_site_use_rec.PRIMARY_PER_TYPE
       , p_party_site_use_rec.STATUS
    FROM HZ_PARTY_SITE_USES
    WHERE PARTY_SITE_USE_ID = p_old_party_site_use_id;

    p_party_site_use_rec.PARTY_SITE_ID := p_party_site_id;
    p_party_site_use_rec.created_by_module := 'OKL';
    p_party_site_use_rec.application_id := 540;

    --Call the API to create the site use
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE_USE');
    END IF;

    HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE_USE(
      p_init_msg_list         => FND_API.G_TRUE,
      p_party_site_use_rec    => p_party_site_use_rec,
      x_party_site_use_id     => x_new_party_site_use_id,
      x_return_status         => l_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE_USE');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE_USE'
         ,' New Party Site Use Id '|| x_new_party_site_use_id ||
          ' result status ' || l_return_status ||
          ' x_msg_data ' || x_msg_data);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END CREATE_PARTY_SITE_USE;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Function  Name  : CHECK_IF_SAME_PARTY
  -- Description     : This function checks whether the given two customer accounts
  --                   belong to same party or not.
  -- Business Rules  :
  -- Parameters      : If both the customer accounts belong to same party then
  --                   it returns TRUE else FALSE
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  FUNCTION CHECK_IF_SAME_PARTY(
      orig_cust_acct_id    IN NUMBER,
      new_cust_acct_id     IN NUMBER) RETURN BOOLEAN
  AS
    l_api_name              VARCHAR2(30) := 'CHECK_IF_SAME_PARTY';
    ret_val BOOLEAN DEFAULT FALSE;
    --Cursor to check if Parties of both the Customer Accounts is same.
    CURSOR same_party_csr(l_orig_cust_acct_id NUMBER, l_new_cust_acct_id NUMBER) IS
      SELECT 1
      FROM HZ_CUST_ACCOUNTS_ALL HCA1
         , HZ_CUST_ACCOUNTS_ALL HCA2
      WHERE HCA1.CUST_ACCOUNT_ID = l_orig_cust_acct_id
        AND HCA2.CUST_ACCOUNT_ID = l_new_cust_acct_id
        AND HCA1.PARTY_ID = HCA2.PARTY_ID;
    same_party_val VARCHAR2(1);
  BEGIN
    --Use to cursor to identify if both the customer accounts belong to same party
    OPEN same_party_csr(orig_cust_acct_id, new_cust_acct_id);
    FETCH same_party_csr INTO same_party_val;
    CLOSE same_party_csr;

    IF NVL(same_party_val, 'X') = 'X'
    THEN
      --If the value returned by cursor is null then return false as both the accounts
      --do not belong to same party
      ret_val := FALSE;
    ELSE
      --If a value returned by cursor then return true as both the accounts belong
      --to same party
      ret_val := TRUE;
    END IF;
    RETURN ret_val;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN FALSE;
  END CHECK_IF_SAME_PARTY;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Function  Name  : GET_NEW_PARTY_SITE
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  FUNCTION GET_NEW_PARTY_SITE(
      old_party_site_id    IN NUMBER,
      new_cust_acct_id     IN NUMBER) RETURN NUMBER
  AS
    new_party_site_id NUMBER;
    CURSOR new_party_site_csr(l_old_party_site_id NUMBER, l_new_cust_acct_id NUMBER) IS
      SELECT HPSN.PARTY_SITE_ID
      FROM HZ_PARTY_SITES HPS
         , HZ_CUST_ACCOUNTS_ALL HCA
         , HZ_PARTY_SITES HPSN
      WHERE HPS.PARTY_SITE_ID = l_old_party_site_id
        AND HCA.CUST_ACCOUNT_ID = l_new_cust_acct_id
        AND HCA.PARTY_ID = HPSN.PARTY_ID
        AND HPSN.LOCATION_ID = HPS.LOCATION_ID
        AND ROWNUM < 2;

  BEGIN
    OPEN new_party_site_csr(old_party_site_id, new_cust_acct_id);
    FETCH new_party_site_csr INTO new_party_site_id;
    CLOSE new_party_site_csr;

    RETURN new_party_site_id;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN NULL;
  END GET_NEW_PARTY_SITE;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- FUNCTION  Name  : GET_NEW_PARTY_SITE_USE
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  FUNCTION GET_NEW_PARTY_SITE_USE(
      old_party_site_use_id   IN NUMBER,
      new_cust_acct_id        IN NUMBER) RETURN NUMBER
  AS
    new_party_site_use_id NUMBER;
    CURSOR new_party_site_use_csr(l_old_party_site_use_id NUMBER, l_new_cust_acct_id NUMBER) IS
      SELECT HPSUN.PARTY_SITE_USE_ID
      FROM HZ_PARTY_SITES HPS
         , HZ_CUST_ACCOUNTS_ALL HCA
         , HZ_PARTY_SITES HPSN
         , HZ_PARTY_SITE_USES HPSU
         , HZ_PARTY_SITE_USES HPSUN
      WHERE HPSU.PARTY_SITE_USE_ID = l_old_party_site_use_id
        AND HPS.PARTY_SITE_ID = HPSU.PARTY_SITE_ID
        AND HCA.CUST_ACCOUNT_ID = l_new_cust_acct_id
        AND HCA.PARTY_ID = HPSN.PARTY_ID
        AND HPSN.LOCATION_ID = HPS.LOCATION_ID
        AND HPSUN.PARTY_SITE_ID = HPSN.PARTY_SITE_ID
        AND HPSUN.SITE_USE_TYPE = HPSU.SITE_USE_TYPE
        AND ROWNUM < 2;

  BEGIN
    OPEN new_party_site_use_csr(old_party_site_use_id, new_cust_acct_id);
    FETCH new_party_site_use_csr INTO new_party_site_use_id;
    CLOSE new_party_site_use_csr;

    RETURN new_party_site_use_id;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN NULL;
  END GET_NEW_PARTY_SITE_USE;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : UPDATE_ASSET_LOCATION
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE UPDATE_ASSET_LOCATION(
    p_init_msg_list      IN  VARCHAR2,
    p_cust_acct_id       IN  NUMBER,
    p_parent_object_id   IN  NUMBER,
    p_parent_object_code IN  VARCHAR2,
    p_merge_header_id    IN  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE,
    req_id               IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    l_api_name              VARCHAR2(30) := 'UPDATE_ASSET_LOCATION';
    l_return_status         VARCHAR2(1);

    TYPE ASSET_ID_LIST_TYPE IS TABLE OF OKL_ASSETS_B.ID%TYPE
      INDEX BY BINARY_INTEGER;
    ASSET_ID_LIST ASSET_ID_LIST_TYPE;

    TYPE IS_ID_LIST_TYPE IS TABLE OF OKL_ASSETS_B.INSTALL_SITE_ID%TYPE
      INDEX BY BINARY_INTEGER;
    IS_ID_LIST IS_ID_LIST_TYPE;
    NEW_IS_ID_LIST IS_ID_LIST_TYPE;

    TYPE PS_ID_LIST_TYPE IS TABLE OF HZ_PARTY_SITES.PARTY_SITE_ID%TYPE
      INDEX BY BINARY_INTEGER;
    PS_ID_LIST PS_ID_LIST_TYPE;
    NEW_PS_ID_LIST PS_ID_LIST_TYPE;

    l_profile_val VARCHAR2(30);

    CURSOR LAP_ASSET_CSR(l_lap_id NUMBER) IS
      SELECT ASS.ID ASSET_ID
           , ASS.INSTALL_SITE_ID
           , HPS.PARTY_SITE_ID
      FROM OKL_ASSETS_B ASS
         , OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_APPLICATIONS_B LAP
         , HZ_PARTY_SITE_USES HPSU
         , HZ_PARTY_SITES HPS
      WHERE ASS.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND LSQ.ID = ASS.PARENT_OBJECT_ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEAPP'
        AND LSQ.PARENT_OBJECT_ID = LAP.ID
        AND HPSU.PARTY_SITE_USE_ID = ASS.INSTALL_SITE_ID
        AND HPSU.PARTY_SITE_ID = HPS.PARTY_SITE_ID
        AND LAP.ID = l_lap_id;

    CURSOR LOP_ASSET_CSR(l_lop_id NUMBER) IS
      SELECT ASS.ID ASSET_ID
           , ASS.INSTALL_SITE_ID
           , HPS.PARTY_SITE_ID
      FROM OKL_ASSETS_B ASS
         , OKL_LEASE_QUOTES_B LSQ
         , OKL_LEASE_OPPORTUNITIES_B LOP
         , HZ_PARTY_SITE_USES HPSU
         , HZ_PARTY_SITES HPS
      WHERE ASS.PARENT_OBJECT_CODE = 'LEASEQUOTE'
        AND LSQ.ID = ASS.PARENT_OBJECT_ID
        AND LSQ.PARENT_OBJECT_CODE = 'LEASEOPP'
        AND LSQ.PARENT_OBJECT_ID = LOP.ID
        AND HPSU.PARTY_SITE_USE_ID = ASS.INSTALL_SITE_ID
        AND HPSU.PARTY_SITE_ID = HPS.PARTY_SITE_ID
        AND LOP.ID = l_lop_id;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_PARTY_MERGE_PUB.UPDATE_ASSET_LOCATION';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_init_msg_list => p_init_msg_list
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_parent_object_code = 'LEASEAPP')
    THEN
      OPEN LAP_ASSET_CSR(p_parent_object_id);
      FETCH LAP_ASSET_CSR BULK COLLECT INTO
        ASSET_ID_LIST,
        IS_ID_LIST,
        PS_ID_LIST;
      CLOSE LAP_ASSET_CSR;
    ELSIF(p_parent_object_code = 'LEASEOPP')
    THEN
      OPEN LOP_ASSET_CSR(p_parent_object_id);
      FETCH LOP_ASSET_CSR BULK COLLECT INTO
        ASSET_ID_LIST,
        IS_ID_LIST,
        PS_ID_LIST;
      CLOSE LOP_ASSET_CSR;
    END IF;

    FOR I IN 1..ASSET_ID_LIST.COUNT
    LOOP
      IF(IS_ID_LIST(I) IS NOT NULL)
      THEN
        NEW_IS_ID_LIST(I) := GET_NEW_PARTY_SITE_USE(IS_ID_LIST(I), p_cust_acct_id);
        IF(NEW_IS_ID_LIST(I) IS NULL)
        THEN
          NEW_PS_ID_LIST(I) := GET_NEW_PARTY_SITE(PS_ID_LIST(I), p_cust_acct_id);
          IF(NEW_PS_ID_LIST(I) IS NULL)
          THEN
            --Call the Create Party Site API
            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'begin debug call CREATE_PARTY_SITE');
            END IF;

            CREATE_PARTY_SITE(
              p_init_msg_list      => p_init_msg_list,
              p_cust_acct_id       => p_cust_acct_id,
              p_old_party_site_id  => PS_ID_LIST(I),
              x_new_party_site_id  => NEW_PS_ID_LIST(I),
              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'end debug call CREATE_PARTY_SITE');
            END IF;

            -- write to log
            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_STATEMENT
                 ,L_MODULE || ' Result of CREATE_PARTY_SITE'
                 ,' New Party Site Id '|| NEW_PS_ID_LIST(I) ||
                  ' result status ' || l_return_status ||
                  ' x_msg_data ' || x_msg_data);
            END IF; -- end of statement level debug

            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

          --Call the API to create the site use
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'begin debug call CREATE_PARTY_SITE_USE');
          END IF;

          CREATE_PARTY_SITE_USE(
            p_init_msg_list          => p_init_msg_list,
            p_party_site_id          => NEW_PS_ID_LIST(I),
            p_old_party_site_use_id  => IS_ID_LIST(I),
            x_new_party_site_use_id  => NEW_IS_ID_LIST(I),
            x_return_status          => l_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'end debug call CREATE_PARTY_SITE_USE');
          END IF;

          -- write to log
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_STATEMENT
               ,L_MODULE || ' Result of CREATE_PARTY_SITE_USE'
               ,' New Party Site Use Id '|| NEW_IS_ID_LIST(I) ||
                ' result status ' || l_return_status ||
                ' x_msg_data ' || x_msg_data);
          END IF; -- end of statement level debug

          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      ELSE
        NEW_IS_ID_LIST(I) := NULL;
      END IF;
    END LOOP;

    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y'
    THEN
      FORALL I in 1..ASSET_ID_LIST.COUNT
        INSERT INTO HZ_CUSTOMER_MERGE_LOG (
          MERGE_LOG_ID,
          TABLE_NAME,
          MERGE_HEADER_ID,
          PRIMARY_KEY_ID,
          NUM_COL1_ORIG,
          NUM_COL1_NEW,
          ACTION_FLAG,
          REQUEST_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY
        )VALUES(
          HZ_CUSTOMER_MERGE_LOG_S.nextval,
          'OKL_ASSETS_B',
          p_merge_header_id,
          ASSET_ID_LIST(I),
          IS_ID_LIST(I),
          NEW_IS_ID_LIST(I),
          'U',
          req_id,
          hz_utility_pub.CREATED_BY,
          hz_utility_pub.CREATION_DATE,
          hz_utility_pub.LAST_UPDATE_LOGIN,
          hz_utility_pub.LAST_UPDATE_DATE,
          hz_utility_pub.LAST_UPDATED_BY);
    END IF;

    FORALL I IN 1..ASSET_ID_LIST.COUNT
      UPDATE OKL_ASSETS_B SET
            INSTALL_SITE_ID = NEW_IS_ID_LIST(I)
          , LAST_UPDATE_DATE = SYSDATE
          , last_updated_by = arp_standard.profile.user_id
          , last_update_login = arp_standard.profile.last_update_login
      WHERE ID = ASSET_ID_LIST(I);

    x_return_status := l_return_status;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OTHERS
    THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END UPDATE_ASSET_LOCATION;

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name	: OKL_INSURANCE_PARTY_MERGE
  -- Description	: To merge Insurance Provider
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE OKL_INSURANCE_PARTY_MERGE(
           p_entity_name                IN   VARCHAR2,
           p_from_id                    IN   NUMBER,
           x_to_id                      OUT NOCOPY  NUMBER,
           p_from_fk_id                 IN    NUMBER,
           p_to_fk_id                   IN   NUMBER,
           p_parent_entity_name         IN   VARCHAR2,
           p_batch_id                   IN   NUMBER,
           p_batch_party_id             IN   NUMBER,
           x_return_status              OUT NOCOPY  VARCHAR2)
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_PARTY_MERGE';
    l_count                      NUMBER(10)   := 0;
  BEGIN
    fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_MERGE');
    arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
    into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id

    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);

        UPDATE OKL_INS_POLICIES_ALL_B IPYB
        SET IPYB.ISU_ID = p_to_fk_id
          , IPYB.object_version_number = IPYB.object_version_number + 1
          , IPYB.last_update_date      = SYSDATE
          , IPYB.last_updated_by       = arp_standard.profile.user_id
          , IPYB.last_update_login     = arp_standard.profile.last_update_login
        WHERE IPYB.ISU_ID = p_from_fk_id
          AND IPY_TYPE = 'THIRD_PARTY_POLICY';

        x_to_id := p_from_id;
        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
            'OKL_INS_POLICIES for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END OKL_INSURANCE_PARTY_MERGE ;

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name	: OKL_INSURANCE_PARTY_SITE_MERGE
  -- Description	:To merge Insurance Agency Site
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE OKL_INSURANCE_PARTY_SITE_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_PARTY_SITE_MERGE';
    l_count                      NUMBER(10)   := 0;
  BEGIN
    fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_SITE_MERGE');
    arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_PARTY_SITE_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
    into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
	  -- if reason code is duplicate then allow the party merge to happen without
	  -- any validations.
	  null;
    else
	  -- if there are any validations to be done, include it in this section
	  null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
	  x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id

    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);

        UPDATE OKL_INS_POLICIES_ALL_B IPYB
        SET IPYB.AGENCY_SITE_ID = p_to_fk_id
          , IPYB.object_version_number = IPYB.object_version_number + 1
          , IPYB.last_update_date      = SYSDATE
          , IPYB.last_updated_by       = arp_standard.profile.user_id
          , IPYB.last_update_login     = arp_standard.profile.last_update_login
        WHERE IPYB.AGENCY_SITE_ID = p_from_fk_id
          AND IPY_TYPE = 'THIRD_PARTY_POLICY';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
            'OKL_INS_POLICIES for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END OKL_INSURANCE_PARTY_SITE_MERGE ;

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name	: OKL_INSURANCE_AGENT_MERGE
  -- Description	:To merge Insurance Agent
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE OKL_INSURANCE_AGENT_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_AGENT_MERGE';
    l_count                      NUMBER(10)   := 0;
  BEGIN
    fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_MERGE');
    arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
    into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
	  -- if reason code is duplicate then allow the party merge to happen without
	  -- any validations.
	  null;
    else
	  -- if there are any validations to be done, include it in this section
	  null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
	  x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id

    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);

        UPDATE OKL_INS_POLICIES_ALL_B IPYB
        SET IPYB.INT_ID = p_to_fk_id
          , IPYB.object_version_number = IPYB.object_version_number + 1
          , IPYB.last_update_date      = SYSDATE
          , IPYB.last_updated_by       = arp_standard.profile.user_id
          , IPYB.last_update_login     = arp_standard.profile.last_update_login
        WHERE IPYB.INT_ID = p_from_fk_id
          AND IPY_TYPE = 'THIRD_PARTY_POLICY';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
          when others then
            arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
            fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
              'OKL_INS_POLICIES for = '|| p_from_id));
            fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
            x_return_status :=  FND_API.G_RET_STS_ERROR;
        end;
      end if;
  END OKL_INSURANCE_AGENT_MERGE ;

  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name	: OKL_INSURANCE_AGENT_SITE_MERGE
  -- Description	:To merge Insurance Agent Site
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
  PROCEDURE OKL_INSURANCE_AGENT_SITE_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_api_name                   VARCHAR2(30) := 'OKL_INSURANCE_AGENT_SITE_MERGE';
    l_count                      NUMBER(10)   := 0;
  BEGIN
    fnd_file.put_line(fnd_file.log, 'OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_SITE_MERGE');
    arp_message.set_line('OKL_INSURANCE_POLICIES_PVT.OKL_INSURANCE_AGENT_SITE_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
    into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
	  -- if reason code is duplicate then allow the party merge to happen without
	  -- any validations.
	  null;
    else
	  -- if there are any validations to be done, include it in this section
	  null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_INS_POLICIES',FALSE);

        UPDATE OKL_INS_POLICIES_ALL_B IPYB
        SET IPYB.AGENT_SITE_ID = p_to_fk_id
          , IPYB.object_version_number = IPYB.object_version_number + 1
          , IPYB.last_update_date      = SYSDATE
          , IPYB.last_updated_by       = arp_standard.profile.user_id
          , IPYB.last_update_login     = arp_standard.profile.last_update_login
        WHERE IPYB.AGENT_SITE_ID = p_from_fk_id
          AND IPY_TYPE = 'THIRD_PARTY_POLICY';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
            'OKL_INS_POLICIES for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END OKL_INSURANCE_AGENT_SITE_MERGE ;

  ---------------------------------------------------
  ----------- API BODY-----------------------------
  ----------------------------------------------------
  ---- Party Merge
  PROCEDURE OKL_OPEN_INT_PARTY_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
  IS
   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'OKL_OPEN_INT_PARTY_MERGE';
   l_count                      NUMBER(10)   := 0;
  BEGIN
   fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.OKL_OPEN_INT_PARTY_MERGE');
   arp_message.set_line('OKL_PARTY_MERGE_PUB.OKL_OPEN_INT_PARTY_MERGE()+');
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- If the parent has not changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return
   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id
   if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_OPEN_INT_ALL',FALSE);

  UPDATE OKL_OPEN_INT_ALL opi
  SET opi.party_ID = p_to_fk_id
     ,opi.party_name = (select party_name from hz_parties where party_id = p_to_fk_id)
     ,opi.party_type = (select party_type from hz_parties where party_id = p_to_fk_id)
     ,opi.object_version_number = opi.object_version_number + 1
     ,opi.last_update_date      = SYSDATE
     ,opi.last_updated_by       = arp_standard.profile.user_id
     ,opi.last_update_login     = arp_standard.profile.last_update_login
  WHERE opi.party_ID = p_from_fk_id ;

  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  exception
    when others then
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_OPEN_INT_ALL for = '|| p_from_id));
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      x_return_status :=  FND_API.G_RET_STS_ERROR;
  end;
 end if;
END OKL_OPEN_INT_PARTY_MERGE ;

  -- Start BAKUCHIB Bug#2892149
  -- Start of comments
  --
  -- Procedure Name       : party_merge_pac_id
  -- Description          : Procedure to merge Relocate Assets for PAC_ID
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : BAKUCHIB 14-APR-03 Bug #2892149 Created
  -- End of comments
  PROCEDURE party_merge_pac_id (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
    IS
    l_merge_reason_code          VARCHAR2(30);
    l_count                      NUMBER(10)   := 0;
    l_api_name                   VARCHAR2(30) := 'PARTY_MERGE_PAC_ID';
  BEGIN
    FND_FILE.put_line(fnd_file.log, 'OKL_AM_SHIPPING_INSTR_PVT.PARTY_MERGE_PAC_ID');
    ARP_MESSAGE.set_line('OKL_AM_SHIPPING_INSTR_PVT.PARTY_MERGE_PAC_ID()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code
    INTO   l_merge_reason_code
    FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen
      -- without any validations.
      NULL;
    ELSE
      -- if there are any validations to be done, include it in this section
      NULL;
    END IF;

    -- If the parent has not changed (ie. Parent getting transferred) then
    -- nothing needs to be done. Set Merged To Id is same as Merged From Id
    -- and return
    IF p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      RETURN;
    END IF;
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a
    -- similar dependent record exists on the new parent. If a duplicate
    -- exists then do not transfer and return the id of the duplicate record
    -- as the Merged To Id
    IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
        ARP_MESSAGE.set_name('AR','AR_UPDATING_TABLE');
        ARP_MESSAGE.set_token('TABLE_NAME','OKL_RELOCATE_ASTS_ALL_B',FALSE);
        UPDATE OKL_RELOCATE_ASTS_ALL_B RAB
        SET RAB.PAC_ID = p_to_fk_id,
        RAB.object_version_number = RAB.object_version_number + 1,
        RAB.last_update_date      = SYSDATE,
        RAB.last_updated_by       = arp_standard.profile.user_id,
        RAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE RAB.PAC_ID = p_from_fk_id ;
        l_count := sql%rowcount;
        ARP_MESSAGE.set_name('AR','AR_ROWS_UPDATED');
        ARP_MESSAGE.set_token('NUM_ROWS',to_char(l_count));
      EXCEPTION
        WHEN OTHERS THEN
          ARP_MESSAGE.set_line(G_PKG_NAME|| '.' ||l_api_name||': '|| sqlerrm);
          FND_FILE.put_line(FND_FILE.log,
                           (G_PKG_NAME|| '.'||l_api_name ||'OKL_RELOCATE_ASTS_ALL_B for = '|| p_from_id));
          FND_FILE.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END party_merge_pac_id ;

  -- Start of comments
  -- Procedure Name       : party_merge_ist_id
  -- Description          : Procedure to merge Relocate Assets for IST_ID
  -- Business Rules       :
  -- Parameters           :
  -- Version              : 1.0
  -- History              : BAKUCHIB 14-APR-03 Bug #2892149 Created
  -- End of comments
  PROCEDURE party_merge_ist_id (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_count                      NUMBER(10)   := 0;
    l_api_name                   VARCHAR2(30) := 'PARTY_MERGE_IST_ID';
  BEGIN
    FND_FILE.put_line(fnd_file.log, 'OKL_AM_SHIPPING_INSTR_PVT.PARTY_MERGE_IST_ID');
    ARP_MESSAGE.set_line('OKL_AM_SHIPPING_INSTR_PVT.PARTY_MERGE_IST_ID()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code
    INTO   l_merge_reason_code
    FROM   hz_merge_batch
    WHERE  batch_id  = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen
      -- without any validations.
      NULL;
    ELSE
      -- if there are any validations to be done, include it in this section
      NULL;
    END IF;

    -- If the parent has not changed (ie. Parent getting transferred) then
    -- nothing needs to be done. Set Merged To Id is same as Merged From Id
    -- and return

    IF p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      RETURN;
    END IF;
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a
    -- similar dependent record exists on the new parent. If a duplicate
    -- exists then do not transfer and return the id of the duplicate record
    -- as the Merged To Id
    IF p_from_fk_id <> p_to_fk_id THEN
      BEGIN
        ARP_MESSAGE.set_name('AR','AR_UPDATING_TABLE');
        ARP_MESSAGE.set_token('TABLE_NAME','OKL_RELOCATE_ASTS_ALL_B',FALSE);
        UPDATE OKL_RELOCATE_ASTS_ALL_B RAB
        SET RAB.IST_ID = p_to_fk_id,
        RAB.object_version_number = RAB.object_version_number + 1,
        RAB.last_update_date      = SYSDATE,
        RAB.last_updated_by       = arp_standard.profile.user_id,
        RAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE RAB.IST_ID = p_from_fk_id ;
        l_count := sql%rowcount;
        ARP_MESSAGE.set_name('AR','AR_ROWS_UPDATED');
        ARP_MESSAGE.set_token('NUM_ROWS',to_char(l_count));
      EXCEPTION
        WHEN OTHERS THEN
          ARP_MESSAGE.set_line(G_PKG_NAME|| '.' ||l_api_name||': '|| sqlerrm);
          FND_FILE.put_line(FND_FILE.log,
                           (G_PKG_NAME|| '.'||l_api_name ||'OKL_RELOCATE_ASTS_ALL_B for = '|| p_from_id));
          FND_FILE.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END party_merge_ist_id ;
  -- End BAKUCHIB Bug#2892149

  --start merge code pjgomes
  PROCEDURE okl_cnr_party_merge (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
  IS
   l_api_name                   VARCHAR2(30) := 'okl_cnr_party_merge';
  BEGIN
    fnd_file.put_line(fnd_file.log, 'okl_cnr_pvt.okl_cnr_party_merge');
    arp_message.set_line('okl_cnr_pvt.okl_cnr_party_merge()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   --OKL_CNSLD_AR_HDRS_ALL_B stores reference to Customer Account Site Usage in column IBT_ID
   --Account Merge logic is moved to CNR_ACCOUNT_MERGE API which is called during
   --Account Merge process

  exception
    when others then
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
        'OKL_CNR_PVT for = '|| p_from_id));
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      x_return_status :=  FND_API.G_RET_STS_ERROR;
  END okl_cnr_party_merge;

  PROCEDURE OKL_XSI_PARTY_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
  IS
   l_api_name                   VARCHAR2(30) := 'OKL_XSI_PARTY_MERGE';
  BEGIN
    fnd_file.put_line(fnd_file.log, 'Okl_Xsi_Pvt.OKL_XSI_PARTY_MERGE');
    arp_message.set_line('Okl_Xsi_Pvt.OKL_XSI_PARTY_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   --OKL_EXT_SELL_INVS_ALL_B stores reference to Customer Account in column CUSTOMER_ID
   --Account Merge logic is moved to XSI_ACCOUNT_MERGE API which is called during
   --Account Merge process

  exception
    when others then
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
        'OKL_XSI_PARTY_MERGE for = '|| p_from_id));
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      x_return_status :=  FND_API.G_RET_STS_ERROR;
  END OKL_XSI_PARTY_MERGE ;

  PROCEDURE OKL_TAI_PARTY_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2)
  IS
   l_api_name                   VARCHAR2(30) := 'OKL_TAI_PARTY_MERGE';
  BEGIN
   fnd_file.put_line(fnd_file.log, 'Okl_Tai_Pvt.OKL_TAI_PARTY_MERGE');
   arp_message.set_line('Okl_Tai_Pvt.OKL_TAI_PARTY_MERGE()+');
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   --OKL_TRX_AR_INVOICES_B stores reference to Customer Account Site Use in column IBT_ID
   --Account Merge logic is moved to TAI_ACCOUNT_MERGE API which is called during
   --Account Merge process

  exception
    when others then
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
        'OKL_TAI_PARTY_MERGE for = '|| p_from_id));
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      x_return_status :=  FND_API.G_RET_STS_ERROR;
  END OKL_TAI_PARTY_MERGE;

  --start merge code pjgomes
  --procedure for install at site  merge routine for party merge
  -- impacted entity :OKL_TXL_ITM_INSTS
  Procedure OKL_INSTALL_SITE_MERGE
    (p_entity_name                IN   VARCHAR2,
     p_from_id                    IN   NUMBER,
     x_to_id                      OUT NOCOPY  NUMBER,
     p_from_fk_id                 IN   NUMBER,
     p_to_fk_id                   IN   NUMBER,
     p_parent_entity_name         IN   VARCHAR2,
     p_batch_id                   IN   NUMBER,
     p_batch_party_id             IN   NUMBER,
     x_return_status              OUT NOCOPY  VARCHAR2)
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_api_name                   VARCHAR2(30) := 'OKL_INSTALL_SITE_MERGE';
    l_count                      NUMBER(10)   := 0;
  BEGIN
    fnd_file.put_line(fnd_file.log, 'OKL_LLA_UTIL_PVT.INSTALL_AT_SITE_MERGE');
    arp_message.set_line('OKL_LLA_UTIL_PVT.INSTALL_AT_SITE_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
    into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
    else
	 -- if there are any validations to be done, include it in this section
	 null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TXL_ITM_INSTS',FALSE);

        UPDATE okl_txl_itm_insts iti
        SET iti.object_id1_old = p_to_fk_id
          , iti.object_version_number = iti.object_version_number + 1
          , iti.last_update_date      = SYSDATE
          , iti.last_updated_by       = arp_standard.profile.user_id
          , iti.last_update_login     = arp_standard.profile.last_update_login
        WHERE iti.object_id1_old      = p_from_fk_id
          AND JTOT_OBJECT_CODE_OLD = 'OKX_PARTSITE';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
	      fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_INSTALL_SITE_MERGE for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END OKL_INSTALL_SITE_MERGE ;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : ITI_OBJECT_ID1_NEW
  -- Description     : Updating the table: OKL_TXL_ITM_INSTS for column: OBJECT_ID1_NEW
  -- Business Rules  : performing PARTY MERGE for table: OKL_TXL_ITM_INSTS and col: OBJECT_ID1_NEW
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE ITI_OBJECT_ID1_NEW(
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
    l_merge_reason_code          VARCHAR2(30);
    l_api_name                   VARCHAR2(30) := 'ITI_OBJECT_ID1_NEW';
    l_count                      NUMBER(10)   := 0;
  BEGIN
    --Log statements for all input parameters and the procedure name
    fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.ITI_OBJECT_ID1_NEW');
    fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
    fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
    fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
    fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
    fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
    fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
    fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
    fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.ITI_OBJECT_ID1_NEW()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TXL_ITM_INSTS',FALSE);

        IF p_parent_entity_name = 'HZ_PARTY_SITE_USES'
        THEN
          --updating the OKL_TXL_ITM_INSTS table for column references PROSPECT_ID
          UPDATE OKL_TXL_ITM_INSTS TAB
            SET TAB.object_id1_new = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.object_id1_new = p_from_fk_id
          AND JTOT_OBJECT_CODE_NEW = 'OKX_PARTSITE';
        END IF;
        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      EXCEPTION
        when others
        then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_ITM_INSTS for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END ITI_OBJECT_ID1_NEW ;

  ---- Party Merge
  PROCEDURE OKL_RCA_PARTY_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2)
  IS
    l_api_name                   VARCHAR2(30) := 'OKL_RCA_PARTY_MERGE';
  BEGIN
    fnd_file.put_line(fnd_file.log, 'OKL_RCA_PVT.OKL_RCA_PARTY_MERGE');
    arp_message.set_line('OKL_RCA_PVT.OKL_RCA_PARTY_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    --OKL_TXL_RCPT_APPS_ALL_B stores reference to Customer Account in column ILE_ID
    --Account Merge logic is moved to RCA_ACCOUNT_MERGE API which is called during
    --Account Merge process

  exception
    when others then
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
	       'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      x_return_status :=  FND_API.G_RET_STS_ERROR;
  END OKL_RCA_PARTY_MERGE;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : ASS_INSTALL_SITE_ID
-- Description     : Updating the table: OKL_ASSETS_B for column: INSTALL_SITE_ID
-- Business Rules  : performing PARTY MERGE for table: OKL_ASSETS_B and col: INSTALL_SITE_ID
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE ASS_INSTALL_SITE_ID (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'ASS_INSTALL_SITE_ID';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.ASS_INSTALL_SITE_ID');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.ASS_INSTALL_SITE_ID()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return

        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id

        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_ASSETS_B',FALSE);

        --updating the OKL_ASSETS_B table for column references INSTALL_SITE_ID

        UPDATE OKL_ASSETS_B TAB
           SET TAB.INSTALL_SITE_ID = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.INSTALL_SITE_ID = p_from_fk_id ;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_ASSETS_B for INSTALL_SITE_ID = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END ASS_INSTALL_SITE_ID ;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : LAP_PARTY_MERGE
-- Description     : Updating the table: OKL_LEASE_APPS_ALL_B for column:
--                   PROSPECT_ID and PROSPECT_ADDRESS_ID
-- Business Rules  : performing PARTY MERGE for table: OKL_LEASE_APPS_ALL_B
--                   and col: PROSPECT_ID and PROSPECT_ADDRESS_ID
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE LAP_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'LAP_PARTY_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
    --Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.LAP_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.LAP_PROSPECT_ID()+');

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_LEASE_APPS_ALL_B',FALSE);

        IF p_parent_entity_name = 'HZ_PARTIES'
        THEN
          --updating the OKL_LEASE_APPS_ALL_B table for column references PROSPECT_ID
          UPDATE OKL_LEASE_APPS_ALL_B TAB
            SET TAB.PROSPECT_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.PROSPECT_ID = p_from_fk_id;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKL_LEASE_APPS_ALL_B table for column references PROSPECT_ADDRESS_ID
          UPDATE OKL_LEASE_APPS_ALL_B TAB
            SET TAB.PROSPECT_ADDRESS_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.PROSPECT_ADDRESS_ID = p_from_fk_id ;
        END IF;
        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      EXCEPTION
        when others
        then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_LEASE_APPS_ALL_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END LAP_PARTY_MERGE ;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : LOP_PARTY_MERGE
-- Description     : Updating the table: OKL_LEASE_OPPS_ALL_B for column:
--                   PROSPECT_ID, PROSPECT_ADDRESS_ID, INSTALL_SITE_ID and USAGE_LOCATION_ID
-- Business Rules  : performing PARTY MERGE for table: OKL_LEASE_OPPS_ALL_B
--                   and col: PROSPECT_ID, PROSPECT_ADDRESS_ID, INSTALL_SITE_ID and USAGE_LOCATION_ID
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE LOP_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'LOP_PARTY_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.LOP_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.LOP_PARTY_MERGE()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE'
    then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_LEASE_OPPS_ALL_B',FALSE);

        IF p_parent_entity_name = 'HZ_PARTIES'
        THEN
          --updating the OKL_LEASE_OPPS_ALL_B table for column references PROSPECT_ID
          UPDATE OKL_LEASE_OPPS_ALL_B TAB
            SET TAB.PROSPECT_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.PROSPECT_ID = p_from_fk_id ;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKL_LEASE_OPPS_ALL_B table for column references PROSPECT_ADDRESS_ID
          UPDATE OKL_LEASE_OPPS_ALL_B TAB
            SET TAB.PROSPECT_ADDRESS_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.PROSPECT_ADDRESS_ID = p_from_fk_id ;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITE_USES'
        THEN
          --updating the OKL_LEASE_OPPS_ALL_B table for column references INSTALL_SITE_ID
          UPDATE OKL_LEASE_OPPS_ALL_B TAB
            SET TAB.INSTALL_SITE_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.INSTALL_SITE_ID = p_from_fk_id ;
        END IF;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      exception
        when others
        then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_LEASE_OPPS_ALL_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END LOP_PARTY_MERGE ;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : LOP_USAGE_LOCATION
-- Description     : Updating the table: OKL_LEASE_OPPS_ALL_B for column:
--                   USAGE_LOCATION_ID
-- Business Rules  : performing PARTY MERGE for table: OKL_LEASE_OPPS_ALL_B
--                   and col: USAGE_LOCATION_ID
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE LOP_USAGE_LOCATION (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'LOP_USAGE_LOCATION';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.LOP_USAGE_LOCATION');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.LOP_USAGE_LOCATION()+');
	x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE'
    then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_LEASE_OPPS_ALL_B',FALSE);

        IF p_parent_entity_name = 'HZ_PARTY_SITE_USES'
        THEN
          --updating the OKL_LEASE_OPPS_ALL_B table for column references USAGE_LOCATION_ID
          UPDATE OKL_LEASE_OPPS_ALL_B TAB
            SET TAB.USAGE_LOCATION_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.USAGE_LOCATION_ID = p_from_fk_id ;
        END IF;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      exception
        when others
        then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_LEASE_OPPS_ALL_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END LOP_USAGE_LOCATION ;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXS_BILL_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES for column:
  --                   BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES
  --                   and col: BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXS_BILL_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TXS_BILL_TO_PARTY_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TXS_BILL_TO_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.TXS_BILL_TO_PARTY_MERGE()+');
	x_return_status :=  FND_API.G_RET_STS_SUCCESS;

	select merge_reason_code
    into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      --if reason code is duplicate then allow the party merge to happen without
      --any validations.
      null;
    else
      --if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TAX_SOURCES',FALSE);

        IF p_parent_entity_name = 'HZ_PARTIES'
        THEN
          --updating the OKL_TAX_SOURCES table for column references BILL_TO_PARTY_ID
          UPDATE OKL_TAX_SOURCES TAB
            SET TAB.BILL_TO_PARTY_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.BILL_TO_PARTY_ID = p_from_fk_id ;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKL_TAX_SOURCES table for column references BILL_TO_PARTY_SITE_ID
          UPDATE OKL_TAX_SOURCES TAB
            SET TAB.BILL_TO_PARTY_SITE_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.BILL_TO_PARTY_SITE_ID = p_from_fk_id ;
        END IF;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
            'OKL_TAX_SOURCES for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END TXS_BILL_TO_PARTY_MERGE ;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXS_SHIP_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES for column:
  --                   SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES
  --                   and col: SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXS_SHIP_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TXS_SHIP_TO_PARTY_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TXS_SHIP_TO_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.TXS_SHIP_TO_PARTY_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return

        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id

    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TAX_SOURCES',FALSE);

        IF p_parent_entity_name = 'HZ_PARTIES'
        THEN
          --updating the OKL_TAX_SOURCES table for column references SHIP_TO_PARTY_ID
          UPDATE OKL_TAX_SOURCES TAB
            SET TAB.SHIP_TO_PARTY_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.SHIP_TO_PARTY_ID = p_from_fk_id ;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKL_TAX_SOURCES table for column references SHIP_TO_PARTY_SITE_ID
          UPDATE OKL_TAX_SOURCES TAB
            SET TAB.SHIP_TO_PARTY_SITE_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.SHIP_TO_PARTY_SITE_ID = p_from_fk_id ;
        END IF;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END TXS_SHIP_TO_PARTY_MERGE ;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXST_BILL_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES_T for column:
  --                   BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES_T
  --                   and col: BILL_TO_PARTY_ID and BILL_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXST_BILL_TO_PARTY_MERGE(
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TXST_BILL_TO_PARTY_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TXST_BILL_TO_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.TXST_BILL_TO_PARTY_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
      into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
    else
        -- if there are any validations to be done, include it in this section
        null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id

    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TAX_SOURCES_T',FALSE);

        IF p_parent_entity_name = 'HZ_PARTIES'
        THEN
          --updating the OKL_TAX_SOURCES_T table for column references BILL_TO_PARTY_ID
          UPDATE OKL_TAX_SOURCES_T TAB
            SET TAB.BILL_TO_PARTY_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.BILL_TO_PARTY_ID = p_from_fk_id ;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKL_TAX_SOURCES_T table for column references BILL_TO_PARTY_SITE_ID
          UPDATE OKL_TAX_SOURCES_T TAB
            SET TAB.BILL_TO_PARTY_SITE_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.BILL_TO_PARTY_SITE_ID = p_from_fk_id ;
        END IF;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

      exception
        when others then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
            'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
          fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      end;
    end if;
  END TXST_BILL_TO_PARTY_MERGE ;

  ------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : TXST_SHIP_TO_PARTY_MERGE
  -- Description     : Updating the table: OKL_TAX_SOURCES_T for column:
  --                   SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Business Rules  : performing PARTY MERGE for table: OKL_TAX_SOURCES_T
  --                   and col: SHIP_TO_PARTY_ID and SHIP_TO_PARTY_SITE_ID
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE TXST_SHIP_TO_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TXST_SHIP_TO_PARTY_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TXST_SHIP_TO_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.TXST_SHIP_TO_PARTY_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code
      into   l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
    else
        -- if there are any validations to be done, include it in this section
        null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id

    if p_from_fk_id <> p_to_fk_id then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKL_TAX_SOURCES_T',FALSE);

        IF p_parent_entity_name = 'HZ_PARTIES'
        THEN
          --updating the OKL_TAX_SOURCES_T table for column references SHIP_TO_PARTY_ID
          UPDATE OKL_TAX_SOURCES_T TAB
            SET TAB.SHIP_TO_PARTY_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.SHIP_TO_PARTY_ID = p_from_fk_id ;
        ELSIF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKL_TAX_SOURCES_T table for column references SHIP_TO_PARTY_SITE_ID
          UPDATE OKL_TAX_SOURCES_T TAB
            SET TAB.SHIP_TO_PARTY_SITE_ID = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.SHIP_TO_PARTY_SITE_ID = p_from_fk_id;
        END IF;

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END TXST_SHIP_TO_PARTY_MERGE ;

----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : TCN_PARTY_REL_ID2_NEW
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID2_NEW
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID2_NEW
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE TCN_PARTY_REL_ID2_NEW (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TCN_PARTY_REL_ID2_NEW';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID2_NEW');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID2_NEW()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return

        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id

        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_TRX_CONTRACTS_ALL',FALSE);

        --updating the OKL_TRX_CONTRACTS_ALL table for column references PARTY_REL_ID2_NEW

        UPDATE OKL_TRX_CONTRACTS_ALL TAB
           SET TAB.PARTY_REL_ID2_NEW = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.PARTY_REL_ID2_NEW = to_char(p_from_fk_id); -- MGAAP 7263041
--rkuttiya added for 12.1.1 multi gaap project
        --AND   TAB.REPRESENTATION_TYPE = 'PRIMARY' ;
--

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END TCN_PARTY_REL_ID2_NEW ;

----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : QPY_PARTY_OBJECT1_ID1
-- Description     : Updating the table: OKL_QUOTE_PARTIES for column: PARTY_OBJECT1_ID1
-- Business Rules  : performing PARTY MERGE for table: OKL_QUOTE_PARTIES and col: PARTY_OBJECT1_ID1
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE QPY_PARTY_OBJECT1_ID1 (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'QPY_PARTY_OBJECT1_ID1';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.QPY_PARTY_OBJECT1_ID1');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.QPY_PARTY_OBJECT1_ID1()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return
         if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id
        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_QUOTE_PARTIES',FALSE);

        --updating the OKL_QUOTE_PARTIES table for column references PARTY_OBJECT1_ID1

        UPDATE OKL_QUOTE_PARTIES TAB
           SET TAB.PARTY_OBJECT1_ID1 = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.PARTY_OBJECT1_ID1 = to_char(p_from_fk_id)
        AND PARTY_JTOT_OBJECT1_CODE = 'OKX_PARTY';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END QPY_PARTY_OBJECT1_ID1 ;

----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : QPY_CONTACT_OBJECT1_ID1
-- Description     : Updating the table: OKL_QUOTE_PARTIES for column: CONTACT_OBJECT1_ID1
-- Business Rules  : performing PARTY MERGE for table: OKL_QUOTE_PARTIES and col: CONTACT_OBJECT1_ID1
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE QPY_CONTACT_OBJECT1_ID1 (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'QPY_CONTACT_OBJECT1_ID1';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.QPY_CONTACT_OBJECT1_ID1');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.QPY_CONTACT_OBJECT1_ID1()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return
        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id
        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_QUOTE_PARTIES',FALSE);

        --updating the OKL_QUOTE_PARTIES table for column references CONTACT_OBJECT1_ID1

        UPDATE OKL_QUOTE_PARTIES TAB
           SET TAB.CONTACT_OBJECT1_ID1 = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.CONTACT_OBJECT1_ID1 = to_char(p_from_fk_id)
        AND CONTACT_JTOT_OBJECT1_CODE = 'OKX_PARTY';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END QPY_CONTACT_OBJECT1_ID1 ;

----------------------------------------------------------------------------------------------------------
-- Start of comments

-- Procedure Name  : TIN_PARTY_OBJECT_ID1
-- Description     : Updating the table: OKL_TERMNT_INTF_PTY for column: PARTY_OBJECT_ID1
-- Business Rules  : performing PARTY MERGE for table: OKL_TERMNT_INTF_PTY and col: PARTY_OBJECT_ID1
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE TIN_PARTY_OBJECT_ID1 (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TIN_PARTY_OBJECT_ID1';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TIN_PARTY_OBJECT_ID1');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.TIN_PARTY_OBJECT_ID1()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return
         if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id
        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_TERMNT_INTF_PTY',FALSE);

        --updating the OKL_TERMNT_INTF_PTY table for column references PARTY_OBJECT_ID1

        UPDATE OKL_TERMNT_INTF_PTY TAB
           SET TAB.PARTY_OBJECT_ID1 = p_to_fk_id
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.PARTY_OBJECT_ID1 = to_char(p_from_fk_id)
        AND PARTY_OBJECT_CODE = 'OKX_PARTY';

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKL_TXL_RCPT_APPS_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END TIN_PARTY_OBJECT_ID1 ;

  ----------------------------------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : CPL_PARTY_MERGE
  -- Description     : Updating the table: OKC_K_PARTY_ROLES_B for column: OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKC_K_PARTY_ROLES_B and col: OBJECT1_ID1
  --                   for the records created for Lease Management
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  -----------------------------------------------------------------------------------------------------------
  PROCEDURE CPL_PARTY_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2)
  IS
    l_api_version   CONSTANT NUMBER       DEFAULT 1.0;
    p_init_msg_list          VARCHAR2(1)  DEFAULT FND_API.G_FALSE;
    p_msg_count              NUMBER;
    p_msg_data               VARCHAR2(1000);
    l_return_status          VARCHAR2(1);
    l_merge_reason_code      VARCHAR2(30);
    l_api_name               VARCHAR2(30) := 'CPL_PARTY_MERGE';
    l_count                  NUMBER;
    l_cplv_rec               OKC_CPL_PVT.cplv_rec_type;
    l_kplv_rec               OKL_KPL_PVT.kplv_rec_type;

    --start NISINHA Bug# 6655434 declaring variables for storing source and destination party names
    l_src_party_name hz_parties.party_name%type;
    l_des_party_name hz_parties.party_name%type;

    --This cursor is used to get the party name based on the party id.
    CURSOR c_get_party_name(p_party_id IN NUMBER) IS
    SELECT party_name FROM hz_parties WHERE party_id = p_party_id;
    -- end NISINHA Bug#6655434

    --This cursor fetches all those contracts, which have both source and destination
    --Parties as the parties to the contract at header or line level
    CURSOR chk_vendor_chr_csr (p_src_party_id NUMBER, p_des_party_id NUMBER)
    IS
      SELECT CHR.CONTRACT_NUMBER
           , CHR.ID
           , NULL CLE_ID
           , CHR.SCS_CODE
           , SC.MEANING SCS_MEANING
           , CPRS.RLE_CODE
           , RLE.MEANING RLE_MEANING
           , CPRS.ID CPRS_CPL_ID
           , CPRD.ID CPRD_CPL_ID
           , CPRS.OBJECT1_ID1 CPRS_OBJECT1_ID1
           , CPRD.OBJECT1_ID1 CPRD_OBJECT1_ID1
      FROM OKC_K_HEADERS_ALL_B CHR
         , OKC_K_PARTY_ROLES_B CPRS
         , OKC_K_PARTY_ROLES_B CPRD
         , OKC_SUBCLASSES_V SC
         , FND_LOOKUPS RLE
      WHERE CPRS.CHR_ID = CHR.ID
        AND CPRS.DNZ_CHR_ID = CPRD.DNZ_CHR_ID
        AND CPRS.CHR_ID = CPRD.CHR_ID
        AND CPRS.RLE_CODE = CPRD.RLE_CODE
        AND CPRS.OBJECT1_ID1 <> CPRD.OBJECT1_ID1
        AND CPRS.OBJECT1_ID1 = p_src_party_id
        AND CPRD.OBJECT1_ID1 = p_des_party_id
        AND CPRS.JTOT_OBJECT1_CODE = 'OKX_PARTY'
        AND CPRD.JTOT_OBJECT1_CODE = 'OKX_PARTY'
        AND CHR.SCS_CODE = SC.CODE
        AND SC.CLS_CODE = 'OKL'
        AND RLE.LOOKUP_TYPE = 'OKC_ROLE'
        AND RLE.LOOKUP_CODE = CPRS.RLE_CODE
        AND CPRS.CLE_ID IS NULL
        AND CPRD.CLE_ID IS NULL

      UNION

      SELECT CHR.CONTRACT_NUMBER
           , CHR.ID
           , CPRD.CLE_ID
           , CHR.SCS_CODE
           , SC.MEANING SCS_MEANING
           , CPRS.RLE_CODE
           , RLE.MEANING RLE_MEANING
           , CPRS.ID CPRS_CPL_ID
           , CPRD.ID CPRD_CPL_ID
           , CPRS.OBJECT1_ID1 CPRS_OBJECT1_ID1
           , CPRD.OBJECT1_ID1 CPRD_OBJECT1_ID1
      FROM OKC_K_HEADERS_ALL_B CHR
         , OKC_K_PARTY_ROLES_B CPRS
         , OKC_K_PARTY_ROLES_B CPRD
         , OKC_SUBCLASSES_V SC
         , FND_LOOKUPS RLE
      WHERE CPRS.DNZ_CHR_ID = CHR.ID
        AND CPRS.DNZ_CHR_ID = CPRD.DNZ_CHR_ID
        AND CPRS.OBJECT1_ID1 <> CPRD.OBJECT1_ID1
        AND CPRS.OBJECT1_ID1 = p_src_party_id
        AND CPRD.OBJECT1_ID1 = p_des_party_id
        AND CPRS.JTOT_OBJECT1_CODE = 'OKX_PARTY'
        AND CPRD.JTOT_OBJECT1_CODE = 'OKX_PARTY'
        AND CHR.SCS_CODE = SC.CODE
        AND SC.CLS_CODE = 'OKL'
        AND RLE.LOOKUP_TYPE = 'OKC_ROLE'
        AND RLE.LOOKUP_CODE = CPRS.RLE_CODE
        AND CPRS.CHR_ID IS NULL
        AND CPRD.CHR_ID IS NULL
      ORDER BY CONTRACT_NUMBER;

    chk_vendor_chr_rec chk_vendor_chr_csr%ROWTYPE;
  BEGIN
    l_count := 0;
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);
    --Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.CPL_PARTY_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.CPL_PARTY_MERGE()+');

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'start debug okl_vendormerge_grp.merge_vendor');
    END IF;  -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                        ,fnd_log.level_statement);
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                             ,p_pkg_name      => G_PKG_NAME
                                             ,p_init_msg_list => p_init_msg_list
                                             ,p_api_version   => l_api_version
                                             ,l_api_version   => l_api_version
                                             ,p_api_type      => G_API_TYPE
                                             ,x_return_status => l_return_status);
    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      arp_message.set_name('AR','AR_UPDATING_TABLE');
      arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES_B',FALSE);

      IF p_parent_entity_name = 'HZ_PARTIES'
      THEN
        --Check if the parties to be merged are part of same type of contract
        OPEN chk_vendor_chr_csr(p_from_fk_id, p_to_fk_id);
        LOOP
          FETCH chk_vendor_chr_csr INTO chk_vendor_chr_rec;
          EXIT WHEN chk_vendor_chr_csr%NOTFOUND;
          IF ((chk_vendor_chr_rec.RLE_CODE = 'INVESTOR'
              AND chk_vendor_chr_rec.SCS_CODE IN ('INVESTOR', 'PROGRAM'))
              OR (chk_vendor_chr_rec.RLE_CODE = 'PRIVATE_LABEL'
              AND chk_vendor_chr_rec.SCS_CODE = 'LEASE'))
          THEN
            --If both the parties to be merged are part of same object with given
            --party role then set the message and raise the error.
            --Error should be raised if Party Role is "Investor" and is part of
            --"Investor Agreement" or "Program Agreement". And, also if party role
            --is "Private Label" and is part of "Lease Contracts"

            --Set the Error
	     --start NISINHA Bug#6655434
	     --getting the source party name based on p_from_fk_id
	     OPEN c_get_party_name(p_from_fk_id);
	     FETCH c_get_party_name INTO l_src_party_name;
	     CLOSE c_get_party_name;

	     --getting the des party name based on p_to_fk_id
	     OPEN c_get_party_name(p_to_fk_id);
	     FETCH c_get_party_name INTO l_des_party_name;
	     CLOSE c_get_party_name;

	     -- set the error message to stop the proceeding of party merge
	     OKL_API.SET_MESSAGE
		(
			p_app_name      => G_APP_NAME,
			p_msg_name      => 'OKL_BLOCK_PARTYMERGE_MSG',
			p_token1        => 'SOURCE',
			p_token1_value  => l_src_party_name,
			p_token2        => 'DESTINATION',
			p_token2_value  =>  l_des_party_name,
			p_token3        => 'RLE_CODE',
			p_token3_value  => chk_vendor_chr_rec.RLE_MEANING,
			p_token4        => 'SCS_CODE_MEANING',
			p_token4_value  => chk_vendor_chr_rec.SCS_MEANING,
			p_token5        => 'NAME',
			p_token5_value  => chk_vendor_chr_rec.CONTRACT_NUMBER
		);
	     --end NISINHA Bug#6655434

            l_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF (chk_vendor_chr_rec.RLE_CODE IN ('BROKER', 'DEALER', 'EXTERNAL_PARTY', 'GUARANTOR', 'MANUFACTURER')
                 OR (chk_vendor_chr_rec.RLE_CODE = 'INVESTOR' AND chk_vendor_chr_rec.SCS_CODE = 'OPERATING'))
          THEN
            --If there is no passthrough setup which uses both the vendors at line level
            --then remove the party role using source vendor for the given line.
            l_kplv_rec.id := chk_vendor_chr_rec.CPRS_CPL_ID;
            l_cplv_rec.id := chk_vendor_chr_rec.CPRS_CPL_ID;

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'begin debug call OKL_KPL_PVT.DELETE_ROW');
            END IF;

            --Remove the Party Role at the line level for the vendor getting merged
            --Call the following API to remove the record in OKL
            OKL_KPL_PVT.DELETE_ROW
                 (p_api_version      => l_api_version,
                  p_init_msg_list    => 'F',
                  x_return_status    => l_return_status,
                  x_msg_count        => p_msg_count,
                  x_msg_data         => p_msg_data,
                  p_kplv_rec         => l_kplv_rec);

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'end debug call OKL_KPL_PVT.DELETE_ROW');
            END IF;

            -- write to log
            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_STATEMENT
                 ,L_MODULE || ' Result of OKL_KPL_PVT.DELETE_ROW'
                 ,'l_return_status ' || l_return_status);
            END IF; -- end of statement level debug

            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'begin debug call OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE');
            END IF;

            --Remove the Party Role at the line level for the vendor getting merged
            --Call the following API to remove the record in OKC
            OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE
                 (p_api_version      => l_api_version,
                  p_init_msg_list    => 'F',
                  x_return_status    => l_return_status,
                  x_msg_count        => p_msg_count,
                  x_msg_data         => p_msg_data,
                  p_cplv_rec         => l_cplv_rec);

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'end debug call OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE');
            END IF;

            -- write to log
            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_STATEMENT
                 ,L_MODULE || ' Result of OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE'
                 ,'l_return_status ' || l_return_status);
            END IF; -- end of statement level debug

            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END LOOP;
        CLOSE chk_vendor_chr_csr;
      END IF;
    END IF;

    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  p_msg_count
                        ,x_msg_data  => p_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on)
    THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug okl_vendormerge_grp.merge_vendor');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKC_K_PARTY_ROLES_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      IF chk_vendor_chr_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_csr;
      END IF;

      --start NISINHA Bug#6655434 closing the cursor in exception block
      IF c_get_party_name%ISOPEN
      THEN
        CLOSE c_get_party_name;
      END IF;
      --end NISINHA 6655434

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => p_msg_count,
                           x_msg_data  => p_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKC_K_PARTY_ROLES_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      IF chk_vendor_chr_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_csr;
      END IF;

       --start NISINHA Bug#6655434 closing the cursor in exception block
       IF c_get_party_name%ISOPEN
      THEN
        CLOSE c_get_party_name;
      END IF;
      --end NISINHA 6655434

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => p_msg_count,
                           x_msg_data  => p_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS
    THEN
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKC_K_PARTY_ROLES_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      IF chk_vendor_chr_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_csr;
      END IF;

      --start NISINHA Bug#6655434 closing the cursor in exception block
       IF c_get_party_name%ISOPEN
      THEN
        CLOSE c_get_party_name;
      END IF;
      --end NISINHA 6655434

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => p_msg_count,
                           x_msg_data  => p_msg_data,
                           p_api_type  => G_API_TYPE);
  END CPL_PARTY_MERGE ;

  ----------------------------------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : CPL_PARTY_SITE_MERGE
  -- Description     : Updating the table: OKC_K_PARTY_ROLES_B for column: OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKC_K_PARTY_ROLES_B and col: OBJECT1_ID1
  --                   for the records created by Lease Management for Party Site
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  -----------------------------------------------------------------------------------------------------------
  PROCEDURE CPL_PARTY_SITE_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2)
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'CPL_PARTY_SITE_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
    --Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.CPL_PARTY_SITE_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.CPL_PARTY_SITE_MERGE()+');

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES_B',FALSE);

        IF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKC_K_PARTY_ROLES_B table for column references OBJECT1_ID1
          --and JTOT_OBJECT1_CODE = 'OKL_PARTYSITE'
          UPDATE OKC_K_PARTY_ROLES_B TAB
            SET TAB.OBJECT1_ID1 = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.OBJECT1_ID1 = TO_CHAR(p_from_fk_id)
            AND JTOT_OBJECT1_CODE = 'OKL_PARTYSITE'
            AND DNZ_CHR_ID IN (SELECT ID FROM OKL_K_HEADERS);
        END IF;
        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      EXCEPTION
        when others
        then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKC_K_PARTY_ROLES_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END CPL_PARTY_SITE_MERGE;

  /*-------------------------------------------------------------
  | PROCEDURE
  |      LOP_ACCOUNT_MERGE
  | DESCRIPTION :
  |      Account merge procedure for the table, OKL_LEASE_OPPORTUNITIES_B
  |
  | NOTES:
  |--------------------------------------------------------------*/
  PROCEDURE LOP_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2)
  IS
    l_init_msg_list         VARCHAR2(1)  DEFAULT FND_API.G_FALSE;
    l_api_name              VARCHAR2(30) := 'LOP_ACCOUNT_MERGE';
    l_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(1000);

    TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
    MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

    TYPE ID_LIST_TYPE IS TABLE OF OKL_LEASE_OPPORTUNITIES_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
    PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

    TYPE CUST_ACCT_ID_LIST_TYPE IS TABLE OF OKL_LEASE_OPPORTUNITIES_B.CUST_ACCT_ID%TYPE
        INDEX BY BINARY_INTEGER;
    NUM_COL1_ORIG_LIST CUST_ACCT_ID_LIST_TYPE;
    NUM_COL1_NEW_LIST CUST_ACCT_ID_LIST_TYPE;

    TYPE PROSPECT_ADDRESS_ID_LIST_TYPE IS TABLE OF
      OKL_LEASE_OPPORTUNITIES_B.PROSPECT_ADDRESS_ID%TYPE INDEX BY BINARY_INTEGER;
    PROSPECT_ADDRESS_ID_LIST PROSPECT_ADDRESS_ID_LIST_TYPE;
    PROSPECT_ADD_OLD_ID_LIST PROSPECT_ADDRESS_ID_LIST_TYPE;

    TYPE PROSPECT_ID_LIST_TYPE IS TABLE OF
      OKL_LEASE_OPPORTUNITIES_B.PROSPECT_ID%TYPE INDEX BY BINARY_INTEGER;
    PROSPECT_ID_LIST PROSPECT_ID_LIST_TYPE;
    PROSPECT_OLD_ID_LIST PROSPECT_ID_LIST_TYPE;

    TYPE IS_ID_LIST_TYPE IS TABLE OF
      OKL_LEASE_OPPORTUNITIES_B.INSTALL_SITE_ID%TYPE INDEX BY BINARY_INTEGER;
    IS_ID_LIST IS_ID_LIST_TYPE;
    IS_OLD_ID_LIST IS_ID_LIST_TYPE;

    TYPE UL_ID_LIST_TYPE IS TABLE OF
      OKL_LEASE_OPPORTUNITIES_B.USAGE_LOCATION_ID%TYPE INDEX BY BINARY_INTEGER;
    UL_ID_LIST UL_ID_LIST_TYPE;
    UL_OLD_ID_LIST UL_ID_LIST_TYPE;

    l_party_site_id           HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
    l_new_party_site_id       HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;

    l_profile_val VARCHAR2(30);
    CURSOR merged_records IS
      SELECT distinct CUSTOMER_MERGE_HEADER_ID
           , ID
           , CUST_ACCT_ID
      FROM OKL_LEASE_OPPORTUNITIES_B yt, ra_customer_merges m
      WHERE (yt.CUST_ACCT_ID = m.DUPLICATE_ID)
        AND m.process_flag = 'N'
        AND m.request_id = req_id
        AND m.set_number = set_num;

    l_last_fetch BOOLEAN := FALSE;
    l_count NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_PARTY_MERGE_PUB.LOP_ACCOUNT_MERGE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_init_msg_list => l_init_msg_list
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_count := 0;
    IF process_mode='LOCK' THEN
      NULL;
    ELSE
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_LEASE_OPPORTUNITIES_B',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;
      LOOP
        FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST;

        IF merged_records%NOTFOUND THEN
          l_last_fetch := TRUE;
        END IF;
        IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
          EXIT;
        END IF;
        FOR I in 1..MERGE_HEADER_ID_LIST.COUNT
        LOOP
          NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
          IF(NOT CHECK_IF_SAME_PARTY(NUM_COL1_ORIG_LIST(I), NUM_COL1_NEW_LIST(I)))
          THEN
            SELECT PARTY_ID INTO PROSPECT_ID_LIST(I)
            FROM HZ_CUST_ACCOUNTS_ALL
            WHERE CUST_ACCOUNT_ID = NUM_COL1_NEW_LIST(I);
            --check if there exists a party site with same location id under new party
            SELECT PROSPECT_ID
                 , PROSPECT_ADDRESS_ID
                 , INSTALL_SITE_ID
                 , USAGE_LOCATION_ID
            INTO PROSPECT_OLD_ID_LIST(I)
               , PROSPECT_ADD_OLD_ID_LIST(I)
               , IS_OLD_ID_LIST(I)
               , UL_OLD_ID_LIST(I)
            FROM OKL_LEASE_OPPORTUNITIES_B
            WHERE ID = PRIMARY_KEY_ID_LIST(I);

            IF(PROSPECT_ADD_OLD_ID_LIST(I) IS NOT NULL)
            THEN
              PROSPECT_ADDRESS_ID_LIST(I) := get_new_party_site(PROSPECT_ADD_OLD_ID_LIST(I), NUM_COL1_NEW_LIST(I));
              --if yes then update the party site id with that new party site id else
              IF(PROSPECT_ADDRESS_ID_LIST(I) IS NULL)
              THEN
                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'begin debug call CREATE_PARTY_SITE');
                END IF;

                --copy the party site id under new party and update the party site id with
                --the newly created party site id.
                CREATE_PARTY_SITE(
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_cust_acct_id       => NUM_COL1_NEW_LIST(I),
                  p_old_party_site_id  => PROSPECT_ADD_OLD_ID_LIST(I),
                  x_new_party_site_id  => PROSPECT_ADDRESS_ID_LIST(I),
                  x_return_status      => l_return_status,
                  x_msg_count          => x_msg_count,
                  x_msg_data           => x_msg_data);

                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'end debug call CREATE_PARTY_SITE');
                END IF;

                -- write to log
                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_STATEMENT
                     ,L_MODULE || ' Result of CREATE_PARTY_SITE'
                     ,'New Party Site Id '|| PROSPECT_ADDRESS_ID_LIST(I) ||
                      ' result status ' || l_return_status ||
                      ' x_msg_data ' || x_msg_data);
                END IF; -- end of statement level debug

                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
            ELSE
              PROSPECT_ADDRESS_ID_LIST(I) := NULL;
            END IF;

            IF(IS_OLD_ID_LIST(I) IS NOT NULL)
            THEN
              IS_ID_LIST(I) := GET_NEW_PARTY_SITE_USE(IS_OLD_ID_LIST(I), NUM_COL1_NEW_LIST(I));
              IF(IS_ID_LIST(I) IS NULL)
              THEN
                SELECT PARTY_SITE_ID INTO l_party_site_id
                FROM HZ_PARTY_SITE_USES
                WHERE PARTY_SITE_USE_ID = IS_OLD_ID_LIST(I);
                l_new_party_site_id := GET_NEW_PARTY_SITE(l_party_site_id, NUM_COL1_NEW_LIST(I));
                IF(l_new_party_site_id IS NULL)
                THEN
                  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                  THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(
                        FND_LOG.LEVEL_PROCEDURE
                       ,L_MODULE
                       ,'begin debug call CREATE_PARTY_SITE');
                  END IF;

                  CREATE_PARTY_SITE(
                    p_init_msg_list      => FND_API.G_FALSE,
                    p_cust_acct_id       => NUM_COL1_NEW_LIST(I),
                    p_old_party_site_id  => l_party_site_id,
                    x_new_party_site_id  => l_new_party_site_id,
                    x_return_status      => l_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);

                  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                  THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(
                        FND_LOG.LEVEL_PROCEDURE
                       ,L_MODULE
                       ,'end debug call CREATE_PARTY_SITE');
                  END IF;

                  -- write to log
                  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(
                        FND_LOG.LEVEL_STATEMENT
                       ,L_MODULE || ' Result of CREATE_PARTY_SITE'
                       ,'New Party Site Id '|| l_new_party_site_id ||
                        ' result status ' || l_return_status ||
                        ' x_msg_data ' || x_msg_data);
                  END IF; -- end of statement level debug

                  IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'begin debug call CREATE_PARTY_SITE_USE');
                END IF;

                CREATE_PARTY_SITE_USE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_party_site_id          => l_new_party_site_id,
                  p_old_party_site_use_id  => IS_OLD_ID_LIST(I),
                  x_new_party_site_use_id  => IS_ID_LIST(I),
                  x_return_status          => l_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);

                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'end debug call CREATE_PARTY_SITE_USE');
                END IF;

                -- write to log
                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_STATEMENT
                     ,L_MODULE || ' Result of CREATE_PARTY_SITE_USE'
                     ,'New Party Site Use Id '|| IS_ID_LIST(I) ||
                      ' result status ' || l_return_status ||
                      ' x_msg_data ' || x_msg_data);
                END IF; -- end of statement level debug

                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
            ELSE
              IS_ID_LIST(I) := NULL;
            END IF;

            IF(UL_OLD_ID_LIST(I) IS NOT NULL)
            THEN
              UL_ID_LIST(I) := GET_NEW_PARTY_SITE_USE(UL_OLD_ID_LIST(I), NUM_COL1_NEW_LIST(I));
              IF(UL_ID_LIST(I) IS NULL)
              THEN
                SELECT PARTY_SITE_ID INTO l_party_site_id
                FROM HZ_PARTY_SITE_USES
                WHERE PARTY_SITE_USE_ID = UL_OLD_ID_LIST(I);
                l_new_party_site_id := GET_NEW_PARTY_SITE(l_party_site_id, NUM_COL1_NEW_LIST(I));
                IF(l_new_party_site_id IS NULL)
                THEN
                  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                  THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(
                        FND_LOG.LEVEL_PROCEDURE
                       ,L_MODULE
                       ,'begin debug call CREATE_PARTY_SITE');
                  END IF;

                  CREATE_PARTY_SITE(
                    p_init_msg_list      => FND_API.G_FALSE,
                    p_cust_acct_id       => NUM_COL1_NEW_LIST(I),
                    p_old_party_site_id  => l_party_site_id,
                    x_new_party_site_id  => l_new_party_site_id,
                    x_return_status      => l_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);

                  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                  THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(
                        FND_LOG.LEVEL_PROCEDURE
                       ,L_MODULE
                       ,'end debug call CREATE_PARTY_SITE');
                  END IF;

                  -- write to log
                  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(
                        FND_LOG.LEVEL_STATEMENT
                       ,L_MODULE || ' Result of CREATE_PARTY_SITE'
                       ,'New Party Site Id '|| l_new_party_site_id ||
                        ' result status ' || l_return_status ||
                        ' x_msg_data ' || x_msg_data);
                  END IF; -- end of statement level debug

                  IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                END IF;

                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'begin debug call CREATE_PARTY_SITE_USE');
                END IF;

                CREATE_PARTY_SITE_USE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_party_site_id          => l_new_party_site_id,
                  p_old_party_site_use_id  => UL_OLD_ID_LIST(I),
                  x_new_party_site_use_id  => UL_ID_LIST(I),
                  x_return_status          => l_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);

                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'end debug call CREATE_PARTY_SITE_USE');
                END IF;

                -- write to log
                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_STATEMENT
                     ,L_MODULE || ' Result of CREATE_PARTY_SITE_USE'
                     ,'New Party Site Use Id '|| UL_ID_LIST(I) ||
                      ' result status ' || l_return_status ||
                      ' x_msg_data ' || x_msg_data);
                END IF; -- end of statement level debug

                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
            ELSE
              UL_ID_LIST(I) := NULL;
            END IF;

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'begin debug call UPDATE_ASSET_LOCATION');
            END IF;

            --Also update the install location id in okl_assets_b for all the lease quotes
            --undet this lease application.
            UPDATE_ASSET_LOCATION(
              p_init_msg_list      => FND_API.G_FALSE,
              p_cust_acct_id       => NUM_COL1_NEW_LIST(I),
              p_parent_object_id   => PRIMARY_KEY_ID_LIST(I),
              p_parent_object_code => 'LEASEOPP',
              p_merge_header_id    => MERGE_HEADER_ID_LIST(I),
              req_id               => req_id,
              x_return_status      => l_return_status,
              x_msg_count          => x_msg_count,
              x_msg_data           => x_msg_data);

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'end debug call UPDATE_ASSET_LOCATION');
            END IF;

            -- write to log
            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_STATEMENT
                 ,L_MODULE || ' Result of UPDATE_ASSET_LOCATION'
                 ,' result status ' || l_return_status ||
                  ' x_msg_data ' || x_msg_data);
            END IF; -- end of statement level debug

            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END LOOP;

        IF l_profile_val IS NOT NULL AND l_profile_val = 'Y'
        THEN
          FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            INSERT INTO HZ_CUSTOMER_MERGE_LOG (
              MERGE_LOG_ID,
              TABLE_NAME,
              MERGE_HEADER_ID,
              PRIMARY_KEY_ID,
              NUM_COL1_ORIG,
              NUM_COL1_NEW,
              NUM_COL2_ORIG,
              NUM_COL2_NEW,
              NUM_COL3_ORIG,
              NUM_COL3_NEW,
              NUM_COL4_ORIG,
              NUM_COL4_NEW,
              NUM_COL5_ORIG,
              NUM_COL5_NEW,
              ACTION_FLAG,
              REQUEST_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY)
            VALUES(
              HZ_CUSTOMER_MERGE_LOG_s.nextval,
              'OKL_LEASE_OPPORTUNITIES_B',
              MERGE_HEADER_ID_LIST(I),
              PRIMARY_KEY_ID_LIST(I),
              NUM_COL1_ORIG_LIST(I),
              NUM_COL1_NEW_LIST(I),
              PROSPECT_OLD_ID_LIST(I),
              PROSPECT_ID_LIST(I),
              PROSPECT_ADD_OLD_ID_LIST(I),
              PROSPECT_ADDRESS_ID_LIST(I),
              IS_OLD_ID_LIST(I),
              IS_ID_LIST(I),
              UL_OLD_ID_LIST(I),
              UL_ID_LIST(I),
              'U',
              req_id,
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY);
        END IF;

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
          UPDATE OKL_LEASE_OPPORTUNITIES_B yt SET
             CUST_ACCT_ID=NUM_COL1_NEW_LIST(I)
           , PROSPECT_ID = PROSPECT_ID_LIST(I)
           , PROSPECT_ADDRESS_ID = PROSPECT_ADDRESS_ID_LIST(I)
           , INSTALL_SITE_ID = IS_ID_LIST(I)
           , USAGE_LOCATION_ID = UL_ID_LIST(I)
           , LAST_UPDATE_DATE=SYSDATE
           , last_updated_by=arp_standard.profile.user_id
           , last_update_login=arp_standard.profile.last_update_login
          WHERE ID=PRIMARY_KEY_ID_LIST(I);

        l_count := l_count + SQL%ROWCOUNT;
        IF l_last_fetch THEN
          EXIT;
        END IF;
      END LOOP;

      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
    END IF;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
      RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
      RAISE;
    WHEN OTHERS
    THEN
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
      RAISE;
  END LOP_ACCOUNT_MERGE;

  /*-------------------------------------------------------------
  |  PROCEDURE
  |      LAP_ACCOUNT_MERGE
  |  DESCRIPTION :
  |      Account merge procedure for the table, OKL_LEASE_APPLICATIONS_B
  |
  |  NOTES:
  |--------------------------------------------------------------*/
  PROCEDURE LAP_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2)
  IS
    l_init_msg_list         VARCHAR2(1)  DEFAULT FND_API.G_FALSE;
    l_api_name              VARCHAR2(30) := 'LAP_ACCOUNT_MERGE';
    l_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(1000);

    TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
    MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

    TYPE ID_LIST_TYPE IS TABLE OF OKL_LEASE_APPLICATIONS_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
    PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

    TYPE CUST_ACCT_ID_LIST_TYPE IS TABLE OF OKL_LEASE_APPLICATIONS_B.CUST_ACCT_ID%TYPE
        INDEX BY BINARY_INTEGER;
    NUM_COL1_ORIG_LIST CUST_ACCT_ID_LIST_TYPE;
    NUM_COL1_NEW_LIST CUST_ACCT_ID_LIST_TYPE;

    TYPE PROSPECT_ADDRESS_ID_LIST_TYPE IS TABLE OF
      OKL_LEASE_APPLICATIONS_B.PROSPECT_ADDRESS_ID%TYPE INDEX BY BINARY_INTEGER;
    PROSPECT_ADDRESS_ID_LIST PROSPECT_ADDRESS_ID_LIST_TYPE;
    PROSPECT_ADD_OLD_ID_LIST PROSPECT_ADDRESS_ID_LIST_TYPE;

    TYPE PROSPECT_ID_LIST_TYPE IS TABLE OF
      OKL_LEASE_APPLICATIONS_B.PROSPECT_ID%TYPE INDEX BY BINARY_INTEGER;
    PROSPECT_ID_LIST PROSPECT_ID_LIST_TYPE;
    PROSPECT_OLD_ID_LIST PROSPECT_ID_LIST_TYPE;

    l_profile_val VARCHAR2(30);
    CURSOR merged_records IS
      SELECT distinct CUSTOMER_MERGE_HEADER_ID
           , ID
           , CUST_ACCT_ID
      FROM OKL_LEASE_APPLICATIONS_B yt, ra_customer_merges m
      WHERE (yt.CUST_ACCT_ID = m.DUPLICATE_ID)
        AND m.process_flag = 'N'
        AND m.request_id = req_id
        AND m.set_number = set_num;
    l_last_fetch BOOLEAN := FALSE;
    l_count NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_PARTY_MERGE_PUB.LAP_ACCOUNT_MERGE';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_init_msg_list => l_init_msg_list
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_count := 0;
    IF process_mode='LOCK' THEN
      NULL;
    ELSE
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_LEASE_APPLICATIONS_B',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;
      LOOP
        FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST;

        IF merged_records%NOTFOUND THEN
          l_last_fetch := TRUE;
        END IF;
        IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
          EXIT;
        END IF;
        FOR I in 1..MERGE_HEADER_ID_LIST.COUNT
        LOOP
          NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
          IF(NOT CHECK_IF_SAME_PARTY(NUM_COL1_ORIG_LIST(I), NUM_COL1_NEW_LIST(I)))
          THEN
            SELECT PARTY_ID INTO PROSPECT_ID_LIST(I)
            FROM HZ_CUST_ACCOUNTS_ALL
            WHERE CUST_ACCOUNT_ID = NUM_COL1_NEW_LIST(I);

            --check if there exists a party site with same location id under new party
            SELECT PROSPECT_ID
                 , PROSPECT_ADDRESS_ID
              INTO PROSPECT_OLD_ID_LIST(I)
                 , PROSPECT_ADD_OLD_ID_LIST(I)
            FROM OKL_LEASE_APPLICATIONS_B
            WHERE ID = PRIMARY_KEY_ID_LIST(I);
            IF(PROSPECT_ADD_OLD_ID_LIST(I) IS NOT NULL)
            THEN
              PROSPECT_ADDRESS_ID_LIST(I) := get_new_party_site(PROSPECT_ADD_OLD_ID_LIST(I), NUM_COL1_NEW_LIST(I));
              --if yes then update the party site id with that new party site id else
              IF(PROSPECT_ADDRESS_ID_LIST(I) IS NULL)
              THEN
                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'begin debug call CREATE_PARTY_SITE');
                END IF;

                --copy the party site id under new party and update the party site id with
                --the newly created party site id.
                CREATE_PARTY_SITE(
                    p_init_msg_list      => FND_API.G_FALSE,
                    p_cust_acct_id       => NUM_COL1_NEW_LIST(I),
                    p_old_party_site_id  => PROSPECT_ADD_OLD_ID_LIST(I),
                    x_new_party_site_id  => PROSPECT_ADDRESS_ID_LIST(I),
                    x_return_status      => l_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data);

                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
                THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_PROCEDURE
                     ,L_MODULE
                     ,'end debug call CREATE_PARTY_SITE');
                END IF;

                -- write to log
                IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(
                      FND_LOG.LEVEL_STATEMENT
                     ,L_MODULE || ' Result of CREATE_PARTY_SITE'
                     ,'New Party Site Id '|| PROSPECT_ADDRESS_ID_LIST(I) ||
                      ' result status ' || l_return_status ||
                      ' x_msg_data ' || x_msg_data);
                END IF; -- end of statement level debug

                IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
            ELSE
              PROSPECT_ADDRESS_ID_LIST(I) := NULL;
            END IF;

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'begin debug call UPDATE_ASSET_LOCATION');
            END IF;

            --Also update the install location id in okl_assets_b for all the lease quotes
            --undet this lease application.
            UPDATE_ASSET_LOCATION(
                p_init_msg_list      => FND_API.G_FALSE,
                p_cust_acct_id       => NUM_COL1_NEW_LIST(I),
                p_parent_object_id   => PRIMARY_KEY_ID_LIST(I),
                p_parent_object_code => 'LEASEAPP',
                p_merge_header_id    => MERGE_HEADER_ID_LIST(I),
                req_id               => req_id,
                x_return_status      => l_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data);

            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
            THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_PROCEDURE
                 ,L_MODULE
                 ,'end debug call UPDATE_ASSET_LOCATION');
            END IF;

            -- write to log
            IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(
                  FND_LOG.LEVEL_STATEMENT
                 ,L_MODULE || ' Result of UPDATE_ASSET_LOCATION'
                 ,' result status ' || l_return_status ||
                  ' x_msg_data ' || x_msg_data);
            END IF; -- end of statement level debug

            IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END LOOP;
        IF l_profile_val IS NOT NULL AND l_profile_val = 'Y'
        THEN
          FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            INSERT INTO HZ_CUSTOMER_MERGE_LOG (
              MERGE_LOG_ID,
              TABLE_NAME,
              MERGE_HEADER_ID,
              PRIMARY_KEY_ID,
              NUM_COL1_ORIG,
              NUM_COL1_NEW,
              NUM_COL2_ORIG,
              NUM_COL2_NEW,
              NUM_COL3_ORIG,
              NUM_COL3_NEW,
              ACTION_FLAG,
              REQUEST_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATE_LOGIN,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY
            )VALUES(
              HZ_CUSTOMER_MERGE_LOG_s.nextval,
              'OKL_LEASE_APPLICATIONS_B',
              MERGE_HEADER_ID_LIST(I),
              PRIMARY_KEY_ID_LIST(I),
              NUM_COL1_ORIG_LIST(I),
              NUM_COL1_NEW_LIST(I),
              PROSPECT_OLD_ID_LIST(I),
              PROSPECT_ID_LIST(I),
              PROSPECT_ADD_OLD_ID_LIST(I),
              PROSPECT_ADDRESS_ID_LIST(I),
              'U',
              req_id,
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY);

        END IF;
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
          UPDATE OKL_LEASE_APPLICATIONS_B yt SET
              CUST_ACCT_ID=NUM_COL1_NEW_LIST(I)
            , PROSPECT_ID = PROSPECT_ID_LIST(I)
            , PROSPECT_ADDRESS_ID = PROSPECT_ADDRESS_ID_LIST(I)
            , LAST_UPDATE_DATE=SYSDATE
            , last_updated_by=arp_standard.profile.user_id
            , last_update_login=arp_standard.profile.last_update_login
          WHERE ID=PRIMARY_KEY_ID_LIST(I);

        l_count := l_count + SQL%ROWCOUNT;
        IF l_last_fetch THEN
          EXIT;
        END IF;
      END LOOP;

      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
    END IF;

    OKL_API.END_ACTIVITY(
        x_msg_count => x_msg_count
       ,x_msg_data  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
      RAISE;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
      RAISE;
    WHEN OTHERS
    THEN
      arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
      RAISE;
  END LAP_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      XSI_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_EXT_SELL_INVS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE XSI_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_EXT_SELL_INVS_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         OKL_EXT_SELL_INVS_B.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_ADDRESS_ID_LIST_TYPE IS TABLE OF
         OKL_EXT_SELL_INVS_B.CUSTOMER_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUSTOMER_ADDRESS_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_ADDRESS_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,yt.ID
              ,yt.CUSTOMER_ID
              ,yt.CUSTOMER_ADDRESS_ID
         FROM OKL_EXT_SELL_INVS_B yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.CUSTOMER_ADDRESS_ID = m.DUPLICATE_ADDRESS_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_EXT_SELL_INVS_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_EXT_SELL_INVS_B',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_EXT_SELL_INVS_B yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          ,CUSTOMER_ADDRESS_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'XSI_ACCOUNT_MERGE');
    RAISE;
END XSI_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      TXST_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TAX_SOURCES_T
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE TXST_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES_T.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE BILL_TO_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES_T.BILL_TO_CUST_ACCT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST BILL_TO_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST BILL_TO_CUST_ACCT_ID_LIST_TYPE;

  TYPE BT_CA_SU_ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES_T.BILL_TO_CUST_ACCT_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST BT_CA_SU_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST BT_CA_SU_ID_LIST_TYPE;

  TYPE ST_CA_SU_ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES_T.SHIP_TO_CUST_ACCT_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST ST_CA_SU_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST ST_CA_SU_ID_LIST_TYPE;

  TYPE ST_PAR_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES_T.SHIP_TO_PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  ST_PAR_ID_ORIG_LIST ST_PAR_ID_LIST_TYPE;
  ST_PAR_ID_NEW_LIST ST_PAR_ID_LIST_TYPE;

  TYPE ST_PAR_SITE_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES_T.SHIP_TO_PARTY_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  ST_PAR_SITE_ID_ORIG_LIST ST_PAR_SITE_ID_LIST_TYPE;
  ST_PAR_SITE_ID_NEW_LIST ST_PAR_SITE_ID_LIST_TYPE;

  TYPE ST_LOC_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES_T.SHIP_TO_LOCATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  ST_LOC_ID_ORIG_LIST ST_LOC_ID_LIST_TYPE;
  ST_LOC_ID_NEW_LIST ST_LOC_ID_LIST_TYPE;

  TYPE BT_PAR_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES_T.BILL_TO_PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  BT_PAR_ID_ORIG_LIST BT_PAR_ID_LIST_TYPE;
  BT_PAR_ID_NEW_LIST BT_PAR_ID_LIST_TYPE;

  TYPE BT_PAR_SITE_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES_T.BILL_TO_PARTY_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  BT_PAR_SITE_ID_ORIG_LIST BT_PAR_SITE_ID_LIST_TYPE;
  BT_PAR_SITE_ID_NEW_LIST BT_PAR_SITE_ID_LIST_TYPE;

  TYPE BT_LOC_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES_T.BILL_TO_LOCATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  BT_LOC_ID_ORIG_LIST BT_LOC_ID_LIST_TYPE;
  BT_LOC_ID_NEW_LIST BT_LOC_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,BILL_TO_CUST_ACCT_ID
              ,BILL_TO_CUST_ACCT_SITE_USE_ID
              ,SHIP_TO_CUST_ACCT_SITE_USE_ID
         FROM OKL_TAX_SOURCES_T yt, ra_customer_merges m
         WHERE (
            yt.BILL_TO_CUST_ACCT_ID = m.DUPLICATE_ID
            OR yt.BILL_TO_CUST_ACCT_SITE_USE_ID = m.DUPLICATE_SITE_ID
            OR yt.SHIP_TO_CUST_ACCT_SITE_USE_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

  CURSOR tax_src_dtls_csr(l_tax_src_id NUMBER)
  IS
    SELECT BILL_TO_PARTY_ID
         , BILL_TO_PARTY_SITE_ID
         , BILL_TO_LOCATION_ID
         , SHIP_TO_PARTY_ID
         , SHIP_TO_PARTY_SITE_ID
         , SHIP_TO_LOCATION_ID
    FROM OKL_TAX_SOURCES_T
    WHERE id = l_tax_src_id;

  CURSOR bt_st_dtls_csr(l_site_use_id NUMBER)
  IS
    SELECT HPS.PARTY_ID
         , HPS.PARTY_SITE_ID
         , HPS.LOCATION_ID
    FROM HZ_PARTY_SITES HPS
       , HZ_CUST_ACCT_SITES_ALL CAS
       , HZ_CUST_SITE_USES_ALL CSU
    WHERE CSU.CUST_ACCT_SITE_ID = CAS.CUST_ACCT_SITE_ID
      AND CAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID
      AND CSU.SITE_USE_ID = l_site_use_id;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_TAX_SOURCES_T',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));

         OPEN tax_src_dtls_csr(PRIMARY_KEY_ID_LIST(I));
         FETCH tax_src_dtls_csr INTO
           BT_PAR_ID_ORIG_LIST(I),
           BT_PAR_SITE_ID_ORIG_LIST(I),
           BT_LOC_ID_ORIG_LIST(I),
           ST_PAR_ID_ORIG_LIST(I),
           ST_PAR_SITE_ID_ORIG_LIST(I),
           ST_LOC_ID_ORIG_LIST(I);
         CLOSE tax_src_dtls_csr;

         OPEN bt_st_dtls_csr(NUM_COL2_NEW_LIST(I));
         FETCH bt_st_dtls_csr INTO
           BT_PAR_ID_NEW_LIST(I),
           BT_PAR_SITE_ID_NEW_LIST(I),
           BT_LOC_ID_NEW_LIST(I);
         CLOSE bt_st_dtls_csr;

         OPEN bt_st_dtls_csr(NUM_COL3_NEW_LIST(I));
         FETCH bt_st_dtls_csr INTO
           ST_PAR_ID_NEW_LIST(I),
           ST_PAR_SITE_ID_NEW_LIST(I),
           ST_LOC_ID_NEW_LIST(I);
         CLOSE bt_st_dtls_csr;
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           NUM_COL4_ORIG,
           NUM_COL4_NEW,
           NUM_COL5_ORIG,
           NUM_COL5_NEW,
           NUM_COL6_ORIG,
           NUM_COL6_NEW,
           NUM_COL7_ORIG,
           NUM_COL7_NEW,
           NUM_COL8_ORIG,
           NUM_COL8_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_TAX_SOURCES_T',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         BT_PAR_ID_ORIG_LIST(I),
         BT_PAR_ID_NEW_LIST(I),
         BT_PAR_SITE_ID_ORIG_LIST(I),
         BT_PAR_SITE_ID_NEW_LIST(I),
         BT_LOC_ID_ORIG_LIST(I),
         BT_LOC_ID_NEW_LIST(I),
         ST_PAR_ID_ORIG_LIST(I),
         ST_PAR_ID_NEW_LIST(I),
         ST_PAR_SITE_ID_ORIG_LIST(I),
         ST_PAR_SITE_ID_NEW_LIST(I),
         ST_LOC_ID_ORIG_LIST(I),
         ST_LOC_ID_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_TAX_SOURCES_T yt SET
            BILL_TO_CUST_ACCT_ID=NUM_COL1_NEW_LIST(I)
          , BILL_TO_CUST_ACCT_SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          , SHIP_TO_CUST_ACCT_SITE_USE_ID=NUM_COL3_NEW_LIST(I)
          , BILL_TO_PARTY_ID = BT_PAR_ID_NEW_LIST(I)
          , BILL_TO_PARTY_SITE_ID = BT_PAR_SITE_ID_NEW_LIST(I)
          , BILL_TO_LOCATION_ID = BT_LOC_ID_NEW_LIST(I)
          , SHIP_TO_PARTY_ID = ST_PAR_ID_NEW_LIST(I)
          , SHIP_TO_PARTY_SITE_ID = ST_PAR_SITE_ID_NEW_LIST(I)
          , SHIP_TO_LOCATION_ID = ST_LOC_ID_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF merged_records%ISOPEN
    THEN
      CLOSE merged_records;
    END IF;
    IF tax_src_dtls_csr%ISOPEN
    THEN
      CLOSE tax_src_dtls_csr;
    END IF;
    IF bt_st_dtls_csr%ISOPEN
    THEN
      CLOSE bt_st_dtls_csr;
    END IF;
    arp_message.set_line( 'TXST_ACCOUNT_MERGE');
    RAISE;
END TXST_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      TXS_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TAX_SOURCES
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE TXS_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE BILL_TO_CUST_ACCT_ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES.BILL_TO_CUST_ACCT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST BILL_TO_CUST_ACCT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST BILL_TO_CUST_ACCT_ID_LIST_TYPE;

  TYPE BT_CA_SU_ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES.BILL_TO_CUST_ACCT_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST BT_CA_SU_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST BT_CA_SU_ID_LIST_TYPE;

  TYPE ST_CA_SU_ID_LIST_TYPE IS TABLE OF
         OKL_TAX_SOURCES.SHIP_TO_CUST_ACCT_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST ST_CA_SU_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST ST_CA_SU_ID_LIST_TYPE;

  TYPE ST_PAR_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES.SHIP_TO_PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  ST_PAR_ID_ORIG_LIST ST_PAR_ID_LIST_TYPE;
  ST_PAR_ID_NEW_LIST ST_PAR_ID_LIST_TYPE;

  TYPE ST_PAR_SITE_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES.SHIP_TO_PARTY_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  ST_PAR_SITE_ID_ORIG_LIST ST_PAR_SITE_ID_LIST_TYPE;
  ST_PAR_SITE_ID_NEW_LIST ST_PAR_SITE_ID_LIST_TYPE;

  TYPE ST_LOC_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES.SHIP_TO_LOCATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  ST_LOC_ID_ORIG_LIST ST_LOC_ID_LIST_TYPE;
  ST_LOC_ID_NEW_LIST ST_LOC_ID_LIST_TYPE;

  TYPE BT_PAR_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES.BILL_TO_PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  BT_PAR_ID_ORIG_LIST BT_PAR_ID_LIST_TYPE;
  BT_PAR_ID_NEW_LIST BT_PAR_ID_LIST_TYPE;

  TYPE BT_PAR_SITE_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES.BILL_TO_PARTY_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  BT_PAR_SITE_ID_ORIG_LIST BT_PAR_SITE_ID_LIST_TYPE;
  BT_PAR_SITE_ID_NEW_LIST BT_PAR_SITE_ID_LIST_TYPE;

  TYPE BT_LOC_ID_LIST_TYPE IS TABLE OF OKL_TAX_SOURCES.BILL_TO_LOCATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  BT_LOC_ID_ORIG_LIST BT_LOC_ID_LIST_TYPE;
  BT_LOC_ID_NEW_LIST BT_LOC_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,BILL_TO_CUST_ACCT_ID
              ,BILL_TO_CUST_ACCT_SITE_USE_ID
              ,SHIP_TO_CUST_ACCT_SITE_USE_ID
         FROM OKL_TAX_SOURCES yt, ra_customer_merges m
         WHERE (
            yt.BILL_TO_CUST_ACCT_ID = m.DUPLICATE_ID
            OR yt.BILL_TO_CUST_ACCT_SITE_USE_ID = m.DUPLICATE_SITE_ID
            OR yt.SHIP_TO_CUST_ACCT_SITE_USE_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

  CURSOR tax_src_dtls_csr(l_tax_src_id NUMBER)
  IS
    SELECT BILL_TO_PARTY_ID
         , BILL_TO_PARTY_SITE_ID
         , BILL_TO_LOCATION_ID
         , SHIP_TO_PARTY_ID
         , SHIP_TO_PARTY_SITE_ID
         , SHIP_TO_LOCATION_ID
    FROM OKL_TAX_SOURCES
    WHERE id = l_tax_src_id;

  CURSOR bt_st_dtls_csr(l_site_use_id NUMBER)
  IS
    SELECT HPS.PARTY_ID
         , HPS.PARTY_SITE_ID
         , HPS.LOCATION_ID
    FROM HZ_PARTY_SITES HPS
       , HZ_CUST_ACCT_SITES_ALL CAS
       , HZ_CUST_SITE_USES_ALL CSU
    WHERE CSU.CUST_ACCT_SITE_ID = CAS.CUST_ACCT_SITE_ID
      AND CAS.PARTY_SITE_ID = HPS.PARTY_SITE_ID
      AND CSU.SITE_USE_ID = l_site_use_id;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_TAX_SOURCES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));

         OPEN tax_src_dtls_csr(PRIMARY_KEY_ID_LIST(I));
         FETCH tax_src_dtls_csr INTO
           BT_PAR_ID_ORIG_LIST(I),
           BT_PAR_SITE_ID_ORIG_LIST(I),
           BT_LOC_ID_ORIG_LIST(I),
           ST_PAR_ID_ORIG_LIST(I),
           ST_PAR_SITE_ID_ORIG_LIST(I),
           ST_LOC_ID_ORIG_LIST(I);
         CLOSE tax_src_dtls_csr;

         OPEN bt_st_dtls_csr(NUM_COL2_NEW_LIST(I));
         FETCH bt_st_dtls_csr INTO
           BT_PAR_ID_NEW_LIST(I),
           BT_PAR_SITE_ID_NEW_LIST(I),
           BT_LOC_ID_NEW_LIST(I);
         CLOSE bt_st_dtls_csr;

         OPEN bt_st_dtls_csr(NUM_COL3_NEW_LIST(I));
         FETCH bt_st_dtls_csr INTO
           ST_PAR_ID_NEW_LIST(I),
           ST_PAR_SITE_ID_NEW_LIST(I),
           ST_LOC_ID_NEW_LIST(I);
         CLOSE bt_st_dtls_csr;
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           NUM_COL3_ORIG,
           NUM_COL3_NEW,
           NUM_COL4_ORIG,
           NUM_COL4_NEW,
           NUM_COL5_ORIG,
           NUM_COL5_NEW,
           NUM_COL6_ORIG,
           NUM_COL6_NEW,
           NUM_COL7_ORIG,
           NUM_COL7_NEW,
           NUM_COL8_ORIG,
           NUM_COL8_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_TAX_SOURCES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         BT_PAR_ID_ORIG_LIST(I),
         BT_PAR_ID_NEW_LIST(I),
         BT_PAR_SITE_ID_ORIG_LIST(I),
         BT_PAR_SITE_ID_NEW_LIST(I),
         BT_LOC_ID_ORIG_LIST(I),
         BT_LOC_ID_NEW_LIST(I),
         ST_PAR_ID_ORIG_LIST(I),
         ST_PAR_ID_NEW_LIST(I),
         ST_PAR_SITE_ID_ORIG_LIST(I),
         ST_PAR_SITE_ID_NEW_LIST(I),
         ST_LOC_ID_ORIG_LIST(I),
         ST_LOC_ID_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_TAX_SOURCES yt SET
            BILL_TO_CUST_ACCT_ID=NUM_COL1_NEW_LIST(I)
          , BILL_TO_CUST_ACCT_SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          , SHIP_TO_CUST_ACCT_SITE_USE_ID=NUM_COL3_NEW_LIST(I)
          , BILL_TO_PARTY_ID = BT_PAR_ID_NEW_LIST(I)
          , BILL_TO_PARTY_SITE_ID = BT_PAR_SITE_ID_NEW_LIST(I)
          , BILL_TO_LOCATION_ID = BT_LOC_ID_NEW_LIST(I)
          , SHIP_TO_PARTY_ID = ST_PAR_ID_NEW_LIST(I)
          , SHIP_TO_PARTY_SITE_ID = ST_PAR_SITE_ID_NEW_LIST(I)
          , SHIP_TO_LOCATION_ID = ST_LOC_ID_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF merged_records%ISOPEN
    THEN
      CLOSE merged_records;
    END IF;
    IF tax_src_dtls_csr%ISOPEN
    THEN
      CLOSE tax_src_dtls_csr;
    END IF;
    IF bt_st_dtls_csr%ISOPEN
    THEN
      CLOSE bt_st_dtls_csr;
    END IF;
    arp_message.set_line( 'TXS_ACCOUNT_MERGE');
    RAISE;
END TXS_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      TAI_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TRX_AR_INVOICES_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE TAI_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_TRX_AR_INVOICES_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE IBT_ID_LIST_TYPE IS TABLE OF
         OKL_TRX_AR_INVOICES_B.IBT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST IBT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST IBT_ID_LIST_TYPE;

  TYPE IXX_ID_LIST_TYPE IS TABLE OF
         OKL_TRX_AR_INVOICES_B.IXX_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST IXX_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST IXX_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,IBT_ID
              ,IXX_ID
         FROM OKL_TRX_AR_INVOICES_B yt, ra_customer_merges m
         WHERE (
            yt.IBT_ID = m.DUPLICATE_SITE_ID
            OR yt.IXX_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_TRX_AR_INVOICES_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_TRX_AR_INVOICES_B',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_TRX_AR_INVOICES_B yt SET
           IBT_ID=NUM_COL1_NEW_LIST(I)
          ,IXX_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'TAI_ACCOUNT_MERGE');
    RAISE;
END TAI_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      RCA_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_TXL_RCPT_APPS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE RCA_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_TXL_RCPT_APPS_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE ILE_ID_LIST_TYPE IS TABLE OF
         OKL_TXL_RCPT_APPS_B.ILE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST ILE_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST ILE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,ILE_ID
         FROM OKL_TXL_RCPT_APPS_B yt, ra_customer_merges m
         WHERE (
            yt.ILE_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_TXL_RCPT_APPS_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_TXL_RCPT_APPS_B',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_TXL_RCPT_APPS_B yt SET
           ILE_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'RCA_ACCOUNT_MERGE');
    RAISE;
END RCA_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      CNR_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_CNSLD_AR_HDRS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE CNR_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_CNSLD_AR_HDRS_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE IXX_ID_LIST_TYPE IS TABLE OF
         OKL_CNSLD_AR_HDRS_B.IXX_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST IXX_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST IXX_ID_LIST_TYPE;

  TYPE IBT_ID_LIST_TYPE IS TABLE OF
         OKL_CNSLD_AR_HDRS_B.IBT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST IBT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST IBT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,IXX_ID
              ,IBT_ID
         FROM OKL_CNSLD_AR_HDRS_B yt, ra_customer_merges m
         WHERE (
            yt.IXX_ID = m.DUPLICATE_ID
            OR yt.IBT_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_CNSLD_AR_HDRS_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_CNSLD_AR_HDRS_B',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_CNSLD_AR_HDRS_B yt SET
           IXX_ID=NUM_COL1_NEW_LIST(I)
          ,IBT_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'CNR_ACCOUNT_MERGE');
    RAISE;
END CNR_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      CLG_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_CNTR_LVLNG_GRPS_B
|
|  NOTES:
|--------------------------------------------------------------*/
PROCEDURE CLG_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_CNTR_LVLNG_GRPS_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE ICA_ID_LIST_TYPE IS TABLE OF
         OKL_CNTR_LVLNG_GRPS_B.ICA_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST ICA_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST ICA_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,ICA_ID
         FROM OKL_CNTR_LVLNG_GRPS_B yt, ra_customer_merges m
         WHERE (
            yt.ICA_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  l_count := 0;
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_CNTR_LVLNG_GRPS_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_CNTR_LVLNG_GRPS_B',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_CNTR_LVLNG_GRPS_B yt SET
           ICA_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'CLG_ACCOUNT_MERGE');
    RAISE;
END CLG_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      ASE_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_ACCT_SOURCES
|--------------------------------------------------------------*/
PROCEDURE ASE_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_ACCT_SOURCES.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE REC_SITE_USES_PK_LIST_TYPE IS TABLE OF
         OKL_ACCT_SOURCES.REC_SITE_USES_PK%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST REC_SITE_USES_PK_LIST_TYPE;
  NUM_COL1_NEW_LIST REC_SITE_USES_PK_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,REC_SITE_USES_PK
         FROM OKL_ACCT_SOURCES yt, ra_customer_merges m
         WHERE (
            yt.REC_SITE_USES_PK = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_ACCT_SOURCES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_ACCT_SOURCES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_ACCT_SOURCES yt SET
           REC_SITE_USES_PK=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'ASE_ACCOUNT_MERGE');
    RAISE;
END ASE_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      SID_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_SUPP_INVOICE_DTLS
|--------------------------------------------------------------*/
PROCEDURE SID_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_SUPP_INVOICE_DTLS.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE SHIPPING_ADDRESS_ID1_LIST_TYPE IS TABLE OF
         OKL_SUPP_INVOICE_DTLS.SHIPPING_ADDRESS_ID1%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SHIPPING_ADDRESS_ID1_LIST_TYPE;
  NUM_COL1_NEW_LIST SHIPPING_ADDRESS_ID1_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,SHIPPING_ADDRESS_ID1
         FROM OKL_SUPP_INVOICE_DTLS yt, ra_customer_merges m
         WHERE (
            yt.SHIPPING_ADDRESS_ID1 = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_SUPP_INVOICE_DTLS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_SUPP_INVOICE_DTLS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY);
    END IF;

		FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_SUPP_INVOICE_DTLS yt SET
           SHIPPING_ADDRESS_ID1=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
	  --NISINHA Bug#6655434 removed extra attributes
      WHERE ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'SID_ACCOUNT_MERGE');
    RAISE;
END SID_ACCOUNT_MERGE;

/*-------------------------------------------------------------
|  PROCEDURE
|      SIDH_ACCOUNT_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, OKL_SUPP_INVOICE_DTLS_H
|--------------------------------------------------------------*/
PROCEDURE SIDH_ACCOUNT_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ID_LIST_TYPE IS TABLE OF
         OKL_SUPP_INVOICE_DTLS_H.ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

  TYPE SHIPPING_ADDRESS_ID1_LIST_TYPE IS TABLE OF
         OKL_SUPP_INVOICE_DTLS_H.SHIPPING_ADDRESS_ID1%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SHIPPING_ADDRESS_ID1_LIST_TYPE;
  NUM_COL1_NEW_LIST SHIPPING_ADDRESS_ID1_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,ID
              ,SHIPPING_ADDRESS_ID1
         FROM OKL_SUPP_INVOICE_DTLS_H yt, ra_customer_merges m
         WHERE (
            yt.SHIPPING_ADDRESS_ID1 = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKL_SUPP_INVOICE_DTLS_H',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'OKL_SUPP_INVOICE_DTLS_H',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OKL_SUPP_INVOICE_DTLS_H yt SET
           SHIPPING_ADDRESS_ID1=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
  	  --NISINHA Bug#6655434 removed extra attributes
      WHERE ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'SIDH_ACCOUNT_MERGE');
    RAISE;
END SIDH_ACCOUNT_MERGE;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : TCN_PARTY_REL_ID1_NEW
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID1_NEW
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID1_NEW
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE TCN_PARTY_REL_ID1_NEW (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TCN_PARTY_REL_ID1_NEW';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID1_NEW');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID1_NEW()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return

        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id

        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_TRX_CONTRACTS_ALL',FALSE);

        --updating the OKL_TRX_CONTRACTS_ALL table for column references PARTY_REL_ID1_NEW

        UPDATE OKL_TRX_CONTRACTS_ALL TAB
           SET TAB.PARTY_REL_ID1_NEW = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.PARTY_REL_ID1_NEW = p_from_fk_id; -- MGAAP 7263041
--rkuttiya added for 12.1.1 multigaap project
        --AND   TAB.REPRESENTATION_TYPE = 'PRIMARY' ;
--

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'TCN_PARTY_REL_ID1_NEW for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END TCN_PARTY_REL_ID1_NEW ;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : TCN_PARTY_REL_ID1_OLD
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID1_OLD
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID1_OLD
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE TCN_PARTY_REL_ID1_OLD (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TCN_PARTY_REL_ID1_OLD';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID1_OLD');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID1_OLD()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return

        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id

        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_TRX_CONTRACTS_ALL',FALSE);

        --updating the OKL_TRX_CONTRACTS_ALL table for column references PARTY_REL_ID1_OLD

        UPDATE OKL_TRX_CONTRACTS_ALL TAB
           SET TAB.PARTY_REL_ID1_OLD = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.PARTY_REL_ID1_OLD = p_from_fk_id; -- MGAAP 7263041
--rkuttiya added for 12.1.1 multigaap project
        --AND REPRESENTATION_TYPE = 'PRIMARY' ;
--

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'TCN_PARTY_REL_ID1_OLD for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END TCN_PARTY_REL_ID1_OLD ;

----------------------------------------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : TCN_PARTY_REL_ID2_OLD
-- Description     : Updating the table: OKL_TRX_CONTRACTS_ALL for column: PARTY_REL_ID2_OLD
-- Business Rules  : performing PARTY MERGE for table: OKL_TRX_CONTRACTS_ALL and col: PARTY_REL_ID2_OLD
-- Parameters      :
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------------------------------------------
  PROCEDURE TCN_PARTY_REL_ID2_OLD (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2 )
  IS

	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'TCN_PARTY_REL_ID2_OLD';
	l_count                      NUMBER(10)   := 0;
  BEGIN
	--Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID2_OLD');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

  arp_message.set_line('OKL_PARTY_MERGE_PUB.TCN_PARTY_REL_ID2_OLD()+');
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

        select merge_reason_code
           into   l_merge_reason_code
        from   hz_merge_batch
        where  batch_id  = p_batch_id;

        if l_merge_reason_code = 'DUPLICATE' then
         -- if reason code is duplicate then allow the party merge to happen without
         -- any validations.
        null;
        else
        -- if there are any validations to be done, include it in this section
        null;
        end if;

        -- If the parent has not changed (ie. Parent getting transferred) then nothing
        -- needs to be done. Set Merged To Id is same as Merged From Id and return

        if p_from_fk_id = p_to_fk_id then
          x_to_id := p_from_id;
        return;
        end if;

        -- If the parent has changed(ie. Parent is getting merged) then transfer the
        -- dependent record to the new parent. Before transferring check if a similar
        -- dependent record exists on the new parent. If a duplicate exists then do
        -- not transfer and return the id of the duplicate record as the Merged To Id

        if p_from_fk_id <> p_to_fk_id then
          begin
             arp_message.set_name('AR','AR_UPDATING_TABLE');
             arp_message.set_token('TABLE_NAME','OKL_TRX_CONTRACTS_ALL',FALSE);

        --updating the OKL_TRX_CONTRACTS_ALL table for column references PARTY_REL_ID2_OLD

        UPDATE OKL_TRX_CONTRACTS_ALL TAB
           SET TAB.PARTY_REL_ID2_OLD = p_to_fk_id
           ,TAB.object_version_number = TAB.object_version_number + 1
           ,TAB.last_update_date      = SYSDATE
           ,TAB.last_updated_by       = arp_standard.profile.user_id
           ,TAB.last_update_login     = arp_standard.profile.last_update_login
        WHERE TAB.PARTY_REL_ID2_OLD = to_char(p_from_fk_id); -- MGAAP 7263041
  --rkuttiya added for 12.1.1 Multi gaap
        --AND REPRESENTATION_TYPE = 'PRIMARY';
  --

        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));

        exception
           when others then
              arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
              fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'TCN_PARTY_REL_ID2_OLD for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
              x_return_status :=  FND_API.G_RET_STS_ERROR;
           end;
        end if;
  END TCN_PARTY_REL_ID2_OLD ;

  ----------------------------------------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : RUL_PARTY_SITE_MERGE
  -- Description     : Updating the table: OKC_RULES_B for column: OBJECT1_ID1
  -- Business Rules  : performing PARTY MERGE for table: OKC_RULES_B and col: OBJECT1_ID1
  --                   for the records created by Lease Management for Party Site
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  -----------------------------------------------------------------------------------------------------------
  PROCEDURE RUL_PARTY_SITE_MERGE (
	p_entity_name          IN VARCHAR2,
	p_from_id              IN NUMBER,
	x_to_id                OUT NOCOPY NUMBER,
	p_from_fk_id           IN NUMBER,
	p_to_fk_id             IN NUMBER,
	p_parent_entity_name   IN VARCHAR2,
	p_batch_id             IN NUMBER,
	p_batch_party_id       IN NUMBER,
	x_return_status        OUT NOCOPY VARCHAR2)
  IS
	l_merge_reason_code          VARCHAR2(30);
	l_api_name                   VARCHAR2(30) := 'RUL_PARTY_SITE_MERGE';
	l_count                      NUMBER(10)   := 0;
  BEGIN
    --Log statements for all input parameters and the procedure name
	fnd_file.put_line(fnd_file.log, 'OKL_PARTY_MERGE_PUB.RUL_PARTY_SITE_MERGE');
	fnd_file.put_line(fnd_file.log, '******             PARAMETERS                          ****** ');
	fnd_file.put_line(fnd_file.log, 'p_entity_name :        '||p_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_from_id :            '||p_from_id);
	fnd_file.put_line(fnd_file.log, 'p_from_fk_id :         '||p_from_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_to_fk_id :           '||p_to_fk_id);
	fnd_file.put_line(fnd_file.log, 'p_parent_entity_name : '||p_parent_entity_name);
	fnd_file.put_line(fnd_file.log, 'p_batch_id :           '||p_batch_id);
	fnd_file.put_line(fnd_file.log, 'p_batch_party_id :     '||p_batch_party_id);

    arp_message.set_line('OKL_PARTY_MERGE_PUB.RUL_PARTY_SITE_MERGE()+');
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from   hz_merge_batch
    where  batch_id  = p_batch_id;

    if l_merge_reason_code = 'DUPLICATE' then
      -- if reason code is duplicate then allow the party merge to happen without
      -- any validations.
      null;
    else
      -- if there are any validations to be done, include it in this section
      null;
    end if;

    -- If the parent has not changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return

    if p_from_fk_id = p_to_fk_id
    then
      x_to_id := p_from_id;
      return;
    end if;

    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    if p_from_fk_id <> p_to_fk_id
    then
      begin
        arp_message.set_name('AR','AR_UPDATING_TABLE');
        arp_message.set_token('TABLE_NAME','OKC_RULES_B',FALSE);

        IF p_parent_entity_name = 'HZ_PARTY_SITES'
        THEN
          --updating the OKC_RULES_B table for column references OBJECT1_ID1
          --and JTOT_OBJECT1_CODE = 'OKL_PARTYSITE'
          UPDATE OKC_RULES_B TAB
            SET TAB.OBJECT1_ID1 = p_to_fk_id
              , TAB.object_version_number = TAB.object_version_number + 1
              , TAB.last_update_date      = SYSDATE
              , TAB.last_updated_by       = arp_standard.profile.user_id
              , TAB.last_update_login     = arp_standard.profile.last_update_login
          WHERE TAB.OBJECT1_ID1 = TO_CHAR(p_from_fk_id)
            AND JTOT_OBJECT1_CODE = 'OKL_PARTYSITE'
            AND DNZ_CHR_ID IN (SELECT ID FROM OKL_K_HEADERS);
        END IF;
        l_count := sql%rowcount;
        arp_message.set_name('AR','AR_ROWS_UPDATED');
        arp_message.set_token('NUM_ROWS',to_char(l_count));
      EXCEPTION
        when others
        then
          arp_message.set_line(G_PKG_NAME || '.' || l_api_name || ': ' || sqlerrm);
          fnd_file.put_line(fnd_file.log,(G_PKG_NAME || '.' || l_api_name ||
                'OKC_RULES_B for = '|| p_from_id));
              fnd_file.put_line(fnd_file.log, G_PKG_NAME||'.'||l_api_name||':'||sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
      END;
    END IF;
  END RUL_PARTY_SITE_MERGE;

  /*-------------------------------------------------------------
  |  PROCEDURE
  |      RUL_ACCOUNT_MERGE
  |  DESCRIPTION :
  |      Account merge procedure for the table, OKC_RULES_B for OKL
  |      specific usage of rules architecture. OKL uses rules
  |      architecture for storing vendor billing information where
  |      billing party is stored in rules tables for the vendor account
  |      This API will be called prior to the OKC hook of account merge.
  *--------------------------------------------------------------*/
  PROCEDURE RUL_ACCOUNT_MERGE(
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2)
  IS
    TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
    MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

    TYPE ID_LIST_TYPE IS TABLE OF OKC_RULES_B.ID%TYPE
        INDEX BY BINARY_INTEGER;
    PRIMARY_KEY_ID_LIST ID_LIST_TYPE;

    TYPE CUST_ACCT_ID_LIST_TYPE IS TABLE OF OKC_K_PARTY_ROLES_B.CUST_ACCT_ID%TYPE
        INDEX BY BINARY_INTEGER;
    NUM_COL1_ORIG_LIST CUST_ACCT_ID_LIST_TYPE;
    NUM_COL1_NEW_LIST CUST_ACCT_ID_LIST_TYPE;

    TYPE RUL_OBJ1_ID_LIST_TYPE IS TABLE OF
         OKC_RULES_B.OBJECT1_ID1%TYPE
        INDEX BY BINARY_INTEGER;
    NUM_RUL_OBJ1_ORIG_LIST RUL_OBJ1_ID_LIST_TYPE;
    NUM_RUL_OBJ1_NEW_LIST  RUL_OBJ1_ID_LIST_TYPE;

    l_profile_val VARCHAR2(30);
    CURSOR merged_records IS
      SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
           , rul.ID
           , yt.CUST_ACCT_ID
           , rul.object1_id1
      FROM OKC_RULES_B         rul
         , OKC_RG_PARTY_ROLES  rgpr
         , OKC_RULE_GROUPS_B   rgp
         , OKC_K_PARTY_ROLES_B yt
         , RA_CUSTOMER_MERGES m
      WHERE yt.cust_acct_id = m.duplicate_id
        AND rgpr.cpl_id = yt.id
        AND rgp.id = rgpr.rgp_id
        AND rgp.rgd_code = 'LAVENB'
        AND rul.rgp_id = rgp.id
        AND rul.rule_information_category = 'LAVENC'
        AND m.process_flag = 'N'
        AND m.request_id = req_id
        AND m.set_number = set_num
        AND EXISTS( SELECT 1
                    FROM OKL_K_HEADERS KHR
                    WHERE yt.DNZ_CHR_ID  =  KHR.ID);

    CURSOR get_new_party(cp_cust_acct_id HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE)
    IS
      SELECT PARTY_ID
      FROM HZ_CUST_ACCOUNTS
      WHERE CUST_ACCOUNT_ID = cp_cust_acct_id;

    l_last_fetch BOOLEAN := FALSE;
    l_count NUMBER;
  BEGIN
    IF process_mode='LOCK' THEN
      NULL;
    ELSE
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OKC_RULES_B',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;
      LOOP
        FETCH merged_records BULK COLLECT INTO
              MERGE_HEADER_ID_LIST
            , PRIMARY_KEY_ID_LIST
            , NUM_COL1_ORIG_LIST
            , NUM_RUL_OBJ1_ORIG_LIST;

        IF merged_records%NOTFOUND THEN
           l_last_fetch := TRUE;
        END IF;
        IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
          exit;
        END IF;
        FOR I in 1..MERGE_HEADER_ID_LIST.COUNT
        LOOP
          NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));

          -- get the party of the new customer account
          OPEN get_new_party(NUM_COL1_NEW_LIST(I));
          FETCH get_new_party INTO NUM_RUL_OBJ1_NEW_LIST(I);
          CLOSE get_new_party;
        END LOOP;

        IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
          FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
           INSERT INTO HZ_CUSTOMER_MERGE_LOG
           (MERGE_LOG_ID,
            TABLE_NAME,
            MERGE_HEADER_ID,
            PRIMARY_KEY_ID1,
            NUM_COL1_ORIG,
            NUM_COL1_NEW,
            ACTION_FLAG,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATE_LOGIN,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY)
           VALUES
           (HZ_CUSTOMER_MERGE_LOG_s.nextval,
            'OKC_RULES_B',
            MERGE_HEADER_ID_LIST(I),
            PRIMARY_KEY_ID_LIST(I),
            NUM_RUL_OBJ1_ORIG_LIST(I),
            NUM_RUL_OBJ1_NEW_LIST(I),
            'U',
            req_id,
            hz_utility_pub.CREATED_BY,
            hz_utility_pub.CREATION_DATE,
            hz_utility_pub.LAST_UPDATE_LOGIN,
            hz_utility_pub.LAST_UPDATE_DATE,
            hz_utility_pub.LAST_UPDATED_BY);
        END IF;

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
          UPDATE OKC_RULES_B yt SET
            OBJECT1_ID1=NUM_RUL_OBJ1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          WHERE ID=PRIMARY_KEY_ID_LIST(I);
        l_count := l_count + SQL%ROWCOUNT;
        IF l_last_fetch THEN
          EXIT;
        END IF;
      END LOOP;

      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      arp_message.set_line('RUL_ACCOUNT_MERGE');
      RAISE;
  END RUL_ACCOUNT_MERGE;

END OKL_PARTY_MERGE_PUB;

/
