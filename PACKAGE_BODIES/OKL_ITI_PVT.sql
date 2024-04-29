--------------------------------------------------------
--  DDL for Package Body OKL_ITI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ITI_PVT" AS
/* $Header: OKLSITIB.pls 120.2 2006/07/11 10:21:57 dkagrawa noship $ */
-- Badrinath Kuchibholta
/************************ HAND-CODED *********************************/
G_TABLE_TOKEN                CONSTANT  VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR           CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_ID2                        CONSTANT  VARCHAR2(200) := '#';
G_SQLERRM_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN              CONSTANT  VARCHAR2(200) := 'SQLcode';

G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
G_INVALID_VALUE              CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
G_NO_MATCHING_RECORD         CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
G_TAL_LOOKUP_TYPE            CONSTANT  VARCHAR2(200) := 'OKL_TRANS_LINE_TYPE';
G_EXCEPTION_HALT_VALIDATION            EXCEPTION;
G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
-- List validation procedures for quick reference
--1.  validate_tas_id                -- Attribute Validation
--2.  Validate_tal_id                -- Attribute Validation
--3.  Validate_kle_id                -- Attribute Validation
--5.  validate_object_id1_new        -- Attribute Validation
--6.  validate_object_id2_new        -- Attribute Validation
--7.  validate_jtot_object_code_new  -- Attribute Validation
--8.  validate_object_id1_old        -- Attribute Validation
--9.  validate_object_id2_old        -- Attribute Validation
--10. validate_jtot_object_code_old  -- Attribute Validation
--11. validate_mfg_serial_number_yn  -- Attribute Validation
--12. validate_inv_item_id           -- Attribute Validation
--13. validate_inv_master_org_id     -- Attribute Validation
--14. validate_inv_org_id            -- Atrribute Validation
--Bug#Bug# 2697681 schema change  : 11.5.9 Split asset by serial numbers validations
--15. Instance_id                    -- Attribute Validation
--16. Selected_for_split_flag        -- Attribute Validation
--17. Asd_Id                         -- Attribute Validation
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
                            p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_tas_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TRX_ASSETS
                  WHERE id = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.tas_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.tas_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_tas_id_validate(p_itiv_rec.tas_id);
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
    -- If the cursor is open then it has to be closed
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
-- Procedure Name       : Validate_tal_id
-- Description          : FK validation with OKL_TXL_ASSETS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tal_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_tal_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_V
                  WHERE id = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.tal_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.tal_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_tal_id_validate(p_itiv_rec.tal_id);
    IF c_tal_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_tal_id_validate into ln_dummy;
    CLOSE c_tal_id_validate;
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
                        p_token1_value => 'tal_id');
    -- If the cursor is open then it has to be closed
    IF c_tal_id_validate%ISOPEN THEN
       CLOSE c_tal_id_validate;
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
    IF c_tal_id_validate%ISOPEN THEN
       CLOSE c_tal_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tal_id;
--------------------------------3-------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_kle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_kle_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_itiv_rec IN itiv_rec_type) IS
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
    IF (p_itiv_rec.kle_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.kle_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_kle_id_validate(p_itiv_rec.kle_id);
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
                              p_itiv_rec IN itiv_rec_type) IS
    l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.tal_type = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.tal_type IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    l_return_status := OKC_UTIL.check_lookup_code(G_TAL_LOOKUP_TYPE,
                                                  p_itiv_rec.tal_type);
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
----------------------------------5----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_object_id1_new
-- Description          : Validate against OKX_PARTY_SITE_USES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_object_id1_new(x_return_status OUT NOCOPY VARCHAR2,
                                    p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_object_id1_new_validate(p_id1 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM OKX_PARTY_SITE_USES_V
                 WHERE id1 = p_id1);
--                 FROM OKX_CUST_SITE_USES_V
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.object_id1_new = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.object_id1_new IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_object_id1_new_validate(p_itiv_rec.object_id1_new);
    IF c_object_id1_new_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_object_id1_new_validate into ln_dummy;
    CLOSE c_object_id1_new_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'object_id1_new');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'object_id1_new');
       -- If the cursor is open then it has to be closed
    IF c_object_id1_new_validate%ISOPEN THEN
       CLOSE c_object_id1_new_validate;
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
    IF c_object_id1_new_validate%ISOPEN THEN
       CLOSE c_object_id1_new_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_id1_new;
-----------------------------------6---------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_object_id2_new
-- Description          : Validate against OKX_PARTY_SITES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_object_id2_new(x_return_status OUT NOCOPY VARCHAR2,
                                    p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_object_id2_new_validate(p_id1 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE,
                                     p_id2 OKL_TXL_ITM_INSTS_V.OBJECT_ID2_NEW%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM OKX_PARTY_SITE_USES_V
                 WHERE id2 = p_id2
                 AND id1 = p_id1);
--                 FROM OKX_CUST_SITE_USES_V
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.object_id2_new = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.object_id2_new IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_object_id2_new_validate(p_itiv_rec.object_id1_new,
                                    p_itiv_rec.object_id2_new);
    IF c_object_id2_new_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_object_id2_new_validate into ln_dummy;
    CLOSE c_object_id2_new_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'object_id2_new');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'object_id2_new');
       -- If the cursor is open then it has to be closed
    IF c_object_id2_new_validate%ISOPEN THEN
       CLOSE c_object_id2_new_validate;
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
    IF c_object_id2_new_validate%ISOPEN THEN
       CLOSE c_object_id2_new_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_id2_new;
------------------------------------7--------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_jtot_object_code_new
-- Description          : Check if same pre seeded jtot object
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_jtot_object_code_new(x_return_status OUT NOCOPY VARCHAR2,
                                          p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_jtot_code_new_validate(
        p_jtot_code_new  OKL_TXL_ITM_INSTS_V.JTOT_OBJECT_CODE_NEW%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM JTF_OBJECTS_B
                  WHERE object_code = p_jtot_code_new);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.jtot_object_code_new = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.jtot_object_code_new IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN c_jtot_code_new_validate(p_itiv_rec.jtot_object_code_new);
    IF c_jtot_code_new_validate%NOTFOUND THEN
       -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_jtot_code_new_validate INTO ln_dummy;
    CLOSE c_jtot_code_new_validate;
    -- Check if same pre seeded jtot object
    IF ln_dummy = 0 THEN
       -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'jtot_object_code_new');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'jtot_object_code_new');
       -- If the cursor is open then it has to be closed
    IF c_jtot_code_new_validate%ISOPEN THEN
       CLOSE c_jtot_code_new_validate;
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
    IF c_jtot_code_new_validate%ISOPEN THEN
       CLOSE c_jtot_code_new_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_jtot_object_code_new;
-------------------------------------8-------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_object_id1_old
-- Description          : Validate against OKX_CUST_SITE_USES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_object_id1_old(x_return_status OUT NOCOPY VARCHAR2,
                                    p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_object_id1_old_validate(p_id1 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_OLD%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM OKX_PARTY_SITE_USES_V
                 WHERE id1 = p_id1);
--                 FROM OKX_CUST_SITE_USES_V

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.object_id1_old = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.object_id1_old IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_object_id1_old_validate(p_itiv_rec.object_id1_old);
    IF c_object_id1_old_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_object_id1_old_validate into ln_dummy;
    CLOSE c_object_id1_old_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'object_id1_old');
       -- If the cursor is open then it has to be closed
    IF c_object_id1_old_validate%ISOPEN THEN
       CLOSE c_object_id1_old_validate;
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
    IF c_object_id1_old_validate%ISOPEN THEN
       CLOSE c_object_id1_old_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_id1_old;
