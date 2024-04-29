--------------------------------------------------------
--  DDL for Package Body OKL_SETUPDQUALITYS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPDQUALITYS_PUB" AS
/* $Header: OKLPSDQB.pls 120.3 2007/03/04 10:04:44 dcshanmu ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.PRODUCTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: okl_pdt_pqys_v
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_pdqv_rec                     IN pdqv_rec_type,
    				x_no_data_found                OUT NOCOPY BOOLEAN,
 	                x_msg_data			           OUT NOCOPY VARCHAR2,
                    x_return_status		           OUT NOCOPY VARCHAR2,
					x_pdqv_rec			           OUT NOCOPY pdqv_rec_type) IS
    l_pdqv_rec                        pdqv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_no_data_found					  BOOLEAN;
  BEGIN

  	l_pdqv_rec := p_pdqv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

-- Start of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.get_rec
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.get_rec ');
    END;
  END IF;
    okl_setupdqualitys_pvt.get_rec(p_pdqv_rec      => l_pdqv_rec,
								   x_return_status => l_return_status,
								   x_no_data_found => l_no_data_found,
								   x_pdqv_rec	   => x_pdqv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.get_rec ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.get_rec

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
  -- PROCEDURE insert_dqualitys
  -- Public wrapper for insert_dqualitys process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_dqualitys(p_api_version      IN  NUMBER,
                             p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	 x_return_status    OUT NOCOPY VARCHAR2,
                        	 x_msg_count        OUT NOCOPY NUMBER,
                        	 x_msg_data         OUT NOCOPY VARCHAR2,
							 p_ptlv_rec         IN  ptlv_rec_type,
                        	 p_pdqv_rec         IN  pdqv_rec_type,
                        	 x_pdqv_rec         OUT NOCOPY pdqv_rec_type) IS
    l_pdqv_rec                        pdqv_rec_type;
	l_ptlv_rec                        ptlv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_dqualitys';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_dqualitys;
    l_pdqv_rec := p_pdqv_rec;
    l_ptlv_rec := p_ptlv_rec;



	-- call process api to insert dqualitys
-- Start of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.insert_dqualitys
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.insert_dqualitys ');
    END;
  END IF;
    okl_setupdqualitys_pvt.insert_dqualitys(p_api_version   => p_api_version,                                            p_init_msg_list => p_init_msg_list,
                              			    x_return_status => l_return_status,
                              			    x_msg_count     => x_msg_count,
                              			    x_msg_data      => x_msg_data,
											p_ptlv_rec      => l_ptlv_rec,
                              			    p_pdqv_rec      => l_pdqv_rec,
                              			    x_pdqv_rec      => x_pdqv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.insert_dqualitys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.insert_dqualitys

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pdqv_rec := x_pdqv_rec;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_dqualitys;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_dqualitys;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDQUALITYS_PUB','insert_dqualitys');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_dqualitys;


  PROCEDURE insert_dqualitys(p_api_version      IN  NUMBER,
                             p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	 x_return_status    OUT NOCOPY VARCHAR2,
                        	 x_msg_count        OUT NOCOPY NUMBER,
                        	 x_msg_data         OUT NOCOPY VARCHAR2,
							 p_ptlv_rec         IN  ptlv_rec_type,
                        	 p_pdqv_tbl         IN  pdqv_tbl_type,
                        	 x_pdqv_tbl         OUT NOCOPY pdqv_tbl_type) IS
    l_pdqv_tbl                        pdqv_tbl_type;
	l_ptlv_rec                        ptlv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_dqualitys';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_dqualitys;
    l_pdqv_tbl := p_pdqv_tbl;
    l_ptlv_rec := p_ptlv_rec;



	-- call process api to insert dqualitys
-- Start of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.insert_dqualitys
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.insert_dqualitys ');
    END;
  END IF;
    okl_setupdqualitys_pvt.insert_dqualitys(p_api_version   => p_api_version,                                            p_init_msg_list => p_init_msg_list,
                              			    x_return_status => l_return_status,
                              			    x_msg_count     => x_msg_count,
                              			    x_msg_data      => x_msg_data,
											p_ptlv_rec      => l_ptlv_rec,
                              			    p_pdqv_tbl      => l_pdqv_tbl,
                              			    x_pdqv_tbl      => x_pdqv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.insert_dqualitys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.insert_dqualitys

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pdqv_tbl := x_pdqv_tbl;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_dqualitys;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_dqualitys;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDQUALITYS_PUB','insert_dqualitys');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_dqualitys;

   ---------------------------------------------------------------------------
  -- PROCEDURE delete_dqualitys
  -- Public wrapper for delete_dqualitys process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_dqualitys(p_api_version      IN  NUMBER,
                             p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	 x_return_status    OUT NOCOPY VARCHAR2,
                        	 x_msg_count        OUT NOCOPY NUMBER,
                        	 x_msg_data         OUT NOCOPY VARCHAR2,
							 p_ptlv_rec         IN  ptlv_rec_type,
                        	 p_pdqv_tbl         IN  pdqv_tbl_type) IS
    l_pdqv_tbl                        pdqv_tbl_type;
	l_ptlv_rec                        ptlv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_dqualitys';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_dqualitys;
    l_pdqv_tbl := p_pdqv_tbl;
    l_ptlv_rec := p_ptlv_rec;



	-- call process api to delete dqualitys
-- Start of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.delete_dqualitys
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.delete_dqualitys ');
    END;
  END IF;
    okl_setupdqualitys_pvt.delete_dqualitys(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                              			    x_return_status => l_return_status,
                              			    x_msg_count     => x_msg_count,
                              			    x_msg_data      => x_msg_data,
											p_ptlv_rec      => l_ptlv_rec,
                              			    p_pdqv_tbl      => l_pdqv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSDQB.pls call okl_setupdqualitys_pvt.delete_dqualitys ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupdqualitys_pvt.delete_dqualitys

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_dqualitys;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_dqualitys;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPDQUALITYS_PUB','delete_dqualitys');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_dqualitys;

END OKL_SETUPDQUALITYS_PUB;

/
