--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_TRXPARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_TRXPARAMS_PUB" AS
/* $Header: OKLPTXRB.pls 115.0 2004/07/02 02:37:12 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE create_trx_parm for: OKL_SIF_TRX_PARMS_V
  -- Public Wrapper for create_trx_parm Process API
  ---------------------------------------------------------------------------
  PROCEDURE create_trx_parm(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_sxpv_rec                     IN  sxpv_rec_type,
      		                  	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_trx_parm';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_sxpv_rec		  sxpv_rec_type;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    l_sxpv_rec := p_sxpv_rec;

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





	-- call process api to create_trx_parm
    OKL_SETUP_TRXPARAMS_PVT.create_trx_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sxpv_rec      => l_sxpv_rec,
                              			  x_sxpv_rec      => x_sxpv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sxpv_rec := x_sxpv_rec;


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
  END create_trx_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_trx_parm for: OKL_SIF_TRX_PARMS_V
  -- Public Wrapper for Process API
  ---------------------------------------------------------------------------
  PROCEDURE update_trx_parm(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_sxpv_rec                     IN  sxpv_rec_type,
                        	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_trx_parm';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
	l_sxpv_rec	  	 	  	sxpv_rec_type;

    l_data            VARCHAR2(100);
    l_count           NUMBER ;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    l_sxpv_rec := p_sxpv_rec;

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
    OKL_SETUP_TRXPARAMS_PVT.update_trx_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sxpv_rec      => l_sxpv_rec,
                              			  x_sxpv_rec      => x_sxpv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sxpv_rec := x_sxpv_rec;


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
END update_trx_parm;

  PROCEDURE create_trx_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_sxpv_tbl                     IN  sxpv_tbl_type,
         x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_trx_parm_tbl';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
	rec_num		INTEGER	:= 0;
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

 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
		create_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
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
  END create_trx_parm;


  PROCEDURE update_trx_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_sxpv_tbl                     IN  sxpv_tbl_type,
         x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_trx_parm_tbl';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
	rec_num		INTEGER	:= 0;
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

 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
		update_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
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
 END update_trx_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_trx_parm for: OKL_SIF_TRX_PARMS_V
  -- Public Wrapper for Process API
  ---------------------------------------------------------------------------
  PROCEDURE delete_trx_parm(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_sxpv_rec                     IN  sxpv_rec_type,
                        	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'delete_trx_parm';
    l_api_version     CONSTANT NUMBER := 1;
	l_sxpv_rec	  	 	  	sxpv_rec_type;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    l_sxpv_rec := p_sxpv_rec;

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



	-- call process api to delete formulae
    OKL_SETUP_TRXPARAMS_PVT.delete_trx_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sxpv_rec      => l_sxpv_rec,
                              			  x_sxpv_rec      => x_sxpv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sxpv_rec := x_sxpv_rec;



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
  END delete_trx_parm;

  PROCEDURE delete_trx_parm(
           p_api_version                  IN  NUMBER,
           p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
           x_return_status                OUT NOCOPY VARCHAR2,
           x_msg_count                    OUT NOCOPY NUMBER,
           x_msg_data                     OUT NOCOPY VARCHAR2,
           p_sxpv_tbl                     IN  sxpv_tbl_type,
           x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type)
     IS
      l_api_name        	  	CONSTANT VARCHAR2(30)  := 'delete_trx_parm_tbl';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
  	rec_num		INTEGER	:= 0;
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

   	FOR rec_num IN 1..p_sxpv_tbl.COUNT
  	LOOP
  		delete_trx_parm(
           p_api_version                  => p_api_version,
           p_init_msg_list                => p_init_msg_list,
           x_return_status                => l_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_sxpv_rec                     => p_sxpv_tbl(rec_num),
           x_sxpv_rec                     => x_sxpv_tbl(rec_num) );

	    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
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
    END delete_trx_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_trx_asset_parm for: OKL_SIF_TRX_PARMS_V
  -- Public Wrapper for create_trx_asset_parm Process API
  ---------------------------------------------------------------------------
  PROCEDURE create_trx_asset_parm(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_sxpv_rec                     IN  sxpv_rec_type,
      		                  	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_trx_asset_parm';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_sxpv_rec		  sxpv_rec_type;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    l_sxpv_rec := p_sxpv_rec;

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





	-- call process api to create_trx_asset_parm
    OKL_SETUP_TRXPARAMS_PVT.create_trx_asset_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sxpv_rec      => l_sxpv_rec,
                              			  x_sxpv_rec      => x_sxpv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sxpv_rec := x_sxpv_rec;


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
  END create_trx_asset_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_trx_asset_parm for: OKL_SIF_TRX_PARMS_V
  -- Public Wrapper for Process API
  ---------------------------------------------------------------------------
  PROCEDURE update_trx_asset_parm(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_sxpv_rec                     IN  sxpv_rec_type,
                        	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_trx_asset_parm';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
	l_sxpv_rec	  	 	  	sxpv_rec_type;

    l_data            VARCHAR2(100);
    l_count           NUMBER ;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    l_sxpv_rec := p_sxpv_rec;

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
    OKL_SETUP_TRXPARAMS_PVT.update_trx_asset_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sxpv_rec      => l_sxpv_rec,
                              			  x_sxpv_rec      => x_sxpv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sxpv_rec := x_sxpv_rec;


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
END update_trx_asset_parm;

  PROCEDURE create_trx_asset_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_sxpv_tbl                     IN  sxpv_tbl_type,
         x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_trx_asset_parm_tbl';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
	rec_num		INTEGER	:= 0;
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

 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
		create_trx_asset_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
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
  END create_trx_asset_parm;


  PROCEDURE update_trx_asset_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_sxpv_tbl                     IN  sxpv_tbl_type,
         x_sxpv_tbl                     OUT NOCOPY sxpv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_trx_asset_parm_tbl';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
	rec_num		INTEGER	:= 0;
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

 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
		update_trx_asset_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
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
 END update_trx_asset_parm;


END OKL_SETUP_TRXPARAMS_PUB;

/
