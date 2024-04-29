--------------------------------------------------------
--  DDL for Package Body OKL_SETUPPQVALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPPQVALUES_PUB" AS
/* $Header: OKLPSUVB.pls 120.3 2007/09/26 08:22:34 rajnisku ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.PRODUCTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: Okl_Pdt_Pqy_Vals_v
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_pqvv_rec			  IN pqvv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_pqvv_rec			  OUT NOCOPY pqvv_rec_type) IS
    l_pqvv_rec                        pqvv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
    l_no_data_found					  BOOLEAN;
  BEGIN

  	l_pqvv_rec := p_pqvv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

-- Start of wraper code generated automatically by Debug code generator for okl_setuppqvalues_pvt.get_rec
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSUVB.pls call okl_setuppqvalues_pvt.get_rec ');
    END;
  END IF;
    okl_setuppqvalues_pvt.get_rec(p_pqvv_rec      => l_pqvv_rec,
								  x_return_status => l_return_status,
								  x_no_data_found => l_no_data_found,
								  x_pqvv_rec	  => x_pqvv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSUVB.pls call okl_setuppqvalues_pvt.get_rec ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setuppqvalues_pvt.get_rec

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
  -- PROCEDURE insert_pqvalues
  -- Public wrapper for insert_pqvalues process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_pqvalues(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pqyv_rec         IN  pqyv_rec_type,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_pqvv_rec         IN  pqvv_rec_type,
                        	x_pqvv_rec         OUT NOCOPY pqvv_rec_type
						    ) IS
    l_pqvv_rec                        pqvv_rec_type;
    l_pqyv_rec                        pqyv_rec_type;
    l_pdtv_rec                        pdtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_pqvalues';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_pqvalues;
    l_pqvv_rec := p_pqvv_rec;
    l_pqyv_rec := p_pqyv_rec;
    l_pdtv_rec := p_pdtv_rec;



	-- call process api to insert pqvalues
-- Start of wraper code generated automatically by Debug code generator for okl_setuppqvalues_pvt.insert_pqvalues
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSUVB.pls call okl_setuppqvalues_pvt.insert_pqvalues ');
    END;
  END IF;
    okl_setuppqvalues_pvt.insert_pqvalues(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pqvv_rec      => l_pqvv_rec,
                              			  x_pqvv_rec      => x_pqvv_rec,
										  p_pqyv_rec      => l_pqyv_rec,
										  p_pdtv_rec      => l_pdtv_rec
										  );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSUVB.pls call okl_setuppqvalues_pvt.insert_pqvalues ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setuppqvalues_pvt.insert_pqvalues

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pqvv_rec := x_pqvv_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPQVALUES_PUB','insert_pqvalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_pqvalues;

   ---------------------------------------------------------------------------
  -- PROCEDURE update_pqvalues
  -- Public wrapper for update_pqvalues process api
  ---------------------------------------------------------------------------
  PROCEDURE update_pqvalues(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pqyv_rec         IN  pqyv_rec_type,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_pqvv_rec         IN  pqvv_rec_type,
                        	x_pqvv_rec         OUT NOCOPY pqvv_rec_type
						    ) IS
    l_pqvv_rec                        pqvv_rec_type;
    l_pqyv_rec                        pqyv_rec_type;
    l_pdtv_rec                        pdtv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pqvalues';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_pqvalues;
    l_pqvv_rec := p_pqvv_rec;
    l_pqyv_rec := p_pqyv_rec;
    l_pdtv_rec := p_pdtv_rec;



	-- call process api to update pqvalues
-- Start of wraper code generated automatically by Debug code generator for okl_setuppqvalues_pvt.update_pqvalues
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSUVB.pls call okl_setuppqvalues_pvt.update_pqvalues ');
    END;
  END IF;
    okl_setuppqvalues_pvt.update_pqvalues(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                              			  x_return_status => l_return_status,
                              			  x_msg_count     => x_msg_count,
                              			  x_msg_data      => x_msg_data,
                              			  p_pqvv_rec      => l_pqvv_rec,
                              			  x_pqvv_rec      => x_pqvv_rec,
										  p_pqyv_rec      => l_pqyv_rec,
										  p_pdtv_rec      => l_pdtv_rec
										  );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSUVB.pls call okl_setuppqvalues_pvt.update_pqvalues ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setuppqvalues_pvt.update_pqvalues

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pqvv_rec := x_pqvv_rec;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPQVALUES_PUB','update_pqvalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_pqvalues;
      PROCEDURE insert_pqvalues(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pqyv_rec         IN  pqyv_rec_type,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_pqvv_tbl         IN  pqvv_tbl_type,
                        	x_pqvv_tbl         OUT NOCOPY pqvv_tbl_type
						    ) IS
  l_pqyv_rec						pqyv_rec_type:= p_pqyv_rec ;
    l_pdtv_rec						pdtv_rec_type:= p_pdtv_rec ;
    l_pqvv_tbl						pqvv_tbl_type:= p_pqvv_tbl ;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_dqualitys';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_pqvalues;
		l_pqyv_rec :=      p_pqyv_rec;
        l_pdtv_rec  :=  p_pdtv_rec;
		l_pqvv_tbl      :=   p_pqvv_tbl;
                        	--x_pqvv_tbl      :=   x_pqvv_tbl



	-- call process api to insert dqualitys
-- Start of wraper code generated automatically by Debug code generator for OKL_SETUPPQVALUES_PUB .insert_pqvalues
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSUVB.pls  call OKL_SETUPPQVALUES_PUB.insert_pqvalues ');
    END;
  END IF;
   OKL_SETUPPQVALUES_PVT.insert_pqvalues(p_api_version   => p_api_version,                                            p_init_msg_list => p_init_msg_list,
                              			    x_return_status => l_return_status,
                              			    x_msg_count     => x_msg_count,
                              			    x_msg_data      => x_msg_data,
											p_pqyv_rec  =>        l_pqyv_rec,
							p_pdtv_rec     =>  l_pdtv_rec,
							p_pqvv_tbl       =>    l_pqvv_tbl,
                        	x_pqvv_tbl       =>   x_pqvv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSUVB.pls  call OKL_SETUPPQVALUES_PUB.insert_pqvalues ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_SETUPPQVALUES_PUB .insert_pqvalues

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pqvv_tbl := x_pqvv_tbl;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPQVALUES_PUB','insert_pqvalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_pqvalues;
      PROCEDURE update_pqvalues(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status    OUT NOCOPY VARCHAR2,
                        	x_msg_count        OUT NOCOPY NUMBER,
                        	x_msg_data         OUT NOCOPY VARCHAR2,
                        	p_pqyv_rec         IN  pqyv_rec_type,
							p_pdtv_rec         IN  pdtv_rec_type,
							p_pqvv_tbl         IN  pqvv_tbl_type,
                        	x_pqvv_tbl         OUT NOCOPY pqvv_tbl_type
						    ) IS
  l_pqyv_rec						pqyv_rec_type:= p_pqyv_rec ;
    l_pdtv_rec						pdtv_rec_type:= p_pdtv_rec ;
    l_pqvv_tbl						pqvv_tbl_type:= p_pqvv_tbl ;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_pqvalues';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_pqvalues;
		l_pqyv_rec :=      p_pqyv_rec;
        l_pdtv_rec  :=  p_pdtv_rec;
		l_pqvv_tbl      :=   p_pqvv_tbl;
                        	--x_pqvv_tbl      :=   x_pqvv_tbl



	-- call process api to insert dqualitys
-- Start of wraper code generated automatically by Debug code generator for OKL_SETUPPQVALUES_PUB .insert_pqvalues
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSUVB.pls  call OKL_SETUPPQVALUES_PUB.update_pqvalues ');
    END;
  END IF;
  OKL_SETUPPQVALUES_PVT.update_pqvalues(p_api_version   => p_api_version,                                            p_init_msg_list => p_init_msg_list,
                              			    x_return_status => l_return_status,
                              			    x_msg_count     => x_msg_count,
                              			    x_msg_data      => x_msg_data,
											p_pqyv_rec  =>        l_pqyv_rec,
							p_pdtv_rec     =>  l_pdtv_rec,
							p_pqvv_tbl       =>    l_pqvv_tbl,
                        	x_pqvv_tbl       =>   x_pqvv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSUVB.pls  call OKL_SETUPPQVALUES_PUB.update_pqvalues ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_SETUPPQVALUES_PUB .insert_pqvalues

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_pqvv_tbl := x_pqvv_tbl;




  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_pqvalues;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPPQVALUES_PUB','update_pqvalues');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_pqvalues;


END OKL_SETUPPQVALUES_PUB;

/
