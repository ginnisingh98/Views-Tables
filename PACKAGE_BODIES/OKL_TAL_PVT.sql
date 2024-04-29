--------------------------------------------------------
--  DDL for Package Body OKL_TAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAL_PVT" AS
/* $Header: OKLSTALB.pls 120.8 2008/05/23 19:30:58 cklee noship $ */
-- Badrinath Kuchibholta
/************************ HAND-CODED *********************************/
G_TABLE_TOKEN                CONSTANT  VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR           CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';

G_TAL_LOOKUP_TYPE            CONSTANT  VARCHAR2(200) := 'OKL_TRANS_LINE_TYPE';
G_ID2                        CONSTANT  VARCHAR2(200) := '#';
G_SQLERRM_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLcode';
G_RANGE_CHECK                CONSTANT VARCHAR2(200) := 'OKL_GREATER_THAN';
G_SALVAGE_RANGE              CONSTANT VARCHAR2(200) := 'OKL_LLA_SALVAGE_VALUE';
G_COL_NAME_TOKEN1	     CONSTANT VARCHAR2(200) := 'COL_NAME1';
G_COL_NAME_TOKEN2            CONSTANT VARCHAR2(200) := 'COL_NAME2';
G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
G_INVALID_VALUE              CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
G_NO_MATCHING_RECORD         CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
G_EXCEPTION_HALT_VALIDATION            EXCEPTION;
G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
-- List validation procedures for quick reference
--1.  validate_tas_id           -- Attribute Validation
--2.  validate_ilo_id           -- Attribute Validation
--3.  validate_ilo_id_old       -- Attribute Validation
--4.  validate_iay_id           -- Attribute Validation
--5.  validate_iay_id_new       -- Attribute Validation
--6.  validate_kle_id           -- Attribute Validation
--7.  validate_tal_type         -- Attribute Validation
--8.  validate_org_id           -- Attribute Validation
--9.  validate_asset_number     -- Attribute Validation
--10. validate_current_units    -- Attribute Validation
--11. validate_used_asset_yn    -- Attribute Validation
--12. validate_life_in_months   -- Attribute Validation
--13. validate_deprn_id         -- Attribute Validation
--14. validate_fa_location_id   -- Attribute Validation
--15. validate_dnz_khr_id       -- Attribute Validation
--16. validate_shipping_id1     -- Attribute Validation
--17. validate_shipping_id2     -- Attribute Validation
--18. validate_shipping_code    -- Attribute Validation
--19. validate_corp_book        -- Attribute Validation
--20  validate_deprn_method     -- Attribute Validation
--21. validate_pds_date         -- Tuple Record Validation
--22 .validate_salv_oec         -- Tuple Record Validation
--23. validate_inv_due_date     -- Tuple Record Validation
------------------------------1----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_tas_id
-- Description          : FK validation with OKL_TRX_ASSETS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tas_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_tas_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id
                 FROM OKL_TRX_ASSETS
                 WHERE id = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.tas_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.tas_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_tas_id_validate(p_talv_rec.tas_id);
    IF c_tas_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_tas_id_validate into ln_dummy;
    CLOSE c_tas_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tas_id');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tas_id');
    IF c_tas_id_validate%ISOPEN THEN
       CLOSE c_tas_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_tas_id_validate%ISOPEN THEN
       CLOSE c_tas_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tas_id;
-------------------------------2--------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_ilo_id
-- Description          : FK validation with OKX_AST_LOCS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_ilo_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_ilo_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id1
                 FROM OKX_AST_LOCS_V
                 WHERE id1 = p_id
                 AND id2 = G_ID2);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.ilo_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.ilo_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_ilo_id_validate(p_talv_rec.ilo_id);
    IF c_ilo_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_ilo_id_validate into ln_dummy;
    CLOSE c_ilo_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'ilo_id');
    -- notify caller of an error
    IF c_ilo_id_validate%ISOPEN THEN
       CLOSE c_ilo_id_validate;
    END IF;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_ilo_id_validate%ISOPEN THEN
       CLOSE c_ilo_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_ilo_id;
--------------------------------3-------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_ilo_id_old
-- Description          : FK validation with OKX_AST_LOCS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_ilo_id_old(x_return_status OUT NOCOPY VARCHAR2,
                                p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_ilo_id_old_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id1
                 FROM OKX_AST_LOCS_V
                 WHERE id1 = p_id
                 AND id2 = G_ID2);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.ilo_id_old = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.ilo_id_old IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_ilo_id_old_validate(p_talv_rec.ilo_id_old);
    IF c_ilo_id_old_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_ilo_id_old_validate into ln_dummy;
    CLOSE c_ilo_id_old_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'ilo_id_old');
    IF c_ilo_id_old_validate%ISOPEN THEN
       CLOSE c_ilo_id_old_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_ilo_id_old_validate%ISOPEN THEN
       CLOSE c_ilo_id_old_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_ilo_id_old;
---------------------------------4-----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_iay_id
-- Description          : FK validation with OKX_ASST_CATGRS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_iay_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_iay_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id1
                 FROM OKX_ASST_CATGRS_V
                 WHERE id1 = p_id
                 AND id2 = G_ID2);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.iay_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.iay_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_iay_id_validate(p_talv_rec.iay_id);
    IF c_iay_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_iay_id_validate into ln_dummy;
    CLOSE c_iay_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'iay_id');
    -- If the cursor is open then it has to be closed
    IF c_iay_id_validate%ISOPEN THEN
       CLOSE c_iay_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_iay_id_validate%ISOPEN THEN
       CLOSE c_iay_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_iay_id;
----------------------------------5----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_iay_id_new
-- Description          : FK validation with OKX_ASST_CATGRS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_iay_id_new(x_return_status OUT NOCOPY VARCHAR2,
                                p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_iay_id_new_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id1
                 FROM OKX_ASST_CATGRS_V
                 WHERE id1 = p_id
                 AND id2 = G_ID2);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.iay_id_new = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.iay_id_new IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_iay_id_new_validate(p_talv_rec.iay_id_new);
    -- If the cursor is open then it has to be closed
    IF c_iay_id_new_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_iay_id_new_validate into ln_dummy;
    CLOSE c_iay_id_new_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
      WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'iay_id_new');
    -- If the cursor is open then it has to be closed
    IF c_iay_id_new_validate%ISOPEN THEN
       CLOSE c_iay_id_new_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_iay_id_new_validate%ISOPEN THEN
       CLOSE c_iay_id_new_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_iay_id_new;
----------------------------------6-----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_kle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_kle_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_kle_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id
                 FROM OKL_K_LINES_V
                 WHERE id = p_id);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.kle_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.kle_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_kle_id_validate(p_talv_rec.kle_id);
    IF c_kle_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_kle_id_validate into ln_dummy;
    CLOSE c_kle_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'kle_id');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'kle_id');
    -- If the cursor is open then it has to be closed
    IF c_kle_id_validate%ISOPEN THEN
       CLOSE c_kle_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_kle_id_validate%ISOPEN THEN
       CLOSE c_kle_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_kle_id;
-----------------------------------7-----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_TAL_TYPE
-- Description          : FK validation with FND COMMON LOOKUPS
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tal_type(x_return_status OUT NOCOPY VARCHAR2,
                              p_talv_rec IN talv_rec_type) IS
    l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.tal_type = OKC_API.G_MISS_CHAR) OR
       (p_talv_rec.tal_type IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    l_return_status := OKC_UTIL.check_lookup_code(G_TAL_LOOKUP_TYPE,
                                                  p_talv_rec.tal_type);
    IF l_return_status = x_return_status THEN
       x_return_status := l_return_status;
    ELSIF l_return_status <> x_return_status THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tal_type');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tal_type');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tal_type;
-----------------------------------8---------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_org_id
-- Description          : Validate org_id against OKC_K_HEADERS_V.AUTHORING_ORG_ID
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_org_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_talv_rec IN talv_rec_type) IS
  ln_dummy number := 0;
  CURSOR c_org_id_validate(p_org_id OKL_TXL_ASSETS_B.ORG_ID%TYPE,
                           p_kle_id OKL_TXL_ASSETS_B.KLE_ID%TYPE) is
  SELECT 1
  FROM DUAL
  WHERE EXISTS (SELECT chrv.authoring_org_id
                FROM OKC_K_HEADERS_B chrv,
                     OKC_K_LINES_B cle,
                     OKL_K_LINES_V kle
                WHERE kle.id = p_kle_id
                AND kle.id = cle.id
                AND cle.dnz_chr_id = chrv.id
                AND chrv.authoring_org_id = p_org_id);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.org_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.org_id IS NULL) THEN
       -- halt validation as it is optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_org_id_validate(p_talv_rec.org_id,
                            p_talv_rec.kle_id);
    IF c_org_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_org_id_validate into ln_dummy;
    CLOSE c_org_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'org_id');
    IF c_org_id_validate%ISOPEN THEN
       CLOSE c_org_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_org_id_validate%ISOPEN THEN
       CLOSE c_org_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_org_id;
-----------------------------------10---------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_current_units
-- Description          : See that is more than 0
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_current_units(x_return_status OUT NOCOPY VARCHAR2,
                                   p_talv_rec IN talv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.current_units = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.current_units IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- See that is more than 0
    IF p_talv_rec.current_units <= 0 THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'current_units');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'current_units');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_current_units;

-------------------------------------11-------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_used_asset_yn
-- Description          : Check Constraint for Y,N
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_used_asset_yn(x_return_status OUT NOCOPY VARCHAR2,
                                   p_talv_rec IN talv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.used_asset_yn = OKC_API.G_MISS_CHAR) OR
       (p_talv_rec.used_asset_yn IS NULL) THEN
        -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- See that in Y,N
    IF p_talv_rec.used_asset_yn not in ('Y','N') THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'used_asset_yn');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_used_asset_yn;
---------------------------------------12-----------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_life_in_months
-- Description          : See that is more than 0
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_life_in_months(x_return_status OUT NOCOPY VARCHAR2,
                                    p_talv_rec IN talv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.life_in_months = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.life_in_months IS NULL) THEN
        -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- See that is more than 0
    IF p_talv_rec.life_in_months <= 0 THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'life_in_months');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_life_in_months;
-----------------------------------------13---------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_deprn_id
-- Description          : FK validation with OKX_ASST_CATGRS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_deprn_id(x_return_status OUT NOCOPY VARCHAR2,
                              p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_deprn_id_validate(p_id1 OKX_ASST_CATGRS_V.ID1%type) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_ASST_CATGRS_V
                  WHERE id1 = p_id1
                  and id2 = G_ID2);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.depreciation_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.depreciation_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce validation
    OPEN  c_deprn_id_validate(p_talv_rec.depreciation_id);
    IF c_deprn_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_deprn_id_validate into ln_dummy;
    CLOSE c_deprn_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'depreciation_id');
    -- If the cursor is open then it has to be closed
    IF c_deprn_id_validate%ISOPEN THEN
       CLOSE c_deprn_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_deprn_id_validate%ISOPEN THEN
       CLOSE c_deprn_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_deprn_id;
-------------------------------------------14-------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_fa_location_id
-- Description          : FK validation with OKX_ASST_LOCS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_fa_location_id(x_return_status OUT NOCOPY VARCHAR2,
                                  p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_fa_location_id_validate(p_fa_location_id OKX_AST_LOCS_V.LOCATION_ID%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_AST_LOCS_V
                  WHERE id1 = p_fa_location_id
                  AND id2 = G_ID2);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.fa_location_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.fa_location_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Validation
    OPEN  c_fa_location_id_validate(p_talv_rec.fa_location_id);
    -- If the cursor is open then it has to be closed
    IF c_fa_location_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_fa_location_id_validate into ln_dummy;
    CLOSE c_fa_location_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'fa_location_id');
    -- If the cursor is open then it has to be closed
    IF c_fa_location_id_validate%ISOPEN THEN
       CLOSE c_fa_location_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_fa_location_id_validate%ISOPEN THEN
       CLOSE c_fa_location_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_fa_location_id;

---------------------------------------------15-----------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_dnz_khr_id
-- Description          : FK validation with OKL_K_HEADERS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_dnz_khr_id(x_return_status OUT NOCOPY VARCHAR2,
                                p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_dnz_khr_id_validate(p_dnz_khr_id OKL_TXL_ASSETS_V.DNZ_KHR_ID%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKC_K_HEADERS_B chrv
                  WHERE chrv.id = p_dnz_khr_id);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.dnz_khr_id = OKC_API.G_MISS_NUM) OR
       (p_talv_rec.dnz_khr_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Validation
    OPEN  c_dnz_khr_id_validate(p_talv_rec.dnz_khr_id);
    -- If the cursor is open then it has to be closed
    IF c_dnz_khr_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_dnz_khr_id_validate into ln_dummy;
    CLOSE c_dnz_khr_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'dnz_khr_id');
    -- If the cursor is open then it has to be closed
    IF c_dnz_khr_id_validate%ISOPEN THEN
       CLOSE c_dnz_khr_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_dnz_khr_id_validate%ISOPEN THEN
       CLOSE c_dnz_khr_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_dnz_khr_id;