--------------------------------------9------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_object_id2_old
-- Description          : Validate against OKX_CUST_SITE_USES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_object_id2_old(x_return_status OUT NOCOPY VARCHAR2,
                                    p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_object_id2_old_validate(p_id1 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_OLD%TYPE,
                                     p_id2 OKL_TXL_ITM_INSTS_V.OBJECT_ID2_OLD%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM OKX_PARTY_SITE_USES_V
                 WHERE id2 = p_id2
                 AND id1 = p_id1);
--                 FROM OKX_CUST_SITE_USES_V

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.object_id2_old = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.object_id2_old IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_object_id2_old_validate(p_itiv_rec.object_id1_old,
                                    p_itiv_rec.object_id2_old);
    IF c_object_id2_old_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_object_id2_old_validate into ln_dummy;
    CLOSE c_object_id2_old_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'object_id2_old');
       -- If the cursor is open then it has to be closed
    IF c_object_id2_old_validate%ISOPEN THEN
       CLOSE c_object_id2_old_validate;
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
    IF c_object_id2_old_validate%ISOPEN THEN
       CLOSE c_object_id2_old_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_id2_old;
---------------------------------------10-----------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_jtot_object_code_old
-- Description          : Check if same pre seeded jtot object
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_jtot_object_code_old(x_return_status OUT NOCOPY VARCHAR2,
                                          p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_jtot_code_old_validate(
        p_jtot_code_old OKL_TXL_ITM_INSTS_V.JTOT_OBJECT_CODE_OLD%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM JTF_OBJECTS_B
                  WHERE object_code = p_jtot_code_old);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.jtot_object_code_old = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.jtot_object_code_old IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;    OPEN c_jtot_code_old_validate(p_itiv_rec.jtot_object_code_old);
    IF c_jtot_code_old_validate%NOTFOUND THEN
       -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_jtot_code_old_validate INTO ln_dummy;
    CLOSE c_jtot_code_old_validate;
    -- Check if same pre seeded jtot object
    IF ln_dummy = 0 THEN
       -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'jtot_object_code_old');
       -- If the cursor is open then it has to be closed
    IF c_jtot_code_old_validate%ISOPEN THEN
       CLOSE c_jtot_code_old_validate;
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
    IF c_jtot_code_old_validate%ISOPEN THEN
       CLOSE c_jtot_code_old_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_jtot_object_code_old;
----------------------------------------11----------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_mfg_serial_number_yn
-- Description          : Check Constraint for Y,N
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_mfg_serial_number_yn(x_return_status OUT NOCOPY VARCHAR2,
                                          p_itiv_rec IN itiv_rec_type) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.mfg_serial_number_yn = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.mfg_serial_number_yn IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- See that in Y,N
    IF p_itiv_rec.mfg_serial_number_yn not in ('Y','N') THEN
       -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'mfg_serial_number_yn');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'mfg_serial_number_yn');
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
  END validate_mfg_serial_number_yn;

------------------------------------------12--------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_inv_item_id
-- Description          : FK validation with OKX_SYSTEM_ITEMS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_inv_item_id(x_return_status OUT NOCOPY VARCHAR2,
                                 p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;

    CURSOR c_inv_item_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_SYSTEM_ITEMS_V
                  WHERE id1 = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.inventory_item_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.inventory_item_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_inv_item_id_validate(p_itiv_rec.inventory_item_id);
    IF c_inv_item_id_validate%NOTFOUND THEN
     -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_inv_item_id_validate into ln_dummy;
    CLOSE c_inv_item_id_validate;
    IF (ln_dummy = 0) then
     -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'inventory_item_id');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'inventory_item_id');
    -- If the cursor is open then it has to be closed
    IF c_inv_item_id_validate%ISOPEN THEN
       CLOSE c_inv_item_id_validate;
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
    IF c_inv_item_id_validate%ISOPEN THEN
       CLOSE c_inv_item_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_inv_item_id;
--------------------------------------------13------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_inv_master_org__id
-- Description          : FK validation with OKX_SYSTEM_ITEMS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_inv_master_org_id(x_return_status OUT NOCOPY VARCHAR2,
                                      p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_inv_master_org_id_validate(p_id number) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_SYSTEM_ITEMS_V
                  WHERE id2 = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.inv_master_org_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.inv_master_org_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_inv_master_org_id_validate(p_itiv_rec.inv_master_org_id);
    IF c_inv_master_org_id_validate%NOTFOUND THEN
     -- halt validation as it has parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_inv_master_org_id_validate into ln_dummy;
    CLOSE c_inv_master_org_id_validate;
    IF (ln_dummy = 0) then
     -- halt validation as it has parent record
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
                        p_token1_value => 'inv_master_org_id');
    -- If the cursor is open then it has to be closed
    IF c_inv_master_org_id_validate%ISOPEN THEN
       CLOSE c_inv_master_org_id_validate;
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
    IF c_inv_master_org_id_validate%ISOPEN THEN
       CLOSE c_inv_master_org_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_inv_master_org_id;

--------------------------------------14------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_inv_org_id
-- Description          : Validate against OKX_ORGANIZATION_DEFS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_inv_org_id(x_return_status OUT NOCOPY VARCHAR2,
                                p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_inventory_org_id_validate(p_id1 OKX_ORGANIZATION_DEFS_V.ID1%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM OKX_ORGANIZATION_DEFS_V
                 WHERE id2 = G_ID2
                 AND  organization_type = 'INV'
                 AND id1 = p_id1);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.inventory_org_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.inventory_org_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_inventory_org_id_validate(p_itiv_rec.inventory_org_id);
    IF c_inventory_org_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_inventory_org_id_validate into ln_dummy;
    CLOSE c_inventory_org_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'inventory_org_id');
       -- If the cursor is open then it has to be closed
    IF c_inventory_org_id_validate%ISOPEN THEN
       CLOSE c_inventory_org_id_validate;
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
    IF c_inventory_org_id_validate%ISOPEN THEN
       CLOSE c_inventory_org_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_inv_org_id;
--------------------------------------15----------------------------------------
-- Start of Commnets
-- avsingh
-- Procedure Name       : validate_instance_id
-- Description          : Validate against CSI_ITEM_INSTANCES
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_instance_id(x_return_status OUT NOCOPY VARCHAR2,
                                p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_instance_id_validate(p_instance_id NUMBER) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM  CSI_ITEM_INSTANCES
                 WHERE instance_id = p_instance_id
                 );
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.instance_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.instance_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_instance_id_validate(p_itiv_rec.instance_id);
    IF c_instance_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_instance_id_validate into ln_dummy;
    CLOSE c_instance_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'instance_id');
       -- If the cursor is open then it has to be closed
    IF c_instance_id_validate%ISOPEN THEN
       CLOSE c_instance_id_validate;
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
    IF c_instance_id_validate%ISOPEN THEN
       CLOSE c_instance_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_instance_id;
--------------------------------------16----------------------------------------
-- Start of Commnets
-- avsingh
-- Procedure Name       : validate_slctd_for_split
-- Description          : Validate against selected_for_split_flag
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_slctd_for_split(x_return_status OUT NOCOPY VARCHAR2,
                                     p_itiv_rec      IN itiv_rec_type) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.selected_for_split_flag = OKC_API.G_MISS_CHAR) OR
       (p_itiv_rec.selected_for_split_flag IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Valid values
    --'Y' = Selected
    --'N' = Not selected
    --'P' = Split has been processed
    If p_itiv_rec.selected_for_split_flag not in ('Y','N','P') Then
       -- halt validation as it has no valid value
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'selected_for_split_flag');
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
  END validate_slctd_for_split;
