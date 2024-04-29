--------------------------------------------------------
--  DDL for Package Body OKL_SEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEL_PVT" AS
/* $Header: OKLSSELB.pls 120.6 2007/03/13 08:42:42 prasjain noship $ */
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
  -- FUNCTION get_rec for: OKL_STRM_ELEMENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sel_rec                      IN sel_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sel_rec_type IS
    CURSOR okl_strm_elements_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STM_ID,
            OBJECT_VERSION_NUMBER,
            STREAM_ELEMENT_DATE,
            AMOUNT,
            COMMENTS,
            ACCRUED_YN,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
			SE_LINE_NUMBER,
			DATE_BILLED,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SEL_ID,
            --Added by Keerthi 15-Sep-2003
    	    SOURCE_ID,
    	    SOURCE_TABLE,
    	    -- Added by rgooty: 4212626
            bill_adj_flag,
            accrual_adj_flag,
			-- Added by hkpatel for bug 4350255
	        date_disbursed
      FROM Okl_Strm_Elements
     WHERE okl_strm_elements.id = p_id;
    l_okl_strm_elements_pk         okl_strm_elements_pk_csr%ROWTYPE;
    l_sel_rec                      sel_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_strm_elements_pk_csr (p_sel_rec.id);
    FETCH okl_strm_elements_pk_csr INTO
              l_sel_rec.ID,
              l_sel_rec.STM_ID,
              l_sel_rec.OBJECT_VERSION_NUMBER,
              l_sel_rec.STREAM_ELEMENT_DATE,
              l_sel_rec.AMOUNT,
              l_sel_rec.COMMENTS,
              l_sel_rec.ACCRUED_YN,
              l_sel_rec.PROGRAM_ID,
              l_sel_rec.REQUEST_ID,
              l_sel_rec.PROGRAM_APPLICATION_ID,
              l_sel_rec.PROGRAM_UPDATE_DATE,
              l_sel_rec.SE_LINE_NUMBER,
              l_sel_rec.DATE_BILLED,
              l_sel_rec.CREATED_BY,
              l_sel_rec.CREATION_DATE,
              l_sel_rec.LAST_UPDATED_BY,
              l_sel_rec.LAST_UPDATE_DATE,
              l_sel_rec.LAST_UPDATE_LOGIN,
              l_sel_rec.SEL_ID,
              -- Added by Keerthi 15-Sep-2003
	          l_sel_rec.SOURCE_ID,
              l_sel_rec.SOURCE_TABLE,
              -- Added by rgooty: 4212626
              l_sel_rec.bill_adj_flag,
              l_sel_rec.accrual_adj_flag,
			  -- Added by hkpatel for bug 4350255
	          l_sel_rec.date_disbursed;
    x_no_data_found := okl_strm_elements_pk_csr%NOTFOUND;
    CLOSE okl_strm_elements_pk_csr;
    RETURN(l_sel_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sel_rec                      IN sel_rec_type
  ) RETURN sel_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sel_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_STRM_ELEMENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_selv_rec                     IN selv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN selv_rec_type IS
    CURSOR okl_selv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            STM_ID,
            AMOUNT,
            COMMENTS,
            ACCRUED_YN,
            STREAM_ELEMENT_DATE,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE,
			SE_LINE_NUMBER,
			DATE_BILLED,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SEL_ID,
            --Added by Keerthi 15-Sep-2003
    	    SOURCE_ID,
    	    SOURCE_TABLE,
    	    -- Added by rgooty: 4212626
    	    BILL_ADJ_FLAG,
    	    ACCRUAL_ADJ_FLAG,
			-- Added by hkpatel for bug 4350255
			DATE_DISBURSED
      FROM Okl_Strm_Elements_V
     WHERE okl_strm_elements_v.id = p_id;
    l_okl_selv_pk                  okl_selv_pk_csr%ROWTYPE;
    l_selv_rec                     selv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_selv_pk_csr (p_selv_rec.id);
    FETCH okl_selv_pk_csr INTO
              l_selv_rec.ID,
              l_selv_rec.OBJECT_VERSION_NUMBER,
              l_selv_rec.STM_ID,
              l_selv_rec.AMOUNT,
              l_selv_rec.COMMENTS,
              l_selv_rec.ACCRUED_YN,
              l_selv_rec.STREAM_ELEMENT_DATE,
              l_selv_rec.PROGRAM_ID,
              l_selv_rec.REQUEST_ID,
              l_selv_rec.PROGRAM_APPLICATION_ID,
              l_selv_rec.PROGRAM_UPDATE_DATE,
              l_selv_rec.SE_LINE_NUMBER,
              l_selv_rec.DATE_BILLED,
              l_selv_rec.CREATED_BY,
              l_selv_rec.CREATION_DATE,
              l_selv_rec.LAST_UPDATED_BY,
              l_selv_rec.LAST_UPDATE_DATE,
              l_selv_rec.LAST_UPDATE_LOGIN,
              l_selv_rec.SEL_ID,
              -- Added by Keerthi 15-Sep-2003
	          l_selv_rec.SOURCE_ID,
              l_selv_rec.SOURCE_TABLE,
              -- Added by rgooty: 4212626
              l_selv_rec.BILL_ADJ_FLAG,
              l_selv_rec.ACCRUAL_ADJ_FLAG,
			  -- Added by hkpatel for bug 4350255
			  l_selv_rec.DATE_DISBURSED;
    x_no_data_found := okl_selv_pk_csr%NOTFOUND;
    CLOSE okl_selv_pk_csr;
    RETURN(l_selv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_selv_rec                     IN selv_rec_type
  ) RETURN selv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_selv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_STRM_ELEMENTS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_selv_rec	IN selv_rec_type
  ) RETURN selv_rec_type IS
    l_selv_rec	selv_rec_type := p_selv_rec;
  BEGIN
    IF (l_selv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.object_version_number := NULL;
    END IF;
    IF (l_selv_rec.stm_id = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.stm_id := NULL;
    END IF;
    IF (l_selv_rec.amount = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.amount := NULL;
    END IF;
    IF (l_selv_rec.comments = Okc_Api.G_MISS_CHAR) THEN
      l_selv_rec.comments := NULL;
    END IF;
    IF (l_selv_rec.accrued_yn = Okc_Api.G_MISS_CHAR) THEN
      l_selv_rec.accrued_yn := NULL;
    END IF;
    IF (l_selv_rec.stream_element_date = Okc_Api.G_MISS_DATE) THEN
      l_selv_rec.stream_element_date := NULL;
    END IF;


    -- as per the standards - the concurrent program columns should not be nulled out
    /*
    IF (l_selv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_selv_rec.program_id := NULL;
    END IF;
    IF (l_selv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_selv_rec.request_id := NULL;
    END IF;
    IF (l_selv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_selv_rec.program_application_id := NULL;
    END IF;
    IF (l_selv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_selv_rec.program_update_date := NULL;
    END IF;

    */
    IF (l_selv_rec.se_line_number = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.se_line_number := NULL;
    END IF;

    IF (l_selv_rec.date_billed = Okc_Api.G_MISS_DATE) THEN
      l_selv_rec.date_billed := NULL;
    END IF;

    IF (l_selv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.created_by := NULL;
    END IF;
    IF (l_selv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_selv_rec.creation_date := NULL;
    END IF;
    IF (l_selv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.last_updated_by := NULL;
    END IF;
    IF (l_selv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_selv_rec.last_update_date := NULL;
    END IF;
    IF (l_selv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.last_update_login := NULL;
    END IF;
    IF (l_selv_rec.sel_id = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.sel_id := NULL;
    END IF;
-- Added by Keerthi 15-Sep-2003
    IF (l_selv_rec.source_id = Okc_Api.G_MISS_NUM) THEN
      l_selv_rec.source_id := NULL;
    END IF;
     IF (l_selv_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
      l_selv_rec.source_table := NULL;
    END IF;
    -- Added by rgooty: 4212626
    IF (l_selv_rec.bill_adj_flag = Okc_Api.G_MISS_CHAR) THEN
      l_selv_rec.bill_adj_flag := NULL;
    END IF;
    IF (l_selv_rec.accrual_adj_flag = Okc_Api.G_MISS_CHAR) THEN
      l_selv_rec.accrual_adj_flag := NULL;
    END IF;
	-- Added by hkpatel for bug 4350255
    IF (l_selv_rec.date_disbursed = Okc_Api.G_MISS_DATE) THEN
      l_selv_rec.date_disbursed := NULL;
    END IF;


    RETURN(l_selv_rec);
  END null_out_defaults;




-- START change : akjain , 05/07/2001
-- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
/*
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_STRM_ELEMENTS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_selv_rec IN  selv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_selv_rec.id = OKC_API.G_MISS_NUM OR
       p_selv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_selv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_selv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_selv_rec.stm_id = OKC_API.G_MISS_NUM OR
          p_selv_rec.stm_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'stm_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_selv_rec.amount = OKC_API.G_MISS_NUM OR
          p_selv_rec.amount IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'amount');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKL_STRM_ELEMENTS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_selv_rec IN selv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
*/

  --------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  --------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
 ---------------------------------------------------------------------------

  PROCEDURE Validate_Id(p_selv_rec IN  selv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

          IS

          l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

          BEGIN
            -- initialize return status
            x_return_status := Okc_Api.G_RET_STS_SUCCESS;
            -- check for data before processing
            IF (p_selv_rec.id IS NULL)      THEN

                Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                                  ,p_msg_name       => g_required_value
                                  ,p_token1         => g_col_name_token
                                  ,p_token1_value   => 'id');
               x_return_status    := Okc_Api.G_RET_STS_ERROR;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

          EXCEPTION
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue
            -- with the next column
            NULL;

            WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_unexpected_error,
                                  p_token1       => g_sqlcode_token,
                                  p_token1_value => SQLCODE,
                                  p_token2       => g_sqlerrm_token,
                                  p_token2_value => SQLERRM);

              -- notify caller of an UNEXPECTED error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      END Validate_Id;
/*
 This validation is not required.
       ---------------------------------------------------------------------------
        -- PROCEDURE Validate_Unique_Sel_Record
        ---------------------------------------------------------------------------
        -- Start of comments
        --
        -- Procedure Name  : Validate_Unique_Sel_Record
        -- Description     :
        -- Business Rules  : The combination of Se_Line_Number and Stm_id should be unique.
        -- Parameters      :
        -- Version         : 1.0
        -- End of comments
        ---------------------------------------------------------------------------
        PROCEDURE Validate_Unique_Sel_Record(p_selv_rec IN  selv_rec_type
        				    ,x_return_status OUT NOCOPY  VARCHAR2)
        IS

        l_dummy		VARCHAR2(1)	:= '?';
        l_row_found		BOOLEAN 	:= FALSE;

        -- Cursor for FOD Unique Key
        CURSOR okl_sel_uk_csr(p_rec selv_rec_type) IS
        SELECT '1'
        FROM OKL_STRM_ELEMENTS_V
        WHERE  stm_id =  p_rec.stm_id
          AND  stream_element_date =  p_rec.stream_element_date
          AND  id     <> NVL(p_rec.id,-9999);

        BEGIN

          -- initialize return status
          x_return_status := Okc_Api.G_RET_STS_SUCCESS;
          OPEN okl_sel_uk_csr(p_selv_rec);
          FETCH okl_sel_uk_csr INTO l_dummy;
          l_row_found := okl_sel_uk_csr%FOUND;
          CLOSE okl_sel_uk_csr;
          IF l_row_found THEN
      	Okc_Api.set_message(G_APP_NAME,G_UNQS);
      	x_return_status := Okc_Api.G_RET_STS_ERROR;
           END IF;
        EXCEPTION
          WHEN G_EXCEPTION_HALT_VALIDATION THEN
          -- no processing necessary;  validation can continue
          -- with the next column
          NULL;

          WHEN OTHERS THEN
            -- store SQL error message on message stack for caller
            Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => g_unexpected_error,
                                p_token1       => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2       => g_sqlerrm_token,
                                p_token2_value => SQLERRM);

            -- notify caller of an UNEXPECTED error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
            IF okl_sel_uk_csr%ISOPEN
            THEN
            CLOSE okl_sel_uk_csr;
            END IF;

        END Validate_Unique_Sel_Record;

  */

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Amount
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Amount
  -- Description     :
  -- Business Rules  :Amount can not be null.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Amount(p_selv_rec IN  selv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

                  IS

                  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

                  BEGIN
                    -- initialize return status
                    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
                    -- check for data before processing
                    IF (p_selv_rec.amount IS NULL)      THEN

                        Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                                          ,p_msg_name       => g_required_value
                                          ,p_token1         => g_col_name_token
                                          ,p_token1_value   => 'amount');
                       x_return_status    := Okc_Api.G_RET_STS_ERROR;
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                  EXCEPTION
                    WHEN G_EXCEPTION_HALT_VALIDATION THEN
                    -- no processing necessary; validation can continue
                    -- with the next column
                    NULL;

                    WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
                      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                          p_msg_name     => g_unexpected_error,
                                          p_token1       => g_sqlcode_token,
                                          p_token1_value => SQLCODE,
                                          p_token2       => g_sqlerrm_token,
                                          p_token2_value => SQLERRM);

                      -- notify caller of an UNEXPECTED error
                      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

              END Validate_Amount;




  --------------------------------------------------------------------------
  -- PROCEDURE Validate_Stm_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Stm_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

      PROCEDURE Validate_Stm_Id( p_selv_rec IN  selv_rec_type
  		 	   ,x_return_status OUT NOCOPY  VARCHAR2 ) IS

  		 	CURSOR l_stmid_csr IS
			            SELECT '1'
			            FROM OKL_STREAMS_V
			            WHERE ID=p_selv_rec.STM_ID;

                        l_dummy_stm_id  VARCHAR2(1);

  	              l_row_notfound  BOOLEAN :=TRUE;
  		     BEGIN
  		 	-- initialize return status
  		   	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

  		     -- check for data before processing
  		     IF (p_selv_rec.stm_id IS NULL) THEN
  		        Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
  		                           ,p_msg_name       => g_required_value
  		                           ,p_token1         => g_col_name_token
  		                           ,p_token1_value   => 'stm_id');
  		        x_return_status    := Okc_Api.G_RET_STS_ERROR;
  		        RAISE G_EXCEPTION_HALT_VALIDATION;

  		 	ELSIF p_selv_rec.stm_id IS NOT NULL THEN
  		 	--Check if stm_id exists in the stream level table or not
  		 	   OPEN l_stmid_csr;
			   FETCH l_stmid_csr INTO l_dummy_stm_id;
			   l_row_notfound :=l_stmid_csr%NOTFOUND;
                           CLOSE l_stmid_csr;

  	                   IF(l_row_notfound ) THEN
  	                      Okc_Api.set_message(g_app_name,g_no_parent_record,g_col_name_token,'stm_id',g_child_table_token,'okl_strm_elements_v',g_parent_table_token,'okl_stream_levels_v');

  			      x_return_status := Okc_Api.G_RET_STS_ERROR;
  			      -- raise the exception as there's no matching foreign key value

  			       RAISE G_EXCEPTION_HALT_VALIDATION;
  	                    END IF;


  		     END IF;
  		     EXCEPTION
  		 		WHEN G_EXCEPTION_HALT_VALIDATION THEN
  		     		-- no processing necessary;  validation can continue
  		     		-- with the next column
  		     		NULL;

  		 		WHEN OTHERS THEN
  		     		-- store SQL error message on message stack for caller
  		     		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
  		                         	    p_msg_name     => g_unexpected_error,
  		                         	    p_token1       => g_sqlcode_token,
  		                         	    p_token1_value => SQLCODE,
  		                         	    p_token2       => g_sqlerrm_token,
  		                         	    p_token2_value => SQLERRM);
  		     		-- notify caller of an UNEXPECTED error
  		     		x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  		     	IF l_stmid_csr%ISOPEN
  		     	THEN
                           CLOSE l_stmid_csr;
			    END IF;
  	    END Validate_stm_Id;




  --------------------------------------------------------------------------
  -- PROCEDURE Validate_Stream_Element_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  -- Procedure Name  : Validate_Stream_Element_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Stream_Element_Date(p_selv_rec IN  selv_rec_type,x_return_status OUT NOCOPY  VARCHAR2) IS



	    	      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

	    	      BEGIN
	    	        -- initialize return status
	    	        x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	    	        -- check for data before processing


	    	       IF (p_selv_rec.stream_element_date) IS NULL  THEN



	    	             Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
	    	                              ,p_msg_name       => g_required_value
	    	                              ,p_token1         => g_col_name_token
	    	                              ,p_token1_value   => 'stream_element_date');

	    	           x_return_status    := Okc_Api.G_RET_STS_ERROR;
	    	           RAISE G_EXCEPTION_HALT_VALIDATION;
	    	       END IF;

	    	      EXCEPTION
	    	        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	        -- no processing necessary; validation can continue
	    	        -- with the next column
	    	        NULL;

	    	        WHEN OTHERS THEN
	    	          -- store SQL error message on message stack for caller
	    	         Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
	    	                              p_msg_name     => g_unexpected_error,
	    	                              p_token1       => g_sqlcode_token,
	    	                              p_token1_value => SQLCODE,
	    	                              p_token2       => g_sqlerrm_token,
	    	                              p_token2_value => SQLERRM);


	    	          -- notify caller of an UNEXPECTED error
	    	          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_Stream_Element_Date;

    ---------------------------------------------------------------------------
     -- PROCEDURE Validate_Object_Version_Number
     ---------------------------------------------------------------------------
     -- Start of comments
     --
     -- Procedure Name  : Validate_Object_Version_Number
     -- Description     :
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments
     ---------------------------------------------------------------------------

      PROCEDURE Validate_Object_Version_Number(p_selv_rec IN  selv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

    	    IS

    	    l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

    	    BEGIN
    	      -- initialize return status
    	      x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    	      -- check for data before processing
    	      IF (p_selv_rec.object_version_number IS NULL)THEN
    	         Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
    	                            ,p_msg_name       => g_required_value
    	                            ,p_token1         => g_col_name_token
    	                            ,p_token1_value   => 'object_version_number');
    	         x_return_status    := Okc_Api.G_RET_STS_ERROR;
    	         RAISE G_EXCEPTION_HALT_VALIDATION;
    	      END IF;

    	    EXCEPTION
    	      WHEN G_EXCEPTION_HALT_VALIDATION THEN
    	      -- no processing necessary; validation can continue
    	      -- with the next column
    	      NULL;

    	      WHEN OTHERS THEN
    	        -- store SQL error message on message stack for caller
    	        Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
    	                            p_msg_name     => g_unexpected_error,
    	                            p_token1       => g_sqlcode_token,
    	                            p_token1_value => SQLCODE,
    	                            p_token2       => g_sqlerrm_token,
    	                            p_token2_value => SQLERRM);

    	        -- notify caller of an UNEXPECTED error
    	        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

       END Validate_Object_Version_Number;

  --------------------------------------------------------------------------
  -- PROCEDURE Validate_Se_Line_Number
  --------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Se_Line_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
 ---------------------------------------------------------------------------

  PROCEDURE Validate_Se_Line_Number(p_selv_rec IN  selv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)
  IS
	  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
            -- initialize return status
            x_return_status := Okc_Api.G_RET_STS_SUCCESS;
            -- check for data before processing
            IF (p_selv_rec.se_line_number IS NULL)      THEN

                Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                                  ,p_msg_name       => g_required_value
                                  ,p_token1         => g_col_name_token
                                  ,p_token1_value   => 'se_line_number');
               x_return_status    := Okc_Api.G_RET_STS_ERROR;
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

          EXCEPTION
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue
            -- with the next column
            NULL;

            WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_unexpected_error,
                                  p_token1       => g_sqlcode_token,
                                  p_token1_value => SQLCODE,
                                  p_token2       => g_sqlerrm_token,
                                  p_token2_value => SQLERRM);

              -- notify caller of an UNEXPECTED error
              x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      END Validate_Se_Line_Number;


------------------------------------------------------------------------
   -- PROCEDURE Validate_SEL_Id
   ---------------------------------------------------------------------------
   -- Start of comments
   -- Author          : Kanti
   -- Procedure Name  : Validate_SEL_Id
   -- Description     :
   -- Business Rules  :
   -- Parameters      :
   -- Version         : 1.0
   -- End of comments
   ---------------------------------------------------------------------------

    PROCEDURE Validate_SEL_Id(p_selv_rec IN  selv_rec_type,
                              x_return_status OUT  NOCOPY VARCHAR2)

      IS

      l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

      CURSOR sel_csr (p_sel_id NUMBER)
      IS
      SELECT ID
      FROM okl_strm_elements
      WHERE id = p_sel_id;

      l_sel_id NUMBER := NULL;

      BEGIN

        x_return_status := Okc_Api.G_RET_STS_SUCCESS;

        IF (p_selv_rec.sel_id IS NOT NULL)      THEN

            OPEN sel_csr(p_selv_rec.sel_id);
            FETCH sel_csr INTO l_sel_id;
            CLOSE sel_csr;

            IF (l_sel_id IS NULL) THEN

                   Okc_Api.SET_MESSAGE(p_app_name       => G_APP_NAME
                                      ,p_msg_name       => g_invalid_value
                                      ,p_token1         => g_col_name_token
                                      ,p_token1_value   => 'sel_id');
                   x_return_status    := Okc_Api.G_RET_STS_ERROR;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;

        END IF;

      EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
        -- no processing necessary; validation can continue
        -- with the next column
        NULL;

            WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => g_unexpected_error,
                                  p_token1       => g_sqlcode_token,
                                  p_token1_value => SQLCODE,
                                  p_token2       => g_sqlerrm_token,
                                  p_token2_value => SQLERRM);

          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    END Validate_sel_Id;


 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Source_Id_Table
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Source_Id_table
  -- Description     :
  -- Business Rules  : If Source Id Exists then Source Table cannot be null.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Source_Id_Table(p_selv_rec IN  selv_rec_type,x_return_status OUT NOCOPY  VARCHAR2)

                  IS

                  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
                  l_dummy    VARCHAR2(1) := OKC_API.G_FALSE;

                  BEGIN
                    -- initialize return status
                    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
                    -- check for data before processing


                   IF (p_selv_rec.source_id IS NOT NULL) THEN

        		IF (p_selv_rec.source_table IS NULL) THEN
        	   	       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                	                          ,p_msg_name       => g_invalid_value
                        	                  ,p_token1         => g_col_name_token
                                       	          ,p_token1_value   => 'SOURCE_TABLE');
          		       x_return_status    := Okc_Api.G_RET_STS_ERROR;
 		               RAISE G_EXCEPTION_HALT_VALIDATION;
                        ELSE
		              l_dummy  := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE(p_lookup_type => 'OKL_SEL_SOURCE',
                                       p_lookup_code => p_selv_rec.source_table);

			      IF (l_dummy = Okc_Api.G_FALSE) THEN
          			   Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                                                      ,p_msg_name       => g_invalid_value
                                                      ,p_token1         => g_col_name_token
                                                      ,p_token1_value   => 'SOURCE_TABLE');
                                   x_return_status    := Okc_Api.G_RET_STS_ERROR;
         			   RAISE G_EXCEPTION_HALT_VALIDATION;
       			       END IF;

                        END IF;

                   END IF;



                  EXCEPTION
                    WHEN G_EXCEPTION_HALT_VALIDATION THEN
                    -- no processing necessary; validation can continue
                    -- with the next column
                    NULL;

                    WHEN OTHERS THEN
                      -- store SQL error message on message stack for caller
                      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                                          p_msg_name     => g_unexpected_error,
                                          p_token1       => g_sqlcode_token,
                                          p_token1_value => SQLCODE,
                                          p_token2       => g_sqlerrm_token,
                                          p_token2_value => SQLERRM);

                      -- notify caller of an UNEXPECTED error
                      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

              END Validate_Source_Id_Table;





    ---------------------------------------------------------------------------
     -- FUNCTION Validate_Attributes
     ---------------------------------------------------------------------------
     -- Start of comments
     --
     -- Procedure Name  : Validate_Attributes
     -- Description     :
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments
     ---------------------------------------------------------------------------
       FUNCTION Validate_Attributes (
    	    	    p_selv_rec IN  selv_rec_type
    	    	  ) RETURN VARCHAR2 IS

    	    	    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	    	    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    	    	  BEGIN

    	    	     -- call each column-level validation


    	    	    -- Validate_Id
    	    	    Validate_Id(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;

    	    	    -- Validate_Object_Version_Number
    	    	    Validate_Object_Version_Number(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;

    	    	    -- Validate_Amount
    	    	    Validate_Amount(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;


    	    	    -- Validate_Stm_Id
    	    	       Validate_Stm_Id(p_selv_rec, x_return_status);

    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;

    	    	    -- Validate_Stream_Element_Date
    	    	       Validate_Stream_Element_Date(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;

    	    	    -- Validate_Se_Line_Number
    	    	       Validate_Se_Line_Number(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;

    	    	    -- Validate_sel_id
    	    	       Validate_Sel_ID(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
    	    	       END IF;

                        -- Validate source_id and Source_table (Added by Keerthi 15-Sep-2003)
		        Validate_Source_Id_Table(p_selv_rec, x_return_status);
    	    	    -- store the highest degree of error
    	    	       IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
    	    	          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
    	    	          -- need to leave
    	    	          l_return_status := x_return_status;
    	    	          RAISE G_EXCEPTION_HALT_VALIDATION;
    	    	          ELSE
    	    	          -- record that there was an error
    	    	          l_return_status := x_return_status;
    	    	          END IF;
                        END IF;



    	    	    RETURN(l_return_status);
    	    	  EXCEPTION
    	    	    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    	    	       -- just come out with return status

    	    	       RETURN (l_return_status);

    	    	    WHEN OTHERS THEN
    	    	       -- store SQL error message on message stack for caller
    	    	       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
    	    	                           p_msg_name         => g_unexpected_error,
    	    	                           p_token1           => g_sqlcode_token,
    	    	                           p_token1_value     => SQLCODE,
    	    	                           p_token2           => g_sqlerrm_token,
    	    	                           p_token2_value     => SQLERRM);
    	    	       -- notify caller of an UNEXPECTED error
    	    	       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    	    	       RETURN(l_return_status);

    END Validate_Attributes;

  -- END CUSTOM CODE, akjain

  -- mvasudev , 09/27/2001
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Sel_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Sel_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Sel_Record(p_selv_rec      IN      selv_rec_type
                                       ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for sel Unique Key
  CURSOR okl_sel_uk_csr(p_rec selv_rec_type) IS
  SELECT '1'
  FROM okl_strm_elements_v
  WHERE stm_id				= p_rec.stm_id
  AND   se_line_number	= p_rec.se_line_number
  AND   id     <> NVL(p_rec.id,-9999);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_sel_uk_csr(p_selv_rec);
    FETCH okl_sel_uk_csr INTO l_dummy;
    l_row_found := okl_sel_uk_csr%FOUND;
    CLOSE okl_sel_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message(G_APP_NAME,G_UNQS);
	x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Sel_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_selv_rec IN selv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_sel_Record
    Validate_Unique_Sel_Record(p_selv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;
  -- END change : mvasudev


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN selv_rec_type,
    p_to	IN OUT NOCOPY sel_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.stm_id := p_from.stm_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.stream_element_date := p_from.stream_element_date;
    p_to.amount := p_from.amount;
    p_to.comments := p_from.comments;
    p_to.accrued_yn := p_from.accrued_yn;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.se_line_number := p_from.se_line_number;
    p_to.date_billed := p_from.date_billed;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.sel_id := p_from.sel_id;
-- Added by Keerthi 15-Sep-2003
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    -- Added by rgooty: 4212626
    p_to.bill_adj_flag := p_from.bill_adj_flag;
    p_to.accrual_adj_flag := p_from.accrual_adj_flag;
	-- Added by hkpatel for bug 4350255
	p_to.date_disbursed := p_from.date_disbursed;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sel_rec_type,
    p_to	IN OUT NOCOPY selv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.stm_id := p_from.stm_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.stream_element_date := p_from.stream_element_date;
    p_to.amount := p_from.amount;
    p_to.comments := p_from.comments;
    p_to.accrued_yn := p_from.accrued_yn;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.se_line_number := p_from.se_line_number;
    p_to.date_billed := p_from.date_billed;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.sel_id := p_from.sel_id;
-- Added by Keerthi 15-Sep-2003
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    -- Added by rgooty: 4212626
    p_to.bill_adj_flag := p_from.bill_adj_flag;
    p_to.accrual_adj_flag := p_from.accrual_adj_flag;
	-- Added by hkpatel for bug 4350255
	p_to.date_disbursed := p_from.date_disbursed;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_STRM_ELEMENTS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_selv_rec                     selv_rec_type := p_selv_rec;
    l_sel_rec                      sel_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_selv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_selv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:SELV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_selv_tbl.COUNT > 0) THEN
      i := p_selv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_selv_rec                     => p_selv_tbl(i));
        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_selv_tbl.LAST);
        i := p_selv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- insert_row for:OKL_STRM_ELEMENTS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sel_rec                      IN sel_rec_type,
    x_sel_rec                      OUT NOCOPY sel_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ELEMENTS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sel_rec                      sel_rec_type := p_sel_rec;
    l_def_sel_rec                  sel_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_STRM_ELEMENTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_sel_rec IN  sel_rec_type,
      x_sel_rec OUT NOCOPY sel_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sel_rec := p_sel_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sel_rec,                         -- IN
      l_sel_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;


    INSERT INTO OKL_STRM_ELEMENTS(
        id,
        stm_id,
        object_version_number,
        stream_element_date,
        amount,
        comments,
        accrued_yn,
        program_id,
        request_id,
        program_application_id,
        program_update_date,
		se_line_number,
		date_billed,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        sel_id,
-- Added by Keerthi 15-Sep-2003
        source_id,
        source_table,
        bill_adj_flag,
        accrual_adj_flag,
-- Added by hkpatel for bug 4350255
		date_disbursed)
      VALUES (
        l_sel_rec.id,
        l_sel_rec.stm_id,
        l_sel_rec.object_version_number,
        l_sel_rec.stream_element_date,
        l_sel_rec.amount,
        l_sel_rec.comments,
        l_sel_rec.accrued_yn,
        l_sel_rec.program_id,
        l_sel_rec.request_id,
        l_sel_rec.program_application_id,
        l_sel_rec.program_update_date,
        l_sel_rec.se_line_number,
        l_sel_rec.date_billed,
        l_sel_rec.created_by,
        l_sel_rec.creation_date,
        l_sel_rec.last_updated_by,
        l_sel_rec.last_update_date,
        l_sel_rec.last_update_login,
        l_sel_rec.sel_id,
-- Added by Keerthi 15-Sep-2003
        l_sel_rec.source_id,
        l_sel_rec.source_table,
        l_sel_rec.bill_adj_flag,
        l_sel_rec.accrual_adj_flag,
-- Added by hkpatel for bug 4350255
		l_sel_rec.date_disbursed);

    -- Set OUT values
    x_sel_rec := l_sel_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_STRM_ELEMENTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type,
    x_selv_rec                     OUT NOCOPY selv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_selv_rec                     selv_rec_type;
    l_def_selv_rec                 selv_rec_type;
    l_sel_rec                      sel_rec_type;
    lx_sel_rec                     sel_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_selv_rec	IN selv_rec_type
    ) RETURN selv_rec_type IS
      l_selv_rec	selv_rec_type := p_selv_rec;
    BEGIN
      l_selv_rec.CREATION_DATE := SYSDATE;
      l_selv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_selv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_selv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_selv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_selv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_STRM_ELEMENTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_selv_rec IN  selv_rec_type,
      x_selv_rec OUT NOCOPY selv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_selv_rec := p_selv_rec;
      x_selv_rec.OBJECT_VERSION_NUMBER := 1;

          -- fill Concurrent program columns
          /*** Concurrent Manager columns assignement  ************/

           SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID),
                    DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID),
                  DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID),
                  DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
                   INTO  x_selv_rec.REQUEST_ID
                       ,x_selv_rec.PROGRAM_APPLICATION_ID
                     ,x_selv_rec.PROGRAM_ID
                     ,x_selv_rec.PROGRAM_UPDATE_DATE
               FROM DUAL;
         /***** END Concurrent Manager columns assignement  ************/

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_selv_rec := null_out_defaults(p_selv_rec);
    -- Set primary key value
    l_selv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_selv_rec,                        -- IN
      l_def_selv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_selv_rec := fill_who_columns(l_def_selv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_selv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_selv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_selv_rec, l_sel_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sel_rec,
      lx_sel_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sel_rec, l_def_selv_rec);
    -- Set OUT values
    x_selv_rec := l_def_selv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:SELV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type,
    x_selv_tbl                     OUT NOCOPY selv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

    in_id                     Okl_Streams_Util.NumberTabTyp;
    in_stm_id                 Okl_Streams_Util.NumberTabTyp;
    in_stream_element_date    Okl_Streams_Util.DateTabTyp;
    in_object_version_number  Okl_Streams_Util.NumberTabTyp;
    in_amount                 Okl_Streams_Util.NumberTabTyp;
    in_comments               Okl_Streams_Util.Var450TabTyp;
    in_accrued_yn             Okl_Streams_Util.Var150TabTyp;
    in_program_id             Okl_Streams_Util.NumberTabTyp;
    in_request_id             Okl_Streams_Util.NumberTabTyp;
    in_program_application_id Okl_Streams_Util.NumberTabTyp;
    in_program_update_date    Okl_Streams_Util.DateTabTyp;
    in_se_line_number         Okl_Streams_Util.Var150TabTyp;
    in_date_billed            Okl_Streams_Util.DateTabTyp;

    in_created_by             Okl_Streams_Util.NumberTabTyp;
    in_last_updated_by        Okl_Streams_Util.NumberTabTyp;
    in_creation_date          Okl_Streams_Util.DateTabTyp;
    in_last_update_date       Okl_Streams_Util.DateTabTyp;
    in_last_update_login      Okl_Streams_Util.NumberTabTyp;

    in_sel_id                 Okl_Streams_Util.NumberTabTyp;
    in_source_id              Okl_Streams_Util.NumberTabTyp;
    in_source_table           Okl_Streams_Util.Var150TabTyp;
    -- Added by rgooty: 4212626
    in_bill_adj_flag          Okl_Streams_Util.Var150TabTyp;
    in_accrual_adj_flag       Okl_Streams_Util.Var150TabTyp;