------------------------------19----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_corp_book
-- Description          : FK validation with OKX_ASST_BK_CONTROLS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_corp_book(x_return_status OUT NOCOPY VARCHAR2,
                               p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_corp_book_validate(p_name OKX_ASST_BK_CONTROLS_V.NAME%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id1
                 FROM OKX_ASST_BK_CONTROLS_V
                 WHERE name = p_name
                 AND book_class = 'CORPORATE');

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.corporate_book = OKC_API.G_MISS_CHAR) OR
       (p_talv_rec.corporate_book IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_corp_book_validate(p_talv_rec.corporate_book);
    IF c_corp_book_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_corp_book_validate into ln_dummy;
    CLOSE c_corp_book_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'corporate_book');
    IF c_corp_book_validate%ISOPEN THEN
       CLOSE c_corp_book_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_corp_book_validate%ISOPEN THEN
       CLOSE c_corp_book_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_corp_book;
--------------------------------20-------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_deprn_method
-- Description          : FK validation with OKX_ASST_DEP_METHODS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_deprn_method(x_return_status OUT NOCOPY VARCHAR2,
                                  p_talv_rec IN talv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_deprn_method_validate(p_deprn_method OKX_ASST_DEP_METHODS_V.METHOD_CODE%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT method_code
                 FROM OKX_ASST_DEP_METHODS_V
                 WHERE method_code  = p_deprn_method);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_talv_rec.deprn_method = OKC_API.G_MISS_CHAR) OR
       (p_talv_rec.deprn_method IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_deprn_method_validate(p_talv_rec.deprn_method);
    IF c_deprn_method_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_deprn_method_validate into ln_dummy;
    CLOSE c_deprn_method_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'deprn_method');
    IF c_deprn_method_validate%ISOPEN THEN
       CLOSE c_deprn_method_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_deprn_method_validate%ISOPEN THEN
       CLOSE c_deprn_method_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_deprn_method;

-----------------------------------------------21---------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_pds_date
-- Description          : Tuple record validation of date_purchased,date_delivery
--                        and in_service_date
-- Business Rules       : Delivery date,in_service_date
--                        Should be greater than Purchase date
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_pds_date(x_return_status OUT NOCOPY VARCHAR2,
                              p_talv_rec IN talv_rec_type) IS
    ln_dummy number := 0;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- purchase date should be less than delivery date
    -- and in service date
    -- When all the dates are given
    IF (p_talv_rec.date_purchased IS NOT NULL
       AND p_talv_rec.date_delivery IS NOT NULL
       AND p_talv_rec.in_service_date IS NOT NULL) THEN
       IF(p_talv_rec.date_purchased > p_talv_rec.date_delivery) AND
         (p_talv_rec.date_purchased > p_talv_rec.in_service_date) THEN
         -- halt validation as the above statments are true
         RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSIF ((p_talv_rec.date_purchased > p_talv_rec.date_delivery) OR
             (p_talv_rec.date_purchased > p_talv_rec.in_service_date) OR
             (p_talv_rec.date_delivery > p_talv_rec.in_service_date)) THEN
             -- Purchase date should be greater than date_delivery and in_service_date
             -- and date_delivery should be less than equal to in_service_date
             -- halt validation as the above statments are true
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'date_purchased,date_delivery,in_service_date');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_RANGE_CHECK,
                        p_token1       => G_COL_NAME_TOKEN1,
                        p_token1_value => 'date_delivery',
                        p_token2       => G_COL_NAME_TOKEN2,
                        p_token2_value => 'in_service_date');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_pds_date;

-------------------------------------------------22-------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_salv_oec
-- Description          : Tuple record validation of salvage_value
--                        ,original_cost
-- Business Rules       : original_cost Should be greater than salvage_value
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_salv_oec(x_return_status OUT NOCOPY VARCHAR2,
                              p_talv_rec IN talv_rec_type) IS
  ln_comp_prn_oec        NUMBER := 0;
  ln_comp_prn_salv       NUMBER := 0;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_talv_rec.original_cost IS NOT NULL AND
          p_talv_rec.salvage_value IS NOT NULL OR
          p_talv_rec.percent_salvage_value IS NOT NULL) THEN
          ln_comp_prn_oec := (p_talv_rec.original_cost/100);
       --Bug# 3950089
       IF(nvl(p_talv_rec.salvage_value,0) > p_talv_rec.original_cost) THEN
       --IF(p_talv_rec.salvage_value > p_talv_rec.original_cost) THEN
          -- original cost is greater than salvage value
          -- halt validation as the above statments are true
          RAISE G_EXCEPTION_HALT_VALIDATION;
       --Bug# 3950089
       ELSIF (p_talv_rec.percent_salvage_value > 100) THEN
       --ELSIF (p_talv_rec.percent_salvage_value > ln_comp_prn_oec) THEN
          -- To Check if computed original_cost is greater than percent_salvage_value
          -- halt validation as the above statments are true
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    ELSIF (p_talv_rec.original_cost IS NOT NULL
       AND p_talv_rec.salvage_value IS NOT NULL
       AND p_talv_rec.percent_salvage_value IS NOT NULL) THEN
       ln_comp_prn_oec := (p_talv_rec.original_cost/100);
       ln_comp_prn_salv := (p_talv_rec.salvage_value/100);
       IF (p_talv_rec.salvage_value > p_talv_rec.original_cost) AND
          (p_talv_rec.percent_salvage_value > ln_comp_prn_oec) THEN
          -- To Check if computed original_cost is greater than percent_salvage_value
          -- And original cost is greater than salvage value
          -- halt validation as the above statments are true
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSIF (p_talv_rec.salvage_value > p_talv_rec.original_cost) OR
          (p_talv_rec.percent_salvage_value > ln_comp_prn_oec) OR
          (ln_comp_prn_salv <> p_talv_rec.percent_salvage_value)  THEN
          -- To Check if computed original_cost is greater than percent_salvage_value
          -- or original cost is greater than salvage value
          -- or the computed salvage value is not equal to percentage salvage value
          -- halt validation as the above statments are true
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Original_cost');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_SALVAGE_RANGE);
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_salv_oec;
--Bug# 2981308
-------------------------------------------------23-------------------------------
-- Start of Commnets
-- avsingh
-- Procedure Name       : Validate_asset_key
-- Description          : validate asset key ccid
--
-- Business Rules       : Asset_Key_Id should exist as a valid code_combination_id
--                        in FA_ASSET_KEYWORDS
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_asset_key(x_return_status OUT NOCOPY VARCHAR2,
                              p_talv_rec IN talv_rec_type) IS

  l_exists Varchar2(1) default 'N';

  --cursor to check asset key ccid
  cursor l_fak_csr(p_asset_key_id in number) is
  select 'Y'
  from   FA_ASSET_KEYWORDS fak
  where  fak.CODE_COMBINATION_ID   = p_asset_key_id
  and    fak.enabled_flag          = 'Y';
  --and    trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
                        --and     trunc(nvl(end_date_active,sysdate));

  Begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      If p_talv_rec.asset_key_id <> OKL_API.G_MISS_NUM AND
         p_talv_rec.asset_key_id is NOT NULL then
          l_exists := 'N';
          open l_fak_csr(p_asset_key_id => p_talv_rec.asset_key_id);
          fetch l_fak_csr into l_exists;
          if l_fak_csr%NOTFOUND then
              NULL;
          end if;
          close l_fak_csr;
          IF l_exists = 'N' then
              OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Asset Key');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
      End If;

      EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
          null;
      WHEN OTHERS THEN
          If l_fak_csr%ISOPEN then
             close l_fak_csr;
          End If;

          OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_UNEXPECTED_ERROR
                              ,p_token1       => G_SQLCODE_TOKEN
                              ,p_token1_value => SQLCODE
                              ,p_token2       => G_SQLERRM_TOKEN
                              ,p_token2_value => SQLERRM);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_asset_key;


/************************ HAND-CODED *********************************/

