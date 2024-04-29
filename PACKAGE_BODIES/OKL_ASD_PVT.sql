--------------------------------------------------------
--  DDL for Package Body OKL_ASD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ASD_PVT" AS
/* $Header: OKLSASDB.pls 115.13 2004/05/20 22:07:28 avsingh noship $ */
-- Badrinath Kuchibholta
/************************ HAND-CODED *********************************/
G_TABLE_TOKEN                CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
G_EXCEPTION_STOP_VALIDATION           EXCEPTION;
G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
G_INVALID_VALUE              CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
G_NO_MATCHING_RECORD         CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
-- List validation procedures for quick reference
--1. validate_tal_id             -- Attribute Validation
--2. validate_asset_number       -- Attribute Validation
--3. validate_quantity           -- Attribute Validation
--4. validate_life_in_months_tax -- Attribute Validation
--5. validate_target_kle_id      -- Attribute Validation
--7. Validate_INVENTORY_ITEM_ID  -- Attribute Validation
--6. validate_qcs                -- Tuple Record Validation
----------------------------------7---------------------------------------------
-- Start of Commnets
-- chenkuang.lee
-- Procedure Name       : Validate_INVENTORY_ITEM_ID
-- Description          : FK validation with okx_system_items_v
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE Validate_INVENTORY_ITEM_ID(x_return_status OUT NOCOPY VARCHAR2,
                            p_asdv_rec IN asdv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_INVENTORY_ITEM_ID_validate(p_id number) is
    SELECT 1
    FROM okx_system_items_v
    WHERE id1 = p_id;
    --AND   ID2=OKL_CONTEXT.get_okc_organization_id; -- multi-org enable

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is not required
    IF (p_asdv_rec.INVENTORY_ITEM_ID <> OKC_API.G_MISS_NUM) AND
       (p_asdv_rec.INVENTORY_ITEM_ID IS NOT NULL) THEN

      -- Enforce Foreign Key
      OPEN  c_INVENTORY_ITEM_ID_validate(p_asdv_rec.INVENTORY_ITEM_ID);
      FETCH c_INVENTORY_ITEM_ID_validate into ln_dummy;
      CLOSE c_INVENTORY_ITEM_ID_validate;
      IF (ln_dummy = 0) then
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
      OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'INVENTORY_ITEM_ID');
      -- Notify Error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- store SQL error message on message stack
      OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'INVENTORY_ITEM_ID');
      -- If the cursor is open then it has to be closed
      IF c_INVENTORY_ITEM_ID_validate%ISOPEN THEN
         CLOSE c_INVENTORY_ITEM_ID_validate;
      END IF;
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack
      OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                        p_msg_name => G_UNEXPECTED_ERROR,
                        p_token1 => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2 => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
      -- If the cursor is open then it has to be closed
      IF c_INVENTORY_ITEM_ID_validate%ISOPEN THEN
         CLOSE c_INVENTORY_ITEM_ID_validate;
      END IF;
      -- notify caller of an error as UNEXPETED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_INVENTORY_ITEM_ID;

--------------------------------------1-----------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_Tal_Id
-- Description          : FK validation with OKL_TRX_ASSET_LINES_B
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tal_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_asdv_rec IN asdv_rec_type) IS
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
    IF (p_asdv_rec.tal_id = OKC_API.G_MISS_NUM) OR
       (p_asdv_rec.tal_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_tal_id_validate(p_asdv_rec.tal_id);
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
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tal_id');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
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
    OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                        p_msg_name => G_UNEXPECTED_ERROR,
                        p_token1 => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2 => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_tal_id_validate%ISOPEN THEN
       CLOSE c_tal_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tal_id;
------------------------------------3--------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_quantity
-- Description          : See that is more than 0
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_quantity(x_return_status OUT NOCOPY VARCHAR2,
                              p_asdv_rec IN asdv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asdv_rec.quantity = OKC_API.G_MISS_NUM) OR
       (p_asdv_rec.quantity IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- See that is more than 0
    IF p_asdv_rec.quantity <= 0 THEN
       -- halt validation
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause not greater than zero
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'quantity');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                        p_msg_name => G_UNEXPECTED_ERROR,
                        p_token1 => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2 => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_quantity;

-------------------------------------4-------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_life_in_months_tax
-- Description          : See that is more than 0
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_life_in_months_tax(x_return_status OUT NOCOPY VARCHAR2,
                                        p_asdv_rec IN asdv_rec_type) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asdv_rec.life_in_months_tax = OKC_API.G_MISS_NUM) OR
       (p_asdv_rec.life_in_months_tax IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- See that is more than 0
    IF p_asdv_rec.life_in_months_tax <= 0 THEN
       -- halt validation
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause not greater than zero
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_INVALID_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'life_in_months_tax');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                        p_msg_name => G_UNEXPECTED_ERROR,
                        p_token1 => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2 => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_life_in_months_tax;
--------------------------------------5-------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_target_kle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_target_kle_id(x_return_status OUT NOCOPY VARCHAR2,
                                   p_asdv_rec IN asdv_rec_type) IS
    ln_dummy number := 0;
    CURSOR c_target_kle_id_validate(p_id OKL_TXD_ASSETS_V.TARGET_KLE_ID%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_K_LINES_V kle
                  WHERE kle.id = p_id);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asdv_rec.target_kle_id = OKC_API.G_MISS_NUM) OR
       (p_asdv_rec.target_kle_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_target_kle_id_validate(p_asdv_rec.target_kle_id);
    IF c_target_kle_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_target_kle_id_validate into ln_dummy;
    CLOSE c_target_kle_id_validate;
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
                        p_token1_value => 'target_kle_id');
    -- If the cursor is open then it has to be closed
    IF c_target_kle_id_validate%ISOPEN THEN
       CLOSE c_target_kle_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                        p_msg_name => G_UNEXPECTED_ERROR,
                        p_token1 => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2 => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_target_kle_id_validate%ISOPEN THEN
       CLOSE c_target_kle_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_target_kle_id;
------------------------------19----------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_tax_book
-- Description          : FK validation with OKX_ASST_BK_CONTROLS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tax_book(x_return_status OUT NOCOPY VARCHAR2,
                              p_asdv_rec IN asdv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_tax_book_validate(p_name OKX_ASST_BK_CONTROLS_V.NAME%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id1
                 FROM OKX_ASST_BK_CONTROLS_V
                 WHERE name = p_name
                 AND book_class = 'TAX');

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asdv_rec.tax_book = OKC_API.G_MISS_CHAR) OR
       (p_asdv_rec.tax_book IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_tax_book_validate(p_asdv_rec.tax_book);
    IF c_tax_book_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_tax_book_validate into ln_dummy;
    CLOSE c_tax_book_validate;
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
                        p_token1_value => 'tax_book');
    IF c_tax_book_validate%ISOPEN THEN
       CLOSE c_tax_book_validate;
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
    IF c_tax_book_validate%ISOPEN THEN
       CLOSE c_tax_book_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tax_book;
