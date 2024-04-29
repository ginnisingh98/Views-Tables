--------------------------------------------------------
--  DDL for Package Body OKL_SST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SST_PVT" AS
/* $Header: OKLSSSTB.pls 115.8 2002/08/07 22:54:37 bvaghela noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SRCH_STRM_TYPS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sst_rec                      IN sst_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sst_rec_type IS
    CURSOR sst_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STY_ID,
            CAH_ID,
            OBJECT_VERSION_NUMBER,
            ADD_YN,
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
      FROM Okl_Srch_Strm_Typs
     WHERE okl_srch_strm_typs.id = p_id;
    l_sst_pk                       sst_pk_csr%ROWTYPE;
    l_sst_rec                      sst_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sst_pk_csr (p_sst_rec.id);
    FETCH sst_pk_csr INTO
              l_sst_rec.ID,
              l_sst_rec.STY_ID,
              l_sst_rec.CAH_ID,
              l_sst_rec.OBJECT_VERSION_NUMBER,
              l_sst_rec.ADD_YN,
              l_sst_rec.ATTRIBUTE_CATEGORY,
              l_sst_rec.ATTRIBUTE1,
              l_sst_rec.ATTRIBUTE2,
              l_sst_rec.ATTRIBUTE3,
              l_sst_rec.ATTRIBUTE4,
              l_sst_rec.ATTRIBUTE5,
              l_sst_rec.ATTRIBUTE6,
              l_sst_rec.ATTRIBUTE7,
              l_sst_rec.ATTRIBUTE8,
              l_sst_rec.ATTRIBUTE9,
              l_sst_rec.ATTRIBUTE10,
              l_sst_rec.ATTRIBUTE11,
              l_sst_rec.ATTRIBUTE12,
              l_sst_rec.ATTRIBUTE13,
              l_sst_rec.ATTRIBUTE14,
              l_sst_rec.ATTRIBUTE15,
              l_sst_rec.CREATED_BY,
              l_sst_rec.CREATION_DATE,
              l_sst_rec.LAST_UPDATED_BY,
              l_sst_rec.LAST_UPDATE_DATE,
              l_sst_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sst_pk_csr%NOTFOUND;
    CLOSE sst_pk_csr;
    RETURN(l_sst_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sst_rec                      IN sst_rec_type
  ) RETURN sst_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sst_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SRCH_STRM_TYPS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sstv_rec                     IN sstv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sstv_rec_type IS
    CURSOR okl_sstv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            STY_ID,
            CAH_ID,
            ADD_YN,
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
      FROM Okl_Srch_Strm_Typs_V
     WHERE okl_srch_strm_typs_v.id = p_id;
    l_okl_sstv_pk                  okl_sstv_pk_csr%ROWTYPE;
    l_sstv_rec                     sstv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_sstv_pk_csr (p_sstv_rec.id);
    FETCH okl_sstv_pk_csr INTO
              l_sstv_rec.ID,
              l_sstv_rec.OBJECT_VERSION_NUMBER,
              l_sstv_rec.STY_ID,
              l_sstv_rec.CAH_ID,
              l_sstv_rec.ADD_YN,
              l_sstv_rec.ATTRIBUTE_CATEGORY,
              l_sstv_rec.ATTRIBUTE1,
              l_sstv_rec.ATTRIBUTE2,
              l_sstv_rec.ATTRIBUTE3,
              l_sstv_rec.ATTRIBUTE4,
              l_sstv_rec.ATTRIBUTE5,
              l_sstv_rec.ATTRIBUTE6,
              l_sstv_rec.ATTRIBUTE7,
              l_sstv_rec.ATTRIBUTE8,
              l_sstv_rec.ATTRIBUTE9,
              l_sstv_rec.ATTRIBUTE10,
              l_sstv_rec.ATTRIBUTE11,
              l_sstv_rec.ATTRIBUTE12,
              l_sstv_rec.ATTRIBUTE13,
              l_sstv_rec.ATTRIBUTE14,
              l_sstv_rec.ATTRIBUTE15,
              l_sstv_rec.CREATED_BY,
              l_sstv_rec.CREATION_DATE,
              l_sstv_rec.LAST_UPDATED_BY,
              l_sstv_rec.LAST_UPDATE_DATE,
              l_sstv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_sstv_pk_csr%NOTFOUND;
    CLOSE okl_sstv_pk_csr;
    RETURN(l_sstv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sstv_rec                     IN sstv_rec_type
  ) RETURN sstv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sstv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SRCH_STRM_TYPS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sstv_rec	IN sstv_rec_type
  ) RETURN sstv_rec_type IS
    l_sstv_rec	sstv_rec_type := p_sstv_rec;
  BEGIN
    IF (l_sstv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_sstv_rec.object_version_number := NULL;
    END IF;
    IF (l_sstv_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
      l_sstv_rec.sty_id := NULL;
    END IF;
    IF (l_sstv_rec.cah_id = Okl_Api.G_MISS_NUM) THEN
      l_sstv_rec.cah_id := NULL;
    END IF;
    IF (l_sstv_rec.add_yn = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.add_yn := NULL;
    END IF;
    IF (l_sstv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute_category := NULL;
    END IF;
    IF (l_sstv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute1 := NULL;
    END IF;
    IF (l_sstv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute2 := NULL;
    END IF;
    IF (l_sstv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute3 := NULL;
    END IF;
    IF (l_sstv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute4 := NULL;
    END IF;
    IF (l_sstv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute5 := NULL;
    END IF;
    IF (l_sstv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute6 := NULL;
    END IF;
    IF (l_sstv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute7 := NULL;
    END IF;
    IF (l_sstv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute8 := NULL;
    END IF;
    IF (l_sstv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute9 := NULL;
    END IF;
    IF (l_sstv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute10 := NULL;
    END IF;
    IF (l_sstv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute11 := NULL;
    END IF;
    IF (l_sstv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute12 := NULL;
    END IF;
    IF (l_sstv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute13 := NULL;
    END IF;
    IF (l_sstv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute14 := NULL;
    END IF;
    IF (l_sstv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_sstv_rec.attribute15 := NULL;
    END IF;
    IF (l_sstv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_sstv_rec.created_by := NULL;
    END IF;
    IF (l_sstv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_sstv_rec.creation_date := NULL;
    END IF;
    IF (l_sstv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_sstv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sstv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_sstv_rec.last_update_date := NULL;
    END IF;
    IF (l_sstv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_sstv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sstv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/23/2001
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : validate_cah_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_cah_id(p_sstv_rec 		IN 	sstv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_cah_id_csr IS
   SELECT '1'
   FROM   okl_csh_allct_srchs
   WHERE  id = p_sstv_rec.cah_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_sstv_rec.cah_id IS NULL) OR (p_sstv_rec.cah_id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'CAH_ID');
     -- RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_cah_id_csr;
   FETCH l_cah_id_csr INTO l_dummy_var;
   CLOSE l_cah_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CAH_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_CSH_ALLCT_SRCHS');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    --just come out with return status
    NULL;
     -- other appropriate handlers
  WHEN OTHERS THEN
      -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);

    -- notify  UNEXPECTED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END validate_cah_id;

-- Start of comments
-- Procedure Name  : validate_sty_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_sty_id(p_sstv_rec 		IN 	sstv_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_sty_id_csr IS
   SELECT '1'
   FROM   okl_strm_type_b
   WHERE  id = p_sstv_rec.sty_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
  --check not null
  IF (p_sstv_rec.sty_id IS NULL) OR (p_sstv_rec.sty_id = Okl_Api.G_MISS_NUM) THEN

        x_return_status:=Okl_Api.G_RET_STS_ERROR;

        Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                           ,p_msg_name       => 'OKL_BPD_MISSING_BILL_TYP');

        RAISE G_EXCEPTION_HALT_VALIDATION;
        -- x_return_status    := Okl_Api.G_RET_STS_ERROR;

  END IF;

 END validate_sty_id;

  FUNCTION IS_UNIQUE (p_sstv_rec sstv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_chr_csr IS
		 SELECT 'x'
		 FROM okl_srch_strm_typs
		 WHERE sty_id = p_sstv_rec.sty_id
		 AND   cah_id = p_sstv_rec.cah_id
		 AND   id <> NVL(p_sstv_rec.id,-99999);

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN
    -- check for unique sty_id + cah_id
    OPEN l_chr_csr;
    FETCH l_chr_csr INTO l_dummy;
	l_found := l_chr_csr%FOUND;
	CLOSE l_chr_csr;

    IF (l_found) THEN
  	    Okl_Api.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> 'YOU HAVE SELECTED DUPLICATE BILLING TYPES',
					    p_token1		=> 'VALUE1',
					    p_token1_value	=> p_sstv_rec.sty_id,
					    p_token2		=> 'VALUE2',
					    p_token2_value	=> NVL(p_sstv_rec.cah_id,' '));
	  -- notify caller of an error
	  l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE ENDS HERE  04/23/2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_SRCH_STRM_TYPS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sstv_rec IN  sstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/23/2001 Bruno Vaghela ---

    validate_cah_id(p_sstv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_sty_id(p_sstv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

  --END Added 04/23/2001 Bruno Vaghela ---

	IF p_sstv_rec.id = Okl_Api.G_MISS_NUM OR
       p_sstv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_sstv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_sstv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_sstv_rec.sty_id = Okl_Api.G_MISS_NUM OR
          p_sstv_rec.sty_id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sty_id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_sstv_rec.cah_id = Okl_Api.G_MISS_NUM OR
          p_sstv_rec.cah_id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cah_id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_SRCH_STRM_TYPS_V --
  ----------------------------------------------

  --Added 04/23/2001 Bruno Vaghela ---

  FUNCTION Validate_Record (
    p_sstv_rec IN sstv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    l_return_status := IS_UNIQUE(p_sstv_rec);

    RETURN (l_return_status);

  END Validate_Record;

  --END Added 04/23/2001 Bruno Vaghela ---

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sstv_rec_type,
    p_to	IN OUT NOCOPY sst_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.cah_id := p_from.cah_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.add_yn := p_from.add_yn;
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
    p_from	IN sst_rec_type,
    p_to	IN OUT NOCOPY sstv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.cah_id := p_from.cah_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.add_yn := p_from.add_yn;
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
/*  -- history tables not supported -- 04 APR 2002
  PROCEDURE migrate (
    p_from	IN sst_rec_type,
    p_to	IN OUT NOCOPY okl_srch_strm_typs_h_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sty_id := p_from.sty_id;
    p_to.cah_id := p_from.cah_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.add_yn := p_from.add_yn;
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
*/  -- history tables not supported -- 04 APR 2002
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKL_SRCH_STRM_TYPS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sstv_rec                     sstv_rec_type := p_sstv_rec;
    l_sst_rec                      sst_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_sstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sstv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:SSTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sstv_tbl.COUNT > 0) THEN
      i := p_sstv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sstv_rec                     => p_sstv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_sstv_tbl.LAST);
        i := p_sstv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_SRCH_STRM_TYPS_H --
  -----------------------------------------
