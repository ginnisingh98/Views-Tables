--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_STRMS_TRANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_STRMS_TRANS_PUB" AS
/* $Header: OKLPSMNB.pls 115.6 2004/04/13 11:17:54 rnaik noship $ */

  PROCEDURE insert_translations (p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
								,p_sgnv_tbl           IN     sgnv_tbl_type
        	                    ,x_sgnv_tbl           OUT    NOCOPY sgnv_tbl_type
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2
  ) IS
	l_api_name VARCHAR2(20):= 'insert_translations';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
	i NUMBER;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => 'OKL_SETUP_STRMS_TRANS_PUB',
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PUB',
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



    OKL_SETUP_STRMS_TRANS_PVT.insert_translations (p_api_version      => l_api_version
                                                  ,p_init_msg_list    => p_init_msg_list
                                                  ,p_sgnv_tbl         => p_sgnv_tbl
                                                  ,x_sgnv_tbl         => x_sgnv_tbl
                                                  ,x_return_status    => l_return_status
                                                  ,x_msg_count        => x_msg_count
                                                  ,x_msg_data         => x_msg_data);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



	OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
	  					 x_msg_data	  => x_msg_data);

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count  => x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');
  END insert_translations;

  PROCEDURE update_translations (p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
								,p_sgnv_tbl           IN     sgnv_tbl_type
        	                    ,x_sgnv_tbl           OUT    NOCOPY sgnv_tbl_type
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2
  ) IS
	l_api_name VARCHAR2(20):= 'update_translations';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
	i NUMBER;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => 'OKL_SETUP_STRMS_TRANS_PUB',
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PUB',
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



    OKL_SETUP_STRMS_TRANS_PVT.update_translations (p_api_version        => l_api_version
                                                  ,p_init_msg_list    => p_init_msg_list
                                                  ,p_sgnv_tbl         => p_sgnv_tbl
                                                  ,x_sgnv_tbl         => x_sgnv_tbl
                                                  ,x_return_status    => x_return_status
                                                  ,x_msg_count        => x_msg_count
                                                  ,x_msg_data         => x_msg_data);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



	OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
	  					 x_msg_data	  => x_msg_data);

    x_return_status := l_return_status;

    EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						     p_pkg_name	=> G_PKG_NAME,
												     p_exc_name => G_EXC_NAME_ERROR,
												     x_msg_count=> x_msg_count,
												     x_msg_data	=> x_msg_data,
												     p_api_type	=> '_PUB');

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');

      WHEN OTHERS THEN

        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');

  END update_translations;

  PROCEDURE delete_translations (p_api_version        IN     NUMBER
                                ,p_init_msg_list      IN     VARCHAR2
        	                    ,p_sgnv_tbl           IN     sgnv_tbl_type
                                ,x_return_status      OUT    NOCOPY VARCHAR2
                                ,x_msg_count          OUT    NOCOPY NUMBER
                                ,x_msg_data           OUT    NOCOPY VARCHAR2
  ) IS
	l_api_name VARCHAR2(20):= 'delete_translations';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
	i NUMBER;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => 'OKL_SETUP_STRMS_TRANS_PUB',
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PUB',
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



    OKL_SETUP_STRMS_TRANS_PVT.delete_translations (p_api_version        => l_api_version
                                                  ,p_init_msg_list      => p_init_msg_list
                                                  ,p_sgnv_tbl           => p_sgnv_tbl
                                                  ,x_return_status      => x_return_status
                                                  ,x_msg_count          => x_msg_count
                                                  ,x_msg_data           => x_msg_data);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



	OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
	  					 x_msg_data	  => x_msg_data);

    x_return_status := l_return_status;

    EXCEPTION
      WHEN G_EXCEPTION_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						     p_pkg_name	=> G_PKG_NAME,
												     p_exc_name => G_EXC_NAME_ERROR,
												     x_msg_count=> x_msg_count,
												     x_msg_data	=> x_msg_data,
												     p_api_type	=> '_PUB');
      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');
      WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PUB');
  END delete_translations;


END OKL_SETUP_STRMS_TRANS_PUB;

/
