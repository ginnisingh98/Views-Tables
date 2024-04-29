--------------------------------------------------------
--  DDL for Package Body OKL_INA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INA_PVT" AS
/* $Header: OKLSINAB.pls 120.5 2007/10/10 11:20:06 zrehman noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
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
  -- FUNCTION get_rec for: OKL_INS_ASSETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_inav_rec                     IN inav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN inav_rec_type IS
    CURSOR okl_inav_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IPY_ID,
            KLE_ID,
            CALCULATED_PREMIUM,
            ASSET_PREMIUM,
            LESSOR_PREMIUM,
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
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_INS_ASSETS
     WHERE OKL_INS_ASSETS.id  = p_id;
    l_okl_inav_pk                  okl_inav_pk_csr%ROWTYPE;
    l_inav_rec                     inav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_inav_pk_csr (p_inav_rec.id);
    FETCH okl_inav_pk_csr INTO
              l_inav_rec.id,
              l_inav_rec.object_version_number,
              l_inav_rec.ipy_id,
              l_inav_rec.kle_id,
              l_inav_rec.calculated_premium,
              l_inav_rec.asset_premium,
              l_inav_rec.lessor_premium,
              l_inav_rec.attribute_category,
              l_inav_rec.attribute1,
              l_inav_rec.attribute2,
              l_inav_rec.attribute3,
              l_inav_rec.attribute4,
              l_inav_rec.attribute5,
              l_inav_rec.attribute6,
              l_inav_rec.attribute7,
              l_inav_rec.attribute8,
              l_inav_rec.attribute9,
              l_inav_rec.attribute10,
              l_inav_rec.attribute11,
              l_inav_rec.attribute12,
              l_inav_rec.attribute13,
              l_inav_rec.attribute14,
              l_inav_rec.attribute15,
              l_inav_rec.org_id,
              l_inav_rec.request_id,
              l_inav_rec.program_application_id,
              l_inav_rec.program_id,
              l_inav_rec.program_update_date,
              l_inav_rec.created_by,
              l_inav_rec.creation_date,
              l_inav_rec.last_updated_by,
              l_inav_rec.last_update_date,
              l_inav_rec.last_update_login;
    x_no_data_found := okl_inav_pk_csr%NOTFOUND;
    CLOSE okl_inav_pk_csr;
    RETURN(l_inav_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_inav_rec                     IN inav_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN inav_rec_type IS
    l_inav_rec                     inav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_inav_rec := get_rec(p_inav_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_inav_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_inav_rec                     IN inav_rec_type
  ) RETURN inav_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_inav_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_ASSETS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ina_rec                      IN ina_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ina_rec_type IS
    CURSOR ina_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            IPY_ID,
            KLE_ID,
            CALCULATED_PREMIUM,
            ASSET_PREMIUM,
            LESSOR_PREMIUM,
            PROGRAM_UPDATE_DATE,
            PROGRAM_ID,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
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
      FROM Okl_Ins_Assets
     WHERE okl_ins_assets.id    = p_id;
    l_ina_pk                       ina_pk_csr%ROWTYPE;
    l_ina_rec                      ina_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ina_pk_csr (p_ina_rec.id);
    FETCH ina_pk_csr INTO
              l_ina_rec.id,
              l_ina_rec.ipy_id,
              l_ina_rec.kle_id,
              l_ina_rec.calculated_premium,
              l_ina_rec.asset_premium,
              l_ina_rec.lessor_premium,
              l_ina_rec.program_update_date,
              l_ina_rec.program_id,
              l_ina_rec.object_version_number,
              l_ina_rec.request_id,
              l_ina_rec.program_application_id,
              l_ina_rec.attribute_category,
              l_ina_rec.attribute1,
              l_ina_rec.attribute2,
              l_ina_rec.attribute3,
              l_ina_rec.attribute4,
              l_ina_rec.attribute5,
              l_ina_rec.attribute6,
              l_ina_rec.attribute7,
              l_ina_rec.attribute8,
              l_ina_rec.attribute9,
              l_ina_rec.attribute10,
              l_ina_rec.attribute11,
              l_ina_rec.attribute12,
              l_ina_rec.attribute13,
              l_ina_rec.attribute14,
              l_ina_rec.attribute15,
              l_ina_rec.org_id,
              l_ina_rec.created_by,
              l_ina_rec.creation_date,
              l_ina_rec.last_updated_by,
              l_ina_rec.last_update_date,
              l_ina_rec.last_update_login;
    x_no_data_found := ina_pk_csr%NOTFOUND;
    CLOSE ina_pk_csr;
    RETURN(l_ina_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ina_rec                      IN ina_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ina_rec_type IS
    l_ina_rec                      ina_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ina_rec := get_rec(p_ina_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ina_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ina_rec                      IN ina_rec_type
  ) RETURN ina_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ina_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INS_ASSETS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_inav_rec   IN inav_rec_type
  ) RETURN inav_rec_type IS
    l_inav_rec                     inav_rec_type := p_inav_rec;
  BEGIN
    IF (l_inav_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.id := NULL;
    END IF;
    IF (l_inav_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.object_version_number := NULL;
    END IF;
    IF (l_inav_rec.ipy_id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.ipy_id := NULL;
    END IF;
    IF (l_inav_rec.kle_id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.kle_id := NULL;
    END IF;
    IF (l_inav_rec.calculated_premium = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.calculated_premium := NULL;
    END IF;
    IF (l_inav_rec.asset_premium = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.asset_premium := NULL;
    END IF;
    IF (l_inav_rec.lessor_premium = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.lessor_premium := NULL;
    END IF;
    IF (l_inav_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute_category := NULL;
    END IF;
    IF (l_inav_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute1 := NULL;
    END IF;
    IF (l_inav_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute2 := NULL;
    END IF;
    IF (l_inav_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute3 := NULL;
    END IF;
    IF (l_inav_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute4 := NULL;
    END IF;
    IF (l_inav_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute5 := NULL;
    END IF;
    IF (l_inav_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute6 := NULL;
    END IF;
    IF (l_inav_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute7 := NULL;
    END IF;
    IF (l_inav_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute8 := NULL;
    END IF;
    IF (l_inav_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute9 := NULL;
    END IF;
    IF (l_inav_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute10 := NULL;
    END IF;
    IF (l_inav_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute11 := NULL;
    END IF;
    IF (l_inav_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute12 := NULL;
    END IF;
    IF (l_inav_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute13 := NULL;
    END IF;
    IF (l_inav_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute14 := NULL;
    END IF;
    IF (l_inav_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_inav_rec.attribute15 := NULL;
    END IF;
    IF (l_inav_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.org_id := NULL;
    END IF;
    IF (l_inav_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.request_id := NULL;
    END IF;
    IF (l_inav_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.program_application_id := NULL;
    END IF;
    IF (l_inav_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.program_id := NULL;
    END IF;
    IF (l_inav_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_inav_rec.program_update_date := NULL;
    END IF;
    IF (l_inav_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.created_by := NULL;
    END IF;
    IF (l_inav_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_inav_rec.creation_date := NULL;
    END IF;
    IF (l_inav_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.last_updated_by := NULL;
    END IF;
    IF (l_inav_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_inav_rec.last_update_date := NULL;
    END IF;
    IF (l_inav_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_inav_rec.last_update_login := NULL;
    END IF;
    RETURN(l_inav_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
-- Start of Comments
      --
      -- Procedure Name : validate_id
      -- Description    : It validates null value of id
      -- Business Rules :
      -- Parameter      :
      -- Version        : 1.0
      -- End of comments
      procedure validate_id (p_inav_rec IN  inav_rec_type, x_return_status OUT NOCOPY VARCHAR2 ) IS
      	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          BEGIN
    		-- initialize return status
    		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
    		-- data is required
    		IF ( ( p_inav_rec.id is null)  or  (p_inav_rec.id = OKC_API.G_MISS_NUM)) THEN
    			OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
    			-- notify caller of an error
    			x_return_status := OKC_API.G_RET_STS_ERROR;
    		 END IF;
          EXCEPTION
          	WHEN OTHERS THEN
                  	-- store SQL error message on message stack for caller
                  	 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
          		-- notify caller of an UNEXPECTED error
          		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       End validate_id ;
      -- End validate_Id
      -- Start of Comments
      --
      -- Procedure Name : validate_object_version_number
      -- Description    : It validates null value of object_version_number
      -- Business Rules :
      -- Parameter      :
      -- Version        : 1.0
      -- End of comments
      procedure validate_object_version_number ( p_inav_rec IN  inav_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
      	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          BEGIN
      		-- initialize return status
      		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
      		-- data is required
      		IF ( ( p_inav_rec.object_version_number is null)  OR  (p_inav_rec.object_version_number = OKC_API.G_MISS_NUM)) THEN
      			OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      			-- notify caller of an error
      			x_return_status := OKC_API.G_RET_STS_ERROR;
      		 END IF;
           EXCEPTION
            	WHEN OTHERS THEN
                  	-- store SQL error message on message stack for caller
                     	OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
            		-- notify caller of an UNEXPECTED error
            		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      End validate_object_version_number ;
      -- End validate_object_version_number
      -- Start of Comments
      --
      -- Procedure Name : validate_ipy_id (policy id)
      -- Description    : It validates null value and referntial integrity for ipy_id
      -- Business Rules :
      -- Parameter      :
      -- Version        : 1.0
      -- End of comment
      procedure validate_ipy_id ( p_inav_rec IN  inav_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
        	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        	l_dummy_var		VARCHAR2(1) := '?' ;
        	CURSOR  l_ipy_csr IS
        	 SELECT 'x'
        	 FROM OKL_INS_POLICIES_V
        	 WHERE ID = p_inav_rec.ipy_id	;
  	BEGIN
  		-- initialize return status
  		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
  		-- data is required
  		IF ( ( p_inav_rec.ipy_id is null)  OR  (p_inav_rec.ipy_id = OKC_API.G_MISS_NUM)) THEN
  			OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Policy Number');
  			-- notify caller of an error
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		ELSE
  			-- enforce foreign key
  			OPEN   l_ipy_csr ;
  			FETCH l_ipy_csr into l_dummy_var ;
  			CLOSE l_ipy_csr ;
  			-- still set to default means data was not found
  			IF ( l_dummy_var = '?' ) THEN
  			    OKC_API.set_message(g_app_name,
  						G_NO_PARENT_RECORD,
  						g_col_name_token,
  						'ipy_id',
  						g_child_table_token ,
  						'OKL_INS_ASSETS' ,
  						g_parent_table_token ,
  						'OKL_INS_POLICIES_V');
  			     x_return_status := OKC_API.G_RET_STS_ERROR;
  			END IF;
  		END IF;
  	EXCEPTION
  		WHEN OTHERS THEN
  			-- store SQL error message on message stack for caller
  			OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
  			-- notify caller of an UNEXPECTED error
  			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  			-- verify that cursor was closed
  			IF l_ipy_csr%ISOPEN then
  				CLOSE l_ipy_csr;
        			END IF;
       End validate_ipy_id ;
       -- End validate_ipy_id
     -- Start of Comments
     --
     -- Procedure Name : validate_kle_id
     -- Description    : It validates for null value for kle_id (Contract Header ID)
     -- Business Rules :
     -- Parameter      :
     -- Version        : 1.0
     -- End of comments
     procedure validate_kle_id ( p_inav_rec IN  inav_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
     	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     	l_dummy_var		VARCHAR2(1) := '?' ;
      	CURSOR  l_kle_csr IS
      	 SELECT 'x'
      	 FROM OKL_K_LINES_V
      	 WHERE id = p_inav_rec.kle_id ;
  	BEGIN
  		-- initialize return status
  		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
  		IF ( ( p_inav_rec.kle_id is null)  OR  (p_inav_rec.kle_id = OKC_API.G_MISS_NUM)) THEN
		  	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Contract Line'); --Fix for 3745151 corrected spelling
		  			-- notify caller of an error
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		ELSE
  			-- enforce foreign key
  			OPEN   l_kle_csr ;
  			FETCH l_kle_csr into l_dummy_var ;
  			CLOSE l_kle_csr ;
  			-- still set to default means data was not found
  			IF ( l_dummy_var = '?' ) THEN
  			    OKC_API.set_message(g_app_name,
  						g_no_parent_record,
  						g_col_name_token,
  						'kle_id',
  						g_child_table_token ,
  						'OKL_INS_ASSETS' ,
  						g_parent_table_token ,
  						'OKL_K_LINES_V');
  			     x_return_status := OKC_API.G_RET_STS_ERROR;
  			END IF;
  		 END IF;
  	  EXCEPTION
  		WHEN OTHERS THEN
  			-- store SQL error message on message stack for caller
  			OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
  			-- notify caller of an UNEXPECTED error
  			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  			-- verify that cursor was closed
  			IF l_kle_csr%ISOPEN then
  				CLOSE l_kle_csr;
        			END IF;
     End   validate_kle_id ;
     -- End validate_kle_id
    -- Start of Comments
    --
    -- Procedure Name : validate_asset_premium
    -- Description    : It validates for asset_premium sign(premium)
    -- Business Rules :
    -- Parameter      :
    -- Version        : 1.0
    -- End of comments
    procedure validate_asset_premium ( p_inav_rec IN  inav_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
    	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    	l_dummy_var		VARCHAR2(1) := '?' ;
  	BEGIN
  		-- initialize return status
  		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
  		IF ( ( p_inav_rec.asset_premium is null)  OR  (p_inav_rec.asset_premium = OKC_API.G_MISS_NUM)) THEN
				  	OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Contract Lime');
				  			-- notify caller of an error
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		ELSE
  			IF (sign(p_inav_rec.asset_premium) <> 1) THEN
  	            		OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
  						p_msg_name		=> g_invalid_value,
  						p_token1		=> g_col_name_token,
  						p_token1_value	=> 'Asset Premium');
  				-- notify caller of an error
          			x_return_status := OKC_API.G_RET_STS_ERROR;
  	        	END IF ;
  		 END IF;
  	EXCEPTION
  		WHEN OTHERS THEN
  			-- store SQL error message on message stack for caller
  			OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
  			-- notify caller of an UNEXPECTED error
  			x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    End validate_asset_premium ;
    -- End validate_asset_premium
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_created_by
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       PROCEDURE  validate_created_by(x_return_status OUT NOCOPY VARCHAR2,p_inav_rec IN  inav_rec_type ) IS
         BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;
           --data is required
           IF p_inav_rec.created_by = Okc_Api.G_MISS_NUM OR
              p_inav_rec.created_by IS NULL
           THEN
             Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_REQUIRED_VALUE,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Created By');
             --Notify caller of  an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
             END IF;
           EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
    	    Okc_Api.set_message(p_app_name => G_APP_NAME,
    				    p_msg_name => G_UNEXPECTED_ERROR,
    				    p_token1 => G_SQLCODE_TOKEN,
    				    p_token1_value => SQLCODE,
    				    p_token2 => G_SQLERRM_TOKEN,
    				    p_token2_value => SQLERRM
    			);
                -- Notify the caller of an unexpected error
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END validate_created_by;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_creation_date
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       PROCEDURE  validate_creation_date(x_return_status OUT NOCOPY VARCHAR2,p_inav_rec IN inav_rec_type ) IS
         BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;
           --data is required
           IF p_inav_rec.creation_date = Okc_Api.G_MISS_DATE OR
              p_inav_rec.creation_date IS NULL
           THEN
             Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_REQUIRED_VALUE,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Creation Date');
             --Notify caller of  an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
           EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
    	    Okc_Api.set_message(p_app_name => G_APP_NAME,
    				    p_msg_name => G_UNEXPECTED_ERROR,
    				    p_token1 => G_SQLCODE_TOKEN,
    				    p_token1_value => SQLCODE,
    				    p_token2 => G_SQLERRM_TOKEN,
    				    p_token2_value => SQLERRM
    			);
                -- Notify the caller of an unexpected error
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END validate_creation_date;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_last_updated_by
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       PROCEDURE  validate_last_updated_by(x_return_status OUT NOCOPY VARCHAR2,p_inav_rec IN inav_rec_type ) IS
        BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;
           --data is required
           IF p_inav_rec.last_updated_by = Okc_Api.G_MISS_NUM OR
              p_inav_rec.last_updated_by IS NULL
           THEN
             Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_REQUIRED_VALUE,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Last Updated By');
             --Notify caller of  an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
          EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
    	    Okc_Api.set_message(p_app_name => G_APP_NAME,
    				    p_msg_name => G_UNEXPECTED_ERROR,
    				    p_token1 => G_SQLCODE_TOKEN,
    				    p_token1_value => SQLCODE,
    				    p_token2 => G_SQLERRM_TOKEN,
    				    p_token2_value => SQLERRM
    			);
                -- Notify the caller of an unexpected error
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END validate_last_updated_by;
    ---------------------------------------------------------------------------
    -- Start of comments
    --
    -- Procedure Name	: validate_last_update_date
    -- Description		:
    -- Business Rules	:
    -- Parameters		:
    -- Version		: 1.0
    -- End of Comments
    ---------------------------------------------------------------------------
       PROCEDURE  validate_last_update_date(x_return_status OUT NOCOPY VARCHAR2,p_inav_rec IN inav_rec_type ) IS
         BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;
           --data is required
           IF p_inav_rec.last_update_date = Okc_Api.G_MISS_DATE OR
              p_inav_rec.last_update_date IS NULL
           THEN
             Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_REQUIRED_VALUE,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Last Update Date');
             --Notify caller of  an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;
          EXCEPTION
              WHEN OTHERS THEN
                -- store SQL error  message on message stack for caller
    	    Okc_Api.set_message(p_app_name => G_APP_NAME,
    				    p_msg_name => G_UNEXPECTED_ERROR,
    				    p_token1 => G_SQLCODE_TOKEN,
    				    p_token1_value => SQLCODE,
    				    p_token2 => G_SQLERRM_TOKEN,
    				    p_token2_value => SQLERRM
    			);
                -- Notify the caller of an unexpected error
                x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END validate_last_update_date;
        ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_INS_ASSETS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_inav_rec                     IN inav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
validate_id(p_inav_rec, l_return_status);
  		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
  				x_return_status := l_return_status;
  				RAISE G_EXCEPTION_HALT_VALIDATION;
  			ELSE
  				x_return_status := l_return_status;   -- record that there was an error
  			END IF;
  		END IF;
  	validate_object_version_number(p_inav_rec, l_return_status);
  		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
  				x_return_status := l_return_status;
  				RAISE G_EXCEPTION_HALT_VALIDATION;
  			ELSE
  				x_return_status := l_return_status;   -- record that there was an error
  			END IF;
  		END IF;
  	validate_ipy_id(p_inav_rec, l_return_status);
  		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
  				x_return_status := l_return_status;
  				RAISE G_EXCEPTION_HALT_VALIDATION;
  			ELSE
  				x_return_status := l_return_status;   -- record that there was an error
  			END IF;
  		END IF;
  	validate_kle_id(p_inav_rec, l_return_status);
  		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
  				x_return_status := l_return_status;
  				RAISE G_EXCEPTION_HALT_VALIDATION;
  			ELSE
  				x_return_status := l_return_status;   -- record that there was an error
  			END IF;
  		END IF;
  	validate_asset_premium(p_inav_rec, l_return_status);
  		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
  			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
  				x_return_status := l_return_status;
  				RAISE G_EXCEPTION_HALT_VALIDATION;
  			ELSE
  				x_return_status := l_return_status;   -- record that there was an error
  			END IF;
  		END IF;
  		-- call inr created_by column_level validation
		    validate_created_by(x_return_status => l_return_status,
		                            p_inav_rec      => p_inav_rec);
		    -- store the highest degree of error
		    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		            x_return_status := l_return_status;
		            RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status;   -- record that there was an error
		          END IF;
		    END IF;
		    -- call inr creation_date column_level validation
		    validate_creation_date(x_return_status => l_return_status,
		                               p_inav_rec      => p_inav_rec);
		    -- store the highest degree of error
		    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		            x_return_status := l_return_status;
		            RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status;   -- record that there was an error
		          END IF;
		    END IF;
		    -- call inr last_updated_by column_level validation
		    validate_last_updated_by(x_return_status => l_return_status,
		                                 p_inav_rec      => p_inav_rec);
		    -- store the highest degree of error
		    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		            x_return_status := l_return_status;
		            RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status;   -- record that there was an error
		          END IF;
		    END IF;
		    -- call inr last_update_date column_level validation
		    validate_last_update_date(x_return_status => l_return_status,
		                                  p_inav_rec      => p_inav_rec);
		    -- store the highest degree of error
		    IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		          IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		            x_return_status := l_return_status;
		            RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status;   -- record that there was an error
		          END IF;
		    END IF;
		    RETURN(x_return_status);
		    EXCEPTION
		        WHEN G_EXCEPTION_HALT_VALIDATION THEN
		          RETURN(x_return_status);
		        WHEN OTHERS THEN
		          -- store SQL error message on message stack for caller
		          Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
		          -- notify caller of an UNEXPECTED error
		          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
		      RETURN(x_return_status);
       END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------

      ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_inav_rec IN inav_rec_type,
      p_db_inav_rec IN inav_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN

      RETURN (l_return_status);
    END validate_foreign_keys;

  ------------------------------------------
  -- Validate Record for:OKL_INS_ASSETS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_inav_rec IN inav_rec_type,
    p_db_inav_rec IN inav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
    l_return_status := validate_foreign_keys(p_inav_rec, p_db_inav_rec);
    RETURN (l_return_status);
  END Validate_Record;



  FUNCTION Validate_Record (
    p_inav_rec IN inav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_inav_rec                  inav_rec_type := get_rec(p_inav_rec);
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN inav_rec_type,
    p_to   IN OUT NOCOPY ina_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ipy_id := p_from.ipy_id;
    p_to.kle_id := p_from.kle_id;
    p_to.calculated_premium := p_from.calculated_premium;
    p_to.asset_premium := p_from.asset_premium;
    p_to.lessor_premium := p_from.lessor_premium;
    p_to.program_update_date := p_from.program_update_date;
    p_to.program_id := p_from.program_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
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
    p_from IN ina_rec_type,
    p_to   IN OUT NOCOPY inav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.ipy_id := p_from.ipy_id;
    p_to.kle_id := p_from.kle_id;
    p_to.calculated_premium := p_from.calculated_premium;
    p_to.asset_premium := p_from.asset_premium;
    p_to.lessor_premium := p_from.lessor_premium;
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
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_INS_ASSETS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_rec                     IN inav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_inav_rec                     inav_rec_type := p_inav_rec;
    l_ina_rec                      ina_rec_type;
    l_ina_rec                      ina_rec_type;
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
    l_return_status := Validate_Attributes(l_inav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_inav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  --------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_INS_ASSETS_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      i := p_inav_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_inav_rec                     => p_inav_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_inav_tbl.LAST);
        i := p_inav_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  --------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_INS_ASSETS_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_inav_tbl                     => p_inav_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_INS_ASSETS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ina_rec                      IN ina_rec_type,
    x_ina_rec                      OUT NOCOPY ina_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ina_rec                      ina_rec_type := p_ina_rec;
    l_def_ina_rec                  ina_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_INS_ASSETS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ina_rec IN ina_rec_type,
      x_ina_rec OUT NOCOPY ina_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ina_rec := p_ina_rec;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_ina_rec,                         -- IN
      l_ina_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INS_ASSETS(
      id,
      ipy_id,
      kle_id,
      calculated_premium,
      asset_premium,
      lessor_premium,
      program_update_date,
      program_id,
      object_version_number,
      request_id,
      program_application_id,
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
      l_ina_rec.id,
      l_ina_rec.ipy_id,
      l_ina_rec.kle_id,
      l_ina_rec.calculated_premium,
      l_ina_rec.asset_premium,
      l_ina_rec.lessor_premium,
      l_ina_rec.program_update_date,
      l_ina_rec.program_id,
      l_ina_rec.object_version_number,
      l_ina_rec.request_id,
      l_ina_rec.program_application_id,
      l_ina_rec.attribute_category,
      l_ina_rec.attribute1,
      l_ina_rec.attribute2,
      l_ina_rec.attribute3,
      l_ina_rec.attribute4,
      l_ina_rec.attribute5,
      l_ina_rec.attribute6,
      l_ina_rec.attribute7,
      l_ina_rec.attribute8,
      l_ina_rec.attribute9,
      l_ina_rec.attribute10,
      l_ina_rec.attribute11,
      l_ina_rec.attribute12,
      l_ina_rec.attribute13,
      l_ina_rec.attribute14,
      l_ina_rec.attribute15,
      l_ina_rec.org_id,
      l_ina_rec.created_by,
      l_ina_rec.creation_date,
      l_ina_rec.last_updated_by,
      l_ina_rec.last_update_date,
      l_ina_rec.last_update_login);
    -- Set OUT values
    x_ina_rec := l_ina_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  --------------------------------------
  -- insert_row for :OKL_INS_ASSETS_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_rec                     IN inav_rec_type,
    x_inav_rec                     OUT NOCOPY inav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_inav_rec                     inav_rec_type := p_inav_rec;
    l_def_inav_rec                 inav_rec_type;
    l_ina_rec                      ina_rec_type;
    lx_ina_rec                     ina_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_inav_rec IN inav_rec_type
    ) RETURN inav_rec_type IS
      l_inav_rec inav_rec_type := p_inav_rec;
    BEGIN
      l_inav_rec.CREATION_DATE := SYSDATE;
      l_inav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_inav_rec.LAST_UPDATE_DATE := l_inav_rec.CREATION_DATE;
      l_inav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_inav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_inav_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_INS_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_inav_rec IN inav_rec_type,
      x_inav_rec OUT NOCOPY inav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_org_id NUMBER;
    BEGIN
      x_inav_rec := p_inav_rec;
      x_inav_rec.OBJECT_VERSION_NUMBER := 1;
          SELECT NVL(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),p_inav_rec.request_id),
      	                               NVL(DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),p_inav_rec.program_application_id),
      	                               NVL(DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),p_inav_rec.program_id),
      	                               DECODE(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,p_inav_rec.program_update_date,SYSDATE),
      	                               MO_GLOBAL.GET_CURRENT_ORG_ID()
      	                               INTO x_inav_rec.request_id,
      	                                    x_inav_rec.program_application_id,
      	                                    x_inav_rec.program_id,
      	                                    x_inav_rec.program_update_date,
                                    l_org_id FROM dual; -- Change by zrehman for Bug#6363652 9-Oct-2007
      IF(x_inav_rec.org_id IS NULL OR x_inav_rec.org_id = OKC_API.G_MISS_NUM) THEN
        x_inav_rec.org_id := l_org_id;
      END IF;

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
    l_inav_rec := null_out_defaults(p_inav_rec);
    -- Set primary key value
    l_inav_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_inav_rec,                        -- IN
      l_def_inav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_inav_rec := fill_who_columns(l_def_inav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_inav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_inav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_inav_rec, l_ina_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ina_rec,
      lx_ina_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ina_rec, l_def_inav_rec);
    -- Set OUT values
    x_inav_rec := l_def_inav_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:INAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    x_inav_tbl                     OUT NOCOPY inav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      i := p_inav_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_inav_rec                     => p_inav_tbl(i),
            x_inav_rec                     => x_inav_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_inav_tbl.LAST);
        i := p_inav_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:INAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    x_inav_tbl                     OUT NOCOPY inav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_inav_tbl                     => p_inav_tbl,
        x_inav_tbl                     => x_inav_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_INS_ASSETS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ina_rec                      IN ina_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ina_rec IN ina_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_ASSETS
     WHERE ID = p_ina_rec.id
       AND OBJECT_VERSION_NUMBER = p_ina_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_ina_rec IN ina_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_ASSETS
     WHERE ID = p_ina_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_INS_ASSETS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_INS_ASSETS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_ina_rec);
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
      OPEN lchk_csr(p_ina_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ina_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ina_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ------------------------------------
  -- lock_row for: OKL_INS_ASSETS_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_rec                     IN inav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ina_rec                      ina_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_inav_rec, l_ina_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ina_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:INAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      i := p_inav_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_inav_rec                     => p_inav_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_inav_tbl.LAST);
        i := p_inav_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:INAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_inav_tbl                     => p_inav_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INS_ASSETS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ina_rec                      IN ina_rec_type,
    x_ina_rec                      OUT NOCOPY ina_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ina_rec                      ina_rec_type := p_ina_rec;
    l_def_ina_rec                  ina_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ina_rec IN ina_rec_type,
      x_ina_rec OUT NOCOPY ina_rec_type
    ) RETURN VARCHAR2 IS
      l_ina_rec                      ina_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ina_rec := p_ina_rec;
      -- Get current database values
      l_ina_rec := get_rec(p_ina_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ina_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.id := l_ina_rec.id;
        END IF;
        IF (x_ina_rec.ipy_id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.ipy_id := l_ina_rec.ipy_id;
        END IF;
        IF (x_ina_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.kle_id := l_ina_rec.kle_id;
        END IF;
        IF (x_ina_rec.calculated_premium = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.calculated_premium := l_ina_rec.calculated_premium;
        END IF;
        IF (x_ina_rec.asset_premium = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.asset_premium := l_ina_rec.asset_premium;
        END IF;
        IF (x_ina_rec.lessor_premium = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.lessor_premium := l_ina_rec.lessor_premium;
        END IF;
        IF (x_ina_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ina_rec.program_update_date := l_ina_rec.program_update_date;
        END IF;
        IF (x_ina_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.program_id := l_ina_rec.program_id;
        END IF;
        IF (x_ina_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.object_version_number := l_ina_rec.object_version_number;
        END IF;
        IF (x_ina_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.request_id := l_ina_rec.request_id;
        END IF;
        IF (x_ina_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.program_application_id := l_ina_rec.program_application_id;
        END IF;
        IF (x_ina_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute_category := l_ina_rec.attribute_category;
        END IF;
        IF (x_ina_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute1 := l_ina_rec.attribute1;
        END IF;
        IF (x_ina_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute2 := l_ina_rec.attribute2;
        END IF;
        IF (x_ina_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute3 := l_ina_rec.attribute3;
        END IF;
        IF (x_ina_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute4 := l_ina_rec.attribute4;
        END IF;
        IF (x_ina_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute5 := l_ina_rec.attribute5;
        END IF;
        IF (x_ina_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute6 := l_ina_rec.attribute6;
        END IF;
        IF (x_ina_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute7 := l_ina_rec.attribute7;
        END IF;
        IF (x_ina_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute8 := l_ina_rec.attribute8;
        END IF;
        IF (x_ina_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute9 := l_ina_rec.attribute9;
        END IF;
        IF (x_ina_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute10 := l_ina_rec.attribute10;
        END IF;
        IF (x_ina_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute11 := l_ina_rec.attribute11;
        END IF;
        IF (x_ina_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute12 := l_ina_rec.attribute12;
        END IF;
        IF (x_ina_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute13 := l_ina_rec.attribute13;
        END IF;
        IF (x_ina_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute14 := l_ina_rec.attribute14;
        END IF;
        IF (x_ina_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_ina_rec.attribute15 := l_ina_rec.attribute15;
        END IF;
        IF (x_ina_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.org_id := l_ina_rec.org_id;
        END IF;
        IF (x_ina_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.created_by := l_ina_rec.created_by;
        END IF;
        IF (x_ina_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ina_rec.creation_date := l_ina_rec.creation_date;
        END IF;
        IF (x_ina_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.last_updated_by := l_ina_rec.last_updated_by;
        END IF;
        IF (x_ina_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ina_rec.last_update_date := l_ina_rec.last_update_date;
        END IF;
        IF (x_ina_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ina_rec.last_update_login := l_ina_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_INS_ASSETS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ina_rec IN ina_rec_type,
      x_ina_rec OUT NOCOPY ina_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ina_rec := p_ina_rec;
      x_ina_rec.OBJECT_VERSION_NUMBER := p_ina_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_ina_rec,                         -- IN
      l_ina_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ina_rec, l_def_ina_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_INS_ASSETS
    SET IPY_ID = l_def_ina_rec.ipy_id,
        KLE_ID = l_def_ina_rec.kle_id,
        CALCULATED_PREMIUM = l_def_ina_rec.calculated_premium,
        ASSET_PREMIUM = l_def_ina_rec.asset_premium,
        LESSOR_PREMIUM = l_def_ina_rec.lessor_premium,
        PROGRAM_UPDATE_DATE = l_def_ina_rec.program_update_date,
        PROGRAM_ID = l_def_ina_rec.program_id,
        OBJECT_VERSION_NUMBER = l_def_ina_rec.object_version_number,
        REQUEST_ID = l_def_ina_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_ina_rec.program_application_id,
        ATTRIBUTE_CATEGORY = l_def_ina_rec.attribute_category,
        ATTRIBUTE1 = l_def_ina_rec.attribute1,
        ATTRIBUTE2 = l_def_ina_rec.attribute2,
        ATTRIBUTE3 = l_def_ina_rec.attribute3,
        ATTRIBUTE4 = l_def_ina_rec.attribute4,
        ATTRIBUTE5 = l_def_ina_rec.attribute5,
        ATTRIBUTE6 = l_def_ina_rec.attribute6,
        ATTRIBUTE7 = l_def_ina_rec.attribute7,
        ATTRIBUTE8 = l_def_ina_rec.attribute8,
        ATTRIBUTE9 = l_def_ina_rec.attribute9,
        ATTRIBUTE10 = l_def_ina_rec.attribute10,
        ATTRIBUTE11 = l_def_ina_rec.attribute11,
        ATTRIBUTE12 = l_def_ina_rec.attribute12,
        ATTRIBUTE13 = l_def_ina_rec.attribute13,
        ATTRIBUTE14 = l_def_ina_rec.attribute14,
        ATTRIBUTE15 = l_def_ina_rec.attribute15,
        ORG_ID = l_def_ina_rec.org_id,
        CREATED_BY = l_def_ina_rec.created_by,
        CREATION_DATE = l_def_ina_rec.creation_date,
        LAST_UPDATED_BY = l_def_ina_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ina_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ina_rec.last_update_login
    WHERE ID = l_def_ina_rec.id;

    x_ina_rec := l_ina_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_INS_ASSETS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_rec                     IN inav_rec_type,
    x_inav_rec                     OUT NOCOPY inav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_inav_rec                     inav_rec_type := p_inav_rec;
    l_def_inav_rec                 inav_rec_type;
    l_db_inav_rec                  inav_rec_type;
    l_ina_rec                      ina_rec_type;
    lx_ina_rec                     ina_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_inav_rec IN inav_rec_type
    ) RETURN inav_rec_type IS
      l_inav_rec inav_rec_type := p_inav_rec;
    BEGIN
      l_inav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_inav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_inav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_inav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_inav_rec IN inav_rec_type,
      x_inav_rec OUT NOCOPY inav_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_inav_rec := p_inav_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_inav_rec := get_rec(p_inav_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_inav_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.id := l_db_inav_rec.id;
        END IF;
        IF (x_inav_rec.ipy_id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.ipy_id := l_db_inav_rec.ipy_id;
        END IF;
        IF (x_inav_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.kle_id := l_db_inav_rec.kle_id;
        END IF;
        IF (x_inav_rec.calculated_premium = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.calculated_premium := l_db_inav_rec.calculated_premium;
        END IF;
        IF (x_inav_rec.asset_premium = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.asset_premium := l_db_inav_rec.asset_premium;
        END IF;
        IF (x_inav_rec.lessor_premium = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.lessor_premium := l_db_inav_rec.lessor_premium;
        END IF;
        IF (x_inav_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute_category := l_db_inav_rec.attribute_category;
        END IF;
        IF (x_inav_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute1 := l_db_inav_rec.attribute1;
        END IF;
        IF (x_inav_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute2 := l_db_inav_rec.attribute2;
        END IF;
        IF (x_inav_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute3 := l_db_inav_rec.attribute3;
        END IF;
        IF (x_inav_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute4 := l_db_inav_rec.attribute4;
        END IF;
        IF (x_inav_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute5 := l_db_inav_rec.attribute5;
        END IF;
        IF (x_inav_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute6 := l_db_inav_rec.attribute6;
        END IF;
        IF (x_inav_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute7 := l_db_inav_rec.attribute7;
        END IF;
        IF (x_inav_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute8 := l_db_inav_rec.attribute8;
        END IF;
        IF (x_inav_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute9 := l_db_inav_rec.attribute9;
        END IF;
        IF (x_inav_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute10 := l_db_inav_rec.attribute10;
        END IF;
        IF (x_inav_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute11 := l_db_inav_rec.attribute11;
        END IF;
        IF (x_inav_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute12 := l_db_inav_rec.attribute12;
        END IF;
        IF (x_inav_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute13 := l_db_inav_rec.attribute13;
        END IF;
        IF (x_inav_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute14 := l_db_inav_rec.attribute14;
        END IF;
        IF (x_inav_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_inav_rec.attribute15 := l_db_inav_rec.attribute15;
        END IF;
        IF (x_inav_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.org_id := l_db_inav_rec.org_id;
        END IF;
        IF (x_inav_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.request_id := l_db_inav_rec.request_id;
        END IF;
        IF (x_inav_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.program_application_id := l_db_inav_rec.program_application_id;
        END IF;
        IF (x_inav_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.program_id := l_db_inav_rec.program_id;
        END IF;
        IF (x_inav_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_inav_rec.program_update_date := l_db_inav_rec.program_update_date;
        END IF;
        IF (x_inav_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.created_by := l_db_inav_rec.created_by;
        END IF;
        IF (x_inav_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_inav_rec.creation_date := l_db_inav_rec.creation_date;
        END IF;
        IF (x_inav_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.last_updated_by := l_db_inav_rec.last_updated_by;
        END IF;
        IF (x_inav_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_inav_rec.last_update_date := l_db_inav_rec.last_update_date;
        END IF;
        IF (x_inav_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_inav_rec.last_update_login := l_db_inav_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_INS_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_inav_rec IN inav_rec_type,
      x_inav_rec OUT NOCOPY inav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_inav_rec := p_inav_rec;
         SELECT NVL(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),p_inav_rec.request_id),
            	                               NVL(DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),p_inav_rec.program_application_id),
            	                               NVL(DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),p_inav_rec.program_id),
            	                               DECODE(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,p_inav_rec.program_update_date,SYSDATE),
            	                               MO_GLOBAL.GET_CURRENT_ORG_ID()
            	                               INTO x_inav_rec.request_id,
            	                                    x_inav_rec.program_application_id,
            	                                    x_inav_rec.program_id,
            	                                    x_inav_rec.program_update_date,
                                    x_inav_rec.org_id FROM dual;


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
      p_inav_rec,                        -- IN
      x_inav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_inav_rec, l_def_inav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_inav_rec := fill_who_columns(l_def_inav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_inav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_inav_rec, l_db_inav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_inav_rec                     => p_inav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_inav_rec, l_ina_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ina_rec,
      lx_ina_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ina_rec, l_def_inav_rec);
    x_inav_rec := l_def_inav_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:inav_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    x_inav_tbl                     OUT NOCOPY inav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      i := p_inav_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_inav_rec                     => p_inav_tbl(i),
            x_inav_rec                     => x_inav_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_inav_tbl.LAST);
        i := p_inav_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:INAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    x_inav_tbl                     OUT NOCOPY inav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_inav_tbl                     => p_inav_tbl,
        x_inav_tbl                     => x_inav_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INS_ASSETS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ina_rec                      IN ina_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ina_rec                      ina_rec_type := p_ina_rec;
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

    DELETE FROM OKL_INS_ASSETS
     WHERE ID = p_ina_rec.id;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_INS_ASSETS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_rec                     IN inav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_inav_rec                     inav_rec_type := p_inav_rec;
    l_ina_rec                      ina_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_inav_rec, l_ina_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ina_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_INS_ASSETS_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      i := p_inav_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_inav_rec                     => p_inav_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_inav_tbl.LAST);
        i := p_inav_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_INS_ASSETS_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_inav_tbl                     IN inav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_inav_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_inav_tbl                     => p_inav_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_INA_PVT;

/
