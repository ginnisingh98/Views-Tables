--------------------------------------------------------
--  DDL for Package Body OKC_CRJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CRJ_PVT" AS
/* $Header: OKCSCRJB.pls 120.0 2005/05/26 09:43:45 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*  start added code
*/
G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
G_EXCEPTION_HALT_VALIDATION			exception;
/*  end added code
*/
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
  -- FUNCTION get_rec for: OKC_K_REL_OBJS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crj_rec                      IN crj_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crj_rec_type IS
    CURSOR crj_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            CHR_ID,
            RTY_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
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
      FROM Okc_K_Rel_Objs
     WHERE okc_k_rel_objs.id    = p_id;
    l_crj_pk                       crj_pk_csr%ROWTYPE;
    l_crj_rec                      crj_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN crj_pk_csr (p_crj_rec.id);
    FETCH crj_pk_csr INTO
              l_crj_rec.ID,
              l_crj_rec.CLE_ID,
              l_crj_rec.CHR_ID,
              l_crj_rec.RTY_CODE,
              l_crj_rec.OBJECT1_ID1,
              l_crj_rec.OBJECT1_ID2,
              l_crj_rec.JTOT_OBJECT1_CODE,
              l_crj_rec.OBJECT_VERSION_NUMBER,
              l_crj_rec.CREATED_BY,
              l_crj_rec.CREATION_DATE,
              l_crj_rec.LAST_UPDATED_BY,
              l_crj_rec.LAST_UPDATE_DATE,
              l_crj_rec.LAST_UPDATE_LOGIN,
              l_crj_rec.ATTRIBUTE_CATEGORY,
              l_crj_rec.ATTRIBUTE1,
              l_crj_rec.ATTRIBUTE2,
              l_crj_rec.ATTRIBUTE3,
              l_crj_rec.ATTRIBUTE4,
              l_crj_rec.ATTRIBUTE5,
              l_crj_rec.ATTRIBUTE6,
              l_crj_rec.ATTRIBUTE7,
              l_crj_rec.ATTRIBUTE8,
              l_crj_rec.ATTRIBUTE9,
              l_crj_rec.ATTRIBUTE10,
              l_crj_rec.ATTRIBUTE11,
              l_crj_rec.ATTRIBUTE12,
              l_crj_rec.ATTRIBUTE13,
              l_crj_rec.ATTRIBUTE14,
              l_crj_rec.ATTRIBUTE15;
    x_no_data_found := crj_pk_csr%NOTFOUND;
    CLOSE crj_pk_csr;
    RETURN(l_crj_rec);
  END get_rec;

  FUNCTION get_rec (
    p_crj_rec                      IN crj_rec_type
  ) RETURN crj_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crj_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_REL_OBJS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_crjv_rec                     IN crjv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN crjv_rec_type IS
    CURSOR okc_crjv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CLE_ID,
            CHR_ID,
            RTY_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
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
      FROM Okc_K_Rel_Objs
     WHERE okc_k_rel_objs.id  = p_id;
    l_okc_crjv_pk                  okc_crjv_pk_csr%ROWTYPE;
    l_crjv_rec                     crjv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_crjv_pk_csr (p_crjv_rec.id);
    FETCH okc_crjv_pk_csr INTO
              l_crjv_rec.ID,
              l_crjv_rec.OBJECT_VERSION_NUMBER,
              l_crjv_rec.CLE_ID,
              l_crjv_rec.CHR_ID,
              l_crjv_rec.RTY_CODE,
              l_crjv_rec.OBJECT1_ID1,
              l_crjv_rec.OBJECT1_ID2,
              l_crjv_rec.JTOT_OBJECT1_CODE,
              l_crjv_rec.ATTRIBUTE_CATEGORY,
              l_crjv_rec.ATTRIBUTE1,
              l_crjv_rec.ATTRIBUTE2,
              l_crjv_rec.ATTRIBUTE3,
              l_crjv_rec.ATTRIBUTE4,
              l_crjv_rec.ATTRIBUTE5,
              l_crjv_rec.ATTRIBUTE6,
              l_crjv_rec.ATTRIBUTE7,
              l_crjv_rec.ATTRIBUTE8,
              l_crjv_rec.ATTRIBUTE9,
              l_crjv_rec.ATTRIBUTE10,
              l_crjv_rec.ATTRIBUTE11,
              l_crjv_rec.ATTRIBUTE12,
              l_crjv_rec.ATTRIBUTE13,
              l_crjv_rec.ATTRIBUTE14,
              l_crjv_rec.ATTRIBUTE15,
              l_crjv_rec.CREATED_BY,
              l_crjv_rec.CREATION_DATE,
              l_crjv_rec.LAST_UPDATED_BY,
              l_crjv_rec.LAST_UPDATE_DATE,
              l_crjv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_crjv_pk_csr%NOTFOUND;
    CLOSE okc_crjv_pk_csr;
    RETURN(l_crjv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_crjv_rec                     IN crjv_rec_type
  ) RETURN crjv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_crjv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_REL_OBJS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_crjv_rec	IN crjv_rec_type
  ) RETURN crjv_rec_type IS
    l_crjv_rec	crjv_rec_type := p_crjv_rec;
  BEGIN
    IF (l_crjv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_crjv_rec.object_version_number := NULL;
    END IF;
    IF (l_crjv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_crjv_rec.cle_id := NULL;
    END IF;
    IF (l_crjv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_crjv_rec.chr_id := NULL;
    END IF;
    IF (l_crjv_rec.rty_code = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.rty_code := NULL;
    END IF;
    IF (l_crjv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.object1_id1 := NULL;
    END IF;
    IF (l_crjv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.object1_id2 := NULL;
    END IF;
    IF (l_crjv_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.JTOT_OBJECT1_CODE := NULL;
    END IF;
    IF (l_crjv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute_category := NULL;
    END IF;
    IF (l_crjv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute1 := NULL;
    END IF;
    IF (l_crjv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute2 := NULL;
    END IF;
    IF (l_crjv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute3 := NULL;
    END IF;
    IF (l_crjv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute4 := NULL;
    END IF;
    IF (l_crjv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute5 := NULL;
    END IF;
    IF (l_crjv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute6 := NULL;
    END IF;
    IF (l_crjv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute7 := NULL;
    END IF;
    IF (l_crjv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute8 := NULL;
    END IF;
    IF (l_crjv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute9 := NULL;
    END IF;
    IF (l_crjv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute10 := NULL;
    END IF;
    IF (l_crjv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute11 := NULL;
    END IF;
    IF (l_crjv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute12 := NULL;
    END IF;
    IF (l_crjv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute13 := NULL;
    END IF;
    IF (l_crjv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute14 := NULL;
    END IF;
    IF (l_crjv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_crjv_rec.attribute15 := NULL;
    END IF;
    IF (l_crjv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_crjv_rec.created_by := NULL;
    END IF;
    IF (l_crjv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_crjv_rec.creation_date := NULL;
    END IF;
    IF (l_crjv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_crjv_rec.last_updated_by := NULL;
    END IF;
    IF (l_crjv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_crjv_rec.last_update_date := NULL;
    END IF;
    IF (l_crjv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_crjv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_crjv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- Validate_Attributes
  ---------------------------------------------------------------------------
/*  start added code
*/
  	---------------------------------------------------------------------------
	-- PROCEDURE validate_attribute_id
	---------------------------------------------------------------------------
	PROCEDURE valid_att_id
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_att_id';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		IF	(-- id null
				p_crjv_rec.id	= OKC_API.G_MISS_NUM
			OR	p_crjv_rec.id	IS NULL
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'id'
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF; -- id null
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_att_id;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_att_obj_vers_number
	---------------------------------------------------------------------------
	PROCEDURE valid_att_obj_vers_number
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_att_obj_vers_num';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		IF	(-- object_version_number null
				p_crjv_rec.object_version_number	= OKC_API.G_MISS_NUM
			OR	p_crjv_rec.object_version_number	IS NULL
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'object_version_number'
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF; -- object_version_number null
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_att_obj_vers_number;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_att_rty_code
	---------------------------------------------------------------------------
	PROCEDURE valid_att_rty_code
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_att_rty_code';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;

	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		IF	(-- rel. type code null
				p_crjv_rec.rty_code	= OKC_API.G_MISS_CHAR
			OR	p_crjv_rec.rty_code	IS NULL
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'='
				,p_crjv_rec.rty_code
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF; -- rel. type code null
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_att_rty_code;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_att_k_hdr_and_line
	---------------------------------------------------------------------------
	PROCEDURE valid_att_k_hdr_and_line
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_att_k_hdr_and_line';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		IF	(-- both contract header and line are null
				(-- line null
					p_crjv_rec.cle_id	= OKC_API.G_MISS_NUM
				OR	p_crjv_rec.cle_id	IS NULL
				)
			and
				(-- header null
					p_crjv_rec.chr_id	= OKC_API.G_MISS_NUM
				OR	p_crjv_rec.chr_id	IS NULL
				)
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'chr_id / cle_id'
				)
			;
			x_return_status	:= OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF; -- both contract header and line are null
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_att_k_hdr_and_line;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_att_obj_id
	---------------------------------------------------------------------------
	PROCEDURE valid_att_obj_id
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_att_obj_id';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		IF	(-- rel. type code null
				p_crjv_rec.JTOT_OBJECT1_CODE	= OKC_API.G_MISS_CHAR
			OR	p_crjv_rec.JTOT_OBJECT1_CODE	IS NULL
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'JTOT_OBJECT1_CODE'
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF; -- rel. type code null
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_att_obj_id;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_rec_obj_type
	---------------------------------------------------------------------------
	PROCEDURE valid_rec_obj_type
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS

                CURSOR c_check_okx_khead is
                   SELECT 'x' from okc_k_headers_b
                       where id=p_crjv_rec.object1_id1;

               CURSOR c_check_okx_kline is
                  SELECT 'x' from okc_k_lines_b
                      where id=p_crjv_rec.object1_id1;

		l_api_name		varchar2(300)	:= 'valid_rec_obj_type';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
		l_row_notfound		BOOLEAN		:= TRUE;
                l_found varchar2(1);

	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		/*  start added code
		*/

		/* check object existence
		*/
--Bug 2793261
         if p_crjv_rec.jtot_object1_code='OKX_KHEAD' then

            open   c_check_okx_khead;
            fetch  C_check_okx_khead into l_found;
            close C_check_okx_khead ;

            If l_found = 'x' then
              l_row_notfound := false;
            end if;

        elsif p_crjv_rec.jtot_object1_code='OKX_KLINE' then

           open   c_check_okx_kline;
           fetch  C_check_okx_kline into l_found;
           close C_check_okx_kline ;

           If l_found = 'x' then
             l_row_notfound := false;
           end if;
        else

--End Bug 2793261

		OKC_CRJ_PVT.GET_OBJ_FROM_JTFV
				(
				p_crjv_rec.jtot_object1_code
				,p_crjv_rec.object1_id1
				,p_crjv_rec.object1_id2
				,l_row_notfound
				);
        end if;

		if	(--
				l_row_notfound
			) then
			OKC_API.set_message
				(
				G_APP_NAME
				,G_INVALID_VALUE
				,G_COL_NAME_TOKEN
				,'object'
				,'='
				,p_crjv_rec.jtot_object1_code
				|| ';' || p_crjv_rec.object1_id1
				|| ';' || p_crjv_rec.object1_id2
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		end if; --
		/*  end added code
		*/
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_rec_obj_type;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_rec_rty_code
	---------------------------------------------------------------------------
	PROCEDURE valid_rec_rty_code
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_rec_rty_code';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
		l_row_notfound		BOOLEAN		:= TRUE;

	      --CURSOR fnd_lookup_pk_csr (p_lookup_code        IN VARCHAR2) IS
	      --SELECT
	      --        LOOKUP_TYPE,
	      --        LOOKUP_CODE,
	      --        MEANING,
	      --        DESCRIPTION,
	      --        ENABLED_FLAG,
	      --        START_DATE_ACTIVE,
	      --        END_DATE_ACTIVE
	      --FROM Fnd_Lookups
	      --WHERE fnd_lookups.lookup_code = p_lookup_code;
	      --l_fnd_lookup_pk         fnd_lookup_pk_csr%ROWTYPE;

	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
/*
	      IF (p_crjv_rec.RTY_CODE IS NOT NULL) THEN
	        OPEN fnd_lookup_pk_csr(p_crjv_rec.RTY_CODE);
	        FETCH fnd_lookup_pk_csr INTO l_fnd_lookup_pk;
	        l_row_notfound := fnd_lookup_pk_csr%NOTFOUND;
	        CLOSE fnd_lookup_pk_csr;
	        IF (l_row_notfound) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'rty_code'
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
	        END IF;
	      END IF;
*/
		x_return_status	:= OKC_UTIL.check_lookup_code
					(
					'OKC_REL_OBJ'
					,p_crjv_rec.rty_code
					);
		if	(--
				x_return_status	<> OKC_API.G_RET_STS_SUCCESS
			) then
			OKC_API.set_message
				(
				G_APP_NAME
				,G_INVALID_VALUE
				,G_COL_NAME_TOKEN
				,'rty_code'
				,'='
				,p_crjv_rec.rty_code
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		end if; --

	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_rec_rty_code;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_rec_cle_id
	---------------------------------------------------------------------------
	PROCEDURE valid_rec_cle_id
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_rec_cle_id';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
		l_row_notfound		BOOLEAN		:= TRUE;

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
	              CURRENCY_CODE,
	              LAST_UPDATE_LOGIN
	        FROM Okc_K_Lines_V
	       WHERE okc_k_lines_v.id     = p_id;
	      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;

	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
	      IF (p_crjv_rec.CLE_ID IS NOT NULL)
	      THEN
	        OPEN okc_clev_pk_csr(p_crjv_rec.CLE_ID);
	        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
	        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
	        CLOSE okc_clev_pk_csr;
	        IF (l_row_notfound) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'cle_id'
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
	        END IF;
	      END IF;
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_rec_cle_id;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_rec_chr_id
	---------------------------------------------------------------------------
	PROCEDURE valid_rec_chr_id
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_rec_chr_id';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
		l_row_notfound		BOOLEAN		:= TRUE;

	      CURSOR okc_chrv_pk_csr (p_id                 IN NUMBER) IS
	      SELECT
	              ID,
	              OBJECT_VERSION_NUMBER,
	              SFWT_FLAG,
	              CHR_ID_RESPONSE,
	              CHR_ID_AWARD,
	              STS_CODE,
	              QCL_ID,
	              SCS_CODE,
	              CONTRACT_NUMBER,
	              CURRENCY_CODE,
	              CONTRACT_NUMBER_MODIFIER,
	              ARCHIVED_YN,
	              DELETED_YN,
	              CUST_PO_NUMBER_REQ_YN,
	              PRE_PAY_REQ_YN,
	              CUST_PO_NUMBER,
	              SHORT_DESCRIPTION,
	              COMMENTS,
	              DESCRIPTION,
	              DPAS_RATING,
	              COGNOMEN,
	              TEMPLATE_YN,
	              TEMPLATE_USED,
	              DATE_APPROVED,
	              DATETIME_CANCELLED,
	              AUTO_RENEW_DAYS,
	              DATE_ISSUED,
	              DATETIME_RESPONDED,
	              NON_RESPONSE_REASON,
	              NON_RESPONSE_EXPLAIN,
	              RFP_TYPE,
	              CHR_TYPE,
	              KEEP_ON_MAIL_LIST,
	              SET_ASIDE_REASON,
        	      SET_ASIDE_PERCENT,
	              RESPONSE_COPIES_REQ,
	              DATE_CLOSE_PROJECTED,
	              DATETIME_PROPOSED,
	              DATE_SIGNED,
	              DATE_TERMINATED,
	              DATE_RENEWED,
	              TRN_CODE,
	              START_DATE,
	              END_DATE,
	              AUTHORING_ORG_ID,
	              BUY_OR_SELL,
	              ISSUE_OR_RECEIVE,
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
	        FROM Okc_K_Headers_V
	       WHERE okc_k_headers_v.id   = p_id;
	      l_okc_chrv_pk                  okc_chrv_pk_csr%ROWTYPE;
	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
	      IF (p_crjv_rec.CHR_ID IS NOT NULL) THEN
	        OPEN okc_chrv_pk_csr(p_crjv_rec.CHR_ID);
	        FETCH okc_chrv_pk_csr INTO l_okc_chrv_pk;
	        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
	        CLOSE okc_chrv_pk_csr;
	        IF (l_row_notfound) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,G_REQUIRED_VALUE
				,G_COL_NAME_TOKEN
				,'chr_id'
				)
			;
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
	        END IF;
	      END IF;
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_rec_chr_id;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_rec_unique
	---------------------------------------------------------------------------
	PROCEDURE valid_rec_unique
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_rec_unique';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
		l_row_notfound		BOOLEAN		:= TRUE;

		CURSOR	row_unique
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT         --replaced the SQL for Bug 3094073
			id
		FROM
			okc_k_rel_objs	o
		WHERE	( nvl(o.chr_id, -99) = nvl(p_crjv_rec.chr_id, -99)
			and	(-- lines same (or both null)
					o.cle_id	= p_crjv_rec.cle_id
				or	(-- both null
						o.cle_id		is null
					and	p_crjv_rec.cle_id	is null
					)
				)
			and	o.rty_code		= p_crjv_rec.rty_code
			and	o.jtot_object1_code	= p_crjv_rec.jtot_object1_code
			and	o.object1_id1		= p_crjv_rec.object1_id1
			and	(-- object id same (or both null)
					o.object1_id2	= p_crjv_rec.object1_id2
				or	(-- both null
						o.object1_id2		is null
					and	p_crjv_rec.object1_id2	is null
					)
				)
		   	) ;
		r_row_unique row_unique%rowtype;
	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;

		OPEN row_unique
			(
			p_crjv_rec
			);
	        FETCH	row_unique
		INTO	r_row_unique;
	        l_row_notfound	:= row_unique%NOTFOUND;
	        CLOSE	row_unique;
	        IF	(
				not(l_row_notfound)
			) THEN

			OKC_API.set_message
				(
				G_APP_NAME
				,'not unique row'
				,'@'
				,l_api_name
				);
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF;
	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_rec_unique;

	---------------------------------------------------------------------------
	-- PROCEDURE valid_rec_cardinality
	---------------------------------------------------------------------------
	PROCEDURE valid_rec_cardinality
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			) IS
		l_api_name		varchar2(300)	:= 'valid_rec_cardinality';
		l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
		l_row_notfound		BOOLEAN		:= TRUE;

		CURSOR	row_cardinality_k
			(-- contract negotiates only 1 quote (all rest many)
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			id
		FROM
			okc_k_rel_objs	o
		WHERE	(-- all data same
				(-- headers same (or both null)
					o.chr_id	= p_crjv_rec.chr_id
				or	(-- both null
						o.chr_id		is null
					and	p_crjv_rec.chr_id	is null
					)
				)
			and	(-- lines same (or both null)
					o.cle_id	= p_crjv_rec.cle_id
				or	(-- both null
						o.cle_id		is null
					and	p_crjv_rec.cle_id	is null
					)
				)
			--and	o.rty_code		= p_crjv_rec.rty_code
		     and	o.rty_code		= 'CONTRACTNEGOTIATESQUOTE'
			and	o.jtot_object1_code	= p_crjv_rec.jtot_object1_code
		   	)
		;
		r_row_cardinality_k row_cardinality_k%rowtype;

		CURSOR	row_cardinality_obj
			(-- objects have only 1 rel. of any type except quote negotiates
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			id
		FROM
			okc_k_rel_objs	o
		WHERE	(-- all data same
				o.rty_code		= p_crjv_rec.rty_code
			-- and o.rty_code <> 'CONTRACTNEGOTIATESQUOTE' Bug# 1255862
			and	o.rty_code not in ('CONTRACTNEGOTIATESQUOTE', 'CONTRACTSERVICESORDER')
			and	o.jtot_object1_code	= p_crjv_rec.jtot_object1_code
			and	o.object1_id1		= p_crjv_rec.object1_id1
			and	(-- object id same (or both null)
					o.object1_id2	= p_crjv_rec.object1_id2
				or	(-- both null
						o.object1_id2		is null
					and	p_crjv_rec.object1_id2	is null
					)
				)
		   	)
		;
		r_row_cardinality_obj row_cardinality_obj%rowtype;

	BEGIN
		x_return_status := OKC_API.G_RET_STS_SUCCESS;
		OPEN row_cardinality_k
			(
			p_crjv_rec
			);
	        FETCH	row_cardinality_k
		INTO	r_row_cardinality_k;
	        l_row_notfound	:= row_cardinality_k%NOTFOUND;
	        CLOSE	row_cardinality_k;
	        IF	(
				not(l_row_notfound)
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,'not unique row for contract'
				,'@'
				,l_api_name
				);
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF;
		OPEN row_cardinality_obj
			(
			p_crjv_rec
			);
	        FETCH	row_cardinality_obj
		INTO	r_row_cardinality_obj;
	        l_row_notfound	:= row_cardinality_obj%NOTFOUND;
	        CLOSE	row_cardinality_obj;
	        IF	(
				not(l_row_notfound)
			) THEN
			OKC_API.set_message
				(
				G_APP_NAME
				,'not unique object rel'
				,'@'
				,l_api_name
				);
			x_return_status := OKC_API.G_RET_STS_ERROR;
			raise g_exception_halt_validation;
		END IF;

	EXCEPTION
		WHEN g_exception_halt_validation THEN
			null;
		WHEN OTHERS THEN
			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
			OKC_API.set_message
				(
				G_APP_NAME
				,g_unexpected_error
				,g_sqlcode_token
				,sqlcode
				,g_sqlerrm_token
				,sqlerrm
				,'@'
				,l_api_name
				);
	END valid_rec_cardinality;

/*  end added code
*/
  ----------------------------------------------
  -- Validate_Attributes for:OKC_K_REL_OBJS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes
		(
		p_crjv_rec		IN 		crjv_rec_type
		,p_api			IN		varchar2
		) RETURN VARCHAR2 IS
	l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	x_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	l_api_name		varchar2(300)	:= 'Validate_Attributes';
  BEGIN
/*  start mod code
*/
	valid_att_id
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_att_obj_vers_number
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_att_rty_code
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_att_k_hdr_and_line
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_att_obj_id
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_rec_obj_type
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_rec_rty_code
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_rec_cle_id
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_rec_chr_id
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
	valid_rec_unique
		(
		p_crjv_rec
		,l_api_name
		,l_return_status
		);
	if	(-- error returned
			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
		) then
		if	(-- no error so far
				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
			) then
			x_return_status	:= l_return_status;
		end if; -- no error so far
	end if; -- error returned
--
-- 08/31/00
-- Check for cardinality (Q2K) no longer required
--valid_rec_cardinality
--		(
--		p_crjv_rec
--		,l_api_name
--		,l_return_status
--		);
--	if	(-- error returned
--			l_return_status	<> OKC_API.G_RET_STS_SUCCESS
--		) then
--		if	(-- no error so far
--				x_return_status	<> OKC_API.G_RET_STS_UNEXP_ERROR
--			) then
--			x_return_status	:= l_return_status;
--		end if; -- no error so far
--   end if; -- error returned

/*  end mod code
*/
	RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN crjv_rec_type,
    p_to	OUT NOCOPY crj_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.rty_code := p_from.rty_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
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
    p_from	IN crj_rec_type,
    p_to	OUT NOCOPY crjv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.rty_code := p_from.rty_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
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
  ---------------------------------------
  -- validate_row for:OKC_K_REL_OBJS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_crj_rec                      crj_rec_type;
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
    l_return_status := Validate_Attributes(l_crjv_rec, l_api_name);
    --- If any errors happen abort API
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
  -- PL/SQL TBL validate_row for:CRJV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crjv_tbl.COUNT > 0) THEN
      i := p_crjv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crjv_rec                     => p_crjv_tbl(i));
        EXIT WHEN (i = p_crjv_tbl.LAST);
        i := p_crjv_tbl.NEXT(i);
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
  -- insert_row for:OKC_K_REL_OBJS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crj_rec                      IN crj_rec_type,
    x_crj_rec                      OUT NOCOPY crj_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OBJS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crj_rec                      crj_rec_type := p_crj_rec;
    l_def_crj_rec                  crj_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_REL_OBJS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_crj_rec IN  crj_rec_type,
      x_crj_rec OUT NOCOPY crj_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crj_rec := p_crj_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(5, ' ');
       okc_util.print_trace(5, '>START - OKC_CRJ_PVT.INSERT_ROW -');
    END IF;
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
      p_crj_rec,                         -- IN
      l_crj_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKC_K_REL_OBJS(
        id,
        cle_id,
        chr_id,
        rty_code,
        object1_id1,
        object1_id2,
        JTOT_OBJECT1_CODE,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
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
        l_crj_rec.id,
        l_crj_rec.cle_id,
        l_crj_rec.chr_id,
        l_crj_rec.rty_code,
        l_crj_rec.object1_id1,
        l_crj_rec.object1_id2,
        l_crj_rec.JTOT_OBJECT1_CODE,
        l_crj_rec.object_version_number,
        l_crj_rec.created_by,
        l_crj_rec.creation_date,
        l_crj_rec.last_updated_by,
        l_crj_rec.last_update_date,
        l_crj_rec.last_update_login,
        l_crj_rec.attribute_category,
        l_crj_rec.attribute1,
        l_crj_rec.attribute2,
        l_crj_rec.attribute3,
        l_crj_rec.attribute4,
        l_crj_rec.attribute5,
        l_crj_rec.attribute6,
        l_crj_rec.attribute7,
        l_crj_rec.attribute8,
        l_crj_rec.attribute9,
        l_crj_rec.attribute10,
        l_crj_rec.attribute11,
        l_crj_rec.attribute12,
        l_crj_rec.attribute13,
        l_crj_rec.attribute14,
        l_crj_rec.attribute15);
        IF (l_debug = 'Y') THEN
           okc_util.print_trace(5, 'Insertion into OKC_K_REL_OBJS:');
           okc_util.print_trace(5, '==============================');
           okc_util.print_trace(6, 'Id               = '||l_crj_rec.id);
           okc_util.print_trace(6, 'Contract Id      = '||l_crj_rec.chr_id);
           okc_util.print_trace(6, 'Contract Line Id = '||l_crj_rec.cle_id);
           okc_util.print_trace(6, 'Relation type    = '||l_crj_rec.rty_code);
           okc_util.print_trace(6, 'Quote object     = '||l_crj_rec.jtot_object1_code);
        END IF;
	   IF l_crj_rec.jtot_object1_code = 'OKX_QUOTEHEAD' THEN
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(6, 'Quote id1        = '||l_crj_rec.object1_id1);
              okc_util.print_trace(6, 'Quote id2        = '||l_crj_rec.object1_id2);
           END IF;
        ELSE
           IF (l_debug = 'Y') THEN
              okc_util.print_trace(6, 'Quote Line id1   = '||l_crj_rec.object1_id1);
              okc_util.print_trace(6, 'Quote Line id2   = '||l_crj_rec.object1_id2);
           END IF;
	   END IF;

    -- Set OUT values
    x_crj_rec := l_crj_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(5, '<END - OKC_CRJ_PVT.INSERT_ROW -');
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
  -------------------------------------
  -- insert_row for:OKC_K_REL_OBJS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type;
    l_def_crjv_rec                 crjv_rec_type;
    l_crj_rec                      crj_rec_type;
    lx_crj_rec                     crj_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crjv_rec	IN crjv_rec_type
    ) RETURN crjv_rec_type IS
      l_crjv_rec	crjv_rec_type := p_crjv_rec;
    BEGIN
      l_crjv_rec.CREATION_DATE := SYSDATE;
      l_crjv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_crjv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crjv_rec.LAST_UPDATE_DATE := l_crjv_rec.CREATION_DATE;
      l_crjv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_crjv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_crjv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_REL_OBJS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_crjv_rec IN  crjv_rec_type,
      x_crjv_rec OUT NOCOPY crjv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crjv_rec := p_crjv_rec;
      x_crjv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, ' ');
       okc_util.print_trace(4, '>START - OKC_CRJ_PVT.INSERT_ROW -');
    END IF;
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
    l_crjv_rec := null_out_defaults(p_crjv_rec);
    -- Set primary key value
    l_crjv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_crjv_rec,                        -- IN
      l_def_crjv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(5, 'calling fill_who_columns');
    END IF;
    l_def_crjv_rec := fill_who_columns(l_def_crjv_rec);
    --- Validate all non-missing attributes (Item Level Validation)

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(5, 'calling Validate_Attributes');
       okc_util.print_trace(6, 'l_def_crjv_rec.id:' || l_def_crjv_rec.id);
       okc_util.print_trace(6, 'l_def_crjv_rec.cle_id:' || l_def_crjv_rec.cle_id);
       okc_util.print_trace(6, 'l_def_crjv_rec.chr_id:' || l_def_crjv_rec.chr_id);
       okc_util.print_trace(6, 'l_def_crjv_rec.rty_code:' || l_def_crjv_rec.rty_code);
       okc_util.print_trace(6, 'l_def_crjv_rec.object1_id1:' || l_def_crjv_rec.object1_id1);
       okc_util.print_trace(6, 'l_def_crjv_rec.jtot_object1_id:' || l_def_crjv_rec.jtot_object1_id);
       okc_util.print_trace(6, 'l_def_crjv_rec.jtot_object1_code:' || l_def_crjv_rec.jtot_object1_code);
       okc_util.print_trace(6, '');
    END IF;
    l_return_status := Validate_Attributes(l_def_crjv_rec, l_api_name);

    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(5, 'calling migrate');
    END IF;
    migrate(l_def_crjv_rec, l_crj_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------

    IF (l_debug = 'Y') THEN
       okc_util.print_trace(5, 'before insert');
    END IF;
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crj_rec,
      lx_crj_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crj_rec, l_def_crjv_rec);
    -- Set OUT values
    x_crjv_rec := l_def_crjv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    IF (l_debug = 'Y') THEN
       okc_util.print_trace(4, '<END - OKC_CRJ_PVT.INSERT_ROW -');
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
  ----------------------------------------
  -- PL/SQL TBL insert_row for:CRJV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crjv_tbl.COUNT > 0) THEN
      i := p_crjv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crjv_rec                     => p_crjv_tbl(i),
          x_crjv_rec                     => x_crjv_tbl(i));
        EXIT WHEN (i = p_crjv_tbl.LAST);
        i := p_crjv_tbl.NEXT(i);
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
  -- lock_row for:OKC_K_REL_OBJS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crj_rec                      IN crj_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_crj_rec IN crj_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_REL_OBJS
     WHERE ID = p_crj_rec.id
       AND OBJECT_VERSION_NUMBER = p_crj_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_crj_rec IN crj_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_REL_OBJS
    WHERE ID = p_crj_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OBJS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_REL_OBJS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_REL_OBJS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_crj_rec);
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
      OPEN lchk_csr(p_crj_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_crj_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_crj_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for:OKC_K_REL_OBJS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crj_rec                      crj_rec_type;
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
    migrate(p_crjv_rec, l_crj_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crj_rec
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
  -- PL/SQL TBL lock_row for:CRJV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crjv_tbl.COUNT > 0) THEN
      i := p_crjv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crjv_rec                     => p_crjv_tbl(i));
        EXIT WHEN (i = p_crjv_tbl.LAST);
        i := p_crjv_tbl.NEXT(i);
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
  -- update_row for:OKC_K_REL_OBJS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crj_rec                      IN crj_rec_type,
    x_crj_rec                      OUT NOCOPY crj_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OBJS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crj_rec                      crj_rec_type := p_crj_rec;
    l_def_crj_rec                  crj_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crj_rec	IN crj_rec_type,
      x_crj_rec	OUT NOCOPY crj_rec_type
    ) RETURN VARCHAR2 IS
      l_crj_rec                      crj_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crj_rec := p_crj_rec;
      -- Get current database values
      l_crj_rec := get_rec(p_crj_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_crj_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.id := l_crj_rec.id;
      END IF;
      IF (x_crj_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.cle_id := l_crj_rec.cle_id;
      END IF;
      IF (x_crj_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.chr_id := l_crj_rec.chr_id;
      END IF;
      IF (x_crj_rec.rty_code = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.rty_code := l_crj_rec.rty_code;
      END IF;
      IF (x_crj_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.object1_id1 := l_crj_rec.object1_id1;
      END IF;
      IF (x_crj_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.object1_id2 := l_crj_rec.object1_id2;
      END IF;
      IF (x_crj_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.JTOT_OBJECT1_CODE := l_crj_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_crj_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.object_version_number := l_crj_rec.object_version_number;
      END IF;
      IF (x_crj_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.created_by := l_crj_rec.created_by;
      END IF;
      IF (x_crj_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_crj_rec.creation_date := l_crj_rec.creation_date;
      END IF;
      IF (x_crj_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.last_updated_by := l_crj_rec.last_updated_by;
      END IF;
      IF (x_crj_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_crj_rec.last_update_date := l_crj_rec.last_update_date;
      END IF;
      IF (x_crj_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_crj_rec.last_update_login := l_crj_rec.last_update_login;
      END IF;
      IF (x_crj_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute_category := l_crj_rec.attribute_category;
      END IF;
      IF (x_crj_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute1 := l_crj_rec.attribute1;
      END IF;
      IF (x_crj_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute2 := l_crj_rec.attribute2;
      END IF;
      IF (x_crj_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute3 := l_crj_rec.attribute3;
      END IF;
      IF (x_crj_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute4 := l_crj_rec.attribute4;
      END IF;
      IF (x_crj_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute5 := l_crj_rec.attribute5;
      END IF;
      IF (x_crj_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute6 := l_crj_rec.attribute6;
      END IF;
      IF (x_crj_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute7 := l_crj_rec.attribute7;
      END IF;
      IF (x_crj_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute8 := l_crj_rec.attribute8;
      END IF;
      IF (x_crj_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute9 := l_crj_rec.attribute9;
      END IF;
      IF (x_crj_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute10 := l_crj_rec.attribute10;
      END IF;
      IF (x_crj_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute11 := l_crj_rec.attribute11;
      END IF;
      IF (x_crj_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute12 := l_crj_rec.attribute12;
      END IF;
      IF (x_crj_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute13 := l_crj_rec.attribute13;
      END IF;
      IF (x_crj_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute14 := l_crj_rec.attribute14;
      END IF;
      IF (x_crj_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_crj_rec.attribute15 := l_crj_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_REL_OBJS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_crj_rec IN  crj_rec_type,
      x_crj_rec OUT NOCOPY crj_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crj_rec := p_crj_rec;
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
      p_crj_rec,                         -- IN
      l_crj_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crj_rec, l_def_crj_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_REL_OBJS
    SET CLE_ID = l_def_crj_rec.cle_id,
        CHR_ID = l_def_crj_rec.chr_id,
        RTY_CODE = l_def_crj_rec.rty_code,
        OBJECT1_ID1 = l_def_crj_rec.object1_id1,
        OBJECT1_ID2 = l_def_crj_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_crj_rec.JTOT_OBJECT1_CODE,
        OBJECT_VERSION_NUMBER = l_def_crj_rec.object_version_number,
        CREATED_BY = l_def_crj_rec.created_by,
        CREATION_DATE = l_def_crj_rec.creation_date,
        LAST_UPDATED_BY = l_def_crj_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_crj_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_crj_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_crj_rec.attribute_category,
        ATTRIBUTE1 = l_def_crj_rec.attribute1,
        ATTRIBUTE2 = l_def_crj_rec.attribute2,
        ATTRIBUTE3 = l_def_crj_rec.attribute3,
        ATTRIBUTE4 = l_def_crj_rec.attribute4,
        ATTRIBUTE5 = l_def_crj_rec.attribute5,
        ATTRIBUTE6 = l_def_crj_rec.attribute6,
        ATTRIBUTE7 = l_def_crj_rec.attribute7,
        ATTRIBUTE8 = l_def_crj_rec.attribute8,
        ATTRIBUTE9 = l_def_crj_rec.attribute9,
        ATTRIBUTE10 = l_def_crj_rec.attribute10,
        ATTRIBUTE11 = l_def_crj_rec.attribute11,
        ATTRIBUTE12 = l_def_crj_rec.attribute12,
        ATTRIBUTE13 = l_def_crj_rec.attribute13,
        ATTRIBUTE14 = l_def_crj_rec.attribute14,
        ATTRIBUTE15 = l_def_crj_rec.attribute15
    WHERE ID = l_def_crj_rec.id;

    x_crj_rec := l_def_crj_rec;
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
  -- update_row for:OKC_K_REL_OBJS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_def_crjv_rec                 crjv_rec_type;
    l_crj_rec                      crj_rec_type;
    lx_crj_rec                     crj_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_crjv_rec	IN crjv_rec_type
    ) RETURN crjv_rec_type IS
      l_crjv_rec	crjv_rec_type := p_crjv_rec;
    BEGIN
      l_crjv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_crjv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_crjv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_crjv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_crjv_rec	IN crjv_rec_type,
      x_crjv_rec	OUT NOCOPY crjv_rec_type
    ) RETURN VARCHAR2 IS
      l_crjv_rec                     crjv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crjv_rec := p_crjv_rec;
      -- Get current database values
      l_crjv_rec := get_rec(p_crjv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_crjv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.id := l_crjv_rec.id;
      END IF;
      IF (x_crjv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.object_version_number := l_crjv_rec.object_version_number;
      END IF;
      IF (x_crjv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.cle_id := l_crjv_rec.cle_id;
      END IF;
      IF (x_crjv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.chr_id := l_crjv_rec.chr_id;
      END IF;
      IF (x_crjv_rec.rty_code = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.rty_code := l_crjv_rec.rty_code;
      END IF;
      IF (x_crjv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.object1_id1 := l_crjv_rec.object1_id1;
      END IF;
      IF (x_crjv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.object1_id2 := l_crjv_rec.object1_id2;
      END IF;
      IF (x_crjv_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.JTOT_OBJECT1_CODE := l_crjv_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_crjv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute_category := l_crjv_rec.attribute_category;
      END IF;
      IF (x_crjv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute1 := l_crjv_rec.attribute1;
      END IF;
      IF (x_crjv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute2 := l_crjv_rec.attribute2;
      END IF;
      IF (x_crjv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute3 := l_crjv_rec.attribute3;
      END IF;
      IF (x_crjv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute4 := l_crjv_rec.attribute4;
      END IF;
      IF (x_crjv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute5 := l_crjv_rec.attribute5;
      END IF;
      IF (x_crjv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute6 := l_crjv_rec.attribute6;
      END IF;
      IF (x_crjv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute7 := l_crjv_rec.attribute7;
      END IF;
      IF (x_crjv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute8 := l_crjv_rec.attribute8;
      END IF;
      IF (x_crjv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute9 := l_crjv_rec.attribute9;
      END IF;
      IF (x_crjv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute10 := l_crjv_rec.attribute10;
      END IF;
      IF (x_crjv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute11 := l_crjv_rec.attribute11;
      END IF;
      IF (x_crjv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute12 := l_crjv_rec.attribute12;
      END IF;
      IF (x_crjv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute13 := l_crjv_rec.attribute13;
      END IF;
      IF (x_crjv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute14 := l_crjv_rec.attribute14;
      END IF;
      IF (x_crjv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_crjv_rec.attribute15 := l_crjv_rec.attribute15;
      END IF;
      IF (x_crjv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.created_by := l_crjv_rec.created_by;
      END IF;
      IF (x_crjv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_crjv_rec.creation_date := l_crjv_rec.creation_date;
      END IF;
      IF (x_crjv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.last_updated_by := l_crjv_rec.last_updated_by;
      END IF;
      IF (x_crjv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_crjv_rec.last_update_date := l_crjv_rec.last_update_date;
      END IF;
      IF (x_crjv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_crjv_rec.last_update_login := l_crjv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_REL_OBJS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_crjv_rec IN  crjv_rec_type,
      x_crjv_rec OUT NOCOPY crjv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_crjv_rec := p_crjv_rec;
      x_crjv_rec.OBJECT_VERSION_NUMBER := NVL(x_crjv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_crjv_rec,                        -- IN
      l_crjv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_crjv_rec, l_def_crjv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_crjv_rec := fill_who_columns(l_def_crjv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_crjv_rec, l_api_name);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_crjv_rec, l_crj_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crj_rec,
      lx_crj_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_crj_rec, l_def_crjv_rec);
    x_crjv_rec := l_def_crjv_rec;
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
  -- PL/SQL TBL update_row for:CRJV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crjv_tbl.COUNT > 0) THEN
      i := p_crjv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crjv_rec                     => p_crjv_tbl(i),
          x_crjv_rec                     => x_crjv_tbl(i));
        EXIT WHEN (i = p_crjv_tbl.LAST);
        i := p_crjv_tbl.NEXT(i);
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
  -- delete_row for:OKC_K_REL_OBJS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crj_rec                      IN crj_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OBJS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crj_rec                      crj_rec_type:= p_crj_rec;
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
    DELETE FROM OKC_K_REL_OBJS
     WHERE ID = l_crj_rec.id;

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
  -- delete_row for:OKC_K_REL_OBJS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_crjv_rec                     crjv_rec_type := p_crjv_rec;
    l_crj_rec                      crj_rec_type;
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
    migrate(l_crjv_rec, l_crj_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_crj_rec
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
  -- PL/SQL TBL delete_row for:CRJV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_crjv_tbl.COUNT > 0) THEN
      i := p_crjv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_crjv_rec                     => p_crjv_tbl(i));
        EXIT WHEN (i = p_crjv_tbl.LAST);
        i := p_crjv_tbl.NEXT(i);
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

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: quote_is_renewal
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE quote_is_renewal
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	boolean
		)	is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'quote_is_renewal';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_row_notfound				boolean;
	l_crjv_rec				crjv_rec_type;
	i					number;

/*	CURSOR	renew_rel_for_quote
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			  id
		FROM
			  okc_k_rel_objs	o
		WHERE	(
				o.rty_code		= 'QUOTERENEWSCONTRACT'
			and	o.jtot_object1_code	= 'OKX_QUOTEHEAD'
			and	o.object1_id1		= p_crjv_rec.object1_id1
			and	(
					o.object1_id2	= p_crjv_rec.object1_id2
				or	(
						p_crjv_rec.object1_id2	is null
					and	o.object1_id2		is null
					)
				)
		   	)
	;
quotes are versioned with the same number and the rel probably not updated so use code below not above
*/
	CURSOR	renew_rel_for_quote
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			id
		FROM
			okc_k_rel_objs		o
		WHERE	(-- object with right type and relationship codes
				o.rty_code		= 'QUOTERENEWSCONTRACT'
			and	o.jtot_object1_code	= 'OKX_QUOTEHEAD'
			and	exists	(-- another quote (or same) with same number as object
					select
						1
					from
						okx_quote_headers_v	q1
						,okx_quote_headers_v	q2
					where	(
							(-- q1 is passed in
								q1.id1	= p_crjv_rec.object1_id1
							and	(
									q1.id2	= p_crjv_rec.object1_id2
								or	(
										p_crjv_rec.object1_id2	is null
									and	q1.id2			= '#'
									)
								)
							)
						and	(-- q2 has same num as q1
								q1.quote_number	= q2.quote_number
							)
						and	(-- q2 is the obj rel we're looking for
								q2.id1	= o.object1_id1
							and	(
									q2.id2	= o.object1_id2
								or	(
										o.object1_id2	is null
									and	q2.id2		= '#'
									)
								)
							)
						)
					)
			)
	;
	r_renew_rel_for_quote renew_rel_for_quote%rowtype;

BEGIN
	OKC_API.init_msg_list(p_init_msg_list);
	l_return_status	:= OKC_API.START_ACTIVITY
				(
				substr(l_api_name,1,26)
				,p_init_msg_list
				,'_PUB'
				,x_return_status
				);
	IF	(-- unexpected error
			l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF	(-- standard error
			l_return_status = OKC_API.G_RET_STS_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_crjv_rec	:= null_out_defaults (p_crjv_rec);

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	x_true_false	:= false;

	/* is quote for renewal?
	*/
	IF	(-- quote to search for
			l_crjv_rec.object1_id1	IS NOT NULL
		) THEN
		OPEN renew_rel_for_quote
			(
			l_crjv_rec
			);
	        FETCH	renew_rel_for_quote
		INTO	r_renew_rel_for_quote;
	        l_row_notfound	:= renew_rel_for_quote%NOTFOUND;
	        CLOSE	renew_rel_for_quote;
		x_true_false	:= not(l_row_notfound);
	END IF;
EXCEPTION
	WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
	WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_UNEXP_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		WHEN	OTHERS	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OTHERS'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		OKC_API.set_message
			(
			G_APP_NAME
			,g_unexpected_error
			,g_sqlcode_token
			,sqlcode
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
end quote_is_renewal;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: order_is_renewal
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE order_is_renewal
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	boolean
		)	is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'order_is_renewal';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_row_notfound				boolean;
	l_crjv_rec				crjv_rec_type;
	i					number;

	CURSOR	renew_rel_for_order
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			  id
		FROM
			  okc_k_rel_objs	o
		WHERE	(
				o.rty_code		= 'ORDERRENEWSCONTRACT'
			and	o.jtot_object1_code	= 'OKX_ORDERHEAD'
			and	o.object1_id1		= p_crjv_rec.object1_id1
			and	(
					o.object1_id2	= p_crjv_rec.object1_id2
				or	(
						p_crjv_rec.object1_id2	is null
					and	o.object1_id2		is null
					)
				)
		   	)
	;
	r_renew_rel_for_order renew_rel_for_order%rowtype;

	CURSOR	quote_for_order
		(
			p_crjv_rec	crjv_rec_type
		) IS
	SELECT
		id1
		,id2
	FROM
		okx_quote_headers_v	q
	WHERE
		(
			q.order_id	= p_crjv_rec.object1_id1
/*			q.order_id1	= p_crjv_rec.object1_id1
		and	(
				q.order_id2	= p_crjv_rec.object1_id2
			or	(
					p_crjv_rec.object1_id2	is null
				and	q.order_id2		= '#'
				)
			)
*/	   	)
	;
	r_quote_for_order quote_for_order%rowtype;

BEGIN
	l_return_status	:= OKC_API.START_ACTIVITY
				(
				substr(l_api_name,1,26)
				,p_init_msg_list
				,'_PUB'
				,x_return_status
				);
	IF	(-- unexpected error
			l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF	(-- standard error
			l_return_status = OKC_API.G_RET_STS_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_crjv_rec	:= null_out_defaults (p_crjv_rec);

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	x_true_false	:= false;

	/* is order for renewal?
	*/
	OPEN renew_rel_for_order
		(
		l_crjv_rec
		);
        FETCH	renew_rel_for_order
	INTO	r_renew_rel_for_order;
        l_row_notfound	:= renew_rel_for_order%NOTFOUND;
        CLOSE	renew_rel_for_order;
	x_true_false	:= not(l_row_notfound);

	if	(-- didn't find rel. for order
			l_row_notfound
		) then	-- look for rel. on quote related to order
			-- might not have managed to implement order rels. in time for 11i release
		-- get quote for order
		OPEN quote_for_order
			(
			l_crjv_rec
			);
	        FETCH	quote_for_order
		INTO	r_quote_for_order;
	        l_row_notfound	:= quote_for_order%NOTFOUND;
	        CLOSE	quote_for_order;

		l_crjv_rec.object1_id1 := r_quote_for_order.id1;
		l_crjv_rec.object1_id2 := r_quote_for_order.id2;

	        IF	(-- quote found
				not(l_row_notfound)
			) THEN
			-- is quote for renewal?
			OKC_CRJ_PVT.quote_is_renewal
				(
				p_api_version		=> p_api_version
				,p_init_msg_list	=> p_init_msg_list
				,x_return_status	=> x_return_status
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_crjv_rec		=> l_crjv_rec
				,x_true_false		=> x_true_false
				);
		END IF; -- quote found
	end if; -- didn't find rel. for order

EXCEPTION
	WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
	WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_UNEXP_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		WHEN	OTHERS	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OTHERS'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		OKC_API.set_message
			(
			G_APP_NAME
			,g_unexpected_error
			,g_sqlcode_token
			,sqlcode
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
end order_is_renewal;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: quote_is_subject
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE quote_is_subject
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	boolean
		)	is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'quote_is_subject';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_row_notfound				boolean;
	l_crjv_rec				crjv_rec_type;
	i					number;

	CURSOR	subject_rel_for_quote
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			id
		FROM
			okc_k_rel_objs		o
		WHERE	(-- object with right type and relationship codes
				o.rty_code		= 'QUOTESUBJECTCONTRACT'
			and	o.jtot_object1_code	= 'OKX_QUOTEHEAD'
			and	exists	(-- another quote (or same) with same number as object
					select
						1
					from
						okx_quote_headers_v	q1
						,okx_quote_headers_v	q2
					where	(
							(-- q1 is passed in
								q1.id1	= p_crjv_rec.object1_id1
							and	(
									q1.id2	= p_crjv_rec.object1_id2
								or	(
										p_crjv_rec.object1_id2	is null
									and	q1.id2			= '#'
									)
								)
							)
						and	(-- q2 has same num as q1
								q1.quote_number	= q2.quote_number
							)
						and	(-- q2 is the obj rel we're looking for
								q2.id1	= o.object1_id1
							and	(
									q2.id2	= o.object1_id2
								or	(
										o.object1_id2	is null
									and	q2.id2		= '#'
									)
								)
							)
						)
					)
			)
	;
	r_subject_rel_for_quote subject_rel_for_quote%rowtype;

BEGIN
	l_return_status	:= OKC_API.START_ACTIVITY
				(
				substr(l_api_name,1,26)
				,p_init_msg_list
				,'_PUB'
				,x_return_status
				);
	IF	(-- unexpected error
			l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF	(-- standard error
			l_return_status = OKC_API.G_RET_STS_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_crjv_rec	:= null_out_defaults (p_crjv_rec);

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	x_true_false	:= false;

	/* is quote subject?
	*/
	IF	(-- quote to search for
			l_crjv_rec.object1_id1	IS NOT NULL
		) THEN
		OPEN subject_rel_for_quote
			(
			l_crjv_rec
			);
	        FETCH	subject_rel_for_quote
		INTO	r_subject_rel_for_quote;
	        l_row_notfound	:= subject_rel_for_quote%NOTFOUND;
	        CLOSE	subject_rel_for_quote;
		x_true_false	:= not(l_row_notfound);
	END IF;
EXCEPTION
	WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
	WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_UNEXP_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		WHEN	OTHERS	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OTHERS'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		OKC_API.set_message
			(
			G_APP_NAME
			,g_unexpected_error
			,g_sqlcode_token
			,sqlcode
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
end quote_is_subject;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: order_is_subject
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE order_is_subject
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	boolean
		)	is

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'order_is_subject';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	l_row_notfound				boolean;
	l_crjv_rec				crjv_rec_type;
	i					number;

	CURSOR	subject_rel_for_order
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			  id
		FROM
			  okc_k_rel_objs	o
		WHERE	(
				o.rty_code		= 'ORDERSUBJECTCONTRACT'
			and	o.jtot_object1_code	= 'OKX_ORDERHEAD'
			and	o.object1_id1		= p_crjv_rec.object1_id1
			and	(
					o.object1_id2	= p_crjv_rec.object1_id2
				or	(
						p_crjv_rec.object1_id2	is null
					and	o.object1_id2		is null
					)
				)
		   	)
	;
	r_subject_rel_for_order subject_rel_for_order%rowtype;

	CURSOR	quote_for_order
		(
			p_crjv_rec	crjv_rec_type
		) IS
	SELECT
		id1
		,id2
	FROM
		okx_quote_headers_v	q
	WHERE
		(
			q.order_id	= p_crjv_rec.object1_id1
/*			q.order_id1	= p_crjv_rec.object1_id1
		and	(
				q.order_id2	= p_crjv_rec.object1_id2
			or	(
					p_crjv_rec.object1_id2	is null
				and	q.order_id2		= '#'
				)
			)
*/	   	)
	;
	r_quote_for_order quote_for_order%rowtype;

BEGIN
	l_return_status	:= OKC_API.START_ACTIVITY
				(
				substr(l_api_name,1,26)
				,p_init_msg_list
				,'_PUB'
				,x_return_status
				);
	IF	(-- unexpected error
			l_return_status	= OKC_API.G_RET_STS_UNEXP_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF	(-- standard error
			l_return_status = OKC_API.G_RET_STS_ERROR
		) THEN
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_crjv_rec	:= null_out_defaults (p_crjv_rec);

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	x_true_false	:= false;

	/* is order subject?
	*/
	OPEN subject_rel_for_order
		(
		l_crjv_rec
		);
        FETCH	subject_rel_for_order
	INTO	r_subject_rel_for_order;
        l_row_notfound	:= subject_rel_for_order%NOTFOUND;
        CLOSE	subject_rel_for_order;
	x_true_false	:= not(l_row_notfound);

	if	(-- didn't find rel. for order
			l_row_notfound
		) then	-- look for rel. on quote related to order
			-- might not have managed to implement order rels. in time for 11i release
		-- get quote for order
		OPEN quote_for_order
			(
			l_crjv_rec
			);
	        FETCH	quote_for_order
		INTO	r_quote_for_order;
	        l_row_notfound	:= quote_for_order%NOTFOUND;
	        CLOSE	quote_for_order;

		l_crjv_rec.object1_id1 := r_quote_for_order.id1;
		l_crjv_rec.object1_id2 := r_quote_for_order.id2;

	        IF	(-- quote found
				not(l_row_notfound)
			) THEN
			-- is quote subject?
			OKC_CRJ_PVT.quote_is_subject
				(
				p_api_version		=> p_api_version
				,p_init_msg_list	=> p_init_msg_list
				,x_return_status	=> x_return_status
				,x_msg_count		=> x_msg_count
				,x_msg_data		=> x_msg_data
				,p_crjv_rec		=> l_crjv_rec
				,x_true_false		=> x_true_false
				);
		END IF; -- quote found
	end if; -- didn't find rel. for order

EXCEPTION
	WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
	WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_UNEXP_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		WHEN	OTHERS	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OTHERS'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		OKC_API.set_message
			(
			G_APP_NAME
			,g_unexpected_error
			,g_sqlcode_token
			,sqlcode
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
end order_is_subject;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: quote_contract_is_ordered
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE quote_contract_is_ordered
		(
		p_api_version		IN		NUMBER
		,p_init_msg_list	IN		VARCHAR2
		,x_return_status	OUT	NOCOPY	VARCHAR2
		,x_msg_count		OUT	NOCOPY	NUMBER
		,x_msg_data		OUT	NOCOPY	VARCHAR2
		,p_crjv_rec		IN		crjv_rec_type
		,x_true_false		out	nocopy	boolean
		) IS
	l_api_name		varchar2(30)	:= 'quote_contract_is_ordered';
	l_return_status		varchar2(1)	:= OKC_API.G_RET_STS_SUCCESS;
	l_row_notfound		BOOLEAN		:= TRUE;
	l_crjv_rec				crjv_rec_type;

	CURSOR	renew_rel_for_quote	-- finds contract header if quote is for contract renewal
			(
			p_crjv_rec	crjv_rec_type
			) IS
		SELECT
			id
			,chr_id
		FROM
			okc_k_rel_objs		o
		WHERE	(-- object with right type and relationship codes
				o.rty_code		= 'QUOTERENEWSCONTRACT'
			and	o.jtot_object1_code	= 'OKX_QUOTEHEAD'
			and	exists	(-- another quote (or same) with same number as object
					select
						1
					from
						okx_quote_headers_v	q1
						,okx_quote_headers_v	q2
					where	(
							(-- q1 is passed in
								q1.id1	= p_crjv_rec.object1_id1
							and	(
									q1.id2	= p_crjv_rec.object1_id2
								or	(
										p_crjv_rec.object1_id2	is null
									and	q1.id2			= '#'
									)
								)
							)
						and	(-- q2 has same num as q1
								q1.quote_number	= q2.quote_number
							)
						and	(-- q2 is the obj rel we're looking for
								q2.id1	= o.object1_id1
							and	(
									q2.id2	= o.object1_id2
								or	(
										o.object1_id2	is null
									and	q2.id2		= '#'
									)
								)
							)
						)
					)
			)
	;
	r_renew_rel_for_quote renew_rel_for_quote%rowtype;

	CURSOR	quote_contract_order	-- finds order for contract
		(
		p_crjv_rec		crjv_rec_type
		,r_renew_rel_for_quote	renew_rel_for_quote%rowtype
		) IS
	SELECT
		object1_id1
		,object1_id2
	FROM
		okc_k_rel_objs	o
	WHERE
		(
			o.chr_id	= r_renew_rel_for_quote.chr_id
		and	o.rty_code	= 'CONTRACTSERVICESORDER'
	   	)
	;
	r_quote_contract_order quote_contract_order%rowtype;
BEGIN
	l_crjv_rec	:= null_out_defaults (p_crjv_rec);

	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	x_true_false	:= false;

	IF	(-- quote to search for
			l_crjv_rec.object1_id1	IS NOT NULL
		) THEN
		-- get contract id which quote renews
		OPEN renew_rel_for_quote
			(
			l_crjv_rec
			);
	        FETCH	renew_rel_for_quote
		INTO	r_renew_rel_for_quote;
	        l_row_notfound	:= renew_rel_for_quote%NOTFOUND;
	        CLOSE	renew_rel_for_quote;
		x_true_false	:= not(l_row_notfound);
	END IF;

	IF	(-- quote is renewal
			not(l_row_notfound)
		) THEN
		-- get order for renewed contract
		OPEN quote_contract_order
			(
			l_crjv_rec
			,r_renew_rel_for_quote
			);
	        FETCH	quote_contract_order
		INTO	r_quote_contract_order;
	        l_row_notfound	:= quote_contract_order%NOTFOUND;
	        CLOSE	quote_contract_order;
		x_true_false	:= not(l_row_notfound);
	END IF;
EXCEPTION
	WHEN	OKC_API.G_EXCEPTION_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
	WHEN	OKC_API.G_EXCEPTION_UNEXPECTED_ERROR	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OKC_API.G_RET_STS_UNEXP_ERROR'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		WHEN	OTHERS	THEN
		x_return_status	:= OKC_API.HANDLE_EXCEPTIONS
					(
					l_api_name
					,G_PKG_NAME
					,'OTHERS'
					,x_msg_count
					,x_msg_data
					,'_PUB'
					);
		OKC_API.set_message
			(
			G_APP_NAME
			,g_unexpected_error
			,g_sqlcode_token
			,sqlcode
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
END quote_contract_is_ordered;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: GET_OBJ_FROM_JTFV
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
FUNCTION GET_OBJ_FROM_JTFV
		(
		p_object_code	IN	VARCHAR2
		,p_id1		IN	NUMBER
		,p_id2		IN	VARCHAR2
		) RETURN boolean IS

	l_name				VARCHAR2(255);
	l_id2				varchar2(50);
	l_num				number;
	l_from_table			VARCHAR2(200);
	l_where_clause			VARCHAR2(2000);
	l_sql_stmt			VARCHAR2(500);
	l_not_found			BOOLEAN			:= true;
	l_api_name	CONSTANT	VARCHAR2(30)		:= 'GET_OBJ_FROM_JTFV';

	Cursor	jtfv_csr IS
		SELECT
			FROM_TABLE
			,WHERE_CLAUSE
		FROM
			JTF_OBJECTS_B
		WHERE
			OBJECT_CODE	= p_object_code
	;
	Type	SOURCE_CSR IS	REF	CURSOR;
	c	SOURCE_CSR;

BEGIN
	open jtfv_csr;
	fetch jtfv_csr into
		l_from_table
		,l_where_clause;
	l_not_found	:= jtfv_csr%NOTFOUND;
	close jtfv_csr;

	If	(
			l_not_found
		) Then
		OKC_API.set_message
			(
			G_APP_NAME
			,G_UNEXPECTED_ERROR
			,'not found'
			,'no object=' || p_object_code
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
		return l_not_found;
	End if;

	l_sql_stmt	:=	'SELECT '
				|| ' 1 '
				|| ' FROM '
				|| l_from_table
				|| ' WHERE '
				|| ' ( '
				|| 'ID1 = :id1'
				|| ' AND '
--				|| ' ( '
				|| ' ID2 = :id2'
/*				|| ' or '
				|| ' ( '
				|| ' ID2 = ''#'' '
				|| ' AND '
				|| ' :id2 is null '
				|| ' )'
				|| ' )'
*/				|| ' )';
	If	(
			l_where_clause	is not null
		) Then
		l_sql_stmt	:=	l_sql_stmt
					|| ' AND '
					|| l_where_clause;
	End If;

	l_not_found	:= true;

	l_id2	:= p_id2;
	if	(
			p_id2	is null
		) then
		l_id2	:= '#';
	end if;

        IF (l_debug = 'Y') THEN
           okc_util.print_trace(6, 'l_sql_stmt:' || l_sql_stmt);
           okc_util.print_trace(6, 'p_id1: ' || p_id1 || ', l_id2: ' || l_id2);
           okc_util.print_trace(6, 'Operating Unit = '|| sys_context('OKC_CONTEXT','ORG_ID'));
        END IF;
	open c for l_sql_stmt using p_id1, l_id2;
	fetch c into l_num;
	l_not_found := c%NOTFOUND;
	close c;

	If	(
			l_not_found
		) Then
                IF (l_debug = 'Y') THEN
                   okc_util.print_trace(6, 'temp: not found');
                END IF;
		OKC_API.set_message
			(
			G_APP_NAME
			,G_UNEXPECTED_ERROR
			,'not found'
			,to_char(p_id1) || ' not in ' || l_from_table || ' table'
			,g_sqlerrm_token
			,sqlerrm
			,'@'
			,l_api_name
			);
		return l_not_found;
	End if;

	return l_not_found;
END GET_OBJ_FROM_JTFV;

---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: GET_OBJ_FROM_JTFV
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version 		: 1.0
-- End of comments
PROCEDURE GET_OBJ_FROM_JTFV
		(--
		p_object_code		IN		VARCHAR2
		,p_id1			IN		NUMBER
		,p_id2			IN		VARCHAR2
		,x_true_false		out	nocopy	boolean
		) IS

	l_api_version		CONSTANT	NUMBER			:= 1;
	l_api_name		CONSTANT	VARCHAR2(30)		:= 'GET_OBJ_FROM_JTFV';
	l_return_status				VARCHAR2(1)		:= OKC_API.G_RET_STS_SUCCESS;
	i					number;

	G_UNEXPECTED_ERROR		CONSTANT	varchar2(200) := 'OKC_UNEXPECTED_ERROR';
	G_SQLCODE_TOKEN			CONSTANT	varchar2(200) := 'ERROR_CODE';
	G_SQLERRM_TOKEN			CONSTANT	varchar2(200) := 'ERROR_MESSAGE';
	G_EXCEPTION_HALT_VALIDATION			exception;

BEGIN
	/* check native object
	*/
	x_true_false	:= GET_OBJ_FROM_JTFV
				(
				p_object_code
				,p_id1
				,p_id2
				);
end GET_OBJ_FROM_JTFV;

---------------------------------------------------------------
-- Procedure for mass insert in OKC_K_REL_OBJS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_crjv_tbl crjv_tbl_type) IS
  l_tabsize NUMBER := p_crjv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_rty_code                      OKC_DATATYPES.Var30TabTyp;
  in_object1_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object1_id2                   OKC_DATATYPES.Var200TabTyp;
  in_jtot_object1_code             OKC_DATATYPES.Var30TabTyp;
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
  l_created_by                     NUMBER  := FND_GLOBAL.USER_ID;
  l_creation_date                  DATE    := SYSDATE;
  l_last_updated_by                NUMBER  := FND_GLOBAL.USER_ID;
  l_last_update_date               DATE    := SYSDATE;
  l_last_update_login              NUMBER  := FND_GLOBAL.LOGIN_ID;
  l_id                             NUMBER;
  l_object_version_number          NUMBER  := 1;
BEGIN
  -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

  i := p_crjv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    --IF ID is null or default..generate id
    If (p_crjv_tbl(i).id is null) or (p_crjv_tbl(i).id = OKC_API.G_MISS_NUM) Then
      l_id := get_seq_id;
    Else
      l_id := p_crjv_tbl(i).id;
    End If;
    j:=j+1;
    in_id                       (j) := l_id;
    in_object_version_number    (j) := l_object_version_number;
    in_cle_id                   (j) := p_crjv_tbl(i).cle_id;
    in_chr_id                   (j) := p_crjv_tbl(i).chr_id;
    in_rty_code                 (j) := p_crjv_tbl(i).rty_code;
    in_object1_id1              (j) := p_crjv_tbl(i).object1_id1;
    in_object1_id2              (j) := p_crjv_tbl(i).object1_id2;
    in_jtot_object1_code        (j) := p_crjv_tbl(i).jtot_object1_code;
    in_attribute_category       (j) := p_crjv_tbl(i).attribute_category;
    in_attribute1               (j) := p_crjv_tbl(i).attribute1;
    in_attribute2               (j) := p_crjv_tbl(i).attribute2;
    in_attribute3               (j) := p_crjv_tbl(i).attribute3;
    in_attribute4               (j) := p_crjv_tbl(i).attribute4;
    in_attribute5               (j) := p_crjv_tbl(i).attribute5;
    in_attribute6               (j) := p_crjv_tbl(i).attribute6;
    in_attribute7               (j) := p_crjv_tbl(i).attribute7;
    in_attribute8               (j) := p_crjv_tbl(i).attribute8;
    in_attribute9               (j) := p_crjv_tbl(i).attribute9;
    in_attribute10              (j) := p_crjv_tbl(i).attribute10;
    in_attribute11              (j) := p_crjv_tbl(i).attribute11;
    in_attribute12              (j) := p_crjv_tbl(i).attribute12;
    in_attribute13              (j) := p_crjv_tbl(i).attribute13;
    in_attribute14              (j) := p_crjv_tbl(i).attribute14;
    in_attribute15              (j) := p_crjv_tbl(i).attribute15;
    in_created_by               (j) := l_created_by;
    in_creation_date            (j) := l_creation_date;
    in_last_updated_by          (j) := l_last_updated_by;
    in_last_update_date         (j) := l_last_update_date;
    in_last_update_login        (j) := l_last_update_login;
    i:=p_crjv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_K_REL_OBJS
      (
        id,
        cle_id,
        chr_id,
        rty_code,
        object1_id1,
        object1_id2,
        jtot_object1_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
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
        attribute15
     )
     VALUES (
        in_id(i),
        in_cle_id(i),
        in_chr_id(i),
        in_rty_code(i),
        in_object1_id1(i),
        in_object1_id2(i),
        in_jtot_object1_code(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
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
        in_attribute15(i)
     );

EXCEPTION
  WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  --  RAISE;
END INSERT_ROW_UPG;


END OKC_CRJ_PVT;

/