-- Added by hkpatel for bug 4350255
	in_date_disbursed         Okl_Streams_Util.DateTabTyp;
    l_tabsize       NUMBER := p_selv_tbl.COUNT;
    i number;
    j number;


  BEGIN

    Okc_Api.init_msg_list(p_init_msg_list);
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

 --prasjain :start for bug 5474827
       x_selv_tbl := p_selv_tbl;
 --prasjain:End

--Changed to bulk insert as a part of performance bug fix 3866049
    i := p_selv_tbl.FIRST; j:=0;
    WHILE i is not null LOOP
      j:=j+1;
      in_id(j) :=  get_seq_id;

 --prasjain:Start for bug 5474827
         x_selv_tbl(i).id := in_id(j);
 --prasjain:End


      in_stm_id(j) := p_selv_tbl(i).stm_id;
      in_object_version_number(j) := p_selv_tbl(i).object_version_number;
      in_stream_element_date(j) := p_selv_tbl(i).stream_element_date;
      in_amount(j) := p_selv_tbl(i).amount;
      in_comments(j) := p_selv_tbl(i).comments;
      in_accrued_yn(j) := p_selv_tbl(i).accrued_yn;
      in_program_id(j) := p_selv_tbl(i).program_id;
      in_request_id(j) := p_selv_tbl(i).request_id;
      in_program_application_id(j) := p_selv_tbl(i).program_application_id;
      in_program_update_date(j) := p_selv_tbl(i).program_update_date;
      in_se_line_number(j) := p_selv_tbl(i).se_line_number;
      in_date_billed(j) := p_selv_tbl(i).date_billed;
      in_sel_id(j) := p_selv_tbl(i).sel_id;
      in_source_id(j) := p_selv_tbl(i).source_id;
      in_source_table(j) := p_selv_tbl(i).source_table;
      -- Added by rgooty: 4212626
      in_bill_adj_flag(j) := p_selv_tbl(i).bill_adj_flag;
      in_accrual_adj_flag(j) := p_selv_tbl(i).accrual_adj_flag;
      -- 4212626: End
	  -- Added by hkpatel for bug 4350255
	  in_date_disbursed(j) := p_selv_tbl(i).date_disbursed;
      in_CREATION_DATE(j) := SYSDATE;
      in_cREATED_BY(j) := FND_GLOBAL.USER_ID;
      in_LAST_UPDATE_DATE(j) := SYSDATE;
      in_LAST_UPDATED_BY(j) := FND_GLOBAL.USER_ID;
      in_LAST_UPDATE_LOGIN(j) := FND_GLOBAL.LOGIN_ID;
      in_object_version_number(j) := 1.0;


