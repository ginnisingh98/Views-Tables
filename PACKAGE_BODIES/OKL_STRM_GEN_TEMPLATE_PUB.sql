--------------------------------------------------------
--  DDL for Package Body OKL_STRM_GEN_TEMPLATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STRM_GEN_TEMPLATE_PUB" as
/* $Header: OKLPTSGB.pls 120.4 2005/11/15 11:53:23 rgooty noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE create_strm_gen_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_strm_gen_template
  -- Description     : Creates a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure create_strm_gen_template(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtsv_rec                IN  gtsv_rec_type
                    ,p_gttv_rec                IN  gttv_rec_type
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      ) IS
    l_api_name VARCHAR2(30):= 'create_strm_gen_template';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.create_strm_gen_template(
                     p_api_version   => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => l_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    ,p_gtsv_rec      => p_gtsv_rec
                    ,p_gttv_rec      => p_gttv_rec
                    ,p_gtpv_tbl      => p_gtpv_tbl
                    ,p_gtlv_tbl      => p_gtlv_tbl
                    ,x_gttv_rec      => x_gttv_rec
    );

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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_strm_gen_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_strm_gen_template
  -- Description     : Update a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure update_strm_gen_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtsv_rec                IN  gtsv_rec_type
                    ,p_gttv_rec                IN  gttv_rec_type
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      )IS
    l_api_name VARCHAR2(30):= 'update_strm_gen_template';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.update_strm_gen_template(
                     p_api_version   => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => l_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    ,p_gtsv_rec      => p_gtsv_rec
                    ,p_gttv_rec      => p_gttv_rec
                    ,p_gtpv_tbl      => p_gtpv_tbl
                    ,p_gtlv_tbl      => p_gtlv_tbl
                    ,x_gttv_rec      => x_gttv_rec
    );
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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_dep_strms
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_dep_strms
  -- Description     : Update Dependent Streams of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure update_dep_strms(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtt_id                  IN  OKL_ST_GEN_TEMPLATES.ID%type
                    ,p_pri_sty_id              IN  OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_missing_deps            OUT NOCOPY VARCHAR2
                    ,x_show_warn_flag          OUT NOCOPY VARCHAR2
      )IS
    l_api_name VARCHAR2(30):= 'update_dep_strms';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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
    OKL_STRM_GEN_TEMPLATE_PVT.update_dep_strms(
                     p_api_version    => l_api_version
                    ,p_init_msg_list  => p_init_msg_list
                    ,x_return_status  => l_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
                    ,p_gtt_id         => p_gtt_id
                    ,p_pri_sty_id     => p_pri_sty_id
                    ,p_gtlv_tbl       => p_gtlv_tbl
                    ,x_missing_deps   => x_missing_deps
                    ,x_show_warn_flag => x_show_warn_flag
    );

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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_version_duplicate
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_version_duplicate
  -- Description     : Create a duplicate of a Stream Generation Template
  --                     or a new version of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure create_version_duplicate(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,p_mode                    IN  VARCHAR2 DEFAULT G_DEFAULT_MODE
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      ) IS
    l_api_name VARCHAR2(30):= 'create_version_duplicate';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.create_version_duplicate(
                     p_api_version   => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => l_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    ,p_gtt_id        => p_gtt_id
		            ,p_mode          => p_mode
                    ,x_gttv_rec      => x_gttv_rec
    );

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
END;


  ---------------------------------------------------------------------------
  -- PROCEDURE delete_tmpt_prc_params
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_tmpt_prc_params
  -- Description     : Delete Pricing Parameters of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure delete_tmpt_prc_params(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
      ) IS
    l_api_name VARCHAR2(30):= 'delete_tmpt_prc_params';
	l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.delete_tmpt_prc_params(
                    p_api_version     => l_api_version
                    ,p_init_msg_list  => p_init_msg_list
                    ,x_return_status  => x_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
                    ,p_gtpv_tbl       => p_gtpv_tbl
      );

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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_pri_tmpt_lns
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_pri_tmpt_lns
  -- Description     : Delete Primary Lines of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure delete_pri_tmpt_lns(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
      )IS
    l_api_name VARCHAR2(30):= 'delete_pri_tmpt_lns';
    l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN

   l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.delete_pri_tmpt_lns(
                    p_api_version     => l_api_version
                    ,p_init_msg_list  => p_init_msg_list
                    ,x_return_status  => x_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
                    ,p_gtlv_tbl       => p_gtlv_tbl
      );

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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_dep_tmpt_lns
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_dep_tmpt_lns
  -- Description     : Delete dependent Template Lines of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure delete_dep_tmpt_lns(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
      )IS
    l_api_name VARCHAR2(30):= 'delete_dep_tmpt_lns';
    l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN

   l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.delete_dep_tmpt_lns(
                    p_api_version     => l_api_version
                    ,p_init_msg_list  => p_init_msg_list
                    ,x_return_status  => x_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
                    ,p_gtlv_tbl       => p_gtlv_tbl
      );

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
END;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_template
  -- Description     : Validate a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure validate_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,x_error_msgs_tbl          OUT NOCOPY error_msgs_tbl_type
		            ,x_return_tmpt_status      OUT NOCOPY VARCHAR2
		            ,p_during_upd_flag         IN  VARCHAR2
      )IS
    l_api_name VARCHAR2(30):= 'validate_template';
    l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.validate_template(
                    p_api_version    => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
		            ,p_gtt_id        => p_gtt_id
		            ,x_error_msgs_tbl => x_error_msgs_tbl
		            ,x_return_tmpt_status => x_return_tmpt_status
		            ,p_during_upd_flag => p_during_upd_flag
      );

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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE activate_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : activate_template
  -- Description     : Activate a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure activate_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
      ) IS
    l_api_name VARCHAR2(30):= 'activate_template';
    l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.activate_template(
                    p_api_version       => l_api_version
                    ,p_init_msg_list    => p_init_msg_list
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data
		            ,p_gtt_id           => p_gtt_id
     );

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
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_for_warnings
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_for_warnings
  -- Description     : Validate the SGT for any warnings to be shown
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure validate_for_warnings(
                    p_api_version             IN   NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,x_wrn_msgs_tbl            OUT NOCOPY error_msgs_tbl_type
		            ,p_during_upd_flag         IN  VARCHAR
		            ,x_pri_purpose_list        OUT NOCOPY VARCHAR
      ) IS
    l_api_name VARCHAR2(30):= 'validate_for_warnings';
    l_api_version NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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

    OKL_STRM_GEN_TEMPLATE_PVT.validate_for_warnings(
                    p_api_version       => p_api_version
                    ,p_init_msg_list    => p_init_msg_list
                    ,x_return_status    => l_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data
		            ,p_gtt_id           => p_gtt_id
		            ,x_wrn_msgs_tbl     => x_wrn_msgs_tbl
		            ,p_during_upd_flag  => p_during_upd_flag
		            ,x_pri_purpose_list => x_pri_purpose_list
      );

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
END;


  PROCEDURE update_pri_dep_of_sgt(
              p_api_version             IN  NUMBER
             ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
             ,x_return_status           OUT NOCOPY VARCHAR2
             ,x_msg_count               OUT NOCOPY NUMBER
             ,x_msg_data                OUT NOCOPY VARCHAR2
             ,p_gtsv_rec                IN  gtsv_rec_type
             ,p_gttv_rec                IN  gttv_rec_type
             ,p_gtpv_tbl                IN  gtpv_tbl_type
             ,p_pri_gtlv_tbl            IN  gtlv_tbl_type
             ,p_del_dep_gtlv_tbl        IN  gtlv_tbl_type
             ,p_ins_dep_gtlv_tbl        IN  gtlv_tbl_type
             ,x_gttv_rec                OUT NOCOPY gttv_rec_type
             ,x_pri_purpose_list        OUT NOCOPY VARCHAR2)
  IS
    l_api_name          VARCHAR2(30):= 'update_pri_dep_of_sgt';
    l_api_version       NUMBER := 1.0;
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
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
    okl_strm_gen_template_pvt.update_pri_dep_of_sgt(
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_gtsv_rec          => p_gtsv_rec,
      p_gttv_rec          => p_gttv_rec,
      p_gtpv_tbl          => p_gtpv_tbl,
      p_pri_gtlv_tbl      => p_pri_gtlv_tbl,
      p_del_dep_gtlv_tbl  => p_del_dep_gtlv_tbl,
      p_ins_dep_gtlv_tbl  => p_ins_dep_gtlv_tbl ,
      x_gttv_rec          => x_gttv_rec,
      x_pri_purpose_list  => x_pri_purpose_list );
    IF l_return_status = G_RET_STS_ERROR
    THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR
    THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
	  OKL_API.END_ACTIVITY(
      x_msg_count  => x_msg_count,
      x_msg_data	  => x_msg_data);
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                p_api_name	=> l_api_name,
	  				  	p_pkg_name	=> G_PKG_NAME,
								p_exc_name   => G_EXC_NAME_ERROR,
								x_msg_count  => x_msg_count,
								x_msg_data	=> x_msg_data,
								p_api_type	=> '_PUB');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                p_api_name	=> l_api_name,
	  				  	p_pkg_name	=> G_PKG_NAME,
								p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
								x_msg_count	=> x_msg_count,
								x_msg_data	=> x_msg_data,
								p_api_type	=> '_PUB');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                p_api_name	=> l_api_name,
	  				  	p_pkg_name	=> G_PKG_NAME,
								p_exc_name   => G_EXC_NAME_OTHERS,
								x_msg_count	=> x_msg_count,
								x_msg_data	=> x_msg_data,
								p_api_type	=> '_PUB');
  END update_pri_dep_of_sgt;

End  okl_strm_gen_template_pub;

/
