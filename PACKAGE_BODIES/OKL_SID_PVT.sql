--------------------------------------------------------
--  DDL for Package Body OKL_SID_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SID_PVT" AS
/* $Header: OKLSSIDB.pls 115.2 2002/11/30 09:24:22 spillaip noship $ */
/************************ HAND-CODED *********************************/
  G_NO_MATCHING_RECORD         CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_TABLE_TOKEN                CONSTANT VARCHAR2(200) := 'OKL_API.G_CHILD_TABLE_TOKEN';
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_RANGE_CHECK                CONSTANT VARCHAR2(200) := 'OKL_GREATER_THAN';
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_FIN_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_MODEL_LINE_LTY_CODE                 OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_ADDON_LINE_LTY_CODE                 OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_ID2                        CONSTANT VARCHAR2(200) := '#';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_EXCEPTION_HALT_VALIDATION            EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
---------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_cle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_id IN  OKC_K_LINES_V.ID%TYPE) IS

    ln_dummy number := 0;
    l_lty_code              OKC_LINE_STYLES_V.LTY_CODE%TYPE;

    CURSOR get_lty_code(p_cle_id IN OKC_K_LINES_V.ID%TYPE) IS
    SELECT lse.lty_code
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.id = p_cle_id
    AND cle.lse_id = lse.id;

    CURSOR c_cle_id_validate1(p_cle_id IN OKC_K_LINES_V.ID%TYPE,
                              p_code IN OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT t1.id
                  FROM okc_line_styles_b t1
                       ,okc_line_styles_b t2
                       ,okc_subclass_top_line t3
                       ,okc_k_lines_b cle
                  WHERE t1.lty_code = p_code
                  AND cle.id = p_cle_id
                  AND cle.lse_id = t1.id
                  AND t2.lty_code = G_FIN_LINE_LTY_CODE
                  AND t1.lse_parent_id = t2.id
                  AND t3.lse_id = t2.id
                  AND t3.scs_code = 'LEASE');

    CURSOR c_cle_id_validate2(p_cle_id IN OKC_K_LINES_V.ID%TYPE,
                              p_code IN OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                              p_code2 IN OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT t1.id
                  FROM okc_line_styles_b t1
                       ,okc_line_styles_b t2
                       ,okc_line_styles_b t3
                       ,okc_subclass_top_line t4
                       ,okc_k_lines_b cle
                  WHERE t1.lty_code = p_code
                  AND cle.id = p_cle_id
                  AND cle.lse_id = t1.id
                  AND t2.lty_code = p_code2
                  AND t1.lse_parent_id = t2.id
                  AND t2.lse_parent_id = t3.id
                  AND t3.lty_code = G_FIN_LINE_LTY_CODE
                  AND t4.lse_id = t3.id
                  AND t4.scs_code = 'LEASE');


  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_id = OKL_API.G_MISS_NUM) OR
       (p_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN get_lty_code(p_id);
    IF get_lty_code%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH get_lty_code into l_lty_code;
    CLOSE get_lty_code;

    IF l_lty_code = G_MODEL_LINE_LTY_CODE THEN
      OPEN  c_cle_id_validate1(p_id,
                               l_lty_code);
      IF c_cle_id_validate1%NOTFOUND THEN
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      FETCH c_cle_id_validate1 into ln_dummy;
      CLOSE c_cle_id_validate1;
      IF (ln_dummy = 0) then
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSIF l_lty_code = G_ADDON_LINE_LTY_CODE THEN
      OPEN  c_cle_id_validate2(p_id,
                               l_lty_code,
                               G_MODEL_LINE_LTY_CODE);
      IF c_cle_id_validate2%NOTFOUND THEN
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      FETCH c_cle_id_validate2 into ln_dummy;
      CLOSE c_cle_id_validate2;
      IF (ln_dummy = 0) then
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'cle_id');
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'cle_id');
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_cle_id_validate1%ISOPEN THEN
       CLOSE c_cle_id_validate1;
    END IF;
    IF c_cle_id_validate2%ISOPEN THEN
       CLOSE c_cle_id_validate2;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_cle_id_validate1%ISOPEN THEN
       CLOSE c_cle_id_validate1;
    END IF;
    IF c_cle_id_validate2%ISOPEN THEN
       CLOSE c_cle_id_validate2;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_cle_id;
