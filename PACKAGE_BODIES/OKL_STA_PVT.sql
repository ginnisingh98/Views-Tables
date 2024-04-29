--------------------------------------------------------
--  DDL for Package Body OKL_STA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STA_PVT" AS
/* $Header: OKLSSTAB.pls 120.2 2006/07/11 10:27:49 dkagrawa noship $ */
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
  -- FUNCTION get_rec for: OKL_STRM_TYP_ALLOCS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sta_rec                      IN sta_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sta_rec_type IS
    CURSOR sta_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CAT_ID,
            STY_ID,
            STREAM_ALLC_TYPE,
            OBJECT_VERSION_NUMBER,
            SEQUENCE_NUMBER,
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
      FROM Okl_Strm_Typ_Allocs
     WHERE okl_strm_typ_allocs.id = p_id;
    l_sta_pk                       sta_pk_csr%ROWTYPE;
    l_sta_rec                      sta_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sta_pk_csr (p_sta_rec.id);
    FETCH sta_pk_csr INTO
              l_sta_rec.ID,
              l_sta_rec.CAT_ID,
              l_sta_rec.STY_ID,
              l_sta_rec.STREAM_ALLC_TYPE,
              l_sta_rec.OBJECT_VERSION_NUMBER,
              l_sta_rec.SEQUENCE_NUMBER,
              l_sta_rec.ATTRIBUTE_CATEGORY,
              l_sta_rec.ATTRIBUTE1,
              l_sta_rec.ATTRIBUTE2,
              l_sta_rec.ATTRIBUTE3,
              l_sta_rec.ATTRIBUTE4,
              l_sta_rec.ATTRIBUTE5,
              l_sta_rec.ATTRIBUTE6,
              l_sta_rec.ATTRIBUTE7,
              l_sta_rec.ATTRIBUTE8,
              l_sta_rec.ATTRIBUTE9,
              l_sta_rec.ATTRIBUTE10,
              l_sta_rec.ATTRIBUTE11,
              l_sta_rec.ATTRIBUTE12,
              l_sta_rec.ATTRIBUTE13,
              l_sta_rec.ATTRIBUTE14,
              l_sta_rec.ATTRIBUTE15,
              l_sta_rec.CREATED_BY,
              l_sta_rec.CREATION_DATE,
              l_sta_rec.LAST_UPDATED_BY,
              l_sta_rec.LAST_UPDATE_DATE,
              l_sta_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sta_pk_csr%NOTFOUND;
    CLOSE sta_pk_csr;
    RETURN(l_sta_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sta_rec                      IN sta_rec_type
  ) RETURN sta_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sta_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_TYP_ALLOCS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_stav_rec                     IN stav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN stav_rec_type IS
    CURSOR okl_stav_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            STY_ID,
            CAT_ID,
            SEQUENCE_NUMBER,
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
            STREAM_ALLC_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_STRM_TYP_ALLOCS
     WHERE OKL_STRM_TYP_ALLOCS.id = p_id;
    l_okl_stav_pk                  okl_stav_pk_csr%ROWTYPE;
    l_stav_rec                     stav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_stav_pk_csr (p_stav_rec.id);
    FETCH okl_stav_pk_csr INTO
              l_stav_rec.ID,
              l_stav_rec.OBJECT_VERSION_NUMBER,
              l_stav_rec.STY_ID,
              l_stav_rec.CAT_ID,
              l_stav_rec.SEQUENCE_NUMBER,
              l_stav_rec.ATTRIBUTE_CATEGORY,
              l_stav_rec.ATTRIBUTE1,
              l_stav_rec.ATTRIBUTE2,
              l_stav_rec.ATTRIBUTE3,
              l_stav_rec.ATTRIBUTE4,
              l_stav_rec.ATTRIBUTE5,
              l_stav_rec.ATTRIBUTE6,
              l_stav_rec.ATTRIBUTE7,
              l_stav_rec.ATTRIBUTE8,
              l_stav_rec.ATTRIBUTE9,
              l_stav_rec.ATTRIBUTE10,
              l_stav_rec.ATTRIBUTE11,
              l_stav_rec.ATTRIBUTE12,
              l_stav_rec.ATTRIBUTE13,
              l_stav_rec.ATTRIBUTE14,
              l_stav_rec.ATTRIBUTE15,
              l_stav_rec.STREAM_ALLC_TYPE,
              l_stav_rec.CREATED_BY,
              l_stav_rec.CREATION_DATE,
              l_stav_rec.LAST_UPDATED_BY,
              l_stav_rec.LAST_UPDATE_DATE,
              l_stav_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_stav_pk_csr%NOTFOUND;
    CLOSE okl_stav_pk_csr;
    RETURN(l_stav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_stav_rec                     IN stav_rec_type
  ) RETURN stav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_stav_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_STRM_TYP_ALLOCS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_stav_rec	IN stav_rec_type
  ) RETURN stav_rec_type IS
    l_stav_rec	stav_rec_type := p_stav_rec;
  BEGIN
    IF (l_stav_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.object_version_number := NULL;
    END IF;
    IF (l_stav_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.sty_id := NULL;
    END IF;
    IF (l_stav_rec.cat_id = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.cat_id := NULL;
    END IF;
    IF (l_stav_rec.sequence_number = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.sequence_number := NULL;
    END IF;
    IF (l_stav_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute_category := NULL;
    END IF;
    IF (l_stav_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute1 := NULL;
    END IF;
    IF (l_stav_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute2 := NULL;
    END IF;
    IF (l_stav_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute3 := NULL;
    END IF;
    IF (l_stav_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute4 := NULL;
    END IF;
    IF (l_stav_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute5 := NULL;
    END IF;
    IF (l_stav_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute6 := NULL;
    END IF;
    IF (l_stav_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute7 := NULL;
    END IF;
    IF (l_stav_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute8 := NULL;
    END IF;
    IF (l_stav_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute9 := NULL;
    END IF;
    IF (l_stav_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute10 := NULL;
    END IF;
    IF (l_stav_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute11 := NULL;
    END IF;
    IF (l_stav_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute12 := NULL;
    END IF;
    IF (l_stav_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute13 := NULL;
    END IF;
    IF (l_stav_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute14 := NULL;
    END IF;
    IF (l_stav_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.attribute15 := NULL;
    END IF;
    IF (l_stav_rec.stream_allc_type = Okl_Api.G_MISS_CHAR) THEN
      l_stav_rec.stream_allc_type := NULL;
    END IF;
    IF (l_stav_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.created_by := NULL;
    END IF;
    IF (l_stav_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_stav_rec.creation_date := NULL;
    END IF;
    IF (l_stav_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.last_updated_by := NULL;
    END IF;
    IF (l_stav_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_stav_rec.last_update_date := NULL;
    END IF;
    IF (l_stav_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_stav_rec.last_update_login := NULL;
    END IF;
    RETURN(l_stav_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/23/2001
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : validate_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_id(p_stav_rec 		IN 	stav_rec_type,
                      x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_stav_rec.id IS NULL) OR (p_stav_rec.id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'ID');
     -- RAISE G_EXCEPTION_HALT_VALIDATION;
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

END validate_id;

-- Start of comments
-- Procedure Name  : validate_cat_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_cat_id(p_stav_rec 		IN 	stav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_cat_id_csr IS
   SELECT '1'
   FROM   okl_cash_allctn_rls
   WHERE  id = p_stav_rec.cat_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
   IF (p_stav_rec.cat_id IS NULL) OR (p_stav_rec.cat_id = Okl_Api.G_MISS_NUM) THEN
     x_return_status:=Okl_Api.G_RET_STS_ERROR;
     --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_REQUIRED_VALUE,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'CAT_ID');
     -- RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_cat_id_csr;
   FETCH l_cat_id_csr INTO l_dummy_var;
   CLOSE l_cat_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CAT_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_CASH_ALLCTN_RLS');
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

END validate_cat_id;

-- Start of comments
-- Procedure Name  : validate_sty_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_sty_id(p_stav_rec 		IN 	stav_rec_type,
                          x_return_status 	OUT NOCOPY VARCHAR2) IS

   CURSOR l_sty_id_csr IS
   SELECT '1'
   FROM   okl_strm_type_b
   WHERE  id = p_stav_rec.sty_id;

   l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
  --check not null
  IF (p_stav_rec.sty_id IS NULL) OR (p_stav_rec.sty_id = Okl_Api.G_MISS_NUM) THEN
    x_return_status:=Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
    Okl_Api.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'STY_ID');
    -- RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

   --check FK Relation with okl_trx_csh_batch_b
   OPEN l_sty_id_csr;
   FETCH l_sty_id_csr INTO l_dummy_var;
   CLOSE l_sty_id_csr;
   IF (l_dummy_var<>'1') THEN

	--Corresponding Column value not found
  	x_return_status:= Okl_Api.G_RET_STS_ERROR;
    --set error message in message stack
     Okl_Api.SET_MESSAGE(p_app_name    => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'STY_ID',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKL_STRM_TYPE_B');
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

 END validate_sty_id;
/*	 				   -- not required as records will never be duplicated.
  FUNCTION IS_UNIQUE (p_stav_rec stav_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_chr_csr IS
		 SELECT 'x'
		 FROM okl_strm_typ_allocs
		 WHERE sty_id = p_stav_rec.sty_id
		 AND   cat_id = p_stav_rec.cat_id
		 AND   id <> NVL(p_stav_rec.id,-99999);

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN
    -- check for unique sty_id + cat_id
    OPEN l_chr_csr;
    FETCH l_chr_csr INTO l_dummy;
	l_found := l_chr_csr%FOUND;
	CLOSE l_chr_csr;

    IF (l_found) THEN
  	    Okl_Api.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> 'STY_ID and CAT_ID NOT UNIQUE',
					    p_token1		=> 'VALUE1',
					    p_token1_value	=> p_stav_rec.sty_id,
					    p_token2		=> 'VALUE2',
					    p_token2_value	=> NVL(p_stav_rec.cat_id,' '));
	  -- notify caller of an error
	  l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN (l_return_status);

  EXCEPTION
    WHEN OTHERS THEN
	 RETURN (l_return_status);
  END IS_UNIQUE;
*/
  ---------------------------------------------------------------------------
  -- POST TAPI CODE ENDS HERE  04/23/2001
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_EXT_CSH_BTCHS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_stav_rec IN  stav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	   -- Added 04/23/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/23/2001 Bruno Vaghela ---

    validate_id(p_stav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_cat_id(p_stav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

	validate_sty_id(p_stav_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

 	--END 04/23/2001 Bruno Vaghela ---

    IF p_stav_rec.id = Okl_Api.G_MISS_NUM OR
       p_stav_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_stav_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_stav_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_stav_rec.sty_id = Okl_Api.G_MISS_NUM OR
          p_stav_rec.sty_id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sty_id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_stav_rec.cat_id = Okl_Api.G_MISS_NUM OR
          p_stav_rec.cat_id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cat_id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_stav_rec.stream_allc_type = Okl_Api.G_MISS_CHAR OR
          p_stav_rec.stream_allc_type IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'stream_allc_type');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_STRM_TYP_ALLOCS_V --
  -----------------------------------------------

  --Added 04/23/2001 Bruno Vaghela ---

  FUNCTION Validate_Record (
    p_stav_rec IN stav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

--    l_return_status := IS_UNIQUE(p_stav_rec);

  IF p_stav_rec.stream_allc_type = 'ODD' AND
  	 p_stav_rec.sequence_number IS NULL OR
	 p_stav_rec.sequence_number = Okl_Api.G_MISS_NUM THEN

   	    l_return_status := Okl_Api.G_RET_STS_ERROR;

  END IF;

  RETURN (l_return_status);

  END Validate_Record;

  --END 04/23/2001 Bruno Vaghela ---

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN stav_rec_type,
    p_to	IN OUT NOCOPY sta_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cat_id := p_from.cat_id;
    p_to.sty_id := p_from.sty_id;
    p_to.stream_allc_type := p_from.stream_allc_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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
    p_from	IN sta_rec_type,
    p_to	IN OUT NOCOPY stav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cat_id := p_from.cat_id;
    p_to.sty_id := p_from.sty_id;
    p_to.stream_allc_type := p_from.stream_allc_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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

/*  -- history stables not supported   04 Apr 2002
  PROCEDURE migrate (
    p_from	IN sta_rec_type,
    p_to	IN OUT NOCOPY okl_strm_typ_allocs_h_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cat_id := p_from.cat_id;
    p_to.sty_id := p_from.sty_id;
    p_to.stream_allc_type := p_from.stream_allc_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
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
*/

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_STRM_TYP_ALLOCS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_rec                     IN stav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stav_rec                     stav_rec_type := p_stav_rec;
    l_sta_rec                      sta_rec_type;
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
    l_return_status := Validate_Attributes(l_stav_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_stav_rec);
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
  -- PL/SQL TBL validate_row for:STAV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_tbl                     IN stav_tbl_type) IS

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
    IF (p_stav_tbl.COUNT > 0) THEN
      i := p_stav_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stav_rec                     => p_stav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_stav_tbl.LAST);
        i := p_stav_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKL_STRM_TYP_ALLOCS_H --
  ------------------------------------------

/*  -- history tables not supported  04 Apr 2002

  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_strm_typ_allocs_h_rec    IN okl_strm_typ_allocs_h_rec_type,
    x_okl_strm_typ_allocs_h_rec    OUT NOCOPY okl_strm_typ_allocs_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'H_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_strm_typ_allocs_h_rec    okl_strm_typ_allocs_h_rec_type := p_okl_strm_typ_allocs_h_rec;
    ldefoklstrmtypallocshrec       okl_strm_typ_allocs_h_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYP_ALLOCS_H --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_strm_typ_allocs_h_rec IN  okl_strm_typ_allocs_h_rec_type,
      x_okl_strm_typ_allocs_h_rec OUT NOCOPY okl_strm_typ_allocs_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_strm_typ_allocs_h_rec := p_okl_strm_typ_allocs_h_rec;
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
      p_okl_strm_typ_allocs_h_rec,       -- IN
      l_okl_strm_typ_allocs_h_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_STRM_TYP_ALLOCS_H(
        id,
        major_version,
        cat_id,
        sty_id,
        stream_allc_type,
        object_version_number,
        sequence_number,
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
        l_okl_strm_typ_allocs_h_rec.id,
        l_okl_strm_typ_allocs_h_rec.major_version,
        l_okl_strm_typ_allocs_h_rec.cat_id,
        l_okl_strm_typ_allocs_h_rec.sty_id,
        l_okl_strm_typ_allocs_h_rec.stream_allc_type,
        l_okl_strm_typ_allocs_h_rec.object_version_number,
        l_okl_strm_typ_allocs_h_rec.sequence_number,
        l_okl_strm_typ_allocs_h_rec.attribute_category,
        l_okl_strm_typ_allocs_h_rec.attribute1,
        l_okl_strm_typ_allocs_h_rec.attribute2,
        l_okl_strm_typ_allocs_h_rec.attribute3,
        l_okl_strm_typ_allocs_h_rec.attribute4,
        l_okl_strm_typ_allocs_h_rec.attribute5,
        l_okl_strm_typ_allocs_h_rec.attribute6,
        l_okl_strm_typ_allocs_h_rec.attribute7,
        l_okl_strm_typ_allocs_h_rec.attribute8,
        l_okl_strm_typ_allocs_h_rec.attribute9,
        l_okl_strm_typ_allocs_h_rec.attribute10,
        l_okl_strm_typ_allocs_h_rec.attribute11,
        l_okl_strm_typ_allocs_h_rec.attribute12,
        l_okl_strm_typ_allocs_h_rec.attribute13,
        l_okl_strm_typ_allocs_h_rec.attribute14,
        l_okl_strm_typ_allocs_h_rec.attribute15,
        l_okl_strm_typ_allocs_h_rec.created_by,
        l_okl_strm_typ_allocs_h_rec.creation_date,
        l_okl_strm_typ_allocs_h_rec.last_updated_by,
        l_okl_strm_typ_allocs_h_rec.last_update_date,
        l_okl_strm_typ_allocs_h_rec.last_update_login);
    -- Set OUT values
    x_okl_strm_typ_allocs_h_rec := l_okl_strm_typ_allocs_h_rec;
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
*/

  ----------------------------------------
  -- insert_row for:OKL_STRM_TYP_ALLOCS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sta_rec                      IN sta_rec_type,
    x_sta_rec                      OUT NOCOPY sta_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ALLOCS_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sta_rec                      sta_rec_type := p_sta_rec;
    l_def_sta_rec                  sta_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYP_ALLOCS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sta_rec IN  sta_rec_type,
      x_sta_rec OUT NOCOPY sta_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sta_rec := p_sta_rec;
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
      p_sta_rec,                         -- IN
      l_sta_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_STRM_TYP_ALLOCS(
        id,
        cat_id,
        sty_id,
        stream_allc_type,
        object_version_number,
        sequence_number,
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
        l_sta_rec.id,
        l_sta_rec.cat_id,
        l_sta_rec.sty_id,
        l_sta_rec.stream_allc_type,
        l_sta_rec.object_version_number,
        l_sta_rec.sequence_number,
        l_sta_rec.attribute_category,
        l_sta_rec.attribute1,
        l_sta_rec.attribute2,
        l_sta_rec.attribute3,
        l_sta_rec.attribute4,
        l_sta_rec.attribute5,
        l_sta_rec.attribute6,
        l_sta_rec.attribute7,
        l_sta_rec.attribute8,
        l_sta_rec.attribute9,
        l_sta_rec.attribute10,
        l_sta_rec.attribute11,
        l_sta_rec.attribute12,
        l_sta_rec.attribute13,
        l_sta_rec.attribute14,
        l_sta_rec.attribute15,
        l_sta_rec.created_by,
        l_sta_rec.creation_date,
        l_sta_rec.last_updated_by,
        l_sta_rec.last_update_date,
        l_sta_rec.last_update_login);
    -- Set OUT values
    x_sta_rec := l_sta_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_STRM_TYP_ALLOCS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_rec                     IN stav_rec_type,
    x_stav_rec                     OUT NOCOPY stav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stav_rec                     stav_rec_type;
    l_def_stav_rec                 stav_rec_type;
    l_sta_rec                      sta_rec_type;
    lx_sta_rec                     sta_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_stav_rec	IN stav_rec_type
    ) RETURN stav_rec_type IS
      l_stav_rec	stav_rec_type := p_stav_rec;
    BEGIN
      l_stav_rec.CREATION_DATE := SYSDATE;
      l_stav_rec.CREATED_BY := Fnd_Global.User_Id;
      l_stav_rec.LAST_UPDATE_DATE := l_stav_rec.CREATION_DATE;
      l_stav_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_stav_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_stav_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYP_ALLOCS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_stav_rec IN  stav_rec_type,
      x_stav_rec OUT NOCOPY stav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_stav_rec := p_stav_rec;
      x_stav_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_stav_rec := null_out_defaults(p_stav_rec);
    -- Set primary key value
    l_stav_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_stav_rec,                        -- IN
      l_def_stav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_stav_rec := fill_who_columns(l_def_stav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_stav_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_stav_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_stav_rec, l_sta_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sta_rec,
      lx_sta_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sta_rec, l_def_stav_rec);
    -- Set OUT values
    x_stav_rec := l_def_stav_rec;
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
  ----------------------------------------
  -- PL/SQL TBL insert_row for:STAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_tbl                     IN stav_tbl_type,
    x_stav_tbl                     OUT NOCOPY stav_tbl_type) IS

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

    IF (p_stav_tbl.COUNT > 0) THEN
      i := p_stav_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stav_rec                     => p_stav_tbl(i),
          x_stav_rec                     => x_stav_tbl(i));

	   	  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_stav_tbl.LAST);
        i := p_stav_tbl.NEXT(i);
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
  --------------------------------------
  -- lock_row for:OKL_STRM_TYP_ALLOCS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sta_rec                      IN sta_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sta_rec IN sta_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_TYP_ALLOCS
     WHERE ID = p_sta_rec.id
       AND OBJECT_VERSION_NUMBER = p_sta_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sta_rec IN sta_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_TYP_ALLOCS
    WHERE ID = p_sta_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ALLOCS_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_STRM_TYP_ALLOCS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_STRM_TYP_ALLOCS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sta_rec);
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
      OPEN lchk_csr(p_sta_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sta_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sta_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKL_STRM_TYP_ALLOCS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_rec                     IN stav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sta_rec                      sta_rec_type;
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
    migrate(p_stav_rec, l_sta_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sta_rec
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
  -- PL/SQL TBL lock_row for:STAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_tbl                     IN stav_tbl_type) IS

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
    IF (p_stav_tbl.COUNT > 0) THEN
      i := p_stav_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stav_rec                     => p_stav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_stav_tbl.LAST);
        i := p_stav_tbl.NEXT(i);
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
  ----------------------------------------
  -- update_row for:OKL_STRM_TYP_ALLOCS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sta_rec                      IN sta_rec_type,
    x_sta_rec                      OUT NOCOPY sta_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ALLOCS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sta_rec                      sta_rec_type := p_sta_rec;
    l_def_sta_rec                  sta_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
--    l_okl_strm_typ_allocs_h_rec    okl_strm_typ_allocs_h_rec_type;
--    lx_okl_strm_typ_allocs_h_rec   okl_strm_typ_allocs_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sta_rec	IN sta_rec_type,
      x_sta_rec	OUT NOCOPY sta_rec_type
    ) RETURN VARCHAR2 IS
      l_sta_rec                      sta_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sta_rec := p_sta_rec;
      -- Get current database values
      l_sta_rec := get_rec(p_sta_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
--      migrate(l_sta_rec, l_okl_strm_typ_allocs_h_rec);
      IF (x_sta_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.id := l_sta_rec.id;
      END IF;
      IF (x_sta_rec.cat_id = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.cat_id := l_sta_rec.cat_id;
      END IF;
      IF (x_sta_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.sty_id := l_sta_rec.sty_id;
      END IF;
      IF (x_sta_rec.stream_allc_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.stream_allc_type := l_sta_rec.stream_allc_type;
      END IF;
      IF (x_sta_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.object_version_number := l_sta_rec.object_version_number;
      END IF;
      IF (x_sta_rec.sequence_number = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.sequence_number := l_sta_rec.sequence_number;
      END IF;
      IF (x_sta_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute_category := l_sta_rec.attribute_category;
      END IF;
      IF (x_sta_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute1 := l_sta_rec.attribute1;
      END IF;
      IF (x_sta_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute2 := l_sta_rec.attribute2;
      END IF;
      IF (x_sta_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute3 := l_sta_rec.attribute3;
      END IF;
      IF (x_sta_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute4 := l_sta_rec.attribute4;
      END IF;
      IF (x_sta_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute5 := l_sta_rec.attribute5;
      END IF;
      IF (x_sta_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute6 := l_sta_rec.attribute6;
      END IF;
      IF (x_sta_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute7 := l_sta_rec.attribute7;
      END IF;
      IF (x_sta_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute8 := l_sta_rec.attribute8;
      END IF;
      IF (x_sta_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute9 := l_sta_rec.attribute9;
      END IF;
      IF (x_sta_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute10 := l_sta_rec.attribute10;
      END IF;
      IF (x_sta_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute11 := l_sta_rec.attribute11;
      END IF;
      IF (x_sta_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute12 := l_sta_rec.attribute12;
      END IF;
      IF (x_sta_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute13 := l_sta_rec.attribute13;
      END IF;
      IF (x_sta_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute14 := l_sta_rec.attribute14;
      END IF;
      IF (x_sta_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_sta_rec.attribute15 := l_sta_rec.attribute15;
      END IF;
      IF (x_sta_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.created_by := l_sta_rec.created_by;
      END IF;
      IF (x_sta_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_sta_rec.creation_date := l_sta_rec.creation_date;
      END IF;
      IF (x_sta_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.last_updated_by := l_sta_rec.last_updated_by;
      END IF;
      IF (x_sta_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_sta_rec.last_update_date := l_sta_rec.last_update_date;
      END IF;
      IF (x_sta_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_sta_rec.last_update_login := l_sta_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYP_ALLOCS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sta_rec IN  sta_rec_type,
      x_sta_rec OUT NOCOPY sta_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sta_rec := p_sta_rec;
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
      p_sta_rec,                         -- IN
      l_sta_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sta_rec, l_def_sta_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_STRM_TYP_ALLOCS
    SET CAT_ID = l_def_sta_rec.cat_id,
        STY_ID = l_def_sta_rec.sty_id,
        STREAM_ALLC_TYPE = l_def_sta_rec.stream_allc_type,
        OBJECT_VERSION_NUMBER = l_def_sta_rec.object_version_number,
        SEQUENCE_NUMBER = l_def_sta_rec.sequence_number,
        ATTRIBUTE_CATEGORY = l_def_sta_rec.attribute_category,
        ATTRIBUTE1 = l_def_sta_rec.attribute1,
        ATTRIBUTE2 = l_def_sta_rec.attribute2,
        ATTRIBUTE3 = l_def_sta_rec.attribute3,
        ATTRIBUTE4 = l_def_sta_rec.attribute4,
        ATTRIBUTE5 = l_def_sta_rec.attribute5,
        ATTRIBUTE6 = l_def_sta_rec.attribute6,
        ATTRIBUTE7 = l_def_sta_rec.attribute7,
        ATTRIBUTE8 = l_def_sta_rec.attribute8,
        ATTRIBUTE9 = l_def_sta_rec.attribute9,
        ATTRIBUTE10 = l_def_sta_rec.attribute10,
        ATTRIBUTE11 = l_def_sta_rec.attribute11,
        ATTRIBUTE12 = l_def_sta_rec.attribute12,
        ATTRIBUTE13 = l_def_sta_rec.attribute13,
        ATTRIBUTE14 = l_def_sta_rec.attribute14,
        ATTRIBUTE15 = l_def_sta_rec.attribute15,
        CREATED_BY = l_def_sta_rec.created_by,
        CREATION_DATE = l_def_sta_rec.creation_date,
        LAST_UPDATED_BY = l_def_sta_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sta_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sta_rec.last_update_login
    WHERE ID = l_def_sta_rec.id;

    -- Insert into History table
   /*
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_strm_typ_allocs_h_rec,
      lx_okl_strm_typ_allocs_h_rec
    );
  */
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_sta_rec := l_def_sta_rec;
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
  ------------------------------------------
  -- update_row for:OKL_STRM_TYP_ALLOCS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_rec                     IN stav_rec_type,
    x_stav_rec                     OUT NOCOPY stav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stav_rec                     stav_rec_type := p_stav_rec;
    l_def_stav_rec                 stav_rec_type;
    l_sta_rec                      sta_rec_type;
    lx_sta_rec                     sta_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_stav_rec	IN stav_rec_type
    ) RETURN stav_rec_type IS
      l_stav_rec	stav_rec_type := p_stav_rec;
    BEGIN
      l_stav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_stav_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_stav_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_stav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_stav_rec	IN stav_rec_type,
      x_stav_rec	OUT NOCOPY stav_rec_type
    ) RETURN VARCHAR2 IS
      l_stav_rec                     stav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_stav_rec := p_stav_rec;
      -- Get current database values
      l_stav_rec := get_rec(p_stav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_stav_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.id := l_stav_rec.id;
      END IF;
      IF (x_stav_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.object_version_number := l_stav_rec.object_version_number;
      END IF;
      IF (x_stav_rec.sty_id = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.sty_id := l_stav_rec.sty_id;
      END IF;
      IF (x_stav_rec.cat_id = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.cat_id := l_stav_rec.cat_id;
      END IF;
      IF (x_stav_rec.sequence_number = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.sequence_number := l_stav_rec.sequence_number;
      END IF;
      IF (x_stav_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute_category := l_stav_rec.attribute_category;
      END IF;
      IF (x_stav_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute1 := l_stav_rec.attribute1;
      END IF;
      IF (x_stav_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute2 := l_stav_rec.attribute2;
      END IF;
      IF (x_stav_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute3 := l_stav_rec.attribute3;
      END IF;
      IF (x_stav_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute4 := l_stav_rec.attribute4;
      END IF;
      IF (x_stav_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute5 := l_stav_rec.attribute5;
      END IF;
      IF (x_stav_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute6 := l_stav_rec.attribute6;
      END IF;
      IF (x_stav_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute7 := l_stav_rec.attribute7;
      END IF;
      IF (x_stav_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute8 := l_stav_rec.attribute8;
      END IF;
      IF (x_stav_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute9 := l_stav_rec.attribute9;
      END IF;
      IF (x_stav_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute10 := l_stav_rec.attribute10;
      END IF;
      IF (x_stav_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute11 := l_stav_rec.attribute11;
      END IF;
      IF (x_stav_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute12 := l_stav_rec.attribute12;
      END IF;
      IF (x_stav_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute13 := l_stav_rec.attribute13;
      END IF;
      IF (x_stav_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute14 := l_stav_rec.attribute14;
      END IF;
      IF (x_stav_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.attribute15 := l_stav_rec.attribute15;
      END IF;
      IF (x_stav_rec.stream_allc_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_stav_rec.stream_allc_type := l_stav_rec.stream_allc_type;
      END IF;
      IF (x_stav_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.created_by := l_stav_rec.created_by;
      END IF;
      IF (x_stav_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_stav_rec.creation_date := l_stav_rec.creation_date;
      END IF;
      IF (x_stav_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.last_updated_by := l_stav_rec.last_updated_by;
      END IF;
      IF (x_stav_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_stav_rec.last_update_date := l_stav_rec.last_update_date;
      END IF;
      IF (x_stav_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_stav_rec.last_update_login := l_stav_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_STRM_TYP_ALLOCS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_stav_rec IN  stav_rec_type,
      x_stav_rec OUT NOCOPY stav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_stav_rec := p_stav_rec;
      x_stav_rec.OBJECT_VERSION_NUMBER := NVL(x_stav_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_stav_rec,                        -- IN
      l_stav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_stav_rec, l_def_stav_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_stav_rec := fill_who_columns(l_def_stav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_stav_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_stav_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_stav_rec, l_sta_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sta_rec,
      lx_sta_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sta_rec, l_def_stav_rec);
    x_stav_rec := l_def_stav_rec;
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
  -- PL/SQL TBL update_row for:STAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_tbl                     IN stav_tbl_type,
    x_stav_tbl                     OUT NOCOPY stav_tbl_type) IS

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
    IF (p_stav_tbl.COUNT > 0) THEN
      i := p_stav_tbl.FIRST;
      LOOP

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stav_rec                     => p_stav_tbl(i),
          x_stav_rec                     => x_stav_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
               l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_stav_tbl.LAST);
        i := p_stav_tbl.NEXT(i);
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
  ----------------------------------------
  -- delete_row for:OKL_STRM_TYP_ALLOCS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sta_rec                      IN sta_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ALLOCS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_sta_rec                      sta_rec_type:= p_sta_rec;
    l_row_notfound                 BOOLEAN := TRUE;
--    l_okl_strm_typ_allocs_h_rec    okl_strm_typ_allocs_h_rec_type;
--    lx_okl_strm_typ_allocs_h_rec   okl_strm_typ_allocs_h_rec_type;
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
    l_sta_rec := get_rec(l_sta_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

   /*
    migrate(l_sta_rec, l_okl_strm_typ_allocs_h_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_strm_typ_allocs_h_rec,
      lx_okl_strm_typ_allocs_h_rec
    );
   */

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_STRM_TYP_ALLOCS
     WHERE ID = l_sta_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_STRM_TYP_ALLOCS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_rec                     IN stav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_stav_rec                     stav_rec_type := p_stav_rec;
    l_sta_rec                      sta_rec_type;
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
    migrate(l_stav_rec, l_sta_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sta_rec
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
  -- PL/SQL TBL delete_row for:STAV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stav_tbl                     IN stav_tbl_type) IS

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
    IF (p_stav_tbl.COUNT > 0) THEN
      i := p_stav_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stav_rec                     => p_stav_tbl(i));
		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change


        EXIT WHEN (i = p_stav_tbl.LAST);
        i := p_stav_tbl.NEXT(i);
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
END Okl_Sta_Pvt;

/
