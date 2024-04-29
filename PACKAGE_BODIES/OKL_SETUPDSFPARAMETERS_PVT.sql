--------------------------------------------------------
--  DDL for Package Body OKL_SETUPDSFPARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPDSFPARAMETERS_PVT" AS
/* $Header: OKLRSFRB.pls 120.1 2005/06/03 05:31:09 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_FNCTN_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_fprv_rec                     IN fprv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_fprv_rec					   OUT NOCOPY fprv_rec_type
  ) IS
    CURSOR okl_fprv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			SFWT_FLAG,
			DSF_ID,
			PMR_ID,
			SEQUENCE_NUMBER,
			NVL(VALUE,OKL_API.G_MISS_CHAR) VALUE,
			NVL(INSTRUCTIONS,OKL_API.G_MISS_CHAR) INSTRUCTIONS,
			FPR_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Fnctn_Prmtrs_V
     WHERE okl_Fnctn_Prmtrs_V.id    = p_id;
    l_okl_fprv_pk                  okl_fprv_pk_csr%ROWTYPE;
    l_fprv_rec                     fprv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_fprv_pk_csr (p_fprv_rec.id);
    FETCH okl_fprv_pk_csr INTO
              l_fprv_rec.ID,
              l_fprv_rec.OBJECT_VERSION_NUMBER,
			  l_fprv_rec.SFWT_FLAG,
              l_fprv_rec.DSF_ID,
              l_fprv_rec.PMR_ID,
              l_fprv_rec.SEQUENCE_NUMBER,
              l_fprv_rec.VALUE,
              l_fprv_rec.INSTRUCTIONS,
              l_fprv_rec.FPR_TYPE,
              l_fprv_rec.CREATED_BY,
              l_fprv_rec.CREATION_DATE,
              l_fprv_rec.LAST_UPDATED_BY,
              l_fprv_rec.LAST_UPDATE_DATE,
              l_fprv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_fprv_pk_csr%NOTFOUND;
    CLOSE okl_fprv_pk_csr;
    x_fprv_rec := l_fprv_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_fprv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_fprv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_FNCTN_PRMTRS_V
  -- To verify whether the dates are valid for both formula and operands
  -- attached to it
  ---------------------------------------------------------------------------
  PROCEDURE check_constraints (
	p_fprv_rec		IN fprv_rec_type,
	x_return_status	OUT NOCOPY VARCHAR2,
    x_valid         OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_fprv_pk_csr (p_dsf_id IN Okl_Fnctn_Prmtrs_V.dsf_id%TYPE,
							p_sequence_number IN Okl_Fnctn_Prmtrs_V.sequence_number%TYPE
	) IS
    SELECT '1'
    FROM Okl_Fnctn_Prmtrs_V fpr
    WHERE fpr.DSF_ID 		= p_dsf_id
	AND fpr.SEQUENCE_NUMBER = p_sequence_number;

	l_check		   	VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for function parameter sequence
    OPEN okl_fprv_pk_csr (p_fprv_rec.dsf_id,
		 				  p_fprv_rec.sequence_number);
    FETCH okl_fprv_pk_csr INTO l_check;
    l_row_not_found := okl_fprv_pk_csr%NOTFOUND;
    CLOSE okl_fprv_pk_csr;

    IF l_row_not_found = FALSE then
	   OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
						   p_msg_name		=>	G_SEQUENCE_NUMBER,
						   p_token1			=>  G_COL_NAME_TOKEN,
						   p_token1_value	=>  'DSF_ID');
	   x_valid := FALSE;
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
	   x_valid := FALSE;
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_fprv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_fprv_pk_csr;
       END IF;


  END check_constraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pmr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pmr_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pmr_Id(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;
  l_token_1               VARCHAR2(1999);

  -- Cursor For OKL_FPR_PMR_FK;
  CURSOR okl_pmrv_pk_csr (p_id IN OKL_FNCTN_PRMTRS_V.pmr_id%TYPE) IS
  SELECT '1'
    FROM OKL_PARAMETERS_V
   WHERE OKL_PARAMETERS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_FNCT_PARMS_CRUPD','OKL_PARAMETER');


    IF p_fprv_rec.pmr_id = Okc_Api.G_MISS_NUM OR
       p_fprv_rec.pmr_id IS NULL THEN
      	   --Okc_Api.set_message(G_APP_NAME,G_INVALID_KEY);
           Okc_Api.SET_MESSAGE(p_app_name       => Okl_fpr_Pvt.g_app_name
                          ,p_msg_name           => Okl_fpr_Pvt.g_required_value
                          ,p_token1             => Okl_fpr_Pvt.g_col_name_token
                          ,p_token1_value       => l_token_1);
      	   x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

	-- RPOONUGA001: Modified the if condition to check the validility
	-- in the case of valid pmr_id passed
    IF  p_fprv_rec.pmr_id IS NOT NULL
    THEN
    	OPEN okl_pmrv_pk_csr(p_fprv_rec.pmr_id);
    	FETCH okl_pmrv_pk_csr INTO l_dummy;
    	l_row_not_found := okl_pmrv_pk_csr%NOTFOUND;
    	CLOSE okl_pmrv_pk_csr;

    	IF l_row_not_found THEN
      	   --Okc_Api.set_message(G_APP_NAME,G_INVALID_KEY);

          Okc_Api.set_message(Okl_fpr_Pvt.G_APP_NAME, Okl_fpr_Pvt.G_INVALID_VALUE,Okl_fpr_Pvt.G_COL_NAME_TOKEN,l_token_1);

           /*Okc_Api.SET_MESSAGE(p_app_name       => Okl_fpr_Pvt.g_app_name
                          ,p_msg_name           => Okl_fpr_Pvt.g_required_value
                          ,p_token1             => Okl_fpr_Pvt.g_col_name_token
                          ,p_token1_value       => l_token_1);*/
      	   x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_pmrv_pk_csr%ISOPEN THEN
        CLOSE okl_pmrv_pk_csr;
      END IF;

  END Validate_Pmr_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_sequence_number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_sequence_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_sequence_number(p_fprv_rec      IN   fprv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_token_1               VARCHAR2(1999);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    l_token_1 := Okl_Accounting_Util.Get_Message_Token('OKL_LP_FNCT_PARMS_CRUPD','OKL_SEQUENCE');

    -- check for data before processing
    IF (p_fprv_rec.sequence_number IS NULL) AND (p_fprv_rec.sequence_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => Okl_fpr_Pvt.g_app_name
                          ,p_msg_name       => Okl_fpr_Pvt.g_required_value
                          ,p_token1         => Okl_fpr_Pvt.g_col_name_token
                          ,p_token1_value   => l_token_1);

       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => Okl_Pdt_Pvt.g_app_name,
                          p_msg_name     => Okl_Pdt_Pvt.g_unexpected_error,
                          p_token1       => Okl_Pdt_Pvt.g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => Okl_Pdt_Pvt.g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_sequence_number;

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
    p_fprv_rec IN  fprv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

      -- Validate_Pmr_Id
    Validate_Pmr_Id(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_sequence_number
    Validate_sequence_number(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_PROCESSING;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

  RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
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
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_dsfparameters for: OKL_FNCTN_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_dsfparameters(p_api_version     IN  NUMBER,
                        		  p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status  OUT NOCOPY VARCHAR2,
                        		  x_msg_count      OUT NOCOPY NUMBER,
                        		  x_msg_data       OUT NOCOPY VARCHAR2,
								  p_dsfv_rec	   IN  dsfv_rec_type,
                        		  p_fprv_rec       IN  fprv_rec_type,
                        		  x_fprv_rec       OUT NOCOPY fprv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_dsfparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_dsfv_rec		  dsfv_rec_type;
	l_fprv_rec		  fprv_rec_type;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_return_status := OKC_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	l_dsfv_rec := p_dsfv_rec;
	l_fprv_rec := p_fprv_rec;

    l_return_status := Validate_Attributes(l_fprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

	/* call check_constraints to check the validity of this relationship */
	check_constraints(p_fprv_rec 		=> l_fprv_rec,
				   	  x_return_status	=> l_return_status,
				   	  x_valid			=> l_valid);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		   (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := OKL_API.G_RET_STS_ERROR;
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	/* public api to insert function parameters */
    okl_fnctn_prmtrs_pub.insert_fnctn_prmtrs(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 	   	 x_return_status => l_return_status,
                              		 	   	 x_msg_count     => x_msg_count,
                              		 	   	 x_msg_data      => x_msg_data,
                              		 	   	 p_fprv_rec      => l_fprv_rec,
                              		 	   	 x_fprv_rec      => x_fprv_rec);

     IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END insert_dsfparameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_dsfparameters for: OKL_FNCTN_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_dsfparameters(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
								  p_dsfv_rec		IN  dsfv_rec_type,
                        		  p_fprv_rec        IN  fprv_rec_type,
                        		  x_fprv_rec        OUT NOCOPY fprv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_dsfparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_dsfv_rec		  dsfv_rec_type;
	l_fprv_rec		  fprv_rec_type;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_return_status := OKC_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	l_dsfv_rec := p_dsfv_rec;
	l_fprv_rec := p_fprv_rec;

	/* call check_constraints to check the validity of this relationship */
	check_constraints(p_fprv_rec 		=> l_fprv_rec,
				      x_return_status	=> l_return_status,
				   	  x_valid			=> l_valid);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		   (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := OKL_API.G_RET_STS_ERROR;
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	/* public api to insert function parameters */
    okl_fnctn_prmtrs_pub.update_fnctn_prmtrs(p_api_version   => p_api_version,
                              		 	     p_init_msg_list => p_init_msg_list,
                              		 	   	 x_return_status => l_return_status,
                              		 	   	 x_msg_count     => x_msg_count,
                              		 	   	 x_msg_data      => x_msg_data,
                              		 	   	 p_fprv_rec      => l_fprv_rec,
                              		 	   	 x_fprv_rec      => x_fprv_rec);

     IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END update_dsfparameters;


  ---------------------------------------------------------------------------
  -- PROCEDURE delete_dsfparameters for: OKL_FNCTN_PRMTRS_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_dsfparameters(p_api_version          IN  NUMBER,
                                 p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		 x_return_status        OUT NOCOPY VARCHAR2,
                        		 x_msg_count            OUT NOCOPY NUMBER,
                        		 x_msg_data             OUT NOCOPY VARCHAR2,
                        		 p_fprv_tbl             IN  fprv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_fprv_tbl        fprv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_dsfparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_return_status := OKC_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	l_fprv_tbl := p_fprv_tbl;

	/* delete formulae constraints */
    okl_fnctn_prmtrs_pub.delete_fnctn_prmtrs(p_api_version   => p_api_version,
                              		         p_init_msg_list => p_init_msg_list,
                              		 		 x_return_status => l_return_status,
                              		 		 x_msg_count     => x_msg_count,
                              		 		 x_msg_data      => x_msg_data,
                              		 		 p_fprv_tbl      => l_fprv_tbl);

     IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKC_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END delete_dsfparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FNCTN_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_dsfparameters for: OKL_FNCTN_PRMTRS_V - TBL
  ---------------------------------------------------------------------------
  PROCEDURE insert_dsfparameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   	p_dsfv_rec					   IN dsfv_rec_type,
    p_fprv_tbl                     IN fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_dsfparameters';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP
        insert_dsfparameters (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          p_dsfv_rec                     => p_dsfv_rec,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i),
          x_fprv_rec                     => x_fprv_tbl(i));

          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;


        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;

      -- return overall status
      x_return_status := l_overall_status;


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
  END insert_dsfparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FNCTN_PRMTRS_V - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FNCTN_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE update_dsfparameters for: OKL_FNCTN_PRMTRS_V -TBL
  ---------------------------------------------------------------------------
  PROCEDURE update_dsfparameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   	p_dsfv_rec					   IN dsfv_rec_type,
    p_fprv_tbl                     IN fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_dsfparameters';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP

        update_dsfparameters (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          p_dsfv_rec                     => p_dsfv_rec,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i),
          x_fprv_rec                     => x_fprv_tbl(i));


          -- store the highest degree of error
          IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
             IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
                l_overall_status := x_return_status;
             END IF;
          END IF;


        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;

      -- return overall status
      x_return_status := l_overall_status;


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
  END update_dsfparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FNCTN_PRMTRS_V - TBL : end


END OKL_SETUPDSFPARAMETERS_PVT;

/