--------------------------------20-------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_dprn_mtd_tax
-- Description          : FK validation with OKX_ASST_DEP_METHODS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_dprn_mtd_tax(x_return_status OUT NOCOPY VARCHAR2,
                                  p_asdv_rec IN asdv_rec_type) IS

    ln_dummy number := 0;
    CURSOR c_dprn_mtd_tax_validate(p_deprn_method OKX_ASST_DEP_METHODS_V.METHOD_CODE%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT method_code
                 FROM OKX_ASST_DEP_METHODS_V
                 WHERE method_code  = p_deprn_method);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asdv_rec.deprn_method_tax = OKC_API.G_MISS_CHAR) OR
       (p_asdv_rec.deprn_method_tax IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_dprn_mtd_tax_validate(p_asdv_rec.deprn_method_tax);
    IF c_dprn_mtd_tax_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_dprn_mtd_tax_validate into ln_dummy;
    CLOSE c_dprn_mtd_tax_validate;
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
                        p_token1_value => 'deprn_method_tax');
    IF c_dprn_mtd_tax_validate%ISOPEN THEN
       CLOSE c_dprn_mtd_tax_validate;
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
    IF c_dprn_mtd_tax_validate%ISOPEN THEN
       CLOSE c_dprn_mtd_tax_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_dprn_mtd_tax;

/************************ HAND-CODED *********************************/

