--------------------------------------------------------
--  DDL for Package Body OKL_SETUPFMACONSTRAINTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPFMACONSTRAINTS_PVT" AS
/* $Header: OKLRSFCB.pls 120.1.12010000.2 2008/11/20 20:14:32 cklee ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.FORMULAS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_fodv_rec                     IN fodv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_fodv_rec					   OUT NOCOPY fodv_rec_type
  ) IS
    CURSOR okl_fodv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
			OPD_ID,
			FMA_ID,
			LABEL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
     FROM Okl_Fmla_Oprnds_V
     WHERE okl_Fmla_Oprnds_V.id    = p_id;
    l_okl_fodv_pk                  okl_fodv_pk_csr%ROWTYPE;
    l_fodv_rec                     fodv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_fodv_pk_csr (p_fodv_rec.id);
    FETCH okl_fodv_pk_csr INTO
              l_fodv_rec.ID,
              l_fodv_rec.OBJECT_VERSION_NUMBER,
              l_fodv_rec.OPD_ID,
              l_fodv_rec.FMA_ID,
              l_fodv_rec.LABEL,
              l_fodv_rec.CREATED_BY,
              l_fodv_rec.CREATION_DATE,
              l_fodv_rec.LAST_UPDATED_BY,
              l_fodv_rec.LAST_UPDATE_DATE,
              l_fodv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_fodv_pk_csr%NOTFOUND;
    CLOSE okl_fodv_pk_csr;
    x_fodv_rec := l_fodv_rec;
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

      IF (okl_fodv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_fodv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_operands for: OKL_FMLA_OPRNDS_V
  -- To verify whether the dates are valid for both formula and operands
  -- attached to it
  ---------------------------------------------------------------------------
  PROCEDURE check_operands (
    p_fmav_rec      IN fmav_rec_type,
	p_fodv_rec		IN fodv_rec_type,
	x_return_status	OUT NOCOPY VARCHAR2,
    x_valid         OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_opdv_pk_csr (p_opd_id IN Okl_Operands_V.id%TYPE,
                            p_fma_id IN Okl_Formulae_V.id%TYPE
	) IS
    SELECT '1'
    FROM Okl_Operands_V opd,
         Okl_Formulae_V fma
    WHERE opd.ID    = p_opd_id
    AND   fma.ID    = p_fma_id
	AND   (opd.START_DATE > fma.START_DATE  OR
	      NVL(opd.END_DATE, NVL(fma.END_DATE, OKL_API.G_MISS_DATE)) < NVL(fma.END_DATE, OKL_API.G_MISS_DATE));

	l_check		   	VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for operand dates
    OPEN okl_opdv_pk_csr (p_fodv_rec.opd_id,
                          p_fodv_rec.fma_id);
    FETCH okl_opdv_pk_csr INTO l_check;
    l_row_not_found := okl_opdv_pk_csr%NOTFOUND;
    CLOSE okl_opdv_pk_csr;

    IF l_row_not_found = FALSE then
	   OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
						   p_msg_name	   => G_DATES_MISMATCH,
						   p_token1		   => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Okl_Operands_V',
						   p_token2		   => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Okl_Fmla_Oprnds_V');
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

       IF (okl_opdv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_opdv_pk_csr;
       END IF;


  END check_operands;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_fmaconstraints for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_fmaconstraints(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
								  p_fmav_rec		IN  fmav_rec_type,
                        		  p_fodv_rec        IN  fodv_rec_type,
                        		  x_fodv_rec        OUT NOCOPY fodv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_fmaconstraints';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_fmav_rec		  fmav_rec_type;
	l_fodv_rec		  fodv_rec_type;
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

	l_fmav_rec := p_fmav_rec;
	l_fodv_rec := p_fodv_rec;


	/* call check_operands to check the validity of this relationship */
	check_operands(p_fmav_rec 		=> l_fmav_rec,
				   p_fodv_rec 		=> l_fodv_rec,
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

	/* public api to insert formulae constraints */
-- Start of wraper code generated automatically by Debug code generator for okl_fmla_oprnds_pub.insert_fmla_oprnds
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSFCB.pls call okl_fmla_oprnds_pub.insert_fmla_oprnds ');
    END;
  END IF;
    okl_fmla_oprnds_pub.insert_fmla_oprnds(p_api_version   => p_api_version,
                              		       p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_fodv_rec      => l_fodv_rec,
                              		 	   x_fodv_rec      => x_fodv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSFCB.pls call okl_fmla_oprnds_pub.insert_fmla_oprnds ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_fmla_oprnds_pub.insert_fmla_oprnds

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

  END insert_fmaconstraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_fmaconstraints for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_fmaconstraints(p_api_version     IN  NUMBER,
                        		  p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status   OUT NOCOPY VARCHAR2,
                        		  x_msg_count       OUT NOCOPY NUMBER,
                        		  x_msg_data        OUT NOCOPY VARCHAR2,
								  p_fmav_rec		IN  fmav_rec_type,
                        		  p_fodv_rec        IN  fodv_rec_type,
                        		  x_fodv_rec        OUT NOCOPY fodv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_fmaconstraints';
    l_return_status   VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
	l_valid			  BOOLEAN;
	l_fmav_rec		  fmav_rec_type;
	l_fodv_rec		  fodv_rec_type;
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

	l_fmav_rec := p_fmav_rec;
	l_fodv_rec := p_fodv_rec;

	/* call check_operands to check the validity of this relationship */
	check_operands(p_fmav_rec 		=> l_fmav_rec,
				   p_fodv_rec 		=> l_fodv_rec,
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

	/* public api to insert formulae constraints */
-- Start of wraper code generated automatically by Debug code generator for okl_fmla_oprnds_pub.update_fmla_oprnds
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSFCB.pls call okl_fmla_oprnds_pub.update_fmla_oprnds ');
    END;
  END IF;
    okl_fmla_oprnds_pub.update_fmla_oprnds(p_api_version   => p_api_version,
                              		 	   p_init_msg_list => p_init_msg_list,
                              		 	   x_return_status => l_return_status,
                              		 	   x_msg_count     => x_msg_count,
                              		 	   x_msg_data      => x_msg_data,
                              		 	   p_fodv_rec      => l_fodv_rec,
                              		 	   x_fodv_rec      => x_fodv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSFCB.pls call okl_fmla_oprnds_pub.update_fmla_oprnds ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_fmla_oprnds_pub.update_fmla_oprnds

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

  END update_fmaconstraints;


  ---------------------------------------------------------------------------
  -- PROCEDURE delete_fmaconstraints for: OKL_FMLA_OPRNDS_V
  -- This allows the user to delete table of records
  ---------------------------------------------------------------------------
  PROCEDURE delete_fmaconstraints(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_fodv_tbl                     IN  fodv_tbl_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_fodv_tbl        fodv_tbl_type;
    l_api_name        CONSTANT VARCHAR2(30)  := 'delete_fmaconstraints';
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

	l_fodv_tbl := p_fodv_tbl;

	/* delete formulae constraints */
-- Start of wraper code generated automatically by Debug code generator for okl_fmla_oprnds_pub.delete_fmla_oprnds
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSFCB.pls call okl_fmla_oprnds_pub.delete_fmla_oprnds ');
    END;
  END IF;
    okl_fmla_oprnds_pub.delete_fmla_oprnds(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_fodv_tbl      => l_fodv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSFCB.pls call okl_fmla_oprnds_pub.delete_fmla_oprnds ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_fmla_oprnds_pub.delete_fmla_oprnds

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

  END delete_fmaconstraints;

 -- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FMLA_OPRNDS - TBL : begin

  PROCEDURE insert_fmaconstraints(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_fmav_rec					   IN  fmav_rec_type
                        ,p_fodv_tbl                     IN  fodv_tbl_type
                        ,x_fodv_tbl                     OUT NOCOPY fodv_tbl_type
                        ) IS
    l_fodv_tbl                        fodv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_fmaconstraints';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                        NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT insert_fmaconstraints;
    l_fodv_tbl :=  p_fodv_tbl;



    IF (p_fodv_tbl.COUNT > 0) THEN
      i := p_fodv_tbl.FIRST;

      LOOP
        insert_fmaconstraints (
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_fmav_rec     => p_fmav_rec
                          ,p_fodv_rec      => p_fodv_tbl(i)
                          ,x_fodv_rec      => x_fodv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_fodv_tbl.LAST);

          i := p_fodv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local table structure using output table from pvt api */
    l_fodv_tbl := x_fodv_tbl;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_fmaconstraints;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_fmaconstraints;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_fmaconstraints_PUB','insert_fmaconstraints');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 END insert_fmaconstraints;
-- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FMLA_OPRNDS - TBL : end

-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FMLA_OPRNDS - TBL : begin
PROCEDURE update_fmaconstraints(
                         p_api_version                  IN  NUMBER
                        ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                        ,x_return_status                OUT NOCOPY VARCHAR2
                        ,x_msg_count                    OUT NOCOPY NUMBER
                        ,x_msg_data                     OUT NOCOPY VARCHAR2
                        ,p_fmav_rec					   IN  fmav_rec_type
                        ,p_fodv_tbl                     IN  fodv_tbl_type
                        ,x_fodv_tbl                     OUT NOCOPY fodv_tbl_type
                        ) IS
    l_fodv_tbl                        fodv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_fmaconstraints';
    l_return_status                   VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    l_overall_status			  VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
    i                        NUMBER;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT update_fmaconstraints;
    l_fodv_tbl :=  p_fodv_tbl;



    IF (p_fodv_tbl.COUNT > 0) THEN
      i := p_fodv_tbl.FIRST;

      LOOP
        update_fmaconstraints (
                           p_api_version   => p_api_version
--start:|  20-Nov-08 cklee/smadhava Bug# 7439737/7298457
--                          ,p_init_msg_list => p_init_msg_list
-- Bug# 7298457 - Donot reset message list- passing 'T' overwrites the error messages of previous operands
                          ,p_init_msg_list => OKL_API.G_FALSE
--end:|  20-Nov-08 cklee/smadhava Bug# 7439737/7298457
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_fmav_rec     => p_fmav_rec
                          ,p_fodv_rec      => p_fodv_tbl(i)
                          ,x_fodv_rec      => x_fodv_tbl(i)
                          );

		  -- store the highest degree of error
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  	 IF l_overall_status <> FND_API.G_RET_STS_UNEXP_ERROR THEN
			    l_overall_status := x_return_status;
			 END IF;
		  END IF;
          EXIT WHEN (i = p_fodv_tbl.LAST);

          i := p_fodv_tbl.NEXT(i);

       END LOOP;

	   -- return overall status
	   x_return_status := l_overall_status;
     END IF;

     l_return_status := x_return_status;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local table structure using output table from pvt api */
    l_fodv_tbl := x_fodv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_fmaconstraints;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_fmaconstraints;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_fmaconstraints_PUB','update_fmaconstraints');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_fmaconstraints;
-- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FMLA_OPRNDS - TBL : end


END OKL_SETUPFMACONSTRAINTS_PVT;

/
