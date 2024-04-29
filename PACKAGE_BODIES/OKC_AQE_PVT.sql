--------------------------------------------------------
--  DDL for Package Body OKC_AQE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AQE_PVT" AS
/* $Header: OKCSAQEB.pls 120.0 2005/05/25 18:26:33 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_AQERRORS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aqe_rec                      IN aqe_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aqe_rec_type IS
    CURSOR okc_aqerrors_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SOURCE_NAME,
            DATETIME,
            Q_NAME,
            MSGID,
            RETRY_COUNT,
            QUEUE_CONTENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Aqerrors
     WHERE okc_aqerrors.id      = p_id;
    l_okc_aqerrors_pk              okc_aqerrors_pk_csr%ROWTYPE;
    l_aqe_rec                      aqe_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_aqerrors_pk_csr (p_aqe_rec.id);
    FETCH okc_aqerrors_pk_csr INTO
              l_aqe_rec.ID,
              l_aqe_rec.SOURCE_NAME,
              l_aqe_rec.DATETIME,
              l_aqe_rec.Q_NAME,
              l_aqe_rec.MSGID,
              l_aqe_rec.RETRY_COUNT,
              l_aqe_rec.QUEUE_CONTENTS,
              l_aqe_rec.CREATED_BY,
              l_aqe_rec.CREATION_DATE,
              l_aqe_rec.LAST_UPDATED_BY,
              l_aqe_rec.LAST_UPDATE_DATE,
              l_aqe_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_aqerrors_pk_csr%NOTFOUND;
    CLOSE okc_aqerrors_pk_csr;
    RETURN(l_aqe_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aqe_rec                      IN aqe_rec_type
  ) RETURN aqe_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aqe_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_AQERRORS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aqev_rec                     IN aqev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aqev_rec_type IS
    CURSOR okc_aqev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SOURCE_NAME,
            DATETIME,
            Q_NAME,
            MSGID,
            RETRY_COUNT,
            QUEUE_CONTENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Aqerrors_V
     WHERE okc_aqerrors_v.id    = p_id;
    l_okc_aqev_pk                  okc_aqev_pk_csr%ROWTYPE;
    l_aqev_rec                     aqev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_aqev_pk_csr (p_aqev_rec.id);
    FETCH okc_aqev_pk_csr INTO
              l_aqev_rec.ID,
              l_aqev_rec.SOURCE_NAME,
              l_aqev_rec.DATETIME,
              l_aqev_rec.Q_NAME,
              l_aqev_rec.MSGID,
              l_aqev_rec.RETRY_COUNT,
              l_aqev_rec.QUEUE_CONTENTS,
              l_aqev_rec.CREATED_BY,
              l_aqev_rec.CREATION_DATE,
              l_aqev_rec.LAST_UPDATED_BY,
              l_aqev_rec.LAST_UPDATE_DATE,
              l_aqev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_aqev_pk_csr%NOTFOUND;
    CLOSE okc_aqev_pk_csr;
    RETURN(l_aqev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aqev_rec                     IN aqev_rec_type
  ) RETURN aqev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aqev_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_AQERRORS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_aqev_rec	IN aqev_rec_type
  ) RETURN aqev_rec_type IS
    l_aqev_rec	aqev_rec_type := p_aqev_rec;
  BEGIN
    IF (l_aqev_rec.source_name = OKC_API.G_MISS_CHAR) THEN
      l_aqev_rec.source_name := NULL;
    END IF;
    IF (l_aqev_rec.datetime = OKC_API.G_MISS_DATE) THEN
      l_aqev_rec.datetime := NULL;
    END IF;
    IF (l_aqev_rec.q_name = OKC_API.G_MISS_CHAR) THEN
      l_aqev_rec.q_name := NULL;
    END IF;
    IF (l_aqev_rec.msgid = OKC_API.G_MISS_CHAR) THEN
      l_aqev_rec.msgid := NULL;
    END IF;
    IF (l_aqev_rec.retry_count = OKC_API.G_MISS_NUM) THEN
      l_aqev_rec.retry_count := NULL;
    END IF;
    /*IF (l_aqev_rec.queue_contents = OKC_API.G_MISS_NUM) THEN
      l_aqev_rec.queue_contents := NULL;
    END IF;*/
    IF (l_aqev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_aqev_rec.created_by := NULL;
    END IF;
    IF (l_aqev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_aqev_rec.creation_date := NULL;
    END IF;
    IF (l_aqev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_aqev_rec.last_updated_by := NULL;
    END IF;
    IF (l_aqev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_aqev_rec.last_update_date := NULL;
    END IF;
    IF (l_aqev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_aqev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aqev_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKC_AQERRORS_V --
  --------------------------------------------
 --------------------------------------------
  -- Validate_Attributes for:OKC_AQERRORS_V --
  --------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_source_name
  -- Description     : Check if source name is null
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_source_name(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_aqev_rec              IN aqev_rec_type) IS
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	--Check if the source name is null
	IF p_aqev_rec.source_name = OKC_API.G_MISS_CHAR OR p_aqev_rec.source_name IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'source_name');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	/*IF p_aqev_rec.source_name <> UPPER(p_aqev_rec.source_name) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'source_name');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;*/
   EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 WHEN OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_source_name;

  FUNCTION Validate_Attributes (
    p_aqev_rec IN  aqev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	validate_source_name(x_return_status
		             ,p_aqev_rec);
      	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
      		ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
    	END IF;
    	RETURN(l_return_status);
    EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;
		RETURN(l_return_status);

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         	RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKC_AQERRORS_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_aqev_rec IN aqev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aqev_rec_type,
    p_to	OUT NOCOPY aqe_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.source_name := p_from.source_name;
    p_to.datetime := p_from.datetime;
    p_to.q_name := p_from.q_name;
    p_to.msgid := p_from.msgid;
    p_to.retry_count := p_from.retry_count;
    p_to.queue_contents := p_from.queue_contents;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN aqe_rec_type,
    p_to	IN OUT NOCOPY aqev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.source_name := p_from.source_name;
    p_to.datetime := p_from.datetime;
    p_to.q_name := p_from.q_name;
    p_to.msgid := p_from.msgid;
    p_to.retry_count := p_from.retry_count;
    p_to.queue_contents := p_from.queue_contents;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKC_AQERRORS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqev_rec                     aqev_rec_type := p_aqev_rec;
    l_aqe_rec                      aqe_rec_type;
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
    -- ** No validation required for error log
    -- l_return_status := Validate_Attributes(l_aqev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aqev_rec);
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
  -- PL/SQL TBL validate_row for:AQEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aqev_tbl.COUNT > 0) THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aqev_rec                     => p_aqev_tbl(i));
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  ---------------------------------
  -- insert_row for:OKC_AQERRORS --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqe_rec                      IN aqe_rec_type,
    x_aqe_rec                      OUT NOCOPY aqe_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'AQERRORS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqe_rec                      aqe_rec_type := p_aqe_rec;
    l_def_aqe_rec                  aqe_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKC_AQERRORS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_aqe_rec IN  aqe_rec_type,
      x_aqe_rec OUT NOCOPY aqe_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aqe_rec := p_aqe_rec;
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
      p_aqe_rec,                         -- IN
      l_aqe_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_AQERRORS(
        id,
        source_name,
        datetime,
        q_name,
        msgid,
        retry_count,
        queue_contents,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_aqe_rec.id,
        l_aqe_rec.source_name,
        l_aqe_rec.datetime,
        l_aqe_rec.q_name,
        l_aqe_rec.msgid,
        l_aqe_rec.retry_count,
        l_aqe_rec.queue_contents,
        l_aqe_rec.created_by,
        l_aqe_rec.creation_date,
        l_aqe_rec.last_updated_by,
        l_aqe_rec.last_update_date,
        l_aqe_rec.last_update_login);
    -- Set OUT values
    x_aqe_rec := l_aqe_rec;
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
  -----------------------------------
  -- insert_row for:OKC_AQERRORS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    x_aqev_rec                     OUT NOCOPY aqev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqev_rec                     aqev_rec_type;
    l_def_aqev_rec                 aqev_rec_type;
    l_aqe_rec                      aqe_rec_type;
    lx_aqe_rec                     aqe_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aqev_rec	IN aqev_rec_type
    ) RETURN aqev_rec_type IS
      l_aqev_rec	aqev_rec_type := p_aqev_rec;
    BEGIN
      l_aqev_rec.CREATION_DATE := SYSDATE;
      l_aqev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_aqev_rec.LAST_UPDATE_DATE := l_aqev_rec.CREATION_DATE;
      l_aqev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aqev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aqev_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKC_AQERRORS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_aqev_rec IN  aqev_rec_type,
      x_aqev_rec OUT NOCOPY aqev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aqev_rec := p_aqev_rec;
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
    l_aqev_rec := null_out_defaults(p_aqev_rec);
    -- Set primary key value
    l_aqev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aqev_rec,                        -- IN
      l_def_aqev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aqev_rec := fill_who_columns(l_def_aqev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    -- ** No validation required for error log
    -- l_return_status := Validate_Attributes(l_def_aqev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aqev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aqev_rec, l_aqe_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aqe_rec,
      lx_aqe_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aqe_rec, l_def_aqev_rec);
    -- Set OUT values
    x_aqev_rec := l_def_aqev_rec;
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
  -- PL/SQL TBL insert_row for:AQEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type,
    x_aqev_tbl                     OUT NOCOPY aqev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aqev_tbl.COUNT > 0) THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aqev_rec                     => p_aqev_tbl(i),
          x_aqev_rec                     => x_aqev_tbl(i));
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  -------------------------------
  -- lock_row for:OKC_AQERRORS --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqe_rec                      IN aqe_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aqe_rec IN aqe_rec_type) IS
    SELECT *
      FROM OKC_AQERRORS
     WHERE ID = p_aqe_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'AQERRORS_lock_row';
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
      OPEN lock_csr(p_aqe_rec);
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
    ELSE
      IF (l_lock_var.ID <> p_aqe_rec.id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.SOURCE_NAME <> p_aqe_rec.source_name) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.DATETIME <> p_aqe_rec.datetime) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.Q_NAME <> p_aqe_rec.q_name) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.MSGID <> p_aqe_rec.msgid) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.RETRY_COUNT <> p_aqe_rec.retry_count) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      /*IF (l_lock_var.QUEUE_CONTENTS <> p_aqe_rec.queue_contents) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;*/
      IF (l_lock_var.CREATED_BY <> p_aqe_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATION_DATE <> p_aqe_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATED_BY <> p_aqe_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATE_DATE <> p_aqe_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATE_LOGIN <> p_aqe_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
  ---------------------------------
  -- lock_row for:OKC_AQERRORS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqe_rec                      aqe_rec_type;
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
    migrate(p_aqev_rec, l_aqe_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aqe_rec
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
  -- PL/SQL TBL lock_row for:AQEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aqev_tbl.COUNT > 0) THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aqev_rec                     => p_aqev_tbl(i));
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  ---------------------------------
  -- update_row for:OKC_AQERRORS --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqe_rec                      IN aqe_rec_type,
    x_aqe_rec                      OUT NOCOPY aqe_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'AQERRORS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqe_rec                      aqe_rec_type := p_aqe_rec;
    l_def_aqe_rec                  aqe_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aqe_rec	IN aqe_rec_type,
      x_aqe_rec	OUT NOCOPY aqe_rec_type
    ) RETURN VARCHAR2 IS
      l_aqe_rec                      aqe_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aqe_rec := p_aqe_rec;
      -- Get current database values
      l_aqe_rec := get_rec(p_aqe_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aqe_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_aqe_rec.id := l_aqe_rec.id;
      END IF;
      IF (x_aqe_rec.source_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aqe_rec.source_name := l_aqe_rec.source_name;
      END IF;
      IF (x_aqe_rec.datetime = OKC_API.G_MISS_DATE)
      THEN
        x_aqe_rec.datetime := l_aqe_rec.datetime;
      END IF;
      IF (x_aqe_rec.q_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aqe_rec.q_name := l_aqe_rec.q_name;
      END IF;
      IF (x_aqe_rec.msgid = OKC_API.G_MISS_CHAR)
      THEN
        x_aqe_rec.msgid := l_aqe_rec.msgid;
      END IF;
      IF (x_aqe_rec.retry_count = OKC_API.G_MISS_NUM)
      THEN
        x_aqe_rec.retry_count := l_aqe_rec.retry_count;
      END IF;
      IF (x_aqe_rec.queue_contents IS NULL)
      THEN
        x_aqe_rec.queue_contents := l_aqe_rec.queue_contents;
      END IF;
      IF (x_aqe_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aqe_rec.created_by := l_aqe_rec.created_by;
      END IF;
      IF (x_aqe_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aqe_rec.creation_date := l_aqe_rec.creation_date;
      END IF;
      IF (x_aqe_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aqe_rec.last_updated_by := l_aqe_rec.last_updated_by;
      END IF;
      IF (x_aqe_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aqe_rec.last_update_date := l_aqe_rec.last_update_date;
      END IF;
      IF (x_aqe_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aqe_rec.last_update_login := l_aqe_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKC_AQERRORS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_aqe_rec IN  aqe_rec_type,
      x_aqe_rec OUT NOCOPY aqe_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aqe_rec := p_aqe_rec;
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
      p_aqe_rec,                         -- IN
      l_aqe_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aqe_rec, l_def_aqe_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_AQERRORS
    SET SOURCE_NAME = l_def_aqe_rec.source_name,
        DATETIME = l_def_aqe_rec.datetime,
        Q_NAME = l_def_aqe_rec.q_name,
        MSGID = l_def_aqe_rec.msgid,
        RETRY_COUNT = l_def_aqe_rec.retry_count,
        QUEUE_CONTENTS = l_def_aqe_rec.queue_contents,
        CREATED_BY = l_def_aqe_rec.created_by,
        CREATION_DATE = l_def_aqe_rec.creation_date,
        LAST_UPDATED_BY = l_def_aqe_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aqe_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aqe_rec.last_update_login
    WHERE ID = l_def_aqe_rec.id;

    x_aqe_rec := l_def_aqe_rec;
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
  -----------------------------------
  -- update_row for:OKC_AQERRORS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type,
    x_aqev_rec                     OUT NOCOPY aqev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqev_rec                     aqev_rec_type := p_aqev_rec;
    l_def_aqev_rec                 aqev_rec_type;
    l_aqe_rec                      aqe_rec_type;
    lx_aqe_rec                     aqe_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aqev_rec	IN aqev_rec_type
    ) RETURN aqev_rec_type IS
      l_aqev_rec	aqev_rec_type := p_aqev_rec;
    BEGIN
      l_aqev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aqev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aqev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aqev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aqev_rec	IN aqev_rec_type,
      x_aqev_rec	OUT NOCOPY aqev_rec_type
    ) RETURN VARCHAR2 IS
      l_aqev_rec                     aqev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aqev_rec := p_aqev_rec;
      -- Get current database values
      l_aqev_rec := get_rec(p_aqev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aqev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_aqev_rec.id := l_aqev_rec.id;
      END IF;
      IF (x_aqev_rec.source_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aqev_rec.source_name := l_aqev_rec.source_name;
      END IF;
      IF (x_aqev_rec.datetime = OKC_API.G_MISS_DATE)
      THEN
        x_aqev_rec.datetime := l_aqev_rec.datetime;
      END IF;
      IF (x_aqev_rec.q_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aqev_rec.q_name := l_aqev_rec.q_name;
      END IF;
      IF (x_aqev_rec.msgid = OKC_API.G_MISS_CHAR)
      THEN
        x_aqev_rec.msgid := l_aqev_rec.msgid;
      END IF;
      IF (x_aqev_rec.retry_count = OKC_API.G_MISS_NUM)
      THEN
        x_aqev_rec.retry_count := l_aqev_rec.retry_count;
      END IF;
      IF (x_aqev_rec.queue_contents IS NULL)
      THEN
        x_aqev_rec.queue_contents := l_aqev_rec.queue_contents;
      END IF;
      IF (x_aqev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aqev_rec.created_by := l_aqev_rec.created_by;
      END IF;
      IF (x_aqev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aqev_rec.creation_date := l_aqev_rec.creation_date;
      END IF;
      IF (x_aqev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aqev_rec.last_updated_by := l_aqev_rec.last_updated_by;
      END IF;
      IF (x_aqev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aqev_rec.last_update_date := l_aqev_rec.last_update_date;
      END IF;
      IF (x_aqev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aqev_rec.last_update_login := l_aqev_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_AQERRORS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_aqev_rec IN  aqev_rec_type,
      x_aqev_rec OUT NOCOPY aqev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aqev_rec := p_aqev_rec;
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
      p_aqev_rec,                        -- IN
      l_aqev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aqev_rec, l_def_aqev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aqev_rec := fill_who_columns(l_def_aqev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    -- ** No validation required for error log
    -- l_return_status := Validate_Attributes(l_def_aqev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aqev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aqev_rec, l_aqe_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aqe_rec,
      lx_aqe_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aqe_rec, l_def_aqev_rec);
    x_aqev_rec := l_def_aqev_rec;
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
  -- PL/SQL TBL update_row for:AQEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type,
    x_aqev_tbl                     OUT NOCOPY aqev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aqev_tbl.COUNT > 0) THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aqev_rec                     => p_aqev_tbl(i),
          x_aqev_rec                     => x_aqev_tbl(i));
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
  ---------------------------------
  -- delete_row for:OKC_AQERRORS --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqe_rec                      IN aqe_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'AQERRORS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqe_rec                      aqe_rec_type:= p_aqe_rec;
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
    DELETE FROM OKC_AQERRORS
     WHERE ID = l_aqe_rec.id;

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
  -----------------------------------
  -- delete_row for:OKC_AQERRORS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_rec                     IN aqev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aqev_rec                     aqev_rec_type := p_aqev_rec;
    l_aqe_rec                      aqe_rec_type;
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
    migrate(l_aqev_rec, l_aqe_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aqe_rec
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
  -- PL/SQL TBL delete_row for:AQEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aqev_tbl                     IN aqev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aqev_tbl.COUNT > 0) THEN
      i := p_aqev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aqev_rec                     => p_aqev_tbl(i));
        EXIT WHEN (i = p_aqev_tbl.LAST);
        i := p_aqev_tbl.NEXT(i);
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
END OKC_AQE_PVT;

/
