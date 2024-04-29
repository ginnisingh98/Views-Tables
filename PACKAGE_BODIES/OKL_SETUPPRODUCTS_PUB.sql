--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPRODUCTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPRODUCTS_PUB" AS
/* $Header: OKLPSPDB.pls 115.9 2004/04/14 13:07:14 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.PRODUCTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PRODUCTS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_pdtv_rec			  IN pdtv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_pdtv_rec			  OUT NOCOPY pdtv_rec_type) IS
    l_pdtv_rec                        pdtv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_pdtv_rec := p_pdtv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

-- Start of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.get_rec
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSPDB.pls call okl_setupproducts_pvt.get_rec ');
    END;
  END IF;
    okl_setupproducts_pvt.get_rec(p_pdtv_rec      => l_pdtv_rec,
								  x_return_status => l_return_status,
								  x_no_data_found => l_no_data_found,
								  x_pdtv_rec	  => x_pdtv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSPDB.pls call okl_setupproducts_pvt.get_rec ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.get_rec

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  x_no_data_found := FALSE;
	  FND_MESSAGE.set_name(application	=> G_APP_NAME,
	  					   name			=> G_UNEXPECTED_ERROR);
	  x_msg_data := FND_MESSAGE.get;
  END get_rec;


  ---------------------------------------------------------------------------
  -- PROCEDURE Getpdt_parameters for: OKL_PRODUCTS_V
  ---------------------------------------------------------------------------
  PROCEDURE Getpdt_parameters(p_api_version                  IN  NUMBER,
  				  			  p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
						      x_return_status                OUT NOCOPY VARCHAR2,
							  x_no_data_found                OUT NOCOPY BOOLEAN,
							  x_msg_count                    OUT NOCOPY NUMBER,
							  x_msg_data                     OUT NOCOPY VARCHAR2,
							  p_pdtv_rec                     IN  pdtv_rec_type,
							  p_product_date                 IN  DATE DEFAULT SYSDATE,
							  p_pdt_parameter_rec            OUT NOCOPY pdt_parameters_rec_type) IS

  l_pdtv_rec                        pdtv_rec_type;
  l_product_date                    DATE;
  l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  l_no_data_found					BOOLEAN;


  BEGIN

  	l_pdtv_rec := p_pdtv_rec;
	l_product_date := p_product_date;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

-- Start of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.Getpdt_parameters
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSPDB.pls call okl_setupproducts_pvt.Getpdt_parameters ');
    END;
  END IF;
    okl_setupproducts_pvt.Getpdt_parameters(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                              			    x_return_status => l_return_status,
											x_no_data_found => l_no_data_found,
                              			    x_msg_count     => x_msg_count,
                              			    x_msg_data      => x_msg_data,
							  	            p_pdtv_rec      => l_pdtv_rec,
								            p_product_date  => l_product_date,
											p_pdt_parameter_rec => p_pdt_parameter_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSPDB.pls call okl_setupproducts_pvt.Getpdt_parameters ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.Getpdt_parameters

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_MESSAGE.set_name(application	=> G_APP_NAME,
	  					   name			=> G_UNEXPECTED_ERROR);
	  x_msg_data := FND_MESSAGE.get;
  END Getpdt_parameters;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_products
  -- Public wrapper for insert_products process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_products(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pdtv_rec         IN  pdtv_rec_type,
                        	x_pdtv_rec         OUT NOCOPY pdtv_rec_type) IS
    l_pdtv_rec                        pdtv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_products';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_products;
    l_pdtv_rec := p_pdtv_rec;

	-- call process api to insert products
-- Start of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.insert_products
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSPDB.pls call okl_setupproducts_pvt.insert_products ');
    END;
  END IF;
    okl_setupproducts_pvt.insert_products(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pdtv_rec      => l_pdtv_rec,
                              			  x_pdtv_rec      => x_pdtv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSPDB.pls call okl_setupproducts_pvt.insert_products ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.insert_products

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pdtv_rec := x_pdtv_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_products;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_products;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPRODUCTS_PUB','insert_products');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_products;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_products
  -- Public wrapper for update_products process api
  ---------------------------------------------------------------------------
  PROCEDURE update_products(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pdtv_rec         IN  pdtv_rec_type,
                        	x_pdtv_rec         OUT NOCOPY pdtv_rec_type) IS
    l_pdtv_rec                        pdtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_products';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_products;
    l_pdtv_rec := p_pdtv_rec;


	-- call process api to update products
-- Start of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.update_products
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSPDB.pls call okl_setupproducts_pvt.update_products ');
    END;
  END IF;
    okl_setupproducts_pvt.update_products(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pdtv_rec      => l_pdtv_rec,
                              			  x_pdtv_rec      => x_pdtv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSPDB.pls call okl_setupproducts_pvt.update_products ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupproducts_pvt.update_products

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pdtv_rec := x_pdtv_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_products;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_products;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPRODUCTS_PUB','update_products');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_products;

END OKL_SETUPPRODUCTS_PUB;

/
