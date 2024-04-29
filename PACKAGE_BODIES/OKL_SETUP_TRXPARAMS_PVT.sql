--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_TRXPARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_TRXPARAMS_PVT" AS
/* $Header: OKLRTXRB.pls 115.1 2004/07/02 02:56:51 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE create_trx_parm for: OKL_SIF_TRX_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE create_trx_parm(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_sxpv_rec                     IN  sxpv_rec_type,
      		                  	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        )
  IS


    CURSOR l_okl_sxp_index_csr(p_sxpv_rec sxpv_rec_type)
    IS
     SELECT NVL(MAX(INDEX_NUMBER1),0)
     FROM OKL_SIF_TRX_PARMS TRX
     WHERE TRX.SIF_ID = p_sxpv_rec.sif_id
     AND TRX.SPP_ID = p_sxpv_rec.spp_id;

    l_okl_sxp_index_rec l_okl_sxp_index_csr%ROWTYPE;

    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_trx_parm';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_sxpv_rec		  sxpv_rec_type;
    l_max_index number := 0;


  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    l_sxpv_rec := p_sxpv_rec;

    if(l_sxpv_rec.index_number1 is not null and l_sxpv_rec.index_number1 <> G_MISS_NUM) THEN
     OPEN l_okl_sxp_index_csr(l_sxpv_rec);
     FETCH l_okl_sxp_index_csr INTO l_max_index;
     CLOSE l_okl_sxp_index_csr;

     l_sxpv_rec.index_number1 := l_max_index + 1;
    end if;


	/* public api to insert streamtype */
    okl_sif_trx_parms_pub.insert_sif_trx_parms(p_api_version   => p_api_version,
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

	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
	  if (l_okl_sxp_index_csr%ISOPEN) then
        CLOSE  l_okl_sxp_index_csr;
	  end if;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
	  if (l_okl_sxp_index_csr%ISOPEN) then
        CLOSE  l_okl_sxp_index_csr;
	  end if;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
	  if (l_okl_sxp_index_csr%ISOPEN) then
        CLOSE  l_okl_sxp_index_csr;
	  end if;
  END create_trx_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_trx_parm for: OKL_SIF_TRX_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_trx_parm(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_sxpv_rec                     IN  sxpv_rec_type,
                        	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_trx_parm';
	l_sxpv_rec	  	 	  	sxpv_rec_type;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN
    l_sxpv_rec := p_sxpv_rec;

   /* public api to update formulae */
      okl_sif_trx_parms_pub.update_sif_trx_parms(p_api_version   => p_api_version,
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

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

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
	rec_num		INTEGER	:= 0;
	l_sxpv_tbl sxpv_tbl_type;
   BEGIN
        l_sxpv_tbl := p_sxpv_tbl;

 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
           /* Clean Up the index to be in Order */
           -- pushing this logic to the record level method
           --l_sxpv_tbl(rec_num).index_number1 := rec_num;


		create_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => l_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;
	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
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
	rec_num		INTEGER	:= 0;
	l_sxpv_tbl sxpv_tbl_type;
   BEGIN
        l_sxpv_tbl := p_sxpv_tbl;

        FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
           /* Clean Up the index to be in Order */
           l_sxpv_tbl(rec_num).index_number1 := rec_num;

		update_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => l_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;
	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
	  -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_trx_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_trx_parm for: OKL_SIF_TRX_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE delete_trx_parm(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_sxpv_rec                     IN  sxpv_rec_type,
                        	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS

    CURSOR l_okl_sxp_csr(p_rec sxpv_rec_type)
	IS
	  SELECT ID
	  FROM OKL_SIF_TRX_PARMS
	  WHERE SIF_ID = p_rec.sif_id
	  AND	SPP_ID = p_rec.spp_id;


    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'delete_trx_parm';
	l_sxpv_rec	  	 	  	sxpv_rec_type;
	l_sxpv_tbl	  	 	  	sxpv_tbl_type;
	x_sxpv_tbl	  	 	  	sxpv_tbl_type;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    i NUMBER := 1;

  BEGIN

    l_sxpv_rec := p_sxpv_rec;

    IF l_sxpv_rec.sif_id IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'SIF_ID'
                         );
         RAISE G_EXCEPTION_ERROR;
    END IF;

	IF l_sxpv_rec.spp_id IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'SPP_ID'
                         );
         RAISE G_EXCEPTION_ERROR;
    END IF;

	FOR l_okl_sxp_rec IN l_okl_sxp_csr(l_sxpv_rec)
	LOOP
	    l_sxpv_tbl(i).id := l_okl_sxp_rec.id;
	    i := i+1;
	END LOOP;

	IF l_sxpv_tbl.count > 0 THEN
	     /* public api to delete trxparms */
	    okl_sif_trx_parms_pub.delete_sif_trx_parms(p_api_version   => p_api_version,
	                         		 	p_init_msg_list => p_init_msg_list,
	                           		 	x_return_status => l_return_status,
	                           		 	x_msg_count     => x_msg_count,
	                           		 	x_msg_data      => x_msg_data,
	                           		 	p_sxpv_tbl      => l_sxpv_tbl,
	                           		 	x_sxpv_tbl      => x_sxpv_tbl);

	    IF l_return_status = G_RET_STS_ERROR THEN
	       RAISE G_EXCEPTION_ERROR;
	    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	    	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;
	END IF;

	x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

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
	rec_num		INTEGER	:= 0;
   BEGIN
 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
		delete_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;

	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END delete_trx_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_trx_asset_parm for: OKL_SIF_TRX_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE create_trx_asset_parm(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_sxpv_rec                     IN  sxpv_rec_type,
      		                  	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_trx_asset_parm';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
	l_sxpv_rec		  sxpv_rec_type;
  BEGIN

    IF p_sxpv_rec.kle_id IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_OKL_LLA_ASSET_REQUIRED);
      RAISE G_EXCEPTION_ERROR;
    ELSE
		create_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_rec,
         x_sxpv_rec                     => x_sxpv_rec );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;

    END IF;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END create_trx_asset_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_trx_asset_parm for: OKL_SIF_TRX_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_trx_asset_parm(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_sxpv_rec                     IN  sxpv_rec_type,
      		                  	x_sxpv_rec                     OUT NOCOPY sxpv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'update_trx_asset_parm';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
	l_sxpv_rec		  sxpv_rec_type;
  BEGIN

    IF p_sxpv_rec.kle_id IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_OKL_LLA_ASSET_REQUIRED);
      RAISE G_EXCEPTION_ERROR;
    ELSE
		update_trx_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => p_sxpv_rec,
         x_sxpv_rec                     => x_sxpv_rec );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;

    END IF;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
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
	rec_num		INTEGER	:= 0;
	l_sxpv_tbl sxpv_tbl_type;
   BEGIN
        l_sxpv_tbl := p_sxpv_tbl;

 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
           /* Clean Up the index to be in Order */
           l_sxpv_tbl(rec_num).index_number1 := rec_num;

		create_trx_asset_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => l_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;
	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
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
	rec_num		INTEGER	:= 0;
	l_sxpv_tbl sxpv_tbl_type;
   BEGIN
        l_sxpv_tbl := p_sxpv_tbl;


 	FOR rec_num IN 1..p_sxpv_tbl.COUNT
	LOOP
           /* Clean Up the index to be in Order */
           l_sxpv_tbl(rec_num).index_number1 := rec_num;

		update_trx_asset_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sxpv_rec                     => l_sxpv_tbl(rec_num),
         x_sxpv_rec                     => x_sxpv_tbl(rec_num) );
	      IF x_return_status = G_RET_STS_ERROR THEN
		 RAISE G_EXCEPTION_ERROR;
	      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;
	END LOOP;
   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_trx_asset_parm;

END OKL_SETUP_TRXPARAMS_PVT;

/
