--------------------------------------------------------
--  DDL for Package Body OKC_SCR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SCR_PVT" AS
/* $Header: OKCRSCRB.pls 120.0 2005/05/25 23:10:20 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  -- FUNCTION get_rec for: OKC_K_SALES_CREDITS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_scr_rec                      IN scr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scr_rec_type IS
    CURSOR okc_k_sales_credits_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PERCENT,

            CHR_ID,
            DNZ_CHR_ID,

            CLE_ID,

            --CTC_ID,
            --replaced by SALESREP_ID1, SALESREP_ID2
            SALESREP_ID1,
            SALESREP_ID2,

            SALES_CREDIT_TYPE_ID1,
            SALES_CREDIT_TYPE_ID2,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
      FROM Okc_K_Sales_Credits
     WHERE okc_k_sales_credits.id = p_id;
    l_okc_k_sales_credits_pk       okc_k_sales_credits_pk_csr%ROWTYPE;
    l_scr_rec                      scr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_k_sales_credits_pk_csr (p_scr_rec.id);
    FETCH okc_k_sales_credits_pk_csr INTO
              l_scr_rec.ID,
              l_scr_rec.PERCENT,

              l_scr_rec.CHR_ID,
              l_scr_rec.DNZ_CHR_ID,

              l_scr_rec.CLE_ID,

              --l_scr_rec.CTC_ID,
              --replaced by SALESREP_ID1, SALESREP_ID2
              l_scr_rec.SALESREP_ID1,
              l_scr_rec.SALESREP_ID2,

              l_scr_rec.SALES_CREDIT_TYPE_ID1,
              l_scr_rec.SALES_CREDIT_TYPE_ID2,
              l_scr_rec.OBJECT_VERSION_NUMBER,
              l_scr_rec.CREATED_BY,
              l_scr_rec.CREATION_DATE,
              l_scr_rec.LAST_UPDATED_BY,
              l_scr_rec.LAST_UPDATE_DATE;
    x_no_data_found := okc_k_sales_credits_pk_csr%NOTFOUND;
    CLOSE okc_k_sales_credits_pk_csr;
    RETURN(l_scr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_scr_rec                      IN scr_rec_type
  ) RETURN scr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_scr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_SALES_CREDITS_V
  ---------------------------------------------------------------------------
   FUNCTION get_rec (
    p_scrv_rec    IN scrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN scrv_rec_type IS
  CURSOR okc_scrv_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PERCENT,

            CHR_ID,
            DNZ_CHR_ID,

            CLE_ID,

            --CTC_ID,
            --replaced by SALESREP_ID1, SALESREP_ID2
            SALESREP_ID1,
            SALESREP_ID2,

            SALES_CREDIT_TYPE_ID1,
            SALES_CREDIT_TYPE_ID2,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
      FROM Okc_K_Sales_Credits
     WHERE okc_k_sales_credits.id = p_id;
    l_scrv_pk       okc_scrv_csr%ROWTYPE;
    l_scrv_rec                      scrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values

    OPEN okc_scrv_csr (p_scrv_rec.id);
    FETCH okc_scrv_csr INTO
              l_scrv_rec.ID,
              l_scrv_rec.PERCENT,

              l_scrv_rec.CHR_ID,
              l_scrv_rec.DNZ_CHR_ID,

              l_scrv_rec.CLE_ID,

              --l_scrv_rec.CTC_ID,
              --replaced by SALESREP_ID1, SALESREP_ID2
              l_scrv_rec.SALESREP_ID1,
              l_scrv_rec.SALESREP_ID2,

              l_scrv_rec.SALES_CREDIT_TYPE_ID1,
              l_scrv_rec.SALES_CREDIT_TYPE_ID2,
              l_scrv_rec.OBJECT_VERSION_NUMBER,
              l_scrv_rec.CREATED_BY,
              l_scrv_rec.CREATION_DATE,
              l_scrv_rec.LAST_UPDATED_BY,
              l_scrv_rec.LAST_UPDATE_DATE;
    x_no_data_found := okc_scrv_csr%NOTFOUND;

    CLOSE okc_scrv_csr;
    RETURN(l_scrv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_scrv_rec    IN scrv_rec_type
  ) RETURN scrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_scrv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_SALES_CREDITS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_scrv_rec	IN scrv_rec_type
  ) RETURN scrv_rec_type IS
    l_scrv_rec	scrv_rec_type := p_scrv_rec;
  BEGIN
    IF (l_scrv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.id := NULL;
    END IF;
    IF (l_scrv_rec.percent = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.percent := NULL;
    END IF;
    IF (l_scrv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.chr_id := NULL;
    END IF;
    IF (l_scrv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_scrv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.cle_id := NULL;
    END IF;

    --IF (l_scrv_rec.ctc_id = OKC_API.G_MISS_NUM) THEN
    --  l_scrv_rec.ctc_id := NULL;
    --END IF;
    --replaced by SALESREP_ID1, SALESREP_ID2
    IF (l_scrv_rec.salesrep_id1 = OKC_API.G_MISS_CHAR) THEN
      l_scrv_rec.salesrep_id1 := NULL;
    END IF;
    IF (l_scrv_rec.salesrep_id2 = OKC_API.G_MISS_CHAR) THEN
      l_scrv_rec.salesrep_id2 := NULL;
    END IF;

    IF (l_scrv_rec.sales_credit_type_id1 = OKC_API.G_MISS_CHAR) THEN
      l_scrv_rec.sales_credit_type_id1 := NULL;
    END IF;
    IF (l_scrv_rec.sales_credit_type_id2 = OKC_API.G_MISS_CHAR) THEN
      l_scrv_rec.sales_credit_type_id2 := NULL;
    END IF;
    IF (l_scrv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.object_version_number := NULL;
    END IF;
    IF (l_scrv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.created_by := NULL;
    END IF;
    IF (l_scrv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_scrv_rec.creation_date := NULL;
    END IF;
    IF (l_scrv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_scrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_scrv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_scrv_rec.last_update_date := NULL;
    END IF;
    RETURN(l_scrv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKC_K_SALES_CREDITS_V --
  ---------------------------------------------------
  -----------------------------------------------------
  -- Validate ID--
  -----------------------------------------------------
  PROCEDURE validate_id(x_return_status OUT NOCOPY varchar2,
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_SCRV_REC.id = OKC_API.G_MISS_NUM OR
       P_SCRV_REC.id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
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
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_SCRV_REC.object_version_number = OKC_API.G_MISS_NUM OR
       P_SCRV_REC.object_version_number IS NULL
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
  -- Validate CHR_ID
  -----------------------------------------------------
  PROCEDURE validate_CHR_ID (x_return_status OUT NOCOPY varchar2,
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_Count	INTEGER;
  CURSOR Chr_Cur IS
  SELECT COUNT(1) FROM OKC_K_Headers_v
  WHERE ID=P_SCRV_REC.CHR_ID;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If P_SCRV_REC.CHR_ID = OKC_API.G_MISS_NUM OR
          P_SCRV_REC.CHR_ID IS NULL
  Then
     OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_Id');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

    OPEN Chr_Cur;
    FETCH Chr_Cur INTO l_Count;
    CLOSE Chr_Cur;
    IF NOT l_Count=1
    THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_Id');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

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
  END validate_CHR_ID;

  -----------------------------------------------------
  -- Validate Cle_Id
  -----------------------------------------------------
  PROCEDURE validate_Cle_Id (x_return_status OUT NOCOPY varchar2,
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_Count	INTEGER;
  CURSOR Cle_Cur IS
  SELECT COUNT(1) FROM OKC_K_Lines_V
  WHERE ID=P_SCRV_REC.Cle_Id;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If NOT (P_SCRV_REC.cle_Id = OKC_API.G_MISS_NUM OR
          P_SCRV_REC.cle_Id IS NULL)
  Then
    OPEN cle_Cur;
    FETCH cle_Cur INTO l_Count;
    CLOSE cle_Cur;

    IF NOT l_Count=1
    THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Cle_Id');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
 END IF;
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
  END validate_Cle_Id;

  /******   was not being used even in the original version - abkumar
  -----------------------------------------------------
  -- Validate CTC_Id
  -----------------------------------------------------
  PROCEDURE validate_CTC_Id(	x_return_status OUT NOCOPY varchar2,
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  CURSOR Ctc_Cur IS
  SELECT COUNT(1) FROM Okx_Vendor_Contacts_v
  WHERE Id1=P_SCRV_REC.ctc_Id;
  l_Count NUMBER;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_SCRV_REC.Ctc_Id= OKC_API.G_MISS_NUM OR
          P_SCRV_REC.Ctc_Id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CTC_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
    OPEN Ctc_Cur;
    FETCH Ctc_Cur INTO l_Count;
    CLOSE Ctc_Cur;
    IF NOT l_Count=1
    THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CTC_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

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
  END validate_CTC_Id;
  ********/

  -----------------------------------------------------
  -- Validate SALES_CREDIT_Type_Id1
  -----------------------------------------------------
  PROCEDURE validate_SALES_CREDIT_Type_Id1
                              (x_return_status OUT NOCOPY varchar2,
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_SCRV_REC.SALES_CREDIT_Type_Id1= OKC_API.G_MISS_CHAR OR
     P_SCRV_REC.SALES_CREDIT_Type_Id1 IS NULL
  Then
      OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SALES_CREDIT_Type_Id1');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

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
  END validate_SALES_CREDIT_Type_Id1;

  -----------------------------------------------------
  -- Validate SALES_CREDIT_Type_Id2
  -----------------------------------------------------
  PROCEDURE validate_SALES_CREDIT_Type_Id2
                              (x_return_status OUT NOCOPY varchar2,
				P_SCRV_REC   IN  SCRV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_SCRV_REC.SALES_CREDIT_Type_Id2= OKC_API.G_MISS_CHAR OR
     P_SCRV_REC.SALES_CREDIT_Type_Id2 IS NULL
  Then
      OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'SALES_CREDIT_Type_Id2');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

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
  END validate_SALES_CREDIT_Type_Id2;


---------------------------------------------------
  -- Validate_Attributes for:OKC_K_SALES_CREDITS_V --
  ---------------------------------------------------
 FUNCTION Validate_Attributes (
    p_scrv_rec IN  scrv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKC_K_SALES_CREDITS_V',x_return_status);

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
    validate_id(x_return_status, p_scrv_rec);

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
    validate_objvernum(x_return_status, p_scrv_rec);

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
    --CHR_ID
		validate_CHR_ID(x_return_status, p_scrv_rec);
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

    --Cle_Id
		validate_Cle_Id(x_return_status, p_scrv_rec);
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

    --Ctc_Id
/*
		validate_Ctc_Id(x_return_status, p_scrv_rec);
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

*/


    --SALES_CREDIT_Type_Id1
		validate_SALES_CREDIT_Type_Id1(x_return_status, p_scrv_rec);
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
    --SALES_CREDIT_Type_Id2
		validate_SALES_CREDIT_Type_Id2(x_return_status, p_scrv_rec);
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
      Return (l_return_status);
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

  -----------------------------------------------
  -- Validate_Record for:OKC_K_SALES_CREDITS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_scrv_rec IN scrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_Return_Status:=Validate_Attributes(p_scrv_Rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN scrv_rec_type,
    p_to	OUT NOCOPY scr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.percent := p_from.percent;

    p_to.chr_id := p_from.chr_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;

    p_to.cle_id := p_from.cle_id;

    --p_to.ctc_id := p_from.ctc_id;
    --replaced by SALESREP_ID1, SALESREP_ID2
    p_to.salesrep_id1 := p_from.salesrep_id1;
    p_to.salesrep_id2 := p_from.salesrep_id2;

    p_to.sales_credit_type_id1 := p_from.sales_credit_type_id1;
    p_to.sales_credit_type_id2 := p_from.sales_credit_type_id2;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;
  PROCEDURE migrate (
    p_from	IN scr_rec_type,
    p_to	OUT NOCOPY scrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.percent := p_from.percent;

    p_to.chr_id := p_from.chr_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;

    p_to.cle_id := p_from.cle_id;

    --p_to.ctc_id := p_from.ctc_id;
    --replaced by SALESREP_ID1, SALESREP_ID2
    p_to.salesrep_id1 := p_from.salesrep_id1;
    p_to.salesrep_id2 := p_from.salesrep_id2;

    p_to.sales_credit_type_id1 := p_from.sales_credit_type_id1;
    p_to.sales_credit_type_id2 := p_from.sales_credit_type_id2;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKC_K_SALES_CREDITS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scrv_rec    scrv_rec_type := p_scrv_rec;
    l_scr_rec                      scr_rec_type;
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
    l_return_status := Validate_Attributes(l_scrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_scrv_rec);
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
  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKC_K_SALES_CREDITS_V_TBL --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scrv_tbl.COUNT > 0) THEN
      i := p_scrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scrv_rec    => p_scrv_tbl(i));
        EXIT WHEN (i = p_scrv_tbl.LAST);
        i := p_scrv_tbl.NEXT(i);
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



  FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

  BEGIN
     INSERT INTO okc_k_sales_credits_h
     (
        major_version,
        id,
        dnz_chr_id,
        percent,
        chr_id,
        cle_id,
        salesrep_id1,
        salesrep_id2,
        sales_credit_type_id1,
        sales_credit_type_id2,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date
      )

      SELECT
         p_major_version,
         id,
         dnz_chr_id,
         percent,
         chr_id,
         cle_id,
         salesrep_id1,
         salesrep_id2,
         sales_credit_type_id1,
         sales_credit_type_id2,
         object_version_number,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date
    FROM okc_k_sales_credits
    WHERE dnz_chr_id = p_chr_id;

   RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_scr_pvt.G_APP_NAME,
                                 p_msg_name     => okc_scr_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_scr_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_scr_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
   END create_version;



   FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

   l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;


   BEGIN

     INSERT INTO okc_k_sales_credits
     (
        id,
        dnz_chr_id,
        percent,
        chr_id,
        cle_id,
        salesrep_id1,
        salesrep_id2,
        sales_credit_type_id1,
        sales_credit_type_id2,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date
      )

      SELECT
         id,
         dnz_chr_id,
         percent,
         chr_id,
         cle_id,
         salesrep_id1,
         salesrep_id2,
         sales_credit_type_id1,
         sales_credit_type_id2,
         object_version_number,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date
    FROM okc_k_sales_credits_h
    WHERE dnz_chr_id = p_chr_id
          AND major_version = p_major_version;


   RETURN l_return_status;
   EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_scr_pvt.G_APP_NAME,
                                 p_msg_name     => okc_scr_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_scr_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_scr_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
   END restore_version;



  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for:OKC_K_SALES_CREDITS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scr_rec                      IN scr_rec_type,
    x_scr_rec                      OUT NOCOPY scr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CREDITS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scr_rec                      scr_rec_type := p_scr_rec;
    l_def_scr_rec                  scr_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKC_K_SALES_CREDITS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_scr_rec IN  scr_rec_type,
      x_scr_rec OUT NOCOPY scr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scr_rec := p_scr_rec;
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
      p_scr_rec,                         -- IN
      l_scr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_scr_rec.id := get_seq_id;

    INSERT INTO OKC_K_SALES_CREDITS(
        id,
        percent,

        chr_id,
        dnz_chr_id,

        cle_id,

        --ctc_id,
        --replaced by SALESREP_ID1, SALESREP_ID2
        salesrep_id1,
        salesrep_id2,

        sales_credit_type_id1,
        sales_credit_type_id2,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date
        )
      VALUES (
        l_scr_rec.id,
        l_scr_rec.percent,

        l_scr_rec.chr_id,
        l_scr_rec.dnz_chr_id,

        l_scr_rec.cle_id,

        --l_scr_rec.ctc_id,
        --replaced by SALESREP_ID1, SALESREP_ID2
        l_scr_rec.salesrep_id1,
        l_scr_rec.salesrep_id2,

        l_scr_rec.sales_credit_type_id1,
        l_scr_rec.sales_credit_type_id2,
        l_scr_rec.object_version_number,
        l_scr_rec.created_by,
        l_scr_rec.creation_date,
        l_scr_rec.last_updated_by,
        l_scr_rec.last_update_date);
    -- Set OUT values
    x_scr_rec := l_scr_rec;
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
  -- insert_row for:OKC_K_SALES_CREDITS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type,
    x_scrv_rec    OUT NOCOPY scrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scrv_rec    scrv_rec_type;
    ldefokcksalescreditsvrec       scrv_rec_type;
    l_scr_rec                      scr_rec_type;
    lx_scr_rec                     scr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_scrv_rec	IN scrv_rec_type
    ) RETURN scrv_rec_type IS
      l_scrv_rec	scrv_rec_type := p_scrv_rec;
    BEGIN
      l_scrv_rec.CREATION_DATE := SYSDATE;
      l_scrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_scrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_scrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_scrv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_K_SALES_CREDITS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_scrv_rec IN  scrv_rec_type,
      x_scrv_rec OUT NOCOPY scrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scrv_rec := p_scrv_rec;
      x_scrv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_scrv_rec := null_out_defaults(p_scrv_rec);

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_scrv_rec,       -- IN
      ldefokcksalescreditsvrec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    ldefokcksalescreditsvrec := fill_who_columns(ldefokcksalescreditsvrec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(ldefokcksalescreditsvrec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(ldefokcksalescreditsvrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(ldefokcksalescreditsvrec, l_scr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scr_rec,
      lx_scr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scr_rec, ldefokcksalescreditsvrec);
    -- Set OUT values
    x_scrv_rec := ldefokcksalescreditsvrec;
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
  ---------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKC_K_SALES_CREDITS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type,
    x_scrv_tbl    OUT NOCOPY scrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scrv_tbl.COUNT > 0) THEN
      i := p_scrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scrv_rec    => p_scrv_tbl(i),
          x_scrv_rec    => x_scrv_tbl(i));
        EXIT WHEN (i = p_scrv_tbl.LAST);
        i := p_scrv_tbl.NEXT(i);
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
  -- lock_row for:OKC_K_SALES_CREDITS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scr_rec                      IN scr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_scr_rec IN scr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_SALES_CREDITS
     WHERE ID = p_scr_rec.id
       AND OBJECT_VERSION_NUMBER = p_scr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_scr_rec IN scr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKc_K_SALES_CREDITS
    WHERE ID = p_scr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CREDITS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_SALES_CREDITS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_SALES_CREDITS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_scr_rec);
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
      OPEN lchk_csr(p_scr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_scr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_scr_rec.object_version_number THEN
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
  -- lock_row for:OKC_K_SALES_CREDITS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scr_rec                      scr_rec_type;
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
    migrate(p_scrv_rec, l_scr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scr_rec
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
  -------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKC_K_SALES_CREDITS_V_TBL --
  -------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scrv_tbl.COUNT > 0) THEN
      i := p_scrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scrv_rec    => p_scrv_tbl(i));
        EXIT WHEN (i = p_scrv_tbl.LAST);
        i := p_scrv_tbl.NEXT(i);
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
  -- update_row for:OKC_K_SALES_CREDITS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scr_rec                      IN scr_rec_type,
    x_scr_rec                      OUT NOCOPY scr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CREDITS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scr_rec                      scr_rec_type := p_scr_rec;
    l_def_scr_rec                  scr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scr_rec	IN scr_rec_type,
      x_scr_rec	OUT NOCOPY scr_rec_type
    ) RETURN VARCHAR2 IS
      l_scr_rec                      scr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scr_rec := p_scr_rec;
      -- Get current database values
      l_scr_rec := get_rec(p_scr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scr_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.id := l_scr_rec.id;
      END IF;
      IF (x_scr_rec.percent = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.percent := l_scr_rec.percent;
      END IF;

      IF (x_scr_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.chr_id := l_scr_rec.chr_id;
      END IF;
      IF (x_scr_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.dnz_chr_id := l_scr_rec.dnz_chr_id;
      END IF;


      IF (x_scr_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.cle_id := l_scr_rec.cle_id;
      END IF;

      --IF (x_scr_rec.ctc_id = OKC_API.G_MISS_NUM)
      --THEN
      --  x_scr_rec.ctc_id := l_scr_rec.ctc_id;
      --END IF;
      --replaced by SALESREP_ID1, SALESREP_ID2
      IF (x_scr_rec.salesrep_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scr_rec.salesrep_id1 := l_scr_rec.salesrep_id1;
      END IF;
      IF (x_scr_rec.salesrep_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scr_rec.salesrep_id2 := l_scr_rec.salesrep_id2;
      END IF;


      IF (x_scr_rec.sales_credit_type_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scr_rec.sales_credit_type_id1 := l_scr_rec.sales_credit_type_id1;
      END IF;
      IF (x_scr_rec.sales_credit_type_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scr_rec.sales_credit_type_id2 := l_scr_rec.sales_credit_type_id2;
      END IF;
      IF (x_scr_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.object_version_number := l_scr_rec.object_version_number;
      END IF;
      IF (x_scr_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.created_by := l_scr_rec.created_by;
      END IF;
      IF (x_scr_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scr_rec.creation_date := l_scr_rec.creation_date;
      END IF;
      IF (x_scr_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scr_rec.last_updated_by := l_scr_rec.last_updated_by;
      END IF;
      IF (x_scr_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scr_rec.last_update_date := l_scr_rec.last_update_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_K_SALES_CREDITS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_scr_rec IN  scr_rec_type,
      x_scr_rec OUT NOCOPY scr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scr_rec := p_scr_rec;
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
      p_scr_rec,                         -- IN
      l_scr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scr_rec, l_def_scr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_SALES_CREDITS
    SET PERCENT = l_def_scr_rec.percent,

        CHR_ID = l_def_scr_rec.chr_id,
        DNZ_CHR_ID = l_def_scr_rec.dnz_chr_id,

        CLE_ID = l_def_scr_rec.cle_id,

        --CTC_ID = l_def_scr_rec.ctc_id,
        --replaced by SALESREP_ID1, SALESREP_ID2
        SALESREP_ID1 = l_def_scr_rec.salesrep_id1,
        SALESREP_ID2 = l_def_scr_rec.salesrep_id2,

        SALES_CREDIT_TYPE_ID1 = l_def_scr_rec.sales_credit_type_id1,
        SALES_CREDIT_TYPE_ID2 = l_def_scr_rec.sales_credit_type_id2,
        OBJECT_VERSION_NUMBER = l_def_scr_rec.object_version_number,
        CREATED_BY = l_def_scr_rec.created_by,
        CREATION_DATE = l_def_scr_rec.creation_date,
        LAST_UPDATED_BY = l_def_scr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_scr_rec.last_update_date
    WHERE ID = l_def_scr_rec.id;

    x_scr_rec := l_def_scr_rec;
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
  -- update_row for:OKC_K_SALES_CREDITS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type,
    x_scrv_rec    OUT NOCOPY scrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scrv_rec    scrv_rec_type := p_scrv_rec;
    ldefokcksalescreditsvrec       scrv_rec_type;
    l_scr_rec                      scr_rec_type;
    lx_scr_rec                     scr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_scrv_rec	IN scrv_rec_type
    ) RETURN scrv_rec_type IS
      l_scrv_rec	scrv_rec_type := p_scrv_rec;
    BEGIN
      l_scrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_scrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_scrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_scrv_rec	IN scrv_rec_type,
      x_scrv_rec	OUT NOCOPY scrv_rec_type
    ) RETURN VARCHAR2 IS
      l_scrv_rec    scrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scrv_rec := p_scrv_rec;
      -- Get current database values
      l_scrv_rec := get_rec(p_scrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_scrv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.id := l_scrv_rec.id;
      END IF;
      IF (x_scrv_rec.percent = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.percent := l_scrv_rec.percent;
      END IF;

      IF (x_scrv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.chr_id := l_scrv_rec.chr_id;
      END IF;
      IF (x_scrv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.dnz_chr_id := l_scrv_rec.dnz_chr_id;
      END IF;

      IF (x_scrv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.cle_id := l_scrv_rec.cle_id;
      END IF;

      --IF (x_scrv_rec.ctc_id = OKC_API.G_MISS_NUM)
      --THEN
      --  x_scrv_rec.ctc_id := l_scrv_rec.ctc_id;
      --END IF;
      --replaced by SALESREP_ID1, SALESREP_ID2
      IF (x_scrv_rec.salesrep_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scrv_rec.salesrep_id1 := l_scrv_rec.salesrep_id1;
      END IF;
      IF (x_scrv_rec.salesrep_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scrv_rec.salesrep_id2 := l_scrv_rec.salesrep_id2;
      END IF;


      IF (x_scrv_rec.sales_credit_type_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_scrv_rec.sales_credit_type_id1 := l_scrv_rec.sales_credit_type_id1;
      END IF;
      IF (x_scrv_rec.sales_credit_type_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_scrv_rec.sales_credit_type_id2 := l_scrv_rec.sales_credit_type_id2;
      END IF;
      IF (x_scrv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.object_version_number := l_scrv_rec.object_version_number;
      END IF;
      IF (x_scrv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.created_by := l_scrv_rec.created_by;
      END IF;
      IF (x_scrv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_scrv_rec.creation_date := l_scrv_rec.creation_date;
      END IF;
      IF (x_scrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_scrv_rec.last_updated_by := l_scrv_rec.last_updated_by;
      END IF;
      IF (x_scrv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_scrv_rec.last_update_date := l_scrv_rec.last_update_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_K_SALES_CREDITS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_scrv_rec IN  scrv_rec_type,
      x_scrv_rec OUT NOCOPY scrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_scrv_rec := p_scrv_rec;
      x_scrv_rec.OBJECT_VERSION_NUMBER := NVL(x_scrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_scrv_rec,       -- IN
      l_scrv_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_scrv_rec, ldefokcksalescreditsvrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    ldefokcksalescreditsvrec := fill_who_columns(ldefokcksalescreditsvrec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(ldefokcksalescreditsvrec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(ldefokcksalescreditsvrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(ldefokcksalescreditsvrec, l_scr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scr_rec,
      lx_scr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_scr_rec, ldefokcksalescreditsvrec);
    x_scrv_rec := ldefokcksalescreditsvrec;
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
  ---------------------------------------------------------
  -- PL/SQL TBL update_row for:OKC_K_SALES_CREDITS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type,
    x_scrv_tbl    OUT NOCOPY scrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scrv_tbl.COUNT > 0) THEN
      i := p_scrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scrv_rec    => p_scrv_tbl(i),
          x_scrv_rec    => x_scrv_tbl(i));
        EXIT WHEN (i = p_scrv_tbl.LAST);
        i := p_scrv_tbl.NEXT(i);
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
  -- delete_row for:OKC_K_SALES_CREDITS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scr_rec                      IN scr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CREDITS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scr_rec                      scr_rec_type:= p_scr_rec;
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

    DELETE FROM OKC_K_SALES_CREDITS
     WHERE ID = l_scr_rec.id;

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
  -- delete_row for:OKC_K_SALES_CREDITS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_rec    IN scrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_scrv_rec    scrv_rec_type := p_scrv_rec;
    l_scr_rec                      scr_rec_type;
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
    migrate(l_scrv_rec, l_scr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_scr_rec
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
  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKC_K_SALES_CREDITS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_tbl    IN scrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_scrv_tbl.COUNT > 0) THEN
      i := p_scrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_scrv_rec    => p_scrv_tbl(i));
        EXIT WHEN (i = p_scrv_tbl.LAST);
        i := p_scrv_tbl.NEXT(i);
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
END OKC_SCR_PVT;

/
