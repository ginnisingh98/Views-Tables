--------------------------------------------------------
--  DDL for Package Body OKS_BCL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BCL_PVT" AS
/* $Header: OKSSBCLB.pls 120.0 2005/05/25 18:11:38 appldev noship $ */
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
  -- FUNCTION get_rec for: OKS_BILL_CONT_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bcl_rec                      IN bcl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bcl_rec_type IS
    CURSOR bcl_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            BTN_ID,
            DATE_BILLED_FROM,
            DATE_BILLED_TO,
            SENT_YN,
            CURRENCY_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            AMOUNT,
            BILL_ACTION,
            DATE_NEXT_INVOICE,
            LAST_UPDATE_LOGIN,
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
            ATTRIBUTE15
      FROM Oks_Bill_Cont_Lines
     WHERE oks_bill_cont_lines.id = p_id;
    l_bcl_pk                       bcl_pk_csr%ROWTYPE;
    l_bcl_rec                      bcl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN bcl_pk_csr (p_bcl_rec.id);
    FETCH bcl_pk_csr INTO
              l_bcl_rec.ID,
              l_bcl_rec.CLE_ID,
              l_bcl_rec.BTN_ID,
              l_bcl_rec.DATE_BILLED_FROM,
              l_bcl_rec.DATE_BILLED_TO,
              l_bcl_rec.SENT_YN,
              l_bcl_rec.CURRENCY_CODE,
              l_bcl_rec.OBJECT_VERSION_NUMBER,
              l_bcl_rec.CREATED_BY,
              l_bcl_rec.CREATION_DATE,
              l_bcl_rec.LAST_UPDATED_BY,
              l_bcl_rec.LAST_UPDATE_DATE,
              l_bcl_rec.AMOUNT,
              l_bcl_rec.BILL_ACTION,
              l_bcl_rec.DATE_NEXT_INVOICE,
              l_bcl_rec.LAST_UPDATE_LOGIN,
              l_bcl_rec.ATTRIBUTE_CATEGORY,
              l_bcl_rec.ATTRIBUTE1,
              l_bcl_rec.ATTRIBUTE2,
              l_bcl_rec.ATTRIBUTE3,
              l_bcl_rec.ATTRIBUTE4,
              l_bcl_rec.ATTRIBUTE5,
              l_bcl_rec.ATTRIBUTE6,
              l_bcl_rec.ATTRIBUTE7,
              l_bcl_rec.ATTRIBUTE8,
              l_bcl_rec.ATTRIBUTE9,
              l_bcl_rec.ATTRIBUTE10,
              l_bcl_rec.ATTRIBUTE11,
              l_bcl_rec.ATTRIBUTE12,
              l_bcl_rec.ATTRIBUTE13,
              l_bcl_rec.ATTRIBUTE14,
              l_bcl_rec.ATTRIBUTE15;
    x_no_data_found := bcl_pk_csr%NOTFOUND;
    CLOSE bcl_pk_csr;
    RETURN(l_bcl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bcl_rec                      IN bcl_rec_type
  ) RETURN bcl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bcl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILL_CONT_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bclv_rec                     IN bclv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bclv_rec_type IS
    CURSOR okc_bclv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CLE_ID,
            BTN_ID,
            DATE_BILLED_FROM,
            DATE_BILLED_TO,
            DATE_NEXT_INVOICE,
            AMOUNT,
            SENT_YN,
            CURRENCY_CODE,
            BILL_ACTION,
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
      FROM Oks_Bill_Cont_Lines_V
     WHERE oks_bill_cont_lines_v.id = p_id;
    l_okc_bclv_pk                  okc_bclv_pk_csr%ROWTYPE;
    l_bclv_rec                     bclv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_bclv_pk_csr (p_bclv_rec.id);
    FETCH okc_bclv_pk_csr INTO
              l_bclv_rec.ID,
              l_bclv_rec.OBJECT_VERSION_NUMBER,
              l_bclv_rec.CLE_ID,
              l_bclv_rec.BTN_ID,
              l_bclv_rec.DATE_BILLED_FROM,
              l_bclv_rec.DATE_BILLED_TO,
              l_bclv_rec.DATE_NEXT_INVOICE,
              l_bclv_rec.AMOUNT,
              l_bclv_rec.SENT_YN,
              l_bclv_rec.CURRENCY_CODE,
              l_bclv_rec.BILL_ACTION,
              l_bclv_rec.ATTRIBUTE_CATEGORY,
              l_bclv_rec.ATTRIBUTE1,
              l_bclv_rec.ATTRIBUTE2,
              l_bclv_rec.ATTRIBUTE3,
              l_bclv_rec.ATTRIBUTE4,
              l_bclv_rec.ATTRIBUTE5,
              l_bclv_rec.ATTRIBUTE6,
              l_bclv_rec.ATTRIBUTE7,
              l_bclv_rec.ATTRIBUTE8,
              l_bclv_rec.ATTRIBUTE9,
              l_bclv_rec.ATTRIBUTE10,
              l_bclv_rec.ATTRIBUTE11,
              l_bclv_rec.ATTRIBUTE12,
              l_bclv_rec.ATTRIBUTE13,
              l_bclv_rec.ATTRIBUTE14,
              l_bclv_rec.ATTRIBUTE15,
              l_bclv_rec.CREATED_BY,
              l_bclv_rec.CREATION_DATE,
              l_bclv_rec.LAST_UPDATED_BY,
              l_bclv_rec.LAST_UPDATE_DATE,
              l_bclv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_bclv_pk_csr%NOTFOUND;
    CLOSE okc_bclv_pk_csr;
    RETURN(l_bclv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bclv_rec                     IN bclv_rec_type
  ) RETURN bclv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bclv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_BILL_CONT_LINES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_bclv_rec	IN bclv_rec_type
  ) RETURN bclv_rec_type IS
    l_bclv_rec	bclv_rec_type := p_bclv_rec;
  BEGIN
    IF (l_bclv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.object_version_number := NULL;
    END IF;
    IF (l_bclv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.cle_id := NULL;
    END IF;
    IF (l_bclv_rec.btn_id = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.btn_id := NULL;
    END IF;
    IF (l_bclv_rec.date_billed_from = OKC_API.G_MISS_DATE) THEN
      l_bclv_rec.date_billed_from := NULL;
    END IF;
    IF (l_bclv_rec.date_billed_to = OKC_API.G_MISS_DATE) THEN
      l_bclv_rec.date_billed_to := NULL;
    END IF;
    IF (l_bclv_rec.date_next_invoice = OKC_API.G_MISS_DATE) THEN
      l_bclv_rec.date_next_invoice := NULL;
    END IF;
    IF (l_bclv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.amount := NULL;
    END IF;
    IF (l_bclv_rec.sent_yn = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.sent_yn := NULL;
    END IF;
    IF (l_bclv_rec.currency_code = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.currency_code := NULL;
    END IF;
    IF (l_bclv_rec.bill_action = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.bill_action := NULL;
    END IF;
    IF (l_bclv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute_category := NULL;
    END IF;
    IF (l_bclv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute1 := NULL;
    END IF;
    IF (l_bclv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute2 := NULL;
    END IF;
    IF (l_bclv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute3 := NULL;
    END IF;
    IF (l_bclv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute4 := NULL;
    END IF;
    IF (l_bclv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute5 := NULL;
    END IF;
    IF (l_bclv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute6 := NULL;
    END IF;
    IF (l_bclv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute7 := NULL;
    END IF;
    IF (l_bclv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute8 := NULL;
    END IF;
    IF (l_bclv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute9 := NULL;
    END IF;
    IF (l_bclv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute10 := NULL;
    END IF;
    IF (l_bclv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute11 := NULL;
    END IF;
    IF (l_bclv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute12 := NULL;
    END IF;
    IF (l_bclv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute13 := NULL;
    END IF;
    IF (l_bclv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute14 := NULL;
    END IF;
    IF (l_bclv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_bclv_rec.attribute15 := NULL;
    END IF;
    IF (l_bclv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.created_by := NULL;
    END IF;
    IF (l_bclv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_bclv_rec.creation_date := NULL;
    END IF;
    IF (l_bclv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.last_updated_by := NULL;
    END IF;
    IF (l_bclv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_bclv_rec.last_update_date := NULL;
    END IF;
    IF (l_bclv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_bclv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_bclv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
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


PROCEDURE validate_cle_id(x_return_status OUT NOCOPY varchar2,
					 P_cle_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_cle_Csr Is
  	  select 'x'
	  from OKC_K_LINES_V
  	  where id = P_cle_id;

Begin
   If p_cle_id  = OKC_API.G_MISS_NUM OR
      p_cle_id  IS NULL
   Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cle_id');

     l_return_status := OKC_API.G_RET_STS_ERROR;
     RAISE G_EXCEPTION_HALT_VALIDATION;
   End If;

   If (p_cle_id <> OKC_API.G_MISS_NUM and
  	   p_cle_id IS NOT NULL)
   Then
       Open l_cle_csr;
       Fetch l_cle_csr Into l_dummy_var;
       Close l_cle_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'cle_id ');

	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
       End If;
   End If;
  ---------giving prob so commented
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
  END validate_cle_id;


PROCEDURE validate_btn_id(x_return_status OUT NOCOPY varchar2,
					 P_btn_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

  ------giving prob so commented
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
  END validate_btn_id;



PROCEDURE validate_Date_Billed_from(	x_return_status OUT NOCOPY varchar2,
							 P_Date_Billed_from IN  DATE)
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


  END validate_Date_Billed_from;


PROCEDURE validate_Date_Billed_to(	x_return_status OUT NOCOPY varchar2,
							 P_Date_Billed_to IN  DATE)
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


  END validate_Date_Billed_to;


PROCEDURE validate_Date_Next_Invoice(	x_return_status OUT NOCOPY varchar2,
							 P_Date_Next_Invoice IN  DATE)
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


  END validate_Date_Next_Invoice;





PROCEDURE validate_Amount(	x_return_status OUT NOCOPY varchar2,
					P_amount IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'Amount'
            ,p_col_value     => P_amount
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
                          p_token2_value => 'Amount Length');


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
  END validate_Amount;

PROCEDURE validate_Bill_Action (	x_return_status OUT NOCOPY varchar2,
							 P_Bill_Action IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;



  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'Bill_Action'
            ,p_col_value     => P_Bill_Action
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
                          p_token2_value => 'Bill_Action length');


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
  END validate_Bill_Action;

PROCEDURE validate_sent_yn (	x_return_status OUT NOCOPY varchar2,
							 p_sent_yn IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;



  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'Sent_yn'
            ,p_col_value     => P_sent_yn
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
                          p_token2_value => 'sent_yn');


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
  END validate_sent_yn;


  PROCEDURE validate_currency_code (	x_return_status OUT NOCOPY varchar2,
							 p_currency_code IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;



  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
	     p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'currency_code'
            ,p_col_value     => P_currency_code
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
                          p_token2_value => 'currency_code');


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
  END validate_currency_code;

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


PROCEDURE validate_attribute_category(	x_return_status OUT NOCOPY varchar2,
							 P_attribute_category IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility

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
  END validate_attribute_category;


PROCEDURE validate_attribute1(	x_return_status OUT NOCOPY varchar2,
							 P_attribute1 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute1'
            ,p_col_value     => p_attribute1
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
                          p_token2_value => 'attribute 1 Length');


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
  END validate_attribute1;
PROCEDURE validate_attribute2(	x_return_status OUT NOCOPY varchar2,
							 P_attribute2 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute2'
            ,p_col_value     => p_attribute2
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
                          p_token2_value => 'attribute 2 Length');

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
  END validate_attribute2;


PROCEDURE validate_attribute3(	x_return_status OUT NOCOPY varchar2,
							 P_attribute3 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute3'
            ,p_col_value     => p_attribute3
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
                          p_token2_value => 'attribute 3 Length');

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
  END validate_attribute3;

PROCEDURE validate_attribute4 (x_return_status OUT NOCOPY varchar2,
							 P_attribute4 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute4'
            ,p_col_value     => p_attribute4
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
                          p_token2_value => 'attribute 4 Length');

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
  END validate_attribute4;


PROCEDURE validate_attribute5(	x_return_status OUT NOCOPY varchar2,
							 P_attribute5 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute5'
            ,p_col_value     => p_attribute5
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
                          p_token2_value => 'attribute 5 Length');

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
  END validate_attribute5;


PROCEDURE validate_attribute6(	x_return_status OUT NOCOPY varchar2,
							 P_attribute6 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute6'
            ,p_col_value     => p_attribute6
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
                          p_token2_value => 'attribute 6 Length');

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
  END validate_attribute6;


PROCEDURE validate_attribute7(	x_return_status OUT NOCOPY varchar2,
							 P_attribute7 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute7'
            ,p_col_value     => p_attribute7
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
                          p_token2_value => 'attribute 7 Length');

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
  END validate_attribute7;



PROCEDURE validate_attribute8 (x_return_status OUT NOCOPY varchar2,
							 P_attribute8 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute8'
            ,p_col_value     => p_attribute8
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
                          p_token2_value => 'attribute 8 Length');

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
  END validate_attribute8;



PROCEDURE validate_attribute9(	x_return_status OUT NOCOPY varchar2,
							 P_attribute9 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute9'
            ,p_col_value     => p_attribute9
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
                          p_token2_value => 'attribute 9 Length');

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
  END validate_attribute9;


PROCEDURE validate_attribute10(	x_return_status OUT NOCOPY varchar2,
							 P_attribute10 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute10'
            ,p_col_value     => p_attribute10
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
                          p_token2_value => 'attribute 10 Length');

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
  END validate_attribute10;



PROCEDURE validate_attribute11(	x_return_status OUT NOCOPY varchar2,
							 P_attribute11 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute11'
            ,p_col_value     => p_attribute11
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
                          p_token2_value => 'attribute 11 Length');

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
  END validate_attribute11;




PROCEDURE validate_attribute12(	x_return_status OUT NOCOPY varchar2,
							 P_attribute12 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute12'
            ,p_col_value     => p_attribute12
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
                          p_token2_value => 'attribute 12 Length');

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
  END validate_attribute12;




PROCEDURE validate_attribute13(	x_return_status OUT NOCOPY varchar2,
							 P_attribute13 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute13'
            ,p_col_value     => p_attribute13
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
                          p_token2_value => 'attribute 13 Length');

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
  END validate_attribute13;




PROCEDURE validate_attribute14(	x_return_status OUT NOCOPY varchar2,
							 P_attribute14 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute14'
            ,p_col_value     => p_attribute14
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
                          p_token2_value => 'attribute 14 Length');

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
  END validate_attribute14;



PROCEDURE validate_attribute15(	x_return_status OUT NOCOPY varchar2,
							 P_attribute15 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_CONT_LINES_V'
            ,p_col_name      => 'attribute15'
            ,p_col_value     => p_attribute15
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
                          p_token2_value => 'attribute 15 Length');

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
  END validate_attribute15;

---------------------------------------------------
  -- Validate_Attributes for:OKS_BILL_CONT_LINES_V --
  ---------------------------------------------------
 FUNCTION Validate_Attributes (
    p_bclv_rec IN  bclv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_BILL_CONT_LINES_V',x_return_status);

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
    validate_id(x_return_status, p_bclv_rec.id);

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
    validate_objvernum(x_return_status, p_bclv_rec.object_version_number);

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
    --Cle_ID
	 validate_cle_id(x_return_status, p_bclv_rec.cle_id);
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

	--btn_id

 	validate_btn_id(x_return_status, p_bclv_rec.btn_id);
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

	--DATE_BILLED_FROM
	 validate_date_billed_from(x_return_status, p_bclv_rec.date_billed_from);

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

	--DATE_BILLED_TO
	 validate_date_billed_to(x_return_status, p_bclv_rec.date_billed_to);

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


	--DATE_NEXT_INVOICE
		validate_date_next_invoice(x_return_status, p_bclv_rec.date_next_invoice);
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

	--AMOUNT
		validate_amount(x_return_status, p_bclv_rec.amount);

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


	--BILL_ACTION
		validate_bill_action(x_return_status, p_bclv_rec.bill_action);
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

	--sent_yn
		validate_sent_yn(x_return_status, p_bclv_rec.sent_yn);
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

      --currency_code
                validate_currency_code(x_return_status, p_bclv_rec.currency_code);
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

	--ATTRIBUTE_CATEGORY
		validate_attribute_category(x_return_status, p_bclv_rec.attribute_category);

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


	--ATTRIBUTE1

		validate_attribute1(x_return_status, p_bclv_rec.attribute1);

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

	--ATTRIBUTE2

		validate_attribute2(x_return_status, p_bclv_rec.attribute2);

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


--ATTRIBUTE3

		validate_attribute3(x_return_status, p_bclv_rec.attribute3);

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


--ATTRIBUTE4
		validate_attribute4(x_return_status, p_bclv_rec.attribute4);

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


	--ATTRIBUTE5
		validate_attribute5(x_return_status, p_bclv_rec.attribute5);

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


	--ATTRIBUTE6

		validate_attribute6(x_return_status, p_bclv_rec.attribute6);

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


	--ATTRIBUTE7

		validate_attribute7(x_return_status, p_bclv_rec.attribute7);

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


	--ATTRIBUTE8
		validate_attribute8(x_return_status, p_bclv_rec.attribute8);

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


	--ATTRIBUTE9
		validate_attribute9(x_return_status, p_bclv_rec.attribute9);

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


	--ATTRIBUTE10

		validate_attribute10(x_return_status, p_bclv_rec.attribute10);

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


	--ATTRIBUTE11

		validate_attribute11(x_return_status, p_bclv_rec.attribute11);

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


	--ATTRIBUTE12

		validate_attribute12(x_return_status, p_bclv_rec.attribute12);

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


	--ATTRIBUTE13
		validate_attribute13(x_return_status, p_bclv_rec.attribute13);

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


	--ATTRIBUTE14

		validate_attribute14(x_return_status, p_bclv_rec.attribute14);

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

	--ATTRIBUTE15

		validate_attribute15(x_return_status, p_bclv_rec.attribute15);

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
  ---------------------------------------------------
  -- Validate_Attributes for:OKS_BILL_CONT_LINES_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_bclv_rec IN  bclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_bclv_rec.id = OKC_API.G_MISS_NUM OR
       p_bclv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bclv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_bclv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bclv_rec.cle_id = OKC_API.G_MISS_NUM OR
          p_bclv_rec.cle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cle_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bclv_rec.date_billed_from = OKC_API.G_MISS_DATE OR
          p_bclv_rec.date_billed_from IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_billed_from');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bclv_rec.date_billed_to = OKC_API.G_MISS_DATE OR
          p_bclv_rec.date_billed_to IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_billed_to');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bclv_rec.sent_yn = OKC_API.G_MISS_CHAR OR
          p_bclv_rec.sent_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sent_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
*/
  -----------------------------------------------
  -- Validate_Record for:OKS_BILL_CONT_LINES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_bclv_rec IN bclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_bclv_rec IN bclv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
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
      CURSOR okc_clev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              CHR_ID,
              CLE_ID,
              LSE_ID,
              LINE_NUMBER,
              STS_CODE,
              DISPLAY_SEQUENCE,
              TRN_CODE,
              DNZ_CHR_ID,
              COMMENTS,
              ITEM_DESCRIPTION,
              HIDDEN_IND,
              PRICE_UNIT,
              PRICE_UNIT_PERCENT,
              PRICE_NEGOTIATED,
              PRICE_LEVEL_IND,
              INVOICE_LINE_LEVEL_IND,
              DPAS_RATING,
              BLOCK23TEXT,
              EXCEPTION_YN,
              TEMPLATE_USED,
              DATE_TERMINATED,
              NAME,
              START_DATE,
              END_DATE,
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
              PRICE_TYPE,
              --UOM_CODE,
              CURRENCY_CODE,
              LAST_UPDATE_LOGIN
        FROM Okc_K_Lines_V
       WHERE okc_k_lines_v.id     = p_id;
      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_bclv_rec.BTN_ID IS NOT NULL and p_bclv_rec.BTN_ID not in (-55,-44))
      THEN
        OPEN okc_btnv_pk_csr(p_bclv_rec.BTN_ID);
        FETCH okc_btnv_pk_csr INTO l_okc_btnv_pk;
        l_row_notfound := okc_btnv_pk_csr%NOTFOUND;
        CLOSE okc_btnv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BTN_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_bclv_rec.CLE_ID IS NOT NULL)
      THEN
        OPEN okc_clev_pk_csr(p_bclv_rec.CLE_ID);
        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
        CLOSE okc_clev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_bclv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN bclv_rec_type,
    p_to	OUT NOCOPY bcl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.btn_id := p_from.btn_id;
    p_to.date_billed_from := p_from.date_billed_from;
    p_to.date_billed_to := p_from.date_billed_to;
    p_to.sent_yn := p_from.sent_yn;
    p_to.currency_code := p_from.currency_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.amount := p_from.amount;
    p_to.bill_action := p_from.bill_action;
    p_to.date_next_invoice := p_from.date_next_invoice;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN bcl_rec_type,
    p_to	OUT NOCOPY bclv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.btn_id := p_from.btn_id;
    p_to.date_billed_from := p_from.date_billed_from;
    p_to.date_billed_to := p_from.date_billed_to;
    p_to.sent_yn := p_from.sent_yn;
    p_to.currency_code := p_from.currency_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.amount := p_from.amount;
    p_to.bill_action := p_from.bill_action;
    p_to.date_next_invoice := p_from.date_next_invoice;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKS_BILL_CONT_LINES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bclv_rec                     bclv_rec_type := p_bclv_rec;
    l_bcl_rec                      bcl_rec_type;
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
    l_return_status := Validate_Attributes(l_bclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_bclv_rec);
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
  -- PL/SQL TBL validate_row for:BCLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bclv_tbl.COUNT > 0) THEN
      i := p_bclv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bclv_rec                     => p_bclv_tbl(i));
        EXIT WHEN (i = p_bclv_tbl.LAST);
        i := p_bclv_tbl.NEXT(i);
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
  ----------------------------------------
  -- insert_row for:OKS_BILL_CONT_LINES --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bcl_rec                      IN bcl_rec_type,
    x_bcl_rec                      OUT NOCOPY bcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bcl_rec                      bcl_rec_type := p_bcl_rec;
    l_def_bcl_rec                  bcl_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKS_BILL_CONT_LINES --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_bcl_rec IN  bcl_rec_type,
      x_bcl_rec OUT NOCOPY bcl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bcl_rec := p_bcl_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'inside insert bcl procedure');

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    FND_FILE.PUT_LINE( FND_FILE.LOG, 'before setting item attributes');

    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_bcl_rec,                         -- IN
      l_bcl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    FND_FILE.PUT_LINE( FND_FILE.LOG, 'for id ' || l_bcl_rec.id ||'cle '|| l_bcl_rec.cle_id ||'btn '|| l_bcl_rec.btn_id);
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'date from ' || l_bcl_rec.date_billed_from ||'To  '|| l_bcl_rec.date_billed_to);
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'sent yn ' || l_bcl_rec.sent_yn ||'Cur  '|| l_bcl_rec.currency_code);
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'ver ' || l_bcl_rec.object_version_number ||'cr by '|| l_bcl_rec.created_by);
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'cr dt ' || l_bcl_rec.creation_date ||'up by '|| l_bcl_rec.last_updated_by);
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'ls up dt ' || l_bcl_rec.last_update_date ||'Amt '||l_bcl_rec.amount);
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'ls up lg ' || l_bcl_rec.last_update_login ||'At cg '||l_bcl_rec.attribute_category);


    INSERT INTO OKS_BILL_CONT_LINES(
        id,
        cle_id,
        btn_id,
        date_billed_from,
        date_billed_to,
        sent_yn,
        currency_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        amount,
        bill_action,
        date_next_invoice,
        last_update_login,
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
        attribute15)
      VALUES (
        l_bcl_rec.id,
        l_bcl_rec.cle_id,
        l_bcl_rec.btn_id,
        l_bcl_rec.date_billed_from,
        l_bcl_rec.date_billed_to,
        l_bcl_rec.sent_yn,
        l_bcl_rec.currency_code,
        l_bcl_rec.object_version_number,
        l_bcl_rec.created_by,
        l_bcl_rec.creation_date,
        l_bcl_rec.last_updated_by,
        l_bcl_rec.last_update_date,
        l_bcl_rec.amount,
        l_bcl_rec.bill_action,
        l_bcl_rec.date_next_invoice,
        l_bcl_rec.last_update_login,
        l_bcl_rec.attribute_category,
        l_bcl_rec.attribute1,
        l_bcl_rec.attribute2,
        l_bcl_rec.attribute3,
        l_bcl_rec.attribute4,
        l_bcl_rec.attribute5,
        l_bcl_rec.attribute6,
        l_bcl_rec.attribute7,
        l_bcl_rec.attribute8,
        l_bcl_rec.attribute9,
        l_bcl_rec.attribute10,
        l_bcl_rec.attribute11,
        l_bcl_rec.attribute12,
        l_bcl_rec.attribute13,
        l_bcl_rec.attribute14,
        l_bcl_rec.attribute15);
    -- Set OUT values
    x_bcl_rec := l_bcl_rec;
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
  ------------------------------------------
  -- insert_row for:OKS_BILL_CONT_LINES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type,
    x_bclv_rec                     OUT NOCOPY bclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bclv_rec                     bclv_rec_type;
    l_def_bclv_rec                 bclv_rec_type;
    l_bcl_rec                      bcl_rec_type;
    lx_bcl_rec                     bcl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bclv_rec	IN bclv_rec_type
    ) RETURN bclv_rec_type IS
      l_bclv_rec	bclv_rec_type := p_bclv_rec;
    BEGIN
      l_bclv_rec.CREATION_DATE := SYSDATE;
      l_bclv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_bclv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bclv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bclv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bclv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKS_BILL_CONT_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_bclv_rec IN  bclv_rec_type,
      x_bclv_rec OUT NOCOPY bclv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bclv_rec := p_bclv_rec;
      x_bclv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_bclv_rec := null_out_defaults(p_bclv_rec);
    -- Set primary key value
    l_bclv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_bclv_rec,                        -- IN
      l_def_bclv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bclv_rec := fill_who_columns(l_def_bclv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bclv_rec, l_bcl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bcl_rec,
      lx_bcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bcl_rec, l_def_bclv_rec);
    -- Set OUT values
    x_bclv_rec := l_def_bclv_rec;
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
  -- PL/SQL TBL insert_row for:BCLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type,
    x_bclv_tbl                     OUT NOCOPY bclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bclv_tbl.COUNT > 0) THEN
      i := p_bclv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bclv_rec                     => p_bclv_tbl(i),
          x_bclv_rec                     => x_bclv_tbl(i));
        EXIT WHEN (i = p_bclv_tbl.LAST);
        i := p_bclv_tbl.NEXT(i);
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
  --------------------------------------
  -- lock_row for:OKS_BILL_CONT_LINES --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bcl_rec                      IN bcl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bcl_rec IN bcl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_CONT_LINES
     WHERE ID = p_bcl_rec.id
       AND OBJECT_VERSION_NUMBER = p_bcl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_bcl_rec IN bcl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_CONT_LINES
    WHERE ID = p_bcl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_BILL_CONT_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_BILL_CONT_LINES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_bcl_rec);
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
      OPEN lchk_csr(p_bcl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_bcl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_bcl_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKS_BILL_CONT_LINES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bcl_rec                      bcl_rec_type;
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
    migrate(p_bclv_rec, l_bcl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bcl_rec
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
  -- PL/SQL TBL lock_row for:BCLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bclv_tbl.COUNT > 0) THEN
      i := p_bclv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bclv_rec                     => p_bclv_tbl(i));
        EXIT WHEN (i = p_bclv_tbl.LAST);
        i := p_bclv_tbl.NEXT(i);
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
  ----------------------------------------
  -- update_row for:OKS_BILL_CONT_LINES --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bcl_rec                      IN bcl_rec_type,
    x_bcl_rec                      OUT NOCOPY bcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bcl_rec                      bcl_rec_type := p_bcl_rec;
    l_def_bcl_rec                  bcl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bcl_rec	IN bcl_rec_type,
      x_bcl_rec	OUT NOCOPY bcl_rec_type
    ) RETURN VARCHAR2 IS
      l_bcl_rec                      bcl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bcl_rec := p_bcl_rec;
      -- Get current database values
      l_bcl_rec := get_rec(p_bcl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bcl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.id := l_bcl_rec.id;
      END IF;
      IF (x_bcl_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.cle_id := l_bcl_rec.cle_id;
      END IF;
      IF (x_bcl_rec.btn_id = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.btn_id := l_bcl_rec.btn_id;
      END IF;
      IF (x_bcl_rec.date_billed_from = OKC_API.G_MISS_DATE)
      THEN
        x_bcl_rec.date_billed_from := l_bcl_rec.date_billed_from;
      END IF;
      IF (x_bcl_rec.date_billed_to = OKC_API.G_MISS_DATE)
      THEN
        x_bcl_rec.date_billed_to := l_bcl_rec.date_billed_to;
      END IF;
      IF (x_bcl_rec.sent_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.sent_yn := l_bcl_rec.sent_yn;
      END IF;
      IF (x_bcl_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.currency_code := l_bcl_rec.currency_code;
      END IF;
      IF (x_bcl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.object_version_number := l_bcl_rec.object_version_number;
      END IF;
      IF (x_bcl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.created_by := l_bcl_rec.created_by;
      END IF;
      IF (x_bcl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_bcl_rec.creation_date := l_bcl_rec.creation_date;
      END IF;
      IF (x_bcl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.last_updated_by := l_bcl_rec.last_updated_by;
      END IF;
      IF (x_bcl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_bcl_rec.last_update_date := l_bcl_rec.last_update_date;
      END IF;
      IF (x_bcl_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.amount := l_bcl_rec.amount;
      END IF;
      IF (x_bcl_rec.bill_action = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.bill_action := l_bcl_rec.bill_action;
      END IF;
      IF (x_bcl_rec.date_next_invoice = OKC_API.G_MISS_DATE)
      THEN
        x_bcl_rec.date_next_invoice := l_bcl_rec.date_next_invoice;
      END IF;
      IF (x_bcl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_bcl_rec.last_update_login := l_bcl_rec.last_update_login;
      END IF;
      IF (x_bcl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute_category := l_bcl_rec.attribute_category;
      END IF;
      IF (x_bcl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute1 := l_bcl_rec.attribute1;
      END IF;
      IF (x_bcl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute2 := l_bcl_rec.attribute2;
      END IF;
      IF (x_bcl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute3 := l_bcl_rec.attribute3;
      END IF;
      IF (x_bcl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute4 := l_bcl_rec.attribute4;
      END IF;
      IF (x_bcl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute5 := l_bcl_rec.attribute5;
      END IF;
      IF (x_bcl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute6 := l_bcl_rec.attribute6;
      END IF;
      IF (x_bcl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute7 := l_bcl_rec.attribute7;
      END IF;
      IF (x_bcl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute8 := l_bcl_rec.attribute8;
      END IF;
      IF (x_bcl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute9 := l_bcl_rec.attribute9;
      END IF;
      IF (x_bcl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute10 := l_bcl_rec.attribute10;
      END IF;
      IF (x_bcl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute11 := l_bcl_rec.attribute11;
      END IF;
      IF (x_bcl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute12 := l_bcl_rec.attribute12;
      END IF;
      IF (x_bcl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute13 := l_bcl_rec.attribute13;
      END IF;
      IF (x_bcl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute14 := l_bcl_rec.attribute14;
      END IF;
      IF (x_bcl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_bcl_rec.attribute15 := l_bcl_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKS_BILL_CONT_LINES --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_bcl_rec IN  bcl_rec_type,
      x_bcl_rec OUT NOCOPY bcl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bcl_rec := p_bcl_rec;
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
      p_bcl_rec,                         -- IN
      l_bcl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bcl_rec, l_def_bcl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_BILL_CONT_LINES
    SET CLE_ID = l_def_bcl_rec.cle_id,
        BTN_ID = l_def_bcl_rec.btn_id,
        DATE_BILLED_FROM = l_def_bcl_rec.date_billed_from,
        DATE_BILLED_TO = l_def_bcl_rec.date_billed_to,
        SENT_YN = l_def_bcl_rec.sent_yn,
        CURRENCY_CODE = l_def_bcl_rec.currency_code,
        OBJECT_VERSION_NUMBER = l_def_bcl_rec.object_version_number,
        CREATED_BY = l_def_bcl_rec.created_by,
        CREATION_DATE = l_def_bcl_rec.creation_date,
        LAST_UPDATED_BY = l_def_bcl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bcl_rec.last_update_date,
        AMOUNT = l_def_bcl_rec.amount,
        BILL_ACTION = l_def_bcl_rec.bill_action,
        DATE_NEXT_INVOICE = l_def_bcl_rec.date_next_invoice,
        LAST_UPDATE_LOGIN = l_def_bcl_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_bcl_rec.attribute_category,
        ATTRIBUTE1 = l_def_bcl_rec.attribute1,
        ATTRIBUTE2 = l_def_bcl_rec.attribute2,
        ATTRIBUTE3 = l_def_bcl_rec.attribute3,
        ATTRIBUTE4 = l_def_bcl_rec.attribute4,
        ATTRIBUTE5 = l_def_bcl_rec.attribute5,
        ATTRIBUTE6 = l_def_bcl_rec.attribute6,
        ATTRIBUTE7 = l_def_bcl_rec.attribute7,
        ATTRIBUTE8 = l_def_bcl_rec.attribute8,
        ATTRIBUTE9 = l_def_bcl_rec.attribute9,
        ATTRIBUTE10 = l_def_bcl_rec.attribute10,
        ATTRIBUTE11 = l_def_bcl_rec.attribute11,
        ATTRIBUTE12 = l_def_bcl_rec.attribute12,
        ATTRIBUTE13 = l_def_bcl_rec.attribute13,
        ATTRIBUTE14 = l_def_bcl_rec.attribute14,
        ATTRIBUTE15 = l_def_bcl_rec.attribute15
    WHERE ID = l_def_bcl_rec.id;

    x_bcl_rec := l_def_bcl_rec;
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
  ------------------------------------------
  -- update_row for:OKS_BILL_CONT_LINES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type,
    x_bclv_rec                     OUT NOCOPY bclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bclv_rec                     bclv_rec_type := p_bclv_rec;
    l_def_bclv_rec                 bclv_rec_type;
    l_bcl_rec                      bcl_rec_type;
    lx_bcl_rec                     bcl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bclv_rec	IN bclv_rec_type
    ) RETURN bclv_rec_type IS
      l_bclv_rec	bclv_rec_type := p_bclv_rec;
    BEGIN
      l_bclv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bclv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bclv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bclv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bclv_rec	IN bclv_rec_type,
      x_bclv_rec	OUT NOCOPY bclv_rec_type
    ) RETURN VARCHAR2 IS
      l_bclv_rec                     bclv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bclv_rec := p_bclv_rec;
      -- Get current database values
      l_bclv_rec := get_rec(p_bclv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bclv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.id := l_bclv_rec.id;
      END IF;
      IF (x_bclv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.object_version_number := l_bclv_rec.object_version_number;
      END IF;
      IF (x_bclv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.cle_id := l_bclv_rec.cle_id;
      END IF;
      IF (x_bclv_rec.btn_id = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.btn_id := l_bclv_rec.btn_id;
      END IF;
      IF (x_bclv_rec.date_billed_from = OKC_API.G_MISS_DATE)
      THEN
        x_bclv_rec.date_billed_from := l_bclv_rec.date_billed_from;
      END IF;
      IF (x_bclv_rec.date_billed_to = OKC_API.G_MISS_DATE)
      THEN
        x_bclv_rec.date_billed_to := l_bclv_rec.date_billed_to;
      END IF;
      IF (x_bclv_rec.date_next_invoice = OKC_API.G_MISS_DATE)
      THEN
        x_bclv_rec.date_next_invoice := l_bclv_rec.date_next_invoice;
      END IF;
      IF (x_bclv_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.amount := l_bclv_rec.amount;
      END IF;
      IF (x_bclv_rec.sent_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.sent_yn := l_bclv_rec.sent_yn;
      END IF;
      IF (x_bclv_rec.currency_code = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.currency_code := l_bclv_rec.currency_code;
      END IF;
      IF (x_bclv_rec.bill_action = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.bill_action := l_bclv_rec.bill_action;
      END IF;
      IF (x_bclv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute_category := l_bclv_rec.attribute_category;
      END IF;
      IF (x_bclv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute1 := l_bclv_rec.attribute1;
      END IF;
      IF (x_bclv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute2 := l_bclv_rec.attribute2;
      END IF;
      IF (x_bclv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute3 := l_bclv_rec.attribute3;
      END IF;
      IF (x_bclv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute4 := l_bclv_rec.attribute4;
      END IF;
      IF (x_bclv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute5 := l_bclv_rec.attribute5;
      END IF;
      IF (x_bclv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute6 := l_bclv_rec.attribute6;
      END IF;
      IF (x_bclv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute7 := l_bclv_rec.attribute7;
      END IF;
      IF (x_bclv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute8 := l_bclv_rec.attribute8;
      END IF;
      IF (x_bclv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute9 := l_bclv_rec.attribute9;
      END IF;
      IF (x_bclv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute10 := l_bclv_rec.attribute10;
      END IF;
      IF (x_bclv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute11 := l_bclv_rec.attribute11;
      END IF;
      IF (x_bclv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute12 := l_bclv_rec.attribute12;
      END IF;
      IF (x_bclv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute13 := l_bclv_rec.attribute13;
      END IF;
      IF (x_bclv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute14 := l_bclv_rec.attribute14;
      END IF;
      IF (x_bclv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_bclv_rec.attribute15 := l_bclv_rec.attribute15;
      END IF;
      IF (x_bclv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.created_by := l_bclv_rec.created_by;
      END IF;
      IF (x_bclv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_bclv_rec.creation_date := l_bclv_rec.creation_date;
      END IF;
      IF (x_bclv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.last_updated_by := l_bclv_rec.last_updated_by;
      END IF;
      IF (x_bclv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_bclv_rec.last_update_date := l_bclv_rec.last_update_date;
      END IF;
      IF (x_bclv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_bclv_rec.last_update_login := l_bclv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKS_BILL_CONT_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_bclv_rec IN  bclv_rec_type,
      x_bclv_rec OUT NOCOPY bclv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bclv_rec := p_bclv_rec;
      x_bclv_rec.OBJECT_VERSION_NUMBER := NVL(x_bclv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_bclv_rec,                        -- IN
      l_bclv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bclv_rec, l_def_bclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bclv_rec := fill_who_columns(l_def_bclv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bclv_rec, l_bcl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bcl_rec,
      lx_bcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bcl_rec, l_def_bclv_rec);
    x_bclv_rec := l_def_bclv_rec;
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
  -- PL/SQL TBL update_row for:BCLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type,
    x_bclv_tbl                     OUT NOCOPY bclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bclv_tbl.COUNT > 0) THEN
      i := p_bclv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bclv_rec                     => p_bclv_tbl(i),
          x_bclv_rec                     => x_bclv_tbl(i));
        EXIT WHEN (i = p_bclv_tbl.LAST);
        i := p_bclv_tbl.NEXT(i);
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
  ----------------------------------------
  -- delete_row for:OKS_BILL_CONT_LINES --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bcl_rec                      IN bcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bcl_rec                      bcl_rec_type:= p_bcl_rec;
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
    DELETE FROM OKS_BILL_CONT_LINES
     WHERE ID = l_bcl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKS_BILL_CONT_LINES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bclv_rec                     bclv_rec_type := p_bclv_rec;
    l_bcl_rec                      bcl_rec_type;
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
    migrate(l_bclv_rec, l_bcl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bcl_rec
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
  -- PL/SQL TBL delete_row for:BCLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bclv_tbl.COUNT > 0) THEN
      i := p_bclv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bclv_rec                     => p_bclv_tbl(i));
        EXIT WHEN (i = p_bclv_tbl.LAST);
        i := p_bclv_tbl.NEXT(i);
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


PROCEDURE INSERT_ROW_UPG(p_bclv_tbl bclv_tbl_type) IS
  l_tabsize NUMBER := p_bclv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
TYPE Var720TabTyp IS TABLE OF Varchar2(720)
     INDEX BY BINARY_INTEGER;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_btn_id                        OKC_DATATYPES.NumberTabTyp;
  in_date_billed_from              OKC_DATATYPES.DateTabTyp;
  in_date_billed_to                OKC_DATATYPES.DateTabTyp;
  in_sent_yn                       OKC_DATATYPES.Var3TabTyp;
  in_currency_code                 OKC_DATATYPES.Var15TabTyp;
  in_amount                        OKC_DATATYPES.NumberTabTyp;
  in_bill_action                   Var9TabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_date_next_invoice             OKC_DATATYPES.DateTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i number;
  j number;
BEGIN
  i := p_bclv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                            (j) := p_bclv_tbl(i).id;
    in_cle_id                        (j) := p_bclv_tbl(i).cle_id;
    in_btn_id                        (j) := p_bclv_tbl(i).btn_id;
    in_date_billed_from              (j) := p_bclv_tbl(i).date_billeD_from;
    in_date_billed_to                (j) := p_bclv_tbl(i).date_billed_to;
    in_sent_yn                       (j) := p_bclv_tbl(i).sent_yn;
    in_currency_code                 (j) := p_bclv_tbl(i).currency_code;
    in_amount                        (j) := p_bclv_tbl(i).amount;
    in_bill_action                   (j) := p_bclv_tbl(i).bill_action;
    in_object_version_number         (j) := p_bclv_tbl(i).object_version_number;
    in_date_next_invoice             (j) := p_bclv_tbl(i).date_next_invoice;
    in_attribute_category            (j) := p_bclv_tbl(i).attribute_category;
    in_attribute1                    (j) := p_bclv_tbl(i).attribute1;
    in_attribute2                    (j) := p_bclv_tbl(i).attribute2;
    in_attribute3                    (j) := p_bclv_tbl(i).attribute3;
    in_attribute4                    (j) := p_bclv_tbl(i).attribute4;
    in_attribute5                    (j) := p_bclv_tbl(i).attribute5;
    in_attribute6                    (j) := p_bclv_tbl(i).attribute6;
    in_attribute7                    (j) := p_bclv_tbl(i).attribute7;
    in_attribute8                    (j) := p_bclv_tbl(i).attribute8;
    in_attribute9                    (j) := p_bclv_tbl(i).attribute9;
    in_attribute10                   (j) := p_bclv_tbl(i).attribute10;
    in_attribute11                   (j) := p_bclv_tbl(i).attribute11;
    in_attribute12                   (j) := p_bclv_tbl(i).attribute12;
    in_attribute13                   (j) := p_bclv_tbl(i).attribute13;
    in_attribute14                   (j) := p_bclv_tbl(i).attribute14;
    in_attribute15                   (j) := p_bclv_tbl(i).attribute15;
    in_created_by                    (j) := p_bclv_tbl(i).created_by;
    in_creation_date                 (j) := p_bclv_tbl(i).creation_date;
    in_last_updated_by               (j) := p_bclv_tbl(i).last_updated_by;
    in_last_update_date              (j) := p_bclv_tbl(i).last_update_date;
    in_last_update_login             (j) := p_bclv_tbl(i).last_update_login;

    i:=p_bclv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKS_BILL_CONT_LINES
      (
        id ,
        cle_id,
        btn_id ,
        date_billed_from ,
        date_billed_to,
        sent_yn,
        currency_code,
        object_version_number,
        amount,
        bill_action ,
        date_next_invoice ,
        attribute_category ,
        attribute1 ,
        attribute2 ,
        attribute3 ,
        attribute4 ,
        attribute5 ,
        attribute6 ,
        attribute7 ,
        attribute8 ,
        attribute9 ,
        attribute10 ,
        attribute11 ,
        attribute12 ,
        attribute13 ,
        attribute14 ,
        attribute15 ,
        created_by ,
        creation_date ,
        last_updated_by ,
        last_update_date ,
        last_update_login
     )
     VALUES (
        in_id(i),
        in_cle_id(i),
        in_btn_id(i),
        in_date_billed_from(i),
        in_date_billed_to(i),
        in_sent_yn(i),
        in_currency_code(i),
        in_object_version_number(i),
        in_amount(i),
        in_bill_action (i),
        in_date_next_invoice(i),
        in_attribute_category(i),
        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i),
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
END OKS_BCL_PVT;

/
