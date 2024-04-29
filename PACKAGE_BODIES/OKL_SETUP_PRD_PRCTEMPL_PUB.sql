--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_PRD_PRCTEMPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_PRD_PRCTEMPL_PUB" AS
/* $Header: OKLPPPEB.pls 115.5 2004/04/13 10:58:04 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_prd_price_tmpls for: OKL_PRD_PRC_TMPLS_V
  -- Public Wrapper for insert_prd_price_tmpls Process API
  ---------------------------------------------------------------------------
  PROCEDURE insert_prd_price_tmpls(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_pitv_rec                     IN  pitv_rec_type,
      		                  	x_pitv_rec                     OUT NOCOPY pitv_rec_type
                        ) IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_prd_price_tmpls';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
	l_pitv_rec		  pitv_rec_type;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := G_RET_STS_SUCCESS;

    l_pitv_rec := p_pitv_rec;
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



	-- call process api to insert_prd_price_tmpls
    OKL_SETUP_PRD_PRCTEMPL_PVT.insert_prd_price_tmpls(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pitv_rec      => l_pitv_rec,
                              			  x_pitv_rec      => x_pitv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pitv_rec := x_pitv_rec;


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
  END insert_prd_price_tmpls;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_prd_price_tmpls for: OKL_PRD_PRC_TMPLS_V
  -- Public Wrapper for Process API
  ---------------------------------------------------------------------------
  PROCEDURE update_prd_price_tmpls(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_pitv_rec                     IN  pitv_rec_type,
                        	x_pitv_rec                     OUT NOCOPY pitv_rec_type
                        ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_prd_price_tmpls';
    l_api_version     CONSTANT NUMBER := 1;
    l_pitv_rec	  	 	  	pitv_rec_type;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := G_RET_STS_SUCCESS;

    l_pitv_rec := p_pitv_rec;

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
    OKL_SETUP_PRD_PRCTEMPL_PVT.update_prd_price_tmpls(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pitv_rec      => l_pitv_rec,
                              			  x_pitv_rec      => x_pitv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pitv_rec := x_pitv_rec;


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
  END update_prd_price_tmpls;

  PROCEDURE insert_prd_price_tmpls(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pitv_tbl                     IN  pitv_tbl_type,
         x_pitv_tbl                     OUT NOCOPY pitv_tbl_type)
   IS
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'insert_prd_price_tmpls_tbl';
	rec_num		INTEGER	:= 0;
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

 	FOR rec_num IN 1..p_pitv_tbl.COUNT
	LOOP
		insert_prd_price_tmpls(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_pitv_rec                     => p_pitv_tbl(rec_num),
         x_pitv_rec                     => x_pitv_tbl(rec_num) );

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

  END insert_prd_price_tmpls;


  PROCEDURE update_prd_price_tmpls(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pitv_tbl                     IN  pitv_tbl_type,
         x_pitv_tbl                     OUT NOCOPY pitv_tbl_type)
   IS
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_prd_price_tmpls_tbl';
	rec_num		INTEGER	:= 0;
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

 	FOR rec_num IN 1..p_pitv_tbl.COUNT
	LOOP
		update_prd_price_tmpls(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_pitv_rec                     => p_pitv_tbl(rec_num),
         x_pitv_rec                     => x_pitv_tbl(rec_num) );

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

  END update_prd_price_tmpls;

 PROCEDURE check_product_constraints(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
	p_pdtv_rec			IN  pdtv_rec_type,
        x_validated		       OUT NOCOPY VARCHAR2)
IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'check_product_constraints';
    l_api_version     CONSTANT NUMBER := 1;
    l_pdtv_rec	  	 	  	pdtv_rec_type;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
	l_validated VARCHAR2(1);
	l_valid BOOLEAN := TRUE;
BEGIN


    l_pdtv_rec := p_pdtv_rec;
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
    OKL_SETUP_PRD_PRCTEMPL_PVT.check_product_constraints(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pdtv_rec      => l_pdtv_rec,
                              			  x_validated      => l_validated);
	 l_valid := FND_API.TO_BOOLEAN(l_validated);
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) OR
		  	    (l_return_status = G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
        RAISE G_EXCEPTION_ERROR;
     END IF;


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

 END check_product_constraints;

 PROCEDURE check_product_constraints(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
	p_pdtv_tbl			IN  pdtv_tbl_type,
        x_validated		       OUT NOCOPY VARCHAR2)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'check_product_constraints_tbl';
	rec_num		INTEGER	:= 0;
	l_validated VARCHAR2(1);
	l_valid BOOLEAN := TRUE;
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
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

 	FOR rec_num IN 1..p_pdtv_tbl.COUNT
	LOOP
		check_product_constraints(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_pdtv_rec                     => p_pdtv_tbl(rec_num),
         x_validated                        => l_validated );
	 l_valid := FND_API.TO_BOOLEAN(l_validated);
	     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
	       RAISE G_EXCEPTION_ERROR;
	     ELSIF (l_return_status = G_RET_STS_ERROR) OR
				    (l_return_status = G_RET_STS_SUCCESS AND
				     l_valid <> TRUE) THEN
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

  END check_product_constraints;

END OKL_SETUP_PRD_PRCTEMPL_PUB;

/