--prasjain:Start for bug 5474827
         --i:= p_selv_tbl.next(j);
         i:= p_selv_tbl.next(i);
--prasjain:end


    END LOOP;

     FORALL i in 1..l_tabsize

     INSERT INTO OKL_STRM_ELEMENTS(
        id,
        stm_id,
        object_version_number,
        stream_element_date,
        amount,
        comments,
        accrued_yn,
        program_id,
        request_id,
        program_application_id,
        program_update_date,
       	se_line_number,
        date_billed,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        sel_id,
        source_id,
        source_table,
        -- Added by rgooty: 4212626
        bill_adj_flag,
        accrual_adj_flag,
		-- Added by hkpatel for bug 4350255
		date_disbursed)
     VALUES
         (in_id(i),
          in_stm_id(i),
          in_object_version_number(i),
          in_stream_element_date(i),
          in_amount(i),
          in_comments(i),
          in_accrued_yn(i),
          in_program_id(i),
          in_request_id(i),
          in_program_application_id(i),
          in_program_update_date(i),
          in_se_line_number(i),
          in_date_billed(i),
          in_created_by(i),
          in_creation_date(i),
          in_last_updated_by(i),
          in_last_update_date(i),
          in_last_update_login(i),
          in_sel_id(i),
          in_source_id(i),
          in_source_table(i),
          -- Added by rgooty: 4212626
          in_bill_adj_flag(i),
          in_accrual_adj_flag(i),
		  in_date_disbursed(i));

