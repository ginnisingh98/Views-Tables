--------------------------------------------------------
--  DDL for Package Body OKC_SAC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SAC_PVT" AS
/* $Header: OKCSSACB.pls 120.0 2005/05/25 22:49:31 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_STD_ART_CLASSINGS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sac_rec                      IN sac_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sac_rec_type IS
    CURSOR sac_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SAT_CODE,
            PRICE_TYPE,
            SCS_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Std_Art_Classings
     WHERE okc_std_art_classings.id = p_id;
    l_sac_pk                       sac_pk_csr%ROWTYPE;
    l_sac_rec                      sac_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sac_pk_csr (p_sac_rec.id);
    FETCH sac_pk_csr INTO
              l_sac_rec.ID,
              l_sac_rec.SAT_CODE,
              l_sac_rec.PRICE_TYPE,
              l_sac_rec.SCS_CODE,
              l_sac_rec.OBJECT_VERSION_NUMBER,
              l_sac_rec.CREATED_BY,
              l_sac_rec.CREATION_DATE,
              l_sac_rec.LAST_UPDATED_BY,
              l_sac_rec.LAST_UPDATE_DATE,
              l_sac_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := sac_pk_csr%NOTFOUND;
    CLOSE sac_pk_csr;
    RETURN(l_sac_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sac_rec                      IN sac_rec_type
  ) RETURN sac_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sac_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_STD_ART_CLASSINGS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sacv_rec                     IN sacv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sacv_rec_type IS
    CURSOR okc_sacv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SAT_CODE,
            PRICE_TYPE,
            SCS_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Std_Art_Classings_V
     WHERE okc_std_art_classings_v.id = p_id;
    l_okc_sacv_pk                  okc_sacv_pk_csr%ROWTYPE;
    l_sacv_rec                     sacv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_sacv_pk_csr (p_sacv_rec.id);
    FETCH okc_sacv_pk_csr INTO
              l_sacv_rec.ID,
              l_sacv_rec.OBJECT_VERSION_NUMBER,
              l_sacv_rec.SAT_CODE,
              l_sacv_rec.PRICE_TYPE,
              l_sacv_rec.SCS_CODE,
              l_sacv_rec.CREATED_BY,
              l_sacv_rec.CREATION_DATE,
              l_sacv_rec.LAST_UPDATED_BY,
              l_sacv_rec.LAST_UPDATE_DATE,
              l_sacv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_sacv_pk_csr%NOTFOUND;
    CLOSE okc_sacv_pk_csr;
    RETURN(l_sacv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sacv_rec                     IN sacv_rec_type
  ) RETURN sacv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sacv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_STD_ART_CLASSINGS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sacv_rec	IN sacv_rec_type
  ) RETURN sacv_rec_type IS
    l_sacv_rec	sacv_rec_type := p_sacv_rec;
  BEGIN
    IF (l_sacv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sacv_rec.object_version_number := NULL;
    END IF;
     IF (l_sacv_rec.sat_code = OKC_API.G_MISS_CHAR) THEN
      l_sacv_rec.sat_code := NULL;
    END IF;
    IF (l_sacv_rec.price_type = OKC_API.G_MISS_CHAR) THEN
      l_sacv_rec.price_type := NULL;
    END IF;
    IF (l_sacv_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
      l_sacv_rec.scs_code := NULL;
    END IF;
    IF (l_sacv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sacv_rec.created_by := NULL;
    END IF;
    IF (l_sacv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sacv_rec.creation_date := NULL;
    END IF;
    IF (l_sacv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sacv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sacv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sacv_rec.last_update_date := NULL;
    END IF;
    IF (l_sacv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sacv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sacv_rec);
  END null_out_defaults;

/******************ADDED AFTER TAPI****************/
---------------------------------------------------------------------------
  -- Private Validation Procedures
  ---------------------------------------------------------------------------
-- Start of comments
-- Procedure Name  : validate_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_id(p_sacv_rec 	IN 	sacv_rec_type,
                      x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_sacv_rec.id is null) OR (p_sacv_rec.id=OKC_API.G_MISS_NUM) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'ID');
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

END validate_id;

