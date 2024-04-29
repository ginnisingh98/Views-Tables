--------------------------------------------------------
--  DDL for Package Body OKC_SAI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SAI_PVT" AS
/* $Header: OKCSSAIB.pls 120.0 2005/05/26 09:25:52 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_STD_ART_INCMPTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sai_rec                      IN sai_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sai_rec_type IS
    CURSOR sai_pk_csr (p_sae_id             IN NUMBER,
                       p_sae_id_for         IN NUMBER) IS
    SELECT
            SAE_ID,
            SAE_ID_FOR,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Std_Art_Incmpts
     WHERE okc_std_art_incmpts.sae_id = p_sae_id
       AND okc_std_art_incmpts.sae_id_for = p_sae_id_for;
    l_sai_pk                       sai_pk_csr%ROWTYPE;
    l_sai_rec                      sai_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sai_pk_csr (p_sai_rec.sae_id,
                     p_sai_rec.sae_id_for);
    FETCH sai_pk_csr INTO
              l_sai_rec.SAE_ID,
              l_sai_rec.SAE_ID_FOR,
              l_sai_rec.OBJECT_VERSION_NUMBER,
              l_sai_rec.CREATED_BY,
              l_sai_rec.CREATION_DATE,
              l_sai_rec.LAST_UPDATED_BY,
              l_sai_rec.LAST_UPDATE_DATE,
              l_sai_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sai_pk_csr%NOTFOUND;
    CLOSE sai_pk_csr;
    RETURN(l_sai_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sai_rec                      IN sai_rec_type
  ) RETURN sai_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sai_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ART_INCMPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_saiv_rec                     IN saiv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN saiv_rec_type IS
    CURSOR okc_saiv_pk_csr (p_sae_id             IN NUMBER,
                            p_sae_id_for         IN NUMBER) IS
    SELECT
            SAE_ID,
            SAE_ID_FOR,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Std_Art_Incmpts_V
     WHERE okc_std_art_incmpts_v.sae_id = p_sae_id
       AND okc_std_art_incmpts_v.sae_id_for = p_sae_id_for;
    l_okc_saiv_pk                  okc_saiv_pk_csr%ROWTYPE;
    l_saiv_rec                     saiv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_saiv_pk_csr (p_saiv_rec.sae_id,
                          p_saiv_rec.sae_id_for);
    FETCH okc_saiv_pk_csr INTO
              l_saiv_rec.SAE_ID,
              l_saiv_rec.SAE_ID_FOR,
              l_saiv_rec.OBJECT_VERSION_NUMBER,
              l_saiv_rec.CREATED_BY,
              l_saiv_rec.CREATION_DATE,
              l_saiv_rec.LAST_UPDATED_BY,
              l_saiv_rec.LAST_UPDATE_DATE,
              l_saiv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_saiv_pk_csr%NOTFOUND;
    CLOSE okc_saiv_pk_csr;
    RETURN(l_saiv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_saiv_rec                     IN saiv_rec_type
  ) RETURN saiv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_saiv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_STD_ART_INCMPTS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_saiv_rec	IN saiv_rec_type
  ) RETURN saiv_rec_type IS
    l_saiv_rec	saiv_rec_type := p_saiv_rec;
  BEGIN
    IF (l_saiv_rec.sae_id = OKC_API.G_MISS_NUM) THEN
      l_saiv_rec.sae_id := NULL;
    END IF;
    IF (l_saiv_rec.sae_id_for = OKC_API.G_MISS_NUM) THEN
      l_saiv_rec.sae_id_for := NULL;
    END IF;
    IF (l_saiv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_saiv_rec.object_version_number := NULL;
    END IF;
    IF (l_saiv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_saiv_rec.created_by := NULL;
    END IF;
    IF (l_saiv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_saiv_rec.creation_date := NULL;
    END IF;
    IF (l_saiv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_saiv_rec.last_updated_by := NULL;
    END IF;
    IF (l_saiv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_saiv_rec.last_update_date := NULL;
    END IF;
    IF (l_saiv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_saiv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_saiv_rec);
  END null_out_defaults;

/******************ADDED AFTER TAPI****************/
---------------------------------------------------------------------------
  -- Private Validation Procedures
  ---------------------------------------------------------------------------

