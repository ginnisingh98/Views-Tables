--------------------------------------------------------
--  DDL for Package Body OKS_BSD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BSD_PVT" AS
/* $Header: OKSSBSDB.pls 120.0 2005/05/25 17:54:55 appldev noship $ */
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
  -- FUNCTION get_rec for: OKS_BILL_SUB_LINE_DTLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bsd_rec                      IN bsd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bsd_rec_type IS
    CURSOR bsd_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            BSL_ID,
            BSL_ID_AVERAGED,
            BSD_ID,
            BSD_ID_APPLIED,
            CCR_ID,
            CGR_ID,
            START_READING,
            END_READING,
            BASE_READING,
            ESTIMATED_QUANTITY,
            UNIT_OF_MEASURE,
            AMCV_YN,
            RESULT,
            AMOUNT,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            FIXED,
            ACTUAL,
            DEFAULT_DEFAULT,
            ADJUSTMENT_LEVEL,
            ADJUSTMENT_MINIMUM,
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
      FROM Oks_Bill_Sub_Line_Dtls
     WHERE oks_bill_sub_line_dtls.id = p_id;
    l_bsd_pk                       bsd_pk_csr%ROWTYPE;
    l_bsd_rec                      bsd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN bsd_pk_csr (p_bsd_rec.id);
    FETCH bsd_pk_csr INTO
              l_bsd_rec.ID,
              l_bsd_rec.BSL_ID,
              l_bsd_rec.BSL_ID_AVERAGED,
              l_bsd_rec.BSD_ID,
              l_bsd_rec.BSD_ID_APPLIED,
              l_bsd_rec.CCR_ID,
              l_bsd_rec.CGR_ID,
              l_bsd_rec.START_READING,
              l_bsd_rec.END_READING,
              l_bsd_rec.BASE_READING,
              l_bsd_rec.ESTIMATED_QUANTITY,
              l_bsd_rec.UNIT_OF_MEASURE,
              l_bsd_rec.AMCV_YN,
              l_bsd_rec.RESULT,
              l_bsd_rec.AMOUNT,
              l_bsd_rec.OBJECT_VERSION_NUMBER,
              l_bsd_rec.CREATED_BY,
              l_bsd_rec.CREATION_DATE,
              l_bsd_rec.LAST_UPDATED_BY,
              l_bsd_rec.LAST_UPDATE_DATE,
              l_bsd_rec.FIXED,
              l_bsd_rec.ACTUAL,
              l_bsd_rec.DEFAULT_DEFAULT,
              l_bsd_rec.ADJUSTMENT_LEVEL,
              l_bsd_rec.ADJUSTMENT_MINIMUM,
              l_bsd_rec.LAST_UPDATE_LOGIN,
              l_bsd_rec.ATTRIBUTE_CATEGORY,
              l_bsd_rec.ATTRIBUTE1,
              l_bsd_rec.ATTRIBUTE2,
              l_bsd_rec.ATTRIBUTE3,
              l_bsd_rec.ATTRIBUTE4,
              l_bsd_rec.ATTRIBUTE5,
              l_bsd_rec.ATTRIBUTE6,
              l_bsd_rec.ATTRIBUTE7,
              l_bsd_rec.ATTRIBUTE8,
              l_bsd_rec.ATTRIBUTE9,
              l_bsd_rec.ATTRIBUTE10,
              l_bsd_rec.ATTRIBUTE11,
              l_bsd_rec.ATTRIBUTE12,
              l_bsd_rec.ATTRIBUTE13,
              l_bsd_rec.ATTRIBUTE14,
              l_bsd_rec.ATTRIBUTE15;
    x_no_data_found := bsd_pk_csr%NOTFOUND;
    CLOSE bsd_pk_csr;
    RETURN(l_bsd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bsd_rec                      IN bsd_rec_type
  ) RETURN bsd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bsd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILL_SUBLINE_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bsdv_rec                     IN bsdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bsdv_rec_type IS
    CURSOR okc_bsdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            BSL_ID,
            BSL_ID_AVERAGED,
            BSD_ID,
            BSD_ID_APPLIED,
            CCR_ID,
            CGR_ID,
            START_READING,
            END_READING,
            BASE_READING,
            ESTIMATED_QUANTITY,
            UNIT_OF_MEASURE,
            FIXED,
            ACTUAL,
            DEFAULT_DEFAULT,
            AMCV_YN,
            ADJUSTMENT_LEVEL,
            ADJUSTMENT_MINIMUM,
            RESULT,
            AMOUNT,
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
      FROM Oks_Bill_Subline_Dtls_V
     WHERE oks_bill_subline_dtls_v.id = p_id;
    l_okc_bsdv_pk                  okc_bsdv_pk_csr%ROWTYPE;
    l_bsdv_rec                     bsdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_bsdv_pk_csr (p_bsdv_rec.id);
    FETCH okc_bsdv_pk_csr INTO
              l_bsdv_rec.ID,
              l_bsdv_rec.OBJECT_VERSION_NUMBER,
              l_bsdv_rec.BSL_ID,
              l_bsdv_rec.BSL_ID_AVERAGED,
              l_bsdv_rec.BSD_ID,
              l_bsdv_rec.BSD_ID_APPLIED,
              l_bsdv_rec.CCR_ID,
              l_bsdv_rec.CGR_ID,
              l_bsdv_rec.START_READING,
              l_bsdv_rec.END_READING,
              l_bsdv_rec.BASE_READING,
              l_bsdv_rec.ESTIMATED_QUANTITY,
              l_bsdv_rec.UNIT_OF_MEASURE,
              l_bsdv_rec.FIXED,
              l_bsdv_rec.ACTUAL,
              l_bsdv_rec.DEFAULT_DEFAULT,
              l_bsdv_rec.AMCV_YN,
              l_bsdv_rec.ADJUSTMENT_LEVEL,
              l_bsdv_rec.ADJUSTMENT_MINIMUM,
              l_bsdv_rec.RESULT,
              l_bsdv_rec.AMOUNT,
              l_bsdv_rec.ATTRIBUTE_CATEGORY,
              l_bsdv_rec.ATTRIBUTE1,
              l_bsdv_rec.ATTRIBUTE2,
              l_bsdv_rec.ATTRIBUTE3,
              l_bsdv_rec.ATTRIBUTE4,
              l_bsdv_rec.ATTRIBUTE5,
              l_bsdv_rec.ATTRIBUTE6,
              l_bsdv_rec.ATTRIBUTE7,
              l_bsdv_rec.ATTRIBUTE8,
              l_bsdv_rec.ATTRIBUTE9,
              l_bsdv_rec.ATTRIBUTE10,
              l_bsdv_rec.ATTRIBUTE11,
              l_bsdv_rec.ATTRIBUTE12,
              l_bsdv_rec.ATTRIBUTE13,
              l_bsdv_rec.ATTRIBUTE14,
              l_bsdv_rec.ATTRIBUTE15,
              l_bsdv_rec.CREATED_BY,
              l_bsdv_rec.CREATION_DATE,
              l_bsdv_rec.LAST_UPDATED_BY,
              l_bsdv_rec.LAST_UPDATE_DATE,
              l_bsdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_bsdv_pk_csr%NOTFOUND;
    CLOSE okc_bsdv_pk_csr;
    RETURN(l_bsdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_bsdv_rec                     IN bsdv_rec_type
  ) RETURN bsdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bsdv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_BILL_SUBLINE_DTLS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_bsdv_rec	IN bsdv_rec_type
  ) RETURN bsdv_rec_type IS
    l_bsdv_rec	bsdv_rec_type := p_bsdv_rec;
  BEGIN
    IF (l_bsdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.object_version_number := NULL;
    END IF;
    IF (l_bsdv_rec.bsl_id = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.bsl_id := NULL;
    END IF;
    IF (l_bsdv_rec.bsl_id_averaged = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.bsl_id_averaged := NULL;
    END IF;
    IF (l_bsdv_rec.bsd_id = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.bsd_id := NULL;
    END IF;
    IF (l_bsdv_rec.bsd_id_applied = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.bsd_id_applied := NULL;
    END IF;
    IF (l_bsdv_rec.ccr_id = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.ccr_id := NULL;
    END IF;
    IF (l_bsdv_rec.cgr_id = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.cgr_id := NULL;
    END IF;
    IF (l_bsdv_rec.start_reading = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.start_reading := NULL;
    END IF;
    IF (l_bsdv_rec.end_reading = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.end_reading := NULL;
    END IF;
    IF (l_bsdv_rec.base_reading = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.base_reading := NULL;
    END IF;
    IF (l_bsdv_rec.estimated_quantity = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.estimated_quantity := NULL;
    END IF;
    IF (l_bsdv_rec.unit_of_measure = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.unit_of_measure := NULL;
    END IF;
    IF (l_bsdv_rec.fixed = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.fixed := NULL;
    END IF;
    IF (l_bsdv_rec.actual = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.actual := NULL;
    END IF;
    IF (l_bsdv_rec.default_default = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.default_default := NULL;
    END IF;
    IF (l_bsdv_rec.amcv_yn = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.amcv_yn := NULL;
    END IF;
    IF (l_bsdv_rec.adjustment_level = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.adjustment_level := NULL;
    END IF;
    IF (l_bsdv_rec.adjustment_minimum = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.adjustment_minimum := NULL;
    END IF;
    IF (l_bsdv_rec.result = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.result := NULL;
    END IF;
    IF (l_bsdv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.amount := NULL;
    END IF;
    IF (l_bsdv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute_category := NULL;
    END IF;
    IF (l_bsdv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute1 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute2 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute3 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute4 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute5 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute6 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute7 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute8 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute9 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute10 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute11 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute12 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute13 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute14 := NULL;
    END IF;
    IF (l_bsdv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_bsdv_rec.attribute15 := NULL;
    END IF;
    IF (l_bsdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.created_by := NULL;
    END IF;
    IF (l_bsdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_bsdv_rec.creation_date := NULL;
    END IF;
    IF (l_bsdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_bsdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_bsdv_rec.last_update_date := NULL;
    END IF;
    IF (l_bsdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_bsdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_bsdv_rec);
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


PROCEDURE validate_bsl_id(x_return_status OUT NOCOPY varchar2,
					 P_bsl_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_bsl_Csr Is
  	  select 'x'
	  from OKS_BILL_SUB_LINES_V
  	  where id = P_bsl_id;

Begin
   If p_bsl_id  = OKC_API.G_MISS_NUM OR
      p_bsl_id  IS NULL
   Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'bsl_id');

     l_return_status := OKC_API.G_RET_STS_ERROR;
     RAISE G_EXCEPTION_HALT_VALIDATION;
   End If;

   If (p_bsl_id <> OKC_API.G_MISS_NUM and
  	   p_bsl_id IS NOT NULL)
   Then
       Open l_bsl_csr;
       Fetch l_bsl_csr Into l_dummy_var;
       Close l_bsl_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'bsl_id ');

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
  END validate_bsl_id;

  PROCEDURE validate_bsl_id_averaged(x_return_status OUT NOCOPY varchar2,
					 P_bsl_id_averaged IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

    -- call column length utility

---------giving prob so commented
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'bsl_id_averaged'
            ,p_col_value     => p_bsl_id_averaged
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
                          p_token2_value => 'bsl_id_averaged Length');


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
END validate_bsl_id_averaged;

PROCEDURE validate_bsd_id(x_return_status OUT NOCOPY varchar2,
					 P_bsd_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

    -- call column length utility

---------giving prob so commented
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'bsd_id'
            ,p_col_value     => p_bsd_id
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
                          p_token2_value => 'bsd_id Length');


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
END validate_bsd_id;



PROCEDURE validate_bsd_id_applied(x_return_status OUT NOCOPY varchar2,
					 P_bsd_id_applied IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

    -- call column length utility

---------giving prob so commented
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'bsd_id_applied'
            ,p_col_value     => p_bsd_id_applied
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
                          p_token2_value => 'bsd_id_applied Length');


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
  END validate_bsd_id_applied;

PROCEDURE validate_ccr_id(x_return_status OUT NOCOPY varchar2,
					 P_ccr_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status           := OKC_API.G_RET_STS_SUCCESS;

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
  END validate_ccr_id;


PROCEDURE validate_cgr_id(x_return_status OUT NOCOPY varchar2,
					 P_cgr_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status           := OKC_API.G_RET_STS_SUCCESS;

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
  END validate_cgr_id;


PROCEDURE validate_start_reading(x_return_status OUT NOCOPY varchar2,
					 P_start_reading IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status           := OKC_API.G_RET_STS_SUCCESS;

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
  END validate_start_reading;


PROCEDURE validate_end_reading(x_return_status OUT NOCOPY varchar2,
					 P_end_reading IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status           := OKC_API.G_RET_STS_SUCCESS;
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
  END validate_end_reading;

 PROCEDURE validate_base_reading(x_return_status OUT NOCOPY varchar2,
                                         P_base_reading IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status           := OKC_API.G_RET_STS_SUCCESS;
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
  END validate_base_reading;
 PROCEDURE validate_estimated_Quantity(x_return_status OUT NOCOPY varchar2,
                                 P_estimated_Quantity IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status           := OKC_API.G_RET_STS_SUCCESS;
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
  END validate_estimated_Quantity;


PROCEDURE validate_unit_of_measure (	x_return_status OUT NOCOPY varchar2,
							 P_unit_of_measure IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  If P_unit_of_measure = OKC_API.G_MISS_CHAR OR
       P_unit_of_measure IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'unit_of_measure');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'unit_of_measure'
            ,p_col_value     => P_unit_of_measure
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
                          p_token2_value => 'unit_of_measure length');


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
  END validate_unit_of_measure;

  PROCEDURE validate_amcv_yn (	x_return_status OUT NOCOPY varchar2,
							 P_amcv_yn IN  Varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  If P_amcv_yn = OKC_API.G_MISS_CHAR OR
       P_amcv_yn IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'amcv_yn');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  -- call column length utility

  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'amcv_yn'
            ,p_col_value     => P_amcv_yn
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
                          p_token2_value => 'amcv_yn length');


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
  END validate_amcv_yn;

PROCEDURE validate_result(	x_return_status OUT NOCOPY varchar2,
					P_result IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If P_result= OKC_API.G_MISS_NUM OR
       P_result	IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Result' );
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'Result'
            ,p_col_value     => P_result
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
                          p_token2_value => 'Result Length');


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
  END validate_result;


PROCEDURE validate_Amount(	x_return_status OUT NOCOPY varchar2,
					P_amount IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If P_Amount= OKC_API.G_MISS_NUM OR
       P_Amount	IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Amount' );
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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


PROCEDURE validate_fixed(	x_return_status OUT NOCOPY varchar2,
					P_fixed IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'Fixed'
            ,p_col_value     => P_fixed
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
                          p_token2_value => 'Fixed Length');


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
  END validate_fixed;


PROCEDURE validate_actual(	x_return_status OUT NOCOPY varchar2,
					P_actual IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'Actual'
            ,p_col_value     => P_actual
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
                          p_token2_value => 'Actual Length');


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
  END validate_actual;


PROCEDURE validate_default_default(	x_return_status OUT NOCOPY varchar2,
					P_default_default IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'default_default'
            ,p_col_value     => P_default_default
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
                          p_token2_value => 'default_default');


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
  END validate_default_default;

PROCEDURE validate_adjustment_level(	x_return_status OUT NOCOPY varchar2,
					P_adjustment_level IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'adjustment_level'
            ,p_col_value     => P_adjustment_level
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
                          p_token2_value => 'adjustment_level Length');


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
  END validate_adjustment_level;

PROCEDURE validate_adjustment_minimum(	x_return_status OUT NOCOPY varchar2,
					P_adjustment_minimum IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin


    -- call column length utility
  /*
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
            ,p_col_name      => 'adjustment_minimum'
            ,p_col_value     => P_adjustment_minimum
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
                          p_token2_value => 'adjustment_minimum Length');


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
  END validate_adjustment_minimum;


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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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
		 p_view_name     => 'OKS_BILL_SUBLINE_DTLS_V'
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


/*  -----------------------------------------------------
  -- Validate_Attributes for:OKS_BILL_SUBLINE_DTLS_V --
  -----------------------------------------------------

  FUNCTION Validate_Attributes (
    p_bsdv_rec IN  bsdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_bsdv_rec.id = OKC_API.G_MISS_NUM OR
       p_bsdv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bsdv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_bsdv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bsdv_rec.bsl_id = OKC_API.G_MISS_NUM OR
          p_bsdv_rec.bsl_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'bsl_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bsdv_rec.unit_of_measure = OKC_API.G_MISS_CHAR OR
          p_bsdv_rec.unit_of_measure IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'unit_of_measure');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bsdv_rec.amcv_yn = OKC_API.G_MISS_CHAR OR
          p_bsdv_rec.amcv_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'amcv_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bsdv_rec.result = OKC_API.G_MISS_NUM OR
          p_bsdv_rec.result IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'result');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_bsdv_rec.amount = OKC_API.G_MISS_NUM OR
          p_bsdv_rec.amount IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'amount');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */




FUNCTION Validate_Attributes (
    p_bsdv_rec IN  bsdv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_BILL_SUBLINE_DTLS_V',x_return_status);

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
    validate_id(x_return_status, p_bsdv_rec.id);

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

--bsl_id
	 validate_bsl_id(x_return_status, p_bsdv_rec.bsl_id);
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

    --bsl_id_averaged
	 validate_bsl_id_averaged(x_return_status, p_bsdv_rec.bsl_id_averaged);
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

	--bsd_id

 	validate_bsd_id(x_return_status, p_bsdv_rec.bsd_id);
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

   --bsd_id_applied
    validate_bsd_id_applied(x_return_status, p_bsdv_rec.bsd_id_applied);
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

   --ccr_id
      validate_ccr_id(x_return_status, p_bsdv_rec.ccr_id);
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

    --cgr_id
      validate_cgr_id(x_return_status, p_bsdv_rec.cgr_id);
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

      --start_read
      validate_start_reading(x_return_status, p_bsdv_rec.start_reading);
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

     --end_read
      validate_end_reading(x_return_status, p_bsdv_rec.end_reading);
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

  --base_read
      validate_base_reading(x_return_status, p_bsdv_rec.base_reading);
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

     --estimated_quantity
        validate_estimated_quantity(x_return_status, p_bsdv_rec.estimated_quantity);
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

    --unit_of_measure
	 validate_unit_of_measure(x_return_status, p_bsdv_rec.unit_of_measure);
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

	--amcv_yn

 	validate_amcv_yn(x_return_status, p_bsdv_rec.amcv_yn);
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

    --result
    validate_result(x_return_status, p_bsdv_rec.result);
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
		validate_amount(x_return_status, p_bsdv_rec.amount);

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
    validate_objvernum(x_return_status, p_bsdv_rec.object_version_number);

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

    --fixed
    validate_fixed(x_return_status, p_bsdv_rec.fixed);

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

    --actual
	 validate_actual(x_return_status, p_bsdv_rec.actual);
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

    --default_default
	 validate_default_default(x_return_status, p_bsdv_rec.default_default);
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

	--adjustment_level

 	validate_adjustment_level(x_return_status, p_bsdv_rec.adjustment_level);
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

    -- adjustment_level

    validate_adjustment_level(x_return_status, p_bsdv_rec.adjustment_level);
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

		validate_attribute_category(x_return_status, p_bsdv_rec.attribute_category);

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

		validate_attribute1(x_return_status, p_bsdv_rec.attribute1);

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

		validate_attribute2(x_return_status, p_bsdv_rec.attribute2);

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

		validate_attribute3(x_return_status, p_bsdv_rec.attribute3);

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
		validate_attribute4(x_return_status, p_bsdv_rec.attribute4);

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
		validate_attribute5(x_return_status, p_bsdv_rec.attribute5);

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

		validate_attribute6(x_return_status, p_bsdv_rec.attribute6);

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

		validate_attribute7(x_return_status, p_bsdv_rec.attribute7);

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
		validate_attribute8(x_return_status, p_bsdv_rec.attribute8);

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
		validate_attribute9(x_return_status, p_bsdv_rec.attribute9);

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

		validate_attribute10(x_return_status, p_bsdv_rec.attribute10);

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

		validate_attribute11(x_return_status, p_bsdv_rec.attribute11);

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

		validate_attribute12(x_return_status, p_bsdv_rec.attribute12);

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
		validate_attribute13(x_return_status, p_bsdv_rec.attribute13);

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

		validate_attribute14(x_return_status, p_bsdv_rec.attribute14);

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

		validate_attribute15(x_return_status, p_bsdv_rec.attribute15);

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
  -------------------------------------------------
  -- Validate_Record for:OKS_BILL_SUBLINE_DTLS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_bsdv_rec IN bsdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_bsdv_rec IN bsdv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_bsdv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              BSL_ID,
              BSL_ID_AVERAGED,
              BSD_ID,
              BSD_ID_APPLIED,
              CCR_ID,
              CGR_ID,
              START_READING,
              END_READING,
              BASE_READING,
              ESTIMATED_QUANTITY,
              UNIT_OF_MEASURE,
              FIXED,
              ACTUAL,
              DEFAULT_DEFAULT,
              AMCV_YN,
              ADJUSTMENT_LEVEL,
              ADJUSTMENT_MINIMUM,
              RESULT,
              AMOUNT,
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
        FROM Oks_Bill_Subline_Dtls_V
       WHERE oks_bill_subline_dtls_v.id = p_id;
      l_okc_bsdv_pk                  okc_bsdv_pk_csr%ROWTYPE;
      CURSOR okc_bslv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              BCL_ID,
              CLE_ID,
              AVERAGE,
              AMOUNT,
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
        FROM Oks_Bill_Sub_lines_V
       WHERE oks_bill_sub_lines_v.id = p_id;
      l_okc_bslv_pk                  okc_bslv_pk_csr%ROWTYPE;
    /*  CURSOR okx_units_of_measure_v_pk_csr (p_unit_of_measure    IN VARCHAR2) IS
      SELECT
              UNIT_OF_MEASURE,
              UOM_CODE,
              UOM_CLASS,
              DISABLE_DATE,
              DESCRIPTION
        FROM Okx_Units_Of_Measure_V
       WHERE okx_units_of_measure_v.unit_of_measure = p_unit_of_measure;
  */
    --  l_okx_units_of_measure_v_pk    okx_units_of_measure_v_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_bsdv_rec.BSD_ID IS NOT NULL)
      THEN
        OPEN okc_bsdv_pk_csr(p_bsdv_rec.BSD_ID);
        FETCH okc_bsdv_pk_csr INTO l_okc_bsdv_pk;
        l_row_notfound := okc_bsdv_pk_csr%NOTFOUND;
        CLOSE okc_bsdv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BSD_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_bsdv_rec.BSL_ID IS NOT NULL)
      THEN
        OPEN okc_bslv_pk_csr(p_bsdv_rec.BSL_ID);
        FETCH okc_bslv_pk_csr INTO l_okc_bslv_pk;
        l_row_notfound := okc_bslv_pk_csr%NOTFOUND;
        CLOSE okc_bslv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BSL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      /*
      IF (p_bsdv_rec.UNIT_OF_MEASURE IS NOT NULL)
      THEN
        OPEN okx_units_of_measure_v_pk_csr(p_bsdv_rec.UNIT_OF_MEASURE);
        FETCH okx_units_of_measure_v_pk_csr INTO l_okx_units_of_measure_v_pk;
        l_row_notfound := okx_units_of_measure_v_pk_csr%NOTFOUND;
        CLOSE okx_units_of_measure_v_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'UNIT_OF_MEASURE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      */
      IF (p_bsdv_rec.BSD_ID_APPLIED IS NOT NULL)
      THEN
        OPEN okc_bsdv_pk_csr(p_bsdv_rec.BSD_ID_APPLIED);
        FETCH okc_bsdv_pk_csr INTO l_okc_bsdv_pk;
        l_row_notfound := okc_bsdv_pk_csr%NOTFOUND;
        CLOSE okc_bsdv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BSD_ID_APPLIED');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_bsdv_rec.BSL_ID_AVERAGED IS NOT NULL)
      THEN
        OPEN okc_bslv_pk_csr(p_bsdv_rec.BSL_ID_AVERAGED);
        FETCH okc_bslv_pk_csr INTO l_okc_bslv_pk;
        l_row_notfound := okc_bslv_pk_csr%NOTFOUND;
        CLOSE okc_bslv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BSL_ID_AVERAGED');
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
    l_return_status := validate_foreign_keys (p_bsdv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN bsdv_rec_type,
    p_to	OUT NOCOPY bsd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bsl_id_averaged := p_from.bsl_id_averaged;
    p_to.bsd_id := p_from.bsd_id;
    p_to.bsd_id_applied := p_from.bsd_id_applied;
    p_to.ccr_id := p_from.ccr_id;
    p_to.cgr_id := p_from.cgr_id;
    p_to.start_reading := p_from.start_reading;
    p_to.end_reading := p_from.end_reading;
    p_to.base_reading := p_from.base_reading;
    p_to.estimated_quantity := p_from.estimated_quantity;
    p_to.unit_of_measure := p_from.unit_of_measure;
    p_to.amcv_yn := p_from.amcv_yn;
    p_to.result := p_from.result;
    p_to.amount := p_from.amount;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.fixed := p_from.fixed;
    p_to.actual := p_from.actual;
    p_to.default_default := p_from.default_default;
    p_to.adjustment_level := p_from.adjustment_level;
    p_to.adjustment_minimum := p_from.adjustment_minimum;
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
    p_from	IN bsd_rec_type,
    p_to	OUT NOCOPY bsdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bsl_id_averaged := p_from.bsl_id_averaged;
    p_to.bsd_id := p_from.bsd_id;
    p_to.bsd_id_applied := p_from.bsd_id_applied;
    p_to.ccr_id := p_from.ccr_id;
    p_to.cgr_id := p_from.cgr_id;
    p_to.start_Reading := p_from.start_Reading;
    p_to.end_Reading := p_from.end_Reading;
    p_to.base_Reading := p_from.base_Reading;
    p_to.estimated_quantity := p_from.estimated_quantity;
    p_to.unit_of_measure := p_from.unit_of_measure;
    p_to.amcv_yn := p_from.amcv_yn;
    p_to.result := p_from.result;
    p_to.amount := p_from.amount;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.fixed := p_from.fixed;
    p_to.actual := p_from.actual;
    p_to.default_default := p_from.default_default;
    p_to.adjustment_level := p_from.adjustment_level;
    p_to.adjustment_minimum := p_from.adjustment_minimum;
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
  ----------------------------------------------
  -- validate_row for:OKS_BILL_SUBLINE_DTLS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsdv_rec                     bsdv_rec_type := p_bsdv_rec;
    l_bsd_rec                      bsd_rec_type;
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
    l_return_status := Validate_Attributes(l_bsdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_bsdv_rec);
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
  -- PL/SQL TBL validate_row for:BSDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bsdv_tbl.COUNT > 0) THEN
      i := p_bsdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bsdv_rec                     => p_bsdv_tbl(i));
        EXIT WHEN (i = p_bsdv_tbl.LAST);
        i := p_bsdv_tbl.NEXT(i);
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
  -------------------------------------------
  -- insert_row for:OKS_BILL_SUB_LINE_DTLS --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsd_rec                      IN bsd_rec_type,
    x_bsd_rec                      OUT NOCOPY bsd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsd_rec                      bsd_rec_type := p_bsd_rec;
    l_def_bsd_rec                  bsd_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUB_LINE_DTLS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_bsd_rec IN  bsd_rec_type,
      x_bsd_rec OUT NOCOPY bsd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsd_rec := p_bsd_rec;
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
      p_bsd_rec,                         -- IN
      l_bsd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_BILL_SUB_LINE_DTLS(
        id,
        bsl_id,
        bsl_id_averaged,
        bsd_id,
        bsd_id_applied,
        ccr_id,
        cgr_id,
        start_Reading,
        end_reading,
        base_reading,
        estimated_quantity,
        unit_of_measure,
        amcv_yn,
        result,
        amount,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        fixed,
        actual,
        default_default,
        adjustment_level,
        adjustment_minimum,
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
        l_bsd_rec.id,
        l_bsd_rec.bsl_id,
        l_bsd_rec.bsl_id_averaged,
        l_bsd_rec.bsd_id,
        l_bsd_rec.bsd_id_applied,
        l_bsd_rec.ccr_id,
        l_bsd_rec.cgr_id,
        l_bsd_rec.start_reading,
        l_bsd_rec.end_reading,
        l_bsd_rec.base_reading,
        l_bsd_rec.estimated_quantity,
        l_bsd_rec.unit_of_measure,
        l_bsd_rec.amcv_yn,
        l_bsd_rec.result,
        l_bsd_rec.amount,
        l_bsd_rec.object_version_number,
        l_bsd_rec.created_by,
        l_bsd_rec.creation_date,
        l_bsd_rec.last_updated_by,
        l_bsd_rec.last_update_date,
        l_bsd_rec.fixed,
        l_bsd_rec.actual,
        l_bsd_rec.default_default,
        l_bsd_rec.adjustment_level,
        l_bsd_rec.adjustment_minimum,
        l_bsd_rec.last_update_login,
        l_bsd_rec.attribute_category,
        l_bsd_rec.attribute1,
        l_bsd_rec.attribute2,
        l_bsd_rec.attribute3,
        l_bsd_rec.attribute4,
        l_bsd_rec.attribute5,
        l_bsd_rec.attribute6,
        l_bsd_rec.attribute7,
        l_bsd_rec.attribute8,
        l_bsd_rec.attribute9,
        l_bsd_rec.attribute10,
        l_bsd_rec.attribute11,
        l_bsd_rec.attribute12,
        l_bsd_rec.attribute13,
        l_bsd_rec.attribute14,
        l_bsd_rec.attribute15);
    -- Set OUT values
    x_bsd_rec := l_bsd_rec;
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
  -- insert_row for:OKS_BILL_SUBLINE_DTLS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type,
    x_bsdv_rec                     OUT NOCOPY bsdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsdv_rec                     bsdv_rec_type;
    l_def_bsdv_rec                 bsdv_rec_type;
    l_bsd_rec                      bsd_rec_type;
    lx_bsd_rec                     bsd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bsdv_rec	IN bsdv_rec_type
    ) RETURN bsdv_rec_type IS
      l_bsdv_rec	bsdv_rec_type := p_bsdv_rec;
    BEGIN
      l_bsdv_rec.CREATION_DATE := SYSDATE;
      l_bsdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_bsdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bsdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bsdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bsdv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUBLINE_DTLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_bsdv_rec IN  bsdv_rec_type,
      x_bsdv_rec OUT NOCOPY bsdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsdv_rec := p_bsdv_rec;
      x_bsdv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_bsdv_rec := null_out_defaults(p_bsdv_rec);
    -- Set primary key value
    l_bsdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_bsdv_rec,                        -- IN
      l_def_bsdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bsdv_rec := fill_who_columns(l_def_bsdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bsdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bsdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bsdv_rec, l_bsd_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsd_rec,
      lx_bsd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bsd_rec, l_def_bsdv_rec);
    -- Set OUT values
    x_bsdv_rec := l_def_bsdv_rec;
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
  -- PL/SQL TBL insert_row for:BSDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type,
    x_bsdv_tbl                     OUT NOCOPY bsdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bsdv_tbl.COUNT > 0) THEN
      i := p_bsdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bsdv_rec                     => p_bsdv_tbl(i),
          x_bsdv_rec                     => x_bsdv_tbl(i));
        EXIT WHEN (i = p_bsdv_tbl.LAST);
        i := p_bsdv_tbl.NEXT(i);
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
  -----------------------------------------
  -- lock_row for:OKS_BILL_SUB_LINE_DTLS --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsd_rec                      IN bsd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bsd_rec IN bsd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_SUB_LINE_DTLS
     WHERE ID = p_bsd_rec.id
       AND OBJECT_VERSION_NUMBER = p_bsd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_bsd_rec IN bsd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILL_SUB_LINE_DTLS
    WHERE ID = p_bsd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_BILL_SUB_LINE_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_BILL_SUB_LINE_DTLS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_bsd_rec);
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
      OPEN lchk_csr(p_bsd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_bsd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_bsd_rec.object_version_number THEN
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
  -- lock_row for:OKS_BILL_SUBLINE_DTLS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsd_rec                      bsd_rec_type;
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
    migrate(p_bsdv_rec, l_bsd_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsd_rec
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
  -- PL/SQL TBL lock_row for:BSDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bsdv_tbl.COUNT > 0) THEN
      i := p_bsdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bsdv_rec                     => p_bsdv_tbl(i));
        EXIT WHEN (i = p_bsdv_tbl.LAST);
        i := p_bsdv_tbl.NEXT(i);
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
  -------------------------------------------
  -- update_row for:OKS_BILL_SUB_LINE_DTLS --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsd_rec                      IN bsd_rec_type,
    x_bsd_rec                      OUT NOCOPY bsd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsd_rec                      bsd_rec_type := p_bsd_rec;
    l_def_bsd_rec                  bsd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bsd_rec	IN bsd_rec_type,
      x_bsd_rec	OUT NOCOPY bsd_rec_type
    ) RETURN VARCHAR2 IS
      l_bsd_rec                      bsd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsd_rec := p_bsd_rec;
      -- Get current database values
      l_bsd_rec := get_rec(p_bsd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bsd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.id := l_bsd_rec.id;
      END IF;
      IF (x_bsd_rec.bsl_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.bsl_id := l_bsd_rec.bsl_id;
      END IF;
      IF (x_bsd_rec.bsl_id_averaged = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.bsl_id_averaged := l_bsd_rec.bsl_id_averaged;
      END IF;
      IF (x_bsd_rec.bsd_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.bsd_id := l_bsd_rec.bsd_id;
      END IF;
      IF (x_bsd_rec.bsd_id_applied = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.bsd_id_applied := l_bsd_rec.bsd_id_applied;
      END IF;
      IF (x_bsd_rec.ccr_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.ccr_id := l_bsd_rec.ccr_id;
      END IF;
      IF (x_bsd_rec.cgr_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.cgr_id := l_bsd_rec.cgr_id;
      END IF;
      IF (x_bsd_rec.start_reading = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.start_reading := l_bsd_rec.start_reading;
      END IF;
      IF (x_bsd_rec.end_reading = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.end_reading := l_bsd_rec.end_reading;
      END IF;
      IF (x_bsd_rec.base_reading = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.base_reading := l_bsd_rec.base_reading;
      END IF;
      IF (x_bsd_rec.estimated_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.estimated_quantity := l_bsd_rec.estimated_quantity;
      END IF;
      IF (x_bsd_rec.unit_of_measure = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.unit_of_measure := l_bsd_rec.unit_of_measure;
      END IF;
      IF (x_bsd_rec.amcv_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.amcv_yn := l_bsd_rec.amcv_yn;
      END IF;
      IF (x_bsd_rec.result = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.result := l_bsd_rec.result;
      END IF;
      IF (x_bsd_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.amount := l_bsd_rec.amount;
      END IF;
      IF (x_bsd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.object_version_number := l_bsd_rec.object_version_number;
      END IF;
      IF (x_bsd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.created_by := l_bsd_rec.created_by;
      END IF;
      IF (x_bsd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_bsd_rec.creation_date := l_bsd_rec.creation_date;
      END IF;
      IF (x_bsd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.last_updated_by := l_bsd_rec.last_updated_by;
      END IF;
      IF (x_bsd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_bsd_rec.last_update_date := l_bsd_rec.last_update_date;
      END IF;
      IF (x_bsd_rec.fixed = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.fixed := l_bsd_rec.fixed;
      END IF;
      IF (x_bsd_rec.actual = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.actual := l_bsd_rec.actual;
      END IF;
      IF (x_bsd_rec.default_default = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.default_default := l_bsd_rec.default_default;
      END IF;
      IF (x_bsd_rec.adjustment_level = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.adjustment_level := l_bsd_rec.adjustment_level;
      END IF;
      IF (x_bsd_rec.adjustment_minimum = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.adjustment_minimum := l_bsd_rec.adjustment_minimum;
      END IF;
      IF (x_bsd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_bsd_rec.last_update_login := l_bsd_rec.last_update_login;
      END IF;
      IF (x_bsd_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute_category := l_bsd_rec.attribute_category;
      END IF;
      IF (x_bsd_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute1 := l_bsd_rec.attribute1;
      END IF;
      IF (x_bsd_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute2 := l_bsd_rec.attribute2;
      END IF;
      IF (x_bsd_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute3 := l_bsd_rec.attribute3;
      END IF;
      IF (x_bsd_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute4 := l_bsd_rec.attribute4;
      END IF;
      IF (x_bsd_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute5 := l_bsd_rec.attribute5;
      END IF;
      IF (x_bsd_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute6 := l_bsd_rec.attribute6;
      END IF;
      IF (x_bsd_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute7 := l_bsd_rec.attribute7;
      END IF;
      IF (x_bsd_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute8 := l_bsd_rec.attribute8;
      END IF;
      IF (x_bsd_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute9 := l_bsd_rec.attribute9;
      END IF;
      IF (x_bsd_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute10 := l_bsd_rec.attribute10;
      END IF;
      IF (x_bsd_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute11 := l_bsd_rec.attribute11;
      END IF;
      IF (x_bsd_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute12 := l_bsd_rec.attribute12;
      END IF;
      IF (x_bsd_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute13 := l_bsd_rec.attribute13;
      END IF;
      IF (x_bsd_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute14 := l_bsd_rec.attribute14;
      END IF;
      IF (x_bsd_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsd_rec.attribute15 := l_bsd_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUB_LINE_DTLS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_bsd_rec IN  bsd_rec_type,
      x_bsd_rec OUT NOCOPY bsd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsd_rec := p_bsd_rec;
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
      p_bsd_rec,                         -- IN
      l_bsd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bsd_rec, l_def_bsd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_BILL_SUB_LINE_DTLS
    SET BSL_ID = l_def_bsd_rec.bsl_id,
        BSL_ID_AVERAGED = l_def_bsd_rec.bsl_id_averaged,
        BSD_ID = l_def_bsd_rec.bsd_id,
        BSD_ID_APPLIED = l_def_bsd_rec.bsd_id_applied,
        CCR_ID         = l_def_bsd_rec.ccr_id,
        CGR_ID         = l_def_bsd_rec.cgr_id,
        START_READING         = l_def_bsd_rec.start_reading,
        END_READING         = l_def_bsd_rec.end_reading,
        BASE_READING         = l_def_bsd_rec.base_reading,
        ESTIMATED_QUANTITY         = l_def_bsd_rec.estimated_quantity,
        UNIT_OF_MEASURE = l_def_bsd_rec.unit_of_measure,
        AMCV_YN = l_def_bsd_rec.amcv_yn,
        RESULT = l_def_bsd_rec.result,
        AMOUNT = l_def_bsd_rec.amount,
        OBJECT_VERSION_NUMBER = l_def_bsd_rec.object_version_number,
        CREATED_BY = l_def_bsd_rec.created_by,
        CREATION_DATE = l_def_bsd_rec.creation_date,
        LAST_UPDATED_BY = l_def_bsd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bsd_rec.last_update_date,
        FIXED = l_def_bsd_rec.fixed,
        ACTUAL = l_def_bsd_rec.actual,
        DEFAULT_DEFAULT = l_def_bsd_rec.default_default,
        ADJUSTMENT_LEVEL = l_def_bsd_rec.adjustment_level,
        ADJUSTMENT_MINIMUM = l_def_bsd_rec.adjustment_minimum,
        LAST_UPDATE_LOGIN = l_def_bsd_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_bsd_rec.attribute_category,
        ATTRIBUTE1 = l_def_bsd_rec.attribute1,
        ATTRIBUTE2 = l_def_bsd_rec.attribute2,
        ATTRIBUTE3 = l_def_bsd_rec.attribute3,
        ATTRIBUTE4 = l_def_bsd_rec.attribute4,
        ATTRIBUTE5 = l_def_bsd_rec.attribute5,
        ATTRIBUTE6 = l_def_bsd_rec.attribute6,
        ATTRIBUTE7 = l_def_bsd_rec.attribute7,
        ATTRIBUTE8 = l_def_bsd_rec.attribute8,
        ATTRIBUTE9 = l_def_bsd_rec.attribute9,
        ATTRIBUTE10 = l_def_bsd_rec.attribute10,
        ATTRIBUTE11 = l_def_bsd_rec.attribute11,
        ATTRIBUTE12 = l_def_bsd_rec.attribute12,
        ATTRIBUTE13 = l_def_bsd_rec.attribute13,
        ATTRIBUTE14 = l_def_bsd_rec.attribute14,
        ATTRIBUTE15 = l_def_bsd_rec.attribute15
    WHERE ID = l_def_bsd_rec.id;

    x_bsd_rec := l_def_bsd_rec;
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
  -- update_row for:OKS_BILL_SUBLINE_DTLS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type,
    x_bsdv_rec                     OUT NOCOPY bsdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsdv_rec                     bsdv_rec_type := p_bsdv_rec;
    l_def_bsdv_rec                 bsdv_rec_type;
    l_bsd_rec                      bsd_rec_type;
    lx_bsd_rec                     bsd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bsdv_rec	IN bsdv_rec_type
    ) RETURN bsdv_rec_type IS
      l_bsdv_rec	bsdv_rec_type := p_bsdv_rec;
    BEGIN
      l_bsdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bsdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bsdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bsdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bsdv_rec	IN bsdv_rec_type,
      x_bsdv_rec	OUT NOCOPY bsdv_rec_type
    ) RETURN VARCHAR2 IS
      l_bsdv_rec                     bsdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsdv_rec := p_bsdv_rec;
      -- Get current database values
      l_bsdv_rec := get_rec(p_bsdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_bsdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.id := l_bsdv_rec.id;
      END IF;
      IF (x_bsdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.object_version_number := l_bsdv_rec.object_version_number;
      END IF;
      IF (x_bsdv_rec.bsl_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.bsl_id := l_bsdv_rec.bsl_id;
      END IF;
      IF (x_bsdv_rec.bsl_id_averaged = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.bsl_id_averaged := l_bsdv_rec.bsl_id_averaged;
      END IF;
      IF (x_bsdv_rec.bsd_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.bsd_id := l_bsdv_rec.bsd_id;
      END IF;
      IF (x_bsdv_rec.bsd_id_applied = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.bsd_id_applied := l_bsdv_rec.bsd_id_applied;
      END IF;
      IF (x_bsdv_rec.ccr_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.ccr_id := l_bsdv_rec.ccr_id;
      END IF;
      IF (x_bsdv_rec.cgr_id = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.cgr_id := l_bsdv_rec.cgr_id;
      END IF;
      IF (x_bsdv_rec.start_Reading = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.start_Reading := l_bsdv_rec.start_Reading;
      END IF;
      IF (x_bsdv_rec.end_reading = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.end_reading := l_bsdv_rec.end_reading;
      END IF;
      IF (x_bsdv_rec.base_reading = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.base_reading := l_bsdv_rec.base_reading;
      END IF;
      IF (x_bsdv_rec.estimated_quantity = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.estimated_quantity := l_bsdv_rec.estimated_quantity;
      END IF;
      IF (x_bsdv_rec.unit_of_measure = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.unit_of_measure := l_bsdv_rec.unit_of_measure;
      END IF;
      IF (x_bsdv_rec.fixed = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.fixed := l_bsdv_rec.fixed;
      END IF;
      IF (x_bsdv_rec.actual = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.actual := l_bsdv_rec.actual;
      END IF;
      IF (x_bsdv_rec.default_default = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.default_default := l_bsdv_rec.default_default;
      END IF;
      IF (x_bsdv_rec.amcv_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.amcv_yn := l_bsdv_rec.amcv_yn;
      END IF;
      IF (x_bsdv_rec.adjustment_level = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.adjustment_level := l_bsdv_rec.adjustment_level;
      END IF;
      IF (x_bsdv_rec.adjustment_minimum = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.adjustment_minimum := l_bsdv_rec.adjustment_minimum;
      END IF;
      IF (x_bsdv_rec.result = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.result := l_bsdv_rec.result;
      END IF;
      IF (x_bsdv_rec.amount = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.amount := l_bsdv_rec.amount;
      END IF;
      IF (x_bsdv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute_category := l_bsdv_rec.attribute_category;
      END IF;
      IF (x_bsdv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute1 := l_bsdv_rec.attribute1;
      END IF;
      IF (x_bsdv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute2 := l_bsdv_rec.attribute2;
      END IF;
      IF (x_bsdv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute3 := l_bsdv_rec.attribute3;
      END IF;
      IF (x_bsdv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute4 := l_bsdv_rec.attribute4;
      END IF;
      IF (x_bsdv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute5 := l_bsdv_rec.attribute5;
      END IF;
      IF (x_bsdv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute6 := l_bsdv_rec.attribute6;
      END IF;
      IF (x_bsdv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute7 := l_bsdv_rec.attribute7;
      END IF;
      IF (x_bsdv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute8 := l_bsdv_rec.attribute8;
      END IF;
      IF (x_bsdv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute9 := l_bsdv_rec.attribute9;
      END IF;
      IF (x_bsdv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute10 := l_bsdv_rec.attribute10;
      END IF;
      IF (x_bsdv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute11 := l_bsdv_rec.attribute11;
      END IF;
      IF (x_bsdv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute12 := l_bsdv_rec.attribute12;
      END IF;
      IF (x_bsdv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute13 := l_bsdv_rec.attribute13;
      END IF;
      IF (x_bsdv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute14 := l_bsdv_rec.attribute14;
      END IF;
      IF (x_bsdv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_bsdv_rec.attribute15 := l_bsdv_rec.attribute15;
      END IF;
      IF (x_bsdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.created_by := l_bsdv_rec.created_by;
      END IF;
      IF (x_bsdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_bsdv_rec.creation_date := l_bsdv_rec.creation_date;
      END IF;
      IF (x_bsdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.last_updated_by := l_bsdv_rec.last_updated_by;
      END IF;
      IF (x_bsdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_bsdv_rec.last_update_date := l_bsdv_rec.last_update_date;
      END IF;
      IF (x_bsdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_bsdv_rec.last_update_login := l_bsdv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKS_BILL_SUBLINE_DTLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_bsdv_rec IN  bsdv_rec_type,
      x_bsdv_rec OUT NOCOPY bsdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bsdv_rec := p_bsdv_rec;
      x_bsdv_rec.OBJECT_VERSION_NUMBER := NVL(x_bsdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_bsdv_rec,                        -- IN
      l_bsdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bsdv_rec, l_def_bsdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bsdv_rec := fill_who_columns(l_def_bsdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bsdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bsdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_bsdv_rec, l_bsd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsd_rec,
      lx_bsd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bsd_rec, l_def_bsdv_rec);
    x_bsdv_rec := l_def_bsdv_rec;
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
  -- PL/SQL TBL update_row for:BSDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type,
    x_bsdv_tbl                     OUT NOCOPY bsdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bsdv_tbl.COUNT > 0) THEN
      i := p_bsdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bsdv_rec                     => p_bsdv_tbl(i),
          x_bsdv_rec                     => x_bsdv_tbl(i));
        EXIT WHEN (i = p_bsdv_tbl.LAST);
        i := p_bsdv_tbl.NEXT(i);
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
  -------------------------------------------
  -- delete_row for:OKS_BILL_SUB_LINE_DTLS --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsd_rec                      IN bsd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsd_rec                      bsd_rec_type:= p_bsd_rec;
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
    DELETE FROM OKS_BILL_SUB_LINE_DTLS
     WHERE ID = l_bsd_rec.id;

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
  -- delete_row for:OKS_BILL_SUBLINE_DTLS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec                     IN bsdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bsdv_rec                     bsdv_rec_type := p_bsdv_rec;
    l_bsd_rec                      bsd_rec_type;
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
    migrate(l_bsdv_rec, l_bsd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_bsd_rec
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
  -- PL/SQL TBL delete_row for:BSDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_tbl                     IN bsdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bsdv_tbl.COUNT > 0) THEN
      i := p_bsdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_bsdv_rec                     => p_bsdv_tbl(i));
        EXIT WHEN (i = p_bsdv_tbl.LAST);
        i := p_bsdv_tbl.NEXT(i);
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
END OKS_BSD_PVT;

/