--
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
                         p_asdv_rec        IN  asdv_rec_type,
                         x_asdv_rec        OUT NOCOPY asdv_rec_type
                        ) IS

   l_conv_amount   NUMBER;
   l_currency_code OKC_K_LINES_B.CURRENCY_CODE%TYPE;

   roundoff_error EXCEPTION;

   BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- Take original record values
     x_asdv_rec := p_asdv_rec;

     l_currency_code := p_asdv_rec.currency_code;

     IF (l_currency_code IS NULL) THEN -- Fatal error, Not a valid currency_code
        RAISE roundoff_error;
     END IF;

     --dbms_output.put_line('Round off start '||l_currency_code);
     -- Round off all Asset Transaction Line Amounts
     IF (p_asdv_rec.cost IS NOT NULL
         AND
         p_asdv_rec.cost <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_asdv_rec.cost,
                                          p_currency_code => l_currency_code
                                         );

         x_asdv_rec.cost := l_conv_amount;
     END IF;

     IF (p_asdv_rec.salvage_value IS NOT NULL
         AND
         p_asdv_rec.salvage_value <> OKL_API.G_MISS_NUM) THEN

         l_conv_amount := NULL;
         l_conv_amount := okl_accounting_util.cross_currency_round_amount(
                                          p_amount        => p_asdv_rec.salvage_value,
                                          p_currency_code => l_currency_code
                                         );

         x_asdv_rec.salvage_value := l_conv_amount;
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
                              p_asdv_rec      IN  asdv_rec_type,
                              x_asdv_rec      OUT NOCOPY asdv_rec_type
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

    x_asdv_rec := p_asdv_rec;
    l_func_currency := okl_accounting_util.get_func_curr_code();

    --dbms_output.put_line('Func Curr: '||l_func_currency);
    --dbms_output.put_line('Trans Curr Code: '|| p_asdv_rec.currency_code);
    --dbms_output.put_line('Trans Curr Rate: '|| p_asdv_rec.currency_conversion_rate);
    --dbms_output.put_line('Trans Curr Date: '|| p_asdv_rec.currency_conversion_date);
    --dbms_output.put_line('Trans Curr Type: '|| p_asdv_rec.currency_conversion_type);

    IF (p_asdv_rec.currency_code IS NULL
        OR
        p_asdv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN -- take functional currency
       x_asdv_rec.currency_code := l_func_currency;
       x_asdv_rec.currency_conversion_type := NULL;
       x_asdv_rec.currency_conversion_rate := NULL;
       x_asdv_rec.currency_conversion_date := NULL;
    ELSE

       l_ok := '?';
       OPEN curr_csr(p_asdv_rec.currency_code);
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

       IF (p_asdv_rec.currency_code = l_func_currency) THEN -- both are same
           x_asdv_rec.currency_conversion_type := NULL;
           x_asdv_rec.currency_conversion_rate := NULL;
           x_asdv_rec.currency_conversion_date := NULL;
       ELSE -- transactional and functional currency are different

           -- Conversion type, date and rate mandetory
           IF (p_asdv_rec.currency_conversion_type IS NULL
               OR
               p_asdv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR) THEN
              OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'currency_conversion_type');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;

           l_ok := '?';
           OPEN conv_type_csr (p_asdv_rec.currency_conversion_type);
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

           IF (p_asdv_rec.currency_conversion_date IS NULL
               OR
               p_asdv_rec.currency_conversion_date = OKC_API.G_MISS_DATE) THEN
              OKC_API.set_message(
                                  p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_REQUIRED_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'currency_conversion_date');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE currency_validation_failed;
           END IF;

           IF (p_asdv_rec.currency_conversion_type = 'User') THEN

               IF (p_asdv_rec.currency_conversion_rate IS NULL
                   OR
                   p_asdv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM) THEN
                  OKC_API.set_message(
                                      p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_REQUIRED_VALUE,
                                      p_token1       => G_COL_NAME_TOKEN,
                                      p_token1_value => 'currency_conversion_rate');
                  x_return_status := OKC_API.G_RET_STS_ERROR;
                  RAISE currency_validation_failed;
               END IF;

              x_asdv_rec.currency_conversion_type := p_asdv_rec.currency_conversion_type;
              x_asdv_rec.currency_conversion_rate := p_asdv_rec.currency_conversion_rate;
              x_asdv_rec.currency_conversion_date := p_asdv_rec.currency_conversion_date;

           ELSE -- conversion_type <> 'User'

              x_asdv_rec.currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
                                                          p_from_curr_code => p_asdv_rec.currency_code,
                                                          p_to_curr_code   => l_func_currency,
                                                          p_con_date       => p_asdv_rec.currency_conversion_date,
                                                          p_con_type       => p_asdv_rec.currency_conversion_type
                                                         );

              x_asdv_rec.currency_conversion_type := p_asdv_rec.currency_conversion_type;
              x_asdv_rec.currency_conversion_date := p_asdv_rec.currency_conversion_date;

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
    DELETE FROM OKL_TXD_ASSETS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXD_ASSETS_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TXD_ASSETS_TL T SET (
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_TXD_ASSETS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXD_ASSETS_TL SUBB, OKL_TXD_ASSETS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKL_TXD_ASSETS_TL (
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
        FROM OKL_TXD_ASSETS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXD_ASSETS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_ASSETS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_asd_rec                      IN asd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN asd_rec_type IS
    CURSOR asd_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TAL_ID,
            TARGET_KLE_ID,
            LINE_DETAIL_NUMBER,
            ASSET_NUMBER,
            QUANTITY,
            COST,
            TAX_BOOK,
            LIFE_IN_MONTHS_TAX,
            DEPRN_METHOD_TAX,
            DEPRN_RATE_TAX,
            SALVAGE_VALUE,
-- added new columns for split asset component
            SPLIT_PERCENT,
            INVENTORY_ITEM_ID,
-- end of added new columns for split asset component
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
-- Multi-Currency changes
            CURRENCY_CODE,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE
-- Multi-Currency changes
      FROM Okl_Txd_Assets_b txd
     WHERE txd.id = p_id;
    l_asd_pk                       asd_pk_csr%ROWTYPE;
    l_asd_rec                      asd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN asd_pk_csr (p_asd_rec.id);
    FETCH asd_pk_csr INTO
              l_asd_rec.ID,
              l_asd_rec.OBJECT_VERSION_NUMBER,
              l_asd_rec.TAL_ID,
              l_asd_rec.TARGET_KLE_ID,
              l_asd_rec.LINE_DETAIL_NUMBER,
              l_asd_rec.ASSET_NUMBER,
              l_asd_rec.QUANTITY,
              l_asd_rec.COST,
              l_asd_rec.TAX_BOOK,
              l_asd_rec.LIFE_IN_MONTHS_TAX,
              l_asd_rec.DEPRN_METHOD_TAX,
              l_asd_rec.DEPRN_RATE_TAX,
              l_asd_rec.SALVAGE_VALUE,
-- added new columns for split asset component
              l_asd_rec.SPLIT_PERCENT,
              l_asd_rec.INVENTORY_ITEM_ID,
-- end of added new columns for split asset component
              l_asd_rec.ATTRIBUTE_CATEGORY,
              l_asd_rec.ATTRIBUTE1,
              l_asd_rec.ATTRIBUTE2,
              l_asd_rec.ATTRIBUTE3,
              l_asd_rec.ATTRIBUTE4,
              l_asd_rec.ATTRIBUTE5,
              l_asd_rec.ATTRIBUTE6,
              l_asd_rec.ATTRIBUTE7,
              l_asd_rec.ATTRIBUTE8,
              l_asd_rec.ATTRIBUTE9,
              l_asd_rec.ATTRIBUTE10,
              l_asd_rec.ATTRIBUTE11,
              l_asd_rec.ATTRIBUTE12,
              l_asd_rec.ATTRIBUTE13,
              l_asd_rec.ATTRIBUTE14,
              l_asd_rec.ATTRIBUTE15,
              l_asd_rec.CREATED_BY,
              l_asd_rec.CREATION_DATE,
              l_asd_rec.LAST_UPDATED_BY,
              l_asd_rec.LAST_UPDATE_DATE,
              l_asd_rec.LAST_UPDATE_LOGIN,
-- Multi-Currency changes
              l_asd_rec.CURRENCY_CODE,
              l_asd_rec.CURRENCY_CONVERSION_TYPE,
              l_asd_rec.CURRENCY_CONVERSION_RATE,
              l_asd_rec.CURRENCY_CONVERSION_DATE;
-- Multi-Currency changes
    x_no_data_found := asd_pk_csr%NOTFOUND;
    CLOSE asd_pk_csr;
    RETURN(l_asd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_asd_rec                      IN asd_rec_type
  ) RETURN asd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_asd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_ASSETS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txd_assets_tl_rec        IN okl_txd_assets_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txd_assets_tl_rec_type IS
    CURSOR okl_txd_asset_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM okl_txd_assets_tl
     WHERE okl_txd_assets_tl.id = p_id
       AND okl_txd_assets_tl.language = p_language;
    l_okl_txd_asset_tl_pk          okl_txd_asset_tl_pk_csr%ROWTYPE;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txd_asset_tl_pk_csr (p_okl_txd_assets_tl_rec.id,
                                  p_okl_txd_assets_tl_rec.language);
    FETCH okl_txd_asset_tl_pk_csr INTO
              l_okl_txd_assets_tl_rec.ID,
              l_okl_txd_assets_tl_rec.LANGUAGE,
              l_okl_txd_assets_tl_rec.SOURCE_LANG,
              l_okl_txd_assets_tl_rec.SFWT_FLAG,
              l_okl_txd_assets_tl_rec.DESCRIPTION,
              l_okl_txd_assets_tl_rec.CREATED_BY,
              l_okl_txd_assets_tl_rec.CREATION_DATE,
              l_okl_txd_assets_tl_rec.LAST_UPDATED_BY,
              l_okl_txd_assets_tl_rec.LAST_UPDATE_DATE,
              l_okl_txd_assets_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txd_asset_tl_pk_csr%NOTFOUND;
    CLOSE okl_txd_asset_tl_pk_csr;
    RETURN(l_okl_txd_assets_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txd_assets_tl_rec        IN okl_txd_assets_tl_rec_type
  ) RETURN okl_txd_assets_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txd_assets_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXD_ASSETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_asdv_rec                     IN asdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN asdv_rec_type IS
    CURSOR okl_asdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT id,
           object_version_number,
           sfwt_flag,
           tal_id,
           target_kle_id,
           line_detail_number,
           asset_number,
           description,
           quantity,
           cost,
           tax_book,
           life_in_months_tax,
           deprn_method_tax,
           deprn_rate_tax,
           salvage_value,
-- added new columns for split asset component
           SPLIT_PERCENT,
           INVENTORY_ITEM_ID,
-- end of added new columns for split asset component
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
     FROM Okl_Txd_Assets_V txd
     WHERE txd.id  = p_id;
    l_okl_asdv_pk                  okl_asdv_pk_csr%ROWTYPE;
    l_asdv_rec                     asdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_asdv_pk_csr (p_asdv_rec.id);
    FETCH okl_asdv_pk_csr INTO
              l_asdv_rec.ID,
              l_asdv_rec.OBJECT_VERSION_NUMBER,
              l_asdv_rec.SFWT_FLAG,
              l_asdv_rec.TAL_ID,
              l_asdv_rec.TARGET_KLE_ID,
              l_asdv_rec.LINE_DETAIL_NUMBER,
              l_asdv_rec.ASSET_NUMBER,
              l_asdv_rec.DESCRIPTION,
              l_asdv_rec.QUANTITY,
              l_asdv_rec.COST,
              l_asdv_rec.TAX_BOOK,
              l_asdv_rec.LIFE_IN_MONTHS_TAX,
              l_asdv_rec.DEPRN_METHOD_TAX,
              l_asdv_rec.DEPRN_RATE_TAX,
              l_asdv_rec.SALVAGE_VALUE,
-- added new columns for split asset component
              l_asdv_rec.SPLIT_PERCENT,
              l_asdv_rec.INVENTORY_ITEM_ID,
-- end of added new columns for split asset component
              l_asdv_rec.ATTRIBUTE_CATEGORY,
              l_asdv_rec.ATTRIBUTE1,
              l_asdv_rec.ATTRIBUTE2,
              l_asdv_rec.ATTRIBUTE3,
              l_asdv_rec.ATTRIBUTE4,
              l_asdv_rec.ATTRIBUTE5,
              l_asdv_rec.ATTRIBUTE6,
              l_asdv_rec.ATTRIBUTE7,
              l_asdv_rec.ATTRIBUTE8,
              l_asdv_rec.ATTRIBUTE9,
              l_asdv_rec.ATTRIBUTE10,
              l_asdv_rec.ATTRIBUTE11,
              l_asdv_rec.ATTRIBUTE12,
              l_asdv_rec.ATTRIBUTE13,
              l_asdv_rec.ATTRIBUTE14,
              l_asdv_rec.ATTRIBUTE15,
              l_asdv_rec.CREATED_BY,
              l_asdv_rec.CREATION_DATE,
              l_asdv_rec.LAST_UPDATED_BY,
              l_asdv_rec.LAST_UPDATE_DATE,
              l_asdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_asdv_pk_csr%NOTFOUND;
    CLOSE okl_asdv_pk_csr;
    RETURN(l_asdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_asdv_rec                     IN asdv_rec_type
  ) RETURN asdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_asdv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXD_ASSETS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_asdv_rec	IN asdv_rec_type
  ) RETURN asdv_rec_type IS
    l_asdv_rec	asdv_rec_type := p_asdv_rec;
  BEGIN
    IF (l_asdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.object_version_number := NULL;
    END IF;
    IF (l_asdv_rec.tal_id = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.tal_id := NULL;
    END IF;
    IF (l_asdv_rec.target_kle_id = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.target_kle_id := NULL;
    END IF;
    IF (l_asdv_rec.line_detail_number = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.line_detail_number := NULL;
    END IF;
    IF (l_asdv_rec.asset_number = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.asset_number := NULL;
    END IF;
    IF (l_asdv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.description := NULL;
    END IF;
    IF (l_asdv_rec.quantity = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.quantity := NULL;
    END IF;
    IF (l_asdv_rec.cost = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.cost := NULL;
    END IF;
    IF (l_asdv_rec.tax_book = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.tax_book := NULL;
    END IF;
    IF (l_asdv_rec.life_in_months_tax = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.life_in_months_tax := NULL;
    END IF;
    IF (l_asdv_rec.deprn_method_tax = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.deprn_method_tax := NULL;
    END IF;
    IF (l_asdv_rec.deprn_rate_tax = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.deprn_rate_tax := NULL;
    END IF;
    IF (l_asdv_rec.salvage_value = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.salvage_value := NULL;
    END IF;

-- added new columns for split asset component
    IF (l_asdv_rec.SPLIT_PERCENT = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.SPLIT_PERCENT := NULL;
    END IF;
    IF (l_asdv_rec.INVENTORY_ITEM_ID = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.INVENTORY_ITEM_ID := NULL;
    END IF;
-- end of added new columns for split asset component

    IF (l_asdv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute_category := NULL;
    END IF;
    IF (l_asdv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute1 := NULL;
    END IF;
    IF (l_asdv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute2 := NULL;
    END IF;
    IF (l_asdv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute3 := NULL;
    END IF;
    IF (l_asdv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute4 := NULL;
    END IF;
    IF (l_asdv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute5 := NULL;
    END IF;
    IF (l_asdv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute6 := NULL;
    END IF;
    IF (l_asdv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute7 := NULL;
    END IF;
    IF (l_asdv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute8 := NULL;
    END IF;
    IF (l_asdv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute9 := NULL;
    END IF;
    IF (l_asdv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute10 := NULL;
    END IF;
    IF (l_asdv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute11 := NULL;
    END IF;
    IF (l_asdv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute12 := NULL;
    END IF;
    IF (l_asdv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute13 := NULL;
    END IF;
    IF (l_asdv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute14 := NULL;
    END IF;
    IF (l_asdv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_asdv_rec.attribute15 := NULL;
    END IF;
    IF (l_asdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.created_by := NULL;
    END IF;
    IF (l_asdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_asdv_rec.creation_date := NULL;
    END IF;
    IF (l_asdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_asdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_asdv_rec.last_update_date := NULL;
    END IF;
    IF (l_asdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_asdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_asdv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_TXD_ASSETS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_asdv_rec IN  asdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_asdv_rec.id = OKC_API.G_MISS_NUM OR
       p_asdv_rec.id IS NULL THEN
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_asdv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_asdv_rec.object_version_number IS NULL THEN
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_asdv_rec.asset_number = OKC_API.G_MISS_CHAR OR
          p_asdv_rec.asset_number IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Asset_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
/************************ HAND-CODED *********************************/
    -- Calling the Validate Procedure  to validate Individual Attributes
    validate_tal_id(x_return_status  => l_return_status,
                    p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_quantity(x_return_status  => l_return_status,
                      p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_life_in_months_tax(x_return_status  => l_return_status,
                                p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_target_kle_id(x_return_status  => l_return_status,
                                p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_tax_book(x_return_status  => l_return_status,
                      p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_dprn_mtd_tax(x_return_status  => l_return_status,
                          p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status :=  l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
--
    Validate_INVENTORY_ITEM_ID(x_return_status  => l_return_status,
                          p_asdv_rec => p_asdv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status :=  l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
--

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
  -- Validate_Record for:OKL_TXD_ASSETS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_asdv_rec IN asdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 BEGIN
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
    RETURN(l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN asdv_rec_type,
    p_to	IN OUT NOCOPY asd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.tal_id := p_from.tal_id;
    p_to.target_kle_id := p_from.target_kle_id;
    p_to.line_detail_number := p_from.line_detail_number;
    p_to.asset_number := p_from.asset_number;
    p_to.quantity := p_from.quantity;
    p_to.cost := p_from.cost;
    p_to.tax_book := p_from.tax_book;
    p_to.life_in_months_tax := p_from.life_in_months_tax;
    p_to.deprn_method_tax := p_from.deprn_method_tax;
    p_to.deprn_rate_tax := p_from.deprn_rate_tax;
    p_to.salvage_value := p_from.salvage_value;
--
    p_to.SPLIT_PERCENT := p_from.SPLIT_PERCENT;
    p_to.INVENTORY_ITEM_ID := p_from.INVENTORY_ITEM_ID;
--
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
    -- Multi-Currency Change
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    -- Multi-Currency Change
  END migrate;
  PROCEDURE migrate (
    p_from	IN asd_rec_type,
    p_to	IN OUT NOCOPY asdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.tal_id := p_from.tal_id;
    p_to.target_kle_id := p_from.target_kle_id;
    p_to.line_detail_number := p_from.line_detail_number;
    p_to.asset_number := p_from.asset_number;
    p_to.quantity := p_from.quantity;
    p_to.cost := p_from.cost;
    p_to.tax_book := p_from.tax_book;
    p_to.life_in_months_tax := p_from.life_in_months_tax;
    p_to.deprn_method_tax := p_from.deprn_method_tax;
    p_to.deprn_rate_tax := p_from.deprn_rate_tax;
    p_to.salvage_value := p_from.salvage_value;
--
    p_to.SPLIT_PERCENT := p_from.SPLIT_PERCENT;
    p_to.INVENTORY_ITEM_ID := p_from.INVENTORY_ITEM_ID;
--
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
    -- Multi-Currency Change
    p_to.currency_code := p_from.currency_code;
    p_to.currency_conversion_type := p_from.currency_conversion_type;
    p_to.currency_conversion_rate := p_from.currency_conversion_rate;
    p_to.currency_conversion_date := p_from.currency_conversion_date;
    -- Multi-Currency Change
  END migrate;
  PROCEDURE migrate (
    p_from	IN asdv_rec_type,
    p_to	IN OUT NOCOPY okl_txd_assets_tl_rec_type
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
    p_from	IN okl_txd_assets_tl_rec_type,
    p_to	IN OUT NOCOPY asdv_rec_type
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
  -- validate_row for:OKL_TXD_ASSETS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_rec                     IN asdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asdv_rec                     asdv_rec_type := p_asdv_rec;
    l_asd_rec                      asd_rec_type;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_asdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_asdv_rec);
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
  -- PL/SQL TBL validate_row for:ASDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN asdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asdv_rec                     => p_asdv_tbl(i));
        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
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
  -----------------------------------
  -- insert_row for:OKL_TXD_ASSETS_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asd_rec                      IN asd_rec_type,
    x_asd_rec                      OUT NOCOPY asd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asd_rec                      asd_rec_type := p_asd_rec;
    l_def_asd_rec                  asd_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_asd_rec IN  asd_rec_type,
      x_asd_rec OUT NOCOPY asd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_asd_rec := p_asd_rec;
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
      p_asd_rec,                         -- IN
      l_asd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXD_ASSETS_B(
        id,
        object_version_number,
        tal_id,
        target_kle_id,
        line_detail_number,
        asset_number,
        quantity,
        cost,
        tax_book,
        life_in_months_tax,
        deprn_method_tax,
        deprn_rate_tax,
        salvage_value,

-- added new columns for split asset component
        SPLIT_PERCENT,
        INVENTORY_ITEM_ID,
-- end of added new columns for split asset component

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
-- Multi-Currency changes
        currency_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date)
-- Multi-Currency changes
      VALUES (
        l_asd_rec.id,
        l_asd_rec.object_version_number,
        l_asd_rec.tal_id,
        l_asd_rec.target_kle_id,
        l_asd_rec.line_detail_number,
        l_asd_rec.asset_number,
        l_asd_rec.quantity,
        l_asd_rec.cost,
        l_asd_rec.tax_book,
        l_asd_rec.life_in_months_tax,
        l_asd_rec.deprn_method_tax,
        l_asd_rec.deprn_rate_tax,
        l_asd_rec.salvage_value,

-- added new columns for split asset component
        l_asd_rec.SPLIT_PERCENT,
        l_asd_rec.INVENTORY_ITEM_ID,
-- end of added new columns for split asset component

        l_asd_rec.attribute_category,
        l_asd_rec.attribute1,
        l_asd_rec.attribute2,
        l_asd_rec.attribute3,
        l_asd_rec.attribute4,
        l_asd_rec.attribute5,
        l_asd_rec.attribute6,
        l_asd_rec.attribute7,
        l_asd_rec.attribute8,
        l_asd_rec.attribute9,
        l_asd_rec.attribute10,
        l_asd_rec.attribute11,
        l_asd_rec.attribute12,
        l_asd_rec.attribute13,
        l_asd_rec.attribute14,
        l_asd_rec.attribute15,
        l_asd_rec.created_by,
        l_asd_rec.creation_date,
        l_asd_rec.last_updated_by,
        l_asd_rec.last_update_date,
        l_asd_rec.last_update_login,
        -- Multi-Currency Change
        l_asd_rec.currency_code,
        l_asd_rec.currency_conversion_type,
        l_asd_rec.currency_conversion_rate,
        l_asd_rec.currency_conversion_date);
        -- Multi-Currency Change
    -- Set OUT values
    x_asd_rec := l_asd_rec;
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
  -- insert_row for:OKL_TXD_ASSETS_TL --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_assets_tl_rec        IN okl_txd_assets_tl_rec_type,
    x_okl_txd_assets_tl_rec        OUT NOCOPY okl_txd_assets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type := p_okl_txd_assets_tl_rec;
    l_def_okl_txd_assets_tl_rec    okl_txd_assets_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txd_assets_tl_rec IN  okl_txd_assets_tl_rec_type,
      x_okl_txd_assets_tl_rec OUT NOCOPY okl_txd_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_assets_tl_rec := p_okl_txd_assets_tl_rec;
      x_okl_txd_assets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txd_assets_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txd_assets_tl_rec,           -- IN
      l_okl_txd_assets_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txd_assets_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TXD_ASSETS_TL(
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
          l_okl_txd_assets_tl_rec.id,
          l_okl_txd_assets_tl_rec.language,
          l_okl_txd_assets_tl_rec.source_lang,
          l_okl_txd_assets_tl_rec.sfwt_flag,
          l_okl_txd_assets_tl_rec.description,
          l_okl_txd_assets_tl_rec.created_by,
          l_okl_txd_assets_tl_rec.creation_date,
          l_okl_txd_assets_tl_rec.last_updated_by,
          l_okl_txd_assets_tl_rec.last_update_date,
          l_okl_txd_assets_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txd_assets_tl_rec := l_okl_txd_assets_tl_rec;
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
  -- insert_row for:OKL_TXD_ASSETS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_rec                     IN asdv_rec_type,
    x_asdv_rec                     OUT NOCOPY asdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asdv_rec                     asdv_rec_type;
    l_def_asdv_rec                 asdv_rec_type;
    l_asd_rec                      asd_rec_type;
    lx_asd_rec                     asd_rec_type;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
    lx_okl_txd_assets_tl_rec       okl_txd_assets_tl_rec_type;
    lx_temp_asdv_rec               asdv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_asdv_rec	IN asdv_rec_type
    ) RETURN asdv_rec_type IS
      l_asdv_rec	asdv_rec_type := p_asdv_rec;
    BEGIN
      l_asdv_rec.CREATION_DATE := SYSDATE;
      l_asdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_asdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_asdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_asdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_asdv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_asdv_rec IN  asdv_rec_type,
      x_asdv_rec OUT NOCOPY asdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_asdv_rec := p_asdv_rec;
      x_asdv_rec.OBJECT_VERSION_NUMBER := 1;
      x_asdv_rec.SFWT_FLAG := 'N';
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
    l_asdv_rec := null_out_defaults(p_asdv_rec);
    -- Set primary key value
    l_asdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_asdv_rec,                        -- IN
      l_def_asdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_asdv_rec := fill_who_columns(l_def_asdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_asdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_asdv_rec);
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
                      p_asdv_rec      => l_def_asdv_rec,
                      x_asdv_rec      => lx_temp_asdv_rec
                     );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_asdv_rec := lx_temp_asdv_rec;

    --dbms_output.put_line('After Change: '||lx_temp_asdv_rec.currency_code);
    --dbms_output.put_line('After Change: '||l_def_asdv_rec.currency_code);
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
                         p_asdv_rec      => l_def_asdv_rec,
                         x_asdv_rec      => lx_temp_asdv_rec
                        );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_asdv_rec := lx_temp_asdv_rec;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_asdv_rec, l_asd_rec);
    migrate(l_def_asdv_rec, l_okl_txd_assets_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asd_rec,
      lx_asd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_asd_rec, l_def_asdv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_assets_tl_rec,
      lx_okl_txd_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txd_assets_tl_rec, l_def_asdv_rec);
    -- Set OUT values
    x_asdv_rec := l_def_asdv_rec;
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
  -- PL/SQL TBL insert_row for:ASDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN asdv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY asdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asdv_rec                     => p_asdv_tbl(i),
          x_asdv_rec                     => x_asdv_tbl(i));
        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
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
  ---------------------------------
  -- lock_row for:OKL_TXD_ASSETS_B --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asd_rec                      IN asd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_asd_rec IN asd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_ASSETS_B
     WHERE ID = p_asd_rec.id
       AND OBJECT_VERSION_NUMBER = p_asd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_asd_rec IN asd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXD_ASSETS_B
    WHERE ID = p_asd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXD_ASSETS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXD_ASSETS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_asd_rec);
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
      OPEN lchk_csr(p_asd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_asd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_asd_rec.object_version_number THEN
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
  -- lock_row for:OKL_TXD_ASSETS_TL --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_assets_tl_rec        IN okl_txd_assets_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txd_assets_tl_rec IN okl_txd_assets_tl_rec_type) IS
    SELECT *
      FROM OKL_TXD_ASSETS_TL
     WHERE ID = p_okl_txd_assets_tl_rec.id
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
      OPEN lock_csr(p_okl_txd_assets_tl_rec);
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
  -- lock_row for:OKL_TXD_ASSETS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_rec                     IN asdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asd_rec                      asd_rec_type;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
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
    migrate(p_asdv_rec, l_asd_rec);
    migrate(p_asdv_rec, l_okl_txd_assets_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asd_rec
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
      l_okl_txd_assets_tl_rec
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
  -- PL/SQL TBL lock_row for:ASDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN asdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asdv_rec                     => p_asdv_tbl(i));
        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
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
  -----------------------------------
  -- update_row for:OKL_TXD_ASSETS_B --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asd_rec                      IN asd_rec_type,
    x_asd_rec                      OUT NOCOPY asd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asd_rec                      asd_rec_type := p_asd_rec;
    l_def_asd_rec                  asd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_asd_rec	IN asd_rec_type,
      x_asd_rec	OUT NOCOPY asd_rec_type
    ) RETURN VARCHAR2 IS
      l_asd_rec                      asd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_asd_rec := p_asd_rec;
      -- Get current database values
      l_asd_rec := get_rec(p_asd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_asd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.id := l_asd_rec.id;
      END IF;
      IF (x_asd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.object_version_number := l_asd_rec.object_version_number;
      END IF;
      IF (x_asd_rec.tal_id = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.tal_id := l_asd_rec.tal_id;
      END IF;
      IF (x_asd_rec.target_kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.target_kle_id := l_asd_rec.target_kle_id;
      END IF;
      IF (x_asd_rec.line_detail_number = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.line_detail_number := l_asd_rec.line_detail_number;
      END IF;
      IF (x_asd_rec.asset_number = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.asset_number := l_asd_rec.asset_number;
      END IF;
      IF (x_asd_rec.quantity = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.quantity := l_asd_rec.quantity;
      END IF;
      IF (x_asd_rec.cost = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.cost := l_asd_rec.cost;
      END IF;
      IF (x_asd_rec.tax_book = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.tax_book := l_asd_rec.tax_book;
      END IF;
      IF (x_asd_rec.life_in_months_tax = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.life_in_months_tax := l_asd_rec.life_in_months_tax;
      END IF;
      IF (x_asd_rec.deprn_method_tax = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.deprn_method_tax := l_asd_rec.deprn_method_tax;
      END IF;
      IF (x_asd_rec.deprn_rate_tax = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.deprn_rate_tax := l_asd_rec.deprn_rate_tax;
      END IF;
      IF (x_asd_rec.salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.salvage_value := l_asd_rec.salvage_value;
      END IF;

-- added new columns for split asset component
      IF (x_asd_rec.SPLIT_PERCENT = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.SPLIT_PERCENT := l_asd_rec.SPLIT_PERCENT;
      END IF;
      IF (x_asd_rec.INVENTORY_ITEM_ID = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.INVENTORY_ITEM_ID := l_asd_rec.INVENTORY_ITEM_ID;
      END IF;
-- end of added new columns for split asset component

      IF (x_asd_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute_category := l_asd_rec.attribute_category;
      END IF;
      IF (x_asd_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute1 := l_asd_rec.attribute1;
      END IF;
      IF (x_asd_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute2 := l_asd_rec.attribute2;
      END IF;
      IF (x_asd_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute3 := l_asd_rec.attribute3;
      END IF;
      IF (x_asd_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute4 := l_asd_rec.attribute4;
      END IF;
      IF (x_asd_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute5 := l_asd_rec.attribute5;
      END IF;
      IF (x_asd_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute6 := l_asd_rec.attribute6;
      END IF;
      IF (x_asd_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute7 := l_asd_rec.attribute7;
      END IF;
      IF (x_asd_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute8 := l_asd_rec.attribute8;
      END IF;
      IF (x_asd_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute9 := l_asd_rec.attribute9;
      END IF;
      IF (x_asd_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute10 := l_asd_rec.attribute10;
      END IF;
      IF (x_asd_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute11 := l_asd_rec.attribute11;
      END IF;
      IF (x_asd_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute12 := l_asd_rec.attribute12;
      END IF;
      IF (x_asd_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute13 := l_asd_rec.attribute13;
      END IF;
      IF (x_asd_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute14 := l_asd_rec.attribute14;
      END IF;
      IF (x_asd_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.attribute15 := l_asd_rec.attribute15;
      END IF;
      IF (x_asd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.created_by := l_asd_rec.created_by;
      END IF;
      IF (x_asd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_asd_rec.creation_date := l_asd_rec.creation_date;
      END IF;
      IF (x_asd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.last_updated_by := l_asd_rec.last_updated_by;
      END IF;
      IF (x_asd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_asd_rec.last_update_date := l_asd_rec.last_update_date;
      END IF;
      IF (x_asd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.last_update_login := l_asd_rec.last_update_login;
      END IF;
      -- Multi Currency Change
      IF (x_asd_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.currency_code := l_asd_rec.currency_code;
      END IF;
      IF (x_asd_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_asd_rec.currency_conversion_type := l_asd_rec.currency_conversion_type;
      END IF;
      IF (x_asd_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_asd_rec.currency_conversion_rate := l_asd_rec.currency_conversion_rate;
      END IF;
      IF (x_asd_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_asd_rec.currency_conversion_date := l_asd_rec.currency_conversion_date;
      END IF;
      -- Multi Currency Change
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_B --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_asd_rec IN  asd_rec_type,
      x_asd_rec OUT NOCOPY asd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_asd_rec := p_asd_rec;
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
      p_asd_rec,                         -- IN
      l_asd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_asd_rec, l_def_asd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXD_ASSETS_B
    SET OBJECT_VERSION_NUMBER = l_def_asd_rec.object_version_number,
        TAL_ID = l_def_asd_rec.tal_id,
        TARGET_KLE_ID = l_def_asd_rec.target_kle_id,
        LINE_DETAIL_NUMBER = l_def_asd_rec.line_detail_number,
        ASSET_NUMBER = l_def_asd_rec.asset_number,
        QUANTITY = l_def_asd_rec.quantity,
        COST = l_def_asd_rec.cost,
        TAX_BOOK = l_def_asd_rec.tax_book,
        LIFE_IN_MONTHS_TAX = l_def_asd_rec.life_in_months_tax,
        DEPRN_METHOD_TAX = l_def_asd_rec.deprn_method_tax,
        DEPRN_RATE_TAX = l_def_asd_rec.deprn_rate_tax,
        SALVAGE_VALUE = l_def_asd_rec.salvage_value,

-- added new columns for split asset component
        SPLIT_PERCENT = l_def_asd_rec.SPLIT_PERCENT,
        INVENTORY_ITEM_ID = l_def_asd_rec.INVENTORY_ITEM_ID,
-- end of added new columns for split asset component

        ATTRIBUTE_CATEGORY = l_def_asd_rec.attribute_category,
        ATTRIBUTE1 = l_def_asd_rec.attribute1,
        ATTRIBUTE2 = l_def_asd_rec.attribute2,
        ATTRIBUTE3 = l_def_asd_rec.attribute3,
        ATTRIBUTE4 = l_def_asd_rec.attribute4,
        ATTRIBUTE5 = l_def_asd_rec.attribute5,
        ATTRIBUTE6 = l_def_asd_rec.attribute6,
        ATTRIBUTE7 = l_def_asd_rec.attribute7,
        ATTRIBUTE8 = l_def_asd_rec.attribute8,
        ATTRIBUTE9 = l_def_asd_rec.attribute9,
        ATTRIBUTE10 = l_def_asd_rec.attribute10,
        ATTRIBUTE11 = l_def_asd_rec.attribute11,
        ATTRIBUTE12 = l_def_asd_rec.attribute12,
        ATTRIBUTE13 = l_def_asd_rec.attribute13,
        ATTRIBUTE14 = l_def_asd_rec.attribute14,
        ATTRIBUTE15 = l_def_asd_rec.attribute15,
        CREATED_BY = l_def_asd_rec.created_by,
        CREATION_DATE = l_def_asd_rec.creation_date,
        LAST_UPDATED_BY = l_def_asd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_asd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_asd_rec.last_update_login,
        CURRENCY_CODE = l_def_asd_rec.currency_code,
        CURRENCY_CONVERSION_TYPE = l_def_asd_rec.currency_conversion_type,
        CURRENCY_CONVERSION_RATE = l_def_asd_rec.currency_conversion_rate,
        CURRENCY_CONVERSION_DATE = l_def_asd_rec.currency_conversion_date
    WHERE ID = l_def_asd_rec.id;

    x_asd_rec := l_def_asd_rec;
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
  -- update_row for:OKL_TXD_ASSETS_TL --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_assets_tl_rec        IN okl_txd_assets_tl_rec_type,
    x_okl_txd_assets_tl_rec        OUT NOCOPY okl_txd_assets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type := p_okl_txd_assets_tl_rec;
    l_def_okl_txd_assets_tl_rec    okl_txd_assets_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txd_assets_tl_rec	IN okl_txd_assets_tl_rec_type,
      x_okl_txd_assets_tl_rec	OUT NOCOPY okl_txd_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_assets_tl_rec := p_okl_txd_assets_tl_rec;
      -- Get current database values
      l_okl_txd_assets_tl_rec := get_rec(p_okl_txd_assets_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txd_assets_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txd_assets_tl_rec.id := l_okl_txd_assets_tl_rec.id;
      END IF;
      IF (x_okl_txd_assets_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txd_assets_tl_rec.language := l_okl_txd_assets_tl_rec.language;
      END IF;
      IF (x_okl_txd_assets_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txd_assets_tl_rec.source_lang := l_okl_txd_assets_tl_rec.source_lang;
      END IF;
      IF (x_okl_txd_assets_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txd_assets_tl_rec.sfwt_flag := l_okl_txd_assets_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txd_assets_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txd_assets_tl_rec.description := l_okl_txd_assets_tl_rec.description;
      END IF;
      IF (x_okl_txd_assets_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txd_assets_tl_rec.created_by := l_okl_txd_assets_tl_rec.created_by;
      END IF;
      IF (x_okl_txd_assets_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txd_assets_tl_rec.creation_date := l_okl_txd_assets_tl_rec.creation_date;
      END IF;
      IF (x_okl_txd_assets_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txd_assets_tl_rec.last_updated_by := l_okl_txd_assets_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txd_assets_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txd_assets_tl_rec.last_update_date := l_okl_txd_assets_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txd_assets_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txd_assets_tl_rec.last_update_login := l_okl_txd_assets_tl_rec.last_update_login;
      END IF;
/*
      -- Multi Currency Change
      IF (x_okl_txd_assets_tl_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txd_assets_tl_rec.currency_code := l_okl_txd_assets_tl_rec.currency_code;
      END IF;
      IF (x_okl_txd_assets_tl_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_txd_assets_tl_rec.currency_conversion_type := l_okl_txd_assets_tl_rec.currency_conversion_type;
      END IF;
      IF (x_okl_txd_assets_tl_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_okl_txd_assets_tl_rec.currency_conversion_rate := l_okl_txd_assets_tl_rec.currency_conversion_rate;
      END IF;
      IF (x_okl_txd_assets_tl_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_txd_assets_tl_rec.currency_conversion_date := l_okl_txd_assets_tl_rec.currency_conversion_date;
      END IF;
      -- Multi Currency Change
*/
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txd_assets_tl_rec IN  okl_txd_assets_tl_rec_type,
      x_okl_txd_assets_tl_rec OUT NOCOPY okl_txd_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_assets_tl_rec := p_okl_txd_assets_tl_rec;
      x_okl_txd_assets_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txd_assets_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txd_assets_tl_rec,           -- IN
      l_okl_txd_assets_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txd_assets_tl_rec, l_def_okl_txd_assets_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXD_ASSETS_TL
    SET DESCRIPTION = l_def_okl_txd_assets_tl_rec.description,
        --Bug# 3641933 :
        SOURCE_LANG = l_def_okl_txd_assets_tl_rec.source_lang,
        CREATED_BY = l_def_okl_txd_assets_tl_rec.created_by,
        CREATION_DATE = l_def_okl_txd_assets_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_txd_assets_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_txd_assets_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_txd_assets_tl_rec.last_update_login
    WHERE ID = l_def_okl_txd_assets_tl_rec.id
      --Bug# 3641933 :
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_TXD_ASSETS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okl_txd_assets_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txd_assets_tl_rec := l_def_okl_txd_assets_tl_rec;
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
  -- update_row for:OKL_TXD_ASSETS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_rec                     IN asdv_rec_type,
    x_asdv_rec                     OUT NOCOPY asdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asdv_rec                     asdv_rec_type := p_asdv_rec;
    l_def_asdv_rec                 asdv_rec_type;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
    lx_okl_txd_assets_tl_rec       okl_txd_assets_tl_rec_type;
    l_asd_rec                      asd_rec_type;
    lx_asd_rec                     asd_rec_type;
    lx_temp_asdv_rec               asdv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_asdv_rec	IN asdv_rec_type
    ) RETURN asdv_rec_type IS
      l_asdv_rec	asdv_rec_type := p_asdv_rec;
    BEGIN
      l_asdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_asdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_asdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_asdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_asdv_rec	IN asdv_rec_type,
      x_asdv_rec	OUT NOCOPY asdv_rec_type
    ) RETURN VARCHAR2 IS
      l_asdv_rec                     asdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_asdv_rec := p_asdv_rec;
      -- Get current database values
      l_asdv_rec := get_rec(p_asdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_asdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.id := l_asdv_rec.id;
      END IF;
      IF (x_asdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.object_version_number := l_asdv_rec.object_version_number;
      END IF;
      IF (x_asdv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.sfwt_flag := l_asdv_rec.sfwt_flag;
      END IF;
      IF (x_asdv_rec.tal_id = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.tal_id := l_asdv_rec.tal_id;
      END IF;
      IF (x_asdv_rec.target_kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.target_kle_id := l_asdv_rec.target_kle_id;
      END IF;
      IF (x_asdv_rec.line_detail_number = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.line_detail_number := l_asdv_rec.line_detail_number;
      END IF;
      IF (x_asdv_rec.asset_number = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.asset_number := l_asdv_rec.asset_number;
      END IF;
      IF (x_asdv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.description := l_asdv_rec.description;
      END IF;
      IF (x_asdv_rec.quantity = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.quantity := l_asdv_rec.quantity;
      END IF;
      IF (x_asdv_rec.cost = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.cost := l_asdv_rec.cost;
      END IF;
      IF (x_asdv_rec.tax_book = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.tax_book := l_asdv_rec.tax_book;
      END IF;
      IF (x_asdv_rec.life_in_months_tax = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.life_in_months_tax := l_asdv_rec.life_in_months_tax;
      END IF;
      IF (x_asdv_rec.deprn_method_tax = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.deprn_method_tax := l_asdv_rec.deprn_method_tax;
      END IF;
      IF (x_asdv_rec.deprn_rate_tax = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.deprn_rate_tax := l_asdv_rec.deprn_rate_tax;
      END IF;
      IF (x_asdv_rec.salvage_value = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.salvage_value := l_asdv_rec.salvage_value;
      END IF;

-- added new columns for split asset component
      IF (x_asdv_rec.SPLIT_PERCENT = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.SPLIT_PERCENT := l_asdv_rec.SPLIT_PERCENT;
      END IF;
      IF (x_asdv_rec.INVENTORY_ITEM_ID = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.INVENTORY_ITEM_ID := l_asdv_rec.INVENTORY_ITEM_ID;
      END IF;
-- end of added new columns for split asset component

      IF (x_asdv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute_category := l_asdv_rec.attribute_category;
      END IF;
      IF (x_asdv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute1 := l_asdv_rec.attribute1;
      END IF;
      IF (x_asdv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute2 := l_asdv_rec.attribute2;
      END IF;
      IF (x_asdv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute3 := l_asdv_rec.attribute3;
      END IF;
      IF (x_asdv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute4 := l_asdv_rec.attribute4;
      END IF;
      IF (x_asdv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute5 := l_asdv_rec.attribute5;
      END IF;
      IF (x_asdv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute6 := l_asdv_rec.attribute6;
      END IF;
      IF (x_asdv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute7 := l_asdv_rec.attribute7;
      END IF;
      IF (x_asdv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute8 := l_asdv_rec.attribute8;
      END IF;
      IF (x_asdv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute9 := l_asdv_rec.attribute9;
      END IF;
      IF (x_asdv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute10 := l_asdv_rec.attribute10;
      END IF;
      IF (x_asdv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute11 := l_asdv_rec.attribute11;
      END IF;
      IF (x_asdv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute12 := l_asdv_rec.attribute12;
      END IF;
      IF (x_asdv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute13 := l_asdv_rec.attribute13;
      END IF;
      IF (x_asdv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute14 := l_asdv_rec.attribute14;
      END IF;
      IF (x_asdv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.attribute15 := l_asdv_rec.attribute15;
      END IF;
      IF (x_asdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.created_by := l_asdv_rec.created_by;
      END IF;
      IF (x_asdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_asdv_rec.creation_date := l_asdv_rec.creation_date;
      END IF;
      IF (x_asdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.last_updated_by := l_asdv_rec.last_updated_by;
      END IF;
      IF (x_asdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_asdv_rec.last_update_date := l_asdv_rec.last_update_date;
      END IF;
      IF (x_asdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.last_update_login := l_asdv_rec.last_update_login;
      END IF;
      -- Multi Currency Change
      IF (x_asdv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.currency_code := l_asdv_rec.currency_code;
      END IF;
      IF (x_asdv_rec.currency_conversion_type = OKC_API.G_MISS_CHAR)
      THEN
        x_asdv_rec.currency_conversion_type := l_asdv_rec.currency_conversion_type;
      END IF;
      IF (x_asdv_rec.currency_conversion_rate = OKC_API.G_MISS_NUM)
      THEN
        x_asdv_rec.currency_conversion_rate := l_asdv_rec.currency_conversion_rate;
      END IF;
      IF (x_asdv_rec.currency_conversion_date = OKC_API.G_MISS_DATE)
      THEN
        x_asdv_rec.currency_conversion_date := l_asdv_rec.currency_conversion_date;
      END IF;
      -- Multi Currency Change
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_asdv_rec IN  asdv_rec_type,
      x_asdv_rec OUT NOCOPY asdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_asdv_rec := p_asdv_rec;
      x_asdv_rec.OBJECT_VERSION_NUMBER := NVL(x_asdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_asdv_rec,                        -- IN
      l_asdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_asdv_rec, l_def_asdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_asdv_rec := fill_who_columns(l_def_asdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_asdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_asdv_rec);
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
                      p_asdv_rec      => l_def_asdv_rec,
                      x_asdv_rec      => lx_temp_asdv_rec
                     );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_asdv_rec := lx_temp_asdv_rec;

    --dbms_output.put_line('After Change: '||lx_temp_asdv_rec.currency_code);
    --dbms_output.put_line('After Change: '||l_def_asdv_rec.currency_code);
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
                         p_asdv_rec      => l_def_asdv_rec,
                         x_asdv_rec      => lx_temp_asdv_rec
                        );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_asdv_rec := lx_temp_asdv_rec;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_asdv_rec, l_okl_txd_assets_tl_rec);
    migrate(l_def_asdv_rec, l_asd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_assets_tl_rec,
      lx_okl_txd_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txd_assets_tl_rec, l_def_asdv_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asd_rec,
      lx_asd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_asd_rec, l_def_asdv_rec);
    x_asdv_rec := l_def_asdv_rec;
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
  -- PL/SQL TBL update_row for:ASDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN asdv_tbl_type,
    x_asdv_tbl                     OUT NOCOPY asdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asdv_rec                     => p_asdv_tbl(i),
          x_asdv_rec                     => x_asdv_tbl(i));
        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
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
  -----------------------------------
  -- delete_row for:OKL_TXD_ASSETS_B --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asd_rec                      IN asd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asd_rec                      asd_rec_type:= p_asd_rec;
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
    DELETE FROM OKL_TXD_ASSETS_B
     WHERE ID = l_asd_rec.id;

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
  -- delete_row for:OKL_TXD_ASSETS_TL --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txd_assets_tl_rec        IN okl_txd_assets_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type:= p_okl_txd_assets_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ------------------------------------------
    -- Set_Attributes for:OKL_TXD_ASSETS_TL --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txd_assets_tl_rec IN  okl_txd_assets_tl_rec_type,
      x_okl_txd_assets_tl_rec OUT NOCOPY okl_txd_assets_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txd_assets_tl_rec := p_okl_txd_assets_tl_rec;
      x_okl_txd_assets_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_txd_assets_tl_rec,           -- IN
      l_okl_txd_assets_tl_rec);          -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXD_ASSETS_TL
     WHERE ID = l_okl_txd_assets_tl_rec.id;

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
  -- delete_row for:OKL_TXD_ASSETS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_rec                     IN asdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asdv_rec                     asdv_rec_type := p_asdv_rec;
    l_okl_txd_assets_tl_rec        okl_txd_assets_tl_rec_type;
    l_asd_rec                      asd_rec_type;
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
    migrate(l_asdv_rec, l_okl_txd_assets_tl_rec);
    migrate(l_asdv_rec, l_asd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txd_assets_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_asd_rec
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
  -- PL/SQL TBL delete_row for:ASDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asdv_tbl                     IN asdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_asdv_tbl.COUNT > 0) THEN
      i := p_asdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_asdv_rec                     => p_asdv_tbl(i));
        EXIT WHEN (i = p_asdv_tbl.LAST);
        i := p_asdv_tbl.NEXT(i);
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
END OKL_ASD_PVT;

/
