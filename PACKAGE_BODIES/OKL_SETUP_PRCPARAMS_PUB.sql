--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_PRCPARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_PRCPARAMS_PUB" AS
/* $Header: OKLPPPRB.pls 115.1 2004/07/02 02:36:49 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE create_price_parm for: OKL_SIF_PRICE_PARMS_V
  -- Public Wrapper for create_price_parm Process API
  ---------------------------------------------------------------------------
  PROCEDURE create_price_parm(	p_api_version                  IN  NUMBER,
	                        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
   	 	                    	p_sppv_rec                     IN  sppv_rec_type,
      		                  	x_sppv_rec                     OUT NOCOPY sppv_rec_type,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2
                        ) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_price_parm';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
	l_sppv_rec		  sppv_rec_type;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    l_sppv_rec := p_sppv_rec;

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



	-- call process api to create_price_parm
    OKL_SETUP_PRCPARAMS_pvt.create_price_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sppv_rec      => l_sppv_rec,
                              			  x_sppv_rec      => x_sppv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXC_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sppv_rec := x_sppv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
			 x_msg_data	  => x_msg_data);
    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXC_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						  p_pkg_name	=> G_PKG_NAME,
						  p_exc_name   => G_EXC_NAME_RET_STS_ERR,
						  x_msg_count	=> x_msg_count,
						  x_msg_data	=> x_msg_data,
						  p_api_type	=> G_API_TYPE);

    WHEN G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						   p_pkg_name	=> G_PKG_NAME,
						   p_exc_name   => G_EXC_NAME_RET_STS_UNEXP_ERR,
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

  END create_price_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_price_parm for: OKL_SIF_PRICE_PARMS_V
  -- Public Wrapper for Process API
  ---------------------------------------------------------------------------
  PROCEDURE update_price_parm(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
                              p_sppv_rec                     IN  sppv_rec_type,
                              x_sppv_rec                     OUT NOCOPY sppv_rec_type,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2
                        ) IS

    l_api_name		CONSTANT VARCHAR2(30)  := 'update_price_parm';
    l_api_version	CONSTANT NUMBER := 1;
    l_sppv_rec	  	sppv_rec_type;
    l_return_status    	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            	VARCHAR2(100);
    l_count           	NUMBER ;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    l_sppv_rec := p_sppv_rec;

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
    OKL_SETUP_PRCPARAMS_pvt.update_price_parm(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_sppv_rec      => l_sppv_rec,
                              			  x_sppv_rec      => x_sppv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXC_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_sppv_rec := x_sppv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
			 x_msg_data	  => x_msg_data);
    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXC_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						  p_pkg_name	=> G_PKG_NAME,
						  p_exc_name   => G_EXC_NAME_RET_STS_ERR,
						  x_msg_count	=> x_msg_count,
						  x_msg_data	=> x_msg_data,
						  p_api_type	=> G_API_TYPE);

    WHEN G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						   p_pkg_name	=> G_PKG_NAME,
						   p_exc_name   => G_EXC_NAME_RET_STS_UNEXP_ERR,
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
  END update_price_parm;

  PROCEDURE create_price_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
         p_sppv_tbl                     IN  sppv_tbl_type,
         x_sppv_tbl                     OUT NOCOPY sppv_tbl_type,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_price_parm';
	rec_num		INTEGER	:= 0;
   BEGIN
 	rec_num	:= p_sppv_tbl.FIRST;
	LOOP
		create_price_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sppv_rec                     => p_sppv_tbl(rec_num),
         x_sppv_rec                     => x_sppv_tbl(rec_num) );
	EXIT WHEN (rec_num = p_sppv_tbl.LAST);
	rec_num	:= p_sppv_tbl.NEXT(rec_num);
	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						  p_pkg_name	=> G_PKG_NAME,
						  p_exc_name   => G_EXC_NAME_RET_STS_ERR,
						  x_msg_count	=> x_msg_count,
						  x_msg_data	=> x_msg_data,
						  p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						   p_pkg_name	=> G_PKG_NAME,
						   p_exc_name   => G_EXC_NAME_RET_STS_UNEXP_ERR,
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

  END create_price_parm;


  PROCEDURE update_price_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
         p_sppv_tbl                     IN  sppv_tbl_type,
         x_sppv_tbl                     OUT NOCOPY sppv_tbl_type,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_price_parm';
	rec_num		INTEGER	:= 0;
   BEGIN
 	rec_num	:= p_sppv_tbl.FIRST;
	LOOP
		update_price_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sppv_rec                     => p_sppv_tbl(rec_num),
         x_sppv_rec                     => x_sppv_tbl(rec_num) );
	EXIT WHEN (rec_num = p_sppv_tbl.LAST);
	rec_num	:= p_sppv_tbl.NEXT(rec_num);
	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
     x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						  p_pkg_name	=> G_PKG_NAME,
						  p_exc_name   => G_EXC_NAME_RET_STS_ERR,
						  x_msg_count	=> x_msg_count,
						  x_msg_data	=> x_msg_data,
						  p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
						   p_pkg_name	=> G_PKG_NAME,
						   p_exc_name   => G_EXC_NAME_RET_STS_UNEXP_ERR,
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

  END update_price_parm;

END OKL_SETUP_PRCPARAMS_PUB;

/