-- Start of comments
-- Procedure Name  : validate_Object_Version_number
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_Object_Version_Number(p_sacv_rec 	IN 	sacv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is

 BEGIN
  x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_sacv_rec.object_version_number is null) OR (p_sacv_rec.object_version_number=OKC_API.G_MISS_NUM) then
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
-- Procedure Name  : validate_sat_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_sat_code(p_sacv_rec 	IN 	sacv_rec_type,
                          x_return_status OUT  NOCOPY VARCHAR2) is

 BEGIN
   x_return_status:=OKC_API.G_RET_STS_SUCCESS;
  --check not null
  If (p_sacv_rec.sat_code is null) OR (p_sacv_rec.sat_code=OKC_API.G_MISS_CHAR) then
    x_return_status:=OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     =>  G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SAT_CODE');
    RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


  -- Check if the value is valid code from lookup table for Article Set
  x_return_status:=OKC_UTIL.check_lookup_code('OKC_ARTICLE_SET',p_sacv_rec.sat_code);
  If  (x_return_status=OKC_API.G_RET_STS_ERROR)  Then
     --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_INVALID_VALUE,
                              p_token1        =>  G_COL_NAME_TOKEN,
			      p_token1_value  =>  'SAT_CODE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  ELSIF (x_return_status=OKC_API.G_RET_STS_UNEXP_ERROR)  Then
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

END validate_sat_code;

--length check not needed as coming from fnd_lookups
-- Start of comments
-- Procedure Name  : VALIDATE_PRICE_TYPE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_price_type(p_sacv_rec 	IN 	sacv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is


 BEGIN
   x_return_status:=OKC_API.G_RET_STS_SUCCESS;

  --check within length limit
  If  (length(p_sacv_rec.price_type)>30)  Then
     x_return_status:=OKC_API.G_RET_STS_ERROR;
     --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_LEN_CHK,
                              p_token1        =>  G_COL_NAME_TOKEN,
			      p_token1_value  =>  'PRICE_TYPE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  -- Check if the value is valid code from lookup table for price type
  x_return_status:=OKC_UTIL.check_lookup_code('OKC_PRICE_TYPE',p_sacv_rec.price_type);
  If  (x_return_status=OKC_API.G_RET_STS_ERROR)  Then
     --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_INVALID_VALUE,
                              p_token1        =>  G_COL_NAME_TOKEN,
			      p_token1_value  =>  'PRICE_TYPE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  ELSIF (x_return_status=OKC_API.G_RET_STS_UNEXP_ERROR)  Then
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

END validate_price_type;

-- Start of comments
-- Procedure Name  : VALIDATE_SCS_CODE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_scs_code(p_sacv_rec 	IN 	sacv_rec_type,
                             x_return_status OUT NOCOPY VARCHAR2) is
  CURSOR l_scs_code_csr IS
   SELECT '1'
   FROM   okc_subclasses_b  scs
   	    WHERE  scs.code = p_sacv_rec.scs_code and
	    sysdate between nvl(start_date,sysdate) and nvl(end_date,sysdate);
  l_dummy_var   VARCHAR2(1):='0';

 BEGIN
   x_return_status:=OKC_API.G_RET_STS_SUCCESS;

  --check within length limit
  If  (length(p_sacv_rec.scs_code)>30)  Then
     x_return_status:=OKC_API.G_RET_STS_ERROR;
     --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			      p_msg_name      =>  G_LEN_CHK,
                              p_token1        =>  G_COL_NAME_TOKEN,
			      p_token1_value  =>  'SCS_CODE');
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

   --check FK Relation with okc_sub_clsses scs code
   OPEN l_scs_code_csr;
   FETCH l_scs_code_csr into l_dummy_var;
   CLOSE l_scs_code_csr;
   IF (l_dummy_var<>'1') Then

	--Corresponding Column value not found
  	x_return_status:= OKC_API.G_RET_STS_ERROR;
    --set error message in message stack
     OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_PARENT_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'SCS_CODE',
                        p_token2       => G_CHILD_TABLE_TOKEN,
                        p_token2_value => G_VIEW,
                        p_token3       => G_PARENT_TABLE_TOKEN,
                        p_token3_value => 'OKC_SUBCLASSES_V');
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

