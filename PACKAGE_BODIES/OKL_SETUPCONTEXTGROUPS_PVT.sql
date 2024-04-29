--------------------------------------------------------
--  DDL for Package Body OKL_SETUPCONTEXTGROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPCONTEXTGROUPS_PVT" AS
/* $Header: OKLRSCGB.pls 115.2 2002/07/17 23:20:46 santonyr noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_CONTEXT_GROUPS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_cgrv_rec                     IN cgrv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_cgrv_rec					   OUT NOCOPY cgrv_rec_type
  ) IS
    CURSOR okl_cgrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			SFWT_FLAG,
			NAME,
			NVL(DESCRIPTION, OKL_API.G_MISS_CHAR) DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Context_Groups_V
     WHERE okl_Context_Groups_V.id    = p_id;
    l_okl_cgrv_pk                  okl_cgrv_pk_csr%ROWTYPE;
    l_cgrv_rec                     cgrv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_cgrv_pk_csr (p_cgrv_rec.id);
    FETCH okl_cgrv_pk_csr INTO
              l_cgrv_rec.ID,
              l_cgrv_rec.OBJECT_VERSION_NUMBER,
			  l_cgrv_rec.SFWT_FLAG,
			  l_cgrv_rec.NAME,
			  l_cgrv_rec.DESCRIPTION,
              l_cgrv_rec.CREATED_BY,
              l_cgrv_rec.CREATION_DATE,
              l_cgrv_rec.LAST_UPDATED_BY,
              l_cgrv_rec.LAST_UPDATE_DATE,
              l_cgrv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cgrv_pk_csr%NOTFOUND;
    CLOSE okl_cgrv_pk_csr;
    x_cgrv_rec := l_cgrv_rec;
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

      IF (okl_cgrv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_cgrv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_contextgroups for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_contextgroups(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
                        		  p_cgrv_rec        IN  cgrv_rec_type,
                        		  x_cgrv_rec        OUT NOCOPY cgrv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_contextgroups';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_cgrv_rec		  cgrv_rec_type;
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

	l_cgrv_rec := p_cgrv_rec;

	/* public api to insert context groups */
    okl_context_groups_pub.insert_context_groups(p_api_version   => p_api_version,
                              		             p_init_msg_list => p_init_msg_list,
                              		 	   		 x_return_status => l_return_status,
                              		 	   		 x_msg_count     => x_msg_count,
                              		 	   		 x_msg_data      => x_msg_data,
                              		 	   		 p_cgrv_rec      => l_cgrv_rec,
                              		 	   		 x_cgrv_rec      => x_cgrv_rec);

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

  END insert_contextgroups;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_contextgroups for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_contextgroups(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
                        		  p_cgrv_rec        IN  cgrv_rec_type,
                        		  x_cgrv_rec        OUT NOCOPY cgrv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_contextgroups';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_cgrv_rec		  cgrv_rec_type;
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

	l_cgrv_rec := p_cgrv_rec;

	/* public api to update context groups */
    okl_context_groups_pub.update_context_groups(p_api_version   => p_api_version,
                              		 	         p_init_msg_list => p_init_msg_list,
                              		 	   		 x_return_status => l_return_status,
                              		 	   		 x_msg_count     => x_msg_count,
                              		 	   		 x_msg_data      => x_msg_data,
                              		 	   		 p_cgrv_rec      => l_cgrv_rec,
                              		 	   		 x_cgrv_rec      => x_cgrv_rec);

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

  END update_contextgroups;

END OKL_SETUPCONTEXTGROUPS_PVT;

/
