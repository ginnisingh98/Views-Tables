--------------------------------------------------------
--  DDL for Package Body OKS_BSL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BSL_PVT" AS
/* $Header: OKSSBSLB.pls 120.0 2005/05/25 18:24:13 appldev noship $ */
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
  -- FUNCTION get_rec for: OKS_BILL_SUB_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bsl_rec                      IN bsl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bsl_rec_type IS
    CURSOR bsl_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            BCL_ID,
            CLE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            AVERAGE,
            AMOUNT,
            MANUAL_CREDIT,
            DATE_BILLED_FROM,
            DATE_BILLED_TO,
            DATE_TO_INTERFACE,
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
      FROM Oks_Bill_Sub_Lines
     WHERE oks_bill_sub_lines.id = p_id;
    l_bsl_pk                       bsl_pk_csr%ROWTYPE;
    l_bsl_rec                      bsl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN bsl_pk_csr (p_bsl_rec.id);
    FETCH bsl_pk_csr INTO
              l_bsl_rec.ID,
              l_bsl_rec.BCL_ID,
              l_bsl_rec.CLE_ID,
              l_bsl_rec.OBJECT_VERSION_NUMBER,
              l_bsl_rec.CREATED_BY,
              l_bsl_rec.CREATION_DATE,
              l_bsl_rec.LAST_UPDATED_BY,
              l_bsl_rec.LAST_UPDATE_DATE,
              l_bsl_rec.AVERAGE,
              l_bsl_rec.AMOUNT,
              l_bsl_rec.MANUAL_CREDIT,
              l_bsl_rec.DATE_BILLED_FROM,
              l_bsl_rec.DATE_BILLED_TO,
              l_bsl_rec.DATE_TO_INTERFACE,
              l_bsl_rec.LAST_UPDATE_LOGIN,
              l_bsl_rec.ATTRIBUTE_CATEGORY,
              l_bsl_rec.ATTRIBUTE1,
              l_bsl_rec.ATTRIBUTE2,
              l_bsl_rec.ATTRIBUTE3,
              l_bsl_rec.ATTRIBUTE4,
              l_bsl_rec.ATTRIBUTE5,
              l_bsl_rec.ATTRIBUTE6,
              l_bsl_rec.ATTRIBUTE7,
              l_bsl_rec.ATTRIBUTE8,
              l_bsl_rec.ATTRIBUTE9,
              l_bsl_rec.ATTRIBUTE10,
              l_bsl_rec.ATTRIBUTE11,
              l_bsl_rec.ATTRIBUTE12,
              l_bsl_rec.ATTRIBUTE13,
              l_bsl_rec.ATTRIBUTE14,
              l_bsl_rec.ATTRIBUTE15;
    x_no_data_found := bsl_pk_csr%NOTFOUND;
    CLOSE bsl_pk_csr;
    RETURN(l_bsl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bsl_rec                      IN bsl_rec_type
  ) RETURN bsl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bsl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILL_SUB_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bslv_rec                     IN bslv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bslv_rec_type IS
    CURSOR oks_bslv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            BCL_ID,
            CLE_ID,
            AVERAGE,
            AMOUNT,
            MANUAL_CREDIT,
            DATE_BILLED_FROM,
            DATE_BILLED_TO,
            DATE_TO_INTERFACE,
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
      FROM Oks_Bill_Sub_Lines_V
     WHERE oks_bill_sub_lines_v.id = p_id;
    l_oks_bslv_pk                  oks_bslv_pk_csr%ROWTYPE;
    l_bslv_rec                     bslv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_bslv_pk_csr (p_bslv_rec.id);
    FETCH oks_bslv_pk_csr INTO
              l_bslv_rec.ID,
              l_bslv_rec.OBJECT_VERSION_NUMBER,
              l_bslv_rec.BCL_ID,
              l_bslv_rec.CLE_ID,
              l_bslv_rec.AVERAGE,
              l_bslv_rec.AMOUNT,
              l_bslv_rec.MANUAL_CREDIT,
              l_bslv_rec.DATE_BILLED_FROM,
              l_bslv_rec.DATE_BILLED_TO,
              l_bslv_rec.DATE_TO_INTERFACE,
              l_bslv_rec.ATTRIBUTE_CATEGORY,
              l_bslv_rec.ATTRIBUTE1,
              l_bslv_rec.ATTRIBUTE2,
              l_bslv_rec.ATTRIBUTE3,
              l_bslv_rec.ATTRIBUTE4,
              l_bslv_rec.ATTRIBUTE5,
              l_bslv_rec.ATTRIBUTE6,
              l_bslv_rec.ATTRIBUTE7,
              l_bslv_rec.ATTRIBUTE8,
              l_bslv_rec.ATTRIBUTE9,
              l_bslv_rec.ATTRIBUTE10,
              l_bslv_rec.ATTRIBUTE11,
              l_bslv_rec.ATTRIBUTE12,
              l_bslv_rec.ATTRIBUTE13,
              l_bslv_rec.ATTRIBUTE14,
              l_bslv_rec.ATTRIBUTE15,
              l_bslv_rec.CREATED_BY,
              l_bslv_rec.CREATION_DATE,
              l_bslv_rec.LAST_UPDATED_BY,
              l_bslv_rec.LAST_UPDATE_DATE,
              l_bslv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := oks_bslv_pk_csr%NOTFOUND;
    CLOSE oks_bslv_pk_csr;
    RETURN(l_bslv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bslv_rec                     IN bslv_rec_type
  ) RETURN bslv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bslv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_BILL_SUB_LINES_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_bslv_rec	IN bslv_rec_type
  ) RETURN bslv_rec_type IS
    l_bslv_rec	bslv_rec_type := p_bslv_rec;
  BEGIN
    IF (l_bslv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.object_version_number := NULL;
    END IF;
    IF (l_bslv_rec.bcl_id = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.bcl_id := NULL;
    END IF;
    IF (l_bslv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.cle_id := NULL;
    END IF;
    IF (l_bslv_rec.average = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.average := NULL;
    END IF;
    IF (l_bslv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.amount := NULL;
    END IF;
    IF (l_bslv_rec.MANUAL_CREDIT = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.MANUAL_CREDIT := NULL;
    END IF;
    IF (l_bslv_rec.date_billed_from = OKC_API.G_MISS_DATE) THEN
      l_bslv_rec.date_billed_from := NULL;
    END IF;
    IF (l_bslv_rec.date_billed_to = OKC_API.G_MISS_DATE) THEN
      l_bslv_rec.date_billed_to := NULL;
    END IF;
    IF (l_bslv_rec.date_to_interface = OKC_API.G_MISS_DATE) THEN
      l_bslv_rec.date_to_interface := NULL;
    END IF;
    IF (l_bslv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute_category := NULL;
    END IF;
    IF (l_bslv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute1 := NULL;
    END IF;
    IF (l_bslv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute2 := NULL;
    END IF;
    IF (l_bslv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute3 := NULL;
    END IF;
    IF (l_bslv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute4 := NULL;
    END IF;
    IF (l_bslv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute5 := NULL;
    END IF;
    IF (l_bslv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute6 := NULL;
    END IF;
    IF (l_bslv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute7 := NULL;
    END IF;
    IF (l_bslv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute8 := NULL;
    END IF;
    IF (l_bslv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute9 := NULL;
    END IF;
    IF (l_bslv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute10 := NULL;
    END IF;
    IF (l_bslv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute11 := NULL;
    END IF;
    IF (l_bslv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute12 := NULL;
    END IF;
    IF (l_bslv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute13 := NULL;
    END IF;
    IF (l_bslv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute14 := NULL;
    END IF;
    IF (l_bslv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_bslv_rec.attribute15 := NULL;
    END IF;
    IF (l_bslv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.created_by := NULL;
    END IF;
    IF (l_bslv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_bslv_rec.creation_date := NULL;
    END IF;
    IF (l_bslv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.last_updated_by := NULL;
    END IF;
    IF (l_bslv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_bslv_rec.last_update_date := NULL;
    END IF;
    IF (l_bslv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_bslv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_bslv_rec);
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

PROCEDURE validate_bcl_id(x_return_status OUT NOCOPY varchar2,
					 P_bcl_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- call column length utility

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
  END validate_bcl_id;


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

PROCEDURE validate_average(	x_return_status OUT NOCOPY varchar2,
					P_average IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
            ,p_col_name      => 'Average'
            ,p_col_value     => P_average
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
                          p_token2_value => 'Average Length');


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
  END validate_average;


PROCEDURE validate_amount(	x_return_status OUT NOCOPY varchar2,
					P_amount IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
  END validate_amount;

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

 PROCEDURE validate_Date_to_Interface(      x_return_status OUT NOCOPY varchar2,
                                            P_Date_to_Interface IN  DATE)
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


  END validate_Date_to_Interface;

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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
  /*OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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
		 p_view_name     => 'OKS_BILL_SUB_LINES_V'
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

  --------------------------------------------------
  -- Validate_Attributes for:OKS_BILL_SUB_LINES_V --
  --------------------------------------------------
/*
  FUNCTION Validate_Attributes (
    p_bslv_rec IN  bslv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_bslv_rec.id = OKC_API.G_MISS_NUM OR
       p_bslv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bslv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_bslv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bslv_rec.cle_id = OKC_API.G_MISS_NUM OR
          p_bslv_rec.cle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cle_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bslv_rec.date_billed_from = OKC_API.G_MISS_DATE OR
          p_bslv_rec.date_billed_from IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_billed_from');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bslv_rec.date_billed_to = OKC_API.G_MISS_DATE OR
          p_bslv_rec.date_billed_to IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_billed_to');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

FUNCTION Validate_Attributes (
    p_bslv_rec IN  bslv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_BILL_SUB_LINES_V',x_return_status);

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
   validate_id(x_return_status, p_bslv_rec.id);

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

	--bcl_id
  validate_bcl_id(x_return_status, p_bslv_rec.bcl_id);
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
 validate_cle_id(x_return_status, p_bslv_rec.cle_id);

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
    validate_objvernum(x_return_status, p_bslv_rec.object_version_number);

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

    --Average
	validate_average (x_return_status, p_bslv_rec.average);

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
		validate_amount(x_return_status, p_bslv_rec.amount);

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
	 validate_date_billed_from(x_return_status, p_bslv_rec.date_billed_from);

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

  --DATE_TO_INTERFACE
         validate_date_to_interface(x_return_status, p_bslv_rec.date_to_interface);

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
	 validate_date_billed_to(x_return_status, p_bslv_rec.date_billed_to);

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

		validate_attribute_category(x_return_status, p_bslv_rec.attribute_category);

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

		validate_attribute1(x_return_status, p_bslv_rec.attribute1);

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

		validate_attribute2(x_return_status, p_bslv_rec.attribute2);

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

		validate_attribute3(x_return_status, p_bslv_rec.attribute3);

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
		validate_attribute4(x_return_status, p_bslv_rec.attribute4);

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
		validate_attribute5(x_return_status, p_bslv_rec.attribute5);

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

		validate_attribute6(x_return_status, p_bslv_rec.attribute6);

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

		validate_attribute7(x_return_status, p_bslv_rec.attribute7);

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
		validate_attribute8(x_return_status, p_bslv_rec.attribute8);

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
		validate_attribute9(x_return_status, p_bslv_rec.attribute9);

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

		validate_attribute10(x_return_status, p_bslv_rec.attribute10);

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

		validate_attribute11(x_return_status, p_bslv_rec.attribute11);

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

		validate_attribute12(x_return_status, p_bslv_rec.attribute12);

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
		validate_attribute13(x_return_status, p_bslv_rec.attribute13);

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

		validate_attribute14(x_return_status, p_bslv_rec.attribute14);

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

		validate_attribute15(x_return_status, p_bslv_rec.attribute15);

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

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKS_BILL_SUB_LINES_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_bslv_rec IN bslv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_bslv_rec IN bslv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
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
      IF (p_bslv_rec.BCL_ID IS NOT NULL)
      THEN
        OPEN okc_bclv_pk_csr(p_bslv_rec.BCL_ID);
        FETCH okc_bclv_pk_csr INTO l_okc_bclv_pk;
        l_row_notfound := okc_bclv_pk_csr%NOTFOUND;
        CLOSE okc_bclv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BCL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_bslv_rec.CLE_ID IS NOT NULL)
      THEN
        OPEN okc_clev_pk_csr(p_bslv_rec.CLE_ID);
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
    l_return_status := validate_foreign_keys (p_bslv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN bslv_rec_type,
    p_to	OUT NOCOPY bsl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.cle_id := p_from.cle_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.average := p_from.average;
    p_to.amount := p_from.amount;
    p_to.MANUAL_CREDIT := p_from.MANUAL_CREDIT;
    p_to.date_billed_from := p_from.date_billed_from;
    p_to.date_billed_to := p_from.date_billed_to;
    p_to.date_to_interface := p_from.date_to_interface;
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
    p_from	IN bsl_rec_type,
    p_to	OUT NOCOPY bslv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.cle_id := p_from.cle_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.average := p_from.average;
    p_to.MANUAL_CREDIT := p_from.MANUAL_CREDIT;
    p_to.date_billed_from := p_from.date_billed_from;
    p_to.date_billed_to := p_from.date_billed_to;
    p_to.date_to_interface := p_from.date_to_interface;
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
  -------------------------------------------
  -- validate_row for:OKS_BILL_SUB_LINES_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bslv_rec                     bslv_rec_type := p_bslv_rec;
    l_bsl_rec                      bsl_rec_type;
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
    l_return_status := Validate_Attributes(l_bslv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_bslv_rec);
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
  -- PL/SQL TBL validate_row for:BSLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bslv_tbl.COUNT > 0) THEN
      i := p_bslv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bslv_rec                     => p_bslv_tbl(i));
        EXIT WHEN (i = p_bslv_tbl.LAST);
        i := p_bslv_tbl.NEXT(i);
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
  ---------------------------------------
  -- insert_row for:OKS_BILL_SUB_LINES --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsl_rec                      IN bsl_rec_type,
    x_bsl_rec                      OUT NOCOPY bsl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsl_rec                      bsl_rec_type := p_bsl_rec;
    l_def_bsl_rec                  bsl_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUB_LINES --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_bsl_rec IN  bsl_rec_type,
      x_bsl_rec OUT NOCOPY bsl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsl_rec := p_bsl_rec;
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
      p_bsl_rec,                         -- IN
      l_bsl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_BILL_SUB_LINES(
        id,
        bcl_id,
        cle_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        average,
        amount,
        MANUAL_CREDIT,
        date_billed_from,
        date_billed_to,
        date_to_interface,
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
        l_bsl_rec.id,
        l_bsl_rec.bcl_id,
        l_bsl_rec.cle_id,
        l_bsl_rec.object_version_number,
        l_bsl_rec.created_by,
        l_bsl_rec.creation_date,
        l_bsl_rec.last_updated_by,
        l_bsl_rec.last_update_date,
        l_bsl_rec.average,
        l_bsl_rec.amount,
        l_bsl_rec.MANUAL_CREDIT,
        l_bsl_rec.date_billed_from,
        l_bsl_rec.date_billed_to,
        l_bsl_rec.date_to_interface,
        l_bsl_rec.last_update_login,
        l_bsl_rec.attribute_category,
        l_bsl_rec.attribute1,
        l_bsl_rec.attribute2,
        l_bsl_rec.attribute3,
        l_bsl_rec.attribute4,
        l_bsl_rec.attribute5,
        l_bsl_rec.attribute6,
        l_bsl_rec.attribute7,
        l_bsl_rec.attribute8,
        l_bsl_rec.attribute9,
        l_bsl_rec.attribute10,
        l_bsl_rec.attribute11,
        l_bsl_rec.attribute12,
        l_bsl_rec.attribute13,
        l_bsl_rec.attribute14,
        l_bsl_rec.attribute15);
    -- Set OUT values
    x_bsl_rec := l_bsl_rec;
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
  -----------------------------------------
  -- insert_row for:OKS_BILL_SUB_LINES_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type,
    x_bslv_rec                     OUT NOCOPY bslv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bslv_rec                     bslv_rec_type;
    l_def_bslv_rec                 bslv_rec_type;
    l_bsl_rec                      bsl_rec_type;
    lx_bsl_rec                     bsl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bslv_rec	IN bslv_rec_type
    ) RETURN bslv_rec_type IS
      l_bslv_rec	bslv_rec_type := p_bslv_rec;
    BEGIN
      l_bslv_rec.CREATION_DATE := SYSDATE;
      l_bslv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_bslv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bslv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bslv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bslv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUB_LINES_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_bslv_rec IN  bslv_rec_type,
      x_bslv_rec OUT NOCOPY bslv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bslv_rec := p_bslv_rec;
      x_bslv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_bslv_rec := null_out_defaults(p_bslv_rec);
    -- Set primary key value
    l_bslv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_bslv_rec,                        -- IN
      l_def_bslv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bslv_rec := fill_who_columns(l_def_bslv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bslv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bslv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bslv_rec, l_bsl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsl_rec,
      lx_bsl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bsl_rec, l_def_bslv_rec);
    -- Set OUT values
    x_bslv_rec := l_def_bslv_rec;
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
  -- PL/SQL TBL insert_row for:BSLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type,
    x_bslv_tbl                     OUT NOCOPY bslv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bslv_tbl.COUNT > 0) THEN
      i := p_bslv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bslv_rec                     => p_bslv_tbl(i),
          x_bslv_rec                     => x_bslv_tbl(i));
        EXIT WHEN (i = p_bslv_tbl.LAST);
        i := p_bslv_tbl.NEXT(i);
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
  -------------------------------------
  -- lock_row for:OKS_BILL_SUB_LINES --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsl_rec                      IN bsl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bsl_rec IN bsl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_SUB_LINES
     WHERE ID = p_bsl_rec.id
       AND OBJECT_VERSION_NUMBER = p_bsl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_bsl_rec IN bsl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_SUB_LINES
    WHERE ID = p_bsl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_BILL_SUB_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_BILL_SUB_LINES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_bsl_rec);
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
      OPEN lchk_csr(p_bsl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_bsl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_bsl_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKS_BILL_SUB_LINES_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsl_rec                      bsl_rec_type;
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
    migrate(p_bslv_rec, l_bsl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsl_rec
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
  -- PL/SQL TBL lock_row for:BSLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bslv_tbl.COUNT > 0) THEN
      i := p_bslv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bslv_rec                     => p_bslv_tbl(i));
        EXIT WHEN (i = p_bslv_tbl.LAST);
        i := p_bslv_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKS_BILL_SUB_LINES --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsl_rec                      IN bsl_rec_type,
    x_bsl_rec                      OUT NOCOPY bsl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsl_rec                      bsl_rec_type := p_bsl_rec;
    l_def_bsl_rec                  bsl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bsl_rec	IN bsl_rec_type,
      x_bsl_rec	OUT NOCOPY bsl_rec_type
    ) RETURN VARCHAR2 IS
      l_bsl_rec                      bsl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsl_rec := p_bsl_rec;
      -- Get current database values
      l_bsl_rec := get_rec(p_bsl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bsl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.id := l_bsl_rec.id;
      END IF;
      IF (x_bsl_rec.bcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.bcl_id := l_bsl_rec.bcl_id;
      END IF;
      IF (x_bsl_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.cle_id := l_bsl_rec.cle_id;
      END IF;
      IF (x_bsl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.object_version_number := l_bsl_rec.object_version_number;
      END IF;
      IF (x_bsl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.created_by := l_bsl_rec.created_by;
      END IF;
      IF (x_bsl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_bsl_rec.creation_date := l_bsl_rec.creation_date;
      END IF;
      IF (x_bsl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.last_updated_by := l_bsl_rec.last_updated_by;
      END IF;
      IF (x_bsl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_bsl_rec.last_update_date := l_bsl_rec.last_update_date;
      END IF;
      IF (x_bsl_rec.average = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.average := l_bsl_rec.average;
      END IF;
      IF (x_bsl_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.amount := l_bsl_rec.amount;
      END IF;
      IF (x_bsl_rec.MANUAL_CREDIT = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.MANUAL_CREDIT := l_bsl_rec.MANUAL_CREDIT;
      END IF;
      IF (x_bsl_rec.date_billed_from = OKC_API.G_MISS_DATE)
      THEN
        x_bsl_rec.date_billed_from := l_bsl_rec.date_billed_from;
      END IF;
      IF (x_bsl_rec.date_billed_to = OKC_API.G_MISS_DATE)
      THEN
        x_bsl_rec.date_billed_to := l_bsl_rec.date_billed_to;
      END IF;
      IF (x_bsl_rec.date_to_interface = OKC_API.G_MISS_DATE)
      THEN
        x_bsl_rec.date_to_interface := l_bsl_rec.date_to_interface;
      END IF;
      IF (x_bsl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_bsl_rec.last_update_login := l_bsl_rec.last_update_login;
      END IF;
      IF (x_bsl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute_category := l_bsl_rec.attribute_category;
      END IF;
      IF (x_bsl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute1 := l_bsl_rec.attribute1;
      END IF;
      IF (x_bsl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute2 := l_bsl_rec.attribute2;
      END IF;
      IF (x_bsl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute3 := l_bsl_rec.attribute3;
      END IF;
      IF (x_bsl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute4 := l_bsl_rec.attribute4;
      END IF;
      IF (x_bsl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute5 := l_bsl_rec.attribute5;
      END IF;
      IF (x_bsl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute6 := l_bsl_rec.attribute6;
      END IF;
      IF (x_bsl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute7 := l_bsl_rec.attribute7;
      END IF;
      IF (x_bsl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute8 := l_bsl_rec.attribute8;
      END IF;
      IF (x_bsl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute9 := l_bsl_rec.attribute9;
      END IF;
      IF (x_bsl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute10 := l_bsl_rec.attribute10;
      END IF;
      IF (x_bsl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute11 := l_bsl_rec.attribute11;
      END IF;
      IF (x_bsl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute12 := l_bsl_rec.attribute12;
      END IF;
      IF (x_bsl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute13 := l_bsl_rec.attribute13;
      END IF;
      IF (x_bsl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute14 := l_bsl_rec.attribute14;
      END IF;
      IF (x_bsl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsl_rec.attribute15 := l_bsl_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUB_LINES --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_bsl_rec IN  bsl_rec_type,
      x_bsl_rec OUT NOCOPY bsl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsl_rec := p_bsl_rec;
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
      p_bsl_rec,                         -- IN
      l_bsl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bsl_rec, l_def_bsl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_BILL_SUB_LINES
    SET BCL_ID = l_def_bsl_rec.bcl_id,
        CLE_ID = l_def_bsl_rec.cle_id,
        OBJECT_VERSION_NUMBER = l_def_bsl_rec.object_version_number,
        CREATED_BY = l_def_bsl_rec.created_by,
        CREATION_DATE = l_def_bsl_rec.creation_date,
        LAST_UPDATED_BY = l_def_bsl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bsl_rec.last_update_date,
        AVERAGE = l_def_bsl_rec.average,
        AMOUNT = l_def_bsl_rec.amount,
        MANUAL_CREDIT = l_def_bsl_rec.MANUAL_CREDIT,
        DATE_BILLED_FROM = l_def_bsl_rec.date_billed_from,
        DATE_BILLED_TO = l_def_bsl_rec.date_billed_to,
        DATE_TO_INTERFACE = l_def_bsl_rec.date_to_interface,
        LAST_UPDATE_LOGIN = l_def_bsl_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_bsl_rec.attribute_category,
        ATTRIBUTE1 = l_def_bsl_rec.attribute1,
        ATTRIBUTE2 = l_def_bsl_rec.attribute2,
        ATTRIBUTE3 = l_def_bsl_rec.attribute3,
        ATTRIBUTE4 = l_def_bsl_rec.attribute4,
        ATTRIBUTE5 = l_def_bsl_rec.attribute5,
        ATTRIBUTE6 = l_def_bsl_rec.attribute6,
        ATTRIBUTE7 = l_def_bsl_rec.attribute7,
        ATTRIBUTE8 = l_def_bsl_rec.attribute8,
        ATTRIBUTE9 = l_def_bsl_rec.attribute9,
        ATTRIBUTE10 = l_def_bsl_rec.attribute10,
        ATTRIBUTE11 = l_def_bsl_rec.attribute11,
        ATTRIBUTE12 = l_def_bsl_rec.attribute12,
        ATTRIBUTE13 = l_def_bsl_rec.attribute13,
        ATTRIBUTE14 = l_def_bsl_rec.attribute14,
        ATTRIBUTE15 = l_def_bsl_rec.attribute15
    WHERE ID = l_def_bsl_rec.id;

    x_bsl_rec := l_def_bsl_rec;
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
  -----------------------------------------
  -- update_row for:OKS_BILL_SUB_LINES_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type,
    x_bslv_rec                     OUT NOCOPY bslv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bslv_rec                     bslv_rec_type := p_bslv_rec;
    l_def_bslv_rec                 bslv_rec_type;
    l_bsl_rec                      bsl_rec_type;
    lx_bsl_rec                     bsl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bslv_rec	IN bslv_rec_type
    ) RETURN bslv_rec_type IS
      l_bslv_rec	bslv_rec_type := p_bslv_rec;
    BEGIN
      l_bslv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bslv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bslv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bslv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bslv_rec	IN bslv_rec_type,
      x_bslv_rec	OUT NOCOPY bslv_rec_type
    ) RETURN VARCHAR2 IS
      l_bslv_rec                     bslv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bslv_rec := p_bslv_rec;
      -- Get current database values
      l_bslv_rec := get_rec(p_bslv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bslv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.id := l_bslv_rec.id;
      END IF;
      IF (x_bslv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.object_version_number := l_bslv_rec.object_version_number;
      END IF;
      IF (x_bslv_rec.bcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.bcl_id := l_bslv_rec.bcl_id;
      END IF;
      IF (x_bslv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.cle_id := l_bslv_rec.cle_id;
      END IF;
      IF (x_bslv_rec.average = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.average := l_bslv_rec.average;
      END IF;
      IF (x_bslv_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.amount := l_bslv_rec.amount;
      END IF;
      IF (x_bslv_rec.MANUAL_CREDIT = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.MANUAL_CREDIT := l_bslv_rec.MANUAL_CREDIT;
      END IF;
      IF (x_bslv_rec.date_billed_from = OKC_API.G_MISS_DATE)
      THEN
        x_bslv_rec.date_billed_from := l_bslv_rec.date_billed_from;
      END IF;
      IF (x_bslv_rec.date_billed_to = OKC_API.G_MISS_DATE)
      THEN
        x_bslv_rec.date_billed_to := l_bslv_rec.date_billed_to;
      END IF;
      IF (x_bslv_rec.date_to_interface = OKC_API.G_MISS_DATE)
      THEN
        x_bslv_rec.date_to_interface := l_bslv_rec.date_to_interface;
      END IF;
      IF (x_bslv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute_category := l_bslv_rec.attribute_category;
      END IF;
      IF (x_bslv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute1 := l_bslv_rec.attribute1;
      END IF;
      IF (x_bslv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute2 := l_bslv_rec.attribute2;
      END IF;
      IF (x_bslv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute3 := l_bslv_rec.attribute3;
      END IF;
      IF (x_bslv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute4 := l_bslv_rec.attribute4;
      END IF;
      IF (x_bslv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute5 := l_bslv_rec.attribute5;
      END IF;
      IF (x_bslv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute6 := l_bslv_rec.attribute6;
      END IF;
      IF (x_bslv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute7 := l_bslv_rec.attribute7;
      END IF;
      IF (x_bslv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute8 := l_bslv_rec.attribute8;
      END IF;
      IF (x_bslv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute9 := l_bslv_rec.attribute9;
      END IF;
      IF (x_bslv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute10 := l_bslv_rec.attribute10;
      END IF;
      IF (x_bslv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute11 := l_bslv_rec.attribute11;
      END IF;
      IF (x_bslv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute12 := l_bslv_rec.attribute12;
      END IF;
      IF (x_bslv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute13 := l_bslv_rec.attribute13;
      END IF;
      IF (x_bslv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute14 := l_bslv_rec.attribute14;
      END IF;
      IF (x_bslv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_bslv_rec.attribute15 := l_bslv_rec.attribute15;
      END IF;
      IF (x_bslv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.created_by := l_bslv_rec.created_by;
      END IF;
      IF (x_bslv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_bslv_rec.creation_date := l_bslv_rec.creation_date;
      END IF;
      IF (x_bslv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.last_updated_by := l_bslv_rec.last_updated_by;
      END IF;
      IF (x_bslv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_bslv_rec.last_update_date := l_bslv_rec.last_update_date;
      END IF;
      IF (x_bslv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_bslv_rec.last_update_login := l_bslv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUB_LINES_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_bslv_rec IN  bslv_rec_type,
      x_bslv_rec OUT NOCOPY bslv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bslv_rec := p_bslv_rec;
      x_bslv_rec.OBJECT_VERSION_NUMBER := NVL(x_bslv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_bslv_rec,                        -- IN
      l_bslv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bslv_rec, l_def_bslv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bslv_rec := fill_who_columns(l_def_bslv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bslv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bslv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bslv_rec, l_bsl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsl_rec,
      lx_bsl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bsl_rec, l_def_bslv_rec);
    x_bslv_rec := l_def_bslv_rec;
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
  -- PL/SQL TBL update_row for:BSLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type,
    x_bslv_tbl                     OUT NOCOPY bslv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bslv_tbl.COUNT > 0) THEN
      i := p_bslv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bslv_rec                     => p_bslv_tbl(i),
          x_bslv_rec                     => x_bslv_tbl(i));
        EXIT WHEN (i = p_bslv_tbl.LAST);
        i := p_bslv_tbl.NEXT(i);
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
  ---------------------------------------
  -- delete_row for:OKS_BILL_SUB_LINES --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsl_rec                      IN bsl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsl_rec                      bsl_rec_type:= p_bsl_rec;
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
    DELETE FROM OKS_BILL_SUB_LINES
     WHERE ID = l_bsl_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKS_BILL_SUB_LINES_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec                     IN bslv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bslv_rec                     bslv_rec_type := p_bslv_rec;
    l_bsl_rec                      bsl_rec_type;
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
    migrate(l_bslv_rec, l_bsl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsl_rec
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
  -- PL/SQL TBL delete_row for:BSLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_tbl                     IN bslv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bslv_tbl.COUNT > 0) THEN
      i := p_bslv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bslv_rec                     => p_bslv_tbl(i));
        EXIT WHEN (i = p_bslv_tbl.LAST);
        i := p_bslv_tbl.NEXT(i);
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
END OKS_BSL_PVT;

/