/*  -- history tables not supported -- 04 APR 2002
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_srch_strm_typs_h_rec     IN okl_srch_strm_typs_h_rec_type,
    x_okl_srch_strm_typs_h_rec     OUT NOCOPY okl_srch_strm_typs_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'H_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_srch_strm_typs_h_rec     okl_srch_strm_typs_h_rec_type := p_okl_srch_strm_typs_h_rec;
    ldefoklsrchstrmtypshrec        okl_srch_strm_typs_h_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SRCH_STRM_TYPS_H --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_srch_strm_typs_h_rec IN  okl_srch_strm_typs_h_rec_type,
      x_okl_srch_strm_typs_h_rec OUT NOCOPY okl_srch_strm_typs_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_srch_strm_typs_h_rec := p_okl_srch_strm_typs_h_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_srch_strm_typs_h_rec,        -- IN
      l_okl_srch_strm_typs_h_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SRCH_STRM_TYPS_H(
        id,
        major_version,
        sty_id,
        cah_id,
        object_version_number,
        add_yn,
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
        l_okl_srch_strm_typs_h_rec.id,
        l_okl_srch_strm_typs_h_rec.major_version,
        l_okl_srch_strm_typs_h_rec.sty_id,
        l_okl_srch_strm_typs_h_rec.cah_id,
        l_okl_srch_strm_typs_h_rec.object_version_number,
        l_okl_srch_strm_typs_h_rec.add_yn,
        l_okl_srch_strm_typs_h_rec.attribute_category,
        l_okl_srch_strm_typs_h_rec.attribute1,
        l_okl_srch_strm_typs_h_rec.attribute2,
        l_okl_srch_strm_typs_h_rec.attribute3,
        l_okl_srch_strm_typs_h_rec.attribute4,
        l_okl_srch_strm_typs_h_rec.attribute5,
        l_okl_srch_strm_typs_h_rec.attribute6,
        l_okl_srch_strm_typs_h_rec.attribute7,
        l_okl_srch_strm_typs_h_rec.attribute8,
        l_okl_srch_strm_typs_h_rec.attribute9,
        l_okl_srch_strm_typs_h_rec.attribute10,
        l_okl_srch_strm_typs_h_rec.attribute11,
        l_okl_srch_strm_typs_h_rec.attribute12,
        l_okl_srch_strm_typs_h_rec.attribute13,
        l_okl_srch_strm_typs_h_rec.attribute14,
        l_okl_srch_strm_typs_h_rec.attribute15,
        l_okl_srch_strm_typs_h_rec.created_by,
        l_okl_srch_strm_typs_h_rec.creation_date,
        l_okl_srch_strm_typs_h_rec.last_updated_by,
        l_okl_srch_strm_typs_h_rec.last_update_date,
        l_okl_srch_strm_typs_h_rec.last_update_login);
    -- Set OUT values
    x_okl_srch_strm_typs_h_rec := l_okl_srch_strm_typs_h_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
*/  -- history tables not supported -- 04 APR 2002

  ---------------------------------------
  -- insert_row for:OKL_SRCH_STRM_TYPS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sst_rec                      IN sst_rec_type,
    x_sst_rec                      OUT NOCOPY sst_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPS_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sst_rec                      sst_rec_type := p_sst_rec;
    l_def_sst_rec                  sst_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_SRCH_STRM_TYPS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_sst_rec IN  sst_rec_type,
      x_sst_rec OUT NOCOPY sst_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sst_rec := p_sst_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sst_rec,                         -- IN
      l_sst_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SRCH_STRM_TYPS(
        id,
        sty_id,
        cah_id,
        object_version_number,
        add_yn,
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
        l_sst_rec.id,
        l_sst_rec.sty_id,
        l_sst_rec.cah_id,
        l_sst_rec.object_version_number,
        l_sst_rec.add_yn,
        l_sst_rec.attribute_category,
        l_sst_rec.attribute1,
        l_sst_rec.attribute2,
        l_sst_rec.attribute3,
        l_sst_rec.attribute4,
        l_sst_rec.attribute5,
        l_sst_rec.attribute6,
        l_sst_rec.attribute7,
        l_sst_rec.attribute8,
        l_sst_rec.attribute9,
        l_sst_rec.attribute10,
        l_sst_rec.attribute11,
        l_sst_rec.attribute12,
        l_sst_rec.attribute13,
        l_sst_rec.attribute14,
        l_sst_rec.attribute15,
        l_sst_rec.created_by,
        l_sst_rec.creation_date,
        l_sst_rec.last_updated_by,
        l_sst_rec.last_update_date,
        l_sst_rec.last_update_login);
    -- Set OUT values
    x_sst_rec := l_sst_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
   WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
      NULL;
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  -----------------------------------------
  -- insert_row for:OKL_SRCH_STRM_TYPS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type,
    x_sstv_rec                     OUT NOCOPY sstv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sstv_rec                     sstv_rec_type;
    l_def_sstv_rec                 sstv_rec_type;
    l_sst_rec                      sst_rec_type;
    lx_sst_rec                     sst_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sstv_rec	IN sstv_rec_type
    ) RETURN sstv_rec_type IS
      l_sstv_rec	sstv_rec_type := p_sstv_rec;
    BEGIN
      l_sstv_rec.CREATION_DATE := SYSDATE;
      l_sstv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_sstv_rec.LAST_UPDATE_DATE := l_sstv_rec.CREATION_DATE;
      l_sstv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_sstv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_sstv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SRCH_STRM_TYPS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_sstv_rec IN  sstv_rec_type,
      x_sstv_rec OUT NOCOPY sstv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sstv_rec := p_sstv_rec;
      x_sstv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_sstv_rec := null_out_defaults(p_sstv_rec);
    -- Set primary key value
    l_sstv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sstv_rec,                        -- IN
      l_def_sstv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_sstv_rec := fill_who_columns(l_def_sstv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sstv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sstv_rec, l_sst_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sst_rec,
      lx_sst_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sst_rec, l_def_sstv_rec);
    -- Set OUT values
    x_sstv_rec := l_def_sstv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
   WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := 'E';
      NULL;
      /*
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
    WHEN OTHERS THEN
      x_return_status := 'U';
      NULL;
      /*
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      */
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:SSTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type,
    x_sstv_tbl                     OUT NOCOPY sstv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sstv_tbl.COUNT > 0) THEN
      i := p_sstv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sstv_rec                     => p_sstv_tbl(i),
          x_sstv_rec                     => x_sstv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_sstv_tbl.LAST);
        i := p_sstv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_SRCH_STRM_TYPS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sst_rec                      IN sst_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sst_rec IN sst_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SRCH_STRM_TYPS
     WHERE ID = p_sst_rec.id
       AND OBJECT_VERSION_NUMBER = p_sst_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sst_rec IN sst_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SRCH_STRM_TYPS
    WHERE ID = p_sst_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPS_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SRCH_STRM_TYPS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SRCH_STRM_TYPS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_sst_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_sst_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sst_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sst_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_SRCH_STRM_TYPS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sst_rec                      sst_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_sstv_rec, l_sst_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sst_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:SSTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sstv_tbl.COUNT > 0) THEN
      i := p_sstv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sstv_rec                     => p_sstv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_sstv_tbl.LAST);
        i := p_sstv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_SRCH_STRM_TYPS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sst_rec                      IN sst_rec_type,
    x_sst_rec                      OUT NOCOPY sst_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sst_rec                      sst_rec_type := p_sst_rec;
    l_def_sst_rec                  sst_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