-- Start of comments
-- Procedure Name  : validate_Unique
-- Description     : Used in insert_row to check that the same article is not listed incompatible twice
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE validate_Unique(p_saiv_rec 	  IN  saiv_rec_type,
                          x_return_status OUT NOCOPY VARCHAR2) IS
   -- ------------------------------------------------------
   -- To check for any matching row, for unique combination.
   -- ------------------------------------------------------
	 CURSOR cur_sae IS
	 SELECT 'x'
	 FROM   okc_std_art_incmpts
	 WHERE  sae_id      = p_saiv_rec.SAE_ID
	 AND    sae_id_for  = p_saiv_rec.SAE_ID_FOR;

l_row_found   BOOLEAN := FALSE;
l_dummy       VARCHAR2(1);

BEGIN
    x_return_status:=OKC_API.G_RET_STS_SUCCESS;

    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call is replaced with
    -- the explicit cursors above, for identical function to
    -- check uniqueness for SAE_ID + SAE_ID_FOR in OKC_STD_ART_INCMPTS_V
    -- ---------------------------------------------------------------------
    IF (        (p_saiv_rec.sae_id IS NOT NULL)
	      AND  (p_saiv_rec.sae_id <> OKC_API.G_MISS_NUM)     )
	   AND
       (        (p_saiv_rec.sae_id_for IS NOT NULL)
		 AND  (p_saiv_rec.sae_id_for <> OKC_API.G_MISS_NUM) )
    THEN
	   OPEN  cur_sae;
	   FETCH cur_sae INTO l_dummy;
	   l_row_found := cur_sae%FOUND;
	   CLOSE cur_sae;

	   IF (l_row_found)
	   THEN
	       -- Display the newly defined error message
		     OKC_API.set_message(G_APP_NAME,
		                         'OKC_DUP_SAE_ID');
		     x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- other appropriate handlers
        -- store SQL error message on message stack
        OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);

        -- notify  UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_unique;

-- Start of comments
-- Procedure Name  : validate_Object_Version_number
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_Object_Version_Number(p_saiv_rec 	IN 	saiv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saiv_rec.object_version_number is null) OR (p_saiv_rec.object_version_number=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'OBJECT_VERSION_NUMBER');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_object_version_number;


