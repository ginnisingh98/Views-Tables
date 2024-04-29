--------------------------------------------------------
--  DDL for Package Body OKS_BTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BTN_PVT" AS
/* $Header: OKSSBTNB.pls 120.0 2005/05/25 17:55:32 appldev noship $ */
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
  -- FUNCTION get_rec for: OKS_BILL_TRANSACTIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_btn_rec                      IN btn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN btn_rec_type IS
    CURSOR btn_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CURRENCY_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            TRX_DATE,
            TRX_NUMBER,
            TRX_AMOUNT,
            TRX_CLASS,
            LAST_UPDATE_LOGIN
      FROM Oks_Bill_Transactions
     WHERE oks_bill_transactions.id = p_id;
    l_btn_pk                       btn_pk_csr%ROWTYPE;
    l_btn_rec                      btn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN btn_pk_csr (p_btn_rec.id);
    FETCH btn_pk_csr INTO
              l_btn_rec.ID,
              l_btn_rec.CURRENCY_CODE,
              l_btn_rec.OBJECT_VERSION_NUMBER,
              l_btn_rec.CREATED_BY,
              l_btn_rec.CREATION_DATE,
              l_btn_rec.LAST_UPDATED_BY,
              l_btn_rec.LAST_UPDATE_DATE,
              l_btn_rec.TRX_DATE,
              l_btn_rec.TRX_NUMBER,
              l_btn_rec.TRX_AMOUNT,
              l_btn_rec.TRX_CLASS,
              l_btn_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := btn_pk_csr%NOTFOUND;
    CLOSE btn_pk_csr;
    RETURN(l_btn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_btn_rec                      IN btn_rec_type
  ) RETURN btn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_btn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILL_TRANSACTIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_btnv_rec                     IN btnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN btnv_rec_type IS
    CURSOR okc_btnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            TRX_DATE,
            TRX_NUMBER,
            TRX_AMOUNT,
            TRX_CLASS,
            CURRENCY_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Bill_Transactions_V
     WHERE oks_bill_transactions_v.id = p_id;
    l_okc_btnv_pk                  okc_btnv_pk_csr%ROWTYPE;
    l_btnv_rec                     btnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_btnv_pk_csr (p_btnv_rec.id);
    FETCH okc_btnv_pk_csr INTO
              l_btnv_rec.ID,
              l_btnv_rec.OBJECT_VERSION_NUMBER,
              l_btnv_rec.TRX_DATE,
              l_btnv_rec.TRX_NUMBER,
              l_btnv_rec.TRX_AMOUNT,
              l_btnv_rec.TRX_CLASS,
              l_btnv_rec.CURRENCY_CODE,
              l_btnv_rec.CREATED_BY,
              l_btnv_rec.CREATION_DATE,
              l_btnv_rec.LAST_UPDATED_BY,
              l_btnv_rec.LAST_UPDATE_DATE,
              l_btnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_btnv_pk_csr%NOTFOUND;
    CLOSE okc_btnv_pk_csr;
    RETURN(l_btnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_btnv_rec                     IN btnv_rec_type
  ) RETURN btnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_btnv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_BILL_TRANSACTIONS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_btnv_rec	IN btnv_rec_type
  ) RETURN btnv_rec_type IS
    l_btnv_rec	btnv_rec_type := p_btnv_rec;
  BEGIN
    IF (l_btnv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_btnv_rec.object_version_number := NULL;
    END IF;
    IF (l_btnv_rec.trx_date = OKC_API.G_MISS_DATE) THEN
      l_btnv_rec.trx_date := NULL;
    END IF;
    IF (l_btnv_rec.trx_number = OKC_API.G_MISS_CHAR) THEN
      l_btnv_rec.trx_number := NULL;
    END IF;
    IF (l_btnv_rec.trx_amount = OKC_API.G_MISS_NUM) THEN
      l_btnv_rec.trx_amount := NULL;
    END IF;
    IF (l_btnv_rec.trx_class = OKC_API.G_MISS_CHAR) THEN
      l_btnv_rec.trx_class := NULL;
    END IF;
    IF (l_btnv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_btnv_rec.currency_code := NULL;
    END IF;
    IF (l_btnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_btnv_rec.created_by := NULL;
    END IF;
    IF (l_btnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_btnv_rec.creation_date := NULL;
    END IF;
    IF (l_btnv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_btnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_btnv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_btnv_rec.last_update_date := NULL;
    END IF;
    IF (l_btnv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_btnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_btnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate ID--
  -----------------------------------------------------
  PROCEDURE validate_id(x_return_status OUT NOCOPY varchar2,
				p_id   IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_id = OKC_API.G_MISS_NUM OR
       p_id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status;
		NULL;
  When OTHERS THEN
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_id;

  -----------------------------------------------------
  -- Validate Object Version Number --
  -----------------------------------------------------
  PROCEDURE validate_objvernum(x_return_status OUT NOCOPY varchar2,
					 P_object_version_number IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_object_version_number = OKC_API.G_MISS_NUM OR
       p_object_version_number IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_objvernum;
  -----------------------------------------------------
  -- Validate TRX DATE --
  -----------------------------------------------------
  PROCEDURE validate_Trx_Date(x_return_status OUT NOCOPY varchar2,
							 P_Trx_Date IN  DATE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  Begin


  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


  END validate_Trx_Date;

  -----------------------------------------------------
  -- Validate TRX NUMBER --
  -----------------------------------------------------
  PROCEDURE validate_Trx_Number(	x_return_status OUT NOCOPY varchar2,
					P_Trx_Number IN  VARCHAR2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
      -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_TRANSACTIONS_V'
            ,p_col_name      => 'TRX_NUMBER'
            ,p_col_value     => P_Trx_Number
            ,x_return_status => l_return_status
   );
   */

   -- verify that length is within allowed limits
   If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Trx Number Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_Trx_Number;

  -----------------------------------------------------
  -- Validate TRX Amount --
  -----------------------------------------------------
  PROCEDURE validate_Trx_Amount(x_return_status OUT NOCOPY varchar2,
					P_Trx_Amount IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
      -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_TRANSACTIONS_V'
            ,p_col_name      => 'TRX_AMOUNT'
            ,p_col_value     => P_Trx_Amount
            ,x_return_status => l_return_status
   );
   */

   -- verify that length is within allowed limits
   If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Trx Amount Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_Trx_Amount;
  -----------------------------------------------------
  -- Validate TRX Class --
  -----------------------------------------------------
  PROCEDURE validate_Trx_Class (x_return_status OUT NOCOPY varchar2,
					 P_Trx_Class IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_TRANSACTIONS_V'
            ,p_col_name      => 'TRX_CLASS'
            ,p_col_value     => P_Trx_Class
            ,x_return_status => l_return_status
   );

   */

   -- verify that length is within allowed limits
   If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Trx_Class length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_Trx_Class;

  -----------------------------------------------------
  -- Validate TRX Class --
  -----------------------------------------------------
  PROCEDURE validate_Currency_Code(	x_return_status OUT NOCOPY varchar2,
							 P_Currency_Code IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  If P_Currency_Code= OKC_API.G_MISS_CHAR OR
       P_Currency_Code IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CURRENCY_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_TRANSACTIONS_V'
            ,p_col_name      => 'CURRENCY_CODE'
            ,p_col_value     => P_Currency_Code
            ,x_return_status => l_return_status
   );
   */

   -- verify that length is within allowed limits
   If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'CURRENCY CODE length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_Currency_Code;


---------------------------------------------------
  -- Validate_Attributes for:OKS_BILL_TRANSACTIONS_V --
  ---------------------------------------------------
 FUNCTION Validate_Attributes (
    p_btnv_rec IN  btnv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_BILL_TRANSACTIONS_V',x_return_status);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there is a error
          l_return_status := x_return_status;
       END IF;
    END IF;

    --Column Level Validation

    --ID
    validate_id(x_return_status, p_btnv_rec.id);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    --OBJECT_VERSION_NUMBER
    validate_objvernum(x_return_status, p_btnv_rec.object_version_number);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;
    	--TRX_DATE
	 validate_Trx_Date(x_return_status, p_btnv_rec.Trx_Date);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN


        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--TRX_NUMBER
	 validate_Trx_Number(x_return_status, p_btnv_rec.Trx_Number);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--TRX_AMOUNT
		validate_Trx_amount(x_return_status, p_btnv_rec.Trx_Amount);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--TRX_Class
		validate_Trx_Class(x_return_status, p_btnv_rec.Trx_Class);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    --Currency Code
		validate_Currency_Code(x_return_status, p_btnv_rec.Currency_Code);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    Raise G_EXCEPTION_HALT_VALIDATION;

  Exception

  When G_EXCEPTION_HALT_VALIDATION Then

       Return (l_return_status);

  When OTHERS Then
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);

       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       Return(l_return_status);

  END validate_attributes;


/*
  -----------------------------------------------------
  -- Validate_Attributes for:OKS_BILL_TRANSACTIONS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_btnv_rec IN  btnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_btnv_rec.id = OKC_API.G_MISS_NUM OR
       p_btnv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_btnv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_btnv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_btnv_rec.currency_code = OKC_API.G_MISS_CHAR OR
          p_btnv_rec.currency_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'currency_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKS_BILL_TRANSACTIONS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_btnv_rec IN btnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_btnv_rec IN btnv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_btnv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN btnv_rec_type,
    p_to	OUT NOCOPY btn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.trx_date := p_from.trx_date;
    p_to.trx_number := p_from.trx_number;
    p_to.trx_amount := p_from.trx_amount;
    p_to.trx_class := p_from.trx_class;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN btn_rec_type,
    p_to	OUT NOCOPY btnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.currency_code := p_from.currency_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.trx_date := p_from.trx_date;
    p_to.trx_number := p_from.trx_number;
    p_to.trx_amount := p_from.trx_amount;
    p_to.trx_class := p_from.trx_class;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKS_BILL_TRANSACTIONS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec                     IN btnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btnv_rec                     btnv_rec_type := p_btnv_rec;
    l_btn_rec                      btn_rec_type;
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
    l_return_status := Validate_Attributes(l_btnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_btnv_rec);
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
  -- PL/SQL TBL validate_row for:BTNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_tbl                     IN btnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btnv_tbl.COUNT > 0) THEN
      i := p_btnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btnv_rec                     => p_btnv_tbl(i));
        EXIT WHEN (i = p_btnv_tbl.LAST);
        i := p_btnv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKS_BILL_TRANSACTIONS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btn_rec                      IN btn_rec_type,
    x_btn_rec                      OUT NOCOPY btn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANSACTIONS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btn_rec                      btn_rec_type := p_btn_rec;
    l_def_btn_rec                  btn_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKS_BILL_TRANSACTIONS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_btn_rec IN  btn_rec_type,
      x_btn_rec OUT NOCOPY btn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_btn_rec := p_btn_rec;
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
      p_btn_rec,                         -- IN
      l_btn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_BILL_TRANSACTIONS(
        id,
        currency_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        trx_date,
        trx_number,
        trx_amount,
        trx_class,
        last_update_login)
      VALUES (
        l_btn_rec.id,
        l_btn_rec.currency_code,
        l_btn_rec.object_version_number,
        l_btn_rec.created_by,
        l_btn_rec.creation_date,
        l_btn_rec.last_updated_by,
        l_btn_rec.last_update_date,
        l_btn_rec.trx_date,
        l_btn_rec.trx_number,
        l_btn_rec.trx_amount,
        l_btn_rec.trx_class,
        l_btn_rec.last_update_login);
    -- Set OUT values
    x_btn_rec := l_btn_rec;
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
  --------------------------------------------
  -- insert_row for:OKS_BILL_TRANSACTIONS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec                     IN btnv_rec_type,
    x_btnv_rec                     OUT NOCOPY btnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btnv_rec                     btnv_rec_type;
    l_def_btnv_rec                 btnv_rec_type;
    l_btn_rec                      btn_rec_type;
    lx_btn_rec                     btn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_btnv_rec	IN btnv_rec_type
    ) RETURN btnv_rec_type IS
      l_btnv_rec	btnv_rec_type := p_btnv_rec;
    BEGIN
      l_btnv_rec.CREATION_DATE := SYSDATE;
      l_btnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_btnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_btnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_btnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_btnv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKS_BILL_TRANSACTIONS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_btnv_rec IN  btnv_rec_type,
      x_btnv_rec OUT NOCOPY btnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_btnv_rec := p_btnv_rec;
      x_btnv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_btnv_rec := null_out_defaults(p_btnv_rec);
    -- Set primary key value
    l_btnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_btnv_rec,                        -- IN
      l_def_btnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_btnv_rec := fill_who_columns(l_def_btnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_btnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_btnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_btnv_rec, l_btn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btn_rec,
      lx_btn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_btn_rec, l_def_btnv_rec);
    -- Set OUT values
    x_btnv_rec := l_def_btnv_rec;
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
  -- PL/SQL TBL insert_row for:BTNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_tbl                     IN btnv_tbl_type,
    x_btnv_tbl                     OUT NOCOPY btnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btnv_tbl.COUNT > 0) THEN
      i := p_btnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btnv_rec                     => p_btnv_tbl(i),
          x_btnv_rec                     => x_btnv_tbl(i));
        EXIT WHEN (i = p_btnv_tbl.LAST);
        i := p_btnv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKS_BILL_TRANSACTIONS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btn_rec                      IN btn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_btn_rec IN btn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_TRANSACTIONS
     WHERE ID = p_btn_rec.id
       AND OBJECT_VERSION_NUMBER = p_btn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_btn_rec IN btn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_TRANSACTIONS
    WHERE ID = p_btn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANSACTIONS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_BILL_TRANSACTIONS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_BILL_TRANSACTIONS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_btn_rec);
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
      OPEN lchk_csr(p_btn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_btn_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_btn_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKS_BILL_TRANSACTIONS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec                     IN btnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btn_rec                      btn_rec_type;
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
    migrate(p_btnv_rec, l_btn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btn_rec
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
  -- PL/SQL TBL lock_row for:BTNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_tbl                     IN btnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btnv_tbl.COUNT > 0) THEN
      i := p_btnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btnv_rec                     => p_btnv_tbl(i));
        EXIT WHEN (i = p_btnv_tbl.LAST);
        i := p_btnv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKS_BILL_TRANSACTIONS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btn_rec                      IN btn_rec_type,
    x_btn_rec                      OUT NOCOPY btn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANSACTIONS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btn_rec                      btn_rec_type := p_btn_rec;
    l_def_btn_rec                  btn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_btn_rec	IN btn_rec_type,
      x_btn_rec	OUT NOCOPY btn_rec_type
    ) RETURN VARCHAR2 IS
      l_btn_rec                      btn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_btn_rec := p_btn_rec;
      -- Get current database values
      l_btn_rec := get_rec(p_btn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_btn_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_btn_rec.id := l_btn_rec.id;
      END IF;
      IF (x_btn_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_btn_rec.currency_code := l_btn_rec.currency_code;
      END IF;
      IF (x_btn_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_btn_rec.object_version_number := l_btn_rec.object_version_number;
      END IF;
      IF (x_btn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_btn_rec.created_by := l_btn_rec.created_by;
      END IF;
      IF (x_btn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_btn_rec.creation_date := l_btn_rec.creation_date;
      END IF;
      IF (x_btn_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_btn_rec.last_updated_by := l_btn_rec.last_updated_by;
      END IF;
      IF (x_btn_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_btn_rec.last_update_date := l_btn_rec.last_update_date;
      END IF;
      IF (x_btn_rec.trx_date = OKC_API.G_MISS_DATE)
      THEN
        x_btn_rec.trx_date := l_btn_rec.trx_date;
      END IF;
      IF (x_btn_rec.trx_number = OKC_API.G_MISS_CHAR)
      THEN
        x_btn_rec.trx_number := l_btn_rec.trx_number;
      END IF;
      IF (x_btn_rec.trx_amount = OKC_API.G_MISS_NUM)
      THEN
        x_btn_rec.trx_amount := l_btn_rec.trx_amount;
      END IF;
      IF (x_btn_rec.trx_class = OKC_API.G_MISS_CHAR)
      THEN
        x_btn_rec.trx_class := l_btn_rec.trx_class;
      END IF;
      IF (x_btn_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_btn_rec.last_update_login := l_btn_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKS_BILL_TRANSACTIONS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_btn_rec IN  btn_rec_type,
      x_btn_rec OUT NOCOPY btn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_btn_rec := p_btn_rec;
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
      p_btn_rec,                         -- IN
      l_btn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_btn_rec, l_def_btn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_BILL_TRANSACTIONS
    SET CURRENCY_CODE = l_def_btn_rec.currency_code,
        OBJECT_VERSION_NUMBER = l_def_btn_rec.object_version_number,
        CREATED_BY = l_def_btn_rec.created_by,
        CREATION_DATE = l_def_btn_rec.creation_date,
        LAST_UPDATED_BY = l_def_btn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_btn_rec.last_update_date,
        TRX_DATE = l_def_btn_rec.trx_date,
        TRX_NUMBER = l_def_btn_rec.trx_number,
        TRX_AMOUNT = l_def_btn_rec.trx_amount,
        TRX_CLASS = l_def_btn_rec.trx_class,
        LAST_UPDATE_LOGIN = l_def_btn_rec.last_update_login
    WHERE ID = l_def_btn_rec.id;

    x_btn_rec := l_def_btn_rec;
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
  --------------------------------------------
  -- update_row for:OKS_BILL_TRANSACTIONS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec                     IN btnv_rec_type,
    x_btnv_rec                     OUT NOCOPY btnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btnv_rec                     btnv_rec_type := p_btnv_rec;
    l_def_btnv_rec                 btnv_rec_type;
    l_btn_rec                      btn_rec_type;
    lx_btn_rec                     btn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_btnv_rec	IN btnv_rec_type
    ) RETURN btnv_rec_type IS
      l_btnv_rec	btnv_rec_type := p_btnv_rec;
    BEGIN
      l_btnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_btnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_btnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_btnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_btnv_rec	IN btnv_rec_type,
      x_btnv_rec	OUT NOCOPY btnv_rec_type
    ) RETURN VARCHAR2 IS
      l_btnv_rec                     btnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_btnv_rec := p_btnv_rec;
      -- Get current database values
      l_btnv_rec := get_rec(p_btnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_btnv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_btnv_rec.id := l_btnv_rec.id;
      END IF;
      IF (x_btnv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_btnv_rec.object_version_number := l_btnv_rec.object_version_number;
      END IF;
      IF (x_btnv_rec.trx_date = OKC_API.G_MISS_DATE)
      THEN
        x_btnv_rec.trx_date := l_btnv_rec.trx_date;
      END IF;
      IF (x_btnv_rec.trx_number = OKC_API.G_MISS_CHAR)
      THEN
        x_btnv_rec.trx_number := l_btnv_rec.trx_number;
      END IF;
      IF (x_btnv_rec.trx_amount = OKC_API.G_MISS_NUM)
      THEN
        x_btnv_rec.trx_amount := l_btnv_rec.trx_amount;
      END IF;
      IF (x_btnv_rec.trx_class = OKC_API.G_MISS_CHAR)
      THEN
        x_btnv_rec.trx_class := l_btnv_rec.trx_class;
      END IF;
      IF (x_btnv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_btnv_rec.currency_code := l_btnv_rec.currency_code;
      END IF;
      IF (x_btnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_btnv_rec.created_by := l_btnv_rec.created_by;
      END IF;
      IF (x_btnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_btnv_rec.creation_date := l_btnv_rec.creation_date;
      END IF;
      IF (x_btnv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_btnv_rec.last_updated_by := l_btnv_rec.last_updated_by;
      END IF;
      IF (x_btnv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_btnv_rec.last_update_date := l_btnv_rec.last_update_date;
      END IF;
      IF (x_btnv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_btnv_rec.last_update_login := l_btnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKS_BILL_TRANSACTIONS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_btnv_rec IN  btnv_rec_type,
      x_btnv_rec OUT NOCOPY btnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_btnv_rec := p_btnv_rec;
      x_btnv_rec.OBJECT_VERSION_NUMBER := NVL(x_btnv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_btnv_rec,                        -- IN
      l_btnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_btnv_rec, l_def_btnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_btnv_rec := fill_who_columns(l_def_btnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_btnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_btnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_btnv_rec, l_btn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btn_rec,
      lx_btn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_btn_rec, l_def_btnv_rec);
    x_btnv_rec := l_def_btnv_rec;
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
  -- PL/SQL TBL update_row for:BTNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_tbl                     IN btnv_tbl_type,
    x_btnv_tbl                     OUT NOCOPY btnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btnv_tbl.COUNT > 0) THEN
      i := p_btnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btnv_rec                     => p_btnv_tbl(i),
          x_btnv_rec                     => x_btnv_tbl(i));
        EXIT WHEN (i = p_btnv_tbl.LAST);
        i := p_btnv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKS_BILL_TRANSACTIONS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btn_rec                      IN btn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TRANSACTIONS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btn_rec                      btn_rec_type:= p_btn_rec;
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
    DELETE FROM OKS_BILL_TRANSACTIONS
     WHERE ID = l_btn_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKS_BILL_TRANSACTIONS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_rec                     IN btnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_btnv_rec                     btnv_rec_type := p_btnv_rec;
    l_btn_rec                      btn_rec_type;
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
    migrate(l_btnv_rec, l_btn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_btn_rec
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
  -- PL/SQL TBL delete_row for:BTNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_btnv_tbl                     IN btnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_btnv_tbl.COUNT > 0) THEN
      i := p_btnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_btnv_rec                     => p_btnv_tbl(i));
        EXIT WHEN (i = p_btnv_tbl.LAST);
        i := p_btnv_tbl.NEXT(i);
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


PROCEDURE INSERT_ROW_UPG(p_btnv_tbl     btnv_tbl_type) IS

  l_tabsize NUMBER := p_btnv_tbl.COUNT;

  in_id                             OKC_DATATYPES.NumberTabTyp;
  in_object_version_number          OKC_DATATYPES.NumberTabTyp;
  in_trx_date                       OKC_DATATYPES.DateTabTyp;
  in_trx_number                     Var60TabTyp;
  in_trx_amount                     OKC_DATATYPES.NumberTabTyp;
  in_trx_class                      Var60TabTyp;
  in_currency_code                  Var45TabTyp;
  in_created_by                     OKC_DATATYPES.NumberTabTyp;
  in_creation_date                  OKC_DATATYPES.DateTabTyp;
  in_last_updated_by                OKC_DATATYPES.NumberTabTyp;
  in_last_update_date               OKC_DATATYPES.DateTabTyp;
  in_last_update_login              OKC_DATATYPES.NumberTabTyp;

  i number;
  j number;

BEGIN
  i := p_btnv_tbl.FIRST;
  j := 0;

  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_btnv_tbl(i).id;
    in_object_version_number    (j) := p_btnv_tbl(i).object_version_number;
    in_trx_date                 (j) := p_btnv_tbl(i).trx_date;
    in_trx_number               (j) := p_btnv_tbl(i).trx_number;
    in_trx_amount               (j) := p_btnv_tbl(i).trx_amount;
    in_trx_class                (j) := p_btnv_tbl(i).trx_class;
    in_currency_code            (j) := p_btnv_tbl(i).currency_code;
    in_created_by               (j) := p_btnv_tbl(i).created_by;
    in_creation_date            (j) := p_btnv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_btnv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_btnv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_btnv_tbl(i).last_update_login;

    i := p_btnv_tbl.next(i);

  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKS_BILL_TRANSACTIONS
      (
        id,
        object_version_number,
        trx_date,
        trx_number,
        trx_amount,
        trx_class,
        currency_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
      )
     VALUES
     (
        in_id(i),
        in_object_version_number(i),
        in_trx_date(i),
        in_trx_number(i),
        in_trx_amount(i),
        in_trx_class(i),
        in_currency_code(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
     );

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END INSERT_ROW_UPG;
END OKS_BTN_PVT;

/