-- history tables not supported -- 04 APR 2002
--  l_okl_srch_strm_typs_h_rec     okl_srch_strm_typs_h_rec_type;
--  lx_okl_srch_strm_typs_h_rec    okl_srch_strm_typs_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sst_rec	IN sst_rec_type,
      x_sst_rec	OUT NOCOPY sst_rec_type
    ) RETURN VARCHAR2 IS
      l_sst_rec                      sst_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sst_rec := p_sst_rec;
      -- Get current database values
      l_sst_rec := get_rec(p_sst_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
--    migrate(l_sst_rec, l_okl_srch_strm_typs_h_rec);
      IF (x_sst_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.id := l_sst_rec.id;
      END IF;
      IF (x_sst_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.sty_id := l_sst_rec.sty_id;
      END IF;
      IF (x_sst_rec.cah_id = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.cah_id := l_sst_rec.cah_id;
      END IF;
      IF (x_sst_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.object_version_number := l_sst_rec.object_version_number;
      END IF;
      IF (x_sst_rec.add_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.add_yn := l_sst_rec.add_yn;
      END IF;
      IF (x_sst_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute_category := l_sst_rec.attribute_category;
      END IF;
      IF (x_sst_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute1 := l_sst_rec.attribute1;
      END IF;
      IF (x_sst_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute2 := l_sst_rec.attribute2;
      END IF;
      IF (x_sst_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute3 := l_sst_rec.attribute3;
      END IF;
      IF (x_sst_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute4 := l_sst_rec.attribute4;
      END IF;
      IF (x_sst_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute5 := l_sst_rec.attribute5;
      END IF;
      IF (x_sst_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute6 := l_sst_rec.attribute6;
      END IF;
      IF (x_sst_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute7 := l_sst_rec.attribute7;
      END IF;
      IF (x_sst_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute8 := l_sst_rec.attribute8;
      END IF;
      IF (x_sst_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute9 := l_sst_rec.attribute9;
      END IF;
      IF (x_sst_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute10 := l_sst_rec.attribute10;
      END IF;
      IF (x_sst_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute11 := l_sst_rec.attribute11;
      END IF;
      IF (x_sst_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute12 := l_sst_rec.attribute12;
      END IF;
      IF (x_sst_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute13 := l_sst_rec.attribute13;
      END IF;
      IF (x_sst_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute14 := l_sst_rec.attribute14;
      END IF;
      IF (x_sst_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sst_rec.attribute15 := l_sst_rec.attribute15;
      END IF;
      IF (x_sst_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.created_by := l_sst_rec.created_by;
      END IF;
      IF (x_sst_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_sst_rec.creation_date := l_sst_rec.creation_date;
      END IF;
      IF (x_sst_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.last_updated_by := l_sst_rec.last_updated_by;
      END IF;
      IF (x_sst_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_sst_rec.last_update_date := l_sst_rec.last_update_date;
      END IF;
      IF (x_sst_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_sst_rec.last_update_login := l_sst_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_SRCH_STRM_TYPS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_sst_rec IN  sst_rec_type,
      x_sst_rec OUT NOCOPY sst_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sst_rec := p_sst_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sst_rec,                         -- IN
      l_sst_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sst_rec, l_def_sst_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SRCH_STRM_TYPS
    SET STY_ID = l_def_sst_rec.sty_id,
        CAH_ID = l_def_sst_rec.cah_id,
        OBJECT_VERSION_NUMBER = l_def_sst_rec.object_version_number,
        ADD_YN = l_def_sst_rec.add_yn,
        ATTRIBUTE_CATEGORY = l_def_sst_rec.attribute_category,
        ATTRIBUTE1 = l_def_sst_rec.attribute1,
        ATTRIBUTE2 = l_def_sst_rec.attribute2,
        ATTRIBUTE3 = l_def_sst_rec.attribute3,
        ATTRIBUTE4 = l_def_sst_rec.attribute4,
        ATTRIBUTE5 = l_def_sst_rec.attribute5,
        ATTRIBUTE6 = l_def_sst_rec.attribute6,
        ATTRIBUTE7 = l_def_sst_rec.attribute7,
        ATTRIBUTE8 = l_def_sst_rec.attribute8,
        ATTRIBUTE9 = l_def_sst_rec.attribute9,
        ATTRIBUTE10 = l_def_sst_rec.attribute10,
        ATTRIBUTE11 = l_def_sst_rec.attribute11,
        ATTRIBUTE12 = l_def_sst_rec.attribute12,
        ATTRIBUTE13 = l_def_sst_rec.attribute13,
        ATTRIBUTE14 = l_def_sst_rec.attribute14,
        ATTRIBUTE15 = l_def_sst_rec.attribute15,
        CREATED_BY = l_def_sst_rec.created_by,
        CREATION_DATE = l_def_sst_rec.creation_date,
        LAST_UPDATED_BY = l_def_sst_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sst_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sst_rec.last_update_login
    WHERE ID = l_def_sst_rec.id;

    -- Insert into History table
   /*
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_srch_strm_typs_h_rec,
      lx_okl_srch_strm_typs_h_rec
    );
    */
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_sst_rec := l_def_sst_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_SRCH_STRM_TYPS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type,
    x_sstv_rec                     OUT NOCOPY sstv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sstv_rec                     sstv_rec_type := p_sstv_rec;
    l_def_sstv_rec                 sstv_rec_type;
    l_sst_rec                      sst_rec_type;
    lx_sst_rec                     sst_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sstv_rec	IN sstv_rec_type
    ) RETURN sstv_rec_type IS
      l_sstv_rec	sstv_rec_type := p_sstv_rec;
    BEGIN
      l_sstv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sstv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_sstv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_sstv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sstv_rec	IN sstv_rec_type,
      x_sstv_rec	OUT NOCOPY sstv_rec_type
    ) RETURN VARCHAR2 IS
      l_sstv_rec                     sstv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sstv_rec := p_sstv_rec;
      -- Get current database values
      l_sstv_rec := get_rec(p_sstv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sstv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.id := l_sstv_rec.id;
      END IF;
      IF (x_sstv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.object_version_number := l_sstv_rec.object_version_number;
      END IF;
      IF (x_sstv_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.sty_id := l_sstv_rec.sty_id;
      END IF;
      IF (x_sstv_rec.cah_id = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.cah_id := l_sstv_rec.cah_id;
      END IF;
      IF (x_sstv_rec.add_yn = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.add_yn := l_sstv_rec.add_yn;
      END IF;
      IF (x_sstv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute_category := l_sstv_rec.attribute_category;
      END IF;
      IF (x_sstv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute1 := l_sstv_rec.attribute1;
      END IF;
      IF (x_sstv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute2 := l_sstv_rec.attribute2;
      END IF;
      IF (x_sstv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute3 := l_sstv_rec.attribute3;
      END IF;
      IF (x_sstv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute4 := l_sstv_rec.attribute4;
      END IF;
      IF (x_sstv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute5 := l_sstv_rec.attribute5;
      END IF;
      IF (x_sstv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute6 := l_sstv_rec.attribute6;
      END IF;
      IF (x_sstv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute7 := l_sstv_rec.attribute7;
      END IF;
      IF (x_sstv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute8 := l_sstv_rec.attribute8;
      END IF;
      IF (x_sstv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute9 := l_sstv_rec.attribute9;
      END IF;
      IF (x_sstv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute10 := l_sstv_rec.attribute10;
      END IF;
      IF (x_sstv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute11 := l_sstv_rec.attribute11;
      END IF;
      IF (x_sstv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute12 := l_sstv_rec.attribute12;
      END IF;
      IF (x_sstv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute13 := l_sstv_rec.attribute13;
      END IF;
      IF (x_sstv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute14 := l_sstv_rec.attribute14;
      END IF;
      IF (x_sstv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sstv_rec.attribute15 := l_sstv_rec.attribute15;
      END IF;
      IF (x_sstv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.created_by := l_sstv_rec.created_by;
      END IF;
      IF (x_sstv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_sstv_rec.creation_date := l_sstv_rec.creation_date;
      END IF;
      IF (x_sstv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.last_updated_by := l_sstv_rec.last_updated_by;
      END IF;
      IF (x_sstv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_sstv_rec.last_update_date := l_sstv_rec.last_update_date;
      END IF;
      IF (x_sstv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_sstv_rec.last_update_login := l_sstv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SRCH_STRM_TYPS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_sstv_rec IN  sstv_rec_type,
      x_sstv_rec OUT NOCOPY sstv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sstv_rec := p_sstv_rec;
      x_sstv_rec.OBJECT_VERSION_NUMBER := NVL(x_sstv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sstv_rec,                        -- IN
      l_sstv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sstv_rec, l_def_sstv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_sstv_rec := fill_who_columns(l_def_sstv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sstv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sstv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sstv_rec, l_sst_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sst_rec,
      lx_sst_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sst_rec, l_def_sstv_rec);
    x_sstv_rec := l_def_sstv_rec;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:SSTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type,
    x_sstv_tbl                     OUT NOCOPY sstv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sstv_tbl.COUNT > 0) THEN
      i := p_sstv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sstv_rec                     => p_sstv_tbl(i),
          x_sstv_rec                     => x_sstv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_sstv_tbl.LAST);
        i := p_sstv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_SRCH_STRM_TYPS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sst_rec                      IN sst_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TYPS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sst_rec                      sst_rec_type:= p_sst_rec;
    l_row_notfound                 BOOLEAN := TRUE;

--  history tables not supported -- 04 APR 2002
--  l_okl_srch_strm_typs_h_rec     okl_srch_strm_typs_h_rec_type;
--  lx_okl_srch_strm_typs_h_rec    okl_srch_strm_typs_h_rec_type;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    -- Insert into History table
    /*
    l_sst_rec := get_rec(l_sst_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    migrate(l_sst_rec, l_okl_srch_strm_typs_h_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_srch_strm_typs_h_rec,
      lx_okl_srch_strm_typs_h_rec
    );
    */
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_SRCH_STRM_TYPS
     WHERE ID = l_sst_rec.id;

    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_SRCH_STRM_TYPS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_rec                     IN sstv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sstv_rec                     sstv_rec_type := p_sstv_rec;
    l_sst_rec                      sst_rec_type;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_sstv_rec, l_sst_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sst_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:SSTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sstv_tbl                     IN sstv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sstv_tbl.COUNT > 0) THEN
      i := p_sstv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sstv_rec                     => p_sstv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_sstv_tbl.LAST);
        i := p_sstv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'Okl_Api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Sst_Pvt;

/
