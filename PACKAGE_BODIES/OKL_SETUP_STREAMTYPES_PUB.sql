--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_STREAMTYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_STREAMTYPES_PUB" AS
/* $Header: OKLPSMTB.pls 115.5 2004/04/13 11:18:05 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE create_stream_type for: OKL_STRM_TYPE_V
  -- Public Wrapper for create_stream_type Process API
  ---------------------------------------------------------------------------
  PROCEDURE create_stream_type(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_styv_rec                     IN  styv_rec_type,
      		                  	x_styv_rec                     OUT NOCOPY styv_rec_type
                        ) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_stream_type';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
	l_styv_rec		  styv_rec_type;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
    l_api_version     CONSTANT NUMBER := 1;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;

    l_styv_rec := p_styv_rec;

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



	-- call process api to create_stream_type
    okl_setup_streamtypes_pvt.create_stream_type(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_styv_rec      => l_styv_rec,
                              			  x_styv_rec      => x_styv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_styv_rec := x_styv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END create_stream_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_stream_type for: OKL_STRM_TYPE_V
  -- Public Wrapper for Process API
  ---------------------------------------------------------------------------
  PROCEDURE update_stream_type(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_styv_rec                     IN  styv_rec_type,
                        	x_styv_rec                     OUT NOCOPY styv_rec_type
                        ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_stream_type';
    l_api_version     CONSTANT NUMBER := 1;
	l_styv_rec	  	 	  	styv_rec_type;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    l_styv_rec := p_styv_rec;

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



	-- call process api to update formulae
    okl_setup_streamtypes_pvt.update_stream_type(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_styv_rec      => l_styv_rec,
                              			  x_styv_rec      => x_styv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_styv_rec := x_styv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END update_stream_type;

  PROCEDURE create_stream_type(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_styv_tbl                     IN  styv_tbl_type,
         x_styv_tbl                     OUT NOCOPY styv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_stream_type_tbl';
	rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

 	FOR rec_num	IN 1..p_styv_tbl.COUNT
	LOOP
		create_stream_type(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_styv_rec                     => p_styv_tbl(rec_num),
         x_styv_rec                     => x_styv_tbl(rec_num) );

       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	END LOOP;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

  END create_stream_type;


  PROCEDURE update_stream_type(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_styv_tbl                     IN  styv_tbl_type,
         x_styv_tbl                     OUT NOCOPY styv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_stream_type_tbl';
	rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

 	FOR rec_num	IN 1.. p_styv_tbl.COUNT
	LOOP
		update_stream_type(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_styv_rec                     => p_styv_tbl(rec_num),
         x_styv_rec                     => x_styv_tbl(rec_num) );

       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	END LOOP;
        OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

  END update_stream_type;

END OKL_SETUP_STREAMTYPES_PUB;

/