-- Start of comments
-- Procedure Name  : validate_sae_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sae_id(p_saiv_rec 	IN 	saiv_rec_type,
                          x_return_status OUT  NOCOPY VARCHAR2) is
  CURSOR l_sae_id_csr IS
   SELECT '1'
   FROM   okc_std_articles_b  sae
   	    WHERE  sae.id = p_saiv_rec.sae_id;
  l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saiv_rec.sae_id is null) OR (p_saiv_rec.sae_id=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAE_ID');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

   --check FK Relation with okc_std_articles_v.sae_id
   OPEN l_sae_id_csr;
   FETCH l_sae_id_csr into l_dummy_var;
   CLOSE l_sae_id_csr;
   IF (l_dummy_var<>'1') Then

	--Corresponding Column value not found
  	x_return_status:= OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAE_ID',
                        p_token2       =>  G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKC_STD_ARTICLES_V');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;



 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_sae_id;

-- Start of comments
-- Procedure Name  : validate_sae_id_for
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sae_id_for(p_saiv_rec 	IN 	saiv_rec_type,
                          x_return_status OUT  NOCOPY VARCHAR2) is
  CURSOR l_sae_id_csr IS
   SELECT '1'
   FROM   okc_std_articles_b  sae
   	    WHERE  sae.id = p_saiv_rec.sae_id_for;
  l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_saiv_rec.sae_id_for is null) OR (p_saiv_rec.sae_id_for=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAE_ID_FOR');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

   --check FK Relation with okc_std_articles_v.sae_id_for
   OPEN l_sae_id_csr;
   FETCH l_sae_id_csr into l_dummy_var;
   CLOSE l_sae_id_csr;
   IF (l_dummy_var<>'1') Then

	--Corresponding Column value not found
  	x_return_status:= OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAE_ID_FOR',
                        p_token2       =>  G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKC_STD_ARTICLES_V');
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

 EXCEPTION
  When G_EXCEPTION_HALT_VALIDATION then
    --just come out with return status
    null;
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END validate_sae_id_for;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_STD_ART_INCMPTS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_saiv_rec IN  saiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN


    validate_object_version_number(p_saiv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;


   validate_sae_id(p_saiv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

   validate_sae_id_for(p_saiv_rec,x_return_status);
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
        RETURN(l_return_status);
     -- other appropriate handlers
  When others then
      -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    -- notify  UNEXPECTED error
    l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    RETURN(l_return_status);
  END Validate_Attributes;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_STD_ART_INCMPTS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_saiv_rec IN saiv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_unq                          OKC_UTIL.unq_tbl_type;
  BEGIN
     l_return_status:=OKC_API.G_RET_STS_SUCCESS;
   	--check that sae_id and sae_id_for are not same
     IF (p_saiv_rec.sae_id=p_saiv_rec.sae_id_for)
        THEN
		l_return_status:=OKC_API.G_RET_STS_ERROR;
                --set error message in message stack
    		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_NOT_SAME);

     END IF;


   RETURN (l_return_status);
   EXCEPTION
  	When G_EXCEPTION_HALT_VALIDATION then
   	 --just come out with return status
   	 RETURN (l_return_status);
    	 -- other appropriate handlers
  	When others then
      	-- store SQL error message on message stack
    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);

    	-- notify  UNEXPECTED error
   	 l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         RETURN (l_return_status);
  END Validate_Record;
    /****************END ADDED AFTER TAPI**************/



  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN saiv_rec_type,
    p_to	OUT NOCOPY sai_rec_type
  ) IS
  BEGIN
    p_to.sae_id := p_from.sae_id;
    p_to.sae_id_for := p_from.sae_id_for;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sai_rec_type,
    p_to	OUT NOCOPY saiv_rec_type
  ) IS
  BEGIN
    p_to.sae_id := p_from.sae_id;
    p_to.sae_id_for := p_from.sae_id_for;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKC_STD_ART_INCMPTS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_rec                     IN saiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saiv_rec                     saiv_rec_type := p_saiv_rec;
    l_sai_rec                      sai_rec_type;
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
    l_return_status := Validate_Attributes(l_saiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_saiv_rec);
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
  -- PL/SQL TBL validate_row for:SAIV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_tbl                     IN saiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saiv_tbl.COUNT > 0) THEN
      i := p_saiv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saiv_rec                     => p_saiv_tbl(i));
        EXIT WHEN (i = p_saiv_tbl.LAST);
        i := p_saiv_tbl.NEXT(i);
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
  -- insert_row for:OKC_STD_ART_INCMPTS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sai_rec                      IN sai_rec_type,
    x_sai_rec                      OUT NOCOPY sai_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INCMPTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sai_rec                      sai_rec_type := p_sai_rec;
    l_def_sai_rec                  sai_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_INCMPTS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sai_rec IN  sai_rec_type,
      x_sai_rec OUT NOCOPY sai_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sai_rec := p_sai_rec;
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
      p_sai_rec,                         -- IN
      l_sai_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_STD_ART_INCMPTS(
        sae_id,
        sae_id_for,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_sai_rec.sae_id,
        l_sai_rec.sae_id_for,
        l_sai_rec.object_version_number,
        l_sai_rec.created_by,
        l_sai_rec.creation_date,
        l_sai_rec.last_updated_by,
        l_sai_rec.last_update_date,
        l_sai_rec.last_update_login);
    -- Set OUT values
    x_sai_rec := l_sai_rec;
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
  -- insert_row for:OKC_STD_ART_INCMPTS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_rec                     IN saiv_rec_type,
    x_saiv_rec                     OUT NOCOPY saiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saiv_rec                     saiv_rec_type;
    l_def_saiv_rec                 saiv_rec_type;
    l_sai_rec                      sai_rec_type;
    lx_sai_rec                     sai_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saiv_rec	IN saiv_rec_type
    ) RETURN saiv_rec_type IS
      l_saiv_rec	saiv_rec_type := p_saiv_rec;
    BEGIN
      l_saiv_rec.CREATION_DATE := SYSDATE;
      l_saiv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_saiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saiv_rec.LAST_UPDATE_DATE := l_saiv_rec.CREATION_DATE;
      l_saiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_saiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_saiv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_INCMPTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_saiv_rec IN  saiv_rec_type,
      x_saiv_rec OUT NOCOPY saiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_saiv_rec := p_saiv_rec;
      x_saiv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_saiv_rec := null_out_defaults(p_saiv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_saiv_rec,                        -- IN
      l_def_saiv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_saiv_rec := fill_who_columns(l_def_saiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    /****************ADDED AFTER TAPI**************/
    validate_unique(l_def_saiv_rec,l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    /****************END ADDED AFTER TAPI**************/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saiv_rec, l_sai_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sai_rec,
      lx_sai_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sai_rec, l_def_saiv_rec);
    -- Set OUT values
    x_saiv_rec := l_def_saiv_rec;
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
  -- PL/SQL TBL insert_row for:SAIV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_tbl                     IN saiv_tbl_type,
    x_saiv_tbl                     OUT NOCOPY saiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saiv_tbl.COUNT > 0) THEN
      i := p_saiv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saiv_rec                     => p_saiv_tbl(i),
          x_saiv_rec                     => x_saiv_tbl(i));
        EXIT WHEN (i = p_saiv_tbl.LAST);
        i := p_saiv_tbl.NEXT(i);
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
  -- lock_row for:OKC_STD_ART_INCMPTS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sai_rec                      IN sai_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sai_rec IN sai_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ART_INCMPTS
     WHERE SAE_ID = p_sai_rec.sae_id
       AND SAE_ID_FOR = p_sai_rec.sae_id_for
       AND OBJECT_VERSION_NUMBER = p_sai_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sai_rec IN sai_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ART_INCMPTS
    WHERE SAE_ID = p_sai_rec.sae_id
       AND SAE_ID_FOR = p_sai_rec.sae_id_for;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INCMPTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_STD_ART_INCMPTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_STD_ART_INCMPTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sai_rec);
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
      OPEN lchk_csr(p_sai_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sai_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sai_rec.object_version_number THEN
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
  -- lock_row for:OKC_STD_ART_INCMPTS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_rec                     IN saiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sai_rec                      sai_rec_type;
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
    migrate(p_saiv_rec, l_sai_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sai_rec
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
  -- PL/SQL TBL lock_row for:SAIV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_tbl                     IN saiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saiv_tbl.COUNT > 0) THEN
      i := p_saiv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saiv_rec                     => p_saiv_tbl(i));
        EXIT WHEN (i = p_saiv_tbl.LAST);
        i := p_saiv_tbl.NEXT(i);
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
  -- update_row for:OKC_STD_ART_INCMPTS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sai_rec                      IN sai_rec_type,
    x_sai_rec                      OUT NOCOPY sai_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INCMPTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sai_rec                      sai_rec_type := p_sai_rec;
    l_def_sai_rec                  sai_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sai_rec	IN sai_rec_type,
      x_sai_rec	OUT NOCOPY sai_rec_type
    ) RETURN VARCHAR2 IS
      l_sai_rec                      sai_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sai_rec := p_sai_rec;
      -- Get current database values
      l_sai_rec := get_rec(p_sai_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sai_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_sai_rec.sae_id := l_sai_rec.sae_id;
      END IF;
      IF (x_sai_rec.sae_id_for = OKC_API.G_MISS_NUM)
      THEN
        x_sai_rec.sae_id_for := l_sai_rec.sae_id_for;
      END IF;
      IF (x_sai_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sai_rec.object_version_number := l_sai_rec.object_version_number;
      END IF;
      IF (x_sai_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sai_rec.created_by := l_sai_rec.created_by;
      END IF;
      IF (x_sai_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sai_rec.creation_date := l_sai_rec.creation_date;
      END IF;
      IF (x_sai_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sai_rec.last_updated_by := l_sai_rec.last_updated_by;
      END IF;
      IF (x_sai_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sai_rec.last_update_date := l_sai_rec.last_update_date;
      END IF;
      IF (x_sai_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sai_rec.last_update_login := l_sai_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_INCMPTS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sai_rec IN  sai_rec_type,
      x_sai_rec OUT NOCOPY sai_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sai_rec := p_sai_rec;
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
      p_sai_rec,                         -- IN
      l_sai_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sai_rec, l_def_sai_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_STD_ART_INCMPTS
    SET OBJECT_VERSION_NUMBER = l_def_sai_rec.object_version_number,
        CREATED_BY = l_def_sai_rec.created_by,
        CREATION_DATE = l_def_sai_rec.creation_date,
        LAST_UPDATED_BY = l_def_sai_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sai_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sai_rec.last_update_login
    WHERE SAE_ID = l_def_sai_rec.sae_id
      AND SAE_ID_FOR = l_def_sai_rec.sae_id_for;

    x_sai_rec := l_def_sai_rec;
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
  -- update_row for:OKC_STD_ART_INCMPTS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_rec                     IN saiv_rec_type,
    x_saiv_rec                     OUT NOCOPY saiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saiv_rec                     saiv_rec_type := p_saiv_rec;
    l_def_saiv_rec                 saiv_rec_type;
    l_sai_rec                      sai_rec_type;
    lx_sai_rec                     sai_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saiv_rec	IN saiv_rec_type
    ) RETURN saiv_rec_type IS
      l_saiv_rec	saiv_rec_type := p_saiv_rec;
    BEGIN
      l_saiv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saiv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_saiv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_saiv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_saiv_rec	IN saiv_rec_type,
      x_saiv_rec	OUT NOCOPY saiv_rec_type
    ) RETURN VARCHAR2 IS
      l_saiv_rec                     saiv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_saiv_rec := p_saiv_rec;
      -- Get current database values
      l_saiv_rec := get_rec(p_saiv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_saiv_rec.sae_id = OKC_API.G_MISS_NUM)
      THEN
        x_saiv_rec.sae_id := l_saiv_rec.sae_id;
      END IF;
      IF (x_saiv_rec.sae_id_for = OKC_API.G_MISS_NUM)
      THEN
        x_saiv_rec.sae_id_for := l_saiv_rec.sae_id_for;
      END IF;
      IF (x_saiv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_saiv_rec.object_version_number := l_saiv_rec.object_version_number;
      END IF;
      IF (x_saiv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_saiv_rec.created_by := l_saiv_rec.created_by;
      END IF;
      IF (x_saiv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_saiv_rec.creation_date := l_saiv_rec.creation_date;
      END IF;
      IF (x_saiv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_saiv_rec.last_updated_by := l_saiv_rec.last_updated_by;
      END IF;
      IF (x_saiv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_saiv_rec.last_update_date := l_saiv_rec.last_update_date;
      END IF;
      IF (x_saiv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_saiv_rec.last_update_login := l_saiv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_INCMPTS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_saiv_rec IN  saiv_rec_type,
      x_saiv_rec OUT NOCOPY saiv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_saiv_rec := p_saiv_rec;
      x_saiv_rec.OBJECT_VERSION_NUMBER := NVL(x_saiv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_saiv_rec,                        -- IN
      l_saiv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_saiv_rec, l_def_saiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_saiv_rec := fill_who_columns(l_def_saiv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saiv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saiv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saiv_rec, l_sai_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sai_rec,
      lx_sai_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sai_rec, l_def_saiv_rec);
    x_saiv_rec := l_def_saiv_rec;
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
  -- PL/SQL TBL update_row for:SAIV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_tbl                     IN saiv_tbl_type,
    x_saiv_tbl                     OUT NOCOPY saiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saiv_tbl.COUNT > 0) THEN
      i := p_saiv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saiv_rec                     => p_saiv_tbl(i),
          x_saiv_rec                     => x_saiv_tbl(i));
        EXIT WHEN (i = p_saiv_tbl.LAST);
        i := p_saiv_tbl.NEXT(i);
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
  -- delete_row for:OKC_STD_ART_INCMPTS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sai_rec                      IN sai_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INCMPTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sai_rec                      sai_rec_type:= p_sai_rec;
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
    DELETE FROM OKC_STD_ART_INCMPTS
     WHERE SAE_ID = l_sai_rec.sae_id AND
SAE_ID_FOR = l_sai_rec.sae_id_for;

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
  -- delete_row for:OKC_STD_ART_INCMPTS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_rec                     IN saiv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saiv_rec                     saiv_rec_type := p_saiv_rec;
    l_sai_rec                      sai_rec_type;
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
    migrate(l_saiv_rec, l_sai_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sai_rec
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
  -- PL/SQL TBL delete_row for:SAIV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saiv_tbl                     IN saiv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saiv_tbl.COUNT > 0) THEN
      i := p_saiv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saiv_rec                     => p_saiv_tbl(i));
        EXIT WHEN (i = p_saiv_tbl.LAST);
        i := p_saiv_tbl.NEXT(i);
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
END OKC_SAI_PVT;

/