---------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_fa_cle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_fa_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                               p_id IN  OKC_K_LINES_V.ID%TYPE) IS

    ln_dummy number := 0;
    l_lty_code              OKC_LINE_STYLES_V.LTY_CODE%TYPE;

    CURSOR get_lty_code(p_cle_id IN OKC_K_LINES_V.ID%TYPE) IS
    SELECT lse.lty_code
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.id = p_cle_id
    AND cle.lse_id = lse.id;

    CURSOR c_cle_id_validate1(p_cle_id IN OKC_K_LINES_V.ID%TYPE,
                              p_code IN OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT t1.id
                  FROM okc_line_styles_b t1
                       ,okc_line_styles_b t2
                       ,okc_subclass_top_line t3
                       ,okc_k_lines_b cle
                  WHERE t1.lty_code = p_code
                  AND cle.id = p_cle_id
                  AND cle.lse_id = t1.id
                  AND t2.lty_code = G_FIN_LINE_LTY_CODE
                  AND t1.lse_parent_id = t2.id
                  AND t3.lse_id = t2.id
                  AND t3.scs_code = 'LEASE');


  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_id = OKL_API.G_MISS_NUM) OR
       (p_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    OPEN get_lty_code(p_id);
    IF get_lty_code%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH get_lty_code into l_lty_code;
    CLOSE get_lty_code;

    IF l_lty_code = G_FA_LINE_LTY_CODE THEN
      OPEN  c_cle_id_validate1(p_id,
                               l_lty_code);
      IF c_cle_id_validate1%NOTFOUND THEN
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      FETCH c_cle_id_validate1 into ln_dummy;
      CLOSE c_cle_id_validate1;
      IF (ln_dummy = 0) then
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'fa_cle_id');
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_cle_id_validate1%ISOPEN THEN
       CLOSE c_cle_id_validate1;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_cle_id_validate1%ISOPEN THEN
       CLOSE c_cle_id_validate1;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_fa_cle_id;
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_shipping_id1
-- Description          : FK validation with OKX_CUST_SITES_USES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_shipping_id1(x_return_status OUT NOCOPY VARCHAR2,
                                  p_shipping_id1 IN OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID1%TYPE) IS

    ln_dummy number := 0;
    CURSOR c_shipping_id1_validate(p_shipping_id1 OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID1%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_CUST_SITE_USES_V
                  WHERE id1 = p_shipping_id1
                  AND id2 = G_ID2
                  AND site_use_code = 'SHIP_TO');
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_shipping_id1 = OKL_API.G_MISS_NUM) OR
       (p_shipping_id1 IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Validation
    OPEN  c_shipping_id1_validate(p_shipping_id1);
    -- If the cursor is open then it has to be closed
    IF c_shipping_id1_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_shipping_id1_validate into ln_dummy;
    CLOSE c_shipping_id1_validate;
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
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'shipping_address_id1');
    -- If the cursor is open then it has to be closed
    IF c_shipping_id1_validate%ISOPEN THEN
       CLOSE c_shipping_id1_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_shipping_id1_validate%ISOPEN THEN
       CLOSE c_shipping_id1_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_shipping_id1;
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_shipping_id2
-- Description          : FK validation with OKX_CUST_SITE_USES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_shipping_id2(x_return_status OUT NOCOPY VARCHAR2,
                                  p_shipping_id1 IN OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID1%TYPE,
                                  p_shipping_id2 IN OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID2%TYPE) IS

    ln_dummy number := 0;
    CURSOR c_shipping_id2_validate(p_shipping_id1 OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID1%TYPE,
                                   p_shipping_id2 OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_ID2%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_CUST_SITE_USES_V
                  WHERE id1 = p_shipping_id1
                  AND id2 = p_shipping_id2
                  AND site_use_code = 'SHIP_TO');
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_shipping_id2 = OKL_API.G_MISS_CHAR) OR
       (p_shipping_id2 IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Validation
    OPEN  c_shipping_id2_validate(p_shipping_id1,
                                  p_shipping_id2);
    -- If the cursor is open then it has to be closed
    IF c_shipping_id2_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_shipping_id2_validate into ln_dummy;
    CLOSE c_shipping_id2_validate;
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
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'shipping_address_id2');
    -- If the cursor is open then it has to be closed
    IF c_shipping_id2_validate%ISOPEN THEN
       CLOSE c_shipping_id2_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_shipping_id2_validate%ISOPEN THEN
       CLOSE c_shipping_id2_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_shipping_id2;
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_shipping_code
-- Description          : FK validation with JTF_OBJECT_CODE
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_shipping_code(x_return_status OUT NOCOPY VARCHAR2,
                                   p_shipping_code IN OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_CODE%TYPE) IS

    ln_dummy number := 0;
    CURSOR c_shipping_code_validate(p_shipping_code OKL_SUPP_INVOICE_DTLS_V.SHIPPING_ADDRESS_CODE%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM JTF_OBJECTS_B
                  WHERE object_code = p_shipping_code);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_shipping_code = OKL_API.G_MISS_CHAR) OR
       (p_shipping_code IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Validation
    OPEN  c_shipping_code_validate(p_shipping_code);
    -- If the cursor is open then it has to be closed
    IF c_shipping_code_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_shipping_code_validate into ln_dummy;
    CLOSE c_shipping_code_validate;
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
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'shipping_address_code');
    -- If the cursor is open then it has to be closed
    IF c_shipping_code_validate%ISOPEN THEN
       CLOSE c_shipping_code_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_shipping_code_validate%ISOPEN THEN
       CLOSE c_shipping_code_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_shipping_code;