END validate_scs_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKC_STD_ART_CLASSINGS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sacv_rec IN  sacv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_UTIL.ADD_VIEW(G_VIEW,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_id(p_sacv_rec,l_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;

    validate_object_version_number(p_sacv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        l_return_status := x_return_status;   -- record that there was an error
      END IF;
    END IF;



    IF p_sacv_rec.price_type is not null then
    	validate_price_type(p_sacv_rec,x_return_status);
    	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
      	  l_return_status := x_return_status;
      	  RAISE G_EXCEPTION_HALT_VALIDATION;
     	 ELSE
     	   l_return_status := x_return_status;   -- record that there was an error
     	 END IF;
    	END IF;

   End If;

   IF p_sacv_rec.scs_code is not null then
   	validate_scs_code(p_sacv_rec,x_return_status);
    	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    	  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
    	   l_return_status := x_return_status;
     	   RAISE G_EXCEPTION_HALT_VALIDATION;
    	 ELSE
    	    l_return_status := x_return_status;   -- record that there was an error
    	  END IF;
   	END IF;
   END If;

   validate_sat_code(p_sacv_rec,x_return_status);
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
  -- Validate_Record for:OKC_STD_ART_CLASSINGS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_sacv_rec IN sacv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

 -- ------------------------------------------------------
 -- To check for any matching row, for unique combination.
 -- The cursor includes id check filter to handle updates
 -- for case K2 should not overwrite already existing K1
 -- Two cursors are for PRICE_TYPE and SCS_CODE checks.
 -- ------------------------------------------------------
    CURSOR cur_sat_price IS
    SELECT 'x'
    FROM   okc_std_art_classings
    WHERE  sat_code    = p_sacv_rec.SAT_CODE
    AND    price_type  = p_sacv_rec.PRICE_TYPE
    AND    id         <> NVL(p_sacv_rec.ID,-9999);

    CURSOR cur_sat_scs IS
    SELECT 'x'
    FROM   okc_std_art_classings
    WHERE  sat_code    = p_sacv_rec.SAT_CODE
    AND    scs_code    = p_sacv_rec.SCS_CODE
    AND    id          <> NVL(p_sacv_rec.ID,-9999);

l_row_found   BOOLEAN := False;
l_dummy       VARCHAR2(1);

BEGIN
     l_return_status:=OKC_API.G_RET_STS_SUCCESS;

     IF (        p_sacv_rec.price_type IS NOT NULL
		   AND p_sacv_rec.price_type <> OKC_API.G_MISS_CHAR )
         AND (   p_sacv_rec.scs_code   IS NOT NULL
             AND p_sacv_rec.scs_code   <> OKC_API.G_MISS_CHAR )
     THEN
		l_return_status:=OKC_API.G_RET_STS_ERROR;
          -- Set error message in message stack
    		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_EITHER_NULL,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'PRICE_TYPE',
                              p_token2       => G_COL_NAME_TOKEN,
                              p_token2_value => 'SCS_CODE'       );

     ELSIF (     p_sacv_rec.price_type IS NULL
		   OR  p_sacv_rec.price_type =  OKC_API.G_MISS_CHAR )
         AND (   p_sacv_rec.scs_code   IS NULL
             OR  p_sacv_rec.scs_code   =  OKC_API.G_MISS_CHAR )
     THEN
		l_return_status:=OKC_API.G_RET_STS_ERROR;
          --set error message in message stack
    		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_EITHER_NOTNULL,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'PRICE_TYPE',
                              p_token2       => G_COL_NAME_TOKEN,
                              p_token2_value => 'SCS_CODE'       );

     ELSIF (      p_sacv_rec.price_type IS NOT NULL
		  AND   p_sacv_rec.price_type <> OKC_API.G_MISS_CHAR)
     THEN
         -- ---------------------------------------------------------------------
         -- Bug 1636056 related changes - Shyam
         -- OKC_UTIL.check_comp_unique call earlier was not using
         -- the bind variables and parses everytime, replaced with
         -- the explicit cursors above, for identical function to
         -- check uniqueness for SAT_CODE + PRICE_TYPE in OKC_STD_ART_CLASSINGS_V
         -- scs_code and price_type are mutually exclusive (in actual values)
         -- ---------------------------------------------------------------------
            OPEN  cur_sat_price;
		  FETCH cur_sat_price INTO l_dummy;
		  l_row_found := cur_sat_price%FOUND;
		  CLOSE cur_sat_price;

            IF (l_row_found)
            THEN
			 -- Display the newly defined error message
			OKC_API.set_message(G_APP_NAME,
		                         'OKC_DUP_PRICE_TYPE');
               l_return_status := OKC_API.G_RET_STS_ERROR;
        	     RAISE G_EXCEPTION_HALT_VALIDATION;
	       END IF;


     ELSIF (    p_sacv_rec.scs_code   IS NOT NULL
		  AND p_sacv_rec.scs_code   <> OKC_API.G_MISS_CHAR)
     THEN
         -- ---------------------------------------------------------------------
         -- OKC_UTIL.check_comp_unique call is replaced with
         -- the explicit cursors above, for identical function to
         -- check uniqueness for SAT_CODE + SCS_CODE in OKC_STD_ART_CLASSINGS_V
         -- scs_code and price_type are mutually exclusive (in actual values)
         -- ---------------------------------------------------------------------
            OPEN  cur_sat_scs;
		  FETCH cur_sat_scs INTO l_dummy;
		  l_row_found := cur_sat_scs%FOUND;
		  CLOSE cur_sat_scs;

            IF (l_row_found)
            THEN
			 -- Display the newly defined error message
			OKC_API.set_message(G_APP_NAME,
		                         'OKC_DUP_SCS_CODE');
               l_return_status := OKC_API.G_RET_STS_ERROR;
        	     RAISE G_EXCEPTION_HALT_VALIDATION;
	       END IF;

      END IF;

   RETURN (l_return_status);
EXCEPTION
  	WHEN G_EXCEPTION_HALT_VALIDATION THEN
   	     --just come out with return status
   	     RETURN (l_return_status);
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
   	     l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         RETURN (l_return_status);
END Validate_Record;
  /****************END ADDED AFTER TAPI**************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sacv_rec_type,
    p_to	OUT NOCOPY sac_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sat_code := p_from.sat_code;
    p_to.price_type := p_from.price_type;
    p_to.scs_code := p_from.scs_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sac_rec_type,
    p_to	 IN OUT NOCOPY sacv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sat_code := p_from.sat_code;
    p_to.price_type := p_from.price_type;
    p_to.scs_code := p_from.scs_code;
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
  ----------------------------------------------
  -- validate_row for:OKC_STD_ART_CLASSINGS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sacv_rec                     sacv_rec_type := p_sacv_rec;
    l_sac_rec                      sac_rec_type;
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
    l_return_status := Validate_Attributes(l_sacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sacv_rec);
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
  -- PL/SQL TBL validate_row for:SACV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_tbl                     IN sacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sacv_tbl.COUNT > 0) THEN
      i := p_sacv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sacv_rec                     => p_sacv_tbl(i));
        EXIT WHEN (i = p_sacv_tbl.LAST);
        i := p_sacv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_STD_ART_CLASSINGS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sac_rec                      IN sac_rec_type,
    x_sac_rec                      OUT NOCOPY sac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CLASSINGS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sac_rec                      sac_rec_type := p_sac_rec;
    l_def_sac_rec                  sac_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_CLASSINGS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sac_rec IN  sac_rec_type,
      x_sac_rec OUT NOCOPY sac_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sac_rec := p_sac_rec;
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
      p_sac_rec,                         -- IN
      l_sac_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_STD_ART_CLASSINGS(
        id,
        sat_code,
        price_type,
        scs_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_sac_rec.id,
        l_sac_rec.sat_code,
        l_sac_rec.price_type,
        l_sac_rec.scs_code,
        l_sac_rec.object_version_number,
        l_sac_rec.created_by,
        l_sac_rec.creation_date,
        l_sac_rec.last_updated_by,
        l_sac_rec.last_update_date,
        l_sac_rec.last_update_login);
    -- Set OUT values
    x_sac_rec := l_sac_rec;
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
  -- insert_row for:OKC_STD_ART_CLASSINGS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type,
    x_sacv_rec                     OUT NOCOPY sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sacv_rec                     sacv_rec_type;
    l_def_sacv_rec                 sacv_rec_type;
    l_sac_rec                      sac_rec_type;
    lx_sac_rec                     sac_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sacv_rec	IN sacv_rec_type
    ) RETURN sacv_rec_type IS
      l_sacv_rec	sacv_rec_type := p_sacv_rec;
    BEGIN
      l_sacv_rec.CREATION_DATE := SYSDATE;
      l_sacv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_sacv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sacv_rec.LAST_UPDATE_DATE := l_sacv_rec.CREATION_DATE;
      l_sacv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sacv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sacv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_CLASSINGS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sacv_rec IN  sacv_rec_type,
      x_sacv_rec OUT NOCOPY sacv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sacv_rec := p_sacv_rec;
      x_sacv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sacv_rec := null_out_defaults(p_sacv_rec);
    -- Set primary key value
    l_sacv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sacv_rec,                        -- IN
      l_def_sacv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sacv_rec := fill_who_columns(l_def_sacv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sacv_rec, l_sac_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sac_rec,
      lx_sac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sac_rec, l_def_sacv_rec);
    -- Set OUT values
    x_sacv_rec := l_def_sacv_rec;
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
  -- PL/SQL TBL insert_row for:SACV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_tbl                     IN sacv_tbl_type,
    x_sacv_tbl                     OUT NOCOPY sacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sacv_tbl.COUNT > 0) THEN
      i := p_sacv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sacv_rec                     => p_sacv_tbl(i),
          x_sacv_rec                     => x_sacv_tbl(i));
        EXIT WHEN (i = p_sacv_tbl.LAST);
        i := p_sacv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_STD_ART_CLASSINGS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sac_rec                      IN sac_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sac_rec IN sac_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ART_CLASSINGS
     WHERE ID = p_sac_rec.id
       AND OBJECT_VERSION_NUMBER = p_sac_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sac_rec IN sac_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_STD_ART_CLASSINGS
    WHERE ID = p_sac_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CLASSINGS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_STD_ART_CLASSINGS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_STD_ART_CLASSINGS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sac_rec);
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
      OPEN lchk_csr(p_sac_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sac_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sac_rec.object_version_number THEN
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
  -- lock_row for:OKC_STD_ART_CLASSINGS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sac_rec                      sac_rec_type;
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
    migrate(p_sacv_rec, l_sac_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sac_rec
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
  -- PL/SQL TBL lock_row for:SACV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_tbl                     IN sacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sacv_tbl.COUNT > 0) THEN
      i := p_sacv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sacv_rec                     => p_sacv_tbl(i));
        EXIT WHEN (i = p_sacv_tbl.LAST);
        i := p_sacv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_STD_ART_CLASSINGS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sac_rec                      IN sac_rec_type,
    x_sac_rec                      OUT NOCOPY sac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CLASSINGS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sac_rec                      sac_rec_type := p_sac_rec;
    l_def_sac_rec                  sac_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sac_rec	IN sac_rec_type,
      x_sac_rec	OUT NOCOPY sac_rec_type
    ) RETURN VARCHAR2 IS
      l_sac_rec                      sac_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sac_rec := p_sac_rec;
      -- Get current database values
      l_sac_rec := get_rec(p_sac_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sac_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sac_rec.id := l_sac_rec.id;
      END IF;
      IF (x_sac_rec.sat_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sac_rec.sat_code := l_sac_rec.sat_code;
      END IF;
      IF (x_sac_rec.price_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sac_rec.price_type := l_sac_rec.price_type;
      END IF;
      IF (x_sac_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sac_rec.scs_code := l_sac_rec.scs_code;
      END IF;
      IF (x_sac_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sac_rec.object_version_number := l_sac_rec.object_version_number;
      END IF;
      IF (x_sac_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sac_rec.created_by := l_sac_rec.created_by;
      END IF;
      IF (x_sac_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sac_rec.creation_date := l_sac_rec.creation_date;
      END IF;
      IF (x_sac_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sac_rec.last_updated_by := l_sac_rec.last_updated_by;
      END IF;
      IF (x_sac_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sac_rec.last_update_date := l_sac_rec.last_update_date;
      END IF;
      IF (x_sac_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sac_rec.last_update_login := l_sac_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_CLASSINGS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sac_rec IN  sac_rec_type,
      x_sac_rec OUT NOCOPY sac_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sac_rec := p_sac_rec;
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
      p_sac_rec,                         -- IN
      l_sac_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sac_rec, l_def_sac_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_STD_ART_CLASSINGS
     SET SAT_CODE = l_def_sac_rec.sat_code,
        PRICE_TYPE = l_def_sac_rec.price_type,
        scs_code = l_def_sac_rec.scs_code,
        OBJECT_VERSION_NUMBER = l_def_sac_rec.object_version_number,
        CREATED_BY = l_def_sac_rec.created_by,
        CREATION_DATE = l_def_sac_rec.creation_date,
        LAST_UPDATED_BY = l_def_sac_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sac_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sac_rec.last_update_login
    WHERE ID = l_def_sac_rec.id;

    x_sac_rec := l_def_sac_rec;
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
  -- update_row for:OKC_STD_ART_CLASSINGS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type,
    x_sacv_rec                     OUT NOCOPY sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sacv_rec                     sacv_rec_type := p_sacv_rec;
    l_def_sacv_rec                 sacv_rec_type;
    l_sac_rec                      sac_rec_type;
    lx_sac_rec                     sac_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sacv_rec	IN sacv_rec_type
    ) RETURN sacv_rec_type IS
      l_sacv_rec	sacv_rec_type := p_sacv_rec;
    BEGIN
      l_sacv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sacv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sacv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sacv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sacv_rec	IN sacv_rec_type,
      x_sacv_rec	OUT NOCOPY sacv_rec_type
    ) RETURN VARCHAR2 IS
      l_sacv_rec                     sacv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sacv_rec := p_sacv_rec;
      -- Get current database values
      l_sacv_rec := get_rec(p_sacv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sacv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sacv_rec.id := l_sacv_rec.id;
      END IF;
      IF (x_sacv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sacv_rec.object_version_number := l_sacv_rec.object_version_number;
      END IF;
      IF (x_sacv_rec.sat_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sacv_rec.sat_code := l_sacv_rec.sat_code;
      END IF;
      IF (x_sacv_rec.price_type = OKC_API.G_MISS_CHAR)
      THEN
        x_sacv_rec.price_type := l_sacv_rec.price_type;
      END IF;
      IF (x_sacv_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sacv_rec.scs_code := l_sacv_rec.scs_code;
      END IF;
      IF (x_sacv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sacv_rec.created_by := l_sacv_rec.created_by;
      END IF;
      IF (x_sacv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sacv_rec.creation_date := l_sacv_rec.creation_date;
      END IF;
      IF (x_sacv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sacv_rec.last_updated_by := l_sacv_rec.last_updated_by;
      END IF;
      IF (x_sacv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sacv_rec.last_update_date := l_sacv_rec.last_update_date;
      END IF;
      IF (x_sacv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sacv_rec.last_update_login := l_sacv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_STD_ART_CLASSINGS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_sacv_rec IN  sacv_rec_type,
      x_sacv_rec OUT NOCOPY sacv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sacv_rec := p_sacv_rec;
      x_sacv_rec.OBJECT_VERSION_NUMBER := NVL(x_sacv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sacv_rec,                        -- IN
      l_sacv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sacv_rec, l_def_sacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sacv_rec := fill_who_columns(l_def_sacv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sacv_rec, l_sac_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sac_rec,
      lx_sac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sac_rec, l_def_sacv_rec);
    x_sacv_rec := l_def_sacv_rec;
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
  -- PL/SQL TBL update_row for:SACV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_tbl                     IN sacv_tbl_type,
    x_sacv_tbl                     OUT NOCOPY sacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sacv_tbl.COUNT > 0) THEN
      i := p_sacv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sacv_rec                     => p_sacv_tbl(i),
          x_sacv_rec                     => x_sacv_tbl(i));
        EXIT WHEN (i = p_sacv_tbl.LAST);
        i := p_sacv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_STD_ART_CLASSINGS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sac_rec                      IN sac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CLASSINGS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sac_rec                      sac_rec_type:= p_sac_rec;
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
    DELETE FROM OKC_STD_ART_CLASSINGS
     WHERE ID = l_sac_rec.id;

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
  -- delete_row for:OKC_STD_ART_CLASSINGS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_rec                     IN sacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sacv_rec                     sacv_rec_type := p_sacv_rec;
    l_sac_rec                      sac_rec_type;
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
    migrate(l_sacv_rec, l_sac_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sac_rec
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
  -- PL/SQL TBL delete_row for:SACV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sacv_tbl                     IN sacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sacv_tbl.COUNT > 0) THEN
      i := p_sacv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sacv_rec                     => p_sacv_tbl(i));
        EXIT WHEN (i = p_sacv_tbl.LAST);
        i := p_sacv_tbl.NEXT(i);
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
END OKC_SAC_PVT;

/
