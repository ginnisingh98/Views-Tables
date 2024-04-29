--------------------------------------------------------
--  DDL for Package Body OKL_SETUPCGRPARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPCGRPARAMETERS_PVT" AS
/* $Header: OKLRSCMB.pls 120.1 2005/06/03 05:30:33 rirawat noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_cgmv_rec                     IN cgmv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_cgmv_rec					   OUT NOCOPY cgmv_rec_type
  ) IS
    CURSOR okl_cgmv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			CGR_ID,
			PMR_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Cntx_Grp_Prmtrs_V
     WHERE okl_Cntx_Grp_Prmtrs_V.id    = p_id;
    l_okl_cgmv_pk                  okl_cgmv_pk_csr%ROWTYPE;
    l_cgmv_rec                     cgmv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_cgmv_pk_csr (p_cgmv_rec.id);
    FETCH okl_cgmv_pk_csr INTO
              l_cgmv_rec.ID,
              l_cgmv_rec.OBJECT_VERSION_NUMBER,
			  l_cgmv_rec.CGR_ID,
			  l_cgmv_rec.PMR_ID,
              l_cgmv_rec.CREATED_BY,
              l_cgmv_rec.CREATION_DATE,
              l_cgmv_rec.LAST_UPDATED_BY,
              l_cgmv_rec.LAST_UPDATE_DATE,
              l_cgmv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cgmv_pk_csr%NOTFOUND;
    CLOSE okl_cgmv_pk_csr;
    x_cgmv_rec := l_cgmv_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1	    =>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_cgmv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_cgmv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_context_groups for: OKL_CNTX_GRP_PRMTRS_V
  -- To verify whether context group under consideration is being attached to
  -- any formula
  ---------------------------------------------------------------------------
  PROCEDURE check_context_groups (
	p_cgmv_rec		IN cgmv_rec_type,
	x_return_status	OUT NOCOPY VARCHAR2,
    x_valid         OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_fmav_fk_csr (p_cgr_id IN Okl_Formulae_V.cgr_id%TYPE
	) IS
    SELECT '1'
    FROM Okl_Formulae_V fma
    WHERE fma.CGR_ID    = p_cgr_id;

	l_check		   	VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for related formulae
    OPEN okl_fmav_fk_csr (p_cgmv_rec.cgr_id);
    FETCH okl_fmav_fk_csr INTO l_check;
    l_row_not_found := okl_fmav_fk_csr%NOTFOUND;
    CLOSE okl_fmav_fk_csr;

    IF l_row_not_found = FALSE then
	   OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_IN_USE,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Okl_Formulae_V',
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Okl_Context_Groups_V');
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

       IF (okl_fmav_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_fmav_fk_csr;
       END IF;


  END check_context_groups;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_cgrparameters for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_cgrparameters(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
                        		  p_cgmv_rec        IN  cgmv_rec_type,
                        		  x_cgmv_rec        OUT NOCOPY cgmv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_cgrparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_cgmv_rec		  cgmv_rec_type;
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

	l_cgmv_rec := p_cgmv_rec;

	/* public api to insert context group parameters */
    okl_cntx_grp_prmtrs_pub.insert_cntx_grp_prmtrs(p_api_version   => p_api_version,
                              		               p_init_msg_list => p_init_msg_list,
                              		 	   		   x_return_status => l_return_status,
                              		 	   		   x_msg_count     => x_msg_count,
                              		 	   		   x_msg_data      => x_msg_data,
                              		 	   		   p_cgmv_rec      => l_cgmv_rec,
                              		 	   		   x_cgmv_rec      => x_cgmv_rec);

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

  END insert_cgrparameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_cgrparameters for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_cgrparameters(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
                        		  p_cgmv_rec        IN  cgmv_rec_type,
                        		  x_cgmv_rec        OUT NOCOPY cgmv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_cgrparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_cgmv_rec		  cgmv_rec_type;
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

	l_cgmv_rec := p_cgmv_rec;

	/* call check_context_groups to check whether it is affecting existing formulae */
	check_context_groups(p_cgmv_rec 		=> l_cgmv_rec,
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

	/* public api to update context groups */
    okl_cntx_grp_prmtrs_pub.update_cntx_grp_prmtrs(p_api_version   => p_api_version,
                              		 	           p_init_msg_list => p_init_msg_list,
                              		 	   		   x_return_status => l_return_status,
                              		 	   		   x_msg_count     => x_msg_count,
                              		 	   		   x_msg_data      => x_msg_data,
                              		 	   		   p_cgmv_rec      => l_cgmv_rec,
                              		 	   		   x_cgmv_rec      => x_cgmv_rec);

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

  END update_cgrparameters;


  ---------------------------------------------------------------------------
  -- PROCEDURE delete_cgrparameters for: OKL_CNTX_GRP_PRMTRS_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_cgrparameters(p_api_version          IN  NUMBER,
                                 p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		 x_return_status        OUT NOCOPY VARCHAR2,
                        		 x_msg_count            OUT NOCOPY NUMBER,
                        		 x_msg_data             OUT NOCOPY VARCHAR2,
                        		 p_cgmv_tbl             IN  cgmv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_cgmv_tbl        cgmv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_cgrparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status  VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	i				  NUMBER;

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

	l_cgmv_tbl := p_cgmv_tbl;
    IF (l_cgmv_tbl.COUNT > 0) THEN
      i := l_cgmv_tbl.FIRST;

      LOOP
	  	  check_context_groups(p_cgmv_rec 		=> l_cgmv_tbl(i),
				               x_return_status	=> l_return_status,
				   		   	   x_valid			=> l_valid);
		  -- store the highest degree of error
		  IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := l_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = l_cgmv_tbl.LAST);

          i := l_cgmv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   l_return_status := l_overall_status;
     END IF;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		   (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	l_valid <> TRUE) THEN
       x_return_status    := OKL_API.G_RET_STS_ERROR;
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	/* delete context group parameters */
    okl_cntx_grp_prmtrs_pub.delete_cntx_grp_prmtrs(p_api_version   => p_api_version,
                              		               p_init_msg_list => p_init_msg_list,
                              		 		 	   x_return_status => l_return_status,
                              		 		 	   x_msg_count     => x_msg_count,
                              		 		 	   x_msg_data      => x_msg_data,
                              		 		 	   p_cgmv_tbl      => l_cgmv_tbl);

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

  END delete_cgrparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_CNTX_GRP_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_cgrparameters for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_cgrparameters(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
                        		  p_cgmv_tbl        IN  cgmv_tbl_type,
                        		  x_cgmv_tbl        OUT NOCOPY cgmv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_cgrparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_cgmv_rec		  cgmv_rec_type;
    i                 NUMBER := 0;
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

    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
    LOOP
	    l_cgmv_rec := p_cgmv_tbl(i);

	   /* public api to insert context group parameters */
        okl_cntx_grp_prmtrs_pub.insert_cntx_grp_prmtrs(p_api_version   => p_api_version,
                                  		               p_init_msg_list => p_init_msg_list,
                                    		 	   	   x_return_status => l_return_status,
                             		 	   		       x_msg_count     => x_msg_count,
                                  		 	   		   x_msg_data      => x_msg_data,
                                  		 	   		   p_cgmv_rec      => l_cgmv_rec,
                                  		 	   		   x_cgmv_rec      => x_cgmv_tbl(i));

         IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         ELSIF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

     EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
     END LOOP;

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

  END insert_cgrparameters;
-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_CNTX_GRP_PRMTRS_V - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_CNTX_GRP_PRMTRS_V - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE update_cgrparameters for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_cgrparameters(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
                        		  p_cgmv_tbl        IN  cgmv_tbl_type,
                        		  x_cgmv_tbl        OUT NOCOPY cgmv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_cgrparameters';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_cgmv_rec		  cgmv_rec_type;
    i                 NUMBER := 0;
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


    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
      LOOP

    	l_cgmv_rec := p_cgmv_tbl(i);

    	/* call check_context_groups to check whether it is affecting existing formulae */
    	check_context_groups(p_cgmv_rec 		=> l_cgmv_rec,
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

    	/* public api to update context groups */
        okl_cntx_grp_prmtrs_pub.update_cntx_grp_prmtrs(p_api_version   => p_api_version,
                                  		 	           p_init_msg_list => p_init_msg_list,
                                  		 	   		   x_return_status => l_return_status,
                                  		 	   		   x_msg_count     => x_msg_count,
                                  		 	   		   x_msg_data      => x_msg_data,
                                  		 	   		   p_cgmv_rec      => l_cgmv_rec,
                                  		 	   		   x_cgmv_rec      => x_cgmv_tbl(i));

         IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
         ELSIF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

     EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
     END LOOP;

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

  END update_cgrparameters;

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_CNTX_GRP_PRMTRS_V - TBL : end


END OKL_SETUPCGRPARAMETERS_PVT;

/