--------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_inv_due_date
-- Description          : Tuple record validation of date_invoiced,date_due
-- Business Rules       : date_invoiced Should be greater than equal to date_due
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_inv_due_date(x_return_status OUT NOCOPY VARCHAR2,
                              p_sidv_rec IN sidv_rec_type) IS
    ln_dummy number := 0;
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_sidv_rec.date_invoiced = OKL_API.G_MISS_DATE OR
       p_sidv_rec.date_invoiced IS NULL) OR
       (p_sidv_rec.date_due = OKL_API.G_MISS_DATE OR
       p_sidv_rec.date_due IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- When all the dates are given
    IF (p_sidv_rec.date_invoiced IS NOT NULL OR
        p_sidv_rec.date_invoiced <> OKL_API.G_MISS_DATE) AND
       (p_sidv_rec.date_due IS NOT NULL OR
       p_sidv_rec.date_due <> OKL_API.G_MISS_DATE) THEN
       IF(p_sidv_rec.date_invoiced > p_sidv_rec.date_due) THEN
         -- halt validation as the above statments are true
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the fields is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause validation falied
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_RANGE_CHECK,
                        p_token1       => G_COL_NAME_TOKEN1,
                        p_token1_value => 'date_invoiced',
                        p_token2       => G_COL_NAME_TOKEN2,
                        p_token2_value => 'date_due');
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_inv_due_date;
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
  -- FUNCTION get_rec for: OKL_SUPP_INVOICE_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_sidv_rec       IN sidv_rec_type,
                    x_no_data_found  OUT NOCOPY BOOLEAN)
    RETURN sidv_rec_type IS
    CURSOR okl_supp_invoice_dtls_v_pk_csr(p_id IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           CLE_ID,
           FA_CLE_ID,
           INVOICE_NUMBER,
           DATE_INVOICED,
           DATE_DUE,
           SHIPPING_ADDRESS_ID1,
           SHIPPING_ADDRESS_ID2,
           SHIPPING_ADDRESS_CODE,
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
           LAST_UPDATE_LOGIN
      FROM Okl_Supp_Invoice_Dtls_V
      WHERE okl_supp_invoice_dtls_V.id = p_id;
    l_okl_supp_invoice_dtls_v_pk   okl_supp_invoice_dtls_v_pk_csr%ROWTYPE;
    l_sidv_rec                     sidv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_supp_invoice_dtls_v_pk_csr (p_sidv_rec.id);
    FETCH okl_supp_invoice_dtls_v_pk_csr INTO
              l_sidv_rec.id,
              l_sidv_rec.object_version_number,
              l_sidv_rec.cle_id,
              l_sidv_rec.fa_cle_id,
              l_sidv_rec.invoice_number,
              l_sidv_rec.date_invoiced,
              l_sidv_rec.date_due,
              l_sidv_rec.shipping_address_id1,
              l_sidv_rec.shipping_address_id2,
              l_sidv_rec.shipping_address_code,
              l_sidv_rec.attribute_category,
              l_sidv_rec.attribute1,
              l_sidv_rec.attribute2,
              l_sidv_rec.attribute3,
              l_sidv_rec.attribute4,
              l_sidv_rec.attribute5,
              l_sidv_rec.attribute6,
              l_sidv_rec.attribute7,
              l_sidv_rec.attribute8,
              l_sidv_rec.attribute9,
              l_sidv_rec.attribute10,
              l_sidv_rec.attribute11,
              l_sidv_rec.attribute12,
              l_sidv_rec.attribute13,
              l_sidv_rec.attribute14,
              l_sidv_rec.attribute15,
              l_sidv_rec.created_by,
              l_sidv_rec.creation_date,
              l_sidv_rec.last_updated_by,
              l_sidv_rec.last_update_date,
              l_sidv_rec.last_update_login;
    x_no_data_found := okl_supp_invoice_dtls_v_pk_csr%NOTFOUND;
    CLOSE okl_supp_invoice_dtls_v_pk_csr;
    RETURN(l_sidv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sidv_rec                     IN sidv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sidv_rec_type IS
    l_sidv_rec                     sidv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    l_sidv_rec := get_rec(p_sidv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
    RETURN(l_sidv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sidv_rec                     IN sidv_rec_type
  ) RETURN sidv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sidv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SUPP_INVOICE_DTLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sid_rec                      IN sid_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sid_rec_type IS
    CURSOR okl_supp_invoice_dtls_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CLE_ID,
            FA_CLE_ID,
            INVOICE_NUMBER,
            DATE_INVOICED,
            DATE_DUE,
            SHIPPING_ADDRESS_ID1,
            SHIPPING_ADDRESS_ID2,
            SHIPPING_ADDRESS_CODE,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Supp_Invoice_Dtls
     WHERE okl_supp_invoice_dtls.id = p_id;
    l_okl_supp_invoice_dtls_pk     okl_supp_invoice_dtls_pk_csr%ROWTYPE;
    l_sid_rec                      sid_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_supp_invoice_dtls_pk_csr (p_sid_rec.id);
    FETCH okl_supp_invoice_dtls_pk_csr INTO
              l_sid_rec.id,
              l_sid_rec.object_version_number,
              l_sid_rec.cle_id,
              l_sid_rec.fa_cle_id,
              l_sid_rec.invoice_number,
              l_sid_rec.date_invoiced,
              l_sid_rec.date_due,
              l_sid_rec.shipping_address_id1,
              l_sid_rec.shipping_address_id2,
              l_sid_rec.shipping_address_code,
              l_sid_rec.attribute_category,
              l_sid_rec.attribute1,
              l_sid_rec.attribute2,
              l_sid_rec.attribute3,
              l_sid_rec.attribute4,
              l_sid_rec.attribute5,
              l_sid_rec.attribute6,
              l_sid_rec.attribute7,
              l_sid_rec.attribute8,
              l_sid_rec.attribute9,
              l_sid_rec.attribute10,
              l_sid_rec.attribute11,
              l_sid_rec.attribute12,
              l_sid_rec.attribute13,
              l_sid_rec.attribute14,
              l_sid_rec.attribute15,
              l_sid_rec.created_by,
              l_sid_rec.creation_date,
              l_sid_rec.last_updated_by,
              l_sid_rec.last_update_date,
              l_sid_rec.last_update_login;
    x_no_data_found := okl_supp_invoice_dtls_pk_csr%NOTFOUND;
    CLOSE okl_supp_invoice_dtls_pk_csr;
    RETURN(l_sid_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sid_rec                      IN sid_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sid_rec_type IS
    l_sid_rec                      sid_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_sid_rec := get_rec(p_sid_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
    RETURN(l_sid_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sid_rec                      IN sid_rec_type
  ) RETURN sid_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sid_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SUPP_INVOICE_DTLS_H
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_sidh_rec      IN okl_sidh_rec_type,
                    x_no_data_found OUT NOCOPY BOOLEAN)
  RETURN okl_sidh_rec_type IS
  CURSOR okl_supp_invoice_dtls_h_pk_csr(p_id IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           MAJOR_VERSION,
           CLE_ID,
           FA_CLE_ID,
           INVOICE_NUMBER,
           DATE_INVOICED,
           DATE_DUE,
           SHIPPING_ADDRESS_ID1,
           SHIPPING_ADDRESS_ID2,
           SHIPPING_ADDRESS_CODE,
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
           LAST_UPDATE_LOGIN
      FROM Okl_Supp_Invoice_Dtls_h
     WHERE okl_supp_invoice_dtls_h.id = p_id;
     l_okl_supp_invoice_dtls_h_pk  okl_supp_invoice_dtls_h_pk_csr%ROWTYPE;
     l_okl_sidh_rec                okl_sidh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_supp_invoice_dtls_h_pk_csr(p_sidh_rec.id);
    FETCH okl_supp_invoice_dtls_h_pk_csr INTO
        l_okl_sidh_rec.ID,
        l_okl_sidh_rec.OBJECT_VERSION_NUMBER,
        l_okl_sidh_rec.MAJOR_VERSION,
        l_okl_sidh_rec.CLE_ID,
        l_okl_sidh_rec.FA_CLE_ID,
        l_okl_sidh_rec.INVOICE_NUMBER,
        l_okl_sidh_rec.DATE_INVOICED,
        l_okl_sidh_rec.DATE_DUE,
        l_okl_sidh_rec.SHIPPING_ADDRESS_ID1,
        l_okl_sidh_rec.SHIPPING_ADDRESS_ID2,
        l_okl_sidh_rec.SHIPPING_ADDRESS_CODE,
        l_okl_sidh_rec.ATTRIBUTE_CATEGORY,
        l_okl_sidh_rec.ATTRIBUTE1,
        l_okl_sidh_rec.ATTRIBUTE2,
        l_okl_sidh_rec.ATTRIBUTE3,
        l_okl_sidh_rec.ATTRIBUTE4,
        l_okl_sidh_rec.ATTRIBUTE5,
        l_okl_sidh_rec.ATTRIBUTE6,
        l_okl_sidh_rec.ATTRIBUTE7,
        l_okl_sidh_rec.ATTRIBUTE8,
        l_okl_sidh_rec.ATTRIBUTE9,
        l_okl_sidh_rec.ATTRIBUTE10,
        l_okl_sidh_rec.ATTRIBUTE11,
        l_okl_sidh_rec.ATTRIBUTE12,
        l_okl_sidh_rec.ATTRIBUTE13,
        l_okl_sidh_rec.ATTRIBUTE14,
        l_okl_sidh_rec.ATTRIBUTE15,
        l_okl_sidh_rec.CREATED_BY,
        l_okl_sidh_rec.CREATION_DATE,
        l_okl_sidh_rec.LAST_UPDATED_BY,
        l_okl_sidh_rec.LAST_UPDATE_DATE,
        l_okl_sidh_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_supp_invoice_dtls_h_pk_csr%NOTFOUND;
    CLOSE okl_supp_invoice_dtls_h_pk_csr;
    RETURN(l_okl_sidh_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sidh_rec                     IN okl_sidh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_sidh_rec_type IS
    l_sidh_rec                      okl_sidh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_sidh_rec := get_rec(p_sidh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
    RETURN(l_sidh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sidh_rec                      IN okl_sidh_rec_type
  ) RETURN okl_sidh_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sidh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SUPP_INVOICE_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sidv_rec   IN sidv_rec_type
  ) RETURN sidv_rec_type IS
    l_sidv_rec                     sidv_rec_type := p_sidv_rec;
  BEGIN
    IF (l_sidv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.id := NULL;
    END IF;
    IF (l_sidv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.object_version_number := NULL;
    END IF;
    IF (l_sidv_rec.cle_id = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.cle_id := NULL;
    END IF;
    IF (l_sidv_rec.fa_cle_id = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.fa_cle_id := NULL;
    END IF;
    IF (l_sidv_rec.invoice_number = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.invoice_number := NULL;
    END IF;
    IF (l_sidv_rec.date_invoiced = OKL_API.G_MISS_DATE ) THEN
      l_sidv_rec.date_invoiced := NULL;
    END IF;
    IF (l_sidv_rec.date_due = OKL_API.G_MISS_DATE ) THEN
      l_sidv_rec.date_due := NULL;
    END IF;
    IF (l_sidv_rec.shipping_address_id1 = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.shipping_address_id1 := NULL;
    END IF;
    IF (l_sidv_rec.shipping_address_id2 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.shipping_address_id2 := NULL;
    END IF;
    IF (l_sidv_rec.shipping_address_code = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.shipping_address_code := NULL;
    END IF;
    IF (l_sidv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute_category := NULL;
    END IF;
    IF (l_sidv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute1 := NULL;
    END IF;
    IF (l_sidv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute2 := NULL;
    END IF;
    IF (l_sidv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute3 := NULL;
    END IF;
    IF (l_sidv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute4 := NULL;
    END IF;
    IF (l_sidv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute5 := NULL;
    END IF;
    IF (l_sidv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute6 := NULL;
    END IF;
    IF (l_sidv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute7 := NULL;
    END IF;
    IF (l_sidv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute8 := NULL;
    END IF;
    IF (l_sidv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute9 := NULL;
    END IF;
    IF (l_sidv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute10 := NULL;
    END IF;
    IF (l_sidv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute11 := NULL;
    END IF;
    IF (l_sidv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute12 := NULL;
    END IF;
    IF (l_sidv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute13 := NULL;
    END IF;
    IF (l_sidv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute14 := NULL;
    END IF;
    IF (l_sidv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_sidv_rec.attribute15 := NULL;
    END IF;
    IF (l_sidv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.created_by := NULL;
    END IF;
    IF (l_sidv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_sidv_rec.creation_date := NULL;
    END IF;
    IF (l_sidv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sidv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_sidv_rec.last_update_date := NULL;
    END IF;
    IF (l_sidv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_sidv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sidv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKL_SUPP_INVOICE_DTLS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sidv_rec                     IN sidv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    OKC_UTIL.ADD_VIEW('OKL_SUPP_INVOICE_DTLS_V', x_return_status);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF p_sidv_rec.id = OKL_API.G_MISS_NUM OR
       p_sidv_rec.id IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_sidv_rec.object_version_number = OKL_API.G_MISS_NUM OR
          p_sidv_rec.object_version_number IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
--*****************************Hand code *******************--
    validate_cle_id(x_return_status, p_sidv_rec.cle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_fa_cle_id(x_return_status, p_sidv_rec.fa_cle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_shipping_id1(x_return_status, p_sidv_rec.shipping_address_id1);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_shipping_id2(x_return_status,p_sidv_rec.shipping_address_id1, p_sidv_rec.shipping_address_id2);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_shipping_code(x_return_status, p_sidv_rec.shipping_address_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
--*****************************Hand code *******************--
    RETURN(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate Record for:OKL_SUPP_INVOICE_DTLS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (p_sidv_rec IN sidv_rec_type)
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
--*****************************Hand code *******************--
    validate_inv_due_date(x_return_status, p_sidv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--*****************************Hand code *******************--
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN sidv_rec_type,
    p_to   IN OUT NOCOPY sid_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cle_id := p_from.cle_id;
    p_to.fa_cle_id := p_from.fa_cle_id;
    p_to.invoice_number := p_from.invoice_number;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.date_due := p_from.date_due;
    p_to.shipping_address_id1 := p_from.shipping_address_id1;
    p_to.shipping_address_id2 := p_from.shipping_address_id2;
    p_to.shipping_address_code := p_from.shipping_address_code;
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
  END migrate;

  PROCEDURE migrate (
    p_from IN sid_rec_type,
    p_to   IN OUT NOCOPY sidv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cle_id := p_from.cle_id;
    p_to.fa_cle_id := p_from.fa_cle_id;
    p_to.invoice_number := p_from.invoice_number;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.date_due := p_from.date_due;
    p_to.shipping_address_id1 := p_from.shipping_address_id1;
    p_to.shipping_address_id2 := p_from.shipping_address_id2;
    p_to.shipping_address_code := p_from.shipping_address_code;
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
  END migrate;

  PROCEDURE migrate (
    p_from	IN sid_rec_type,
    p_to	IN OUT NOCOPY okl_sidh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.cle_id := p_from.cle_id;
    p_to.fa_cle_id := p_from.fa_cle_id;
    p_to.invoice_number := p_from.invoice_number;
    p_to.date_invoiced := p_from.date_invoiced;
    p_to.date_due := p_from.date_due;
    p_to.shipping_address_id1 := p_from.shipping_address_id1;
    p_to.shipping_address_id2 := p_from.shipping_address_id2;
    p_to.shipping_address_code := p_from.shipping_address_code;
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
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKL_SUPP_INVOICE_DTLS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sidv_rec                     sidv_rec_type := p_sidv_rec;
    l_sid_rec                      sid_rec_type;
    l_sid_rec                      sid_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_sidv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sidv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SUPP_INVOICE_DTLS_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sidv_tbl.COUNT > 0) THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_sidv_rec                     => p_sidv_tbl(i));
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  --------------------------------------------------
  -- insert_row for: OKL_SUPP_INVOICE_DTLS_H --
  --------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidh_rec                     IN okl_sidh_rec_type,
    x_sidh_rec                     OUT NOCOPY okl_sidh_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sidh_rec                    okl_sidh_rec_type := p_sidh_rec;
    l_def_sidh_rec                okl_sidh_rec_type;
    --------------------------------------------------
    -- Set_Attributes for: OKL_SUPP_INVOICE_DTLS_H ---
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_sidh_rec IN  okl_sidh_rec_type,
      x_sidh_rec OUT NOCOPY okl_sidh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sidh_rec := p_sidh_rec;
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
      p_sidh_rec,             -- IN
      l_sidh_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SUPP_INVOICE_DTLS_H(
      id,
      object_version_number,
      major_version,
      cle_id,
      fa_cle_id,
      invoice_number,
      date_invoiced,
      date_due,
      shipping_address_id1,
      shipping_address_id2,
      shipping_address_code,
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
      last_update_login)
    VALUES (
      l_sidh_rec.id,
      l_sidh_rec.object_version_number,
      l_sidh_rec.major_version,
      l_sidh_rec.cle_id,
      l_sidh_rec.fa_cle_id,
      l_sidh_rec.invoice_number,
      l_sidh_rec.date_invoiced,
      l_sidh_rec.date_due,
      l_sidh_rec.shipping_address_id1,
      l_sidh_rec.shipping_address_id2,
      l_sidh_rec.shipping_address_code,
      l_sidh_rec.attribute_category,
      l_sidh_rec.attribute1,
      l_sidh_rec.attribute2,
      l_sidh_rec.attribute3,
      l_sidh_rec.attribute4,
      l_sidh_rec.attribute5,
      l_sidh_rec.attribute6,
      l_sidh_rec.attribute7,
      l_sidh_rec.attribute8,
      l_sidh_rec.attribute9,
      l_sidh_rec.attribute10,
      l_sidh_rec.attribute11,
      l_sidh_rec.attribute12,
      l_sidh_rec.attribute13,
      l_sidh_rec.attribute14,
      l_sidh_rec.attribute15,
      l_sidh_rec.created_by,
      l_sidh_rec.creation_date,
      l_sidh_rec.last_updated_by,
      l_sidh_rec.last_update_date,
      l_sidh_rec.last_update_login);
    -- Set OUT values
    x_sidh_rec := l_sidh_rec;
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
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- insert_row for:OKL_SUPP_INVOICE_DTLS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sid_rec                      IN sid_rec_type,
    x_sid_rec                      OUT NOCOPY sid_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sid_rec                      sid_rec_type := p_sid_rec;
    l_def_sid_rec                  sid_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_SUPP_INVOICE_DTLS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sid_rec IN sid_rec_type,
      x_sid_rec OUT NOCOPY sid_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sid_rec := p_sid_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_sid_rec,                         -- IN
      l_sid_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SUPP_INVOICE_DTLS(
      id,
      object_version_number,
      cle_id,
      fa_cle_id,
      invoice_number,
      date_invoiced,
      date_due,
      shipping_address_id1,
      shipping_address_id2,
      shipping_address_code,
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
      last_update_login)
    VALUES (
      l_sid_rec.id,
      l_sid_rec.object_version_number,
      l_sid_rec.cle_id,
      l_sid_rec.fa_cle_id,
      l_sid_rec.invoice_number,
      l_sid_rec.date_invoiced,
      l_sid_rec.date_due,
      l_sid_rec.shipping_address_id1,
      l_sid_rec.shipping_address_id2,
      l_sid_rec.shipping_address_code,
      l_sid_rec.attribute_category,
      l_sid_rec.attribute1,
      l_sid_rec.attribute2,
      l_sid_rec.attribute3,
      l_sid_rec.attribute4,
      l_sid_rec.attribute5,
      l_sid_rec.attribute6,
      l_sid_rec.attribute7,
      l_sid_rec.attribute8,
      l_sid_rec.attribute9,
      l_sid_rec.attribute10,
      l_sid_rec.attribute11,
      l_sid_rec.attribute12,
      l_sid_rec.attribute13,
      l_sid_rec.attribute14,
      l_sid_rec.attribute15,
      l_sid_rec.created_by,
      l_sid_rec.creation_date,
      l_sid_rec.last_updated_by,
      l_sid_rec.last_update_date,
      l_sid_rec.last_update_login);
    -- Set OUT values
    x_sid_rec := l_sid_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------------
  -- insert_row for :OKL_SUPP_INVOICE_DTLS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type,
    x_sidv_rec                     OUT NOCOPY sidv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sidv_rec                     sidv_rec_type := p_sidv_rec;
    l_def_sidv_rec                 sidv_rec_type;
    l_sid_rec                      sid_rec_type;
    lx_sid_rec                     sid_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sidv_rec IN sidv_rec_type
    ) RETURN sidv_rec_type IS
      l_sidv_rec sidv_rec_type := p_sidv_rec;
    BEGIN
      l_sidv_rec.CREATION_DATE := SYSDATE;
      l_sidv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sidv_rec.LAST_UPDATE_DATE := l_sidv_rec.CREATION_DATE;
      l_sidv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sidv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sidv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_SUPP_INVOICE_DTLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sidv_rec IN sidv_rec_type,
      x_sidv_rec OUT NOCOPY sidv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sidv_rec := p_sidv_rec;
      x_sidv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_sidv_rec := null_out_defaults(p_sidv_rec);
    -- Set primary key value
    l_sidv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_sidv_rec,                        -- IN
      l_def_sidv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sidv_rec := fill_who_columns(l_def_sidv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sidv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sidv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sidv_rec, l_sid_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sid_rec,
      lx_sid_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sid_rec, l_def_sidv_rec);
    -- Set OUT values
    x_sidv_rec := l_def_sidv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:SIDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sidv_tbl.COUNT > 0) THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_sidv_rec                     => p_sidv_tbl(i),
            x_sidv_rec                     => x_sidv_tbl(i));
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------
  -- lock_row for:OKL_SUPP_INVOICE_DTLS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sid_rec                      IN sid_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sid_rec IN sid_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SUPP_INVOICE_DTLS
     WHERE ID = p_sid_rec.id
       AND OBJECT_VERSION_NUMBER = p_sid_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_sid_rec IN sid_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SUPP_INVOICE_DTLS
     WHERE ID = p_sid_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_SUPP_INVOICE_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_SUPP_INVOICE_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_sid_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_sid_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sid_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sid_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -------------------------------------------
  -- lock_row for: OKL_SUPP_INVOICE_DTLS_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sid_rec                      sid_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_sidv_rec, l_sid_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sid_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:SIDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sidv_tbl.COUNT > 0) THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_sidv_rec                     => p_sidv_tbl(i));

        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- update_row for:OKL_SUPP_INVOICE_DTLS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sid_rec                      IN sid_rec_type,
    x_sid_rec                      OUT NOCOPY sid_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sid_rec                      sid_rec_type := p_sid_rec;
    l_def_sid_rec                  sid_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_sidh_rec                     okl_sidh_rec_type;
    lx_sidh_rec                    okl_sidh_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sid_rec IN sid_rec_type,
      x_sid_rec OUT NOCOPY sid_rec_type
    ) RETURN VARCHAR2 IS
      l_sid_rec                      sid_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sid_rec := p_sid_rec;
      -- Get current database values
      l_sid_rec := get_rec(p_sid_rec, l_return_status);
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
      migrate(l_sid_rec, l_sidh_rec);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_sid_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.id := l_sid_rec.id;
        END IF;
        IF (x_sid_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.object_version_number := l_sid_rec.object_version_number;
        END IF;
        IF (x_sid_rec.cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.cle_id := l_sid_rec.cle_id;
        END IF;
        IF (x_sid_rec.fa_cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.fa_cle_id := l_sid_rec.fa_cle_id;
        END IF;
        IF (x_sid_rec.invoice_number = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.invoice_number := l_sid_rec.invoice_number;
        END IF;
        IF (x_sid_rec.date_invoiced = OKL_API.G_MISS_DATE)
        THEN
          x_sid_rec.date_invoiced := l_sid_rec.date_invoiced;
        END IF;
        IF (x_sid_rec.date_due = OKL_API.G_MISS_DATE)
        THEN
          x_sid_rec.date_due := l_sid_rec.date_due;
        END IF;
        IF (x_sid_rec.shipping_address_id1 = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.shipping_address_id1 := l_sid_rec.shipping_address_id1;
        END IF;
        IF (x_sid_rec.shipping_address_id2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.shipping_address_id2 := l_sid_rec.shipping_address_id2;
        END IF;
        IF (x_sid_rec.shipping_address_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.shipping_address_code := l_sid_rec.shipping_address_code;
        END IF;
        IF (x_sid_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute_category := l_sid_rec.attribute_category;
        END IF;
        IF (x_sid_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute1 := l_sid_rec.attribute1;
        END IF;
        IF (x_sid_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute2 := l_sid_rec.attribute2;
        END IF;
        IF (x_sid_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute3 := l_sid_rec.attribute3;
        END IF;
        IF (x_sid_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute4 := l_sid_rec.attribute4;
        END IF;
        IF (x_sid_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute5 := l_sid_rec.attribute5;
        END IF;
        IF (x_sid_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute6 := l_sid_rec.attribute6;
        END IF;
        IF (x_sid_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute7 := l_sid_rec.attribute7;
        END IF;
        IF (x_sid_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute8 := l_sid_rec.attribute8;
        END IF;
        IF (x_sid_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute9 := l_sid_rec.attribute9;
        END IF;
        IF (x_sid_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute10 := l_sid_rec.attribute10;
        END IF;
        IF (x_sid_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute11 := l_sid_rec.attribute11;
        END IF;
        IF (x_sid_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute12 := l_sid_rec.attribute12;
        END IF;
        IF (x_sid_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute13 := l_sid_rec.attribute13;
        END IF;
        IF (x_sid_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute14 := l_sid_rec.attribute14;
        END IF;
        IF (x_sid_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_sid_rec.attribute15 := l_sid_rec.attribute15;
        END IF;
        IF (x_sid_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.created_by := l_sid_rec.created_by;
        END IF;
        IF (x_sid_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_sid_rec.creation_date := l_sid_rec.creation_date;
        END IF;
        IF (x_sid_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.last_updated_by := l_sid_rec.last_updated_by;
        END IF;
        IF (x_sid_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sid_rec.last_update_date := l_sid_rec.last_update_date;
        END IF;
        IF (x_sid_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_sid_rec.last_update_login := l_sid_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_SUPP_INVOICE_DTLS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sid_rec IN sid_rec_type,
      x_sid_rec OUT NOCOPY sid_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sid_rec := p_sid_rec;
      x_sid_rec.OBJECT_VERSION_NUMBER := p_sid_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sid_rec,                         -- IN
      l_sid_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sid_rec, l_def_sid_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_SUPP_INVOICE_DTLS
    SET OBJECT_VERSION_NUMBER = l_def_sid_rec.object_version_number,
        CLE_ID = l_def_sid_rec.cle_id,
        FA_CLE_ID = l_def_sid_rec.fa_cle_id,
        INVOICE_NUMBER = l_def_sid_rec.invoice_number,
        DATE_INVOICED = l_def_sid_rec.date_invoiced,
        DATE_DUE = l_def_sid_rec.date_due,
        SHIPPING_ADDRESS_ID1 = l_def_sid_rec.shipping_address_id1,
        SHIPPING_ADDRESS_ID2 = l_def_sid_rec.shipping_address_id2,
        SHIPPING_ADDRESS_CODE = l_def_sid_rec.shipping_address_code,
        ATTRIBUTE_CATEGORY = l_def_sid_rec.attribute_category,
        ATTRIBUTE1 = l_def_sid_rec.attribute1,
        ATTRIBUTE2 = l_def_sid_rec.attribute2,
        ATTRIBUTE3 = l_def_sid_rec.attribute3,
        ATTRIBUTE4 = l_def_sid_rec.attribute4,
        ATTRIBUTE5 = l_def_sid_rec.attribute5,
        ATTRIBUTE6 = l_def_sid_rec.attribute6,
        ATTRIBUTE7 = l_def_sid_rec.attribute7,
        ATTRIBUTE8 = l_def_sid_rec.attribute8,
        ATTRIBUTE9 = l_def_sid_rec.attribute9,
        ATTRIBUTE10 = l_def_sid_rec.attribute10,
        ATTRIBUTE11 = l_def_sid_rec.attribute11,
        ATTRIBUTE12 = l_def_sid_rec.attribute12,
        ATTRIBUTE13 = l_def_sid_rec.attribute13,
        ATTRIBUTE14 = l_def_sid_rec.attribute14,
        ATTRIBUTE15 = l_def_sid_rec.attribute15,
        CREATED_BY = l_def_sid_rec.created_by,
        CREATION_DATE = l_def_sid_rec.creation_date,
        LAST_UPDATED_BY = l_def_sid_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sid_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sid_rec.last_update_login
    WHERE ID = l_def_sid_rec.id;
    x_sid_rec := l_sid_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  --------------------------------------------
  -- update_row for:OKL_SUPP_INVOICE_DTLS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type,
    x_sidv_rec                     OUT NOCOPY sidv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sidv_rec                     sidv_rec_type := p_sidv_rec;
    l_def_sidv_rec                 sidv_rec_type;
    l_db_sidv_rec                  sidv_rec_type;
    l_sid_rec                      sid_rec_type;
    lx_sid_rec                     sid_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sidv_rec IN sidv_rec_type
    ) RETURN sidv_rec_type IS
      l_sidv_rec sidv_rec_type := p_sidv_rec;
    BEGIN
      l_sidv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sidv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sidv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sidv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sidv_rec IN sidv_rec_type,
      x_sidv_rec OUT NOCOPY sidv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sidv_rec := p_sidv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_sidv_rec := get_rec(p_sidv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_sidv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.id := l_db_sidv_rec.id;
        END IF;
        IF (x_sidv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.object_version_number := l_db_sidv_rec.object_version_number;
        END IF;
        IF (x_sidv_rec.cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.cle_id := l_db_sidv_rec.cle_id;
        END IF;
        IF (x_sidv_rec.fa_cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.fa_cle_id := l_db_sidv_rec.fa_cle_id;
        END IF;
        IF (x_sidv_rec.invoice_number = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.invoice_number := l_db_sidv_rec.invoice_number;
        END IF;
        IF (x_sidv_rec.date_invoiced = OKL_API.G_MISS_DATE)
        THEN
          x_sidv_rec.date_invoiced := l_db_sidv_rec.date_invoiced;
        END IF;
        IF (x_sidv_rec.date_due = OKL_API.G_MISS_DATE)
        THEN
          x_sidv_rec.date_due := l_db_sidv_rec.date_due;
        END IF;
        IF (x_sidv_rec.shipping_address_id1 = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.shipping_address_id1 := l_db_sidv_rec.shipping_address_id1;
        END IF;
        IF (x_sidv_rec.shipping_address_id2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.shipping_address_id2 := l_db_sidv_rec.shipping_address_id2;
        END IF;
        IF (x_sidv_rec.shipping_address_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.shipping_address_code := l_db_sidv_rec.shipping_address_code;
        END IF;
        IF (x_sidv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute_category := l_db_sidv_rec.attribute_category;
        END IF;
        IF (x_sidv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute1 := l_db_sidv_rec.attribute1;
        END IF;
        IF (x_sidv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute2 := l_db_sidv_rec.attribute2;
        END IF;
        IF (x_sidv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute3 := l_db_sidv_rec.attribute3;
        END IF;
        IF (x_sidv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute4 := l_db_sidv_rec.attribute4;
        END IF;
        IF (x_sidv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute5 := l_db_sidv_rec.attribute5;
        END IF;
        IF (x_sidv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute6 := l_db_sidv_rec.attribute6;
        END IF;
        IF (x_sidv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute7 := l_db_sidv_rec.attribute7;
        END IF;
        IF (x_sidv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute8 := l_db_sidv_rec.attribute8;
        END IF;
        IF (x_sidv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute9 := l_db_sidv_rec.attribute9;
        END IF;
        IF (x_sidv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute10 := l_db_sidv_rec.attribute10;
        END IF;
        IF (x_sidv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute11 := l_db_sidv_rec.attribute11;
        END IF;
        IF (x_sidv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute12 := l_db_sidv_rec.attribute12;
        END IF;
        IF (x_sidv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute13 := l_db_sidv_rec.attribute13;
        END IF;
        IF (x_sidv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute14 := l_db_sidv_rec.attribute14;
        END IF;
        IF (x_sidv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_sidv_rec.attribute15 := l_db_sidv_rec.attribute15;
        END IF;
        IF (x_sidv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.created_by := l_db_sidv_rec.created_by;
        END IF;
        IF (x_sidv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_sidv_rec.creation_date := l_db_sidv_rec.creation_date;
        END IF;
        IF (x_sidv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.last_updated_by := l_db_sidv_rec.last_updated_by;
        END IF;
        IF (x_sidv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sidv_rec.last_update_date := l_db_sidv_rec.last_update_date;
        END IF;
        IF (x_sidv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_sidv_rec.last_update_login := l_db_sidv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKL_SUPP_INVOICE_DTLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sidv_rec IN sidv_rec_type,
      x_sidv_rec OUT NOCOPY sidv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sidv_rec := p_sidv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sidv_rec,                        -- IN
      x_sidv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sidv_rec, l_def_sidv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sidv_rec := fill_who_columns(l_def_sidv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sidv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sidv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sidv_rec, l_sid_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sid_rec,
      lx_sid_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sid_rec, l_def_sidv_rec);
    x_sidv_rec := l_def_sidv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:sidv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sidv_tbl.COUNT > 0) THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_sidv_rec                     => p_sidv_tbl(i),
            x_sidv_rec                     => x_sidv_tbl(i));
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ------------------------------------------
  -- delete_row for:OKL_SUPP_INVOICE_DTLS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sid_rec                      IN sid_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sid_rec                      sid_rec_type := p_sid_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_SUPP_INVOICE_DTLS
     WHERE ID = p_sid_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  --------------------------------------------
  -- delete_row for:OKL_SUPP_INVOICE_DTLS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sidv_rec                     sidv_rec_type := p_sidv_rec;
    l_sid_rec                      sid_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_sidv_rec, l_sid_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sid_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SUPP_INVOICE_DTLS_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sidv_tbl.COUNT > 0) THEN
      i := p_sidv_tbl.FIRST;
      LOOP
        delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_sidv_rec                     => p_sidv_tbl(i));
        EXIT WHEN (i = p_sidv_tbl.LAST);
        i := p_sidv_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE versioning
  ---------------------------------------------------------------------------
  FUNCTION create_version(p_chr_id        IN OKC_K_LINES_B.ID%TYPE,
                          p_major_version IN OKL_SUPP_INVOICE_DTLS_H.MAJOR_VERSION%TYPE)
  RETURN VARCHAR2
  IS
  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    INSERT INTO OKL_SUPP_INVOICE_DTLS_H(
      id,
      object_version_number,
      major_version,
      cle_id,
      fa_cle_id,
      invoice_number,
      date_invoiced,
      date_due,
      shipping_address_id1,
      shipping_address_id2,
      shipping_address_code,
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
      last_update_login)
  SELECT
      id,
      object_version_number,
      p_major_version,
      cle_id,
      fa_cle_id,
      invoice_number,
      date_invoiced,
      date_due,
      shipping_address_id1,
      shipping_address_id2,
      shipping_address_code,
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
      last_update_login
  FROM OKL_SUPP_INVOICE_DTLS
  WHERE cle_id in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id);
  RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
  END create_version;
-----------------------------------------------------------------------------------------------------

  FUNCTION restore_version(p_chr_id        IN OKC_K_LINES_B.ID%TYPE,
                            p_major_version IN OKL_SUPP_INVOICE_DTLS_H.MAJOR_VERSION%TYPE)
  RETURN VARCHAR2
  IS
  l_return_status         VARCHAR2(3) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    INSERT INTO OKL_SUPP_INVOICE_DTLS(
      id,
      object_version_number,
      cle_id,
      fa_cle_id,
      invoice_number,
      date_invoiced,
      date_due,
      shipping_address_id1,
      shipping_address_id2,
      shipping_address_code,
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
      last_update_login)
  SELECT id,
        object_version_number,
        cle_id,
        fa_cle_id,
        invoice_number,
        date_invoiced,
        date_due,
        shipping_address_id1,
        shipping_address_id2,
        shipping_address_code,
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
        last_update_login
  FROM OKL_SUPP_INVOICE_DTLS_H
  WHERE cle_id in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id)
  and major_version = p_major_version;
  RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
  END restore_version;
END OKL_SID_PVT;

/