--prasjain: Start for bug 5474827
       --x_selv_tbl := p_selv_tbl;
       --prasjain:End


    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  ------------------------------------
  -- lock_row for:OKL_STRM_ELEMENTS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sel_rec                      IN sel_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sel_rec IN sel_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_ELEMENTS
     WHERE ID = p_sel_rec.id
       AND OBJECT_VERSION_NUMBER = p_sel_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sel_rec IN sel_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_STRM_ELEMENTS
    WHERE ID = p_sel_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ELEMENTS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_STRM_ELEMENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_STRM_ELEMENTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_sel_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_sel_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sel_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sel_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_STRM_ELEMENTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sel_rec                      sel_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_selv_rec, l_sel_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sel_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:SELV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_selv_tbl.COUNT > 0) THEN
      i := p_selv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_selv_rec                     => p_selv_tbl(i));

        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_selv_tbl.LAST);
        i := p_selv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- update_row for:OKL_STRM_ELEMENTS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sel_rec                      IN sel_rec_type,
    x_sel_rec                      OUT NOCOPY sel_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ELEMENTS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sel_rec                      sel_rec_type := p_sel_rec;
    l_def_sel_rec                  sel_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sel_rec	IN sel_rec_type,
      x_sel_rec	OUT NOCOPY sel_rec_type
    ) RETURN VARCHAR2 IS
      l_sel_rec                      sel_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sel_rec := p_sel_rec;
      -- Get current database values
      l_sel_rec := get_rec(p_sel_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sel_rec.id IS NULL)THEN
        x_sel_rec.id := l_sel_rec.id;
      ELSIF (x_sel_rec.id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.id := NULL;
      END IF;
      IF (x_sel_rec.stm_id IS NULL)THEN
        x_sel_rec.stm_id := l_sel_rec.stm_id;
      ELSIF (x_sel_rec.stm_id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.stm_id := NULL;
      END IF;
      IF (x_sel_rec.object_version_number IS NULL)THEN
        x_sel_rec.object_version_number := l_sel_rec.object_version_number;
      ELSIF (x_sel_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.object_version_number := NULL;
      END IF;
      IF (x_sel_rec.stream_element_date IS NULL)THEN
        x_sel_rec.stream_element_date := l_sel_rec.stream_element_date;
      ELSIF (x_sel_rec.stream_element_date = Okc_Api.G_MISS_DATE) THEN
        x_sel_rec.stream_element_date := NULL;
      END IF;
      IF (x_sel_rec.amount IS NULL) THEN
        x_sel_rec.amount := l_sel_rec.amount;
      ELSIF (x_sel_rec.amount = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.amount := NULL;
      END IF;
      IF (x_sel_rec.comments IS NULL)THEN
        x_sel_rec.comments := l_sel_rec.comments;
      ELSIF (x_sel_rec.comments = Okc_Api.G_MISS_CHAR) THEN
        x_sel_rec.comments := NULL;
      END IF;
      IF (x_sel_rec.accrued_yn IS NULL) THEN
        x_sel_rec.accrued_yn := l_sel_rec.accrued_yn;
      ELSIF (x_sel_rec.accrued_yn = Okc_Api.G_MISS_CHAR) THEN
        x_sel_rec.accrued_yn := NULL;
      END IF;
      IF (x_sel_rec.program_id IS NULL)THEN
        x_sel_rec.program_id := l_sel_rec.program_id;
      ELSIF (x_sel_rec.program_id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.program_id := NULL;
      END IF;
      IF (x_sel_rec.request_id IS NULL) THEN
        x_sel_rec.request_id := l_sel_rec.request_id;
      ELSIF (x_sel_rec.request_id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.request_id := NULL;
      END IF;
      IF (x_sel_rec.program_application_id IS NULL)THEN
        x_sel_rec.program_application_id := l_sel_rec.program_application_id;
      ELSIF (x_sel_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.program_application_id := NULL;
      END IF;
      IF (x_sel_rec.program_update_date IS NULL) THEN
        x_sel_rec.program_update_date := l_sel_rec.program_update_date;
      ELSIF (x_sel_rec.program_update_date = Okc_Api.G_MISS_DATE) THEN
        x_sel_rec.program_update_date := NULL;
      END IF;
      IF (x_sel_rec.se_line_number IS NULL)THEN
        x_sel_rec.se_line_number := l_sel_rec.se_line_number;
      ELSIF (x_sel_rec.se_line_number = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.se_line_number := NULL;
      END IF;
      IF (x_sel_rec.date_billed IS NULL)THEN
        x_sel_rec.date_billed := l_sel_rec.date_billed;
      ELSIF (x_sel_rec.date_billed = Okc_Api.G_MISS_DATE) THEN
        x_sel_rec.date_billed := NULL;
      END IF;
      IF (x_sel_rec.created_by IS NULL) THEN
        x_sel_rec.created_by := l_sel_rec.created_by;
      ELSIF (x_sel_rec.created_by = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.created_by := NULL;
      END IF;
      IF (x_sel_rec.creation_date IS NULL)THEN
        x_sel_rec.creation_date := l_sel_rec.creation_date;
      ELSIF (x_sel_rec.created_by = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.created_by := NULL;
      END IF;
      IF (x_sel_rec.last_updated_by IS NULL) THEN
        x_sel_rec.last_updated_by := l_sel_rec.last_updated_by;
      ELSIF (x_sel_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.last_updated_by := NULL;
      END IF;
      IF (x_sel_rec.last_update_date IS NULL)THEN
        x_sel_rec.last_update_date := l_sel_rec.last_update_date;
      ELSIF (x_sel_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
        x_sel_rec.last_update_date := NULL;
      END IF;
      IF (x_sel_rec.last_update_login IS NULL)THEN
        x_sel_rec.last_update_login := l_sel_rec.last_update_login;
      ELSIF (x_sel_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.last_update_login := NULL;
      END IF;
      IF (x_sel_rec.sel_id IS NULL)THEN
        x_sel_rec.sel_id := l_sel_rec.sel_id;
      ELSIF (x_sel_rec.sel_id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.sel_id := NULL;
      END IF;
--Added by Keerthi 15-Sep-2003
      IF (x_sel_rec.source_id IS NULL)THEN
        x_sel_rec.source_id := l_sel_rec.source_id;
      ELSIF ( x_sel_rec.source_id = Okc_Api.G_MISS_NUM) THEN
        x_sel_rec.source_id := NULL;
      END IF;
      IF (x_sel_rec.source_table IS NULL)THEN
        x_sel_rec.source_table := l_sel_rec.source_table;
      ELSIF (x_sel_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
        x_sel_rec.source_table := NULL;
      END IF;
      -- Added by rgooty: 4212626
      IF (x_sel_rec.bill_adj_flag IS NULL)THEN
        x_sel_rec.bill_adj_flag := l_sel_rec.bill_adj_flag;
      ELSIF (x_sel_rec.bill_adj_flag = Okc_Api.G_MISS_CHAR) THEN
        x_sel_rec.bill_adj_flag := NULL;
      END IF;
      IF (x_sel_rec.accrual_adj_flag IS NULL)THEN
        x_sel_rec.accrual_adj_flag := l_sel_rec.accrual_adj_flag;
      ELSIF (x_sel_rec.accrual_adj_flag = Okc_Api.G_MISS_CHAR) THEN
        x_sel_rec.accrual_adj_flag := NULL;
      END IF;
	  -- Added by hkpatel for bug 4350255
      IF (x_sel_rec.date_disbursed IS NULL)THEN
        x_sel_rec.date_disbursed := l_sel_rec.date_disbursed;
      ELSIF (x_sel_rec.date_disbursed = Okc_Api.G_MISS_DATE) THEN
        x_sel_rec.date_disbursed := NULL;
      END IF;


      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_STRM_ELEMENTS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_sel_rec IN  sel_rec_type,
      x_sel_rec OUT NOCOPY sel_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_sel_rec := p_sel_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_sel_rec,                         -- IN
      l_sel_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sel_rec, l_def_sel_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_STRM_ELEMENTS
    SET STM_ID = l_def_sel_rec.stm_id,
        OBJECT_VERSION_NUMBER = l_def_sel_rec.object_version_number,
        STREAM_ELEMENT_DATE = l_def_sel_rec.stream_element_date,
        AMOUNT = l_def_sel_rec.amount,
        COMMENTS = l_def_sel_rec.comments,
        ACCRUED_YN = l_def_sel_rec.accrued_yn,
        PROGRAM_ID = l_def_sel_rec.program_id,
        REQUEST_ID = l_def_sel_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_sel_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_sel_rec.program_update_date,
        SE_LINE_NUMBER = l_def_sel_rec.se_line_number,
        DATE_BILLED = l_def_sel_rec.date_billed,
        CREATED_BY = l_def_sel_rec.created_by,
        CREATION_DATE = l_def_sel_rec.creation_date,
        LAST_UPDATED_BY = l_def_sel_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sel_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sel_rec.last_update_login,
        SEL_ID = l_def_sel_rec.sel_id,
-- Added by Keerthi 15-Sep-2003
        SOURCE_ID = l_def_sel_rec.source_id,
        SOURCE_TABLE = l_def_sel_rec.source_table,
        -- Added by rgooty: 4212626
        BILL_ADJ_FLAG = l_def_sel_rec.bill_adj_flag,
        ACCRUAL_ADJ_FLAG = l_def_sel_rec.accrual_adj_flag,
		-- Added by hkpatel for bug 4350255
		DATE_DISBURSED = l_def_sel_rec.date_disbursed
    WHERE ID = l_def_sel_rec.id;

    x_sel_rec := l_def_sel_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_STRM_ELEMENTS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type,
    x_selv_rec                     OUT NOCOPY selv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_selv_rec                     selv_rec_type := p_selv_rec;
    l_def_selv_rec                 selv_rec_type;
    l_sel_rec                      sel_rec_type;
    lx_sel_rec                     sel_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_selv_rec	IN selv_rec_type
    ) RETURN selv_rec_type IS
      l_selv_rec	selv_rec_type := p_selv_rec;
    BEGIN
      l_selv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_selv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_selv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_selv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_selv_rec	IN selv_rec_type,
      x_selv_rec	OUT NOCOPY selv_rec_type
    ) RETURN VARCHAR2 IS
      l_selv_rec                     selv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_selv_rec := p_selv_rec;
      -- Get current database values
      l_selv_rec := get_rec(p_selv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_selv_rec.id IS NULL)THEN
        x_selv_rec.id := l_selv_rec.id;
      ELSIF (x_selv_rec.id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.id := NULL;
      END IF;
      IF (x_selv_rec.object_version_number IS NULL)THEN
        x_selv_rec.object_version_number := l_selv_rec.object_version_number;
      ELSIF (x_selv_rec.object_version_number = Okc_Api.G_MISS_NUM ) THEN
        x_selv_rec.object_version_number := NULL;
      END IF;
      IF (x_selv_rec.stm_id IS NULL)THEN
        x_selv_rec.stm_id := l_selv_rec.stm_id;
      ELSIF (x_selv_rec.stm_id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.stm_id := NULL;
      END IF;
      IF (x_selv_rec.amount IS NULL)THEN
        x_selv_rec.amount := l_selv_rec.amount;
      ELSIF (x_selv_rec.amount = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.amount := NULL;
      END IF;
      IF (x_selv_rec.comments IS NULL)THEN
        x_selv_rec.comments := l_selv_rec.comments;
      ELSIF (x_selv_rec.comments = Okc_Api.G_MISS_CHAR) THEN
        x_selv_rec.comments := NULL ;
      END IF;
      IF (x_selv_rec.accrued_yn IS NULL) THEN
        x_selv_rec.accrued_yn := l_selv_rec.accrued_yn;
      ELSIF (x_selv_rec.accrued_yn = Okc_Api.G_MISS_CHAR) THEN
        x_selv_rec.accrued_yn := NULL;
      END IF;
      IF (x_selv_rec.stream_element_date IS NULL)THEN
        x_selv_rec.stream_element_date := l_selv_rec.stream_element_date;
      ELSIF (x_selv_rec.stream_element_date = Okc_Api.G_MISS_DATE) THEN
        x_selv_rec.stream_element_date := NULL;
      END IF;
      IF (x_selv_rec.program_id IS NULL) THEN
        x_selv_rec.program_id := l_selv_rec.program_id;
      ELSIF (x_selv_rec.program_id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.program_id := NULL;
      END IF;
      IF (x_selv_rec.request_id IS NULL)THEN
        x_selv_rec.request_id := l_selv_rec.request_id;
      ELSIF (x_selv_rec.request_id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.request_id := NULL;
      END IF;
      IF (x_selv_rec.program_application_id IS NULL)THEN
        x_selv_rec.program_application_id := l_selv_rec.program_application_id;
      ELSIF (x_selv_rec.program_application_id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.program_application_id := NULL;
      END IF;
      IF (x_selv_rec.program_update_date IS NULL)THEN
        x_selv_rec.program_update_date := l_selv_rec.program_update_date;
      ELSIF (x_selv_rec.program_update_date = Okc_Api.G_MISS_DATE)THEN
        x_selv_rec.program_update_date := NULL;
      END IF;
      IF (x_selv_rec.se_line_number IS NULL)THEN
        x_selv_rec.se_line_number := l_selv_rec.se_line_number;
      ELSIF (x_selv_rec.se_line_number = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.se_line_number := NULL;
      END IF;
      IF (x_selv_rec.date_billed IS NULL)THEN
        x_selv_rec.date_billed := l_selv_rec.date_billed;
      ELSIF (x_selv_rec.date_billed = Okc_Api.G_MISS_DATE) THEN
        x_selv_rec.date_billed := NULL;
      END IF;
      IF (x_selv_rec.created_by IS NULL)THEN
        x_selv_rec.created_by := l_selv_rec.created_by;
      ELSIF (x_selv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.created_by := NULL;
      END IF;
      IF (x_selv_rec.creation_date IS NULL)THEN
        x_selv_rec.creation_date := l_selv_rec.creation_date;
      ELSIF (x_selv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
        x_selv_rec.creation_date := NULL;
      END IF;
      IF (x_selv_rec.last_updated_by IS NULL)THEN
        x_selv_rec.last_updated_by := l_selv_rec.last_updated_by;
      ELSIF (x_selv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.last_updated_by := NULL;
      END IF;
      IF (x_selv_rec.last_update_date IS NULL)THEN
        x_selv_rec.last_update_date := l_selv_rec.last_update_date;
      ELSIF (x_selv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
        x_selv_rec.last_update_date := NULL;
      END IF;
      IF (x_selv_rec.last_update_login IS NULL)THEN
        x_selv_rec.last_update_login := l_selv_rec.last_update_login;
      ELSIF (x_selv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.last_update_login := NULL;
      END IF;
      IF (x_selv_rec.sel_id IS NULL)THEN
        x_selv_rec.sel_id := l_selv_rec.sel_id;
      ELSIF (x_selv_rec.sel_id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.sel_id := NULL;
      END IF;
-- Added by Keerthi 15-Sep-2003
      IF (x_selv_rec.source_id IS NULL)THEN
        x_selv_rec.source_id := l_selv_rec.source_id;
      ELSIF (x_selv_rec.source_id = Okc_Api.G_MISS_NUM) THEN
        x_selv_rec.source_id := NULL;
      END IF;
      IF (x_selv_rec.source_table IS NULL) THEN
        x_selv_rec.source_table := l_selv_rec.source_table;
      ELSIF (x_selv_rec.source_table = Okc_Api.G_MISS_CHAR) THEN
        x_selv_rec.source_table := NULL;
      END IF;
      -- Added by rgooty: 4212626
      IF (x_selv_rec.bill_adj_flag IS NULL) THEN
        x_selv_rec.bill_adj_flag := l_selv_rec.bill_adj_flag;
      ELSIF (x_selv_rec.bill_adj_flag = Okc_Api.G_MISS_CHAR) THEN
        x_selv_rec.bill_adj_flag := NULL;
      END IF;
      IF (x_selv_rec.accrual_adj_flag IS NULL) THEN
        x_selv_rec.accrual_adj_flag := l_selv_rec.accrual_adj_flag;
      ELSIF (x_selv_rec.accrual_adj_flag = Okc_Api.G_MISS_CHAR) THEN
        x_selv_rec.accrual_adj_flag := NULL;
      END IF;
	  -- Added by hkpatel for bug 4350255
      IF (x_selv_rec.date_billed IS NULL)THEN
        x_selv_rec.date_billed := l_selv_rec.date_billed;
      ELSIF (x_selv_rec.date_billed = Okc_Api.G_MISS_DATE) THEN
        x_selv_rec.date_billed := NULL;
      END IF;



      /***** Concurrent Manager columns assignement  ************/
      	  SELECT  NVL(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, Fnd_Global.CONC_REQUEST_ID)
      	  			 ,x_selv_rec.REQUEST_ID)
      			 ,NVL(DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL, Fnd_Global.PROG_APPL_ID)
      	  			 ,x_selv_rec.PROGRAM_APPLICATION_ID)
      			 ,NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL, Fnd_Global.CONC_PROGRAM_ID)
      	  		 	 ,x_selv_rec.PROGRAM_ID)
      			 ,DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      	  		 	 ,NULL,x_selv_rec.PROGRAM_UPDATE_DATE,SYSDATE)
      		INTO x_selv_rec.REQUEST_ID
      			 ,x_selv_rec.PROGRAM_APPLICATION_ID
      			 ,x_selv_rec.PROGRAM_ID
      			 ,x_selv_rec.PROGRAM_UPDATE_DATE
      		  FROM DUAL;
/******* END Concurrent Manager COLUMN Assignment ******************/

      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_STRM_ELEMENTS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_selv_rec IN  selv_rec_type,
      x_selv_rec OUT NOCOPY selv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_selv_rec := p_selv_rec;
      x_selv_rec.OBJECT_VERSION_NUMBER := NVL(x_selv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_selv_rec,                        -- IN
      l_selv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_selv_rec, l_def_selv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_selv_rec := fill_who_columns(l_def_selv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_selv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_selv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_selv_rec, l_sel_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sel_rec,
      lx_sel_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sel_rec, l_def_selv_rec);
    x_selv_rec := l_def_selv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:SELV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type,
    x_selv_tbl                     OUT NOCOPY selv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain


  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_selv_tbl.COUNT > 0) THEN
      i := p_selv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_selv_rec                     => p_selv_tbl(i),
          x_selv_rec                     => x_selv_tbl(i));
        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_selv_tbl.LAST);
        i := p_selv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  --------------------------------------
  -- delete_row for:OKL_STRM_ELEMENTS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sel_rec                      IN sel_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ELEMENTS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_sel_rec                      sel_rec_type:= p_sel_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_STRM_ELEMENTS
     WHERE ID = l_sel_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_STRM_ELEMENTS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_selv_rec                     selv_rec_type := p_selv_rec;
    l_sel_rec                      sel_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_selv_rec, l_sel_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sel_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:SELV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain


  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_selv_tbl.COUNT > 0) THEN
      i := p_selv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_selv_rec                     => p_selv_tbl(i));
        -- START change : akjain, 05/15/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain

        EXIT WHEN (i = p_selv_tbl.LAST);
        i := p_selv_tbl.NEXT(i);
      END LOOP;

       -- START change : akjain, 05/15/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain
    END IF;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END Okl_Sel_Pvt;

/
