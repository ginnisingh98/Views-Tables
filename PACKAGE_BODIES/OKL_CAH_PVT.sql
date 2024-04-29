--------------------------------------------------------
--  DDL for Package Body OKL_CAH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CAH_PVT" AS
/* $Header: OKLSCAHB.pls 120.2 2006/07/11 10:11:09 dkagrawa noship $ */
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
  -- FUNCTION get_rec for: OKL_CSH_ALLCT_SRCHS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cah_rec                      IN cah_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cah_rec_type IS
    CURSOR cah_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            SEQUENCE_NUMBER,
            CASH_SEARCH_TYPE,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
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
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Csh_Allct_Srchs
     WHERE okl_csh_allct_srchs.id = p_id;
    l_cah_pk                       cah_pk_csr%ROWTYPE;
    l_cah_rec                      cah_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cah_pk_csr (p_cah_rec.id);
    FETCH cah_pk_csr INTO
              l_cah_rec.ID,
              l_cah_rec.NAME,
              l_cah_rec.SEQUENCE_NUMBER,
              l_cah_rec.CASH_SEARCH_TYPE,
              l_cah_rec.OBJECT_VERSION_NUMBER,
              l_cah_rec.DESCRIPTION,
              l_cah_rec.ATTRIBUTE_CATEGORY,
              l_cah_rec.ATTRIBUTE1,
              l_cah_rec.ATTRIBUTE2,
              l_cah_rec.ATTRIBUTE3,
              l_cah_rec.ATTRIBUTE4,
              l_cah_rec.ATTRIBUTE5,
              l_cah_rec.ATTRIBUTE6,
              l_cah_rec.ATTRIBUTE7,
              l_cah_rec.ATTRIBUTE8,
              l_cah_rec.ATTRIBUTE9,
              l_cah_rec.ATTRIBUTE10,
              l_cah_rec.ATTRIBUTE11,
              l_cah_rec.ATTRIBUTE12,
              l_cah_rec.ATTRIBUTE13,
              l_cah_rec.ATTRIBUTE14,
              l_cah_rec.ATTRIBUTE15,
              l_cah_rec.ORG_ID,
              l_cah_rec.CREATED_BY,
              l_cah_rec.CREATION_DATE,
              l_cah_rec.LAST_UPDATED_BY,
              l_cah_rec.LAST_UPDATE_DATE,
              l_cah_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cah_pk_csr%NOTFOUND;
    CLOSE cah_pk_csr;
    RETURN(l_cah_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cah_rec                      IN cah_rec_type
  ) RETURN cah_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cah_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CSH_ALLCT_SRCHS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cahv_rec                     IN cahv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cahv_rec_type IS
    CURSOR okl_cahv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            DESCRIPTION,
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
            ORG_ID,
            CASH_SEARCH_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_CSH_ALLCT_SRCHS
     WHERE OKL_CSH_ALLCT_SRCHS.id = p_id;
    l_okl_cahv_pk                  okl_cahv_pk_csr%ROWTYPE;
    l_cahv_rec                     cahv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cahv_pk_csr (p_cahv_rec.id);
    FETCH okl_cahv_pk_csr INTO
              l_cahv_rec.ID,
              l_cahv_rec.OBJECT_VERSION_NUMBER,
              l_cahv_rec.NAME,
              l_cahv_rec.DESCRIPTION,
              l_cahv_rec.SEQUENCE_NUMBER,
              l_cahv_rec.ATTRIBUTE_CATEGORY,
              l_cahv_rec.ATTRIBUTE1,
              l_cahv_rec.ATTRIBUTE2,
              l_cahv_rec.ATTRIBUTE3,
              l_cahv_rec.ATTRIBUTE4,
              l_cahv_rec.ATTRIBUTE5,
              l_cahv_rec.ATTRIBUTE6,
              l_cahv_rec.ATTRIBUTE7,
              l_cahv_rec.ATTRIBUTE8,
              l_cahv_rec.ATTRIBUTE9,
              l_cahv_rec.ATTRIBUTE10,
              l_cahv_rec.ATTRIBUTE11,
              l_cahv_rec.ATTRIBUTE12,
              l_cahv_rec.ATTRIBUTE13,
              l_cahv_rec.ATTRIBUTE14,
              l_cahv_rec.ATTRIBUTE15,
              l_cahv_rec.ORG_ID,
              l_cahv_rec.CASH_SEARCH_TYPE,
              l_cahv_rec.CREATED_BY,
              l_cahv_rec.CREATION_DATE,
              l_cahv_rec.LAST_UPDATED_BY,
              l_cahv_rec.LAST_UPDATE_DATE,
              l_cahv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cahv_pk_csr%NOTFOUND;
    CLOSE okl_cahv_pk_csr;
    RETURN(l_cahv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cahv_rec                     IN cahv_rec_type
  ) RETURN cahv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cahv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CSH_ALLCT_SRCHS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cahv_rec	IN cahv_rec_type
  ) RETURN cahv_rec_type IS
    l_cahv_rec	cahv_rec_type := p_cahv_rec;
  BEGIN
    IF (l_cahv_rec.object_version_number = Okl_Api.G_MISS_NUM) THEN
      l_cahv_rec.object_version_number := NULL;
    END IF;
    IF (l_cahv_rec.name = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.name := NULL;
    END IF;
    IF (l_cahv_rec.description = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.description := NULL;
    END IF;
    IF (l_cahv_rec.sequence_number = Okl_Api.G_MISS_NUM) THEN
      l_cahv_rec.sequence_number := NULL;
    END IF;
    IF (l_cahv_rec.attribute_category = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute_category := NULL;
    END IF;
    IF (l_cahv_rec.attribute1 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute1 := NULL;
    END IF;
    IF (l_cahv_rec.attribute2 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute2 := NULL;
    END IF;
    IF (l_cahv_rec.attribute3 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute3 := NULL;
    END IF;
    IF (l_cahv_rec.attribute4 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute4 := NULL;
    END IF;
    IF (l_cahv_rec.attribute5 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute5 := NULL;
    END IF;
    IF (l_cahv_rec.attribute6 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute6 := NULL;
    END IF;
    IF (l_cahv_rec.attribute7 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute7 := NULL;
    END IF;
    IF (l_cahv_rec.attribute8 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute8 := NULL;
    END IF;
    IF (l_cahv_rec.attribute9 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute9 := NULL;
    END IF;
    IF (l_cahv_rec.attribute10 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute10 := NULL;
    END IF;
    IF (l_cahv_rec.attribute11 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute11 := NULL;
    END IF;
    IF (l_cahv_rec.attribute12 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute12 := NULL;
    END IF;
    IF (l_cahv_rec.attribute13 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute13 := NULL;
    END IF;
    IF (l_cahv_rec.attribute14 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute14 := NULL;
    END IF;
    IF (l_cahv_rec.attribute15 = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.attribute15 := NULL;
    END IF;
    IF (l_cahv_rec.org_id = Okl_Api.G_MISS_NUM) THEN
      l_cahv_rec.org_id := NULL;
    END IF;
    IF (l_cahv_rec.cash_search_type = Okl_Api.G_MISS_CHAR) THEN
      l_cahv_rec.cash_search_type := NULL;
    END IF;
    IF (l_cahv_rec.created_by = Okl_Api.G_MISS_NUM) THEN
      l_cahv_rec.created_by := NULL;
    END IF;
    IF (l_cahv_rec.creation_date = Okl_Api.G_MISS_DATE) THEN
      l_cahv_rec.creation_date := NULL;
    END IF;
    IF (l_cahv_rec.last_updated_by = Okl_Api.G_MISS_NUM) THEN
      l_cahv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cahv_rec.last_update_date = Okl_Api.G_MISS_DATE) THEN
      l_cahv_rec.last_update_date := NULL;
    END IF;
    IF (l_cahv_rec.last_update_login = Okl_Api.G_MISS_NUM) THEN
      l_cahv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cahv_rec);
  END null_out_defaults;

   ---------------------------------------------------------------------------
  -- POST TAPI CODE  04/23/2001
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : validate_name
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_name(p_cahv_rec 		    IN 	cahv_rec_type,
                        x_return_status 	OUT NOCOPY VARCHAR2) IS

 BEGIN

   x_return_status:=Okl_Api.G_RET_STS_SUCCESS;
   --check not null
    IF (p_cahv_rec.name IS NULL) OR (p_cahv_rec.name = Okl_Api.G_MISS_CHAR) OR
       (p_cahv_rec.sequence_number IS NULL) OR (p_cahv_rec.sequence_number = Okl_Api.G_MISS_NUM) THEN

        Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                           ,p_msg_name       => 'OKL_BPD_MISSING_FIELDS');

        RAISE G_EXCEPTION_HALT_VALIDATION;
        -- x_return_status    := Okl_Api.G_RET_STS_ERROR;

    END IF;

  END validate_name;

  FUNCTION IS_UNIQUE (p_cahv_rec cahv_rec_type) RETURN VARCHAR2
  IS
    CURSOR l_chr_csr IS
		 SELECT 'x'
		 FROM okl_csh_allct_srchs
		 WHERE name = p_cahv_rec.name
		 AND   id <> NVL(p_cahv_rec.id,-99999);

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN
    -- check for unique name
    OPEN l_chr_csr;
    FETCH l_chr_csr INTO l_dummy;
	CLOSE l_chr_csr;

    IF l_dummy = 'x' THEN
  	    Okl_Api.SET_MESSAGE(p_app_name       => 'OKL'
                          ,p_msg_name        => 'OKL_BPD_DUP_COMBI_NAME');

       l_return_status    := Okl_Api.G_RET_STS_ERROR;
    END IF;

    RETURN (l_return_status);

  END IS_UNIQUE;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CSH_ALLCT_SRCHS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cahv_rec IN  cahv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- Added 04/23/2001 -- Bruno Vaghela
    x_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

  --Added 04/23/2001 Bruno Vaghela ---

    validate_name(p_cahv_rec, x_return_status);
	IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

  --END 04/23/2001 Bruno Vaghela ---

    IF p_cahv_rec.id = Okl_Api.G_MISS_NUM OR
       p_cahv_rec.id IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_cahv_rec.object_version_number = Okl_Api.G_MISS_NUM OR
          p_cahv_rec.object_version_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_cahv_rec.name = Okl_Api.G_MISS_CHAR OR
          p_cahv_rec.name IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_cahv_rec.sequence_number = Okl_Api.G_MISS_NUM OR
          p_cahv_rec.sequence_number IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sequence_number');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSIF p_cahv_rec.cash_search_type = Okl_Api.G_MISS_CHAR OR
          p_cahv_rec.cash_search_type IS NULL
    THEN
      Okl_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cash_search_type');
      l_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_CSH_ALLCT_SRCHS_V --
  -----------------------------------------------

  --Added 04/23/2001 Bruno Vaghela ---

  FUNCTION Validate_Record (
    p_cahv_rec IN cahv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  BEGIN

    l_return_status := IS_UNIQUE(p_cahv_rec);

    RETURN (l_return_status);

  END Validate_Record;

  --END 04/23/2001 Bruno Vaghela ---

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cahv_rec_type,
    p_to	IN OUT NOCOPY cah_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.sequence_number := p_from.sequence_number;
    p_to.cash_search_type := p_from.cash_search_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
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
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cah_rec_type,
    p_to	IN OUT NOCOPY cahv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.sequence_number := p_from.sequence_number;
    p_to.cash_search_type := p_from.cash_search_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
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
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
/*  -- history tables not supported -- 04 APR 2002
  PROCEDURE migrate (
    p_from	IN cah_rec_type,
    p_to	IN OUT NOCOPY okl_csh_allct_srchs_h_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.sequence_number := p_from.sequence_number;
    p_to.cash_search_type := p_from.cash_search_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
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
  --------------------------------------------
  -- validate_row for:OKL_CSH_ALLCT_SRCHS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_rec                     IN cahv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cahv_rec                     cahv_rec_type := p_cahv_rec;
    l_cah_rec                      cah_rec_type;
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
    l_return_status := Validate_Attributes(l_cahv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cahv_rec);
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
  -- PL/SQL TBL validate_row for:CAHV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_tbl                     IN cahv_tbl_type) IS

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
    IF (p_cahv_tbl.COUNT > 0) THEN
      i := p_cahv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cahv_rec                     => p_cahv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_cahv_tbl.LAST);
        i := p_cahv_tbl.NEXT(i);
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
  -- insert_row for:OKL_CSH_ALLCT_SRCHS_H --
  ------------------------------------------
/*  -- history tables not supported -- 04 APR 2002
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_csh_allct_srchs_h_rec    IN okl_csh_allct_srchs_h_rec_type,
    x_okl_csh_allct_srchs_h_rec    OUT NOCOPY okl_csh_allct_srchs_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'H_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_okl_csh_allct_srchs_h_rec    okl_csh_allct_srchs_h_rec_type := p_okl_csh_allct_srchs_h_rec;
    ldefoklcshallctsrchshrec       okl_csh_allct_srchs_h_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CSH_ALLCT_SRCHS_H --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_csh_allct_srchs_h_rec IN  okl_csh_allct_srchs_h_rec_type,
      x_okl_csh_allct_srchs_h_rec OUT NOCOPY okl_csh_allct_srchs_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_csh_allct_srchs_h_rec := p_okl_csh_allct_srchs_h_rec;
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
      p_okl_csh_allct_srchs_h_rec,       -- IN
      l_okl_csh_allct_srchs_h_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

   ---------------------------------------------
   --Condition added by PB Suresh for Bug 2482011
   ---------------------------------------------
    l_return_status := Validate_Record(l_def_cahv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CSH_ALLCT_SRCHS_H(
        id,
        major_version,
        name,
        sequence_number,
        cash_search_type,
        object_version_number,
        description,
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
        l_okl_csh_allct_srchs_h_rec.id,
        l_okl_csh_allct_srchs_h_rec.major_version,
        l_okl_csh_allct_srchs_h_rec.name,
        l_okl_csh_allct_srchs_h_rec.sequence_number,
        l_okl_csh_allct_srchs_h_rec.cash_search_type,
        l_okl_csh_allct_srchs_h_rec.object_version_number,
        l_okl_csh_allct_srchs_h_rec.description,
        l_okl_csh_allct_srchs_h_rec.attribute_category,
        l_okl_csh_allct_srchs_h_rec.attribute1,
        l_okl_csh_allct_srchs_h_rec.attribute2,
        l_okl_csh_allct_srchs_h_rec.attribute3,
        l_okl_csh_allct_srchs_h_rec.attribute4,
        l_okl_csh_allct_srchs_h_rec.attribute5,
        l_okl_csh_allct_srchs_h_rec.attribute6,
        l_okl_csh_allct_srchs_h_rec.attribute7,
        l_okl_csh_allct_srchs_h_rec.attribute8,
        l_okl_csh_allct_srchs_h_rec.attribute9,
        l_okl_csh_allct_srchs_h_rec.attribute10,
        l_okl_csh_allct_srchs_h_rec.attribute11,
        l_okl_csh_allct_srchs_h_rec.attribute12,
        l_okl_csh_allct_srchs_h_rec.attribute13,
        l_okl_csh_allct_srchs_h_rec.attribute14,
        l_okl_csh_allct_srchs_h_rec.attribute15,
        l_okl_csh_allct_srchs_h_rec.created_by,
        l_okl_csh_allct_srchs_h_rec.creation_date,
        l_okl_csh_allct_srchs_h_rec.last_updated_by,
        l_okl_csh_allct_srchs_h_rec.last_update_date,
        l_okl_csh_allct_srchs_h_rec.last_update_login);
    -- Set OUT values
    x_okl_csh_allct_srchs_h_rec := l_okl_csh_allct_srchs_h_rec;
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
  ----------------------------------------
  -- insert_row for:OKL_CSH_ALLCT_SRCHS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cah_rec                      IN cah_rec_type,
    x_cah_rec                      OUT NOCOPY cah_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SRCHS_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cah_rec                      cah_rec_type := p_cah_rec;
    l_def_cah_rec                  cah_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_CSH_ALLCT_SRCHS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cah_rec IN  cah_rec_type,
      x_cah_rec OUT NOCOPY cah_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cah_rec := p_cah_rec;
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
      p_cah_rec,                         -- IN
      l_cah_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CSH_ALLCT_SRCHS(
        id,
        name,
        sequence_number,
        cash_search_type,
        object_version_number,
        description,
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
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_cah_rec.id,
        l_cah_rec.name,
        l_cah_rec.sequence_number,
        l_cah_rec.cash_search_type,
        l_cah_rec.object_version_number,
        l_cah_rec.description,
        l_cah_rec.attribute_category,
        l_cah_rec.attribute1,
        l_cah_rec.attribute2,
        l_cah_rec.attribute3,
        l_cah_rec.attribute4,
        l_cah_rec.attribute5,
        l_cah_rec.attribute6,
        l_cah_rec.attribute7,
        l_cah_rec.attribute8,
        l_cah_rec.attribute9,
        l_cah_rec.attribute10,
        l_cah_rec.attribute11,
        l_cah_rec.attribute12,
        l_cah_rec.attribute13,
        l_cah_rec.attribute14,
        l_cah_rec.attribute15,
        l_cah_rec.org_id,
        l_cah_rec.created_by,
        l_cah_rec.creation_date,
        l_cah_rec.last_updated_by,
        l_cah_rec.last_update_date,
        l_cah_rec.last_update_login);
    -- Set OUT values
    x_cah_rec := l_cah_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_CSH_ALLCT_SRCHS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_rec                     IN cahv_rec_type,
    x_cahv_rec                     OUT NOCOPY cahv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cahv_rec                     cahv_rec_type;
    l_def_cahv_rec                 cahv_rec_type;
    l_cah_rec                      cah_rec_type;
    lx_cah_rec                     cah_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cahv_rec	IN cahv_rec_type
    ) RETURN cahv_rec_type IS
      l_cahv_rec	cahv_rec_type := p_cahv_rec;
    BEGIN
      l_cahv_rec.CREATION_DATE := SYSDATE;
      l_cahv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_cahv_rec.LAST_UPDATE_DATE := l_cahv_rec.CREATION_DATE;
      l_cahv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_cahv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_cahv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CSH_ALLCT_SRCHS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cahv_rec IN  cahv_rec_type,
      x_cahv_rec OUT NOCOPY cahv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cahv_rec := p_cahv_rec;
      x_cahv_rec.OBJECT_VERSION_NUMBER := 1;
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



    l_cahv_rec := null_out_defaults(p_cahv_rec);
    -- Set primary key value
    l_cahv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cahv_rec,                        -- IN
      l_def_cahv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_cahv_rec := fill_who_columns(l_def_cahv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cahv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cahv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cahv_rec, l_cah_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cah_rec,
      lx_cah_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cah_rec, l_def_cahv_rec);
    -- Set OUT values
    x_cahv_rec := l_def_cahv_rec;
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
  -- PL/SQL TBL insert_row for:CAHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_tbl                     IN cahv_tbl_type,
    x_cahv_tbl                     OUT NOCOPY cahv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

--custom code start: added by sspurani on 02/22/2002
    l_cahv_tbl           cahv_tbl_type := p_cahv_tbl;

    l_cahv_seq_tbl       cahv_tbl_type;
    x_cahv_seq_tbl       cahv_tbl_type;

    x1_cahv_tbl          cahv_tbl_type;
    x1_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    j                    NUMBER;
    l_newrownum          INTEGER;
--custom code end: added by sspurani on 02/22/2002

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

 -----------------------------------------------------------------------
 --Custom Code Start: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/22/2002
 -----------------------------------------------------------------------

 -------------------
-- DECLARE Cursors
-------------------
-- Get all the rows for update
   CURSOR c_csh_allct_srchs_all IS
   SELECT SEQUENCE_NUMBER, ID , NAME
   FROM OKL_CSH_ALLCT_SRCHS
   order by SEQUENCE_NUMBER;

   c_csh_allct_srchs_all_rec           c_csh_allct_srchs_all%ROWTYPE;

 -----------------------------------------------------------------------
 --Custom Code End: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/22/2002
 -----------------------------------------------------------------------

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cahv_tbl.COUNT > 0) THEN
      i := p_cahv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cahv_rec                     => p_cahv_tbl(i),
          x_cahv_rec                     => x_cahv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_cahv_tbl.LAST);
        i := p_cahv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;

 -----------------------------------------------------------------------
 --Custom Code Start: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/22/2002
 -----------------------------------------------------------------------

        l_newrownum :=  1;
        j   := 1;

        OPEN c_csh_allct_srchs_all;
        LOOP
        FETCH c_csh_allct_srchs_all INTO c_csh_allct_srchs_all_rec;
        EXIT WHEN c_csh_allct_srchs_all%NOTFOUND;

            l_cahv_seq_tbl(j).ID  := c_csh_allct_srchs_all_rec.ID;
            l_cahv_seq_tbl(j).SEQUENCE_NUMBER := (l_newrownum*5);
            l_cahv_seq_tbl(j).NAME := c_csh_allct_srchs_all_rec.NAME;

            l_newrownum := l_newrownum + 1;
            j   := j + 1;

        END LOOP;

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x1_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cahv_tbl                     => l_cahv_seq_tbl,
          x_cahv_tbl                     => x_cahv_seq_tbl);


 -----------------------------------------------------------------------
 --Custom Code End: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/22/2002
 -----------------------------------------------------------------------

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
  -- lock_row for:OKL_CSH_ALLCT_SRCHS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cah_rec                      IN cah_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cah_rec IN cah_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CSH_ALLCT_SRCHS
     WHERE ID = p_cah_rec.id
       AND OBJECT_VERSION_NUMBER = p_cah_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cah_rec IN cah_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CSH_ALLCT_SRCHS
    WHERE ID = p_cah_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SRCHS_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CSH_ALLCT_SRCHS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CSH_ALLCT_SRCHS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cah_rec);
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
      OPEN lchk_csr(p_cah_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cah_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cah_rec.object_version_number THEN
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
  -- lock_row for:OKL_CSH_ALLCT_SRCHS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_rec                     IN cahv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cah_rec                      cah_rec_type;
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
    migrate(p_cahv_rec, l_cah_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cah_rec
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
  -- PL/SQL TBL lock_row for:CAHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_tbl                     IN cahv_tbl_type) IS

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
    IF (p_cahv_tbl.COUNT > 0) THEN
      i := p_cahv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cahv_rec                     => p_cahv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_cahv_tbl.LAST);
        i := p_cahv_tbl.NEXT(i);
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
  -- update_row for:OKL_CSH_ALLCT_SRCHS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cah_rec                      IN cah_rec_type,
    x_cah_rec                      OUT NOCOPY cah_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SRCHS_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cah_rec                      cah_rec_type := p_cah_rec;
    l_def_cah_rec                  cah_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
--  l_okl_csh_allct_srchs_h_rec    okl_csh_allct_srchs_h_rec_type;
--  lx_okl_csh_allct_srchs_h_rec   okl_csh_allct_srchs_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cah_rec	IN cah_rec_type,
      x_cah_rec	OUT NOCOPY cah_rec_type
    ) RETURN VARCHAR2 IS
      l_cah_rec                      cah_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cah_rec := p_cah_rec;
      -- Get current database values
      l_cah_rec := get_rec(p_cah_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
--    migrate(l_cah_rec, l_okl_csh_allct_srchs_h_rec);
      IF (x_cah_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.id := l_cah_rec.id;
      END IF;
      IF (x_cah_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.name := l_cah_rec.name;
      END IF;
      IF (x_cah_rec.sequence_number = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.sequence_number := l_cah_rec.sequence_number;
      END IF;
      IF (x_cah_rec.cash_search_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.cash_search_type := l_cah_rec.cash_search_type;
      END IF;
      IF (x_cah_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.object_version_number := l_cah_rec.object_version_number;
      END IF;
      IF (x_cah_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.description := l_cah_rec.description;
      END IF;
      IF (x_cah_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute_category := l_cah_rec.attribute_category;
      END IF;
      IF (x_cah_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute1 := l_cah_rec.attribute1;
      END IF;
      IF (x_cah_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute2 := l_cah_rec.attribute2;
      END IF;
      IF (x_cah_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute3 := l_cah_rec.attribute3;
      END IF;
      IF (x_cah_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute4 := l_cah_rec.attribute4;
      END IF;
      IF (x_cah_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute5 := l_cah_rec.attribute5;
      END IF;
      IF (x_cah_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute6 := l_cah_rec.attribute6;
      END IF;
      IF (x_cah_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute7 := l_cah_rec.attribute7;
      END IF;
      IF (x_cah_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute8 := l_cah_rec.attribute8;
      END IF;
      IF (x_cah_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute9 := l_cah_rec.attribute9;
      END IF;
      IF (x_cah_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute10 := l_cah_rec.attribute10;
      END IF;
      IF (x_cah_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute11 := l_cah_rec.attribute11;
      END IF;
      IF (x_cah_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute12 := l_cah_rec.attribute12;
      END IF;
      IF (x_cah_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute13 := l_cah_rec.attribute13;
      END IF;
      IF (x_cah_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute14 := l_cah_rec.attribute14;
      END IF;
      IF (x_cah_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cah_rec.attribute15 := l_cah_rec.attribute15;
      END IF;
      IF (x_cah_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.org_id := l_cah_rec.org_id;
      END IF;
      IF (x_cah_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.created_by := l_cah_rec.created_by;
      END IF;
      IF (x_cah_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cah_rec.creation_date := l_cah_rec.creation_date;
      END IF;
      IF (x_cah_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.last_updated_by := l_cah_rec.last_updated_by;
      END IF;
      IF (x_cah_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cah_rec.last_update_date := l_cah_rec.last_update_date;
      END IF;
      IF (x_cah_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_cah_rec.last_update_login := l_cah_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CSH_ALLCT_SRCHS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cah_rec IN  cah_rec_type,
      x_cah_rec OUT NOCOPY cah_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cah_rec := p_cah_rec;
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
      p_cah_rec,                         -- IN
      l_cah_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cah_rec, l_def_cah_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CSH_ALLCT_SRCHS
    SET NAME = l_def_cah_rec.name,
        SEQUENCE_NUMBER = l_def_cah_rec.sequence_number,
        CASH_SEARCH_TYPE = l_def_cah_rec.cash_search_type,
        OBJECT_VERSION_NUMBER = l_def_cah_rec.object_version_number,
        DESCRIPTION = l_def_cah_rec.description,
        ATTRIBUTE_CATEGORY = l_def_cah_rec.attribute_category,
        ATTRIBUTE1 = l_def_cah_rec.attribute1,
        ATTRIBUTE2 = l_def_cah_rec.attribute2,
        ATTRIBUTE3 = l_def_cah_rec.attribute3,
        ATTRIBUTE4 = l_def_cah_rec.attribute4,
        ATTRIBUTE5 = l_def_cah_rec.attribute5,
        ATTRIBUTE6 = l_def_cah_rec.attribute6,
        ATTRIBUTE7 = l_def_cah_rec.attribute7,
        ATTRIBUTE8 = l_def_cah_rec.attribute8,
        ATTRIBUTE9 = l_def_cah_rec.attribute9,
        ATTRIBUTE10 = l_def_cah_rec.attribute10,
        ATTRIBUTE11 = l_def_cah_rec.attribute11,
        ATTRIBUTE12 = l_def_cah_rec.attribute12,
        ATTRIBUTE13 = l_def_cah_rec.attribute13,
        ATTRIBUTE14 = l_def_cah_rec.attribute14,
        ATTRIBUTE15 = l_def_cah_rec.attribute15,
        ORG_ID = l_def_cah_rec.org_id,
        CREATED_BY = l_def_cah_rec.created_by,
        CREATION_DATE = l_def_cah_rec.creation_date,
        LAST_UPDATED_BY = l_def_cah_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cah_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cah_rec.last_update_login
    WHERE ID = l_def_cah_rec.id;

    -- Insert into History table
/*
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_csh_allct_srchs_h_rec,
      lx_okl_csh_allct_srchs_h_rec
    );
*/
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    x_cah_rec := l_def_cah_rec;
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
  -- update_row for:OKL_CSH_ALLCT_SRCHS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_rec                     IN cahv_rec_type,
    x_cahv_rec                     OUT NOCOPY cahv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cahv_rec                     cahv_rec_type := p_cahv_rec;
    l_def_cahv_rec                 cahv_rec_type;
    l_cah_rec                      cah_rec_type;
    lx_cah_rec                     cah_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cahv_rec	IN cahv_rec_type
    ) RETURN cahv_rec_type IS
      l_cahv_rec	cahv_rec_type := p_cahv_rec;
    BEGIN
      l_cahv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cahv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_cahv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_cahv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cahv_rec	IN cahv_rec_type,
      x_cahv_rec	OUT NOCOPY cahv_rec_type
    ) RETURN VARCHAR2 IS
      l_cahv_rec                     cahv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cahv_rec := p_cahv_rec;
      -- Get current database values
      l_cahv_rec := get_rec(p_cahv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cahv_rec.id = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.id := l_cahv_rec.id;
      END IF;
      IF (x_cahv_rec.object_version_number = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.object_version_number := l_cahv_rec.object_version_number;
      END IF;
      IF (x_cahv_rec.name = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.name := l_cahv_rec.name;
      END IF;
      IF (x_cahv_rec.description = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.description := l_cahv_rec.description;
      END IF;
      IF (x_cahv_rec.sequence_number = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.sequence_number := l_cahv_rec.sequence_number;
      END IF;
      IF (x_cahv_rec.attribute_category = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute_category := l_cahv_rec.attribute_category;
      END IF;
      IF (x_cahv_rec.attribute1 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute1 := l_cahv_rec.attribute1;
      END IF;
      IF (x_cahv_rec.attribute2 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute2 := l_cahv_rec.attribute2;
      END IF;
      IF (x_cahv_rec.attribute3 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute3 := l_cahv_rec.attribute3;
      END IF;
      IF (x_cahv_rec.attribute4 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute4 := l_cahv_rec.attribute4;
      END IF;
      IF (x_cahv_rec.attribute5 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute5 := l_cahv_rec.attribute5;
      END IF;
      IF (x_cahv_rec.attribute6 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute6 := l_cahv_rec.attribute6;
      END IF;
      IF (x_cahv_rec.attribute7 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute7 := l_cahv_rec.attribute7;
      END IF;
      IF (x_cahv_rec.attribute8 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute8 := l_cahv_rec.attribute8;
      END IF;
      IF (x_cahv_rec.attribute9 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute9 := l_cahv_rec.attribute9;
      END IF;
      IF (x_cahv_rec.attribute10 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute10 := l_cahv_rec.attribute10;
      END IF;
      IF (x_cahv_rec.attribute11 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute11 := l_cahv_rec.attribute11;
      END IF;
      IF (x_cahv_rec.attribute12 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute12 := l_cahv_rec.attribute12;
      END IF;
      IF (x_cahv_rec.attribute13 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute13 := l_cahv_rec.attribute13;
      END IF;
      IF (x_cahv_rec.attribute14 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute14 := l_cahv_rec.attribute14;
      END IF;
      IF (x_cahv_rec.attribute15 = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.attribute15 := l_cahv_rec.attribute15;
      END IF;
      IF (x_cahv_rec.org_id = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.org_id := l_cahv_rec.org_id;
      END IF;
      IF (x_cahv_rec.cash_search_type = Okl_Api.G_MISS_CHAR)
      THEN
        x_cahv_rec.cash_search_type := l_cahv_rec.cash_search_type;
      END IF;
      IF (x_cahv_rec.created_by = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.created_by := l_cahv_rec.created_by;
      END IF;
      IF (x_cahv_rec.creation_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cahv_rec.creation_date := l_cahv_rec.creation_date;
      END IF;
      IF (x_cahv_rec.last_updated_by = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.last_updated_by := l_cahv_rec.last_updated_by;
      END IF;
      IF (x_cahv_rec.last_update_date = Okl_Api.G_MISS_DATE)
      THEN
        x_cahv_rec.last_update_date := l_cahv_rec.last_update_date;
      END IF;
      IF (x_cahv_rec.last_update_login = Okl_Api.G_MISS_NUM)
      THEN
        x_cahv_rec.last_update_login := l_cahv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CSH_ALLCT_SRCHS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cahv_rec IN  cahv_rec_type,
      x_cahv_rec OUT NOCOPY cahv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_cahv_rec := p_cahv_rec;
      x_cahv_rec.OBJECT_VERSION_NUMBER := NVL(x_cahv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
/*
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
*/
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cahv_rec,                        -- IN
      l_cahv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cahv_rec, l_def_cahv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_cahv_rec := fill_who_columns(l_def_cahv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cahv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cahv_rec);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cahv_rec, l_cah_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------

    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cah_rec,
      lx_cah_rec
    );

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cah_rec, l_def_cahv_rec);
    x_cahv_rec := l_def_cahv_rec;
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
  -- PL/SQL TBL update_row for:CAHV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_tbl                     IN cahv_tbl_type,
    x_cahv_tbl                     OUT NOCOPY cahv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

--custom code start: added by sspurani on 02/22/2002
    l_cahv_rec           cahv_rec_type;
    x_cahv_rec           cahv_rec_type;
    x1_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    j                    NUMBER;
    l_newrownum          INTEGER;
--custom code end: added by sspurani on 02/22/2002

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

 -----------------------------------------------------------------------
 --Custom Code Start: Added for ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/22/2002
 -----------------------------------------------------------------------

 -------------------
-- DECLARE Cursors
-------------------
-- Get all the rows for update
   CURSOR c_csh_allct_srchs_all IS
   SELECT SEQUENCE_NUMBER, ID
   FROM OKL_CSH_ALLCT_SRCHS
   order by SEQUENCE_NUMBER;

   c_csh_allct_srchs_all_rec           c_csh_allct_srchs_all%ROWTYPE;

 -----------------------------------------------------------------------
 --Custom Code End: Added for ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/22/2002
 -----------------------------------------------------------------------

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cahv_tbl.COUNT > 0) THEN
      i := p_cahv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cahv_rec                     => p_cahv_tbl(i),
          x_cahv_rec                     => x_cahv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_cahv_tbl.LAST);
        i := p_cahv_tbl.NEXT(i);
      END LOOP;

	  -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change

    END IF;

 -----------------------------------------------------------------------
 --Custom Code Start: Added for ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/26/2002
 -----------------------------------------------------------------------


    l_newrownum := 1;
    j   := 1;

    OPEN c_csh_allct_srchs_all;
    LOOP
    FETCH c_csh_allct_srchs_all INTO c_csh_allct_srchs_all_rec;
    EXIT WHEN c_csh_allct_srchs_all%NOTFOUND;

    l_cahv_rec.ID  := c_csh_allct_srchs_all_rec.ID;
    l_cahv_rec.SEQUENCE_NUMBER := (l_newrownum*5);

    update_row (
      p_api_version                  => p_api_version,
      p_init_msg_list                => Okl_Api.G_FALSE,
      x_return_status                => x1_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_cahv_rec                     => l_cahv_rec,
      x_cahv_rec                     => x_cahv_rec);

    l_newrownum := l_newrownum + 1;
    j   := j + 1;

    END LOOP;

 -----------------------------------------------------------------------
 --Custom Code End: Added for ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/26/2002
 -----------------------------------------------------------------------


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
  -- delete_row for:OKL_CSH_ALLCT_SRCHS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cah_rec                      IN cah_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SRCHS_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cah_rec                      cah_rec_type:= p_cah_rec;
    l_row_notfound                 BOOLEAN := TRUE;
--  l_okl_csh_allct_srchs_h_rec    okl_csh_allct_srchs_h_rec_type;
--  lx_okl_csh_allct_srchs_h_rec   okl_csh_allct_srchs_h_rec_type;
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
    l_cah_rec := get_rec(l_cah_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    migrate(l_cah_rec, l_okl_csh_allct_srchs_h_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_csh_allct_srchs_h_rec,
      lx_okl_csh_allct_srchs_h_rec
    );
   */
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_CSH_ALLCT_SRCHS
     WHERE ID = l_cah_rec.id;

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
  -- delete_row for:OKL_CSH_ALLCT_SRCHS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_rec                     IN cahv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_cahv_rec                     cahv_rec_type := p_cahv_rec;
    l_cah_rec                      cah_rec_type;

 -----------------------------------------------------------------------
 --Custom Code Start: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/26/2002
 -----------------------------------------------------------------------

    x_cahv_rec           cahv_rec_type;
    j                    NUMBER;
    l_newrownum          INTEGER;

 -------------------
-- DECLARE Cursors
-------------------
-- Get all the rows for update
   CURSOR c_csh_allct_srchs_all IS
   SELECT SEQUENCE_NUMBER, ID
   FROM OKL_CSH_ALLCT_SRCHS
   order by SEQUENCE_NUMBER;

   c_csh_allct_srchs_all_rec           c_csh_allct_srchs_all%ROWTYPE;

 -----------------------------------------------------------------------
 --Custom Code End: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/26/2002
 -----------------------------------------------------------------------

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
    migrate(l_cahv_rec, l_cah_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cah_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

 -----------------------------------------------------------------------
 --Custom Code Start: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/26/2002
 -----------------------------------------------------------------------

        l_newrownum :=  1;
        j   := 1;

        OPEN c_csh_allct_srchs_all;
        LOOP
        FETCH c_csh_allct_srchs_all INTO c_csh_allct_srchs_all_rec;
        EXIT WHEN c_csh_allct_srchs_all%NOTFOUND;

            l_cahv_rec.ID  := c_csh_allct_srchs_all_rec.ID;
            l_cahv_rec.SEQUENCE_NUMBER := (l_newrownum*5);


            update_row (
              p_api_version                  => p_api_version,
              p_init_msg_list                => Okl_Api.G_FALSE,
              x_return_status                => x_return_status,
              x_msg_count                    => x_msg_count,
              x_msg_data                     => x_msg_data,
              p_cahv_rec                     => l_cahv_rec,
              x_cahv_rec                     => x_cahv_rec);

            l_newrownum := l_newrownum + 1;
            j   := j + 1;

        END LOOP;

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

 -----------------------------------------------------------------------
 --Custom Code End: Added for generating and ordering sequence numbers
 --                   in multiples of 5 -- Added by sspurani 02/26/2002
 -----------------------------------------------------------------------


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
  -- PL/SQL TBL delete_row for:CAHV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cahv_tbl                     IN cahv_tbl_type) IS

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
    IF (p_cahv_tbl.COUNT > 0) THEN
      i := p_cahv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cahv_rec                     => p_cahv_tbl(i));

		  -- Begin Post-Generation Change
          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;
          -- End Post-Generation Change

        EXIT WHEN (i = p_cahv_tbl.LAST);
        i := p_cahv_tbl.NEXT(i);
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
END Okl_Cah_Pvt;

/