-- Fix Bug# 2737014
--
-- Procedure Name  : roundoff_line_amount
-- Description     : Round off NOT NULL Asset Transaction line amounts
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

   PROCEDURE roundoff_line_amount(
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
                         p_talv_rec        IN  talv_rec_type,
                         x_talv_rec        OUT NOCOPY talv_rec_type
                        ) IS

   l_conv_amount   NUMBER;
   l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

   roundoff_error EXCEPTION;

   BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Take original record values
     x_talv_rec := p_talv_rec;

     l_currency_code := p_talv_rec.currency_code;

     IF (l_currency_code IS NULL) THEN -- Fatal error, Not a valid currency_code
        RAISE roundoff_error;
     END IF;

     --dbms_output.put_line('Round off start '||l_currency_code);
     -- Round off all Asset Transaction Line Amounts
     IF (p_talv_rec.original_cost IS NOT NULL
         AND
         p_talv_rec.original_cost <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.original_cost,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.original_cost := l_conv_amount;
     END IF;

     IF (p_talv_rec.depreciation_cost IS NOT NULL
         AND
         p_talv_rec.depreciation_cost <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.depreciation_cost,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.depreciation_cost := l_conv_amount;
     END IF;

     IF (p_talv_rec.salvage_value IS NOT NULL
         AND
         p_talv_rec.salvage_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.salvage_value,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.salvage_value := l_conv_amount;
     END IF;

     IF (p_talv_rec.old_salvage_value IS NOT NULL
         AND
         p_talv_rec.old_salvage_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.old_salvage_value,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.old_salvage_value := l_conv_amount;
     END IF;

     IF (p_talv_rec.new_residual_value IS NOT NULL
         AND
         p_talv_rec.new_residual_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.new_residual_value,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.new_residual_value := l_conv_amount;
     END IF;

     IF (p_talv_rec.old_residual_value IS NOT NULL
         AND
         p_talv_rec.old_residual_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.old_residual_value,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.old_residual_value := l_conv_amount;
     END IF;

     IF (p_talv_rec.cost_retired IS NOT NULL
         AND
         p_talv_rec.cost_retired <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.cost_retired,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.cost_retired := l_conv_amount;
     END IF;

     IF (p_talv_rec.sale_proceeds IS NOT NULL
         AND
         p_talv_rec.sale_proceeds <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.sale_proceeds,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.sale_proceeds := l_conv_amount;
     END IF;

     IF (p_talv_rec.match_amount IS NOT NULL
         AND
         p_talv_rec.match_amount <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_talv_rec.match_amount,
                                          p_currency_code => l_currency_code
                                         );

         x_talv_rec.match_amount := l_conv_amount;
     END IF;
     --dbms_output.put_line('Round off complete');

   EXCEPTION
     WHEN roundoff_error THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
   END roundoff_line_amount;


  -- Multi-Currency Change
  --
  -- PROCEDURE validate_currency
  -- Decription: This procedure validates currency_code during insert and update operation
  -- Logic:
  --       1. If transaction currency is NULL, take functional currency and
  --          make rate, date and type as NULL
  --       2. If transaction currency is NOT NULL and
  --             transaction currency <> functional currency and
  --             type <> 'User' then
  --            get conversion rate from GL and change rate column with new rate
  --       3. If transaction currency is NOT NULL and
  --             transaction currency <> functional currency and
  --             type = 'User' then
  --            take all values as it is
  --       4. If transaction currency = functional currency
  --            make rate, date and type as NULL
  --
  PROCEDURE validate_currency(
                              x_return_status OUT NOCOPY VARCHAR2,
                              p_talv_rec      IN  talv_rec_type,
                              x_talv_rec      OUT NOCOPY talv_rec_type
                             ) IS

  l_func_currency            GL_CURRENCIES.CURRENCY_CODE%TYPE;
  currency_validation_failed EXCEPTION;
  l_ok                       VARCHAR2(1);

  CURSOR conv_type_csr (p_conv_type gl_daily_conversion_types.conversion_type%TYPE) IS
  SELECT 'Y'
  FROM   gl_daily_conversion_types
  WHERE  conversion_type = p_conv_type;

  CURSOR curr_csr (p_curr_code gl_currencies.currency_code%TYPE) IS
  SELECT 'Y'
  FROM   gl_currencies
  WHERE  currency_code = p_curr_code
  AND    TRUNC(SYSDATE) BETWEEN NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) AND
                                NVL(TRUNC(end_date_active), TRUNC(SYSDATE));

  BEGIN

    x_talv_rec := p_talv_rec;
    l_func_currency := okl_accounting_util.get_func_curr_code();

    --dbms_output.put_line('Func Curr: '||l_func_currency);
    --dbms_output.put_line('Trans Curr Code: '|| p_talv_rec.currency_code);
    --dbms_output.put_line('Trans Curr Rate: '|| p_talv_rec.currency_conversion_rate);
    --dbms_output.put_line('Trans Curr Date: '|| p_talv_rec.currency_conversion_date);
    --dbms_output.put_line('Trans Curr Type: '|| p_talv_rec.currency_conversion_type);

    IF (p_talv_rec.currency_code IS NULL
        OR
        p_talv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN -- take functional currency
       x_talv_rec.currency_code := l_func_currency;
       x_talv_rec.currency_conversion_type := NULL;
       x_talv_rec.currency_conversion_rate := NULL;
       x_talv_rec.currency_conversion_date := NULL;
    ELSE

       l_ok := '?';
       OPEN curr_csr(p_talv_rec.currency_code);
       FETCH curr_csr INTO l_ok;
       CLOSE curr_csr;

       IF (l_ok <> 'Y') THEN
           OKC_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'currency_code');
           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE currency_validation_failed;
       END IF;

       IF (p_talv_rec.currency_code = l_func_currency) THEN -- both are same
           x_talv_rec.currency_conversion_type := NULL;
           x_talv_rec.currency_conversion_rate := NULL;
           x_talv_rec.currency_conversion_date := NULL;
       ELSE -- transactional and functional currency are different

           -- Conversion type, date and rate mandetory
           IF (p_talv_rec.currency_conversion_type IS NULL
               OR
               p_talv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
              OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'currency_conversion_type');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;

           l_ok := '?';
           OPEN conv_type_csr (p_talv_rec.currency_conversion_type);
           FETCH conv_type_csr INTO l_ok;
           CLOSE conv_type_csr;

           IF (l_ok <> 'Y') THEN
              OKC_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_NO_MATCHING_RECORD,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'currency_conversion_type');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;

           IF (p_talv_rec.currency_conversion_date IS NULL
               OR
               p_talv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
              OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'currency_conversion_date');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;

           IF (p_talv_rec.currency_conversion_type = 'User') THEN

               IF (p_talv_rec.currency_conversion_rate IS NULL
                   OR
                   p_talv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
                  OKC_API.set_message(
                                      p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_REQUIRED_VALUE,
                                      p_token1       => G_COL_NAME_TOKEN,
                                      p_token1_value => 'currency_conversion_rate');
                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  RAISE currency_validation_failed;
               END IF;

              x_talv_rec.currency_conversion_type := p_talv_rec.currency_conversion_type;
              x_talv_rec.currency_conversion_rate := p_talv_rec.currency_conversion_rate;
              x_talv_rec.currency_conversion_date := p_talv_rec.currency_conversion_date;

           ELSE -- conversion_type <> 'User'

              x_talv_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
                                                          p_from_curr_code => p_talv_rec.currency_code,
                                                          p_to_curr_code   => l_func_currency,
                                                          p_con_date       => p_talv_rec.currency_conversion_date,
                                                          p_con_type       => p_talv_rec.currency_conversion_type
                                                         );

              x_talv_rec.currency_conversion_type := p_talv_rec.currency_conversion_type;
              x_talv_rec.currency_conversion_date := p_talv_rec.currency_conversion_date;

           END IF; -- conversion_type
       END IF; -- currency_code check
    END IF; -- currency_code NULL

  EXCEPTION
    WHEN currency_validation_failed THEN
       RETURN;
  END validate_currency;
  -- Multi-Currency Change

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_TXL_ASSETS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_ASSETS_B B   --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TXL_ASSETS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXL_ASSETS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_ASSETS_TL SUBB, OKL_TXL_ASSETS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXL_ASSETS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_TXL_ASSETS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXL_ASSETS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ASSETS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tal_rec                      IN tal_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tal_rec_type IS
    CURSOR okl_txl_asset_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           ILO_ID,
           ILO_ID_OLD,
           IAY_ID,
           IAY_ID_NEW,
           KLE_ID,
           DNZ_KHR_ID,
           LINE_NUMBER,
           ORG_ID,
           TAL_TYPE,
           ASSET_NUMBER,
           FA_LOCATION_ID,
           ORIGINAL_COST,
           CURRENT_UNITS,
           MANUFACTURER_NAME,
           YEAR_MANUFACTURED,
           SUPPLIER_ID,
           USED_ASSET_YN,
           TAG_NUMBER,
           MODEL_NUMBER,
           CORPORATE_BOOK,
           DATE_PURCHASED,
           DATE_DELIVERY,
           IN_SERVICE_DATE,
           LIFE_IN_MONTHS,
           DEPRECIATION_ID,
           DEPRECIATION_COST,
           DEPRN_METHOD,
           DEPRN_RATE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
--Bug# 2981308
           ASSET_KEY_ID,
-- Bug# 4028371
           FA_TRX_DATE,
--Bug# 4899328
           FA_COST,
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
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           DEPRECIATE_YN,
           HOLD_PERIOD_DAYS,
           OLD_SALVAGE_VALUE,
           NEW_RESIDUAL_VALUE,
           OLD_RESIDUAL_VALUE,
           UNITS_RETIRED,
           COST_RETIRED,
           SALE_PROCEEDS,
           REMOVAL_COST,
           DNZ_ASSET_ID,
           DATE_DUE,
           REP_ASSET_ID,
           LKE_ASSET_ID,
           MATCH_AMOUNT,
           SPLIT_INTO_SINGLES_FLAG,
           SPLIT_INTO_UNITS,
        -- Multi-Currency Change
           currency_code,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date,
        -- Multi-Currency Change
        -- VRS Project - START
           RESIDUAL_SHR_PARTY_ID,
           RESIDUAL_SHR_AMOUNT,
           RETIREMENT_ID
        -- VRS Project - END
       FROM Okl_Txl_Assets_B
     WHERE okl_txl_assets_b.id  = p_id;
    l_okl_txl_asset_b_pk           okl_txl_asset_b_pk_csr%ROWTYPE;
    l_tal_rec                      tal_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_asset_b_pk_csr (p_tal_rec.id);
    FETCH okl_txl_asset_b_pk_csr INTO
              l_tal_rec.ID,
              l_tal_rec.OBJECT_VERSION_NUMBER,
              l_tal_rec.TAS_ID,
              l_tal_rec.ILO_ID,
              l_tal_rec.ILO_ID_OLD,
              l_tal_rec.IAY_ID,
              l_tal_rec.IAY_ID_NEW,
              l_tal_rec.KLE_ID,
              l_tal_rec.DNZ_KHR_ID,
              l_tal_rec.LINE_NUMBER,
              l_tal_rec.ORG_ID,
              l_tal_rec.TAL_TYPE,
              l_tal_rec.ASSET_NUMBER,
              l_tal_rec.FA_LOCATION_ID,
              l_tal_rec.ORIGINAL_COST,
              l_tal_rec.CURRENT_UNITS,
              l_tal_rec.MANUFACTURER_NAME,
              l_tal_rec.YEAR_MANUFACTURED,
              l_tal_rec.SUPPLIER_ID,
              l_tal_rec.USED_ASSET_YN,
              l_tal_rec.TAG_NUMBER,
              l_tal_rec.MODEL_NUMBER,
              l_tal_rec.CORPORATE_BOOK,
              l_tal_rec.DATE_PURCHASED,
              l_tal_rec.DATE_DELIVERY,
              l_tal_rec.IN_SERVICE_DATE,
              l_tal_rec.LIFE_IN_MONTHS,
              l_tal_rec.DEPRECIATION_ID,
              l_tal_rec.DEPRECIATION_COST,
              l_tal_rec.DEPRN_METHOD,
              l_tal_rec.DEPRN_RATE,
              l_tal_rec.SALVAGE_VALUE,
              l_tal_rec.PERCENT_SALVAGE_VALUE,
--Bug# 2981308
              l_tal_rec.ASSET_KEY_ID,
-- Bug# 4028371
              l_tal_rec.FA_TRX_DATE,
--Bug# 4899328
              l_tal_rec.FA_COST,
              l_tal_rec.ATTRIBUTE_CATEGORY,
              l_tal_rec.ATTRIBUTE1,
              l_tal_rec.ATTRIBUTE2,
              l_tal_rec.ATTRIBUTE3,
              l_tal_rec.ATTRIBUTE4,
              l_tal_rec.ATTRIBUTE5,
              l_tal_rec.ATTRIBUTE6,
              l_tal_rec.ATTRIBUTE7,
              l_tal_rec.ATTRIBUTE8,
              l_tal_rec.ATTRIBUTE9,
              l_tal_rec.ATTRIBUTE10,
              l_tal_rec.ATTRIBUTE11,
              l_tal_rec.ATTRIBUTE12,
              l_tal_rec.ATTRIBUTE13,
              l_tal_rec.ATTRIBUTE14,
              l_tal_rec.ATTRIBUTE15,
              l_tal_rec.CREATED_BY,
              l_tal_rec.CREATION_DATE,
              l_tal_rec.LAST_UPDATED_BY,
              l_tal_rec.LAST_UPDATE_DATE,
              l_tal_rec.LAST_UPDATE_LOGIN,
              l_tal_rec.DEPRECIATE_YN,
              l_tal_rec.HOLD_PERIOD_DAYS,
              l_tal_rec.OLD_SALVAGE_VALUE,
              l_tal_rec.NEW_RESIDUAL_VALUE,
              l_tal_rec.OLD_RESIDUAL_VALUE,
              l_tal_rec.UNITS_RETIRED,
              l_tal_rec.COST_RETIRED,
              l_tal_rec.SALE_PROCEEDS,
              l_tal_rec.REMOVAL_COST,
              l_tal_rec.DNZ_ASSET_ID,
              l_tal_rec.DATE_DUE,
              l_tal_rec.REP_ASSET_ID,
              l_tal_rec.LKE_ASSET_ID,
              l_tal_rec.MATCH_AMOUNT,
              l_tal_rec.SPLIT_INTO_SINGLES_FLAG,
              l_tal_rec.SPLIT_INTO_UNITS,
        -- Multi-Currency Change
              l_tal_rec.currency_code,
              l_tal_rec.currency_conversion_type,
              l_tal_rec.currency_conversion_rate,
              l_tal_rec.currency_conversion_date,
        -- Multi-Currency Change
        -- VRS Project - START
              l_tal_rec.RESIDUAL_SHR_PARTY_ID,
              l_tal_rec.RESIDUAL_SHR_AMOUNT,
              l_tal_rec.RETIREMENT_ID;
        -- VRS Project - END
    x_no_data_found := okl_txl_asset_b_pk_csr%NOTFOUND;
    CLOSE okl_txl_asset_b_pk_csr;
    RETURN(l_tal_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tal_rec                      IN tal_rec_type
  ) RETURN tal_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tal_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ASSETS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txl_assets_tl_rec        IN okl_txl_assets_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txl_assets_tl_rec_type IS
    CURSOR okl_txl_asset_tl_pk_csr (p_id                 IN NUMBER,
                                    p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Txl_Assets_Tl
     WHERE okl_txl_assets_tl.id = p_id
       AND okl_txl_assets_tl.language = p_language;
    l_okl_txl_asset_tl_pk          okl_txl_asset_tl_pk_csr%ROWTYPE;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_asset_tl_pk_csr (p_okl_txl_assets_tl_rec.id,
                                  p_okl_txl_assets_tl_rec.language);
    FETCH okl_txl_asset_tl_pk_csr INTO
              l_okl_txl_assets_tl_rec.ID,
              l_okl_txl_assets_tl_rec.LANGUAGE,
              l_okl_txl_assets_tl_rec.SOURCE_LANG,
              l_okl_txl_assets_tl_rec.SFWT_FLAG,
              l_okl_txl_assets_tl_rec.DESCRIPTION,
              l_okl_txl_assets_tl_rec.CREATED_BY,
              l_okl_txl_assets_tl_rec.CREATION_DATE,
              l_okl_txl_assets_tl_rec.LAST_UPDATED_BY,
              l_okl_txl_assets_tl_rec.LAST_UPDATE_DATE,
              l_okl_txl_assets_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txl_asset_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_asset_tl_pk_csr;
    RETURN(l_okl_txl_assets_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txl_assets_tl_rec        IN okl_txl_assets_tl_rec_type
  ) RETURN okl_txl_assets_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txl_assets_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ASSETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_talv_rec                     IN talv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN talv_rec_type IS
    CURSOR okl_talv_pk_csr (p_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           TAS_ID,
           ILO_ID,
           ILO_ID_OLD,
           IAY_ID,
           IAY_ID_NEW,
           KLE_ID,
           DNZ_KHR_ID,
           LINE_NUMBER,
           ORG_ID,
           TAL_TYPE,
           ASSET_NUMBER,
           DESCRIPTION,
           FA_LOCATION_ID,
           ORIGINAL_COST,
           CURRENT_UNITS,
           MANUFACTURER_NAME,
           YEAR_MANUFACTURED,
           SUPPLIER_ID,
           USED_ASSET_YN,
           TAG_NUMBER,
           MODEL_NUMBER,
           CORPORATE_BOOK,
           DATE_PURCHASED,
           DATE_DELIVERY,
           IN_SERVICE_DATE,
           LIFE_IN_MONTHS,
           DEPRECIATION_ID,
           DEPRECIATION_COST,
           DEPRN_METHOD,
           DEPRN_RATE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
--Bug# 2981308
           ASSET_KEY_ID,
-- Bug# 4028371
           FA_TRX_DATE,
-- Bug# 4899328
           FA_COST,
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
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           DEPRECIATE_YN,
           HOLD_PERIOD_DAYS,
           OLD_SALVAGE_VALUE,
           NEW_RESIDUAL_VALUE,
           OLD_RESIDUAL_VALUE,
           UNITS_RETIRED,
           COST_RETIRED,
           SALE_PROCEEDS,
           REMOVAL_COST,
           DNZ_ASSET_ID,
           DATE_DUE,
           REP_ASSET_ID,
           LKE_ASSET_ID,
           MATCH_AMOUNT,
           SPLIT_INTO_SINGLES_FLAG,
           SPLIT_INTO_UNITS,
        -- Multi-Currency Change
           currency_code,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date,
        -- Multi-Currency Change
        -- VRS Project - START
           RESIDUAL_SHR_PARTY_ID,
           RESIDUAL_SHR_AMOUNT,
           RETIREMENT_ID
        -- VRS Project - END
     FROM Okl_Txl_Assets_V
     WHERE okl_txl_assets_v.id  = p_id;
    l_okl_talv_pk                  okl_talv_pk_csr%ROWTYPE;
    l_talv_rec                     talv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_talv_pk_csr (p_talv_rec.id);
    FETCH okl_talv_pk_csr INTO
              l_talv_rec.ID,
              l_talv_rec.OBJECT_VERSION_NUMBER,
              l_talv_rec.SFWT_FLAG,
              l_talv_rec.TAS_ID,
              l_talv_rec.ILO_ID,
              l_talv_rec.ILO_ID_OLD,
              l_talv_rec.IAY_ID,
              l_talv_rec.IAY_ID_NEW,
              l_talv_rec.KLE_ID,
              l_talv_rec.DNZ_KHR_ID,
              l_talv_rec.LINE_NUMBER,
              l_talv_rec.ORG_ID,
              l_talv_rec.TAL_TYPE,
              l_talv_rec.ASSET_NUMBER,
              l_talv_rec.DESCRIPTION,
              l_talv_rec.FA_LOCATION_ID,
              l_talv_rec.ORIGINAL_COST,
              l_talv_rec.CURRENT_UNITS,
              l_talv_rec.MANUFACTURER_NAME,
              l_talv_rec.YEAR_MANUFACTURED,
              l_talv_rec.SUPPLIER_ID,
              l_talv_rec.USED_ASSET_YN,
              l_talv_rec.TAG_NUMBER,
              l_talv_rec.MODEL_NUMBER,
              l_talv_rec.CORPORATE_BOOK,
              l_talv_rec.DATE_PURCHASED,
              l_talv_rec.DATE_DELIVERY,
              l_talv_rec.IN_SERVICE_DATE,
              l_talv_rec.LIFE_IN_MONTHS,
              l_talv_rec.DEPRECIATION_ID,
              l_talv_rec.DEPRECIATION_COST,
              l_talv_rec.DEPRN_METHOD,
              l_talv_rec.DEPRN_RATE,
              l_talv_rec.SALVAGE_VALUE,
              l_talv_rec.PERCENT_SALVAGE_VALUE,
--Bug# 2981308
              l_talv_rec.ASSET_KEY_ID,
-- Bug# 4028371
              l_talv_rec.FA_TRX_DATE,
-- Bug# 4899328
              l_talv_rec.FA_COST,
              l_talv_rec.ATTRIBUTE_CATEGORY,
              l_talv_rec.ATTRIBUTE1,
              l_talv_rec.ATTRIBUTE2,
              l_talv_rec.ATTRIBUTE3,
              l_talv_rec.ATTRIBUTE4,
              l_talv_rec.ATTRIBUTE5,
              l_talv_rec.ATTRIBUTE6,
              l_talv_rec.ATTRIBUTE7,
              l_talv_rec.ATTRIBUTE8,
              l_talv_rec.ATTRIBUTE9,
              l_talv_rec.ATTRIBUTE10,
              l_talv_rec.ATTRIBUTE11,
              l_talv_rec.ATTRIBUTE12,
              l_talv_rec.ATTRIBUTE13,
              l_talv_rec.ATTRIBUTE14,
              l_talv_rec.ATTRIBUTE15,
              l_talv_rec.CREATED_BY,
              l_talv_rec.CREATION_DATE,
              l_talv_rec.LAST_UPDATED_BY,
              l_talv_rec.LAST_UPDATE_DATE,
              l_talv_rec.LAST_UPDATE_LOGIN,
              l_talv_rec.DEPRECIATE_YN,
              l_talv_rec.HOLD_PERIOD_DAYS,
              l_talv_rec.OLD_SALVAGE_VALUE,
              l_talv_rec.NEW_RESIDUAL_VALUE,
              l_talv_rec.OLD_RESIDUAL_VALUE,
              l_talv_rec.UNITS_RETIRED,
              l_talv_rec.COST_RETIRED,
              l_talv_rec.SALE_PROCEEDS,
              l_talv_rec.REMOVAL_COST,
              l_talv_rec.DNZ_ASSET_ID,
              l_talv_rec.DATE_DUE,
              l_talv_rec.REP_ASSET_ID,
              l_talv_rec.LKE_ASSET_ID,
              l_talv_rec.MATCH_AMOUNT,
              l_talv_rec.SPLIT_INTO_SINGLES_FLAG,
              l_talv_rec.SPLIT_INTO_UNITS,
        -- Multi-Currency Change
              l_talv_rec.currency_code,
              l_talv_rec.currency_conversion_type,
              l_talv_rec.currency_conversion_rate,
              l_talv_rec.currency_conversion_date,
        -- Multi-Currency Change
          -- VRS Project - START
              l_talv_rec.RESIDUAL_SHR_PARTY_ID,
              l_talv_rec.RESIDUAL_SHR_AMOUNT,
              l_talv_rec.RETIREMENT_ID;
          -- VRS Project - END

    x_no_data_found := okl_talv_pk_csr%NOTFOUND;
    CLOSE okl_talv_pk_csr;
    RETURN(l_talv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_talv_rec                     IN talv_rec_type
  ) RETURN talv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_talv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_ASSETS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_talv_rec	IN talv_rec_type
  ) RETURN talv_rec_type IS
    l_talv_rec	talv_rec_type := p_talv_rec;
  BEGIN
    IF (l_talv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.object_version_number := NULL;
    END IF;
    IF (l_talv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_talv_rec.tas_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.tas_id := NULL;
    END IF;
    IF (l_talv_rec.ilo_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.ilo_id := NULL;
    END IF;
    IF (l_talv_rec.ilo_id_old = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.ilo_id_old := NULL;
    END IF;
    IF (l_talv_rec.iay_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.iay_id := NULL;
    END IF;
    IF (l_talv_rec.iay_id_new = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.iay_id_new := NULL;
    END IF;
    IF (l_talv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.kle_id := NULL;
    END IF;
    IF (l_talv_rec.dnz_khr_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.dnz_khr_id := NULL;
    END IF;
    IF (l_talv_rec.line_number = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.line_number := NULL;
    END IF;
    IF (l_talv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.org_id := NULL;
    END IF;
    IF (l_talv_rec.tal_type = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.tal_type := NULL;
    END IF;
    IF (l_talv_rec.asset_number = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.asset_number := NULL;
    END IF;
    IF (l_talv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.description := NULL;
    END IF;
    IF (l_talv_rec.fa_location_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.fa_location_id := NULL;
    END IF;
    IF (l_talv_rec.original_cost = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.original_cost := NULL;
    END IF;
    IF (l_talv_rec.current_units = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.current_units := NULL;
    END IF;
    IF (l_talv_rec.manufacturer_name = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.manufacturer_name := NULL;
    END IF;
    IF (l_talv_rec.year_manufactured = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.year_manufactured := NULL;
    END IF;
    IF (l_talv_rec.supplier_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.supplier_id := NULL;
    END IF;
    IF (l_talv_rec.used_asset_yn = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.used_asset_yn := NULL;
    END IF;
    IF (l_talv_rec.tag_number = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.tag_number := NULL;
    END IF;
    IF (l_talv_rec.model_number = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.model_number := NULL;
    END IF;
    IF (l_talv_rec.corporate_book = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.corporate_book := NULL;
    END IF;
    IF (l_talv_rec.date_purchased = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.date_purchased := NULL;
    END IF;
    IF (l_talv_rec.date_delivery = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.date_delivery := NULL;
    END IF;
    IF (l_talv_rec.in_service_date = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.in_service_date := NULL;
    END IF;
    IF (l_talv_rec.life_in_months = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.life_in_months := NULL;
    END IF;
    IF (l_talv_rec.depreciation_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.depreciation_id := NULL;
    END IF;
    IF (l_talv_rec.depreciation_cost = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.depreciation_cost := NULL;
    END IF;
    IF (l_talv_rec.deprn_method = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.deprn_method := NULL;
    END IF;
    IF (l_talv_rec.deprn_rate = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.deprn_rate := NULL;
    END IF;
    IF (l_talv_rec.salvage_value = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.salvage_value := NULL;
    END IF;
    IF (l_talv_rec.percent_salvage_value = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.percent_salvage_value := NULL;
    END IF;
--Bug# 2981308
    IF (l_talv_rec.asset_key_id = OKL_API.G_MISS_NUM) THEN
      l_talv_rec.asset_key_id := NULL;
    END IF;
-- Bug# 4028371
    IF (l_talv_rec.fa_trx_date = OKL_API.G_MISS_DATE) THEN
      l_talv_rec.fa_trx_date := NULL;
    END IF;
--Bug# 4899328
    IF (l_talv_rec.fa_cost = OKL_API.G_MISS_NUM) THEN
      l_talv_rec.fa_cost := NULL;
    END IF;
    IF (l_talv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute_category := NULL;
    END IF;
    IF (l_talv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute1 := NULL;
    END IF;
    IF (l_talv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute2 := NULL;
    END IF;
    IF (l_talv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute3 := NULL;
    END IF;
    IF (l_talv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute4 := NULL;
    END IF;
    IF (l_talv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute5 := NULL;
    END IF;
    IF (l_talv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute6 := NULL;
    END IF;
    IF (l_talv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute7 := NULL;
    END IF;
    IF (l_talv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute8 := NULL;
    END IF;
    IF (l_talv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute9 := NULL;
    END IF;
    IF (l_talv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute10 := NULL;
    END IF;
    IF (l_talv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute11 := NULL;
    END IF;
    IF (l_talv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute12 := NULL;
    END IF;
    IF (l_talv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute13 := NULL;
    END IF;
    IF (l_talv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute14 := NULL;
    END IF;
    IF (l_talv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.attribute15 := NULL;
    END IF;
    IF (l_talv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.created_by := NULL;
    END IF;
    IF (l_talv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.creation_date := NULL;
    END IF;
    IF (l_talv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.last_updated_by := NULL;
    END IF;
    IF (l_talv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.last_update_date := NULL;
    END IF;
    IF (l_talv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.last_update_login := NULL;
    END IF;
    IF (l_talv_rec.depreciate_yn = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.depreciate_yn := NULL;
    END IF;
    IF (l_talv_rec.hold_period_days = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.hold_period_days := NULL;
    END IF;
    IF (l_talv_rec.old_salvage_value = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.old_salvage_value := NULL;
    END IF;
    IF (l_talv_rec.new_residual_value = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.new_residual_value := NULL;
    END IF;
    IF (l_talv_rec.old_residual_value = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.old_residual_value := NULL;
    END IF;
    IF (l_talv_rec.units_retired = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.units_retired := NULL;
    END IF;
    IF (l_talv_rec.cost_retired = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.cost_retired := NULL;
    END IF;
    IF (l_talv_rec.sale_proceeds = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.sale_proceeds := NULL;
    END IF;
    IF (l_talv_rec.removal_cost = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.removal_cost := NULL;
    END IF;
    IF (l_talv_rec.dnz_asset_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.dnz_asset_id := NULL;
    END IF;
    IF (l_talv_rec.date_due = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.date_due := NULL;
    END IF;
    IF (l_talv_rec.rep_asset_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.rep_asset_id := NULL;
    END IF;
    IF (l_talv_rec.lke_asset_id = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.lke_asset_id := NULL;
    END IF;
    IF (l_talv_rec.match_amount = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.match_amount := NULL;
    END IF;
    IF (l_talv_rec.split_into_singles_flag = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.split_into_singles_flag := NULL;
    END IF;
    IF (l_talv_rec.split_into_units = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.split_into_units := NULL;
    END IF;

    -- Multi-Currency Change
    IF (l_talv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.currency_code := NULL;
    END IF;
    IF (l_talv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
      l_talv_rec.currency_conversion_type := NULL;
    END IF;
    IF (l_talv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.currency_conversion_rate:= NULL;
    END IF;
    IF (l_talv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
      l_talv_rec.currency_conversion_date := NULL;
    END IF;
    -- Multi-Currency Change

    -- VRS Project - START

    IF (l_talv_rec.RESIDUAL_SHR_PARTY_ID = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.RESIDUAL_SHR_PARTY_ID:= NULL;
    END IF;
    IF (l_talv_rec.RESIDUAL_SHR_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.RESIDUAL_SHR_AMOUNT:= NULL;
    END IF;
    IF (l_talv_rec.RETIREMENT_ID = OKC_API.G_MISS_NUM) THEN
      l_talv_rec.RETIREMENT_ID := NULL;
    END IF;

    -- VRS Project - END

    RETURN(l_talv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_TXL_ASSETS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_talv_rec IN  talv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_talv_rec.id = OKC_API.G_MISS_NUM OR
       p_talv_rec.id IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_talv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_talv_rec.object_version_number IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_talv_rec.line_number = OKC_API.G_MISS_NUM OR
          p_talv_rec.line_number IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_talv_rec.asset_number = OKC_API.G_MISS_CHAR OR
          p_talv_rec.asset_number IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Asset_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_talv_rec.original_cost = OKC_API.G_MISS_NUM OR
          p_talv_rec.original_cost IS NULL  THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'original_cost');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
/************************ HAND-CODED *********************************/
    -- Calling the validation procedures for attributes
    validate_tas_id(x_return_status  => l_return_status,
                    p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_ilo_id(x_return_status  => l_return_status,
                    p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_ilo_id_old(x_return_status  => l_return_status,
                        p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_iay_id(x_return_status  => l_return_status,
                    p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_iay_id_new(x_return_status  => l_return_status,
                        p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_kle_id(x_return_status  => l_return_status,
                      p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_tal_type(x_return_status  => l_return_status,
                      p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_org_id(x_return_status  => l_return_status,
                    p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_current_units(x_return_status  => l_return_status,
                           p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_used_asset_yn(x_return_status  => l_return_status,
                           p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_life_in_months(x_return_status  => l_return_status,
                           p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_deprn_id(x_return_status  => l_return_status,
                      p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_fa_location_id(x_return_status  => l_return_status,
                            p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_dnz_khr_id(x_return_status  => l_return_status,
                        p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_corp_book(x_return_status  => l_return_status,
                           p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_deprn_method(x_return_status  => l_return_status,
                           p_talv_rec => p_talv_rec);
    --Bug# 2981308
    validate_asset_key (x_return_status   => l_return_status,
                        p_talv_rec        => p_talv_rec);

    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    RETURN(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- Return status to caller
    RETURN(x_return_status);
/************************ HAND-CODED *********************************/
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_TXL_ASSETS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_talv_rec IN talv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
/************************ HAND-CODED *********************************/
    validate_pds_date(x_return_status  => l_return_status,
                        p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
--start:|           23-May-2008 cklee fixed bug: 6781324                             |
-- move this check to QA checker
/*
    validate_salv_oec(x_return_status  => l_return_status,
                        p_talv_rec => p_talv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
*/
--end:|           23-May-2008 cklee fixed bug: 6781324                             |
    l_return_status := x_return_status;
    RETURN (l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- Return status to caller
    RETURN(x_return_status);
/************************ HAND-CODED *********************************/
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN talv_rec_type,
    p_to	IN OUT NOCOPY tal_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.tas_id := p_from.tas_id;
    p_to.ilo_id := p_from.ilo_id;
    p_to.ilo_id_old := p_from.ilo_id_old;
    p_to.iay_id := p_from.iay_id;
    p_to.iay_id_new := p_from.iay_id_new;
    p_to.kle_id := p_from.kle_id;
    p_to.dnz_khr_id := p_from.dnz_khr_id;
    p_to.line_number := p_from.line_number;
    p_to.org_id := p_from.org_id;
    p_to.tal_type := p_from.tal_type;
    p_to.asset_number := p_from.asset_number;
    p_to.fa_location_id := p_from.fa_location_id;
    p_to.original_cost := p_from.original_cost;
    p_to.current_units := p_from.current_units;
    p_to.manufacturer_name := p_from.manufacturer_name;
    p_to.year_manufactured := p_from.year_manufactured;
    p_to.supplier_id := p_from.supplier_id;
    p_to.used_asset_yn := p_from.used_asset_yn;
    p_to.tag_number := p_from.tag_number;
    p_to.model_number := p_from.model_number;
    p_to.corporate_book := p_from.corporate_book;
    p_to.date_purchased := p_from.date_purchased;
    p_to.date_delivery := p_from.date_delivery;
    p_to.in_service_date := p_from.in_service_date;
    p_to.life_in_months := p_from.life_in_months;
    p_to.depreciation_id := p_from.depreciation_id;
    p_to.depreciation_cost := p_from.depreciation_cost;
    p_to.deprn_method := p_from.deprn_method;
    p_to.deprn_rate := p_from.deprn_rate;
    p_to.salvage_value := p_from.salvage_value;
    p_to.percent_salvage_value := p_from.percent_salvage_value;
--Bug# 2981308
    p_to.asset_key_id := p_from.asset_key_id;
-- Bug# 4028371
    p_to.fa_trx_date := p_from.fa_trx_date;
--Bug# 4899328
    p_to.fa_cost := p_from.fa_cost;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.depreciate_yn := p_from.depreciate_yn;
    p_to.hold_period_days := p_from.hold_period_days;
    p_to.old_salvage_value := p_from.old_salvage_value;
    p_to.new_residual_value := p_from.new_residual_value;
    p_to.old_residual_value := p_from.old_residual_value;
    p_to.units_retired := p_from.units_retired;
    p_to.cost_retired := p_from.cost_retired;
    p_to.sale_proceeds := p_from.sale_proceeds;
    p_to.removal_cost := p_from.removal_cost;
    p_to.dnz_asset_id := p_from.dnz_asset_id;
    p_to.date_due := p_from.date_due;
    p_to.rep_asset_id := p_from.rep_asset_id;
    p_to.lke_asset_id := p_from.lke_asset_id;
    p_to.match_amount := p_from.match_amount;
    p_to.split_into_singles_flag := p_from.split_into_singles_flag;
    p_to.split_into_units := p_from.split_into_units;
    -- Multi-Currency Change
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    -- Multi-Currency Change
    -- VRS Project - START
    p_to.RESIDUAL_SHR_PARTY_ID := p_from.RESIDUAL_SHR_PARTY_ID;
    p_to.RESIDUAL_SHR_AMOUNT   := p_from.RESIDUAL_SHR_AMOUNT;
    p_to.RETIREMENT_ID         := p_from.RETIREMENT_ID;
    -- VRS Project - END

  END migrate;
  PROCEDURE migrate (
    p_from	IN tal_rec_type,
    p_to	IN OUT NOCOPY talv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.tas_id := p_from.tas_id;
    p_to.ilo_id := p_from.ilo_id;
    p_to.ilo_id_old := p_from.ilo_id_old;
    p_to.iay_id := p_from.iay_id;
    p_to.iay_id_new := p_from.iay_id_new;
    p_to.kle_id := p_from.kle_id;
    p_to.dnz_khr_id := p_from.dnz_khr_id;
    p_to.line_number := p_from.line_number;
    p_to.org_id := p_from.org_id;
    p_to.tal_type := p_from.tal_type;
    p_to.asset_number := p_from.asset_number;
    p_to.fa_location_id := p_from.fa_location_id;
    p_to.original_cost := p_from.original_cost;
    p_to.current_units := p_from.current_units;
    p_to.manufacturer_name := p_from.manufacturer_name;
    p_to.year_manufactured := p_from.year_manufactured;
    p_to.supplier_id := p_from.supplier_id;
    p_to.used_asset_yn := p_from.used_asset_yn;
    p_to.tag_number := p_from.tag_number;
    p_to.model_number := p_from.model_number;
    p_to.corporate_book := p_from.corporate_book;
    p_to.date_purchased := p_from.date_purchased;
    p_to.date_delivery := p_from.date_delivery;
    p_to.in_service_date := p_from.in_service_date;
    p_to.life_in_months := p_from.life_in_months;
    p_to.depreciation_id := p_from.depreciation_id;
    p_to.depreciation_cost := p_from.depreciation_cost;
    p_to.deprn_method := p_from.deprn_method;
    p_to.deprn_rate := p_from.deprn_rate;
    p_to.salvage_value := p_from.salvage_value;
    p_to.percent_salvage_value := p_from.percent_salvage_value;
--Bug# 2981308 :
    p_to.asset_key_id := p_from.asset_key_id;
-- Bug# 4028371
    p_to.fa_trx_date := p_from.fa_trx_date;
--bug# 4899328
    p_to.fa_cost := p_from.fa_cost;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.depreciate_yn := p_from.depreciate_yn;
    p_to.hold_period_days := p_from.hold_period_days;
    p_to.old_salvage_value := p_from.old_salvage_value;
    p_to.new_residual_value := p_from.new_residual_value;
    p_to.old_residual_value := p_from.old_residual_value;
    p_to.units_retired := p_from.units_retired;
    p_to.cost_retired := p_from.cost_retired;
    p_to.sale_proceeds := p_from.sale_proceeds;
    p_to.removal_cost := p_from.removal_cost;
    p_to.dnz_asset_id := p_from.dnz_asset_id;
    p_to.date_due := p_from.date_due;
    p_to.rep_asset_id := p_from.rep_asset_id;
    p_to.lke_asset_id := p_from.lke_asset_id;
    p_to.match_amount := p_from.match_amount;
    p_to.split_into_singles_flag := p_from.split_into_singles_flag;
    p_to.split_into_units := p_from.split_into_units;
    -- Multi-Currency Change
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    -- Multi-Currency Change
    -- VRS Project - START
    p_to.RESIDUAL_SHR_PARTY_ID := p_from.RESIDUAL_SHR_PARTY_ID;
    p_to.RESIDUAL_SHR_AMOUNT   := p_from.RESIDUAL_SHR_AMOUNT;
    p_to.RETIREMENT_ID         := p_from.RETIREMENT_ID;
    -- VRS Project - END

  END migrate;
  PROCEDURE migrate (
    p_from	IN talv_rec_type,
    p_to	IN OUT NOCOPY okl_txl_assets_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_txl_assets_tl_rec_type,
    p_to	IN OUT NOCOPY talv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_TXL_ASSETS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type := p_talv_rec;
    l_tal_rec                      tal_rec_type;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_talv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:TALV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- insert_row for:OKL_TXL_ASSETS_B --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tal_rec                      IN tal_rec_type,
    x_tal_rec                      OUT NOCOPY tal_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tal_rec                      tal_rec_type := p_tal_rec;
    l_def_tal_rec                  tal_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_tal_rec IN  tal_rec_type,
      x_tal_rec OUT NOCOPY tal_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tal_rec := p_tal_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tal_rec,                         -- IN
      l_tal_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_ASSETS_B(
        id,
        object_version_number,
        tas_id,
        ilo_id,
        ilo_id_old,
        iay_id,
        iay_id_new,
        kle_id,
        dnz_khr_id,
        line_number,
        org_id,
        tal_type,
        asset_number,
        fa_location_Id,
        original_cost,
        current_units,
        manufacturer_name,
        year_manufactured,
        supplier_id,
        used_asset_yn,
        tag_number,
        model_number,
        corporate_book,
        date_purchased,
        date_delivery,
        in_service_date,
        life_in_months,
        depreciation_id,
        depreciation_cost,
        deprn_method,
        deprn_rate,
        salvage_value,
        percent_salvage_value,
--Bug# 2981308
        asset_key_id,
-- Bug# 4028371
        fa_trx_date,
--Bug# 4899328
        fa_cost,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        depreciate_yn,
        hold_period_days,
        old_salvage_value,
        new_residual_value,
        old_residual_value,
        units_retired,
        cost_retired,
        sale_proceeds,
        removal_cost,
        dnz_asset_id,
        date_due,
        rep_asset_id,
        lke_asset_id,
        match_amount,
        split_into_singles_flag,
        split_into_units,
        -- Multi-Currency Change
        currency_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
        -- Multi-Currency Change
        -- VRS Project - END
        RESIDUAL_SHR_PARTY_ID,
        RESIDUAL_SHR_AMOUNT,
        RETIREMENT_ID
        -- VRS Project - END
        )
      VALUES (
        l_tal_rec.id,
        l_tal_rec.object_version_number,
        l_tal_rec.tas_id,
        l_tal_rec.ilo_id,
        l_tal_rec.ilo_id_old,
        l_tal_rec.iay_id,
        l_tal_rec.iay_id_new,
        l_tal_rec.kle_id,
        l_tal_rec.dnz_khr_id,
        l_tal_rec.line_number,
        l_tal_rec.org_id,
        l_tal_rec.tal_type,
        l_tal_rec.asset_number,
        l_tal_rec.fa_location_id,
        l_tal_rec.original_cost,
        l_tal_rec.current_units,
        l_tal_rec.manufacturer_name,
        l_tal_rec.year_manufactured,
        l_tal_rec.supplier_id,
        l_tal_rec.used_asset_yn,
        l_tal_rec.tag_number,
        l_tal_rec.model_number,
        l_tal_rec.corporate_book,
        l_tal_rec.date_purchased,
        l_tal_rec.date_delivery,
        l_tal_rec.in_service_date,
        l_tal_rec.life_in_months,
        l_tal_rec.depreciation_id,
        l_tal_rec.depreciation_cost,
        l_tal_rec.deprn_method,
        l_tal_rec.deprn_rate,
        l_tal_rec.salvage_value,
        l_tal_rec.percent_salvage_value,
--Bug# 2981308
        l_tal_rec.asset_key_id,
-- Bug# 4028371
        l_tal_rec.fa_trx_date,
--bug# 4899328
        l_tal_rec.fa_cost,
        l_tal_rec.attribute_category,
        l_tal_rec.attribute1,
        l_tal_rec.attribute2,
        l_tal_rec.attribute3,
        l_tal_rec.attribute4,
        l_tal_rec.attribute5,
        l_tal_rec.attribute6,
        l_tal_rec.attribute7,
        l_tal_rec.attribute8,
        l_tal_rec.attribute9,
        l_tal_rec.attribute10,
        l_tal_rec.attribute11,
        l_tal_rec.attribute12,
        l_tal_rec.attribute13,
        l_tal_rec.attribute14,
        l_tal_rec.attribute15,
        l_tal_rec.created_by,
        l_tal_rec.creation_date,
        l_tal_rec.last_updated_by,
        l_tal_rec.last_update_date,
        l_tal_rec.last_update_login,
        l_tal_rec.depreciate_yn,
        l_tal_rec.hold_period_days,
        l_tal_rec.old_salvage_value,
        l_tal_rec.new_residual_value,
        l_tal_rec.old_residual_value,
        l_tal_rec.units_retired,
        l_tal_rec.cost_retired,
        l_tal_rec.sale_proceeds,
        l_tal_rec.removal_cost,
        l_tal_rec.dnz_asset_id,
        l_tal_rec.date_due,
        l_tal_rec.rep_asset_id,
        l_tal_rec.lke_asset_id,
        l_tal_rec.match_amount,
        l_tal_rec.split_into_singles_flag,
        l_tal_rec.split_into_units,
        -- Multi-Currency Change
        l_tal_rec.currency_code,
        l_tal_rec.currency_conversion_type,
        l_tal_rec.currency_conversion_rate,
        l_tal_rec.currency_conversion_date,
        -- Multi-Currency Change
        -- VRS Project - END
        l_tal_rec.RESIDUAL_SHR_PARTY_ID,
        l_tal_rec.RESIDUAL_SHR_AMOUNT,
        l_tal_rec.RETIREMENT_ID
        -- VRS Project - END
        );

    -- Set OUT values
    x_tal_rec := l_tal_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  --------------------------------------
  -- insert_row for:OKL_TXL_ASSETS_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_assets_tl_rec        IN okl_txl_assets_tl_rec_type,
    x_okl_txl_assets_tl_rec        OUT NOCOPY okl_txl_assets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type := p_okl_txl_assets_tl_rec;
    l_def_okl_txl_assets_tl_rec    okl_txl_assets_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_assets_tl_rec IN  okl_txl_assets_tl_rec_type,
      x_okl_txl_assets_tl_rec OUT NOCOPY okl_txl_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_assets_tl_rec := p_okl_txl_assets_tl_rec;
      x_okl_txl_assets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_assets_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_txl_assets_tl_rec,           -- IN
      l_okl_txl_assets_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txl_assets_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TXL_ASSETS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_txl_assets_tl_rec.id,
          l_okl_txl_assets_tl_rec.language,
          l_okl_txl_assets_tl_rec.source_lang,
          l_okl_txl_assets_tl_rec.sfwt_flag,
          l_okl_txl_assets_tl_rec.description,
          l_okl_txl_assets_tl_rec.created_by,
          l_okl_txl_assets_tl_rec.creation_date,
          l_okl_txl_assets_tl_rec.last_updated_by,
          l_okl_txl_assets_tl_rec.last_update_date,
          l_okl_txl_assets_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txl_assets_tl_rec := l_okl_txl_assets_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------
  -- insert_row for:OKL_TXL_ASSETS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type,
    x_talv_rec                     OUT NOCOPY talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type;
    l_def_talv_rec                 talv_rec_type;
    l_tal_rec                      tal_rec_type;
    lx_tal_rec                     tal_rec_type;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
    lx_okl_txl_assets_tl_rec       okl_txl_assets_tl_rec_type;
    lx_temp_talv_rec               talv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_talv_rec	IN talv_rec_type
    ) RETURN talv_rec_type IS
      l_talv_rec	talv_rec_type := p_talv_rec;
    BEGIN
      l_talv_rec.CREATION_DATE := SYSDATE;
      l_talv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_talv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_talv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_talv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_talv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_talv_rec IN  talv_rec_type,
      x_talv_rec OUT NOCOPY talv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_talv_rec := p_talv_rec;
      x_talv_rec.OBJECT_VERSION_NUMBER := 1;
      x_talv_rec.SFWT_FLAG := 'N';
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_talv_rec := null_out_defaults(p_talv_rec);
    -- Set primary key value
    l_talv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_talv_rec,                        -- IN
      l_def_talv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := fill_who_columns(l_def_talv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_talv_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --
    -- Multi-Currency Change, dedey, 12/04/2002
    --
    validate_currency(
                      x_return_status => l_return_status,
                      p_talv_rec      => l_def_talv_rec,
                      x_talv_rec      => lx_temp_talv_rec
                     );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := lx_temp_talv_rec;

    --dbms_output.put_line('After Change: '||lx_temp_talv_rec.currency_code);
    --dbms_output.put_line('After Change: '||l_def_talv_rec.currency_code);
    --
    -- Multi-Currency Change
    --

    -- Fix Bug# 2737014
    --
    -- Round off amounts
    --
    roundoff_line_amount(
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_talv_rec      => l_def_talv_rec,
                         x_talv_rec      => lx_temp_talv_rec
                        );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := lx_temp_talv_rec;

    --dbms_output.put_line('After Change Orig cost: '||lx_temp_talv_rec.original_cost);
    --dbms_output.put_line('After Change Orig cost: '||l_def_talv_rec.original_cost);


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_talv_rec, l_tal_rec);
    migrate(l_def_talv_rec, l_okl_txl_assets_tl_rec);

    --dbms_output.put_line('After migrate: '||l_tal_rec.currency_code);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tal_rec,
      lx_tal_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tal_rec, l_def_talv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_assets_tl_rec,
      lx_okl_txl_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_assets_tl_rec, l_def_talv_rec);
    -- Set OUT values
    x_talv_rec := l_def_talv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:TALV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i),
          x_talv_rec                     => x_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -----------------------------------
  -- lock_row for:OKL_TXL_ASSETS_B --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tal_rec                      IN tal_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tal_rec IN tal_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_ASSETS_B
     WHERE ID = p_tal_rec.id
       AND OBJECT_VERSION_NUMBER = p_tal_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tal_rec IN tal_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_ASSETS_B
    WHERE ID = p_tal_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_ASSETS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_ASSETS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_tal_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_tal_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tal_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tal_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ------------------------------------
  -- lock_row for:OKL_TXL_ASSETS_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_assets_tl_rec        IN okl_txl_assets_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txl_assets_tl_rec IN okl_txl_assets_tl_rec_type) IS
    SELECT *
      FROM OKL_TXL_ASSETS_TL
     WHERE ID = p_okl_txl_assets_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_txl_assets_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------
  -- lock_row for:OKL_TXL_ASSETS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tal_rec                      tal_rec_type;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_talv_rec, l_tal_rec);
    migrate(p_talv_rec, l_okl_txl_assets_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tal_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:TALV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- update_row for:OKL_TXL_ASSETS_B --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tal_rec                      IN tal_rec_type,
    x_tal_rec                      OUT NOCOPY tal_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tal_rec                      tal_rec_type := p_tal_rec;
    l_def_tal_rec                  tal_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tal_rec	IN tal_rec_type,
      x_tal_rec	OUT NOCOPY tal_rec_type
    ) RETURN VARCHAR2 IS
      l_tal_rec                      tal_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tal_rec := p_tal_rec;
      -- Get current database values
      l_tal_rec := get_rec(p_tal_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tal_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.id := l_tal_rec.id;
      END IF;
      IF (x_tal_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.object_version_number := l_tal_rec.object_version_number;
      END IF;
      IF (x_tal_rec.tas_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.tas_id := l_tal_rec.tas_id;
      END IF;
      IF (x_tal_rec.ilo_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.ilo_id := l_tal_rec.ilo_id;
      END IF;
      IF (x_tal_rec.ilo_id_old = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.ilo_id_old := l_tal_rec.ilo_id_old;
      END IF;
      IF (x_tal_rec.iay_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.iay_id := l_tal_rec.iay_id;
      END IF;
      IF (x_tal_rec.iay_id_new = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.iay_id_new := l_tal_rec.iay_id_new;
      END IF;
      IF (x_tal_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.kle_id := l_tal_rec.kle_id;
      END IF;
      IF (x_tal_rec.dnz_khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.dnz_khr_id := l_tal_rec.dnz_khr_id;
      END IF;
      IF (x_tal_rec.line_number = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.line_number := l_tal_rec.line_number;
      END IF;
      IF (x_tal_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.org_id := l_tal_rec.org_id;
      END IF;
      IF (x_tal_rec.tal_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.tal_type := l_tal_rec.tal_type;
      END IF;
      IF (x_tal_rec.asset_number = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.asset_number := l_tal_rec.asset_number;
      END IF;
      IF (x_tal_rec.original_cost = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.original_cost := l_tal_rec.original_cost;
      END IF;
      IF (x_tal_rec.current_units = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.current_units := l_tal_rec.current_units;
      END IF;
      IF (x_tal_rec.manufacturer_name = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.manufacturer_name := l_tal_rec.manufacturer_name;
      END IF;
      IF (x_tal_rec.year_manufactured = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.year_manufactured := l_tal_rec.year_manufactured;
      END IF;
      IF (x_tal_rec.supplier_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.supplier_id := l_tal_rec.supplier_id;
      END IF;
      IF (x_tal_rec.used_asset_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.used_asset_yn := l_tal_rec.used_asset_yn;
      END IF;
      IF (x_tal_rec.tag_number = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.tag_number := l_tal_rec.tag_number;
      END IF;
      IF (x_tal_rec.model_number = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.model_number := l_tal_rec.model_number;
      END IF;
      IF (x_tal_rec.corporate_book = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.corporate_book := l_tal_rec.corporate_book;
      END IF;
      IF (x_tal_rec.date_purchased = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.date_purchased := l_tal_rec.date_purchased;
      END IF;
      IF (x_tal_rec.date_purchased = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.date_delivery := l_tal_rec.date_delivery;
      END IF;
      IF (x_tal_rec.in_service_date = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.in_service_date := l_tal_rec.in_service_date;
      END IF;
      IF (x_tal_rec.life_in_months = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.life_in_months := l_tal_rec.life_in_months;
      END IF;
      IF (x_tal_rec.depreciation_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.depreciation_id := l_tal_rec.depreciation_id;
      END IF;
      IF (x_tal_rec.depreciation_cost = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.depreciation_cost := l_tal_rec.depreciation_cost;
      END IF;
      IF (x_tal_rec.depreciation_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.deprn_method := l_tal_rec.deprn_method;
      END IF;
      IF (x_tal_rec.deprn_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.deprn_rate := l_tal_rec.deprn_rate;
      END IF;
      IF (x_tal_rec.salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.salvage_value := l_tal_rec.salvage_value;
      END IF;
      IF (x_tal_rec.percent_salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.percent_salvage_value := l_tal_rec.percent_salvage_value;
      END IF;
--Bug# 2981308
      IF (x_tal_rec.asset_key_id = OKL_API.G_MISS_NUM)
      THEN
        x_tal_rec.asset_key_id := l_tal_rec.asset_key_id;
      END IF;
-- Bug# 4028371
      IF (x_tal_rec.fa_trx_date = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.fa_trx_date := l_tal_rec.fa_trx_date;
      END IF;
--Bug# 4899328
      IF (x_tal_rec.fa_cost = OKL_API.G_MISS_NUM)
      THEN
        x_tal_rec.fa_cost := l_tal_rec.fa_cost;
      END IF;
      IF (x_tal_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute_category := l_tal_rec.attribute_category;
      END IF;
      IF (x_tal_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute1 := l_tal_rec.attribute1;
      END IF;
      IF (x_tal_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute2 := l_tal_rec.attribute2;
      END IF;
      IF (x_tal_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute3 := l_tal_rec.attribute3;
      END IF;
      IF (x_tal_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute4 := l_tal_rec.attribute4;
      END IF;
      IF (x_tal_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute5 := l_tal_rec.attribute5;
      END IF;
      IF (x_tal_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute6 := l_tal_rec.attribute6;
      END IF;
      IF (x_tal_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute7 := l_tal_rec.attribute7;
      END IF;
      IF (x_tal_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute8 := l_tal_rec.attribute8;
      END IF;
      IF (x_tal_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute9 := l_tal_rec.attribute9;
      END IF;
      IF (x_tal_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute10 := l_tal_rec.attribute10;
      END IF;
      IF (x_tal_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute11 := l_tal_rec.attribute11;
      END IF;
      IF (x_tal_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute12 := l_tal_rec.attribute12;
      END IF;
      IF (x_tal_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute13 := l_tal_rec.attribute13;
      END IF;
      IF (x_tal_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute14 := l_tal_rec.attribute14;
      END IF;
      IF (x_tal_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.attribute15 := l_tal_rec.attribute15;
      END IF;
      IF (x_tal_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.created_by := l_tal_rec.created_by;
      END IF;
      IF (x_tal_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.creation_date := l_tal_rec.creation_date;
      END IF;
      IF (x_tal_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.last_updated_by := l_tal_rec.last_updated_by;
      END IF;
      IF (x_tal_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.last_update_date := l_tal_rec.last_update_date;
      END IF;
      IF (x_tal_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.last_update_login := l_tal_rec.last_update_login;
      END IF;
      IF (x_tal_rec.depreciate_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.depreciate_yn := l_tal_rec.depreciate_yn;
      END IF;
      IF (x_tal_rec.hold_period_days = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.hold_period_days := l_tal_rec.hold_period_days;
      END IF;
      IF (x_tal_rec.old_salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.old_salvage_value := l_tal_rec.old_salvage_value;
      END IF;
      IF (x_tal_rec.new_residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.new_residual_value := l_tal_rec.new_residual_value;
      END IF;
      IF (x_tal_rec.old_residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.old_residual_value := l_tal_rec.old_residual_value;
      END IF;
      IF (x_tal_rec.units_retired = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.units_retired := l_tal_rec.units_retired;
      END IF;
      IF (x_tal_rec.cost_retired = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.cost_retired := l_tal_rec.cost_retired;
      END IF;
      IF (x_tal_rec.sale_proceeds = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.sale_proceeds := l_tal_rec.sale_proceeds;
      END IF;
      IF (x_tal_rec.removal_cost = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.removal_cost := l_tal_rec.removal_cost;
      END IF;
      IF (x_tal_rec.dnz_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.dnz_asset_id := l_tal_rec.dnz_asset_id;
      END IF;
      IF (x_tal_rec.date_due = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.date_due := l_tal_rec.date_due;
      END IF;
      IF (x_tal_rec.rep_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.rep_asset_id := l_tal_rec.rep_asset_id;
      END IF;
      IF (x_tal_rec.lke_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.lke_asset_id := l_tal_rec.lke_asset_id;
      END IF;
      IF (x_tal_rec.match_amount = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.match_amount := l_tal_rec.match_amount;
      END IF;
      IF (x_tal_rec.split_into_singles_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.split_into_singles_flag := l_tal_rec.split_into_singles_flag;
      END IF;
      IF (x_tal_rec.split_into_units = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.split_into_units := l_tal_rec.split_into_units;
      END IF;
      -- Multi Currency Change
      IF (x_tal_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.currency_code := l_tal_rec.currency_code;
      END IF;
      IF (x_tal_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tal_rec.currency_conversion_type := l_tal_rec.currency_conversion_type;
      END IF;
      IF (x_tal_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_tal_rec.currency_conversion_rate := l_tal_rec.currency_conversion_rate;
      END IF;
      IF (x_tal_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_tal_rec.currency_conversion_date := l_tal_rec.currency_conversion_date;
      END IF;
      -- Multi Currency Change

    -- VRS Project - START

    IF (x_tal_rec.RESIDUAL_SHR_PARTY_ID = OKC_API.G_MISS_NUM) THEN
        x_tal_rec.RESIDUAL_SHR_PARTY_ID:= l_tal_rec.RESIDUAL_SHR_PARTY_ID;
    END IF;

    IF (x_tal_rec.RESIDUAL_SHR_AMOUNT = OKC_API.G_MISS_NUM) THEN
        x_tal_rec.RESIDUAL_SHR_AMOUNT := l_tal_rec.RESIDUAL_SHR_AMOUNT;
    END IF;
    IF (x_tal_rec.RETIREMENT_ID = OKC_API.G_MISS_NUM) THEN
        x_tal_rec.RETIREMENT_ID := l_tal_rec.RETIREMENT_ID;
    END IF;

    -- VRS Project - END


      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_B --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_tal_rec IN  tal_rec_type,
      x_tal_rec OUT NOCOPY tal_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tal_rec := p_tal_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tal_rec,                         -- IN
      l_tal_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tal_rec, l_def_tal_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_ASSETS_B
    SET TAS_ID = l_def_tal_rec.tas_id,
        OBJECT_VERSION_NUMBER = l_def_tal_rec.object_version_number,
        ILO_ID = l_def_tal_rec.ilo_id,
        ILO_ID_OLD = l_def_tal_rec.ilo_id_old,
        IAY_ID = l_def_tal_rec.iay_id,
        IAY_ID_NEW = l_def_tal_rec.iay_id_new,
        KLE_ID = l_def_tal_rec.kle_id,
        DNZ_KHR_ID = l_def_tal_rec.dnz_khr_id,
        LINE_NUMBER = l_def_tal_rec.line_number,
        ORG_ID = l_def_tal_rec.org_id,
        TAL_TYPE = l_def_tal_rec.tal_type,
        ASSET_NUMBER = l_def_tal_rec.asset_number,
        FA_LOCATION_ID = l_def_tal_rec.fa_location_id,
        ORIGINAL_COST = l_def_tal_rec.original_cost,
        CURRENT_UNITS = l_def_tal_rec.current_units,
        MANUFACTURER_NAME = l_def_tal_rec.manufacturer_name,
        YEAR_MANUFACTURED = l_def_tal_rec.year_manufactured,
        SUPPLIER_ID = l_def_tal_rec.supplier_id,
        USED_ASSET_YN = l_def_tal_rec.used_asset_yn,
        TAG_NUMBER = l_def_tal_rec.tag_number,
        MODEL_NUMBER = l_def_tal_rec.model_number,
        CORPORATE_BOOK = l_def_tal_rec.corporate_book,
        DATE_PURCHASED = l_def_tal_rec.date_purchased,
        DATE_DELIVERY = l_def_tal_rec.date_delivery,
        IN_SERVICE_DATE = l_def_tal_rec.in_service_date,
        LIFE_IN_MONTHS = l_def_tal_rec.life_in_months,
        DEPRECIATION_ID = l_def_tal_rec.depreciation_id,
        DEPRECIATION_COST = l_def_tal_rec.depreciation_cost,
        DEPRN_METHOD = l_def_tal_rec.deprn_method,
        DEPRN_RATE = l_def_tal_rec.deprn_rate,
        SALVAGE_VALUE = l_def_tal_rec.salvage_value,
        PERCENT_SALVAGE_VALUE = l_def_tal_rec.percent_salvage_value,
--Bug# 2981308
        ASSET_KEY_ID = l_def_tal_rec.asset_key_id,
-- Bug# 4028371
        FA_TRX_DATE = l_def_tal_rec.fa_trx_date,
--Bug# 4899328
        FA_COST = l_def_tal_rec.fa_cost,
        ATTRIBUTE_CATEGORY = l_def_tal_rec.attribute_category,
        ATTRIBUTE1 = l_def_tal_rec.attribute1,
        ATTRIBUTE2 = l_def_tal_rec.attribute2,
        ATTRIBUTE3 = l_def_tal_rec.attribute3,
        ATTRIBUTE4 = l_def_tal_rec.attribute4,
        ATTRIBUTE5 = l_def_tal_rec.attribute5,
        ATTRIBUTE6 = l_def_tal_rec.attribute6,
        ATTRIBUTE7 = l_def_tal_rec.attribute7,
        ATTRIBUTE8 = l_def_tal_rec.attribute8,
        ATTRIBUTE9 = l_def_tal_rec.attribute9,
        ATTRIBUTE10 = l_def_tal_rec.attribute10,
        ATTRIBUTE11 = l_def_tal_rec.attribute11,
        ATTRIBUTE12 = l_def_tal_rec.attribute12,
        ATTRIBUTE13 = l_def_tal_rec.attribute13,
        ATTRIBUTE14 = l_def_tal_rec.attribute14,
        ATTRIBUTE15 = l_def_tal_rec.attribute15,
        CREATED_BY = l_def_tal_rec.created_by,
        CREATION_DATE = l_def_tal_rec.creation_date,
        LAST_UPDATED_BY = l_def_tal_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tal_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tal_rec.last_update_login,
        DEPRECIATE_YN = l_def_tal_rec.depreciate_yn,
        HOLD_PERIOD_DAYS = l_def_tal_rec.hold_period_days,
        OLD_SALVAGE_VALUE = l_def_tal_rec.old_salvage_value,
        NEW_RESIDUAL_VALUE = l_def_tal_rec.new_residual_value,
        OLD_RESIDUAL_VALUE = l_def_tal_rec.old_residual_value,
        UNITS_RETIRED = l_def_tal_rec.units_retired,
        COST_RETIRED = l_def_tal_rec.cost_retired,
        SALE_PROCEEDS = l_def_tal_rec.sale_proceeds,
        REMOVAL_COST = l_def_tal_rec.removal_cost,
        DNZ_ASSET_ID = l_def_tal_rec.dnz_asset_id,
        DATE_DUE = l_def_tal_rec.date_due,
        REP_ASSET_ID = l_def_tal_rec.rep_asset_id,
        LKE_ASSET_ID = l_def_tal_rec.lke_asset_id,
        MATCH_AMOUNT = l_def_tal_rec.match_amount,
        SPLIT_INTO_SINGLES_FLAG = l_def_tal_rec.split_into_singles_flag,
        SPLIT_INTO_UNITS = l_def_tal_rec.split_into_units,
        CURRENCY_CODE = l_def_tal_rec.currency_code,
        CURRENCY_CONVERSION_TYPE = l_def_tal_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_tal_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_tal_rec.currency_conversion_date,

        -- VRS Project - START
        RESIDUAL_SHR_PARTY_ID =l_def_tal_rec.RESIDUAL_SHR_PARTY_ID,
        RESIDUAL_SHR_AMOUNT   =l_def_tal_rec.RESIDUAL_SHR_AMOUNT,
        RETIREMENT_ID = l_def_tal_rec.RETIREMENT_ID
        -- VRS Project - END

        WHERE ID = l_def_tal_rec.id;

    x_tal_rec := l_def_tal_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  --------------------------------------
  -- update_row for:OKL_TXL_ASSETS_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_assets_tl_rec        IN okl_txl_assets_tl_rec_type,
    x_okl_txl_assets_tl_rec        OUT NOCOPY okl_txl_assets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type := p_okl_txl_assets_tl_rec;
    l_def_okl_txl_assets_tl_rec    okl_txl_assets_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txl_assets_tl_rec	IN okl_txl_assets_tl_rec_type,
      x_okl_txl_assets_tl_rec	OUT NOCOPY okl_txl_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_assets_tl_rec := p_okl_txl_assets_tl_rec;
      -- Get current database values
      l_okl_txl_assets_tl_rec := get_rec(p_okl_txl_assets_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txl_assets_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_assets_tl_rec.id := l_okl_txl_assets_tl_rec.id;
      END IF;
      IF (x_okl_txl_assets_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_assets_tl_rec.language := l_okl_txl_assets_tl_rec.language;
      END IF;
      IF (x_okl_txl_assets_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_assets_tl_rec.source_lang := l_okl_txl_assets_tl_rec.source_lang;
      END IF;
      IF (x_okl_txl_assets_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_assets_tl_rec.sfwt_flag := l_okl_txl_assets_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txl_assets_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txl_assets_tl_rec.description := l_okl_txl_assets_tl_rec.description;
      END IF;
      IF (x_okl_txl_assets_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_assets_tl_rec.created_by := l_okl_txl_assets_tl_rec.created_by;
      END IF;
      IF (x_okl_txl_assets_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txl_assets_tl_rec.creation_date := l_okl_txl_assets_tl_rec.creation_date;
      END IF;
      IF (x_okl_txl_assets_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_assets_tl_rec.last_updated_by := l_okl_txl_assets_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txl_assets_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txl_assets_tl_rec.last_update_date := l_okl_txl_assets_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txl_assets_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txl_assets_tl_rec.last_update_login := l_okl_txl_assets_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_assets_tl_rec IN  okl_txl_assets_tl_rec_type,
      x_okl_txl_assets_tl_rec OUT NOCOPY okl_txl_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_assets_tl_rec := p_okl_txl_assets_tl_rec;
      x_okl_txl_assets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_assets_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_txl_assets_tl_rec,           -- IN
      l_okl_txl_assets_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txl_assets_tl_rec, l_def_okl_txl_assets_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_ASSETS_TL
    SET DESCRIPTION = l_def_okl_txl_assets_tl_rec.description,
        --Bug# 3641933 :
        SOURCE_LANG = l_def_okl_txl_assets_tl_rec.source_lang,
        CREATED_BY = l_def_okl_txl_assets_tl_rec.created_by,
        CREATION_DATE = l_def_okl_txl_assets_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_txl_assets_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_txl_assets_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_txl_assets_tl_rec.last_update_login
    WHERE ID = l_def_okl_txl_assets_tl_rec.id
      --Bug# 3641933 :
      AND  USERENV('LANG') in (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_TXL_ASSETS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_txl_assets_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txl_assets_tl_rec := l_def_okl_txl_assets_tl_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -------------------------------------
  -- update_row for:OKL_TXL_ASSETS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type,
    x_talv_rec                     OUT NOCOPY talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type := p_talv_rec;
    l_def_talv_rec                 talv_rec_type;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
    lx_okl_txl_assets_tl_rec       okl_txl_assets_tl_rec_type;
    l_tal_rec                      tal_rec_type;
    lx_tal_rec                     tal_rec_type;
    lx_temp_talv_rec               talv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_talv_rec	IN talv_rec_type
    ) RETURN talv_rec_type IS
      l_talv_rec	talv_rec_type := p_talv_rec;
    BEGIN
      l_talv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_talv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_talv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_talv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_talv_rec	IN talv_rec_type,
      x_talv_rec	OUT NOCOPY talv_rec_type
    ) RETURN VARCHAR2 IS
      l_talv_rec                     talv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_talv_rec := p_talv_rec;
      -- Get current database values
      l_talv_rec := get_rec(p_talv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_talv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.id := l_talv_rec.id;
      END IF;
      IF (x_talv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.object_version_number := l_talv_rec.object_version_number;
      END IF;
      IF (x_talv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.sfwt_flag := l_talv_rec.sfwt_flag;
      END IF;
      IF (x_talv_rec.tas_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.tas_id := l_talv_rec.tas_id;
      END IF;
      IF (x_talv_rec.ilo_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.ilo_id := l_talv_rec.ilo_id;
      END IF;
      IF (x_talv_rec.ilo_id_old = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.ilo_id_old := l_talv_rec.ilo_id_old;
      END IF;
      IF (x_talv_rec.iay_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.iay_id := l_talv_rec.iay_id;
      END IF;
      IF (x_talv_rec.iay_id_new = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.iay_id_new := l_talv_rec.iay_id_new;
      END IF;
      IF (x_talv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.kle_id := l_talv_rec.kle_id;
      END IF;
      IF (x_talv_rec.dnz_khr_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.dnz_khr_id := l_talv_rec.dnz_khr_id;
      END IF;
      IF (x_talv_rec.line_number = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.line_number := l_talv_rec.line_number;
      END IF;
      IF (x_talv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.org_id := l_talv_rec.org_id;
      END IF;
      IF (x_talv_rec.tal_type = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.tal_type := l_talv_rec.tal_type;
      END IF;
      IF (x_talv_rec.asset_number = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.asset_number := l_talv_rec.asset_number;
      END IF;
      IF (x_talv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.description := l_talv_rec.description;
      END IF;
      IF (x_talv_rec.fa_location_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.fa_location_id := l_talv_rec.fa_location_id;
      END IF;
      IF (x_talv_rec.original_cost = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.original_cost := l_talv_rec.original_cost;
      END IF;
      IF (x_talv_rec.current_units = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.current_units := l_talv_rec.current_units;
      END IF;
      IF (x_talv_rec.manufacturer_name = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.manufacturer_name := l_talv_rec.manufacturer_name;
      END IF;
      IF (x_talv_rec.year_manufactured = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.year_manufactured := l_talv_rec.year_manufactured;
      END IF;
      IF (x_talv_rec.supplier_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.supplier_id := l_talv_rec.supplier_id;
      END IF;
      IF (x_talv_rec.used_asset_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.used_asset_yn := l_talv_rec.used_asset_yn;
      END IF;
      IF (x_talv_rec.tag_number = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.tag_number := l_talv_rec.tag_number;
      END IF;
      IF (x_talv_rec.model_number = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.model_number := l_talv_rec.model_number;
      END IF;
      IF (x_talv_rec.corporate_book = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.corporate_book := l_talv_rec.corporate_book;
      END IF;
      IF (x_talv_rec.date_purchased = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.date_purchased := l_talv_rec.date_purchased;
      END IF;
      IF (x_talv_rec.date_delivery = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.date_delivery := l_talv_rec.date_delivery;
      END IF;
      IF (x_talv_rec.in_service_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.in_service_date := l_talv_rec.in_service_date;
      END IF;
      IF (x_talv_rec.life_in_months = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.life_in_months := l_talv_rec.life_in_months;
      END IF;
      IF (x_talv_rec.depreciation_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.depreciation_id := l_talv_rec.depreciation_id;
      END IF;
      IF (x_talv_rec.depreciation_cost = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.depreciation_cost := l_talv_rec.depreciation_cost;
      END IF;
      IF (x_talv_rec.deprn_method = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.deprn_method := l_talv_rec.deprn_method;
      END IF;
      IF (x_talv_rec.deprn_rate = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.deprn_rate := l_talv_rec.deprn_rate;
      END IF;
      IF (x_talv_rec.salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.salvage_value := l_talv_rec.salvage_value;
      END IF;
      IF (x_talv_rec.percent_salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.percent_salvage_value := l_talv_rec.percent_salvage_value;
      END IF;
--Bug# 2981308
      IF (x_talv_rec.asset_key_id = OKL_API.G_MISS_NUM)
      THEN
        x_talv_rec.asset_key_id := l_talv_rec.asset_key_id;
      END IF;
-- Bug# 4028371
      IF (x_talv_rec.fa_trx_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.fa_trx_date := l_talv_rec.fa_trx_date;
      END IF;
--Bug# 4899328
      IF (x_talv_rec.fa_cost = OKL_API.G_MISS_NUM)
      THEN
        x_talv_rec.fa_cost := l_talv_rec.fa_cost;
      END IF;
      IF (x_talv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute_category := l_talv_rec.attribute_category;
      END IF;
      IF (x_talv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute1 := l_talv_rec.attribute1;
      END IF;
      IF (x_talv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute2 := l_talv_rec.attribute2;
      END IF;
      IF (x_talv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute3 := l_talv_rec.attribute3;
      END IF;
      IF (x_talv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute4 := l_talv_rec.attribute4;
      END IF;
      IF (x_talv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute5 := l_talv_rec.attribute5;
      END IF;
      IF (x_talv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute6 := l_talv_rec.attribute6;
      END IF;
      IF (x_talv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute7 := l_talv_rec.attribute7;
      END IF;
      IF (x_talv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute8 := l_talv_rec.attribute8;
      END IF;
      IF (x_talv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute9 := l_talv_rec.attribute9;
      END IF;
      IF (x_talv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute10 := l_talv_rec.attribute10;
      END IF;
      IF (x_talv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute11 := l_talv_rec.attribute11;
      END IF;
      IF (x_talv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute12 := l_talv_rec.attribute12;
      END IF;
      IF (x_talv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute13 := l_talv_rec.attribute13;
      END IF;
      IF (x_talv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute14 := l_talv_rec.attribute14;
      END IF;
      IF (x_talv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.attribute15 := l_talv_rec.attribute15;
      END IF;
      IF (x_talv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.created_by := l_talv_rec.created_by;
      END IF;
      IF (x_talv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.creation_date := l_talv_rec.creation_date;
      END IF;
      IF (x_talv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.last_updated_by := l_talv_rec.last_updated_by;
      END IF;
      IF (x_talv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.last_update_date := l_talv_rec.last_update_date;
      END IF;
      IF (x_talv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.last_update_login := l_talv_rec.last_update_login;
      END IF;
      IF (x_talv_rec.depreciate_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.depreciate_yn := l_talv_rec.depreciate_yn;
      END IF;
      IF (x_talv_rec.hold_period_days = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.hold_period_days := l_talv_rec.hold_period_days;
      END IF;
      IF (x_talv_rec.old_salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.old_salvage_value := l_talv_rec.old_salvage_value;
      END IF;
      IF (x_talv_rec.new_residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.new_residual_value := l_talv_rec.new_residual_value;
      END IF;
      IF (x_talv_rec.old_residual_value = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.old_residual_value := l_talv_rec.old_residual_value;
      END IF;
      IF (x_talv_rec.units_retired = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.units_retired := l_talv_rec.units_retired;
      END IF;
      IF (x_talv_rec.cost_retired = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.cost_retired := l_talv_rec.cost_retired;
      END IF;
      IF (x_talv_rec.sale_proceeds = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.sale_proceeds := l_talv_rec.sale_proceeds;
      END IF;
      IF (x_talv_rec.removal_cost = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.removal_cost := l_talv_rec.removal_cost;
      END IF;
      IF (x_talv_rec.dnz_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.dnz_asset_id := l_talv_rec.dnz_asset_id;
      END IF;
      IF (x_talv_rec.date_due = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.date_due := l_talv_rec.date_due;
      END IF;
      IF (x_talv_rec.rep_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.rep_asset_id := l_talv_rec.rep_asset_id;
      END IF;
      IF (x_talv_rec.lke_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.lke_asset_id := l_talv_rec.lke_asset_id;
      END IF;
      IF (x_talv_rec.match_amount = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.match_amount := l_talv_rec.match_amount;
      END IF;
      IF (x_talv_rec.split_into_singles_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.split_into_singles_flag := l_talv_rec.split_into_singles_flag;
      END IF;
      IF (x_talv_rec.split_into_units = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.split_into_units := l_talv_rec.split_into_units;
      END IF;

      -- Multi Currency Change
      IF (x_talv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.currency_code := l_talv_rec.currency_code;
      END IF;
      IF (x_talv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_talv_rec.currency_conversion_type := l_talv_rec.currency_conversion_type;
      END IF;
      IF (x_talv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.currency_conversion_rate := l_talv_rec.currency_conversion_rate;
      END IF;
      IF (x_talv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_talv_rec.currency_conversion_date := l_talv_rec.currency_conversion_date;
      END IF;
      -- Multi Currency Change

      -- VRS Project - START
      IF (x_talv_rec.RESIDUAL_SHR_PARTY_ID = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.RESIDUAL_SHR_PARTY_ID := l_talv_rec.RESIDUAL_SHR_PARTY_ID;
      END IF;
      IF (x_talv_rec.RESIDUAL_SHR_AMOUNT = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.RESIDUAL_SHR_AMOUNT := l_talv_rec.RESIDUAL_SHR_AMOUNT;
      END IF;
      IF (x_talv_rec.RETIREMENT_ID = OKC_API.G_MISS_NUM)
      THEN
        x_talv_rec.RETIREMENT_ID := l_talv_rec.RETIREMENT_ID;
      END IF;
      -- VRS Project - END

      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_talv_rec IN  talv_rec_type,
      x_talv_rec OUT NOCOPY talv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_talv_rec := p_talv_rec;
      x_talv_rec.OBJECT_VERSION_NUMBER := NVL(x_talv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_talv_rec,                        -- IN
      l_talv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_talv_rec, l_def_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := fill_who_columns(l_def_talv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_talv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_talv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --
    -- Multi-Currency Change, dedey, 12/04/2002
    --
    validate_currency(
                      x_return_status => l_return_status,
                      p_talv_rec      => l_def_talv_rec,
                      x_talv_rec      => lx_temp_talv_rec
                     );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := lx_temp_talv_rec;

    --dbms_output.put_line('After Change: '||lx_temp_talv_rec.currency_code);
    --dbms_output.put_line('After Change: '||l_def_talv_rec.currency_code);
    --
    -- Multi-Currency Change
    --

    --
    -- Fix Bug# 2737014
    --
    -- Round off amounts
    --
    roundoff_line_amount(
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_talv_rec      => l_def_talv_rec,
                         x_talv_rec      => lx_temp_talv_rec
                        );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_talv_rec := lx_temp_talv_rec;

    --dbms_output.put_line('After Change Orig cost: '||lx_temp_talv_rec.original_cost);
    --dbms_output.put_line('After Change Orig cost: '||l_def_talv_rec.original_cost);

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_talv_rec, l_okl_txl_assets_tl_rec);
    migrate(l_def_talv_rec, l_tal_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_assets_tl_rec,
      lx_okl_txl_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_assets_tl_rec, l_def_talv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tal_rec,
      lx_tal_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tal_rec, l_def_talv_rec);
    x_talv_rec := l_def_talv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:TALV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type,
    x_talv_tbl                     OUT NOCOPY talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i),
          x_talv_rec                     => x_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- delete_row for:OKL_TXL_ASSETS_B --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tal_rec                      IN tal_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tal_rec                      tal_rec_type:= p_tal_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_ASSETS_B
     WHERE ID = l_tal_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  --------------------------------------
  -- delete_row for:OKL_TXL_ASSETS_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_assets_tl_rec        IN okl_txl_assets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type:= p_okl_txl_assets_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKL_TXL_ASSETS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_assets_tl_rec IN  okl_txl_assets_tl_rec_type,
      x_okl_txl_assets_tl_rec OUT NOCOPY okl_txl_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_assets_tl_rec := p_okl_txl_assets_tl_rec;
      x_okl_txl_assets_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_txl_assets_tl_rec,           -- IN
      l_okl_txl_assets_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_ASSETS_TL
     WHERE ID = l_okl_txl_assets_tl_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------
  -- delete_row for:OKL_TXL_ASSETS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_rec                     IN talv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_talv_rec                     talv_rec_type := p_talv_rec;
    l_okl_txl_assets_tl_rec        okl_txl_assets_tl_rec_type;
    l_tal_rec                      tal_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_talv_rec, l_okl_txl_assets_tl_rec);
    migrate(l_talv_rec, l_tal_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tal_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:TALV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_talv_tbl                     IN talv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_talv_tbl.COUNT > 0) THEN
      i := p_talv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_talv_rec                     => p_talv_tbl(i));
        EXIT WHEN (i = p_talv_tbl.LAST);
        i := p_talv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_TAL_PVT;

/
