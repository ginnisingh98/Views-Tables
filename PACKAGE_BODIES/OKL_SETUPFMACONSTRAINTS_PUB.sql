--------------------------------------------------------
--  DDL for Package Body OKL_SETUPFMACONSTRAINTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPFMACONSTRAINTS_PUB" AS
/* $Header: OKLPSFCB.pls 120.2 2005/06/03 05:29:14 rirawat noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.FORMULAS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_FMLA_OPRNDS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec(p_fodv_rec			  IN fodv_rec_type,
			        x_return_status		  OUT NOCOPY VARCHAR2,
					x_msg_data			  OUT NOCOPY VARCHAR2,
    				x_no_data_found       OUT NOCOPY BOOLEAN,
					x_fodv_rec			  OUT NOCOPY fodv_rec_type) IS
    l_fodv_rec                        fodv_rec_type;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
	l_no_data_found					  BOOLEAN;
  BEGIN

  	l_fodv_rec := p_fodv_rec;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_no_data_found := TRUE;

-- Start of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.get_rec
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.get_rec ');
    END;
  END IF;
    okl_setupfmaconstraints_pvt.get_rec(p_fodv_rec      => l_fodv_rec,
								        x_return_status => l_return_status,
								  		x_no_data_found => l_no_data_found,
								  		x_fodv_rec	    => x_fodv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.get_rec ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.get_rec

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
  -- PROCEDURE insert_fmaconstraints
  -- Public wrapper for insert_fmaconstraints process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_fmaconstraints(p_api_version      IN  NUMBER,
                                  p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		  x_return_status    OUT NOCOPY VARCHAR2,
                        		  x_msg_count        OUT NOCOPY NUMBER,
                        		  x_msg_data         OUT NOCOPY VARCHAR2,
								  p_fmav_rec		 IN  fmav_rec_type,
                        		  p_fodv_rec         IN  fodv_rec_type,
                        		  x_fodv_rec         OUT NOCOPY fodv_rec_type) IS
	l_fmav_rec						  fmav_rec_type;
    l_fodv_rec                        fodv_rec_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_fmaconstraints';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_fmaconstraints;

    l_fmav_rec := p_fmav_rec;
    l_fodv_rec := p_fodv_rec;



	-- call process api to insert formula operands
-- Start of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.insert_fmaconstraints
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.insert_fmaconstraints ');
    END;
  END IF;
    okl_setupfmaconstraints_pvt.insert_fmaconstraints(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                              			  			  x_return_status => l_return_status,
                              			  			  x_msg_count     => x_msg_count,
                              			  			  x_msg_data      => x_msg_data,
                              			  			  p_fmav_rec      => l_fmav_rec,
                              			  			  p_fodv_rec      => l_fodv_rec,
                              			  			  x_fodv_rec      => x_fodv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.insert_fmaconstraints ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.insert_fmaconstraints

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_fodv_rec := x_fodv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPFMACONSTRAINTS_PUB','insert_fmaconstraints');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_fmaconstraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_fmaconstraints
  -- Public wrapper for update_fmaconstraints process api
  ---------------------------------------------------------------------------
  PROCEDURE update_fmaconstraints(p_api_version      IN  NUMBER,
                                  p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        		  x_return_status    OUT NOCOPY VARCHAR2,
                        		  x_msg_count        OUT NOCOPY NUMBER,
                        		  x_msg_data         OUT NOCOPY VARCHAR2,
  								  p_fmav_rec		 IN  fmav_rec_type,
                      			  p_fodv_rec         IN  fodv_rec_type,
                        		  x_fodv_rec         OUT NOCOPY fodv_rec_type) IS
	l_fmav_rec						  fmav_rec_type;
    l_fodv_rec                        fodv_rec_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_fmaconstraints';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_fmaconstraints;

    l_fmav_rec := p_fmav_rec;
    l_fodv_rec := p_fodv_rec;



	-- call process api to update formula operands
-- Start of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.update_fmaconstraints
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.update_fmaconstraints ');
    END;
  END IF;
    okl_setupfmaconstraints_pvt.update_fmaconstraints(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                              			  			  x_return_status => l_return_status,
                              			  			  x_msg_count     => x_msg_count,
                              			  			  x_msg_data      => x_msg_data,
                              			  			  p_fmav_rec      => l_fmav_rec,
                              			  			  p_fodv_rec      => l_fodv_rec,
                              			  			  x_fodv_rec      => x_fodv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.update_fmaconstraints ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.update_fmaconstraints

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_fodv_rec := x_fodv_rec;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPFMACONSTRAINTS_PUB','update_fmaconstraints');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_fmaconstraints;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_fmaconstraints
  -- Public wrapper for delete_fmaconstraints process api
  ---------------------------------------------------------------------------
  PROCEDURE delete_fmaconstraints(p_api_version      IN  NUMBER,
                                  p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        		  x_return_status    OUT NOCOPY VARCHAR2,
                        		  x_msg_count        OUT NOCOPY NUMBER,
                        		  x_msg_data         OUT NOCOPY VARCHAR2,
                      			  p_fodv_tbl         IN  fodv_tbl_type) IS
    l_fodv_tbl                        fodv_tbl_type;
    l_data                            VARCHAR2(100);
    l_count                           NUMBER ;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_fmaconstraints';
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_delete_fmaconstraints;

    l_fodv_tbl := p_fodv_tbl;



	-- call process api to delete formula operands
-- Start of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.delete_fmaconstraints
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.delete_fmaconstraints ');
    END;
  END IF;
    okl_setupfmaconstraints_pvt.delete_fmaconstraints(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                              			  			  x_return_status => l_return_status,
                              			  			  x_msg_count     => x_msg_count,
                              			  			  x_msg_data      => x_msg_data,
                              			  			  p_fodv_tbl      => l_fodv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.delete_fmaconstraints ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.delete_fmaconstraints

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_delete_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_delete_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPFMACONSTRAINTS_PUB','delete_fmaconstraints');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  						    p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END delete_fmaconstraints;

  -- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FMLA_OPRNDS - TBL : begin
    ---------------------------------------------------------------------------
  -- PROCEDURE insert_fmaconstraints
  -- Public wrapper for insert_fmaconstraints process api
  ---------------------------------------------------------------------------
  PROCEDURE insert_fmaconstraints(p_api_version      IN  NUMBER,
                                  p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_msg_count        OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2,
				  p_fmav_rec		 IN  fmav_rec_type,
				  p_fodv_tbl         IN  fodv_tbl_type,
				  x_fodv_tbl         OUT NOCOPY fodv_tbl_type) IS
    l_fmav_rec			      fmav_rec_type;
    l_fodv_tbl                        fodv_tbl_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'insert_fmaconstraints';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_insert_fmaconstraints;

    l_fmav_rec := p_fmav_rec;
    l_fodv_tbl := p_fodv_tbl;

	-- call process api to insert formula operands
 -- Start of wraper code generated automatically by Debug code generator for okl_setupfmaconstr_t_pvt.insert_fmaconstraints
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.insert_fmaconstraints ');
    END;
  END IF;
    okl_setupfmaconstraints_pvt.insert_fmaconstraints(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
						      x_return_status => l_return_status,
 						      x_msg_count     => x_msg_count,
						      x_msg_data      => x_msg_data,
						      p_fmav_rec      => l_fmav_rec,
						      p_fodv_tbl      => l_fodv_tbl,
						      x_fodv_tbl      => x_fodv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.insert_fmaconstraints ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_setupfmaconstraints_pvt.insert_fmaconstraints

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_fodv_tbl := x_fodv_tbl;



  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_insert_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_insert_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPFMACONSTRAINTS_PUB','insert_fmaconstraints');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END insert_fmaconstraints;
  -- rirawat 03-Feb-05 4149748: Added the following procedure to insert into OKL_FMLA_OPRNDS - TBL : end

  -- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FMLA_OPRNDS - TBL : begin
  ---------------------------------------------------------------------------
  -- PROCEDURE update_fmaconstraints
  -- Public wrapper for update_fmaconstraints process api
  ---------------------------------------------------------------------------
  PROCEDURE update_fmaconstraints(p_api_version      IN  NUMBER,
	                          p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_msg_count        OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2,
				  p_fmav_rec	     IN  fmav_rec_type,
				  p_fodv_tbl         IN  fodv_tbl_type,
				  x_fodv_tbl         OUT NOCOPY fodv_tbl_type) IS
    l_fmav_rec	  		      fmav_rec_type;
    l_fodv_tbl                        fodv_tbl_type;
    l_data                            VARCHAR2(100);
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_fmaconstraints';
    l_count                           NUMBER ;
    l_return_status                   VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT sp_update_fmaconstraints;

    l_fmav_rec := p_fmav_rec;
    l_fodv_tbl := p_fodv_tbl;

  -- call process api to update formula operands

  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.update_fmaconstraints ');
    END;
  END IF;
    okl_setupfmaconstraints_pvt.update_fmaconstraints(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
						      x_return_status => l_return_status,
						      x_msg_count     => x_msg_count,
						      x_msg_data      => x_msg_data,
						      p_fmav_rec      => l_fmav_rec,
						      p_fodv_tbl      => l_fodv_tbl,
					   	      x_fodv_tbl      => x_fodv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPSFCB.pls call okl_setupfmaconstraints_pvt.update_fmaconstraints ');
    END;
  END IF;


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */
    l_fodv_tbl := x_fodv_tbl;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_update_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_update_fmaconstraints;
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SETUPFMACONSTRAINTS_PUB','update_fmaconstraints');

      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE,
	  			p_count   => x_msg_count,
                                p_data    => x_msg_data);
  END update_fmaconstraints;

  -- rirawat 03-Feb-05 4149748: Added the following procedure to update into OKL_FMLA_OPRNDS - TBL : end


END OKL_SETUPFMACONSTRAINTS_PUB;

/