--------------------------------------17----------------------------------------
-- Start of Commnets
-- avsingh
-- Procedure Name       : validate_asd_id
-- Description          : Validate against OKL_TXD_ASSETS_B
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_asd_id(x_return_status OUT NOCOPY VARCHAR2,
                                p_itiv_rec IN itiv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_asd_id_validate(p_asd_id NUMBER) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                 FROM  OKL_TXD_ASSETS_B
                 WHERE id = p_asd_id
                 );
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_itiv_rec.asd_id = OKC_API.G_MISS_NUM) OR
       (p_itiv_rec.asd_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_asd_id_validate(p_itiv_rec.asd_id);
    IF c_asd_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_asd_id_validate into ln_dummy;
    CLOSE c_asd_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION THEN
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'asd_id');
       -- If the cursor is open then it has to be closed
    IF c_asd_id_validate%ISOPEN THEN
       CLOSE c_asd_id_validate;
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
    IF c_asd_id_validate%ISOPEN THEN
       CLOSE c_asd_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_asd_id;
/************************ HAND-CODED *********************************/
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
  -- FUNCTION get_rec for: OKL_TXL_ITM_INSTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_iti_rec                      IN iti_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN)
    RETURN iti_rec_type IS
    CURSOR okl_txl_itm_insts_b_pk_csr(
             p_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
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
           DNZ_CLE_ID,
--Bug# 2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
           instance_id,
           selected_for_split_flag,
           asd_id
    FROM OKL_TXL_ITM_INSTS iti
    WHERE iti.id  = p_id;
    l_okl_txl_itm_insts_b_pk       okl_txl_itm_insts_b_pk_csr%ROWTYPE;
    l_iti_rec                      iti_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_itm_insts_b_pk_csr (p_iti_rec.id);
    FETCH okl_txl_itm_insts_b_pk_csr INTO
              l_iti_rec.ID,
              l_iti_rec.OBJECT_VERSION_NUMBER,
              l_iti_rec.TAS_ID,
              l_iti_rec.TAL_ID,
              l_iti_rec.KLE_ID,
              l_iti_rec.TAL_TYPE,
              l_iti_rec.LINE_NUMBER,
              l_iti_rec.INSTANCE_NUMBER_IB,
              l_iti_rec.OBJECT_ID1_NEW,
              l_iti_rec.OBJECT_ID2_NEW,
              l_iti_rec.JTOT_OBJECT_CODE_NEW,
              l_iti_rec.OBJECT_ID1_OLD,
              l_iti_rec.OBJECT_ID2_OLD,
              l_iti_rec.JTOT_OBJECT_CODE_OLD,
              l_iti_rec.INVENTORY_ORG_ID,
              l_iti_rec.SERIAL_NUMBER,
              l_iti_rec.MFG_SERIAL_NUMBER_YN,
              l_iti_rec.INVENTORY_ITEM_ID,
              l_iti_rec.INV_MASTER_ORG_ID,
              l_iti_rec.ATTRIBUTE_CATEGORY,
              l_iti_rec.ATTRIBUTE1,
              l_iti_rec.ATTRIBUTE2,
              l_iti_rec.ATTRIBUTE3,
              l_iti_rec.ATTRIBUTE4,
              l_iti_rec.ATTRIBUTE5,
              l_iti_rec.ATTRIBUTE6,
              l_iti_rec.ATTRIBUTE7,
              l_iti_rec.ATTRIBUTE8,
              l_iti_rec.ATTRIBUTE9,
              l_iti_rec.ATTRIBUTE10,
              l_iti_rec.ATTRIBUTE11,
              l_iti_rec.ATTRIBUTE12,
              l_iti_rec.ATTRIBUTE13,
              l_iti_rec.ATTRIBUTE14,
              l_iti_rec.ATTRIBUTE15,
              l_iti_rec.CREATED_BY,
              l_iti_rec.CREATION_DATE,
              l_iti_rec.LAST_UPDATED_BY,
              l_iti_rec.LAST_UPDATE_DATE,
              l_iti_rec.LAST_UPDATE_LOGIN,
              l_iti_rec.DNZ_CLE_ID,
--Bug#2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
              l_iti_rec.instance_id,
              l_iti_rec.selected_for_split_flag,
              l_iti_rec.asd_id;
    x_no_data_found := okl_txl_itm_insts_b_pk_csr%NOTFOUND;
    CLOSE okl_txl_itm_insts_b_pk_csr;
    RETURN(l_iti_rec);
  END get_rec;

  FUNCTION get_rec (
    p_iti_rec                      IN iti_rec_type
  ) RETURN iti_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_iti_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ITEM_INSTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_itiv_rec                     IN itiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN itiv_rec_type IS
    CURSOR okl_itiv_pk_csr (p_id                 IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
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
           DNZ_CLE_ID,
--Bug#2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
           instance_id,
           selected_for_split_flag,
           asd_id
    FROM OKL_TXL_ITM_INSTS_V iti
    WHERE iti.id  = p_id;
    l_okl_itiv_pk                  okl_itiv_pk_csr%ROWTYPE;
    l_itiv_rec                     itiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_itiv_pk_csr (p_itiv_rec.id);
    FETCH okl_itiv_pk_csr INTO
              l_itiv_rec.ID,
              l_itiv_rec.OBJECT_VERSION_NUMBER,
              l_itiv_rec.TAS_ID,
              l_itiv_rec.TAL_ID,
              l_itiv_rec.KLE_ID,
              l_itiv_rec.TAL_TYPE,
              l_itiv_rec.LINE_NUMBER,
              l_itiv_rec.INSTANCE_NUMBER_IB,
              l_itiv_rec.OBJECT_ID1_NEW,
              l_itiv_rec.OBJECT_ID2_NEW,
              l_itiv_rec.JTOT_OBJECT_CODE_NEW,
              l_itiv_rec.OBJECT_ID1_OLD,
              l_itiv_rec.OBJECT_ID2_OLD,
              l_itiv_rec.JTOT_OBJECT_CODE_OLD,
              l_itiv_rec.INVENTORY_ORG_ID,
              l_itiv_rec.SERIAL_NUMBER,
              l_itiv_rec.MFG_SERIAL_NUMBER_YN,
              l_itiv_rec.INVENTORY_ITEM_ID,
              l_itiv_rec.INV_MASTER_ORG_ID,
              l_itiv_rec.ATTRIBUTE_CATEGORY,
              l_itiv_rec.ATTRIBUTE1,
              l_itiv_rec.ATTRIBUTE2,
              l_itiv_rec.ATTRIBUTE3,
              l_itiv_rec.ATTRIBUTE4,
              l_itiv_rec.ATTRIBUTE5,
              l_itiv_rec.ATTRIBUTE6,
              l_itiv_rec.ATTRIBUTE7,
              l_itiv_rec.ATTRIBUTE8,
              l_itiv_rec.ATTRIBUTE9,
              l_itiv_rec.ATTRIBUTE10,
              l_itiv_rec.ATTRIBUTE11,
              l_itiv_rec.ATTRIBUTE12,
              l_itiv_rec.ATTRIBUTE13,
              l_itiv_rec.ATTRIBUTE14,
              l_itiv_rec.ATTRIBUTE15,
              l_itiv_rec.CREATED_BY,
              l_itiv_rec.CREATION_DATE,
              l_itiv_rec.LAST_UPDATED_BY,
              l_itiv_rec.LAST_UPDATE_DATE,
              l_itiv_rec.LAST_UPDATE_LOGIN,
              l_itiv_rec.DNZ_CLE_ID,
--Bug#2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
              l_itiv_rec.instance_id,
              l_itiv_rec.selected_for_split_flag,
              l_itiv_rec.asd_id;
    x_no_data_found := okl_itiv_pk_csr%NOTFOUND;
    CLOSE okl_itiv_pk_csr;
    RETURN(l_itiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_itiv_rec                     IN itiv_rec_type
  ) RETURN itiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_itiv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_ITEM_INSTS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_itiv_rec	IN itiv_rec_type
  ) RETURN itiv_rec_type IS
    l_itiv_rec	itiv_rec_type := p_itiv_rec;
  BEGIN
    IF (l_itiv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.object_version_number := NULL;
    END IF;
    IF (l_itiv_rec.tas_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.tas_id := NULL;
    END IF;
    IF (l_itiv_rec.tal_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.tal_id := NULL;
    END IF;
    IF (l_itiv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.kle_id := NULL;
    END IF;
    IF (l_itiv_rec.tal_type = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.tal_type := NULL;
    END IF;
    IF (l_itiv_rec.line_number = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.line_number := NULL;
    END IF;
    IF (l_itiv_rec.instance_number_ib = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.instance_number_ib := NULL;
    END IF;
    IF (l_itiv_rec.object_id1_new = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.object_id1_new := NULL;
    END IF;
    IF (l_itiv_rec.object_id2_new = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.object_id2_new := NULL;
    END IF;
    IF (l_itiv_rec.jtot_object_code_new = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.jtot_object_code_new := NULL;
    END IF;
    IF (l_itiv_rec.object_id1_old = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.object_id1_old := NULL;
    END IF;
    IF (l_itiv_rec.object_id2_old = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.object_id2_old := NULL;
    END IF;
    IF (l_itiv_rec.jtot_object_code_old = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.jtot_object_code_old := NULL;
    END IF;
    IF (l_itiv_rec.inventory_org_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.inventory_org_id := NULL;
    END IF;
    IF (l_itiv_rec.serial_number = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.serial_number := NULL;
    END IF;
    IF (l_itiv_rec.mfg_serial_number_yn = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.mfg_serial_number_yn := NULL;
    END IF;
    IF (l_itiv_rec.inventory_item_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.inventory_item_id := NULL;
    END IF;
    IF (l_itiv_rec.inv_master_org_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.inv_master_org_id := NULL;
    END IF;
    IF (l_itiv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute_category := NULL;
    END IF;
    IF (l_itiv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
        l_itiv_rec.attribute1 := NULL;
    END IF;
    IF (l_itiv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
        l_itiv_rec.attribute2 := NULL;
    END IF;
    IF (l_itiv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
        l_itiv_rec.attribute3 := NULL;
    END IF;
    IF (l_itiv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
        l_itiv_rec.attribute4 := NULL;
    END IF;
    IF (l_itiv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute5 := NULL;
    END IF;
    IF (l_itiv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute6 := NULL;
    END IF;
    IF (l_itiv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute7 := NULL;
    END IF;
    IF (l_itiv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute8 := NULL;
    END IF;
    IF (l_itiv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute9 := NULL;
    END IF;
    IF (l_itiv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute10 := NULL;
    END IF;
    IF (l_itiv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute11 := NULL;
    END IF;
    IF (l_itiv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute12 := NULL;
    END IF;
    IF (l_itiv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute13 := NULL;
    END IF;
    IF (l_itiv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute14 := NULL;
    END IF;
    IF (l_itiv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.attribute15 := NULL;
    END IF;
    IF (l_itiv_rec.created_by = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.created_by := NULL;
    END IF;
    IF (l_itiv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
       l_itiv_rec.creation_date := NULL;
    END IF;
    IF (l_itiv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_itiv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
       l_itiv_rec.last_update_date := NULL;
    END IF;
    IF (l_itiv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.last_update_login := NULL;
    END IF;
    IF (l_itiv_rec.dnz_cle_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.dnz_cle_id := NULL;
    END IF;
--Bug#2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
    IF (l_itiv_rec.instance_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.instance_id := NULL;
    END IF;
    IF (l_itiv_rec.selected_for_split_flag = OKC_API.G_MISS_CHAR) THEN
       l_itiv_rec.selected_for_split_flag := NULL;
    END IF;
    IF (l_itiv_rec.asd_id = OKC_API.G_MISS_NUM) THEN
       l_itiv_rec.asd_id := NULL;
    END IF;
    RETURN(l_itiv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for: OKL_TXL_ITEM_INSTS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_itiv_rec IN  itiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_itiv_rec.id = OKC_API.G_MISS_NUM OR
       p_itiv_rec.id IS NULL
    THEN
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
       l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_itiv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_itiv_rec.object_version_number IS NULL THEN
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
       l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_itiv_rec.line_number = OKC_API.G_MISS_NUM OR
          p_itiv_rec.line_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_itiv_rec.instance_number_ib = OKC_API.G_MISS_CHAR OR
          p_itiv_rec.instance_number_ib IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'instance_number_ib');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
/************************ HAND-CODED *********************************/
    -- Calling Local validation procedures
    validate_tas_id(x_return_status  => l_return_status,
                    p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    Validate_tal_id(x_return_status  => l_return_status,
                    p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    Validate_kle_id(x_return_status  => l_return_status,
                   p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_tal_type(x_return_status  => l_return_status,
                      p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_object_id1_new(x_return_status  => l_return_status,
                            p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_object_id2_new(x_return_status  => l_return_status,
                            p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_jtot_object_code_new (x_return_status  => l_return_status,
                                  p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_object_id1_old(x_return_status  => l_return_status,
                            p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_object_id2_old(x_return_status  => l_return_status,
                            p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_jtot_object_code_old (x_return_status  => l_return_status,
                                  p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_mfg_serial_number_yn(x_return_status  => l_return_status,
                                  p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_inv_item_id(x_return_status  => l_return_status,
                                  p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_inv_master_org_id(x_return_status  => l_return_status,
                                  p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_inv_org_id(x_return_status  => l_return_status,
                       p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_instance_id(x_return_status  => l_return_status,
                       p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_slctd_for_split(x_return_status  => l_return_status,
                       p_itiv_rec => p_itiv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_asd_id(x_return_status  => l_return_status,
                       p_itiv_rec => p_itiv_rec);
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
    RETURN(l_return_status);
/************************ HAND-CODED *********************************/
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for: OKL_TXL_ITM_INSTS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_itiv_rec IN itiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN itiv_rec_type,
    p_to	OUT NOCOPY iti_rec_type
  ) IS
  BEGIN
    p_to.ID                    := p_from.ID;
    p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;
    p_to.TAS_ID                := p_from.TAS_ID;
    p_to.TAL_ID                := p_from.TAL_ID;
    p_to.KLE_ID                := p_from.KLE_ID;
    p_to.TAL_TYPE              := p_from.TAL_TYPE;
    p_to.LINE_NUMBER           := p_from.LINE_NUMBER;
    p_to.INSTANCE_NUMBER_IB    := p_from.INSTANCE_NUMBER_IB;
    p_to.OBJECT_ID1_NEW        := p_from.OBJECT_ID1_NEW;
    p_to.OBJECT_ID2_NEW        := p_from.OBJECT_ID2_NEW;
    p_to.JTOT_OBJECT_CODE_NEW  := p_from.JTOT_OBJECT_CODE_NEW;
    p_to.OBJECT_ID1_OLD        := p_from.OBJECT_ID1_OLD;
    p_to.OBJECT_ID2_OLD        := p_from.OBJECT_ID2_OLD;
    p_to.JTOT_OBJECT_CODE_OLD  := p_from.JTOT_OBJECT_CODE_OLD;
    p_to.INVENTORY_ORG_ID      := p_from.INVENTORY_ORG_ID;
    p_to.SERIAL_NUMBER         := p_from.SERIAL_NUMBER;
    p_to.MFG_SERIAL_NUMBER_YN  := p_from.MFG_SERIAL_NUMBER_YN;
    p_to.INVENTORY_ITEM_ID     := p_from.INVENTORY_ITEM_ID;
    p_to.INV_MASTER_ORG_ID     := p_from.INV_MASTER_ORG_ID;
    p_to.ATTRIBUTE_CATEGORY    := p_from.ATTRIBUTE_CATEGORY;
    p_to.ATTRIBUTE1            := p_from.ATTRIBUTE1;
    p_to.ATTRIBUTE2            := p_from.ATTRIBUTE2;
    p_to.ATTRIBUTE3            := p_from.ATTRIBUTE3;
    p_to.ATTRIBUTE4            := p_from.ATTRIBUTE4;
    p_to.ATTRIBUTE5            := p_from.ATTRIBUTE5;
    p_to.ATTRIBUTE6            := p_from.ATTRIBUTE6;
    p_to.ATTRIBUTE7            := p_from.ATTRIBUTE7;
    p_to.ATTRIBUTE8            := p_from.ATTRIBUTE8;
    p_to.ATTRIBUTE9            := p_from.ATTRIBUTE9;
    p_to.ATTRIBUTE10           := p_from.ATTRIBUTE10;
    p_to.ATTRIBUTE11           := p_from.ATTRIBUTE11;
    p_to.ATTRIBUTE12           := p_from.ATTRIBUTE12;
    p_to.ATTRIBUTE13           := p_from.ATTRIBUTE13;
    p_to.ATTRIBUTE14           := p_from.ATTRIBUTE14;
    p_to.ATTRIBUTE15           := p_from.ATTRIBUTE15;
    p_to.CREATED_BY            := p_from.CREATED_BY;
    p_to.CREATION_DATE         := p_from.CREATION_DATE;
    p_to.LAST_UPDATED_BY       := p_from.LAST_UPDATED_BY;
    p_to.LAST_UPDATE_DATE      := p_from.LAST_UPDATE_DATE;
    p_to.LAST_UPDATE_LOGIN     := p_from.LAST_UPDATE_LOGIN;
    p_to.DNZ_CLE_ID            := p_from.DNZ_CLE_ID;
--Bug#2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
    p_to.instance_id              := p_from.instance_id;
    p_to.selected_for_split_flag  := p_from.selected_for_split_flag;
    p_to.asd_id                   := p_from.asd_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN iti_rec_type,
    p_to	OUT NOCOPY itiv_rec_type
  ) IS
  BEGIN
    p_to.ID                    := p_from.ID;
    p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;
    p_to.TAS_ID                := p_from.TAS_ID;
    p_to.TAL_ID                := p_from.TAL_ID;
    p_to.KLE_ID                := p_from.KLE_ID;
    p_to.TAL_TYPE              := p_from.TAL_TYPE;
    p_to.LINE_NUMBER           := p_from.LINE_NUMBER;
    p_to.INSTANCE_NUMBER_IB    := p_from.INSTANCE_NUMBER_IB;
    p_to.OBJECT_ID1_NEW        := p_from.OBJECT_ID1_NEW;
    p_to.OBJECT_ID2_NEW        := p_from.OBJECT_ID2_NEW;
    p_to.JTOT_OBJECT_CODE_NEW  := p_from.JTOT_OBJECT_CODE_NEW;
    p_to.OBJECT_ID1_OLD        := p_from.OBJECT_ID1_OLD;
    p_to.OBJECT_ID2_OLD        := p_from.OBJECT_ID2_OLD;
    p_to.JTOT_OBJECT_CODE_OLD  := p_from.JTOT_OBJECT_CODE_OLD;
    p_to.INVENTORY_ORG_ID               := p_from.INVENTORY_ORG_ID;
    p_to.SERIAL_NUMBER         := p_from.SERIAL_NUMBER;
    p_to.MFG_SERIAL_NUMBER_YN  := p_from.MFG_SERIAL_NUMBER_YN;
    p_to.INVENTORY_ITEM_ID     := p_from.INVENTORY_ITEM_ID;
    p_to.INV_MASTER_ORG_ID     := p_from.INV_MASTER_ORG_ID;
    p_to.ATTRIBUTE_CATEGORY    := p_from.ATTRIBUTE_CATEGORY;
    p_to.ATTRIBUTE1            := p_from.ATTRIBUTE1;
    p_to.ATTRIBUTE2            := p_from.ATTRIBUTE2;
    p_to.ATTRIBUTE3            := p_from.ATTRIBUTE3;
    p_to.ATTRIBUTE4            := p_from.ATTRIBUTE4;
    p_to.ATTRIBUTE5            := p_from.ATTRIBUTE5;
    p_to.ATTRIBUTE6            := p_from.ATTRIBUTE6;
    p_to.ATTRIBUTE7            := p_from.ATTRIBUTE7;
    p_to.ATTRIBUTE8            := p_from.ATTRIBUTE8;
    p_to.ATTRIBUTE9            := p_from.ATTRIBUTE9;
    p_to.ATTRIBUTE10           := p_from.ATTRIBUTE10;
    p_to.ATTRIBUTE11           := p_from.ATTRIBUTE11;
    p_to.ATTRIBUTE12           := p_from.ATTRIBUTE12;
    p_to.ATTRIBUTE13           := p_from.ATTRIBUTE13;
    p_to.ATTRIBUTE14           := p_from.ATTRIBUTE14;
    p_to.ATTRIBUTE15           := p_from.ATTRIBUTE15;
    p_to.CREATED_BY            := p_from.CREATED_BY;
    p_to.CREATION_DATE         := p_from.CREATION_DATE;
    p_to.LAST_UPDATED_BY       := p_from.LAST_UPDATED_BY;
    p_to.LAST_UPDATE_DATE      := p_from.LAST_UPDATE_DATE;
    p_to.LAST_UPDATE_LOGIN     := p_from.LAST_UPDATE_LOGIN;
    p_to.DNZ_CLE_ID            := p_from.DNZ_CLE_ID;
--Bug#2697681 schema change  : 11.5.9 enhacement - split asset by serial numbers
    p_to.instance_id             := p_from.instance_id;
    p_to.selected_for_split_flag := p_from.selected_for_split_flag;
    p_to.asd_id                  := p_from.asd_id;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for: OKL_TXL_ITM_INSTS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_itiv_rec                     itiv_rec_type := p_itiv_rec;
    l_iti_rec                      iti_rec_type;

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
    l_return_status := Validate_Attributes(l_itiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_itiv_rec);
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
  -- PL/SQL TBL validate_row for:ITIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_itiv_tbl.COUNT > 0) THEN
      i := p_itiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_itiv_rec                     => p_itiv_tbl(i));
        EXIT WHEN (i = p_itiv_tbl.LAST);
        i := p_itiv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for: OKL_TXL_ITM_INSTS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iti_rec                      IN iti_rec_type,
    x_iti_rec                      OUT NOCOPY iti_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iti_rec                      iti_rec_type := p_iti_rec;
    l_def_iti_rec                  iti_rec_type;
    -----------------------------------------
    -- Set_Attributes for: OKL_TXL_ITM_INSTS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_iti_rec IN  iti_rec_type,
      x_iti_rec OUT NOCOPY iti_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iti_rec := p_iti_rec;
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
      p_iti_rec,                         -- IN
      l_iti_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_ITM_INSTS(
           ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
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
           DNZ_CLE_ID,
--Bug #2697681 schema change  :11.5.9 Splitting asset by serail numbers
           instance_id,
           selected_for_split_flag,
           asd_id
           )
      VALUES (
           l_iti_rec.ID,
           l_iti_rec.OBJECT_VERSION_NUMBER,
           l_iti_rec.TAS_ID,
           l_iti_rec.TAL_ID,
           l_iti_rec.KLE_ID,
           l_iti_rec.TAL_TYPE,
           l_iti_rec.LINE_NUMBER,
           l_iti_rec.INSTANCE_NUMBER_IB,
           l_iti_rec.OBJECT_ID1_NEW,
           l_iti_rec.OBJECT_ID2_NEW,
           l_iti_rec.JTOT_OBJECT_CODE_NEW,
           l_iti_rec.OBJECT_ID1_OLD,
           l_iti_rec.OBJECT_ID2_OLD,
           l_iti_rec.JTOT_OBJECT_CODE_OLD,
           l_iti_rec.INVENTORY_ORG_ID,
           l_iti_rec.SERIAL_NUMBER,
           l_iti_rec.MFG_SERIAL_NUMBER_YN,
           l_iti_rec.INVENTORY_ITEM_ID,
           l_iti_rec.INV_MASTER_ORG_ID,
           l_iti_rec.ATTRIBUTE_CATEGORY,
           l_iti_rec.ATTRIBUTE1,
           l_iti_rec.ATTRIBUTE2,
           l_iti_rec.ATTRIBUTE3,
           l_iti_rec.ATTRIBUTE4,
           l_iti_rec.ATTRIBUTE5,
           l_iti_rec.ATTRIBUTE6,
           l_iti_rec.ATTRIBUTE7,
           l_iti_rec.ATTRIBUTE8,
           l_iti_rec.ATTRIBUTE9,
           l_iti_rec.ATTRIBUTE10,
           l_iti_rec.ATTRIBUTE11,
           l_iti_rec.ATTRIBUTE12,
           l_iti_rec.ATTRIBUTE13,
           l_iti_rec.ATTRIBUTE14,
           l_iti_rec.ATTRIBUTE15,
           l_iti_rec.CREATED_BY,
           l_iti_rec.CREATION_DATE,
           l_iti_rec.LAST_UPDATED_BY,
           l_iti_rec.LAST_UPDATE_DATE,
           l_iti_rec.LAST_UPDATE_LOGIN,
           l_iti_rec.DNZ_CLE_ID,
--Bug #2697681 schema change  :11.5.9 Splitting asset by serail numbers
           l_iti_rec.instance_id,
           l_iti_rec.selected_for_split_flag,
           l_iti_rec.asd_id);
    -- Set OUT values
    x_iti_rec := l_iti_rec;
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
  -- insert_row for: OKL_TXL_ITM_INSTS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_itiv_rec                     itiv_rec_type;
    l_def_itiv_rec                 itiv_rec_type;
    l_iti_rec                      iti_rec_type;
    lx_iti_rec                     iti_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_itiv_rec	IN itiv_rec_type
    ) RETURN itiv_rec_type IS
      l_itiv_rec	itiv_rec_type := p_itiv_rec;
    BEGIN
      l_itiv_rec.CREATION_DATE := SYSDATE;
      l_itiv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_itiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_itiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_itiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_itiv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for: OKL_TXL_ITM_INSTS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_itiv_rec IN  itiv_rec_type,
      x_itiv_rec OUT NOCOPY itiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_itiv_rec := p_itiv_rec;
      x_itiv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_itiv_rec := null_out_defaults(p_itiv_rec);
    -- Set primary key value
    l_itiv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_itiv_rec,                        -- IN
      l_def_itiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_itiv_rec := fill_who_columns(l_def_itiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_itiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_itiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_itiv_rec, l_iti_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_iti_rec,
      lx_iti_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_iti_rec, l_def_itiv_rec);
    x_itiv_rec := l_def_itiv_rec;
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
  -- PL/SQL TBL insert_row for:ITIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type,
    x_itiv_tbl                     OUT NOCOPY itiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_itiv_tbl.COUNT > 0) THEN
      i := p_itiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_itiv_rec                     => p_itiv_tbl(i),
          x_itiv_rec                     => x_itiv_tbl(i));
        EXIT WHEN (i = p_itiv_tbl.LAST);
        i := p_itiv_tbl.NEXT(i);
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
  -- lock_row for: OKL_TXL_ITM_INSTS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iti_rec                      IN iti_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_iti_rec IN iti_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_ITM_INSTS
     WHERE ID = p_iti_rec.id
       AND OBJECT_VERSION_NUMBER = p_iti_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_iti_rec IN iti_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_ITM_INSTS
    WHERE ID = p_iti_rec.id;
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
      OPEN lock_csr(p_iti_rec);
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
      OPEN lchk_csr(p_iti_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_iti_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_iti_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for: OKL_TXL_ITM_INSTS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iti_rec                      iti_rec_type;
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
    migrate(p_itiv_rec, l_iti_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_iti_rec
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
  -- PL/SQL TBL lock_row for:ITIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_itiv_tbl.COUNT > 0) THEN
      i := p_itiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_itiv_rec                     => p_itiv_tbl(i));
        EXIT WHEN (i = p_itiv_tbl.LAST);
        i := p_itiv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for: OKL_TXL_ITM_INSTS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iti_rec                      IN iti_rec_type,
    x_iti_rec                      OUT NOCOPY iti_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iti_rec                      iti_rec_type := p_iti_rec;
    l_def_iti_rec                  iti_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_iti_rec	IN iti_rec_type,
      x_iti_rec	OUT NOCOPY iti_rec_type
    ) RETURN VARCHAR2 IS
      l_iti_rec                      iti_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iti_rec := p_iti_rec;
      -- Get current database values
      l_iti_rec := get_rec(p_iti_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_iti_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_iti_rec.id := l_iti_rec.id;
      END IF;
      IF (x_iti_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.object_version_number := l_iti_rec.object_version_number;
      END IF;
      IF (x_iti_rec.tas_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.tas_id := l_iti_rec.tas_id;
      END IF;
      IF (x_iti_rec.tal_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.tal_id := l_iti_rec.tal_id;
      END IF;
      IF (x_iti_rec.kle_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.kle_id := l_iti_rec.kle_id;
      END IF;
      IF (x_iti_rec.tal_type = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.tal_type := l_iti_rec.tal_type;
      END IF;
      IF (x_iti_rec.line_number = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.line_number := l_iti_rec.line_number;
      END IF;
      IF (x_iti_rec.instance_number_ib = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.instance_number_ib := l_iti_rec.instance_number_ib;
      END IF;
      IF (x_iti_rec.object_id1_new = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.object_id1_new := l_iti_rec.object_id1_new;
      END IF;
      IF (x_iti_rec.object_id2_new = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.object_id2_new := l_iti_rec.object_id2_new;
      END IF;
      IF (x_iti_rec.jtot_object_code_new = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.jtot_object_code_new := l_iti_rec.jtot_object_code_new;
      END IF;
      IF (x_iti_rec.object_id1_old = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.object_id1_old := l_iti_rec.object_id1_old;
      END IF;
      IF (x_iti_rec.object_id2_old = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.object_id2_old := l_iti_rec.object_id2_old;
      END IF;
      IF (x_iti_rec.jtot_object_code_old = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.jtot_object_code_old := l_iti_rec.jtot_object_code_old;
      END IF;
      IF (x_iti_rec.inventory_org_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.inventory_org_id := l_iti_rec.inventory_org_id;
      END IF;
      IF (x_iti_rec.serial_number = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.serial_number := l_iti_rec.serial_number;
      END IF;
      IF (x_iti_rec.mfg_serial_number_yn = OKC_API.G_MISS_CHAR) THEN
          x_iti_rec.mfg_serial_number_yn := l_iti_rec.mfg_serial_number_yn;
      END IF;
      IF (x_iti_rec.inventory_item_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.inventory_item_id := l_iti_rec.inventory_item_id;
      END IF;
      IF (x_iti_rec.inv_master_org_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.inv_master_org_id := l_iti_rec.inv_master_org_id;
      END IF;
      IF (x_iti_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute_category := l_iti_rec.attribute_category;
      END IF;
      IF (x_iti_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute1 := l_iti_rec.attribute1;
      END IF;
      IF (x_iti_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute2 := l_iti_rec.attribute2;
      END IF;
      IF (x_iti_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute3 := l_iti_rec.attribute3;
      END IF;
      IF (x_iti_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute4 := l_iti_rec.attribute4;
      END IF;
      IF (x_iti_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute5 := l_iti_rec.attribute5;
      END IF;
      IF (x_iti_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute6 := l_iti_rec.attribute6;
      END IF;
      IF (x_iti_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute7 := l_iti_rec.attribute7;
      END IF;
      IF (x_iti_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute8 := l_iti_rec.attribute8;
      END IF;
      IF (x_iti_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute9 := l_iti_rec.attribute9;
      END IF;
      IF (x_iti_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute10 := l_iti_rec.attribute10;
      END IF;
      IF (x_iti_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute11 := l_iti_rec.attribute11;
      END IF;
      IF (x_iti_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute12 := l_iti_rec.attribute12;
      END IF;
      IF (x_iti_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute13 := l_iti_rec.attribute13;
      END IF;
      IF (x_iti_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute14 := l_iti_rec.attribute14;
      END IF;
      IF (x_iti_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.attribute15 := l_iti_rec.attribute15;
      END IF;
      IF (x_iti_rec.created_by = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.created_by := l_iti_rec.created_by;
      END IF;
      IF (x_iti_rec.creation_date = OKC_API.G_MISS_DATE) THEN
         x_iti_rec.creation_date := l_iti_rec.creation_date;
      END IF;
      IF (x_iti_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.last_updated_by := l_iti_rec.last_updated_by;
      END IF;
      IF (x_iti_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
         x_iti_rec.last_update_date := l_iti_rec.last_update_date;
      END IF;
      IF (x_iti_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.last_update_login := l_iti_rec.last_update_login;
      END IF;
      IF (x_iti_rec.dnz_cle_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.dnz_cle_id := l_iti_rec.dnz_cle_id;
      END IF;
--Bug #2697681 schema change  :11.5.9 Splitting asset by serail numbers
      IF (x_iti_rec.instance_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.instance_id := l_iti_rec.instance_id;
      END IF;
      IF (x_iti_rec.selected_for_split_flag = OKC_API.G_MISS_CHAR) THEN
         x_iti_rec.selected_for_split_flag := l_iti_rec.selected_for_split_flag;
      END IF;
      IF (x_iti_rec.asd_id = OKC_API.G_MISS_NUM) THEN
         x_iti_rec.asd_id := l_iti_rec.asd_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXL_ITM_INSTS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_iti_rec IN  iti_rec_type,
      x_iti_rec OUT NOCOPY iti_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iti_rec := p_iti_rec;
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
      p_iti_rec,                         -- IN
      l_iti_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_iti_rec, l_def_iti_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_ITM_INSTS
    SET ID = l_def_iti_rec.ID,
        OBJECT_VERSION_NUMBER  = l_def_iti_rec.OBJECT_VERSION_NUMBER,
        TAS_ID                 = l_def_iti_rec.TAS_ID,
        TAL_ID                 = l_def_iti_rec.TAL_ID,
        KLE_ID                 = l_def_iti_rec.KLE_ID,
        TAL_TYPE               = l_def_iti_rec.TAL_TYPE,
        LINE_NUMBER            = l_def_iti_rec.LINE_NUMBER,
        INSTANCE_NUMBER_IB     = l_def_iti_rec.INSTANCE_NUMBER_IB,
        OBJECT_ID1_NEW         = l_def_iti_rec.OBJECT_ID1_NEW,
        OBJECT_ID2_NEW         = l_def_iti_rec.OBJECT_ID2_NEW,
        JTOT_OBJECT_CODE_NEW   = l_def_iti_rec.JTOT_OBJECT_CODE_NEW,
        OBJECT_ID1_OLD         = l_def_iti_rec.OBJECT_ID1_OLD,
        OBJECT_ID2_OLD         = l_def_iti_rec.OBJECT_ID2_OLD,
        JTOT_OBJECT_CODE_OLD   = l_def_iti_rec.JTOT_OBJECT_CODE_OLD,
        INVENTORY_ORG_ID       = l_def_iti_rec.INVENTORY_ORG_ID,
        SERIAL_NUMBER          = l_def_iti_rec.SERIAL_NUMBER,
        MFG_SERIAL_NUMBER_YN   = l_def_iti_rec.MFG_SERIAL_NUMBER_YN,
        INVENTORY_ITEM_ID      = l_def_iti_rec.INVENTORY_ITEM_ID,
        INV_MASTER_ORG_ID      = l_def_iti_rec.INV_MASTER_ORG_ID,
        ATTRIBUTE_CATEGORY     = l_def_iti_rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1             = l_def_iti_rec.ATTRIBUTE1,
        ATTRIBUTE2             = l_def_iti_rec.ATTRIBUTE2,
        ATTRIBUTE3             = l_def_iti_rec.ATTRIBUTE3,
        ATTRIBUTE4             = l_def_iti_rec.ATTRIBUTE4,
        ATTRIBUTE5             = l_def_iti_rec.ATTRIBUTE5,
        ATTRIBUTE6             = l_def_iti_rec.ATTRIBUTE6,
        ATTRIBUTE7             = l_def_iti_rec.ATTRIBUTE7,
        ATTRIBUTE8             = l_def_iti_rec.ATTRIBUTE8,
        ATTRIBUTE9             = l_def_iti_rec.ATTRIBUTE9,
        ATTRIBUTE10            = l_def_iti_rec.ATTRIBUTE10,
        ATTRIBUTE11            = l_def_iti_rec.ATTRIBUTE11,
        ATTRIBUTE12            = l_def_iti_rec.ATTRIBUTE12,
        ATTRIBUTE13            = l_def_iti_rec.ATTRIBUTE13,
        ATTRIBUTE14            = l_def_iti_rec.ATTRIBUTE14,
        ATTRIBUTE15            = l_def_iti_rec.ATTRIBUTE15,
        CREATED_BY             = l_def_iti_rec.CREATED_BY,
        CREATION_DATE          = l_def_iti_rec.CREATION_DATE,
        LAST_UPDATED_BY        = l_def_iti_rec.LAST_UPDATED_BY,
        LAST_UPDATE_DATE       = l_def_iti_rec.LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN      = l_def_iti_rec.LAST_UPDATE_LOGIN,
        DNZ_CLE_ID             = l_def_iti_rec.DNZ_CLE_ID,
--Bug #2697681 schema change  :11.5.9 Splitting asset by serail numbers
        instance_id             = l_def_iti_rec.instance_id,
        selected_for_split_flag = l_def_iti_rec.selected_for_split_flag,
        asd_id                  = l_def_iti_rec.asd_id
    WHERE ID = l_def_iti_rec.id;
    x_iti_rec := l_def_iti_rec;
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
  -- update_row for:OKL_TXL_ITM_INSTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_itiv_rec                     itiv_rec_type := p_itiv_rec;
    l_def_itiv_rec                 itiv_rec_type;
    l_iti_rec                      iti_rec_type;
    lx_iti_rec                     iti_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_itiv_rec	IN itiv_rec_type
    ) RETURN itiv_rec_type IS
      l_itiv_rec	itiv_rec_type := p_itiv_rec;
    BEGIN
      l_itiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_itiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_itiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_itiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_itiv_rec	IN itiv_rec_type,
      x_itiv_rec	OUT NOCOPY itiv_rec_type
    ) RETURN VARCHAR2 IS
      l_itiv_rec                     itiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_itiv_rec := p_itiv_rec;
      -- Get current database values
      l_itiv_rec := get_rec(p_itiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_itiv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_itiv_rec.id := l_itiv_rec.id;
      END IF;
      IF (x_itiv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.object_version_number := l_itiv_rec.object_version_number;
      END IF;
      IF (x_itiv_rec.tas_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.tas_id := l_itiv_rec.tas_id;
      END IF;
      IF (x_itiv_rec.tal_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.tal_id := l_itiv_rec.tal_id;
      END IF;
      IF (x_itiv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.kle_id := l_itiv_rec.kle_id;
      END IF;
      IF (x_itiv_rec.tal_type = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.tal_type := l_itiv_rec.tal_type;
      END IF;
      IF (x_itiv_rec.line_number = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.line_number := l_itiv_rec.line_number;
      END IF;
      IF (x_itiv_rec.instance_number_ib = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.instance_number_ib := l_itiv_rec.instance_number_ib;
      END IF;
      IF (x_itiv_rec.object_id1_new = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.object_id1_new := l_itiv_rec.object_id1_new;
      END IF;
      IF (x_itiv_rec.object_id2_new = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.object_id2_new := l_itiv_rec.object_id2_new;
      END IF;
      IF (x_itiv_rec.jtot_object_code_new = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.jtot_object_code_new := l_itiv_rec.jtot_object_code_new;
      END IF;
      IF (x_itiv_rec.object_id1_old = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.object_id1_old := l_itiv_rec.object_id1_old;
      END IF;
      IF (x_itiv_rec.object_id2_old = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.object_id2_old := l_itiv_rec.object_id2_old;
      END IF;
      IF (x_itiv_rec.jtot_object_code_old = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.jtot_object_code_old := l_itiv_rec.jtot_object_code_old;
      END IF;
      IF (x_itiv_rec.inventory_org_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.inventory_org_id := l_itiv_rec.inventory_org_id;
      END IF;
      IF (x_itiv_rec.serial_number = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.serial_number := l_itiv_rec.serial_number;
      END IF;
      IF (x_itiv_rec.mfg_serial_number_yn = OKC_API.G_MISS_CHAR) THEN
          x_itiv_rec.mfg_serial_number_yn := l_itiv_rec.mfg_serial_number_yn;
      END IF;
      IF (x_itiv_rec.inventory_item_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.inventory_item_id := l_itiv_rec.inventory_item_id;
      END IF;
      IF (x_itiv_rec.inv_master_org_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.inv_master_org_id := l_itiv_rec.inv_master_org_id;
      END IF;
      IF (x_itiv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute_category := l_itiv_rec.attribute_category;
      END IF;
      IF (x_itiv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute1 := l_itiv_rec.attribute1;
      END IF;
      IF (x_itiv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute2 := l_itiv_rec.attribute2;
      END IF;
      IF (x_itiv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute3 := l_itiv_rec.attribute3;
      END IF;
      IF (x_itiv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute4 := l_itiv_rec.attribute4;
      END IF;
      IF (x_itiv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute5 := l_itiv_rec.attribute5;
      END IF;
      IF (x_itiv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute6 := l_itiv_rec.attribute6;
      END IF;
      IF (x_itiv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute7 := l_itiv_rec.attribute7;
      END IF;
      IF (x_itiv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute8 := l_itiv_rec.attribute8;
      END IF;
      IF (x_itiv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute9 := l_itiv_rec.attribute9;
      END IF;
      IF (x_itiv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute10 := l_itiv_rec.attribute10;
      END IF;
      IF (x_itiv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute11 := l_itiv_rec.attribute11;
      END IF;
      IF (x_itiv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute12 := l_itiv_rec.attribute12;
      END IF;
      IF (x_itiv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute13 := l_itiv_rec.attribute13;
      END IF;
      IF (x_itiv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute14 := l_itiv_rec.attribute14;
      END IF;
      IF (x_itiv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.attribute15 := l_itiv_rec.attribute15;
      END IF;
      IF (x_itiv_rec.created_by = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.created_by := l_itiv_rec.created_by;
      END IF;
      IF (x_itiv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
         x_itiv_rec.creation_date := l_itiv_rec.creation_date;
      END IF;
      IF (x_itiv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.last_updated_by := l_itiv_rec.last_updated_by;
      END IF;
      IF (x_itiv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
         x_itiv_rec.last_update_date := l_itiv_rec.last_update_date;
      END IF;
      IF (x_itiv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.last_update_login := l_itiv_rec.last_update_login;
      END IF;
      IF (x_itiv_rec.dnz_cle_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.dnz_cle_id := l_itiv_rec.dnz_cle_id;
      END IF;
--Bug #2697681 schema change  :11.5.9 Splitting asset by serial numbers
      IF (x_itiv_rec.instance_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.instance_id := l_itiv_rec.instance_id;
      END IF;
      IF (x_itiv_rec.selected_for_split_flag = OKC_API.G_MISS_CHAR) THEN
         x_itiv_rec.selected_for_split_flag := l_itiv_rec.selected_for_split_flag;
      END IF;
      IF (x_itiv_rec.asd_id = OKC_API.G_MISS_NUM) THEN
         x_itiv_rec.asd_id := l_itiv_rec.asd_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXL_ITM_INSTS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_itiv_rec IN  itiv_rec_type,
      x_itiv_rec OUT NOCOPY itiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_itiv_rec := p_itiv_rec;
      x_itiv_rec.OBJECT_VERSION_NUMBER := NVL(x_itiv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_itiv_rec,                        -- IN
      l_itiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_itiv_rec, l_def_itiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_itiv_rec := fill_who_columns(l_def_itiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_itiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_itiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_itiv_rec, l_iti_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_iti_rec,
      lx_iti_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_iti_rec, l_def_itiv_rec);
    x_itiv_rec := l_def_itiv_rec;
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
  -- PL/SQL TBL update_row for:ITIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type,
    x_itiv_tbl                     OUT NOCOPY itiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_itiv_tbl.COUNT > 0) THEN
      i := p_itiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_itiv_rec                     => p_itiv_tbl(i),
          x_itiv_rec                     => x_itiv_tbl(i));
        EXIT WHEN (i = p_itiv_tbl.LAST);
        i := p_itiv_tbl.NEXT(i);
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
  -- delete_row for:OKL_TXL_ITM_INSTS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iti_rec                      IN iti_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iti_rec                      iti_rec_type:= p_iti_rec;
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
    DELETE FROM OKL_TXL_ITM_INSTS
     WHERE ID = l_iti_rec.id;

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
  -- delete_row for:OKL_TXL_ITM_INSTS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_itiv_rec                     itiv_rec_type := p_itiv_rec;
    l_iti_rec                      iti_rec_type;
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
    migrate(l_itiv_rec, l_iti_rec);
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_iti_rec
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
  -- PL/SQL TBL delete_row for:IALV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_tbl                     IN itiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_itiv_tbl.COUNT > 0) THEN
      i := p_itiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_itiv_rec                     => p_itiv_tbl(i));
        EXIT WHEN (i = p_itiv_tbl.LAST);
        i := p_itiv_tbl.NEXT(i);
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
END OKL_ITI_PVT;

/
